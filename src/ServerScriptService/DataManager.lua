--[[
	DATA MANAGER - Sistema de guardado y carga de mascotas

	Maneja toda la persistencia de datos usando DataStore.
	Guarda el inventario de mascotas y su estado de equipado.
--]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataManager = {}
DataManager.__index = DataManager

-- DataStore
local PetDataStore = DataStoreService:GetDataStore("PlayerPetsData_v1")

-- Tiempo de cooldown para guardar (anti-spam)
local SAVE_COOLDOWN = 5

-- ============================================
-- ESTRUCTURA DE DATOS POR DEFECTO
-- ============================================
local function getDefaultData()
	return {
		Pets = {}, -- Lista de mascotas: {Name, Rarity, xpMultiplier, UniqueID, Equipped}
		EquippedPets = {} -- IDs de mascotas equipadas
	}
end

-- ============================================
-- CARGAR DATOS DEL JUGADOR
-- ============================================
function DataManager.LoadData(player)
	local userId = player.UserId
	local data
	local success, errorMessage = pcall(function()
		data = PetDataStore:GetAsync("Player_" .. userId)
	end)

	if success then
		if data then
			print("[DataManager] Datos cargados para " .. player.Name)
			-- Migrar datos antiguos si es necesario
			if not data.Pets then data.Pets = {} end
			if not data.EquippedPets then data.EquippedPets = {} end
			return data
		else
			print("[DataManager] Nuevo jugador: " .. player.Name)
			return getDefaultData()
		end
	else
		warn("[DataManager] Error al cargar datos de " .. player.Name .. ": " .. errorMessage)
		return getDefaultData()
	end
end

-- ============================================
-- GUARDAR DATOS DEL JUGADOR
-- ============================================
function DataManager.SaveData(player, data)
	local userId = player.UserId

	local success, errorMessage = pcall(function()
		PetDataStore:SetAsync("Player_" .. userId, data)
	end)

	if success then
		print("[DataManager] Datos guardados para " .. player.Name)
		return true
	else
		warn("[DataManager] Error al guardar datos de " .. player.Name .. ": " .. errorMessage)
		return false
	end
end

-- ============================================
-- AUTO-GUARDADO PERIÓDICO
-- ============================================
function DataManager.SetupAutoSave(player, playerData)
	local lastSaveTime = tick()

	-- Guardar cada 5 minutos
	task.spawn(function()
		while player.Parent do
			task.wait(60) -- Revisar cada minuto
			if tick() - lastSaveTime >= 300 then -- 5 minutos
				DataManager.SaveData(player, playerData[player])
				lastSaveTime = tick()
			end
		end
	end)
end

-- ============================================
-- GENERAR ID ÚNICO PARA MASCOTAS
-- ============================================
function DataManager.GenerateUniqueID()
	return game:GetService("HttpService"):GenerateGUID(false)
end

return DataManager
