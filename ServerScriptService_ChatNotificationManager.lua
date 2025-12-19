--[[
	CHAT NOTIFICATION MANAGER - Script
	Gestiona las notificaciones en el chat del juego
	Soporta tanto TextChatService (nuevo) como Chat (legacy)

	UBICACIÓN: ServerScriptService/ChatNotificationManager (Script normal)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[ChatNotificationManager] 💬 Inicializando sistema de notificaciones de chat...")

-- ==================== CREAR REMOTE EVENT ====================

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local ChatNotificationEvent = RemotesFolder:FindFirstChild("ChatNotification")
if not ChatNotificationEvent then
	ChatNotificationEvent = Instance.new("RemoteEvent")
	ChatNotificationEvent.Name = "ChatNotification"
	ChatNotificationEvent.Parent = RemotesFolder
	print("[ChatNotificationManager] ✅ RemoteEvent 'ChatNotification' creado")
end

-- ==================== CONFIGURACIÓN ====================

local ChatNotificationManager = {}

-- Colores para diferentes tipos de mensajes
ChatNotificationManager.Colors = {
	Purchase = Color3.fromRGB(255, 215, 0),    -- Dorado - Compras con Robux
	Race = Color3.fromRGB(100, 200, 255),      -- Azul - Anuncios de carreras
	Info = Color3.fromRGB(255, 255, 255),      -- Blanco - Información general
	Warning = Color3.fromRGB(255, 200, 0),     -- Amarillo - Advertencias
	Success = Color3.fromRGB(0, 255, 0),       -- Verde - Éxitos
}

-- Prefijos para diferentes tipos de mensajes
ChatNotificationManager.Prefixes = {
	Purchase = "💰 [COMPRA]",
	Race = "🏁 [CARRERA]",
	Info = "ℹ️ [INFO]",
	Warning = "⚠️",
	Success = "✅",
}

-- ==================== FUNCIONES ====================

-- Función principal para enviar notificaciones al chat
function ChatNotificationManager.SendNotification(message, notificationType, customColor)
	notificationType = notificationType or "Info"

	-- Obtener color y prefijo
	local color = customColor or ChatNotificationManager.Colors[notificationType]
	local prefix = ChatNotificationManager.Prefixes[notificationType] or ""

	-- Construir mensaje completo
	local fullMessage = prefix ~= "" and (prefix .. " " .. message) or message

	-- Enviar a todos los clientes vía RemoteEvent
	ChatNotificationEvent:FireAllClients(fullMessage, color)

	print(string.format("[ChatNotificationManager] 📢 %s", fullMessage))
end

-- Función específica para compras con Robux
function ChatNotificationManager.NotifyPurchase(playerName, itemName, price)
	local message = string.format("%s compró %s por %d Robux", playerName, itemName, price or 0)
	ChatNotificationManager.SendNotification(message, "Purchase")
end

-- Función específica para anuncios de carreras
function ChatNotificationManager.NotifyRace(message)
	ChatNotificationManager.SendNotification(message, "Race")
end

-- Función específica para información general
function ChatNotificationManager.NotifyInfo(message)
	ChatNotificationManager.SendNotification(message, "Info")
end

-- Función específica para advertencias
function ChatNotificationManager.NotifyWarning(message)
	ChatNotificationManager.SendNotification(message, "Warning")
end

-- Función específica para éxitos
function ChatNotificationManager.NotifySuccess(message)
	ChatNotificationManager.SendNotification(message, "Success")
end

-- ==================== EXPORTAR GLOBALMENTE ====================

_G.ChatNotificationManager = ChatNotificationManager

print("[ChatNotificationManager] ✅ Sistema de notificaciones de chat listo")
