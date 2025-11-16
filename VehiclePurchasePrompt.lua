--[[
═══════════════════════════════════════════════════════════════
    VEHICLE PURCHASE PROMPT - Sistema de Compra de Vehículos
    Ubicación: Dentro del modelo del vehículo (como Script hijo)

    INSTALACIÓN:
    1. Abre el modelo del vehículo en el Workspace
    2. Crea un nuevo Script como hijo DIRECTO del modelo
    3. Nómbralo "VehiclePurchasePrompt"
    4. Pega este código dentro
    5. Configura las variables abajo

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

-- Esperar a que el sistema global esté cargado
local maxWaitTime = 10
local waitTime = 0
while not _G.VehicleOwnership and waitTime < maxWaitTime do
	task.wait(0.5)
	waitTime = waitTime + 0.5
end

if not _G.VehicleOwnership then
	warn("⚠️ VehicleOwnership no se cargó")
	return
end

-- Buscar RemoteEvent
local purchaseVehicleEvent = ReplicatedStorage:WaitForChild("PurchaseVehicle", 10)
if not purchaseVehicleEvent then
	warn("⚠️ RemoteEvent 'PurchaseVehicle' no encontrado")
	return
end

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
		-- Verificar si ya lo posee
		if _G.VehicleOwnership.OwnsVehicle(player, VEHICLE_NAME) then
			local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
			if notificationEvent then
				notificationEvent:FireClient(
					player,
					"✅ Ya posees " .. VEHICLE_NAME,
					Color3.fromRGB(85, 255, 127)
				)
			end
			return
		end

		-- Enviar solicitud de compra al servidor
		purchaseVehicleEvent:FireServer(VEHICLE_NAME, VEHICLE_PRICE)
	end)

	print("✅ ProximityPrompt de compra creado para: " .. VEHICLE_NAME)
end

-- Crear el prompt de compra
createPurchasePrompt()

-- Actualizar texto del prompt dinámicamente
task.spawn(function()
	while true do
		task.wait(1)

		-- Buscar el prompt
		local prompt = vehicleModel:FindFirstChild("VehiclePurchasePrompt", true)
		if prompt then
			-- Para cada jugador cercano, actualizar el texto
			for _, player in pairs(Players:GetPlayers()) do
				if _G.VehicleOwnership.OwnsVehicle(player, VEHICLE_NAME) then
					-- Si ya lo posee, cambiar el texto
					prompt.ActionText = "✅ Ya poseído"
				else
					-- Si no lo posee, mostrar precio
					prompt.ActionText = "Comprar ($" .. VEHICLE_PRICE .. ")"
				end
			end
		end
	end
end)
