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
local LevelManager = require(Modules:WaitForChild("LevelManager", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[MoneyManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

local OrbCollectedEvent = RemoteEvents:WaitForChild("OrbCollected")
local ShowOrbNotificationEvent = RemoteEvents:FindFirstChild("ShowOrbNotification")
local LevelUpEvent = RemoteEvents:FindFirstChild("LevelUp")
local MaxLevelReachedEvent = RemoteEvents:FindFirstChild("MaxLevelReached")

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

-- Procesa la subida de nivel si es posible
local function processLevelUp(player, playerData)
	local level = playerData.Level
	local currentEXP = playerData.CurrentEXP
	local rebirths = playerData.Rebirths

	-- Intentar subir de nivel
	while true do
		local canLevel, reason, newLevel, newEXP = LevelManager.ProcessLevelUp(level, currentEXP, rebirths)

		if not canLevel then
			-- No puede subir más
			if reason == "Nivel máximo alcanzado" then
				-- Notificar al cliente que alcanzó nivel máximo
				if MaxLevelReachedEvent then
					MaxLevelReachedEvent:FireClient(player, level, rebirths)
				end
			end
			break
		end

		-- Subió de nivel
		level = newLevel
		currentEXP = newEXP

		-- Actualizar en DataManager
		DataManager.SetLevel(player, level)
		DataManager.SetEXP(player, currentEXP)

		-- Notificar al cliente sobre la subida de nivel
		if LevelUpEvent then
			local newSpeed = LevelManager.GetRunSpeed(level)
			LevelUpEvent:FireClient(player, level, newSpeed)
		end

		print(string.format("[MoneyManager] %s subió al nivel %d!", player.Name, level))
	end
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

	-- Calcular EXP con multiplicador de rebirth Y gamepass
	local baseEXP = orbData.EXPReward
	local rebirthMultiplier = playerData.EXPMultiplier or 1

	-- Obtener multiplicador de gamepass de XP boost
	local gamepassMultiplier = 1
	if _G.GetPlayerXPMultiplier then
		gamepassMultiplier = _G.GetPlayerXPMultiplier(player)
	end

	-- Obtener multiplicador global del servidor
	local serverMultiplier = 1
	if _G.GetServerXPMultiplier then
		serverMultiplier = _G.GetServerXPMultiplier()
	end

	-- Multiplicar por TODOS: rebirth * gamepass * servidor
	local finalEXP = math.floor(baseEXP * rebirthMultiplier * gamepassMultiplier * serverMultiplier)

	-- Calcular dinero con multiplicador global del servidor
	local baseMoney = orbData.MoneyReward
	local serverMoneyMultiplier = 1
	if _G.GetServerMoneyMultiplier then
		serverMoneyMultiplier = _G.GetServerMoneyMultiplier()
	end

	local finalMoney = math.floor(baseMoney * serverMoneyMultiplier)

	-- Añadir dinero y EXP
	DataManager.AddMoney(player, finalMoney)
	DataManager.AddEXP(player, finalEXP)

	-- Mostrar notificación al cliente
	if ShowOrbNotificationEvent then
		ShowOrbNotificationEvent:FireClient(player, orbType, finalEXP, orbData.Color)
	end

	-- Procesar posible subida de nivel
	local updatedData = DataManager.GetData(player)
	if updatedData then
		processLevelUp(player, updatedData)
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

print("[MoneyManager] ✅ Sistema de dinero, EXP y niveles inicializado")
