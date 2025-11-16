--[[
═══════════════════════════════════════════════════════════════
    PLAYTIME REWARD SYSTEM - Sistema de Recompensas por Tiempo
    Ubicación: ServerScriptService

    Funcionalidad:
    - Rastrea el tiempo jugado de cada jugador
    - Otorga recompensas de dinero por tiempo jugado
    - Guarda progreso en DataStore
    - Permite reclamar recompensas una sola vez
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- DataStore para guardar tiempo jugado y recompensas reclamadas
local PlaytimeDataStore
local dataStoreEnabled = false

-- Intentar inicializar DataStore
local success, result = pcall(function()
	return DataStoreService:GetDataStore("PlaytimeRewards_V1")
end)

if success then
	PlaytimeDataStore = result
	dataStoreEnabled = true
	print("✅ DataStore de PlaytimeRewards inicializado")
else
	warn("⚠️ DataStore de PlaytimeRewards NO disponible")
end

-- Tabla para rastrear datos de jugadores en sesión
local playerData = {}

--[[
    Configuración de Recompensas por Tiempo
    Tiempo en minutos : Recompensa en dinero
--]]
local REWARD_MILESTONES = {
	{Time = 5, Reward = 100, Icon = "⏰"},
	{Time = 10, Reward = 200, Icon = "⏱️"},
	{Time = 15, Reward = 300, Icon = "⏲️"},
	{Time = 20, Reward = 400, Icon = "🕐"},
	{Time = 25, Reward = 500, Icon = "🕑"},
	{Time = 30, Reward = 750, Icon = "🕒"},
	{Time = 45, Reward = 1000, Icon = "🕓"},
	{Time = 60, Reward = 1500, Icon = "🕔"},
}

-- Crear RemoteEvents
local getRewardsEvent = ReplicatedStorage:FindFirstChild("GetPlaytimeRewards")
if not getRewardsEvent then
	getRewardsEvent = Instance.new("RemoteEvent")
	getRewardsEvent.Name = "GetPlaytimeRewards"
	getRewardsEvent.Parent = ReplicatedStorage
end

local claimRewardEvent = ReplicatedStorage:FindFirstChild("ClaimPlaytimeReward")
if not claimRewardEvent then
	claimRewardEvent = Instance.new("RemoteEvent")
	claimRewardEvent.Name = "ClaimPlaytimeReward"
	claimRewardEvent.Parent = ReplicatedStorage
end

local updatePlaytimeEvent = ReplicatedStorage:FindFirstChild("UpdatePlaytime")
if not updatePlaytimeEvent then
	updatePlaytimeEvent = Instance.new("RemoteEvent")
	updatePlaytimeEvent.Name = "UpdatePlaytime"
	updatePlaytimeEvent.Parent = ReplicatedStorage
end

--[[
    Función: Cargar datos del jugador desde DataStore
    Parámetros: player - El jugador
    Retorna: Tabla con TotalPlaytime y ClaimedRewards
--]]
local function loadPlayerData(player)
	local data = {
		TotalPlaytime = 0, -- En segundos
		ClaimedRewards = {} -- Array de índices de recompensas reclamadas
	}

	if not dataStoreEnabled then
		print("⚠️ DataStore deshabilitado para " .. player.Name)
		return data
	end

	local success, savedData = pcall(function()
		return PlaytimeDataStore:GetAsync(player.UserId .. "_playtime")
	end)

	if success and savedData then
		data.TotalPlaytime = savedData.TotalPlaytime or 0
		data.ClaimedRewards = savedData.ClaimedRewards or {}
		print("✅ Datos de playtime cargados para " .. player.Name .. " (" .. math.floor(data.TotalPlaytime/60) .. " minutos)")
	else
		print("📝 Nuevos datos de playtime para " .. player.Name)
	end

	return data
end

--[[
    Función: Guardar datos del jugador en DataStore
    Parámetros: player - El jugador
--]]
local function savePlayerData(player)
	if not dataStoreEnabled then return end
	if not playerData[player.UserId] then return end

	local success, err = pcall(function()
		PlaytimeDataStore:SetAsync(player.UserId .. "_playtime", {
			TotalPlaytime = playerData[player.UserId].TotalPlaytime,
			ClaimedRewards = playerData[player.UserId].ClaimedRewards
		})
	end)

	if success then
		print("💾 Datos de playtime guardados para " .. player.Name)
	else
		warn("❌ Error al guardar playtime de " .. player.Name .. ": " .. tostring(err))
	end
end

--[[
    Función: Obtener estado de todas las recompensas para un jugador
    Parámetros: player - El jugador
    Retorna: Array de recompensas con estado
--]]
local function getRewardStatus(player)
	if not playerData[player.UserId] then return {} end

	local data = playerData[player.UserId]
	local playtimeMinutes = data.TotalPlaytime / 60
	local rewards = {}

	for index, milestone in ipairs(REWARD_MILESTONES) do
		local isClaimed = table.find(data.ClaimedRewards, index) ~= nil
		local isUnlocked = playtimeMinutes >= milestone.Time

		table.insert(rewards, {
			Index = index,
			Time = milestone.Time,
			Reward = milestone.Reward,
			Icon = milestone.Icon,
			IsUnlocked = isUnlocked,
			IsClaimed = isClaimed,
			CanClaim = isUnlocked and not isClaimed
		})
	end

	return rewards
end

--[[
    Función: Reclamar recompensa
    Parámetros:
        player - El jugador
        rewardIndex - Índice de la recompensa
--]]
local function claimReward(player, rewardIndex)
	if not playerData[player.UserId] then return false end

	local data = playerData[player.UserId]
	local milestone = REWARD_MILESTONES[rewardIndex]

	if not milestone then
		warn("❌ Recompensa inválida: " .. tostring(rewardIndex))
		return false
	end

	-- Verificar si ya fue reclamada
	if table.find(data.ClaimedRewards, rewardIndex) then
		warn("⚠️ " .. player.Name .. " ya reclamó esta recompensa")
		return false
	end

	-- Verificar si el jugador tiene suficiente tiempo jugado
	local playtimeMinutes = data.TotalPlaytime / 60
	if playtimeMinutes < milestone.Time then
		warn("⚠️ " .. player.Name .. " no tiene suficiente tiempo jugado")
		return false
	end

	-- Marcar como reclamada
	table.insert(data.ClaimedRewards, rewardIndex)

	-- Dar dinero usando el sistema de MoneyManager
	if _G.AddMoney then
		_G.AddMoney(player, milestone.Reward)
		print("✅ " .. player.Name .. " reclamó recompensa de " .. milestone.Time .. " min: $" .. milestone.Reward)
	end

	-- Guardar datos
	savePlayerData(player)

	-- Enviar notificación
	local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
	if notificationEvent then
		notificationEvent:FireClient(
			player,
			"🎁 ¡Recompensa reclamada! +$" .. milestone.Reward,
			Color3.fromRGB(85, 255, 127)
		)
	end

	return true
end

--[[
    Evento: Cuando un jugador se une
--]]
Players.PlayerAdded:Connect(function(player)
	-- Cargar datos
	local data = loadPlayerData(player)
	playerData[player.UserId] = data
	playerData[player.UserId].JoinTime = tick()

	-- Enviar estado inicial
	task.wait(1)
	local rewards = getRewardStatus(player)
	updatePlaytimeEvent:FireClient(player, math.floor(data.TotalPlaytime), rewards)
end)

--[[
    Evento: Cuando un jugador sale
--]]
Players.PlayerRemoving:Connect(function(player)
	if playerData[player.UserId] then
		-- Actualizar tiempo total jugado
		local sessionTime = tick() - playerData[player.UserId].JoinTime
		playerData[player.UserId].TotalPlaytime = playerData[player.UserId].TotalPlaytime + sessionTime

		-- Guardar datos
		savePlayerData(player)

		-- Limpiar de memoria
		playerData[player.UserId] = nil
	end
end)

--[[
    Evento: Cliente solicita estado de recompensas
--]]
getRewardsEvent.OnServerEvent:Connect(function(player)
	if playerData[player.UserId] then
		-- Actualizar tiempo actual
		local sessionTime = tick() - playerData[player.UserId].JoinTime
		local currentPlaytime = playerData[player.UserId].TotalPlaytime + sessionTime

		local rewards = getRewardStatus(player)
		updatePlaytimeEvent:FireClient(player, math.floor(currentPlaytime), rewards)
	end
end)

--[[
    Evento: Cliente intenta reclamar recompensa
--]]
claimRewardEvent.OnServerEvent:Connect(function(player, rewardIndex)
	-- Actualizar tiempo actual antes de reclamar
	if playerData[player.UserId] then
		local sessionTime = tick() - playerData[player.UserId].JoinTime
		playerData[player.UserId].TotalPlaytime = playerData[player.UserId].TotalPlaytime + sessionTime
		playerData[player.UserId].JoinTime = tick() -- Resetear join time

		-- Intentar reclamar
		local success = claimReward(player, rewardIndex)

		-- Enviar estado actualizado
		local currentPlaytime = playerData[player.UserId].TotalPlaytime
		local rewards = getRewardStatus(player)
		updatePlaytimeEvent:FireClient(player, math.floor(currentPlaytime), rewards)
	end
end)

--[[
    Loop: Actualizar tiempo de juego cada minuto
--]]
task.spawn(function()
	while true do
		task.wait(60) -- Cada minuto

		for _, player in pairs(Players:GetPlayers()) do
			if playerData[player.UserId] then
				-- Actualizar tiempo actual
				local sessionTime = tick() - playerData[player.UserId].JoinTime
				local currentPlaytime = playerData[player.UserId].TotalPlaytime + sessionTime

				-- Enviar actualización al cliente
				local rewards = getRewardStatus(player)
				updatePlaytimeEvent:FireClient(player, math.floor(currentPlaytime), rewards)
			end
		end
	end
end)

--[[
    Guardar datos cuando el servidor se cierra
--]]
game:BindToClose(function()
	print("💾 Guardando datos de playtime antes de cerrar servidor...")
	for _, player in pairs(Players:GetPlayers()) do
		if playerData[player.UserId] then
			local sessionTime = tick() - playerData[player.UserId].JoinTime
			playerData[player.UserId].TotalPlaytime = playerData[player.UserId].TotalPlaytime + sessionTime
			savePlayerData(player)
		end
	end
	task.wait(2) -- Dar tiempo para guardar
end)

print("🎁 Sistema de recompensas por tiempo cargado")
