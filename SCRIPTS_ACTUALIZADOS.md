# 📝 Scripts Completos Actualizados - Glass Bridge

## 🔄 Cambios Implementados

### ✅ Cambio 1: Paneles seguros NO permanecen verdes
- Los paneles vuelven a su color original después del efecto

### ✅ Cambio 2: Efectos visuales locales
- Solo el jugador que pisa el panel ve el efecto verde

### ✅ Cambio 3: Sonido local
- Solo el jugador que pisa el panel escucha el sonido de éxito

---

## 📂 ESTRUCTURA DE ARCHIVOS

```
Glass Bridge Sistema/
├── ReplicatedStorage/
│   └── ModuleScripts/
│       ├── GlassBridgeConfig (ModuleScript)
│       ├── GlassBridgeEffects (ModuleScript)
│       └── GlassPanel (ModuleScript)
│
├── ServerScriptService/
│   └── GlassBridgeManager (Script)
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── GlassBridgeClientEffects (LocalScript) ⭐ NUEVO
```

---

## 📄 SCRIPT 1: GlassBridgeConfig.lua
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
GlassBridgeConfig.DecalTexture = "rbxassetid://6372755229" -- ID de textura para Decal (vidrio agrietado)
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

## 📄 SCRIPT 2: GlassBridgeEffects.lua
**Ubicación:** `ReplicatedStorage > ModuleScripts > GlassBridgeEffects` (ModuleScript)

```lua
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

## 📄 SCRIPT 3: GlassPanel.lua
**Ubicación:** `ReplicatedStorage > ModuleScripts > GlassPanel` (ModuleScript)

```lua
--[[
	GlassPanel.lua
	Módulo para gestionar paneles individuales del Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassPanel = {}
GlassPanel.__index = GlassPanel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("GlassBridgeConfig"))
local Effects = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("GlassBridgeEffects"))

-- Constructor
function GlassPanel.new(position, isSafe, rowNumber, side)
	local self = setmetatable({}, GlassPanel)

	self.Position = position
	self.IsSafe = isSafe
	self.RowNumber = rowNumber
	self.Side = side -- "Left" o "Right"
	self.HasBeenTouched = false
	self.Part = nil
	self.IsDestroyed = false -- Rastrear si está destruido
	self.RegenerationScheduled = false -- Rastrear si hay regeneración pendiente

	self:CreatePart()
	self:SetupTouchDetection()

	return self
end

-- Crear la parte física del panel
function GlassPanel:CreatePart()
	local panel = Instance.new("Part")
	panel.Name = "GlassPanel_Row" .. self.RowNumber .. "_" .. self.Side
	panel.Size = Config.PanelSize
	panel.Position = self.Position
	panel.Anchored = true
	panel.CanCollide = true
	panel.Material = Config.GlassMaterial
	panel.Transparency = Config.InitialTransparency
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth

	-- Color según si es seguro o falso (opcional para debug)
	if Config.ShowCorrectPath then
		panel.Color = self.IsSafe and Config.SafePanelColor or Config.FakePanelColor
	else
		-- Color neutro si no mostramos el camino
		panel.Color = Color3.fromRGB(200, 230, 255)
	end

	-- Agregar valor para identificar el tipo
	local safeValue = Instance.new("BoolValue")
	safeValue.Name = "IsSafe"
	safeValue.Value = self.IsSafe
	safeValue.Parent = panel

	-- Agregar al workspace
	panel.Parent = workspace:WaitForChild("GlassBridge")

	-- Agregar Decals si está habilitado
	if Config.UseDecals then
		Effects.CreateDecal(panel, Config.DecalTexture)
	end

	self.Part = panel
end

-- Configurar detección de colisión
function GlassPanel:SetupTouchDetection()
	self.Part.Touched:Connect(function(hit)
		self:OnTouch(hit)
	end)
end

-- Manejador de eventos de toque
function GlassPanel:OnTouch(hit)
	-- Si el panel está destruido, no hacer nada
	if self.IsDestroyed then
		return
	end

	-- Verificar si es un jugador
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local player = game.Players:GetPlayerFromCharacter(hit.Parent)

	if self.IsSafe then
		-- Panel seguro - efectos locales solo para el jugador que pisa
		print(hit.Parent.Name .. " pisó un panel SEGURO (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

		-- Disparar evento al cliente específico para efectos locales
		if player then
			local effectEvent = ReplicatedStorage:FindFirstChild("GlassBridgeEffectEvent")
			if effectEvent then
				effectEvent:FireClient(player, "SafePanel", self.Part)
			end
		end
	else
		-- Panel falso - explosión y regeneración
		-- Evitar múltiples activaciones del panel falso
		if self.HasBeenTouched then
			return
		end

		self.HasBeenTouched = true
		print(hit.Parent.Name .. " pisó un panel FALSO (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

		-- Crear explosión si está habilitado
		if Config.ExplosionEnabled then
			-- Calcular fuerza basada en configuración
			local explosionForce = Config.ExplosionForce * 1000 -- Multiplicar para Roblox BlastPressure
			Effects.CreateExplosion(self.Part, explosionForce, Config.ExplosionRadius)
		end

		-- Desactivar colisión inmediatamente para que el jugador caiga
		self.Part.CanCollide = false

		-- Ejecutar efectos de rotura
		Effects.ShatterPanel(self.Part, Config.BreakDelay)

		-- Marcar como destruido
		self.IsDestroyed = true

		-- Matar al jugador o respawnearlo según configuración
		task.delay(Config.BreakDelay, function()
			if humanoid and humanoid.Health > 0 then
				if Config.RespawnOnDeath then
					humanoid.Health = 0 -- Esto hará que respawnee
				else
					-- Eliminar al jugador del juego
					humanoid.Health = 0
					if player then
						task.delay(2, function()
							player:Kick("¡Caíste del Glass Bridge!")
						end)
					end
				end
			end
		end)

		-- Programar regeneración después del delay configurado
		if not self.RegenerationScheduled then
			self.RegenerationScheduled = true
			task.delay(Config.RegenerateDelay, function()
				self:Regenerate()
			end)
		end
	end
end

-- Regenerar el panel después de ser destruido
function GlassPanel:Regenerate()
	print("Regenerando panel (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

	-- Si el panel todavía existe, destruirlo primero
	if self.Part and self.Part.Parent then
		self.Part:Destroy()
	end

	-- Resetear estados
	self.HasBeenTouched = false
	self.IsDestroyed = false
	self.RegenerationScheduled = false

	-- Recrear el panel
	self:CreatePart()

	-- Reconectar la detección de toque
	self:SetupTouchDetection()

	-- Efecto visual de regeneración
	if self.Part then
		-- Empezar invisible y aparecer gradualmente
		self.Part.Transparency = 1

		local tweenService = game:GetService("TweenService")
		local tweenInfo = TweenInfo.new(
			0.5, -- Duración
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local goal = {
			Transparency = Config.InitialTransparency
		}

		local tween = tweenService:Create(self.Part, tweenInfo, goal)
		tween:Play()

		-- Efecto de partículas de regeneración
		local regenEffect = Instance.new("ParticleEmitter")
		regenEffect.Parent = self.Part
		regenEffect.Name = "RegenerationParticles"

		regenEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		regenEffect.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
		regenEffect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0)
		})
		regenEffect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})

		regenEffect.Lifetime = NumberRange.new(0.5, 1)
		regenEffect.Rate = 50
		regenEffect.Speed = NumberRange.new(5, 10)
		regenEffect.SpreadAngle = Vector2.new(180, 180)

		regenEffect:Emit(30)

		-- Sonido de regeneración
		local regenSound = Instance.new("Sound")
		regenSound.Parent = self.Part
		regenSound.SoundId = "rbxassetid://6895079853" -- Sonido de regeneración
		regenSound.Volume = 0.3
		regenSound.PlaybackSpeed = 1.5
		regenSound:Play()

		-- Limpiar efectos
		task.delay(2, function()
			if regenEffect then regenEffect:Destroy() end
			if regenSound then regenSound:Destroy() end
		end)
	end
end

-- Revelar si es seguro o falso (para debug)
function GlassPanel:Reveal()
	if self.IsSafe then
		self.Part.Color = Config.SafePanelColor
	else
		self.Part.Color = Config.FakePanelColor
	end
	self.Part.Transparency = 0.5
end

-- Destruir el panel
function GlassPanel:Destroy()
	if self.Part then
		self.Part:Destroy()
	end
end

return GlassPanel
```

---

## 📄 SCRIPT 4: GlassBridgeManager.lua
**Ubicación:** `ServerScriptService > GlassBridgeManager` (Script)

```lua
--[[
	GlassBridgeManager.lua
	Script principal para gestionar el minijuego Glass Bridge

	Coloca este script en: ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Config = require(ModuleScripts:WaitForChild("GlassBridgeConfig"))
local GlassPanel = require(ModuleScripts:WaitForChild("GlassPanel"))
local Effects = require(ModuleScripts:WaitForChild("GlassBridgeEffects"))

-- Variables globales
local GlassBridgeFolder
local AllPanels = {}
local CorrectPath = {} -- Almacena qué lado es seguro en cada fila

-- Inicializar el juego
local function Initialize()
	print("=== Inicializando Glass Bridge ===")

	-- Crear carpeta en workspace
	GlassBridgeFolder = Instance.new("Folder")
	GlassBridgeFolder.Name = "GlassBridge"
	GlassBridgeFolder.Parent = workspace

	-- Crear RemoteEvent para efectos locales del cliente
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GlassBridgeEffectEvent"
	remoteEvent.Parent = ReplicatedStorage

	-- Generar camino aleatorio
	GenerateRandomPath()

	-- Construir el puente
	BuildBridge()

	-- Crear plataformas de inicio y fin
	CreatePlatforms()

	print("=== Glass Bridge Generado Exitosamente ===")
	print("Filas totales: " .. Config.NumberOfRows)
	print("Camino correcto generado aleatoriamente")
end

-- Generar camino aleatorio (qué lado es seguro en cada fila)
function GenerateRandomPath()
	print("Generando camino aleatorio...")

	math.randomseed(tick())

	for row = 1, Config.NumberOfRows do
		-- Aleatoriamente elegir "Left" o "Right" como seguro
		local safeSide = (math.random(1, 2) == 1) and "Left" or "Right"
		CorrectPath[row] = safeSide

		print("Fila " .. row .. ": Panel seguro = " .. safeSide)
	end
end

-- Construir todo el puente
function BuildBridge()
	print("Construyendo puente...")

	local currentZ = Config.StartPosition.Z

	for row = 1, Config.NumberOfRows do
		-- Avanzar en Z
		currentZ = currentZ + Config.PanelSize.Z + Config.GapBetweenRows

		-- Determinar qué panel es seguro
		local safeSide = CorrectPath[row]

		-- Posición del panel izquierdo
		local leftPosition = Vector3.new(
			Config.StartPosition.X - (Config.PanelSize.X / 2 + Config.GapBetweenPanels / 2),
			Config.StartPosition.Y,
			currentZ
		)

		-- Posición del panel derecho
		local rightPosition = Vector3.new(
			Config.StartPosition.X + (Config.PanelSize.X / 2 + Config.GapBetweenPanels / 2),
			Config.StartPosition.Y,
			currentZ
		)

		-- Crear panel izquierdo
		local leftPanel = GlassPanel.new(
			leftPosition,
			safeSide == "Left", -- Es seguro si safeSide es "Left"
			row,
			"Left"
		)
		table.insert(AllPanels, leftPanel)

		-- Crear panel derecho
		local rightPanel = GlassPanel.new(
			rightPosition,
			safeSide == "Right", -- Es seguro si safeSide es "Right"
			row,
			"Right"
		)
		table.insert(AllPanels, rightPanel)
	end

	print("Puente construido: " .. #AllPanels .. " paneles creados")
end

-- Crear plataformas de inicio y victoria
function CreatePlatforms()
	print("Creando plataformas...")

	-- Plataforma de inicio
	local startPos = Config.StartPosition - Vector3.new(0, 0, 10)
	Effects.CreateStartPlatform(startPos, Vector3.new(20, 1, 10))

	-- Plataforma de victoria
	local winZ = Config.StartPosition.Z + (Config.NumberOfRows * (Config.PanelSize.Z + Config.GapBetweenRows)) + 15
	local winPos = Vector3.new(Config.StartPosition.X, Config.StartPosition.Y, winZ)
	Effects.CreateWinPlatform(winPos, Vector3.new(20, 1, 10))

	print("Plataformas creadas")
end

-- Reiniciar el puente (opcional)
function ResetBridge()
	print("Reiniciando Glass Bridge...")

	-- Destruir todos los paneles
	for _, panel in ipairs(AllPanels) do
		panel:Destroy()
	end
	AllPanels = {}
	CorrectPath = {}

	-- Limpiar carpeta
	if GlassBridgeFolder then
		GlassBridgeFolder:ClearAllChildren()
	end

	-- Regenerar
	GenerateRandomPath()
	BuildBridge()
	CreatePlatforms()

	print("Glass Bridge reiniciado")
end

-- Revelar el camino correcto (para testing/debug)
function RevealPath()
	print("Revelando camino correcto...")
	for _, panel in ipairs(AllPanels) do
		panel:Reveal()
	end
end

-- Comandos de consola (opcional)
_G.GlassBridge = {
	Reset = ResetBridge,
	Reveal = RevealPath,
	Config = Config
}

-- Iniciar el juego
Initialize()

print("Comandos disponibles:")
print("_G.GlassBridge.Reset() - Reinicia el puente")
print("_G.GlassBridge.Reveal() - Revela el camino correcto")
```

---

## 📄 SCRIPT 5: GlassBridgeClientEffects.lua ⭐ NUEVO
**Ubicación:** `StarterPlayer > StarterPlayerScripts > GlassBridgeClientEffects` (LocalScript)

**⚠️ IMPORTANTE: Este debe ser un LocalScript, NO un Script normal**

```lua
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
```

---

## 📋 INSTALACIÓN PASO A PASO

### 1️⃣ Crear carpeta ModuleScripts
1. En **ReplicatedStorage**, crea carpeta **"ModuleScripts"**

### 2️⃣ Crear ModuleScripts (3 archivos)
En `ReplicatedStorage > ModuleScripts`:

1. Crea **ModuleScript** → Nómbralo **"GlassBridgeConfig"** → Copia Script 1
2. Crea **ModuleScript** → Nómbralo **"GlassBridgeEffects"** → Copia Script 2
3. Crea **ModuleScript** → Nómbralo **"GlassPanel"** → Copia Script 3

### 3️⃣ Crear Script del Servidor
En **ServerScriptService**:

1. Crea **Script** → Nómbralo **"GlassBridgeManager"** → Copia Script 4

### 4️⃣ Crear LocalScript del Cliente ⭐ NUEVO
En **StarterPlayer > StarterPlayerScripts**:

1. Abre **StarterPlayer** en Explorer
2. Abre **StarterPlayerScripts**
3. Crea **LocalScript** → Nómbralo **"GlassBridgeClientEffects"** → Copia Script 5

**⚠️ MUY IMPORTANTE:** El Script 5 debe ser un **LocalScript**, NO un Script normal.

### 5️⃣ ¡Jugar!
Presiona **Play (F5)** y prueba:
- Pisa un panel seguro → Solo TÚ verás el efecto verde y escucharás el sonido
- Otros jugadores NO verán ni escucharán tus efectos de éxito

---

## ✨ Resumen de Cambios

| Característica | Antes | Ahora |
|----------------|-------|-------|
| **Paneles verdes** | Permanecen verdes | Vuelven a color original |
| **Efectos visuales** | Todos los ven | Solo el jugador que pisa |
| **Sonido de éxito** | Todos lo escuchan | Solo el jugador que pisa |
| **Arquitectura** | Solo servidor | Cliente + Servidor |

---

¡Listo para copiar y usar! 🎮✨
