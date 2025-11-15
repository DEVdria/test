# 🎮 Glass Bridge Minigame - Roblox Studio

Sistema completo de Glass Bridge inspirado en Squid Game para Roblox Studio. Los jugadores deben atravesar un puente de cristal donde cada fila tiene dos paneles: uno seguro y uno que se rompe al pisarlo.

> **🆕 ACTUALIZADO** - Ver [ACTUALIZACION.md](ACTUALIZACION.md) para las nuevas características

## 📋 Características

✅ Generación aleatoria del camino correcto en cada partida
✅ Dos paneles por fila (izquierda y derecha)
✅ **NUEVO:** Decals/Texturas en los paneles para mejor apariencia
✅ **NUEVO:** Explosiones que lanzan a los jugadores por los aires
✅ **NUEVO:** Regeneración automática de paneles falsos (15 segundos)
✅ **NUEVO:** Paneles seguros se mantienen verdes permanentemente
✅ Efectos visuales de rotura con partículas
✅ Sonidos de vidrio rompiéndose y explosiones
✅ Animación de caída de paneles
✅ Sistema modular y configurable
✅ Fácil de personalizar

## 📦 Estructura del Proyecto

```
GlassBridge/
├── ServerScriptService/
│   └── GlassBridgeManager.lua          (Script principal del servidor)
│
└── ReplicatedStorage/
    └── ModuleScripts/
        ├── GlassBridgeConfig.lua       (Configuración del juego)
        ├── GlassPanel.lua              (Lógica de paneles individuales)
        └── GlassBridgeEffects.lua      (Efectos visuales y sonidos)
```

## 🚀 Instalación Paso a Paso

### 1️⃣ Preparar Roblox Studio

1. Abre Roblox Studio
2. Crea un nuevo proyecto o abre uno existente
3. Asegúrate de estar en modo "Edit" (no en modo "Play")

### 2️⃣ Crear la Estructura de Carpetas

1. En el **Explorer**, localiza **ReplicatedStorage**
2. Click derecho en ReplicatedStorage → Insert Object → Folder
3. Nómbrala **"ModuleScripts"**

### 3️⃣ Agregar los Scripts Modulares

En **ReplicatedStorage > ModuleScripts**, crea los siguientes ModuleScripts:

#### A) GlassBridgeConfig
1. Click derecho en ModuleScripts → Insert Object → ModuleScript
2. Nómbralo **"GlassBridgeConfig"**
3. Copia el contenido de `ModuleScripts/GlassBridgeConfig.lua`
4. Pégalo en el script

#### B) GlassBridgeEffects
1. Click derecho en ModuleScripts → Insert Object → ModuleScript
2. Nómbralo **"GlassBridgeEffects"**
3. Copia el contenido de `ModuleScripts/GlassBridgeEffects.lua`
4. Pégalo en el script

#### C) GlassPanel
1. Click derecho en ModuleScripts → Insert Object → ModuleScript
2. Nómbralo **"GlassPanel"**
3. Copia el contenido de `ModuleScripts/GlassPanel.lua`
4. Pégalo en el script

### 4️⃣ Agregar el Script Principal

1. En el **Explorer**, localiza **ServerScriptService**
2. Click derecho en ServerScriptService → Insert Object → Script
3. Nómbralo **"GlassBridgeManager"**
4. Copia el contenido de `ServerScriptService/GlassBridgeManager.lua`
5. Pégalo en el script

### 5️⃣ Ejecutar el Juego

1. Click en el botón **"Play"** (F5) en Roblox Studio
2. El puente se generará automáticamente en el Workspace
3. Verás en la consola: "=== Glass Bridge Generado Exitosamente ==="

## 🎯 Uso del Sistema

### Probar el Juego

1. Presiona **Play** en Roblox Studio
2. Tu personaje aparecerá en el spawn point
3. Camina hacia la plataforma de inicio (verde)
4. Atraviesa el puente eligiendo paneles (izquierda o derecha)
5. Si pisas un panel falso, se romperá y caerás
6. Si pisas un panel seguro, brillará en verde brevemente
7. Alcanza la plataforma dorada al final para ganar

### Comandos de Consola

Abre la consola de comandos (F9) y ejecuta:

```lua
-- Reiniciar el puente con un nuevo camino aleatorio
_G.GlassBridge.Reset()

-- Revelar el camino correcto (para testing)
_G.GlassBridge.Reveal()
```

## ⚙️ Configuración

Edita `GlassBridgeConfig.lua` para personalizar el juego:

```lua
-- CONFIGURACIÓN DEL PUENTE
NumberOfRows = 18                    -- Número de filas (más filas = más difícil)
PanelSize = Vector3.new(6, 0.5, 6)  -- Tamaño de cada panel
GapBetweenPanels = 1                 -- Espacio horizontal entre paneles
GapBetweenRows = 0.5                 -- Espacio entre filas

-- COLORES Y APARIENCIA
SafePanelColor = Color3.fromRGB(100, 200, 255)  -- Color del panel seguro
FakePanelColor = Color3.fromRGB(255, 100, 100)  -- Color del panel falso
InitialTransparency = 0.3                       -- Transparencia inicial

-- EFECTOS DE ROTURA
BreakDelay = 0.3                     -- Segundos antes de romper el panel
ShatterParticles = true              -- Activar partículas
ShatterSound = true                  -- Activar sonidos

-- GAMEPLAY
FallHeight = 50                      -- Altura de caída
RespawnOnDeath = false               -- true = respawnea, false = elimina
ShowCorrectPath = false              -- true = muestra el camino (debug)
```

## 🎨 Personalización Avanzada

### Cambiar Efectos de Sonido

En `GlassBridgeEffects.lua`, línea 41:
```lua
sound.SoundId = "rbxassetid://3581387885"  -- Cambia este ID
```

Encuentra más sonidos en: https://create.roblox.com/marketplace/audio

### Ajustar Efectos Visuales

En `GlassBridgeEffects.lua`, modifica:
- `CreateShatterEffect()` - Partículas de rotura
- `ShatterPanel()` - Animación de caída
- `CreateSuccessEffect()` - Efecto al pisar panel correcto

### Modificar Comportamiento de Paneles

En `GlassPanel.lua`, función `OnTouch()`:
```lua
-- Personaliza qué pasa cuando se pisa un panel falso
if not self.IsSafe then
    -- Tu código personalizado aquí
end
```

## 📍 Ubicación en el Workspace

El puente se genera automáticamente en:
```
Workspace > GlassBridge/
├── StartPlatform (Plataforma verde de inicio)
├── GlassPanel_Row1_Left
├── GlassPanel_Row1_Right
├── GlassPanel_Row2_Left
├── GlassPanel_Row2_Right
├── ...
└── WinPlatform (Plataforma dorada de victoria)
```

Posición predeterminada: `(0, 5, 0)` en el mundo

Para cambiar la posición, edita en `GlassBridgeConfig.lua`:
```lua
StartPosition = Vector3.new(0, 5, 0)  -- Cambia X, Y, Z
```

## 🐛 Solución de Problemas

### El puente no se genera
- ✅ Verifica que todos los ModuleScripts estén en `ReplicatedStorage > ModuleScripts`
- ✅ Verifica que los nombres sean exactos: `GlassBridgeConfig`, `GlassPanel`, `GlassBridgeEffects`
- ✅ Abre la consola (F9) y busca mensajes de error

### Los paneles no se rompen
- ✅ Asegúrate de que el script está en **ServerScriptService** (no en ReplicatedStorage)
- ✅ Verifica que `CanCollide = true` en los paneles
- ✅ Revisa la consola para errores

### No hay efectos visuales
- ✅ Verifica que `ShatterParticles = true` en la configuración
- ✅ Verifica que `ShatterSound = true` en la configuración

### El jugador no muere al caer
- ✅ Verifica que `FallHeight` sea suficiente (mínimo 50)
- ✅ Asegúrate de que `BreakDelay` no sea 0

## 🎮 Próximos Pasos

Puedes expandir este sistema agregando:

- ⏱️ Sistema de temporizador
- 🏆 Tabla de clasificación
- 👥 Modo multijugador competitivo
- 🎵 Música de fondo
- 💡 Efectos de iluminación
- 📊 Sistema de estadísticas
- 🎯 Diferentes niveles de dificultad
- 🌈 Temas visuales personalizables

## 📝 Notas Importantes

1. **Aleatoriedad**: Cada vez que se inicia el servidor o se ejecuta `Reset()`, se genera un nuevo camino aleatorio
2. **Rendimiento**: Con la configuración predeterminada (18 filas), el sistema es eficiente y no debería causar lag
3. **Compatibilidad**: Compatible con Roblox Studio 2024+
4. **Seguridad**: Todo se ejecuta en el servidor para prevenir exploits

## 📄 Licencia

Este proyecto es de código abierto y puede ser usado libremente en tus juegos de Roblox.

## 🤝 Soporte

Si tienes problemas o preguntas:
1. Revisa la sección de **Solución de Problemas**
2. Verifica que todos los scripts estén en las ubicaciones correctas
3. Abre la consola de desarrollador (F9) para ver errores

---

¡Disfruta creando tu Glass Bridge! 🎮✨
