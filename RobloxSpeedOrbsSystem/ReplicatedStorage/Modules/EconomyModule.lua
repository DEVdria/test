--[[
	MÓDULO DE ECONOMÍA (SERVIDOR)
	Ubicación: ReplicatedStorage/Modules/EconomyModule
	Descripción: Gestiona dinero y renacimientos
]]

local EconomyModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.Config)

function EconomyModule.AddMoney(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("Leaderstats no encontrado para " .. player.Name)
		return false
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		warn("Money no encontrado en leaderstats de " .. player.Name)
		return false
	end

	money.Value = money.Value + amount
	return true
end

function EconomyModule.RemoveMoney(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local money = leaderstats:FindFirstChild("Money")
	if not money then return false end

	if money.Value >= amount then
		money.Value = money.Value - amount
		return true
	end

	return false
end

function EconomyModule.GetMoney(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 0 end

	local money = leaderstats:FindFirstChild("Money")
	if not money then return 0 end

	return money.Value
end

function EconomyModule.CanAffordRebirth(player)
	local currentMoney = EconomyModule.GetMoney(player)
	return currentMoney >= Config.RebirthCost
end

function EconomyModule.PerformRebirth(player)
	-- Verificar si puede costear el rebirth
	if not EconomyModule.CanAffordRebirth(player) then
		return false, "No tienes suficiente dinero para Rebirth"
	end

	-- Quitar el dinero
	if not EconomyModule.RemoveMoney(player, Config.RebirthCost) then
		return false, "Error al quitar dinero"
	end

	-- Aumentar renacimientos
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false, "Leaderstats no encontrado"
	end

	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not rebirths then
		return false, "Rebirths no encontrado"
	end

	rebirths.Value = rebirths.Value + 1

	-- Resetear al jugador (opcional)
	-- Notificar al cliente para resetear orbs
	local remoteEvent = ReplicatedStorage.RemoteEvents:FindFirstChild("RebirthCompleted")
	if remoteEvent then
		remoteEvent:FireClient(player)
	end

	return true, "Rebirth completado exitosamente"
end

function EconomyModule.GetRebirths(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 0 end

	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not rebirths then return 0 end

	return rebirths.Value
end

function EconomyModule.GetSpeedMultiplier(player)
	local rebirths = EconomyModule.GetRebirths(player)
	return 1 + (rebirths * (Config.RebirthSpeedMultiplier - 1))
end

return EconomyModule
