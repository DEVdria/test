--[[
	MONEY PACK MANAGER
	Gestiona la compra de packs de dinero mediante Dev Products.

	CARACTERÍSTICAS:
	- Procesa compras de Dev Products
	- Otorga dinero al jugador
	- Sistema de logging
	- Integración con DataManager
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Importar configuración
local Modules = ReplicatedStorage:WaitForChild("Modules")
local MoneyPackConfig = require(Modules:WaitForChild("MoneyPackConfig"))

print("[MoneyPackManager] 💰 Inicializando sistema de packs de dinero...")

-- Esperar ChatNotificationManager
local ChatNotificationManager = nil
task.spawn(function()
	repeat
		task.wait(0.5)
		ChatNotificationManager = _G.ChatNotificationManager
	until ChatNotificationManager
	print("[MoneyPackManager] ✅ ChatNotificationManager conectado")
end)

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- RemoteEvent para solicitar compra
local PurchaseMoneyPackEvent = RemotesFolder:FindFirstChild("PurchaseMoneyPack")
if not PurchaseMoneyPackEvent then
	PurchaseMoneyPackEvent = Instance.new("RemoteEvent")
	PurchaseMoneyPackEvent.Name = "PurchaseMoneyPack"
	PurchaseMoneyPackEvent.Parent = RemotesFolder
	print("[MoneyPackManager] ✅ RemoteEvent 'PurchaseMoneyPack' creado")
end

-- RemoteFunction para obtener packs disponibles
local GetMoneyPacksFunction = RemotesFolder:FindFirstChild("GetMoneyPacks")
if not GetMoneyPacksFunction then
	GetMoneyPacksFunction = Instance.new("RemoteFunction")
	GetMoneyPacksFunction.Name = "GetMoneyPacks"
	GetMoneyPacksFunction.Parent = RemotesFolder
	print("[MoneyPackManager] ✅ RemoteFunction 'GetMoneyPacks' creada")
end

-- ========================================
-- FUNCIONES
-- ========================================

-- Procesa la compra de un pack de dinero
local function processMoneyPackReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local pack = MoneyPackConfig.GetPackByProductID(productId)

	if not pack then
		-- No es un pack de dinero, dejar que otros sistemas lo manejen
		return nil
	end

	print(string.format("[MoneyPackManager] 🎉 %s compró %s (Product ID: %d)",
		player.Name, pack.Name, productId))

	-- Otorgar dinero al jugador
	if _G.DataManager and _G.DataManager.AddMoney then
		local success = _G.DataManager.AddMoney(player, pack.MoneyAmount)
		if success then
			print(string.format("[MoneyPackManager] 💰 %s recibió %s de dinero (%s)",
				player.Name,
				MoneyPackConfig.FormatNumber(pack.MoneyAmount),
				pack.Name))

			-- Notificar en el chat
			if ChatNotificationManager then
				ChatNotificationManager.NotifyPurchase(player.Name, pack.Name, pack.Price)
			end
		else
			warn(string.format("[MoneyPackManager] ❌ Error al otorgar dinero a %s", player.Name))
		end
	else
		warn("[MoneyPackManager] ❌ DataManager no disponible")
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Exponer función para que GlobalBoostManager la pueda llamar
_G.ProcessMoneyPackReceipt = processMoneyPackReceipt

-- ========================================
-- COMUNICACIÓN CON CLIENTES
-- ========================================

-- Cuando un cliente solicita comprar un pack
PurchaseMoneyPackEvent.OnServerEvent:Connect(function(player, packID)
	local pack = MoneyPackConfig.GetPackByID(packID)
	if not pack then
		warn(string.format("[MoneyPackManager] ❌ %s intentó comprar pack inválido: %s",
			player.Name, tostring(packID)))
		return
	end

	if pack.ProductID == 0 then
		warn(string.format("[MoneyPackManager] ⚠️ %s intentó comprar %s pero no tiene Product ID configurado",
			player.Name, pack.Name))
		return
	end

	print(string.format("[MoneyPackManager] 🛒 %s está comprando %s (Product ID: %d)",
		player.Name, pack.Name, pack.ProductID))

	-- Mostrar prompt de compra
	MarketplaceService:PromptProductPurchase(player, pack.ProductID)
end)

-- Cuando un cliente solicita la lista de packs
GetMoneyPacksFunction.OnServerInvoke = function(player)
	print(string.format("[MoneyPackManager] 📥 %s solicitó lista de packs", player.Name))

	-- Enviar la configuración de packs al cliente
	local packsData = {}
	for _, pack in ipairs(MoneyPackConfig.Packs) do
		table.insert(packsData, {
			ID = pack.ID,
			Name = pack.Name,
			MoneyAmount = pack.MoneyAmount,
			Price = pack.Price,
			Icon = pack.Icon,
			Description = pack.Description
		})
	end

	return packsData
end

print("[MoneyPackManager] ✅ Sistema de packs de dinero inicializado")
print(string.format("[MoneyPackManager] 📊 %d packs disponibles", #MoneyPackConfig.Packs))
