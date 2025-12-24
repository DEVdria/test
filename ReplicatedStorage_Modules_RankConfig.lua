-- ReplicatedStorage > Modules > RankConfig
-- Configuración de títulos de rango por nivel

local RankConfig = {}

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE RANGOS
-- ═══════════════════════════════════════════════════════════
-- Cada rango define:
-- - minLevel: Nivel mínimo requerido
-- - maxLevel: Nivel máximo (nil = infinito)
-- - title: Texto que se mostrará
-- - textColor: Color del texto (Color3)
-- - textStrokeColor: Color del contorno del texto (Color3)

RankConfig.Ranks = {
	-- Ejemplo: puedes configurar tantos rangos como quieras
	{
		minLevel = 1,
		maxLevel = 5,
		title = "Corredor Lento",
		textColor = Color3.fromRGB(255, 255, 255),      -- Blanco
		textStrokeColor = Color3.fromRGB(0, 0, 0),       -- Negro
	},
	{
		minLevel = 5,
		maxLevel = 10,
		title = "Corredor Normal",
		textColor = Color3.fromRGB(100, 200, 255),       -- Azul claro
		textStrokeColor = Color3.fromRGB(0, 0, 0),       -- Negro
	},
	{
		minLevel = 10,
		maxLevel = 20,
		title = "Corredor Rápido",
		textColor = Color3.fromRGB(100, 255, 100),       -- Verde
		textStrokeColor = Color3.fromRGB(0, 100, 0),     -- Verde oscuro
	},
	{
		minLevel = 20,
		maxLevel = 30,
		title = "Velocista",
		textColor = Color3.fromRGB(255, 255, 100),       -- Amarillo
		textStrokeColor = Color3.fromRGB(200, 150, 0),   -- Dorado oscuro
	},
	{
		minLevel = 30,
		maxLevel = 50,
		title = "Corredor Pro",
		textColor = Color3.fromRGB(255, 150, 0),         -- Naranja
		textStrokeColor = Color3.fromRGB(150, 50, 0),    -- Naranja oscuro
	},
	{
		minLevel = 50,
		maxLevel = 75,
		title = "Corredor Elite",
		textColor = Color3.fromRGB(255, 100, 255),       -- Magenta
		textStrokeColor = Color3.fromRGB(150, 0, 150),   -- Púrpura
	},
	{
		minLevel = 75,
		maxLevel = 100,
		title = "Maestro de la Velocidad",
		textColor = Color3.fromRGB(255, 50, 50),         -- Rojo
		textStrokeColor = Color3.fromRGB(150, 0, 0),     -- Rojo oscuro
	},
	{
		minLevel = 100,
		maxLevel = nil,  -- nil = infinito (todos los niveles mayores a 100)
		title = "Leyenda del Speed",
		textColor = Color3.fromRGB(255, 215, 0),         -- Dorado
		textStrokeColor = Color3.fromRGB(255, 100, 0),   -- Naranja brillante
	},
}

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN VISUAL
-- ═══════════════════════════════════════════════════════════

RankConfig.Visual = {
	-- Fuente del texto
	Font = Enum.Font.FredokaOne,

	-- Tamaño del texto
	TextSize = 24,

	-- Background transparency (1 = completamente transparente)
	BackgroundTransparency = 1,

	-- Transparencia del contorno del texto
	TextStrokeTransparency = 0.5,

	-- Grosor del contorno del texto
	TextStrokeThickness = 2,

	-- Tamaño del BillboardGui
	Size = UDim2.new(0, 200, 0, 50),

	-- Distancia sobre la cabeza (studs)
	YOffset = 3,
}

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Obtiene el rango apropiado basado en el nivel del jugador
function RankConfig.GetRankForLevel(level)
	for _, rank in ipairs(RankConfig.Ranks) do
		local meetsMin = level >= rank.minLevel
		local meetsMax = rank.maxLevel == nil or level <= rank.maxLevel

		if meetsMin and meetsMax then
			return rank
		end
	end

	-- Si no encuentra ningún rango, retornar el primero como fallback
	return RankConfig.Ranks[1] or {
		minLevel = 0,
		maxLevel = nil,
		title = "Jugador",
		textColor = Color3.fromRGB(255, 255, 255),
		textStrokeColor = Color3.fromRGB(0, 0, 0),
	}
end

-- Obtiene información completa del rango
function RankConfig.GetRankInfo(level)
	local rank = RankConfig.GetRankForLevel(level)
	return {
		Level = level,
		Title = rank.title,
		MinLevel = rank.minLevel,
		MaxLevel = rank.maxLevel,
		TextColor = rank.textColor,
		TextStrokeColor = rank.textStrokeColor,
	}
end

return RankConfig
