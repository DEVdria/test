--[[
	PurchaseHandler.lua - Procesa todas las compras de Developer Products

	UBICACIÓN: ServerScriptService > ShopSystem > PurchaseHandler (Script)

	INSTRUCCIONES:
	1. Este script debe estar en ServerScriptService
	2. Se ejecuta automáticamente cuando el servidor inicia
	3. Procesa todas las compras de Developer Products
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cargar configuración de productos
local ProductsConfig = require(ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("ProductsConfig"))

-- ==================== DATASTORE (OPCIONAL) ====================
--[[
	Si quieres guardar qué productos ha comprado cada jugador,
	descomenta esta sección y configura DataStoreService
]]

--[[
local DataStoreService = game:GetService("DataStoreService")
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local function savePurchase(userId, productId)
	local success, err = pcall(function()
		local key = "Player_" .. userId
		local history = purchaseHistoryStore:GetAsync(key) or {}
		table.insert(history, {
			ProductId = productId,
			Timestamp = os.time()
		})
		purchaseHistoryStore:SetAsync(key, history)
	end)
	return success
end
]]

-- ==================== FUNCIÓN PRINCIPAL DE COMPRA ====================

local function processReceipt(receiptInfo)
	--[[
		receiptInfo contiene:
		- PlayerId: ID del jugador que compró
		- PlaceIdWherePurchased: ID del lugar donde se compró
		- PurchaseId: ID único de la compra
		- ProductId: ID del producto comprado
		- CurrencyType: Tipo de moneda (Robux)
		- CurrencySpent: Cantidad gastada
	]]

	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	-- Obtener el jugador
	local player = Players:GetPlayerByUserId(userId)

	if not player then
		-- El jugador se fue, pero debemos procesar la compra de todos modos
		warn("Jugador no encontrado para procesar compra:", userId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Buscar el producto en la configuración
	local productData = ProductsConfig:GetDeveloperProduct(productId)

	if not productData then
		warn("Producto no encontrado en configuración:", productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Ejecutar la función OnPurchase del producto
	local success, result = pcall(function()
		return productData.OnPurchase(player)
	end)

	if success and result then
		print("✅ Compra procesada exitosamente:")
		print("   Jugador:", player.Name)
		print("   Producto:", productData.Name)
		print("   ID:", productId)

		-- Guardar en DataStore (opcional)
		-- savePurchase(userId, productId)

		-- Retornar éxito
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("❌ Error al procesar compra:")
		warn("   Jugador:", player.Name)
		warn("   Producto:", productData.Name)
		warn("   Error:", result)

		-- Retornar error, Roblox volverá a intentar procesar la compra
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- ==================== REGISTRAR CALLBACK ====================

-- Establecer el callback de procesamiento de compras
MarketplaceService.ProcessReceipt = processReceipt

print("✅ Sistema de compras inicializado correctamente")
print("📦 Productos registrados:", #ProductsConfig.DeveloperProducts)

-- ==================== LISTENER DE COMPRAS PROMPT ====================

-- Esto se ejecuta cuando un jugador INTENTA comprar algo
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
	local player = Players:GetPlayerByUserId(userId)
	if player then
		if isPurchased then
			print("🎉", player.Name, "compró el producto", productId)
		else
			print("⚠️", player.Name, "canceló la compra del producto", productId)
		end
	end
end)
