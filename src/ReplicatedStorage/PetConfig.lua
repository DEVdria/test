--[[
	CONFIGURACIÓN DEL SISTEMA DE MASCOTAS

	Aquí defines todos los huevos, sus precios, gamepasses y mascotas disponibles.
	Modifica este archivo para añadir nuevos huevos o mascotas.
--]]

local PetConfig = {}

-- ============================================
-- CONFIGURACIÓN DE HUEVOS
-- ============================================
PetConfig.Eggs = {
	-- Huevo Básico
	BasicEgg = {
		DisplayName = "Basic Egg",
		Price = 250, -- Precio en monedas del juego

		-- Gamepasses (cambia estos IDs por los tuyos)
		Gamepass_TripleOpen = 123456, -- ID del gamepass para abrir 3
		Gamepass_AutoOpen = 7891011,  -- ID del gamepass para auto-open

		-- Configuración de mascotas y probabilidades
		Pets = {
			{Name = "Dog", Rarity = "Common", Chance = 60, xpMultiplier = 1.0},
			{Name = "Cat", Rarity = "Uncommon", Chance = 35, xpMultiplier = 1.1},
			{Name = "Fox", Rarity = "Rare", Chance = 5, xpMultiplier = 1.25},
		}
	},

	-- Huevo Dorado (Ejemplo de segundo huevo)
	GoldenEgg = {
		DisplayName = "Golden Egg",
		Price = 1000,

		Gamepass_TripleOpen = 123457,
		Gamepass_AutoOpen = 7891012,

		Pets = {
			{Name = "GoldenDog", Rarity = "Rare", Chance = 50, xpMultiplier = 1.5},
			{Name = "GoldenCat", Rarity = "Epic", Chance = 35, xpMultiplier = 2.0},
			{Name = "Dragon", Rarity = "Legendary", Chance = 15, xpMultiplier = 3.0},
		}
	}
}

-- ============================================
-- CONFIGURACIÓN DE RARITIES (para UI)
-- ============================================
PetConfig.Rarities = {
	Common = {
		Color = Color3.fromRGB(170, 170, 170),
		DisplayName = "Común"
	},
	Uncommon = {
		Color = Color3.fromRGB(85, 255, 127),
		DisplayName = "Poco Común"
	},
	Rare = {
		Color = Color3.fromRGB(85, 170, 255),
		DisplayName = "Raro"
	},
	Epic = {
		Color = Color3.fromRGB(170, 85, 255),
		DisplayName = "Épico"
	},
	Legendary = {
		Color = Color3.fromRGB(255, 170, 0),
		DisplayName = "Legendario"
	}
}

-- ============================================
-- CONFIGURACIÓN DEL SISTEMA
-- ============================================
PetConfig.Settings = {
	MaxEquippedPets = 3,        -- Máximo de mascotas equipadas
	PetFollowDistance = 5,      -- Distancia de seguimiento
	PetSpacing = 3,             -- Espacio entre mascotas
	EggDetectionRange = 15,     -- Rango de detección de huevos

	-- Configuración de AlignPosition
	AlignPositionSettings = {
		MaxForce = 10000,
		Responsiveness = 200,
		MaxVelocity = math.huge
	}
}

-- ============================================
-- NOMBRE DE LA MONEDA (LeaderstatsName)
-- ============================================
PetConfig.CurrencyName = "Coins" -- Cambia esto al nombre de tu moneda

return PetConfig
