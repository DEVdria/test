-- StarterGui > MoneyNotificationManager (LocalScript)
-- Sistema modular de notificaciones de dinero en lista
-- TÚ diseñas la GUI, el código maneja la lógica

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN (Puedes modificar estos valores)
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	MAX_NOTIFICATIONS = 5,           -- Máximo de notificaciones visibles
	NOTIFICATION_LIFETIME = 2.5,     -- Segundos antes de desaparecer
	FADE_IN_TIME = 0.2,              -- Tiempo de aparición (segundos)
	FADE_OUT_TIME = 0.4,             -- Tiempo de desaparición (segundos)
	SLIDE_IN_DISTANCE = 50,          -- Distancia de deslizamiento al aparecer (píxeles)
}

-- ═══════════════════════════════════════════════════════════
-- BUSCAR GUI ELEMENTS (TÚ DEBES CREARLOS EN STARTERGUI)
-- ═══════════════════════════════════════════════════════════

--[[
	ESTRUCTURA REQUERIDA EN StarterGui:

	StarterGui
	└─ MoneyNotifications (ScreenGui)
	   ├─ NotificationContainer (Frame)
	   │  └─ UIListLayout (IMPORTANTE: para organizar las notificaciones en lista)
	   └─ NotificationTemplate (Frame) [Visible = false]
	      └─ MoneyLabel (TextLabel) <- Aquí se mostrará "+$100"

	DISEÑA EL TEMPLATE COMO QUIERAS:
	- Colores, tamaños, fuentes
	- Añade iconos, efectos, bordes
	- El código solo cambiará el texto del MoneyLabel
]]

local moneyNotificationGui = playerGui:WaitForChild("MoneyNotifications", 10)
if not moneyNotificationGui then
	warn("[MoneyNotificationManager] ❌ No se encontró ScreenGui 'MoneyNotifications'")
	warn("[MoneyNotificationManager] 📘 Crea un ScreenGui llamado 'MoneyNotifications' en StarterGui")
	return
end

-- Container donde se añadirán las notificaciones
local notificationContainer = moneyNotificationGui:WaitForChild("NotificationContainer", 5)
if not notificationContainer then
	warn("[MoneyNotificationManager] ❌ No se encontró 'NotificationContainer'")
	warn("[MoneyNotificationManager] 📘 Crea un Frame llamado 'NotificationContainer' con UIListLayout")
	return
end

-- Template de notificación (tú lo diseñas)
local notificationTemplate = moneyNotificationGui:FindFirstChild("NotificationTemplate")
if not notificationTemplate then
	warn("[MoneyNotificationManager] ❌ No se encontró 'NotificationTemplate'")
	warn("[MoneyNotificationManager] 📘 Crea un Frame llamado 'NotificationTemplate' y diseñalo como quieras")
	return
end

-- Verificar que hay UIListLayout
local listLayout = notificationContainer:FindFirstChild("UIListLayout")
if not listLayout then
	warn("[MoneyNotificationManager] ⚠️ No se encontró UIListLayout en NotificationContainer")
	warn("[MoneyNotificationManager] 📘 Añade un UIListLayout para organizar las notificaciones en lista")
end

notificationTemplate.Visible = false
notificationTemplate.Parent = moneyNotificationGui

print("[MoneyNotificationManager] ✅ GUI encontrada correctamente")

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES DE ANIMACIÓN
-- ═══════════════════════════════════════════════════════════

-- Anima la aparición de una notificación
local function animateIn(notification)
	-- Guardar posición original
	local originalPosition = notification.Position

	-- Empezar fuera de pantalla (a la derecha)
	notification.Position = originalPosition + UDim2.new(0, CONFIG.SLIDE_IN_DISTANCE, 0, 0)

	-- Transparencia inicial
	notification.BackgroundTransparency = 1
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child.TextTransparency = 1
			if child.TextStrokeTransparency < 1 then
				child.TextStrokeTransparency = 1
			end
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			child.ImageTransparency = 1
		elseif child:IsA("UIStroke") then
			child.Transparency = 1
		end
	end

	-- Animar deslizamiento y fade in
	local slideTween = TweenService:Create(
		notification,
		TweenInfo.new(CONFIG.FADE_IN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = originalPosition}
	)

	local fadeTween = TweenService:Create(
		notification,
		TweenInfo.new(CONFIG.FADE_IN_TIME),
		{BackgroundTransparency = notificationTemplate.BackgroundTransparency}
	)

	slideTween:Play()
	fadeTween:Play()

	-- Fade in de elementos internos
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			local originalTemplate = notificationTemplate:FindFirstChild(child.Name, true)
			local targetTextTransparency = originalTemplate and originalTemplate.TextTransparency or 0
			local targetStrokeTransparency = originalTemplate and originalTemplate.TextStrokeTransparency or 1

			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_IN_TIME), {
				TextTransparency = targetTextTransparency,
				TextStrokeTransparency = targetStrokeTransparency
			}):Play()
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			local originalTemplate = notificationTemplate:FindFirstChild(child.Name, true)
			local targetImageTransparency = originalTemplate and originalTemplate.ImageTransparency or 0

			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_IN_TIME), {
				ImageTransparency = targetImageTransparency
			}):Play()
		elseif child:IsA("UIStroke") then
			local originalTemplate = notificationTemplate:FindFirstChild(child.Name, true)
			local targetStrokeTransparency = originalTemplate and originalTemplate.Transparency or 0

			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_IN_TIME), {
				Transparency = targetStrokeTransparency
			}):Play()
		end
	end
end

-- Anima la desaparición de una notificación
local function animateOut(notification, callback)
	-- Deslizar a la derecha y fade out
	local slideOutTween = TweenService:Create(
		notification,
		TweenInfo.new(CONFIG.FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = notification.Position + UDim2.new(0, CONFIG.SLIDE_IN_DISTANCE, 0, 0)}
	)

	local fadeTween = TweenService:Create(
		notification,
		TweenInfo.new(CONFIG.FADE_OUT_TIME),
		{BackgroundTransparency = 1}
	)

	slideOutTween:Play()
	fadeTween:Play()

	-- Fade out de elementos internos
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_OUT_TIME), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_OUT_TIME), {
				ImageTransparency = 1
			}):Play()
		elseif child:IsA("UIStroke") then
			TweenService:Create(child, TweenInfo.new(CONFIG.FADE_OUT_TIME), {
				Transparency = 1
			}):Play()
		end
	end

	-- Callback cuando termine
	fadeTween.Completed:Connect(function()
		if callback then callback() end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- GESTIÓN DE NOTIFICACIONES
-- ═══════════════════════════════════════════════════════════

-- Cuenta cuántas notificaciones hay activas
local function countActiveNotifications()
	local count = 0
	for _, child in ipairs(notificationContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^MoneyNotification_") then
			count = count + 1
		end
	end
	return count
end

-- Elimina la notificación más antigua si hay demasiadas
local function removeOldestIfNeeded()
	if countActiveNotifications() >= CONFIG.MAX_NOTIFICATIONS then
		-- Buscar la más antigua (primer hijo que sea notificación)
		for _, child in ipairs(notificationContainer:GetChildren()) do
			if child:IsA("Frame") and child.Name:match("^MoneyNotification_") then
				animateOut(child, function()
					child:Destroy()
				end)
				return
			end
		end
	end
end

-- Muestra una nueva notificación de dinero
local function showMoneyNotification(amount)
	if amount <= 0 then return end

	-- Remover la más antigua si hay demasiadas
	removeOldestIfNeeded()

	-- Clonar el template
	local notification = notificationTemplate:Clone()
	notification.Name = "MoneyNotification_" .. tick()
	notification.Visible = true
	notification.Parent = notificationContainer

	-- Actualizar el texto del dinero
	local moneyLabel = notification:FindFirstChild("MoneyLabel", true)
	if moneyLabel and moneyLabel:IsA("TextLabel") then
		moneyLabel.Text = string.format("+$%d", amount)
	else
		warn("[MoneyNotificationManager] ⚠️ No se encontró 'MoneyLabel' en el template")
	end

	-- Animar aparición
	animateIn(notification)

	-- Programar desaparición
	task.delay(CONFIG.NOTIFICATION_LIFETIME, function()
		if notification and notification.Parent then
			animateOut(notification, function()
				notification:Destroy()
			end)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- DETECCIÓN DE CAMBIOS EN DINERO
-- ═══════════════════════════════════════════════════════════

local previousMoney = 0

local function setupMoneyListener()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[MoneyNotificationManager] ❌ No se encontró leaderstats")
		return
	end

	local moneyValue = leaderstats:WaitForChild("Money", 5)
	if not moneyValue then
		warn("[MoneyNotificationManager] ❌ No se encontró Money en leaderstats")
		return
	end

	-- Inicializar valor anterior
	previousMoney = moneyValue.Value

	-- Escuchar cambios en el dinero
	moneyValue:GetPropertyChangedSignal("Value"):Connect(function()
		local newMoney = moneyValue.Value
		local difference = newMoney - previousMoney

		-- Solo mostrar notificación si se GANÓ dinero (diferencia positiva)
		if difference > 0 then
			showMoneyNotification(difference)
		end

		-- Actualizar valor anterior
		previousMoney = newMoney
	end)

	print("[MoneyNotificationManager] ✅ Sistema de notificaciones de dinero inicializado")
	print(string.format("[MoneyNotificationManager] 📊 Dinero inicial: $%d", previousMoney))
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZAR
-- ═══════════════════════════════════════════════════════════

setupMoneyListener()

-- ═══════════════════════════════════════════════════════════
-- API PÚBLICA (Por si quieres llamar manualmente)
-- ═══════════════════════════════════════════════════════════

-- Puedes llamar esta función manualmente desde otros scripts:
-- _G.ShowMoneyNotification(100)  -- Muestra "+$100"
_G.ShowMoneyNotification = showMoneyNotification

print("[MoneyNotificationManager] 🎨 Diseña el template 'NotificationTemplate' en MoneyNotifications ScreenGui")
