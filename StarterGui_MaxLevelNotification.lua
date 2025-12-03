-- StarterGui > MaxLevelNotification
-- Muestra notificación cuando el jugador alcanza su nivel máximo
-- TÚ DISEÑAS LA INTERFAZ, este script solo actualiza los datos
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

-- ==================== CONFIGURACIÓN ====================
local NOTIFICATION_DURATION = 5  -- Segundos que se muestra la notificación
local ANIMATION_DURATION = 0.5   -- Duración de animaciones de entrada/salida

-- ==================== BUSCAR GUI ====================
-- TÚ debes crear una ScreenGui llamada "MaxLevelNotificationGui" en StarterGui
-- Dentro debe haber un Frame llamado "NotificationFrame"
-- Ver GUIA_DISEÑO_MAX_LEVEL.md para más detalles

local notificationGui = playerGui:WaitForChild("MaxLevelNotificationGui", 10)
if not notificationGui then
	warn("[MaxLevelNotification] ❌ No se encontró ScreenGui 'MaxLevelNotificationGui' en StarterGui")
	warn("[MaxLevelNotification] 📘 Lee GUIA_DISEÑO_MAX_LEVEL.md para crear la interfaz")
	return
end

local notificationFrame = notificationGui:WaitForChild("NotificationFrame", 5)
if not notificationFrame then
	warn("[MaxLevelNotification] ❌ No se encontró Frame 'NotificationFrame' en MaxLevelNotificationGui")
	warn("[MaxLevelNotification] 📘 Lee GUIA_DISEÑO_MAX_LEVEL.md para crear la interfaz")
	return
end

-- La notificación debe estar oculta inicialmente
notificationFrame.Visible = false

-- ==================== FUNCIONES ====================

-- Actualiza los datos de la notificación
local function updateNotificationData(currentLevel, rebirths)
	-- Buscar elementos por nombre (TÚ defines estos nombres en tu diseño)

	-- TextLabel para mostrar nivel alcanzado (busca "LevelLabel" o "CurrentLevel")
	local levelLabel = notificationFrame:FindFirstChild("LevelLabel") or notificationFrame:FindFirstChild("CurrentLevel")
	if levelLabel and levelLabel:IsA("TextLabel") then
		levelLabel.Text = string.format("Nivel %d", currentLevel)
	end

	-- TextLabel para mostrar mensaje principal (busca "MessageLabel" o "MainMessage")
	local messageLabel = notificationFrame:FindFirstChild("MessageLabel") or notificationFrame:FindFirstChild("MainMessage")
	if messageLabel and messageLabel:IsA("TextLabel") then
		messageLabel.Text = "¡Nivel Máximo Alcanzado!"
	end

	-- TextLabel para mostrar cuántos rebirths tienes (busca "RebirthsLabel")
	local rebirthsLabel = notificationFrame:FindFirstChild("RebirthsLabel")
	if rebirthsLabel and rebirthsLabel:IsA("TextLabel") then
		rebirthsLabel.Text = string.format("Rebirths: %d", rebirths)
	end

	-- TextLabel para mostrar sugerencia (busca "SuggestionLabel" o "HintLabel")
	local suggestionLabel = notificationFrame:FindFirstChild("SuggestionLabel") or notificationFrame:FindFirstChild("HintLabel")
	if suggestionLabel and suggestionLabel:IsA("TextLabel") then
		suggestionLabel.Text = "¡Compra un Rebirth para aumentar tu nivel máximo!"
	end

	-- Calcular nivel máximo siguiente
	local nextMaxLevel = LevelManager.GetMaxLevel(rebirths + 1)
	local nextLevelLabel = notificationFrame:FindFirstChild("NextMaxLevelLabel")
	if nextLevelLabel and nextLevelLabel:IsA("TextLabel") then
		nextLevelLabel.Text = string.format("Siguiente nivel máximo: %d", nextMaxLevel)
	end
end

-- Anima la entrada de la notificación
local function animateIn()
	notificationFrame.Visible = true

	-- Guardar posición original
	local originalPosition = notificationFrame.Position
	local originalSize = notificationFrame.Size

	-- Empezar pequeño y fuera de pantalla (opcional)
	notificationFrame.Size = UDim2.new(0, 0, 0, 0)
	notificationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	notificationFrame.BackgroundTransparency = 1

	-- Animar tamaño y posición
	local sizeTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = originalSize,
			Position = originalPosition,
			BackgroundTransparency = notificationFrame.BackgroundTransparency or 0
		}
	)

	sizeTween:Play()

	-- Animar todos los elementos hijos (text labels, etc.)
	for _, child in ipairs(notificationFrame:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			-- Guardar transparencia original
			local originalTextTrans = child.TextTransparency
			local originalBgTrans = child.BackgroundTransparency

			child.TextTransparency = 1
			child.BackgroundTransparency = 1

			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				TextTransparency = originalTextTrans,
				BackgroundTransparency = originalBgTrans
			}):Play()
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			local originalImageTrans = child.ImageTransparency
			local originalBgTrans = child.BackgroundTransparency

			child.ImageTransparency = 1
			child.BackgroundTransparency = 1

			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				ImageTransparency = originalImageTrans,
				BackgroundTransparency = originalBgTrans
			}):Play()
		elseif child:IsA("Frame") then
			local originalBgTrans = child.BackgroundTransparency
			child.BackgroundTransparency = 1

			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				BackgroundTransparency = originalBgTrans
			}):Play()
		end
	end
end

-- Anima la salida de la notificación
local function animateOut()
	-- Animar tamaño y transparencia
	local fadeOutTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1
		}
	)

	-- Desvanecer todos los elementos hijos
	for _, child in ipairs(notificationFrame:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				TextTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				ImageTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		elseif child:IsA("Frame") then
			TweenService:Create(child, TweenInfo.new(ANIMATION_DURATION), {
				BackgroundTransparency = 1
			}):Play()
		end
	end

	fadeOutTween:Play()
	fadeOutTween.Completed:Wait()

	-- Ocultar frame
	notificationFrame.Visible = false
end

-- Muestra la notificación de nivel máximo
local function showMaxLevelNotification(currentLevel, rebirths)
	-- Si ya se está mostrando, no mostrar otra
	if notificationFrame.Visible then
		return
	end

	-- Actualizar datos
	updateNotificationData(currentLevel, rebirths)

	-- Animar entrada
	animateIn()

	-- Esperar duración
	task.wait(NOTIFICATION_DURATION)

	-- Animar salida
	animateOut()
end

-- ==================== ESCUCHAR EVENTOS ====================

MaxLevelReachedEvent.OnClientEvent:Connect(function(currentLevel, rebirths)
	print(string.format("[MaxLevelNotification] Nivel máximo alcanzado: %d (Rebirths: %d)", currentLevel, rebirths))
	showMaxLevelNotification(currentLevel, rebirths)
end)

print("[MaxLevelNotification] ✅ Sistema de notificación de nivel máximo iniciado")
print("[MaxLevelNotification] 📦 Usando frame: " .. notificationFrame.Name)
