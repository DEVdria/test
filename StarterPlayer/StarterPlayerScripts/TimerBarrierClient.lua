--[[
	TimerBarrierClient.lua
	Cliente del sistema de temporizador con barrera local

	Coloca este script en: StarterPlayer > StarterPlayerScripts
	IMPORTANTE: Debe ser un LocalScript

	CÓMO FUNCIONA:
	- Crea una barrera LOCAL (solo visible para este jugador)
	- La barrera bloquea durante 15 minutos
	- Al terminar el timer, la barrera se DESTRUYE
	- Al respawnear, verifica con el servidor si ya completó
	- Si ya completó, NO crea la barrera
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ============================================
-- CONFIGURACIÓN
-- ============================================
local BARRIER_NAME = "TimerBarrier"

-- ============================================
-- VARIABLES
-- ============================================
local timeRemaining = 0
local isRunning = false
local hasCompleted = false

-- Referencias
local visibleBarrier = nil  -- La barrera en Workspace (decorativa)
local localBarrier = nil     -- La barrera LOCAL de este jugador
local surfaceGui = nil
local mainFrame = nil
local timerLabel = nil
local statusLabel = nil

print("🕐 Timer Client iniciado: " .. player.Name)

-- ============================================
-- ESPERAR RECURSOS
-- ============================================
local remoteEvent = ReplicatedStorage:WaitForChild("TimerBarrierEvent", 10)
local timerDuration = ReplicatedStorage:WaitForChild("TimerDuration", 10)

if not remoteEvent or not timerDuration then
	warn("⚠️ No se encontraron recursos del servidor")
	return
end

-- ============================================
-- ENCONTRAR BARRERA VISIBLE
-- ============================================
visibleBarrier = workspace:WaitForChild(BARRIER_NAME, 10)

if not visibleBarrier then
	warn("⚠️ No se encontró '" .. BARRIER_NAME .. "' en Workspace")
	return
end

print("✅ Barrera visible encontrada: " .. visibleBarrier.Name)
print("   (Esta es solo decorativa, la barrera real es local)")

-- ============================================
-- CREAR BARRERA LOCAL (solo para este jugador)
-- ============================================
local function CreateLocalBarrier()
	if localBarrier then
		-- Ya existe, no crear otra
		return
	end

	print("🔨 Creando barrera LOCAL para " .. player.Name)

	-- Crear una copia LOCAL de la barrera visible
	localBarrier = Instance.new("Part")
	localBarrier.Name = "LocalBarrier_" .. player.Name
	localBarrier.Size = visibleBarrier.Size
	localBarrier.CFrame = visibleBarrier.CFrame
	localBarrier.Anchored = true
	localBarrier.CanCollide = true  -- Esta SÍ bloquea
	localBarrier.Transparency = 1   -- Invisible (la visible es decorativa)
	localBarrier.Material = Enum.Material.ForceField
	localBarrier.Parent = workspace

	print("✅ Barrera LOCAL creada")
	print("   - Solo " .. player.Name .. " la ve y colisiona con ella")
	print("   - Se destruirá en 15 minutos")
end

-- ============================================
-- DESTRUIR BARRERA LOCAL
-- ============================================
local function DestroyLocalBarrier()
	if localBarrier then
		print("💥 Destruyendo barrera LOCAL de " .. player.Name)
		localBarrier:Destroy()
		localBarrier = nil
		print("✅ Barrera LOCAL destruida - Ahora puedes pasar")
	end
end

-- ============================================
-- CREAR UI EN LA BARRERA VISIBLE
-- ============================================
local function CreateUI()
	surfaceGui = visibleBarrier:FindFirstChild("TimerSurfaceGui")

	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "TimerSurfaceGui"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.AlwaysOnTop = false
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
		surfaceGui.Parent = visibleBarrier
	end

	mainFrame = surfaceGui:FindFirstChild("MainFrame")

	if not mainFrame then
		mainFrame = Instance.new("Frame")
		mainFrame.Name = "MainFrame"
		mainFrame.Size = UDim2.new(1, 0, 1, 0)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		mainFrame.BackgroundTransparency = 0.3
		mainFrame.BorderSizePixel = 0
		mainFrame.Parent = surfaceGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.05, 0)
		corner.Parent = mainFrame

		local stroke = Instance.new("UIStroke")
		stroke.Name = "BorderStroke"
		stroke.Color = Color3.fromRGB(255, 100, 100)
		stroke.Thickness = 3
		stroke.Transparency = 0.2
		stroke.Parent = mainFrame
	end

	timerLabel = mainFrame:FindFirstChild("TimerLabel")

	if not timerLabel then
		timerLabel = Instance.new("TextLabel")
		timerLabel.Name = "TimerLabel"
		timerLabel.Size = UDim2.new(0.9, 0, 0.45, 0)
		timerLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
		timerLabel.BackgroundTransparency = 1
		timerLabel.Text = "15:00"
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		timerLabel.TextScaled = true
		timerLabel.Font = Enum.Font.GothamBold
		timerLabel.TextStrokeTransparency = 0.5
		timerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		timerLabel.Parent = mainFrame
	end

	statusLabel = mainFrame:FindFirstChild("StatusLabel")

	if not statusLabel then
		statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "StatusLabel"
		statusLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
		statusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "🚫 BARRERA ACTIVA"
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		statusLabel.TextScaled = true
		statusLabel.Font = Enum.Font.GothamBold
		statusLabel.TextStrokeTransparency = 0.3
		statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		statusLabel.Parent = mainFrame
	end

	print("✅ UI creada")
end

-- ============================================
-- FORMATEAR TIEMPO
-- ============================================
local function FormatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- ============================================
-- ACTUALIZAR COLORES
-- ============================================
local function UpdateColors()
	local stroke = mainFrame:FindFirstChild("BorderStroke")

	if hasCompleted then
		timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		if stroke then stroke.Color = Color3.fromRGB(100, 255, 100) end
	elseif timeRemaining <= 60 then
		timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		if stroke then stroke.Color = Color3.fromRGB(255, 50, 50) end
	elseif timeRemaining <= 300 then
		timerLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
		if stroke then stroke.Color = Color3.fromRGB(255, 150, 50) end
	else
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		if stroke then stroke.Color = Color3.fromRGB(255, 100, 100) end
	end
end

-- ============================================
-- ACTUALIZAR UI
-- ============================================
local function UpdateUI()
	if hasCompleted then
		timerLabel.Text = "00:00"
		statusLabel.Text = "✅ PUEDE PASAR"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
	else
		timerLabel.Text = FormatTime(timeRemaining)
		statusLabel.Text = "🚫 BARRERA ACTIVA"
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end

	UpdateColors()
end

-- ============================================
-- CUANDO TERMINA EL TIMER
-- ============================================
local function OnTimerComplete()
	if hasCompleted then return end

	hasCompleted = true
	isRunning = false

	print("✅ Timer completado para " .. player.Name)

	-- DESTRUIR LA BARRERA LOCAL
	DestroyLocalBarrier()

	-- Actualizar UI
	UpdateUI()

	-- Notificar servidor
	remoteEvent:FireServer("TimerCompleted")

	-- Efecto visual
	task.spawn(function()
		for i = 1, 3 do
			mainFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
			task.wait(0.3)
			mainFrame.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
			task.wait(0.3)
		end
	end)
end

-- ============================================
-- INICIAR TIMER
-- ============================================
local function StartTimer(duration)
	timeRemaining = duration
	isRunning = true
	hasCompleted = false

	print("⏰ Timer iniciado: " .. FormatTime(timeRemaining))

	-- CREAR BARRERA LOCAL
	CreateLocalBarrier()

	-- Actualizar UI
	UpdateUI()
end

-- ============================================
-- MARCAR COMO COMPLETADO
-- ============================================
local function MarkAsCompleted()
	hasCompleted = true
	isRunning = false
	timeRemaining = 0

	print("✅ Ya completado anteriormente - No crear barrera")

	-- NO crear barrera local
	-- Actualizar UI
	UpdateUI()
end

-- ============================================
-- LOOP DE ACTUALIZACIÓN
-- ============================================
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
	if not isRunning then return end

	local currentTime = tick()
	local deltaTime = currentTime - lastUpdate

	if deltaTime >= 1 then
		lastUpdate = currentTime
		timeRemaining = timeRemaining - 1

		if timeRemaining <= 0 then
			timeRemaining = 0
			OnTimerComplete()
		else
			UpdateUI()

			if timeRemaining <= 10 then
				timerLabel.TextTransparency = (timeRemaining % 2 == 0) and 0 or 0.5
			else
				timerLabel.TextTransparency = 0
			end
		end
	end
end)

-- ============================================
-- ESCUCHAR SERVIDOR
-- ============================================
remoteEvent.OnClientEvent:Connect(function(action, data)
	if action == "StatusResponse" then
		local completed = data.hasCompleted
		local duration = data.timerDuration

		print("📡 Estado recibido del servidor:")
		print("   Completado: " .. tostring(completed))

		if completed then
			MarkAsCompleted()
		else
			StartTimer(duration)
		end

	elseif action == "BarrierDisabled" then
		print("✅ Confirmación del servidor: Barrera destruida")

	elseif action == "ForceDestroy" then
		-- Comando forzado del servidor para destruir barrera
		print("🔨 Servidor forzó destrucción de barrera")
		hasCompleted = true
		isRunning = false
		DestroyLocalBarrier()
		UpdateUI()

	elseif action == "ForceReset" then
		-- Comando forzado del servidor para resetear
		print("🔨 Servidor forzó reset del timer")
		hasCompleted = false
		DestroyLocalBarrier()
		StartTimer(timerDuration.Value)
	end
end)

-- ============================================
-- MANEJAR RESPAWN
-- ============================================
player.CharacterAdded:Connect(function(character)
	print("🔄 Respawneado, solicitando estado...")
	task.wait(1)
	remoteEvent:FireServer("GetStatus")
end)

-- ============================================
-- INICIALIZAR
-- ============================================
CreateUI()
print("📡 Solicitando estado del servidor...")
remoteEvent:FireServer("GetStatus")
print("✅ Cliente listo")
