--[[
	SCRIPT DE REVIVIR (SERVIDOR)
	Ubicación: ServerScriptService/ReviveScript
	Descripción: Maneja el sistema de revivir jugadores
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Modules.Config)

-- Esperar RemoteEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local reviveEvent = remoteEventsFolder:WaitForChild("RevivePlayer")

-- Función para revivir jugador
local function RevivePlayer(player)
	-- Verificar que el jugador existe
	if not player or not player.Parent then
		warn("Jugador inválido para revivir")
		return false
	end

	-- Verificar que tiene un personaje
	local character = player.Character
	if not character then
		warn("Personaje no encontrado para " .. player.Name)
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		warn("Humanoid no encontrado para " .. player.Name)
		return false
	end

	-- Verificar que está muerto
	if humanoid.Health > 0 then
		warn(player.Name .. " no está muerto")
		return false
	end

	-- Revivir: recargar el personaje
	player:LoadCharacter()

	print(player.Name .. " ha sido revivido")
	return true
end

-- Conectar evento de revivir
reviveEvent.OnServerEvent:Connect(function(player)
	local success = RevivePlayer(player)

	if not success then
		warn("Error al revivir a " .. player.Name)
	end
end)

-- Auto-revivir después del tiempo configurado (opcional)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			print(player.Name .. " murió. Auto-reviviendo en " .. Config.RespawnTime .. " segundos...")

			task.wait(Config.RespawnTime)

			-- Verificar si el jugador aún está en el juego
			if player and player.Parent then
				RevivePlayer(player)
			end
		end)
	end)
end)

print("ReviveScript cargado exitosamente")
