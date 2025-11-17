-- StarterPlayer > StarterCharacterScripts > DoubleJumpScript (LocalScript)
-- Permite a los jugadores con el gamepass de Double Jump saltar en el aire

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Verificar si el jugador tiene el gamepass de DoubleJump activado
local doubleJumpEnabled = player:WaitForChild("DoubleJumpEnabled", 5)

if not doubleJumpEnabled or not doubleJumpEnabled.Value then
	-- El jugador no tiene el gamepass, no hacer nada
	return
end

-- Variables del double jump
local canDoubleJump = false
local hasDoubleJumped = false

-- Detectar cuando el jugador está en el aire
humanoid.StateChanged:Connect(function(oldState, newState)
	-- Si el jugador está en el aire después de saltar, puede hacer double jump
	if newState == Enum.HumanoidStateType.Freefall then
		canDoubleJump = true
	end

	-- Si el jugador aterriza, resetear el double jump
	if newState == Enum.HumanoidStateType.Landed then
		canDoubleJump = false
		hasDoubleJumped = false
	end
end)

-- Detectar cuando el jugador presiona espacio
UserInputService.JumpRequest:Connect(function()
	-- Si está en el aire, no ha hecho double jump aún, y puede hacerlo
	if canDoubleJump and not hasDoubleJumped then
		hasDoubleJumped = true
		canDoubleJump = false

		-- Aplicar fuerza hacia arriba
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			-- Resetear velocidad vertical y aplicar impulso
			local velocity = rootPart.AssemblyLinearVelocity
			rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)

			-- Aplicar el salto
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

print("DoubleJump activado para " .. player.Name)
