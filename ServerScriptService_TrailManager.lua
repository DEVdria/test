-- ServerScriptService > TrailManager (Script)
-- Gestiona la compra y equipamiento de trails para jugadores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar módulos y eventos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TrailConfig = require(Modules:WaitForChild("TrailConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestTrailPurchaseEvent = RemoteEvents:WaitForChild("RequestTrailPurchase")
local EquipTrailEvent = RemoteEvents:WaitForChild("EquipTrail")
local GetTrailDataEvent = RemoteEvents:WaitForChild("GetTrailData")

-- Esperar a que DataManager esté disponible
repeat task.wait(0.1) until _G.DataManager
local DataManager = _G.DataManager

print("[TrailManager] ✅ Sistema de trails inicializado")

-- ==================== FUNCIONES DE UTILIDAD ====================

-- Obtiene los datos de trail de un jugador
local function getPlayerTrailData(player)
	local data = DataManager.GetData(player)
	if not data then return nil end

	-- Inicializar datos de trail si no existen
	if not data.OwnedTrails then
		local defaultTrail = TrailConfig.GetDefaultTrail()
		data.OwnedTrails = {defaultTrail.ID}  -- Todos empiezan con la trail por defecto
		data.EquippedTrail = defaultTrail.ID
	end

	if not data.EquippedTrail then
		local defaultTrail = TrailConfig.GetDefaultTrail()
		data.EquippedTrail = defaultTrail.ID
	end

	return {
		OwnedTrails = data.OwnedTrails,
		EquippedTrail = data.EquippedTrail
	}
end

-- Verifica si el jugador posee una trail
local function ownsTrail(player, trailID)
	local data = DataManager.GetData(player)
	if not data or not data.OwnedTrails then return false end

	for _, ownedID in ipairs(data.OwnedTrails) do
		if ownedID == trailID then
			return true
		end
	end

	return false
end

-- ==================== EVENTOS ====================

-- Manejar solicitud de compra de trail
RequestTrailPurchaseEvent.OnServerEvent:Connect(function(player, trailID)
	print(string.format("[TrailManager] 🛒 %s intenta comprar trail: %s", player.Name, trailID))

	-- Verificar que la trail existe
	local trail = TrailConfig.GetTrail(trailID)
	if not trail then
		warn(string.format("[TrailManager] ⚠️ Trail no encontrada: %s", trailID))
		RequestTrailPurchaseEvent:FireClient(player, {
			Success = false,
			Message = "Trail no encontrada"
		})
		return
	end

	-- Verificar si ya posee la trail
	if ownsTrail(player, trailID) then
		print(string.format("[TrailManager] ⚠️ %s ya posee la trail: %s", player.Name, trailID))
		RequestTrailPurchaseEvent:FireClient(player, {
			Success = false,
			Message = "Ya posees esta trail"
		})
		return
	end

	-- Verificar si es la trail por defecto (gratis)
	if trail.IsDefault then
		local data = DataManager.GetData(player)
		if not table.find(data.OwnedTrails, trailID) then
			table.insert(data.OwnedTrails, trailID)
		end

		RequestTrailPurchaseEvent:FireClient(player, {
			Success = true,
			Message = string.format("Trail '%s' obtenida gratis", trail.Name),
			TrailID = trailID
		})

		print(string.format("[TrailManager] ✅ %s obtuvo trail gratis: %s", player.Name, trail.Name))
		return
	end

	-- Verificar requisitos
	local meetsReqs, errorMsg = TrailConfig.MeetsRequirements(player, trailID)
	if not meetsReqs then
		RequestTrailPurchaseEvent:FireClient(player, {
			Success = false,
			Message = errorMsg or "No cumples los requisitos"
		})
		return
	end

	-- Verificar que tiene suficientes Stars (Money)
	local data = DataManager.GetData(player)
	if not data then
		RequestTrailPurchaseEvent:FireClient(player, {
			Success = false,
			Message = "Error al cargar datos"
		})
		return
	end

	if data.Money < trail.Price then
		RequestTrailPurchaseEvent:FireClient(player, {
			Success = false,
			Message = string.format("Necesitas %d Stars (tienes %d)", trail.Price, data.Money)
		})
		return
	end

	-- PROCESAR COMPRA
	data.Money = data.Money - trail.Price
	table.insert(data.OwnedTrails, trailID)

	-- Actualizar leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyValue = leaderstats:FindFirstChild("Money")
		if moneyValue then
			moneyValue.Value = data.Money
		end
	end

	-- Confirmar compra
	RequestTrailPurchaseEvent:FireClient(player, {
		Success = true,
		Message = string.format("Trail '%s' comprada por %d Stars", trail.Name, trail.Price),
		TrailID = trailID
	})

	print(string.format("[TrailManager] ✅ %s compró trail '%s' por %d Stars", player.Name, trail.Name, trail.Price))
end)

-- Manejar equipamiento de trail
EquipTrailEvent.OnServerEvent:Connect(function(player, trailID)
	print(string.format("[TrailManager] 👕 %s quiere equipar trail: %s", player.Name, trailID))

	-- Verificar que la trail existe
	local trail = TrailConfig.GetTrail(trailID)
	if not trail then
		warn(string.format("[TrailManager] ⚠️ Trail no encontrada: %s", trailID))
		EquipTrailEvent:FireClient(player, {
			Success = false,
			Message = "Trail no encontrada"
		})
		return
	end

	-- Verificar que posee la trail
	if not ownsTrail(player, trailID) then
		EquipTrailEvent:FireClient(player, {
			Success = false,
			Message = "No posees esta trail"
		})
		return
	end

	-- Equipar trail
	local data = DataManager.GetData(player)
	if not data then
		EquipTrailEvent:FireClient(player, {
			Success = false,
			Message = "Error al cargar datos"
		})
		return
	end

	data.EquippedTrail = trailID

	-- Confirmar equipamiento
	EquipTrailEvent:FireClient(player, {
		Success = true,
		Message = string.format("Trail '%s' equipada", trail.Name),
		TrailID = trailID
	})

	print(string.format("[TrailManager] ✅ %s equipó trail: %s", player.Name, trail.Name))
end)

-- Manejar solicitud de datos de trail
GetTrailDataEvent.OnServerInvoke = function(player)
	local trailData = getPlayerTrailData(player)
	return trailData
end

-- ==================== INICIALIZACIÓN DE JUGADORES ====================

-- Cuando un jugador se une, inicializar sus datos de trail
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que DataManager cargue los datos
	task.wait(1)

	-- Inicializar datos de trail si es necesario
	local trailData = getPlayerTrailData(player)

	print(string.format("[TrailManager] 👤 Datos de trail cargados para %s - Trails: %d, Equipada: %s",
		player.Name,
		#trailData.OwnedTrails,
		trailData.EquippedTrail
	))
end)
