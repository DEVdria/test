-- ServerScriptService > RebirthManager
-- Gestiona el sistema de rebirths (renacimientos)
-- NOTA: Este es un Script normal, NO ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
print("[RebirthManager] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[RebirthManager] ❌ No se encontró carpeta Modules")
	return
end

local LevelManager = require(Modules:WaitForChild("LevelManager", 10))
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig", 10))
local RebirthConfig = require(Modules:WaitForChild("RebirthConfig", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[RebirthManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase")
local UpdateZoneOwnershipEvent = RemoteEvents:FindFirstChild("UpdateZoneOwnership")  -- Para resetear zonas

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
	warn("[RebirthManager] ❌ No se pudo acceder a DataManager")
	return
end

-- Caché de cooldowns para prevenir spam de compras
local purchaseCooldowns = {}
local PURCHASE_COOLDOWN = 2 -- 2 segundos entre compras

-- Verifica si un jugador puede comprar (anti-spam)
local function canPurchase(player)
	local userId = player.UserId
	local lastPurchase = purchaseCooldowns[userId]

	if lastPurchase then
		local elapsed = tick() - lastPurchase
		if elapsed < PURCHASE_COOLDOWN then
			return false
		end
	end

	return true
end

-- Procesa una solicitud de rebirth
local function processRebirthPurchase(player)
	print(string.format("[RebirthManager] 🔄 Procesando rebirth para %s", player.Name))

	-- Validaciones de seguridad
	if not player or not player:IsDescendantOf(game.Players) then
		warn("[RebirthManager] ❌ Jugador inválido")
		return {Success = false, Message = "Jugador inválido"}
	end

	if not canPurchase(player) then
		print(string.format("[RebirthManager] ⏳ %s en cooldown", player.Name))
		return {Success = false, Message = "Espera antes de comprar otro rebirth"}
	end

	-- Actualizar cooldown
	purchaseCooldowns[player.UserId] = tick()

	-- Obtener datos del jugador
	local playerData = DataManager.GetData(player)
	if not playerData then
		warn(string.format("[RebirthManager] ❌ No se pudo obtener datos de %s", player.Name))
		return {Success = false, Message = "Error al cargar datos"}
	end

	print(string.format("[RebirthManager] 📊 Datos obtenidos: Money=%d, Rebirths=%d", playerData.Money, playerData.Rebirths))

	-- Calcular costo, nuevo multiplicador y level caps
	local currentRebirths = playerData.Rebirths
	local cost = RebirthConfig.GetRebirthCost(currentRebirths)
	local newMultiplier = RebirthConfig.GetEXPMultiplier(currentRebirths + 1)
	local currentMaxLevel = LevelManager.GetMaxLevel(currentRebirths)
	local nextMaxLevel = LevelManager.GetMaxLevel(currentRebirths + 1)

	print(string.format("[RebirthManager] 💰 Costo del rebirth: %d", cost))

	-- Verificar si tiene suficiente dinero
	if playerData.Money < cost then
		print(string.format("[RebirthManager] ❌ %s no tiene suficiente dinero", player.Name))
		return {
			Success = false,
			Message = string.format("Necesitas $%s (Tienes: $%s)",
				tostring(cost), tostring(playerData.Money))
		}
	end

	-- Procesar el rebirth
	print(string.format("[RebirthManager] ⚙️ Llamando a DataManager.ProcessRebirth..."))
	local pcallSuccess, rebirthSuccess, rebirthMessage = pcall(function()
		return DataManager.ProcessRebirth(player)
	end)

	if not pcallSuccess then
		warn(string.format("[RebirthManager] ❌ Error crítico en ProcessRebirth: %s", tostring(rebirthSuccess)))
		return {Success = false, Message = "Error al procesar rebirth"}
	end

	print(string.format("[RebirthManager] 📋 ProcessRebirth resultado: success=%s, message=%s", tostring(rebirthSuccess), tostring(rebirthMessage)))

	if rebirthSuccess then
		-- Resetear zonas en el cliente
		if UpdateZoneOwnershipEvent then
			-- Primero, limpiar todas las zonas (enviar señal de reset)
			UpdateZoneOwnershipEvent:FireClient(player, "RESET_ALL", false)

			-- Luego enviar las zonas default
			local defaultZones = ZoneConfig.GetDefaultZones()
			for _, zoneID in ipairs(defaultZones) do
				UpdateZoneOwnershipEvent:FireClient(player, zoneID, true)
			end
		end

		-- Teletransportar al jugador a spawn (0, 2, 0)
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				-- Teletransportar a las coordenadas de spawn
				humanoidRootPart.CFrame = CFrame.new(0, 2, 0)
				print(string.format("[RebirthManager] %s teletransportado a spawn (0, 2, 0)", player.Name))
			end
		end

		-- Guardar datos inmediatamente
		task.spawn(function()
			DataManager.SaveData(player)
		end)

		return {
			Success = true,
			Message = string.format("¡Rebirth exitoso! Nivel máximo: %d → %d", currentMaxLevel, nextMaxLevel),
			NewRebirths = currentRebirths + 1,
			NewMultiplier = newMultiplier,
			CurrentMaxLevel = currentMaxLevel,
			NextMaxLevel = nextMaxLevel,
			RemainingMoney = playerData.Money - cost
		}
	else
		return {
			Success = false,
			Message = message or "Error desconocido"
		}
	end
end

-- Limpia cooldowns de jugadores que se van
local function cleanupCooldowns(player)
	purchaseCooldowns[player.UserId] = nil
end

-- Inicializar automáticamente
print("[RebirthManager] Inicializando...")

-- Escuchar solicitudes de compra de rebirth
RequestRebirthPurchaseEvent.OnServerEvent:Connect(function(player)
	print(string.format("[RebirthManager] 📨 Recibida solicitud de rebirth de %s", player.Name))
	local result = processRebirthPurchase(player)
	print(string.format("[RebirthManager] 📤 Enviando resultado al cliente: Success=%s, Message=%s", tostring(result.Success), tostring(result.Message)))
	-- Devolver resultado al cliente
	RequestRebirthPurchaseEvent:FireClient(player, result)
	print(string.format("[RebirthManager] ✅ Resultado enviado a %s", player.Name))
end)

-- Limpiar cooldowns al salir
game.Players.PlayerRemoving:Connect(cleanupCooldowns)

print("[RebirthManager] ✅ Sistema de rebirths inicializado")
