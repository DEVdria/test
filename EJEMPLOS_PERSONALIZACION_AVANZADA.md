# 🎨 EJEMPLOS DE PERSONALIZACIÓN AVANZADA

Esta guía contiene ejemplos de personalización avanzada del sistema de orbs.

---

## 🌟 AÑADIR NUEVOS TIPOS DE ORBS

### Ejemplo 1: Orb Púrpura (Épico)

Abre `ReplicatedStorage > Modules > OrbConfig` y añade en `OrbConfig.OrbTypes`:

```lua
Purple = {
    Name = "Purple",
    SpeedBonus = 5,                              -- +5 velocidad
    MoneyReward = 100,                           -- $100
    Color = Color3.fromRGB(150, 0, 255),         -- Color púrpura
    Size = Vector3.new(3, 3, 3),                 -- Más grande
    Material = Enum.Material.Neon,
    Transparency = 0.2,                          -- Más sólido
    ParticleColor = ColorSequence.new(Color3.fromRGB(150, 0, 255))
},
```

### Ejemplo 2: Orb Dorado (Legendario)

```lua
Gold = {
    Name = "Gold",
    SpeedBonus = 10,                             -- +10 velocidad
    MoneyReward = 500,                           -- $500
    Color = Color3.fromRGB(255, 215, 0),         -- Dorado brillante
    Size = Vector3.new(4, 4, 4),                 -- Muy grande
    Material = Enum.Material.Neon,
    Transparency = 0.1,
    ParticleColor = ColorSequence.new(Color3.fromRGB(255, 215, 0))
},
```

### Ejemplo 3: Orb Rojo (Rápido)

```lua
Red = {
    Name = "Red",
    SpeedBonus = 15,                             -- +15 velocidad (mucha!)
    MoneyReward = 25,                            -- Poco dinero
    Color = Color3.fromRGB(255, 0, 0),           -- Rojo intenso
    Size = Vector3.new(1.5, 1.5, 1.5),           -- Pequeño
    Material = Enum.Material.Neon,
    Transparency = 0.3,
    ParticleColor = ColorSequence.new(Color3.fromRGB(255, 0, 0))
},
```

---

## 🗺️ CONFIGURACIONES AVANZADAS DE ZONAS

### Ejemplo 1: Zona de Principiantes

```lua
{
    Name = "BeginnerZone",
    Position = Vector3.new(0, 5, 0),
    Size = Vector3.new(100, 0, 100),             -- Zona grande
    SpawnHeight = 5,
    OrbTypes = {"Yellow"},                       -- Solo amarillos (fácil)
    MaxOrbs = 30,                                -- Muchos orbs
    RespawnTime = 1                              -- Spawn rápido
},
```

### Ejemplo 2: Zona Intermedia

```lua
{
    Name = "IntermediateZone",
    Position = Vector3.new(200, 10, 0),
    Size = Vector3.new(80, 0, 80),
    SpawnHeight = 10,
    OrbTypes = {"Yellow", "Green", "Blue"},      -- Mix de todos
    MaxOrbs = 20,
    RespawnTime = 2
},
```

### Ejemplo 3: Zona VIP (Solo orbs legendarios)

```lua
{
    Name = "VIPZone",
    Position = Vector3.new(500, 50, 0),          -- Lejos y alto
    Size = Vector3.new(40, 0, 40),               -- Zona pequeña
    SpawnHeight = 50,
    OrbTypes = {"Purple", "Gold"},               -- Solo épicos
    MaxOrbs = 5,                                 -- Pocos orbs
    RespawnTime = 10                             -- Spawn lento
},
```

### Ejemplo 4: Zona de Desafío (Orbs en movimiento)

Para hacer orbs que se muevan, necesitarías modificar `OrbManager.AnimateOrb`:

```lua
-- Añade en OrbManager.AnimateOrb después de la flotación:
-- Movimiento horizontal
task.spawn(function()
    local elapsed = 0
    local moveSpeed = 5
    local moveRadius = 10
    while orb and orb.Parent do
        elapsed = elapsed + task.wait()
        local offsetX = math.sin(elapsed * moveSpeed) * moveRadius
        local offsetZ = math.cos(elapsed * moveSpeed) * moveRadius
        if orb and orb.Parent then
            orb.Position = startPosition + Vector3.new(offsetX, math.sin(elapsed * bobSpeed) * bobHeight, offsetZ)
        else
            break
        end
    end
end)
```

---

## 💰 SISTEMAS DE REBIRTH PERSONALIZADOS

### Ejemplo 1: Rebirths Baratos y Frecuentes

```lua
-- En OrbConfig.Rebirth:
Rebirth = {
    BaseCost = 5000,              -- Muy barato
    CostMultiplier = 1.2,         -- Aumenta poco
    BaseSpeedMultiplier = 1.05,   -- +5% por rebirth
    SpeedMultiplierIncrease = 0.02,
}
```

### Ejemplo 2: Rebirths Caros pero Poderosos

```lua
Rebirth = {
    BaseCost = 50000,             -- Muy caro
    CostMultiplier = 2,           -- Se duplica cada vez
    BaseSpeedMultiplier = 1.5,    -- +50% por rebirth
    SpeedMultiplierIncrease = 0.1,
}
```

### Ejemplo 3: Sistema de Rebirth Escalonado

Modifica `OrbConfig.CalculateRebirthCost` para usar costos fijos por niveles:

```lua
function OrbConfig.CalculateRebirthCost(currentRebirths)
    local costs = {
        [0] = 15000,   -- Rebirth 1
        [1] = 30000,   -- Rebirth 2
        [2] = 60000,   -- Rebirth 3
        [3] = 120000,  -- Rebirth 4
        [4] = 250000,  -- Rebirth 5
        [5] = 500000,  -- Rebirth 6
        [6] = 1000000, -- Rebirth 7+
    }

    return costs[currentRebirths] or costs[6] * (currentRebirths - 5)
end
```

---

## 🎯 MODIFICAR EFECTOS VISUALES

### Ejemplo 1: Orbs que Brillan Más

En `OrbManager.CreateOrb`, modifica:

```lua
-- Aumentar brillo de la luz
pointLight.Brightness = 5          -- De 2 a 5
pointLight.Range = 30              -- De 15 a 30

-- Más partículas
sparkles.Rate = 50                 -- De 20 a 50
```

### Ejemplo 2: Orbs con Efecto de Arcoíris

```lua
-- Añade en OrbManager.CreateOrb después de crear el orb:
task.spawn(function()
    local hue = 0
    while orb and orb.Parent do
        hue = (hue + 0.01) % 1
        orb.Color = Color3.fromHSV(hue, 1, 1)
        pointLight.Color = orb.Color
        task.wait(0.05)
    end
end)
```

### Ejemplo 3: Efecto de Explosión al Recoger

Modifica `OrbManager.PlayCollectionEffect`:

```lua
-- Añade después de crear effectOrb:
-- Crear onda expansiva
local wave = Instance.new("Part")
wave.Shape = Enum.PartType.Ball
wave.Size = Vector3.new(1, 1, 1)
wave.Position = effectOrb.Position
wave.Anchored = true
wave.CanCollide = false
wave.Material = Enum.Material.Neon
wave.Color = effectOrb.Color
wave.Transparency = 0.5
wave.Parent = effectOrb.Parent

local waveTween = TweenService:Create(
    wave,
    TweenInfo.new(0.5),
    {Size = Vector3.new(15, 15, 15), Transparency = 1}
)
waveTween:Play()

task.delay(0.6, function()
    wave:Destroy()
end)
```

---

## 🏃 MODIFICAR SISTEMA DE RUNNING

### Ejemplo 1: Límite Máximo de Velocidad

En `Running.lua`, modifica `getTotalRunSpeed`:

```lua
local function getTotalRunSpeed()
    local totalSpeed = config.Speed + accumulatedSpeed
    local maxSpeed = 100  -- Límite máximo
    return math.min(totalSpeed, maxSpeed)
end
```

### Ejemplo 2: Velocidad Exponencial

```lua
local function getTotalRunSpeed()
    -- Velocidad crece exponencialmente pero con límite suave
    local baseSpeed = config.Speed
    local speedBonus = accumulatedSpeed
    -- Fórmula: base + bonus * (1 - e^(-bonus/100))
    local scaledBonus = speedBonus * (1 - math.exp(-speedBonus / 100))
    return baseSpeed + scaledBonus
end
```

### Ejemplo 3: Velocidad con Efectos de Partículas Mejorados

```lua
-- Añade en el Heartbeat loop, después de crear RunDust:
if accumulatedSpeed > 50 then
    -- Efecto especial si tienes mucha velocidad
    local trail = Instance.new("Trail")
    local att0 = Instance.new("Attachment")
    local att1 = Instance.new("Attachment")

    att0.Parent = RootPart
    att1.Parent = RootPart
    att0.Position = Vector3.new(-1, 0, 0)
    att1.Position = Vector3.new(1, 0, 0)

    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    trail.Lifetime = 0.5
    trail.Parent = RootPart

    task.delay(2, function()
        trail:Destroy()
        att0:Destroy()
        att1:Destroy()
    end)
end
```

---

## 📊 SISTEMA DE NIVELES BASADO EN VELOCIDAD

### Añadir niveles automáticos

Crea un nuevo ModuleScript `LevelSystem` en ReplicatedStorage/Modules:

```lua
local LevelSystem = {}

function LevelSystem.CalculateLevel(accumulatedSpeed)
    return math.floor(accumulatedSpeed / 10) + 1
end

function LevelSystem.GetLevelName(level)
    local names = {
        [1] = "Novato",
        [2] = "Corredor",
        [3] = "Velocista",
        [4] = "Relámpago",
        [5] = "Supersónico",
        [6] = "Legendario"
    }

    return names[math.min(level, 6)] or "Dios de la Velocidad"
end

return LevelSystem
```

Luego, en `SpeedDisplayScript`, modifica:

```lua
local LevelSystem = require(ReplicatedStorage.Modules.LevelSystem)

local function updateDisplay(speed)
    currentSpeed = speed or 0
    local level = LevelSystem.CalculateLevel(currentSpeed)
    local levelName = LevelSystem.GetLevelName(level)

    speedLabel.Text = string.format("Velocidad: +%d | Nivel %d: %s",
        math.floor(currentSpeed), level, levelName)
end
```

---

## 🎁 SISTEMA DE ORBS ESPECIALES POR TIEMPO

### Orbs que solo aparecen en ciertos momentos

Modifica `OrbGenerator.lua` para añadir:

```lua
-- Añade esta función:
local function isSpecialTime()
    local hour = os.date("*t").hour
    return hour >= 18 and hour <= 21  -- 6 PM a 9 PM
end

-- Modifica spawnOrbInZone para incluir orbs especiales:
local function spawnOrbInZone(zone)
    -- ... código existente ...

    local orbType = OrbConfig.GetRandomOrbTypeForZone(zoneName)

    -- Si es hora especial, 20% de probabilidad de orb dorado
    if isSpecialTime() and math.random(1, 100) <= 20 then
        orbType = "Gold"
    end

    -- ... resto del código ...
end
```

---

## 🌈 ORBS CON RAREZA

### Sistema de Rareza Automático

En `OrbConfig`, añade raridades:

```lua
OrbConfig.Rarities = {
    Common = {Chance = 60, Types = {"Yellow"}},
    Uncommon = {Chance = 25, Types = {"Green"}},
    Rare = {Chance = 10, Types = {"Blue"}},
    Epic = {Chance = 4, Types = {"Purple"}},
    Legendary = {Chance = 1, Types = {"Gold"}},
}
```

Luego crea una función para seleccionar por rareza:

```lua
function OrbConfig.GetRandomOrbByRarity()
    local roll = math.random(1, 100)
    local cumulative = 0

    for _, rarity in pairs(OrbConfig.Rarities) do
        cumulative = cumulative + rarity.Chance
        if roll <= cumulative then
            local types = rarity.Types
            return types[math.random(1, #types)]
        end
    end

    return "Yellow"  -- Fallback
end
```

---

## 🔊 AÑADIR SONIDOS

### Sonido al Recoger Orbs

En `OrbManager.PlayCollectionEffect`, añade:

```lua
-- Crear sonido
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://12345678"  -- Cambia por tu SoundId
sound.Volume = 0.5
sound.Parent = effectOrb
sound:Play()
```

### Sonido al Comprar Rebirth

En `RebirthGuiScript`, en la sección de éxito:

```lua
if result.Success then
    -- Reproducir sonido de éxito
    local successSound = Instance.new("Sound")
    successSound.SoundId = "rbxassetid://12345678"
    successSound.Volume = 0.7
    successSound.Parent = game.SoundService
    successSound:Play()

    task.delay(2, function()
        successSound:Destroy()
    end)
end
```

---

## 💡 CONSEJOS DE OPTIMIZACIÓN

### 1. Reducir Orbs para Mejor Performance

```lua
-- En cada zona:
MaxOrbs = 8,              -- Menos orbs
RespawnTime = 5,          -- Spawn más lento
```

### 2. Desactivar Efectos Visuales en Dispositivos Móviles

```lua
-- En OrbManager.CreateOrb, añade:
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if not isMobile then
    -- Crear partículas solo en PC
    local sparkles = Instance.new("ParticleEmitter")
    -- ... código de partículas ...
end
```

### 3. Limitar Distancia de Renderizado de Orbs

```lua
-- En OrbClientManager, añade:
local MAX_RENDER_DISTANCE = 200  -- studs

local function shouldRenderOrb(orbPosition)
    if not humanoidRootPart then return false end
    local distance = (humanoidRootPart.Position - orbPosition).Magnitude
    return distance <= MAX_RENDER_DISTANCE
end

-- Usa esto antes de crear orbs visuales
```

---

¡Experimenta con estas personalizaciones y crea un sistema único! 🚀
