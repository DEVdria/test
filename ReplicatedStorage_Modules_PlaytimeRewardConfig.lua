--[[
	PLAYTIME REWARD CONFIG - ModuleScript
	Configuración para el sistema de recompensas por tiempo de juego

	UBICACIÓN: ReplicatedStorage/Modules/PlaytimeRewardConfig
]]

local PlaytimeRewardConfig = {}

-- ==================== CONFIGURACIÓN DE RECOMPENSAS ====================

-- Define las 6 recompensas por tiempo jugado
-- IMPORTANTE: Los tiempos están en SEGUNDOS
PlaytimeRewardConfig.Rewards = {
	{
		ID = 1,
		Name = "Recompensa 5 min",
		TimeRequired = 5 * 60,  -- 5 minutos en segundos (300 segundos)
		MoneyReward = 5000,
	},
	{
		ID = 2,
		Name = "Recompensa 10 min",
		TimeRequired = 10 * 60,  -- 10 minutos (600 segundos)
		MoneyReward = 10000,
	},
	{
		ID = 3,
		Name = "Recompensa 20 min",
		TimeRequired = 20 * 60,  -- 20 minutos (1200 segundos)
		MoneyReward = 25000,
	},
	{
		ID = 4,
		Name = "Recompensa 30 min",
		TimeRequired = 30 * 60,  -- 30 minutos (1800 segundos)
		MoneyReward = 50000,
	},
	{
		ID = 5,
		Name = "Recompensa 1 hora",
		TimeRequired = 60 * 60,  -- 1 hora (3600 segundos)
		MoneyReward = 100000,
	},
	{
		ID = 6,
		Name = "Recompensa 2 horas",
		TimeRequired = 120 * 60,  -- 2 horas (7200 segundos)
		MoneyReward = 250000,
	},
}

-- ==================== NOMBRES DE GUI ====================

PlaytimeRewardConfig.GuiNames = {
	-- ScreenGui principal (debe existir)
	ScreenGui = "PrincipalGui",

	-- ImageButton principal para abrir el panel
	MainButton = "PlaytimeButton",
	MainButtonTimeLabel = "TimeLabel",  -- TextLabel dentro del botón principal

	-- Frame que contiene las recompensas
	RewardsFrame = "PlaytimeRewardsFrame",

	-- Prefijo de los ImageButtons de recompensas
	-- Se buscará: Reward1, Reward2, Reward3, etc.
	RewardButtonPrefix = "Reward",

	-- TextLabels dentro de cada ImageButton de recompensa
	TimeLabel = "TimeLabel",  -- Muestra el tiempo requerido
	MoneyLabel = "MoneyLabel",  -- Muestra la cantidad de dinero

	-- Botón para cerrar el panel (opcional)
	CloseButton = "CloseButton",
}

-- ==================== CONFIGURACIÓN VISUAL ====================

-- Colores para los estados de las recompensas
PlaytimeRewardConfig.StateColors = {
	Available = Color3.fromRGB(0, 255, 0),      -- Verde - Disponible para reclamar
	Claimed = Color3.fromRGB(100, 100, 100),    -- Gris - Ya reclamada
	Locked = Color3.fromRGB(255, 100, 100),     -- Rojo - Aún no alcanzado el tiempo
}

-- Transparencia de los botones según estado
PlaytimeRewardConfig.StateTransparency = {
	Available = 0,      -- Completamente visible
	Claimed = 0.5,      -- Semi-transparente
	Locked = 0.3,       -- Ligeramente transparente
}

-- Textos de estado
PlaytimeRewardConfig.StateTexts = {
	Available = "¡RECLAMAR!",
	Claimed = "RECLAMADO ✅",
	Locked = function(timeRemaining)
		return string.format("Falta: %s", PlaytimeRewardConfig.FormatTime(timeRemaining))
	end,
}

-- ==================== FUNCIONES HELPER ====================

-- Obtiene una recompensa por su ID
function PlaytimeRewardConfig.GetReward(rewardID)
	for _, reward in ipairs(PlaytimeRewardConfig.Rewards) do
		if reward.ID == rewardID then
			return reward
		end
	end
	return nil
end

-- Obtiene todas las recompensas ordenadas por tiempo
function PlaytimeRewardConfig.GetRewardsSorted()
	local sorted = {}
	for _, reward in ipairs(PlaytimeRewardConfig.Rewards) do
		table.insert(sorted, reward)
	end

	table.sort(sorted, function(a, b)
		return a.TimeRequired < b.TimeRequired
	end)

	return sorted
end

-- Formatea tiempo en segundos a formato legible
-- Ejemplos:
--   300 segundos = "5 min"
--   3600 segundos = "1 hora"
--   5400 segundos = "1h 30m"
function PlaytimeRewardConfig.FormatTime(seconds)
	if seconds < 60 then
		return string.format("%d seg", seconds)
	elseif seconds < 3600 then
		local minutes = math.floor(seconds / 60)
		local remainingSeconds = seconds % 60
		if remainingSeconds > 0 then
			return string.format("%d min %d seg", minutes, remainingSeconds)
		else
			return string.format("%d min", minutes)
		end
	else
		local hours = math.floor(seconds / 3600)
		local remainingMinutes = math.floor((seconds % 3600) / 60)
		if remainingMinutes > 0 then
			return string.format("%dh %dm", hours, remainingMinutes)
		else
			return string.format("%d hora%s", hours, hours > 1 and "s" or "")
		end
	end
end

-- Formatea tiempo corto (para los labels de las recompensas)
-- Ejemplos:
--   300 = "5 min"
--   3600 = "1h"
function PlaytimeRewardConfig.FormatTimeShort(seconds)
	if seconds < 60 then
		return string.format("%ds", seconds)
	elseif seconds < 3600 then
		return string.format("%d min", math.floor(seconds / 60))
	else
		local hours = math.floor(seconds / 3600)
		local remainingMinutes = math.floor((seconds % 3600) / 60)
		if remainingMinutes > 0 then
			return string.format("%dh %dm", hours, remainingMinutes)
		else
			return string.format("%dh", hours)
		end
	end
end

-- Formatea números con separadores de miles
function PlaytimeRewardConfig.FormatNumber(num)
	local formatted = tostring(num)
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted
end

-- Calcula la próxima recompensa disponible (no reclamada)
function PlaytimeRewardConfig.GetNextReward(playtime, claimedRewards)
	local sorted = PlaytimeRewardConfig.GetRewardsSorted()

	for _, reward in ipairs(sorted) do
		local isClaimed = table.find(claimedRewards or {}, reward.ID) ~= nil
		if not isClaimed then
			return reward
		end
	end

	return nil  -- Todas las recompensas reclamadas
end

-- Calcula el tiempo restante para la siguiente recompensa
function PlaytimeRewardConfig.GetTimeUntilNextReward(playtime, claimedRewards)
	local nextReward = PlaytimeRewardConfig.GetNextReward(playtime, claimedRewards)

	if not nextReward then
		return 0  -- Todas las recompensas reclamadas
	end

	local timeRemaining = nextReward.TimeRequired - playtime
	return math.max(0, timeRemaining)
end

-- Verifica si una recompensa puede ser reclamada
function PlaytimeRewardConfig.CanClaimReward(rewardID, playtime, claimedRewards)
	local reward = PlaytimeRewardConfig.GetReward(rewardID)
	if not reward then
		return false, "Recompensa no encontrada"
	end

	-- Verificar si ya fue reclamada
	local isClaimed = table.find(claimedRewards or {}, rewardID) ~= nil
	if isClaimed then
		return false, "Ya reclamaste esta recompensa"
	end

	-- Verificar si tiene suficiente tiempo de juego
	if playtime < reward.TimeRequired then
		local timeRemaining = reward.TimeRequired - playtime
		return false, string.format("Necesitas jugar %s más", PlaytimeRewardConfig.FormatTime(timeRemaining))
	end

	return true, "Puede reclamar"
end

return PlaytimeRewardConfig
