-- ReplicatedStorage > Modules > OrbConfig
-- Configuración centralizada del sistema de orbs

local OrbConfig = {}

-- ==================== CONFIGURACIÓN DE TIPOS DE ORBS ====================
OrbConfig.OrbTypes = {
	Yellow = {
		Name = "Yellow",
		SpeedBonus = 1,                          -- Velocidad que otorga
		MoneyReward = 10,                        -- Dinero que otorga al recogerlo
		Color = Color3.fromRGB(255, 255, 0),     -- Color amarillo
		Size = Vector3.new(2, 2, 2),             -- Tamaño del orb
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		ParticleColor = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	},
	Green = {
		Name = "Green",
		SpeedBonus = 2,
		MoneyReward = 25,
		Color = Color3.fromRGB(0, 255, 0),       -- Color verde
		Size = Vector3.new(2.2, 2.2, 2.2),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		ParticleColor = ColorSequence.new(Color3.fromRGB(0, 255, 0))
	},
	Blue = {
		Name = "Blue",
		SpeedBonus = 3,
		MoneyReward = 50,
		Color = Color3.fromRGB(0, 100, 255),     -- Color azul
		Size = Vector3.new(2.5, 2.5, 2.5),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		ParticleColor = ColorSequence.new(Color3.fromRGB(0, 100, 255))
	},

	-- EXTRA: Puedes añadir más tipos aquí siguiendo el mismo formato
	-- Purple = {
	--     Name = "Purple",
	--     SpeedBonus = 5,
	--     MoneyReward = 100,
	--     Color = Color3.fromRGB(150, 0, 255),
	--     Size = Vector3.new(3, 3, 3),
	--     Material = Enum.Material.Neon,
	--     Transparency = 0.2,
	--     ParticleColor = ColorSequence.new(Color3.fromRGB(150, 0, 255))
	-- },
}

-- ==================== CONFIGURACIÓN DE ZONAS ====================
-- Cada zona define qué tipos de orbs pueden aparecer
OrbConfig.Zones = {
	{
		Name = "Zone1",
		Position = Vector3.new(0, 10, 0),        -- Posición central de la zona
		Size = Vector3.new(50, 0, 50),           -- Área: 50x50 studs
		SpawnHeight = 10,                        -- Altura fija de spawn
		OrbTypes = {"Yellow", "Green"},          -- Solo orbs amarillos y verdes
		MaxOrbs = 15,                            -- Máximo de orbs simultáneos en esta zona
		RespawnTime = 3                          -- Tiempo entre spawns (segundos)
	},
	{
		Name = "Zone2",
		Position = Vector3.new(100, 10, 0),
		Size = Vector3.new(50, 0, 50),
		SpawnHeight = 10,
		OrbTypes = {"Green", "Blue"},            -- Solo orbs verdes y azules
		MaxOrbs = 12,
		RespawnTime = 4
	},

	-- EXTRA: Añade más zonas aquí
	-- {
	--     Name = "Zone3",
	--     Position = Vector3.new(0, 10, 100),
	--     Size = Vector3.new(60, 0, 60),
	--     SpawnHeight = 15,
	--     OrbTypes = {"Blue", "Purple"},
	--     MaxOrbs = 10,
	--     RespawnTime = 5
	-- },
}

-- ==================== CONFIGURACIÓN GENERAL ====================
OrbConfig.General = {
	OrbLifetime = 30,                            -- Tiempo antes de que desaparezca un orb (segundos)
	CollectionDistance = 8,                      -- Distancia para recoger orb (studs)
	RotationSpeed = 45,                          -- Velocidad de rotación visual (grados/seg)
	BobHeight = 1,                               -- Altura del efecto de flotación
	BobSpeed = 2,                                -- Velocidad del efecto de flotación
}

-- ==================== CONFIGURACIÓN DE REBIRTHS ====================
OrbConfig.Rebirth = {
	BaseCost = 15000,                            -- Costo del primer rebirth
	CostMultiplier = 1.5,                        -- Multiplicador de costo por rebirth (1.5 = +50% cada vez)
	BaseSpeedMultiplier = 1.1,                   -- Multiplicador de velocidad base (1.1 = +10%)
	SpeedMultiplierIncrease = 0.05,              -- Incremento adicional por rebirth
}

-- ==================== FUNCIONES AUXILIARES ====================

-- Calcula el costo de un rebirth basado en el número actual de rebirths
function OrbConfig.CalculateRebirthCost(currentRebirths)
	return math.floor(OrbConfig.Rebirth.BaseCost * (OrbConfig.Rebirth.CostMultiplier ^ currentRebirths))
end

-- Calcula el multiplicador de velocidad basado en el número de rebirths
function OrbConfig.CalculateSpeedMultiplier(rebirths)
	return OrbConfig.Rebirth.BaseSpeedMultiplier + (OrbConfig.Rebirth.SpeedMultiplierIncrease * rebirths)
end

-- Obtiene un tipo de orb aleatorio válido para una zona
function OrbConfig.GetRandomOrbTypeForZone(zoneName)
	for _, zone in ipairs(OrbConfig.Zones) do
		if zone.Name == zoneName then
			local validTypes = zone.OrbTypes
			if #validTypes > 0 then
				return validTypes[math.random(1, #validTypes)]
			end
		end
	end
	return nil
end

-- Valida si un tipo de orb existe
function OrbConfig.IsValidOrbType(orbType)
	return OrbConfig.OrbTypes[orbType] ~= nil
end

return OrbConfig
