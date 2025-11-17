--[[
═══════════════════════════════════════════════════════════════
    MONEY MANAGER - Sistema de Dinero con DataStore
    Ubicación: ServerScriptService

    Funcionalidad:
    - Crea carpeta leaderstats para cada jugador
    - Añade estadística "Money"
    - Guarda y carga datos con DataStoreService
    - Maneja errores de guardado
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Dinero inicial que reciben los nuevos jugadores
local DEFAULT_MONEY = 100
local DEFAULT_WINS = 0

-- Tabla para almacenar datos en memoria
local playerData = {}

-- Verificar si el DataStore está disponible
local MoneyDataStore = nil
local dataStoreEnabled = false

-- Intentar inicializar DataStore
local success, result = pcall(function()
	return DataStoreService:GetDataStore("PlayerMoney_V1")
end)

if success then
	MoneyDataStore = result
	dataStoreEnabled = true
	print("✅ DataStore inicializado correctamente")
else
	warn("⚠️ DataStore NO disponible: " .. tostring(result))
	warn("⚠️ El dinero NO se guardará entre sesiones")
	warn("⚠️ Para habilitar DataStore en Studio:")
	warn("   1. Ve a Game Settings (Home → Game Settings)")
	warn("   2. Security → Enable Studio Access to API Services")
	warn("   3. Guarda y reinicia el juego")
	warn("⚠️ En juegos publicados, el DataStore funciona automáticamente")
end

--[[
    Función: Cargar datos del jugador
    Parámetros: player - El jugador que se une
    Retorna: tabla con Money y Wins
--]]
local function loadPlayerData(player)
	-- Si DataStore no está disponible, usar datos por defecto
	if not dataStoreEnabled or not MoneyDataStore then
		print("📊 " .. player.Name .. " inicia con datos por defecto (DataStore deshabilitado)")
		return {Money = DEFAULT_MONEY, Wins = DEFAULT_WINS}
	end

	local success, data
	local attempts = 0
	local maxAttempts = 3

	-- Intentar cargar datos con reintentos en caso de error
	repeat
		attempts = attempts + 1
		success, data = pcall(function()
			return MoneyDataStore:GetAsync(player.UserId)
		end)

		if not success then
			warn("❌ Error al cargar datos de " .. player.Name .. " (Intento " .. attempts .. "/" .. maxAttempts .. ")")
			if attempts < maxAttempts then
				wait(1)
			end
		end
	until success or attempts >= maxAttempts

	-- Retornar datos cargados o datos por defecto
	if success and data then
		-- Si data es un número (formato antiguo), convertir a tabla
		if type(data) == "number" then
			print("💾 Datos cargados para " .. player.Name .. ": $" .. tostring(data) .. " (formato antiguo)")
			return {Money = data, Wins = DEFAULT_WINS}
		-- Si data es una tabla (formato nuevo)
		elseif type(data) == "table" then
			print("💾 Datos cargados para " .. player.Name .. ": $" .. tostring(data.Money) .. ", Wins: " .. tostring(data.Wins or 0))
			return {Money = data.Money or DEFAULT_MONEY, Wins = data.Wins or DEFAULT_WINS}
		end
	end

	print("📊 " .. player.Name .. " inicia con datos por defecto")
	return {Money = DEFAULT_MONEY, Wins = DEFAULT_WINS}
end

--[[
    Función: Guardar datos del jugador
    Parámetros: player - El jugador cuyo dinero y wins se guardarán
--]]
local function savePlayerData(player)
	if not playerData[player.UserId] then
		return
	end

	-- Si DataStore no está disponible, no intentar guardar
	if not dataStoreEnabled or not MoneyDataStore then
		return
	end

	local dataToSave = {
		Money = playerData[player.UserId].Money,
		Wins = playerData[player.UserId].Wins
	}

	local success, errorMessage = pcall(function()
		MoneyDataStore:SetAsync(player.UserId, dataToSave)
	end)

	if success then
		print("💾 Datos guardados para " .. player.Name .. ": $" .. dataToSave.Money .. ", Wins: " .. dataToSave.Wins)
	else
		warn("❌ Error al guardar datos de " .. player.Name .. ": " .. tostring(errorMessage))
	end
end

--[[
    Función: Añadir dinero a un jugador
    Parámetros:
        player - El jugador
        amount - Cantidad a añadir
--]]
local function addMoney(player, amount)
	if playerData[player.UserId] then
		-- Añadir dinero
		playerData[player.UserId].Money = playerData[player.UserId].Money + amount

		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				money.Value = playerData[player.UserId].Money
			end
		end

		-- Actualizar progreso de misiones (si no viene de cofres)
		-- Los cofres ya actualizan directamente en su script
		if _G.QuestSystem and amount > 0 then
			-- Solo actualizar si es una cantidad pequeña (probablemente no es de cofre)
			if amount < 2000 then
				_G.QuestSystem.UpdateProgress(player, "MoneyEarned", amount)
			end
		end
	end
end

--[[
    Función: Remover dinero de un jugador
    Parámetros:
        player - El jugador
        amount - Cantidad a remover
    Retorna: true si tiene suficiente dinero, false si no
--]]
local function removeMoney(player, amount)
	if playerData[player.UserId] then
		if playerData[player.UserId].Money >= amount then
			playerData[player.UserId].Money = playerData[player.UserId].Money - amount

			-- Actualizar leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local money = leaderstats:FindFirstChild("Money")
				if money then
					money.Value = playerData[player.UserId].Money
				end
			end
			return true
		else
			return false -- No tiene suficiente dinero
		end
	end
	return false
end

--[[
    Función: Obtener dinero actual del jugador
    Parámetros: player - El jugador
    Retorna: Cantidad de dinero o 0
--]]
local function getMoney(player)
	if playerData[player.UserId] then
		return playerData[player.UserId].Money
	end
	return 0
end

--[[
    Función: Añadir wins a un jugador
    Parámetros:
        player - El jugador
        amount - Cantidad de wins a añadir (por defecto 1)
--]]
local function addWins(player, amount)
	amount = amount or 1

	if playerData[player.UserId] then
		-- Añadir wins
		playerData[player.UserId].Wins = playerData[player.UserId].Wins + amount

		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local wins = leaderstats:FindFirstChild("Wins")
			if wins then
				wins.Value = playerData[player.UserId].Wins
			end
		end
	end
end

--[[
    Función: Obtener wins actuales del jugador
    Parámetros: player - El jugador
    Retorna: Cantidad de wins o 0
--]]
local function getWins(player)
	if playerData[player.UserId] then
		return playerData[player.UserId].Wins
	end
	return 0
end

-- Cuando un jugador se une al juego
Players.PlayerAdded:Connect(function(player)
	-- Crear carpeta leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Crear valor de Money
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 0
	money.Parent = leaderstats

	-- Crear valor de Wins
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats

	-- Cargar datos guardados
	local savedData = loadPlayerData(player)

	-- Guardar en tabla de datos
	playerData[player.UserId] = {
		Money = savedData.Money,
		Wins = savedData.Wins
	}

	-- Actualizar valores en leaderstats
	money.Value = savedData.Money
	wins.Value = savedData.Wins

	print("👤 " .. player.Name .. " se ha unido con $" .. savedData.Money .. " y " .. savedData.Wins .. " wins")
end)

-- Cuando un jugador sale del juego
Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	playerData[player.UserId] = nil
end)

-- Guardar datos cada 5 minutos (auto-guardado)
-- Solo si DataStore está habilitado
if dataStoreEnabled then
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutos

			local playerCount = 0
			for _, player in pairs(Players:GetPlayers()) do
				savePlayerData(player)
				playerCount = playerCount + 1
			end

			if playerCount > 0 then
				print("💾 Auto-guardado completado (" .. playerCount .. " jugadores)")
			end
		end
	end)
else
	print("⚠️ Auto-guardado deshabilitado (DataStore no disponible)")
end

-- Exponer funciones globalmente para otros scripts
_G.MoneyManager = {
	AddMoney = addMoney,
	RemoveMoney = removeMoney,
	GetMoney = getMoney,
	AddWins = addWins,
	GetWins = getWins,
	SaveData = savePlayerData,
	IsDataStoreEnabled = function() return dataStoreEnabled end
}

-- Alias para compatibilidad con scripts existentes
_G.AddMoney = addMoney
_G.RemoveMoney = removeMoney
_G.GetMoney = getMoney
_G.AddWins = addWins
_G.GetWins = getWins

print("═══════════════════════════════════════════════════════")
print("💰 Money Manager iniciado correctamente")
print("💾 DataStore: " .. (dataStoreEnabled and "✅ HABILITADO" or "❌ DESHABILITADO"))
print("💵 Dinero inicial: $" .. DEFAULT_MONEY)
print("═══════════════════════════════════════════════════════")
