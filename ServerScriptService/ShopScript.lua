--[[
═══════════════════════════════════════════════════════════════
    SHOP SCRIPT - Sistema de Tienda Física
    Ubicación: ServerScriptService

    Cómo usar:
    1. Crea una Part en Workspace y nómbrala "ShopStand"
    2. Añade un ProximityPrompt como hijo de la Part
    3. Este script detectará automáticamente todas las tiendas

    Funcionalidad:
    - Detecta ProximityPrompt en puestos de tienda
    - Abre UI de tienda cuando el jugador activa el prompt
    - Procesa compras y resta dinero
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear RemoteEvent para sonidos si no existe
local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
if not playSoundEvent then
	playSoundEvent = Instance.new("RemoteEvent")
	playSoundEvent.Name = "PlaySound"
	playSoundEvent.Parent = ReplicatedStorage
end

-- CATÁLOGO DE PRODUCTOS
-- Puedes añadir más productos aquí
local SHOP_ITEMS = {
	{
		Name = "Espada Básica",
		Price = 100,
		Description = "Una espada simple para empezar",
		Icon = "🗡️",
		ItemType = "Tool" -- Tipo de objeto que se dará
	},
	{
		Name = "Poción de Salud",
		Price = 50,
		Description = "Restaura tu salud al máximo",
		Icon = "🧪",
		ItemType = "Consumable"
	},
	{
		Name = "Escudo Dorado",
		Price = 250,
		Description = "Un escudo resistente y brillante",
		Icon = "🛡️",
		ItemType = "Tool"
	},
	{
		Name = "Botas de Velocidad",
		Price = 150,
		Description = "Te hace correr más rápido",
		Icon = "👟",
		ItemType = "Tool"
	},
	{
		Name = "Casco de Diamante",
		Price = 300,
		Description = "Protección máxima para tu cabeza",
		Icon = "💎",
		ItemType = "Tool"
	}
}

-- Crear RemoteEvents si no existen
local openShopEvent = ReplicatedStorage:FindFirstChild("OpenShop")
if not openShopEvent then
	openShopEvent = Instance.new("RemoteEvent")
	openShopEvent.Name = "OpenShop"
	openShopEvent.Parent = ReplicatedStorage
end

local purchaseEvent = ReplicatedStorage:FindFirstChild("PurchaseItem")
if not purchaseEvent then
	purchaseEvent = Instance.new("RemoteEvent")
	purchaseEvent.Name = "PurchaseItem"
	purchaseEvent.Parent = ReplicatedStorage
end

local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
if not notificationEvent then
	notificationEvent = Instance.new("RemoteEvent")
	notificationEvent.Name = "SendNotification"
	notificationEvent.Parent = ReplicatedStorage
end

--[[
    Función: Dar un objeto al jugador
    Parámetros:
        player - El jugador
        itemName - Nombre del objeto
        itemType - Tipo de objeto
--]]
local function giveItemToPlayer(player, itemName, itemType)
	-- Aquí puedes personalizar qué sucede cuando se compra cada tipo de objeto
	if itemType == "Tool" then
		-- Crear una herramienta simple como ejemplo
		local tool = Instance.new("Tool")
		tool.Name = itemName
		tool.RequiresHandle = false
		tool.Parent = player.Backpack

		-- Aquí podrías clonar herramientas predefinidas desde ServerStorage
		-- Ejemplo:
		-- local toolTemplate = game.ServerStorage:FindFirstChild(itemName)
		-- if toolTemplate then
		--     local toolClone = toolTemplate:Clone()
		--     toolClone.Parent = player.Backpack
		-- end

	elseif itemType == "Consumable" then
		-- Ejemplo: Restaurar salud para pociones
		if itemName == "Poción de Salud" then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		end
	end
end

--[[
    Función: Procesar una compra
    Parámetros:
        player - El jugador que compra
        itemIndex - Índice del objeto en el catálogo
--]]
local function processPurchase(player, itemIndex)
	-- Verificar que el índice sea válido
	if itemIndex < 1 or itemIndex > #SHOP_ITEMS then
		warn("Índice de objeto inválido: " .. tostring(itemIndex))
		return
	end

	local item = SHOP_ITEMS[itemIndex]

	-- Verificar que el jugador tenga suficiente dinero
	if _G.MoneyManager then
		local currentMoney = _G.MoneyManager.GetMoney(player)

		if currentMoney >= item.Price then
			-- Remover dinero
			local success = _G.MoneyManager.RemoveMoney(player, item.Price)

			if success then
				-- Dar objeto al jugador
				giveItemToPlayer(player, item.Name, item.ItemType)

				-- Actualizar progreso de misiones
				if _G.QuestSystem then
					_G.QuestSystem.UpdateProgress(player, "MoneySpent", item.Price)
				end

				-- Notificar éxito
				notificationEvent:FireClient(
					player,
					"✅ Compraste: " .. item.Name,
					Color3.fromRGB(85, 255, 127)
				)

				-- Reproducir sonido de compra exitosa
				playSoundEvent:FireClient(player, "Shop", "Purchase")

				print(player.Name .. " compró " .. item.Name .. " por $" .. item.Price)
			else
				-- No se pudo remover dinero
				notificationEvent:FireClient(
					player,
					"❌ Error al procesar la compra",
					Color3.fromRGB(255, 85, 85)
				)
			end
		else
			-- No tiene suficiente dinero
			notificationEvent:FireClient(
				player,
				"❌ No tienes suficiente dinero ($" .. item.Price .. " necesarios)",
				Color3.fromRGB(255, 170, 0)
			)

			-- Reproducir sonido de error (no puede comprar)
			playSoundEvent:FireClient(player, "Shop", "CannotAfford")
		end
	else
		warn("MoneyManager no está disponible")
	end
end

--[[
    Función: Configurar una tienda
    Parámetros: shop - La part de la tienda
--]]
local function setupShop(shop)
	-- Buscar o crear ProximityPrompt
	local proximityPrompt = shop:FindFirstChildOfClass("ProximityPrompt")

	if not proximityPrompt then
		-- Crear ProximityPrompt si no existe
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = "Tienda"
		proximityPrompt.ActionText = "Abrir Tienda"
		proximityPrompt.MaxActivationDistance = 10
		proximityPrompt.HoldDuration = 0
		proximityPrompt.Parent = shop
	end

	-- Evento cuando se activa el prompt
	proximityPrompt.Triggered:Connect(function(player)
		-- Enviar catálogo de productos al cliente
		openShopEvent:FireClient(player, SHOP_ITEMS)
	end)

	print("Tienda configurada: " .. shop:GetFullName())
end

--[[
    Buscar y configurar todas las tiendas en Workspace
--]]
local function findAndSetupShops()
	for _, obj in pairs(game.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "ShopStand" then
			setupShop(obj)
		end
	end
end

-- Configurar tiendas existentes
findAndSetupShops()

-- Configurar nuevas tiendas que se añadan
game.Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "ShopStand" then
		setupShop(obj)
	end
end)

-- Escuchar compras
purchaseEvent.OnServerEvent:Connect(function(player, itemIndex)
	processPurchase(player, itemIndex)
end)

print("Sistema de tienda inicializado con " .. #SHOP_ITEMS .. " productos")
