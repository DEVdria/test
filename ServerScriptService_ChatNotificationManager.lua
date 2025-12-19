--[[
	CHAT NOTIFICATION MANAGER - Script
	Gestiona las notificaciones en el chat del juego
	Soporta tanto TextChatService (nuevo) como Chat (legacy)

	UBICACIÓN: ServerScriptService/ChatNotificationManager
]]

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

print("[ChatNotificationManager] 💬 Inicializando sistema de notificaciones de chat...")

-- ==================== DETECTAR SISTEMA DE CHAT ====================

local useTextChatService = false
local generalChannel = nil

-- Intentar usar TextChatService (nuevo sistema)
local success = pcall(function()
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral", 5)
		if generalChannel then
			useTextChatService = true
			print("[ChatNotificationManager] ✅ Usando TextChatService (nuevo sistema)")
		end
	end
end)

if not useTextChatService then
	print("[ChatNotificationManager] ⚠️ TextChatService no disponible, usando sistema legacy")
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

-- Envía un mensaje al chat usando TextChatService
local function sendTextChatMessage(message, color)
	if not generalChannel then return false end

	local textChannel = generalChannel

	-- Crear mensaje con color
	local displayMessage = message

	-- Enviar mensaje
	local success, err = pcall(function()
		textChannel:DisplaySystemMessage(displayMessage)
	end)

	if success then
		return true
	else
		warn("[ChatNotificationManager] Error enviando mensaje TextChatService:", err)
		return false
	end
end

-- Envía un mensaje al chat usando sistema legacy
local function sendLegacyChatMessage(message, color)
	local success = pcall(function()
		for _, player in ipairs(Players:GetPlayers()) do
			-- Crear mensaje en el chat del jugador
			game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
				Text = message,
				Color = color or Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SourceSansBold,
				FontSize = Enum.FontSize.Size18,
			})
		end
	end)

	return success
end

-- Función principal para enviar notificaciones al chat
function ChatNotificationManager.SendNotification(message, notificationType, customColor)
	notificationType = notificationType or "Info"

	-- Obtener color y prefijo
	local color = customColor or ChatNotificationManager.Colors[notificationType]
	local prefix = ChatNotificationManager.Prefixes[notificationType] or ""

	-- Construir mensaje completo
	local fullMessage = prefix ~= "" and (prefix .. " " .. message) or message

	-- Enviar según el sistema disponible
	if useTextChatService then
		sendTextChatMessage(fullMessage, color)
	else
		sendLegacyChatMessage(fullMessage, color)
	end

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
print(string.format("[ChatNotificationManager] 📊 Sistema activo: %s", useTextChatService and "TextChatService" or "Legacy Chat"))

return ChatNotificationManager
