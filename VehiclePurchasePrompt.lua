--[[
═══════════════════════════════════════════════════════════════
    VEHICLE PURCHASE PROMPT - Sistema de Compra de Vehículos
    Ubicación: Dentro del modelo del vehículo (como LocalScript hijo)

    INSTALACIÓN:
    1. Abre el modelo del vehículo en el Workspace
    2. Crea un nuevo **LocalScript** como hijo DIRECTO del modelo
    3. Nómbralo "VehiclePurchasePrompt"
    4. Pega este código dentro
    5. Configura las variables abajo

    ⚠️ IMPORTANTE: DEBE ser LocalScript, NO Script normal

    Funcionalidad:
    - Crea un ProximityPrompt para comprar el vehículo
    - Se comunica con VehicleOwnershipManager
    - Muestra precio y permite comprar
═══════════════════════════════════════════════════════════════
--]]

-- ⚙️ CONFIGURACIÓN (MODIFICA ESTOS VALORES)
local VEHICLE_NAME = "Carro"  -- Nombre único del vehículo (debe coincidir con VehicleLocker)
local VEHICLE_PRICE = 1000    -- Precio del vehículo en dinero
local PROMPT_ICON = "🚗"      -- Icono que se muestra (🚗 para carro, 🚁 para helicóptero)

-- ═══════════════════════════════════════════════════════════

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Referencia al modelo del vehículo
local vehicleModel = script.Parent

-- Verificar que el script esté en el lugar correcto
if not vehicleModel:IsA("Model") then
	warn("⚠️ VehiclePurchasePrompt debe ser hijo de un Model (el vehículo)")
	return
end

-- Buscar RemoteEvent (esperar hasta 10 segundos)
local purchaseVehicleEvent = ReplicatedStorage:WaitForChild("PurchaseVehicle", 10)
if not purchaseVehicleEvent then
	warn("⚠️ RemoteEvent 'PurchaseVehicle' no encontrado en ReplicatedStorage")
	return
end

print("🎮 VehiclePurchasePrompt (Cliente) iniciado para: " .. VEHICLE_NAME)

--[[
    Función: Crear punto de compra (ProximityPrompt)
--]]
local function createPurchasePrompt()
	-- Buscar la PrimaryPart del modelo (o usar la primera Part)
	local promptPart = vehicleModel.PrimaryPart or vehicleModel:FindFirstChildWhichIsA("BasePart")

	if not promptPart then
		warn("⚠️ No se encontró una Part para colocar el ProximityPrompt en " .. VEHICLE_NAME)
		return
	end

	-- Crear ProximityPrompt
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "VehiclePurchasePrompt"
	proximityPrompt.ObjectText = PROMPT_ICON .. " " .. VEHICLE_NAME
	proximityPrompt.ActionText = "Comprar ($" .. VEHICLE_PRICE .. ")"
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.HoldDuration = 1
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = promptPart

	-- Evento cuando se activa
	proximityPrompt.Triggered:Connect(function(player)
		print("🛒 Jugador " .. player.Name .. " presionó el botón de compra")
		print("   Vehículo: " .. VEHICLE_NAME)
		print("   Precio: $" .. VEHICLE_PRICE)
		print("   Enviando evento al servidor...")

		-- Enviar solicitud de compra al servidor
		-- NOTA: Se permite comprar múltiples veces (compras temporales)
		purchaseVehicleEvent:FireServer(VEHICLE_NAME, VEHICLE_PRICE)

		print("✅ Evento enviado al servidor")
	end)

	print("✅ ProximityPrompt de compra creado para: " .. VEHICLE_NAME)
end

-- Crear el prompt de compra
createPurchasePrompt()
