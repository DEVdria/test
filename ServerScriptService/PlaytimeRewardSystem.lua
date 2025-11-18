--[[
═══════════════════════════════════════════════════════════════
    PLAYTIME REWARD SYSTEM - Sistema de Recompensas por Tiempo
    Ubicación: ServerScriptService

    Funcionalidad:
    - Rastrea el tiempo jugado de cada jugador POR SESIÓN
    - Otorga recompensas de dinero por tiempo jugado
    - El tiempo y las recompensas SE REINICIAN cada sesión
    - Los jugadores pueden reclamar recompensas cada vez que juegan
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Crear RemoteEvent para sonidos si no existe
local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
if not playSoundEvent then
	playSoundEvent = Instance.new("RemoteEvent")
	playSoundEvent.Name = "PlaySound"
	playSoundEvent.Parent = ReplicatedStorage
end

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

    NOTA: SIEMPRE empieza con datos frescos cada sesión
          - TotalPlaytime = 0
          - ClaimedRewards = {} (vacío, pueden reclamar todo de nuevo)
--]]
local function loadPlayerData(player)
	local data = {
		TotalPlaytime = 0, -- SIEMPRE empieza en 0 cada sesión
		ClaimedRewards = {} -- SIEMPRE vacío cada sesión
	}

	print("📝 Nueva sesión de playtime para " .. player.Name .. " (tiempo y recompensas reiniciados)")

	return data
end

--[[
    Función: Guardar datos del jugador en DataStore
    Parámetros: player - El jugador

    NOTA: NO guarda nada ya que todo se reinicia cada sesión
          Esta función se mantiene por compatibilidad pero no hace nada
--]]
local function savePlayerData(player)
	-- No se guarda nada porque todo se reinicia cada sesión
	-- Esta función existe solo por compatibilidad con el código existente
	return
end

--[[
    Función: Obtener estado de todas las recompensas para un jugador
    Parámetros: player - El jugador
    Retorna: Array de recompensas con estado

    NOTA: Calcula el tiempo de la sesión actual únicamente
--]]
local function getRewardStatus(player)
	if not playerData[player.UserId] then return {} end

	local data = playerData[player.UserId]

	-- Calcular tiempo de sesión actual
	local sessionTime = tick() - data.JoinTime
	local playtimeMinutes = sessionTime / 60

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

    NOTA: Verifica el tiempo de la sesión actual únicamente
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

	-- Calcular tiempo de sesión actual
	local sessionTime = tick() - data.JoinTime
	local playtimeMinutes = sessionTime / 60

	-- Verificar si el jugador tiene suficiente tiempo jugado en esta sesión
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

	-- Reproducir sonido de recompensa
	playSoundEvent:FireClient(player, "Rewards", "PlaytimeReward")

	return true
end

--[[
    Evento: Cuando un jugador se une
    NOTA: El tiempo siempre empieza en 0 cada sesión
--]]
Players.PlayerAdded:Connect(function(player)
	-- Cargar datos (solo recompensas reclamadas)
	local data = loadPlayerData(player)
	playerData[player.UserId] = data
	playerData[player.UserId].JoinTime = tick() -- Inicio de la sesión

	-- Enviar estado inicial (tiempo = 0)
	task.wait(1)
	local rewards = getRewardStatus(player)
	updatePlaytimeEvent:FireClient(player, 0, rewards) -- Tiempo inicial = 0
end)

--[[
    Evento: Cuando un jugador sale
    NOTA: Solo guarda las recompensas reclamadas
          El tiempo jugado NO se guarda (se reinicia cada sesión)
--]]
Players.PlayerRemoving:Connect(function(player)
	if playerData[player.UserId] then
		-- Guardar solo las recompensas reclamadas
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
		-- Calcular tiempo de sesión actual
		local sessionTime = tick() - playerData[player.UserId].JoinTime

		local rewards = getRewardStatus(player)
		updatePlaytimeEvent:FireClient(player, math.floor(sessionTime), rewards)
	end
end)

--[[
    Evento: Cliente intenta reclamar recompensa
--]]
claimRewardEvent.OnServerEvent:Connect(function(player, rewardIndex)
	if playerData[player.UserId] then
		-- Calcular tiempo actual de la sesión
		local sessionTime = tick() - playerData[player.UserId].JoinTime
		local currentPlaytime = sessionTime -- Solo tiempo de esta sesión

		-- Intentar reclamar
		local success = claimReward(player, rewardIndex)

		-- Enviar estado actualizado
		local rewards = getRewardStatus(player)
		updatePlaytimeEvent:FireClient(player, math.floor(currentPlaytime), rewards)
	end
end)

--[[
    Loop: Actualizar tiempo de juego cada minuto
    NOTA: Solo cuenta el tiempo de la sesión actual
--]]
task.spawn(function()
	while true do
		task.wait(60) -- Cada minuto

		for _, player in pairs(Players:GetPlayers()) do
			if playerData[player.UserId] then
				-- Calcular tiempo de sesión actual
				local sessionTime = tick() - playerData[player.UserId].JoinTime

				-- Enviar actualización al cliente
				local rewards = getRewardStatus(player)
				updatePlaytimeEvent:FireClient(player, math.floor(sessionTime), rewards)
			end
		end
	end
end)

--[[
    Guardar datos cuando el servidor se cierra
    NOTA: Solo guarda las recompensas reclamadas
--]]
game:BindToClose(function()
	print("💾 Guardando recompensas antes de cerrar servidor...")
	for _, player in pairs(Players:GetPlayers()) do
		if playerData[player.UserId] then
			savePlayerData(player)
		end
	end
	task.wait(2) -- Dar tiempo para guardar
end)

print("🎁 Sistema de recompensas por tiempo cargado")
