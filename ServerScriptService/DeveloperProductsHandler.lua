--[[
	DEVELOPER PRODUCTS HANDLER
	Ubicación: ServerScriptService

	Este script maneja todas las compras de Developer Products usando MarketplaceService.
	Configura los IDs de tus productos en la tabla PRODUCT_IDS.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- CONFIGURACIÓN DE PRODUCTOS
-- ============================================
-- IMPORTANTE: Reemplaza estos IDs con los IDs reales de tus Developer Products
local PRODUCT_IDS = {
	TrollProduct = 0,  -- ID del producto para el botón Troll
	Donacion1 = 0,     -- ID del primer producto de donación
	Donacion2 = 0,     -- ID del segundo producto de donación
	Donacion3 = 0,     -- ID del tercer producto de donación
	Donacion4 = 0,     -- ID del cuarto producto de donación
	Donacion5 = 0,     -- ID del quinto producto de donación
}

-- Esperar a que los RemoteEvents estén disponibles
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TrollEvent = RemoteEvents:WaitForChild("TrollEvent")
local PurchaseEvent = RemoteEvents:WaitForChild("PurchaseEvent")

-- ============================================
-- ALMACENAMIENTO DE COMPRAS PENDIENTES
-- ============================================
-- Tabla para rastrear jugadores que han comprado el producto Troll
local playersWithTroll = {}

-- ============================================
-- FUNCIONES DE PRODUCTOS
-- ============================================

-- Función para otorgar el producto Troll
local function grantTrollProduct(player)
	playersWithTroll[player.UserId] = true
	print("Producto Troll otorgado a:", player.Name)

	-- Notificar al cliente que ahora puede usar el botón
	PurchaseEvent:FireClient(player, "TrollUnlocked")
end

-- Función para ejecutar el efecto Troll (matar a todos los jugadores)
local function executeTrollEffect(player)
	-- Verificar que el jugador tiene el producto
	if not playersWithTroll[player.UserId] then
		warn(player.Name, "intentó usar Troll sin comprarlo")
		return
	end

	print(player.Name, "activó el efecto Troll - matando a todos los jugadores")

	-- Matar a todos los jugadores en el servidor
	for _, targetPlayer in pairs(Players:GetPlayers()) do
		local character = targetPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end
end

-- Función para procesar donaciones
local function processDonation(player, productId)
	print(player.Name, "hizo una donación - Producto ID:", productId)

	-- Aquí puedes agregar lógica adicional para las donaciones
	-- Por ejemplo: dar monedas, puntos, items, etc.

	-- Notificar al cliente que la donación fue exitosa
	PurchaseEvent:FireClient(player, "DonationSuccess")
end

-- ============================================
-- MANEJADOR DE RECEIPTS
-- ============================================

local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	-- Obtener el jugador
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		-- El jugador se desconectó, pero aún debemos otorgar el producto
		-- En un juego real, deberías guardar esto en un DataStore
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Procesar según el tipo de producto
	if productId == PRODUCT_IDS.TrollProduct then
		grantTrollProduct(player)
		return Enum.ProductPurchaseDecision.PurchaseGranted

	elseif productId == PRODUCT_IDS.Donacion1 or
	       productId == PRODUCT_IDS.Donacion2 or
	       productId == PRODUCT_IDS.Donacion3 or
	       productId == PRODUCT_IDS.Donacion4 or
	       productId == PRODUCT_IDS.Donacion5 then
		processDonation(player, productId)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Producto desconocido
	warn("Producto desconocido comprado:", productId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Configurar el callback de ProcessReceipt
MarketplaceService.ProcessReceipt = processReceipt

-- ============================================
-- EVENTOS REMOTOS
-- ============================================

-- Evento cuando el cliente solicita usar el Troll
TrollEvent.OnServerEvent:Connect(function(player)
	executeTrollEffect(player)
end)

-- Evento para iniciar una compra desde el cliente
local PromptPurchaseEvent = RemoteEvents:WaitForChild("PromptPurchase")
PromptPurchaseEvent.OnServerEvent:Connect(function(player, productName)
	local productId = PRODUCT_IDS[productName]

	if productId and productId ~= 0 then
		MarketplaceService:PromptProductPurchase(player, productId)
	else
		warn("Producto no configurado o ID inválido:", productName)
	end
end)

-- ============================================
-- MANEJO DE JUGADORES
-- ============================================

-- Limpiar datos cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	playersWithTroll[player.UserId] = nil
end)

print("✅ Developer Products Handler cargado correctamente")
print("⚠️ Recuerda configurar los IDs de productos en PRODUCT_IDS")
