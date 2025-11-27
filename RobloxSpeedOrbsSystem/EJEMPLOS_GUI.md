# 🎨 EJEMPLOS DE GUI PARA EL SISTEMA

Este archivo contiene ejemplos completos de cómo crear las GUIs necesarias para el sistema.

---

## 📋 ESTRUCTURA RECOMENDADA DE GUI

```
StarterGui/
└── MainGui (ScreenGui)
    ├── SpeedDisplay (Frame)
    │   └── SpeedLabel (TextLabel)
    │
    ├── MobileControls (Frame)
    │   └── SprintButton (TextButton)
    │
    └── ReviveFrame (Frame)
        └── ReviveButton (TextButton)
```

---

## 🎯 EJEMPLO 1: GUI SIMPLE

### **Crear la GUI en Roblox Studio:**

1. **StarterGui > Insertar ScreenGui**
   - Nombre: `MainGui`

2. **MainGui > Insertar TextLabel**
   - Nombre: `SpeedLabel`
   - Propiedades:
     - Position: `{0.5, -100}, {0.05, 0}` (arriba centro)
     - Size: `{0, 200}, {0, 40}`
     - AnchorPoint: `0.5, 0`
     - BackgroundColor3: `0, 0, 0` (negro)
     - BackgroundTransparency: `0.5`
     - TextColor3: `255, 255, 255` (blanco)
     - TextScaled: `true`
     - Font: `GothamBold`
     - Text: `"Velocidad: 16"`

3. **MainGui > Insertar TextButton**
   - Nombre: `SprintButton`
   - Propiedades:
     - Position: `{0.85, 0}, {0.8, 0}`
     - Size: `{0, 100}, {0, 100}`
     - AnchorPoint: `0.5, 0.5`
     - BackgroundColor3: `255, 255, 255` (blanco)
     - TextColor3: `0, 0, 0` (negro)
     - TextScaled: `true`
     - Font: `GothamBold`
     - Text: `"SPRINT"`

4. **MainGui > Insertar TextButton**
   - Nombre: `ReviveButton`
   - Propiedades:
     - Position: `{0.5, 0}, {0.5, 0}`
     - Size: `{0, 200}, {0, 60}`
     - AnchorPoint: `0.5, 0.5`
     - BackgroundColor3: `0, 255, 0` (verde)
     - TextColor3: `255, 255, 255` (blanco)
     - TextScaled: `true`
     - Font: `GothamBold`
     - Text: `"REVIVIR"`
     - Visible: `false` (se muestra automáticamente al morir)

### **Configurar CustomGUIHandler.lua:**

```lua
local SCREEN_GUI_NAME = "MainGui"
local SPEED_LABEL_NAME = "SpeedLabel"
local SPRINT_BUTTON_NAME = "SprintButton"
local REVIVE_BUTTON_NAME = "ReviveButton"
```

---

## 🎯 EJEMPLO 2: GUI CON FRAMES (Organizada)

### **Estructura:**

```
MainGui (ScreenGui)
├── TopBar (Frame)
│   └── SpeedLabel (TextLabel)
│
├── MobileUI (Frame)
│   └── SprintButton (ImageButton)
│
└── CenterUI (Frame)
    └── ReviveButton (TextButton)
```

### **Crear en Roblox Studio:**

1. **StarterGui > Insertar ScreenGui**
   - Nombre: `MainGui`

2. **MainGui > Insertar Frame**
   - Nombre: `TopBar`
   - Position: `{0, 0}, {0, 0}`
   - Size: `{1, 0}, {0, 50}`
   - BackgroundColor3: `0, 0, 0`
   - BackgroundTransparency: `0.3`

3. **TopBar > Insertar TextLabel**
   - Nombre: `SpeedLabel`
   - Position: `{0.5, -100}, {0.5, -20}`
   - Size: `{0, 200}, {0, 40}`
   - AnchorPoint: `0.5, 0.5`
   - (Resto de propiedades igual que antes)

4. **MainGui > Insertar Frame**
   - Nombre: `MobileUI`
   - Position: `{0.8, 0}, {0.7, 0}`
   - Size: `{0, 120}, {0, 120}`
   - BackgroundTransparency: `1`

5. **MobileUI > Insertar TextButton**
   - Nombre: `SprintButton`
   - Position: `{0.5, 0}, {0.5, 0}`
   - Size: `{0, 100}, {0, 100}`
   - AnchorPoint: `0.5, 0.5`
   - (Resto igual que antes)

6. **MainGui > Insertar Frame**
   - Nombre: `CenterUI`
   - Position: `{0.5, -100}, {0.5, -30}`
   - Size: `{0, 200}, {0, 60}`
   - AnchorPoint: `0.5, 0.5`
   - BackgroundTransparency: `1`

7. **CenterUI > Insertar TextButton**
   - Nombre: `ReviveButton`
   - (Resto igual que antes)

### **Configurar CustomGUIHandler.lua:**

```lua
-- La búsqueda recursiva (true) encontrará los elementos aunque estén dentro de Frames
local SCREEN_GUI_NAME = "MainGui"
local SPEED_LABEL_NAME = "SpeedLabel"
local SPRINT_BUTTON_NAME = "SprintButton"
local REVIVE_BUTTON_NAME = "ReviveButton"
```

---

## 🎯 EJEMPLO 3: CÓDIGO LUA PARA CREAR GUI AUTOMÁTICAMENTE

Si prefieres crear la GUI mediante código, usa este script:

### **Script de Creación de GUI (LocalScript en StarterPlayerScripts):**

```lua
--[[
    AUTO-CREATE GUI SCRIPT
    Crea automáticamente la GUI necesaria para el sistema
    Solo ejecuta este script UNA VEZ para crear la GUI
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- SPEED LABEL
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
speedLabel.Size = UDim2.new(0, 200, 0, 40)
speedLabel.AnchorPoint = Vector2.new(0.5, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.BackgroundTransparency = 0.5
speedLabel.BorderSizePixel = 0
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "Velocidad: 16"
speedLabel.Parent = screenGui

-- Borde decorativo
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedLabel

-- SPRINT BUTTON (MÓVIL)
local sprintButton = Instance.new("TextButton")
sprintButton.Name = "SprintButton"
sprintButton.Position = UDim2.new(0.85, 0, 0.8, 0)
sprintButton.Size = UDim2.new(0, 100, 0, 100)
sprintButton.AnchorPoint = Vector2.new(0.5, 0.5)
sprintButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sprintButton.BorderSizePixel = 0
sprintButton.TextColor3 = Color3.fromRGB(0, 0, 0)
sprintButton.TextScaled = true
sprintButton.Font = Enum.Font.GothamBold
sprintButton.Text = "SPRINT"
sprintButton.Visible = false -- Se muestra automáticamente en móvil
sprintButton.Parent = screenGui

-- Borde decorativo
local sprintCorner = Instance.new("UICorner")
sprintCorner.CornerRadius = UDim.new(0, 12)
sprintCorner.Parent = sprintButton

-- REVIVE BUTTON
local reviveButton = Instance.new("TextButton")
reviveButton.Name = "ReviveButton"
reviveButton.Position = UDim2.new(0.5, 0, 0.5, 0)
reviveButton.Size = UDim2.new(0, 200, 0, 60)
reviveButton.AnchorPoint = Vector2.new(0.5, 0.5)
reviveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
reviveButton.BorderSizePixel = 0
reviveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reviveButton.TextScaled = true
reviveButton.Font = Enum.Font.GothamBold
reviveButton.Text = "REVIVIR"
reviveButton.Visible = false
reviveButton.Parent = screenGui

-- Borde decorativo
local reviveCorner = Instance.new("UICorner")
reviveCorner.CornerRadius = UDim.new(0, 10)
reviveCorner.Parent = reviveButton

print("GUI creada automáticamente: MainGui")
```

---

## 🎨 PERSONALIZACIÓN DE ESTILOS

### **Añadir Gradientes:**

```lua
-- En SpeedLabel
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
}
gradient.Rotation = 45
gradient.Parent = speedLabel
```

### **Añadir Sombras:**

```lua
-- Duplicar el TextLabel y ponerlo detrás
local shadow = speedLabel:Clone()
shadow.Name = "Shadow"
shadow.Position = UDim2.new(0.5, -98, 0.05, 2) -- Ligeramente desplazado
shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 1
shadow.ZIndex = speedLabel.ZIndex - 1
shadow.Parent = screenGui
```

### **Animaciones de Botones:**

```lua
-- Script en el botón para efecto hover
local button = script.Parent
local tweenService = game:GetService("TweenService")

local normalSize = button.Size
local hoverSize = UDim2.new(normalSize.X.Scale, normalSize.X.Offset + 10,
                            normalSize.Y.Scale, normalSize.Y.Offset + 10)

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

button.MouseEnter:Connect(function()
    local tween = tweenService:Create(button, tweenInfo, {Size = hoverSize})
    tween:Play()
end)

button.MouseLeave:Connect(function()
    local tween = tweenService:Create(button, tweenInfo, {Size = normalSize})
    tween:Play()
end)
```

---

## 📱 RESPONSIVE DESIGN (Adaptable a móvil)

### **Script para adaptar GUI al tamaño de pantalla:**

```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("MainGui")

local function UpdateLayout()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local isSmallScreen = viewportSize.X < 800

    local speedLabel = screenGui:FindFirstChild("SpeedLabel")
    if speedLabel then
        if isSmallScreen then
            -- Pantalla pequeña (móvil)
            speedLabel.Position = UDim2.new(0.5, 0, 0.02, 0)
            speedLabel.Size = UDim2.new(0.6, 0, 0, 35)
        else
            -- Pantalla grande (PC)
            speedLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
            speedLabel.Size = UDim2.new(0, 200, 0, 40)
        end
    end
end

-- Actualizar al cambiar tamaño
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateLayout)
UpdateLayout()
```

---

## 🎯 INTEGRACIÓN AVANZADA

### **Mostrar Boost de Velocidad Separado:**

Añade este código a `CustomGUIHandler.lua`:

```lua
-- Crear un label adicional para mostrar el boost
local boostLabel = Instance.new("TextLabel")
boostLabel.Name = "BoostLabel"
boostLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
boostLabel.Size = UDim2.new(0, 200, 0, 30)
boostLabel.AnchorPoint = Vector2.new(0.5, 0)
boostLabel.BackgroundTransparency = 1
boostLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
boostLabel.TextScaled = true
boostLabel.Font = Enum.Font.Gotham
boostLabel.Parent = screenGui

-- Actualizar el boost
RunService.Heartbeat:Connect(function()
    if _G.PlayerOrbsManager then
        local boost = _G.PlayerOrbsManager:GetSpeedBoost()
        boostLabel.Text = string.format("+%.0f Boost", boost)
    end
end)
```

### **Contador de Orbs Recogidas:**

```lua
local orbsCollected = 0
local orbsLabel = Instance.new("TextLabel")
orbsLabel.Name = "OrbsLabel"
orbsLabel.Position = UDim2.new(0.5, -100, 0.15, 0)
orbsLabel.Size = UDim2.new(0, 200, 0, 30)
orbsLabel.AnchorPoint = Vector2.new(0.5, 0)
orbsLabel.BackgroundTransparency = 1
orbsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
orbsLabel.TextScaled = true
orbsLabel.Font = Enum.Font.Gotham
orbsLabel.Text = "Orbs: 0"
orbsLabel.Parent = screenGui

-- Escuchar cuando se recoge una orb
local orbCollectedEvent = ReplicatedStorage.RemoteEvents:WaitForChild("OrbCollected")
orbCollectedEvent.OnClientEvent:Connect(function()
    orbsCollected = orbsCollected + 1
    orbsLabel.Text = "Orbs: " .. orbsCollected
end)
```

---

## ✨ EFECTOS VISUALES EXTRA

### **Partículas al tocar el botón:**

```lua
local function CreateClickEffect(button)
    button.MouseButton1Click:Connect(function()
        -- Crear efecto de onda
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 0, 0, 0)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BackgroundTransparency = 0
        circle.BorderSizePixel = 0
        circle.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        -- Animar
        local tween = tweenService:Create(circle, TweenInfo.new(0.5), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })

        tween:Play()
        tween.Completed:Connect(function()
            circle:Destroy()
        end)
    end)
end

-- Aplicar a todos los botones
CreateClickEffect(sprintButton)
CreateClickEffect(reviveButton)
```

---

**¡Usa estos ejemplos para crear GUIs increíbles para tu juego!** 🎨
