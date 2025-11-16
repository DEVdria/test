--[[
═══════════════════════════════════════════════════════════════
    NOTIFICATION HANDLER - Sistema de Notificaciones
    Ubicación: StarterPlayer > StarterPlayerScripts

    Funcionalidad:
    - Recibe notificaciones del servidor
    - Muestra mensajes en pantalla
    - Se auto-destruyen después de unos segundos
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear RemoteEvent si no existe
local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
if not notificationEvent then
	notificationEvent = Instance.new("RemoteEvent")
	notificationEvent.Name = "SendNotification"
	notificationEvent.Parent = ReplicatedStorage
end

--[[
    Función: Mostrar notificación en pantalla
    Parámetros:
        message - El mensaje a mostrar
        color - Color de fondo (opcional)
--]]
local function showNotification(message, color)
	color = color or Color3.fromRGB(50, 50, 50)

	-- Crear ScreenGui si no existe
	local screenGui = playerGui:FindFirstChild("NotificationGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "NotificationGui"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.DisplayOrder = 100
		screenGui.Parent = playerGui
	end

	-- Crear frame de notificación
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 350, 0, 60)
	notification.Position = UDim2.new(0.5, -175, 0, -80)
	notification.BackgroundColor3 = color
	notification.BorderSizePixel = 0
	notification.Parent = screenGui

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notification

	-- Texto de la notificación
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 1, 0)
	textLabel.Position = UDim2.new(0, 10, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = message
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextWrapped = true
	textLabel.Parent = notification

	-- Animación de entrada
	notification:TweenPosition(
		UDim2.new(0.5, -175, 0, 20),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)

	-- Animación de salida y destrucción
	task.delay(3, function()
		notification:TweenPosition(
			UDim2.new(0.5, -175, 0, -80),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Back,
			0.5,
			true
		)

		task.wait(0.5)
		notification:Destroy()
	end)
end

-- Escuchar evento de notificaciones
notificationEvent.OnClientEvent:Connect(function(message, color)
	showNotification(message, color)
end)

print("Sistema de notificaciones cargado")
