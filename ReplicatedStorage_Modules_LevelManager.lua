-- ReplicatedStorage > Modules > LevelManager
-- Sistema de niveles y experiencia modular y editable

local LevelManager = {}

-- ==================== CONFIGURACIÓN DE NIVELES ====================
-- Aquí defines cada nivel, la XP necesaria y la velocidad de sprint
-- FORMATO: [Nivel] = {XPRequired = XP necesaria, RunSpeed = Velocidad de sprint}

LevelManager.Levels = {
	-- Nivel 0 a 1
	[0] = {XPRequired = 50, RunSpeed = 24},

	-- Niveles 1-10
	[1] = {XPRequired = 100, RunSpeed = 26},
	[2] = {XPRequired = 150, RunSpeed = 28},
	[3] = {XPRequired = 200, RunSpeed = 30},
	[4] = {XPRequired = 300, RunSpeed = 32},
	[5] = {XPRequired = 400, RunSpeed = 34},
	[6] = {XPRequired = 500, RunSpeed = 36},
	[7] = {XPRequired = 650, RunSpeed = 38},
	[8] = {XPRequired = 800, RunSpeed = 40},
	[9] = {XPRequired = 1000, RunSpeed = 42},
	[10] = {XPRequired = 1200, RunSpeed = 44},

	-- Niveles 11-20
	[11] = {XPRequired = 1500, RunSpeed = 46},
	[12] = {XPRequired = 1800, RunSpeed = 48},
	[13] = {XPRequired = 2200, RunSpeed = 50},
	[14] = {XPRequired = 2600, RunSpeed = 52},
	[15] = {XPRequired = 3000, RunSpeed = 54},
	[16] = {XPRequired = 3500, RunSpeed = 56},
	[17] = {XPRequired = 4000, RunSpeed = 58},
	[18] = {XPRequired = 4600, RunSpeed = 60},
	[19] = {XPRequired = 5300, RunSpeed = 62},
	[20] = {XPRequired = 6000, RunSpeed = 64},

	-- Niveles 21-30 (Requiere 1 rebirth)
	[21] = {XPRequired = 7000, RunSpeed = 66},
	[22] = {XPRequired = 8000, RunSpeed = 68},
	[23] = {XPRequired = 9200, RunSpeed = 70},
	[24] = {XPRequired = 10500, RunSpeed = 72},
	[25] = {XPRequired = 12000, RunSpeed = 74},
	[26] = {XPRequired = 13500, RunSpeed = 76},
	[27] = {XPRequired = 15200, RunSpeed = 78},
	[28] = {XPRequired = 17000, RunSpeed = 80},
	[29] = {XPRequired = 19000, RunSpeed = 82},
	[30] = {XPRequired = 21000, RunSpeed = 84},

	-- Niveles 31-40 (Requiere 2 rebirths)
	[31] = {XPRequired = 24000, RunSpeed = 86},
	[32] = {XPRequired = 27000, RunSpeed = 88},
	[33] = {XPRequired = 30000, RunSpeed = 90},
	[34] = {XPRequired = 33500, RunSpeed = 92},
	[35] = {XPRequired = 37500, RunSpeed = 94},
	[36] = {XPRequired = 42000, RunSpeed = 96},
	[37] = {XPRequired = 47000, RunSpeed = 98},
	[38] = {XPRequired = 52500, RunSpeed = 100},
	[39] = {XPRequired = 58500, RunSpeed = 102},
	[40] = {XPRequired = 65000, RunSpeed = 104},

	-- PUEDES AÑADIR MÁS NIVELES AQUÍ SIGUIENDO EL MISMO FORMATO
	-- [41] = {XPRequired = 72000, RunSpeed = 106},
	-- [42] = {XPRequired = 80000, RunSpeed = 108},
	-- etc...
}

-- ==================== CONFIGURACIÓN DE LEVEL CAPS ====================
-- Define el nivel máximo según el número de rebirths
-- FORMATO: [Rebirths] = Nivel Máximo

LevelManager.LevelCaps = {
	[0] = 20,   -- 0 rebirths = Máximo nivel 20
	[1] = 30,   -- 1 rebirth = Máximo nivel 30
	[2] = 40,   -- 2 rebirths = Máximo nivel 40
	[3] = 50,   -- 3 rebirths = Máximo nivel 50
	[4] = 60,   -- 4 rebirths = Máximo nivel 60
	[5] = 70,   -- 5 rebirths = Máximo nivel 70

	-- PUEDES AÑADIR MÁS CAPS AQUÍ
	-- [6] = 80,
	-- [7] = 90,
	-- etc...
}

-- ==================== FUNCIONES ====================

-- Obtiene el nivel máximo permitido según rebirths
function LevelManager.GetMaxLevel(rebirths)
	return LevelManager.LevelCaps[rebirths] or LevelManager.LevelCaps[0]
end

-- Obtiene la velocidad de sprint para un nivel específico
function LevelManager.GetRunSpeed(level)
	local levelData = LevelManager.Levels[level]
	if levelData then
		return levelData.RunSpeed
	end
	-- Si el nivel no existe, retornar velocidad base
	return 24
end

-- Obtiene la XP requerida para subir de un nivel al siguiente
function LevelManager.GetXPRequired(currentLevel)
	local levelData = LevelManager.Levels[currentLevel]
	if levelData then
		return levelData.XPRequired
	end
	-- Si el nivel no existe, retornar un valor alto
	return 999999
end

-- Calcula si el jugador puede subir de nivel con la XP actual
function LevelManager.CanLevelUp(currentLevel, currentXP, rebirths)
	local maxLevel = LevelManager.GetMaxLevel(rebirths)

	-- No puede subir si ya está en el nivel máximo
	if currentLevel >= maxLevel then
		return false, "Nivel máximo alcanzado"
	end

	-- Verificar si tiene suficiente XP
	local xpRequired = LevelManager.GetXPRequired(currentLevel)
	if currentXP >= xpRequired then
		return true
	end

	return false, "XP insuficiente"
end

-- Procesa la subida de nivel y retorna los nuevos valores
function LevelManager.ProcessLevelUp(currentLevel, currentXP, rebirths)
	local canLevel, reason = LevelManager.CanLevelUp(currentLevel, currentXP, rebirths)

	if not canLevel then
		return false, reason, currentLevel, currentXP
	end

	-- Restar XP requerida
	local xpRequired = LevelManager.GetXPRequired(currentLevel)
	local newXP = currentXP - xpRequired
	local newLevel = currentLevel + 1

	return true, "Nivel incrementado", newLevel, newXP
end

-- Verifica si el jugador está en su nivel máximo
function LevelManager.IsAtMaxLevel(level, rebirths)
	local maxLevel = LevelManager.GetMaxLevel(rebirths)
	return level >= maxLevel
end

-- Obtiene información completa del nivel actual
function LevelManager.GetLevelInfo(level, currentXP, rebirths)
	local maxLevel = LevelManager.GetMaxLevel(rebirths)
	local isMaxLevel = level >= maxLevel
	local currentSpeed = LevelManager.GetRunSpeed(level)
	local nextSpeed = LevelManager.GetRunSpeed(level + 1)
	local xpRequired = LevelManager.GetXPRequired(level)

	return {
		CurrentLevel = level,
		CurrentXP = currentXP,
		XPRequired = xpRequired,
		CurrentSpeed = currentSpeed,
		NextSpeed = nextSpeed,
		MaxLevel = maxLevel,
		IsAtMaxLevel = isMaxLevel,
		Progress = isMaxLevel and 1 or (currentXP / xpRequired)
	}
end

-- Calcula el siguiente level cap si compra un rebirth
function LevelManager.GetNextLevelCap(currentRebirths)
	local currentCap = LevelManager.GetMaxLevel(currentRebirths)
	local nextCap = LevelManager.GetMaxLevel(currentRebirths + 1)
	return currentCap, nextCap
end

return LevelManager
