--[[
	EGG PROXIMITY DETECTOR - LocalScript

	Detecta cuando el jugador entra/sale del rango de un huevo.
	Envía RemoteEvents para mostrar/ocultar la GUI del huevo.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Configuración
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

-- RemoteEvents
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local ShowEggUIRemote = RemoteEventsFolder:WaitForChild("ShowEggUI")
local HideEggUIRemote = RemoteEventsFolder:WaitForChild("HideEggUI")

-- Variables locales
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Carpeta de huevos en Workspace
local EggsFolder = Workspace:WaitForChild("Eggs")

-- Estado actual (qué huevo está cerca)
local currentNearbyEgg = nil

-- ============================================
-- FUNCIÓN: OBTENER HUEVO MÁS CERCANO
-- ============================================
local function getNearestEgg()
	local nearestEgg = nil
	local nearestDistance = math.huge

	for _, eggModel in ipairs(EggsFolder:GetChildren()) do
		if eggModel:IsA("Model") then
			local eggPart = eggModel.PrimaryPart or eggModel:FindFirstChildWhichIsA("BasePart")
			if eggPart then
				local distance = (humanoidRootPart.Position - eggPart.Position).Magnitude
				if distance < PetConfig.Settings.EggDetectionRange and distance < nearestDistance then
					nearestEgg = eggModel
					nearestDistance = distance
				end
			end
		end
	end

	return nearestEgg
end

-- ============================================
-- LOOP DE DETECCIÓN
-- ============================================
RunService.Heartbeat:Connect(function()
	if not humanoidRootPart or not humanoidRootPart.Parent then
		-- Personaje murió, re-obtener referencias
		character = player.Character
		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end
		return
	end

	local nearestEgg = getNearestEgg()

	-- Si cambió el huevo cercano
	if nearestEgg ~= currentNearbyEgg then
		-- Ocultar GUI del huevo anterior
		if currentNearbyEgg then
			HideEggUIRemote:FireServer()
		end

		-- Mostrar GUI del nuevo huevo
		if nearestEgg then
			-- Enviar nombre del huevo al servidor
			ShowEggUIRemote:FireServer(nearestEgg.Name)
		end

		currentNearbyEgg = nearestEgg
	end
end)

-- ============================================
-- RESET AL CAMBIAR DE PERSONAJE
-- ============================================
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
	currentNearbyEgg = nil
end)
