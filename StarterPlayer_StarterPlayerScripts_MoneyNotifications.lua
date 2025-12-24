-- StarterPlayer > StarterPlayerScripts > MoneyNotifications
-- Sistema de notificaciones de dinero en forma de lista (+$1, +$2, etc.)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuración
local NOTIFICATION_LIFETIME = 2.0  -- Segundos antes de desaparecer
local FADE_OUT_TIME = 0.5  -- Tiempo de animación de desaparición
local MAX_NOTIFICATIONS = 5  -- Máximo de notificaciones visibles

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyNotifications"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Crear Frame contenedor para las notificaciones
local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 200, 0, 400)
notificationContainer.Position = UDim2.new(1, -220, 0, 20)  -- Esquina superior derecha
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = screenGui

-- UIListLayout para organizar las notificaciones en lista vertical
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = notificationContainer

-- Contador para LayoutOrder (las nuevas notificaciones aparecen abajo)
local layoutOrderCounter = 0

-- Crear una notificación de dinero
local function createMoneyNotification(amount)
	if amount <= 0 then return end

	-- Limitar número de notificaciones
	local children = notificationContainer:GetChildren()
	local notificationCount = 0
	for _, child in ipairs(children) do
		if child:IsA("TextLabel") then
			notificationCount = notificationCount + 1
		end
	end

	-- Si hay demasiadas notificaciones, eliminar las más antiguas
	if notificationCount >= MAX_NOTIFICATIONS then
		for _, child in ipairs(children) do
			if child:IsA("TextLabel") then
				child:Destroy()
				break
			end
		end
	end

	-- Crear TextLabel para la notificación
	local notification = Instance.new("TextLabel")
	notification.Name = "MoneyNotification"
	notification.Size = UDim2.new(1, 0, 0, 30)
	notification.BackgroundColor3 = Color3.fromRGB(46, 125, 50)  -- Verde oscuro
	notification.BackgroundTransparency = 0.3
	notification.BorderSizePixel = 0
	notification.Text = string.format("+$%d", amount)
	notification.TextColor3 = Color3.fromRGB(255, 255, 255)
	notification.TextSize = 20
	notification.Font = Enum.Font.GothamBold
	notification.TextXAlignment = Enum.TextXAlignment.Center
	notification.LayoutOrder = layoutOrderCounter

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notification

	-- Stroke para mejor visibilidad
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 0)  -- Dorado
	stroke.Thickness = 2
	stroke.Parent = notification

	notification.Parent = notificationContainer
	layoutOrderCounter = layoutOrderCounter + 1

	-- Animación de entrada (aparece desde la derecha)
	notification.Position = UDim2.new(1, 50, 0, 0)
	local tweenIn = TweenService:Create(
		notification,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, 0, 0)}
	)
	tweenIn:Play()

	-- Esperar y luego desvanecer
	task.delay(NOTIFICATION_LIFETIME, function()
		if notification and notification.Parent then
			-- Animación de desaparición
			local tweenOut = TweenService:Create(
				notification,
				TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					BackgroundTransparency = 1,
					TextTransparency = 1,
					Position = UDim2.new(1, 50, 0, 0)
				}
			)

			-- También desvanecer el stroke
			TweenService:Create(
				stroke,
				TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Transparency = 1}
			):Play()

			tweenOut:Play()
			tweenOut.Completed:Connect(function()
				notification:Destroy()
			end)
		end
	end)
end

-- Rastrear el valor anterior de dinero
local previousMoney = 0

-- Inicializar con el valor actual
local function setupMoneyListener()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[MoneyNotifications] No se encontró leaderstats")
		return
	end

	local moneyValue = leaderstats:WaitForChild("Money", 5)
	if not moneyValue then
		warn("[MoneyNotifications] No se encontró Money en leaderstats")
		return
	end

	-- Inicializar valor anterior
	previousMoney = moneyValue.Value

	-- Escuchar cambios en el valor de dinero
	moneyValue:GetPropertyChangedSignal("Value"):Connect(function()
		local newMoney = moneyValue.Value
		local difference = newMoney - previousMoney

		-- Solo mostrar notificación si se ganó dinero (diferencia positiva)
		if difference > 0 then
			createMoneyNotification(difference)
		end

		-- Actualizar valor anterior
		previousMoney = newMoney
	end)

	print("[MoneyNotifications] ✅ Sistema de notificaciones de dinero inicializado")
end

-- Inicializar
setupMoneyListener()
