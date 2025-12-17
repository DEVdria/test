--[[
	CONFIGURACIÓN DE BOOST GLOBAL DE DINERO POR SERVIDOR

	Este ModuleScript define todos los boosts de dinero disponibles para el servidor.
	Los boosts son GLOBALES - afectan a todos los jugadores del servidor.

	REGLAS:
	- Solo puede haber UN boost de dinero activo al mismo tiempo
	- Los boosts NO se acumulan
	- Un boost puede reemplazar al anterior (upgrade)
	- El multiplicador afecta a TODOS los jugadores por igual
]]

local GlobalMoneyBoostConfig = {}

-- ========================================
-- DEFINICIÓN DE BOOSTS DE DINERO
-- ========================================
GlobalMoneyBoostConfig.Boosts = {
	-- Boost 1: x2 MONEY por 15 minutos
	{
		ID = 1,
		Name = "x2 MONEY SERVER",
		Multiplier = 2.0,
		Duration = 900,  -- 15 minutos en segundos
		Price = 49,      -- Robux
		ProductID = 1926699554,  -- REEMPLAZAR con tu Dev Product ID real
		UpgradeFrom = nil,  -- Puede comprarse cuando no hay boost activo
		Description = "Dobla el dinero de todo el servidor por 15 minutos",
	},

	-- Boost 2: x4 MONEY por 30 minutos (UPGRADE)
	{
		ID = 2,
		Name = "x4 MONEY SERVER",
		Multiplier = 4.0,
		Duration = 1800,  -- 30 minutos en segundos
		Price = 129,      -- Robux
		ProductID = 1926699607,  -- REEMPLAZAR con tu Dev Product ID real
		UpgradeFrom = 1,  -- Solo puede comprarse cuando el boost 1 está activo
		Description = "Cuadruplica el dinero de todo el servidor por 30 minutos",
	},
}

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene un boost por su ID
function GlobalMoneyBoostConfig.GetBoostByID(boostID)
	for _, boost in ipairs(GlobalMoneyBoostConfig.Boosts) do
		if boost.ID == boostID then
			return boost
		end
	end
	return nil
end

-- Obtiene un boost por su Product ID
function GlobalMoneyBoostConfig.GetBoostByProductID(productID)
	for _, boost in ipairs(GlobalMoneyBoostConfig.Boosts) do
		if boost.ProductID == productID then
			return boost
		end
	end
	return nil
end

-- Obtiene el boost disponible según el estado actual
-- currentBoostID: ID del boost activo (nil si no hay ninguno)
function GlobalMoneyBoostConfig.GetAvailableBoost(currentBoostID)
	-- Si no hay boost activo, devolver el boost 1
	if not currentBoostID then
		return GlobalMoneyBoostConfig.GetBoostByID(1)
	end

	-- Si hay boost activo, buscar su upgrade
	for _, boost in ipairs(GlobalMoneyBoostConfig.Boosts) do
		if boost.UpgradeFrom == currentBoostID then
			return boost
		end
	end

	-- No hay boost disponible (ya está en el máximo nivel)
	return nil
end

return GlobalMoneyBoostConfig
