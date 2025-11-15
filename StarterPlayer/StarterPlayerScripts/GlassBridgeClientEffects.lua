--[[
	GlassBridgeClientEffects.lua
	LocalScript para manejar efectos visuales y sonoros locales

	Coloca este script en: StarterPlayer > StarterPlayerScripts
	IMPORTANTE: Este debe ser un LocalScript, NO un Script normal
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Esperar al RemoteEvent
local effectEvent = ReplicatedStorage:WaitForChild("GlassBridgeEffectEvent")

-- Función para crear efecto visual local de panel correcto
local function CreateLocalSuccessEffect(panel)
	if not panel or not panel.Parent then
		return
	end

	-- Guardar color original
	local originalColor = panel.Color
	local originalTransparency = panel.Transparency

	-- Cambiar a verde
	panel.Color = Color3.fromRGB(100, 255, 100)
	panel.Transparency = 0.2

	-- Crear destello local
	local highlight = Instance.new("SelectionBox")
	highlight.Parent = panel
	highlight.Adornee = panel
	highlight.Color3 = Color3.fromRGB(100, 255, 100)
	highlight.LineThickness = 0.1

	-- Crear partículas de éxito
	local successParticles = Instance.new("ParticleEmitter")
	successParticles.Parent = panel
	successParticles.Name = "LocalSuccessParticles"

	successParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	successParticles.Color = ColorSequence.new(Color3.fromRGB(100, 255, 100))
	successParticles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	successParticles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})

	successParticles.Lifetime = NumberRange.new(0.3, 0.6)
	successParticles.Rate = 50
	successParticles.Speed = NumberRange.new(3, 6)
	successParticles.SpreadAngle = Vector2.new(180, 180)

	successParticles:Emit(20)

	-- Volver al color original después de un momento
	task.delay(0.3, function()
		if panel and panel.Parent then
			panel.Color = originalColor
			panel.Transparency = originalTransparency
		end
		if highlight then
			highlight:Destroy()
		end
		task.delay(1, function()
			if successParticles then
				successParticles:Destroy()
			end
		end)
	end)
end

-- Función para crear sonido local de panel correcto
local function CreateLocalSuccessSound(panel)
	if not panel or not panel.Parent then
		return
	end

	local sound = Instance.new("Sound")
	sound.Parent = panel
	sound.Name = "LocalSuccessSound"
	sound.SoundId = "rbxassetid://5153734944" -- Sonido de éxito/correcto
	sound.Volume = 0.5
	sound.PlaybackSpeed = 1.2
	sound:Play()

	-- Limpiar después
	task.delay(2, function()
		if sound then
			sound:Destroy()
		end
	end)
end

-- Escuchar eventos del servidor
effectEvent.OnClientEvent:Connect(function(effectType, panel)
	if effectType == "SafePanel" then
		-- Crear efectos visuales y sonoros locales
		CreateLocalSuccessEffect(panel)
		CreateLocalSuccessSound(panel)
	end
end)

print("GlassBridge Client Effects initialized")
