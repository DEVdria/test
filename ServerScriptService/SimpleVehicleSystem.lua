--[[
═══════════════════════════════════════════════════════════════
    SIMPLE VEHICLE SYSTEM - Sistema Simple de Vehículos
    Ubicación: ServerScriptService

    Funcionalidad:
    - Gestiona compras de vehículos (temporales por sesión)
    - Sistema simple sin DataStore
    - Los jugadores pagan y pueden usar el vehículo hasta que salgan
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tabla de jugadores que han comprado vehículos (solo en sesión)
-- Formato: playerOwnedVehicles[UserId] = {Helicopter = true, Carro = true}
local playerOwnedVehicles = {}

print("🚗 Simple Vehicle System iniciando...")

-- Crear RemoteEvent para compras
local buyVehicleEvent = ReplicatedStorage:FindFirstChild("BuyVehicle")
if not buyVehicleEvent then
	buyVehicleEvent = Instance.new("RemoteEvent")
	buyVehicleEvent.Name = "BuyVehicle"
	buyVehicleEvent.Parent = ReplicatedStorage
end

--[[
    Función: Verificar si un jugador posee un vehículo
]]
local function ownsVehicle(player, vehicleName)
	if not playerOwnedVehicles[player.UserId] then
		return false
	end
	return playerOwnedVehicles[player.UserId][vehicleName] == true
end

--[[
    Función: Comprar un vehículo
]]
local function buyVehicle(player, vehicleName, price)
	print("💰 " .. player.Name .. " intenta comprar " .. vehicleName .. " por $" .. price)

	-- Verificar MoneyManager
	if not _G.MoneyManager then
		warn("❌ MoneyManager no disponible")
		return false
	end

	local currentMoney = _G.MoneyManager.GetMoney(player)
	print("   💵 Dinero actual: $" .. currentMoney)

	if currentMoney >= price then
		-- Remover dinero
		local success = _G.MoneyManager.RemoveMoney(player, price)

		if success then
			-- Dar acceso al vehículo
			if not playerOwnedVehicles[player.UserId] then
				playerOwnedVehicles[player.UserId] = {}
			end
			playerOwnedVehicles[player.UserId][vehicleName] = true

			print("✅ " .. player.Name .. " compró " .. vehicleName)

			-- Notificación
			local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
			if notificationEvent then
				notificationEvent:FireClient(
					player,
					"🚁 ¡Compraste " .. vehicleName .. "!",
					Color3.fromRGB(85, 255, 127)
				)
			end

			-- Sonido
			local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
			if playSoundEvent then
				playSoundEvent:FireClient(player, "Shop", "Purchase")
			end

			return true
		end
	else
		-- No tiene dinero
		print("❌ " .. player.Name .. " no tiene suficiente dinero")

		local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
		if notificationEvent then
			notificationEvent:FireClient(
				player,
				"❌ Necesitas $" .. price .. " (Tienes: $" .. currentMoney .. ")",
				Color3.fromRGB(255, 85, 85)
			)
		end

		local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
		if playSoundEvent then
			playSoundEvent:FireClient(player, "Shop", "CannotAfford")
		end
	end

	return false
end

-- Eventos de jugadores
Players.PlayerAdded:Connect(function(player)
	playerOwnedVehicles[player.UserId] = {}
	print("📝 " .. player.Name .. " se unió (sin vehículos)")
end)

Players.PlayerRemoving:Connect(function(player)
	playerOwnedVehicles[player.UserId] = nil
	print("👋 " .. player.Name .. " salió (vehículos borrados)")
end)

-- Evento de compra desde cliente
buyVehicleEvent.OnServerEvent:Connect(function(player, vehicleName, price)
	buyVehicle(player, vehicleName, price)
end)

-- Exponer funciones globalmente
_G.SimpleVehicleSystem = {
	OwnsVehicle = ownsVehicle,
	BuyVehicle = buyVehicle
}

print("✅ Simple Vehicle System cargado")
