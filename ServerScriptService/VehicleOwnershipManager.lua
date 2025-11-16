--[[
═══════════════════════════════════════════════════════════════
    VEHICLE OWNERSHIP MANAGER - Sistema de Propiedad de Vehículos
    Ubicación: ServerScriptService

    Funcionalidad:
    - Gestiona qué jugadores han comprado qué vehículos
    - Guarda las compras en DataStore (permanente)
    - Proporciona funciones globales para verificar propiedad
    - Procesa compras de vehículos
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DataStore para vehículos comprados
local VehicleOwnershipStore
local dataStoreEnabled = false

-- Intentar inicializar DataStore
local success, result = pcall(function()
	return DataStoreService:GetDataStore("VehicleOwnership_V1")
end)

if success then
	VehicleOwnershipStore = result
	dataStoreEnabled = true
	print("✅ DataStore de VehicleOwnership inicializado")
else
	warn("⚠️ DataStore de VehicleOwnership NO disponible")
end

-- Tabla en memoria: [UserId] = {VehicleName1 = true, VehicleName2 = true, ...}
local playerOwnedVehicles = {}

-- Crear RemoteEvents
local purchaseVehicleEvent = ReplicatedStorage:FindFirstChild("PurchaseVehicle")
if not purchaseVehicleEvent then
	purchaseVehicleEvent = Instance.new("RemoteEvent")
	purchaseVehicleEvent.Name = "PurchaseVehicle"
	purchaseVehicleEvent.Parent = ReplicatedStorage
end

local checkOwnershipEvent = ReplicatedStorage:FindFirstChild("CheckVehicleOwnership")
if not checkOwnershipEvent then
	checkOwnershipEvent = Instance.new("RemoteFunction")
	checkOwnershipEvent.Name = "CheckVehicleOwnership"
	checkOwnershipEvent.Parent = ReplicatedStorage
end

--[[
    Función: Cargar vehículos comprados del jugador
    Parámetros: player - El jugador
    Retorna: Tabla con vehículos comprados {VehicleName = true, ...}
--]]
local function loadPlayerVehicles(player)
	local ownedVehicles = {}

	if not dataStoreEnabled then
		return ownedVehicles
	end

	local success, data = pcall(function()
		return VehicleOwnershipStore:GetAsync(player.UserId .. "_vehicles")
	end)

	if success and data then
		ownedVehicles = data
		print("✅ Vehículos cargados para " .. player.Name .. ": " .. #ownedVehicles .. " vehículos")
	else
		print("📝 Sin vehículos comprados para " .. player.Name)
	end

	return ownedVehicles
end

--[[
    Función: Guardar vehículos comprados del jugador
    Parámetros: player - El jugador
--]]
local function savePlayerVehicles(player)
	if not dataStoreEnabled then return end
	if not playerOwnedVehicles[player.UserId] then return end

	local vehicleList = {}
	for vehicleName, _ in pairs(playerOwnedVehicles[player.UserId]) do
		table.insert(vehicleList, vehicleName)
	end

	local success, err = pcall(function()
		VehicleOwnershipStore:SetAsync(player.UserId .. "_vehicles", vehicleList)
	end)

	if success then
		print("💾 Vehículos guardados para " .. player.Name)
	else
		warn("❌ Error al guardar vehículos de " .. player.Name .. ": " .. tostring(err))
	end
end

--[[
    Función: Verificar si un jugador posee un vehículo
    Parámetros:
        player - El jugador
        vehicleName - Nombre del vehículo
    Retorna: true si lo posee, false si no
--]]
local function ownsVehicle(player, vehicleName)
	if not playerOwnedVehicles[player.UserId] then
		return false
	end

	return playerOwnedVehicles[player.UserId][vehicleName] == true
end

--[[
    Función: Dar propiedad de un vehículo a un jugador
    Parámetros:
        player - El jugador
        vehicleName - Nombre del vehículo
--]]
local function grantVehicle(player, vehicleName)
	if not playerOwnedVehicles[player.UserId] then
		playerOwnedVehicles[player.UserId] = {}
	end

	playerOwnedVehicles[player.UserId][vehicleName] = true
	savePlayerVehicles(player)

	print("✅ " .. player.Name .. " ahora posee: " .. vehicleName)
end

--[[
    Función: Procesar compra de vehículo
    Parámetros:
        player - El jugador que compra
        vehicleName - Nombre del vehículo
        price - Precio del vehículo
    Retorna: true si la compra fue exitosa, false si no
--]]
local function purchaseVehicle(player, vehicleName, price)
	-- Verificar si ya lo posee
	if ownsVehicle(player, vehicleName) then
		local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
		if notificationEvent then
			notificationEvent:FireClient(
				player,
				"⚠️ Ya posees este vehículo",
				Color3.fromRGB(255, 170, 0)
			)
		end
		return false
	end

	-- Verificar que tenga suficiente dinero
	if _G.MoneyManager then
		local currentMoney = _G.MoneyManager.GetMoney(player)

		if currentMoney >= price then
			-- Remover dinero
			local success = _G.MoneyManager.RemoveMoney(player, price)

			if success then
				-- Dar propiedad del vehículo
				grantVehicle(player, vehicleName)

				-- Notificar éxito
				local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
				if notificationEvent then
					notificationEvent:FireClient(
						player,
						"🚗 ¡Compraste " .. vehicleName .. "!",
						Color3.fromRGB(85, 255, 127)
					)
				end

				-- Reproducir sonido
				local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
				if playSoundEvent then
					playSoundEvent:FireClient(player, "Shop", "Purchase")
				end

				print("💰 " .. player.Name .. " compró " .. vehicleName .. " por $" .. price)
				return true
			end
		else
			-- No tiene suficiente dinero
			local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
			if notificationEvent then
				notificationEvent:FireClient(
					player,
					"❌ Necesitas $" .. price .. " (Tienes: $" .. currentMoney .. ")",
					Color3.fromRGB(255, 85, 85)
				)
			end

			-- Reproducir sonido de error
			local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
			if playSoundEvent then
				playSoundEvent:FireClient(player, "Shop", "CannotAfford")
			end
		end
	end

	return false
end

--[[
    Evento: Cuando un jugador se une
--]]
Players.PlayerAdded:Connect(function(player)
	-- Cargar vehículos comprados
	local ownedVehicles = loadPlayerVehicles(player)

	-- Convertir array a tabla hash
	playerOwnedVehicles[player.UserId] = {}
	for _, vehicleName in ipairs(ownedVehicles) do
		playerOwnedVehicles[player.UserId][vehicleName] = true
	end
end)

--[[
    Evento: Cuando un jugador sale
--]]
Players.PlayerRemoving:Connect(function(player)
	savePlayerVehicles(player)
	playerOwnedVehicles[player.UserId] = nil
end)

--[[
    Evento: Cliente solicita comprar vehículo
--]]
purchaseVehicleEvent.OnServerEvent:Connect(function(player, vehicleName, price)
	purchaseVehicle(player, vehicleName, price)
end)

--[[
    Función: Cliente verifica si posee un vehículo
--]]
checkOwnershipEvent.OnServerInvoke = function(player, vehicleName)
	return ownsVehicle(player, vehicleName)
end

--[[
    Guardar datos cuando el servidor se cierra
--]]
game:BindToClose(function()
	print("💾 Guardando datos de vehículos antes de cerrar servidor...")
	for _, player in pairs(Players:GetPlayers()) do
		savePlayerVehicles(player)
	end
	task.wait(2)
end)

-- Exponer funciones globalmente
_G.VehicleOwnership = {
	OwnsVehicle = ownsVehicle,
	GrantVehicle = grantVehicle,
	PurchaseVehicle = purchaseVehicle
}

print("═══════════════════════════════════════════════════════")
print("🚗 Vehicle Ownership Manager inicializado")
print("💾 DataStore: " .. (dataStoreEnabled and "✅ HABILITADO" or "❌ DESHABILITADO"))
print("═══════════════════════════════════════════════════════")
