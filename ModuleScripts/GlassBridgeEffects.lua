--[[
	GlassBridgeEffects.lua
	Módulo de efectos visuales para el Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassBridgeEffects = {}

-- Crear Decal en el panel para mejor apariencia visual
function GlassBridgeEffects.CreateDecal(panel, textureId)
	-- Crear Decal en la parte superior del panel
	local decalTop = Instance.new("Decal")
	decalTop.Name = "GlassDecalTop"
	decalTop.Face = Enum.NormalId.Top
	decalTop.Texture = textureId or "rbxassetid://6372755229"
	decalTop.Transparency = 0.5
	decalTop.Parent = panel

	-- Crear Decal en la parte inferior del panel
	local decalBottom = Instance.new("Decal")
	decalBottom.Name = "GlassDecalBottom"
	decalBottom.Face = Enum.NormalId.Bottom
	decalBottom.Texture = textureId or "rbxassetid://6372755229"
	decalBottom.Transparency = 0.5
	decalBottom.Parent = panel

	return {decalTop, decalBottom}
end

-- Crear efecto de partículas de vidrio roto
function GlassBridgeEffects.CreateShatterEffect(panel)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Parent = panel
	particleEmitter.Name = "ShatterParticles"

	-- Configuración de partículas
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = ColorSequence.new(panel.Color)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})

	particleEmitter.Lifetime = NumberRange.new(0.5, 1.5)
	particleEmitter.Rate = 100
	particleEmitter.Speed = NumberRange.new(10, 20)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-200, 200)

	-- Emitir partículas una vez
	particleEmitter:Emit(50)

	-- Limpiar después de 2 segundos
	task.delay(2, function()
		particleEmitter:Destroy()
	end)
end

-- Crear sonido de vidrio rompiéndose
function GlassBridgeEffects.CreateShatterSound(panel)
	local sound = Instance.new("Sound")
	sound.Parent = panel
	sound.Name = "ShatterSound"
	sound.SoundId = "rbxassetid://3581387885" -- Sonido de vidrio rompiéndose
	sound.Volume = 0.5
	sound.PlaybackSpeed = 1.2
	sound:Play()

	-- Limpiar después de que termine
	task.delay(3, function()
		sound:Destroy()
	end)
end

-- Animación de rotura del panel
function GlassBridgeEffects.ShatterPanel(panel, delay)
	-- Esperar un momento antes de romper
	task.wait(delay or 0.3)

	-- Cambiar color a rojo para indicar que es falso
	panel.Color = Color3.fromRGB(255, 100, 100)
	panel.Transparency = 0.5

	-- Efectos visuales
	GlassBridgeEffects.CreateShatterEffect(panel)
	GlassBridgeEffects.CreateShatterSound(panel)

	-- Animación de caída con rotación
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(
		1, -- Duración
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)

	local goal = {
		Position = panel.Position - Vector3.new(0, 50, 0),
		Transparency = 1,
		Orientation = panel.Orientation + Vector3.new(
			math.random(-90, 90),
			math.random(-90, 90),
			math.random(-90, 90)
		)
	}

	local tween = tweenService:Create(panel, tweenInfo, goal)
	tween:Play()

	-- Desactivar colisión inmediatamente
	panel.CanCollide = false

	-- Eliminar panel después de la animación
	task.delay(1.5, function()
		panel:Destroy()
	end)
end

-- Crear efecto de éxito al pisar panel correcto
function GlassBridgeEffects.CreateSuccessEffect(panel, keepGreen)
	-- Cambiar a verde
	local originalColor = panel.Color
	panel.Color = Color3.fromRGB(100, 255, 100)
	panel.Transparency = 0.2

	-- Crear destello
	local highlight = Instance.new("SelectionBox")
	highlight.Parent = panel
	highlight.Adornee = panel
	highlight.Color3 = Color3.fromRGB(100, 255, 100)
	highlight.LineThickness = 0.1

	-- Si keepGreen es true, mantener el verde; si no, volver al color original
	task.delay(0.3, function()
		if not keepGreen then
			panel.Color = originalColor
			panel.Transparency = 0.3
		else
			-- Mantener verde pero ajustar transparencia
			panel.Transparency = 0.2
		end
		highlight:Destroy()
	end)
end

-- Crear efecto de explosión (NUEVO)
function GlassBridgeEffects.CreateExplosion(panel, force, radius)
	-- Crear explosión visual
	local explosion = Instance.new("Explosion")
	explosion.Position = panel.Position
	explosion.BlastRadius = radius or 10
	explosion.BlastPressure = force or 100000
	explosion.DestroyJointRadiusPercent = 0 -- No destruir articulaciones del personaje
	explosion.Parent = workspace

	-- Crear efecto de partículas de explosión
	local explosionEffect = Instance.new("ParticleEmitter")
	explosionEffect.Parent = panel
	explosionEffect.Name = "ExplosionParticles"

	explosionEffect.Texture = "rbxasset://textures/particles/fire_main.dds"
	explosionEffect.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 100)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
	})
	explosionEffect.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 0)
	})
	explosionEffect.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})

	explosionEffect.Lifetime = NumberRange.new(0.3, 0.8)
	explosionEffect.Rate = 200
	explosionEffect.Speed = NumberRange.new(20, 40)
	explosionEffect.SpreadAngle = Vector2.new(180, 180)

	explosionEffect:Emit(80)

	-- Sonido de explosión
	local explosionSound = Instance.new("Sound")
	explosionSound.Parent = panel
	explosionSound.SoundId = "rbxassetid://3802269531" -- Sonido de explosión
	explosionSound.Volume = 0.8
	explosionSound.PlaybackSpeed = 1
	explosionSound:Play()

	-- Limpiar efectos
	task.delay(2, function()
		if explosionEffect then explosionEffect:Destroy() end
		if explosionSound then explosionSound:Destroy() end
	end)
end

-- Crear plataforma de inicio
function GlassBridgeEffects.CreateStartPlatform(position, size)
	local platform = Instance.new("Part")
	platform.Name = "StartPlatform"
	platform.Size = size or Vector3.new(20, 1, 10)
	platform.Position = position
	platform.Anchored = true
	platform.Color = Color3.fromRGB(50, 150, 50)
	platform.Material = Enum.Material.Concrete
	platform.Parent = workspace:WaitForChild("GlassBridge")

	return platform
end

-- Crear plataforma de victoria
function GlassBridgeEffects.CreateWinPlatform(position, size)
	local platform = Instance.new("Part")
	platform.Name = "WinPlatform"
	platform.Size = size or Vector3.new(20, 1, 10)
	platform.Position = position
	platform.Anchored = true
	platform.Color = Color3.fromRGB(255, 215, 0) -- Dorado
	platform.Material = Enum.Material.Neon
	platform.Parent = workspace:WaitForChild("GlassBridge")

	-- Agregar detector de victoria
	platform.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			print(hit.Parent.Name .. " ha ganado!")
			-- Aquí puedes agregar lógica de victoria
		end
	end)

	return platform
end

return GlassBridgeEffects
