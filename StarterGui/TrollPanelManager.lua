-- StarterGui > ScreenGui > TrollPanelManager (LocalScript)
-- Maneja la interfaz del panel de Troll (Developer Products)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")

-- Referencias a la UI
local mainFrame = screenGui:WaitForChild("Frame")
local trollButton = mainFrame:WaitForChild("Troll")

-- Esperar RemoteEvents
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))
local PurchaseDeveloperProduct = ShopRemotesModule.PurchaseDeveloperProduct

-- ====================================
-- CREAR PANEL DE TROLL
-- ====================================
-- Crear el TrollFrame si no existe
local trollFrame = screenGui:FindFirstChild("TrollFrame")
if not trollFrame then
	trollFrame = Instance.new("Frame")
	trollFrame.Name = "TrollFrame"
	trollFrame.Size = UDim2.new(0, 400, 0, 500)
	trollFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	trollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	trollFrame.BorderSizePixel = 3
	trollFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
	trollFrame.Visible = false
	trollFrame.Parent = screenGui

	-- Título
	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.Size = UDim2.new(1, 0, 0, 50)
	titleFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	titleFrame.BorderSizePixel = 0
	titleFrame.Parent = trollFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -10, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 24
	titleLabel.Text = "💀 TROLL SHOP 💀"
	titleLabel.Parent = titleFrame

	-- ScrollingFrame para productos
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, -20, 1, -110)
	scrollingFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	scrollingFrame.BorderSizePixel = 2
	scrollingFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.Parent = trollFrame

	-- UIListLayout
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollingFrame

	-- Botón Cerrar
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Cerrar"
	closeButton.Size = UDim2.new(0, 100, 0, 35)
	closeButton.Position = UDim2.new(0.5, -50, 1, -45)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeButton.BorderSizePixel = 2
	closeButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Text = "CERRAR"
	closeButton.Parent = trollFrame
end

-- ====================================
-- CONFIGURACIÓN DE DEVELOPER PRODUCTS
-- ====================================
-- IMPORTANTE: Estos deben coincidir con los del servidor
local DEVELOPER_PRODUCTS = {
	{
		Key = "KillAll",
		Name = "💀 Kill All",
		Description = "Mata a todos los jugadores del servidor",
		Price = "25 Robux",
		Color = Color3.fromRGB(150, 0, 0)
	},
	{
		Key = "RagdollAll",
		Name = "🚀 Launch All",
		Description = "Lanza a todos los jugadores hacia el cielo",
		Price = "20 Robux",
		Color = Color3.fromRGB(100, 100, 0)
	},
	{
		Key = "Explosion",
		Name = "💥 Explosion",
		Description = "Crea una explosión masiva",
		Price = "30 Robux",
		Color = Color3.fromRGB(200, 100, 0)
	},
	{
		Key = "SpeedBoostAll",
		Name = "⚡ Speed Boost All",
		Description = "Da velocidad a todos por 30 segundos",
		Price = "15 Robux",
		Color = Color3.fromRGB(0, 150, 200)
	}
}

-- ====================================
-- FUNCIONES DE UI
-- ====================================

-- Abrir/Cerrar TrollFrame
trollButton.MouseButton1Click:Connect(function()
	trollFrame.Visible = not trollFrame.Visible
end)

trollFrame.Cerrar.MouseButton1Click:Connect(function()
	trollFrame.Visible = false
end)

-- Crear un botón de developer product
local function createProductButton(productData)
	local button = Instance.new("TextButton")
	button.Name = productData.Key
	button.Size = UDim2.new(1, -10, 0, 90)
	button.BackgroundColor3 = productData.Color or Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.Text = "" -- Quitar el texto por defecto "Button"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.AutoButtonColor = true

	-- Texto del botón
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 30)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 22
	nameLabel.Text = productData.Name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -10, 0, 25)
	descLabel.Position = UDim2.new(0, 5, 0, 35)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	descLabel.TextSize = 14
	descLabel.Text = productData.Description
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = button

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(1, -10, 0, 25)
	priceLabel.Position = UDim2.new(0, 5, 0, 60)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	priceLabel.TextSize = 18
	priceLabel.Text = "💰 " .. productData.Price
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = button

	-- Evento de clic
	button.MouseButton1Click:Connect(function()
		-- Solicitar compra al servidor
		PurchaseDeveloperProduct:FireServer(productData.Key)

		-- Feedback visual
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		wait(0.1)
		button.BackgroundColor3 = productData.Color or Color3.fromRGB(60, 60, 60)
	end)

	button.Parent = trollFrame.ScrollingFrame

	return button
end

-- ====================================
-- INICIALIZACIÓN
-- ====================================

-- Crear botones para todos los developer products
for _, productData in ipairs(DEVELOPER_PRODUCTS) do
	createProductButton(productData)
end

-- Ajustar el tamaño del canvas automáticamente
local scrollingFrame = trollFrame.ScrollingFrame
local listLayout = scrollingFrame:FindFirstChild("UIListLayout")

local function updateCanvasSize()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()

print("TrollPanelManager cargado correctamente")
