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
		startPosition = Vector3.new(0, 10, 0),
		direction = "Z",                    -- X, Y, o Z
		spacing = 6,                        -- Espacio entre paneles

		-- Apariencia
		panelSize = Vector3.new(5, 0.5, 5),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(100, 200, 255), -- Azul claro
		reflectance = 0.4,

		-- Decals (3 texturas)
		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://8257933359",
			"rbxassetid://6372755229",
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(100, 200, 255),
	},

	-- NIVEL 2 (ejemplo para cuando lo necesites)
	{
		name = "Level2",
		numPanels = 30,

		timeGroups = {
			{count = 10, time = 4.5},
			{count = 10, time = 4.3},
			{count = 10, time = 4.1},
		},

		startPosition = Vector3.new(50, 10, 0), -- Separado del nivel 1
		direction = "Z",
		spacing = 6,

		panelSize = Vector3.new(5, 0.5, 5),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(255, 200, 100), -- Naranja
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://8257933359",
			"rbxassetid://6372755229",
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(255, 200, 100),
	},

	-- NIVEL 3 (ejemplo para cuando lo necesites)
	{
		name = "Level3",
		numPanels = 25,

		timeGroups = {
			{count = 10, time = 4.0},
			{count = 10, time = 3.8},
			{count = 5, time = 3.6},
		},

		startPosition = Vector3.new(100, 10, 0), -- Separado del nivel 2
		direction = "Z",
		spacing = 6,

		panelSize = Vector3.new(5, 0.5, 5),
		material = Enum.Material.Glass,
		transparency = 0.3,
		color = Color3.fromRGB(200, 100, 255), -- Morado
		reflectance = 0.4,

		decalTextures = {
			"rbxassetid://11673555479",
			"rbxassetid://8257933359",
			"rbxassetid://6372755229",
		},
		decalTransparency = 0.5,
		decalColor = Color3.fromRGB(200, 100, 255),
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
	stepSound.SoundId = "rbxasset://sounds/impact_water.mp3"  -- Sonido de cristal/agua
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
