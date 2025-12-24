# Notificación de Rebirth Disponible - Guía de Diseño

## 📋 Descripción

Sistema que muestra una notificación automática cuando el jugador tiene suficiente dinero para comprar un rebirth. El código está listo, **TÚ solo diseñas la parte visual**.

## ✅ Funcionamiento

- ✅ Detecta automáticamente cuando Money >= Costo del Rebirth
- ✅ Muestra notificación solo UNA vez por nivel de rebirth (no spam)
- ✅ Botón de comprar funciona igual que el de RebirthGui
- ✅ Botón de cerrar para ocultar la notificación
- ✅ Se oculta automáticamente después de comprar
- ✅ Actualiza cuando cambias de rebirth level

## 🎨 Cómo Diseñar la GUI

### Paso 1: Crear la Estructura Base

En **StarterGui**, crea esta estructura exacta:

```
StarterGui
└─ RebirthAvailableGui (ScreenGui)
   └─ NotificationFrame (Frame) [Visible = false]
      ├─ MessageLabel (TextLabel)
      ├─ PurchaseButton (TextButton)
      └─ CloseButton (TextButton)
```

### Paso 2: Configurar Cada Elemento

#### 📺 **RebirthAvailableGui** (ScreenGui)
- **Tipo:** ScreenGui
- **Propiedades:**
  - `ResetOnSpawn = false`
  - `ZIndexBehavior = Sibling`

#### 📦 **NotificationFrame** (Frame)
Este es el contenedor principal de la notificación. **DISEÑA ESTO COMO QUIERAS**.

**Propiedades base:**
```
Name = "NotificationFrame"
Visible = false  (IMPORTANTE: debe empezar oculto)
Size = UDim2.new(0, 400, 0, 200)  -- Ancho: 400px, Alto: 200px (ajústalo)
Position = UDim2.new(0.5, -200, 0.5, -100)  -- Centro de pantalla
AnchorPoint = Vector2.new(0.5, 0.5)
BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- Gris oscuro (cámbialo)
BackgroundTransparency = 0.1  -- Semi-transparente (cámbialo)
```

**Elementos que PUEDES añadir:**
- ✨ UICorner (esquinas redondeadas)
- ✨ UIStroke (bordes)
- ✨ UIGradient (degradados)
- ✨ ImageLabel (iconos de rebirth)
- ✨ Efectos de sombra

#### 💬 **MessageLabel** (TextLabel)
Este label muestra el mensaje "¡Puedes comprar un Rebirth!". Puedes cambiar el texto.

**Propiedades recomendadas:**
```
Name = "MessageLabel" (IMPORTANTE: debe tener este nombre exacto)
Size = UDim2.new(1, -20, 0, 60)  -- Ocupa el ancho del frame
Position = UDim2.new(0, 10, 0, 20)  -- Margen superior
Text = "¡Puedes comprar un Rebirth!"  -- Cámbialo si quieres
TextColor3 = Color3.fromRGB(255, 255, 255)  -- Blanco
TextSize = 24
Font = Enum.Font.GothamBold
TextWrapped = true
BackgroundTransparency = 1
```

#### 🛒 **PurchaseButton** (TextButton)
**IMPORTANTE:** Este botón ejecuta la compra del rebirth (igual que en RebirthGui).

**Propiedades recomendadas:**
```
Name = "PurchaseButton" (IMPORTANTE: debe tener este nombre exacto)
Size = UDim2.new(0.8, 0, 0, 50)  -- 80% del ancho, 50px alto
Position = UDim2.new(0.1, 0, 0.5, 10)  -- Centrado horizontalmente
Text = "Comprar Rebirth"
TextColor3 = Color3.fromRGB(255, 255, 255)
TextSize = 20
Font = Enum.Font.GothamBold
BackgroundColor3 = Color3.fromRGB(0, 200, 0)  -- Verde
```

**Estados del botón:**
- Normal: `"Comprar Rebirth"`
- Procesando: `"PROCESANDO..."` (automático)
- Éxito: `"¡REBIRTH EXITOSO!"` (automático)
- Error: Muestra mensaje de error (automático)

#### ❌ **CloseButton** (TextButton)
Botón para cerrar/ocultar la notificación.

**Propiedades recomendadas:**
```
Name = "CloseButton" (IMPORTANTE: debe tener este nombre exacto)
Size = UDim2.new(0, 40, 0, 40)  -- Botón cuadrado 40x40
Position = UDim2.new(1, -50, 0, 10)  -- Esquina superior derecha
Text = "X"  -- O "Cerrar"
TextColor3 = Color3.fromRGB(255, 255, 255)
TextSize = 24
Font = Enum.Font.GothamBold
BackgroundColor3 = Color3.fromRGB(200, 0, 0)  -- Rojo
```

---

## 🎨 Ejemplos de Diseño

### Ejemplo 1: Diseño Minimalista Moderno

```
NotificationFrame (Frame)
├─ Size = UDim2.new(0, 450, 0, 180)
├─ Position = UDim2.new(0.5, -225, 0.3, 0)  -- Centro-arriba
├─ BackgroundColor3 = Color3.fromRGB(30, 30, 35)  -- Gris muy oscuro
├─ BackgroundTransparency = 0.05
├─ UICorner (CornerRadius = 12)
├─ UIStroke
│  ├─ Color = Color3.fromRGB(100, 200, 255)  -- Azul claro
│  └─ Thickness = 3
├─ MessageLabel (TextLabel)
│  ├─ Text = "🎉 ¡Rebirth Disponible!"
│  ├─ TextColor3 = Color3.fromRGB(100, 200, 255)
│  ├─ Font = GothamBold
│  └─ TextSize = 26
├─ PurchaseButton (TextButton)
│  ├─ BackgroundColor3 = Color3.fromRGB(0, 170, 255)  -- Azul
│  ├─ UICorner (CornerRadius = 8)
│  └─ UIStroke (Color = blanco, Thickness = 2)
└─ CloseButton (TextButton)
   ├─ BackgroundColor3 = Color3.fromRGB(50, 50, 55)
   ├─ UICorner (CornerRadius = 8)
   └─ Text = "✕"
```

### Ejemplo 2: Diseño Llamativo con Degradado

```
NotificationFrame (Frame)
├─ BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- Dorado
├─ UIGradient
│  ├─ Color = ColorSequence (dorado → naranja)
│  └─ Rotation = 45
├─ UICorner (CornerRadius = 15)
├─ DropShadow (ImageLabel con sombra)
├─ MessageLabel (TextLabel)
│  ├─ Text = "⭐ ¡REBIRTH DISPONIBLE! ⭐"
│  ├─ TextColor3 = Color3.fromRGB(255, 255, 255)
│  ├─ TextStrokeTransparency = 0.5
│  └─ TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
├─ PurchaseButton (TextButton)
│  ├─ BackgroundColor3 = Color3.fromRGB(50, 200, 50)  -- Verde brillante
│  ├─ Text = "💰 COMPRAR REBIRTH 💰"
│  └─ UIGradient (verde → verde oscuro)
└─ CloseButton (TextButton)
   └─ Posición en esquina superior derecha
```

### Ejemplo 3: Diseño Estilo Popup

```
NotificationFrame (Frame)
├─ Size = UDim2.new(0, 500, 0, 250)
├─ Position = UDim2.new(0.5, -250, 0.5, -125)  -- Centro total
├─ BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Blanco
├─ UICorner (CornerRadius = 20)
├─ UIStroke (Color = dorado, Thickness = 4)
├─ TitleBar (Frame)  -- Barra superior
│  ├─ Size = UDim2.new(1, 0, 0, 60)
│  ├─ BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- Dorado
│  └─ TitleLabel "REBIRTH DISPONIBLE"
├─ IconImage (ImageLabel)  -- Icono de rebirth
│  └─ Image = rbxassetid://TU_ICONO_AQUI
├─ MessageLabel (TextLabel)
│  ├─ Text = "Has alcanzado el dinero necesario\npara comprar un Rebirth!"
│  ├─ TextColor3 = Color3.fromRGB(50, 50, 50)  -- Gris oscuro
│  └─ TextWrapped = true
├─ PurchaseButton (TextButton)
│  ├─ Size = UDim2.new(0.7, 0, 0, 55)
│  ├─ BackgroundColor3 = Color3.fromRGB(255, 170, 0)  -- Naranja
│  └─ Text = "COMPRAR AHORA"
└─ CloseButton (TextButton)
   ├─ En esquina de TitleBar
   └─ BackgroundTransparency = 0.8
```

---

## 🎯 Posiciones Recomendadas en Pantalla

### Centro (Más Visible)
```lua
Position = UDim2.new(0.5, -200, 0.5, -100)
AnchorPoint = Vector2.new(0.5, 0.5)
```

### Centro Superior (No Obstruye Gameplay)
```lua
Position = UDim2.new(0.5, -200, 0.2, 0)
AnchorPoint = Vector2.new(0.5, 0)
```

### Esquina Superior Derecha (Discreta)
```lua
Position = UDim2.new(1, -420, 0, 20)
AnchorPoint = Vector2.new(1, 0)
```

### Parte Inferior Centro (Como Notificación)
```lua
Position = UDim2.new(0.5, -200, 0.85, 0)
AnchorPoint = Vector2.new(0.5, 0)
```

---

## 🔧 Efectos Opcionales

### Sombra (Drop Shadow)
Crea un ImageLabel con una imagen de sombra detrás del NotificationFrame.

### Animación de Entrada
Puedes usar TweenService en el código para animar la aparición (opcional).

### Partículas
Añade efectos de partículas alrededor del frame para hacerlo más llamativo.

### Sonido
Añade un SoundEffect que suene cuando aparece la notificación.

---

## ⚙️ Configuración Avanzada

El código detecta automáticamente cuando:
```
Money >= RebirthConfig.GetRebirthCost(CurrentRebirths)
```

### Comportamiento:
1. **Primera vez:** Cuando alcanzas el dinero necesario → Muestra notificación
2. **Cierras notificación:** No vuelve a aparecer (hasta próximo rebirth)
3. **Compras rebirth:** Notificación se oculta automáticamente
4. **Subes un rebirth:** Se resetea el sistema, puede mostrar nueva notificación

---

## 🧪 Cómo Probar

1. **Crea la estructura GUI** en StarterGui (RebirthAvailableGui → NotificationFrame → elementos)
2. **Diseña el NotificationFrame** como quieras
3. **Asegúrate** de tener:
   - MessageLabel (TextLabel)
   - PurchaseButton (TextButton)
   - CloseButton (TextButton)
4. **NotificationFrame.Visible = false** al inicio
5. **Juega** y acumula dinero suficiente para un rebirth
6. **Verás** la notificación aparecer automáticamente

---

## ❓ Solución de Problemas

### "No se encontró RebirthAvailableGui"
→ Verifica que creaste el **ScreenGui** llamado exactamente "RebirthAvailableGui"

### "No se encontró NotificationFrame"
→ Verifica que el **Frame** se llama exactamente "NotificationFrame"

### "No se encontró PurchaseButton"
→ Verifica que hay un **TextButton** llamado exactamente "PurchaseButton"

### La notificación no aparece
→ Verifica que:
- NotificationFrame.Visible = false al inicio
- Tienes suficiente dinero para comprar el rebirth
- El script está en StarterGui como LocalScript

### El botón no funciona
→ Verifica que:
- PurchaseButton es un TextButton (no TextLabel)
- RequestRebirthPurchase existe en ReplicatedStorage/RemoteEvents

### La notificación aparece múltiples veces
→ Esto no debería pasar, el código tiene un flag `hasShownNotification`
Si ocurre, verifica que el script no esté duplicado

---

## 📝 Notas Importantes

1. **La notificación se muestra UNA sola vez** por nivel de rebirth para evitar spam.

2. **Cerrar la notificación** no la hace volver a aparecer (hasta que compres el rebirth).

3. **El botón funciona IGUAL** que el purchaseButton de RebirthGui:
   - Verifica dinero
   - Envía solicitud al servidor
   - Muestra "PROCESANDO..."
   - Muestra resultado (éxito o error)

4. **Auto-oculta** después de comprar exitosamente.

5. **Compatible** con el sistema de rebirth existente.

---

## 📊 Checklist de Instalación

- [ ] Crear ScreenGui "RebirthAvailableGui" en StarterGui
- [ ] Crear Frame "NotificationFrame" (Visible = false)
- [ ] Crear TextLabel "MessageLabel"
- [ ] Crear TextButton "PurchaseButton"
- [ ] Crear TextButton "CloseButton"
- [ ] Diseñar NotificationFrame (colores, efectos, etc.)
- [ ] Configurar posición del NotificationFrame
- [ ] Copiar el script RebirthAvailableNotification.lua a StarterGui como LocalScript
- [ ] Probar acumulando dinero suficiente para un rebirth

---

**¡Diseña la notificación como quieras y el código se encargará de mostrarla en el momento correcto!** 🎉
