-- ServerScriptService > ZoneManager
-- Gestiona el sistema de compra de zonas
-- NOTA: Este es un Script normal, NO ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Esperar a que los módulos estén disponibles
print("[ZoneManager] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[ZoneManager] ❌ No se encontró carpeta Modules")
	return
end

local ZoneConfig = require(Modules:WaitForChild("ZoneConfig", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[ZoneManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

-- RemoteEvents para zonas (crear estos en ReplicatedStorage/RemoteEvents)
local RequestZonePurchaseEvent = RemoteEvents:WaitForChild("RequestZonePurchase", 10)
local UpdateZoneOwnershipEvent = RemoteEvents:FindFirstChild("UpdateZoneOwnership")

-- Esperar DataManager (se carga a través de _G)
local DataManager
local maxWait = 10
local waited = 0
repeat
	task.wait(0.5)
	waited = waited + 0.5
	DataManager = _G.DataManager
until DataManager or waited >= maxWait

if not DataManager then
	warn("[ZoneManager] ❌ No se pudo acceder a DataManager")
	return
end

-- ==================== FUNCIONES ====================

-- Verifica si un jugador posee una zona
local function playerOwnsZone(player, zoneID)
	local playerData = DataManager.GetData(player)
	if not playerData or not playerData.OwnedZones then
		return false
	end

	for _, ownedZone in ipairs(playerData.OwnedZones) do
		if ownedZone == zoneID then
			return true
		end
	end

	return false
end

-- Procesa la compra de una zona
local function processZonePurchase(player, zoneID)
	-- Validaciones de seguridad
	if not player or not player:IsDescendantOf(Players) then
		return {Success = false, Message = "Jugador inválido"}
	end

	if not ZoneConfig.IsValidZone(zoneID) then
		return {Success = false, Message = "Zona no encontrada"}
	end

	-- Obtener datos del jugador
	local playerData = DataManager.GetData(player)
	if not playerData then
		return {Success = false, Message = "Error al cargar datos"}
	end

	-- Verificar si ya posee la zona
	if playerOwnsZone(player, zoneID) then
		return {Success = false, Message = "Ya posees esta zona"}
	end

	-- Obtener configuración de la zona
	local zone = ZoneConfig.GetZone(zoneID)

	-- Verificar requisitos
	local canPurchase, reason = ZoneConfig.CanPurchaseZone(
		zoneID,
		playerData.Money,
		playerData.Rebirths,
		playerData.Level
	)

	if not canPurchase then
		return {Success = false, Message = reason}
	end

	-- Procesar compra
	local success = DataManager.PurchaseZone(player, zoneID, zone.Price)

	if success then
		-- Notificar al cliente sobre la actualización
		if UpdateZoneOwnershipEvent then
			UpdateZoneOwnershipEvent:FireClient(player, zoneID, true)
		end

		-- Guardar datos inmediatamente
		task.spawn(function()
			DataManager.SaveData(player)
		end)

		print(string.format("[ZoneManager] %s compró la zona %s por $%d", player.Name, zoneID, zone.Price))

		return {
			Success = true,
			Message = string.format("¡Zona %s desbloqueada!", zone.Name),
			ZoneID = zoneID,
			RemainingMoney = playerData.Money - zone.Price
		}
	else
		return {Success = false, Message = "Error al procesar la compra"}
	end
end

-- Obtiene la lista de zonas que posee un jugador
local function getPlayerZones(player)
	local playerData = DataManager.GetData(player)
	if not playerData or not playerData.OwnedZones then
		return ZoneConfig.GetDefaultZones()
	end

	return playerData.OwnedZones
end

-- ==================== EVENTOS ====================

-- Escuchar solicitudes de compra de zona
if RequestZonePurchaseEvent then
	RequestZonePurchaseEvent.OnServerEvent:Connect(function(player, zoneID)
		local result = processZonePurchase(player, zoneID)
		RequestZonePurchaseEvent:FireClient(player, result)
	end)
end

-- Cuando un jugador se une, enviarle sus zonas
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que DataManager cargue los datos y cree leaderstats
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn(string.format("[ZoneManager] ⚠️ No se encontraron leaderstats para %s", player.Name))
	end

	-- Pequeño delay adicional para asegurar que el cliente esté listo
	task.wait(0.5)

	local ownedZones = getPlayerZones(player)

	-- Notificar al cliente sobre sus zonas
	if UpdateZoneOwnershipEvent then
		print(string.format("[ZoneManager] 📤 Enviando %d zonas a %s...", #ownedZones, player.Name))
		for _, zoneID in ipairs(ownedZones) do
			UpdateZoneOwnershipEvent:FireClient(player, zoneID, true)
			task.wait(0.05)  -- Pequeño delay entre envíos para evitar saturación
		end
		print(string.format("[ZoneManager] ✅ Zonas enviadas a %s", player.Name))
	end
end)

print("[ZoneManager] ✅ Sistema de zonas inicializado")
