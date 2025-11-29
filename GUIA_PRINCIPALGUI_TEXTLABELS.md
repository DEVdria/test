# 🎨 GUÍA - Añadir TextLabels al PrincipalGui

## 📍 ¿DÓNDE PEGAR LOS TEXTLABELS?

Los TextLabels deben estar en:

```
StarterGui
  └─ PrincipalGui (ScreenGui)
      └─ Frame
          ├─ LevelDisplay (TextLabel) ← CREAR AQUÍ
          ├─ ExpDisplay (TextLabel) ← CREAR AQUÍ
          ├─ SpeedDisplay (TextLabel) ← CREAR AQUÍ
          ├─ PlayerStatsDisplay (LocalScript) ← PEGAR SCRIPT AQUÍ
          └─ [tus otros elementos...]
```

---

## 🔨 PASO A PASO

### PASO 1: Navegar al Frame de PrincipalGui

1. Abre Roblox Studio
2. Ve a **StarterGui**
3. Busca **PrincipalGui** (ScreenGui)
4. Dentro de PrincipalGui, busca **Frame**
5. Haz clic en **Frame** para seleccionarlo

### PASO 2: Crear LevelDisplay (TextLabel)

1. Clic derecho en **Frame**
2. Insert Object → **TextLabel**
3. Renombrar a: **LevelDisplay** (nombre exacto)
4. Configurar propiedades:

```
Name: LevelDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 20}  ← Ajusta según tu diseño
BackgroundTransparency: 1
Text: "Nivel: 0"
TextColor3: (255, 255, 255) - Blanco
TextSize: 20
Font: GothamBold
TextXAlignment: Left
TextYAlignment: Center
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0) - Negro
```

### PASO 3: Crear ExpDisplay (TextLabel)

1. Clic derecho en **Frame**
2. Insert Object → **TextLabel**
3. Renombrar a: **ExpDisplay** (nombre exacto)
4. Configurar propiedades:

```
Name: ExpDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 55}  ← Justo debajo de LevelDisplay
BackgroundTransparency: 1
Text: "EXP: 0 / 50"
TextColor3: (100, 200, 255) - Azul claro
TextSize: 18
Font: Gotham
TextXAlignment: Left
TextYAlignment: Center
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0) - Negro
```

### PASO 4: Crear SpeedDisplay (TextLabel)

1. Clic derecho en **Frame**
2. Insert Object → **TextLabel**
3. Renombrar a: **SpeedDisplay** (nombre exacto)
4. Configurar propiedades:

```
Name: SpeedDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 90}  ← Justo debajo de ExpDisplay
BackgroundTransparency: 1
Text: "Velocidad: 24"
TextColor3: (255, 255, 100) - Amarillo claro
TextSize: 18
Font: Gotham
TextXAlignment: Left
TextYAlignment: Center
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0) - Negro
```

### PASO 5: Pegar el script PlayerStatsDisplay

1. Clic derecho en **Frame** (el mismo Frame donde creaste los TextLabels)
2. Insert Object → **LocalScript**
3. Renombrar a: **PlayerStatsDisplay** (nombre exacto)
4. **Abrir el archivo:** `StarterGui_PrincipalGui_Frame_PlayerStatsDisplay.lua`
5. **Copiar TODO el contenido** del archivo
6. **Pegar** dentro del LocalScript en Roblox Studio

---

## 📐 PERSONALIZACIÓN DE POSICIONES

### Ejemplo 1: Esquina superior izquierda (vertical)

```
LevelDisplay:
  Position: {0, 20},{0, 20}

ExpDisplay:
  Position: {0, 20},{0, 55}

SpeedDisplay:
  Position: {0, 20},{0, 90}
```

### Ejemplo 2: Esquina superior derecha (vertical)

```
LevelDisplay:
  Position: {1, -220},{0, 20}
  TextXAlignment: Right

ExpDisplay:
  Position: {1, -220},{0, 55}
  TextXAlignment: Right

SpeedDisplay:
  Position: {1, -220},{0, 90}
  TextXAlignment: Right
```

### Ejemplo 3: Parte inferior izquierda (horizontal)

```
LevelDisplay:
  Position: {0, 20},{1, -100}
  Size: {0, 150},{0, 30}

ExpDisplay:
  Position: {0, 180},{1, -100}
  Size: {0, 150},{0, 30}

SpeedDisplay:
  Position: {0, 340},{1, -100}
  Size: {0, 150},{0, 30}
```

### Ejemplo 4: Centro superior (horizontal)

```
LevelDisplay:
  Position: {0.5, -225},{0, 20}
  Size: {0, 150},{0, 30}

ExpDisplay:
  Position: {0.5, -75},{0, 20}
  Size: {0, 150},{0, 30}

SpeedDisplay:
  Position: {0.5, 75},{0, 20}
  Size: {0, 150},{0, 30}
```

---

## 🎨 PERSONALIZACIÓN DE ESTILO

### Opción 1: Con fondo semi-transparente

```
BackgroundTransparency: 0.5
BackgroundColor3: (0, 0, 0) - Negro
BorderSizePixel: 0

Añadir UICorner:
  Clic derecho en TextLabel → Insert Object → UICorner
  CornerRadius: {0, 8}
```

### Opción 2: Con borde brillante

```
BackgroundTransparency: 1

Añadir UIStroke:
  Clic derecho en TextLabel → Insert Object → UIStroke
  Color: (255, 255, 255) - Blanco
  Thickness: 2
  Transparency: 0.5
```

### Opción 3: Con sombra de texto

```
TextStrokeTransparency: 0.3
TextStrokeColor3: (0, 0, 0) - Negro
```

### Opción 4: Con gradiente

```
Añadir UIGradient:
  Clic derecho en TextLabel → Insert Object → UIGradient
  Color: ColorSequence (de blanco a gris)
  Rotation: 90
```

---

## 🔤 PERSONALIZACIÓN DE TEXTO

### Fuentes disponibles:
- **Gotham** - Moderno, limpio
- **GothamBold** - Moderno, negrita
- **GothamBlack** - Moderno, extra negrita
- **SourceSans** - Simple, por defecto
- **SourceSansBold** - Simple, negrita
- **Arcade** - Estilo retro
- **Fantasy** - Estilo medieval

### Tamaños recomendados:
- **Título grande:** 24-28
- **Texto normal:** 18-20
- **Texto pequeño:** 14-16

---

## 🎨 EJEMPLOS DE COLORES

### Nivel (Level):
- Blanco: `(255, 255, 255)` ✅ Recomendado
- Verde: `(100, 255, 100)` - Indica progreso
- Dorado: `(255, 215, 0)` - Indica prestigio

### Experiencia (EXP):
- Azul claro: `(100, 200, 255)` ✅ Recomendado
- Púrpura: `(200, 100, 255)` - Mágico
- Cyan: `(0, 255, 255)` - Brillante

### Velocidad (Speed):
- Amarillo claro: `(255, 255, 100)` ✅ Recomendado
- Naranja: `(255, 165, 0)` - Indica velocidad
- Rojo: `(255, 100, 100)` - Indica potencia

---

## ✅ VERIFICACIÓN

### Checklist después de crear los TextLabels:

1. ✅ Existe **LevelDisplay** (TextLabel) en Frame
2. ✅ Existe **ExpDisplay** (TextLabel) en Frame
3. ✅ Existe **SpeedDisplay** (TextLabel) en Frame
4. ✅ Los 3 tienen nombres EXACTOS (mayúsculas/minúsculas importan)
5. ✅ Existe **PlayerStatsDisplay** (LocalScript) en Frame
6. ✅ El script está pegado correctamente (sin errores de sintaxis)

### Cómo probar:

1. Inicia el juego
2. Los TextLabels deben mostrar:
   - "Nivel: 0" (o tu nivel actual)
   - "EXP: 0 / 50" (o tu EXP actual)
   - "Velocidad: 24" (o tu velocidad actual)

3. Recoge un orb
4. ExpDisplay debe actualizarse inmediatamente

5. Cuando tengas suficiente EXP, debes subir de nivel
6. LevelDisplay debe cambiar a "Nivel: 1"
7. SpeedDisplay debe cambiar a "Velocidad: 26"
8. ExpDisplay debe resetear: "EXP: 0 / 100"

### Si no funciona:

**Los TextLabels no se actualizan:**
- Verifica que los nombres sean exactos
- Verifica que PlayerStatsDisplay esté en el mismo Frame
- Revisa el Output por errores

**El texto no se ve:**
- Cambia TextColor3 a blanco
- Verifica BackgroundTransparency (debe ser 1 o cercano)
- Verifica que el TextSize no sea muy pequeño

**El script da error:**
- Verifica que LevelManager existe en ReplicatedStorage/Modules
- Verifica que leaderstats tiene Level y CurrentEXP
- Revisa el Output para ver el error específico

---

## 📦 EJEMPLO COMPLETO DE PROPIEDADES

### LevelDisplay (TextLabel):

```
Name: LevelDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 20}
AnchorPoint: {0, 0}
BackgroundTransparency: 1
BackgroundColor3: (0, 0, 0)
BorderSizePixel: 0
Text: "Nivel: 0"
TextColor3: (255, 255, 255)
TextSize: 20
Font: GothamBold
TextXAlignment: Left
TextYAlignment: Center
TextWrapped: false
TextScaled: false
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0)
```

### ExpDisplay (TextLabel):

```
Name: ExpDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 55}
AnchorPoint: {0, 0}
BackgroundTransparency: 1
BackgroundColor3: (0, 0, 0)
BorderSizePixel: 0
Text: "EXP: 0 / 50"
TextColor3: (100, 200, 255)
TextSize: 18
Font: Gotham
TextXAlignment: Left
TextYAlignment: Center
TextWrapped: false
TextScaled: false
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0)
```

### SpeedDisplay (TextLabel):

```
Name: SpeedDisplay
Size: {0, 200},{0, 30}
Position: {0, 20},{0, 90}
AnchorPoint: {0, 0}
BackgroundTransparency: 1
BackgroundColor3: (0, 0, 0)
BorderSizePixel: 0
Text: "Velocidad: 24"
TextColor3: (255, 255, 100)
TextSize: 18
Font: Gotham
TextXAlignment: Left
TextYAlignment: Center
TextWrapped: false
TextScaled: false
TextStrokeTransparency: 0.5
TextStrokeColor3: (0, 0, 0)
```

---

## 🎯 RESULTADO FINAL

Después de crear todo, deberías tener en **StarterGui > PrincipalGui > Frame:**

```
Frame
  ├─ LevelDisplay (TextLabel)
  ├─ ExpDisplay (TextLabel)
  ├─ SpeedDisplay (TextLabel)
  ├─ PlayerStatsDisplay (LocalScript)
  └─ [tus otros elementos...]
```

Y cuando inicies el juego, verás en tu GUI:

```
Nivel: 0
EXP: 0 / 50
Velocidad: 24
```

Estos valores se actualizarán automáticamente en tiempo real cuando:
- Recojas orbs (EXP aumenta)
- Subas de nivel (Nivel aumenta, Velocidad aumenta, EXP resetea)
- Compres rebirth (Nivel resetea a 0)

---

## 💡 CONSEJOS FINALES

1. **Ajusta las posiciones** según el diseño de tu GUI existente
2. **Usa colores consistentes** con tu tema visual
3. **Añade UICorner** para esquinas redondeadas modernas
4. **Usa TextStrokeTransparency** para que el texto se vea mejor
5. **Mantén los nombres exactos** - el script los busca por nombre

---

**¿Listo para implementar?** Solo crea los 3 TextLabels, pega el script, ¡y funcionará automáticamente! 🎉
