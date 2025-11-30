# 🐾 SISTEMA DE MASCOTAS PARA ROBLOX - GUÍA COMPLETA

Sistema completo de mascotas con huevos, inventario, equipar/desequipar, multiplicadores y visualización 3D.

---

## 📋 ÍNDICE

1. [Estructura de Archivos](#estructura-de-archivos)
2. [Instalación Paso a Paso](#instalación-paso-a-paso)
3. [Configuración](#configuración)
4. [Crear Modelos de Mascotas](#crear-modelos-de-mascotas)
5. [Crear Huevos en el Mapa](#crear-huevos-en-el-mapa)
6. [Conectar tus GUIs](#conectar-tus-guis)
7. [RemoteEvents Disponibles](#remoteevents-disponibles)
8. [Ejemplos de Código](#ejemplos-de-código)

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
ReplicatedStorage/
  ├── PetConfig (ModuleScript)          -- Configuración de mascotas y huevos
  ├── ViewportUtil (ModuleScript)       -- Utilidad para mostrar modelos 3D
  ├── RemoteEvents (Folder)             -- Se crea automáticamente
  │   ├── OpenEgg (RemoteEvent)
  │   ├── EquipPet (RemoteEvent)
  │   ├── UnequipPet (RemoteEvent)
  │   ├── ShowPetReward (RemoteEvent)
  │   ├── AutoOpenToggle (RemoteEvent)
  │   ├── ShowEggUI (RemoteEvent)
  │   └── HideEggUI (RemoteEvent)
  └── PetsModels (Folder)               -- TÚ pones aquí los modelos

ServerScriptService/
  ├── CreateRemoteEvents (Script)       -- Ejecutar UNA VEZ para setup
  ├── DataManager (ModuleScript)        -- Sistema de guardado
  ├── PetSystemServer (Script)          -- Lógica principal del servidor
  └── PetFollowSystem (ModuleScript)    -- Sistema de seguimiento

StarterPlayer/StarterPlayerScripts/
  ├── PetSystemClient (LocalScript)     -- Ejemplos para conectar GUIs
  └── EggProximityDetector (LocalScript)-- Detección de rango de huevos

Workspace/
  └── Eggs (Folder)                     -- TÚ pones aquí los huevos
      ├── BasicEgg (Model)
      └── GoldenEgg (Model)
```

---

## 🚀 INSTALACIÓN PASO A PASO

### **Paso 1: Copiar los archivos**

1. Copia todos los scripts a las carpetas correspondientes según la estructura de arriba.
2. Asegúrate de que los nombres de archivos sean exactos.

### **Paso 2: Ejecutar el script de configuración**

1. Ve a `ServerScriptService` → `CreateRemoteEvents`
2. **Ejecuta el juego** (Play)
3. Verás en la consola que se crean los RemoteEvents y carpetas necesarias.
4. **Opcional:** Puedes deshabilitar este script después de la primera ejecución.

### **Paso 3: Configurar tu sistema de monedas**

1. Abre `ReplicatedStorage` → `PetConfig`
2. Busca la línea:
```lua
PetConfig.CurrencyName = "Coins"
```
3. Cámbiala por el nombre de TU moneda (debe coincidir con el nombre en `leaderstats`).

Ejemplo:
```lua
PetConfig.CurrencyName = "Money"  -- Si tu moneda se llama "Money"
```

### **Paso 4: Configurar tus mascotas y huevos**

Edita `PetConfig.lua` en la sección `PetConfig.Eggs`:

```lua
PetConfig.Eggs = {
    BasicEgg = {
        DisplayName = "Basic Egg",
        Price = 250,
        Gamepass_TripleOpen = 123456,    -- Cambia por tu ID de gamepass
        Gamepass_AutoOpen = 7891011,     -- Cambia por tu ID de gamepass
        Pets = {
            {Name = "Dog", Rarity = "Common", Chance = 60, xpMultiplier = 1.0},
            {Name = "Cat", Rarity = "Uncommon", Chance = 35, xpMultiplier = 1.1},
            {Name = "Fox", Rarity = "Rare", Chance = 5, xpMultiplier = 1.25},
        }
    }
}
```

**IMPORTANTE:**
- `Name` debe coincidir EXACTAMENTE con el nombre del modelo en `ReplicatedStorage.PetsModels`
- `Chance` es el porcentaje de probabilidad (deben sumar 100)
- Los IDs de gamepass son opcionales (déjalos si no usas gamepasses)

---

## 🎨 CREAR MODELOS DE MASCOTAS

### **Requisitos del modelo:**

1. Debe ser un **Model** (no un simple Part)
2. Debe tener un **PrimaryPart** definido (usualmente el cuerpo principal)
3. Todas las partes deben estar ancladas (`Anchored = false`)
4. El modelo debe estar centrado en su origen (0,0,0)

### **Pasos:**

1. Crea tu mascota en Roblox Studio (puede ser con MeshParts, Unions, etc.)
2. Agrupa todo en un **Model**
3. Selecciona el Model → Properties → `PrimaryPart` → Elige la parte principal
4. Nombra el Model igual que en `PetConfig` (ej: "Dog", "Cat", "Fox")
5. Mueve el modelo a `ReplicatedStorage` → `PetsModels`

**Ejemplo:**
```
ReplicatedStorage/
  └── PetsModels/
      ├── Dog (Model)
      │   ├── Body (MeshPart) [PrimaryPart]
      │   ├── Head (MeshPart)
      │   └── Tail (Part)
      ├── Cat (Model)
      └── Fox (Model)
```

---

## 🥚 CREAR HUEVOS EN EL MAPA

### **Pasos:**

1. Crea un Model en Workspace
2. Añade una **Part** principal (puede ser con forma de huevo)
3. Selecciona el Model → Properties → `PrimaryPart` → Elige la Part del huevo
4. Nombra el Model igual que la clave en `PetConfig.Eggs` (ej: "BasicEgg", "GoldenEgg")
5. Mueve el modelo a `Workspace` → `Eggs`

**Ejemplo:**
```
Workspace/
  └── Eggs/
      ├── BasicEgg (Model)
      │   └── EggPart (Part) [PrimaryPart]
      └── GoldenEgg (Model)
          └── EggPart (MeshPart) [PrimaryPart]
```

**IMPORTANTE:** El nombre del Model en Workspace debe coincidir con la clave en `PetConfig.Eggs`.

---

## 🎮 CONECTAR TUS GUIS

El sistema **NO incluye GUIs**, solo la lógica. Tú debes crear las GUIs y conectarlas usando los RemoteEvents.

### **GUIs que necesitas crear:**

1. **GUI de Huevo** (cuando el jugador se acerca)
2. **GUI de Recompensa** (cuando abre un huevo)
3. **GUI de Inventario** (para ver y equipar mascotas)

---

### **1. GUI de Huevo**

Crea una ScreenGui en `StarterGui` con:
- Frame principal
- Botón "Abrir 1"
- Botón "Abrir 3"
- Toggle "Auto-Open"
- TextLabels para precio y nombre

**Script de ejemplo (LocalScript dentro de la GUI):**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PetConfig = require(ReplicatedStorage.PetConfig)
local RemoteEventsFolder = ReplicatedStorage.RemoteEvents
local OpenEggRemote = RemoteEventsFolder.OpenEgg
local AutoOpenToggleRemote = RemoteEventsFolder.AutoOpenToggle
local ShowEggUIRemote = RemoteEventsFolder.ShowEggUI
local HideEggUIRemote = RemoteEventsFolder.HideEggUI

local player = Players.LocalPlayer
local gui = script.Parent  -- Tu Frame principal
local currentEggType = nil

-- Cuando el servidor dice que muestres la GUI
ShowEggUIRemote.OnClientEvent:Connect(function(eggType)
    currentEggType = eggType
    local eggConfig = PetConfig.Eggs[eggType]

    -- Actualizar GUI
    gui.EggName.Text = eggConfig.DisplayName
    gui.Price.Text = eggConfig.Price
    gui.Visible = true
end)

-- Cuando el servidor dice que ocultes la GUI
HideEggUIRemote.OnClientEvent:Connect(function()
    gui.Visible = false
    currentEggType = nil
end)

-- Botón "Abrir 1"
gui.OpenButton.MouseButton1Click:Connect(function()
    if currentEggType then
        OpenEggRemote:FireServer(currentEggType, "Single")
    end
end)

-- Botón "Abrir 3"
gui.Open3Button.MouseButton1Click:Connect(function()
    if currentEggType then
        OpenEggRemote:FireServer(currentEggType, "Triple")
    end
end)

-- Toggle "Auto-Open"
local autoOpenEnabled = false
gui.AutoOpenToggle.MouseButton1Click:Connect(function()
    autoOpenEnabled = not autoOpenEnabled
    AutoOpenToggleRemote:FireServer(currentEggType, autoOpenEnabled)

    -- Actualizar UI
    gui.AutoOpenToggle.Text = autoOpenEnabled and "Stop Auto-Open" or "Auto-Open"
end)
```

---

### **2. GUI de Recompensa**

Crea una ScreenGui con:
- ViewportFrame (para mostrar la mascota en 3D)
- TextLabels para nombre y rareza

**Script de ejemplo:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ViewportUtil = require(ReplicatedStorage.ViewportUtil)
local PetConfig = require(ReplicatedStorage.PetConfig)
local ShowPetRewardRemote = ReplicatedStorage.RemoteEvents.ShowPetReward

local player = Players.LocalPlayer
local gui = script.Parent
local viewportFrame = gui.ViewportFrame

ShowPetRewardRemote.OnClientEvent:Connect(function(status, data)
    if status == "Success" then
        -- data = tabla de mascotas obtenidas
        local pet = data[1]  -- Primera mascota (si abriste 3, tendrás 3 en la tabla)

        -- Mostrar modelo 3D con rotación
        ViewportUtil.ShowPetInViewport(viewportFrame, pet.Name, true, 1)

        -- Actualizar info
        gui.PetName.Text = pet.Name
        gui.Rarity.Text = pet.Rarity
        gui.Rarity.TextColor3 = PetConfig.Rarities[pet.Rarity].Color

        -- Mostrar GUI
        gui.Visible = true

    elseif status == "NotEnoughMoney" then
        -- Mostrar mensaje de error
        print("No tienes suficiente dinero")

    elseif status == "NoGamepass" then
        -- Mostrar mensaje de gamepass
        print("Necesitas el gamepass para esta función")
    end
end)

-- Botón para cerrar
gui.CloseButton.MouseButton1Click:Connect(function()
    gui.Visible = false
end)
```

---

### **3. GUI de Inventario**

Crea una ScreenGui con:
- ScrollingFrame para la lista de mascotas
- Template de mascota (Frame con ViewportFrame, nombre, botón equipar)

**Script de ejemplo:**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ViewportUtil = require(ReplicatedStorage.ViewportUtil)
local PetConfig = require(ReplicatedStorage.PetConfig)
local EquipPetRemote = ReplicatedStorage.RemoteEvents.EquipPet
local UnequipPetRemote = ReplicatedStorage.RemoteEvents.UnequipPet

local player = Players.LocalPlayer
local gui = script.Parent
local scrollingFrame = gui.ScrollingFrame
local template = gui.Template  -- Template oculto

-- Función para actualizar el inventario
function updateInventory()
    -- Limpiar lista actual
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= template then
            child:Destroy()
        end
    end

    -- NOTA: Necesitas obtener las mascotas del servidor
    -- Puedes crear un RemoteFunction para esto
    -- Por ahora, ejemplo manual:

    local pets = {
        {Name = "Dog", Rarity = "Common", UniqueID = "abc123", Equipped = false},
        {Name = "Cat", Rarity = "Uncommon", UniqueID = "def456", Equipped = true},
    }

    for i, pet in ipairs(pets) do
        local petFrame = template:Clone()
        petFrame.Name = pet.UniqueID
        petFrame.Visible = true
        petFrame.Parent = scrollingFrame

        -- Mostrar modelo 3D
        ViewportUtil.ShowPetInViewport(petFrame.ViewportFrame, pet.Name, true, 0.5)

        -- Info
        petFrame.PetName.Text = pet.Name
        petFrame.Rarity.Text = pet.Rarity
        petFrame.Rarity.TextColor3 = PetConfig.Rarities[pet.Rarity].Color

        -- Botón equipar/desequipar
        local button = petFrame.EquipButton
        button.Text = pet.Equipped and "Unequip" or "Equip"

        button.MouseButton1Click:Connect(function()
            if pet.Equipped then
                UnequipPetRemote:FireServer(pet.UniqueID)
            else
                EquipPetRemote:FireServer(pet.UniqueID)
            end

            -- Esperar y actualizar
            task.wait(0.5)
            updateInventory()
        end)
    end
end

-- Actualizar al abrir
gui.Visible = true
updateInventory()
```

---

## 📡 REMOTEEVENTS DISPONIBLES

### **Cliente → Servidor:**

| RemoteEvent | Parámetros | Descripción |
|-------------|-----------|-------------|
| `OpenEgg` | `eggType: string, openType: string` | Abrir huevo ("Single", "Triple") |
| `EquipPet` | `petUniqueID: string` | Equipar mascota |
| `UnequipPet` | `petUniqueID: string` | Desequipar mascota |
| `AutoOpenToggle` | `eggType: string, enabled: boolean` | Activar/desactivar auto-open |
| `ShowEggUI` | `eggType: string` | *(Interno)* Jugador entró en rango |
| `HideEggUI` | `nil` | *(Interno)* Jugador salió del rango |

### **Servidor → Cliente:**

| RemoteEvent | Parámetros | Descripción |
|-------------|-----------|-------------|
| `ShowPetReward` | `status: string, data: table` | Resultado de apertura de huevo |
| `ShowEggUI` | `eggType: string` | Mostrar GUI del huevo |
| `HideEggUI` | `nil` | Ocultar GUI del huevo |

---

## 🔧 EJEMPLOS DE CÓDIGO

### **Usar ViewportUtil:**

```lua
local ViewportUtil = require(ReplicatedStorage.ViewportUtil)

-- Mostrar mascota con rotación
local viewportData = ViewportUtil.ShowPetInViewport(
    yourViewportFrame,  -- Tu ViewportFrame
    "Dog",              -- Nombre de la mascota
    true,               -- Auto-rotar (true/false)
    1                   -- Velocidad de rotación
)

-- Cambiar de mascota
ViewportUtil.UpdatePetInViewport(yourViewportFrame, "Cat", true, 1)

-- Limpiar al cerrar GUI
ViewportUtil.CleanupViewport(viewportData)
```

### **Obtener configuración de huevo:**

```lua
local PetConfig = require(ReplicatedStorage.PetConfig)

local eggConfig = PetConfig.Eggs["BasicEgg"]
print(eggConfig.DisplayName)  -- "Basic Egg"
print(eggConfig.Price)        -- 250
```

### **Obtener color de rareza:**

```lua
local rarityColor = PetConfig.Rarities["Legendary"].Color
yourTextLabel.TextColor3 = rarityColor
```

---

## ⚙️ CONFIGURACIÓN AVANZADA

### **Cambiar máximo de mascotas equipadas:**

```lua
-- En PetConfig.lua
PetConfig.Settings.MaxEquippedPets = 5  -- Default: 3
```

### **Cambiar distancia de seguimiento:**

```lua
PetConfig.Settings.PetFollowDistance = 8  -- Default: 5
```

### **Cambiar rango de detección de huevos:**

```lua
PetConfig.Settings.EggDetectionRange = 20  -- Default: 15
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### **Las mascotas no aparecen:**
- Verifica que los modelos estén en `ReplicatedStorage.PetsModels`
- Verifica que el nombre en `PetConfig` coincida exactamente con el nombre del modelo
- Verifica que el modelo tenga `PrimaryPart` definido

### **La GUI del huevo no aparece:**
- Verifica que el huevo esté en `Workspace.Eggs`
- Verifica que el nombre del huevo coincida con `PetConfig.Eggs`
- Verifica que `EggProximityDetector` esté en `StarterPlayerScripts`

### **No se guardan las mascotas:**
- Verifica que DataStore esté habilitado en Game Settings
- Revisa la consola del servidor para errores de DataStore

### **Error "RemoteEvent not found":**
- Ejecuta `CreateRemoteEvents` (en ServerScriptService)
- Verifica que todos los scripts esperen a los RemoteEvents con `:WaitForChild()`

---

## 📝 NOTAS FINALES

- **NO se incluyen GUIs**, solo lógica
- **Todos los scripts están comentados** para que puedas modificarlos
- **El sistema es modular**: puedes usar solo las partes que necesites
- **Compatible con cualquier sistema de monedas** (solo configura `CurrencyName`)

---

## 💡 TIPS

1. Empieza con un solo huevo y 2-3 mascotas para probar
2. Usa `print()` en tus GUIs para debugear
3. Revisa `PetSystemClient.lua` para ver ejemplos completos
4. Los multiplicadores (`xpMultiplier`) puedes usarlos en tu sistema de XP

---

**¡Sistema creado! Solo falta que agregues tus modelos y GUIs!** 🎉
