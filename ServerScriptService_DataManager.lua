-- ServerScriptService > DataManager
-- Gestiona la persistencia de datos con DataStore
-- NOTA: Este es un Script normal, NO ModuleScript

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
print("[DataManager] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[DataManager] ❌ No se encontró carpeta Modules")
	return
end

local ZoneConfig = require(Modules:WaitForChild("ZoneConfig", 10))
local LevelManager = require(Modules:WaitForChild("LevelManager", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)

-- Funciones de rebirth (antes estaban en OrbConfig)
local function CalculateRebirthCost(rebirths)
	-- Costo base: 1000, aumenta exponencialmente
	local baseCost = 1000
	return baseCost * (2 ^ rebirths)
end

local function CalculateEXPMultiplier(rebirths)
	-- Cada rebirth da +10% de multiplicador
	return 1 + (rebirths * 0.1)
end
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_V2")  -- Cambio a V2 para nueva estructura

-- Almacenar funciones globalmente para que otros scripts puedan acceder
_G.DataManager = _G.DataManager or {}
local DataManager = _G.DataManager

local playerData = {}

-- Configuración
local AUTOSAVE_INTERVAL = 60 -- Guardar cada 60 segundos
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Estructura de datos por defecto
local function getDefaultData()
	return {
		Money = 0,
		Rebirths = 0,
		Level = 0,                    -- Nivel actual del jugador
		CurrentEXP = 0,               -- EXP actual del jugador
		EXPMultiplier = 1,            -- Multiplicador de EXP por rebirths
		OwnedZones = ZoneConfig.GetDefaultZones(),  -- Zonas que posee el jugador
		OwnedTrails = {"Fire"},       -- Trails que posee el jugador (Fire es gratis por defecto)
		EquippedTrail = "Fire",       -- Trail equipada actualmente
		Wins = 0,                     -- Victorias en carreras
		ChestCooldowns = {},          -- Cooldowns de cofres {[chestID] = timestamp}
		DailyRewards = {              -- Sistema de recompensas diarias
			CurrentDay = 1,           -- Día actual en el ciclo (1-7)
			LastClaimTime = 0,        -- Timestamp de última reclamación
			TotalClaimed = 0          -- Total de recompensas reclamadas
		},
		-- NOTA: PlayTime y ClaimedRewards NO se guardan - son solo por sesión
		-- Se inicializan cuando el jugador entra al servidor
		LastSave = os.time()
	}
end

-- Carga los datos de un jugador con reintentos
function DataManager.LoadData(player)
	local userId = player.UserId
	local success, data
	local attempts = 0

	repeat
		attempts = attempts + 1
		success, data = pcall(function()
			return PlayerDataStore:GetAsync(userId)
		end)

		if not success then
			warn(string.format("[DataManager] Error cargando datos de %s (Intento %d/%d): %s",
				player.Name, attempts, MAX_RETRIES, tostring(data)))
			if attempts < MAX_RETRIES then
				task.wait(RETRY_DELAY)
			end
		end
	until success or attempts >= MAX_RETRIES

	-- Si no se pudo cargar, usar datos por defecto
	if not success or not data then
		data = getDefaultData()
		warn(string.format("[DataManager] Usando datos por defecto para %s", player.Name))
	end

	-- Validar estructura de datos
	local defaultData = getDefaultData()
	for key, defaultValue in pairs(defaultData) do
		if data[key] == nil then
			data[key] = defaultValue
		end
	end

	-- Inicializar datos de sesión (no persistentes)
	data.PlayTime = 0  -- Tiempo de juego se reinicia cada sesión
	data.ClaimedRewards = {}  -- Recompensas se reinician cada sesión

	playerData[userId] = data
	return data
end

-- Guarda los datos de un jugador con reintentos
function DataManager.SaveData(player)
	local userId = player.UserId
	local data = playerData[userId]

	if not data then
		warn(string.format("[DataManager] No hay datos para guardar de %s", player.Name))
		return false
	end

	data.LastSave = os.time()

	-- Crear copia de datos SIN los datos de sesión (PlayTime, ClaimedRewards)
	local dataToSave = {}
	for key, value in pairs(data) do
		if key ~= "PlayTime" and key ~= "ClaimedRewards" then
			dataToSave[key] = value
		end
	end

	local success, errorMsg
	local attempts = 0

	repeat
		attempts = attempts + 1
		success, errorMsg = pcall(function()
			PlayerDataStore:SetAsync(userId, dataToSave)
		end)

		if not success then
			warn(string.format("[DataManager] Error guardando datos de %s (Intento %d/%d): %s",
				player.Name, attempts, MAX_RETRIES, tostring(errorMsg)))
			if attempts < MAX_RETRIES then
				task.wait(RETRY_DELAY)
			end
		end
	until success or attempts >= MAX_RETRIES

	if success then
		return true
	else
		warn(string.format("[DataManager] Fallo al guardar datos de %s después de %d intentos",
			player.Name, MAX_RETRIES))
		return false
	end
end

-- Obtiene los datos de un jugador en memoria
function DataManager.GetData(player)
	return playerData[player.UserId]
end

-- Actualiza un valor específico en los datos del jugador
function DataManager.SetValue(player, key, value)
	local data = playerData[player.UserId]
	if data then
		data[key] = value
		return true
	end
	return false
end

-- Incrementa un valor numérico
function DataManager.IncrementValue(player, key, amount)
	local data = playerData[player.UserId]
	if data and type(data[key]) == "number" then
		data[key] = data[key] + amount
		return data[key]
	end
	return nil
end

-- Añade dinero al jugador
function DataManager.AddMoney(player, amount)
	local newMoney = DataManager.IncrementValue(player, "Money", amount)
	if newMoney then
		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local moneyValue = leaderstats:FindFirstChild("Money")
			if moneyValue then
				moneyValue.Value = newMoney
			end
		end
		return true
	end
	return false
end

-- Añade EXP al jugador y procesa level ups automáticamente
function DataManager.AddEXP(player, expAmount)
	local data = playerData[player.UserId]
	if not data then return nil end

	-- Añadir EXP
	local newEXP = DataManager.IncrementValue(player, "CurrentEXP", expAmount)
	if not newEXP then return nil end

	-- Verificar si debe subir de nivel
	local currentLevel = data.Level
	local currentRebirths = data.Rebirths
	local maxLevel = LevelManager.GetMaxLevel(currentRebirths)

	-- Procesar level ups mientras tenga suficiente EXP y no haya alcanzado el máximo
	while currentLevel < maxLevel do
		local requiredEXP = LevelManager.GetRequiredEXP(currentLevel)

		if newEXP >= requiredEXP then
			-- Suficiente EXP para subir de nivel
			currentLevel = currentLevel + 1
			newEXP = newEXP - requiredEXP

			-- Actualizar datos
			data.Level = currentLevel
			data.CurrentEXP = newEXP

			-- Actualizar leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local levelValue = leaderstats:FindFirstChild("Level")
				if levelValue then
					levelValue.Value = currentLevel
				end
				local expValue = leaderstats:FindFirstChild("CurrentEXP")
				if expValue then
					expValue.Value = newEXP
				end
			end

			-- Enviar evento de level up
			local LevelUpEvent = RemoteEvents:FindFirstChild("LevelUp")
			if LevelUpEvent then
				local newSpeed = LevelManager.GetRunSpeed(currentLevel)
				LevelUpEvent:FireClient(player, currentLevel, newSpeed)
			end

			-- Verificar si alcanzó el nivel máximo
			if currentLevel >= maxLevel then
				local MaxLevelReachedEvent = RemoteEvents:FindFirstChild("MaxLevelReached")
				if MaxLevelReachedEvent then
					MaxLevelReachedEvent:FireClient(player, maxLevel)
				end
				break
			end

			print(string.format("[DataManager] ✅ %s subió al nivel %d!", player.Name, currentLevel))
		else
			-- No tiene suficiente EXP para subir más
			break
		end
	end

	-- Actualizar leaderstats con la EXP final
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local expValue = leaderstats:FindFirstChild("CurrentEXP")
		if expValue then
			expValue.Value = newEXP
		end
	end

	return newEXP
end

-- Añade Wins (victorias en carreras) al jugador
function DataManager.AddWins(player, winsAmount)
	winsAmount = winsAmount or 1  -- Por defecto añadir 1 win
	local newWins = DataManager.IncrementValue(player, "Wins", winsAmount)
	if newWins then
		print(string.format("[DataManager] ✅ %s ahora tiene %d wins", player.Name, newWins))
		return newWins
	end
	return nil
end

-- Actualiza el nivel del jugador
function DataManager.SetLevel(player, newLevel)
	local success = DataManager.SetValue(player, "Level", newLevel)
	if success then
		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local levelValue = leaderstats:FindFirstChild("Level")
			if levelValue then
				levelValue.Value = newLevel
			end
		end
	end
	return success
end

-- Actualiza la EXP actual
function DataManager.SetEXP(player, newEXP)
	local success = DataManager.SetValue(player, "CurrentEXP", newEXP)
	if success then
		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local expValue = leaderstats:FindFirstChild("CurrentEXP")
			if expValue then
				expValue.Value = newEXP
			end
		end
	end
	return success
end

-- Resetea nivel y EXP (para rebirths)
function DataManager.ResetLevelAndEXP(player)
	local data = playerData[player.UserId]
	if data then
		data.Level = 0
		data.CurrentEXP = 0
		return true
	end
	return false
end

-- Procesa un rebirth
function DataManager.ProcessRebirth(player)
	local data = playerData[player.UserId]
	if not data then return false end

	local currentRebirths = data.Rebirths
	local cost = CalculateRebirthCost(currentRebirths)

	-- Verificar si tiene suficiente dinero
	if data.Money < cost then
		return false, "Dinero insuficiente"
	end

	-- Procesar rebirth
	data.Money = 0                        -- Resetear dinero a 0
	data.Rebirths = data.Rebirths + 1
	data.Level = 0                        -- Resetear nivel
	data.CurrentEXP = 0                   -- Resetear EXP
	data.EXPMultiplier = CalculateEXPMultiplier(data.Rebirths)
	data.OwnedZones = ZoneConfig.GetDefaultZones()  -- Resetear zonas a las default

	-- Actualizar leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyValue = leaderstats:FindFirstChild("Money")
		if moneyValue then
			moneyValue.Value = data.Money
		end
		local rebirthsValue = leaderstats:FindFirstChild("Rebirths")
		if rebirthsValue then
			rebirthsValue.Value = data.Rebirths
		end
		local levelValue = leaderstats:FindFirstChild("Level")
		if levelValue then
			levelValue.Value = data.Level
		end
		local expValue = leaderstats:FindFirstChild("CurrentEXP")
		if expValue then
			expValue.Value = data.CurrentEXP
		end
	end

	return true, "Rebirth exitoso"
end

-- Procesa la compra de una zona
function DataManager.PurchaseZone(player, zoneID, cost)
	local data = playerData[player.UserId]
	if not data then return false end

	-- Verificar si tiene suficiente dinero
	if data.Money < cost then
		return false
	end

	-- Verificar si ya posee la zona
	if data.OwnedZones then
		for _, ownedZone in ipairs(data.OwnedZones) do
			if ownedZone == zoneID then
				return false  -- Ya posee la zona
			end
		end
	else
		data.OwnedZones = ZoneConfig.GetDefaultZones()
	end

	-- Procesar compra
	data.Money = data.Money - cost
	table.insert(data.OwnedZones, zoneID)

	-- Actualizar leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyValue = leaderstats:FindFirstChild("Money")
		if moneyValue then
			moneyValue.Value = data.Money
		end
	end

	return true
end

-- Limpia los datos de un jugador de la memoria
function DataManager.UnloadData(player)
	playerData[player.UserId] = nil
end

-- ==================== FUNCIONES DE PLAYTIME ====================

-- Obtiene el tiempo de juego actual del jugador (en segundos)
function DataManager.GetPlaytime(player)
	local data = playerData[player.UserId]
	if not data then return 0 end

	return data.PlayTime or 0
end

-- Añade tiempo de juego al jugador
function DataManager.AddPlaytime(player, seconds)
	local data = playerData[player.UserId]
	if not data then return false end

	data.PlayTime = (data.PlayTime or 0) + seconds
	return data.PlayTime
end

-- Obtiene las recompensas reclamadas por el jugador
function DataManager.GetClaimedRewards(player)
	local data = playerData[player.UserId]
	if not data then return {} end

	return data.ClaimedRewards or {}
end

-- Verifica si una recompensa ya fue reclamada
function DataManager.IsRewardClaimed(player, rewardID)
	local claimedRewards = DataManager.GetClaimedRewards(player)
	return table.find(claimedRewards, rewardID) ~= nil
end

-- Reclama una recompensa de playtime
-- Devuelve: success (boolean), message (string), moneyEarned (number)
function DataManager.ClaimReward(player, rewardID, moneyAmount)
	local data = playerData[player.UserId]
	if not data then
		return false, "Datos no encontrados", 0
	end

	-- Verificar si ya fue reclamada
	if DataManager.IsRewardClaimed(player, rewardID) then
		return false, "Ya reclamaste esta recompensa", 0
	end

	-- Añadir a recompensas reclamadas
	if not data.ClaimedRewards then
		data.ClaimedRewards = {}
	end
	table.insert(data.ClaimedRewards, rewardID)

	-- Añadir dinero
	local success = DataManager.AddMoney(player, moneyAmount)
	if not success then
		return false, "Error al añadir dinero", 0
	end

	print(string.format("[DataManager] ✅ %s reclamó recompensa %d: $%d", player.Name, rewardID, moneyAmount))

	return true, string.format("¡Reclamaste $%s!", DataManager.FormatNumber(moneyAmount)), moneyAmount
end

-- Formatea números con separadores de miles
function DataManager.FormatNumber(num)
	local formatted = tostring(num)
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted
end

-- Inicializar automáticamente
print("[DataManager] Inicializando...")

-- Manejar cuando un jugador se une
Players.PlayerAdded:Connect(function(player)
	-- Cargar datos
	local data = DataManager.LoadData(player)

	-- Crear leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = data.Money
	money.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths
	rebirths.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = data.Level
	level.Parent = leaderstats

	local currentEXP = Instance.new("IntValue")
	currentEXP.Name = "CurrentEXP"
	currentEXP.Value = data.CurrentEXP
	currentEXP.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = data.Wins
	wins.Parent = leaderstats

	print(string.format("[DataManager] ✅ Datos cargados para %s (Nivel: %d, EXP: %d, Wins: %d)",
		player.Name, data.Level, data.CurrentEXP, data.Wins))
end)

-- Manejar cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	DataManager.SaveData(player)
	DataManager.UnloadData(player)
end)

-- Autoguardado periódico
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				DataManager.SaveData(player)
			end)
		end
	end
end)

-- Guardar todos los datos al cerrar el servidor
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.SaveData(player)
	end
	task.wait(2) -- Dar tiempo para que se guarden los datos
end)

-- ========================================
-- REMOTES PARA CLIENTES
-- ========================================

-- Crear carpeta Remotes si no existe
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
	print("[DataManager] 📁 Carpeta 'Remotes' creada")
end

-- RemoteFunction para obtener wins del jugador
local GetPlayerWinsFunction = RemotesFolder:FindFirstChild("GetPlayerWins")
if not GetPlayerWinsFunction then
	GetPlayerWinsFunction = Instance.new("RemoteFunction")
	GetPlayerWinsFunction.Name = "GetPlayerWins"
	GetPlayerWinsFunction.Parent = RemotesFolder
	print("[DataManager] ✅ RemoteFunction 'GetPlayerWins' creada")
end

GetPlayerWinsFunction.OnServerInvoke = function(player)
	local data = DataManager.GetData(player)
	if data then
		return data.Wins or 0
	end
	return 0
end

print("[DataManager] ✅ Sistema de datos inicializado")
