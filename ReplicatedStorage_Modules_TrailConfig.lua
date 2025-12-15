-- ReplicatedStorage > Modules > TrailConfig (ModuleScript)
-- Configuración modular de todas las trails disponibles en el juego
-- AÑADE NUEVAS TRAILS AQUÍ fácilmente

local TrailConfig = {}

-- ==================== CONFIGURACIÓN DE TRAILS ====================

-- Configuración de cada trail disponible
-- TÚ PUEDES MODIFICAR: Texture, Color, Price, RequiredLevel, RequiredRebirths
TrailConfig.Trails = {
	-- Trail 1: Fuego (GRATIS - Default)
	{
		ID = "Fire",
		Name = "🔥 Estela de Fuego",
		Description = "Una estela ardiente que sigue tus pasos",

		-- VISUAL (TÚ MODIFICAS ESTO)
		Texture = "rbxasset://textures/particles/fire_main.dds",  -- Textura de la trail
		Color = ColorSequence.new(Color3.fromRGB(255, 85, 0)),    -- Color naranja-rojo
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),  -- Inicio semi-transparente
			NumberSequenceKeypoint.new(1, 1)     -- Final completamente transparente
		}),

		-- PROPIEDADES DE LA TRAIL
		Lifetime = 1.5,           -- Duración de la estela (segundos)
		MinLength = 0.1,          -- Longitud mínima
		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),    -- Inicio ancho normal
			NumberSequenceKeypoint.new(1, 0.2)   -- Final más delgado
		}),

		-- PRECIO Y REQUISITOS
		Price = 0,                -- GRATIS (trail por defecto)
		RequiredLevel = 0,
		RequiredRebirths = 0,

		-- METADATA
		Category = "Basic",
		Rarity = "Common",
		IsDefault = true          -- Trail que todos tienen por defecto
	},

	-- Trail 2: Relámpago
	{
		ID = "Lightning",
		Name = "⚡ Estela Eléctrica",
		Description = "Electricidad salvaje te rodea",

		-- VISUAL (TÚ MODIFICAS ESTO)
		Texture = "rbxasset://textures/particles/smoke_main.dds",  -- Cambia por tu textura
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),    -- Azul eléctrico
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Blanco
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))    -- Azul claro
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		}),

		-- PROPIEDADES DE LA TRAIL
		Lifetime = 1.2,
		MinLength = 0.05,
		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(1, 0.1)
		}),

		-- PRECIO Y REQUISITOS
		Price = 5000,             -- 5,000 Stars
		RequiredLevel = 10,
		RequiredRebirths = 0,

		-- METADATA
		Category = "Premium",
		Rarity = "Rare",
		IsDefault = false
	},

	-- Trail 3: Arcoíris
	{
		ID = "Rainbow",
		Name = "🌈 Estela Arcoíris",
		Description = "Colores brillantes en cada paso",

		-- VISUAL (TÚ MODIFICAS ESTO)
		Texture = "rbxasset://textures/particles/sparkles_main.dds",  -- Cambia por tu textura
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),      -- Rojo
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),   -- Naranja
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),   -- Amarillo
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),      -- Verde
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),     -- Azul
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),    -- Índigo
			ColorSequenceKeypoint.new(1.0, Color3.fromRGB(148, 0, 211))     -- Violeta
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),

		-- PROPIEDADES DE LA TRAIL
		Lifetime = 2.0,
		MinLength = 0.2,
		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.2),
			NumberSequenceKeypoint.new(1, 0.3)
		}),

		-- PRECIO Y REQUISITOS
		Price = 15000,            -- 15,000 Stars
		RequiredLevel = 25,
		RequiredRebirths = 1,

		-- METADATA
		Category = "Premium",
		Rarity = "Epic",
		IsDefault = false
	},

	-- ==================== AÑADE MÁS TRAILS AQUÍ ====================
	-- Copia el formato de arriba y añade nuevas trails:
	--[[
	{
		ID = "NombreUnico",
		Name = "📛 Nombre Visible",
		Description = "Descripción corta",

		Texture = "rbxassetid://TU_TEXTURE_ID",
		Color = ColorSequence.new(Color3.fromRGB(R, G, B)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),

		Lifetime = 1.5,
		MinLength = 0.1,
		WidthScale = NumberSequence.new(1),

		Price = 10000,
		RequiredLevel = 15,
		RequiredRebirths = 0,

		Category = "Premium",
		Rarity = "Rare",
		IsDefault = false
	},
	]]
}

-- ==================== FUNCIONES DE UTILIDAD ====================

-- Obtiene una trail por su ID
function TrailConfig.GetTrail(trailID)
	for _, trail in ipairs(TrailConfig.Trails) do
		if trail.ID == trailID then
			return trail
		end
	end
	return nil
end

-- Obtiene todas las trails disponibles
function TrailConfig.GetAllTrails()
	return TrailConfig.Trails
end

-- Obtiene la trail por defecto
function TrailConfig.GetDefaultTrail()
	for _, trail in ipairs(TrailConfig.Trails) do
		if trail.IsDefault then
			return trail
		end
	end
	return TrailConfig.Trails[1]  -- Fallback a la primera
end

-- Obtiene trails por categoría
function TrailConfig.GetTrailsByCategory(category)
	local filtered = {}
	for _, trail in ipairs(TrailConfig.Trails) do
		if trail.Category == category then
			table.insert(filtered, trail)
		end
	end
	return filtered
end

-- Obtiene trails por rareza
function TrailConfig.GetTrailsByRarity(rarity)
	local filtered = {}
	for _, trail in ipairs(TrailConfig.Trails) do
		if trail.Rarity == rarity then
			table.insert(filtered, trail)
		end
	end
	return filtered
end

-- Verifica si el jugador cumple los requisitos para una trail
function TrailConfig.MeetsRequirements(player, trailID)
	local trail = TrailConfig.GetTrail(trailID)
	if not trail then return false end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local level = leaderstats:FindFirstChild("Nivel")
	local rebirths = leaderstats:FindFirstChild("Rebirths")

	if not level or not rebirths then return false end

	-- Verificar nivel
	if level.Value < trail.RequiredLevel then
		return false, string.format("Necesitas nivel %d (tienes %d)", trail.RequiredLevel, level.Value)
	end

	-- Verificar rebirths
	if rebirths.Value < trail.RequiredRebirths then
		return false, string.format("Necesitas %d rebirths (tienes %d)", trail.RequiredRebirths, rebirths.Value)
	end

	return true
end

return TrailConfig
