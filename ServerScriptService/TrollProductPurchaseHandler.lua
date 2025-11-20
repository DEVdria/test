-- ServerScriptService > TrollProductPurchaseHandler
-- Maneja las solicitudes de compra de Developer Products de Troll
-- El UnifiedProcessReceipt se encarga de procesar la compra y ejecutar el efecto

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que ShopRemotes esté disponible
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))
local PurchaseDeveloperProduct = ShopRemotesModule.PurchaseDeveloperProduct

-- ====================================
-- CONFIGURACIÓN DE DEVELOPER PRODUCTS
-- ====================================
-- IMPORTANTE: Estos IDs deben coincidir EXACTAMENTE con los de UnifiedProcessReceipt.lua

local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 3458498800,
	},
	RagdollAll = {
		ID = 3458498799,
	},
	Explosion = {
		ID = 3458498802,
	},
	SpeedBoostAll = {
		ID = 3458498801,
	}
}

-- ====================================
-- VERIFICACIÓN DE CONFIGURACIÓN
-- ====================================

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🛒 TrollProductPurchaseHandler iniciado")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local hasInvalidIds = false
for key, data in pairs(DEVELOPER_PRODUCTS) do
	if data.ID == 0 then
		warn("⚠️ " .. key .. ": ID NO CONFIGURADO (actualmente 0)")
		hasInvalidIds = true
	else
		print("✅ " .. key .. ": ID configurado (" .. data.ID .. ")")
	end
end

if hasInvalidIds then
	warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	warn("⚠️ ADVERTENCIA: Hay productos sin configurar")
	warn("⚠️ Los botones NO mostrarán el prompt de compra")
	warn("⚠️ Configura los IDs en TrollProductPurchaseHandler.lua")
	warn("⚠️ Y asegúrate de que coincidan con UnifiedProcessReceipt.lua")
	warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- ====================================
-- MANEJAR SOLICITUDES DE COMPRA
-- ====================================

PurchaseDeveloperProduct.OnServerEvent:Connect(function(player, productKey)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🛒 Solicitud de compra recibida")
	print("Jugador: " .. player.Name)
	print("Producto: " .. tostring(productKey))
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	-- Verificar que el producto existe
	local productData = DEVELOPER_PRODUCTS[productKey]

	if not productData then
		warn("❌ Producto desconocido: " .. tostring(productKey))
		warn("❌ Productos válidos: KillAll, RagdollAll, Explosion, SpeedBoostAll")
		warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		return
	end

	-- Verificar que el ID está configurado
	if productData.ID == 0 then
		warn("❌ El producto " .. productKey .. " no tiene ID configurado")
		warn("❌ Configura el ID en TrollProductPurchaseHandler.lua línea correspondiente")
		warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		return
	end

	print("✅ Producto encontrado con ID: " .. productData.ID)
	print("🔄 Mostrando prompt de compra...")

	-- Mostrar el prompt de compra al jugador
	local success, errorMessage = pcall(function()
		MarketplaceService:PromptProductPurchase(player, productData.ID)
	end)

	if success then
		print("✅ Prompt de compra mostrado correctamente")
		print("💡 Esperando respuesta del jugador...")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	else
		warn("❌ Error al mostrar prompt de compra: " .. tostring(errorMessage))
		warn("❌ Verifica que el ID " .. productData.ID .. " sea correcto")
		warn("❌ Y que el Developer Product exista en tu juego")
		warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	end
end)

print("✅ TrollProductPurchaseHandler listo para recibir solicitudes")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
