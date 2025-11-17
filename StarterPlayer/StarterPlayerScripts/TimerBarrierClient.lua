--[[
	TimerBarrierClient.lua
	LocalScript para mostrar temporizador individual en la barrera

	Coloca este script en: StarterPlayer > StarterPlayerScripts
	IMPORTANTE: Este debe ser un LocalScript, NO un Script normal
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Configuración
local BARRIER_NAME = "TimerBarrier" -- Nombre de la Part en Workspace

print("🕐 Timer Barrier Client iniciado para: " .. player.Name)

-- Esperar a que los recursos estén disponibles
local remoteEvent = ReplicatedStorage:WaitForChild("TimerBarrierEvent")
local timerDurationValue = ReplicatedStorage:WaitForChild("TimerDuration")

-- Variables del temporizador
local timeRemaining = timerDurationValue.Value -- 15 minutos en segundos
local timerActive = true
local barrierDisabled = false

-- Encontrar la barrera en Workspace
local barrier = workspace:WaitForChild(BARRIER_NAME, 10)

if not barrier then
	warn("⚠️ No se encontró la barrera '" .. BARRIER_NAME .. "' en Workspace")
	return
end

print("✅ Barrera encontrada: " .. barrier.Name)

-- Crear o encontrar el SurfaceGui
local surfaceGui = barrier:FindFirstChild("TimerSurfaceGui")

if not surfaceGui then
	-- Crear nuevo SurfaceGui
	surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "TimerSurfaceGui"
	surfaceGui.Face = Enum.NormalId.Front -- Cara frontal de la Part
	surfaceGui.AlwaysOnTop = false
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 50
	surfaceGui.Parent = barrier
end

-- Crear o encontrar el Frame contenedor
local mainFrame = surfaceGui:FindFirstChild("MainFrame")

if not mainFrame then
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
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
	stroke.Color = Color3.fromRGB(255, 100, 100)
	stroke.Thickness = 3
	stroke.Transparency = 0.2
	stroke.Parent = mainFrame
end

-- Crear o encontrar el TextLabel del temporizador
local timerLabel = mainFrame:FindFirstChild("TimerLabel")

if not timerLabel then
	timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
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

-- Crear o encontrar el TextLabel del título
local titleLabel = mainFrame:FindFirstChild("TitleLabel")

if not titleLabel then
	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
	titleLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "⏰ BARRERA ACTIVA"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextStrokeTransparency = 0.3
	titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.Parent = mainFrame
end

-- Función para formatear tiempo (segundos a MM:SS)
local function FormatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- Función para actualizar el color según el tiempo restante
local function UpdateTimerColor()
	if timeRemaining <= 60 then
		-- Últimos 60 segundos - Rojo parpadeante
		timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		mainFrame:FindFirstChild("UIStroke").Color = Color3.fromRGB(255, 50, 50)
	elseif timeRemaining <= 300 then
		-- Últimos 5 minutos - Naranja
		timerLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
		mainFrame:FindFirstChild("UIStroke").Color = Color3.fromRGB(255, 150, 50)
	else
		-- Tiempo normal - Rojo
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		mainFrame:FindFirstChild("UIStroke").Color = Color3.fromRGB(255, 100, 100)
	end
end

-- Función para cuando el temporizador termina
local function OnTimerEnd()
	if barrierDisabled then
		return
	end

	barrierDisabled = true
	timerActive = false

	print("✅ Temporizador terminado para " .. player.Name)

	-- Actualizar UI
	timerLabel.Text = "00:00"
	timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	titleLabel.Text = "✅ BARRERA DESACTIVADA"
	titleLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	mainFrame:FindFirstChild("UIStroke").Color = Color3.fromRGB(100, 255, 100)

	-- Notificar al servidor
	remoteEvent:FireServer("TimerEnded")

	-- Efecto visual de éxito
	task.spawn(function()
		for i = 1, 3 do
			mainFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
			task.wait(0.3)
			mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			task.wait(0.3)
		end

		-- Después de 5 segundos, ocultar la UI
		task.wait(5)
		surfaceGui.Enabled = false
	end)
end

-- Actualizar temporizador cada segundo
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
	if not timerActive then
		return
	end

	local currentTime = tick()
	local deltaTime = currentTime - lastUpdate

	if deltaTime >= 1 then
		lastUpdate = currentTime
		timeRemaining = timeRemaining - 1

		if timeRemaining <= 0 then
			timeRemaining = 0
			OnTimerEnd()
		else
			-- Actualizar UI
			timerLabel.Text = FormatTime(timeRemaining)
			UpdateTimerColor()

			-- Efecto de parpadeo en los últimos 10 segundos
			if timeRemaining <= 10 then
				timerLabel.TextTransparency = (timeRemaining % 2 == 0) and 0 or 0.5
			end
		end
	end
end)

-- Escuchar confirmación del servidor
remoteEvent.OnClientEvent:Connect(function(action)
	if action == "BarrierDisabled" then
		print("✅ Confirmación del servidor: Barrera desactivada")
	end
end)

-- Resetear cuando el jugador respawnea
player.CharacterAdded:Connect(function(character)
	-- Reiniciar temporizador (opcional - puedes comentar esto si quieres que persista)
	-- timeRemaining = timerDurationValue.Value
	-- timerActive = true
	-- barrierDisabled = false
	-- surfaceGui.Enabled = true
end)

print("✅ Timer Barrier Client configurado")
print("   - Tiempo inicial: " .. FormatTime(timeRemaining))
print("   - Barrera: " .. barrier.Name)
