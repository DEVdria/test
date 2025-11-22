--[[
	═══════════════════════════════════════════════════════════
	TIMED GLASS PANEL SETUP - SERVER
	Script para crear los paneles automáticamente
	═══════════════════════════════════════════════════════════

	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)

	INSTRUCCIONES:
	1. Pega este código en un Script en ServerScriptService
	2. Ajusta la configuración abajo si quieres
	3. Ejecuta el juego UNA SOLA VEZ
	4. Elimina este script después de crear los paneles
]]

local workspace = game:GetService("Workspace")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	-- Paneles
	FOLDER_NAME = "TimedGlassRow",      -- Nombre del folder
	PANEL_PREFIX = "TimedPanel",        -- Prefijo de los paneles
	NUM_PANELS = 15,                    -- Cuántos paneles crear

	-- Tamaño y posición
	PANEL_SIZE = Vector3.new(5, 0.5, 5), -- Tamaño de cada panel
	START_POSITION = Vector3.new(0, 10, 0), -- Posición del primer panel
	SPACING = 6,                        -- Espacio entre paneles

	-- Dirección de la fila
	DIRECTION = "Z",                    -- X, Y, o Z

	-- Apariencia
	MATERIAL = Enum.Material.Glass,
	TRANSPARENCY = 0.3,
	COLOR = Color3.fromRGB(100, 200, 255), -- Azul claro
	REFLECTANCE = 0.4,

	-- Decals (3 texturas que se aplicarán a cada panel)
	-- ⚠️ IMPORTANTE: Cambia estos IDs por los de tus texturas
	DECAL_TEXTURES = {
		"rbxassetid://11673555479",  -- Textura 1
		"rbxassetid://8257933359",   -- Textura 2
		"rbxassetid://6372755229",   -- Textura 3
	},
	DECAL_TRANSPARENCY = 0.5,
	DECAL_COLOR = Color3.fromRGB(100, 200, 255), -- Color de los decals
}

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Calcular posición del panel según su índice
local function calculatePosition(index)
	local offset = (index - 1) * CONFIG.SPACING
	local pos = CONFIG.START_POSITION

	if CONFIG.DIRECTION == "X" then
		return pos + Vector3.new(offset, 0, 0)
	elseif CONFIG.DIRECTION == "Y" then
		return pos + Vector3.new(0, offset, 0)
	elseif CONFIG.DIRECTION == "Z" then
		return pos + Vector3.new(0, 0, offset)
	else
		warn("⚠️ Dirección no válida, usando Z por defecto")
		return pos + Vector3.new(0, 0, offset)
	end
end

-- Crear decals en el panel
local function createDecals(panel)
	-- Crear 3 decals en la parte superior
	for i, textureId in ipairs(CONFIG.DECAL_TEXTURES) do
		local decalTop = Instance.new("Decal")
		decalTop.Name = "GlassDecalTop" .. i
		decalTop.Face = Enum.NormalId.Top
		decalTop.Texture = textureId
		decalTop.Transparency = CONFIG.DECAL_TRANSPARENCY
		decalTop.Color3 = CONFIG.DECAL_COLOR
		decalTop.Parent = panel
	end

	-- Crear 3 decals en la parte inferior
	for i, textureId in ipairs(CONFIG.DECAL_TEXTURES) do
		local decalBottom = Instance.new("Decal")
		decalBottom.Name = "GlassDecalBottom" .. i
		decalBottom.Face = Enum.NormalId.Bottom
		decalBottom.Texture = textureId
		decalBottom.Transparency = CONFIG.DECAL_TRANSPARENCY
		decalBottom.Color3 = CONFIG.DECAL_COLOR
		decalBottom.Parent = panel
	end
end

-- Crear contador de tiempo encima del panel
local function createTimerDisplay(panel, panelNumber)
	-- Calcular tiempo de caída
	local fallTime = 5.0 - ((panelNumber - 1) * 0.1)

	-- Crear BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TimerDisplay"
	billboard.Size = UDim2.new(4, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)  -- Encima del panel
	billboard.AlwaysOnTop = true
	billboard.Parent = panel

	-- Crear TextLabel
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

	-- Agregar esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = textLabel

	-- Agregar stroke para mejor visibilidad
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Parent = textLabel
end

-- Crear un panel individual
local function createPanel(index, parentFolder)
	local panel = Instance.new("Part")

	-- Nombre
	panel.Name = CONFIG.PANEL_PREFIX .. index

	-- Tamaño y posición
	panel.Size = CONFIG.PANEL_SIZE
	panel.Position = calculatePosition(index)

	-- Física
	panel.Anchored = true
	panel.CanCollide = true

	-- Apariencia
	panel.Material = CONFIG.MATERIAL
	panel.Transparency = CONFIG.TRANSPARENCY
	panel.Color = CONFIG.COLOR
	panel.Reflectance = CONFIG.REFLECTANCE
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth

	-- Parent
	panel.Parent = parentFolder

	-- Agregar decals
	createDecals(panel)

	-- Agregar display de tiempo
	createTimerDisplay(panel, index)

	return panel
end

-- Configurar todo el sistema
local function setupSystem()
	print("═══════════════════════════════════════════════════════")
	print("TIMED GLASS PANEL SETUP - CREANDO PANELES")
	print("═══════════════════════════════════════════════════════")

	-- Verificar si ya existe el folder
	local existingFolder = workspace:FindFirstChild(CONFIG.FOLDER_NAME)
	if existingFolder then
		warn("⚠️ Ya existe el folder '" .. CONFIG.FOLDER_NAME .. "', eliminándolo...")
		existingFolder:Destroy()
		task.wait(0.5)
	end

	-- Crear nuevo folder
	local folder = Instance.new("Folder")
	folder.Name = CONFIG.FOLDER_NAME
	folder.Parent = workspace

	print("✅ Folder creado:", CONFIG.FOLDER_NAME)
	print("───────────────────────────────────────────────────────")

	-- Crear paneles
	for i = 1, CONFIG.NUM_PANELS do
		local panel = createPanel(i, folder)

		-- Calcular tiempo de caída para mostrar info
		local fallTime = 5.0 - ((i - 1) * 0.1)

		print(string.format(
			"📦 %s creado | Posición: %s | Tiempo: %.1fs",
			panel.Name,
			tostring(panel.Position),
			fallTime
		))
	end

	print("───────────────────────────────────────────────────────")
	print("✅ SISTEMA CREADO EXITOSAMENTE")
	print("Total de paneles:", CONFIG.NUM_PANELS)
	print("═══════════════════════════════════════════════════════")
	print("")
	print("SIGUIENTE PASO:")
	print("1. Detén el juego")
	print("2. ELIMINA ESTE SCRIPT (ya no lo necesitas)")
	print("3. Coloca 'TimedGlassPanelClient.lua' en StarterPlayerScripts")
	print("4. Presiona Play y camina sobre los paneles")
	print("")
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR
-- ═══════════════════════════════════════════════════════════

local success, error = pcall(setupSystem)

if not success then
	warn("❌ ERROR AL CREAR SISTEMA:", error)
else
	print("✅ Sin errores")
end
