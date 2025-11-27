--[[
	MÓDULO DE SPRINT (CLIENTE)
	Ubicación: ReplicatedStorage/Modules/SprintModule
	Descripción: Gestiona el sistema de sprint sin modificar directamente Humanoid.WalkSpeed
]]

local SprintModule = {}
SprintModule.__index = SprintModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Modules.Config)

function SprintModule.new(player, orbsModule)
	local self = setmetatable({}, SprintModule)

	self.Player = player
	self.OrbsModule = orbsModule
	self._isSprinting = false -- Propiedad privada (con guión bajo para evitar conflicto)
	self.IsEnabled = true
	self.Connection = nil
	self.SprintAnimation = nil
	self.SprintAnimTrack = nil

	return self
end

function SprintModule:Initialize()
	local character = self.Player.Character or self.Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Establecer velocidad base
	humanoid.WalkSpeed = Config.BaseWalkSpeed

	-- Configurar input para PC (SHIFT)
	self:SetupPCInput()

	-- Actualizar velocidad constantemente
	self:StartSpeedUpdate()

	-- Reconectar cuando el jugador reaparezca
	self.Player.CharacterAdded:Connect(function(newCharacter)
		local newHumanoid = newCharacter:WaitForChild("Humanoid")
		newHumanoid.WalkSpeed = Config.BaseWalkSpeed
		self:StartSpeedUpdate()
	end)
end

function SprintModule:SetupPCInput()
	-- Input para PC (SHIFT)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Config.SprintKey then
			self:SetSprinting(true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Config.SprintKey then
			self:SetSprinting(false)
		end
	end)
end

function SprintModule:SetSprinting(sprinting)
	if not self.IsEnabled then return end
	self._isSprinting = sprinting

	-- Gestionar animación de sprint
	self:UpdateSprintAnimation()
end

function SprintModule:ToggleSprint()
	self:SetSprinting(not self._isSprinting)
end

function SprintModule:StartSpeedUpdate()
	-- Desconectar conexión anterior si existe
	if self.Connection then
		self.Connection:Disconnect()
	end

	-- Actualizar velocidad cada frame
	self.Connection = RunService.Heartbeat:Connect(function()
		local character = self.Player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		-- Calcular velocidad
		local targetSpeed = self:GetCurrentSpeed()

		-- Aplicar velocidad
		humanoid.WalkSpeed = targetSpeed
	end)
end

function SprintModule:GetCurrentSpeed()
	local baseSpeed = Config.BaseWalkSpeed
	local speedBoost = self.OrbsModule:GetSpeedBoost()

	if self._isSprinting then
		-- Sprint activado: Base + Boost
		return Config.BaseSprintSpeed + speedBoost
	else
		-- Sin sprint: solo base
		return baseSpeed
	end
end

function SprintModule:IsSprinting()
	return self._isSprinting
end

function SprintModule:Enable()
	self.IsEnabled = true
end

function SprintModule:Disable()
	self.IsEnabled = false
	self._isSprinting = false
	self:StopSprintAnimation()
end

function SprintModule:LoadSprintAnimation()
	-- Cargar animación de sprint
	local character = self.Player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Si ya hay una animación cargada, limpiarla
	if self.SprintAnimTrack then
		self.SprintAnimTrack:Stop()
		self.SprintAnimTrack = nil
	end

	-- Buscar o crear la animación
	-- Puedes cambiar el ID de animación aquí
	if Config.SprintAnimationId and Config.SprintAnimationId ~= "" then
		self.SprintAnimation = Instance.new("Animation")
		self.SprintAnimation.AnimationId = Config.SprintAnimationId

		self.SprintAnimTrack = humanoid:LoadAnimation(self.SprintAnimation)
	end
end

function SprintModule:UpdateSprintAnimation()
	local character = self.Player.Character
	if not character then return end

	-- Cargar animación si no existe
	if not self.SprintAnimTrack then
		self:LoadSprintAnimation()
	end

	if self._isSprinting then
		-- Activar animación de sprint
		if self.SprintAnimTrack and not self.SprintAnimTrack.IsPlaying then
			self.SprintAnimTrack:Play()
		end
	else
		-- Detener animación de sprint
		self:StopSprintAnimation()
	end
end

function SprintModule:StopSprintAnimation()
	if self.SprintAnimTrack and self.SprintAnimTrack.IsPlaying then
		self.SprintAnimTrack:Stop()
	end
end

function SprintModule:Cleanup()
	self:StopSprintAnimation()

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	if self.SprintAnimTrack then
		self.SprintAnimTrack:Destroy()
		self.SprintAnimTrack = nil
	end

	if self.SprintAnimation then
		self.SprintAnimation:Destroy()
		self.SprintAnimation = nil
	end
end

return SprintModule
