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

-- Progress Bar
local progressBarGui
local progressBarFill
local playerIcon  -- Avatar icon del jugador
local percentageText
local currentLevel = nil -- Nivel activo actual
local levelData = {} -- {levelName -> {startPos, endPos}}
local diedConnection = nil -- Conexión del evento Died

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

	-- Reproducir sonido con velocidad progresiva
	local stepSound = panel:FindFirstChild("StepSound")
	if stepSound then
		-- Calcular posición en el ciclo de 20 paneles (0-19)
		local cyclePosition = (panelNumber - 1) % 20

		-- Velocidad base 1.0, incremento de 0.05 por panel
		-- Panel 1: 1.0, Panel 2: 1.05, ..., Panel 20: 1.95
		-- Panel 21: 1.0 (reinicia), Panel 22: 1.05, etc.
		local playbackSpeed = 1.0 + (cyclePosition * 0.05)

		stepSound.PlaybackSpeed = playbackSpeed
		stepSound:Play()
	end

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

			-- Hacer el panel completamente invisible
			local originalTransparency = panel.Transparency
			panel.Transparency = 1

			-- Ocultar todos los decals
			local decals = {}
			for _, child in ipairs(panel:GetChildren()) do
				if child:IsA("Decal") then
					table.insert(decals, {decal = child, wasVisible = child.Transparency})
					child.Transparency = 1
				end
			end

			-- Animar caída
			local fallTween = createFallTween(panel, data.originalCFrame)
			fallTween:Play()
			fallTween.Completed:Wait()

			-- Ocultar el timer mientras está abajo
			if timerDisplay then
				timerDisplay.Enabled = false
			end

			print(string.format("⌛ %s - PANEL %d respawnea en %d segundos", levelName, panelNumber, CONFIG.RESPAWN_TIME))

			-- Esperar tiempo de respawn
			task.wait(CONFIG.RESPAWN_TIME)

			-- Reactivar colisión
			panel.CanCollide = true

			-- Restaurar transparencia original
			panel.Transparency = originalTransparency

			-- Restaurar decals
			for _, decalData in ipairs(decals) do
				decalData.decal.Transparency = decalData.wasVisible
			end

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
-- SISTEMA DE PROGRESS BAR
-- ═══════════════════════════════════════════════════════════

local function initializeProgressBar()
	-- Buscar la ProgressBarGui en PlayerGui
	local playerGui = player:WaitForChild("PlayerGui")
	progressBarGui = playerGui:FindFirstChild("ProgressBarGui")

	if not progressBarGui then
		warn("⚠️ No se encontró ProgressBarGui en StarterGui")
		warn("Crea la interfaz siguiendo INSTRUCCIONES_PROGRESS_BAR.md")
		return false
	end

	local progressBarFrame = progressBarGui:FindFirstChild("ProgressBarFrame")
	if progressBarFrame then
		progressBarFill = progressBarFrame:FindFirstChild("Fill")
		playerIcon = progressBarFrame:FindFirstChild("PlayerIcon") -- Avatar del jugador
		percentageText = progressBarFrame:FindFirstChild("PercentageText") -- Opcional
	end

	if not progressBarFill then
		warn("⚠️ No se encontró el Frame 'Fill' en la ProgressBarGui")
		return false
	end

	if not playerIcon then
		warn("⚠️ No se encontró 'PlayerIcon' en la ProgressBarGui")
		warn("Agrega un ImageLabel llamado 'PlayerIcon' con tu avatar")
		return false
	end

	-- Configurar el avatar del jugador
	local userId = player.UserId
	playerIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"

	-- Asegurar que empieza oculta
	progressBarGui.Enabled = false

	print("✅ Progress Bar inicializada")
	return true
end

local function showProgressBar(levelName)
	-- Buscar el GUI actualizado cada vez (por si se reseteó)
	local playerGui = player:WaitForChild("PlayerGui")
	progressBarGui = playerGui:FindFirstChild("ProgressBarGui")

	if not progressBarGui then
		warn("⚠️ No se encontró ProgressBarGui al intentar mostrar")
		return
	end

	-- Re-obtener referencias
	local progressBarFrame = progressBarGui:FindFirstChild("ProgressBarFrame")
	if progressBarFrame then
		progressBarFill = progressBarFrame:FindFirstChild("Fill")
		playerIcon = progressBarFrame:FindFirstChild("PlayerIcon")
		percentageText = progressBarFrame:FindFirstChild("PercentageText")
	end

	if not playerIcon then
		warn("⚠️ PlayerIcon no encontrado al mostrar progress bar")
		return
	end

	-- Re-configurar el avatar por si acaso
	local userId = player.UserId
	playerIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"

	currentLevel = levelName
	progressBarGui.Enabled = true
	print(string.format("📊 Progress Bar activada para %s", levelName))
end

local function hideProgressBar()
	-- Buscar el GUI actualizado cada vez
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		progressBarGui = playerGui:FindFirstChild("ProgressBarGui")
		if progressBarGui then
			progressBarGui.Enabled = false
		end
	end

	currentLevel = nil
	print("📊 Progress Bar ocultada")
end

local function updateProgressBar()
	if not progressBarGui or not currentLevel or not playerIcon then return end

	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local levelInfo = levelData[currentLevel]
	if not levelInfo then return end

	-- Calcular progreso basado en la dirección del nivel
	local startPos = levelInfo.startPos
	local endPos = levelInfo.endPos
	local playerPos = humanoidRootPart.Position

	-- Calcular progreso en el eje correcto (usualmente Z)
	local totalDistance = (endPos - startPos).Magnitude
	local currentDistance = (playerPos - startPos).Magnitude

	local progress = math.clamp(currentDistance / totalDistance, 0, 1)

	-- Mover el avatar icon a lo largo de la barra
	-- Position.X.Scale va de 0 (inicio) a 1 (fin)
	playerIcon.Position = UDim2.new(progress, 0, 0.5, 0)

	-- Actualizar texto de porcentaje si existe
	if percentageText then
		percentageText.Text = string.format("%d%%", math.floor(progress * 100))
	end
end

local function detectPlatformTouch()
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Verificar cada nivel
	for levelName, levelInfo in pairs(levelData) do
		local levelFolder = workspace:FindFirstChild(levelName)
		if levelFolder then
			-- Detectar cuando pisa el primer panel (Panel1)
			local firstPanel = levelFolder:FindFirstChild("Panel1")

			if firstPanel then
				-- Verificar si el jugador está sobre el primer panel
				local panelTop = firstPanel.Position.Y + (firstPanel.Size.Y / 2)
				local playerY = humanoidRootPart.Position.Y

				local panelX = firstPanel.Position.X
				local panelZ = firstPanel.Position.Z
				local panelSizeX = firstPanel.Size.X / 2
				local panelSizeZ = firstPanel.Size.Z / 2

				local playerX = humanoidRootPart.Position.X
				local playerZ = humanoidRootPart.Position.Z

				local inXRange = playerX >= (panelX - panelSizeX) and playerX <= (panelX + panelSizeX)
				local inZRange = playerZ >= (panelZ - panelSizeZ) and playerZ <= (panelZ + panelSizeZ)
				local inYRange = playerY >= panelTop - 1 and playerY <= panelTop + 4

				if inXRange and inZRange and inYRange then
					if currentLevel ~= levelName then
						showProgressBar(levelName)
					end
					return
				end
			end

			-- Detectar cuando llega a la EndPlatform (victoria)
			local endPlatform = levelFolder:FindFirstChild("EndPlatform")

			if endPlatform then
				local platformTop = endPlatform.Position.Y + (endPlatform.Size.Y / 2)
				local playerY = humanoidRootPart.Position.Y

				local platformX = endPlatform.Position.X
				local platformZ = endPlatform.Position.Z
				local platformSizeX = endPlatform.Size.X / 2
				local platformSizeZ = endPlatform.Size.Z / 2

				local playerX = humanoidRootPart.Position.X
				local playerZ = humanoidRootPart.Position.Z

				local inXRange = playerX >= (platformX - platformSizeX) and playerX <= (platformX + platformSizeX)
				local inZRange = playerZ >= (platformZ - platformSizeZ) and playerZ <= (platformZ + platformSizeZ)
				local inYRange = playerY >= platformTop - 1 and playerY <= platformTop + 4

				if inXRange and inZRange and inYRange then
					-- Si estaba mostrando la progress bar de este nivel, ocultarla
					if currentLevel == levelName then
						hideProgressBar()
						print(string.format("🏆 ¡Victoria en %s! Progress Bar ocultada", levelName))
					end
				end
			end
		end
	end
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN DE UN NIVEL
-- ═══════════════════════════════════════════════════════════

local function initializeLevel(levelFolder)
	print(string.format("📂 Inicializando %s...", levelFolder.Name))

	-- Esperar a que el primer panel se replique
	local firstPanel = levelFolder:WaitForChild("Panel1", 10)
	if not firstPanel then
		warn(string.format("❌ No se encontró Panel1 en %s", levelFolder.Name))
		return 0
	end

	-- Esperar un poco más para que todos los paneles se repliquen
	print(string.format("⏳ Esperando replicación de paneles en %s...", levelFolder.Name))
	task.wait(0.5)

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

	-- Guardar posiciones de inicio y fin para la progress bar
	-- Usar el primer panel como inicio y la EndPlatform como fin
	local firstPanelInLevel = levelFolder:FindFirstChild("Panel1")
	local endPlatform = levelFolder:FindFirstChild("EndPlatform")

	if firstPanelInLevel and endPlatform then
		levelData[levelFolder.Name] = {
			startPos = firstPanelInLevel.Position,
			endPos = endPlatform.Position
		}
		print(string.format("📍 Inicio (Panel1) y EndPlatform detectadas en %s", levelFolder.Name))
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

		-- Actualizar progress bar si está activa
		if currentLevel then
			updateProgressBar()
		end

		-- Detectar si pisa una plataforma de inicio
		detectPlatformTouch()

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

	-- Detectar cuando el jugador muere para ocultar la progress bar
	player.CharacterAdded:Connect(function(character)
		hideProgressBar() -- Ocultar al respawnear

		-- Desconectar conexión anterior si existe
		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		-- Conectar nueva conexión al humanoid
		local humanoid = character:WaitForChild("Humanoid")
		diedConnection = humanoid.Died:Connect(function()
			hideProgressBar()
		end)
	end)

	-- También conectar para el personaje actual
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			-- Desconectar conexión anterior si existe
			if diedConnection then
				diedConnection:Disconnect()
			end

			diedConnection = humanoid.Died:Connect(function()
				hideProgressBar()
			end)
		end
	end
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
	-- Inicializar progress bar (opcional, funcionará sin ella)
	initializeProgressBar()

	startDetectionLoop()
	print("🔄 Sistema de detección continua activado")
end
