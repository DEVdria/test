--[[
	SHOP BUTTON - LocalScript
	Maneja la apertura/cierre de la tienda y conecta los botones de compra diseñados manualmente.

	ESTRUCTURA DE GUI ESPERADA:
	ScreenGui (PrincipalGui o como se llame)
	├── SHOP (ImageButton) ← Botón que abre/cierra la tienda
	├── ShopButton (LocalScript) ← ESTE SCRIPT (al mismo nivel que SHOP button)
	└── ShopFrame (Frame) ← Contenedor de la tienda (Visible = false por defecto)
	    ├── CloseButton (TextButton o ImageButton) ← Botón para cerrar [OPCIONAL]
	    └── PacksScrolling (ScrollingFrame) ← Aquí DISEÑAS TÚ los packs
	        ├── Frame1 (Frame) ← Pack 1 diseñado por ti
	        │   └── BuyButton (TextButton) ← Botón de compra
	        ├── Frame2 (Frame) ← Pack 2 diseñado por ti
	        │   └── BuyButton (TextButton) ← Botón de compra
	        ├── Frame3 (Frame) ← Pack 3 diseñado por ti
	        │   └── BuyButton (TextButton) ← Botón de compra
	        └── ... etc

	NOTA: El script conecta automáticamente cada BuyButton con su pack correspondiente
	      Frame1 = Pack 1, Frame2 = Pack 2, Frame3 = Pack 3, etc.
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
local BUY_BUTTON_NAME = "BuyButton"          -- Nombre del botón de compra en cada frame

-- ========================================
-- REFERENCIAS A LA GUI
-- ========================================
local screenGui = script.Parent
local shopButton = screenGui:WaitForChild(SHOP_BUTTON_NAME)
local shopFrame = screenGui:WaitForChild(SHOP_FRAME_NAME)
local packsScrolling = shopFrame:WaitForChild(SCROLLING_FRAME_NAME)
local closeButton = shopFrame:FindFirstChild(CLOSE_BUTTON_NAME)  -- Opcional

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local PurchaseMoneyPackEvent = RemotesFolder:WaitForChild("PurchaseMoneyPack")

-- ========================================
-- VARIABLES
-- ========================================
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
-- CONECTAR BOTONES DE COMPRA
-- ========================================

-- Conecta el BuyButton de un frame con la compra del pack
local function connectPackButton(packFrame, packID)
	local buyButton = packFrame:FindFirstChild(BUY_BUTTON_NAME)

	if not buyButton or not buyButton:IsA("TextButton") then
		warn(string.format("[ShopButton] ⚠️ No se encontró '%s' en %s", BUY_BUTTON_NAME, packFrame.Name))
		return false
	end

	-- Conectar evento de click
	buyButton.MouseButton1Click:Connect(function()
		print(string.format("[ShopButton] 🛒 Comprando Pack %d...", packID))
		PurchaseMoneyPackEvent:FireServer(packID)
	end)

	print(string.format("[ShopButton] ✅ %s conectado al Pack %d", packFrame.Name, packID))
	return true
end

-- Busca y conecta todos los frames de packs
local function setupPackButtons()
	local connectedCount = 0

	-- Buscar todos los frames en el ScrollingFrame
	for _, child in ipairs(packsScrolling:GetChildren()) do
		if child:IsA("Frame") then
			-- Extraer el número del nombre del frame (Frame1 → 1, Frame2 → 2, etc.)
			local frameName = child.Name
			local packNumber = tonumber(string.match(frameName, "%d+"))

			if packNumber then
				-- Conectar este frame con el pack correspondiente
				local success = connectPackButton(child, packNumber)
				if success then
					connectedCount = connectedCount + 1
				end
			else
				warn(string.format("[ShopButton] ⚠️ Frame '%s' no tiene un número válido", frameName))
			end
		end
	end

	if connectedCount > 0 then
		print(string.format("[ShopButton] ✅ %d packs conectados exitosamente", connectedCount))
	else
		warn("[ShopButton] ⚠️ No se encontraron frames de packs en PacksScrolling")
	end
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

-- Conectar botones de packs
task.spawn(function()
	task.wait(0.5)  -- Pequeña espera para asegurar que todo esté cargado
	setupPackButtons()
end)

print("[ShopButton] ✅ Sistema de tienda inicializado")
