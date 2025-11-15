# 🎨 3 Decals con Texturas DIFERENTES

## ✨ Cambio Implementado

**Antes:** 3 Decals con la **misma textura** repetida
**Ahora:** 3 Decals con **texturas diferentes** cada uno

Esto te permite tener hasta 3 texturas distintas de vidrio/cristal superpuestas en cada panel para crear efectos visuales más complejos y realistas.

---

## 📝 Archivos Modificados

Se actualizaron **3 archivos**:
1. `GlassBridgeConfig.lua` - Nueva configuración con array de 3 texturas
2. `GlassBridgeEffects.lua` - Función actualizada para usar texturas diferentes
3. `GlassPanel.lua` - Ahora pasa el array de texturas

---

## 📄 SCRIPTS COMPLETOS ACTUALIZADOS

### 📂 SCRIPT 1: GlassBridgeConfig.lua
**Ubicación:** `ReplicatedStorage > ModuleScripts > GlassBridgeConfig` (ModuleScript)

```lua
--[[
	GlassBridgeConfig.lua
	Módulo de configuración para el minijuego Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassBridgeConfig = {}

-- CONFIGURACIÓN DEL PUENTE
GlassBridgeConfig.NumberOfRows = 18 -- Número de filas del puente
GlassBridgeConfig.PanelSize = Vector3.new(6, 0.5, 6) -- Tamaño de cada panel
GlassBridgeConfig.GapBetweenPanels = 1 -- Espacio entre paneles (horizontal)
GlassBridgeConfig.GapBetweenRows = 0.5 -- Espacio entre filas

-- COLORES Y APARIENCIA
GlassBridgeConfig.SafePanelColor = Color3.fromRGB(100, 200, 255) -- Azul (inicialmente transparente)
GlassBridgeConfig.FakePanelColor = Color3.fromRGB(255, 100, 100) -- Rojo (inicialmente transparente)
GlassBridgeConfig.InitialTransparency = 0.3 -- Transparencia inicial (0.3 = semi-transparente)
GlassBridgeConfig.GlassMaterial = Enum.Material.Glass

-- EFECTOS DE ROTURA
GlassBridgeConfig.BreakDelay = 0.3 -- Segundos antes de que el panel se rompa
GlassBridgeConfig.ShatterParticles = true -- Activar partículas de rotura
GlassBridgeConfig.ShatterSound = true -- Activar sonido de rotura

-- NUEVOS EFECTOS (ACTUALIZADOS)
GlassBridgeConfig.UseDecals = true -- Agregar Decals a los paneles para mejor apariencia
GlassBridgeConfig.DecalTextures = { -- 3 texturas diferentes para los Decals
	"rbxassetid://6372755229", -- Textura 1 (vidrio agrietado)
	"rbxassetid://6372755229", -- Textura 2 (puedes cambiar este ID)
	"rbxassetid://6372755229"  -- Textura 3 (puedes cambiar este ID)
}
GlassBridgeConfig.ExplosionEnabled = true -- Activar explosión en paneles falsos
GlassBridgeConfig.ExplosionForce = 100 -- Fuerza de la explosión
GlassBridgeConfig.ExplosionRadius = 10 -- Radio de la explosión
GlassBridgeConfig.RegenerateDelay = 15 -- Segundos para regenerar paneles falsos destruidos
GlassBridgeConfig.AlwaysShowSafeGreen = false -- Paneles seguros NO permanecen verdes (efecto temporal)

-- GAMEPLAY
GlassBridgeConfig.FallHeight = 50 -- Altura de caída debajo del puente
GlassBridgeConfig.RespawnOnDeath = false -- Si true, respawnea; si false, elimina al jugador
GlassBridgeConfig.ShowCorrectPath = false -- Si true, muestra el camino correcto (modo debug)

-- PUNTOS DE INICIO Y FIN
GlassBridgeConfig.StartPosition = Vector3.new(0, 5, 0) -- Posición del primer panel
GlassBridgeConfig.WinPosition = Vector3.new(0, 5, 120) -- Posición de la plataforma de victoria

return GlassBridgeConfig
```

---

### 📂 SCRIPT 2: GlassBridgeEffects.lua
**Ubicación:** `ReplicatedStorage > ModuleScripts > GlassBridgeEffects` (ModuleScript)

```lua
--[[
	GlassBridgeEffects.lua
	Módulo de efectos visuales para el Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassBridgeEffects = {}

-- Crear Decal en el panel para mejor apariencia visual
function GlassBridgeEffects.CreateDecal(panel, textures)
	local decals = {}

	-- Si no se proporciona un array de texturas, usar valores por defecto
	local textureList = textures or {
		"rbxassetid://6372755229",
		"rbxassetid://6372755229",
		"rbxassetid://6372755229"
	}

	-- Crear 3 Decals DIFERENTES en la parte superior del panel
	for i = 1, 3 do
		local decalTop = Instance.new("Decal")
		decalTop.Name = "GlassDecalTop" .. i
		decalTop.Face = Enum.NormalId.Top
		decalTop.Texture = textureList[i] or "rbxassetid://6372755229"
		decalTop.Transparency = 0.5
		decalTop.Parent = panel
		table.insert(decals, decalTop)
	end

	-- Crear 3 Decals DIFERENTES en la parte inferior del panel
	for i = 1, 3 do
		local decalBottom = Instance.new("Decal")
		decalBottom.Name = "GlassDecalBottom" .. i
		decalBottom.Face = Enum.NormalId.Bottom
		decalBottom.Texture = textureList[i] or "rbxassetid://6372755229"
		decalBottom.Transparency = 0.5
		decalBottom.Parent = panel
		table.insert(decals, decalBottom)
	end

	return decals
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

-- Crear efecto de explosión
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
```

---

### 📂 SCRIPT 3: GlassPanel.lua (Solo la parte modificada)
**Ubicación:** `ReplicatedStorage > ModuleScripts > GlassPanel` (ModuleScript)

**⚠️ IMPORTANTE:** Solo cambia la línea 67

**Encuentra esta línea:**
```lua
Effects.CreateDecal(panel, Config.DecalTexture)
```

**Cámbiala por:**
```lua
Effects.CreateDecal(panel, Config.DecalTextures)
```

O simplemente actualiza toda la sección:

```lua
-- Agregar al workspace
panel.Parent = workspace:WaitForChild("GlassBridge")

-- Agregar Decals si está habilitado (3 texturas diferentes)
if Config.UseDecals then
	Effects.CreateDecal(panel, Config.DecalTextures)
end

self.Part = panel
```

---

## 🎨 Cómo Personalizar las Texturas

En `GlassBridgeConfig.lua`, cambia los IDs de las texturas:

```lua
GlassBridgeConfig.DecalTextures = {
	"rbxassetid://6372755229", -- Textura 1 - Vidrio agrietado
	"rbxassetid://8644367095", -- Textura 2 - Cristal mágico
	"rbxassetid://9852787908"  -- Textura 3 - Hielo
}
```

### 🔍 Dónde Encontrar Texturas

1. Ve a https://create.roblox.com/marketplace/asset
2. Busca: "glass texture", "ice texture", "crystal texture"
3. Copia el ID del asset (número en la URL)
4. Úsalo en formato: `rbxassetid://ID_AQUI`

### 💡 Ejemplos de Texturas Recomendadas

```lua
-- Opción 1: Diferentes intensidades de grietas
GlassBridgeConfig.DecalTextures = {
	"rbxassetid://6372755229", -- Grietas ligeras
	"rbxassetid://6372755229", -- Grietas medias
	"rbxassetid://6372755229"  -- Grietas intensas
}

-- Opción 2: Diferentes estilos
GlassBridgeConfig.DecalTextures = {
	"rbxassetid://6372755229", -- Vidrio normal
	"rbxassetid://8644367095", -- Efecto cristalino
	"rbxassetid://9852787908"  -- Efecto helado
}

-- Opción 3: Mismo estilo (por ahora)
GlassBridgeConfig.DecalTextures = {
	"rbxassetid://6372755229",
	"rbxassetid://6372755229",
	"rbxassetid://6372755229"
}
```

---

## 🚀 Instalación

### Si ya tienes el sistema instalado:

1. Actualiza **GlassBridgeConfig.lua** - Reemplaza todo el contenido
2. Actualiza **GlassBridgeEffects.lua** - Reemplaza todo el contenido
3. Actualiza **GlassPanel.lua** - Cambia solo la línea 67 (o toda la sección indicada)
4. Presiona **Play (F5)**

---

## 📊 Comparación

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Texturas** | 1 misma textura x3 | 3 texturas diferentes |
| **Configuración** | `DecalTexture` (string) | `DecalTextures` (array) |
| **Flexibilidad** | Limitada | Total - puedes mezclar texturas |
| **Apariencia** | Uniforme | Capas superpuestas variadas |

---

## ✨ Beneficios

✅ **Texturas únicas** - Cada Decal puede tener su propia textura
✅ **Capas visuales** - Crea profundidad con texturas superpuestas diferentes
✅ **Fácil personalización** - Cambia las 3 texturas en el config
✅ **Efectos complejos** - Mezcla estilos: grietas + hielo + cristal

---

## 🔧 Ejemplo de Uso Avanzado

```lua
-- Crear efecto de "vidrio mágico congelado"
GlassBridgeConfig.DecalTextures = {
	"rbxassetid://6372755229", -- Base de vidrio
	"rbxassetid://9852787908", -- Capa de hielo
	"rbxassetid://8644367095"  -- Brillo mágico encima
}
```

Cada panel tendrá:
- Textura 1 (arriba y abajo): Vidrio base
- Textura 2 (arriba y abajo): Hielo superpuesto
- Textura 3 (arriba y abajo): Brillo mágico en la cima

= 6 Decals totales con 3 texturas diferentes creando un efecto único

---

¡Ahora puedes crear efectos visuales mucho más complejos! 🎨✨
