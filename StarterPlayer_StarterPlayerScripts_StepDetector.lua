-- StarterPlayer > StarterPlayerScripts > StepDetector
-- Detecta los pasos del jugador y otorga +1 EXP por cada paso

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Esperar RemoteEvent
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AddStepEXPEvent = RemoteEvents:WaitForChild("AddStepEXP", 10)

if not AddStepEXPEvent then
	warn("[StepDetector] ❌ No se encontró RemoteEvent 'AddStepEXP'")
	return
end

-- ==================== CONFIGURACIÓN ====================
local STUDS_PER_STEP = 2.5          -- Distancia en studs para contar 1 paso
local MIN_WALK_SPEED = 1            -- Velocidad mínima para contar como caminando

-- ==================== VARIABLES ====================
local lastPosition = rootPart.Position
local accumulatedDistance = 0
local totalSteps = 0

-- ==================== DETECCIÓN DE PASOS ====================

-- Actualizar cada frame
RunService.Heartbeat:Connect(function(deltaTime)
	-- Verificar que el personaje existe
	if not character or not character.Parent then
		character = player.Character
		if character then
			humanoid = character:FindFirstChild("Humanoid")
			rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				lastPosition = rootPart.Position
			end
		end
		return
	end

	-- Verificar que el humanoid existe y está vivo
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	-- Verificar que se está moviendo
	local moveDirection = humanoid.MoveDirection
	local isMoving = moveDirection.Magnitude > 0.1

	if isMoving and rootPart then
		local currentPosition = rootPart.Position

		-- Calcular distancia recorrida (solo en el plano XZ, ignorar Y para saltos)
		local distance2D = Vector2.new(
			currentPosition.X - lastPosition.X,
			currentPosition.Z - lastPosition.Z
		).Magnitude

		-- Acumular distancia
		accumulatedDistance = accumulatedDistance + distance2D

		-- Si acumulamos suficiente distancia, contar un paso
		while accumulatedDistance >= STUDS_PER_STEP do
			accumulatedDistance = accumulatedDistance - STUDS_PER_STEP
			totalSteps = totalSteps + 1

			-- Enviar al servidor para otorgar +1 EXP
			AddStepEXPEvent:FireServer()
		end

		-- Actualizar última posición
		lastPosition = currentPosition
	end
end)

-- Resetear cuando el personaje muere
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	lastPosition = rootPart.Position
	accumulatedDistance = 0
end)

print("[StepDetector] ✅ Sistema de detección de pasos iniciado")
print(string.format("[StepDetector] 📏 %d studs = 1 paso", STUDS_PER_STEP))
