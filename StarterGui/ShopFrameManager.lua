-- StarterGui > ScreenGui > ShopFrameManager (LocalScript)
-- Maneja la interfaz de la tienda de Gamepasses

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")

-- Referencias a la UI
local mainFrame = screenGui:WaitForChild("Frame")
local shopButton = mainFrame:WaitForChild("Shop")
local shopFrame = screenGui:WaitForChild("ShopFrame")
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local closeButton = shopFrame:WaitForChild("Cerrar")

-- Esperar RemoteEvents
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))
local PurchaseGamepass = ShopRemotesModule.PurchaseGamepass
local CheckGamepassOwnership = ShopRemotesModule.CheckGamepassOwnership

-- ====================================
-- CONFIGURACIÓN DE GAMEPASSES
-- ====================================
-- IMPORTANTE: Estos deben coincidir con los del servidor
-- Los IDs reales se configuran en el servidor
local GAMEPASSES = {
	{
		Key = "VIP",
		Name = "VIP Pass",
		Description = "Obtén beneficios exclusivos VIP",
		Icon = "rbxassetid://0", -- Opcional: ID de la imagen del gamepass
		Price = "100 Robux" -- Texto informativo
	},
	{
		Key = "SpeedBoost",
		Name = "Speed Boost",
		Description = "Corre el doble de rápido",
		Icon = "rbxassetid://0",
		Price = "50 Robux"
	},
	{
		Key = "DoubleJump",
		Name = "Double Jump",
		Description = "Salta mucho más alto",
		Icon = "rbxassetid://0",
		Price = "75 Robux"
	}
}

-- ====================================
-- FUNCIONES DE UI
-- ====================================

-- Abrir/Cerrar ShopFrame
shopButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = not shopFrame.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

-- Crear un botón de gamepass
local function createGamepassButton(gamepassData)
	local button = Instance.new("TextButton")
	button.Name = gamepassData.Key
	button.Size = UDim2.new(1, -10, 0, 80)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	nameLabel.TextSize = 20
	nameLabel.Text = gamepassData.Name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -10, 0, 20)
	descLabel.Position = UDim2.new(0, 5, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 14
	descLabel.Text = gamepassData.Description
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = button

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(1, -10, 0, 20)
	priceLabel.Position = UDim2.new(0, 5, 0, 55)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	priceLabel.TextSize = 16
	priceLabel.Text = gamepassData.Price
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = button

	-- Estado de propiedad
	local ownedLabel = Instance.new("TextLabel")
	ownedLabel.Name = "OwnedLabel"
	ownedLabel.Size = UDim2.new(0, 100, 0, 30)
	ownedLabel.Position = UDim2.new(1, -110, 0.5, -15)
	ownedLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	ownedLabel.BorderSizePixel = 0
	ownedLabel.Font = Enum.Font.GothamBold
	ownedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ownedLabel.TextSize = 14
	ownedLabel.Text = "✓ OWNED"
	ownedLabel.Visible = false
	ownedLabel.Parent = button

	-- Evento de clic
	button.MouseButton1Click:Connect(function()
		-- Si ya lo tiene, no hacer nada (o podrías mostrar un mensaje)
		if ownedLabel.Visible then
			print("Ya tienes este gamepass!")
			return
		end

		-- Solicitar compra al servidor
		PurchaseGamepass:FireServer(gamepassData.Key)
	end)

	button.Parent = scrollingFrame

	-- Verificar propiedad (opcional, se puede hacer desde el servidor también)
	-- Por ahora dejamos que el servidor maneje todo
	return button
end

-- ====================================
-- INICIALIZACIÓN
-- ====================================

-- Crear botones para todos los gamepasses
for _, gamepassData in ipairs(GAMEPASSES) do
	createGamepassButton(gamepassData)
end

-- Ajustar el UIListLayout si es necesario
local listLayout = scrollingFrame:FindFirstChild("UIListLayout")
if not listLayout then
	listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollingFrame
end

-- Ajustar el tamaño del canvas automáticamente
local function updateCanvasSize()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()

-- Inicialmente ocultar el ShopFrame
shopFrame.Visible = false

print("ShopFrameManager cargado correctamente")
