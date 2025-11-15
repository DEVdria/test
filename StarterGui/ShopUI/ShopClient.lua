--[[
	ShopClient.lua
	UBICACIÓN: StarterGui > ShopUI > ShopClient (LocalScript)

	DESCRIPCIÓN:
	Este script maneja la interfaz de la tienda en el cliente.
	Muestra los items disponibles y permite al jugador comprarlos.

	REQUISITOS:
	- Debe estar dentro de un ScreenGui llamado "ShopUI"
	- El ScreenGui debe tener:
		* Frame principal llamado "ShopFrame"
		* ScrollingFrame llamado "ItemsContainer" (para los items)
		* TextButton llamado "CloseButton" (para cerrar la tienda)
		* TextButton llamado "OpenButton" (para abrir la tienda)

	FUNCIONES:
	- Carga items desde el servidor
	- Muestra items en una cuadrícula
	- Permite comprar items
	- Notificaciones de compra
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Esperar a RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getShopItemsRemote = remoteEvents:WaitForChild("GetShopItems")
local purchaseItemRemote = remoteEvents:WaitForChild("PurchaseItem")

-- Referencias a la UI
local screenGui = script.Parent
local shopFrame = screenGui:WaitForChild("ShopFrame")
local itemsContainer = shopFrame:WaitForChild("ItemsContainer")
local closeButton = shopFrame:WaitForChild("CloseButton")
local openButton = screenGui:WaitForChild("OpenButton")

-- Estado
local shopItems = {}
local isShopOpen = false

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE UI
-- ═══════════════════════════════════════════════════════════

-- Configurar visibilidad inicial
shopFrame.Visible = false
openButton.Visible = true

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES DE UI
-- ═══════════════════════════════════════════════════════════

--[[
	Función: formatNumber
	Formatea un número con separadores de miles
]]
local function formatNumber(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

--[[
	Función: createNotification
	Crea una notificación temporal en la pantalla
]]
local function createNotification(message, duration)
	duration = duration or 3

	-- Crear notificación
	local notification = Instance.new("TextLabel")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 400, 0, 60)
	notification.Position = UDim2.new(0.5, -200, 0.1, 0)
	notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	notification.BackgroundTransparency = 0.3
	notification.Text = message
	notification.TextColor3 = Color3.fromRGB(255, 255, 255)
	notification.TextScaled = true
	notification.Font = Enum.Font.GothamBold
	notification.Parent = screenGui

	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = notification

	-- Destruir después del tiempo especificado
	task.delay(duration, function()
		notification:Destroy()
	end)
end

--[[
	Función: createItemButton
	Crea un botón para un item de la tienda
]]
local function createItemButton(item, index)
	-- Frame contenedor del item
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Item_" .. item.ItemId
	itemFrame.Size = UDim2.new(0, 180, 0, 220)
	itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	itemFrame.BorderSizePixel = 0

	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.05, 0)
	corner.Parent = itemFrame

	-- Imagen del item (si tiene)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ItemImage"
	imageLabel.Size = UDim2.new(1, -20, 0, 100)
	imageLabel.Position = UDim2.new(0, 10, 0, 10)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = item.ImageId or ""
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = itemFrame

	-- Nombre del item
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = UDim2.new(1, -20, 0, 30)
	nameLabel.Position = UDim2.new(0, 10, 0, 115)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = itemFrame

	-- Descripción del item
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "ItemDescription"
	descLabel.Size = UDim2.new(1, -20, 0, 40)
	descLabel.Position = UDim2.new(0, 10, 0, 150)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = item.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextScaled = true
	descLabel.TextWrapped = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = itemFrame

	-- Botón de compra
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(1, -20, 0, 35)
	buyButton.Position = UDim2.new(0, 10, 1, -45)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	buyButton.Text = "💰 $" .. formatNumber(item.Price)
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextScaled = true
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = itemFrame

	-- UICorner para el botón
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0.2, 0)
	buttonCorner.Parent = buyButton

	-- Evento de compra
	buyButton.MouseButton1Click:Connect(function()
		-- Desactivar el botón temporalmente
		buyButton.Active = false
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

		-- Intentar comprar el item
		local result = purchaseItemRemote:InvokeServer(item.ItemId)

		-- Mostrar resultado
		if result.success then
			createNotification(result.message, 3)
		else
			createNotification(result.message, 3)
		end

		-- Reactivar el botón
		task.wait(1)
		buyButton.Active = true
		buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end)

	itemFrame.Parent = itemsContainer
end

--[[
	Función: loadShopItems
	Carga los items de la tienda desde el servidor
]]
local function loadShopItems()
	-- Limpiar items existentes
	for _, child in ipairs(itemsContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Obtener items del servidor
	local success, items = pcall(function()
		return getShopItemsRemote:InvokeServer()
	end)

	if not success then
		warn("[ShopClient] Error al cargar items: " .. tostring(items))
		createNotification("❌ Error al cargar la tienda", 3)
		return
	end

	shopItems = items

	-- Crear botones para cada item
	for index, item in ipairs(shopItems) do
		createItemButton(item, index)
	end

	-- Configurar UIGridLayout si no existe
	if not itemsContainer:FindFirstChildOfClass("UIGridLayout") then
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 180, 0, 220)
		gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
		gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		gridLayout.Parent = itemsContainer
	end

	print("[ShopClient] Cargados " .. #shopItems .. " items")
end

--[[
	Función: toggleShop
	Abre o cierra la tienda
]]
local function toggleShop()
	isShopOpen = not isShopOpen
	shopFrame.Visible = isShopOpen
	openButton.Visible = not isShopOpen

	if isShopOpen then
		loadShopItems()
	end
end

-- ═══════════════════════════════════════════════════════════
-- EVENTOS
-- ═══════════════════════════════════════════════════════════

-- Botón para abrir la tienda
openButton.MouseButton1Click:Connect(toggleShop)

-- Botón para cerrar la tienda
closeButton.MouseButton1Click:Connect(toggleShop)

-- Tecla para abrir/cerrar la tienda (Ejemplo: "E")
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		toggleShop()
	end
end)

print("[ShopClient] Sistema de tienda del cliente inicializado")
print("[ShopClient] Presiona 'E' o el botón 'Tienda' para abrir la tienda")
