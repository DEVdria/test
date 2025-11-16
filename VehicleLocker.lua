--[[
═══════════════════════════════════════════════════════════════
    VEHICLE LOCKER - Bloquea vehículos hasta que se compren
    Ubicación: Dentro del modelo del vehículo (como Script hijo)

    INSTALACIÓN:
    1. Abre el modelo del vehículo en el Workspace
    2. Crea un nuevo Script como hijo DIRECTO del modelo
    3. Nómbralo "VehicleLocker"
    4. Pega este código dentro
    5. Configura las variables abajo

    IMPORTANTE: NO modifiques los scripts originales del creador.
    Este script se ejecuta en paralelo y bloquea el acceso.
═══════════════════════════════════════════════════════════════
--]]

-- ⚙️ CONFIGURACIÓN (MODIFICA ESTOS VALORES)
local VEHICLE_NAME = "Carro"  -- Nombre único del vehículo (debe coincidir con el ProximityPrompt)
local LOCK_MESSAGE_ENABLED = true -- Mostrar mensaje cuando intenta usar sin comprar

-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Referencia al modelo del vehículo (este script debe ser hijo del modelo)
local vehicleModel = script.Parent

-- Verificar que el script esté en el lugar correcto
if not vehicleModel:IsA("Model") then
	warn("⚠️ VehicleLocker debe ser hijo de un Model (el vehículo)")
	return
end

-- Tabla para rastrear jugadores expulsados recientemente (evitar spam)
local recentlyKicked = {}

--[[
    Función: Verificar si un jugador puede usar este vehículo
    Parámetros: player - El jugador
    Retorna: true si puede usar, false si no
--]]
local function canUseVehicle(player)
	-- Esperar a que el sistema global esté cargado
	if not _G.VehicleOwnership then
		return false
	end

	-- Verificar propiedad
	return _G.VehicleOwnership.OwnsVehicle(player, VEHICLE_NAME)
end

--[[
    Función: Matar a un jugador que usa el vehículo sin comprar
    Parámetros:
        player - El jugador a matar
--]]
local function killPlayer(player)
	-- Evitar spam de mensajes
	if recentlyKicked[player.UserId] then
		return
	end

	recentlyKicked[player.UserId] = true

	-- Mensaje de advertencia
	if LOCK_MESSAGE_ENABLED then
		local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
		if notificationEvent then
			notificationEvent:FireClient(
				player,
				"🔒 Debes comprar " .. VEHICLE_NAME .. " para usarlo",
				Color3.fromRGB(255, 85, 85)
			)
		end
	end

	-- Matar al jugador después de 1 segundo
	task.delay(1, function()
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Health = 0
				print("💀 " .. player.Name .. " murió por usar " .. VEHICLE_NAME .. " sin comprarlo")
			end
		end
	end)

	-- Cooldown para evitar spam
	task.delay(2, function()
		recentlyKicked[player.UserId] = nil
	end)
end

--[[
    Función: Configurar bloqueo en un asiento
    Parámetros: seat - El asiento a bloquear
--]]
local function lockSeat(seat)
	-- Solo asientos y asientos de vehículo
	if not (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
		return
	end

	-- Evento cuando alguien se sienta
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = seat.Occupant

		if occupant then
			-- Encontrar al jugador que se sentó
			local character = occupant.Parent
			local player = Players:GetPlayerFromCharacter(character)

			if player then
				-- Verificar si puede usar el vehículo
				if not canUseVehicle(player) then
					-- Matar al jugador
					killPlayer(player)
				end
			end
		end
	end)
end

--[[
    Buscar y bloquear todos los asientos del vehículo
--]]
local function lockAllSeats()
	for _, descendant in pairs(vehicleModel:GetDescendants()) do
		if descendant:IsA("VehicleSeat") or descendant:IsA("Seat") then
			lockSeat(descendant)
			print("🔒 Asiento bloqueado: " .. descendant:GetFullName())
		end
	end
end

-- Esperar a que el VehicleOwnership esté cargado
local maxWaitTime = 10
local waitTime = 0
while not _G.VehicleOwnership and waitTime < maxWaitTime do
	task.wait(0.5)
	waitTime = waitTime + 0.5
end

if not _G.VehicleOwnership then
	warn("⚠️ VehicleOwnership no se cargó. Asegúrate de que VehicleOwnershipManager.lua esté en ServerScriptService")
	return
end

-- Bloquear asientos existentes
lockAllSeats()

-- Bloquear nuevos asientos que se añadan
vehicleModel.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("VehicleSeat") or descendant:IsA("Seat") then
		lockSeat(descendant)
	end
end)

print("✅ VehicleLocker activado para: " .. VEHICLE_NAME)
