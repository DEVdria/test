--[[
	MÓDULO DE ORBS (CLIENTE)
	Ubicación: ReplicatedStorage/Modules/OrbsModule
	Descripción: Gestiona la creación y recolección de orbs solo visibles para el cliente
]]

local OrbsModule = {}
OrbsModule.__index = OrbsModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Modules.Config)

function OrbsModule.new(player)
	local self = setmetatable({}, OrbsModule)

	self.Player = player
	self.PlayerSpeedBoost = 0 -- Velocidad acumulada
	self.CollectedOrbs = {} -- Orbs que ya recogió este jugador
	self.OrbInstances = {} -- Instancias de las orbs creadas
	self.OrbFolder = nil

	return self
end

function OrbsModule:Initialize()
	-- Crear carpeta para las orbs del cliente
	self.OrbFolder = Instance.new("Folder")
	self.OrbFolder.Name = "ClientOrbs_" .. self.Player.Name
	self.OrbFolder.Parent = workspace

	-- Generar todas las orbs
	self:SpawnAllOrbs()
end

function OrbsModule:SpawnAllOrbs()
	for index, position in ipairs(Config.OrbSpawnLocations) do
		self:CreateOrb(index, position)
	end
end

function OrbsModule:CreateOrb(index, position)
	-- Si ya fue recogida, no la crear
	if self.CollectedOrbs[index] then
		return
	end

	-- Crear la orb
	local orb = Instance.new("Part")
	orb.Name = "SpeedOrb_" .. index
	orb.Size = Config.OrbSize
	orb.Position = position
	orb.Anchored = true
	orb.CanCollide = false
	orb.Material = Config.OrbMaterial
	orb.Color = Config.OrbColor
	orb.Transparency = Config.OrbTransparency
	orb.Shape = Enum.PartType.Ball

	-- Efecto visual (rotación suave)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyGyro.CFrame = orb.CFrame
	bodyGyro.Parent = orb

	-- Guardar la instancia
	self.OrbInstances[index] = orb
	orb.Parent = self.OrbFolder

	-- Conectar evento de toque
	orb.Touched:Connect(function(hit)
		self:OnOrbTouched(index, hit)
	end)

	-- Animación de flotación
	task.spawn(function()
		local startY = position.Y
		local time = 0
		while orb and orb.Parent do
			time = time + RunService.Heartbeat:Wait()
			if orb and orb.Parent then
				local newY = startY + math.sin(time * 2) * 0.5
				orb.Position = Vector3.new(position.X, newY, position.Z)
			end
		end
	end)
end

function OrbsModule:OnOrbTouched(index, hit)
	-- Verificar si es el jugador correcto
	local character = self.Player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Verificar si el toque es de este jugador
	if hit.Parent ~= character then return end

	-- Verificar que no haya sido recogida ya
	if self.CollectedOrbs[index] then return end

	-- Marcar como recogida
	self.CollectedOrbs[index] = true

	-- Aumentar velocidad
	self.PlayerSpeedBoost = self.PlayerSpeedBoost + Config.OrbSpeedBoost

	-- Destruir la orb
	if self.OrbInstances[index] then
		self.OrbInstances[index]:Destroy()
		self.OrbInstances[index] = nil
	end

	-- Notificar al servidor (para dar dinero)
	local remoteEvent = ReplicatedStorage.RemoteEvents:FindFirstChild("OrbCollected")
	if remoteEvent then
		remoteEvent:FireServer(index)
	end

	-- Respawnear después de un tiempo
	task.delay(Config.OrbRespawnTime, function()
		self.CollectedOrbs[index] = nil
		self:CreateOrb(index, Config.OrbSpawnLocations[index])
	end)
end

function OrbsModule:GetSpeedBoost()
	return self.PlayerSpeedBoost
end

function OrbsModule:ResetSpeed()
	self.PlayerSpeedBoost = 0
end

function OrbsModule:Cleanup()
	if self.OrbFolder then
		self.OrbFolder:Destroy()
	end
	self.OrbInstances = {}
	self.CollectedOrbs = {}
end

return OrbsModule
