--[[
	GlassBridgeProgressBar.lua
	LocalScript para mostrar barra de progreso del Glass Bridge

	Coloca este script en: StarterPlayer > StarterPlayerScripts
	IMPORTANTE: Este debe ser un LocalScript, NO un Script normal
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que la configuración esté disponible
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Config = require(ModuleScripts:WaitForChild("GlassBridgeConfig"))

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GlassBridgeProgressUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Frame contenedor principal (centrado arriba)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.4, 0, 0.05, 0) -- 40% ancho, 5% alto
mainFrame.Position = UDim2.new(0.3, 0, 0.02, 0) -- Centrado horizontalmente, 2% desde arriba
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.3
mainFrame.Parent = screenGui

-- Esquinas redondeadas para el frame principal
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0.3, 0)
mainCorner.Parent = mainFrame

-- Borde exterior decorativo
local borderStroke = Instance.new("UIStroke")
borderStroke.Color = Color3.fromRGB(255, 255, 255)
borderStroke.Thickness = 2
borderStroke.Transparency = 0.5
borderStroke.Parent = mainFrame

-- Frame de la barra de progreso (interior)
local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(0, 0, 1, 0) -- Comienza en 0% de ancho
progressBar.Position = UDim2.new(0, 0, 0, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Verde brillante
progressBar.BorderSizePixel = 0
progressBar.Parent = mainFrame

-- Esquinas redondeadas para la barra de progreso
local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0.3, 0)
progressCorner.Parent = progressBar

-- Gradiente para la barra de progreso (de azul a verde)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)), -- Azul
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 255, 180)), -- Cyan
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 100)) -- Verde
})
gradient.Parent = progressBar

-- Texto de porcentaje
local percentText = Instance.new("TextLabel")
percentText.Name = "PercentText"
percentText.Size = UDim2.new(1, 0, 1, 0)
percentText.Position = UDim2.new(0, 0, 0, 0)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Color3.fromRGB(255, 255, 255)
percentText.TextScaled = true
percentText.Font = Enum.Font.GothamBold
percentText.TextStrokeTransparency = 0.5
percentText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
percentText.Parent = mainFrame

-- Padding para el texto
local textPadding = Instance.new("UIPadding")
textPadding.PaddingLeft = UDim.new(0.05, 0)
textPadding.PaddingRight = UDim.new(0.05, 0)
textPadding.PaddingTop = UDim.new(0.2, 0)
textPadding.PaddingBottom = UDim.new(0.2, 0)
textPadding.Parent = percentText

-- Título "Glass Bridge"
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0.4, 0, 0.03, 0)
titleText.Position = UDim2.new(0.3, 0, 0.08, 0) -- Justo debajo de la barra
titleText.BackgroundTransparency = 1
titleText.Text = "🎮 GLASS BRIDGE"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextStrokeTransparency = 0.3
titleText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleText.Parent = screenGui

-- Calcular posiciones de inicio y fin basadas en el eje X
local startX = Config.StartPosition.X
local endX = Config.StartPosition.X + (Config.NumberOfRows * (Config.PanelSize.X + Config.GapBetweenRows)) + 15

-- Función para actualizar la barra de progreso
local function UpdateProgressBar()
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	-- Obtener posición X del jugador
	local playerX = humanoidRootPart.Position.X

	-- Calcular progreso (0 a 1)
	local progress = math.clamp((playerX - startX) / (endX - startX), 0, 1)

	-- Actualizar tamaño de la barra
	progressBar.Size = UDim2.new(progress, 0, 1, 0)

	-- Actualizar texto de porcentaje
	local percentage = math.floor(progress * 100)
	percentText.Text = percentage .. "%"

	-- Cambiar color según progreso
	if progress >= 1 then
		-- Victoria - Dorado brillante
		progressBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		percentText.Text = "🏆 VICTORIA!"
	elseif progress >= 0.75 then
		-- Casi llegando - Verde brillante
		progressBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	elseif progress >= 0.5 then
		-- Medio camino - Amarillo
		progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
	elseif progress >= 0.25 then
		-- Inicio - Naranja
		progressBar.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
	else
		-- Muy al inicio - Azul
		progressBar.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
	end
end

-- Actualizar cada frame para tener progreso en tiempo real
RunService.RenderStepped:Connect(UpdateProgressBar)

-- Actualizar cuando el personaje respawnea
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("HumanoidRootPart")
	UpdateProgressBar()
end)

print("GlassBridge Progress Bar initialized")
