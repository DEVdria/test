--[[
	LEVEL PROGRESS BAR - LocalScript
	Actualiza una barra de progreso que muestra el avance del nivel del jugador

	UBICACIÓN: StarterGui/PrincipalGui/LevelProgressBar (LocalScript)
	         (Dentro del ScreenGui donde diseñaste la barra)

	TÚ DISEÑAS LA BARRA, este script solo:
	- Actualiza el tamaño del Frame interior (la barra que se llena)
	- Actualiza TextLabels con información de nivel/XP
	- Se sincroniza automáticamente cuando el jugador gana XP o sube de nivel

	ESTRUCTURA ESPERADA:
	PrincipalGui (ScreenGui)
	└─ LevelProgressBarContainer (Frame) - El contenedor principal de la barra
	   ├─ ProgressBar (Frame) - La barra que se llena (escala su Size.X.Scale de 0 a 1)
	   ├─ LevelLabel (TextLabel) [OPCIONAL] - Muestra el nivel actual (ej: "Nivel 5")
	   ├─ XPLabel (TextLabel) [OPCIONAL] - Muestra XP actual/requerida (ej: "450 / 1000 XP")
	   └─ PercentLabel (TextLabel) [OPCIONAL] - Muestra porcentaje (ej: "45%")
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Obtener el ScreenGui directamente desde el parent del script
local screenGui = script.Parent
if not screenGui or not screenGui:IsA("ScreenGui") then
	warn("[LevelProgressBar] ❌ Este script debe estar dentro del ScreenGui (PrincipalGui)")
	return
end

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[LevelProgressBar] ❌ No se encontró carpeta Modules")
	return
end

local LevelManager = require(Modules:WaitForChild("LevelManager", 10))
if not LevelManager then
	warn("[LevelProgressBar] ❌ No se encontró LevelManager")
	return
end

print("[LevelProgressBar] 🎯 Inicializando barra de progreso de nivel...")

-- ==================== CONFIGURACIÓN ====================

-- Nombres de los elementos de la GUI (puedes cambiarlos si usas otros nombres)
local CONFIG = {
	ContainerName = "LevelProgressBarContainer",  -- Frame contenedor principal
	ProgressBarName = "ProgressBar",              -- Frame que se llena (hijo del contenedor)
	LevelLabelName = "LevelLabel",                -- TextLabel que muestra el nivel
	XPLabelName = "XPLabel",                      -- TextLabel que muestra XP actual/requerida
	PercentLabelName = "PercentLabel",            -- TextLabel que muestra porcentaje
}

-- ==================== BUSCAR GUI ====================

-- Buscar contenedor principal
local container = screenGui:FindFirstChild(CONFIG.ContainerName, true)
if not container then
	warn(string.format("[LevelProgressBar] ❌ No se encontró Frame contenedor: %s", CONFIG.ContainerName))
	warn("[LevelProgressBar] 📘 Crea un Frame llamado 'LevelProgressBarContainer' en tu ScreenGui")
	return
end

-- Buscar barra de progreso (el Frame que se escala)
local progressBar = container:FindFirstChild(CONFIG.ProgressBarName)
if not progressBar then
	warn(string.format("[LevelProgressBar] ❌ No se encontró ProgressBar: %s", CONFIG.ProgressBarName))
	warn("[LevelProgressBar] 📘 Crea un Frame llamado 'ProgressBar' dentro de 'LevelProgressBarContainer'")
	return
end

-- Buscar TextLabels opcionales
local levelLabel = container:FindFirstChild(CONFIG.LevelLabelName, true)
local xpLabel = container:FindFirstChild(CONFIG.XPLabelName, true)
local percentLabel = container:FindFirstChild(CONFIG.PercentLabelName, true)

print("[LevelProgressBar] ✅ GUI encontrada correctamente")
if levelLabel then print("[LevelProgressBar] 📊 LevelLabel encontrado") end
if xpLabel then print("[LevelProgressBar] 📊 XPLabel encontrado") end
if percentLabel then print("[LevelProgressBar] 📊 PercentLabel encontrado") end

-- ==================== FUNCIONES ====================

-- Formatea números con separadores de miles (1000 → 1,000)
local function formatNumber(num)
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Actualiza la barra de progreso y los labels
local function updateProgressBar()
	-- Obtener leaderstats del jugador
	local leaderstats = player:WaitForChild("leaderstats", 5)
	if not leaderstats then
		warn("[LevelProgressBar] ⚠️ No se encontraron leaderstats")
		return
	end

	local levelValue = leaderstats:FindFirstChild("Level")
	local currentEXPValue = leaderstats:FindFirstChild("CurrentEXP")
	local rebirthsValue = leaderstats:FindFirstChild("Rebirths")

	if not levelValue or not currentEXPValue or not rebirthsValue then
		warn("[LevelProgressBar] ⚠️ Faltan valores en leaderstats")
		return
	end

	local currentLevel = levelValue.Value
	local currentXP = currentEXPValue.Value
	local rebirths = rebirthsValue.Value

	-- Obtener información del nivel usando LevelManager
	local levelInfo = LevelManager.GetLevelInfo(currentLevel, currentXP, rebirths)

	-- Calcular progreso (0 a 1)
	local progress = levelInfo.Progress

	-- Actualizar barra de progreso (escalar el tamaño)
	progressBar.Size = UDim2.new(progress, 0, progressBar.Size.Y.Scale, 0)

	-- Actualizar TextLabels si existen
	if levelLabel then
		levelLabel.Text = string.format("Nivel %d", currentLevel)
	end

	if xpLabel then
		if levelInfo.IsAtMaxLevel then
			xpLabel.Text = "MAX NIVEL"
		else
			xpLabel.Text = string.format("%s / %s XP",
				formatNumber(currentXP),
				formatNumber(levelInfo.XPRequired))
		end
	end

	if percentLabel then
		local percent = math.floor(progress * 100)
		percentLabel.Text = string.format("%d%%", percent)
	end
end

-- ==================== EVENTOS ====================

-- Actualizar cuando cambian los valores del jugador
local leaderstats = player:WaitForChild("leaderstats", 10)
if leaderstats then
	local levelValue = leaderstats:FindFirstChild("Level")
	local currentEXPValue = leaderstats:FindFirstChild("CurrentEXP")
	local rebirthsValue = leaderstats:FindFirstChild("Rebirths")

	if levelValue then
		levelValue.Changed:Connect(function()
			updateProgressBar()
		end)
	end

	if currentEXPValue then
		currentEXPValue.Changed:Connect(function()
			updateProgressBar()
		end)
	end

	if rebirthsValue then
		rebirthsValue.Changed:Connect(function()
			updateProgressBar()
		end)
	end
end

-- ==================== INICIALIZACIÓN ====================

-- Actualizar por primera vez
task.wait(1)  -- Esperar a que los valores estén cargados
updateProgressBar()

-- Actualizar periódicamente (por si acaso)
task.spawn(function()
	while true do
		task.wait(2)  -- Actualizar cada 2 segundos
		updateProgressBar()
	end
end)

print("[LevelProgressBar] ✅ Sistema de barra de progreso inicializado")

-- ==================== NOTAS DE USO ====================
--[[
	CÓMO DISEÑAR TU BARRA DE PROGRESO:

	1. Crea un Frame contenedor llamado "LevelProgressBarContainer" en tu ScreenGui
	   - Este es el fondo/borde de la barra
	   - Tamaño recomendado: {0.3, 0}, {0.05, 0} (30% ancho, 5% alto)
	   - Posición: donde quieras en pantalla

	2. Dentro del contenedor, crea un Frame llamado "ProgressBar"
	   - Este es la barra que se llena
	   - Tamaño inicial: {0, 0}, {1, 0} (empieza vacía, altura 100% del contenedor)
	   - Posición: {0, 0}, {0, 0} (esquina superior izquierda)
	   - AnchorPoint: (0, 0)
	   - Color: Verde, azul, o el que prefieras
	   - El script modificará automáticamente su Size.X.Scale de 0 a 1

	3. [OPCIONAL] Añade TextLabels para mostrar información:
	   - "LevelLabel": Muestra "Nivel X"
	   - "XPLabel": Muestra "X / Y XP"
	   - "PercentLabel": Muestra "X%"

	4. Coloca este script (LevelProgressBar) dentro del ScreenGui

	EJEMPLO DE JERARQUÍA:
	StarterGui
	└─ PrincipalGui (ScreenGui)
	   ├─ LevelProgressBar (LocalScript) ← ESTE SCRIPT
	   └─ LevelProgressBarContainer (Frame) - Fondo/borde
	      ├─ ProgressBar (Frame) - Barra que se llena
	      ├─ LevelLabel (TextLabel) [OPCIONAL]
	      ├─ XPLabel (TextLabel) [OPCIONAL]
	      └─ PercentLabel (TextLabel) [OPCIONAL]

	PERSONALIZACIÓN:
	- Cambia los colores, bordes, efectos de los Frames como quieras
	- Añade UIGradient, UICorner, UIStroke para hacer la barra más bonita
	- Cambia la fuente, tamaño, color de los TextLabels
	- El script solo actualiza el tamaño del ProgressBar y el texto de los labels
]]
