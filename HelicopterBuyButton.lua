--[[
═══════════════════════════════════════════════════════════════
    HELICOPTER BUY BUTTON
    Ubicación: Dentro de Button1 (como Script)

    INSTALACIÓN:
    1. Ve a Workspace → Helicopter → Button1
    2. Crea un nuevo Script (hijo de Button1)
    3. Nómbralo "BuyScript"
    4. Pega este código

    ⚠️ Script normal (servidor), NO LocalScript
    ⚠️ NO borres el script de regeneración que ya tiene Button1

    Funcionalidad:
    - Usa el ClickDetector existente para vender el helicóptero
    - Cuando hacen click, intenta vender
═══════════════════════════════════════════════════════════════
--]]

-- ⚙️ CONFIGURACIÓN
local VEHICLE_NAME = "Helicopter"
local VEHICLE_PRICE = 5000

-- ═══════════════════════════════════════════════════════════

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local button = script.Parent

-- Esperar a que SimpleVehicleSystem cargue
local maxWait = 10
local waited = 0
while not _G.SimpleVehicleSystem and waited < maxWait do
	task.wait(0.5)
	waited = waited + 0.5
end

if not _G.SimpleVehicleSystem then
	warn("❌ SimpleVehicleSystem no cargó!")
	return
end

print("🛒 BuyScript activado en Button1")

-- Buscar o crear ClickDetector
local clickDetector = button:FindFirstChild("ClickDetector")
if not clickDetector then
	clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = button
	print("✅ ClickDetector creado")
end

-- Crear BillboardGui para mostrar el precio
local billboard = Instance.new("BillboardGui")
billboard.Name = "PriceTag"
billboard.Size = UDim2.new(0, 200, 0, 50)
billboard.StudsOffset = Vector3.new(0, 3, 0)
billboard.AlwaysOnTop = true
billboard.Parent = button

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
textLabel.BackgroundTransparency = 0.5
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "🚁 COMPRAR HELICOPTER\n$" .. VEHICLE_PRICE
textLabel.Parent = billboard

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = textLabel

print("✅ Cartel de precio creado")

-- Cuando hacen click en el botón
clickDetector.MouseClick:Connect(function(player)
	print("🛒 " .. player.Name .. " hizo click en el botón de compra")

	-- Intentar comprar
	local success = _G.SimpleVehicleSystem.BuyVehicle(player, VEHICLE_NAME, VEHICLE_PRICE)

	if success then
		print("✅ Compra exitosa para " .. player.Name)
	else
		print("❌ Compra fallida para " .. player.Name)
	end
end)

print("✅ Sistema de compra conectado al ClickDetector")
