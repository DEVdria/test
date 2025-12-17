--[[
	SHOP BUTTON - LocalScript
	Maneja la apertura/cierre de la tienda y la compra de packs de dinero.

	ESTRUCTURA DE GUI ESPERADA:
	ScreenGui (PrincipalGui o como se llame)
	├── SHOP (ImageButton) ← Botón que abre/cierra la tienda
	├── ShopFrame (Frame) ← Contenedor de la tienda (Visible = false por defecto)
	│   ├── CloseButton (TextButton o ImageButton) ← Botón para cerrar [OPCIONAL]
	│   └── PacksScrolling (ScrollingFrame) ← Aquí se crearán los botones de packs
	│       └── UIListLayout ← Para organizar los botones automáticamente
	└── ShopButton (LocalScript) ← ESTE SCRIPT (al mismo nivel que SHOP button)

	NOTA: Los botones de packs se crean AUTOMÁTICAMENTE
	      Tú solo diseñas el PackTemplate (ver abajo)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ========================================
-- CONFIGURACIÓN
-- ========================================
-- Ajusta estos nombres según tu GUI
local SHOP_BUTTON_NAME = "SHOP"              -- Nombre del ImageButton que abre la tienda
local SHOP_FRAME_NAME = "ShopFrame"          -- Nombre del Frame de la tienda
local SCROLLING_FRAME_NAME = "PacksScrolling"  -- Nombre del ScrollingFrame
local CLOSE_BUTTON_NAME = "CloseButton"      -- Nombre del botón de cerrar (opcional)

-- ========================================
-- REFERENCIAS A LA GUI
-- ========================================
local screenGui = script.Parent
local shopButton = screenGui:WaitForChild(SHOP_BUTTON_NAME)
local shopFrame = screenGui:WaitForChild(SHOP_FRAME_NAME)
local packsScrolling = shopFrame:WaitForChild(SCROLLING_FRAME_NAME)
local closeButton = shopFrame:FindFirstChild(CLOSE_BUTTON_NAME)  -- Opcional

-- Verificar que existe UIListLayout
local uiListLayout = packsScrolling:FindFirstChildOfClass("UIListLayout")
if not uiListLayout then
	warn("[ShopButton] ⚠️ No se encontró UIListLayout en PacksScrolling, creando uno...")
	uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Parent = packsScrolling
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 10)
end

-- ========================================
-- REMOTES
-- ========================================
local Modules = ReplicatedStorage:WaitForChild("Modules")
local MoneyPackConfig = require(Modules:WaitForChild("MoneyPackConfig"))

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetMoneyPacksFunction = RemotesFolder:WaitForChild("GetMoneyPacks")
local PurchaseMoneyPackEvent = RemotesFolder:WaitForChild("PurchaseMoneyPack")

-- ========================================
-- VARIABLES
-- ========================================
local packsData = {}
local shopOpen = false

-- ========================================
-- FUNCIONES DE GUI
-- ========================================

-- Abre la tienda
local function openShop()
	shopFrame.Visible = true
	shopOpen = true
	print("[ShopButton] 🛒 Tienda abierta")
end

-- Cierra la tienda
local function closeShop()
	shopFrame.Visible = false
	shopOpen = false
	print("[ShopButton] ❌ Tienda cerrada")
end

-- Toggle (abrir/cerrar) la tienda
local function toggleShop()
	if shopOpen then
		closeShop()
	else
		openShop()
	end
end

-- ========================================
-- CREAR BOTONES DE PACKS
-- ========================================

-- Crea un botón de pack en el ScrollingFrame
local function createPackButton(pack, index)
	-- Crear el botón
	local packButton = Instance.new("TextButton")
	packButton.Name = "Pack" .. pack.ID
	packButton.Size = UDim2.new(1, -20, 0, 100)  -- Ancho completo, altura 100
	packButton.LayoutOrder = index
	packButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	packButton.BorderSizePixel = 2
	packButton.BorderColor3 = Color3.fromRGB(255, 200, 0)
	packButton.Text = ""
	packButton.AutoButtonColor = true
	packButton.Parent = packsScrolling

	-- Crear UICorner para bordes redondeados
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = packButton

	-- Nombre del pack
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = pack.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = packButton

	-- Cantidad de dinero
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, -10, 0, 30)
	moneyLabel.Position = UDim2.new(0, 5, 0, 30)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = MoneyPackConfig.FormatNumber(pack.MoneyAmount) .. " Dinero"
	moneyLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
	moneyLabel.TextSize = 24
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moneyLabel.Parent = packButton

	-- Precio
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(0, 100, 0, 30)
	priceLabel.Position = UDim2.new(1, -110, 1, -35)
	priceLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	priceLabel.Text = pack.Price .. " R$"
	priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	priceLabel.TextSize = 16
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.Parent = packButton

	local priceCorner = Instance.new("UICorner")
	priceCorner.CornerRadius = UDim.new(0, 6)
	priceCorner.Parent = priceLabel

	-- Descripción (opcional)
	if pack.Description then
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "DescLabel"
		descLabel.Size = UDim2.new(1, -10, 0, 20)
		descLabel.Position = UDim2.new(0, 5, 0, 65)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = pack.Description
		descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		descLabel.TextSize = 12
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = packButton
	end

	-- Evento de click
	packButton.MouseButton1Click:Connect(function()
		print(string.format("[ShopButton] 🛒 Comprando %s...", pack.Name))
		PurchaseMoneyPackEvent:FireServer(pack.ID)
	end)

	print(string.format("[ShopButton] ✅ Botón creado para %s", pack.Name))
end

-- Carga y crea todos los botones de packs
local function loadPacks()
	-- Limpiar botones existentes
	for _, child in ipairs(packsScrolling:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Solicitar packs al servidor
	local success, packs = pcall(function()
		return GetMoneyPacksFunction:InvokeServer()
	end)

	if not success then
		warn("[ShopButton] ❌ Error al cargar packs:", packs)
		return
	end

	if not packs or #packs == 0 then
		warn("[ShopButton] ⚠️ No hay packs disponibles")
		return
	end

	packsData = packs

	-- Crear botón para cada pack
	for index, pack in ipairs(packs) do
		createPackButton(pack, index)
	end

	print(string.format("[ShopButton] ✅ %d packs cargados", #packs))
end

-- ========================================
-- EVENTOS
-- ========================================

-- Click en botón SHOP
shopButton.MouseButton1Click:Connect(function()
	toggleShop()
end)

-- Click en botón Close (si existe)
if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		closeShop()
	end)
end

-- ========================================
-- INICIALIZACIÓN
-- ========================================

-- Asegurar que la tienda esté cerrada al inicio
shopFrame.Visible = false
shopOpen = false

-- Cargar packs
task.spawn(function()
	task.wait(1)  -- Esperar a que todo esté cargado
	loadPacks()
end)

print("[ShopButton] ✅ Sistema de tienda inicializado")
