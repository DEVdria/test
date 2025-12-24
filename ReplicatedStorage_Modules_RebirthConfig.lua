-- ReplicatedStorage > Modules > RebirthConfig
-- Configuración de Rebirths: Costos y Multiplicadores
-- EDITA AQUÍ para cambiar los costos y multiplicadores de cada rebirth

local RebirthConfig = {}

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE COSTOS DE REBIRTH
-- ═══════════════════════════════════════════════════════════
-- Define cuánto dinero cuesta cada rebirth
-- FORMATO: [Número de Rebirths] = Costo en dinero

RebirthConfig.RebirthCosts = {
	[0] = 1000,      -- Primer rebirth (de 0 a 1) cuesta 1,000
	[1] = 2000,      -- Segundo rebirth (de 1 a 2) cuesta 2,000
	[2] = 4000,      -- Tercer rebirth (de 2 a 3) cuesta 4,000
	[3] = 8000,      -- Cuarto rebirth (de 3 a 4) cuesta 8,000
	[4] = 16000,     -- Quinto rebirth cuesta 16,000
	[5] = 32000,     -- Sexto rebirth cuesta 32,000
	[6] = 64000,     -- Séptimo rebirth cuesta 64,000
	[7] = 128000,    -- Octavo rebirth cuesta 128,000
	[8] = 256000,    -- Noveno rebirth cuesta 256,000
	[9] = 512000,    -- Décimo rebirth cuesta 512,000
	[10] = 1000000,  -- Undécimo rebirth cuesta 1,000,000

	-- PUEDES AGREGAR MÁS REBIRTHS AQUÍ
	-- [11] = 2000000,
	-- [12] = 4000000,
	-- etc...
}

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE MULTIPLICADORES DE EXP
-- ═══════════════════════════════════════════════════════════
-- Define el multiplicador de EXP que obtienes con cada rebirth
-- FORMATO: [Número de Rebirths] = Multiplicador

RebirthConfig.EXPMultipliers = {
	[0] = 1.0,    -- Sin rebirths: x1.0 EXP (normal)
	[1] = 1.1,    -- 1 rebirth: x1.1 EXP (+10%)
	[2] = 1.2,    -- 2 rebirths: x1.2 EXP (+20%)
	[3] = 1.3,    -- 3 rebirths: x1.3 EXP (+30%)
	[4] = 1.4,    -- 4 rebirths: x1.4 EXP (+40%)
	[5] = 1.5,    -- 5 rebirths: x1.5 EXP (+50%)
	[6] = 1.6,    -- 6 rebirths: x1.6 EXP (+60%)
	[7] = 1.7,    -- 7 rebirths: x1.7 EXP (+70%)
	[8] = 1.8,    -- 8 rebirths: x1.8 EXP (+80%)
	[9] = 1.9,    -- 9 rebirths: x1.9 EXP (+90%)
	[10] = 2.0,   -- 10 rebirths: x2.0 EXP (+100%)

	-- PUEDES AGREGAR MÁS MULTIPLICADORES AQUÍ
	-- [11] = 2.2,
	-- [12] = 2.4,
	-- etc...
}

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Obtiene el costo de dinero para hacer un rebirth
function RebirthConfig.GetRebirthCost(currentRebirths)
	-- Buscar el costo en la tabla
	local cost = RebirthConfig.RebirthCosts[currentRebirths]

	if cost then
		return cost
	end

	-- Si no está definido, calcular usando fórmula exponencial
	-- (para mantener compatibilidad con rebirths muy altos)
	local baseCost = 1000
	return baseCost * (2 ^ currentRebirths)
end

-- Obtiene el multiplicador de EXP según rebirths
function RebirthConfig.GetEXPMultiplier(rebirths)
	-- Buscar el multiplicador en la tabla
	local multiplier = RebirthConfig.EXPMultipliers[rebirths]

	if multiplier then
		return multiplier
	end

	-- Si no está definido, calcular usando fórmula lineal
	-- (para mantener compatibilidad con rebirths muy altos)
	return 1.0 + (rebirths * 0.1)
end

-- Obtiene el costo del siguiente rebirth
function RebirthConfig.GetNextRebirthCost(currentRebirths)
	return RebirthConfig.GetRebirthCost(currentRebirths)
end

-- Obtiene el multiplicador del siguiente rebirth
function RebirthConfig.GetNextEXPMultiplier(currentRebirths)
	return RebirthConfig.GetEXPMultiplier(currentRebirths + 1)
end

-- Verifica si un jugador puede hacer rebirth
function RebirthConfig.CanAffordRebirth(currentMoney, currentRebirths)
	local cost = RebirthConfig.GetRebirthCost(currentRebirths)
	return currentMoney >= cost
end

-- Obtiene información completa del rebirth actual
function RebirthConfig.GetRebirthInfo(currentRebirths, currentMoney)
	local currentCost = RebirthConfig.GetRebirthCost(currentRebirths)
	local currentMultiplier = RebirthConfig.GetEXPMultiplier(currentRebirths)
	local nextMultiplier = RebirthConfig.GetEXPMultiplier(currentRebirths + 1)

	return {
		CurrentRebirths = currentRebirths,
		CurrentMoney = currentMoney,
		RebirthCost = currentCost,
		CurrentMultiplier = currentMultiplier,
		NextMultiplier = nextMultiplier,
		CanAfford = currentMoney >= currentCost,
		MultiplierIncrease = nextMultiplier - currentMultiplier
	}
end

-- ═══════════════════════════════════════════════════════════
-- VALIDACIÓN Y DEBUG
-- ═══════════════════════════════════════════════════════════

-- Imprime la configuración actual (útil para debug)
function RebirthConfig.PrintConfig()
	print("═══════════════════════════════════════════════════════")
	print("CONFIGURACIÓN DE REBIRTHS")
	print("═══════════════════════════════════════════════════════")
	print("Rebirths | Costo      | Multiplicador EXP")
	print("─────────┼────────────┼─────────────────")

	-- Encontrar el rebirth máximo configurado
	local maxRebirth = 0
	for rebirth, _ in pairs(RebirthConfig.RebirthCosts) do
		if rebirth > maxRebirth then
			maxRebirth = rebirth
		end
	end
	for rebirth, _ in pairs(RebirthConfig.EXPMultipliers) do
		if rebirth > maxRebirth then
			maxRebirth = rebirth
		end
	end

	for i = 0, maxRebirth do
		local cost = RebirthConfig.GetRebirthCost(i)
		local mult = RebirthConfig.GetEXPMultiplier(i)
		print(string.format("   %2d    | %10s | x%.2f", i, tostring(cost), mult))
	end

	print("═══════════════════════════════════════════════════════")
end

return RebirthConfig
