--[[
	GLOBAL MONEY BOOST MANAGER
	Gestiona los boosts de DINERO globales del servidor.

	CARACTERÍSTICAS:
	- Un solo boost de dinero activo por servidor
	- Afecta a TODOS los jugadores por igual
	- Sistema de temporizador visible para todos
	- Permite upgrades (x2 → x4)
	- Sincronización automática para nuevos jugadores
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Importar configuración desde ReplicatedStorage/Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GlobalMoneyBoostConfig = require(Modules:WaitForChild("GlobalMoneyBoostConfig"))

print("[GlobalMoneyBoostManager] 🚀 Inicializando sistema de boost global de dinero...")

-- ========================================
-- ESTADO GLOBAL DEL SERVIDOR
-- ========================================
local ServerMoneyBoostState = {
	ActiveBoostID = nil,        -- ID del boost activo (nil = sin boost)
	Multiplier = 1.0,           -- Multiplicador actual
	TimeRemaining = 0,          -- Tiempo restante en segundos
	StartTime = 0,              -- Timestamp cuando se activó
	PurchasedBy = nil,          -- Nombre del jugador que lo compró
}

-- ========================================
-- REMOTES
-- ========================================
-- Usar la carpeta Remotes existente (creada por GlobalBoostManager)
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
	print("[GlobalMoneyBoostManager] 📁 Carpeta 'Remotes' creada en ReplicatedStorage")
end

-- Eventos para comunicación cliente-servidor
local GlobalMoneyBoostStateChangedEvent = RemotesFolder:FindFirstChild("GlobalMoneyBoostStateChanged")
if not GlobalMoneyBoostStateChangedEvent then
	GlobalMoneyBoostStateChangedEvent = Instance.new("RemoteEvent")
	GlobalMoneyBoostStateChangedEvent.Name = "GlobalMoneyBoostStateChanged"
	GlobalMoneyBoostStateChangedEvent.Parent = RemotesFolder
	print("[GlobalMoneyBoostManager] ✅ RemoteEvent 'GlobalMoneyBoostStateChanged' creado")
end

local RequestMoneyBoostStateFunction = RemotesFolder:FindFirstChild("RequestMoneyBoostState")
if not RequestMoneyBoostStateFunction then
	RequestMoneyBoostStateFunction = Instance.new("RemoteFunction")
	RequestMoneyBoostStateFunction.Name = "RequestMoneyBoostState"
	RequestMoneyBoostStateFunction.Parent = RemotesFolder
	print("[GlobalMoneyBoostManager] ✅ RemoteFunction 'RequestMoneyBoostState' creada")
end

local PurchaseGlobalMoneyBoostEvent = RemotesFolder:FindFirstChild("PurchaseGlobalMoneyBoost")
if not PurchaseGlobalMoneyBoostEvent then
	PurchaseGlobalMoneyBoostEvent = Instance.new("RemoteEvent")
	PurchaseGlobalMoneyBoostEvent.Name = "PurchaseGlobalMoneyBoost"
	PurchaseGlobalMoneyBoostEvent.Parent = RemotesFolder
	print("[GlobalMoneyBoostManager] ✅ RemoteEvent 'PurchaseGlobalMoneyBoost' creado")
end

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene el estado actual del boost en formato serializable
local function getMoneyBoostStateData()
	local availableBoost = GlobalMoneyBoostConfig.GetAvailableBoost(ServerMoneyBoostState.ActiveBoostID)

	return {
		ActiveBoostID = ServerMoneyBoostState.ActiveBoostID,
		Multiplier = ServerMoneyBoostState.Multiplier,
		TimeRemaining = ServerMoneyBoostState.TimeRemaining,
		PurchasedBy = ServerMoneyBoostState.PurchasedBy,
		AvailableBoost = availableBoost and {
			ID = availableBoost.ID,
			Name = availableBoost.Name,
			Multiplier = availableBoost.Multiplier,
			Duration = availableBoost.Duration,
			Price = availableBoost.Price,
			ProductID = availableBoost.ProductID,
			IsUpgrade = availableBoost.UpgradeFrom ~= nil,
		} or nil
	}
end

-- Notifica a TODOS los clientes sobre el cambio de estado
local function broadcastMoneyBoostState()
	local stateData = getMoneyBoostStateData()
	GlobalMoneyBoostStateChangedEvent:FireAllClients(stateData)
	print(string.format("[GlobalMoneyBoostManager] 📢 Estado enviado a todos los clientes: Boost=%s, Mult=x%.1f, Tiempo=%ds",
		tostring(stateData.ActiveBoostID or "NINGUNO"),
		stateData.Multiplier,
		stateData.TimeRemaining
	))
end

-- Activa un boost en el servidor
local function activateMoneyBoost(boostID, purchaserName)
	local boost = GlobalMoneyBoostConfig.GetBoostByID(boostID)
	if not boost then
		warn("[GlobalMoneyBoostManager] ❌ Boost ID inválido:", boostID)
		return false
	end

	-- Actualizar estado del servidor
	ServerMoneyBoostState.ActiveBoostID = boost.ID
	ServerMoneyBoostState.Multiplier = boost.Multiplier
	ServerMoneyBoostState.TimeRemaining = boost.Duration
	ServerMoneyBoostState.StartTime = tick()
	ServerMoneyBoostState.PurchasedBy = purchaserName

	print(string.format("[GlobalMoneyBoostManager] ✅ Boost activado: %s (x%.1f) por %d segundos - Comprado por: %s",
		boost.Name,
		boost.Multiplier,
		boost.Duration,
		purchaserName
	))

	-- Notificar a todos los clientes
	broadcastMoneyBoostState()

	return true
end

-- Desactiva el boost actual
local function deactivateMoneyBoost()
	print(string.format("[GlobalMoneyBoostManager] ⏰ Boost %s ha expirado", ServerMoneyBoostState.ActiveBoostID or "DESCONOCIDO"))

	ServerMoneyBoostState.ActiveBoostID = nil
	ServerMoneyBoostState.Multiplier = 1.0
	ServerMoneyBoostState.TimeRemaining = 0
	ServerMoneyBoostState.StartTime = 0
	ServerMoneyBoostState.PurchasedBy = nil

	-- Notificar a todos los clientes
	broadcastMoneyBoostState()
end

-- ========================================
-- TEMPORIZADOR
-- ========================================

-- Actualiza el temporizador cada segundo
task.spawn(function()
	while true do
		task.wait(1)

		if ServerMoneyBoostState.ActiveBoostID then
			-- Calcular tiempo restante
			local elapsed = tick() - ServerMoneyBoostState.StartTime
			local timeLeft = math.max(0, ServerMoneyBoostState.TimeRemaining - elapsed)

			-- Actualizar estado
			ServerMoneyBoostState.TimeRemaining = timeLeft

			-- Si el tiempo se acabó, desactivar boost
			if timeLeft <= 0 then
				deactivateMoneyBoost()
			end
		end
	end
end)

-- Enviar actualización de tiempo cada 5 segundos (para no saturar)
task.spawn(function()
	while true do
		task.wait(5)

		if ServerMoneyBoostState.ActiveBoostID then
			broadcastMoneyBoostState()
		end
	end
end)

-- ========================================
-- DEV PRODUCT HANDLING
-- ========================================

-- Procesar compra de Dev Product
local function processMoneyBoostReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local boost = GlobalMoneyBoostConfig.GetBoostByProductID(productId)

	if not boost then
		-- No es un boost de dinero, dejar que otros sistemas lo manejen
		return nil
	end

	print(string.format("[GlobalMoneyBoostManager] 🎉 %s compró %s (Product ID: %d)", player.Name, boost.Name, productId))

	-- Verificar si el boost puede activarse
	local availableBoost = GlobalMoneyBoostConfig.GetAvailableBoost(ServerMoneyBoostState.ActiveBoostID)

	if not availableBoost or availableBoost.ID ~= boost.ID then
		warn(string.format("[GlobalMoneyBoostManager] ⚠️ Boost %s no está disponible en este momento", boost.Name))
		-- Aún así conceder la compra para evitar problemas
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Activar el boost
	activateMoneyBoost(boost.ID, player.Name)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Exponer función para que GlobalBoostManager la pueda llamar
_G.ProcessMoneyBoostReceipt = processMoneyBoostReceipt

-- ========================================
-- COMUNICACIÓN CON CLIENTES
-- ========================================

-- Cuando un cliente solicita el estado actual
RequestMoneyBoostStateFunction.OnServerInvoke = function(player)
	print(string.format("[GlobalMoneyBoostManager] 📥 %s solicitó estado del boost de dinero", player.Name))
	return getMoneyBoostStateData()
end

-- Cuando un cliente quiere comprar un boost
PurchaseGlobalMoneyBoostEvent.OnServerEvent:Connect(function(player, boostID)
	local boost = GlobalMoneyBoostConfig.GetBoostByID(boostID)
	if not boost then
		warn(string.format("[GlobalMoneyBoostManager] ❌ %s intentó comprar boost inválido: %s", player.Name, tostring(boostID)))
		return
	end

	-- Verificar si el boost está disponible
	local availableBoost = GlobalMoneyBoostConfig.GetAvailableBoost(ServerMoneyBoostState.ActiveBoostID)
	if not availableBoost or availableBoost.ID ~= boost.ID then
		warn(string.format("[GlobalMoneyBoostManager] ⚠️ %s intentó comprar %s pero no está disponible", player.Name, boost.Name))
		return
	end

	print(string.format("[GlobalMoneyBoostManager] 🛒 %s está comprando %s (Product ID: %d)", player.Name, boost.Name, boost.ProductID))

	-- Mostrar prompt de compra
	MarketplaceService:PromptProductPurchase(player, boost.ProductID)
end)

-- ========================================
-- SINCRONIZACIÓN DE NUEVOS JUGADORES
-- ========================================

Players.PlayerAdded:Connect(function(player)
	-- Esperar a que el jugador esté completamente cargado
	task.wait(1)

	-- Enviar estado actual del boost
	local stateData = getMoneyBoostStateData()
	GlobalMoneyBoostStateChangedEvent:FireClient(player, stateData)

	print(string.format("[GlobalMoneyBoostManager] 🔄 Estado sincronizado con %s: Boost=%s, Mult=x%.1f",
		player.Name,
		tostring(stateData.ActiveBoostID or "NINGUNO"),
		stateData.Multiplier
	))
end)

-- ========================================
-- FUNCIÓN GLOBAL PARA OTROS SISTEMAS
-- ========================================

-- Función global que otros sistemas pueden usar para obtener el multiplicador de dinero
_G.GetServerMoneyMultiplier = function()
	return ServerMoneyBoostState.Multiplier
end

print("[GlobalMoneyBoostManager] ✅ Sistema de boost global de dinero inicializado")
print(string.format("[GlobalMoneyBoostManager] 📊 Estado inicial: Boost=%s, Mult=x%.1f",
	tostring(ServerMoneyBoostState.ActiveBoostID or "NINGUNO"),
	ServerMoneyBoostState.Multiplier
))
