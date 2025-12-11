--[[
	═══════════════════════════════════════════════════════════
	MULTI-LEVEL GLASS PANEL SETUP - SERVER
	Sistema de paneles con múltiples niveles
	═══════════════════════════════════════════════════════════

	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)

	CARACTERÍSTICAS:
	- Múltiples niveles/puentes independientes
	- Configuración de tiempos por grupos de paneles
	- Fácil de configurar y expandir
	- Cada nivel tiene su propia configuración

	INSTRUCCIONES:
	1. Pega este código en un Script en ServerScriptService
	2. Configura los niveles abajo (LEVELS)
	3. Ejecuta el juego UNA SOLA VEZ
	4. Elimina este script después de crear los paneles
]]

local workspace = game:GetService("Workspace")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE NIVELES
-- ═══════════════════════════════════════════════════════════

local LEVELS = {
	-- NIVEL 1
	{
		name = "Level1",                    -- Nombre del nivel
		numPanels = 42,                     -- Total de paneles

		-- Tiempos por grupos
		timeGroups = {
			{count = 10, time = 5.0},       -- Primeros 10 paneles: 5.0 segundos
			{count = 10, time = 4.9},       -- Siguientes 10: 4.9 segundos
			{count = 10, time = 4.8},       -- Siguientes 10: 4.8 segundos
			{count = 12, time = 4.7},       -- Últimos 12: 4.7 segundos
		},

		-- Posición y orientación
		startPosition = Vector3.new(30, -0.5, 90),
		direction = "Z",                    -- X, Y, o Z
		spacing = 12,                        -- Espacio entre paneles

		-- Apariencia
		panelSize = Vector3.new(10, 0.5, 10),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(100, 200, 255), -- Azul claro
		reflectance = 0.4,

		-- Decals (3 texturas)
		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(100, 200, 255),
	},

	-- NIVEL 2 (ejemplo para cuando lo necesites)
	{
		name = "Level2",
		numPanels = 42,

		timeGroups = {
			{count = 10, time = 4.0},
			{count = 10, time = 3.5},
			{count = 10, time = 3.2},
		},

		startPosition = Vector3.new(0.2, -0.5, 90), -- Separado del nivel 1
		direction = "Z",
		spacing = 15,

		panelSize = Vector3.new(10, 0.5, 10),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 200, 100), -- Naranja
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 200, 100),
	},

	-- NIVEL 3 (ejemplo para cuando lo necesites)
	{
		name = "Level3",
		numPanels = 35,

		timeGroups = {
			{count = 10, time = 3.0},
			{count = 10, time = 2.6},
			{count = 5, time = 2.0},
			{count = 10, time = 1.4},
		},

		startPosition = Vector3.new(-29.5,-0.5,90), -- Separado del nivel 2
		direction = "Z",
		spacing = 21,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(200, 100, 255), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(200, 100, 255),
	},
	-- NIVEL 4
	{
		name = "Level4",
		numPanels = 30,

		timeGroups = {
			{count = 10, time = 2.0},
			{count = 10, time = 1.6},
			{count = 10, time = 1.2},

		},

		startPosition = Vector3.new(-80,-0.5,90), -- Separado del nivel 2
		direction = "Z",
		spacing = 22.5,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 255, 0), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 0),
	},
	-- NIVEL 5
	{
		name = "Level5",
		numPanels = 35,

		timeGroups = {
			{count = 10, time = 1.9},
			{count = 10, time = 1.6},
			{count = 10, time = 1.1},
			{count = 5, time = 1.0},

		},

		startPosition = Vector3.new(-110,-0.5,90), -- Separado del nivel
		direction = "Z",
		spacing = 25,

		panelSize = Vector3.new(10, 0.5, 20),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 85, 0), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 85, 0),
	},
	-- NIVEL 6
	{
		name = "Level6",
		numPanels = 70,

		timeGroups = {
			{count = 20, time = 1.3},
			{count = 30, time = 1.0},
			{count = 0, time = 0.6},
			{count = 10, time = 0.4},

		},

		startPosition = Vector3.new(-139.5,-0.5,90), -- Separado del nivel
		direction = "Z",
		spacing = 9.5,

		panelSize = Vector3.new(10, 0.5, 5),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 255, 0), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 255, 0),
	},
	-- NIVEL 7
	{
		name = "Level7",
		numPanels = 30,

		timeGroups = {
			{count = 10, time = 1.3},
			{count = 10, time = 1.0},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},


		},

		startPosition = Vector3.new(-190,-0.5,90), -- Separado del nivel
		direction = "Z",
		spacing = 30,

		panelSize = Vector3.new(10, 0.5,26),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 170, 0), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 170, 0),
	},
	-- NIVEL 8
	{
		name = "Level8",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},


		},

		startPosition = Vector3.new(-220,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 27,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 85, 127), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 85, 127),
	},
	-- NIVEL 9
	{
		name = "Level9",
		numPanels = 25,

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},

		},

		startPosition = Vector3.new(-249.5,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 35,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 0, 0), -- color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 0, 0),
	},
	-- NIVEL 10
	{
		name = "Level10",
		numPanels = 25,

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},

		},

		startPosition = Vector3.new(-316.5,-0.5,110), -- Separado del nivel
		direction = "Z",
		spacing = 42,

		panelSize = Vector3.new(10, 0.5, 37),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 127), -- color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 127),
	},
	-- NIVEL 11
	{
		name = "Level11",
		numPanels = 25,

		timeGroups = {
			{count = 10, time = 1.0},
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.4},

		},

		startPosition = Vector3.new(-345.9,-0.5,110), -- Separado del nivel
		direction = "Z",
		spacing = 50,

		panelSize = Vector3.new(10, 0.5, 45),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 0, 255), -- color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 0, 255),
	},
	-- NIVEL 12
	{
		name = "Level12",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},


		},

		startPosition = Vector3.new(-410,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 51,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 255),
	},
	-- NIVEL 13
	{
		name = "Level13",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
			{count = 15, time = 0.3},


		},

		startPosition = Vector3.new(-440,-0.5,115), -- Separado del nivel
		direction = "Z",
		spacing = 55,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(170, 0, 0), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(170, 0, 0),
	},

	{
		name = "Level14",
		numPanels = 25,

		timeGroups = {
			{count = 5, time = 0.8},
			{count = 5, time = 0.6},
			{count = 5, time = 0.4},
			{count = 15, time = 0.3},


		},

		startPosition = Vector3.new(-469.5,-0.5,115), -- Separado del nivel
		direction = "Z",
		spacing = 70,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 255, 0), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 255, 0),
	},

	{
		name = "Level15",
		numPanels = 72,

		timeGroups = {
			{count = 20, time = 0.8},
			{count = 10, time = 0.6},
			{count = 20, time = 0.4},
			{count = 22, time = 0.3},


		},

		startPosition = Vector3.new(-520,-0.5,90), -- Separado del nivel
		direction = "Z",
		spacing = 25,

		panelSize = Vector3.new(10, 0.5, 15),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(0, 255, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(0, 255, 255),
	},

	{
		name = "Level16",
		numPanels = 28,

		timeGroups = {
			{count = 5, time = 0.7},
			{count = 5, time = 0.5},
			{count = 5, time = 0.3},
			{count = 13, time = 0.2},


		},

		startPosition = Vector3.new(-550,-0.5,115), -- Separado del nivel
		direction = "Z",
		spacing = 55,

		panelSize = Vector3.new(10, 0.5, 50),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 85, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 85, 255),
	},
	-- NIVEL 17
	{
		name = "Level17",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},


		},

		startPosition = Vector3.new(-579.5,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 51,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 255),
	},
	-- NIVEL 18
	{
		name = "Level18",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},


		},

		startPosition = Vector3.new(-643.5,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 51,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 255),
	},
	-- NIVEL 19
	{
		name = "Level19",
		numPanels = 30,

		timeGroups = {
			{count = 5, time = 1.3},
			{count = 5, time = 1.0},
			{count = 5, time = 0.6},
			{count = 15, time = 0.4},


		},

		startPosition = Vector3.new(-673.5,-0.5,100), -- Separado del nivel
		direction = "Z",
		spacing = 51,

		panelSize = Vector3.new(10, 0.5, 30),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(85, 85, 255), -- Color
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479", -- Textura 1 (vidrio agrietado)
			"rbxassetid://100869468561738", -- Textura 2 (puedes cambiar este ID)
			"rbxassetid://8257933359"  -- Textura 3 (puedes cambiar este ID)
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(85, 85, 255),
	},
}

-- Configuración global
local RESPAWN_TIME = 15  -- Tiempo de respawn para todos los niveles

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Calcular tiempo de caída según grupo
local function calculateFallTime(panelNumber, levelConfig)
	local currentCount = 0

	for _, group in ipairs(levelConfig.timeGroups) do
		currentCount = currentCount + group.count
		if panelNumber <= currentCount then
			return group.time
		end
	end

	-- Si se pasa del total, usar el tiempo del último grupo
	return levelConfig.timeGroups[#levelConfig.timeGroups].time
end

-- Calcular posición del panel según su índice
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

-- Crear decals en el panel
local function createDecals(panel, levelConfig)
	for i, textureId in ipairs(levelConfig.decalTextures) do
		-- Top
		local decalTop = Instance.new("Decal")
		decalTop.Name = "GlassDecalTop" .. i
		decalTop.Face = Enum.NormalId.Top
		decalTop.Texture = textureId
		decalTop.Transparency = levelConfig.decalTransparency
		decalTop.Color3 = levelConfig.decalColor
		decalTop.Parent = panel

		-- Bottom
		local decalBottom = Instance.new("Decal")
		decalBottom.Name = "GlassDecalBottom" .. i
		decalBottom.Face = Enum.NormalId.Bottom
		decalBottom.Texture = textureId
		decalBottom.Transparency = levelConfig.decalTransparency
		decalBottom.Color3 = levelConfig.decalColor
		decalBottom.Parent = panel
	end
end

-- Crear contador de tiempo encima del panel
local function createTimerDisplay(panel, fallTime)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TimerDisplay"
	billboard.Size = UDim2.new(4, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = panel

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TimerText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 0.3
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Text = string.format("%.1f", fallTime)
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = textLabel

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Parent = textLabel
end

-- Crear un panel individual
local function createPanel(index, levelConfig, parentFolder)
	local panel = Instance.new("Part")

	-- Nombre
	panel.Name = "Panel" .. index

	-- Tamaño y posición
	panel.Size = levelConfig.panelSize
	panel.Position = calculatePosition(index, levelConfig)

	-- Física
	panel.Anchored = true
	panel.CanCollide = true

	-- Apariencia
	panel.Material = levelConfig.material
	panel.Transparency = levelConfig.transparency
	panel.Color = levelConfig.color
	panel.Reflectance = levelConfig.reflectance
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth

	-- Parent
	panel.Parent = parentFolder

	-- Calcular tiempo de caída
	local fallTime = calculateFallTime(index, levelConfig)

	-- Agregar decals
	createDecals(panel, levelConfig)

	-- Agregar display de tiempo
	createTimerDisplay(panel, fallTime)

	-- Agregar sonido de paso
	local stepSound = Instance.new("Sound")
	stepSound.Name = "StepSound"
	stepSound.SoundId = "rbxassetid://1169755927"  -- Sonido de cristal/agua
	stepSound.Volume = 0.5
	stepSound.Parent = panel

	return panel, fallTime
end

-- Crear un nivel completo
local function createLevel(levelConfig)
	print("───────────────────────────────────────────────────────")
	print(string.format("Creando %s con %d paneles", levelConfig.name, levelConfig.numPanels))

	-- Verificar si ya existe el folder
	local existingFolder = workspace:FindFirstChild(levelConfig.name)
	if existingFolder then
		warn("⚠️ Ya existe " .. levelConfig.name .. ", eliminándolo...")
		existingFolder:Destroy()
		task.wait(0.5)
	end

	-- Crear nuevo folder
	local folder = Instance.new("Folder")
	folder.Name = levelConfig.name
	folder.Parent = workspace

	-- Plataforma de INICIO eliminada (empezar directamente en los cristales)

	-- Crear plataforma de FIN PRIMERO (para que replique antes que los paneles)
	local endPlatform = Instance.new("Part")
	endPlatform.Name = "EndPlatform"
	endPlatform.Size = Vector3.new(10, 1, 10)
	endPlatform.Position = calculatePosition(levelConfig.numPanels + 1, levelConfig) -- Después del último panel
	endPlatform.Anchored = true
	endPlatform.CanCollide = true
	endPlatform.Material = Enum.Material.Neon
	endPlatform.Color = Color3.fromRGB(255, 215, 0) -- Dorado = meta
	endPlatform.TopSurface = Enum.SurfaceType.Smooth
	endPlatform.Parent = folder

	-- Pequeño delay para forzar replicación de EndPlatform antes de paneles
	task.wait(0.05)

	-- Crear paneles
	for i = 1, levelConfig.numPanels do
		local panel, fallTime = createPanel(i, levelConfig, folder)

		print(string.format(
			"  📦 Panel%d | Tiempo: %.1fs",
			i,
			fallTime
		))
	end

	print(string.format("✅ %s completado", levelConfig.name))
	return folder
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR
-- ═══════════════════════════════════════════════════════════

local function setupAllLevels()
	print("═══════════════════════════════════════════════════════")
	print("MULTI-LEVEL GLASS PANEL SETUP - INICIANDO")
	print("═══════════════════════════════════════════════════════")

	for levelIndex, levelConfig in ipairs(LEVELS) do
		createLevel(levelConfig)

		-- Delay gradual entre niveles para evitar saturar la replicación
		-- Niveles más altos necesitan más tiempo para replicar
		if levelIndex < #LEVELS then
			local delay = 0.1 -- Default para Level1-9
			if levelIndex >= 15 then
				delay = 0.5 -- 500ms para Level15-19 (más distantes)
			elseif levelIndex >= 10 then
				delay = 0.3 -- 300ms para Level10-14
			end
			task.wait(delay)
		end
	end

	print("═══════════════════════════════════════════════════════")
	print("✅ TODOS LOS NIVELES CREADOS EXITOSAMENTE")
	print(string.format("Total de niveles: %d", #LEVELS))
	print("───────────────────────────────────────────────────────")
	print("SIGUIENTE PASO:")
	print("1. Detén el juego")
	print("2. ELIMINA ESTE SCRIPT (ya no lo necesitas)")
	print("3. Coloca 'MultiLevelGlassPanelClient.lua' en StarterPlayerScripts")
	print("4. Presiona Play y camina sobre los paneles")
	print("═══════════════════════════════════════════════════════")
end

local success, error = pcall(setupAllLevels)

if not success then
	warn("❌ ERROR AL CREAR NIVELES:", error)
else
	print("✅ Sin errores")
end
