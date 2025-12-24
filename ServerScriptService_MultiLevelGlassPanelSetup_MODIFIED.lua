--[[
	═══════════════════════════════════════════════════════════
	MULTI-LEVEL GLASS PANEL SETUP - SERVER (CON SISTEMA DE DINERO)
	Sistema de paneles con múltiples niveles + Recompensas de dinero
	═══════════════════════════════════════════════════════════
	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)
	NUEVO: Sistema de recompensas de dinero por nivel
	- Nivel 1 = 1 dinero, Nivel 2 = 2 dinero, etc. (configurable)
	- SurfaceGui en la parte superior con el tiempo
	- SurfaceGui en el lado derecho con el dinero (rotado 90°)
]]

local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════
-- CREAR REMOTEEVENT PARA DINERO
-- ═══════════════════════════════════════════════════════════

local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

local givePanelMoneyEvent = remoteEventsFolder:FindFirstChild("GivePanelMoney")
if not givePanelMoneyEvent then
	givePanelMoneyEvent = Instance.new("RemoteEvent")
	givePanelMoneyEvent.Name = "GivePanelMoney"
	givePanelMoneyEvent.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'GivePanelMoney' creado")
end

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE NIVELES (CON DINERO)
-- ═══════════════════════════════════════════════════════════

local LEVELS = {
	-- NIVEL 1
	{
		name = "Level1",
		numPanels = 32,
		moneyReward = 1,  -- 💰 DINERO QUE DA CADA PANEL

		timeGroups = {
			{count = 10, time = 5.0},
			{count = 10, time = 4.9},
			{count = 10, time = 4.8},
			{count = 12, time = 4.7},
		},

		startPosition = Vector3.new(30, -0.5, 90),
		direction = "Z",
		spacing = 12,

		panelSize = Vector3.new(10, 0.5, 10),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(100, 200, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(100, 200, 255),
	},

	-- NIVEL 2
	{
		name = "Level2",
		numPanels = 42,
		moneyReward = 2,  -- 💰 2 de dinero

		timeGroups = {
			{count = 10, time = 4.0},
			{count = 10, time = 3.5},
			{count = 10, time = 3.2},
		},

		startPosition = Vector3.new(0.2, -0.5, 90),
		direction = "Z",
		spacing = 15,

		panelSize = Vector3.new(10, 0.5, 10),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 200, 100),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 200, 100),
	},

	-- NIVEL 3
	{
		name = "Level3",
		numPanels = 35,
		moneyReward = 3,  -- 💰 3 de dinero

		timeGroups = {
			{count = 10, time = 3.0},
			{count = 10, time = 2.6},
			{count = 5, time = 2.0},
			{count = 10, time = 1.4},
		},

		startPosition = Vector3.new(-29.5,-0.5,90),
		direction = "Z",
		spacing = 21,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(200, 100, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(200, 100, 255),
	},

	-- NIVEL 4
	{
		name = "Level4",
		numPanels = 30,
		moneyReward = 4,  -- 💰 4 de dinero

		timeGroups = {
			{count = 10, time = 2.0},
			{count = 10, time = 1.6},
			{count = 10, time = 1.2},
		},

		startPosition = Vector3.new(-88.735, 13.95,90),
		direction = "Z",
		spacing = 22.5,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 255, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 0),
	},

	-- NIVEL 5
	{
		name = "Level5",
		numPanels = 35,
		moneyReward = 5,  -- 💰 5 de dinero

		timeGroups = {
			{count = 10, time = 1.9},
			{count = 10, time = 1.6},
			{count = 10, time = 1.1},
			{count = 5, time = 1.0},
		},

		startPosition = Vector3.new(-118.4, 13.95, 90),
		direction = "Z",
		spacing = 25,

		panelSize = Vector3.new(10, 0.5, 20),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 85, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 85, 0),
	},

	-- NIVEL 6
	{
		name = "Level6",
		numPanels = 70,
		moneyReward = 6,  -- 💰 6 de dinero

		timeGroups = {
			{count = 20, time = 1.3},
			{count = 30, time = 1.0},
			{count = 0, time = 0.6},
			{count = 10, time = 0.4},
		},

		startPosition = Vector3.new(-148.035, 13.95, 90),
		direction = "Z",
		spacing = 9.5,

		panelSize = Vector3.new(10, 0.5, 5),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 255, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 255, 0),
	},

	-- NIVEL 7
	{
		name = "Level7",
		numPanels = 30,
		moneyReward = 7,  -- 💰 7 de dinero

		timeGroups = {
			{count = 10, time = 1.3},
			{count = 10, time = 1.0},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
		},

		startPosition = Vector3.new(-203.635, 28.95,90),
		direction = "Z",
		spacing = 30,

		panelSize = Vector3.new(10, 0.5,26),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 170, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 170, 0),
	},

	-- NIVEL 8
	{
		name = "Level8",
		numPanels = 30,
		moneyReward = 8,  -- 💰 8 de dinero

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},
		},

		startPosition = Vector3.new(-233.3, 28.95,100),
		direction = "Z",
		spacing = 27,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 85, 127),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 85, 127),
	},

	-- NIVEL 9
	{
		name = "Level9",
		numPanels = 25,
		moneyReward = 9,  -- 💰 9 de dinero

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},
		},

		startPosition = Vector3.new(-262.935, 28.95,100),
		direction = "Z",
		spacing = 35,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 0, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 0, 0),
	},

	-- NIVEL 10
	{
		name = "Level10",
		numPanels = 25,
		moneyReward = 10,  -- 💰 10 de dinero

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},
		},

		startPosition = Vector3.new(-332.7, 44.85,110),
		direction = "Z",
		spacing = 42,

		panelSize = Vector3.new(10, 0.5, 37),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 127),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 127),
	},

	-- NIVEL 11
	{
		name = "Level11",
		numPanels = 25,
		moneyReward = 11,

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.4},
		},

		startPosition = Vector3.new(-362.335, 44.85,110),
		direction = "Z",
		spacing = 50,

		panelSize = Vector3.new(10, 0.5, 45),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 0, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 0, 255),
	},

	-- NIVEL 12
	{
		name = "Level12",
		numPanels = 30,
		moneyReward = 12,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},
		},

		startPosition = Vector3.new(-431.635, 60.15,100),
		direction = "Z",
		spacing = 51,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 255),
	},

	-- NIVEL 13
	{
		name = "Level13",
		numPanels = 29,
		moneyReward = 13,

		timeGroups = {
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
			{count = 15, time = 0.3},
		},

		startPosition = Vector3.new(-461.3, 60.15,115),
		direction = "Z",
		spacing = 55,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 0, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 0, 0),
	},

	-- NIVEL 14
	{
		name = "Level14",
		numPanels = 23,
		moneyReward = 14,

		timeGroups = {
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
			{count = 15, time = 0.3},
		},

		startPosition = Vector3.new(-490.935, 60.15,115),
		direction = "Z",
		spacing = 70,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 255, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 255, 0),
	},

	-- NIVEL 15
	{
		name = "Level15",
		numPanels = 63,
		moneyReward = 15,

		timeGroups = {
			{count = 20, time = 0.8},
			{count = 10, time = 0.6},
			{count = 20, time = 0.4},
			{count = 13, time = 0.3},
		},

		startPosition = Vector3.new(-548.135, 75.75,90),
		direction = "Z",
		spacing = 25,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 255, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 255),
	},

	-- NIVEL 16
	{
		name = "Level16",
		numPanels = 26,
		moneyReward = 16,

		timeGroups = {
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},
			{count = 11, time = 0.2},
		},

		startPosition = Vector3.new(-577.8, 75.75,115),
		direction = "Z",
		spacing = 55,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 85, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 85, 255),
	},

	-- NIVEL 17
	{
		name = "Level17",
		numPanels = 25,
		moneyReward = 17,

		timeGroups = {
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
			{count = 10, time = 0.2},
		},

		startPosition = Vector3.new(-607.435, 75.75,100),
		direction = "Z",
		spacing = 65,

		panelSize = Vector3.new(10, 0.5, 55),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 170, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 170, 255),
	},

	-- NIVEL 18
	{
		name = "Level18",
		numPanels = 20,
		moneyReward = 18,

		timeGroups = {
			{count = 5, time = 1.0},
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.3},
		},

		startPosition = Vector3.new(-678.057, 92.55,100),
		direction = "Z",
		spacing = 75,

		panelSize = Vector3.new(10, 0.5, 65),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 170, 0),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 170, 0),
	},

	-- NIVEL 19
	{
		name = "Level19",
		numPanels = 17,
		moneyReward = 19,

		timeGroups = {
			{count = 5, time = 0.9},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 2, time = 0.2},
		},

		startPosition = Vector3.new(-707.692, 92.55,100),
		direction = "Z",
		spacing = 90,

		panelSize = Vector3.new(10, 0.5, 75),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 255, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 255),
	},

	-- NIVEL 20
	{
		name = "Level20",
		numPanels = 7,
		moneyReward = 20,

		timeGroups = {
			{count = 3, time = 0.3},
			{count = 2, time = 0.2},
			{count = 2, time = 0.1},
		},

		startPosition = Vector3.new(-107.9, -0.6, -89.3),
		direction = "X",
		spacing = -100,

		panelSize = Vector3.new(90, 0.5, 10),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 255, 255),
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://100869468561738",
			"rbxassetid://8257933359"
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 255),
	},
}

local RESPAWN_TIME = 15

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

local function calculateFallTime(panelNumber, levelConfig)
	local currentCount = 0
	for _, group in ipairs(levelConfig.timeGroups) do
		currentCount = currentCount + group.count
		if panelNumber <= currentCount then
			return group.time
		end
	end
	return levelConfig.timeGroups[#levelConfig.timeGroups].time
end

local function calculatePosition(index, levelConfig)
	local offset = (index - 1) * levelConfig.spacing
	local pos = levelConfig.startPosition

	if levelConfig.direction == "X" then
		return pos + Vector3.new(offset, 0, 0)
	elseif levelConfig.direction == "Y" then
		return pos + Vector3.new(0, offset, 0)
	elseif levelConfig.direction == "Z" then
		return pos + Vector3.new(0, 0, offset)
	else
		warn("⚠️ Dirección no válida, usando Z por defecto")
		return pos + Vector3.new(0, 0, offset)
	end
end

local function createDecals(panel, levelConfig)
	for i, textureId in ipairs(levelConfig.decalTextures) do
		local decalTop = Instance.new("Decal")
		decalTop.Name = "GlassDecalTop" .. i
		decalTop.Face = Enum.NormalId.Top
		decalTop.Texture = textureId
		decalTop.Transparency = levelConfig.decalTransparency
		decalTop.Color3 = levelConfig.decalColor
		decalTop.Parent = panel

		local decalBottom = Instance.new("Decal")
		decalBottom.Name = "GlassDecalBottom" .. i
		decalBottom.Face = Enum.NormalId.Bottom
		decalBottom.Texture = textureId
		decalBottom.Transparency = levelConfig.decalTransparency
		decalBottom.Color3 = levelConfig.decalColor
		decalBottom.Parent = panel
	end
end

-- Crear SurfaceGui con tiempo (arriba) y dinero (lado derecho, rotado 90°)
local function createTimerDisplay(panel, fallTime, moneyReward)
	-- ═══════════════════════════════════════════════════════
	-- TIEMPO EN LA PARTE SUPERIOR
	-- ═══════════════════════════════════════════════════════
	local timerSurfaceGui = Instance.new("SurfaceGui")
	timerSurfaceGui.Name = "TimerDisplay"
	timerSurfaceGui.Face = Enum.NormalId.Top
	timerSurfaceGui.CanvasSize = Vector2.new(200, 200)
	timerSurfaceGui.LightInfluence = 0
	timerSurfaceGui.AlwaysOnTop = false
	timerSurfaceGui.Parent = panel

	local timerText = Instance.new("TextLabel")
	timerText.Name = "TimerText"
	timerText.Size = UDim2.new(1, 0, 1, 0)
	timerText.BackgroundTransparency = 0.3
	timerText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	timerText.Text = string.format("%.1f", fallTime)
	timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerText.TextScaled = true
	timerText.Font = Enum.Font.GothamBold
	timerText.Parent = timerSurfaceGui

	local timerCorner = Instance.new("UICorner")
	timerCorner.CornerRadius = UDim.new(0.2, 0)
	timerCorner.Parent = timerText

	local timerStroke = Instance.new("UIStroke")
	timerStroke.Thickness = 3
	timerStroke.Color = Color3.fromRGB(0, 0, 0)
	timerStroke.Parent = timerText

	-- ═══════════════════════════════════════════════════════
	-- DINERO EN EL LADO DERECHO (ROTADO 90°)
	-- ═══════════════════════════════════════════════════════
	local moneySurfaceGui = Instance.new("SurfaceGui")
	moneySurfaceGui.Name = "MoneyDisplay"
	moneySurfaceGui.Face = Enum.NormalId.Right  -- Lado derecho
	moneySurfaceGui.CanvasSize = Vector2.new(200, 200)
	moneySurfaceGui.LightInfluence = 0
	moneySurfaceGui.AlwaysOnTop = false
	moneySurfaceGui.Parent = panel

	local moneyText = Instance.new("TextLabel")
	moneyText.Name = "MoneyText"
	moneyText.Size = UDim2.new(1, 0, 1, 0)
	moneyText.BackgroundTransparency = 0.3
	moneyText.BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- Dorado
	moneyText.Text = string.format("💰 %d", moneyReward)
	moneyText.TextColor3 = Color3.fromRGB(0, 0, 0)
	moneyText.TextScaled = true
	moneyText.Font = Enum.Font.GothamBold
	moneyText.Rotation = 90  -- 🔄 ROTADO 90° A LA DERECHA
	moneyText.Parent = moneySurfaceGui

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0.2, 0)
	moneyCorner.Parent = moneyText

	local moneyStroke = Instance.new("UIStroke")
	moneyStroke.Thickness = 3
	moneyStroke.Color = Color3.fromRGB(0, 0, 0)
	moneyStroke.Parent = moneyText
end

local function createPanel(index, levelConfig, parentFolder)
	local panel = Instance.new("Part")
	panel.Name = "Panel" .. index
	panel.Size = levelConfig.panelSize
	panel.Position = calculatePosition(index, levelConfig)
	panel.Anchored = true
	panel.CanCollide = true
	panel.Material = levelConfig.material
	panel.Transparency = levelConfig.transparency
	panel.Color = levelConfig.color
	panel.Reflectance = levelConfig.reflectance
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth
	panel.Parent = parentFolder

	local fallTime = calculateFallTime(index, levelConfig)

	createDecals(panel, levelConfig)
	createTimerDisplay(panel, fallTime, levelConfig.moneyReward)

	-- Guardar el dinero como atributo para que el cliente lo pueda leer
	panel:SetAttribute("MoneyReward", levelConfig.moneyReward)
	panel:SetAttribute("LevelName", levelConfig.name)

	local stepSound = Instance.new("Sound")
	stepSound.Name = "StepSound"
	stepSound.SoundId = "rbxassetid://1169755927"
	stepSound.Volume = 0.5
	stepSound.Parent = panel

	return panel, fallTime
end

local function createLevel(levelConfig)
	print("───────────────────────────────────────────────────────")
	print(string.format("Creando %s con %d paneles (💰 %d por panel)", levelConfig.name, levelConfig.numPanels, levelConfig.moneyReward))

	local existingFolder = workspace:FindFirstChild(levelConfig.name)
	if existingFolder then
		warn("⚠️ Ya existe " .. levelConfig.name .. ", eliminándolo...")
		existingFolder:Destroy()
		task.wait(0.5)
	end

	local folder = Instance.new("Folder")
	folder.Name = levelConfig.name
	folder.Parent = workspace

	for i = 1, levelConfig.numPanels do
		local panel, fallTime = createPanel(i, levelConfig, folder)

		if i % 10 == 0 or i == levelConfig.numPanels then
			print(string.format("  📦 Paneles: %d/%d creados", i, levelConfig.numPanels))
		end
	end

	print(string.format("✅ %s completado", levelConfig.name))
	return folder
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR
-- ═══════════════════════════════════════════════════════════

local function setupAllLevels()
	print("═══════════════════════════════════════════════════════")
	print("MULTI-LEVEL GLASS PANEL SETUP - INICIANDO (CON DINERO)")
	print("═══════════════════════════════════════════════════════")

	for levelIndex, levelConfig in ipairs(LEVELS) do
		createLevel(levelConfig)

		if levelIndex < #LEVELS then
			task.wait(0.05)
		end
	end

	print("═══════════════════════════════════════════════════════")
	print("✅ TODOS LOS NIVELES CREADOS EXITOSAMENTE")
	print(string.format("Total de niveles: %d", #LEVELS))
	print("───────────────────────────────────────────────────────")
	print("SIGUIENTE PASO:")
	print("1. Detén el juego")
	print("2. ELIMINA ESTE SCRIPT (ya no lo necesitas)")
	print("3. Usa el cliente modificado con sistema de dinero")
	print("4. Presiona Play y camina sobre los paneles")
	print("═══════════════════════════════════════════════════════")
end

local success, error = pcall(setupAllLevels)

if not success then
	warn("❌ ERROR AL CREAR NIVELES:", error)
else
	print("✅ Sin errores")
end
