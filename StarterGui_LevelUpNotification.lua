-- StarterGui > LevelUpNotification (LocalScript)
-- Muestra una notificación cuando el jugador sube de nivel
-- TÚ DISEÑAS LA GUI, este script solo la muestra con el nuevo nivel

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[LevelUpNotification] ❌ No se encontró carpeta RemoteEvents")
	return
end

local LevelUpEvent = RemoteEvents:WaitForChild("LevelUp", 10)
if not LevelUpEvent then
	warn("[LevelUpNotification] ❌ No se encontró RemoteEvent 'LevelUp'")
	return
end

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

-- Buscar el ScreenGui que TÚ diseñaste
local notificationGui = playerGui:WaitForChild("LevelUpNotificationGui", 10)
if not notificationGui then
	warn("[LevelUpNotification] ❌ No se encontró ScreenGui 'LevelUpNotificationGui'")
	warn("[LevelUpNotification] 📘 Crea un ScreenGui llamado 'LevelUpNotificationGui' en StarterGui")
	warn("[LevelUpNotification] 📘 Dentro debe tener un Frame llamado 'NotificationFrame'")
	return
end

-- Buscar el Frame principal
local notificationFrame = notificationGui:WaitForChild("NotificationFrame", 5)
if not notificationFrame then
	warn("[LevelUpNotification] ❌ No se encontró Frame 'NotificationFrame' dentro del ScreenGui")
	return
end

-- Buscar elementos opcionales dentro del Frame
local levelLabel = notificationFrame:FindFirstChild("LevelLabel", true)
	or notificationFrame:FindFirstChild("NewLevel", true)
	or notificationFrame:FindFirstChild("Level", true)

-- Ocultar la notificación al inicio
notificationFrame.Visible = false

-- ==================== CONFIGURACIÓN DE ANIMACIÓN ====================

local SHOW_DURATION = 0.5      -- Duración de la animación de entrada
local DISPLAY_TIME = 3         -- Tiempo que se muestra la notificación
local HIDE_DURATION = 0.5      -- Duración de la animación de salida

-- Configuración de animación (puedes personalizar)
local TWEEN_INFO_SHOW = TweenInfo.new(
	SHOW_DURATION,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)

local TWEEN_INFO_HIDE = TweenInfo.new(
	HIDE_DURATION,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

-- ==================== FUNCIONES ====================

-- Muestra la notificación con animación
local function showNotification(newLevel)
	-- Actualizar el texto del nivel (si existe)
	if levelLabel and levelLabel:IsA("TextLabel") then
		levelLabel.Text = tostring(newLevel)
	end

	-- Posición inicial (fuera de pantalla, arriba)
	notificationFrame.Position = UDim2.new(0.5, 0, -0.2, 0)
	notificationFrame.Visible = true

	-- Animar entrada (deslizar desde arriba)
	local showTween = TweenService:Create(
		notificationFrame,
		TWEEN_INFO_SHOW,
		{Position = UDim2.new(0.5, 0, 0.1, 0)}  -- Posición final (ajusta según tu diseño)
	)
	showTween:Play()

	-- Esperar el tiempo de display
	task.wait(SHOW_DURATION + DISPLAY_TIME)

	-- Animar salida (deslizar hacia arriba)
	local hideTween = TweenService:Create(
		notificationFrame,
		TWEEN_INFO_HIDE,
		{Position = UDim2.new(0.5, 0, -0.2, 0)}
	)
	hideTween:Play()

	-- Ocultar después de la animación
	hideTween.Completed:Connect(function()
		notificationFrame.Visible = false
	end)
end

-- ==================== ESCUCHAR EVENTO ====================

-- Cuando el jugador sube de nivel
LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
	showNotification(newLevel)
	print(string.format("[LevelUpNotification] ✨ Nivel %d alcanzado!", newLevel))
end)

print("[LevelUpNotification] ✅ Sistema de notificación de nivel iniciado")
print(string.format("[LevelUpNotification] 📦 Usando GUI: %s", notificationGui.Name))

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ LevelUpNotificationGui (ScreenGui)
	   └─ NotificationFrame (Frame)
	      └─ LevelLabel (TextLabel) - OPCIONAL, mostrará el número del nivel

	NOMBRES ALTERNATIVOS ACEPTADOS PARA LevelLabel:
	- LevelLabel
	- NewLevel
	- Level

	PERSONALIZACIÓN DE ANIMACIÓN:

	Puedes cambiar:
	- SHOW_DURATION: Velocidad de la animación de entrada
	- DISPLAY_TIME: Cuánto tiempo se muestra
	- HIDE_DURATION: Velocidad de la animación de salida

	Las posiciones en los tweens (líneas 71 y 81):
	- Posición inicial: UDim2.new(0.5, 0, -0.2, 0) (arriba, fuera de pantalla)
	- Posición final: UDim2.new(0.5, 0, 0.1, 0) (10% desde arriba)
	- Ajusta según tu diseño

	EJEMPLO DE DISEÑO SIMPLE:

	1. Crea un ScreenGui llamado "LevelUpNotificationGui"
	2. Dentro, crea un Frame llamado "NotificationFrame"
	   - Size: {0.3, 0}, {0.15, 0}
	   - Position: {0.5, 0}, {0.1, 0}
	   - AnchorPoint: 0.5, 0
	   - BackgroundColor3: 0, 0, 0
	   - BackgroundTransparency: 0.3
	3. Dentro del Frame, crea un TextLabel llamado "LevelLabel"
	   - Size: {1, 0}, {1, 0}
	   - Text: "50"
	   - TextScaled: true
	   - Font: GothamBold
	   - TextColor3: 255, 255, 0

	El script actualizará automáticamente el texto con el nuevo nivel.
]]
