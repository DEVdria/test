--[[
	LeaderboardHandler.lua
	UBICACIÓN: ServerScriptService

	DESCRIPCIÓN:
	Este script maneja el leaderboard global de jugadores con más dinero.
	Usa OrderedDataStore para mantener un ranking actualizado.

	FUNCIONES:
	- Actualiza el leaderboard cuando cambia el dinero de un jugador
	- Permite consultar el top N jugadores
	- Sistema de caché para reducir llamadas al DataStore

	CONFIGURACIÓN:
	- El leaderboard se actualiza automáticamente
	- Los clientes pueden solicitar el top mediante RemoteFunction
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local LEADERBOARD_CONFIG = {
	DataStoreName = "GlobalMoneyLeaderboard_v1",
	UpdateInterval = 60,  -- Actualizar el leaderboard cada 60 segundos
	TopPlayersCount = 10, -- Número de jugadores en el top
	CacheDuration = 30,   -- Duración del caché en segundos
}

-- ═══════════════════════════════════════════════════════════
-- DATASTORES
-- ═══════════════════════════════════════════════════════════

local MoneyLeaderboard = DataStoreService:GetOrderedDataStore(LEADERBOARD_CONFIG.DataStoreName)

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local LeaderboardCache = {
	Data = {},
	LastUpdate = 0,
}

-- ═══════════════════════════════════════════════════════════
-- REMOTE EVENTS
-- ═══════════════════════════════════════════════════════════

local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

local getLeaderboardRemote = remoteEventsFolder:FindFirstChild("GetLeaderboard")
if not getLeaderboardRemote then
	getLeaderboardRemote = Instance.new("RemoteFunction")
	getLeaderboardRemote.Name = "GetLeaderboard"
	getLeaderboardRemote.Parent = remoteEventsFolder
end

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

--[[
	Función: updatePlayerScore
	Actualiza el puntaje de un jugador en el leaderboard
	@param player - El jugador
	@param money - La cantidad de dinero del jugador
]]
local function updatePlayerScore(player, money)
	local userId = player.UserId
	local username = player.Name

	local success, errorMsg = pcall(function()
		MoneyLeaderboard:SetAsync(userId, money)
	end)

	if success then
		print(string.format("[Leaderboard] Actualizado %s: $%d", username, money))
	else
		warn(string.format("[Leaderboard] Error al actualizar %s: %s", username, tostring(errorMsg)))
	end
end

--[[
	Función: getTopPlayers
	Obtiene el top N jugadores del leaderboard
	@param count - Número de jugadores a obtener
	@return table - Lista de jugadores en formato {UserId, Name, Money}
]]
local function getTopPlayers(count)
	count = count or LEADERBOARD_CONFIG.TopPlayersCount

	local topPlayers = {}

	local success, pages = pcall(function()
		return MoneyLeaderboard:GetSortedAsync(false, count)
	end)

	if not success then
		warn("[Leaderboard] Error al obtener top players: " .. tostring(pages))
		return {}
	end

	local entries = pages:GetCurrentPage()

	for rank, entry in ipairs(entries) do
		local userId = entry.key
		local money = entry.value

		-- Obtener nombre del usuario
		local username = "Jugador_" .. userId
		local nameSuccess, fetchedName = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)

		if nameSuccess then
			username = fetchedName
		end

		table.insert(topPlayers, {
			Rank = rank,
			UserId = userId,
			Name = username,
			Money = money,
		})
	end

	return topPlayers
end

--[[
	Función: getCachedLeaderboard
	Obtiene el leaderboard desde caché o actualiza si es necesario
	@return table - Lista de top jugadores
]]
local function getCachedLeaderboard()
	local currentTime = tick()
	local timeSinceUpdate = currentTime - LeaderboardCache.LastUpdate

	-- Si el caché es reciente, devolverlo
	if timeSinceUpdate < LEADERBOARD_CONFIG.CacheDuration and #LeaderboardCache.Data > 0 then
		return LeaderboardCache.Data
	end

	-- Si no, actualizar el caché
	local topPlayers = getTopPlayers()
	LeaderboardCache.Data = topPlayers
	LeaderboardCache.LastUpdate = currentTime

	return topPlayers
end

-- ═══════════════════════════════════════════════════════════
-- MONITOREO DE CAMBIOS EN DINERO
-- ═══════════════════════════════════════════════════════════

--[[
	Función: onMoneyChanged
	Se ejecuta cuando cambia el dinero de un jugador
	@param player - El jugador
	@param money - IntValue del dinero
]]
local function onMoneyChanged(player, money)
	money.Changed:Connect(function(newValue)
		updatePlayerScore(player, newValue)
	end)

	-- Actualizar por primera vez
	updatePlayerScore(player, money.Value)
end

--[[
	Función: onPlayerAdded
	Se ejecuta cuando un jugador se une
	@param player - El jugador
]]
local function onPlayerAdded(player)
	-- Esperar a que se creen leaderstats
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[Leaderboard] No se encontró leaderstats para " .. player.Name)
		return
	end

	local money = leaderstats:WaitForChild("Money", 10)
	if not money then
		warn("[Leaderboard] No se encontró Money para " .. player.Name)
		return
	end

	-- Monitorear cambios en el dinero
	onMoneyChanged(player, money)
end

-- ═══════════════════════════════════════════════════════════
-- CALLBACKS DE REMOTE FUNCTIONS
-- ═══════════════════════════════════════════════════════════

--[[
	GetLeaderboard: Devuelve el top de jugadores al cliente
	@param player - El jugador que solicita el leaderboard
	@return table - Lista de top jugadores
]]
getLeaderboardRemote.OnServerInvoke = function(player)
	return getCachedLeaderboard()
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

-- Conectar eventos
Players.PlayerAdded:Connect(onPlayerAdded)

-- Configurar jugadores que ya están en el juego
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(player)
	end)
end

-- Actualización periódica del leaderboard (para limpiar caché)
task.spawn(function()
	while true do
		task.wait(LEADERBOARD_CONFIG.UpdateInterval)
		-- Actualizar caché
		getCachedLeaderboard()
		print("[Leaderboard] Caché actualizado")
	end
end)

print("[LeaderboardHandler] Sistema de leaderboard inicializado")
