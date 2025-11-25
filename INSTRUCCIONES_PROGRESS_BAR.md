# 📊 Instrucciones para Crear la Progress Bar

## 🎨 Paso 1: Crear la Interfaz en StarterGui

1. Abre **StarterGui** en Roblox Studio
2. Crea un **ScreenGui**
3. Nómbralo: `ProgressBarGui`
4. **IMPORTANTE**: Set `Enabled = false`

### Estructura Requerida:

```
ProgressBarGui (ScreenGui)
  Enabled = false
  ResetOnSpawn = false
  ZIndexBehavior = Sibling

  └── ProgressBarFrame (Frame)
      Position = UDim2.new(0.5, 0, 0.9, 0)
      Size = UDim2.new(0.4, 0, 0.05, 0)
      AnchorPoint = Vector2.new(0.5, 0.5)
      BackgroundTransparency = 1

      ├── Background (Frame)
      │   Name = "Background"
      │   Size = UDim2.new(1, 0, 1, 0)
      │   BackgroundColor3 = Color3.fromRGB(50, 50, 50)
      │   BorderColor3 = Color3.fromRGB(255, 255, 255)
      │   BorderSizePixel = 2
      │
      │   └── UICorner
      │       CornerRadius = UDim.new(0.2, 0)
      │
      └── Fill (Frame)
          Name = "Fill"
          Size = UDim2.new(0, 0, 1, 0)  ← Empieza en 0!
          Position = UDim2.new(0, 0, 0, 0)
          BackgroundColor3 = Color3.fromRGB(0, 255, 0)
          BorderSizePixel = 0

          └── UICorner
              CornerRadius = UDim.new(0.2, 0)
```

## 🎨 Personalización Recomendada:

### Cambiar Posición:
```lua
ProgressBarFrame.Position = UDim2.new(0.5, 0, 0.1, 0) -- Arriba centro
ProgressBarFrame.Position = UDim2.new(0.95, 0, 0.5, 0) -- Derecha centro
```

### Cambiar Tamaño:
```lua
ProgressBarFrame.Size = UDim2.new(0.6, 0, 0.08, 0) -- Más grande
```

### Agregar Gradiente:
```lua
-- En el Frame "Fill", agrega un UIGradient:
UIGradient
  Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),    -- Rojo al inicio
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))     -- Verde al final
  })
  Rotation = 0
```

### Agregar Texto de Porcentaje:
```lua
-- Dentro de ProgressBarFrame, agregar:
TextLabel
  Name = "PercentageText"
  Size = UDim2.new(1, 0, 1, 0)
  BackgroundTransparency = 1
  Text = "0%"
  TextScaled = true
  TextColor3 = Color3.white
  Font = Enum.Font.GothamBold
  ZIndex = 10
```

### Cambiar Colores:
```lua
-- Fondo oscuro
Background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Barra verde neón
Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)

-- Barra azul
Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
```

### Agregar Sombra:
```lua
-- Dentro de ProgressBarFrame, agregar:
UIStroke
  Color = Color3.fromRGB(0, 0, 0)
  Thickness = 3
  Transparency = 0.5
```

## ⚠️ Requisitos Importantes:

1. **Nombre exacto de los elementos**:
   - ScreenGui DEBE llamarse `ProgressBarGui`
   - Frame principal DEBE llamarse `ProgressBarFrame`
   - Frame de fondo DEBE llamarse `Background`
   - Frame de relleno DEBE llamarse `Fill`

2. **Enabled = false**: El ScreenGui DEBE empezar deshabilitado

3. **Fill empieza en 0**: `Size = UDim2.new(0, 0, 1, 0)`

4. **ResetOnSpawn = false**: Para que no se reinicie cuando respawneas

## 🎮 El Script Actualiza Automáticamente:

- `Fill.Size.X.Scale` - De 0 a 1 según el progreso
- `ProgressBarGui.Enabled` - true/false para mostrar/ocultar

Si agregas un TextLabel con nombre "PercentageText", el script también actualizará el texto del porcentaje.
