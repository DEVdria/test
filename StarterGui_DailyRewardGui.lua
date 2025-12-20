--[[
	DAILY REWARD GUI - LocalScript
	Controla la interfaz de recompensas diarias

	UBICACIÓN: StarterGui/DailyRewardGui/DailyRewardGui (LocalScript)
	         (Dentro del ScreenGui, NO en StarterGui directamente)

	TÚ DISEÑAS LA GUI, este script:
	- Auto-abre el panel si hay recompensa disponible
	- Actualiza el estado de cada día (reclamado/disponible/bloqueado)
	- Maneja la reclamación con animación y sonido
	- Muestra indicador de boosts activos en pantalla
	- Actualiza el contador de tiempo en tiempo real
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Obtener el ScreenGui directamente desde el parent del script
local screenGui = script.Parent
if not screenGui or not screenGui:IsA("ScreenGui") then
	warn("[DailyRewardGui] ❌ Este script debe estar dentro del ScreenGui (DailyRewardGui)")
	return
end

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DailyRewardConfig = require(Modules:WaitForChild("DailyRewardConfig"))

-- Esperar RemoteEvents
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetRewardInfoFunction = RemotesFolder:WaitForChild(DailyRewardConfig.RemoteEvents.GetRewardInfo, 10)
local ClaimRewardEvent = RemotesFolder:WaitForChild(DailyRewardConfig.RemoteEvents.ClaimReward, 10)
local BoostUpdateEvent = RemotesFolder:WaitForChild(DailyRewardConfig.RemoteEvents.BoostUpdate, 10)
local RewardAvailableEvent = RemotesFolder:WaitForChild("DailyRewardAvailable", 10)

if not GetRewardInfoFunction or not ClaimRewardEvent or not BoostUpdateEvent then
	warn("[DailyRewardGui] ❌ No se encontraron RemoteEvents necesarios")
	return
end

print("[DailyRewardGui] 🎁 Inicializando sistema de recompensas diarias...")

-- ==================== BUSCAR ELEMENTOS DE LA GUI ====================

-- Frame principal
local mainFrame = screenGui:FindFirstChild(DailyRewardConfig.GuiNames.MainFrame, true)
if not mainFrame then
	warn(string.format("[DailyRewardGui] ❌ No se encontró Frame principal: %s", DailyRewardConfig.GuiNames.MainFrame))
	warn("[DailyRewardGui] 📘 Crea un Frame llamado 'DailyRewardFrame' en tu ScreenGui")
	return
end

-- Botón de cerrar
local closeButton = mainFrame:FindFirstChild(DailyRewardConfig.GuiNames.CloseButton, true)

-- Botón para abrir el panel (fuera del DailyRewardFrame, en la GUI principal)
-- Este botón debe estar en tu ScreenGui principal (ej: PrincipalGui)
local openButton = nil
local principalGui = player:WaitForChild("PlayerGui"):FindFirstChild("PrincipalGui")
if principalGui then
	openButton = principalGui:FindFirstChild("DailyRewardButton", true)
	if openButton then
		print("[DailyRewardGui] ✅ Botón de apertura encontrado en PrincipalGui")
	end
end

-- Indicador de boost activo (opcional)
local boostIndicator = screenGui:FindFirstChild(DailyRewardConfig.GuiNames.BoostIndicator, true)
local boostText = boostIndicator and boostIndicator:FindFirstChild(DailyRewardConfig.GuiNames.BoostText, true)
local boostTimer = boostIndicator and boostIndicator:FindFirstChild(DailyRewardConfig.GuiNames.BoostTimer, true)

-- Ocultar al inicio
mainFrame.Visible = false
if boostIndicator then
	boostIndicator.Visible = false
end

-- Guardar el tamaño original del frame (el que TÚ diseñaste)
local originalSize = mainFrame.Size

print("[DailyRewardGui] ✅ GUI encontrada correctamente")

-- ==================== VARIABLES ====================

local currentRewardInfo = nil
local dayButtons = {}
local activeBoosts = {
	XP = {Active = false, Multiplier = 1, TimeRemaining = 0},
	Money = {Active = false, Multiplier = 1, TimeRemaining = 0}
}

-- ==================== FUNCIONES DE UI ====================

-- Actualiza el estado visual de un botón de día
local function updateDayButton(dayNumber, currentDay, canClaim)
	local dayButton = dayButtons[dayNumber]
	if not dayButton then return end

	local reward = DailyRewardConfig.GetReward(dayNumber)
	if not reward then return end

	-- Encontrar elementos del botón
	local icon = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.DayIcon, true)
	local numberLabel = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.DayNumber, true)
	local rewardText = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.DayReward, true)
	local status = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.DayStatus, true)
	local claimButton = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.ClaimButton, true)

	-- Auto-poblar información
	if icon and icon:IsA("TextLabel") then
		icon.Text = reward.Icon
	end

	if numberLabel and numberLabel:IsA("TextLabel") then
		numberLabel.Text = string.format("DÍA %d", dayNumber)
	end

	if rewardText and rewardText:IsA("TextLabel") then
		rewardText.Text = reward.DisplayName
	end

	-- Determinar estado del día
	local isDayCompleted = dayNumber < currentDay
	local isCurrentDay = dayNumber == currentDay
	local isLocked = dayNumber > currentDay

	-- Actualizar apariencia según estado
	if isDayCompleted then
		-- Día ya reclamado
		dayButton.BackgroundColor3 = DailyRewardConfig.Colors.Claimed
		if status and status:IsA("TextLabel") then
			status.Text = "✅ RECLAMADO"
			status.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		if claimButton then
			claimButton.Visible = false
		end

	elseif isCurrentDay and canClaim then
		-- Día disponible para reclamar
		local color = dayNumber == 7 and DailyRewardConfig.Colors.Special or DailyRewardConfig.Colors.Available
		dayButton.BackgroundColor3 = color

		if status and status:IsA("TextLabel") then
			status.Text = "¡DISPONIBLE!"
			status.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		if claimButton and claimButton:IsA("TextButton") then
			claimButton.Visible = true
			claimButton.Text = "RECLAMAR"
			claimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			claimButton.Active = true

			-- Animación de pulso para el botón disponible
			local pulse = TweenService:Create(claimButton, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				Size = UDim2.new(claimButton.Size.X.Scale * 1.1, 0, claimButton.Size.Y.Scale * 1.1, 0)
			})
			pulse:Play()
		end

	elseif isCurrentDay and not canClaim then
		-- Día actual pero aún no disponible (cooldown)
		dayButton.BackgroundColor3 = DailyRewardConfig.Colors.Available
		if status and status:IsA("TextLabel") then
			local timeRemaining = DailyRewardConfig.FormatTime(currentRewardInfo.TimeUntilClaim or 0)
			status.Text = string.format("⏰ %s", timeRemaining)
			status.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		if claimButton then
			claimButton.Visible = false
		end

	else
		-- Día bloqueado (futuro)
		dayButton.BackgroundColor3 = DailyRewardConfig.Colors.Locked
		if status and status:IsA("TextLabel") then
			status.Text = "🔒 BLOQUEADO"
			status.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
		if claimButton then
			claimButton.Visible = false
		end
	end
end

-- Actualiza todos los botones de días
local function updateAllDayButtons()
	if not currentRewardInfo then return end

	for day = 1, 7 do
		updateDayButton(day, currentRewardInfo.CurrentDay, currentRewardInfo.CanClaim)
	end
end

-- Solicita información actualizada del servidor
local function requestRewardInfo()
	local success, info = pcall(function()
		return GetRewardInfoFunction:InvokeServer()
	end)

	if success and info and info.Success then
		currentRewardInfo = info
		updateAllDayButtons()

		-- Actualizar boosts activos
		if info.ActiveBoosts then
			activeBoosts = info.ActiveBoosts
			updateBoostIndicator()
		end
	else
		warn("[DailyRewardGui] ⚠️ Error al obtener información de recompensas")
	end
end

-- Reclama la recompensa actual
local function claimReward()
	print("[DailyRewardGui] 🎁 Reclamando recompensa...")
	ClaimRewardEvent:FireServer()
end

-- Muestra el panel principal
local function showPanel()
	mainFrame.Visible = true

	-- Animación de entrada (escala en lugar de mover posición)
	-- Esto respeta tu posición y solo anima el tamaño
	mainFrame.Size = UDim2.new(0, 0, 0, 0)  -- Empieza pequeño desde el centro del frame

	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalSize  -- Crece hasta el tamaño que TÚ diseñaste
	})
	tween:Play()

	-- Actualizar información
	requestRewardInfo()

	print("[DailyRewardGui] 📋 Panel de recompensas abierto")
end

-- Oculta el panel principal
local function hidePanel()
	-- Simplemente ocultar sin animación de salida que cambie posición
	mainFrame.Visible = false
	print("[DailyRewardGui] 📋 Panel de recompensas cerrado")
end

-- Actualiza el indicador de boost activo
local function updateBoostIndicator()
	if not boostIndicator then return end

	local hasActiveBoost = activeBoosts.XP.Active or activeBoosts.Money.Active

	if hasActiveBoost then
		-- Construir texto del boost
		local boostTexts = {}
		if activeBoosts.XP.Active then
			table.insert(boostTexts, string.format("🔥 x%.0f XP", activeBoosts.XP.Multiplier))
		end
		if activeBoosts.Money.Active then
			table.insert(boostTexts, string.format("💵 x%.0f Money", activeBoosts.Money.Multiplier))
		end

		if boostText then
			boostText.Text = table.concat(boostTexts, " + ")
		end

		-- Mostrar tiempo restante del boost más largo
		local maxTime = math.max(activeBoosts.XP.TimeRemaining or 0, activeBoosts.Money.TimeRemaining or 0)
		if boostTimer then
			boostTimer.Text = DailyRewardConfig.FormatBoostTime(maxTime)
		end

		-- Mostrar indicador con animación
		if not boostIndicator.Visible then
			boostIndicator.Visible = true
			boostIndicator.Position = UDim2.new(0.5, 0, -0.2, 0)  -- Fuera de pantalla arriba
			local tween = TweenService:Create(boostIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 0, 0.05, 0)
			})
			tween:Play()
		end
	else
		-- Ocultar indicador
		if boostIndicator.Visible then
			local tween = TweenService:Create(boostIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, -0.2, 0)
			})
			tween:Play()

			task.delay(0.3, function()
				boostIndicator.Visible = false
			end)
		end
	end
end

-- ==================== CONECTAR BOTONES ====================

-- Botón de abrir (en PrincipalGui o donde lo hayas puesto)
if openButton then
	openButton.MouseButton1Click:Connect(function()
		if mainFrame.Visible then
			hidePanel()
		else
			showPanel()
		end
	end)
	print("[DailyRewardGui] 🔘 Botón de apertura conectado")
end

-- Botón de cerrar
if closeButton then
	closeButton.MouseButton1Click:Connect(hidePanel)
end

-- Buscar y conectar botones de días (Day1, Day2, ... Day7)
for day = 1, 7 do
	local buttonName = DailyRewardConfig.GuiNames.DayButtonPrefix .. day
	local dayButton = mainFrame:FindFirstChild(buttonName, true)

	if dayButton then
		dayButtons[day] = dayButton

		-- Buscar botón de reclamar dentro del día
		local claimButton = dayButton:FindFirstChild(DailyRewardConfig.GuiNames.ClaimButton, true)
		if claimButton and claimButton:IsA("TextButton") then
			claimButton.MouseButton1Click:Connect(function()
				claimReward()
			end)
		end

		print(string.format("[DailyRewardGui] 🔘 Botón Día %d conectado", day))
	else
		warn(string.format("[DailyRewardGui] ⚠️ No se encontró botón '%s'", buttonName))
	end
end

-- ==================== EVENTOS DEL SERVIDOR ====================

-- Escuchar respuesta de reclamación
ClaimRewardEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[DailyRewardGui] ✅ %s", result.Message))

		-- Reproducir sonido de éxito
		local claimSound = Instance.new("Sound")
		claimSound.SoundId = "rbxassetid://9114221327"  -- Sonido de victoria
		claimSound.Volume = 0.8
		claimSound.Pitch = 1.3
		claimSound.Parent = game:GetService("SoundService")
		claimSound:Play()

		task.delay(3, function()
			claimSound:Destroy()
		end)

		-- Animación de celebración (opcional - efectos de partículas aquí)
		-- TODO: Añadir efectos visuales

		-- Actualizar información después de reclamar
		task.wait(0.5)
		requestRewardInfo()

		-- Si es un boost, mostrar mensaje grande
		if result.RewardType and (result.RewardType == "XPBoost" or result.RewardType == "MoneyBoost" or result.RewardType == "DoubleBoost") then
			-- Crear mensaje temporal en pantalla
			local messageLabel = Instance.new("TextLabel")
			messageLabel.Size = UDim2.new(0.8, 0, 0.15, 0)
			messageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			messageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			messageLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
			messageLabel.BackgroundTransparency = 0.1
			messageLabel.BorderSizePixel = 0
			messageLabel.Text = result.Message
			messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			messageLabel.TextScaled = true
			messageLabel.Font = Enum.Font.GothamBold
			messageLabel.Parent = screenGui

			-- Añadir efecto de borde
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = Color3.fromRGB(255, 255, 255)
			uiStroke.Thickness = 3
			uiStroke.Parent = messageLabel

			-- Animación del mensaje
			messageLabel.Size = UDim2.new(0, 0, 0, 0)
			local expandTween = TweenService:Create(messageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.8, 0, 0.15, 0)
			})
			expandTween:Play()

			-- Eliminar después de 3 segundos
			task.delay(3, function()
				local fadeTween = TweenService:Create(messageLabel, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
					TextTransparency = 1
				})
				fadeTween:Play()

				task.delay(0.3, function()
					messageLabel:Destroy()
				end)
			end)
		end
	else
		warn(string.format("[DailyRewardGui] ❌ %s", result.Message))

		-- Sonido de error
		local errorSound = Instance.new("Sound")
		errorSound.SoundId = "rbxassetid://4590662766"  -- Sonido de error
		errorSound.Volume = 0.5
		errorSound.Parent = game:GetService("SoundService")
		errorSound:Play()

		task.delay(2, function()
			errorSound:Destroy()
		end)
	end
end)

-- Escuchar actualizaciones de boost
BoostUpdateEvent.OnClientEvent:Connect(function(boostData)
	if boostData.BoostType == "XP" then
		activeBoosts.XP = {
			Active = boostData.Active,
			Multiplier = boostData.Multiplier,
			TimeRemaining = boostData.TimeRemaining
		}
	elseif boostData.BoostType == "Money" then
		activeBoosts.Money = {
			Active = boostData.Active,
			Multiplier = boostData.Multiplier,
			TimeRemaining = boostData.TimeRemaining
		}
	end

	updateBoostIndicator()
end)

-- Escuchar señal de recompensa disponible (auto-abrir)
if RewardAvailableEvent then
	RewardAvailableEvent.OnClientEvent:Connect(function()
		print("[DailyRewardGui] 🔔 Recompensa disponible - Abriendo panel...")
		task.wait(1)
		showPanel()
	end)
end

-- ==================== INICIALIZACIÓN ====================

-- Actualizar periódicamente el contador de tiempo
task.spawn(function()
	while true do
		task.wait(1)

		-- Actualizar tiempo restante si está en cooldown
		if currentRewardInfo and not currentRewardInfo.CanClaim and currentRewardInfo.TimeUntilClaim > 0 then
			currentRewardInfo.TimeUntilClaim = math.max(0, currentRewardInfo.TimeUntilClaim - 1)

			-- Verificar si ahora puede reclamar
			if currentRewardInfo.TimeUntilClaim == 0 then
				currentRewardInfo.CanClaim = true
				print("[DailyRewardGui] ✅ ¡Recompensa ahora disponible!")
			end

			updateAllDayButtons()
		end

		-- Decrementar tiempo de boosts localmente
		if activeBoosts.XP.Active and activeBoosts.XP.TimeRemaining > 0 then
			activeBoosts.XP.TimeRemaining = math.max(0, activeBoosts.XP.TimeRemaining - 1)
			if activeBoosts.XP.TimeRemaining == 0 then
				activeBoosts.XP.Active = false
			end
		end

		if activeBoosts.Money.Active and activeBoosts.Money.TimeRemaining > 0 then
			activeBoosts.Money.TimeRemaining = math.max(0, activeBoosts.Money.TimeRemaining - 1)
			if activeBoosts.Money.TimeRemaining == 0 then
				activeBoosts.Money.Active = false
			end
		end

		updateBoostIndicator()
	end
end)

-- Solicitar información inicial
task.wait(3)
requestRewardInfo()

print("[DailyRewardGui] ✅ Sistema de GUI de recompensas diarias inicializado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA EN STARTERGUI:

	StarterGui
	├─ PrincipalGui (ScreenGui) - Tu GUI principal del juego
	│  └─ DailyRewardButton (ImageButton/TextButton) [OPCIONAL]
	│     ↑ Botón para abrir/cerrar el panel manualmente
	│     (Puede estar en cualquier ScreenGui, no necesariamente PrincipalGui)
	│
	└─ DailyRewardGui (ScreenGui)
	   ├─ DailyRewardGui (LocalScript) ← ESTE SCRIPT
	   ├─ DailyRewardFrame (Frame) - Panel principal
	   │  ├─ CloseButton (TextButton) - Botón cerrar
	   │  ├─ Day1 (Frame/ImageButton) - Día 1
	   │  │  ├─ Icon (TextLabel) - Emoji
	   │  │  ├─ DayNumber (TextLabel) - "DÍA 1"
	   │  │  ├─ RewardText (TextLabel) - Nombre de recompensa
	   │  │  ├─ Status (TextLabel) - Estado
	   │  │  └─ ClaimButton (TextButton) - Botón reclamar
	   │  ├─ Day2 (Frame/ImageButton) - Día 2
	   │  ├─ ... (hasta Day7)
	   │  └─ Day7 (Frame/ImageButton) - Día 7
	   └─ BoostIndicator (Frame) [OPCIONAL] - Indicador de boost activo
	      ├─ BoostText (TextLabel) - "🔥 x2 XP"
	      └─ BoostTimer (TextLabel) - "9:45"

	PERSONALIZACIÓN:
	- Diseña los Frames/Buttons como quieras
	- El script auto-puebla los TextLabels
	- Los colores se actualizan automáticamente según estado
	- Añade UICorner, UIGradient, etc. para mejorar la apariencia

	BOTÓN DE APERTURA (OPCIONAL):
	- Crea un ImageButton o TextButton llamado "DailyRewardButton"
	- Colócalo en tu GUI principal (ej: PrincipalGui)
	- El script lo buscará automáticamente
	- Si no existe, el panel solo se abrirá automáticamente cuando haya recompensa
	- Si existe, podrás abrir/cerrar el panel manualmente haciendo clic

	ESTADOS DE LOS DÍAS:
	- ✅ RECLAMADO: Verde (días completados)
	- ¡DISPONIBLE!: Dorado/Naranja (día actual si puede reclamar)
	- ⏰ Tiempo: Dorado con contador (día actual en cooldown)
	- 🔒 BLOQUEADO: Gris (días futuros)
]]
