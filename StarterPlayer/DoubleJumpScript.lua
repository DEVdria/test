-- StarterPlayer > StarterCharacterScripts > DoubleJumpScript (LocalScript)
-- Permite a los jugadores con el gamepass de Double Jump saltar en el aire

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Esperar al jugador y verificar si tiene el gamepass
wait(0.5) -- Pequeña espera para asegurar que el BoolValue esté sincronizado

-- Verificar si el jugador tiene el gamepass de DoubleJump activado
local doubleJumpEnabled = player:FindFirstChild("DoubleJumpEnabled")

if not doubleJumpEnabled or not doubleJumpEnabled.Value then
	-- El jugador no tiene el gamepass, no hacer nada
	script:Destroy()
	return
end

print("DoubleJump activado para " .. player.Name .. " en este personaje")

-- Variables del double jump
local canDoubleJump = false
local hasDoubleJumped = false
local jumpPower = 50 -- Fuerza del double jump

-- Detectar cuando el jugador está en el suelo o en el aire
humanoid.StateChanged:Connect(function(oldState, newState)
	-- Si el jugador está en el aire (cayendo), puede hacer double jump
	if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Flying then
		if oldState == Enum.HumanoidStateType.Jumping then
			-- Acaba de saltar, ahora puede hacer double jump
			canDoubleJump = true
		end
	end

	-- Si el jugador aterriza, resetear el double jump
	if newState == Enum.HumanoidStateType.Landed then
		canDoubleJump = false
		hasDoubleJumped = false
	end
end)

-- Detectar cuando el jugador presiona espacio (salto)
UserInputService.JumpRequest:Connect(function()
	-- Verificar que el humanoid y rootPart sigan existiendo
	if not humanoid or not humanoid.Parent then return end
	if not rootPart or not rootPart.Parent then return end

	-- Si está en el aire, no ha hecho double jump aún, puede hacerlo, y no está nadando
	if canDoubleJump and not hasDoubleJumped then
		local state = humanoid:GetState()
		if state ~= Enum.HumanoidStateType.Swimming then
			hasDoubleJumped = true
			canDoubleJump = false

			-- Aplicar el segundo salto
			-- Resetear la velocidad vertical para que el salto sea consistente
			local velocity = rootPart.AssemblyLinearVelocity
			rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)

			-- Cambiar el estado a Jumping para activar el salto
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

			-- Aplicar un impulso adicional para que se note el double jump
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(0, jumpPower, 0)
			bodyVelocity.MaxForce = Vector3.new(0, 10000, 0)
			bodyVelocity.Parent = rootPart

			-- Eliminar el BodyVelocity después de un momento
			task.delay(0.1, function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end
			end)

			print(player.Name .. " hizo double jump!")
		end
	end
end)
