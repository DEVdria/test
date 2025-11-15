--[[
	ShopHandler.lua
	UBICACIÓN: ServerScriptService

	DESCRIPCIÓN:
	Este script maneja todas las compras de la tienda en el servidor.
	Valida que el jugador tenga suficiente dinero y otorga los items.

	FUNCIONES:
	- Validación de compras
	- Sistema de items configurables
	- Protección contra exploits
	- Registro de transacciones

	CONFIGURACIÓN:
	- Agrega items en la tabla SHOP_ITEMS
	- Cada item puede tener una función personalizada al comprarse
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE LA TIENDA
-- ═══════════════════════════════════════════════════════════

--[[
	SHOP_ITEMS: Tabla de items disponibles en la tienda

	Estructura de cada item:
	{
		ItemId = "id_unico",              -- ID único del item
		Name = "Nombre del Item",         -- Nombre visible
		Description = "Descripción",      -- Descripción del item
		Price = 100,                      -- Precio en dinero
		ImageId = "rbxassetid://12345",   -- ID de la imagen (opcional)
		Category = "Weapons",             -- Categoría (opcional)
		OnPurchase = function(player)    -- Función que se ejecuta al comprar
			-- Código personalizado aquí
		end
	}
]]

local SHOP_ITEMS = {
	-- Armas
	{
		ItemId = "sword_basic",
		Name = "Espada Básica",
		Description = "Una espada simple para comenzar tu aventura",
		Price = 150,
		ImageId = "rbxassetid://0",
		Category = "Armas",
		OnPurchase = function(player)
			-- Aquí deberías clonar el tool de ServerStorage o crear uno
			print("[Shop] " .. player.Name .. " compró una Espada Básica")
			-- Ejemplo: clonar tool
			-- local sword = game.ServerStorage.Weapons.BasicSword:Clone()
			-- sword.Parent = player.Backpack
		end
	},

	{
		ItemId = "sword_legendary",
		Name = "Espada Legendaria",
		Description = "¡Una espada poderosa para guerreros experimentados!",
		Price = 1000,
		ImageId = "rbxassetid://0",
		Category = "Armas",
		OnPurchase = function(player)
			print("[Shop] " .. player.Name .. " compró una Espada Legendaria")
			-- local sword = game.ServerStorage.Weapons.LegendarySword:Clone()
			-- sword.Parent = player.Backpack
		end
	},

	-- Velocidad
	{
		ItemId = "speed_boost",
		Name = "Boost de Velocidad",
		Description = "Aumenta tu velocidad de movimiento permanentemente",
		Price = 500,
		ImageId = "rbxassetid://0",
		Category = "Mejoras",
		OnPurchase = function(player)
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = humanoid.WalkSpeed + 5
					print("[Shop] " .. player.Name .. " aumentó su velocidad a " .. humanoid.WalkSpeed)
				end
			end
		end
	},

	-- Salud
	{
		ItemId = "health_boost",
		Name = "Boost de Salud",
		Description = "Aumenta tu salud máxima permanentemente",
		Price = 750,
		ImageId = "rbxassetid://0",
		Category = "Mejoras",
		OnPurchase = function(player)
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.MaxHealth = humanoid.MaxHealth + 50
					humanoid.Health = humanoid.MaxHealth
					print("[Shop] " .. player.Name .. " aumentó su salud máxima a " .. humanoid.MaxHealth)
				end
			end
		end
	},

	-- VIP
	{
		ItemId = "vip_pass",
		Name = "Pase VIP",
		Description = "Acceso a áreas VIP y beneficios exclusivos",
		Price = 2500,
		ImageId = "rbxassetid://0",
		Category = "Especial",
		OnPurchase = function(player)
			-- Dar una etiqueta VIP al jugador
			local vipTag = Instance.new("BoolValue")
			vipTag.Name = "VIP"
			vipTag.Value = true
			vipTag.Parent = player

			print("[Shop] " .. player.Name .. " es ahora VIP!")
		end
	},
}

-- ═══════════════════════════════════════════════════════════
-- REMOTE EVENTS
-- ═══════════════════════════════════════════════════════════

-- Crear carpeta de RemoteEvents si no existe
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- RemoteFunction para obtener items de la tienda
local getShopItemsRemote = remoteEventsFolder:FindFirstChild("GetShopItems")
if not getShopItemsRemote then
	getShopItemsRemote = Instance.new("RemoteFunction")
	getShopItemsRemote.Name = "GetShopItems"
	getShopItemsRemote.Parent = remoteEventsFolder
end

-- RemoteFunction para comprar items
local purchaseItemRemote = remoteEventsFolder:FindFirstChild("PurchaseItem")
if not purchaseItemRemote then
	purchaseItemRemote = Instance.new("RemoteFunction")
	purchaseItemRemote.Name = "PurchaseItem"
	purchaseItemRemote.Parent = remoteEventsFolder
end

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

--[[
	Función: getItemById
	Busca un item por su ID
	@param itemId - El ID del item a buscar
	@return table|nil - El item encontrado o nil
]]
local function getItemById(itemId)
	for _, item in ipairs(SHOP_ITEMS) do
		if item.ItemId == itemId then
			return item
		end
	end
	return nil
end

--[[
	Función: canAfford
	Verifica si un jugador puede pagar un item
	@param player - El jugador
	@param price - El precio del item
	@return boolean - true si puede pagar, false si no
]]
local function canAfford(player, price)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		return false
	end

	return money.Value >= price
end

--[[
	Función: deductMoney
	Deduce dinero de un jugador
	@param player - El jugador
	@param amount - La cantidad a deducir
	@return boolean - true si se dedujo exitosamente, false si no
]]
local function deductMoney(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		return false
	end

	if money.Value >= amount then
		money.Value = money.Value - amount
		return true
	end

	return false
end

--[[
	Función: processPurchase
	Procesa una compra de un jugador
	@param player - El jugador que está comprando
	@param itemId - El ID del item a comprar
	@return table - {success: boolean, message: string}
]]
local function processPurchase(player, itemId)
	-- Validar que el jugador existe
	if not player or not player.Parent then
		return {success = false, message = "❌ Jugador no válido"}
	end

	-- Buscar el item
	local item = getItemById(itemId)
	if not item then
		warn("[Shop] Item no encontrado: " .. tostring(itemId))
		return {success = false, message = "❌ Item no encontrado"}
	end

	-- Verificar que el jugador tenga suficiente dinero
	if not canAfford(player, item.Price) then
		return {success = false, message = "❌ No tienes suficiente dinero"}
	end

	-- Deducir el dinero
	if not deductMoney(player, item.Price) then
		return {success = false, message = "❌ Error al procesar el pago"}
	end

	-- Ejecutar la función OnPurchase si existe
	if item.OnPurchase and type(item.OnPurchase) == "function" then
		local success, errorMsg = pcall(function()
			item.OnPurchase(player)
		end)

		if not success then
			warn("[Shop] Error al ejecutar OnPurchase para " .. item.Name .. ": " .. tostring(errorMsg))
			-- Reembolsar el dinero
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local money = leaderstats:FindFirstChild("Money")
				if money then
					money.Value = money.Value + item.Price
				end
			end
			return {success = false, message = "❌ Error al otorgar el item"}
		end
	end

	-- Éxito
	print(string.format("[Shop] %s compró '%s' por $%d", player.Name, item.Name, item.Price))
	return {
		success = true,
		message = string.format("✅ ¡Compraste %s por $%d!", item.Name, item.Price)
	}
end

-- ═══════════════════════════════════════════════════════════
-- CALLBACKS DE REMOTE FUNCTIONS
-- ═══════════════════════════════════════════════════════════

--[[
	GetShopItems: Devuelve la lista de items de la tienda al cliente
	@param player - El jugador que solicita los items
	@return table - Lista de items (sin la función OnPurchase)
]]
getShopItemsRemote.OnServerInvoke = function(player)
	-- Crear una copia de los items sin la función OnPurchase
	local itemsToSend = {}

	for _, item in ipairs(SHOP_ITEMS) do
		table.insert(itemsToSend, {
			ItemId = item.ItemId,
			Name = item.Name,
			Description = item.Description,
			Price = item.Price,
			ImageId = item.ImageId,
			Category = item.Category,
		})
	end

	return itemsToSend
end

--[[
	PurchaseItem: Procesa una compra de un jugador
	@param player - El jugador que está comprando
	@param itemId - El ID del item a comprar
	@return table - Resultado de la compra
]]
purchaseItemRemote.OnServerInvoke = function(player, itemId)
	-- Validación de seguridad
	if type(itemId) ~= "string" then
		return {success = false, message = "❌ ID de item no válido"}
	end

	-- Procesar la compra
	return processPurchase(player, itemId)
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

print("[ShopHandler] Sistema de tienda inicializado")
print("[ShopHandler] Items disponibles: " .. #SHOP_ITEMS)
