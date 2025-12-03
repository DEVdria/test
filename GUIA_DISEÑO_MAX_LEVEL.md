# 🎯 GUÍA DE DISEÑO - Notificación de Nivel Máximo

## 📍 ¿QUÉ ES ESTO?

Es la notificación que aparece cuando el jugador alcanza su nivel máximo y necesita comprar un rebirth para continuar progresando.

---

## 🏗️ ESTRUCTURA REQUERIDA

### Ubicación:
Debes crear esto en **StarterGui**

### Estructura:
```
StarterGui
  └─ MaxLevelNotificationGui (ScreenGui) ← CREAR
      └─ NotificationFrame (Frame) ← CREAR Y DISEÑAR
          ├─ LevelLabel (TextLabel) ← OPCIONAL
          ├─ MessageLabel (TextLabel) ← OPCIONAL
          ├─ RebirthsLabel (TextLabel) ← OPCIONAL
          ├─ SuggestionLabel (TextLabel) ← OPCIONAL
          ├─ NextMaxLevelLabel (TextLabel) ← OPCIONAL
          └─ [Otros elementos decorativos] ← TU DISEÑO
```

---

## 📦 PASO A PASO

### PASO 1: Crear MaxLevelNotificationGui

1. Ve a **StarterGui**
2. Insert Object → **ScreenGui**
3. Renombrar a: **MaxLevelNotificationGui** (nombre exacto)
4. Configurar propiedades:
   ```
   Name: MaxLevelNotificationGui
   ResetOnSpawn: false
   ZIndexBehavior: Sibling
   ```

### PASO 2: Crear NotificationFrame

1. Clic derecho en **MaxLevelNotificationGui**
2. Insert Object → **Frame**
3. Renombrar a: **NotificationFrame** (nombre exacto)
4. Configurar propiedades:
   ```
   Name: NotificationFrame
   Size: {0, 400},{0, 200}
   Position: {0.5, -200},{0.5, -100}
   AnchorPoint: {0, 0}
   BackgroundColor3: Naranja/Dorado (255, 165, 0)
   BackgroundTransparency: 0.1
   BorderSizePixel: 0
   Visible: false  ← MUY IMPORTANTE
   ```

---

## 🎨 ELEMENTOS OPCIONALES

El script busca estos elementos **por nombre**. Crea los que quieras:

### **LevelLabel** o **CurrentLevel** - Nivel alcanzado
```
Nombre: LevelLabel (o CurrentLevel)
Tipo: TextLabel
Text: (se actualiza automáticamente)
Ejemplo: "Nivel 20"
```

### **MessageLabel** o **MainMessage** - Mensaje principal
```
Nombre: MessageLabel (o MainMessage)
Tipo: TextLabel
Text: (se actualiza automáticamente)
Ejemplo: "¡Nivel Máximo Alcanzado!"
```

### **RebirthsLabel** - Rebirths actuales
```
Nombre: RebirthsLabel
Tipo: TextLabel
Text: (se actualiza automáticamente)
Ejemplo: "Rebirths: 2"
```

### **SuggestionLabel** o **HintLabel** - Sugerencia
```
Nombre: SuggestionLabel (o HintLabel)
Tipo: TextLabel
Text: (se actualiza automáticamente)
Ejemplo: "¡Compra un Rebirth para aumentar tu nivel máximo!"
```

### **NextMaxLevelLabel** - Siguiente nivel máximo
```
Nombre: NextMaxLevelLabel
Tipo: TextLabel
Text: (se actualiza automáticamente)
Ejemplo: "Siguiente nivel máximo: 30"
```

---

## 📐 DISEÑO EJEMPLO 1: MINIMALISTA

```
NotificationFrame
  Size: {0, 350},{0, 150}
  BackgroundColor3: (255, 165, 0)

  ├─ UICorner (CornerRadius: {0, 15})
  │
  ├─ MessageLabel (TextLabel)
  │   Size: {1, -20},{0, 40}
  │   Position: {0, 10},{0, 15}
  │   Text: "¡Nivel Máximo Alcanzado!"
  │   TextSize: 24
  │   Font: GothamBold
  │   TextColor3: Blanco
  │
  ├─ LevelLabel (TextLabel)
  │   Size: {1, -20},{0, 30}
  │   Position: {0, 10},{0, 60}
  │   Text: "Nivel 20"
  │   TextSize: 20
  │   Font: Gotham
  │   TextColor3: Blanco
  │
  └─ SuggestionLabel (TextLabel)
      Size: {1, -20},{0, 40}
      Position: {0, 10},{0, 95}
      Text: "¡Compra un Rebirth!"
      TextSize: 16
      Font: GothamBold
      TextColor3: (255, 255, 100)
      TextWrapped: true
```

---

## 📐 DISEÑO EJEMPLO 2: COMPLETO

```
NotificationFrame
  Size: {0, 450},{0, 250}
  BackgroundColor3: (255, 100, 0)

  ├─ UICorner (CornerRadius: {0, 20})
  │
  ├─ UIStroke
  │   Color: (255, 215, 0)
  │   Thickness: 4
  │
  ├─ TitleIcon (ImageLabel) ← DECORATIVO
  │   Size: {0, 60},{0, 60}
  │   Position: {0.5, -30},{0, 10}
  │   Image: rbxassetid://TU_ICONO
  │
  ├─ MessageLabel (TextLabel)
  │   Size: {1, -40},{0, 50}
  │   Position: {0, 20},{0, 80}
  │   Text: "⚠️ NIVEL MÁXIMO ALCANZADO ⚠️"
  │   TextSize: 22
  │   Font: GothamBold
  │   TextColor3: Blanco
  │   TextStrokeTransparency: 0.5
  │
  ├─ LevelLabel (TextLabel)
  │   Size: {1, -40},{0, 30}
  │   Position: {0, 20},{0, 135}
  │   Text: "Nivel 20"
  │   TextSize: 18
  │   Font: Gotham
  │   TextColor3: Blanco
  │
  ├─ RebirthsLabel (TextLabel)
  │   Size: {1, -40},{0, 25}
  │   Position: {0, 20},{0, 168}
  │   Text: "Rebirths: 0"
  │   TextSize: 16
  │   Font: Gotham
  │   TextColor3: (200, 200, 200)
  │
  └─ SuggestionLabel (TextLabel)
      Size: {1, -40},{0, 45}
      Position: {0, 20},{0, 198}
      Text: "¡Compra un Rebirth para aumentar tu nivel máximo!"
      TextSize: 15
      Font: GothamBold
      TextColor3: (255, 255, 150)
      TextWrapped: true
```

---

## 🎨 PERSONALIZACIÓN

### Colores recomendados:

**Fondo:**
- Naranja/Dorado: `(255, 165, 0)`
- Rojo: `(255, 100, 100)`
- Púrpura: `(150, 0, 255)`
- Azul oscuro: `(50, 50, 150)`

**Borde (UIStroke):**
- Dorado brillante: `(255, 215, 0)`
- Blanco: `(255, 255, 255)`
- Amarillo: `(255, 255, 0)`

### Efectos adicionales:

**UICorner - Bordes redondeados:**
```lua
UICorner
  CornerRadius: {0, 15}  -- Más alto = más redondeado
  Parent: NotificationFrame
```

**UIStroke - Borde brillante:**
```lua
UIStroke
  Color: (255, 215, 0)
  Thickness: 3
  Transparency: 0
  Parent: NotificationFrame
```

**UIGradient - Degradado:**
```lua
UIGradient
  Color: ColorSequence (de claro a oscuro)
  Rotation: 90  -- Vertical
  Parent: NotificationFrame
```

**UIScale - Efecto de escala:**
```lua
UIScale
  Scale: 1
  Parent: NotificationFrame
-- El script ya anima la escala automáticamente
```

### Añadir íconos:

```lua
ImageLabel
  Name: WarningIcon
  Size: {0, 50},{0, 50}
  Position: {0.5, -25},{0, 10}
  Image: "rbxassetid://ICON_ID"
  BackgroundTransparency: 1
  Parent: NotificationFrame
```

**Íconos sugeridos:**
- Advertencia: rbxassetid://6031071053
- Nivel: rbxassetid://6031068421
- Corona: rbxassetid://6031097367

---

## ⚙️ CONFIGURACIÓN DEL SCRIPT

El script ya está en: `StarterGui_MaxLevelNotification.lua`

### Cambiar duración:

```lua
-- Línea 22
local NOTIFICATION_DURATION = 5  -- Segundos (cambiar aquí)
```

### Cambiar velocidad de animación:

```lua
-- Línea 23
local ANIMATION_DURATION = 0.5  -- Segundos (cambiar aquí)
```

---

## 🎯 POSICIONAMIENTO

### Centro de la pantalla (default):
```lua
Position: {0.5, -200},{0.5, -100}
Size: {0, 400},{0, 200}
```

### Parte superior centro:
```lua
Position: {0.5, -200},{0, 50}
Size: {0, 400},{0, 200}
```

### Parte inferior centro:
```lua
Position: {0.5, -200},{1, -250}
Size: {0, 400},{0, 200}
```

---

## ✅ INSTALACIÓN

### PASO 1: Reemplazar script

1. Abre: `StarterGui > MaxLevelNotification`
2. **Reemplazar TODO el contenido** con: `StarterGui_MaxLevelNotification.lua`

### PASO 2: Crear la interfaz

1. Crear **MaxLevelNotificationGui** (ScreenGui) en StarterGui
2. Crear **NotificationFrame** (Frame) dentro
3. Añadir TextLabels con los nombres que quieras usar
4. Diseñar a tu gusto

### PASO 3: Configurar propiedades

**IMPORTANTE:**
- NotificationFrame debe tener `Visible = false`
- NotificationFrame debe tener una posición y tamaño definidos

---

## ✅ VERIFICACIÓN

### Checklist:

1. ✅ MaxLevelNotificationGui existe en StarterGui
2. ✅ NotificationFrame existe dentro con `Visible = false`
3. ✅ Al menos un TextLabel existe (aunque sea sin nombre específico)
4. ✅ Script MaxLevelNotification actualizado

### Test:

1. **Sube al nivel máximo** (recoge orbs hasta llegar al nivel máximo de tu rebirth)
2. **Debe aparecer la notificación:**
   - Animación de entrada (pop)
   - Se muestra 5 segundos
   - Animación de salida
3. **Verifica Output:**
   ```
   [MaxLevelNotification] ✅ Sistema de notificación de nivel máximo iniciado
   [MaxLevelNotification] 📦 Usando frame: NotificationFrame
   ```

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "No se encontró ScreenGui 'MaxLevelNotificationGui'"
**Solución:** Crea un ScreenGui llamado exactamente "MaxLevelNotificationGui" en StarterGui

### ❌ Error: "No se encontró Frame 'NotificationFrame'"
**Solución:** Crea un Frame llamado exactamente "NotificationFrame" dentro del ScreenGui

### ❌ La notificación no aparece
**Verifica:**
1. Llegaste realmente al nivel máximo
2. NotificationFrame tiene `Visible = false` inicialmente
3. No hay errores en Output

### ❌ La notificación no desaparece
**Solución:** Verifica que NOTIFICATION_DURATION no sea muy alto

### ❌ Los TextLabels no se actualizan
**Verifica:**
1. Los nombres son correctos (LevelLabel, MessageLabel, etc.)
2. Son TextLabels (no Frames u otros)
3. Están dentro de NotificationFrame

---

## 💡 TIPS

### Hacer que dure más tiempo:
```lua
local NOTIFICATION_DURATION = 8  -- 8 segundos en pantalla
```

### Hacer animación más lenta:
```lua
local ANIMATION_DURATION = 1.0  -- 1 segundo de animación
```

### Añadir sonido:
```lua
-- Dentro de showMaxLevelNotification(), después de updateNotificationData():
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://TU_SONIDO_ID"
sound.Volume = 0.5
sound.Parent = game:GetService("SoundService")
sound:Play()
```

---

## 🎯 RESUMEN

**Para crear la notificación:**
1. Crear MaxLevelNotificationGui en StarterGui
2. Crear NotificationFrame dentro (con Visible = false)
3. Añadir TextLabels con nombres específicos (opcional)
4. Diseñar a tu gusto

**El script se encarga de:**
- ✅ Detectar cuándo llegas al nivel máximo
- ✅ Actualizar los datos en los TextLabels
- ✅ Animar entrada y salida
- ✅ Mostrar por 5 segundos
- ✅ Ocultar automáticamente

**TÚ controlas:**
- ✅ Todo el diseño visual
- ✅ Colores, fuentes, tamaños
- ✅ Efectos y decoraciones
- ✅ Qué información mostrar

---

¡Notificación completamente personalizable! 🎯✨
