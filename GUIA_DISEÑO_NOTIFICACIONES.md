# 🎨 GUÍA DE DISEÑO - Interfaz de Notificaciones de Orbs

## 📍 ¿DÓNDE CREAR LA INTERFAZ?

Debes crear la interfaz en **StarterGui**, siguiendo esta estructura exacta:

```
StarterGui
  └─ OrbNotifications (ScreenGui) ← CREAR ESTO
      └─ Container (Frame) ← CREAR ESTO
          └─ NotificationTemplate (Frame) ← CREAR ESTO Y DISEÑAR A TU GUSTO
              ├─ EXPLabel (TextLabel) ← CREAR ESTE
              ├─ OrbTypeLabel (TextLabel) ← OPCIONAL
              ├─ OrbIcon (Frame o ImageLabel) ← OPCIONAL
              ├─ UICorner ← OPCIONAL (para esquinas redondeadas)
              └─ UIStroke ← OPCIONAL (para borde)
```

---

## 🔨 PASO 1: CREAR LA ESTRUCTURA BASE

### 1.1 Crear ScreenGui
1. Abre Roblox Studio
2. Ve a **StarterGui**
3. Clic derecho → Insert Object → **ScreenGui**
4. Renombrar a: **OrbNotifications** (nombre exacto)
5. Configurar propiedades:
   ```
   Name: OrbNotifications
   ResetOnSpawn: false
   ZIndexBehavior: Sibling
   ```

### 1.2 Crear Container (Frame contenedor)
1. Clic derecho en **OrbNotifications**
2. Insert Object → **Frame**
3. Renombrar a: **Container** (nombre exacto)
4. Configurar propiedades:
   ```
   Name: Container
   Size: {0, 300},{1, 0}
   Position: {1, -320},{0, 20}
   BackgroundTransparency: 1
   ```

   **Explicación de posición:** `{1, -320},{0, 20}` = Esquina superior derecha
   - `{1, -320}` en X = 100% del ancho - 320 píxeles (derecha)
   - `{0, 20}` en Y = 0% + 20 píxeles (arriba)

### 1.3 Crear NotificationTemplate (Template de notificación)
1. Clic derecho en **Container**
2. Insert Object → **Frame**
3. Renombrar a: **NotificationTemplate** (nombre exacto)
4. Configurar propiedades básicas:
   ```
   Name: NotificationTemplate
   Size: {1, 0},{0, 60}
   Position: {0, 0},{0, 0}
   BackgroundColor3: Color blanco (255, 255, 255)
   BackgroundTransparency: 0.3
   BorderSizePixel: 0
   Visible: false ← MUY IMPORTANTE
   ```

**⚠️ IMPORTANTE:** El template debe tener `Visible = false` porque el script lo clonará automáticamente.

---

## 🎨 PASO 2: DISEÑAR EL TEMPLATE DE NOTIFICACIÓN

Ahora personalizas **NotificationTemplate** a tu gusto. Aquí tienes 3 ejemplos de diseño:

### 🎨 DISEÑO 1: MINIMALISTA (Recomendado)

**Estructura:**
```
NotificationTemplate (Frame)
  ├─ EXPLabel (TextLabel) ← Muestra "+X EXP"
  ├─ UICorner (esquinas redondeadas)
  └─ UIStroke (borde)
```

**Paso a paso:**

#### Crear EXPLabel
1. Clic derecho en **NotificationTemplate** → Insert Object → **TextLabel**
2. Renombrar a: **EXPLabel** (nombre exacto)
3. Configurar propiedades:
   ```
   Name: EXPLabel
   Size: {1, -20},{1, 0}
   Position: {0, 10},{0, 0}
   BackgroundTransparency: 1
   Text: "+10 EXP"
   TextColor3: Blanco (255, 255, 255)
   TextSize: 20
   Font: GothamBold
   TextXAlignment: Center
   TextYAlignment: Center
   TextStrokeTransparency: 0.5
   ```

#### Añadir UICorner (opcional, esquinas redondeadas)
1. Clic derecho en **NotificationTemplate** → Insert Object → **UICorner**
2. Configurar:
   ```
   CornerRadius: {0, 8}
   ```

#### Añadir UIStroke (opcional, borde brillante)
1. Clic derecho en **NotificationTemplate** → Insert Object → **UIStroke**
2. Configurar:
   ```
   Color: Blanco (255, 255, 255)
   Thickness: 2
   Transparency: 0
   ```

**✅ LISTO.** Este diseño es simple y funcional.

---

### 🎨 DISEÑO 2: CON ÍCONO DE ORB

**Estructura:**
```
NotificationTemplate (Frame)
  ├─ EXPLabel (TextLabel)
  ├─ OrbIcon (Frame circular)
  │   └─ UICorner (hace el círculo)
  ├─ UICorner
  └─ UIStroke
```

**Pasos adicionales al Diseño 1:**

#### Crear OrbIcon
1. Clic derecho en **NotificationTemplate** → Insert Object → **Frame**
2. Renombrar a: **OrbIcon** (nombre exacto)
3. Configurar propiedades:
   ```
   Name: OrbIcon
   Size: {0, 40},{0, 40}
   Position: {1, -50},{0.5, -20}
   BackgroundColor3: Amarillo (255, 255, 0)
   BorderSizePixel: 0
   ```

4. Clic derecho en **OrbIcon** → Insert Object → **UICorner**
5. Configurar:
   ```
   CornerRadius: {1, 0}  ← Esto hace un círculo perfecto
   ```

**Modificar EXPLabel:**
Cambia su alineación para que no cubra el ícono:
```
TextXAlignment: Left
Position: {0, 10},{0, 0}
Size: {1, -60},{1, 0}
```

**✅ LISTO.** Ahora tienes un ícono circular del color del orb.

---

### 🎨 DISEÑO 3: COMPLETO CON TIPO DE ORB

**Estructura:**
```
NotificationTemplate (Frame)
  ├─ EXPLabel (TextLabel) ← "+10 EXP"
  ├─ OrbTypeLabel (TextLabel) ← "Yellow Orb"
  ├─ OrbIcon (Frame circular)
  │   └─ UICorner
  ├─ UICorner
  └─ UIStroke
```

**Pasos adicionales al Diseño 2:**

#### Crear OrbTypeLabel
1. Clic derecho en **NotificationTemplate** → Insert Object → **TextLabel**
2. Renombrar a: **OrbTypeLabel** (nombre exacto)
3. Configurar propiedades:
   ```
   Name: OrbTypeLabel
   Size: {1, -60},{0, 20}
   Position: {0, 10},{0, 5}
   BackgroundTransparency: 1
   Text: "Yellow Orb"
   TextColor3: Blanco (255, 255, 255)
   TextSize: 14
   Font: Gotham
   TextXAlignment: Left
   TextYAlignment: Top
   TextStrokeTransparency: 0.7
   ```

**Modificar EXPLabel:**
Ahora debe estar más abajo:
```
Position: {0, 10},{0, 25}
Size: {1, -60},{0, 30}
TextYAlignment: Top
```

**Ajustar tamaño del NotificationTemplate:**
```
Size: {1, 0},{0, 70}  ← Más alto para acomodar 2 textos
```

**✅ LISTO.** Ahora muestra tipo de orb y EXP.

---

## 🎨 PERSONALIZACIÓN ADICIONAL

### Cambiar posición de las notificaciones

**Esquina superior derecha (default):**
```lua
Container.Position = UDim2.new(1, -320, 0, 20)
```

**Esquina superior izquierda:**
```lua
Container.Position = UDim2.new(0, 20, 0, 20)
```

**Centro arriba:**
```lua
Container.Position = UDim2.new(0.5, -150, 0, 20)
```

**Parte inferior derecha:**
```lua
Container.Position = UDim2.new(1, -320, 1, -200)
```

### Cambiar tamaño de notificaciones

En **NotificationTemplate**:
```
Size: {1, 0},{0, 80}  ← Más alto (80px)
Size: {1, 0},{0, 50}  ← Más bajo (50px)
Size: {0.8, 0},{0, 60}  ← Más estrecho (80% del ancho)
```

### Añadir efectos visuales

#### Sombra (UIStroke con offset):
1. Crear otro Frame del mismo tamaño detrás
2. BackgroundColor3: Negro
3. BackgroundTransparency: 0.7
4. Position ligeramente offset: `{0, 2},{0, 2}`

#### Gradiente:
1. Clic derecho en **NotificationTemplate** → Insert Object → **UIGradient**
2. Configurar:
   ```
   Color: ColorSequence (de claro a oscuro)
   Rotation: 90
   ```

---

## 📋 NOMBRES QUE EL SCRIPT RECONOCE

El script busca estos elementos por nombre. **Usa estos nombres exactos:**

| Nombre del elemento | Tipo | Qué hace |
|---|---|---|
| **EXPLabel** | TextLabel | Muestra "+X EXP" |
| **ExpAmount** | TextLabel | Alternativo a EXPLabel |
| **OrbTypeLabel** | TextLabel | Muestra "Yellow", "Green", "Blue" |
| **OrbIcon** | Frame o ImageLabel | Cambia de color según el orb |
| **UIStroke** | UIStroke | Cambia de color según el orb |

**⚠️ IMPORTANTE:**
- `EXPLabel` o `ExpAmount` es **OBLIGATORIO**
- Los demás son opcionales
- Si no existen, el script los ignora sin dar error

---

## 🎯 COMPORTAMIENTO DEL SCRIPT

### Lo que hace automáticamente:
1. ✅ Clona el template cuando recoges un orb
2. ✅ Actualiza el texto de EXP: `"+5 EXP"`, `"+7 EXP"`, etc.
3. ✅ Cambia el color de fondo según el orb (amarillo, verde, azul)
4. ✅ Cambia el color del borde (UIStroke) según el orb
5. ✅ Cambia el color del ícono (OrbIcon) según el orb
6. ✅ Anima la entrada (desde la derecha)
7. ✅ Anima la salida (desvanece y mueve a la derecha)
8. ✅ Mantiene máximo 5 notificaciones simultáneas
9. ✅ Pone en cola las notificaciones extra

### Lo que TÚ controlas con tu diseño:
- ✅ Tamaño de las notificaciones
- ✅ Posición en pantalla
- ✅ Estilo visual (bordes, sombras, gradientes)
- ✅ Fuente y tamaño de texto
- ✅ Transparencia inicial
- ✅ Elementos adicionales (íconos, imágenes, etc.)

---

## 🔍 VERIFICACIÓN

### Checklist antes de probar:

1. ✅ Existe **OrbNotifications** (ScreenGui) en StarterGui
2. ✅ Existe **Container** (Frame) dentro de OrbNotifications
3. ✅ Existe **NotificationTemplate** (Frame) dentro de Container
4. ✅ NotificationTemplate tiene **Visible = false**
5. ✅ Existe **EXPLabel** (TextLabel) dentro de NotificationTemplate
6. ✅ El script **OrbNotificationManager** está en StarterGui

### Cómo probar:
1. Inicia el juego
2. Revisa el Output, debe decir:
   ```
   [OrbNotificationManager] ✅ Sistema de notificaciones iniciado
   [OrbNotificationManager] 📦 Usando template: NotificationTemplate
   ```
3. Recoge un orb
4. Debe aparecer la notificación desde la derecha

### Si no funciona:
1. **Error: "No se encontró ScreenGui 'OrbNotifications'"**
   - Verifica que existe en StarterGui
   - Verifica que el nombre sea exacto (sin espacios extras)

2. **Error: "No se encontró Frame 'Container'"**
   - Verifica que Container está dentro de OrbNotifications
   - Verifica el nombre

3. **Error: "No se encontró 'NotificationTemplate'"**
   - Verifica que NotificationTemplate está dentro de Container
   - Verifica el nombre

4. **Las notificaciones aparecen pero no muestran texto:**
   - Verifica que EXPLabel existe
   - Verifica que TextColor3 no sea negro sobre fondo negro
   - Verifica que TextTransparency no sea 1

---

## 📦 EJEMPLO COMPLETO DE PROPIEDADES

### NotificationTemplate (Frame):
```
Name: NotificationTemplate
Size: {1, 0},{0, 60}
Position: {0, 0},{0, 0}
BackgroundColor3: (255, 255, 255)
BackgroundTransparency: 0.3
BorderSizePixel: 0
Visible: false
```

### EXPLabel (TextLabel):
```
Name: EXPLabel
Size: {1, -20},{1, 0}
Position: {0, 10},{0, 0}
BackgroundTransparency: 1
Text: "+10 EXP"
TextColor3: (255, 255, 255)
TextSize: 20
Font: GothamBold
TextXAlignment: Center
TextYAlignment: Center
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0)
```

### UICorner:
```
CornerRadius: {0, 8}
```

### UIStroke:
```
Color: (255, 255, 255)
Thickness: 2
Transparency: 0
ApplyStrokeMode: Border
```

---

## 🎨 PLANTILLAS DE COLOR

El script cambia automáticamente el color según el tipo de orb:

| Orb | Color RGB |
|---|---|
| Yellow | `(255, 255, 0)` |
| Green | `(0, 255, 0)` |
| Blue | `(0, 150, 255)` |

Estos colores se aplican a:
- BackgroundColor3 del NotificationTemplate
- Color del UIStroke
- BackgroundColor3 del OrbIcon

---

## 💡 CONSEJOS DE DISEÑO

1. **Usa BackgroundTransparency entre 0.2 y 0.5** para que el fondo se vea semi-transparente
2. **Usa TextStrokeTransparency = 0.5** para que el texto se vea mejor sobre cualquier fondo
3. **Usa UICorner con CornerRadius {0, 8}** para esquinas redondeadas modernas
4. **Usa UIStroke con Thickness 2** para un borde sutil
5. **Mantén el texto grande** (TextSize 18-24) para que se vea desde lejos
6. **No pongas muchos elementos** - mantén el diseño simple y claro

---

## 🚀 ¡LISTO PARA CREAR!

Ahora puedes diseñar la interfaz de notificaciones como tú quieras. El script se encarga de:
- Clonar el template
- Actualizar los datos
- Animar la entrada y salida
- Gestionar la cola de notificaciones

**TÚ solo diseñas el template, el script hace el resto.** 🎉
