--[[
	LOCAL SCRIPT PRINCIPAL DEL CLIENTE
	Ubicación: StarterPlayer/StarterPlayerScripts/ClientMain
	Descripción: Inicializa todos los sistemas del lado del cliente
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Cargar módulos
local OrbsModule = require(ReplicatedStorage.Modules.OrbsModule)
local SprintModule = require(ReplicatedStorage.Modules.SprintModule)
local JumpAnimationModule = require(ReplicatedStorage.Modules.JumpAnimationModule)

-- Variables globales del jugador (accesibles desde otros scripts)
_G.PlayerOrbsManager = nil
_G.PlayerSprintManager = nil
_G.PlayerJumpAnimManager = nil

-- Función de inicialización
local function Initialize()
	-- Esperar a que el personaje cargue
	local character = player.Character or player.CharacterAdded:Wait()

	-- Inicializar módulo de orbs
	_G.PlayerOrbsManager = OrbsModule.new(player)
	_G.PlayerOrbsManager:Initialize()

	-- Inicializar módulo de sprint
	_G.PlayerSprintManager = SprintModule.new(player, _G.PlayerOrbsManager)
	_G.PlayerSprintManager:Initialize()

	-- Inicializar módulo de animación de salto
	_G.PlayerJumpAnimManager = JumpAnimationModule.new(player)
	_G.PlayerJumpAnimManager:Initialize()

	print("Sistema del cliente inicializado correctamente")
end

-- Reconectar cuando el jugador reaparece
player.CharacterAdded:Connect(function()
	-- Limpiar sistemas anteriores
	if _G.PlayerOrbsManager then
		_G.PlayerOrbsManager:Cleanup()
	end

	if _G.PlayerSprintManager then
		_G.PlayerSprintManager:Cleanup()
	end

	if _G.PlayerJumpAnimManager then
		_G.PlayerJumpAnimManager:Cleanup()
	end

	-- Reinicializar
	task.wait(0.5) -- Esperar un poco para que todo cargue
	Initialize()
end)

-- Manejar evento de Rebirth
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local rebirthCompletedEvent = remoteEventsFolder:WaitForChild("RebirthCompleted")

rebirthCompletedEvent.OnClientEvent:Connect(function()
	print("Rebirth completado - Reseteando velocidad")

	-- Resetear velocidad acumulada
	if _G.PlayerOrbsManager then
		_G.PlayerOrbsManager:ResetSpeed()
	end

	-- Limpiar y recrear orbs
	if _G.PlayerOrbsManager then
		_G.PlayerOrbsManager:Cleanup()
		_G.PlayerOrbsManager:Initialize()
	end
end)

-- Inicializar
Initialize()

print("ClientMain cargado exitosamente")
