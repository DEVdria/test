-- ServerScriptService > MoneyManager
-- Gestiona el sistema de dinero y recompensas por orbs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
local OrbConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local OrbCollectedEvent = RemoteEvents:WaitForChild("OrbCollected")
local UpdateSpeedDisplayEvent = RemoteEvents:WaitForChild("UpdateSpeedDisplay")

local MoneyManager = {}

-- Caché de cooldowns para prevenir spam
local collectionCooldowns = {}
local COOLDOWN_TIME = 0.1 -- 100ms entre recolecciones

-- Verifica si un jugador puede recolectar (anti-spam)
local function canCollect(player)
	local userId = player.UserId
	local lastCollection = collectionCooldowns[userId]

	if lastCollection then
		local elapsed = tick() - lastCollection
		if elapsed < COOLDOWN_TIME then
			return false
		end
	end

	return true
end

-- Procesa la recolección de un orb
function MoneyManager.ProcessOrbCollection(player, orbType)
	-- Validaciones de seguridad
	if not player or not player:IsDescendantOf(game.Players) then
		return false
	end

	if not canCollect(player) then
		warn(string.format("[MoneyManager] %s está recolectando orbs demasiado rápido", player.Name))
		return false
	end

	if not OrbConfig.IsValidOrbType(orbType) then
		warn(string.format("[MoneyManager] Tipo de orb inválido recibido de %s: %s", player.Name, orbType))
		return false
	end

	-- Actualizar cooldown
	collectionCooldowns[player.UserId] = tick()

	-- Obtener datos del orb
	local orbData = OrbConfig.OrbTypes[orbType]
	local playerData = DataManager.GetData(player)

	if not playerData then
		warn(string.format("[MoneyManager] No se encontraron datos para %s", player.Name))
		return false
	end

	-- Aplicar multiplicador de rebirth al dinero (opcional)
	local moneyReward = orbData.MoneyReward
	local speedBonus = orbData.SpeedBonus

	-- Aplicar multiplicador de velocidad
	local multipliedSpeed = speedBonus * playerData.SpeedMultiplier

	-- Añadir dinero y velocidad
	DataManager.AddMoney(player, moneyReward)
	local newSpeed = DataManager.AddSpeed(player, multipliedSpeed)

	-- Actualizar display de velocidad en el cliente
	if newSpeed then
		UpdateSpeedDisplayEvent:FireClient(player, newSpeed)
	end

	return true
end

-- Limpia cooldowns de jugadores que se van
local function cleanupCooldowns(player)
	collectionCooldowns[player.UserId] = nil
end

-- Inicializa el sistema de dinero
function MoneyManager.Initialize()
	-- Escuchar eventos de recolección de orbs
	OrbCollectedEvent.OnServerEvent:Connect(function(player, orbType)
		MoneyManager.ProcessOrbCollection(player, orbType)
	end)

	-- Limpiar cooldowns al salir
	game.Players.PlayerRemoving:Connect(cleanupCooldowns)
end

return MoneyManager
