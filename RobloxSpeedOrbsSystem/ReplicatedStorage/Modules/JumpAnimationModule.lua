--[[
	MÓDULO DE ANIMACIÓN DE SALTO (CLIENTE)
	Ubicación: ReplicatedStorage/Modules/JumpAnimationModule
	Descripción: Gestiona la animación personalizada de salto
]]

local JumpAnimationModule = {}
JumpAnimationModule.__index = JumpAnimationModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.Config)

function JumpAnimationModule.new(player)
	local self = setmetatable({}, JumpAnimationModule)

	self.Player = player
	self.JumpAnimation = nil
	self.JumpAnimTrack = nil
	self.StateConnection = nil

	return self
end

function JumpAnimationModule:Initialize()
	local character = self.Player.Character or self.Player.CharacterAdded:Wait()

	-- Cargar animación de salto
	self:LoadJumpAnimation()

	-- Conectar evento de estado del humanoid
	self:ConnectJumpEvent()

	-- Reconectar cuando el jugador reaparezca
	self.Player.CharacterAdded:Connect(function(newCharacter)
		self:Cleanup()
		task.wait(0.5) -- Esperar a que el personaje cargue
		self:LoadJumpAnimation()
		self:ConnectJumpEvent()
	end)
end

function JumpAnimationModule:LoadJumpAnimation()
	local character = self.Player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Si ya hay una animación cargada, limpiarla
	if self.JumpAnimTrack then
		self.JumpAnimTrack:Stop()
		self.JumpAnimTrack:Destroy()
		self.JumpAnimTrack = nil
	end

	-- Cargar animación si está configurada
	if Config.JumpAnimationId and Config.JumpAnimationId ~= "" then
		self.JumpAnimation = Instance.new("Animation")
		self.JumpAnimation.AnimationId = Config.JumpAnimationId

		self.JumpAnimTrack = humanoid:LoadAnimation(self.JumpAnimation)
	end
end

function JumpAnimationModule:ConnectJumpEvent()
	local character = self.Player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Desconectar conexión anterior si existe
	if self.StateConnection then
		self.StateConnection:Disconnect()
	end

	-- Detectar cuando el jugador salta
	self.StateConnection = humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Jumping then
			self:PlayJumpAnimation()
		end
	end)
end

function JumpAnimationModule:PlayJumpAnimation()
	if self.JumpAnimTrack and not self.JumpAnimTrack.IsPlaying then
		self.JumpAnimTrack:Play()
	end
end

function JumpAnimationModule:Cleanup()
	if self.StateConnection then
		self.StateConnection:Disconnect()
		self.StateConnection = nil
	end

	if self.JumpAnimTrack then
		self.JumpAnimTrack:Stop()
		self.JumpAnimTrack:Destroy()
		self.JumpAnimTrack = nil
	end

	if self.JumpAnimation then
		self.JumpAnimation:Destroy()
		self.JumpAnimation = nil
	end
end

return JumpAnimationModule
