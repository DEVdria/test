-- ServerScriptService > StarManager
-- Gestiona el sistema de recompensas de estrellas
-- NOTA: Este es un Script normal, NO ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
print("[StarManager] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[StarManager] ❌ No se encontró carpeta Modules")
	return
end

local StarConfig = require(Modules:WaitForChild("StarConfig", 10))
local LevelManager = require(Modules:WaitForChild("LevelManager", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[StarManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

-- RemoteEvent para estrellas (crear en ReplicatedStorage/RemoteEvents)
local StarCollectedEvent = RemoteEvents:WaitForChild("StarCollected", 10)
if not StarCollectedEvent then
	warn("[StarManager] ❌ No se encontró RemoteEvent 'StarCollected'")
	warn("[StarManager] 📘 Crea este RemoteEvent en ReplicatedStorage/RemoteEvents")
	return
end

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
	warn("[StarManager] ❌ No se pudo acceder a DataManager")
	return
end

-- Caché de cooldowns por jugador y estrella
local starCooldowns = {}  -- {[userId] = {[starID] = lastCollectionTime}}

-- Verifica si un jugador puede recolectar una estrella (cooldown)
local function canCollectStar(player, starID)
	local userId = player.UserId

	if not starCooldowns[userId] then
		starCooldowns[userId] = {}
		return true
	end

	local lastCollection = starCooldowns[userId][starID]
	if not lastCollection then
		return true
	end

	local elapsed = tick() - lastCollection
	return elapsed >= StarConfig.General.CollectionCooldown
end

-- Procesa la subida de nivel si es posible (copiado de MoneyManager)
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

		print(string.format("[StarManager] %s subió al nivel %d!", player.Name, level))
	end
end

-- Procesa la recolección de una estrella
local function processStarCollection(player, starID)
	-- Validaciones de seguridad
	if not player or not player:IsDescendantOf(game.Players) then
		return false
	end

	if not StarConfig.IsValidStar(starID) then
		warn(string.format("[StarManager] Estrella inválida recibida de %s: %s", player.Name, starID))
		return false
	end

	-- Verificar cooldown
	if not canCollectStar(player, starID) then
		-- Silencioso, solo rechazar
		return false
	end

	-- Actualizar cooldown
	local userId = player.UserId
	if not starCooldowns[userId] then
		starCooldowns[userId] = {}
	end
	starCooldowns[userId][starID] = tick()

	-- Obtener datos de la estrella
	local starData = StarConfig.GetStar(starID)
	local playerData = DataManager.GetData(player)

	if not playerData then
		warn(string.format("[StarManager] No se encontraron datos para %s", player.Name))
		return false
	end

	-- Calcular EXP con multiplicador de rebirth Y gamepass
	local baseEXP = starData.EXPReward
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

	local moneyReward = starData.MoneyReward

	-- Añadir dinero y EXP
	DataManager.AddMoney(player, moneyReward)
	DataManager.AddEXP(player, finalEXP)

	-- Mostrar notificación al cliente (usando el sistema de orbs)
	if ShowOrbNotificationEvent then
		ShowOrbNotificationEvent:FireClient(player, "Star", finalEXP, starData.Color)
	end

	-- Procesar posible subida de nivel
	local updatedData = DataManager.GetData(player)
	if updatedData then
		processLevelUp(player, updatedData)
	end

	print(string.format("[StarManager] %s recolectó %s (+%d EXP, $%d)", player.Name, starID, finalEXP, moneyReward))

	return true
end

-- Limpia cooldowns de jugadores que se van
local function cleanupCooldowns(player)
	starCooldowns[player.UserId] = nil
end

-- ==================== EVENTOS ====================

-- Escuchar eventos de recolección de estrellas
StarCollectedEvent.OnServerEvent:Connect(function(player, starID)
	processStarCollection(player, starID)
end)

-- Limpiar cooldowns al salir
game.Players.PlayerRemoving:Connect(cleanupCooldowns)

print("[StarManager] ✅ Sistema de estrellas inicializado")
