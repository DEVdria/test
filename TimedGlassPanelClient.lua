--[[
	═══════════════════════════════════════════════════════════
	TIMED GLASS PANEL SYSTEM - CLIENT
	Sistema de cristales con temporizador individual
	═══════════════════════════════════════════════════════════

	UBICACIÓN: StarterPlayer → StarterPlayerScripts → LocalScript

	CARACTERÍSTICAS:
	- Panel 1: 5.0 segundos
	- Panel 2: 4.9 segundos
	- Panel 3: 4.8 segundos
	- Cada panel reduce 0.1s
	- Caída solo visual (cliente)
	- Respawn después de 15 segundos
	- Muestra en consola qué panel tocas

	NO CHOCA CON GLASS BRIDGE
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	FOLDER_NAME = "TimedGlassRow",  -- Nombre del folder en Workspace
	PANEL_PREFIX = "TimedPanel",    -- Prefijo de los paneles

	-- Tiempos
	BASE_TIME = 5.0,                -- Tiempo del primer panel (segundos)
	TIME_REDUCTION = 0.1,           -- Reducción por cada panel
	RESPAWN_TIME = 15,              -- Tiempo de respawn (segundos)

	-- Animación
	FALL_DISTANCE = 30,             -- Distancia de caída (studs)
	FALL_DURATION = 1.5,            -- Duración de la caída
	RESPAWN_DURATION = 1.0,         -- Duración del respawn
}

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local player = Players.LocalPlayer
local panelData = {} -- Almacena información de cada panel

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES AUXILIARES
-- ═══════════════════════════════════════════════════════════

-- Extraer número del panel
local function getPanelNumber(panelName)
	return tonumber(string.match(panelName, "%d+"))
end

-- Calcular tiempo de caída según el número del panel
local function calculateFallTime(panelNumber)
	return CONFIG.BASE_TIME - ((panelNumber - 1) * CONFIG.TIME_REDUCTION)
end

-- Crear tween de caída
local function createFallTween(panel, originalCFrame)
	local goal = {
		CFrame = originalCFrame * CFrame.new(0, -CONFIG.FALL_DISTANCE, 0)
	}

	local tweenInfo = TweenInfo.new(
		CONFIG.FALL_DURATION,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)

	return TweenService:Create(panel, tweenInfo, goal)
end

-- Crear tween de respawn
local function createRespawnTween(panel, originalCFrame)
	local goal = {
		CFrame = originalCFrame
	}

	local tweenInfo = TweenInfo.new(
		CONFIG.RESPAWN_DURATION,
		Enum.EasingStyle.Bounce,
		Enum.EasingDirection.Out
	)

	return TweenService:Create(panel, tweenInfo, goal)
end

-- ═══════════════════════════════════════════════════════════
-- LÓGICA DE ACTIVACIÓN DEL PANEL
-- ═══════════════════════════════════════════════════════════

local function activatePanel(panel, panelNumber, fallTime)
	local data = panelData[panel]

	-- Si ya está activo, no hacer nada
	if data.isActive then
		return
	end

	-- Marcar como activo
	data.isActive = true
	data.startTime = tick()

	print(string.format(
		"⏱️ PANEL %d ACTIVADO | Caerá en %.1f segundos",
		panelNumber,
		fallTime
	))

	-- Iniciar countdown
	task.spawn(function()
		-- Esperar el tiempo de caída
		task.wait(fallTime)

		print(string.format("💥 PANEL %d CAYENDO", panelNumber))

		-- Deshabilitar colisión (solo en cliente)
		panel.CanCollide = false

		-- Animar caída
		local fallTween = createFallTween(panel, data.originalCFrame)
		fallTween:Play()
		fallTween.Completed:Wait()

		print(string.format("⌛ PANEL %d respawnea en %d segundos", panelNumber, CONFIG.RESPAWN_TIME))

		-- Esperar tiempo de respawn
		task.wait(CONFIG.RESPAWN_TIME)

		-- Reactivar colisión
		panel.CanCollide = true

		-- Animar respawn
		local respawnTween = createRespawnTween(panel, data.originalCFrame)
		respawnTween:Play()
		respawnTween.Completed:Wait()

		print(string.format("✅ PANEL %d RESPAWNEADO - Listo de nuevo", panelNumber))

		-- Resetear estado
		data.isActive = false
		data.startTime = nil
	end)
end

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE EVENTOS TOUCHED
-- ═══════════════════════════════════════════════════════════

local function setupPanelTouched(panel, panelNumber, fallTime)
	panel.Touched:Connect(function(hit)
		-- Verificar si es el jugador local
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local character = hit.Parent
			local touchedPlayer = Players:GetPlayerFromCharacter(character)

			-- Solo procesar si es el jugador local
			if touchedPlayer == player then
				print(string.format(
					"👟 PISASTE PANEL %d | Tiempo: %.1fs",
					panelNumber,
					fallTime
				))

				activatePanel(panel, panelNumber, fallTime)
			end
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL SISTEMA
-- ═══════════════════════════════════════════════════════════

local function initializeSystem()
	print("═══════════════════════════════════════════════════════")
	print("TIMED GLASS PANEL SYSTEM - INICIANDO")
	print("═══════════════════════════════════════════════════════")

	-- Buscar el folder
	local folder = workspace:FindFirstChild(CONFIG.FOLDER_NAME)

	if not folder then
		warn("❌ ERROR: No se encontró el folder '" .. CONFIG.FOLDER_NAME .. "' en Workspace")
		warn("Crea un folder llamado '" .. CONFIG.FOLDER_NAME .. "' en Workspace")
		return
	end

	print("✅ Folder encontrado:", folder.Name)

	-- Buscar todos los paneles
	local panels = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("BasePart") and string.match(child.Name, CONFIG.PANEL_PREFIX .. "%d+") then
			table.insert(panels, child)
		end
	end

	if #panels == 0 then
		warn("❌ ERROR: No se encontraron paneles con formato '" .. CONFIG.PANEL_PREFIX .. "#'")
		warn("Los paneles deben llamarse: " .. CONFIG.PANEL_PREFIX .. "1, " .. CONFIG.PANEL_PREFIX .. "2, etc.")
		return
	end

	-- Ordenar paneles por número
	table.sort(panels, function(a, b)
		return getPanelNumber(a.Name) < getPanelNumber(b.Name)
	end)

	print("✅ Paneles encontrados:", #panels)
	print("───────────────────────────────────────────────────────")

	-- Inicializar cada panel
	for _, panel in ipairs(panels) do
		local panelNumber = getPanelNumber(panel.Name)
		local fallTime = calculateFallTime(panelNumber)

		-- Guardar datos del panel
		panelData[panel] = {
			number = panelNumber,
			fallTime = fallTime,
			originalCFrame = panel.CFrame,
			isActive = false,
			startTime = nil
		}

		-- Configurar evento Touched
		setupPanelTouched(panel, panelNumber, fallTime)

		print(string.format(
			"📦 %s | Tiempo de caída: %.1fs",
			panel.Name,
			fallTime
		))
	end

	print("───────────────────────────────────────────────────────")
	print("✅ SISTEMA LISTO - Camina sobre los paneles")
	print("═══════════════════════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR SISTEMA
-- ═══════════════════════════════════════════════════════════

initializeSystem()
