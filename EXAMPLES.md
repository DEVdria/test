# Ejemplos de Configuración - Single Row Glass Panel System

Este documento contiene ejemplos de diferentes configuraciones y variaciones del sistema de paneles de cristal de una sola fila.

## ⚠️ IMPORTANTE

Este sistema es **completamente independiente** del Glass Bridge. Todos los ejemplos usan:
- Folder: `SingleRowGlass` (NO `GlassBridge`)
- Paneles: `SinglePanel1`, `SinglePanel2`, etc. (NO `Panel1`, `Panel2`)

## 📚 Tabla de Contenidos

1. [Configuración Básica](#configuración-básica)
2. [Configuraciones Avanzadas](#configuraciones-avanzadas)
3. [Variaciones de Dificultad](#variaciones-de-dificultad)
4. [Efectos Visuales](#efectos-visuales)
5. [Debugging y Testing](#debugging-y-testing)

---

## Configuración Básica

### Ejemplo 1: Puente Simple (10 paneles)

Configuración para un puente corto ideal para principiantes:

```lua
-- En SingleRowSetupScript.lua
local CONFIG = {
    NUM_PANELS = 10,
    PANEL_SIZE = Vector3.new(4, 0.5, 4),
    START_POSITION = Vector3.new(0, 5, 0),
    SPACING = 5,
    DIRECTION = "Z",
    FOLDER_NAME = "SingleRowGlass", -- ⚠️ Nombre único
}
```

**Tiempos de caída:**
- Panel 1-10: 5.0s a 4.1s

---

### Ejemplo 2: Puente Largo (20 paneles)

Para jugadores más experimentados:

```lua
local CONFIG = {
    NUM_PANELS = 20,
    PANEL_SIZE = Vector3.new(4, 0.5, 4),
    START_POSITION = Vector3.new(0, 5, 0),
    SPACING = 4.5,
    DIRECTION = "Z",
}
```

**Tiempos de caída:**
- Panel 1-20: 5.0s a 3.1s

---

## Configuraciones Avanzadas

### Ejemplo 3: Puente con Paneles Más Pequeños

Mayor dificultad al reducir el tamaño de los paneles:

```lua
-- Ajustar en SingleRowGlassSystem.lua
local BASE_FALL_TIME = 4.0 -- Tiempo más corto
local TIME_REDUCTION = 0.15 -- Reducción más agresiva

-- En SingleRowSetupScript.lua
local CONFIG = {
    NUM_PANELS = 15,
    PANEL_SIZE = Vector3.new(3, 0.5, 3), -- Paneles más pequeños
    SPACING = 4,
}
```

**Características:**
- Paneles más difíciles de alcanzar
- Tiempo de caída más rápido
- Mayor dificultad general

---

### Ejemplo 4: Puente en Diagonal

Crear un puente que vaya en diagonal:

```lua
-- Modificar calculatePosition en PanelSetupScript.lua
local function calculatePosition(index)
    local offset = (index - 1) * CONFIG.SPACING
    local position = CONFIG.START_POSITION

    -- Diagonal en X y Z
    position = position + Vector3.new(offset * 0.5, 0, offset)

    return position
end
```

---

### Ejemplo 5: Puente Curvo

Para crear un puente con forma de arco:

```lua
-- Modificar en SingleRowSetupScript.lua
local function calculatePosition(index)
    local offset = (index - 1) * CONFIG.SPACING
    local angle = math.rad(offset * 5) -- Ángulo de curvatura
    local radius = 20 -- Radio de la curva

    local x = math.sin(angle) * radius
    local z = math.cos(angle) * radius
    local y = CONFIG.START_POSITION.Y

    return Vector3.new(x, y, z)
end
```

---

## Variaciones de Dificultad

### Modo Fácil

```lua
-- En SingleRowGlassSystem.lua
local GLASS_FOLDER_NAME = "SingleRowGlass" -- ⚠️ No cambiar este nombre
local BASE_FALL_TIME = 7.0 -- Mucho tiempo
local TIME_REDUCTION = 0.05 -- Reducción lenta
local RESPAWN_TIME = 10 -- Respawn más rápido
```

**Características:**
- Ideal para niños o nuevos jugadores
- Los paneles tardan mucho en caer
- Tiempo suficiente para pensar

---

### Modo Normal

```lua
local BASE_FALL_TIME = 5.0
local TIME_REDUCTION = 0.1
local RESPAWN_TIME = 15
```

**Características:**
- Balance entre desafío y accesibilidad
- Configuración por defecto del sistema

---

### Modo Difícil

```lua
local BASE_FALL_TIME = 3.0 -- Tiempo muy corto
local TIME_REDUCTION = 0.15 -- Reducción agresiva
local RESPAWN_TIME = 20 -- Tarda más en respawnear
```

**Características:**
- Requiere reacciones rápidas
- Los últimos paneles caen casi instantáneamente
- Mayor tensión y desafío

---

### Modo Experto

```lua
local BASE_FALL_TIME = 2.0
local TIME_REDUCTION = 0.2
local RESPAWN_TIME = 30
local PANEL_SIZE = Vector3.new(3, 0.5, 3) -- Paneles pequeños
```

**Características:**
- Extremadamente difícil
- Requiere velocidad y precisión
- Solo para jugadores muy experimentados

---

## Efectos Visuales

### Ejemplo 6: Paneles de Lava

```lua
local CONFIG = {
    MATERIAL = Enum.Material.Neon,
    TRANSPARENCY = 0.2,
    COLOR = Color3.fromRGB(255, 100, 0), -- Naranja/rojo
    REFLECTANCE = 0,
}

-- Agregar ParticleEmitter (en el script de setup)
local function addLavaEffect(panel)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/fire_main.dds"
    emitter.Rate = 20
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.Speed = NumberRange.new(2, 5)
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
    emitter.Parent = panel
end
```

---

### Ejemplo 7: Paneles de Hielo

```lua
local CONFIG = {
    MATERIAL = Enum.Material.Ice,
    TRANSPARENCY = 0.4,
    COLOR = Color3.fromRGB(173, 216, 230), -- Azul hielo
    REFLECTANCE = 0.6,
}

-- Agregar brillo
local function addIceEffect(panel)
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(173, 216, 230)
    pointLight.Brightness = 2
    pointLight.Range = 15
    pointLight.Parent = panel
end
```

---

### Ejemplo 8: Paneles Arcoíris

```lua
-- Modificar createPanel para darle color diferente a cada panel
local function createPanel(index, parent)
    local panel = Instance.new("Part")
    -- ... configuración normal ...

    -- Color basado en el índice
    local hue = (index * 30) % 360 -- Rotar por el espectro de color
    panel.Color = Color3.fromHSV(hue / 360, 1, 1)
    panel.Material = Enum.Material.Neon

    panel.Parent = parent
    return panel
end
```

---

## Debugging y Testing

### Script de Testing - Mostrar Tiempos

Agregar esto al LocalScript (SingleRowGlassSystem.lua) para ver los tiempos en pantalla:

```lua
-- Crear GUI para mostrar información (agregar al final de SingleRowGlassSystem.lua)
local function createDebugGUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlassPanelDebug"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(1, -310, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Font = Enum.Font.Code
    textLabel.TextSize = 14
    textLabel.Parent = frame

    return textLabel
end

local debugLabel = createDebugGUI()

-- Actualizar información cada frame
RunService.Heartbeat:Connect(function()
    local info = "GLASS PANEL DEBUG\n\n"

    for panel, state in pairs(panelStates) do
        if panel and panel.Parent then
            local status = "Waiting"
            if state.isFalling then
                status = "Falling"
            elseif state.isActivated then
                local remaining = state.fallTime - (tick() - state.activationTime)
                status = string.format("%.1fs", math.max(0, remaining))
            end

            info = info .. string.format(
                "Panel %d: %s\n",
                state.panelNumber,
                status
            )
        end
    end

    debugLabel.Text = info
end)
```

---

### Script de Testing - Teleport a Inicio

Útil para probar rápidamente:

```lua
-- Agregar a SingleRowGlassSystem.lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Presionar R para resetear posición
    if input.KeyCode == Enum.KeyCode.R then
        if humanoidRootPart then
            local glassFolder = workspace:FindFirstChild(GLASS_FOLDER_NAME)
            if glassFolder then
                local firstPanel = glassFolder:FindFirstChild("SinglePanel1") -- ⚠️ Nombre correcto
                if firstPanel then
                    humanoidRootPart.CFrame = firstPanel.CFrame + Vector3.new(0, 5, 0)
                    print("Teleportado al inicio")
                end
            end
        end
    end
end)
```

---

## Configuración para Diferentes Modos de Juego

### Modo Carrera Contrareloj

```lua
-- Agregar timer global
local START_TIME = 60 -- 60 segundos para completar

local timerLabel = -- crear GUI

local startTime = tick()
RunService.Heartbeat:Connect(function()
    local elapsed = tick() - startTime
    local remaining = START_TIME - elapsed

    if remaining <= 0 then
        -- Game Over
        timerLabel.Text = "TIME'S UP!"
    else
        timerLabel.Text = string.format("Time: %.1fs", remaining)
    end
end)
```

---

### Modo Survival (Última Persona)

```lua
-- Para múltiples jugadores
-- Agregar sistema de puntos cuando un jugador cae
local function onPlayerFell(player)
    -- Registrar que el jugador cayó
    -- Mostrar en leaderboard
end
```

---

## Notas Finales

- Experimenta con diferentes combinaciones de configuraciones
- Ajusta los valores según la dificultad deseada
- Prueba con diferentes grupos de jugadores
- Los tiempos pueden variar según el FPS del cliente

¡Diviértete creando tus propias variaciones!
