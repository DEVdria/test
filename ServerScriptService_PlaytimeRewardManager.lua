--[[
	PLAYTIME REWARD MANAGER - Script
	Gestiona el tracking de tiempo de juego y las recompensas del servidor

	UBICACIÓN: ServerScriptService/PlaytimeRewardManager
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[PlaytimeRewardManager] 🕐 Inicializando sistema de recompensas por tiempo...")

-- ==================== ESPERAR DEPENDENCIAS ====================

-- Esperar DataManager
local DataManager = nil
local maxWait = 10
local waited = 0

repeat
	task.wait(0.5)
	waited = waited + 0.5
	DataManager = _G.DataManager
until DataManager or waited >= maxWait

if not DataManager then
	warn("[PlaytimeRewardManager] ❌ No se pudo acceder a DataManager")
	return
end

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local PlaytimeRewardConfig = require(Modules:WaitForChild("PlaytimeRewardConfig"))

-- Crear o buscar RemoteEvents y RemoteFunctions
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- RemoteFunction para obtener información de recompensas
local GetRewardInfoFunction = RemotesFolder:FindFirstChild("GetPlaytimeRewardInfo")
if not GetRewardInfoFunction then
	GetRewardInfoFunction = Instance.new("RemoteFunction")
	GetRewardInfoFunction.Name = "GetPlaytimeRewardInfo"
	GetRewardInfoFunction.Parent = RemotesFolder
end

-- RemoteEvent para reclamar recompensas
local ClaimRewardEvent = RemotesFolder:FindFirstChild("ClaimPlaytimeReward")
if not ClaimRewardEvent then
	ClaimRewardEvent = Instance.new("RemoteEvent")
	ClaimRewardEvent.Name = "ClaimPlaytimeReward"
	ClaimRewardEvent.Parent = RemotesFolder
end

-- RemoteEvent para actualizar playtime al cliente
local UpdatePlaytimeEvent = RemotesFolder:FindFirstChild("UpdatePlaytime")
if not UpdatePlaytimeEvent then
	UpdatePlaytimeEvent = Instance.new("RemoteEvent")
	UpdatePlaytimeEvent.Name = "UpdatePlaytime"
	UpdatePlaytimeEvent.Parent = RemotesFolder
end

print("[PlaytimeRewardManager] ✅ RemoteEvents creados")

-- ==================== VARIABLES ====================

local UPDATE_INTERVAL = 1  -- Actualizar playtime cada 1 segundo
local BROADCAST_INTERVAL = 5  -- Enviar playtime al cliente cada 5 segundos

-- ==================== FUNCIONES ====================

-- Obtiene el estado de una recompensa para un jugador
-- Devuelve: "Available", "Claimed", o "Locked"
local function getRewardState(player, rewardID)
	local reward = PlaytimeRewardConfig.GetReward(rewardID)
	if not reward then
		return "Locked"
	end

	local playtime = DataManager.GetPlaytime(player)
	local isClaimed = DataManager.IsRewardClaimed(player, rewardID)

	if isClaimed then
		return "Claimed"
	elseif playtime >= reward.TimeRequired then
		return "Available"
	else
		return "Locked"
	end
end

-- Obtiene información completa de todas las recompensas para un jugador
local function getPlayerRewardInfo(player)
	local playtime = DataManager.GetPlaytime(player)
	local claimedRewards = DataManager.GetClaimedRewards(player)

	local rewardStates = {}

	for _, reward in ipairs(PlaytimeRewardConfig.Rewards) do
		local state = getRewardState(player, reward.ID)
		local timeRemaining = math.max(0, reward.TimeRequired - playtime)

		table.insert(rewardStates, {
			ID = reward.ID,
			State = state,
			TimeRequired = reward.TimeRequired,
			TimeRemaining = timeRemaining,
			MoneyReward = reward.MoneyReward,
		})
	end

	-- Calcular tiempo hasta próxima recompensa
	local timeUntilNext = PlaytimeRewardConfig.GetTimeUntilNextReward(playtime, claimedRewards)

	return {
		Playtime = playtime,
		ClaimedRewards = claimedRewards,
		RewardStates = rewardStates,
		TimeUntilNext = timeUntilNext,
	}
end

-- Procesa la reclamación de una recompensa
local function claimReward(player, rewardID)
	-- Validaciones
	if not player or not player:IsDescendantOf(Players) then
		return {Success = false, Message = "Jugador inválido"}
	end

	local reward = PlaytimeRewardConfig.GetReward(rewardID)
	if not reward then
		return {Success = false, Message = "Recompensa no encontrada"}
	end

	-- Verificar si puede reclamar
	local playtime = DataManager.GetPlaytime(player)
	local claimedRewards = DataManager.GetClaimedRewards(player)

	local canClaim, reason = PlaytimeRewardConfig.CanClaimReward(rewardID, playtime, claimedRewards)
	if not canClaim then
		return {Success = false, Message = reason}
	end

	-- Procesar reclamación
	local success, message, moneyEarned = DataManager.ClaimReward(player, rewardID, reward.MoneyReward)

	if success then
		-- Guardar datos inmediatamente
		task.spawn(function()
			DataManager.SaveData(player)
		end)

		return {
			Success = true,
			Message = message,
			MoneyEarned = moneyEarned,
			RewardID = rewardID,
		}
	else
		return {Success = false, Message = message}
	end
end

-- ==================== REMOTE HANDLERS ====================

-- Manejar solicitud de información de recompensas
GetRewardInfoFunction.OnServerInvoke = function(player)
	return getPlayerRewardInfo(player)
end

-- Manejar reclamación de recompensas
ClaimRewardEvent.OnServerEvent:Connect(function(player, rewardID)
	local result = claimReward(player, rewardID)

	-- Enviar resultado al cliente
	ClaimRewardEvent:FireClient(player, result)

	-- Si fue exitoso, actualizar información de recompensas
	if result.Success then
		local updatedInfo = getPlayerRewardInfo(player)
		UpdatePlaytimeEvent:FireClient(player, updatedInfo)
	end
end)

-- ==================== PLAYTIME TRACKING ====================

-- Trackea el tiempo de juego de todos los jugadores
task.spawn(function()
	local lastUpdate = os.clock()
	local lastBroadcast = os.clock()

	while true do
		task.wait(UPDATE_INTERVAL)

		local currentTime = os.clock()
		local deltaTime = currentTime - lastUpdate
		lastUpdate = currentTime

		-- Actualizar playtime de cada jugador
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.AddPlaytime(player, math.floor(deltaTime))
		end

		-- Broadcast al cliente cada cierto tiempo
		if currentTime - lastBroadcast >= BROADCAST_INTERVAL then
			lastBroadcast = currentTime

			for _, player in ipairs(Players:GetPlayers()) do
				local info = getPlayerRewardInfo(player)
				UpdatePlaytimeEvent:FireClient(player, info)
			end
		end
	end
end)

print("[PlaytimeRewardManager] 🕐 Tracking de playtime iniciado")

-- ==================== EVENTOS DE JUGADORES ====================

-- Cuando un jugador se une, enviarle su información inicial
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que DataManager cargue los datos
	task.wait(2)

	local info = getPlayerRewardInfo(player)
	UpdatePlaytimeEvent:FireClient(player, info)

	print(string.format("[PlaytimeRewardManager] 📊 %s - Playtime: %s, Recompensas reclamadas: %d",
		player.Name,
		PlaytimeRewardConfig.FormatTime(info.Playtime),
		#info.ClaimedRewards))
end)

print("[PlaytimeRewardManager] ✅ Sistema de recompensas por tiempo completamente inicializado")
