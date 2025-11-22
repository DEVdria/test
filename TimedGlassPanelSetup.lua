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
