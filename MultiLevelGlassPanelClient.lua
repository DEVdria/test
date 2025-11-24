--[[
	═══════════════════════════════════════════════════════════
	MULTI-LEVEL GLASS PANEL SYSTEM - CLIENT
	Cliente para sistema de paneles con múltiples niveles
	═══════════════════════════════════════════════════════════

	UBICACIÓN: StarterPlayer → StarterPlayerScripts → LocalScript

	CARACTERÍSTICAS:
	- Soporta múltiples niveles automáticamente
	- Detecta todos los niveles en Workspace
	- Sistema de tiempos por grupos
	- Caída solo visual (cliente)
	- Respawn automático después de 15 segundos
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	-- Nombres de niveles a buscar
	LEVEL_NAMES = {"Level1", "Level2", "Level3"},

	-- Tiempos
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
local allPanels = {} -- Lista de todos los paneles de todos los niveles

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES AUXILIARES
-- ═══════════════════════════════════════════════════════════

-- Extraer número del panel
local function getPanelNumber(panelName)
	return tonumber(string.match(panelName, "%d+"))
end

-- Obtener tiempo de caída desde el timer display
local function getFallTimeFromPanel(panel)
	local timerDisplay = panel:FindFirstChild("TimerDisplay")
	if timerDisplay then
		local timerText = timerDisplay:FindFirstChild("TimerText")
		if timerText then
			local time = tonumber(timerText.Text)
			if time then
				return time
			end
		end
	end
	return 5.0 -- Default
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

local function activatePanel(panel, panelNumber, levelName, fallTime)
	local data = panelData[panel]

	-- Si ya está activo, no hacer nada
	if data.isActive then
		return
	end

	-- Marcar como activo
	data.isActive = true
	data.startTime = tick()

	print(string.format(
		"⏱️ %s - PANEL %d ACTIVADO | Caerá en %.1f segundos",
		levelName,
		panelNumber,
		fallTime
	))

	-- Obtener el TextLabel del timer
	local timerDisplay = panel:FindFirstChild("TimerDisplay")
	local timerText = timerDisplay and timerDisplay:FindFirstChild("TimerText")

	-- Iniciar countdown
	task.spawn(function()
		local success, err = pcall(function()
			-- Actualizar el texto cada frame durante el countdown
			local startTime = tick()
			local endTime = startTime + fallTime

			while tick() < endTime do
				local remaining = endTime - tick()

				if timerText then
					timerText.Text = string.format("%.1f", remaining)

					-- Cambiar color según el tiempo restante
					if remaining <= 1 then
						timerText.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
						timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
					elseif remaining <= 2 then
						timerText.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
						timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
					elseif remaining <= 3 then
						timerText.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
						timerText.TextColor3 = Color3.fromRGB(0, 0, 0)
					end
				end

				task.wait(0.05)
			end

			-- Cuando llega a 0
			if timerText then
				timerText.Text = "💥"
				timerText.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end

			print(string.format("💥 %s - PANEL %d CAYENDO", levelName, panelNumber))

			-- Deshabilitar colisión
			panel.CanCollide = false

			-- Animar caída
			local fallTween = createFallTween(panel, data.originalCFrame)
			fallTween:Play()
			fallTween.Completed:Wait()

			-- Ocultar el timer
			if timerDisplay then
				timerDisplay.Enabled = false
			end

			print(string.format("⌛ %s - PANEL %d respawnea en %d segundos", levelName, panelNumber, CONFIG.RESPAWN_TIME))

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

			print(string.format("✅ %s - PANEL %d RESPAWNEADO", levelName, panelNumber))

			-- Resetear estado
			data.isActive = false
			data.startTime = nil
		end)

		if not success then
			warn(string.format("❌ Error en %s PANEL %d: %s", levelName, panelNumber, tostring(err)))
			data.isActive = false
			data.startTime = nil
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- DETECCIÓN DE POSICIÓN DEL JUGADOR
-- ═══════════════════════════════════════════════════════════

local function isPlayerOnPanel(panel, character)
	if not character or not character.Parent then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false
	end

	-- Verificar área XZ (horizontal)
	local panelX = panel.Position.X
	local panelZ = panel.Position.Z
	local panelSizeX = panel.Size.X / 2
	local panelSizeZ = panel.Size.Z / 2

	local playerX = humanoidRootPart.Position.X
	local playerZ = humanoidRootPart.Position.Z

	local inXRange = playerX >= (panelX - panelSizeX) and playerX <= (panelX + panelSizeX)
	local inZRange = playerZ >= (panelZ - panelSizeZ) and playerZ <= (panelZ + panelSizeZ)

	if not (inXRange and inZRange) then
		return false
	end

	-- Verificar altura
	local panelTop = panel.Position.Y + (panel.Size.Y / 2)
	local playerPos = humanoidRootPart.Position.Y

	local heightDiff = playerPos - panelTop
	if heightDiff >= -1 and heightDiff <= 4 then
		return true
	end

	return false
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN DE UN NIVEL
-- ═══════════════════════════════════════════════════════════

local function initializeLevel(levelFolder)
	print(string.format("📂 Inicializando %s...", levelFolder.Name))

	-- Buscar todos los paneles en el nivel
	local levelPanels = {}
	for _, child in ipairs(levelFolder:GetChildren()) do
		if child:IsA("BasePart") and string.match(child.Name, "Panel%d+") then
			table.insert(levelPanels, child)
		end
	end

	if #levelPanels == 0 then
		warn(string.format("⚠️ No se encontraron paneles en %s", levelFolder.Name))
		return 0
	end

	-- Ordenar paneles por número
	table.sort(levelPanels, function(a, b)
		return getPanelNumber(a.Name) < getPanelNumber(b.Name)
	end)

	-- Inicializar cada panel
	for _, panel in ipairs(levelPanels) do
		local panelNumber = getPanelNumber(panel.Name)
		local fallTime = getFallTimeFromPanel(panel)

		-- Guardar datos del panel
		panelData[panel] = {
			number = panelNumber,
			fallTime = fallTime,
			levelName = levelFolder.Name,
			originalCFrame = panel.CFrame,
			isActive = false,
			startTime = nil,
			wasPlayerOn = false,
		}

		-- Agregar a lista global
		table.insert(allPanels, panel)
	end

	print(string.format("✅ %s: %d paneles cargados", levelFolder.Name, #levelPanels))
	return #levelPanels
end

-- ═══════════════════════════════════════════════════════════
-- LOOP DE DETECCIÓN CONTINUA
-- ═══════════════════════════════════════════════════════════

local function startDetectionLoop()
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end

		-- Verificar cada panel de todos los niveles
		for _, panel in ipairs(allPanels) do
			local success, err = pcall(function()
				if panel and panel.Parent then
					local data = panelData[panel]
					if data then
						local isOn = isPlayerOnPanel(panel, character)

						-- Si el jugador acaba de pisar el panel
						if isOn and not data.wasPlayerOn then
							activatePanel(panel, data.number, data.levelName, data.fallTime)
						end

						-- Actualizar estado
						data.wasPlayerOn = isOn
					end
				end
			end)

			if not success then
				warn("⚠️ Error en detección:", err)
			end
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL SISTEMA
-- ═══════════════════════════════════════════════════════════

local function initializeSystem()
	print("═══════════════════════════════════════════════════════")
	print("MULTI-LEVEL GLASS PANEL SYSTEM - INICIANDO")
	print("═══════════════════════════════════════════════════════")

	local totalPanels = 0
	local levelsFound = 0

	-- Buscar e inicializar cada nivel
	for _, levelName in ipairs(CONFIG.LEVEL_NAMES) do
		local levelFolder = workspace:FindFirstChild(levelName)
		if levelFolder then
			levelsFound = levelsFound + 1
			totalPanels = totalPanels + initializeLevel(levelFolder)
		end
	end

	if levelsFound == 0 then
		warn("❌ ERROR: No se encontraron niveles en Workspace")
		warn("Ejecuta el script de setup primero")
		return false
	end

	print("───────────────────────────────────────────────────────")
	print(string.format("✅ SISTEMA LISTO"))
	print(string.format("   Niveles encontrados: %d", levelsFound))
	print(string.format("   Total de paneles: %d", totalPanels))
	print("═══════════════════════════════════════════════════════")

	return true
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR SISTEMA
-- ═══════════════════════════════════════════════════════════

if initializeSystem() then
	startDetectionLoop()
	print("🔄 Sistema de detección continua activado")
end
