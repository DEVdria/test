# 🗺️ Guía de Estructura del Mapa

Esta guía explica cómo configurar el mapa para que funcione el sistema de fila física.

## 📍 Requisitos del Mapa

### 1. Carpeta LinePositions en Workspace

Debes crear una carpeta en el **Workspace** llamada exactamente `LinePositions`.

```
Workspace
└── LinePositions (Folder)
    ├── Part1 (Part)
    ├── Part2 (Part)
    ├── Part3 (Part)
    ├── Part4 (Part)
    ├── Part5 (Part)
    └── ... (más Parts según necesites)
```

### 2. Crear las Posiciones

#### Opción A: Manual

1. En **Workspace**, crea una **Folder**
2. Nómbrala exactamente `LinePositions`
3. Dentro de la carpeta, inserta **Parts**
4. Nombra las Parts en orden: `Part1`, `Part2`, `Part3`, etc.

#### Opción B: Con Script (más rápido)

Puedes usar este código en la Command Bar de Roblox Studio:

```lua
-- Ejecutar en Command Bar para crear 10 posiciones automáticamente
local folder = Instance.new("Folder")
folder.Name = "LinePositions"
folder.Parent = workspace

for i = 1, 10 do
    local part = Instance.new("Part")
    part.Name = "Part" .. i
    part.Size = Vector3.new(4, 1, 4)
    part.Position = Vector3.new(0, 3, i * 6)  -- Espaciado de 6 studs
    part.Anchored = true
    part.BrickColor = BrickColor.new("Bright blue")
    part.Material = Enum.Material.Neon
    part.Parent = folder
end

print("✓ 10 posiciones de fila creadas")
```

## 🎨 Diseño de la Fila

### Configuración Recomendada

#### Tamaño de las Parts
- **Tamaño mínimo**: 4x1x4 studs
- **Tamaño recomendado**: 5x1x5 studs
- Asegúrate de que sea lo suficientemente grande para un personaje

#### Espaciado
- **Mínimo**: 5 studs entre cada posición
- **Recomendado**: 6-8 studs
- Evita que los personajes se superpongan

#### Propiedades Importantes
```lua
part.Anchored = true          -- IMPORTANTE: Debe estar anclado
part.CanCollide = false       -- Opcional: para que no colisione
part.Transparency = 0.5       -- Opcional: semi-transparente
```

### Ejemplos de Diseño

#### 1️⃣ Fila Horizontal (Recomendado)
```
[Part1] → [Part2] → [Part3] → [Part4] → [Part5]
  ↑         ↑         ↑         ↑         ↑
 Turno    Segundo   Tercero   Cuarto   Quinto
```

Código:
```lua
for i = 1, 10 do
    part.Position = Vector3.new(i * 6, 3, 0)
end
```

#### 2️⃣ Fila Vertical
```
[Part1]  ← Turno
   ↓
[Part2]  ← Segundo
   ↓
[Part3]  ← Tercero
   ↓
[Part4]  ← Cuarto
```

Código:
```lua
for i = 1, 10 do
    part.Position = Vector3.new(0, 3, i * 6)
end
```

#### 3️⃣ Fila en Zigzag
```
[Part1] → [Part2] → [Part3]
                      ↓
[Part6] ← [Part5] ← [Part4]
  ↓
[Part7] → [Part8] → [Part9]
```

(Requiere posicionamiento manual)

#### 4️⃣ Fila Circular
```
     [Part2]
  [Part1] [Part3]
[Part8]     [Part4]
  [Part7] [Part5]
     [Part6]
```

(Requiere cálculo con trigonometría)

## ⚙️ Configuración Avanzada

### Personalización Visual

#### Plataformas de Colores
```lua
-- Part1 (turno actual) - Verde brillante
Part1.BrickColor = BrickColor.new("Lime green")
Part1.Material = Enum.Material.Neon

-- Otras posiciones - Azul
for i = 2, 10 do
    parts[i].BrickColor = BrickColor.new("Bright blue")
end
```

#### Agregar Números
```lua
-- Agregar números sobre cada posición
local billboardGui = Instance.new("BillboardGui")
billboardGui.Size = UDim2.new(0, 50, 0, 50)
billboardGui.StudsOffset = Vector3.new(0, 2, 0)
billboardGui.Parent = part

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = tostring(i)
label.TextScaled = true
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Parent = billboardGui
```

#### Efectos de Partículas
```lua
-- Agregar efecto de partículas a la posición del turno
local particles = Instance.new("ParticleEmitter")
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Rate = 50
particles.Lifetime = NumberRange.new(1, 2)
particles.Parent = Part1
```

## 🔍 Verificación

### Checklist antes de Probar

- [ ] Existe una carpeta llamada `LinePositions` en Workspace
- [ ] Contiene al menos 3-5 Parts (para probar con varios jugadores)
- [ ] Las Parts están nombradas `Part1`, `Part2`, `Part3`, etc.
- [ ] Las Parts están **Anchored = true**
- [ ] Las Parts tienen suficiente espacio entre ellas
- [ ] Las Parts están posicionadas a una altura razonable (Y = 3 o más)

### Probar en Studio

1. Presiona **F5** para probar
2. Revisa la **Output** console
3. Deberías ver:
   ```
   [FILA] 5 posiciones encontradas
     Posición 1: Part1
     Posición 2: Part2
     Posición 3: Part3
     ...
   ```

## ❌ Problemas Comunes

### "LinePositions not found"
❌ **Problema**: La carpeta no existe o tiene nombre incorrecto
✅ **Solución**: Asegúrate de que se llame exactamente `LinePositions`

### "No hay suficientes posiciones"
❌ **Problema**: Hay más jugadores que posiciones
✅ **Solución**: Crea más Parts (recomendado: 10-20)

### "Los jugadores no se mueven"
❌ **Problema**: Las Parts no están ancladas o no tienen el nombre correcto
✅ **Solución**: Verifica que:
- `Anchored = true`
- Los nombres sean exactamente `Part1`, `Part2`, etc.
- Los números sean consecutivos (sin saltos)

### "Los jugadores aparecen dentro del suelo"
❌ **Problema**: La altura Y de las Parts es muy baja
✅ **Solución**: Ajusta `Position.Y` a 3 o más

## 🎯 Recomendaciones Finales

### Número de Posiciones
- **Mínimo**: 3 posiciones (para pruebas)
- **Recomendado**: 10-15 posiciones
- **Óptimo**: 20 posiciones (para servidores grandes)

### Ubicación en el Mapa
- Coloca la fila cerca de donde los jugadores spawnearan
- Asegúrate de que sea visible y accesible
- Considera agregar señalización o decoración alrededor

### Estética
- Usa materiales llamativos (Neon, ForceField)
- Agrega iluminación (PointLight, SpotLight)
- Considera agregar flechas o señales indicando la dirección

## 📚 Ejemplo Completo

Script completo para crear una fila profesional:

```lua
-- EJECUTAR EN COMMAND BAR
local folder = Instance.new("Folder")
folder.Name = "LinePositions"
folder.Parent = workspace

local numPositions = 10
local spacing = 7
local startPos = Vector3.new(-30, 3, 0)

for i = 1, numPositions do
    -- Crear Part
    local part = Instance.new("Part")
    part.Name = "Part" .. i
    part.Size = Vector3.new(5, 0.5, 5)
    part.Position = startPos + Vector3.new((i-1) * spacing, 0, 0)
    part.Anchored = true
    part.CanCollide = false
    
    -- Color especial para la primera posición
    if i == 1 then
        part.BrickColor = BrickColor.new("Lime green")
        part.Material = Enum.Material.Neon
    else
        part.BrickColor = BrickColor.new("Deep blue")
        part.Material = Enum.Material.SmoothPlastic
        part.Transparency = 0.3
    end
    
    part.Parent = folder
    
    -- Agregar borde
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Agregar número
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 60, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(i)
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard
end

print("✓ Fila de " .. numPositions .. " posiciones creada con éxito")
```

---

**¡Tu mapa está listo para el sistema de fila física! 🎮**
