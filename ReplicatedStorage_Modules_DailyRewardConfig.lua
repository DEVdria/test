-- ReplicatedStorage > Modules > DailyRewardConfig
-- Configuración del sistema de recompensas diarias

local DailyRewardConfig = {}

-- ==================== CONFIGURACIÓN DE RECOMPENSAS ====================

-- Ciclo de 7 días con recompensas diseñadas para retención
DailyRewardConfig.Rewards = {
	-- DÍA 1: Inicio fuerte para enganchar al jugador
	{
		Day = 1,
		Type = "XPBoost",           -- Tipo de recompensa
		BoostMultiplier = 2,        -- x2 XP
		BoostDuration = 600,        -- 10 minutos (en segundos)
		DisplayName = "x2 XP - 10 min",
		Icon = "⚡",
		Description = "Gana el doble de XP durante 10 minutos"
	},

	-- DÍA 2: Monedas para mantener interés
	{
		Day = 2,
		Type = "Money",
		MoneyAmount = 5000,
		DisplayName = "5,000 Monedas",
		Icon = "💰",
		Description = "Recibe 5,000 monedas instantáneamente"
	},

	-- DÍA 3: Boost de dinero para incentivar grind
	{
		Day = 3,
		Type = "MoneyBoost",
		BoostMultiplier = 2,        -- x2 Money
		BoostDuration = 900,        -- 15 minutos
		DisplayName = "x2 Money - 15 min",
		Icon = "💵",
		Description = "Gana el doble de dinero durante 15 minutos"
	},

	-- DÍA 4: Más monedas
	{
		Day = 4,
		Type = "Money",
		MoneyAmount = 10000,
		DisplayName = "10,000 Monedas",
		Icon = "💰",
		Description = "Recibe 10,000 monedas instantáneamente"
	},

	-- DÍA 5: Aún más monedas
	{
		Day = 5,
		Type = "Money",
		MoneyAmount = 15000,
		DisplayName = "15,000 Monedas",
		Icon = "💰",
		Description = "Recibe 15,000 monedas instantáneamente"
	},

	-- DÍA 6: Boost de XP más largo
	{
		Day = 6,
		Type = "XPBoost",
		BoostMultiplier = 2,
		BoostDuration = 1200,       -- 20 minutos
		DisplayName = "x2 XP - 20 min",
		Icon = "⚡",
		Description = "Gana el doble de XP durante 20 minutos"
	},

	-- DÍA 7: GRAN RECOMPENSA - Ambos boosts para máxima retención
	{
		Day = 7,
		Type = "DoubleBoost",       -- Boost dual
		XPMultiplier = 2,
		MoneyMultiplier = 2,
		BoostDuration = 1800,       -- 30 minutos
		DisplayName = "x2 XP + x2 Money - 30 min",
		Icon = "🔥",
		Description = "¡Gana el doble de XP Y dinero durante 30 minutos!"
	}
}

-- ==================== CONFIGURACIÓN DEL SISTEMA ====================

-- Tiempo entre recompensas (24 horas en segundos)
DailyRewardConfig.CLAIM_COOLDOWN = 24 * 60 * 60  -- 86400 segundos

-- Nombres de RemoteEvents
DailyRewardConfig.RemoteEvents = {
	GetRewardInfo = "GetDailyRewardInfo",      -- RemoteFunction: Obtener info del jugador
	ClaimReward = "ClaimDailyReward",          -- RemoteEvent: Reclamar recompensa
	BoostUpdate = "DailyBoostUpdate"           -- RemoteEvent: Actualizar estado de boost
}

-- Nombres de elementos de la GUI (para el LocalScript)
DailyRewardConfig.GuiNames = {
	ScreenGui = "DailyRewardGui",              -- ScreenGui principal
	MainFrame = "DailyRewardFrame",            -- Frame principal
	CloseButton = "CloseButton",               -- Botón para cerrar
	DayButtonPrefix = "Day",                   -- Day1, Day2, Day3...

	-- Elementos de cada botón de día
	DayIcon = "Icon",                          -- TextLabel con emoji
	DayNumber = "DayNumber",                   -- TextLabel "Día 1"
	DayReward = "RewardText",                  -- TextLabel con nombre de recompensa
	DayStatus = "Status",                      -- TextLabel con estado
	ClaimButton = "ClaimButton",               -- TextButton para reclamar

	-- Indicador de boost activo
	BoostIndicator = "BoostIndicator",         -- Frame que muestra boost activo
	BoostText = "BoostText",                   -- TextLabel con info del boost
	BoostTimer = "BoostTimer"                  -- TextLabel con tiempo restante
}

-- Colores del UI
DailyRewardConfig.Colors = {
	Claimed = Color3.fromRGB(0, 200, 0),       -- Verde para días reclamados
	Available = Color3.fromRGB(255, 215, 0),   -- Dorado para día disponible
	Locked = Color3.fromRGB(100, 100, 100),    -- Gris para días bloqueados
	Special = Color3.fromRGB(255, 100, 0)      -- Naranja para día 7
}

-- ==================== FUNCIONES DE UTILIDAD ====================

-- Obtiene la recompensa de un día específico
function DailyRewardConfig.GetReward(day)
	for _, reward in ipairs(DailyRewardConfig.Rewards) do
		if reward.Day == day then
			return reward
		end
	end
	return nil
end

-- Formatea tiempo restante en formato legible
function DailyRewardConfig.FormatTime(seconds)
	if seconds <= 0 then
		return "Disponible"
	end

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, secs)
	else
		return string.format("%ds", secs)
	end
end

-- Formatea tiempo de boost (MM:SS)
function DailyRewardConfig.FormatBoostTime(seconds)
	if seconds <= 0 then
		return "0:00"
	end

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	return string.format("%d:%02d", minutes, secs)
end

-- Formatea números con separadores de miles
function DailyRewardConfig.FormatNumber(num)
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

return DailyRewardConfig
