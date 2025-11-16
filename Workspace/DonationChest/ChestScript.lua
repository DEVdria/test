--[[
	DONATION CHEST SCRIPT - Script (Server)
	Ubicación: Workspace > DonationChest > ChestScript

	Este script maneja la interacción con el cofre usando ProximityPrompt.
	Cuando el jugador interactúa, se abre la GUI de donaciones.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Referencias
local chest = script.Parent
local proximityPrompt = chest:WaitForChild("ProximityPrompt")

-- RemoteEvent para abrir la GUI
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local OpenDonationGui = RemoteEvents:WaitForChild("OpenDonationGui")

-- ============================================
-- EVENTO DE INTERACCIÓN
-- ============================================

proximityPrompt.Triggered:Connect(function(player)
	print(player.Name, "abrió el cofre de donaciones")

	-- Abrir la GUI de donaciones en el cliente
	OpenDonationGui:FireClient(player)

	-- Opcional: Efecto visual del cofre
	-- Puedes agregar una animación o cambio de color aquí
end)

print("✅ Chest script cargado")
