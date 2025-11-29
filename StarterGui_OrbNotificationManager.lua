-- StarterGui > OrbNotificationManager (LocalScript)
-- Sistema de notificaciones flotantes cuando recoges orbs
-- TÚ diseñas la interfaz completa, este script solo actualiza los datos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local ShowOrbNotificationEvent = RemoteEvents:WaitForChild("ShowOrbNotification", 10)

-- ==================== CONFIGURACIÓN ====================
local MAX_NOTIFICATIONS = 5           -- Máximo de notificaciones simultáneas
local NOTIFICATION_LIFETIME = 2       -- Duración en pantalla (segundos)
local NOTIFICATION_SPACING = 10       -- Espacio entre notificaciones (píxeles)

-- ==================== VARIABLES ====================
local activeNotifications = {}        -- Lista de notificaciones activas {frame, data}
local notificationQueue = {}          -- Cola de notificaciones pendientes

-- ==================== BUSCAR CONTENEDOR GUI ====================
-- TÚ debes crear una ScreenGui llamada "OrbNotifications" en StarterGui
-- Dentro debe haber un Frame llamado "Container"
-- Ver GUIA_DISEÑO_NOTIFICACIONES.md para más detalles

local notificationGui = playerGui:WaitForChild("OrbNotifications", 10)
if not notificationGui then
	warn("[OrbNotificationManager] ❌ No se encontró ScreenGui 'OrbNotifications' en StarterGui")
	warn("[OrbNotificationManager] 📘 Lee GUIA_DISEÑO_NOTIFICACIONES.md para crear la interfaz")
	return
end

local notificationsContainer = notificationGui:WaitForChild("Container", 5)
if not notificationsContainer then
	warn("[OrbNotificationManager] ❌ No se encontró Frame 'Container' en OrbNotifications")
	warn("[OrbNotificationManager] 📘 Lee GUIA_DISEÑO_NOTIFICACIONES.md para crear la interfaz")
	return
end

-- Buscar el template de notificación (debe estar dentro del Container)
local notificationTemplate = notificationsContainer:FindFirstChild("NotificationTemplate")
if not notificationTemplate then
	warn("[OrbNotificationManager] ❌ No se encontró 'NotificationTemplate' en Container")
	warn("[OrbNotificationManager] 📘 Lee GUIA_DISEÑO_NOTIFICACIONES.md para crear el template")
	return
end

-- El template debe estar oculto inicialmente
notificationTemplate.Visible = false

-- ==================== FUNCIONES ====================

-- Actualiza las posiciones de todas las notificaciones activas
local function updateNotificationPositions()
	for i, notifData in ipairs(activeNotifications) do
		local notif = notifData.frame
		if notif and notif.Parent then
			local targetPosition = UDim2.new(0, 0, 0, (i - 1) * (notif.Size.Y.Offset + NOTIFICATION_SPACING))

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

-- Elimina una notificación
local function removeNotification(notifData)
	local notification = notifData.frame
	if not notification or not notification.Parent then return end

	-- Encontrar y eliminar de la lista activa
	for i, data in ipairs(activeNotifications) do
		if data == notifData then
			table.remove(activeNotifications, i)
			break
		end
	end

	-- Animación de desvanecimiento (mueve a la derecha y desvanece)
	local fadeTween = TweenService:Create(
		notification,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = 1,
			Position = notification.Position + UDim2.new(0.2, 0, 0, 0)
		}
	)

	-- Desvanecer todos los elementos de texto e imagen
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(0.3), {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			TweenService:Create(child, TweenInfo.new(0.3), {
				ImageTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif child:IsA("Frame") then
			TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		elseif child:IsA("UIStroke") then
			TweenService:Create(child, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
	end

	fadeTween:Play()

	-- Destruir después de la animación
	task.delay(0.4, function()
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

-- Actualiza los elementos de la notificación con los datos del orb
local function updateNotificationData(notification, orbType, expAmount, orbColor)
	-- Buscar elementos por nombre (TÚ defines estos nombres en tu diseño)

	-- TextLabel para mostrar EXP (busca "EXPLabel" o "ExpAmount")
	local expLabel = notification:FindFirstChild("EXPLabel") or notification:FindFirstChild("ExpAmount")
	if expLabel and expLabel:IsA("TextLabel") then
		expLabel.Text = string.format("+%d EXP", expAmount)
	end

	-- TextLabel para mostrar tipo de orb (busca "OrbTypeLabel")
	local orbTypeLabel = notification:FindFirstChild("OrbTypeLabel")
	if orbTypeLabel and orbTypeLabel:IsA("TextLabel") then
		orbTypeLabel.Text = orbType
	end

	-- Frame/ImageLabel para ícono del orb (busca "OrbIcon")
	local orbIcon = notification:FindFirstChild("OrbIcon")
	if orbIcon then
		if orbIcon:IsA("Frame") or orbIcon:IsA("ImageLabel") then
			orbIcon.BackgroundColor3 = orbColor
		end
	end

	-- Cambiar color de fondo del frame principal si lo deseas
	notification.BackgroundColor3 = orbColor

	-- Cambiar color del borde si existe UIStroke
	local stroke = notification:FindFirstChild("UIStroke")
	if stroke then
		stroke.Color = orbColor
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

	-- Clonar el template
	local notification = notificationTemplate:Clone()
	notification.Name = "Notification_" .. orbType .. "_" .. tick()
	notification.Visible = true
	notification.Parent = notificationsContainer

	-- Actualizar datos de la notificación
	updateNotificationData(notification, orbType, expAmount, orbColor)

	-- Posición inicial (fuera de pantalla a la derecha)
	local notifHeight = notification.Size.Y.Offset
	notification.Position = UDim2.new(1.2, 0, 0, #activeNotifications * (notifHeight + NOTIFICATION_SPACING))

	-- Añadir a la lista activa
	local notifData = {
		frame = notification,
		orbType = orbType,
		expAmount = expAmount,
		orbColor = orbColor
	}
	table.insert(activeNotifications, notifData)

	-- Animación de entrada (desde la derecha)
	local targetPosition = UDim2.new(0, 0, 0, (#activeNotifications - 1) * (notifHeight + NOTIFICATION_SPACING))
	local enterTween = TweenService:Create(
		notification,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = targetPosition}
	)
	enterTween:Play()

	-- Programar eliminación automática
	task.delay(NOTIFICATION_LIFETIME, function()
		removeNotification(notifData)
	end)
end

-- ==================== ESCUCHAR EVENTOS ====================

if ShowOrbNotificationEvent then
	ShowOrbNotificationEvent.OnClientEvent:Connect(function(orbType, expAmount, orbColor)
		showNotification(orbType, expAmount, orbColor)
	end)
	print("[OrbNotificationManager] ✅ Sistema de notificaciones iniciado")
	print("[OrbNotificationManager] 📦 Usando template: " .. notificationTemplate.Name)
else
	warn("[OrbNotificationManager] ❌ No se encontró el RemoteEvent ShowOrbNotification")
end
