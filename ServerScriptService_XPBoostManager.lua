-- ServerScriptService > XPBoostManager (Script)
-- Gestiona los boosts de XP con gamepasses

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local XPBoostConfig = require(Modules:WaitForChild("XPBoostConfig"))

-- Esperar RemoteEvents (se crearán después)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GetXPBoostFunction = RemoteEvents:WaitForChild("GetXPBoost", 10)
local XPBoostPurchasedEvent = RemoteEvents:WaitForChild("XPBoostPurchased", 10)

if not GetXPBoostFunction then
	warn("[XPBoostManager] ❌ No se encontró RemoteFunction 'GetXPBoost'")
	warn("[XPBoostManager] 📘 Crea un RemoteFunction llamado 'GetXPBoost' en ReplicatedStorage/RemoteEvents")
	return
end

if not XPBoostPurchasedEvent then
	warn("[XPBoostManager] ❌ No se encontró RemoteEvent 'XPBoostPurchased'")
	warn("[XPBoostManager] 📘 Crea un RemoteEvent llamado 'XPBoostPurchased' en ReplicatedStorage/RemoteEvents")
	return
end

-- ==================== VARIABLES ====================

-- Cache de multiplicadores por jugador {[userId] = multiplier}
local playerMultipliers = {}

-- ==================== FUNCIONES DE GAMEPASS ====================

-- Verifica si el jugador tiene un gamepass
local function playerOwnsGamepass(player, gamepassID)
	if gamepassID == 0 then
		-- No configurado, retornar false
		return false
	end

	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassID)
	end)

	if not success then
		warn(string.format("[XPBoostManager] ⚠️ Error verificando gamepass %d para %s: %s", gamepassID, player.Name, tostring(hasPass)))
		return false
	end

	return hasPass
end

-- Obtiene el nivel de boost más alto que tiene el jugador
local function getPlayerHighestBoostLevel(player)
	local highestLevel = 0

	-- Revisar en orden inverso (del más alto al más bajo) para optimizar
	for i = #XPBoostConfig.Boosts, 1, -1 do
		local boost = XPBoostConfig.Boosts[i]
		if playerOwnsGamepass(player, boost.GamepassID) then
			highestLevel = boost.Level
			break  -- Ya encontramos el más alto, no seguir buscando
		end
	end

	return highestLevel
end

-- Obtiene el siguiente boost disponible para el jugador
local function getNextAvailableBoost(player)
	local currentLevel = getPlayerHighestBoostLevel(player)

	-- Si ya tiene el máximo, retornar nil
	if currentLevel >= XPBoostConfig.GetMaxLevel() then
		return nil
	end

	-- Retornar el siguiente nivel
	return XPBoostConfig.GetBoostByLevel(currentLevel + 1)
end

-- ==================== FUNCIONES PÚBLICAS ====================

-- Obtiene el multiplicador de XP del jugador
function GetPlayerXPMultiplier(player)
	-- Verificar cache primero
	if playerMultipliers[player.UserId] then
		return playerMultipliers[player.UserId]
	end

	-- Calcular multiplicador
	local highestLevel = getPlayerHighestBoostLevel(player)

	local multiplier = 1.0  -- Por defecto sin boost

	if highestLevel > 0 then
		local boost = XPBoostConfig.GetBoostByLevel(highestLevel)
		if boost then
			multiplier = boost.Multiplier
		end
	end

	-- Guardar en cache
	playerMultipliers[player.UserId] = multiplier

	return multiplier
end

-- Invalida el cache de un jugador (para refrescar después de comprar)
local function invalidatePlayerCache(player)
	playerMultipliers[player.UserId] = nil
	print(string.format("[XPBoostManager] 🔄 Cache invalidado para %s", player.Name))
end

-- ==================== REMOTE FUNCTION ====================

-- El cliente solicita información sobre boosts
GetXPBoostFunction.OnServerInvoke = function(player)
	local currentLevel = getPlayerHighestBoostLevel(player)
	local currentMultiplier = GetPlayerXPMultiplier(player)
	local nextBoost = getNextAvailableBoost(player)

	return {
		CurrentLevel = currentLevel,
		CurrentMultiplier = currentMultiplier,
		NextBoost = nextBoost,  -- nil si ya tiene el máximo
		HasMaxBoost = currentLevel >= XPBoostConfig.GetMaxLevel()
	}
end

-- ==================== DETECCIÓN DE COMPRAS ====================

-- Detectar cuando un jugador compra un gamepass
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassID, wasPurchased)
	if not wasPurchased then return end

	-- Verificar si es uno de nuestros boosts
	local boost = XPBoostConfig.GetBoostByGamepassID(gamepassID)
	if not boost then return end

	print(string.format("[XPBoostManager] 🎉 %s compró %s (Gamepass ID: %d)", player.Name, boost.Name, gamepassID))

	-- Invalidar cache
	invalidatePlayerCache(player)

	-- Esperar un poco para asegurar que el gamepass esté procesado por Roblox
	task.wait(1)

	-- Notificar al cliente específico
	XPBoostPurchasedEvent:FireClient(player, boost.Level)

	-- Mostrar mensaje en el chat de TODOS los jugadores
	local game = game or _G.game
	local TextChatService = game:GetService("TextChatService")
	local StarterGui = game:GetService("StarterGui")

	local chatMessage = string.format("%s ha comprado mejora NIVEL %d a %d ROBUX", player.Name, boost.Level, boost.Price)

	-- Intentar con TextChatService (nuevo sistema de chat)
	local success, err = pcall(function()
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
			generalChannel:DisplaySystemMessage(chatMessage)
		else
			-- Sistema de chat legacy
			for _, p in ipairs(Players:GetPlayers()) do
				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = chatMessage,
					Color = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBold,
					FontSize = Enum.FontSize.Size14
				})
			end
		end
	end)

	if not success then
		-- Fallback: enviar a todos los clientes via RemoteEvent
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				-- Notificar a otros jugadores también (para que vean el mensaje en el output)
				print(string.format("[XPBoostManager] 📢 Notificando a %s sobre la compra de %s", p.Name, player.Name))
			end
		end
	end

	-- Mostrar mensaje en servidor
	print(string.format("[XPBoostManager] ✅ %s ahora tiene multiplicador x%.2f", player.Name, GetPlayerXPMultiplier(player)))
end)

-- ==================== LIMPIEZA ====================

-- Limpiar cache cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	playerMultipliers[player.UserId] = nil
end)

-- ==================== EXPONER GLOBALMENTE ====================

-- Exponer la función globalmente para que otros scripts la usen
_G.GetPlayerXPMultiplier = GetPlayerXPMultiplier

-- ==================== INICIALIZACIÓN ====================

-- Validar configuración
if not XPBoostConfig.ValidateConfig() then
	warn("[XPBoostManager] ⚠️ Algunos gamepass IDs no están configurados")
	warn("[XPBoostManager] 📘 Edita ReplicatedStorage/Modules/XPBoostConfig y cambia los GamepassID")
end

print("[XPBoostManager] ✅ Sistema de boosts de XP inicializado")
print(string.format("[XPBoostManager] 📊 Niveles de boost disponibles: %d", XPBoostConfig.GetMaxLevel()))

-- ==================== EJEMPLO DE USO ====================
--[[
	Para obtener el multiplicador de XP de un jugador en otros scripts:

	-- En cualquier script del servidor:
	local xpMultiplier = _G.GetPlayerXPMultiplier(player)
	local finalXP = baseXP * xpMultiplier

	Ejemplo:
	- Sin boost: 100 XP * 1.0 = 100 XP
	- Nivel 1: 100 XP * 1.25 = 125 XP
	- Nivel 2: 100 XP * 1.5 = 150 XP
	- Nivel 3: 100 XP * 2.0 = 200 XP
]]
