-- StarterGui > OrbNotificationManager (LocalScript)
-- Sistema de notificaciones flotantes cuando recoges orbs
-- TÚ diseñas el estilo, este script solo genera y destruye las notificaciones

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)

-- Crear RemoteEvent para notificaciones (añadirlo al servidor después)
local ShowOrbNotificationEvent = RemoteEvents:WaitForChild("ShowOrbNotification", 10)

-- ==================== CONFIGURACIÓN ====================
local MAX_NOTIFICATIONS = 5           -- Máximo de notificaciones simultáneas
local NOTIFICATION_LIFETIME = 2       -- Duración en pantalla (segundos)
local NOTIFICATION_FADE_TIME = 0.5    -- Tiempo de desvanecimiento
local NOTIFICATION_SPACING = 10       -- Espacio entre notificaciones (píxeles)

-- ==================== VARIABLES ====================
local activeNotifications = {}        -- Lista de notificaciones activas
local notificationQueue = {}          -- Cola de notificaciones pendientes

-- ==================== CREAR CONTENEDOR ====================
-- Crea el ScreenGui que contendrá las notificaciones
local notificationGui = Instance.new("ScreenGui")
notificationGui.Name = "OrbNotifications"
notificationGui.ResetOnSpawn = false
notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationGui.Parent = playerGui

-- Contenedor para las notificaciones
local notificationsContainer = Instance.new("Frame")
notificationsContainer.Name = "Container"
notificationsContainer.Size = UDim2.new(0, 300, 1, 0)
notificationsContainer.Position = UDim2.new(1, -320, 0, 20)  -- Esquina superior derecha
notificationsContainer.BackgroundTransparency = 1
notificationsContainer.Parent = notificationGui

-- ==================== FUNCIONES ====================

-- Crea una notificación visual
-- TÚ PUEDES PERSONALIZAR ESTA FUNCIÓN PARA CAMBIAR EL DISEÑO
local function createNotification(orbType, expAmount, orbColor)
	local notification = Instance.new("Frame")
	notification.Name = "Notification_" .. orbType
	notification.Size = UDim2.new(1, 0, 0, 60)  -- Ancho 100%, Alto 60px
	notification.BackgroundColor3 = orbColor
	notification.BackgroundTransparency = 0.3
	notification.BorderSizePixel = 0
	notification.ClipsDescendants = true

	-- Borde brillante (opcional, puedes quitarlo)
	local border = Instance.new("UIStroke")
	border.Color = orbColor
	border.Thickness = 2
	border.Transparency = 0
	border.Parent = notification

	-- Esquinas redondeadas (opcional, puedes quitarlo)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	-- Texto de EXP
	local expLabel = Instance.new("TextLabel")
	expLabel.Name = "EXPLabel"
	expLabel.Size = UDim2.new(1, -20, 1, 0)
	expLabel.Position = UDim2.new(0, 10, 0, 0)
	expLabel.BackgroundTransparency = 1
	expLabel.Text = string.format("+%d EXP", expAmount)
	expLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	expLabel.TextSize = 24
	expLabel.TextXAlignment = Enum.TextXAlignment.Left
	expLabel.TextYAlignment = Enum.TextYAlignment.Center
	expLabel.Font = Enum.Font.GothamBold
	expLabel.TextStrokeTransparency = 0.5
	expLabel.Parent = notification

	-- Ícono de orb (opcional)
	local orbIcon = Instance.new("Frame")
	orbIcon.Name = "OrbIcon"
	orbIcon.Size = UDim2.new(0, 40, 0, 40)
	orbIcon.Position = UDim2.new(1, -50, 0.5, -20)
	orbIcon.BackgroundColor3 = orbColor
	orbIcon.BorderSizePixel = 0
	orbIcon.Parent = notification

	local orbCorner = Instance.new("UICorner")
	orbCorner.CornerRadius = UDim.new(1, 0)  -- Círculo perfecto
	orbCorner.Parent = orbIcon

	return notification
end

-- Actualiza las posiciones de todas las notificaciones activas
local function updateNotificationPositions()
	for i, notif in ipairs(activeNotifications) do
		if notif and notif.Parent then
			local targetPosition = UDim2.new(0, 0, 0, (i - 1) * (60 + NOTIFICATION_SPACING))

			-- Animar movimiento suave
			local tween = TweenService:Create(
				notif,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = targetPosition}
			)
			tween:Play()
		end
	end
end

-- Elimina una notificación con animación
local function removeNotification(notification)
	if not notification or not notification.Parent then return end

	-- Encontrar y eliminar de la lista activa
	for i, notif in ipairs(activeNotifications) do
		if notif == notification then
			table.remove(activeNotifications, i)
			break
		end
	end

	-- Animación de desvanecimiento
	local fadeTween = TweenService:Create(
		notification,
		TweenInfo.new(NOTIFICATION_FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = 1,
			Position = notification.Position + UDim2.new(0.2, 0, 0, 0)  -- Mover a la derecha
		}
	)

	-- Desvanecer texto e ícono también
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(NOTIFICATION_FADE_TIME), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		elseif child:IsA("Frame") and child.Name == "OrbIcon" then
			TweenService:Create(child, TweenInfo.new(NOTIFICATION_FADE_TIME), {BackgroundTransparency = 1}):Play()
		elseif child:IsA("UIStroke") then
			TweenService:Create(child, TweenInfo.new(NOTIFICATION_FADE_TIME), {Transparency = 1}):Play()
		end
	end

	fadeTween:Play()

	-- Destruir después de la animación
	task.delay(NOTIFICATION_FADE_TIME, function()
		if notification then
			notification:Destroy()
		end
	end)

	-- Actualizar posiciones de las restantes
	updateNotificationPositions()

	-- Procesar cola si hay notificaciones pendientes
	if #notificationQueue > 0 then
		local nextNotif = table.remove(notificationQueue, 1)
		task.wait(0.1)
		showNotification(nextNotif.orbType, nextNotif.expAmount, nextNotif.orbColor)
	end
end

-- Muestra una nueva notificación
function showNotification(orbType, expAmount, orbColor)
	-- Si ya hay el máximo de notificaciones, añadir a la cola
	if #activeNotifications >= MAX_NOTIFICATIONS then
		table.insert(notificationQueue, {
			orbType = orbType,
			expAmount = expAmount,
			orbColor = orbColor
		})
		return
	end

	-- Crear la notificación
	local notification = createNotification(orbType, expAmount, orbColor)
	notification.Parent = notificationsContainer

	-- Posición inicial (fuera de pantalla a la derecha)
	notification.Position = UDim2.new(1.2, 0, 0, #activeNotifications * (60 + NOTIFICATION_SPACING))

	-- Añadir a la lista activa
	table.insert(activeNotifications, notification)

	-- Animación de entrada (desde la derecha)
	local targetPosition = UDim2.new(0, 0, 0, (#activeNotifications - 1) * (60 + NOTIFICATION_SPACING))
	local enterTween = TweenService:Create(
		notification,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = targetPosition}
	)
	enterTween:Play()

	-- Programar eliminación automática
	task.delay(NOTIFICATION_LIFETIME, function()
		removeNotification(notification)
	end)
end

-- ==================== ESCUCHAR EVENTOS ====================

if ShowOrbNotificationEvent then
	ShowOrbNotificationEvent.OnClientEvent:Connect(function(orbType, expAmount, orbColor)
		showNotification(orbType, expAmount, orbColor)
	end)
	print("[OrbNotificationManager] ✅ Sistema de notificaciones iniciado")
else
	warn("[OrbNotificationManager] ❌ No se encontró el RemoteEvent ShowOrbNotification")
end
