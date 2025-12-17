--[[
	CHEST REWARD CONFIG
	Configuración de los cofres de recompensas temporales.

	Cada cofre tiene:
	- ID: Identificador único
	- ModelName: Nombre del modelo en Workspace/CHEST REWARD LEVEL
	- MoneyReward: Cantidad de dinero que otorga
	- Cooldown: Tiempo en segundos antes de poder reclamar de nuevo
]]

local ChestRewardConfig = {}

-- ========================================
-- CONFIGURACIÓN DE COFRES
-- ========================================

ChestRewardConfig.Chests = {
	-- Chest 1: Cofre básico
	{
		ID = 1,
		ModelName = "chest1",
		MoneyReward = 500,
		Cooldown = 14400,  -- 4 horas en segundos (4 * 60 * 60)
		Description = "Cofre Básico - 500 dinero cada 4 horas"
	},

	-- Chest 2: Cofre intermedio
	{
		ID = 2,
		ModelName = "chest2",
		MoneyReward = 1000,
		Cooldown = 14400,  -- 4 horas en segundos
		Description = "Cofre Intermedio - 1000 dinero cada 4 horas"
	},

	-- Chest 3: Cofre avanzado
	{
		ID = 3,
		ModelName = "chest3",
		MoneyReward = 2500,
		Cooldown = 14400,  -- 4 horas en segundos
		Description = "Cofre Avanzado - 2500 dinero cada 4 horas"
	},

	-- Chest 4: Cofre legendario
	{
		ID = 4,
		ModelName = "chest4",
		MoneyReward = 5000,
		Cooldown = 14400,  -- 4 horas en segundos
		Description = "Cofre Legendario - 5000 dinero cada 4 horas"
	},
}

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene la configuración de un cofre por su ID
function ChestRewardConfig.GetChestByID(chestID)
	for _, chest in ipairs(ChestRewardConfig.Chests) do
		if chest.ID == chestID then
			return chest
		end
	end
	return nil
end

-- Obtiene la configuración de un cofre por el nombre del modelo
function ChestRewardConfig.GetChestByModelName(modelName)
	for _, chest in ipairs(ChestRewardConfig.Chests) do
		if chest.ModelName == modelName then
			return chest
		end
	end
	return nil
end

-- Formatea segundos a un formato legible (HH:MM:SS)
function ChestRewardConfig.FormatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)

	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, secs)
	else
		return string.format("%02d:%02d", minutes, secs)
	end
end

return ChestRewardConfig
