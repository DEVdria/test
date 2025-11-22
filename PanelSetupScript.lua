--[[
	Panel Setup Script
	Script para crear automáticamente paneles de cristal

	INSTRUCCIONES:
	1. Copia este script en ServerScriptService (o pégalo en la Command Bar)
	2. Ajusta la configuración según tus necesidades
	3. Ejecuta el script una sola vez
	4. Elimina el script después de crear los paneles

	NOTA: Este script corre del lado del servidor
]]

local workspace = game:GetService("Workspace")

-- ========================================
-- CONFIGURACIÓN
-- ========================================

local CONFIG = {
	-- Configuración de los paneles
	NUM_PANELS = 15, -- Número de paneles a crear
	PANEL_SIZE = Vector3.new(4, 0.5, 4), -- Tamaño de cada panel

	-- Posicionamiento
	START_POSITION = Vector3.new(0, 5, 0), -- Posición del primer panel
	SPACING = 5, -- Espacio entre paneles (en studs)
	DIRECTION = "Z", -- Dirección de la fila: "X", "Y", o "Z"

	-- Apariencia
	MATERIAL = Enum.Material.Glass, -- Material del panel
	TRANSPARENCY = 0.3, -- Transparencia (0 = opaco, 1 = invisible)
	COLOR = Color3.fromRGB(173, 216, 230), -- Color azul claro
	REFLECTANCE = 0.3, -- Reflectividad (0-1)

	-- Física
	ANCHORED = true, -- Los paneles deben estar anclados
	CAN_COLLIDE = true, -- Los paneles deben tener colisión

	-- Configuración del folder
	FOLDER_NAME = "GlassRow", -- Nombre del folder en Workspace
}

-- ========================================
-- FUNCIONES
-- ========================================

--[[
	Función: calculatePosition
	Calcula la posición de un panel basándose en su índice
]]
local function calculatePosition(index)
	local offset = (index - 1) * CONFIG.SPACING
	local position = CONFIG.START_POSITION

	if CONFIG.DIRECTION == "X" then
		position = position + Vector3.new(offset, 0, 0)
	elseif CONFIG.DIRECTION == "Y" then
		position = position + Vector3.new(0, offset, 0)
	elseif CONFIG.DIRECTION == "Z" then
		position = position + Vector3.new(0, 0, offset)
	else
		warn("Dirección no válida:", CONFIG.DIRECTION)
		position = position + Vector3.new(0, 0, offset)
	end

	return position
end

--[[
	Función: createPanel
	Crea un panel con la configuración especificada
]]
local function createPanel(index, parent)
	local panel = Instance.new("Part")

	-- Configuración básica
	panel.Name = "Panel" .. index
	panel.Size = CONFIG.PANEL_SIZE
	panel.Position = calculatePosition(index)

	-- Física
	panel.Anchored = CONFIG.ANCHORED
	panel.CanCollide = CONFIG.CAN_COLLIDE

	-- Apariencia
	panel.Material = CONFIG.MATERIAL
	panel.Transparency = CONFIG.TRANSPARENCY
	panel.Color = CONFIG.COLOR
	panel.Reflectance = CONFIG.REFLECTANCE

	-- Configuración adicional
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth

	-- Asignar parent
	panel.Parent = parent

	return panel
end

--[[
	Función: setupGlassRow
	Configura toda la fila de paneles
]]
local function setupGlassRow()
	print("=================================")
	print("Configurando Glass Panel System")
	print("=================================")

	-- Verificar si ya existe el folder
	local existingFolder = workspace:FindFirstChild(CONFIG.FOLDER_NAME)
	if existingFolder then
		warn("Ya existe un folder con el nombre:", CONFIG.FOLDER_NAME)
		warn("Eliminando folder existente...")
		existingFolder:Destroy()
		task.wait(0.1)
	end

	-- Crear nuevo folder
	local glassRow = Instance.new("Folder")
	glassRow.Name = CONFIG.FOLDER_NAME
	glassRow.Parent = workspace

	print("Folder creado:", CONFIG.FOLDER_NAME)

	-- Crear paneles
	print("Creando", CONFIG.NUM_PANELS, "paneles...")

	for i = 1, CONFIG.NUM_PANELS do
		local panel = createPanel(i, glassRow)

		-- Calcular tiempo de caída para información
		local fallTime = 5.0 - ((i - 1) * 0.1)

		print(string.format(
			"Panel %d creado - Posición: %s - Tiempo de caída: %.1fs",
			i,
			tostring(panel.Position),
			fallTime
		))
	end

	print("=================================")
	print("✅ Sistema creado exitosamente!")
	print("Total de paneles:", CONFIG.NUM_PANELS)
	print("=================================")
	print("")
	print("SIGUIENTE PASO:")
	print("1. Coloca el LocalScript 'GlassPanelSystem' en StarterPlayerScripts")
	print("2. Presiona Play (F5) para probar")
	print("3. Camina sobre los paneles")
	print("")
end

-- ========================================
-- EJECUCIÓN
-- ========================================

-- Ejecutar configuración
local success, errorMsg = pcall(setupGlassRow)

if not success then
	warn("Error al crear el sistema:", errorMsg)
else
	print("Sistema creado sin errores")
end
