--[[
	PLAYTIME REWARD BUTTON - LocalScript
	Controla la GUI de recompensas por tiempo de juego

	UBICACIÓN: StarterGui/PrincipalGui/PlaytimeRewardButton (LocalScript)
	         (Dentro del ScreenGui, NO en StarterGui directamente)

	TÚ DISEÑAS LA GUI, este script solo:
	- Conecta el botón principal
	- Actualiza el tiempo restante
	- Conecta los 6 botones de recompensas
	- Auto-puebla los TextLabels
	- Actualiza el estado visual
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Obtener el ScreenGui directamente desde el parent del script
local screenGui = script.Parent
if not screenGui or not screenGui:IsA("ScreenGui") then
	warn("[PlaytimeRewardButton] ❌ Este script debe estar dentro del ScreenGui (PrincipalGui)")
	return
end

-- Esperar NotificationManager
local NotificationManager = nil
task.spawn(function()
	local maxWait = 5
	local waited = 0
	while not _G.NotificationManager and waited < maxWait do
		task.wait(0.1)
		waited = waited + 0.1
	end
	NotificationManager = _G.NotificationManager
	if NotificationManager then
		print("[PlaytimeRewardButton] ✅ NotificationManager conectado")
	end
end)

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local PlaytimeRewardConfig = require(Modules:WaitForChild("PlaytimeRewardConfig"))

-- Esperar RemoteEvents
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetRewardInfoFunction = RemotesFolder:WaitForChild("GetPlaytimeRewardInfo", 10)
local ClaimRewardEvent = RemotesFolder:WaitForChild("ClaimPlaytimeReward", 10)
local UpdatePlaytimeEvent = RemotesFolder:WaitForChild("UpdatePlaytime", 10)

if not GetRewardInfoFunction or not ClaimRewardEvent or not UpdatePlaytimeEvent then
	warn("[PlaytimeRewardButton] ❌ No se encontraron RemoteEvents necesarios")
	return
end

print("[PlaytimeRewardButton] 🕐 Inicializando sistema de recompensas...")
print(string.format("[PlaytimeRewardButton] 📋 ScreenGui: %s", screenGui.Name))

-- ==================== BUSCAR GUI ====================

-- Buscar ImageButton principal
local mainButton = screenGui:FindFirstChild(PlaytimeRewardConfig.GuiNames.MainButton, true)
if not mainButton then
	warn(string.format("[PlaytimeRewardButton] ❌ No se encontró ImageButton principal: %s", PlaytimeRewardConfig.GuiNames.MainButton))
	warn("[PlaytimeRewardButton] 📘 Crea un ImageButton llamado 'PlaytimeButton' en tu ScreenGui")
	return
end

-- Buscar TextLabel del botón principal
local mainButtonTimeLabel = mainButton:FindFirstChild(PlaytimeRewardConfig.GuiNames.MainButtonTimeLabel)
if not mainButtonTimeLabel then
	warn(string.format("[PlaytimeRewardButton] ⚠️ No se encontró TextLabel '%s' en el botón principal", PlaytimeRewardConfig.GuiNames.MainButtonTimeLabel))
end

-- Buscar Frame de recompensas
local rewardsFrame = screenGui:FindFirstChild(PlaytimeRewardConfig.GuiNames.RewardsFrame, true)
if not rewardsFrame then
	warn(string.format("[PlaytimeRewardButton] ❌ No se encontró Frame de recompensas: %s", PlaytimeRewardConfig.GuiNames.RewardsFrame))
	warn("[PlaytimeRewardButton] 📘 Crea un Frame llamado 'PlaytimeRewardsFrame' en tu ScreenGui")
	return
end

-- Ocultar el Frame al inicio
rewardsFrame.Visible = false

-- Buscar botón de cerrar (opcional)
local closeButton = rewardsFrame:FindFirstChild(PlaytimeRewardConfig.GuiNames.CloseButton, true)

print("[PlaytimeRewardButton] ✅ GUI encontrada correctamente")

-- ==================== VARIABLES ====================

local currentRewardInfo = nil
local rewardButtons = {}

-- ==================== FUNCIONES ====================

-- Actualiza el TextLabel del botón principal con el tiempo restante
local function updateMainButtonTime(timeUntilNext)
	if not mainButtonTimeLabel or not mainButtonTimeLabel:IsA("TextLabel") then
		return
	end

	if timeUntilNext == 0 then
		mainButtonTimeLabel.Text = "¡RECOMPENSA LISTA!"
		mainButtonTimeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Verde
	else
		mainButtonTimeLabel.Text = PlaytimeRewardConfig.FormatTime(timeUntilNext)
		mainButtonTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Blanco
	end
end

-- Actualiza el estado visual de un botón de recompensa
local function updateRewardButton(rewardButton, rewardData, state)
	if not rewardButton then return end

	-- Encontrar TextLabels
	local timeLabel = rewardButton:FindFirstChild(PlaytimeRewardConfig.GuiNames.TimeLabel)
	local moneyLabel = rewardButton:FindFirstChild(PlaytimeRewardConfig.GuiNames.MoneyLabel)

	-- Obtener la recompensa de la config
	local reward = PlaytimeRewardConfig.GetReward(rewardData.ID)
	if not reward then return end

	-- Auto-poblar TextLabels si existen
	if timeLabel and timeLabel:IsA("TextLabel") then
		timeLabel.Text = PlaytimeRewardConfig.FormatTimeShort(reward.TimeRequired)
	end

	if moneyLabel and moneyLabel:IsA("TextLabel") then
		moneyLabel.Text = PlaytimeRewardConfig.FormatNumber(reward.MoneyReward)
	end

	-- Actualizar apariencia según estado
	local stateColor = PlaytimeRewardConfig.StateColors[state]
	local stateTransparency = PlaytimeRewardConfig.StateTransparency[state]

	-- Cambiar color del borde o fondo si tiene UIStroke
	local uiStroke = rewardButton:FindFirstChildOfClass("UIStroke")
	if uiStroke then
		uiStroke.Color = stateColor
	else
		-- Si no tiene UIStroke, cambiar el color de fondo
		if rewardButton:IsA("ImageButton") or rewardButton:IsA("TextButton") then
			rewardButton.BackgroundColor3 = stateColor
		end
	end

	-- Cambiar transparencia
	if rewardButton:IsA("ImageButton") then
		rewardButton.ImageTransparency = stateTransparency
		rewardButton.BackgroundTransparency = stateTransparency
	elseif rewardButton:IsA("TextButton") then
		rewardButton.BackgroundTransparency = stateTransparency
	end

	-- Actualizar interactividad
	if state == "Available" then
		rewardButton.Active = true
		rewardButton.AutoButtonColor = true
	else
		rewardButton.Active = false
		rewardButton.AutoButtonColor = false
	end

	-- Mostrar texto de estado si hay un TextLabel adicional
	local statusLabel = rewardButton:FindFirstChild("Status")
	if statusLabel and statusLabel:IsA("TextLabel") then
		if state == "Available" then
			statusLabel.Text = PlaytimeRewardConfig.StateTexts.Available
		elseif state == "Claimed" then
			statusLabel.Text = PlaytimeRewardConfig.StateTexts.Claimed
		else  -- Locked
			local timeRemaining = rewardData.TimeRemaining
			statusLabel.Text = PlaytimeRewardConfig.StateTexts.Locked(timeRemaining)
		end
	end
end

-- Actualiza todos los botones de recompensas
local function updateAllRewardButtons()
	if not currentRewardInfo or not currentRewardInfo.RewardStates then
		return
	end

	for _, rewardData in ipairs(currentRewardInfo.RewardStates) do
		local rewardButton = rewardButtons[rewardData.ID]
		if rewardButton then
			updateRewardButton(rewardButton, rewardData, rewardData.State)
		end
	end

	-- Actualizar tiempo en botón principal
	updateMainButtonTime(currentRewardInfo.TimeUntilNext or 0)
end

-- Solicita actualización de información al servidor
local function requestRewardInfo()
	local success, info = pcall(function()
		return GetRewardInfoFunction:InvokeServer()
	end)

	if success and info then
		currentRewardInfo = info
		updateAllRewardButtons()
	else
		warn("[PlaytimeRewardButton] ⚠️ Error al obtener información de recompensas")
	end
end

-- Reclama una recompensa
local function claimReward(rewardID)
	local reward = PlaytimeRewardConfig.GetReward(rewardID)
	if not reward then
		warn("[PlaytimeRewardButton] ⚠️ Recompensa no encontrada:", rewardID)
		return
	end

	-- Verificar estado actual
	if not currentRewardInfo or not currentRewardInfo.RewardStates then
		if NotificationManager then
			NotificationManager.Error("Error al verificar recompensa")
		end
		return
	end

	-- Encontrar el estado de esta recompensa
	local rewardData = nil
	for _, data in ipairs(currentRewardInfo.RewardStates) do
		if data.ID == rewardID then
			rewardData = data
			break
		end
	end

	if not rewardData then
		return
	end

	-- Verificar que esté disponible
	if rewardData.State ~= "Available" then
		if rewardData.State == "Claimed" then
			if NotificationManager then
				NotificationManager.Warning("Ya reclamaste esta recompensa")
			end
		else  -- Locked
			if NotificationManager then
				local timeRemaining = PlaytimeRewardConfig.FormatTime(rewardData.TimeRemaining)
				NotificationManager.Error(string.format("Falta %s de juego", timeRemaining))
			end
		end
		return
	end

	-- Enviar solicitud al servidor
	print(string.format("[PlaytimeRewardButton] 🎁 Reclamando recompensa %d...", rewardID))
	ClaimRewardEvent:FireServer(rewardID)
end

-- ==================== CONECTAR BOTONES ====================

-- Conectar botón principal (abrir/cerrar panel)
mainButton.MouseButton1Click:Connect(function()
	rewardsFrame.Visible = not rewardsFrame.Visible

	-- Actualizar información al abrir
	if rewardsFrame.Visible then
		requestRewardInfo()
	end

	print(string.format("[PlaytimeRewardButton] 📋 Panel de recompensas %s", rewardsFrame.Visible and "abierto" or "cerrado"))
end)

-- Conectar botón de cerrar (opcional)
if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		rewardsFrame.Visible = false
		print("[PlaytimeRewardButton] 📋 Panel de recompensas cerrado")
	end)
end

-- Conectar botones de recompensas (Reward1, Reward2, etc.)
for i = 1, #PlaytimeRewardConfig.Rewards do
	local buttonName = PlaytimeRewardConfig.GuiNames.RewardButtonPrefix .. i
	local rewardButton = rewardsFrame:FindFirstChild(buttonName, true)

	if rewardButton then
		local rewardID = i  -- El ID corresponde al número del botón

		-- Guardar referencia
		rewardButtons[rewardID] = rewardButton

		-- Conectar evento de clic
		if rewardButton:IsA("ImageButton") or rewardButton:IsA("TextButton") then
			rewardButton.MouseButton1Click:Connect(function()
				claimReward(rewardID)
			end)
		end

		print(string.format("[PlaytimeRewardButton] 🔘 Botón '%s' conectado (Recompensa %d)", buttonName, rewardID))
	else
		warn(string.format("[PlaytimeRewardButton] ⚠️ No se encontró botón '%s'", buttonName))
	end
end

-- ==================== EVENTOS DEL SERVIDOR ====================

-- Escuchar respuesta de reclamación
ClaimRewardEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[PlaytimeRewardButton] ✅ %s", result.Message))

		-- Mostrar notificación
		if NotificationManager then
			NotificationManager.Money(result.Message, 4)
		end

		-- Actualizar información
		requestRewardInfo()
	else
		warn(string.format("[PlaytimeRewardButton] ❌ %s", result.Message))

		-- Mostrar notificación de error
		if NotificationManager then
			NotificationManager.Error(result.Message, 4)
		end
	end
end)

-- Escuchar actualizaciones de playtime del servidor
UpdatePlaytimeEvent.OnClientEvent:Connect(function(info)
	currentRewardInfo = info
	updateAllRewardButtons()
end)

-- ==================== INICIALIZACIÓN ====================

-- Solicitar información inicial
task.wait(2)  -- Esperar a que el servidor esté listo
requestRewardInfo()

-- Actualizar periódicamente el tiempo en el botón principal
task.spawn(function()
	while true do
		task.wait(1)

		if currentRewardInfo then
			-- Decrementar localmente el tiempo (se sincroniza con el servidor cada 5s)
			if currentRewardInfo.TimeUntilNext > 0 then
				currentRewardInfo.TimeUntilNext = math.max(0, currentRewardInfo.TimeUntilNext - 1)
			end

			updateMainButtonTime(currentRewardInfo.TimeUntilNext)
		end
	end
end)

print("[PlaytimeRewardButton] ✅ Sistema de recompensas inicializado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA EN STARTERGUI:

	StarterGui
	└─ PrincipalGui (ScreenGui) - Ya existe
	   ├─ PlaytimeRewardButton (LocalScript) ← ESTE SCRIPT AQUÍ
	   ├─ PlaytimeButton (ImageButton) - Botón principal
	   │  └─ TimeLabel (TextLabel) - Tiempo restante para próxima recompensa
	   └─ PlaytimeRewardsFrame (Frame) - Panel de recompensas
	      ├─ Reward1 (ImageButton) - Recompensa 1
	      │  ├─ TimeLabel (TextLabel) - Auto-poblado con tiempo requerido
	      │  ├─ MoneyLabel (TextLabel) - Auto-poblado con cantidad de dinero
	      │  └─ Status (TextLabel) [OPCIONAL] - Estado de la recompensa
	      ├─ Reward2 (ImageButton) - Recompensa 2
	      │  ├─ TimeLabel (TextLabel)
	      │  ├─ MoneyLabel (TextLabel)
	      │  └─ Status (TextLabel) [OPCIONAL]
	      ├─ ... (hasta Reward6)
	      └─ CloseButton (TextButton/ImageButton) [OPCIONAL] - Cerrar panel

	PERSONALIZACIÓN:
	- Diseña los ImageButtons como quieras
	- El script auto-puebla los TextLabels
	- El script actualiza los colores según estado:
	  - Verde = Disponible para reclamar
	  - Gris = Ya reclamado
	  - Rojo = Aún bloqueado

	CONFIGURACIÓN DE RECOMPENSAS:
	Edita ReplicatedStorage/Modules/PlaytimeRewardConfig.lua para cambiar:
	- Tiempos requeridos
	- Cantidades de dinero
	- Colores de estados
	- Textos de estados
]]
