--[[
	ShopFrameHandler.lua - Manejo de la UI de la tienda

	UBICACIÓN: StarterGui > ScreenGui > ShopFrame > LocalScript

	INSTRUCCIONES:
	1. Este script debe estar dentro del ShopFrame como LocalScript
	2. Reemplaza el LocalScript existente en ShopFrame con este
	3. Asegúrate de que ProductsConfig esté en ReplicatedStorage
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local shopFrame = script.Parent  -- ShopFrame
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local closeButton = shopFrame:WaitForChild("Cerrar")

-- Esperar a que cargue la configuración
local ProductsConfig = require(ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("ProductsConfig"))
local PurchaseGamepassEvent = ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("PurchaseGamepass")
local PurchaseProductEvent = ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("PurchaseProduct")

-- ==================== FUNCIONES DE UI ====================

local function createGamepassButton(gamepassData, index)
	-- Crear botón principal
	local button = Instance.new("TextButton")
	button.Name = "Gamepass_" .. gamepassData.GamepassId
	button.Size = UDim2.new(1, -20, 0, 120)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = index
	button.Parent = scrollingFrame

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	-- Borde
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 130, 220)
	stroke.Thickness = 2
	stroke.Parent = button

	-- Icono (opcional)
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 80, 0, 80)
	iconFrame.Position = UDim2.new(0, 10, 0.5, -40)
	iconFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	iconFrame.BorderSizePixel = 0
	iconFrame.Parent = button

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = iconFrame

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "🎫"
	iconLabel.TextSize = 40
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = iconFrame

	-- Nombre
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -110, 0, 30)
	nameLabel.Position = UDim2.new(0, 100, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = gamepassData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	-- Descripción
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -110, 0, 40)
	descLabel.Position = UDim2.new(0, 100, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = gamepassData.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = button

	-- Botón de compra
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(0, 100, 0, 35)
	buyButton.Position = UDim2.new(1, -110, 1, -45)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "Comprar"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 16
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = button

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 6)
	buyCorner.Parent = buyButton

	-- Label de "Ya tienes esto"
	local ownedLabel = Instance.new("TextLabel")
	ownedLabel.Name = "OwnedLabel"
	ownedLabel.Size = UDim2.new(0, 100, 0, 35)
	ownedLabel.Position = UDim2.new(1, -110, 1, -45)
	ownedLabel.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	ownedLabel.BorderSizePixel = 0
	ownedLabel.Text = "✓ Owned"
	ownedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ownedLabel.TextSize = 16
	ownedLabel.Font = Enum.Font.GothamBold
	ownedLabel.Visible = false
	ownedLabel.Parent = button

	local ownedCorner = Instance.new("UICorner")
	ownedCorner.CornerRadius = UDim.new(0, 6)
	ownedCorner.Parent = ownedLabel

	-- Verificar si el jugador ya tiene el gamepass
	local hasGamepass = false
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassData.GamepassId)
	end)

	if success and result then
		hasGamepass = true
		buyButton.Visible = false
		ownedLabel.Visible = true
	end

	-- Efecto hover
	buyButton.MouseEnter:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	end)

	buyButton.MouseLeave:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end)

	-- Comprar gamepass
	buyButton.MouseButton1Click:Connect(function()
		-- Solicitar compra
		MarketplaceService:PromptGamePassPurchase(player, gamepassData.GamepassId)
	end)

	return button
end

local function createProductButton(productData, index)
	-- Crear botón principal
	local button = Instance.new("TextButton")
	button.Name = "Product_" .. productData.ProductId
	button.Size = UDim2.new(1, -20, 0, 100)
	button.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = index
	button.Parent = scrollingFrame

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	-- Borde especial para productos troll
	local stroke = Instance.new("UIStroke")
	if productData.Category == "troll" then
		stroke.Color = Color3.fromRGB(220, 50, 50)
	else
		stroke.Color = Color3.fromRGB(220, 180, 50)
	end
	stroke.Thickness = 2
	stroke.Parent = button

	-- Icono
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 60, 0, 60)
	iconLabel.Position = UDim2.new(0, 15, 0.5, -30)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = productData.Name:match("^(%S+)") or "💰"  -- Primer emoji del nombre
	iconLabel.TextSize = 35
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = button

	-- Nombre
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -100, 0, 25)
	nameLabel.Position = UDim2.new(0, 85, 0, 15)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = productData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	-- Descripción
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -100, 0, 30)
	descLabel.Position = UDim2.new(0, 85, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = productData.Description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextSize = 13
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = button

	-- Botón de compra
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(0, 90, 0, 30)
	buyButton.Position = UDim2.new(1, -100, 1, -40)
	buyButton.BackgroundColor3 = productData.Category == "troll" and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(220, 165, 0)
	buyButton.BorderSizePixel = 0
	buyButton.Text = productData.Price .. " R$"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 14
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = button

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 6)
	buyCorner.Parent = buyButton

	-- Efecto hover
	buyButton.MouseEnter:Connect(function()
		if productData.Category == "troll" then
			buyButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
		else
			buyButton.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
		end
	end)

	buyButton.MouseLeave:Connect(function()
		if productData.Category == "troll" then
			buyButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		else
			buyButton.BackgroundColor3 = Color3.fromRGB(220, 165, 0)
		end
	end)

	-- Comprar producto
	buyButton.MouseButton1Click:Connect(function()
		-- Solicitar compra
		MarketplaceService:PromptProductPurchase(player, productData.ProductId)
	end)

	return button
end

local function loadGamepasses()
	-- Limpiar contenido existente
	for _, child in pairs(scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Name:match("^Gamepass_") then
			child:Destroy()
		end
	end

	-- Crear botones para cada gamepass
	for index, gamepass in ipairs(ProductsConfig.Gamepasses) do
		createGamepassButton(gamepass, index)
	end

	-- Ajustar tamaño del scroll
	local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
	if layout then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end
end

local function loadProducts(category)
	-- Limpiar contenido existente
	for _, child in pairs(scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Name:match("^Product_") then
			child:Destroy()
		end
	end

	-- Obtener productos de la categoría
	local products = ProductsConfig:GetProductsByCategory(category or "normal")

	-- Crear botones para cada producto
	for index, product in ipairs(products) do
		createProductButton(product, index)
	end

	-- Ajustar tamaño del scroll
	local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
	if layout then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end
end

-- ==================== CERRAR TIENDA ====================

closeButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

-- ==================== LAYOUT DEL SCROLLING FRAME ====================

-- Asegurarse de que existe un UIListLayout
if not scrollingFrame:FindFirstChildOfClass("UIListLayout") then
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = scrollingFrame
end

-- Padding
if not scrollingFrame:FindFirstChildOfClass("UIPadding") then
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scrollingFrame
end

-- ==================== INICIALIZACIÓN ====================

-- Cargar gamepasses por defecto
loadGamepasses()

-- Escuchar cuando se compra un gamepass para actualizar la UI
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, gamepassId, wasPurchased)
	if plr == player and wasPurchased then
		-- Recargar la tienda para mostrar "Owned"
		loadGamepasses()
	end
end)

-- Exportar funciones para uso externo
_G.ShopFrame = {
	ShowGamepasses = loadGamepasses,
	ShowProducts = loadProducts
}

print("✅ ShopFrame inicializado correctamente")
