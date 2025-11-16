--[[
═══════════════════════════════════════════════════════════════
    MULTIPLIER SYSTEM - Sistema de Multiplicadores de Dinero
    Ubicación: ServerScriptService

    Funcionalidad:
    - Permite a los jugadores comprar multiplicadores de dinero
    - Cada compra aumenta el multiplicador en +0.1 (x1.0 → x1.1 → x1.2...)
    - El multiplicador es individual por jugador
    - Se guarda en DataStore para persistencia
    - Costo: 10,000 por cada nivel de multiplicador
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- DataStore para multiplicadores
local MultiplierDataStore
local dataStoreEnabled = false

-- Intentar inicializar DataStore
local success, result = pcall(function()
	return DataStoreService:GetDataStore("PlayerMultipliers_V1")
end)

if success then
	MultiplierDataStore = result
	dataStoreEnabled = true
	print("✅ DataStore de Multiplicadores inicializado")
else
	warn("⚠️ DataStore de Multiplicadores NO disponible")
end

-- Configuración
local MULTIPLIER_COST = 10000 -- Costo de cada nivel
local MULTIPLIER_INCREMENT = 0.1 -- Incremento por compra

-- Crear RemoteEvents
local purchaseMultiplierEvent = ReplicatedStorage:FindFirstChild("PurchaseMultiplier")
if not purchaseMultiplierEvent then
	purchaseMultiplierEvent = Instance.new("RemoteEvent")
	purchaseMultiplierEvent.Name = "PurchaseMultiplier"
	purchaseMultiplierEvent.Parent = ReplicatedStorage
end

local getMultiplierEvent = ReplicatedStorage:FindFirstChild("GetMultiplier")
if not getMultiplierEvent then
	getMultiplierEvent = Instance.new("RemoteEvent")
	getMultiplierEvent.Name = "GetMultiplier"
	getMultiplierEvent.Parent = ReplicatedStorage
end

--[[
    Función: Cargar multiplicador del jugador
    Parámetros: player - El jugador
    Retorna: Valor del multiplicador
--]]
local function loadMultiplier(player)
	if not dataStoreEnabled then
		return 1.0
	end

	local success, multiplier = pcall(function()
		return MultiplierDataStore:GetAsync(player.UserId .. "_multiplier")
	end)

	if success and multiplier then
		print("✅ Multiplicador cargado para " .. player.Name .. ": x" .. multiplier)
		return multiplier
	else
		print("📝 Nuevo multiplicador para " .. player.Name .. ": x1.0")
		return 1.0
	end
end

--[[
    Función: Guardar multiplicador del jugador
    Parámetros:
        player - El jugador
        multiplier - Valor del multiplicador
--]]
local function saveMultiplier(player, multiplier)
	if not dataStoreEnabled then return end

	local success, err = pcall(function()
		MultiplierDataStore:SetAsync(player.UserId .. "_multiplier", multiplier)
	end)

	if success then
		print("💾 Multiplicador guardado para " .. player.Name .. ": x" .. multiplier)
	else
		warn("❌ Error al guardar multiplicador de " .. player.Name .. ": " .. tostring(err))
	end
end

--[[
    Función: Obtener multiplicador del jugador
    Parámetros: player - El jugador
    Retorna: Valor del multiplicador
--]]
local function getMultiplier(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local multiplierStat = leaderstats:FindFirstChild("Multiplicador")
		if multiplierStat then
			return multiplierStat.Value
		end
	end
	return 1.0
end

--[[
    Función: Comprar multiplicador
    Parámetros: player - El jugador
    Retorna: true si tuvo éxito, false si no
--]]
local function purchaseMultiplier(player)
	-- Verificar que el jugador tenga suficiente dinero
	if not _G.GetMoney then
		warn("❌ MoneyManager no está cargado")
		return false
	end

	local currentMoney = _G.GetMoney(player)
	if currentMoney < MULTIPLIER_COST then
		-- Enviar notificación de dinero insuficiente
		local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
		if notificationEvent then
			notificationEvent:FireClient(
				player,
				"❌ Necesitas $" .. MULTIPLIER_COST .. " para comprar el multiplicador",
				Color3.fromRGB(255, 85, 85)
			)
		end
		return false
	end

	-- Obtener multiplicador actual
	local currentMultiplier = getMultiplier(player)

	-- Restar dinero
	if _G.RemoveMoney then
		_G.RemoveMoney(player, MULTIPLIER_COST)
	end

	-- Aumentar multiplicador
	local newMultiplier = currentMultiplier + MULTIPLIER_INCREMENT
	newMultiplier = math.floor(newMultiplier * 10 + 0.5) / 10 -- Redondear a 1 decimal

	-- Actualizar estadística
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local multiplierStat = leaderstats:FindFirstChild("Multiplicador")
		if multiplierStat then
			multiplierStat.Value = newMultiplier
		end
	end

	-- Guardar en DataStore
	saveMultiplier(player, newMultiplier)

	-- Enviar notificación de éxito
	local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
	if notificationEvent then
		notificationEvent:FireClient(
			player,
			"🎉 ¡Multiplicador aumentado a x" .. newMultiplier .. "!",
			Color3.fromRGB(85, 255, 127)
		)
	end

	print("✅ " .. player.Name .. " compró multiplicador: x" .. currentMultiplier .. " → x" .. newMultiplier)
	return true
end

--[[
    Evento: Cuando un jugador se une
--]]
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que se cree leaderstats
	local leaderstats = player:WaitForChild("leaderstats", 5)
	if not leaderstats then
		warn("⚠️ No se encontró leaderstats para " .. player.Name)
		return
	end

	-- Crear estadística de multiplicador
	local multiplierStat = Instance.new("NumberValue")
	multiplierStat.Name = "Multiplicador"
	multiplierStat.Value = 1.0
	multiplierStat.Parent = leaderstats

	-- Cargar multiplicador guardado
	task.wait(0.5)
	local savedMultiplier = loadMultiplier(player)
	multiplierStat.Value = savedMultiplier

	print("✅ Multiplicador inicializado para " .. player.Name .. ": x" .. savedMultiplier)
end)

--[[
    Evento: Cuando un jugador sale
--]]
Players.PlayerRemoving:Connect(function(player)
	-- Guardar multiplicador
	local multiplier = getMultiplier(player)
	saveMultiplier(player, multiplier)
end)

--[[
    Evento: Cliente solicita comprar multiplicador
--]]
purchaseMultiplierEvent.OnServerEvent:Connect(function(player)
	purchaseMultiplier(player)
end)

--[[
    Evento: Cliente solicita obtener multiplicador
--]]
getMultiplierEvent.OnServerEvent:Connect(function(player)
	local multiplier = getMultiplier(player)
	getMultiplierEvent:FireClient(player, multiplier)
end)

--[[
    Función global: Obtener multiplicador de un jugador
    Exportada para que otros scripts la usen
--]]
_G.GetMultiplier = function(player)
	return getMultiplier(player)
end

--[[
    Guardar datos cuando el servidor se cierra
--]]
game:BindToClose(function()
	print("💾 Guardando multiplicadores antes de cerrar servidor...")
	for _, player in pairs(Players:GetPlayers()) do
		local multiplier = getMultiplier(player)
		saveMultiplier(player, multiplier)
	end
	task.wait(2)
end)

print("✨ Sistema de Multiplicadores cargado")
