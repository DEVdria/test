--[[
═══════════════════════════════════════════════════════════════
    HELICOPTER BUY BUTTON
    Ubicación: Dentro del modelo Helicopter (como LocalScript)

    INSTALACIÓN:
    1. Ve a Workspace → Helicopter
    2. Crea un nuevo LocalScript (hijo del modelo Helicopter)
    3. Nómbralo "BuyButton"
    4. Pega este código

    ⚠️ DEBE ser LocalScript, NO Script

    Funcionalidad:
    - Crea un ProximityPrompt para comprar el helicóptero
    - Al presionar, envía solicitud de compra al servidor
═══════════════════════════════════════════════════════════════
--]]

-- ⚙️ CONFIGURACIÓN
local VEHICLE_NAME = "Helicopter"
local VEHICLE_PRICE = 5000
local PROMPT_ICON = "🚁"

-- ═══════════════════════════════════════════════════════════

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local helicopterModel = script.Parent

-- Esperar el RemoteEvent
local buyVehicleEvent = ReplicatedStorage:WaitForChild("BuyVehicle", 10)
if not buyVehicleEvent then
	warn("❌ BuyVehicle RemoteEvent no encontrado")
	return
end

print("🎮 BuyButton (Cliente) iniciado para " .. VEHICLE_NAME)

-- Buscar una Part donde colocar el ProximityPrompt
local promptPart = helicopterModel:FindFirstChild("Button1")
if not promptPart then
	promptPart = helicopterModel.PrimaryPart
end
if not promptPart then
	promptPart = helicopterModel:FindFirstChildWhichIsA("BasePart", true)
end

if not promptPart then
	warn("❌ No se encontró una Part para el ProximityPrompt")
	return
end

-- Crear ProximityPrompt
local proximityPrompt = Instance.new("ProximityPrompt")
proximityPrompt.Name = "BuyHelicopterPrompt"
proximityPrompt.ObjectText = PROMPT_ICON .. " " .. VEHICLE_NAME
proximityPrompt.ActionText = "Comprar ($" .. VEHICLE_PRICE .. ")"
proximityPrompt.MaxActivationDistance = 10
proximityPrompt.HoldDuration = 1
proximityPrompt.RequiresLineOfSight = false
proximityPrompt.Parent = promptPart

print("✅ ProximityPrompt creado en: " .. promptPart.Name)

-- Cuando se presiona
proximityPrompt.Triggered:Connect(function()
	print("🛒 Presionado botón de compra de " .. VEHICLE_NAME)
	print("   Enviando al servidor: " .. VEHICLE_NAME .. ", $" .. VEHICLE_PRICE)

	-- Enviar al servidor
	buyVehicleEvent:FireServer(VEHICLE_NAME, VEHICLE_PRICE)

	print("✅ Evento enviado")
end)
