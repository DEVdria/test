--[[
═══════════════════════════════════════════════════════════════
    SHOP UI - Interfaz de Usuario de la Tienda
    Ubicación: StarterPlayer > StarterPlayerScripts

    Funcionalidad:
    - Crea la interfaz de la tienda dinámicamente
    - Muestra productos disponibles
    - Permite comprar objetos
    - Se abre cuando el servidor lo solicita
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a RemoteEvents
local openShopEvent = ReplicatedStorage:WaitForChild("OpenShop")
local purchaseEvent = ReplicatedStorage:WaitForChild("PurchaseItem")

-- Variable para almacenar la UI actual
local currentShopGui = nil

--[[
    Función: Crear botón de producto
    Parámetros:
        item - Datos del producto
        index - Índice del producto
        parent - Frame padre
--]]
local function createProductButton(item, index, parent)
	-- Frame del producto
	local productFrame = Instance.new("Frame")
	productFrame.Name = "Product_" .. index
	productFrame.Size = UDim2.new(0, 180, 0, 220)
	productFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	productFrame.BorderSizePixel = 0
	productFrame.Parent = parent

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = productFrame

	-- Ícono
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(1, 0, 0, 60)
	iconLabel.Position = UDim2.new(0, 0, 0, 10)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = item.Icon
	iconLabel.TextSize = 48
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = productFrame

	-- Nombre
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -20, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 80)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextWrapped = true
	nameLabel.Parent = productFrame

	-- Descripción
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -20, 0, 50)
	descLabel.Position = UDim2.new(0, 10, 0, 110)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = item.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = productFrame

	-- Precio
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(1, 0, 0, 25)
	priceLabel.Position = UDim2.new(0, 0, 0, 165)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = "$" .. tostring(item.Price)
	priceLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
	priceLabel.TextSize = 20
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.Parent = productFrame

	-- Botón de compra
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(0, 140, 0, 35)
	buyButton.Position = UDim2.new(0.5, -70, 1, -45)
	buyButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "COMPRAR"
	buyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	buyButton.TextSize = 14
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = productFrame

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton

	-- Efecto hover
	buyButton.MouseEnter:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
	end)

	buyButton.MouseLeave:Connect(function()
		buyButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
	end)

	-- Evento de compra
	buyButton.MouseButton1Click:Connect(function()
		-- Enviar solicitud de compra al servidor
		purchaseEvent:FireServer(index)

		-- Cerrar tienda después de comprar
		task.wait(0.5)
		if currentShopGui then
			currentShopGui:Destroy()
			currentShopGui = nil
		end
	end)
end

--[[
    Función: Crear UI de la tienda
    Parámetros: items - Array de productos
--]]
local function createShopUI(items)
	-- Cerrar tienda anterior si existe
	if currentShopGui then
		currentShopGui:Destroy()
	end

	-- Crear ScreenGui principal
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	currentShopGui = screenGui

	-- Frame de fondo oscuro
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.5
	background.BorderSizePixel = 0
	background.Parent = screenGui

	-- Frame principal de la tienda
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 800, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 15)
	mainCorner.Parent = mainFrame

	-- Barra de título
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 60)
	titleBar.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 15)
	titleCorner.Parent = titleBar

	-- Título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🛒 TIENDA"
	titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextSize = 28
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Botón de cerrar
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 24
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = titleBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Evento de cerrar
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
		currentShopGui = nil
	end)

	-- Hacer que el fondo también cierre la tienda
	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			screenGui:Destroy()
			currentShopGui = nil
		end
	end)

	-- Frame de productos con scroll
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ProductsScroll"
	scrollFrame.Size = UDim2.new(1, -40, 1, -100)
	scrollFrame.Position = UDim2.new(0, 20, 0, 80)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = mainFrame

	-- Grid layout para productos
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 180, 0, 220)
	gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame

	-- Crear botones para cada producto
	for index, item in ipairs(items) do
		createProductButton(item, index, scrollFrame)
	end

	-- Ajustar tamaño del canvas
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)

	-- Actualizar canvas cuando cambia el tamaño del contenido
	gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)
	end)

	-- Animación de entrada
	mainFrame.Position = UDim2.new(0.5, -400, 1.5, 0)
	mainFrame:TweenPosition(
		UDim2.new(0.5, -400, 0.5, -300),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)
end

-- Escuchar evento para abrir tienda
openShopEvent.OnClientEvent:Connect(function(items)
	createShopUI(items)
end)

print("Sistema de UI de tienda cargado")
