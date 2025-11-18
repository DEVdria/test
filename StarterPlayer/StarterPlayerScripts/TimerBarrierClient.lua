--[[
	TimerBarrierClient.lua
	Cliente del sistema de barrera con temporizador individual

	Coloca este script en: StarterPlayer > StarterPlayerScripts
	IMPORTANTE: Debe ser un LocalScript

	CÓMO FUNCIONA:
	- Al entrar al juego, pregunta al servidor si ya completó el timer
	- Si no ha completado, inicia el temporizador de 15 minutos
	- Muestra el tiempo restante en la barrera (SurfaceGui)
	- Cuando termina, notifica al servidor para desactivar la colisión
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

-- Referencias UI
local barrier = nil
local surfaceGui = nil
local mainFrame = nil
local timerLabel = nil
local statusLabel = nil

print("🕐 Timer Barrier Client iniciado para: " .. player.Name)

-- ============================================
-- ESPERAR RECURSOS
-- ============================================
local remoteEvent = ReplicatedStorage:WaitForChild("TimerBarrierEvent", 10)
local timerDuration = ReplicatedStorage:WaitForChild("TimerDuration", 10)

if not remoteEvent or not timerDuration then
	warn("⚠️ No se encontraron los recursos del servidor")
	return
end

-- ============================================
-- ENCONTRAR BARRERA
-- ============================================
barrier = workspace:WaitForChild(BARRIER_NAME, 10)

if not barrier then
	warn("⚠️ No se encontró la barrera '" .. BARRIER_NAME .. "' en Workspace")
	return
end

print("✅ Barrera encontrada: " .. barrier.Name)

-- ============================================
-- CREAR UI EN LA BARRERA
-- ============================================
local function CreateUI()
	-- Buscar o crear SurfaceGui
	surfaceGui = barrier:FindFirstChild("TimerSurfaceGui")

	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "TimerSurfaceGui"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.AlwaysOnTop = false
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
		surfaceGui.Parent = barrier
	end

	-- Buscar o crear MainFrame
	mainFrame = surfaceGui:FindFirstChild("MainFrame")

	if not mainFrame then
		mainFrame = Instance.new("Frame")
		mainFrame.Name = "MainFrame"
		mainFrame.Size = UDim2.new(1, 0, 1, 0)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		mainFrame.BackgroundTransparency = 0.3
		mainFrame.BorderSizePixel = 0
		mainFrame.Parent = surfaceGui

		-- Esquinas redondeadas
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.05, 0)
		corner.Parent = mainFrame

		-- Borde
		local stroke = Instance.new("UIStroke")
		stroke.Name = "BorderStroke"
		stroke.Color = Color3.fromRGB(255, 100, 100)
		stroke.Thickness = 3
		stroke.Transparency = 0.2
		stroke.Parent = mainFrame
	end

	-- Buscar o crear TimerLabel (tiempo grande)
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

	-- Buscar o crear StatusLabel (texto inferior)
	statusLabel = mainFrame:FindFirstChild("StatusLabel")

	if not statusLabel then
		statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "StatusLabel"
		statusLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
		statusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "⏰ BARRERA ACTIVA"
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		statusLabel.TextScaled = true
		statusLabel.Font = Enum.Font.GothamBold
		statusLabel.TextStrokeTransparency = 0.3
		statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		statusLabel.Parent = mainFrame
	end

	print("✅ UI creada en la barrera")
end

-- ============================================
-- FORMATEAR TIEMPO (segundos → MM:SS)
-- ============================================
local function FormatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- ============================================
-- ACTUALIZAR COLORES SEGÚN TIEMPO
-- ============================================
local function UpdateColors()
	local stroke = mainFrame:FindFirstChild("BorderStroke")

	if hasCompleted then
		-- Verde - Completado
		timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		if stroke then
			stroke.Color = Color3.fromRGB(100, 255, 100)
		end
	elseif timeRemaining <= 60 then
		-- Rojo intenso - Últimos 60 segundos
		timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		if stroke then
			stroke.Color = Color3.fromRGB(255, 50, 50)
		end
	elseif timeRemaining <= 300 then
		-- Naranja - Últimos 5 minutos
		timerLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
		if stroke then
			stroke.Color = Color3.fromRGB(255, 150, 50)
		end
	else
		-- Rojo normal
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		if stroke then
			stroke.Color = Color3.fromRGB(255, 100, 100)
		end
	end
end

-- ============================================
-- ACTUALIZAR UI
-- ============================================
local function UpdateUI()
	if hasCompleted then
		timerLabel.Text = "00:00"
		statusLabel.Text = "✅ BARRERA DESACTIVADA"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
	else
		timerLabel.Text = FormatTime(timeRemaining)
		statusLabel.Text = "⏰ BARRERA ACTIVA"
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end

	UpdateColors()
end

-- ============================================
-- CUANDO EL TEMPORIZADOR TERMINA
-- ============================================
local function OnTimerComplete()
	if hasCompleted then
		return -- Ya completado
	end

	hasCompleted = true
	isRunning = false

	print("✅ Temporizador completado para " .. player.Name)

	-- Actualizar UI
	UpdateUI()

	-- Notificar al servidor
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
-- INICIAR TEMPORIZADOR
-- ============================================
local function StartTimer(duration)
	timeRemaining = duration
	isRunning = true
	hasCompleted = false

	print("⏰ Temporizador iniciado: " .. FormatTime(timeRemaining))

	-- Actualizar UI inicial
	UpdateUI()
end

-- ============================================
-- MARCAR COMO COMPLETADO (sin temporizador)
-- ============================================
local function MarkAsCompleted()
	hasCompleted = true
	isRunning = false
	timeRemaining = 0

	print("✅ Barrera ya completada anteriormente")

	-- Actualizar UI
	UpdateUI()
end

-- ============================================
-- LOOP DE ACTUALIZACIÓN DEL TEMPORIZADOR
-- ============================================
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
	if not isRunning then
		return
	end

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

			-- Parpadeo en los últimos 10 segundos
			if timeRemaining <= 10 then
				timerLabel.TextTransparency = (timeRemaining % 2 == 0) and 0 or 0.5
			else
				timerLabel.TextTransparency = 0
			end
		end
	end
end)

-- ============================================
-- ESCUCHAR RESPUESTAS DEL SERVIDOR
-- ============================================
remoteEvent.OnClientEvent:Connect(function(action, data)
	if action == "StatusResponse" then
		-- Respuesta del servidor con el estado
		local completed = data.hasCompleted
		local duration = data.timerDuration

		print("📡 Estado recibido del servidor:")
		print("   Completado: " .. tostring(completed))
		print("   Duración: " .. duration .. " segundos")

		if completed then
			MarkAsCompleted()
		else
			StartTimer(duration)
		end

	elseif action == "BarrierDisabled" then
		print("✅ Confirmación del servidor: Barrera desactivada")
	end
end)

-- ============================================
-- MANEJAR RESPAWN
-- ============================================
player.CharacterAdded:Connect(function(character)
	print("🔄 Personaje respawneado, solicitando estado...")

	-- Esperar un momento y solicitar estado
	task.wait(1)
	remoteEvent:FireServer("GetStatus")
end)

-- ============================================
-- INICIALIZACIÓN
-- ============================================
CreateUI()

-- Solicitar estado inicial al servidor
print("📡 Solicitando estado inicial al servidor...")
remoteEvent:FireServer("GetStatus")

print("✅ Timer Barrier Client listo")
