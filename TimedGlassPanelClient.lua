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

	-- Obtener el TextLabel del timer
	local timerDisplay = panel:FindFirstChild("TimerDisplay")
	local timerText = timerDisplay and timerDisplay:FindFirstChild("TimerText")

	-- Iniciar countdown con actualización del texto
	task.spawn(function()
		-- Actualizar el texto cada frame durante el countdown
		local startTime = tick()
		local endTime = startTime + fallTime

		while tick() < endTime do
			local remaining = endTime - tick()

			if timerText then
				timerText.Text = string.format("%.1f", remaining)

				-- Cambiar color según el tiempo restante
				if remaining <= 1 then
					timerText.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Rojo
					timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
				elseif remaining <= 2 then
					timerText.BackgroundColor3 = Color3.fromRGB(200, 100, 0) -- Naranja
					timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
				elseif remaining <= 3 then
					timerText.BackgroundColor3 = Color3.fromRGB(200, 200, 0) -- Amarillo
					timerText.TextColor3 = Color3.fromRGB(0, 0, 0)
				end
			end

			task.wait(0.05) -- Actualizar cada 0.05 segundos
		end

		-- Cuando llega a 0
		if timerText then
			timerText.Text = "💥"
			timerText.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end

		print(string.format("💥 PANEL %d CAYENDO", panelNumber))

		-- Deshabilitar colisión (solo en cliente)
		panel.CanCollide = false

		-- Animar caída
		local fallTween = createFallTween(panel, data.originalCFrame)
		fallTween:Play()
		fallTween.Completed:Wait()

		-- Ocultar el timer mientras respawnea
		if timerDisplay then
			timerDisplay.Enabled = false
		end

		print(string.format("⌛ PANEL %d respawnea en %d segundos", panelNumber, CONFIG.RESPAWN_TIME))

		-- Esperar tiempo de respawn
		task.wait(CONFIG.RESPAWN_TIME)

		-- Reactivar colisión
		panel.CanCollide = true

		-- Animar respawn
		local respawnTween = createRespawnTween(panel, data.originalCFrame)
		respawnTween:Play()
		respawnTween.Completed:Wait()

		-- Restaurar el timer
		if timerDisplay then
			timerDisplay.Enabled = true
		end

		if timerText then
			timerText.Text = string.format("%.1f", fallTime)
			timerText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		print(string.format("✅ PANEL %d RESPAWNEADO - Listo de nuevo", panelNumber))

		-- Resetear estado
		data.isActive = false
		data.startTime = nil
	end)
end

-- ═══════════════════════════════════════════════════════════
-- DETECCIÓN DE POSICIÓN DEL JUGADOR
-- ═══════════════════════════════════════════════════════════

-- Verificar si el jugador está sobre un panel
local function isPlayerOnPanel(panel, character)
	if not character or not character.Parent then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false
	end

	-- Verificar primero el área XZ (horizontal)
	local panelX = panel.Position.X
	local panelZ = panel.Position.Z
	local panelSizeX = panel.Size.X / 2
	local panelSizeZ = panel.Size.Z / 2

	local playerX = humanoidRootPart.Position.X
	local playerZ = humanoidRootPart.Position.Z

	-- El jugador debe estar dentro del área horizontal del panel
	local inXRange = playerX >= (panelX - panelSizeX) and playerX <= (panelX + panelSizeX)
	local inZRange = playerZ >= (panelZ - panelSizeZ) and playerZ <= (panelZ + panelSizeZ)

	if not (inXRange and inZRange) then
		return false
	end

	-- Ahora verificar altura (más tolerante)
	local panelTop = panel.Position.Y + (panel.Size.Y / 2)
	local playerPos = humanoidRootPart.Position.Y

	-- El jugador debe estar cerca de la altura del panel (más o menos 3 studs arriba)
	local heightDiff = playerPos - panelTop
	if heightDiff >= -1 and heightDiff <= 4 then
		return true
	end

	return false
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL SISTEMA
-- ═══════════════════════════════════════════════════════════

local function initializeSystem()
	print("═══════════════════════════════════════════════════════")
	print("TIMED GLASS PANEL SYSTEM - INICIANDO")
	print("═══════════════════════════════════════════════════════")

	-- Buscar el folder (esperar si no existe)
	local folder = workspace:WaitForChild(CONFIG.FOLDER_NAME, 10)

	if not folder then
		warn("❌ ERROR: No se encontró el folder '" .. CONFIG.FOLDER_NAME .. "' en Workspace")
		warn("Crea un folder llamado '" .. CONFIG.FOLDER_NAME .. "' en Workspace")
		return
	end

	print("✅ Folder encontrado:", folder.Name)
	print("⏳ Esperando a que los paneles se carguen...")

	-- Esperar a que al menos un panel exista
	local firstPanel = folder:WaitForChild(CONFIG.PANEL_PREFIX .. "1", 10)

	if not firstPanel then
		warn("❌ ERROR: No se encontró " .. CONFIG.PANEL_PREFIX .. "1")
		warn("Ejecuta el script de servidor primero para crear los paneles")
		return
	end

	-- Esperar un poco más para asegurar que todos los paneles se repliquen
	task.wait(0.5)

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
			startTime = nil,
			wasPlayerOn = false  -- Para detectar cuando el jugador acaba de pisar
		}

		print(string.format(
			"📦 %s | Tiempo de caída: %.1fs",
			panel.Name,
			fallTime
		))
	end

	print("───────────────────────────────────────────────────────")
	print("✅ SISTEMA LISTO - Camina sobre los paneles")
	print("═══════════════════════════════════════════════════════")

	return panels  -- Retornar la lista de paneles
end

-- ═══════════════════════════════════════════════════════════
-- LOOP DE DETECCIÓN CONTINUA
-- ═══════════════════════════════════════════════════════════

local function startDetectionLoop(panels)
	local RunService = game:GetService("RunService")

	-- Actualizar cada frame
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end

		-- Verificar cada panel
		for _, panel in ipairs(panels) do
			if panel and panel.Parent then
				local data = panelData[panel]
				if data then
					local isOn = isPlayerOnPanel(panel, character)

					-- Si el jugador acaba de pisar el panel
					if isOn and not data.wasPlayerOn then
						print(string.format(
							"👟 PISASTE PANEL %d | Tiempo: %.1fs",
							data.number,
							data.fallTime
						))

						activatePanel(panel, data.number, data.fallTime)
					end

					-- Actualizar estado
					data.wasPlayerOn = isOn
				end
			end
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR SISTEMA
-- ═══════════════════════════════════════════════════════════

local panels = initializeSystem()

if panels then
	startDetectionLoop(panels)
	print("🔄 Sistema de detección continua activado")
end
