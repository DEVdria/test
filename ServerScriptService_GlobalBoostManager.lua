--[[
	GLOBAL BOOST MANAGER
	Gestiona los boosts de XP globales del servidor.

	CARACTERÍSTICAS:
	- Un solo boost activo por servidor
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
local GlobalBoostConfig = require(Modules:WaitForChild("GlobalBoostConfig"))

print("[GlobalBoostManager] 🚀 Inicializando sistema de boost global...")

-- Esperar ChatNotificationManager
local ChatNotificationManager = nil
task.spawn(function()
	repeat
		task.wait(0.5)
		ChatNotificationManager = _G.ChatNotificationManager
	until ChatNotificationManager
	print("[GlobalBoostManager] ✅ ChatNotificationManager conectado")
end)

-- ========================================
-- ESTADO GLOBAL DEL SERVIDOR
-- ========================================
local ServerBoostState = {
	ActiveBoostID = nil,        -- ID del boost activo (nil = sin boost)
	Multiplier = 1.0,           -- Multiplicador actual
	TimeRemaining = 0,          -- Tiempo restante en segundos
	StartTime = 0,              -- Timestamp cuando se activó
	PurchasedBy = nil,          -- Nombre del jugador que lo compró
}

-- ========================================
-- REMOTES
-- ========================================
-- Crear carpeta de Remotes si no existe
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
	print("[GlobalBoostManager] 📁 Carpeta 'Remotes' creada en ReplicatedStorage")
end

-- Eventos para comunicación cliente-servidor
local GlobalBoostStateChangedEvent = RemotesFolder:FindFirstChild("GlobalBoostStateChanged")
if not GlobalBoostStateChangedEvent then
	GlobalBoostStateChangedEvent = Instance.new("RemoteEvent")
	GlobalBoostStateChangedEvent.Name = "GlobalBoostStateChanged"
	GlobalBoostStateChangedEvent.Parent = RemotesFolder
	print("[GlobalBoostManager] ✅ RemoteEvent 'GlobalBoostStateChanged' creado")
end

local RequestBoostStateFunction = RemotesFolder:FindFirstChild("RequestBoostState")
if not RequestBoostStateFunction then
	RequestBoostStateFunction = Instance.new("RemoteFunction")
	RequestBoostStateFunction.Name = "RequestBoostState"
	RequestBoostStateFunction.Parent = RemotesFolder
	print("[GlobalBoostManager] ✅ RemoteFunction 'RequestBoostState' creada")
end

local PurchaseGlobalBoostEvent = RemotesFolder:FindFirstChild("PurchaseGlobalBoost")
if not PurchaseGlobalBoostEvent then
	PurchaseGlobalBoostEvent = Instance.new("RemoteEvent")
	PurchaseGlobalBoostEvent.Name = "PurchaseGlobalBoost"
	PurchaseGlobalBoostEvent.Parent = RemotesFolder
	print("[GlobalBoostManager] ✅ RemoteEvent 'PurchaseGlobalBoost' creado")
end

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene el estado actual del boost en formato serializable
local function getBoostStateData()
	local availableBoost = GlobalBoostConfig.GetAvailableBoost(ServerBoostState.ActiveBoostID)

	return {
		ActiveBoostID = ServerBoostState.ActiveBoostID,
		Multiplier = ServerBoostState.Multiplier,
		TimeRemaining = ServerBoostState.TimeRemaining,
		PurchasedBy = ServerBoostState.PurchasedBy,
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
local function broadcastBoostState()
	local stateData = getBoostStateData()
	GlobalBoostStateChangedEvent:FireAllClients(stateData)
	print(string.format("[GlobalBoostManager] 📢 Estado enviado a todos los clientes: Boost=%s, Mult=x%.1f, Tiempo=%ds",
		tostring(stateData.ActiveBoostID or "NINGUNO"),
		stateData.Multiplier,
		stateData.TimeRemaining
	))
end

-- Activa un boost en el servidor
local function activateBoost(boostID, purchaserName)
	local boost = GlobalBoostConfig.GetBoostByID(boostID)
	if not boost then
		warn("[GlobalBoostManager] ❌ Boost ID inválido:", boostID)
		return false
	end

	-- Actualizar estado del servidor
	ServerBoostState.ActiveBoostID = boost.ID
	ServerBoostState.Multiplier = boost.Multiplier
	ServerBoostState.TimeRemaining = boost.Duration
	ServerBoostState.StartTime = tick()
	ServerBoostState.PurchasedBy = purchaserName

	print(string.format("[GlobalBoostManager] ✅ Boost activado: %s (x%.1f) por %d segundos - Comprado por: %s",
		boost.Name,
		boost.Multiplier,
		boost.Duration,
		purchaserName
	))

	-- Notificar en el chat
	if ChatNotificationManager then
		ChatNotificationManager.NotifyPurchase(purchaserName, boost.Name, boost.Price)
	end

	-- Notificar a todos los clientes
	broadcastBoostState()

	return true
end

-- Desactiva el boost actual
local function deactivateBoost()
	print(string.format("[GlobalBoostManager] ⏰ Boost %s ha expirado", ServerBoostState.ActiveBoostID or "DESCONOCIDO"))

	ServerBoostState.ActiveBoostID = nil
	ServerBoostState.Multiplier = 1.0
	ServerBoostState.TimeRemaining = 0
	ServerBoostState.StartTime = 0
	ServerBoostState.PurchasedBy = nil

	-- Notificar a todos los clientes
	broadcastBoostState()
end

-- ========================================
-- TEMPORIZADOR
-- ========================================

-- Actualiza el temporizador cada segundo
task.spawn(function()
	while true do
		task.wait(1)

		if ServerBoostState.ActiveBoostID then
			-- Calcular tiempo restante
			local elapsed = tick() - ServerBoostState.StartTime
			local timeLeft = math.max(0, ServerBoostState.TimeRemaining - elapsed)

			-- Actualizar estado
			ServerBoostState.TimeRemaining = timeLeft

			-- Si el tiempo se acabó, desactivar boost
			if timeLeft <= 0 then
				deactivateBoost()
			end
		end
	end
end)

-- Enviar actualización de tiempo cada 5 segundos (para no saturar)
task.spawn(function()
	while true do
		task.wait(5)

		if ServerBoostState.ActiveBoostID then
			broadcastBoostState()
		end
	end
end)

-- ========================================
-- DEV PRODUCT HANDLING
-- ========================================

-- Procesar compra de Dev Product
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId

	-- Intentar procesar como boost de XP
	local boost = GlobalBoostConfig.GetBoostByProductID(productId)

	if not boost then
		-- No es un boost de XP, intentar como boost de dinero
		if _G.ProcessMoneyBoostReceipt then
			local moneyBoostResult = _G.ProcessMoneyBoostReceipt(receiptInfo)
			if moneyBoostResult then
				return moneyBoostResult
			end
		end

		-- No es boost de dinero, intentar como pack de dinero
		if _G.ProcessMoneyPackReceipt then
			local moneyPackResult = _G.ProcessMoneyPackReceipt(receiptInfo)
			if moneyPackResult then
				return moneyPackResult
			end
		end

		-- No es ni XP boost, ni MONEY boost, ni MONEY pack
		warn(string.format("[GlobalBoostManager] ❌ Product ID %d no reconocido", productId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Es un boost de XP, procesarlo
	print(string.format("[GlobalBoostManager] 🎉 %s compró %s (Product ID: %d)", player.Name, boost.Name, productId))

	-- Verificar si el boost puede activarse
	local availableBoost = GlobalBoostConfig.GetAvailableBoost(ServerBoostState.ActiveBoostID)

	if not availableBoost or availableBoost.ID ~= boost.ID then
		warn(string.format("[GlobalBoostManager] ⚠️ Boost %s no está disponible en este momento", boost.Name))
		-- Aún así conceder la compra para evitar problemas
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Activar el boost
	activateBoost(boost.ID, player.Name)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Conectar callback de procesamiento
MarketplaceService.ProcessReceipt = processReceipt

-- ========================================
-- COMUNICACIÓN CON CLIENTES
-- ========================================

-- Cuando un cliente solicita el estado actual
RequestBoostStateFunction.OnServerInvoke = function(player)
	print(string.format("[GlobalBoostManager] 📥 %s solicitó estado del boost", player.Name))
	return getBoostStateData()
end

-- Cuando un cliente quiere comprar un boost
PurchaseGlobalBoostEvent.OnServerEvent:Connect(function(player, boostID)
	local boost = GlobalBoostConfig.GetBoostByID(boostID)
	if not boost then
		warn(string.format("[GlobalBoostManager] ❌ %s intentó comprar boost inválido: %s", player.Name, tostring(boostID)))
		return
	end

	-- Verificar si el boost está disponible
	local availableBoost = GlobalBoostConfig.GetAvailableBoost(ServerBoostState.ActiveBoostID)
	if not availableBoost or availableBoost.ID ~= boost.ID then
		warn(string.format("[GlobalBoostManager] ⚠️ %s intentó comprar %s pero no está disponible", player.Name, boost.Name))
		return
	end

	print(string.format("[GlobalBoostManager] 🛒 %s está comprando %s (Product ID: %d)", player.Name, boost.Name, boost.ProductID))

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
	local stateData = getBoostStateData()
	GlobalBoostStateChangedEvent:FireClient(player, stateData)

	print(string.format("[GlobalBoostManager] 🔄 Estado sincronizado con %s: Boost=%s, Mult=x%.1f",
		player.Name,
		tostring(stateData.ActiveBoostID or "NINGUNO"),
		stateData.Multiplier
	))
end)

-- ========================================
-- FUNCIÓN GLOBAL PARA OTROS SISTEMAS
-- ========================================

-- Función global que otros sistemas pueden usar para obtener el multiplicador
_G.GetServerXPMultiplier = function()
	return ServerBoostState.Multiplier
end

print("[GlobalBoostManager] ✅ Sistema de boost global inicializado")
print(string.format("[GlobalBoostManager] 📊 Estado inicial: Boost=%s, Mult=x%.1f",
	tostring(ServerBoostState.ActiveBoostID or "NINGUNO"),
	ServerBoostState.Multiplier
))
