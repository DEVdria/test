-- ReplicatedStorage > Modules > OrbManager
-- Gestiona la creación visual y lógica de orbs

local OrbManager = {}
local OrbConfig = require(script.Parent.OrbConfig)
local TweenService = game:GetService("TweenService")

-- Crea un orb visual con efectos
function OrbManager.CreateOrb(orbType, position)
	local orbData = OrbConfig.OrbTypes[orbType]
	if not orbData then
		warn("Tipo de orb inválido:", orbType)
		return nil
	end

	-- Crear el orb base
	local orb = Instance.new("Part")
	orb.Name = "Orb_" .. orbType
	orb.Shape = Enum.PartType.Ball
	orb.Size = orbData.Size
	orb.Position = position
	orb.Color = orbData.Color
	orb.Material = orbData.Material
	orb.Transparency = orbData.Transparency
	orb.CanCollide = false
	orb.Anchored = true
	orb.CastShadow = false

	-- Atributos del orb
	orb:SetAttribute("OrbType", orbType)
	orb:SetAttribute("SpeedBonus", orbData.SpeedBonus)
	orb:SetAttribute("MoneyReward", orbData.MoneyReward)

	-- Crear efecto de brillo
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Color = orbData.Color
	pointLight.Range = 15
	pointLight.Parent = orb

	-- Crear partículas de brillo
	local attachment = Instance.new("Attachment")
	attachment.Parent = orb

	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Parent = attachment
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Color = orbData.ParticleColor
	sparkles.LightEmission = 1
	sparkles.Size = NumberSequence.new(0.3, 0)
	sparkles.Transparency = NumberSequence.new(0, 1)
	sparkles.Lifetime = NumberRange.new(0.5, 1)
	sparkles.Rate = 20
	sparkles.Speed = NumberRange.new(2, 4)
	sparkles.SpreadAngle = Vector2.new(360, 360)

	-- Efecto de glow
	local glow = Instance.new("SurfaceLight")
	glow.Face = Enum.NormalId.Top
	glow.Brightness = 3
	glow.Color = orbData.Color
	glow.Range = 10
	glow.Parent = orb

	return orb
end

-- Añade animación de flotación y rotación a un orb
function OrbManager.AnimateOrb(orb)
	if not orb or not orb:IsA("BasePart") then return end

	local config = OrbConfig.General
	local startPosition = orb.Position
	local bobHeight = config.BobHeight
	local bobSpeed = config.BobSpeed

	-- Rotación continua
	local rotationTween = TweenService:Create(
		orb,
		TweenInfo.new(
			360 / config.RotationSpeed,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut,
			-1,
			false,
			0
		),
		{CFrame = orb.CFrame * CFrame.Angles(0, math.rad(360), 0)}
	)
	rotationTween:Play()

	-- Flotación (bob effect)
	task.spawn(function()
		local elapsed = 0
		while orb and orb.Parent do
			elapsed = elapsed + task.wait()
			local offset = math.sin(elapsed * bobSpeed) * bobHeight
			if orb and orb.Parent then
				orb.Position = startPosition + Vector3.new(0, offset, 0)
			else
				break
			end
		end
	end)
end

-- Efecto visual al recoger un orb
function OrbManager.PlayCollectionEffect(orb)
	if not orb or not orb.Parent then return end

	-- Crear un clon para el efecto (el original se destruye)
	local effectOrb = orb:Clone()
	effectOrb.Parent = orb.Parent
	effectOrb.Anchored = true
	effectOrb.CanCollide = false

	-- Limpiar partículas del clon
	for _, child in ipairs(effectOrb:GetChildren()) do
		if child:IsA("ParticleEmitter") then
			child.Enabled = false
		end
	end

	-- Efecto de explosión de partículas
	local attachment = effectOrb:FindFirstChildOfClass("Attachment")
	if attachment then
		local burst = Instance.new("ParticleEmitter")
		burst.Parent = attachment
		burst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		burst.Color = ColorSequence.new(effectOrb.Color)
		burst.LightEmission = 1
		burst.Size = NumberSequence.new(0.5, 0)
		burst.Transparency = NumberSequence.new(0, 1)
		burst.Lifetime = NumberRange.new(0.3, 0.6)
		burst.Rate = 0
		burst.Speed = NumberRange.new(10, 20)
		burst.SpreadAngle = Vector2.new(360, 360)
		burst:Emit(30)
	end

	-- Tween de desaparición
	local disappearTween = TweenService:Create(
		effectOrb,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = Vector3.new(0.1, 0.1, 0.1),
			Transparency = 1
		}
	)
	disappearTween:Play()

	-- Destruir después del efecto
	task.delay(0.6, function()
		if effectOrb then
			effectOrb:Destroy()
		end
	end)
end

-- Genera una posición aleatoria dentro de una zona
function OrbManager.GetRandomPositionInZone(zone)
	local halfSizeX = zone.Size.X / 2
	local halfSizeZ = zone.Size.Z / 2

	local randomX = zone.Position.X + math.random(-halfSizeX, halfSizeX)
	local randomZ = zone.Position.Z + math.random(-halfSizeZ, halfSizeZ)
	local fixedY = zone.Position.Y + zone.SpawnHeight

	return Vector3.new(randomX, fixedY, randomZ)
end

-- Verifica si un orb está dentro de la distancia de recolección
function OrbManager.IsInCollectionRange(playerPosition, orbPosition)
	local distance = (playerPosition - orbPosition).Magnitude
	return distance <= OrbConfig.General.CollectionDistance
end

return OrbManager
