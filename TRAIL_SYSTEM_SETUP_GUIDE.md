# 🌟 Guía de Configuración del Sistema de Trails

## 📋 Descripción General

Este sistema permite a los jugadores comprar y equipar **trails (estelas)** que aparecen en su **Torso** mientras se mueven por el juego (R6). El sistema es **completamente modular** y permite:

- ✅ Añadir nuevas trails fácilmente
- ✅ Personalizar texturas, colores, precios y requisitos
- ✅ Diseñar tu propia interfaz de tienda
- ✅ Guardar automáticamente trails compradas y equipadas

---

## 📁 Archivos del Sistema

### **Scripts Creados:**

1. **`ReplicatedStorage_Modules_TrailConfig.lua`** → Configuración de todas las trails
2. **`ReplicatedStorage_RemoteEventsInitializer.lua`** → Inicializa RemoteEvents necesarios
3. **`ServerScriptService_TrailManager.lua`** → Gestiona compra y equipamiento (servidor)
4. **`ServerScriptService_DataManager.lua`** → Actualizado para guardar trails
5. **`StarterGui_TrailShopGui.lua`** → Interfaz de la tienda (cliente)
6. **`StarterPlayer_StarterPlayerScripts_TrailApplier.lua`** → Aplica trails al Torso (cliente)

---

## 🎨 PASO 1: Configurar la Interfaz de la Tienda (GUI)

### **Estructura Requerida en StarterGui:**

```
StarterGui
└─ TrailShopGui (ScreenGui)
   ├─ OpenShopButton (TextButton) ← Botón visible para abrir la tienda
   └─ ShopFrame (Frame) ← Frame principal de la tienda (empieza oculto)
      ├─ CloseButton (TextButton) [OPCIONAL] ← Botón para cerrar
      ├─ TrailsContainer (ScrollingFrame o Frame) [OPCIONAL] ← Contenedor de trails
      └─ TrailCardTemplate (Frame) ← Template de una trail (se clona automáticamente)
         ├─ TrailName (TextLabel) [OPCIONAL] ← Nombre de la trail
         ├─ Description (TextLabel) [OPCIONAL] ← Descripción
         ├─ Price (TextLabel) [OPCIONAL] ← Precio en Stars
         ├─ Requirements (TextLabel) [OPCIONAL] ← Requisitos (nivel/rebirths)
         ├─ Status (TextLabel) [OPCIONAL] ← Estado (equipada/comprada/bloqueada)
         ├─ BuyButton (TextButton) [OPCIONAL] ← Botón de compra
         └─ EquipButton (TextButton) [OPCIONAL] ← Botón de equipar
```

### **Nombres Alternativos Aceptados:**

El script es flexible y acepta estos nombres:

- **TrailName** o **Name**
- **Description** o **Desc**
- **Price** o **PriceLabel**
- **Requirements** o **Reqs**
- **Status** o **StatusLabel**
- **BuyButton** o **PurchaseButton**

---

## ⚙️ PASO 2: Configurar las Trails (TrailConfig)

### **Ubicación:**
`ReplicatedStorage > Modules > TrailConfig`

### **Cómo Añadir una Nueva Trail:**

Abre el archivo `TrailConfig.lua` y añade una nueva entrada a la tabla `TrailConfig.Trails`:

```lua
{
    ID = "MiTrailUnica",              -- ID única (sin espacios)
    Name = "⚡ Mi Trail Personalizada", -- Nombre visible
    Description = "Una trail increíble",

    -- VISUAL (TÚ MODIFICAS ESTO)
    Texture = "rbxassetid://TU_TEXTURE_ID",  -- ID de tu textura
    Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)),  -- Color rojo
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),  -- Inicio semi-transparente
        NumberSequenceKeypoint.new(1, 1)     -- Final completamente transparente
    }),

    -- PROPIEDADES DE LA TRAIL
    Lifetime = 1.5,           -- Duración de la estela (segundos)
    MinLength = 0.1,
    WidthScale = NumberSequence.new(1),  -- Ancho de la trail

    -- PRECIO Y REQUISITOS
    Price = 10000,            -- 10,000 Stars
    RequiredLevel = 20,
    RequiredRebirths = 1,

    -- METADATA
    Category = "Premium",
    Rarity = "Rare",
    IsDefault = false
},
```

### **Texturas Predeterminadas de Roblox:**

Puedes usar estas texturas sin necesidad de subir assets:

```lua
"rbxasset://textures/particles/fire_main.dds"      -- Fuego
"rbxasset://textures/particles/smoke_main.dds"     -- Humo
"rbxasset://textures/particles/sparkles_main.dds"  -- Chispas
"rbxasset://textures/particles/snow.dds"           -- Nieve
```

### **Cómo Crear Colores Gradientes:**

```lua
-- Un solo color
Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))

-- Gradiente de 2 colores
Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),    -- Rojo al inicio
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))     -- Azul al final
})

-- Arcoíris (7 colores)
Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),      -- Rojo
    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),   -- Naranja
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),   -- Amarillo
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),      -- Verde
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),     -- Azul
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),    -- Índigo
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(148, 0, 211))     -- Violeta
})
```

---

## 🔧 PASO 3: Instalar los Scripts en Roblox Studio

### **1. ReplicatedStorage:**

```
ReplicatedStorage
├─ Modules (Folder)
│  └─ TrailConfig (ModuleScript) ← Pega el código de ReplicatedStorage_Modules_TrailConfig.lua
└─ RemoteEventsInitializer (Script) ← Pega el código de ReplicatedStorage_RemoteEventsInitializer.lua
```

### **2. ServerScriptService:**

```
ServerScriptService
├─ DataManager (Script) ← Ya existe, fue actualizado
└─ TrailManager (Script) ← Pega el código de ServerScriptService_TrailManager.lua
```

### **3. StarterGui:**

```
StarterGui
├─ TrailShopGui (ScreenGui) ← Crea la estructura GUI (ver PASO 1)
│  └─ TrailShopGui (LocalScript) ← Pega el código de StarterGui_TrailShopGui.lua
```

### **4. StarterPlayer:**

```
StarterPlayer
└─ StarterPlayerScripts
   └─ TrailApplier (LocalScript) ← Pega el código de StarterPlayer_StarterPlayerScripts_TrailApplier.lua
```

---

## 🎮 PASO 4: Ejecutar el Juego

1. **Ejecuta el juego** en Roblox Studio
2. El sistema se inicializará automáticamente
3. **Click en el botón** `OpenShopButton` para abrir la tienda
4. **Compra una trail** con tus Stars
5. **Equípala** y verás la estela aparecer en tu Torso mientras te mueves

---

## 🛠️ Personalización Avanzada

### **Cambiar Posición de los Attachments:**

En `TrailApplier.lua`, líneas 54-61:

```lua
-- Attachment superior (parte alta del torso)
attachment0.Position = Vector3.new(0, 1, 0)  -- (X, Y, Z)

-- Attachment inferior (parte baja del torso)
attachment1.Position = Vector3.new(0, -1, 0)
```

**Ejemplos:**
- Para trail horizontal: `Vector3.new(1, 0, 0)` y `Vector3.new(-1, 0, 0)`
- Para trail desde atrás: `Vector3.new(0, 0, 1)` y `Vector3.new(0, 0, -1)`

### **Cambiar Animación de la Tienda:**

En `TrailShopGui.lua`, función `openShop()` (línea 247):

```lua
-- Modificar duración (0.3 segundos)
TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Modificar tamaño final
{Size = UDim2.new(0.7, 0, 0.8, 0)}  -- 70% ancho, 80% alto
```

### **Añadir Más Propiedades Visuales:**

En `TrailApplier.lua`, líneas 72-76:

```lua
trail.LightEmission = 0.5     -- Brillo (0 a 1)
trail.LightInfluence = 0.2    -- Influencia de luz ambiental
trail.FaceCamera = true       -- Siempre mira a la cámara
-- Añade más propiedades:
trail.TextureMode = Enum.TextureMode.Stretch  -- o Wrap
trail.TextureLength = 10      -- Longitud de textura
```

---

## 📊 Sistema de Datos

### **Datos Guardados por Jugador:**

```lua
{
    OwnedTrails = {"Fire", "Lightning", "Rainbow"},  -- Trails compradas
    EquippedTrail = "Lightning"                      -- Trail actual
}
```

Los datos se guardan automáticamente cada 60 segundos y cuando el jugador se desconecta.

---

## 🐛 Solución de Problemas

### **"No se encontró ScreenGui 'TrailShopGui'"**
→ Asegúrate de crear el ScreenGui con el nombre exacto `TrailShopGui` en StarterGui

### **"No se encontró Torso (¿el personaje es R6?)"**
→ Tu juego debe estar configurado en modo **R6**. Ve a:
`Game Settings > Avatar > Avatar Type > R6`

### **"Trail no encontrada"**
→ Verifica que el ID de la trail en TrailConfig coincida exactamente (case-sensitive)

### **La trail no aparece visualmente**
→ Verifica que la textura existe y es válida. Usa texturas de Roblox predeterminadas para probar.

### **Los RemoteEvents no se encuentran**
→ Ejecuta el script `RemoteEventsInitializer` primero para crear los eventos.

---

## 📝 Notas Finales

- **Trail por defecto:** Todos los jugadores empiezan con la trail "Fire" (gratis)
- **Moneda:** Las trails se compran con **Stars** (Money en leaderstats)
- **Persistencia:** Las trails se guardan automáticamente en DataStore
- **Performance:** El sistema usa attachments nativos de Roblox para máxima eficiencia

---

## 🎯 Próximos Pasos

1. ✅ Diseña tu GUI de tienda personalizada
2. ✅ Añade más trails al TrailConfig
3. ✅ Personaliza texturas, colores y efectos
4. ✅ Ajusta precios y requisitos según tu economía de juego

¡Disfruta de tu sistema de trails! 🌟
