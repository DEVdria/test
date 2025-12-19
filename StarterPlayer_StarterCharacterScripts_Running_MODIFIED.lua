-- StarterPlayer > StarterCharacterScripts > Running
-- Sistema de sprint integrado con sistema de niveles
-- MODIFICADO PARA USAR VELOCIDAD POR NIVEL (No velocidad acumulada)
-- MODO TOGGLE: El running se activa/desactiva con una sola tecla/botón
--              Se puede activar incluso estando quieto
--              No se desactiva automáticamente al detenerse

-- -=/GETTING CHARACTER/=-
local plr = game.Players.LocalPlayer
local Character = plr.Character or plr.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- -=/SERVICES & CAMERA/=-
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

-- -=/MÓDULOS/=-
local Modules = ReplicatedStorage:WaitForChild("Modules")
local LevelManager = require(Modules:WaitForChild("LevelManager"))

-- -=/REMOTE EVENTS/=-
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LevelUpEvent = RemoteEvents:FindFirstChild("LevelUp")

-- -=/VELOCIDAD POR NIVEL/=-
local currentRunSpeed = 24  -- Velocidad base por defecto

-- Función para obtener la velocidad actual del jugador según su nivel
local function getPlayerRunSpeed()
	local leaderstats = plr:FindFirstChild("leaderstats")
	if leaderstats then
		local levelValue = leaderstats:FindFirstChild("Level")
		if levelValue then
			local level = levelValue.Value
			return LevelManager.GetRunSpeed(level)
		end
	end
	return 24  -- Velocidad base si no se encuentra el nivel
end

-- Cargar velocidad inicial
task.spawn(function()
	task.wait(1)  -- Esperar a que leaderstats se cree
	currentRunSpeed = getPlayerRunSpeed()
end)

-- Escuchar cuando el jugador sube de nivel
if LevelUpEvent then
	LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
		currentRunSpeed = newSpeed
		print(string.format("[Running] ¡Nivel %d alcanzado! Nueva velocidad: %d", newLevel, newSpeed))
	end)
end

----------------- { CONFIGURATION } ---------------------

local config = {
	RunButtons = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightControl},
	RunningCooldown = 0.1,
	BaseSpeed = 24,                              -- Velocidad base (no se usa directamente)
	RunJumpPower = 45,
	DefaultFieldOfView = 70,
	SprintFieldOfView = 85,
	CameraFOVSprintTime = 0.5,
	CameraFOVResetTime = 1,
	JumpCooldownEnabled = false,
	JumpCooldownTime = 1.5,
	RunEnabled = true,
	DustEnabled = true,
	DynamicDustColor = true,
	DustSpawnRate = 0.15,
	LinesEnabled = true,
	StopOnClimbing = true,
	CrouchingEnabled = false
}

---------------------------------------------------------

-- -=/ANIMATIONS/=-
local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
local RunAnim = Animator:LoadAnimation(script:WaitForChild("Sprint"))
local JumpAnim = Animator:LoadAnimation(script:WaitForChild("Jump"))

-- -=/VARIABLES/=-
local notMoving = true
local isOnGround = true
local Jumped = false
local runDebounce = true
local dustDebounce = true
local jumpDebounce = true
local originalSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower
local lastPosition = Character.PrimaryPart.Position
local mobileButton = nil
local mobileButtonConnection

-- -=/SETTING CAMERA FOV/=-
Camera.FieldOfView = config.DefaultFieldOfView

-- -=/INITIAL ATTRIBUTE SETUP/=-
if RootPart:GetAttribute("IsRunning") == nil then
	RootPart:SetAttribute("IsRunning", false)
end

if RootPart:GetAttribute("RunEnabled") == nil then
	if config.RunEnabled == true then
		RootPart:SetAttribute("RunEnabled", true)
	else
		RootPart:SetAttribute("RunEnabled", false)
	end
end

-- -=/RUN KEY CHECK/=-
local function runKey(input)
	local runKeys = (typeof(config.RunButtons) == "table") and config.RunButtons or {config.RunButtons}

	for _, key in ipairs(runKeys) do
		if input.KeyCode == key then
			return true
		end
	end
	return false
end

-- -=/RUN FUNCTION (TOGGLE MODE)/=-
local function Run()
	if not runDebounce then return end
	-- MODO TOGGLE: Se puede activar incluso estando quieto
	if not RootPart:GetAttribute("IsRunning") and RootPart:GetAttribute("RunEnabled") and isOnGround then
		runDebounce = false

		RootPart:SetAttribute("IsRunning", true)
		RunAnim:Play()

		-- USAR VELOCIDAD BASADA EN NIVEL
		Humanoid.WalkSpeed = currentRunSpeed
		Humanoid.JumpPower = config.RunJumpPower
		TweenService:Create(Camera, TweenInfo.new(config.CameraFOVSprintTime), {FieldOfView = config.SprintFieldOfView}):Play()

		task.delay(config.RunningCooldown, function()
			runDebounce = true
		end)
	end
end

-- -=/STOP FUNCTION/=-
local function Stop()
	if RootPart:GetAttribute("IsRunning") then
		RootPart:SetAttribute("IsRunning", false)
		RunAnim:Stop()
		Humanoid.WalkSpeed = originalSpeed
		Humanoid.JumpPower = originalJumpPower
		TweenService:Create(Camera, TweenInfo.new(config.CameraFOVResetTime), {FieldOfView = config.DefaultFieldOfView}):Play()
	end
end

-- -=/MOBILE BUTTON HANDLER/=-
local function MobileButton()
	if mobileButton then
		if mobileButtonConnection then
			mobileButtonConnection:Disconnect()
		end

		mobileButtonConnection = mobileButton.MouseButton1Click:Connect(function()
			if not RootPart:GetAttribute("IsRunning") then
				if config.CrouchingEnabled and RootPart:GetAttribute("IsCrouching") then
					return
				end
				Run()
			else
				Stop()
			end
		end)
	else
		warn("MobileButton not found!")
	end
end

-- -=/FINDING MOBILE BUTTON/=-
task.spawn(function()
	local gui = plr:WaitForChild("PlayerGui"):FindFirstChild("MobileGUI")
	if gui then
		local buttons = gui:FindFirstChild("MobileButtons")
		if buttons then
			mobileButton = buttons:WaitForChild("RunButton")

			MobileButton()
		end
	end
end)

-- -=/KEY INPUT HANDLER (TOGGLE MODE)/=-
UIS.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if runKey(input) then
		if config.CrouchingEnabled and RootPart:GetAttribute("IsCrouching") then
			return
		end
		-- MODO TOGGLE: Alternar entre running y normal con una sola tecla
		if not RootPart:GetAttribute("IsRunning") then
			Run()
		else
			Stop()
		end
	end
end)

-- -=/KEY RELEASE HANDLER (DESACTIVADO EN MODO TOGGLE)/=-
-- En modo toggle no se necesita, pero lo dejamos aquí comentado por si se quiere cambiar el comportamiento
-- UIS.InputEnded:Connect(function(input)
-- 	if runKey(input) then
-- 		Stop()
-- 	end
-- end)

-- -=/STATE CHANGES HANDLER/=-
local function onStateChanged(_, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		if not Jumped and RootPart:GetAttribute("IsRunning") then
			Jumped = true
			jumpDebounce = false
			RunAnim:Stop()
			JumpAnim:Play()

			if config.JumpCooldownEnabled then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

				task.delay(config.JumpCooldownTime or 1, function()
					jumpDebounce = true
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end)
			end
		end

	elseif newState == Enum.HumanoidStateType.Landed then
		Jumped = false
		if RootPart:GetAttribute("IsRunning") then
			if not RunAnim.IsPlaying then
				RunAnim:Play()
			end
		else
			RunAnim:Stop()
		end

	elseif newState == Enum.HumanoidStateType.Freefall then
		if RootPart:GetAttribute("IsRunning") then
			RunAnim:Stop()
		end
	end

	if RootPart:GetAttribute("IsRunning") then
		if newState == Enum.HumanoidStateType.Physics
			or newState == Enum.HumanoidStateType.Seated
			or newState == Enum.HumanoidStateType.Swimming
			or newState == Enum.HumanoidStateType.Dead
			or (config.StopOnClimbing and newState == Enum.HumanoidStateType.Climbing) then
			Stop()
		end
	end
end

-- -=/HEARTBEAT LOOP/=-
RunService.Heartbeat:Connect(function()

	-- -=/ACTUALIZAR VELOCIDAD SI ESTÁ CORRIENDO/=-
	if RootPart:GetAttribute("IsRunning") then
		-- Asegurarse de que la velocidad sea la correcta
		if Humanoid.WalkSpeed ~= currentRunSpeed then
			Humanoid.WalkSpeed = currentRunSpeed
		end
	end

	-- -=/NON-MOVEMENT CHECK (DESACTIVADO EN MODO TOGGLE)/=-
	-- En modo toggle, el running NO se detiene automáticamente al detenerse
	-- El jugador debe presionar la tecla/botón de nuevo para desactivarlo
	-- notMoving = Humanoid.MoveDirection.Magnitude < 0.1
	-- if notMoving and RootPart:GetAttribute("IsRunning") then
	-- 	Stop()
	-- end

	-- -=/RUNNING ENABLED VALUE CHECK/=-
	if RootPart:GetAttribute("IsRunning") and not RootPart:GetAttribute("RunEnabled") then
		Stop()
	end

	-- -=/GROUND CHECK/=-
	isOnGround = Humanoid.FloorMaterial ~= Enum.Material.Air

	-- -=/DUST PARTICLES/=-
	if config.DustEnabled and isOnGround and RootPart:GetAttribute("IsRunning") and dustDebounce then
		dustDebounce = false

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {Character}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = workspace:Raycast(
			RootPart.Position + Vector3.new(0, 1, 0),
			Vector3.new(0, -4.5, 0),
			rayParams
		)

		local dustTemplate = game.ReplicatedStorage:FindFirstChild("VFX") and game.ReplicatedStorage.VFX:FindFirstChild("Dust")
		if dustTemplate then
			local dust = game.ReplicatedStorage.VFX.Dust:Clone()
			dust.Position = RootPart.Position + Vector3.new(0, -2.5, 0)
			dust.Parent = workspace.FX
			dust.Name = "RunDust"

			if config.DynamicDustColor then
				if rayResult then
					local hitPart = rayResult.Instance
					if hitPart and hitPart:IsA("BasePart") then
						dust.Attachment.Dust.Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, hitPart.Color),
							ColorSequenceKeypoint.new(1, hitPart.Color)
						}
					end
				end
			else
				dust.Attachment.Dust.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			end

			dust.Attachment.Dust:Emit(1)
			game.Debris:AddItem(dust, 0.8)

			task.wait(config.DustSpawnRate)
			dustDebounce = true
		end
	end

	-- -=/RUNNING LINES/=-
	if config.LinesEnabled and RootPart:GetAttribute("IsRunning") then
		local currentPosition = Character.PrimaryPart.Position
		local lastGroundedPosition = Vector3.new(lastPosition.X, currentPosition.Y, lastPosition.Z)

		for i = 1, math.random(0,1) do
			local rp = Instance.new("Part", workspace.FX)
			rp.Anchored = true
			rp.CanCollide = false
			rp.Name = "RunParticle"
			rp.Material = Enum.Material.SmoothPlastic
			rp.CanQuery = false
			rp.Size = Vector3.new(0.03, 0.03, math.random(1.75, 3.25))

			local transparentValues = {0.5, 0.6, 0.7, 0.8}

			local colors = {
				Color3.fromRGB(107, 107, 107),
				Color3.fromRGB(175, 175, 175),
				Color3.fromRGB(148, 148, 148)
			}

			rp.Color = colors[math.random(1, #colors)]
			rp.Transparency = transparentValues[math.random(1, #transparentValues)]

			local dirCFrame = CFrame.new(lastGroundedPosition, Vector3.new(currentPosition.X, lastGroundedPosition.Y, currentPosition.Z))
			dirCFrame = dirCFrame * CFrame.new(0, -1.3, 1.5)
			rp.CFrame = dirCFrame * CFrame.new(math.random(-15, 15)/10,math.random(-2.5, 2.5), math.random(-2, 2))

			game.Debris:AddItem(rp, 0.75)
			TweenService:Create(rp,TweenInfo.new(0.75), {Transparency = 1, Size = Vector3.new(0, 0, 0), CFrame = rp.CFrame * CFrame.new (0,0,math.random(2.5, 4))}):Play()
		end
	end
	lastPosition = Character.PrimaryPart.Position
end)

Humanoid.StateChanged:Connect(onStateChanged)
