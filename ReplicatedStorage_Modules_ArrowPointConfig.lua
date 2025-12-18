--[[
	ARROW POINT CONFIG
	Configuración del sistema de flechas direccionales.

	CARACTERÍSTICAS:
	- Compatible con R6 y R15
	- Múltiples tipos de objetivos
	- Sistema de highlights personalizables
	- Detección por distancia o ProximityPrompt
]]

local ArrowPointConfig = {}

-- ========================================
-- CONFIGURACIÓN GENERAL
-- ========================================

-- Tag de CollectionService para marcar objetivos
ArrowPointConfig.ObjectiveTag = "ArrowObjective"

-- Atributos de los objetivos
ArrowPointConfig.Attributes = {
	Order = "Order",           -- Número que indica el orden (1, 2, 3...)
	Distance = "Distance",     -- Distancia de detección (default: 15)
	Highlight = "Highlight",   -- Si debe resaltarse (default: true)
	Type = "Type"             -- Tipo de objetivo (opcional)
}

-- ========================================
-- CONFIGURACIÓN DEL BEAM (FLECHA)
-- ========================================

ArrowPointConfig.Beam = {
	-- Textura de la flecha
	Texture = "rbxassetid://94459865450488",

	-- Colores
	Color = ColorSequence.new(Color3.fromRGB(249, 241, 0)),  -- Amarillo

	-- Tamaño
	Width0 = 4,
	Width1 = 4,

	-- Propiedades visuales
	FaceCamera = true,
	LightEmission = 0.1,
	Transparency = NumberSequence.new(0),

	-- Textura animada
	TextureMode = Enum.TextureMode.Wrap,
	TextureLength = 7,
	TextureSpeed = 1
}

-- ========================================
-- CONFIGURACIÓN DE HIGHLIGHTS
-- ========================================

ArrowPointConfig.Highlight = {
	-- Highlight para Models
	Model = {
		FillTransparency = 1,
		FillColor = Color3.fromRGB(255, 255, 0),
		OutlineColor = Color3.fromRGB(0, 0, 0),
		OutlineTransparency = 0
	},

	-- Highlight para Parts opacas
	Part = {
		FillTransparency = 1,
		FillColor = Color3.fromRGB(255, 255, 0),
		OutlineColor = Color3.fromRGB(0, 0, 0),
		OutlineTransparency = 0
	},

	-- SelectionBox para Parts transparentes
	SelectionBox = {
		Color3 = Color3.fromRGB(0, 0, 0),
		LineThickness = 0.1
	}
}

-- ========================================
-- CONFIGURACIÓN DE DETECCIÓN
-- ========================================

-- Distancia por defecto para detectar objetivo
ArrowPointConfig.DefaultDistance = 15

-- Tiempo de espera antes de iniciar el sistema
ArrowPointConfig.StartDelay = 1

-- Intervalo entre advertencias de configuración incorrecta
ArrowPointConfig.WarningInterval = 3

-- ========================================
-- CONFIGURACIÓN DE COMPATIBILIDAD R6/R15
-- ========================================

-- Nombres de las partes del torso según el rig
ArrowPointConfig.TorsoParts = {
	R15 = "UpperTorso",
	R6 = "Torso"
}

-- Nombre del attachment donde se coloca el beam
ArrowPointConfig.BeamAttachmentName = "ArrowPointAttachment"

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Detecta si un personaje es R6 o R15
function ArrowPointConfig.GetRigType(character)
	if character:FindFirstChild("UpperTorso") then
		return "R15"
	elseif character:FindFirstChild("Torso") then
		return "R6"
	end
	return nil
end

-- Obtiene la parte del torso según el tipo de rig
function ArrowPointConfig.GetTorsoPart(character)
	local rigType = ArrowPointConfig.GetRigType(character)
	if not rigType then return nil end

	local torsoName = ArrowPointConfig.TorsoParts[rigType]
	return character:FindFirstChild(torsoName)
end

-- Obtiene la parte principal de un objeto (Model o Part)
function ArrowPointConfig.GetMainPart(object)
	if object:IsA("Model") then
		return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
	elseif object:IsA("BasePart") then
		return object
	end
	return nil
end

-- Valida si un atributo es del tipo correcto
function ArrowPointConfig.ValidateAttribute(object, attributeName, expectedType)
	local value = object:GetAttribute(attributeName)
	if value == nil then return false, nil end

	if typeof(value) ~= expectedType then
		return false, value
	end

	return true, value
end

return ArrowPointConfig
