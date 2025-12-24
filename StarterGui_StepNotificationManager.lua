-- StarterGui > StepNotificationManager (LocalScript)
-- Sistema de notificaciones animadas cuando caminas y ganas EXP
-- Animación: Centro → Lado Aleatorio → Centro Abajo

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local ShowStepNotificationEvent = RemoteEvents:WaitForChild("ShowStepNotification", 10)

-- ==================== CONFIGURACIÓN ====================
local NOTIFICATION_LIFETIME = 2       -- Duración total de la animación (segundos)
local BOUNDARY_OFFSET_MIN = 50        -- Offset mínimo desde el centro (píxeles)
local BOUNDARY_OFFSET_MAX = 150       -- Offset máximo desde el centro (píxeles)

-- ==================== BUSCAR CONTENEDOR GUI ====================
-- TÚ debes crear una ScreenGui llamada "StepNotifications" en StarterGui
-- Dentro debe haber un Frame llamado "BoundaryFrame" que define los límites de movimiento aleatorio
-- Y un Frame llamado "NotificationTemplate" que es el template de la notificación

local notificationGui = playerGui:WaitForChild("StepNotifications", 10)
if not notificationGui then
	warn("[StepNotificationManager] ❌ No se encontró ScreenGui 'StepNotifications' en StarterGui")
	warn("[StepNotificationManager] 📘 Crea un ScreenGui llamado 'StepNotifications' con un BoundaryFrame y NotificationTemplate")
	return
end

-- Frame que define los límites del movimiento aleatorio
local boundaryFrame = notificationGui:WaitForChild("BoundaryFrame", 5)
if not boundaryFrame then
	warn("[StepNotificationManager] ❌ No se encontró Frame 'BoundaryFrame' en StepNotifications")
	warn("[StepNotificationManager] 📘 Crea un Frame llamado 'BoundaryFrame' que defina los límites")
	return
end

-- Buscar el template de notificación
local notificationTemplate = notificationGui:FindFirstChild("NotificationTemplate")
if not notificationTemplate then
	warn("[StepNotificationManager] ❌ No se encontró 'NotificationTemplate'")
	warn("[StepNotificationManager] 📘 Crea un Frame llamado 'NotificationTemplate'")
	return
end

-- El template debe estar oculto inicialmente
notificationTemplate.Visible = false
notificationTemplate.Parent = notificationGui  -- Debe estar directamente en el ScreenGui

print("[StepNotificationManager] ✅ GUI encontrada correctamente")

-- ==================== FUNCIONES ====================

-- Genera una posición aleatoria dentro del BoundaryFrame
local function getRandomPosition()
	-- Obtener el centro de la pantalla
	local screenCenter = UDim2.new(0.5, 0, 0.5, 0)

	-- Generar offset aleatorio dentro de los límites del BoundaryFrame
	local randomX = math.random(-BOUNDARY_OFFSET_MAX, BOUNDARY_OFFSET_MAX)
	local randomY = math.random(-BOUNDARY_OFFSET_MAX, BOUNDARY_OFFSET_MAX)

	-- Asegurar que está dentro de los límites mínimos
	if math.abs(randomX) < BOUNDARY_OFFSET_MIN then
		randomX = randomX < 0 and -BOUNDARY_OFFSET_MIN or BOUNDARY_OFFSET_MIN
	end
	if math.abs(randomY) < BOUNDARY_OFFSET_MIN then
		randomY = randomY < 0 and -BOUNDARY_OFFSET_MIN or BOUNDARY_OFFSET_MIN
	end

	return UDim2.new(0.5, randomX, 0.5, randomY)
end

-- Muestra una nueva notificación con la animación personalizada
local function showNotification(baseEXP, multiplier, finalEXP)
	-- Clonar el template
	local notification = notificationTemplate:Clone()
	notification.Name = "StepNotification_" .. tick()
	notification.Visible = true
	notification.Parent = notificationGui

	-- Actualizar el texto de la notificación
	local expLabel = notification:FindFirstChild("EXPLabel", true)
	if expLabel and expLabel:IsA("TextLabel") then
		-- Si hay multiplicador mayor que 1, mostrar el multiplicador
		if multiplier > 1 then
			expLabel.Text = string.format("+%d 👟 (x%.1f = %d)", baseEXP, multiplier, finalEXP)
		else
			-- Sin multiplicador, mostrar solo el EXP normal
			expLabel.Text = string.format("+%d 👟", finalEXP)
		end
	end

	-- FASE 1: Posición inicial en el CENTRO de la pantalla
	notification.Position = UDim2.new(0.5, 0, 0.5, 0)
	notification.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Aparecer con fade in rápido
	notification.BackgroundTransparency = 1
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") then
			child.TextTransparency = 1
			child.TextStrokeTransparency = 1
		elseif child:IsA("ImageLabel") then
			child.ImageTransparency = 1
		end
	end

	-- Fade in inicial
	TweenService:Create(notification, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(0.1), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
		elseif child:IsA("ImageLabel") then
			TweenService:Create(child, TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
		end
	end

	-- FASE 2: Moverse a una posición ALEATORIA dentro del BoundaryFrame
	task.wait(0.2)
	local randomPos = getRandomPosition()
	local moveToRandomTween = TweenService:Create(
		notification,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = randomPos}
	)
	moveToRandomTween:Play()

	-- FASE 3: Moverse al CENTRO ABAJO
	task.wait(0.6)
	local centerBottom = UDim2.new(0.5, 0, 0.85, 0)
	local moveToCenterBottomTween = TweenService:Create(
		notification,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{Position = centerBottom}
	)
	moveToCenterBottomTween:Play()

	-- FASE 4: Fade out y destruir
	task.wait(0.7)
	local fadeTween = TweenService:Create(
		notification,
		TweenInfo.new(0.3),
		{BackgroundTransparency = 1}
	)
	fadeTween:Play()

	for _, child in ipairs(notification:GetDescendants()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(0.3), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		elseif child:IsA("ImageLabel") then
			TweenService:Create(child, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
		end
	end

	-- Destruir después de la animación
	task.delay(0.4, function()
		if notification then
			notification:Destroy()
		end
	end)
end

-- ==================== ESCUCHAR EVENTOS ====================

if ShowStepNotificationEvent then
	ShowStepNotificationEvent.OnClientEvent:Connect(function(baseEXP, multiplier, finalEXP)
		showNotification(baseEXP, multiplier, finalEXP)
	end)
	print("[StepNotificationManager] ✅ Sistema de notificaciones de pasos iniciado")
	print("[StepNotificationManager] 📦 Usando template: " .. notificationTemplate.Name)
	print("[StepNotificationManager] 🎯 Mostrará multiplicadores de rebirth en las notificaciones")
else
	warn("[StepNotificationManager] ❌ No se encontró el RemoteEvent ShowStepNotification")
end
