--[[
	SCRIPT DE MANEJO DE EVENTOS DEL SERVIDOR
	Ubicación: ServerScriptService/ServerEventsHandler
	Descripción: Maneja los RemoteEvents disparados desde el cliente
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Modules.Config)
local EconomyModule = require(ReplicatedStorage.Modules.EconomyModule)

-- Esperar a que los RemoteEvents existan
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Cache para prevenir spam de orbs
local playerOrbCooldowns = {}

-- EVENTO: OrbCollected
local orbCollectedEvent = remoteEventsFolder:WaitForChild("OrbCollected")
orbCollectedEvent.OnServerEvent:Connect(function(player, orbIndex)
	-- Validación básica
	if typeof(orbIndex) ~= "number" then
		warn("OrbIndex inválido de " .. player.Name)
		return
	end

	-- Prevenir spam (cooldown de 0.5 segundos por orb)
	local playerName = player.Name
	if not playerOrbCooldowns[playerName] then
		playerOrbCooldowns[playerName] = {}
	end

	local lastCollected = playerOrbCooldowns[playerName][orbIndex]
	local currentTime = tick()

	if lastCollected and (currentTime - lastCollected) < 0.5 then
		warn("Cooldown activo para " .. playerName .. " en orb " .. orbIndex)
		return
	end

	-- Actualizar cooldown
	playerOrbCooldowns[playerName][orbIndex] = currentTime

	-- Dar dinero al jugador
	local success = EconomyModule.AddMoney(player, Config.OrbMoneyReward)

	if success then
		print(player.Name .. " recogió orb " .. orbIndex .. " (+$" .. Config.OrbMoneyReward .. ")")
	else
		warn("Error al dar dinero a " .. player.Name)
	end
end)

-- EVENTO: PerformRebirth
local performRebirthEvent = remoteEventsFolder:WaitForChild("PerformRebirth")
performRebirthEvent.OnServerEvent:Connect(function(player)
	local success, message = EconomyModule.PerformRebirth(player)

	if success then
		print(player.Name .. " completó un Rebirth")
	else
		warn("Rebirth fallido para " .. player.Name .. ": " .. message)
	end

	-- Enviar resultado al cliente (opcional)
	-- Puedes crear un RemoteEvent adicional para esto si lo necesitas
end)

-- Limpiar cooldowns cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	playerOrbCooldowns[player.Name] = nil
end)

print("ServerEventsHandler cargado exitosamente")
