-- StarterGui > MaxLevelNotification
-- Muestra notificación cuando el jugador alcanza su nivel máximo
-- INSTRUCCIONES: Pegar este script como LocalScript en StarterGui

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MaxLevelReachedEvent = RemoteEvents:WaitForChild("MaxLevelReached")

-- Esperar LevelManager para obtener información
local Modules = ReplicatedStorage:WaitForChild("Modules")
local LevelManager = require(Modules:WaitForChild("LevelManager"))

-- Configuración de la notificación
local NOTIFICATION_DURATION = 5  -- Segundos que se muestra
local FADE_IN_TIME = 0.3
local FADE_OUT_TIME = 0.5

-- Función para crear la notificación de nivel máximo
local function createMaxLevelNotification(currentLevel, rebirths)
	-- Crear ScreenGui si no existe
	local screenGui = playerGui:FindFirstChild("MaxLevelNotificationGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MaxLevelNotificationGui"
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 100  -- Asegurar que esté encima de otros GUIs
		screenGui.Parent = playerGui
	end

	-- Crear frame principal de la notificación
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "MaxLevelNotification"
	notificationFrame.Size = UDim2.new(0, 400, 0, 150)
	notificationFrame.Position = UDim2.new(0.5, -200, 0.5, -75)  -- Centro de la pantalla
	notificationFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)  -- Naranja/Dorado
	notificationFrame.BorderSizePixel = 0
	notificationFrame.BackgroundTransparency = 1  -- Empezar invisible
	notificationFrame.Parent = screenGui

	-- Añadir UICorner para bordes redondeados
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = notificationFrame

	-- Añadir borde brillante
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 0)  -- Dorado brillante
	stroke.Thickness = 3
	stroke.Transparency = 1
	stroke.Parent = notificationFrame

	-- Título principal
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 40)
	titleLabel.Position = UDim2.new(0, 10, 0, 15)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "⚠️ NIVEL MÁXIMO ALCANZADO ⚠️"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextTransparency = 1
	titleLabel.Parent = notificationFrame

	-- Nivel actual
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, -20, 0, 30)
	levelLabel.Position = UDim2.new(0, 10, 0, 55)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = string.format("Has alcanzado el nivel %d", currentLevel)
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 16
	levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	levelLabel.TextTransparency = 1
	levelLabel.Parent = notificationFrame

	-- Mensaje de rebirth
	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Size = UDim2.new(1, -20, 0, 40)
	rebirthLabel.Position = UDim2.new(0, 10, 0, 90)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = "¡Compra un REBIRTH para aumentar tu nivel máximo!"
	rebirthLabel.Font = Enum.Font.GothamBold
	rebirthLabel.TextSize = 14
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	rebirthLabel.TextTransparency = 1
	rebirthLabel.TextWrapped = true
	rebirthLabel.Parent = notificationFrame

	-- Animación de entrada
	local fadeInTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.1}
	)

	local strokeFadeIn = TweenService:Create(
		stroke,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Transparency = 0}
	)

	local titleFadeIn = TweenService:Create(
		titleLabel,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)

	local levelFadeIn = TweenService:Create(
		levelLabel,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)

	local rebirthFadeIn = TweenService:Create(
		rebirthLabel,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)

	-- Escala de entrada (efecto de "pop")
	notificationFrame.Size = UDim2.new(0, 0, 0, 0)
	notificationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

	local scaleTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, 400, 0, 150),
			Position = UDim2.new(0.5, -200, 0.5, -75)
		}
	)

	-- Reproducir animaciones de entrada
	scaleTween:Play()
	fadeInTween:Play()
	strokeFadeIn:Play()
	titleFadeIn:Play()
	levelFadeIn:Play()
	rebirthFadeIn:Play()

	-- Esperar duración de la notificación
	task.wait(NOTIFICATION_DURATION)

	-- Animación de salida
	local fadeOutTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)

	local strokeFadeOut = TweenService:Create(
		stroke,
		TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Transparency = 1}
	)

	local titleFadeOut = TweenService:Create(
		titleLabel,
		TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1}
	)

	local levelFadeOut = TweenService:Create(
		levelLabel,
		TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1}
	)

	local rebirthFadeOut = TweenService:Create(
		rebirthLabel,
		TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1}
	)

	fadeOutTween:Play()
	strokeFadeOut:Play()
	titleFadeOut:Play()
	levelFadeOut:Play()
	rebirthFadeOut:Play()

	-- Eliminar después de la animación
	fadeOutTween.Completed:Wait()
	notificationFrame:Destroy()
end

-- Escuchar evento de nivel máximo alcanzado
MaxLevelReachedEvent.OnClientEvent:Connect(function(currentLevel, rebirths)
	print(string.format("[MaxLevelNotification] Nivel máximo alcanzado: %d (Rebirths: %d)", currentLevel, rebirths))
	createMaxLevelNotification(currentLevel, rebirths)
end)

print("[MaxLevelNotification] ✅ Sistema de notificación de nivel máximo iniciado")
