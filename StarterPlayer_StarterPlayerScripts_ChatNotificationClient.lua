--[[
	CHAT NOTIFICATION CLIENT - LocalScript
	Recibe notificaciones del servidor y las muestra en el chat
	Soporta tanto TextChatService (nuevo) como Chat (legacy)

	UBICACIÓN: StarterPlayer/StarterPlayerScripts/ChatNotificationClient
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

print("[ChatNotificationClient] 💬 Inicializando cliente de notificaciones de chat...")

-- ==================== DETECTAR SISTEMA DE CHAT ====================

local useTextChatService = false
local generalChannel = nil

-- Intentar usar TextChatService (nuevo sistema)
local success = pcall(function()
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral", 5)
		if generalChannel then
			useTextChatService = true
			print("[ChatNotificationClient] ✅ Usando TextChatService (nuevo sistema)")
		end
	end
end)

if not useTextChatService then
	print("[ChatNotificationClient] ⚠️ TextChatService no disponible, usando sistema legacy")
end

-- ==================== ESPERAR REMOTE EVENT ====================

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local ChatNotificationEvent = RemotesFolder:WaitForChild("ChatNotification", 10)

if not ChatNotificationEvent then
	warn("[ChatNotificationClient] ❌ No se encontró RemoteEvent 'ChatNotification'")
	return
end

-- ==================== FUNCIONES ====================

-- Muestra un mensaje en TextChatService
local function showTextChatMessage(message, color)
	if not generalChannel then return false end

	local success, err = pcall(function()
		generalChannel:DisplaySystemMessage(message)
	end)

	if success then
		return true
	else
		warn("[ChatNotificationClient] Error mostrando mensaje TextChatService:", err)
		return false
	end
end

-- Muestra un mensaje en Chat Legacy
local function showLegacyChatMessage(message, color)
	local success = pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = message,
			Color = color or Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size18,
		})
	end)

	return success
end

-- ==================== ESCUCHAR EVENTOS ====================

-- Escuchar notificaciones del servidor
ChatNotificationEvent.OnClientEvent:Connect(function(message, color)
	-- Mostrar según el sistema disponible
	if useTextChatService then
		showTextChatMessage(message, color)
	else
		showLegacyChatMessage(message, color)
	end

	print(string.format("[ChatNotificationClient] 💬 %s", message))
end)

print("[ChatNotificationClient] ✅ Cliente de notificaciones listo")
print(string.format("[ChatNotificationClient] 📊 Sistema activo: %s", useTextChatService and "TextChatService" or "Legacy Chat"))
