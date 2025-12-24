# Sistema de Títulos de Rango - Guía de Configuración

## 📋 Descripción

Sistema de títulos que aparecen sobre la cabeza de los jugadores usando BillboardGui. Los títulos cambian automáticamente según el nivel del jugador.

## ✅ Características

- ✅ Títulos sobre la cabeza con BillboardGui
- ✅ Cambian automáticamente al subir de nivel
- ✅ 100% configurables (texto, colores, niveles)
- ✅ Fuente Fredoka One
- ✅ Fondo transparente
- ✅ Contorno personalizable
- ✅ Actualización en tiempo real

## 🎨 Configuración de Rangos

### Ubicación del Archivo

Edita: `ReplicatedStorage_Modules_RankConfig.lua`

### Estructura de un Rango

```lua
{
    minLevel = 1,              -- Nivel mínimo requerido
    maxLevel = 5,              -- Nivel máximo (nil = infinito)
    title = "Corredor Lento",  -- Texto que se muestra
    textColor = Color3.fromRGB(255, 255, 255),      -- Color del texto
    textStrokeColor = Color3.fromRGB(0, 0, 0),      -- Color del contorno
}
```

### Rangos por Defecto

| Nivel | Título | Color |
|-------|--------|-------|
| 1-5 | Corredor Lento | Blanco |
| 5-10 | Corredor Normal | Azul claro |
| 10-20 | Corredor Rápido | Verde |
| 20-30 | Velocista | Amarillo |
| 30-50 | Corredor Pro | Naranja |
| 50-75 | Corredor Elite | Magenta |
| 75-100 | Maestro de la Velocidad | Rojo |
| 100+ | Leyenda del Speed | Dorado |

## ⚙️ Cómo Añadir/Modificar Rangos

### Ejemplo 1: Añadir un nuevo rango

```lua
RankConfig.Ranks = {
    -- ... rangos existentes ...

    -- NUEVO RANGO
    {
        minLevel = 150,
        maxLevel = 200,
        title = "Corredor Supersónico",
        textColor = Color3.fromRGB(0, 255, 255),      -- Cyan
        textStrokeColor = Color3.fromRGB(0, 100, 100), -- Cyan oscuro
    },
}
```

### Ejemplo 2: Modificar un rango existente

```lua
-- ANTES:
{
    minLevel = 1,
    maxLevel = 5,
    title = "Corredor Lento",
    textColor = Color3.fromRGB(255, 255, 255),
    textStrokeColor = Color3.fromRGB(0, 0, 0),
}

-- DESPUÉS (cambiar texto y color):
{
    minLevel = 1,
    maxLevel = 5,
    title = "Principiante",  -- Texto cambiado
    textColor = Color3.fromRGB(200, 200, 200),  -- Gris claro
    textStrokeColor = Color3.fromRGB(50, 50, 50), -- Gris oscuro
}
```

### Ejemplo 3: Rango sin límite superior

```lua
{
    minLevel = 200,
    maxLevel = nil,  -- nil = todos los niveles mayores a 200
    title = "Dios de la Velocidad",
    textColor = Color3.fromRGB(255, 0, 255),
    textStrokeColor = Color3.fromRGB(255, 215, 0),
}
```

## 🎨 Paleta de Colores Recomendada

```lua
-- Blanco
Color3.fromRGB(255, 255, 255)

-- Gris
Color3.fromRGB(150, 150, 150)

-- Negro
Color3.fromRGB(0, 0, 0)

-- Rojo
Color3.fromRGB(255, 50, 50)

-- Naranja
Color3.fromRGB(255, 150, 0)

-- Amarillo
Color3.fromRGB(255, 255, 100)

-- Verde lima
Color3.fromRGB(150, 255, 50)

-- Verde
Color3.fromRGB(100, 255, 100)

-- Cyan
Color3.fromRGB(0, 255, 255)

-- Azul
Color3.fromRGB(100, 150, 255)

-- Púrpura
Color3.fromRGB(200, 100, 255)

-- Magenta
Color3.fromRGB(255, 100, 255)

-- Rosa
Color3.fromRGB(255, 150, 200)

-- Dorado
Color3.fromRGB(255, 215, 0)

-- Arcoíris (cambia entre varios colores)
-- Nota: Para efectos de arcoíris, necesitarías un script adicional
```

## 🔧 Configuración Visual Avanzada

Edita la sección `RankConfig.Visual` en el archivo:

```lua
RankConfig.Visual = {
    -- Fuente del texto (ya configurada: Fredoka One)
    Font = Enum.Font.FredokaOne,

    -- Tamaño del texto
    TextSize = 24,  -- Cambia este número para texto más grande/pequeño

    -- Background transparency (1 = completamente transparente)
    BackgroundTransparency = 1,  -- Ya configurado

    -- Transparencia del contorno del texto
    TextStrokeTransparency = 0.5,  -- 0 = opaco, 1 = invisible

    -- Grosor del contorno del texto
    TextStrokeThickness = 2,  -- Más alto = contorno más grueso

    -- Tamaño del BillboardGui
    Size = UDim2.new(0, 200, 0, 50),  -- Ancho: 200px, Alto: 50px

    -- Distancia sobre la cabeza (studs)
    YOffset = 3,  -- Más alto = más arriba de la cabeza
}
```

## 📐 Ajustes de Posición

Para cambiar qué tan arriba aparece el título:

```lua
-- Más cerca de la cabeza
YOffset = 2,

-- Posición normal
YOffset = 3,

-- Más arriba
YOffset = 4,
```

## 🎯 Ejemplos de Configuración

### Ejemplo: Rangos de Velocidad Temáticos

```lua
RankConfig.Ranks = {
    {
        minLevel = 1,
        maxLevel = 10,
        title = "🐌 Caracol",
        textColor = Color3.fromRGB(200, 200, 200),
        textStrokeColor = Color3.fromRGB(100, 100, 100),
    },
    {
        minLevel = 10,
        maxLevel = 25,
        title = "🐢 Tortuga",
        textColor = Color3.fromRGB(100, 200, 100),
        textStrokeColor = Color3.fromRGB(0, 100, 0),
    },
    {
        minLevel = 25,
        maxLevel = 50,
        title = "🐇 Conejo",
        textColor = Color3.fromRGB(255, 200, 150),
        textStrokeColor = Color3.fromRGB(150, 100, 50),
    },
    {
        minLevel = 50,
        maxLevel = 75,
        title = "🐆 Guepardo",
        textColor = Color3.fromRGB(255, 200, 0),
        textStrokeColor = Color3.fromRGB(150, 100, 0),
    },
    {
        minLevel = 75,
        maxLevel = nil,
        title = "⚡ Relámpago",
        textColor = Color3.fromRGB(255, 255, 100),
        textStrokeColor = Color3.fromRGB(255, 150, 0),
    },
}
```

### Ejemplo: Rangos Estilo Minecraft

```lua
RankConfig.Ranks = {
    {
        minLevel = 1,
        maxLevel = 15,
        title = "[NEWBIE]",
        textColor = Color3.fromRGB(170, 170, 170), -- Gris
        textStrokeColor = Color3.fromRGB(85, 85, 85),
    },
    {
        minLevel = 15,
        maxLevel = 30,
        title = "[MEMBER]",
        textColor = Color3.fromRGB(85, 255, 85), -- Verde
        textStrokeColor = Color3.fromRGB(0, 170, 0),
    },
    {
        minLevel = 30,
        maxLevel = 50,
        title = "[VIP]",
        textColor = Color3.fromRGB(85, 255, 255), -- Aqua
        textStrokeColor = Color3.fromRGB(0, 170, 170),
    },
    {
        minLevel = 50,
        maxLevel = 75,
        title = "[ELITE]",
        textColor = Color3.fromRGB(255, 255, 85), -- Amarillo
        textStrokeColor = Color3.fromRGB(170, 170, 0),
    },
    {
        minLevel = 75,
        maxLevel = nil,
        title = "[LEGEND]",
        textColor = Color3.fromRGB(255, 170, 0), -- Dorado
        textStrokeColor = Color3.fromRGB(170, 85, 0),
    },
}
```

### Ejemplo: Degradado de Colores por Nivel

```lua
RankConfig.Ranks = {
    {minLevel = 1, maxLevel = 20, title = "Nivel Bronce",
     textColor = Color3.fromRGB(205, 127, 50), textStrokeColor = Color3.fromRGB(100, 50, 0)},

    {minLevel = 20, maxLevel = 40, title = "Nivel Plata",
     textColor = Color3.fromRGB(192, 192, 192), textStrokeColor = Color3.fromRGB(100, 100, 100)},

    {minLevel = 40, maxLevel = 60, title = "Nivel Oro",
     textColor = Color3.fromRGB(255, 215, 0), textStrokeColor = Color3.fromRGB(200, 150, 0)},

    {minLevel = 60, maxLevel = 80, title = "Nivel Platino",
     textColor = Color3.fromRGB(229, 228, 226), textStrokeColor = Color3.fromRGB(150, 150, 150)},

    {minLevel = 80, maxLevel = 100, title = "Nivel Diamante",
     textColor = Color3.fromRGB(185, 242, 255), textStrokeColor = Color3.fromRGB(0, 150, 200)},

    {minLevel = 100, maxLevel = nil, title = "Nivel Maestro",
     textColor = Color3.fromRGB(255, 0, 255), textStrokeColor = Color3.fromRGB(150, 0, 150)},
}
```

## 🔧 Fuentes Disponibles

Si quieres cambiar la fuente (aunque especificaste Fredoka One):

```lua
-- Fuentes disponibles en Roblox:
Enum.Font.FredokaOne      -- ← Tu configuración actual
Enum.Font.GothamBold
Enum.Font.Gotham
Enum.Font.SourceSansBold
Enum.Font.Cartoon
Enum.Font.Arcade
Enum.Font.SciFi
```

## ❓ Solución de Problemas

### El título no aparece
- ✅ Verifica que el archivo `RankConfig.lua` esté en `ReplicatedStorage/Modules`
- ✅ Verifica que `RankTitleManager.lua` esté en `ServerScriptService`
- ✅ Revisa el Output para ver errores

### El título tiene el color equivocado
- ✅ Verifica que estés usando `Color3.fromRGB(R, G, B)` con valores entre 0-255
- ✅ Asegúrate de configurar tanto `textColor` como `textStrokeColor`

### El título está muy abajo/arriba
- ✅ Ajusta `YOffset` en `RankConfig.Visual`

### El texto es muy pequeño/grande
- ✅ Ajusta `TextSize` en `RankConfig.Visual`

### Los rangos se solapan
- ✅ Asegúrate de que `maxLevel` de un rango = `minLevel` del siguiente
- ✅ Ejemplo: Si un rango termina en nivel 10, el siguiente debe empezar en nivel 10

## 📝 Notas Importantes

1. **Orden de Rangos**: Los rangos se evalúan de arriba hacia abajo, el primero que coincida se usa.

2. **Niveles Solapados**: Si tienes rangos que se solapan (ej: 1-10 y 5-15), se usará el primero que aparezca en la lista.

3. **Rango por Defecto**: Si un jugador tiene un nivel que no coincide con ningún rango, se usará el primer rango de la lista.

4. **Actualización Automática**: El título se actualiza automáticamente cuando el jugador sube de nivel.

5. **Respawn**: El título se recrea cada vez que el jugador respawnea.

## 📊 Checklist de Instalación

- [x] Archivo `RankConfig.lua` creado en `ReplicatedStorage/Modules`
- [x] Archivo `RankTitleManager.lua` creado en `ServerScriptService`
- [x] Configuración con Fredoka One
- [x] Background transparency = 1
- [ ] Personaliza los rangos según tus preferencias
- [ ] Prueba subiendo de nivel en el juego

---

**¡Personaliza los rangos editando `RankConfig.lua` y disfruta del sistema de títulos!** 🎮
