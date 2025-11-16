--[[
═══════════════════════════════════════════════════════════════
    HELICOPTER SEAT CHECKER
    Ubicación: Dentro del VehicleSeat del helicóptero (como Script)

    INSTALACIÓN:
    1. Ve a Workspace → Helicopter → Heli → VehicleSeat
    2. Crea un nuevo Script (hijo del VehicleSeat)
    3. Nómbralo "SeatChecker"
    4. Pega este código

    ⚠️ NO borres el script original del creador
    ⚠️ Este script se ejecuta en paralelo

    Funcionalidad:
    - Detecta cuando alguien se sienta
    - Verifica si compró el helicóptero
    - Si no compró, muestra mensaje y lo mata 1 segundo después
═══════════════════════════════════════════════════════════════
--]]

-- ⚙️ CONFIGURACIÓN
local VEHICLE_NAME = "Helicopter"  -- Nombre del vehículo (debe coincidir con el ProximityPrompt)

-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local seat = script.Parent

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

print("🔒 SeatChecker activado en " .. seat:GetFullName())

-- Detectar cuando alguien se sienta
seat.ChildAdded:Connect(function(child)
	if child.Name == "SeatWeld" then
		-- Esperar un poco para que el jugador esté completamente sentado
		task.wait(0.1)

		-- Encontrar al jugador
		local character = seat.Occupant
		if not character then return end

		local player = Players:GetPlayerFromCharacter(character.Parent)
		if not player then return end

		print("🪑 " .. player.Name .. " se sentó en " .. VEHICLE_NAME)

		-- Verificar si compró el vehículo
		if not _G.SimpleVehicleSystem.OwnsVehicle(player, VEHICLE_NAME) then
			print("❌ " .. player.Name .. " NO ha comprado " .. VEHICLE_NAME)

			-- Mostrar mensaje
			local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
			if notificationEvent then
				notificationEvent:FireClient(
					player,
					"🔒 Debes comprar " .. VEHICLE_NAME .. " para usarlo",
					Color3.fromRGB(255, 85, 85)
				)
			end

			-- Matar después de 1 segundo
			task.delay(1, function()
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.Health = 0
						print("💀 " .. player.Name .. " murió por usar " .. VEHICLE_NAME .. " sin comprar")
					end
				end
			end)
		else
			print("✅ " .. player.Name .. " SÍ ha comprado " .. VEHICLE_NAME .. " - Permitido")
		end
	end
end)
