# Sistema de Notificaciones de Dinero - Guía de Diseño

## 📋 Descripción

El código de las notificaciones de dinero ya está listo. **TÚ solo necesitas diseñar la parte visual** en StarterGui.

El sistema:
- ✅ Detecta automáticamente cuando ganas dinero
- ✅ Muestra notificaciones en formato "+$X"
- ✅ Organiza las notificaciones en lista vertical
- ✅ Anima las apariciones y desapariciones
- ✅ Limita a 5 notificaciones máximo
- ✅ Elimina las más antiguas automáticamente

## 🎨 Cómo Diseñar la GUI

### Paso 1: Crear la Estructura Base

En **StarterGui**, crea esta estructura exacta:

```
StarterGui
└─ MoneyNotifications (ScreenGui)
   ├─ NotificationContainer (Frame)
   │  └─ UIListLayout
   └─ NotificationTemplate (Frame) [Visible = false]
      └─ MoneyLabel (TextLabel)
```

### Paso 2: Configurar Cada Elemento

#### 📺 **MoneyNotifications** (ScreenGui)
- **Tipo:** ScreenGui
- **Propiedades:**
  - `ResetOnSpawn = false`
  - `ZIndexBehavior = Sibling`

#### 📦 **NotificationContainer** (Frame)
Este es el contenedor donde aparecerán las notificaciones en lista.

**Propiedades recomendadas:**
```
Size = UDim2.new(0, 250, 0, 400)  -- Ancho: 250px, Alto: 400px
Position = UDim2.new(1, -270, 0, 20)  -- Esquina superior derecha
AnchorPoint = Vector2.new(1, 0)
BackgroundTransparency = 1  -- Invisible (solo contenedor)
```

**⚠️ IMPORTANTE:** Añade un **UIListLayout** dentro:
- `FillDirection = Vertical`
- `HorizontalAlignment = Right` (o Left/Center según prefieras)
- `VerticalAlignment = Top`
- `SortOrder = LayoutOrder`
- `Padding = UDim.new(0, 5)` (espacio entre notificaciones)

#### 🎴 **NotificationTemplate** (Frame)
Este es el template que se clonará para cada notificación. **DISEÑA ESTO COMO QUIERAS**.

**Propiedades base:**
```
Name = "NotificationTemplate"
Visible = false  (IMPORTANTE: debe estar oculto)
Size = UDim2.new(1, 0, 0, 40)  -- Ancho: 100%, Alto: 40px
BackgroundColor3 = Color3.fromRGB(46, 125, 50)  -- Verde (cámbialo)
BackgroundTransparency = 0.2  -- Semi-transparente (cámbialo)
```

**Elementos que PUEDES añadir:**
- ✨ UICorner (esquinas redondeadas)
- ✨ UIStroke (bordes)
- ✨ UIGradient (degradados)
- ✨ ImageLabel (iconos de moneda)
- ✨ Efectos visuales

#### 💰 **MoneyLabel** (TextLabel)
Este label mostrará el texto "+$100". El código cambiará automáticamente el texto.

**Propiedades recomendadas:**
```
Name = "MoneyLabel" (IMPORTANTE: debe tener este nombre exacto)
Size = UDim2.new(1, 0, 1, 0)  -- Ocupa todo el frame
BackgroundTransparency = 1  -- Sin fondo
Text = "+$999"  -- Texto de ejemplo (se cambiará automáticamente)
TextColor3 = Color3.fromRGB(255, 255, 255)  -- Blanco
TextSize = 20
Font = Enum.Font.GothamBold
TextXAlignment = Center
TextYAlignment = Center
```

**Puedes añadir:**
- TextStroke (contorno del texto)
- UITextSizeConstraint (límites de tamaño)

---

## 🎨 Ejemplos de Diseño

### Ejemplo 1: Diseño Minimalista
```
NotificationTemplate (Frame)
├─ BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Gris oscuro
├─ BackgroundTransparency = 0.3
├─ UICorner (CornerRadius = 8)
└─ MoneyLabel (TextLabel)
   ├─ TextColor3 = Color3.fromRGB(255, 215, 0)  -- Dorado
   ├─ Font = Gotham
   └─ TextSize = 18
```

### Ejemplo 2: Diseño con Icono
```
NotificationTemplate (Frame)
├─ BackgroundColor3 = Color3.fromRGB(46, 125, 50)  -- Verde
├─ UICorner (CornerRadius = 10)
├─ UIStroke (Color = dorado, Thickness = 2)
├─ CoinIcon (ImageLabel)  -- Imagen de moneda
│  ├─ Image = "rbxassetid://TU_ICONO_AQUI"
│  └─ Position/Size según diseño
└─ MoneyLabel (TextLabel)
   └─ Position ajustada para dejar espacio al icono
```

### Ejemplo 3: Diseño con Degradado
```
NotificationTemplate (Frame)
├─ BackgroundColor3 = Color3.fromRGB(255, 215, 0)
├─ UIGradient
│  ├─ Color = ColorSequence (amarillo → naranja)
│  └─ Rotation = 90
├─ UICorner (CornerRadius = 12)
└─ MoneyLabel (TextLabel)
   ├─ TextColor3 = Color3.fromRGB(0, 0, 0)  -- Negro
   └─ TextStrokeTransparency = 0
```

---

## ⚙️ Configuración Avanzada

Si quieres cambiar el comportamiento, edita estas variables en `MoneyNotificationManager.lua`:

```lua
local CONFIG = {
    MAX_NOTIFICATIONS = 5,           -- Máximo de notificaciones visibles
    NOTIFICATION_LIFETIME = 2.5,     -- Segundos antes de desaparecer
    FADE_IN_TIME = 0.2,              -- Tiempo de aparición
    FADE_OUT_TIME = 0.4,             -- Tiempo de desaparición
    SLIDE_IN_DISTANCE = 50,          -- Distancia de deslizamiento
}
```

---

## 🧪 Cómo Probar

1. **Crea la estructura GUI** en StarterGui (MoneyNotifications → NotificationContainer → NotificationTemplate)
2. **Diseña el NotificationTemplate** como quieras
3. **Añade UIListLayout** al NotificationContainer
4. **Asegúrate** que NotificationTemplate tiene un TextLabel llamado "MoneyLabel"
5. **Juega** y gana dinero (pisando paneles, etc.)
6. **Verás** las notificaciones aparecer automáticamente

### Probar Manualmente
Desde la consola del cliente (F9):
```lua
_G.ShowMoneyNotification(500)  -- Muestra "+$500"
```

---

## ❓ Solución de Problemas

### "No se encontró MoneyNotifications"
→ Verifica que creaste el **ScreenGui** llamado exactamente "MoneyNotifications"

### "No se encontró NotificationContainer"
→ Verifica que el **Frame** se llama exactamente "NotificationContainer"

### "No se encontró NotificationTemplate"
→ Verifica que el **Frame template** se llama exactamente "NotificationTemplate"

### "No se encontró MoneyLabel"
→ Verifica que hay un **TextLabel** dentro del template llamado "MoneyLabel"

### Las notificaciones no se organizan en lista
→ Añade un **UIListLayout** dentro de NotificationContainer

### Las notificaciones aparecen todas en el mismo lugar
→ Verifica la configuración del **UIListLayout**:
- FillDirection = Vertical
- SortOrder = LayoutOrder

---

## 📝 Notas

- El código **NO toca el diseño**, solo cambia el texto del MoneyLabel
- Puedes usar **cualquier color, fuente, tamaño** que quieras
- Puedes añadir **iconos, efectos, animaciones** adicionales al template
- El sistema es **100% automático** una vez diseñada la GUI
- Las notificaciones aparecen cuando el valor de `Money` en leaderstats aumenta

---

## 🎯 Checklist de Instalación

- [ ] Crear ScreenGui "MoneyNotifications" en StarterGui
- [ ] Crear Frame "NotificationContainer" dentro de MoneyNotifications
- [ ] Añadir UIListLayout al NotificationContainer
- [ ] Crear Frame "NotificationTemplate" dentro de MoneyNotifications
- [ ] Configurar NotificationTemplate.Visible = false
- [ ] Crear TextLabel "MoneyLabel" dentro de NotificationTemplate
- [ ] Diseñar el template (colores, tamaños, efectos)
- [ ] Copiar el script MoneyNotificationManager.lua a StarterGui como LocalScript
- [ ] Probar ganando dinero en el juego

---

**¡Diseña el template como quieras y el código se encargará del resto!** 🎨
