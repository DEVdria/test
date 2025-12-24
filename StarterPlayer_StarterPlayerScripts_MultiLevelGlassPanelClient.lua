--[[
	═══════════════════════════════════════════════════════════
	MULTI-LEVEL GLASS PANEL SYSTEM - CLIENT (CON SISTEMA DE DINERO)
	Cliente para sistema de paneles con múltiples niveles + Dinero
	═══════════════════════════════════════════════════════════
	UBICACIÓN: StarterPlayer → StarterPlayerScripts → LocalScript
	CARACTERÍSTICAS:
	- Soporta múltiples niveles automáticamente
	- Sistema de dinero: da monedas al pisar paneles
	- Sistema de tiempos por grupos
	- Caída solo visual (cliente)
	- Respawn automático después de 7 segundos
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════
-- REMOTEEVENT PARA DINERO
-- ═══════════════════════════════════════════════════════════

local givePanelMoneyEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if remoteEventsFolder then
	givePanelMoneyEvent = remoteEventsFolder:WaitForChild("GivePanelMoney", 10)
	if givePanelMoneyEvent then
		print("✅ RemoteEvent 'GivePanelMoney' encontrado")
	else
		warn("⚠️ No se encontró RemoteEvent 'GivePanelMoney'")
	end
else
	warn("⚠️ No se encontró carpeta RemoteEvents")
end

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	LEVEL_NAMES = {"Level1", "Level2", "Level3", "Level4", "Level5", "Level6", "Level7", "Level8", "Level9", "Level10", "Level11", "Level12", "Level13", "Level14", "Level15", "Level16", "Level17", "Level18", "Level19", "Level20"},

	RESPAWN_TIME = 7,
	REPLICATION_WAIT = 4.0,
	MIN_LEVELS_TO_START = 3,

	FALL_DISTANCE = 30,
	FALL_DURATION = 1.5,
	RESPAWN_DURATION = 1.0,
}

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local player = Players.LocalPlayer
local panelData = {}
local allPanels = {}

local progressBarGui
local progressBarFill
local playerIcon
local percentageText
local currentLevel = nil
local levelData = {}
local diedConnection = nil

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES AUXILIARES
-- ═══════════════════════════════════════════════════════════

local function getPanelNumber(panelName)
	return tonumber(string.match(panelName, "%d+"))
end

local function getFallTimeFromPanel(panel)
	local timerDisplay = panel:WaitForChild("TimerDisplay", 2)
	if timerDisplay then
		local timerText = timerDisplay:WaitForChild("TimerText", 2)
		if timerText then
			local time = tonumber(timerText.Text)
			if time then
				return time
			end
		end
	end
	return 5.0
end

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
-- FUNCIÓN AUXILIAR PARA PROGRESS BAR
-- ═══════════════════════════════════════════════════════════

local function hideProgressBar()
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

-- ═══════════════════════════════════════════════════════════
-- LÓGICA DE ACTIVACIÓN DEL PANEL
-- ═══════════════════════════════════════════════════════════

local function activatePanel(panel, panelNumber, levelName, fallTime)
	local data = panelData[panel]

	if data.isActive then
		return
	end

	data.isActive = true
	data.startTime = tick()

	-- ═══════════════════════════════════════════════════════════
	-- 💰 SISTEMA DE DINERO: DAR DINERO AL PISAR EL PANEL
	-- ═══════════════════════════════════════════════════════════
	if givePanelMoneyEvent and panel then
		local moneyReward = panel:GetAttribute("MoneyReward")
		if moneyReward and moneyReward > 0 then
			local success = pcall(function()
				givePanelMoneyEvent:FireServer(panel)
			end)

			if success then
				print(string.format("💰 %s - PANEL %d: Solicitando %d de dinero",
					levelName, panelNumber, moneyReward))
			else
				warn(string.format("⚠️ Error al solicitar dinero para panel %d", panelNumber))
			end
		end
	end

	if data.isLastPanel then
		print(string.format("🏁 %s - ¡META ALCANZADA! (Panel %d) - Ocultando Progress Bar", levelName, panelNumber))
		hideProgressBar()
	end

	local stepSound = panel:FindFirstChild("StepSound")
	if stepSound then
		local cyclePosition = (panelNumber - 1) % 20
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

	task.spawn(function()
		local success, err = pcall(function()
			local timerDisplay = panel:WaitForChild("TimerDisplay", 2)
			local timerText = timerDisplay and timerDisplay:WaitForChild("TimerText", 2)

			local startTime = tick()
			local endTime = startTime + fallTime

			while tick() < endTime do
				local remaining = endTime - tick()

				if timerText then
					timerText.Text = string.format("%.1f", remaining)

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

			if timerText then
				timerText.Text = "💥"
				timerText.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end

			print(string.format("💥 %s - PANEL %d CAYENDO", levelName, panelNumber))

			panel.CanCollide = false

			local originalTransparency = panel.Transparency
			panel.Transparency = 1

			local decals = {}
			for _, child in ipairs(panel:GetChildren()) do
				if child:IsA("Decal") then
					table.insert(decals, {decal = child, wasVisible = child.Transparency})
					child.Transparency = 1
				end
			end

			local fallTween = createFallTween(panel, data.originalCFrame)
			fallTween:Play()
			fallTween.Completed:Wait()

			if timerDisplay then
				timerDisplay.Enabled = false
			end

			-- También ocultar MoneyDisplay si existe
			local moneyDisplay = panel:FindFirstChild("MoneyDisplay")
			if moneyDisplay then
				moneyDisplay.Enabled = false
			end

			print(string.format("⌛ %s - PANEL %d respawnea en %d segundos", levelName, panelNumber, CONFIG.RESPAWN_TIME))

			task.wait(CONFIG.RESPAWN_TIME)

			panel.CanCollide = true
			panel.Transparency = originalTransparency

			for _, decalData in ipairs(decals) do
				decalData.decal.Transparency = decalData.wasVisible
			end

			local respawnTween = createRespawnTween(panel, data.originalCFrame)
			respawnTween:Play()
			respawnTween.Completed:Wait()

			if timerDisplay then
				timerDisplay.Enabled = true
			end

			if moneyDisplay then
				moneyDisplay.Enabled = true
			end

			if timerText then
				timerText.Text = string.format("%.1f", fallTime)
				timerText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			print(string.format("✅ %s - PANEL %d RESPAWNEADO", levelName, panelNumber))

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
-- DETECCIÓN DE PANELES CON TOUCHED EVENTS (OPTIMIZADO)
-- ═══════════════════════════════════════════════════════════

local function setupPanelTouchedEvents(panel, panelNumber, levelName, fallTime)
	local function onPanelTouched(hit)
		-- Verificar que es el HumanoidRootPart del jugador local
		if hit.Name ~= "HumanoidRootPart" then return end

		local hitCharacter = hit.Parent
		if not hitCharacter or hitCharacter ~= player.Character then return end

		-- Activar el panel
		local data = panelData[panel]
		if data and not data.isActive then
			activatePanel(panel, panelNumber, levelName, fallTime)
		end
	end

	-- Conectar Touched event
	local touchedConnection = panel.Touched:Connect(onPanelTouched)

	-- Guardar conexión para limpieza posterior si es necesario
	if not panelData[panel] then
		panelData[panel] = {}
	end
	panelData[panel].touchedConnection = touchedConnection
end

-- ═══════════════════════════════════════════════════════════
-- SISTEMA DE PROGRESS BAR
-- ═══════════════════════════════════════════════════════════

local function initializeProgressBar()
	local playerGui = player:WaitForChild("PlayerGui")

	progressBarGui = playerGui:WaitForChild("ProgressBarGui", 5)

	if not progressBarGui then
		warn("⚠️ No se encontró ProgressBarGui en PlayerGui")
		return false
	end

	local progressBarFrame = progressBarGui:FindFirstChild("ProgressBarFrame")
	if progressBarFrame then
		progressBarFill = progressBarFrame:FindFirstChild("Fill")
		playerIcon = progressBarFrame:FindFirstChild("PlayerIcon")
		percentageText = progressBarFrame:FindFirstChild("PercentageText")
	end

	if not playerIcon then
		warn("⚠️ No se encontró 'PlayerIcon' en la ProgressBarGui")
		return false
	end

	local userId = player.UserId
	playerIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"

	progressBarGui.Enabled = false

	print("✅ Progress Bar inicializada")
	return true
end

local function showProgressBar(levelName)
	local playerGui = player:WaitForChild("PlayerGui")
	progressBarGui = playerGui:FindFirstChild("ProgressBarGui")

	if not progressBarGui then
		warn("⚠️ No se encontró ProgressBarGui al intentar mostrar")
		return
	end

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

	local userId = player.UserId
	playerIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"

	currentLevel = levelName
	progressBarGui.Enabled = true
	print(string.format("📊 Progress Bar activada para %s", levelName))
end

local function updateProgressBar()
	if not progressBarGui or not currentLevel or not playerIcon then return end

	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local levelInfo = levelData[currentLevel]
	if not levelInfo then return end

	local startPos = levelInfo.startPos
	local endPos = levelInfo.endPos
	local playerPos = humanoidRootPart.Position

	local totalDistance = (endPos - startPos).Magnitude
	local currentDistance = (playerPos - startPos).Magnitude

	local progress = math.clamp(currentDistance / totalDistance, 0, 1)

	playerIcon.Position = UDim2.new(progress, 0, 0.5, 0)

	if percentageText then
		percentageText.Text = string.format("%d%%", math.floor(progress * 100))
	end
end

local function detectPlatformTouch()
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	for levelName, levelInfo in pairs(levelData) do
		local levelFolder = workspace:FindFirstChild(levelName)
		if levelFolder then
			local firstPanel = levelFolder:FindFirstChild("Panel1")

			if firstPanel then
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

	local firstPanel = levelFolder:WaitForChild("Panel1", 10)
	if not firstPanel then
		warn(string.format("❌ No se encontró Panel1 en %s", levelFolder.Name))
		return 0
	end

	print(string.format("⏳ Esperando replicación de paneles en %s...", levelFolder.Name))
	task.wait(CONFIG.REPLICATION_WAIT)

	local levelPanels = {}
	for _, child in ipairs(levelFolder:GetChildren()) do
		if child:IsA("BasePart") and string.match(child.Name, "Panel%d+") then
			table.insert(levelPanels, child)
		end
	end

	print(string.format("🔍 %s: Encontrados %d paneles", levelFolder.Name, #levelPanels))

	if #levelPanels == 0 then
		warn(string.format("❌ No se encontraron paneles en %s", levelFolder.Name))
		return 0
	end

	table.sort(levelPanels, function(a, b)
		return getPanelNumber(a.Name) < getPanelNumber(b.Name)
	end)

	for i, panel in ipairs(levelPanels) do
		local panelNumber = getPanelNumber(panel.Name)
		local fallTime = getFallTimeFromPanel(panel)
		local isLastPanel = (i == #levelPanels)

		panelData[panel] = {
			number = panelNumber,
			fallTime = fallTime,
			levelName = levelFolder.Name,
			originalCFrame = panel.CFrame,
			isActive = false,
			startTime = nil,
			isLastPanel = isLastPanel,
		}

		-- 🚀 OPTIMIZACIÓN: Configurar Touched event en vez de Heartbeat loop
		setupPanelTouchedEvents(panel, panelNumber, levelFolder.Name, fallTime)

		table.insert(allPanels, panel)
	end

	local firstPanelInLevel = levelPanels[1]
	local lastPanelInLevel = levelPanels[#levelPanels]

	if firstPanelInLevel and lastPanelInLevel then
		levelData[levelFolder.Name] = {
			startPos = firstPanelInLevel.Position,
			endPos = lastPanelInLevel.Position
		}
		print(string.format("✅ Progress Bar configurada para %s (Panel1 → Panel%d como meta)",
			levelFolder.Name, getPanelNumber(lastPanelInLevel.Name)))
	else
		warn(string.format("⚠️ No se pudo configurar Progress Bar para %s", levelFolder.Name))
	end

	print(string.format("✅ %s: %d paneles cargados", levelFolder.Name, #levelPanels))
	return #levelPanels
end

-- ═══════════════════════════════════════════════════════════
-- LOOP DE DETECCIÓN CONTINUA
-- ═══════════════════════════════════════════════════════════

local function startDetectionLoop()
	-- 🚀 OPTIMIZACIÓN: Solo actualizar progress bar, no iterar sobre paneles
	-- Los paneles ahora usan Touched events (configurados en setupPanelTouchedEvents)
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end

		-- Actualizar progress bar si hay un nivel activo
		if currentLevel then
			updateProgressBar()
		end

		-- Detectar si el jugador está tocando una plataforma (para zonas)
		detectPlatformTouch()

		-- ❌ REMOVIDO: Loop que iteraba sobre TODOS los paneles cada frame
		-- Ahora los paneles usan Touched events individuales (mucho más eficiente)
	end)

	player.CharacterAdded:Connect(function(character)
		hideProgressBar()

		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		local humanoid = character:WaitForChild("Humanoid")
		diedConnection = humanoid.Died:Connect(function()
			hideProgressBar()
		end)
	end)

	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
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
	print("MULTI-LEVEL GLASS PANEL SYSTEM - INICIANDO (CON DINERO)")
	print("═══════════════════════════════════════════════════════")
	print(string.format("⚡ Cargando niveles en PARALELO (empezarás a jugar cuando %d estén listos)", CONFIG.MIN_LEVELS_TO_START))

	local totalPanels = 0
	local levelsReady = 0
	local systemStarted = false

	for _, levelName in ipairs(CONFIG.LEVEL_NAMES) do
		task.spawn(function()
			local levelFolder = workspace:WaitForChild(levelName, 60)
			if levelFolder then
				local panels = initializeLevel(levelFolder)
				if panels > 0 then
					totalPanels = totalPanels + panels
					levelsReady = levelsReady + 1

					print(string.format("✅ %s LISTO PARA JUGAR (%d/%d niveles disponibles)",
						levelName, levelsReady, #CONFIG.LEVEL_NAMES))

					if levelsReady >= CONFIG.MIN_LEVELS_TO_START and not systemStarted then
						systemStarted = true
						print("───────────────────────────────────────────────────────")
						print(string.format("🎮 ¡SISTEMA ACTIVADO! Ya puedes jugar con %d niveles", levelsReady))
						print(string.format("   Los demás %d niveles se siguen cargando en segundo plano",
							#CONFIG.LEVEL_NAMES - levelsReady))
						print("───────────────────────────────────────────────────────")

						startDetectionLoop()
						print("🔄 Sistema de detección continua activado")
					end
				end
			else
				warn(string.format("⚠️ %s no encontrado en Workspace", levelName))
			end
		end)
	end

	local maxWait = 60
	local waited = 0
	while levelsReady < CONFIG.MIN_LEVELS_TO_START and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5
	end

	if levelsReady == 0 then
		warn("❌ ERROR: No se pudieron cargar niveles")
		warn("Ejecuta el script de setup primero")
		return false
	end

	if levelsReady < CONFIG.MIN_LEVELS_TO_START then
		warn(string.format("⚠️ Solo se cargaron %d niveles (esperaba %d mínimo)", levelsReady, CONFIG.MIN_LEVELS_TO_START))
		print("🎮 Activando sistema de todas formas...")
	end

	return true
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR SISTEMA
-- ═══════════════════════════════════════════════════════════

initializeProgressBar()

if initializeSystem() then
	print("═══════════════════════════════════════════════════════")
	print("✅ Inicialización completa")
	print("═══════════════════════════════════════════════════════")

	task.spawn(function()
		task.wait(5)
		local levelsWithProgressBar = 0
		for levelName, _ in pairs(levelData) do
			levelsWithProgressBar = levelsWithProgressBar + 1
		end

		print("───────────────────────────────────────────────────────")
		print("📊 RESUMEN FINAL:")
		print(string.format("   Niveles con Progress Bar: %d/%d", levelsWithProgressBar, #CONFIG.LEVEL_NAMES))

		if levelsWithProgressBar < #CONFIG.LEVEL_NAMES then
			warn("⚠️ Algunos niveles no se cargaron completamente:")
			for _, levelName in ipairs(CONFIG.LEVEL_NAMES) do
				if workspace:FindFirstChild(levelName) and not levelData[levelName] then
					warn(string.format("   - %s", levelName))
				end
			end
		end
		print("───────────────────────────────────────────────────────")
	end)
end
