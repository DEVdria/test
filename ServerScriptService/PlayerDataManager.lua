--[[
	PlayerDataManager.lua
	UBICACIÓN: ServerScriptService

	DESCRIPCIÓN:
	Este script maneja todo el sistema de dinero del jugador:
	- Crea automáticamente la carpeta "leaderstats" con la estadística "Money"
	- Guarda y carga el dinero usando DataStoreService
	- Otorga dinero inicial a nuevos jugadores

	FUNCIONES:
	- Guardado automático cada 5 minutos
	- Guardado al salir del juego
	- Protección contra pérdida de datos
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Configuración del DataStore
local MoneyDataStore = DataStoreService:GetDataStore("PlayerMoneyData_v1")

-- Configuración inicial
local DEFAULT_MONEY = 100 -- Dinero inicial para nuevos jugadores
local AUTO_SAVE_INTERVAL = 300 -- Guardar cada 5 minutos (en segundos)

-- Tabla para rastrear datos de jugadores
local PlayerData = {}

--[[
	Función: loadPlayerData
	Carga los datos del jugador desde el DataStore
	@param player - El jugador cuyos datos se cargarán
	@return number - La cantidad de dinero del jugador
]]
local function loadPlayerData(player)
	local userId = "Player_" .. player.UserId
	local success, data = pcall(function()
		return MoneyDataStore:GetAsync(userId)
	end)

	if success then
		if data then
			print("[DataStore] Datos cargados para " .. player.Name .. ": $" .. data)
			return data
		else
			print("[DataStore] Nuevo jugador detectado: " .. player.Name)
			return DEFAULT_MONEY
		end
	else
		warn("[DataStore] Error al cargar datos para " .. player.Name .. ": " .. tostring(data))
		return DEFAULT_MONEY
	end
end

--[[
	Función: savePlayerData
	Guarda los datos del jugador en el DataStore
	@param player - El jugador cuyos datos se guardarán
	@return boolean - true si se guardó exitosamente, false si hubo error
]]
local function savePlayerData(player)
	if not PlayerData[player] then
		return false
	end

	local userId = "Player_" .. player.UserId
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		return false
	end

	local success, errorMsg = pcall(function()
		MoneyDataStore:SetAsync(userId, money.Value)
	end)

	if success then
		print("[DataStore] Datos guardados para " .. player.Name .. ": $" .. money.Value)
		return true
	else
		warn("[DataStore] Error al guardar datos para " .. player.Name .. ": " .. tostring(errorMsg))
		return false
	end
end

--[[
	Función: setupLeaderstats
	Crea la carpeta leaderstats y la estadística Money para un jugador
	@param player - El jugador para quien se creará leaderstats
]]
local function setupLeaderstats(player)
	-- Crear carpeta leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Crear estadística de Money
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = loadPlayerData(player) -- Cargar dinero guardado o valor por defecto
	money.Parent = leaderstats

	print("[Leaderstats] Creado para " .. player.Name .. " con $" .. money.Value)
end

--[[
	Función: onPlayerAdded
	Se ejecuta cuando un jugador se une al juego
	@param player - El jugador que se unió
]]
local function onPlayerAdded(player)
	-- Configurar leaderstats
	setupLeaderstats(player)

	-- Registrar jugador en la tabla de datos
	PlayerData[player] = true

	-- Auto-guardado periódico para este jugador
	task.spawn(function()
		while player.Parent do
			task.wait(AUTO_SAVE_INTERVAL)
			if player.Parent then
				savePlayerData(player)
			end
		end
	end)
end

--[[
	Función: onPlayerRemoving
	Se ejecuta cuando un jugador sale del juego
	@param player - El jugador que está saliendo
]]
local function onPlayerRemoving(player)
	-- Guardar datos antes de que el jugador salga
	savePlayerData(player)

	-- Limpiar datos del jugador
	PlayerData[player] = nil

	print("[PlayerData] Jugador " .. player.Name .. " ha salido del juego")
end

-- Conectar eventos
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Configurar jugadores que ya están en el juego (por si el script se recarga)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Guardado de emergencia al cerrar el servidor
game:BindToClose(function()
	print("[DataStore] Guardando todos los datos antes de cerrar el servidor...")
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
	task.wait(3) -- Dar tiempo para que se completen los guardados
end)

print("[PlayerDataManager] Sistema de dinero inicializado correctamente")
