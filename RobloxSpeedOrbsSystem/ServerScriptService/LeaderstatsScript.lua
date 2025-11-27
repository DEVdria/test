--[[
	SCRIPT DE LEADERSTATS (SERVIDOR)
	Ubicación: ServerScriptService/LeaderstatsScript
	Descripción: Crea y gestiona las estadísticas de los jugadores
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.Config)

local function CreateLeaderstats(player)
	-- Crear carpeta de leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Crear Money
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = Config.StartingMoney
	money.Parent = leaderstats

	-- Crear Rebirths
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = Config.StartingRebirths
	rebirths.Parent = leaderstats

	print("Leaderstats creadas para " .. player.Name)
end

-- Conectar evento cuando un jugador se une
Players.PlayerAdded:Connect(CreateLeaderstats)

-- Crear leaderstats para jugadores que ya están en el juego
for _, player in ipairs(Players:GetPlayers()) do
	CreateLeaderstats(player)
end

print("LeaderstatsScript cargado exitosamente")
