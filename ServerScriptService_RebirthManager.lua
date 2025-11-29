-- ServerScriptService > RebirthManager
-- Gestiona el sistema de rebirths (renacimientos)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
local OrbConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase")
local UpdateSpeedDisplayEvent = RemoteEvents:WaitForChild("UpdateSpeedDisplay")

local RebirthManager = {}

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
function RebirthManager.ProcessRebirthPurchase(player)
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

	-- Calcular costo y nuevo multiplicador
	local currentRebirths = playerData.Rebirths
	local cost = OrbConfig.CalculateRebirthCost(currentRebirths)
	local newMultiplier = OrbConfig.CalculateSpeedMultiplier(currentRebirths + 1)

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
		-- Actualizar display de velocidad (resetear a 0)
		UpdateSpeedDisplayEvent:FireClient(player, 0)

		-- Guardar datos inmediatamente
		task.spawn(function()
			DataManager.SaveData(player)
		end)

		return {
			Success = true,
			Message = string.format("Rebirth exitoso! Nuevo multiplicador: x%.2f", newMultiplier),
			NewRebirths = currentRebirths + 1,
			NewMultiplier = newMultiplier,
			RemainingMoney = playerData.Money - cost
		}
	else
		return {
			Success = false,
			Message = message or "Error desconocido"
		}
	end
end

-- Obtiene información de rebirth para un jugador (para mostrar en GUI)
function RebirthManager.GetRebirthInfo(player)
	local playerData = DataManager.GetData(player)
	if not playerData then
		return nil
	end

	local currentRebirths = playerData.Rebirths
	local cost = OrbConfig.CalculateRebirthCost(currentRebirths)
	local currentMultiplier = OrbConfig.CalculateSpeedMultiplier(currentRebirths)
	local nextMultiplier = OrbConfig.CalculateSpeedMultiplier(currentRebirths + 1)

	return {
		CurrentRebirths = currentRebirths,
		Cost = cost,
		CurrentMultiplier = currentMultiplier,
		NextMultiplier = nextMultiplier,
		CanAfford = playerData.Money >= cost
	}
end

-- Limpia cooldowns de jugadores que se van
local function cleanupCooldowns(player)
	purchaseCooldowns[player.UserId] = nil
end

-- Inicializa el sistema de rebirths
function RebirthManager.Initialize()
	-- Escuchar solicitudes de compra de rebirth
	RequestRebirthPurchaseEvent.OnServerEvent:Connect(function(player)
		local result = RebirthManager.ProcessRebirthPurchase(player)
		-- Devolver resultado al cliente
		RequestRebirthPurchaseEvent:FireClient(player, result)
	end)

	-- Limpiar cooldowns al salir
	game.Players.PlayerRemoving:Connect(cleanupCooldowns)
end

return RebirthManager
