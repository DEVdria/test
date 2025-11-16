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

-- DataStore para guardar el dinero de los jugadores
local MoneyDataStore = DataStoreService:GetDataStore("PlayerMoney_V1")

-- Dinero inicial que reciben los nuevos jugadores
local DEFAULT_MONEY = 100

-- Tabla para almacenar datos en memoria
local playerData = {}

--[[
    Función: Cargar datos del jugador
    Parámetros: player - El jugador que se une
--]]
local function loadPlayerData(player)
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
			warn("Error al cargar datos de " .. player.Name .. " (Intento " .. attempts .. "/" .. maxAttempts .. ")")
			wait(1)
		end
	until success or attempts >= maxAttempts

	-- Retornar datos cargados o datos por defecto
	if success and data then
		return data
	else
		warn("No se pudieron cargar datos para " .. player.Name .. ". Usando valores por defecto.")
		return DEFAULT_MONEY
	end
end

--[[
    Función: Guardar datos del jugador
    Parámetros: player - El jugador cuyo dinero se guardará
--]]
local function savePlayerData(player)
	if not playerData[player.UserId] then
		return
	end

	local success, errorMessage = pcall(function()
		MoneyDataStore:SetAsync(player.UserId, playerData[player.UserId].Money)
	end)

	if success then
		print("Datos guardados para " .. player.Name)
	else
		warn("Error al guardar datos de " .. player.Name .. ": " .. tostring(errorMessage))
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
		playerData[player.UserId].Money = playerData[player.UserId].Money + amount

		-- Actualizar leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				money.Value = playerData[player.UserId].Money
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

	-- Cargar datos guardados
	local savedMoney = loadPlayerData(player)

	-- Guardar en tabla de datos
	playerData[player.UserId] = {
		Money = savedMoney
	}

	-- Actualizar valor en leaderstats
	money.Value = savedMoney

	print(player.Name .. " se ha unido con $" .. savedMoney)
end)

-- Cuando un jugador sale del juego
Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	playerData[player.UserId] = nil
end)

-- Guardar datos cada 5 minutos (auto-guardado)
while true do
	wait(300) -- 5 minutos

	for _, player in pairs(Players:GetPlayers()) do
		savePlayerData(player)
	end

	print("Auto-guardado completado")
end

-- Exponer funciones globalmente para otros scripts
_G.MoneyManager = {
	AddMoney = addMoney,
	RemoveMoney = removeMoney,
	GetMoney = getMoney,
	SaveData = savePlayerData
}
