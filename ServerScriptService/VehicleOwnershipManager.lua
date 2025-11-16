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

-- Tabla en memoria: [UserId] = {VehicleName1 = true, VehicleName2 = true, ...}
-- NO se guarda en DataStore - las compras son solo para la sesión actual
local playerOwnedVehicles = {}

print("⚠️ NOTA: Las compras de vehículos NO son permanentes")
print("⚠️ Los jugadores pueden comprar vehículos múltiples veces")

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
    NOTA: No hay funciones de carga/guardado porque las compras
    son temporales (solo duran la sesión actual)
--]]

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

	print("✅ " .. player.Name .. " desbloqueó temporalmente: " .. vehicleName)
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
	print("💰 Procesando compra para " .. player.Name)

	-- Verificar que tenga suficiente dinero
	if _G.MoneyManager then
		print("✅ MoneyManager encontrado")
		local currentMoney = _G.MoneyManager.GetMoney(player)
		print("💵 Dinero actual: $" .. currentMoney .. " (Necesita: $" .. price .. ")")

		if currentMoney >= price then
			print("✅ Tiene suficiente dinero, removiendo...")
			-- Remover dinero
			local success = _G.MoneyManager.RemoveMoney(player, price)
			print("💸 Resultado de RemoveMoney: " .. tostring(success))

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
		else
			print("❌ No tiene suficiente dinero")
		end
	else
		warn("❌ ERROR: MoneyManager NO está disponible!")
		warn("⚠️ Asegúrate de que MoneyManager.lua esté en ServerScriptService")
	end

	return false
end

--[[
    Evento: Cuando un jugador se une
--]]
Players.PlayerAdded:Connect(function(player)
	-- Inicializar tabla vacía (sin vehículos comprados)
	playerOwnedVehicles[player.UserId] = {}
	print("📝 " .. player.Name .. " se unió sin vehículos desbloqueados")
end)

--[[
    Evento: Cuando un jugador sale
--]]
Players.PlayerRemoving:Connect(function(player)
	-- Limpiar de memoria (sin guardar)
	playerOwnedVehicles[player.UserId] = nil
	print("👋 " .. player.Name .. " salió - vehículos desbloqueados eliminados")
end)

--[[
    Evento: Cliente solicita comprar vehículo
--]]
purchaseVehicleEvent.OnServerEvent:Connect(function(player, vehicleName, price)
	print("🔔 Solicitud de compra recibida:")
	print("   Jugador: " .. player.Name)
	print("   Vehículo: " .. tostring(vehicleName))
	print("   Precio: $" .. tostring(price))

	purchaseVehicle(player, vehicleName, price)
end)

--[[
    Función: Cliente verifica si posee un vehículo
--]]
checkOwnershipEvent.OnServerInvoke = function(player, vehicleName)
	return ownsVehicle(player, vehicleName)
end

-- Exponer funciones globalmente
_G.VehicleOwnership = {
	OwnsVehicle = ownsVehicle,
	GrantVehicle = grantVehicle,
	PurchaseVehicle = purchaseVehicle
}

print("═══════════════════════════════════════════════════════")
print("🚗 Vehicle Ownership Manager inicializado")
print("⚠️  MODO: Compras temporales (solo por sesión)")
print("💰 Los jugadores pueden comprar vehículos múltiples veces")
print("═══════════════════════════════════════════════════════")
