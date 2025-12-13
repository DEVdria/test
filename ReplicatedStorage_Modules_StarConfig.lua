-- ReplicatedStorage > Modules > StarConfig
-- Configuración de estrellas (coleccionables estáticos)

local StarConfig = {}

-- ==================== CONFIGURACIÓN DE ESTRELLAS ====================
-- Cada estrella tiene una recompensa de EXP y dinero
-- Nombres deben coincidir con los modelos en Workspace/Stars

StarConfig.Stars = {
	star1 = {
		EXPReward = 10,              -- EXP que otorga
		MoneyReward = 50,            -- Dinero que otorga
		Color = Color3.fromRGB(255, 255, 100),  -- Color amarillo claro
	},
	star2 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star3 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star4 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star5 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star6 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star7 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star8 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star9 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star10 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star11 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star12 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star13 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star14 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star15 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star16 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star17 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star18 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	star19 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
}

-- ==================== CONFIGURACIÓN GENERAL ====================
StarConfig.General = {
	CollectionCooldown = 3,              -- Cooldown entre recolecciones (segundos)
	CollectionDistance = 10,             -- Distancia para recoger estrella (studs)
	RotationSpeed = 45,                  -- Velocidad de rotación visual (grados/seg)
	BobHeight = 1.5,                     -- Altura del efecto de flotación
	BobSpeed = 2,                        -- Velocidad del efecto de flotación
}

-- ==================== FUNCIONES ÚTILES ====================

-- Verifica si un starID es válido
function StarConfig.IsValidStar(starID)
	return StarConfig.Stars[starID] ~= nil
end

-- Obtiene la configuración de una estrella
function StarConfig.GetStar(starID)
	return StarConfig.Stars[starID]
end

return StarConfig
