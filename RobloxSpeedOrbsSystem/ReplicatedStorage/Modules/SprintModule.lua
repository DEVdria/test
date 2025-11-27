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
	self.IsSprinting = false
	self.IsEnabled = true
	self.Connection = nil

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
	self.IsSprinting = sprinting
end

function SprintModule:ToggleSprint()
	self:SetSprinting(not self.IsSprinting)
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

	if self.IsSprinting then
		-- Sprint activado: Base + Boost
		return Config.BaseSprintSpeed + speedBoost
	else
		-- Sin sprint: solo base
		return baseSpeed
	end
end

function SprintModule:IsSprinting()
	return self.IsSprinting
end

function SprintModule:Enable()
	self.IsEnabled = true
end

function SprintModule:Disable()
	self.IsEnabled = false
	self.IsSprinting = false
end

function SprintModule:Cleanup()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

return SprintModule
