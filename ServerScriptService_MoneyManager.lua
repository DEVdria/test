-- ServerScriptService > MoneyManager
-- Gestiona el sistema de dinero y recompensas por orbs
-- NOTA: Este es un Script normal, NO ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
print("[MoneyManager] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[MoneyManager] ❌ No se encontró carpeta Modules")
	return
end

local OrbConfig = require(Modules:WaitForChild("OrbConfig", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[MoneyManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

local OrbCollectedEvent = RemoteEvents:WaitForChild("OrbCollected")
local UpdateSpeedDisplayEvent = RemoteEvents:WaitForChild("UpdateSpeedDisplay")

-- Esperar DataManager (se carga a través de _G)
local DataManager
local maxWait = 10
local waited = 0
repeat
	task.wait(0.5)
	waited = waited + 0.5
	DataManager = _G.DataManager
until DataManager or waited >= maxWait

if not DataManager then
	warn("[MoneyManager] ❌ No se pudo acceder a DataManager")
	return
end

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
local function processOrbCollection(player, orbType)
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

-- Inicializar automáticamente
print("[MoneyManager] Inicializando...")

-- Escuchar eventos de recolección de orbs
OrbCollectedEvent.OnServerEvent:Connect(function(player, orbType)
	processOrbCollection(player, orbType)
end)

-- Limpiar cooldowns al salir
game.Players.PlayerRemoving:Connect(cleanupCooldowns)

print("[MoneyManager] ✅ Sistema de dinero inicializado")
