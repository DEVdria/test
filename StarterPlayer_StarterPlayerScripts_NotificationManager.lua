--[[
	NOTIFICATION MANAGER - LocalScript
	Sistema de notificaciones en pantalla para mostrar mensajes al jugador

	UBICACIÓN: StarterPlayer/StarterPlayerScripts/NotificationManager

	USO DESDE OTROS SCRIPTS:
	local NotificationManager = _G.NotificationManager

	-- Mostrar notificación simple
	NotificationManager.Show("¡Zona comprada!", "Success")

	-- Mostrar con duración personalizada
	NotificationManager.Show("Necesitas más dinero", "Error", 5)

	-- Tipos disponibles: "Success", "Error", "Warning", "Info", "Money"
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Importar configuración
local Modules = ReplicatedStorage:WaitForChild("Modules")
local NotificationConfig = require(Modules:WaitForChild("NotificationConfig"))

print("[NotificationManager] 🔔 Sistema de notificaciones inicializado")

-- ==================== VARIABLES ====================

local notificationGui = nil
local notificationTemplate = nil
local notificationsContainer = nil
local activeNotifications = {}  -- Lista de notificaciones activas

-- ==================== FUNCIONES ====================

-- Inicializa el sistema de notificaciones
local function initialize()
	-- Buscar el ScreenGui
	notificationGui = playerGui:WaitForChild(NotificationConfig.GuiNames.ScreenGui, 10)

	if not notificationGui then
		warn("[NotificationManager] ⚠️ No se encontró ScreenGui:", NotificationConfig.GuiNames.ScreenGui)
		warn("[NotificationManager] 📘 Crea un ScreenGui llamado 'NotificationGui' en StarterGui")
		return false
	end

	-- Buscar el template
	notificationTemplate = notificationGui:FindFirstChild(NotificationConfig.GuiNames.Template)

	if not notificationTemplate then
		warn("[NotificationManager] ⚠️ No se encontró template:", NotificationConfig.GuiNames.Template)
		warn("[NotificationManager] 📘 Crea un Frame llamado 'NotificationTemplate' dentro de NotificationGui")
		return false
	end

	-- Ocultar el template
	notificationTemplate.Visible = false

	-- Buscar o crear contenedor de notificaciones
	notificationsContainer = notificationGui:FindFirstChild(NotificationConfig.GuiNames.Container)
	if not notificationsContainer then
		notificationsContainer = Instance.new("Folder")
		notificationsContainer.Name = NotificationConfig.GuiNames.Container
		notificationsContainer.Parent = notificationGui
	end

	print("[NotificationManager] ✅ Sistema inicializado correctamente")
	return true
end

-- Actualiza las posiciones de todas las notificaciones activas
local function updatePositions()
	for i, notification in ipairs(activeNotifications) do
		local targetY = NotificationConfig.VisiblePosition.Y.Scale
		local offsetY = (i - 1) * NotificationConfig.StackOffset

		local targetPosition = UDim2.new(
			NotificationConfig.VisiblePosition.X.Scale,
			NotificationConfig.VisiblePosition.X.Offset,
			targetY,
			offsetY
		)

		local tween = TweenService:Create(
			notification,
			TweenInfo.new(
				NotificationConfig.Animation.TweenTime,
				NotificationConfig.Animation.EasingStyle,
				NotificationConfig.Animation.EasingDirection
			),
			{Position = targetPosition}
		)

		tween:Play()
	end
end

-- Remueve una notificación
local function removeNotification(notification)
	-- Encontrar índice
	local index = table.find(activeNotifications, notification)
	if index then
		table.remove(activeNotifications, index)
	end

	-- Animar salida
	local tweenOut = TweenService:Create(
		notification,
		TweenInfo.new(
			NotificationConfig.Animation.TweenTime,
			NotificationConfig.Animation.EasingStyle,
			Enum.EasingDirection.In
		),
		{
			Position = UDim2.new(0.5, 0, -0.2, 0),
			BackgroundTransparency = 1
		}
	)

	tweenOut:Play()

	tweenOut.Completed:Connect(function()
		notification:Destroy()
		updatePositions()
	end)
end

-- Muestra una notificación
local function showNotification(message, notifType, duration)
	if not notificationGui or not notificationTemplate then
		warn("[NotificationManager] ❌ Sistema no inicializado")
		return
	end

	-- Valores por defecto
	notifType = notifType or "Info"
	duration = duration or NotificationConfig.DefaultDuration

	-- Obtener configuración del tipo
	local typeConfig = NotificationConfig.GetType(notifType)

	-- Clonar el template
	local notification = notificationTemplate:Clone()
	notification.Name = "Notification_" .. tick()
	notification.Visible = true
	notification.Position = NotificationConfig.StartPosition
	notification.AnchorPoint = Vector2.new(0.5, 0)

	-- Configurar mensaje
	local messageLabel = notification:FindFirstChild(NotificationConfig.GuiNames.MessageLabel, true)
	if messageLabel and messageLabel:IsA("TextLabel") then
		messageLabel.Text = NotificationConfig.FormatErrorMessage(message)
		messageLabel.TextColor3 = typeConfig.Color
	end

	-- Configurar icono (opcional)
	local iconLabel = notification:FindFirstChild(NotificationConfig.GuiNames.IconLabel, true)
	if iconLabel and iconLabel:IsA("TextLabel") then
		iconLabel.Text = typeConfig.Icon
	end

	-- Configurar fondo (opcional)
	local backgroundFrame = notification:FindFirstChild(NotificationConfig.GuiNames.BackgroundFrame, true)
	if backgroundFrame and backgroundFrame:IsA("Frame") or backgroundFrame and backgroundFrame:IsA("ImageLabel") then
		-- Aplicar color al borde o fondo si existe
		if backgroundFrame:FindFirstChild("Border") then
			backgroundFrame.Border.BackgroundColor3 = typeConfig.Color
		end
	end

	-- Añadir a la lista de activas
	table.insert(activeNotifications, notification)
	notification.Parent = notificationGui

	-- Animar entrada
	updatePositions()

	-- Programar eliminación
	task.delay(duration, function()
		if notification and notification.Parent then
			removeNotification(notification)
		end
	end)

	print(string.format("[NotificationManager] 🔔 Notificación mostrada: %s (%s)", message, notifType))
end

-- ==================== INICIALIZACIÓN ====================

local initialized = initialize()

-- ==================== GLOBAL API ====================

local NotificationManager = {}

-- Muestra una notificación
-- @param message: El mensaje a mostrar
-- @param notifType: "Success", "Error", "Warning", "Info", "Money" (opcional, default: "Info")
-- @param duration: Duración en segundos (opcional, default: 3)
function NotificationManager.Show(message, notifType, duration)
	if not initialized then
		warn("[NotificationManager] ❌ No se puede mostrar notificación - sistema no inicializado")
		return
	end

	showNotification(message, notifType, duration)
end

-- Muestra una notificación de éxito
function NotificationManager.Success(message, duration)
	NotificationManager.Show(message, "Success", duration)
end

-- Muestra una notificación de error
function NotificationManager.Error(message, duration)
	NotificationManager.Show(message, "Error", duration)
end

-- Muestra una notificación de advertencia
function NotificationManager.Warning(message, duration)
	NotificationManager.Show(message, "Warning", duration)
end

-- Muestra una notificación de información
function NotificationManager.Info(message, duration)
	NotificationManager.Show(message, "Info", duration)
end

-- Muestra una notificación de dinero
function NotificationManager.Money(message, duration)
	NotificationManager.Show(message, "Money", duration)
end

-- Exponer globalmente
_G.NotificationManager = NotificationManager

print("[NotificationManager] ✅ API global expuesta como _G.NotificationManager")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA EN STARTERGUI:

	StarterGui
	└─ NotificationGui (ScreenGui)
	   ├─ NotificationTemplate (Frame) - DISEÑA ESTO COMO QUIERAS
	   │  ├─ Message (TextLabel) - Muestra el mensaje
	   │  ├─ Icon (TextLabel) - OPCIONAL, muestra el icono (✅❌⚠️ℹ️💰)
	   │  └─ Background (Frame/ImageLabel) - OPCIONAL, fondo de la notificación
	   └─ NotificationsContainer (Folder) - SE CREA AUTOMÁTICAMENTE

	DISEÑO SUGERIDO PARA NotificationTemplate:
	- Frame con fondo semitransparente
	- Size: {0.3, 0}, {0.08, 0}
	- AnchorPoint: 0.5, 0
	- BackgroundColor3: Negro con Transparency: 0.3
	- BorderSizePixel: 0
	- Dentro: TextLabel para el mensaje

	EJEMPLO DE USO EN OTROS SCRIPTS:
	```lua
	local NotificationManager = _G.NotificationManager

	-- Esperar a que esté disponible
	while not NotificationManager do
		task.wait(0.1)
		NotificationManager = _G.NotificationManager
	end

	-- Mostrar notificaciones
	NotificationManager.Success("¡Zona desbloqueada!")
	NotificationManager.Error("Necesitas más dinero")
	NotificationManager.Warning("Zona bloqueada")
	NotificationManager.Info("Bienvenido")
	NotificationManager.Money("¡+1000 monedas!")

	-- O con duración personalizada
	NotificationManager.Show("Mensaje personalizado", "Error", 5)
	```

	PERSONALIZACIÓN:
	- Edita NotificationConfig.lua para cambiar colores, iconos, tiempos
	- Diseña NotificationTemplate con tu estilo visual
	- El script se encarga de clonar y animar automáticamente
]]
