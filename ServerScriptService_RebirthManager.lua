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

local OrbConfig = require(Modules:WaitForChild("OrbConfig", 10))
local LevelManager = require(Modules:WaitForChild("LevelManager", 10))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[RebirthManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase")

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
	-- Validaciones de seguridad
	if not player or not player:IsDescendantOf(game.Players) then
		return {Success = false, Message = "Jugador inválido"}
	end

	if not canPurchase(player) then
		return {Success = false, Message = "Espera antes de comprar otro rebirth"}
	end

	-- Actualizar cooldown
	purchaseCooldowns[player.UserId] = tick()

	-- Obtener datos del jugador
	local playerData = DataManager.GetData(player)
	if not playerData then
		return {Success = false, Message = "Error al cargar datos"}
	end

	-- Calcular costo, nuevo multiplicador y level caps
	local currentRebirths = playerData.Rebirths
	local cost = OrbConfig.CalculateRebirthCost(currentRebirths)
	local newMultiplier = OrbConfig.CalculateEXPMultiplier(currentRebirths + 1)
	local currentMaxLevel = LevelManager.GetMaxLevel(currentRebirths)
	local nextMaxLevel = LevelManager.GetMaxLevel(currentRebirths + 1)

	-- Verificar si tiene suficiente dinero
	if playerData.Money < cost then
		return {
			Success = false,
			Message = string.format("Necesitas $%s (Tienes: $%s)",
				tostring(cost), tostring(playerData.Money))
		}
	end

	-- Procesar el rebirth
	local success, message = DataManager.ProcessRebirth(player)

	if success then
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
	local result = processRebirthPurchase(player)
	-- Devolver resultado al cliente
	RequestRebirthPurchaseEvent:FireClient(player, result)
end)

-- Limpiar cooldowns al salir
game.Players.PlayerRemoving:Connect(cleanupCooldowns)

print("[RebirthManager] ✅ Sistema de rebirths inicializado")
