--[[
	ShopPhysical.lua
	UBICACIÓN: Workspace > ShopStand > ShopPhysical (Script)

	DESCRIPCIÓN:
	Este script maneja una tienda física en el mundo del juego.
	Muestra los items disponibles en pantallas usando SurfaceGui.
	Los jugadores pueden comprar items usando ProximityPrompt.

	REQUISITOS:
	- Debe estar dentro de una Part llamada "ShopStand"
	- La Part debe tener un SurfaceGui en una de sus caras
	- El script crea automáticamente el ProximityPrompt

	FUNCIONES:
	- Muestra todos los items disponibles en la tienda
	- Sistema de compra con ProximityPrompt
	- Navegación entre items (anterior/siguiente)
	- Validación de dinero en el servidor
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	PromptText = "Comprar Item",
	PromptKeyText = "Presiona para comprar",
	HoldDuration = 1,
	MaxDistance = 10,
}

-- ═══════════════════════════════════════════════════════════
-- REFERENCIAS
-- ═══════════════════════════════════════════════════════════

-- Obtener la Part que contiene este script
local shopPart = script.Parent
if not shopPart:IsA("BasePart") then
	error("[ShopPhysical] Este script debe estar dentro de una Part")
end

-- Esperar a RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
	error("[ShopPhysical] No se encontró RemoteEvents en ReplicatedStorage")
end

local getShopItemsRemote = remoteEvents:WaitForChild("GetShopItems", 10)
local purchaseItemRemote = remoteEvents:WaitForChild("PurchaseItem", 10)

if not getShopItemsRemote or not purchaseItemRemote then
	error("[ShopPhysical] No se encontraron los RemoteFunctions necesarios")
end

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local shopItems = {}
local currentItemIndex = {} -- Índice actual por jugador

-- ═══════════════════════════════════════════════════════════
-- CREAR UI
-- ═══════════════════════════════════════════════════════════

-- Buscar o crear SurfaceGui
local surfaceGui = shopPart:FindFirstChildOfClass("SurfaceGui")
if not surfaceGui then
	surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "ShopGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(1000, 800)
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 1.5
	surfaceGui.Parent = shopPart
end

-- Frame principal
local mainFrame = surfaceGui:FindFirstChild("MainFrame")
if not mainFrame then
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = surfaceGui
end

-- Título
local titleLabel = mainFrame:FindFirstChild("TitleLabel")
if not titleLabel then
	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Text = "🛒 TIENDA 🛒"
	titleLabel.Size = UDim2.new(1, 0, 0, 80)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.BorderSizePixel = 0

	local titlePadding = Instance.new("UIPadding")
	titlePadding.PaddingLeft = UDim.new(0, 20)
	titlePadding.PaddingRight = UDim.new(0, 20)
	titlePadding.Parent = titleLabel

	titleLabel.Parent = mainFrame
end

-- Contenedor de items (ScrollingFrame)
local itemsContainer = mainFrame:FindFirstChild("ItemsContainer")
if not itemsContainer then
	itemsContainer = Instance.new("ScrollingFrame")
	itemsContainer.Name = "ItemsContainer"
	itemsContainer.Size = UDim2.new(1, -40, 1, -140)
	itemsContainer.Position = UDim2.new(0, 20, 0, 100)
	itemsContainer.BackgroundTransparency = 0.5
	itemsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	itemsContainer.BorderSizePixel = 0
	itemsContainer.ScrollBarThickness = 10
	itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemsContainer.Parent = mainFrame

	-- UIGridLayout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 280, 0, 300)
	gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = itemsContainer

	-- UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = itemsContainer
end

-- Instrucciones
local instructionsLabel = mainFrame:FindFirstChild("InstructionsLabel")
if not instructionsLabel then
	instructionsLabel = Instance.new("TextLabel")
	instructionsLabel.Name = "InstructionsLabel"
	instructionsLabel.Text = "Acércate y presiona E para comprar un item"
	instructionsLabel.Size = UDim2.new(1, 0, 0, 40)
	instructionsLabel.Position = UDim2.new(0, 0, 1, -40)
	instructionsLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	instructionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	instructionsLabel.Font = Enum.Font.Gotham
	instructionsLabel.TextScaled = true
	instructionsLabel.BorderSizePixel = 0

	local instrPadding = Instance.new("UIPadding")
	instrPadding.PaddingLeft = UDim.new(0, 20)
	instrPadding.PaddingRight = UDim.new(0, 20)
	instrPadding.Parent = instructionsLabel

	instructionsLabel.Parent = mainFrame
end

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
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
	Función: createItemDisplay
	Crea un frame que muestra un item de la tienda
]]
local function createItemDisplay(item, index)
	-- Frame del item
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = "Item_" .. item.ItemId
	itemFrame.LayoutOrder = index
	itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	itemFrame.BorderSizePixel = 0

	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.05, 0)
	corner.Parent = itemFrame

	-- Imagen del item
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ItemImage"
	imageLabel.Size = UDim2.new(1, -20, 0, 120)
	imageLabel.Position = UDim2.new(0, 10, 0, 10)
	imageLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	imageLabel.Image = item.ImageId or ""
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.BorderSizePixel = 0

	local imgCorner = Instance.new("UICorner")
	imgCorner.CornerRadius = UDim.new(0.1, 0)
	imgCorner.Parent = imageLabel

	imageLabel.Parent = itemFrame

	-- Nombre del item
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = UDim2.new(1, -20, 0, 40)
	nameLabel.Position = UDim2.new(0, 10, 0, 140)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 24
	nameLabel.Parent = itemFrame

	-- Descripción
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "ItemDescription"
	descLabel.Size = UDim2.new(1, -20, 0, 60)
	descLabel.Position = UDim2.new(0, 10, 0, 185)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = item.Description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextScaled = true
	descLabel.TextWrapped = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 18
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = itemFrame

	-- Precio
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "ItemPrice"
	priceLabel.Size = UDim2.new(1, -20, 0, 40)
	priceLabel.Position = UDim2.new(0, 10, 1, -50)
	priceLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	priceLabel.Text = "💰 $" .. formatNumber(item.Price)
	priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	priceLabel.TextScaled = true
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextSize = 28
	priceLabel.BorderSizePixel = 0

	local priceCorner = Instance.new("UICorner")
	priceCorner.CornerRadius = UDim.new(0.2, 0)
	priceCorner.Parent = priceLabel

	priceLabel.Parent = itemFrame

	return itemFrame
end

--[[
	Función: loadShopItems
	Carga y muestra todos los items de la tienda
]]
local function loadShopItems()
	-- Limpiar items existentes
	for _, child in ipairs(itemsContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Item_") then
			child:Destroy()
		end
	end

	-- Obtener items del servidor
	local success, items = pcall(function()
		return getShopItemsRemote:InvokeServer()
	end)

	if not success then
		warn("[ShopPhysical] Error al cargar items: " .. tostring(items))
		return
	end

	shopItems = items

	-- Crear displays para cada item
	for index, item in ipairs(shopItems) do
		local itemDisplay = createItemDisplay(item, index)
		itemDisplay.Parent = itemsContainer
	end

	-- Ajustar CanvasSize
	local gridLayout = itemsContainer:FindFirstChildOfClass("UIGridLayout")
	if gridLayout then
		itemsContainer.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
	end

	print("[ShopPhysical] Cargados " .. #shopItems .. " items")
end

-- ═══════════════════════════════════════════════════════════
-- PROXIMITY PROMPT SYSTEM
-- ═══════════════════════════════════════════════════════════

-- Crear un ProximityPrompt para cada item
local function createProximityPrompts()
	-- Limpiar prompts existentes
	for _, prompt in ipairs(shopPart:GetChildren()) do
		if prompt:IsA("ProximityPrompt") and prompt.Name:match("^BuyPrompt_") then
			prompt:Destroy()
		end
	end

	-- Crear un prompt para cada item
	for index, item in ipairs(shopItems) do
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "BuyPrompt_" .. item.ItemId
		prompt.ActionText = "Comprar " .. item.Name
		prompt.ObjectText = "$" .. formatNumber(item.Price)
		prompt.HoldDuration = CONFIG.HoldDuration
		prompt.MaxActivationDistance = CONFIG.MaxDistance
		prompt.RequiresLineOfSight = false
		prompt.Style = Enum.ProximityPromptStyle.Custom

		-- Conectar evento
		prompt.Triggered:Connect(function(player)
			-- Intentar comprar
			local result = purchaseItemRemote:InvokeServer(item.ItemId)

			if result.success then
				print("[ShopPhysical] " .. player.Name .. " compró " .. item.Name)

				-- Crear notificación flotante (opcional)
				local notification = Instance.new("Hint")
				notification.Text = result.message
				notification.Parent = player.PlayerGui
				task.delay(3, function()
					notification:Destroy()
				end)
			else
				-- Notificar error
				local notification = Instance.new("Hint")
				notification.Text = result.message
				notification.Parent = player.PlayerGui
				task.delay(3, function()
					notification:Destroy()
				end)
			end
		end)

		prompt.Parent = shopPart
	end
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

-- Cargar items por primera vez
task.wait(2)
loadShopItems()
createProximityPrompts()

-- Actualizar cada 60 segundos (por si se agregan nuevos items)
task.spawn(function()
	while true do
		task.wait(60)
		loadShopItems()
		createProximityPrompts()
	end
end)

print("[ShopPhysical] Tienda física inicializada en: " .. shopPart:GetFullName())
