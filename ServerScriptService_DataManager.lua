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

local OrbConfig = require(Modules:WaitForChild("OrbConfig", 10))
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_V1")

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

	local success, errorMsg
	local attempts = 0

	repeat
		attempts = attempts + 1
		success, errorMsg = pcall(function()
			PlayerDataStore:SetAsync(userId, data)
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

-- Añade EXP al jugador
function DataManager.AddEXP(player, expAmount)
	local newEXP = DataManager.IncrementValue(player, "CurrentEXP", expAmount)
	if newEXP then
		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local expValue = leaderstats:FindFirstChild("CurrentEXP")
			if expValue then
				expValue.Value = newEXP
			end
		end
		return newEXP
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
	local cost = OrbConfig.CalculateRebirthCost(currentRebirths)

	-- Verificar si tiene suficiente dinero
	if data.Money < cost then
		return false, "Dinero insuficiente"
	end

	-- Procesar rebirth
	data.Money = data.Money - cost
	data.Rebirths = data.Rebirths + 1
	data.Level = 0                        -- Resetear nivel
	data.CurrentEXP = 0                   -- Resetear EXP
	data.EXPMultiplier = OrbConfig.CalculateEXPMultiplier(data.Rebirths)

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

-- Limpia los datos de un jugador de la memoria
function DataManager.UnloadData(player)
	playerData[player.UserId] = nil
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

	print(string.format("[DataManager] ✅ Datos cargados para %s (Nivel: %d, EXP: %d)",
		player.Name, data.Level, data.CurrentEXP))
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

print("[DataManager] ✅ Sistema de datos inicializado")
