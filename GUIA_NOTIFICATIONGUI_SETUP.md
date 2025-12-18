# 🔔 Guía de Instalación - Sistema de Notificaciones

Esta guía te muestra cómo crear la GUI de notificaciones para mostrar mensajes en pantalla cuando compras zonas.

## 📋 Archivos del Sistema

El sistema ya está instalado con estos archivos:

1. **ReplicatedStorage/Modules/NotificationConfig.lua** - Configuración
2. **StarterPlayer/StarterPlayerScripts/NotificationManager.lua** - Script del sistema
3. **StarterPlayer/StarterPlayerScripts/ZoneCollisionGui.lua** - Modificado para usar notificaciones
4. **StarterPlayer/StarterPlayerScripts/ZoneClientManager.lua** - Modificado para usar notificaciones

## ✅ Crear la GUI en StarterGui

### Paso 1: Crear el ScreenGui

1. En **StarterGui**, crea un nuevo **ScreenGui**
2. Nómbralo exactamente: `NotificationGui`
3. Propiedades recomendadas:
   - `DisplayOrder` = 100 (para que esté encima de otras GUIs)
   - `ResetOnSpawn` = false
   - `ZIndexBehavior` = Sibling

### Paso 2: Crear el Template de Notificación

Dentro de `NotificationGui`, crea un **Frame**:

**Propiedades del Frame:**
- **Name:** `NotificationTemplate` (exactamente así)
- **Size:** `{0.3, 0}, {0.08, 0}` (30% de ancho, altura fija)
- **Position:** `{0.5, 0}, {0.1, 0}` (centrado horizontalmente, arriba)
- **AnchorPoint:** `0.5, 0` (anclaje centrado)
- **BackgroundColor3:** Negro `0, 0, 0`
- **BackgroundTransparency:** `0.3` (semitransparente)
- **BorderSizePixel:** `0` (sin borde)
- **Visible:** `false` (el template debe estar oculto)

### Paso 3: Añadir el TextLabel del Mensaje

Dentro de `NotificationTemplate`, crea un **TextLabel**:

**Propiedades del TextLabel:**
- **Name:** `Message` (exactamente así)
- **Size:** `{1, 0}, {1, 0}` (llena todo el Frame)
- **Position:** `{0, 0}, {0, 0}`
- **BackgroundTransparency:** `1` (transparente)
- **Text:** "Mensaje de prueba"
- **TextColor3:** Blanco `255, 255, 255`
- **TextSize:** `18` o el tamaño que prefieras
- **Font:** Enum.Font.GothamBold (o la que prefieras)
- **TextScaled:** `false`
- **TextWrapped:** `true`
- **TextXAlignment:** Center
- **TextYAlignment:** Center

### Paso 4: (Opcional) Añadir Icono

Si quieres mostrar iconos (✅❌⚠️), crea otro **TextLabel**:

**Propiedades del icono:**
- **Name:** `Icon` (exactamente así)
- **Size:** `{0.1, 0}, {1, 0}` (pequeño, altura completa)
- **Position:** `{0, 5}, {0, 0}` (a la izquierda con padding)
- **BackgroundTransparency:** `1`
- **Text:** "✅"
- **TextSize:** `24`
- **TextColor3:** Blanco
- **Font:** Enum.Font.GothamBold
- **TextScaled:** `false`

Si añades icono, ajusta el TextLabel del mensaje:
- **Position:** `{0.15, 0}, {0, 0}` (deja espacio para el icono)
- **Size:** `{0.85, 0}, {1, 0}`

### Paso 5: (Opcional) Mejorar el Diseño

Puedes añadir:

**Frame de borde (dentro de NotificationTemplate):**
- Name: `Border`
- Size: `{1, 0}, {0, 3}` (línea delgada en la parte superior)
- Position: `{0, 0}, {0, 0}`
- BackgroundColor3: Color vibrante (se cambiará según el tipo)

**Sombra o efectos:**
- Usa UIStroke para bordes
- Usa UICorner para esquinas redondeadas
- Usa UIGradient para efectos de gradiente

## 🎨 Ejemplo de Diseño Completo

```
StarterGui
└─ NotificationGui (ScreenGui)
   └─ NotificationTemplate (Frame)
      ├─ Message (TextLabel)
      ├─ Icon (TextLabel) [OPCIONAL]
      ├─ Border (Frame) [OPCIONAL]
      ├─ UICorner [OPCIONAL - para esquinas redondeadas]
      └─ UIStroke [OPCIONAL - para borde]
```

## 🔧 Propiedades Opcionales Recomendadas

### UICorner (dentro de NotificationTemplate)
- **CornerRadius:** `{0, 8}` (esquinas ligeramente redondeadas)

### UIStroke (dentro de NotificationTemplate)
- **Color:** `255, 255, 255`
- **Thickness:** `2`
- **Transparency:** `0.7`
- **ApplyStrokeMode:** Border

### UIGradient (dentro de NotificationTemplate)
- **Color:** Gradient de oscuro a claro
- **Rotation:** `90`
- **Transparency:** `0, 0`

## 📱 Diseño Simple Recomendado para Empezar

Si quieres algo rápido y funcional:

1. **NotificationTemplate (Frame):**
   - Size: `{0.35, 0}, {0.08, 0}`
   - BackgroundColor3: `20, 20, 20`
   - BackgroundTransparency: `0.2`
   - BorderSizePixel: `0`
   - Añade UICorner con CornerRadius `{0, 8}`

2. **Message (TextLabel):**
   - Size: `{0.9, 0}, {1, 0}`
   - Position: `{0.05, 0}, {0, 0}`
   - TextColor3: `255, 255, 255`
   - TextSize: `18`
   - Font: GothamBold
   - TextWrapped: `true`
   - BackgroundTransparency: `1`

## ✅ Probar el Sistema

Una vez diseñada la GUI:

1. **Inicia el juego** en modo Play
2. **Intenta comprar una zona** sin tener suficiente dinero
3. Deberías ver una **notificación roja** en pantalla con el mensaje de error
4. Si compras exitosamente, verás una **notificación verde**

## 🎯 Tipos de Notificaciones

El sistema muestra automáticamente estos tipos:

| Tipo | Color | Icono | Cuándo se Usa |
|------|-------|-------|---------------|
| **Success** | Verde `0, 255, 0` | ✅ | Zona comprada exitosamente |
| **Error** | Rojo `255, 50, 50` | ❌ | Faltan requisitos (dinero, rebirths, nivel) |
| **Warning** | Amarillo `255, 200, 0` | ⚠️ | Advertencias generales |
| **Info** | Azul `100, 200, 255` | ℹ️ | Información general |
| **Money** | Dorado `255, 215, 0` | 💰 | Mensajes relacionados con dinero |

## 🔄 Mensajes que Verás

**Cuando NO tienes suficiente dinero:**
- "💰 Necesitas $500" (o la cantidad que falte)

**Cuando NO tienes suficientes rebirths:**
- "🔄 Necesitas 5 rebirths"

**Cuando NO tienes suficiente nivel:**
- "⭐ Necesitas nivel 10"

**Cuando compras exitosamente:**
- "¡Zona [nombre] desbloqueada!"

**Cuando ya posees la zona:**
- "Ya posees esta zona"

## ⚙️ Personalización

### Cambiar Duración de las Notificaciones

Edita `ReplicatedStorage/Modules/NotificationConfig.lua`:

```lua
NotificationConfig.DefaultDuration = 3  -- Cambia a 5 para 5 segundos
```

### Cambiar Colores

En el mismo archivo, modifica:

```lua
NotificationConfig.Types = {
    Success = {
        Color = Color3.fromRGB(0, 255, 0),  -- Cambia este color
        Icon = "✅"
    },
    Error = {
        Color = Color3.fromRGB(255, 50, 50),  -- Cambia este color
        Icon = "❌"
    },
    -- ...
}
```

### Cambiar Posición

```lua
-- Posición cuando está visible (arriba al centro)
NotificationConfig.VisiblePosition = UDim2.new(0.5, 0, 0.1, 0)

-- Cambia 0.1 a otro valor:
-- 0.05 = más arriba
-- 0.2 = más abajo
-- 0.5 = centro de la pantalla
```

### Cambiar Espaciado entre Múltiples Notificaciones

```lua
NotificationConfig.StackOffset = 80  -- Píxeles entre cada notificación
```

## 🐛 Solución de Problemas

### No aparecen las notificaciones

1. **Verifica que la GUI esté bien nombrada:**
   - ScreenGui debe llamarse `NotificationGui`
   - Template debe llamarse `NotificationTemplate`
   - TextLabel debe llamarse `Message`

2. **Verifica que el sistema esté cargado:**
   - Abre el Output en Roblox Studio
   - Busca: `[NotificationManager] ✅ Sistema inicializado correctamente`

3. **Verifica que NotificationTemplate esté oculto:**
   - `Visible` debe ser `false`

### Las notificaciones no se ven bien

- Ajusta el `Size` del NotificationTemplate
- Asegúrate de que `TextWrapped` esté en `true`
- Verifica que `BackgroundTransparency` no esté en `1` (completamente transparente)

### Los iconos no aparecen

- El icono es opcional, el sistema funciona sin él
- Si quieres iconos, crea un TextLabel llamado `Icon`

## 🎮 Uso en Otros Scripts (Avanzado)

Puedes usar el sistema en cualquier otro LocalScript:

```lua
-- Esperar a que el sistema esté listo
local NotificationManager = _G.NotificationManager
while not NotificationManager do
    task.wait(0.1)
    NotificationManager = _G.NotificationManager
end

-- Usar el sistema
NotificationManager.Success("¡Logro desbloqueado!")
NotificationManager.Error("No puedes hacer eso")
NotificationManager.Warning("Cuidado con los enemigos")
NotificationManager.Info("Nuevo jugador se unió")
NotificationManager.Money("¡+1000 monedas!")

-- Con duración personalizada (en segundos)
NotificationManager.Success("Mensaje largo", 5)
```

---

## 📝 Notas Finales

- El sistema ya está integrado con las zonas automáticamente
- También funciona cuando presionas el botón en la SurfaceGui de las zonas
- Puedes usar múltiples notificaciones al mismo tiempo (se apilan)
- Las notificaciones desaparecen automáticamente después de 3-4 segundos

¡Ya está todo listo para usar! Solo necesitas diseñar la GUI en StarterGui siguiendo esta guía. 🎉
