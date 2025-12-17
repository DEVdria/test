-- ReplicatedStorage > Modules > XPBoostConfig (ModuleScript)
-- Configuración del sistema de boosts de XP con gamepasses

local XPBoostConfig = {}

-- ==================== CONFIGURACIÓN DE BOOSTS ====================

-- IMPORTANTE: Cambia estos IDs por los de tus gamepasses reales
XPBoostConfig.Boosts = {
	{
		Level = 1,
		Name = "Boost de XP Nivel 1",
		Description = "+25% XP permanente",
		Multiplier = 1.25,  -- x1.25 (25% extra)
		Price = 29,  -- Robux
		GamepassID = 0,  -- ⚠️ CAMBIA ESTO por tu Gamepass ID real
	},
	{
		Level = 2,
		Name = "Boost de XP Nivel 2",
		Description = "+50% XP permanente",
		Multiplier = 1.5,  -- x1.5 (50% extra)
		Price = 79,  -- Robux
		GamepassID = 0,  -- ⚠️ CAMBIA ESTO por tu Gamepass ID real
	},
	{
		Level = 3,
		Name = "Boost de XP Nivel 3",
		Description = "+100% XP permanente",
		Multiplier = 2.0,  -- x2.0 (100% extra)
		Price = 149,  -- Robux
		GamepassID = 0,  -- ⚠️ CAMBIA ESTO por tu Gamepass ID real
	},
}

-- ==================== MENSAJES ====================

XPBoostConfig.Messages = {
	MaxBoostUnlocked = "🎉 XP Máxima Desbloqueada",
	PurchaseButton = "Comprar por %d Robux",
	Owned = "✅ Comprado",
	Loading = "Cargando...",
}

-- ==================== FUNCIONES DE UTILIDAD ====================

-- Obtiene el boost por nivel
function XPBoostConfig.GetBoostByLevel(level)
	for _, boost in ipairs(XPBoostConfig.Boosts) do
		if boost.Level == level then
			return boost
		end
	end
	return nil
end

-- Obtiene el boost por gamepass ID
function XPBoostConfig.GetBoostByGamepassID(gamepassID)
	for _, boost in ipairs(XPBoostConfig.Boosts) do
		if boost.GamepassID == gamepassID then
			return boost
		end
	end
	return nil
end

-- Obtiene el nivel máximo de boost
function XPBoostConfig.GetMaxLevel()
	return #XPBoostConfig.Boosts
end

-- Valida que todos los gamepass IDs estén configurados
function XPBoostConfig.ValidateConfig()
	local isValid = true
	for _, boost in ipairs(XPBoostConfig.Boosts) do
		if boost.GamepassID == 0 then
			warn(string.format("[XPBoostConfig] ⚠️ Gamepass ID no configurado para nivel %d", boost.Level))
			isValid = false
		end
	end
	return isValid
end

return XPBoostConfig
