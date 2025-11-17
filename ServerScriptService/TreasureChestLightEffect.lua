--[[
═══════════════════════════════════════════════════════════════
    TREASURE CHEST LIGHT EFFECT - Animación de Luces
    Ubicación: ServerScriptService

    Funcionalidad:
    - Añade PointLight a todos los TreasureChest
    - Anima el brillo con efecto de pulso
    - Cambia colores entre dorado, amarillo y naranja
    - Hace el cofre más visible y llamativo
═══════════════════════════════════════════════════════════════
--]]

local TweenService = game:GetService("TweenService")

-- CONFIGURACIÓN DE LA LUZ
local LIGHT_CONFIG = {
	-- Brillo
	BrightnessMin = 2,      -- Brillo mínimo
	BrightnessMax = 8,      -- Brillo máximo

	-- Rango de luz
	Range = 20,             -- Distancia que ilumina

	-- Colores (efecto arcoíris dorado)
	Colors = {
		Color3.fromRGB(255, 215, 0),   -- Dorado
		Color3.fromRGB(255, 255, 0),   -- Amarillo brillante
		Color3.fromRGB(255, 165, 0),   -- Naranja
		Color3.fromRGB(255, 200, 50),  -- Amarillo dorado
	},

	-- Velocidad de animación
	PulseDuration = 1.5,    -- Duración del pulso (segundos)
	ColorDuration = 3,      -- Duración del cambio de color (segundos)
}

--[[
    Función: Crear animación de pulso de brillo
    Parámetros: light - El PointLight a animar
--]]
local function createPulseAnimation(light)
	-- Configurar TweenInfo para el pulso
	local tweenInfo = TweenInfo.new(
		LIGHT_CONFIG.PulseDuration,   -- Duración
		Enum.EasingStyle.Sine,         -- Estilo suave
		Enum.EasingDirection.InOut,    -- Entrada y salida suave
		-1,                            -- Repetir infinitamente
		true,                          -- Reversa (va y viene)
		0                              -- Sin delay
	)

	-- Objetivo: cambiar de brillo mínimo a máximo
	local goal = {
		Brightness = LIGHT_CONFIG.BrightnessMax
	}

	-- Crear y ejecutar tween
	local tween = TweenService:Create(light, tweenInfo, goal)
	tween:Play()

	return tween
end

--[[
    Función: Crear animación de cambio de color
    Parámetros: light - El PointLight a animar
--]]
local function createColorAnimation(light)
	local currentColorIndex = 1

	-- Función para cambiar al siguiente color
	local function changeToNextColor()
		currentColorIndex = currentColorIndex + 1
		if currentColorIndex > #LIGHT_CONFIG.Colors then
			currentColorIndex = 1
		end

		local tweenInfo = TweenInfo.new(
			LIGHT_CONFIG.ColorDuration,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		local goal = {
			Color = LIGHT_CONFIG.Colors[currentColorIndex]
		}

		local tween = TweenService:Create(light, tweenInfo, goal)
		tween:Play()
	end

	-- Cambiar color continuamente
	while light and light.Parent do
		changeToNextColor()
		task.wait(LIGHT_CONFIG.ColorDuration)
	end
end

--[[
    Función: Añadir efecto de luz a un cofre
    Parámetros: chest - La Part del TreasureChest
--]]
local function addLightEffect(chest)
	-- Verificar si ya tiene luz (evitar duplicados)
	local existingLight = chest:FindFirstChild("TreasureLight")
	if existingLight then
		return -- Ya tiene luz
	end

	-- Crear PointLight
	local light = Instance.new("PointLight")
	light.Name = "TreasureLight"
	light.Brightness = LIGHT_CONFIG.BrightnessMin -- Empezar con brillo mínimo
	light.Range = LIGHT_CONFIG.Range
	light.Color = LIGHT_CONFIG.Colors[1] -- Empezar con primer color
	light.Shadows = true -- Proyectar sombras (más realista)
	light.Parent = chest

	-- Iniciar animación de pulso
	createPulseAnimation(light)

	-- Iniciar animación de color en un hilo separado
	task.spawn(function()
		createColorAnimation(light)
	end)

	print("✨ Luz añadida a: " .. chest:GetFullName())
end

--[[
    Función: Buscar y añadir luces a todos los TreasureChest
--]]
local function setupAllTreasureChests()
	local chestCount = 0

	for _, obj in pairs(game.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "TreasureChest" then
			addLightEffect(obj)
			chestCount = chestCount + 1
		end
	end

	print("💡 Sistema de luces inicializado para " .. chestCount .. " cofres")
end

-- Añadir luces a cofres existentes
setupAllTreasureChests()

-- Detectar nuevos cofres que se añadan
game.Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "TreasureChest" then
		-- Esperar un momento para asegurar que el objeto está completamente cargado
		task.wait(0.1)
		addLightEffect(obj)
	end
end)

print("✅ TreasureChest Light Effect script inicializado")
