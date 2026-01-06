# 🎮 Juego de Adivinanza - Roblox (Con Fila Física)

Un juego multijugador por turnos donde los jugadores deben adivinar un número secreto entre 1 y 500. **Los jugadores avanzan físicamente en una fila dentro del mapa**, y el servidor responde con pistas "Más alto" o "Más bajo" hasta que alguien acierta.

## 📋 Características

### ⭐ Nuevas Características
- ✅ **Fila física en el mapa**: Los jugadores se mueven realmente en el Workspace
- ✅ **Animaciones suaves**: Tweens para movimiento fluido
- ✅ **Indicador visual de turno**: Flecha verde sobre el jugador actual
- ✅ **Teclado numérico**: Botones estilo calculadora (0-9)
- ✅ **UI personalizable**: Solo código lógico, diseña tu propia interfaz

### 🎯 Características Base
- ✅ Sistema de turnos automático
- ✅ Número secreto generado por el servidor (anti-trampas)
- ✅ Validación de entrada del lado del servidor
- ✅ Manejo robusto de jugadores que entran/salen
- ✅ Contador de intentos por ronda
- ✅ Reinicio automático cuando alguien gana

## 📁 Estructura del Proyecto

```
src/
├── ServerScriptService/
│   └── GameManager.lua          ← Servidor con sistema de fila física
│
├── ReplicatedStorage/
│   └── RemoteEvents.lua         ← Crea los RemoteEvents
│
└── StarterGui/
    └── GameGui/
        ├── GameUILogic.lua      ← Lógica de UI (sin crear elementos)
        └── NumpadController.lua ← Controlador del teclado numérico
```

## 🗺️ Configuración del Mapa

### PASO 1: Crear la Fila Física

**IMPORTANTE**: Antes de probar el juego, debes crear las posiciones de la fila.

1. En **Workspace**, crea una **Folder** llamada `LinePositions`
2. Dentro, crea **Parts** nombradas: `Part1`, `Part2`, `Part3`, etc.

#### Método Rápido (Recomendado)

Copia y pega esto en la **Command Bar** de Roblox Studio:

```lua
local folder = Instance.new("Folder")
folder.Name = "LinePositions"
folder.Parent = workspace

for i = 1, 10 do
    local part = Instance.new("Part")
    part.Name = "Part" .. i
    part.Size = Vector3.new(5, 1, 5)
    part.Position = Vector3.new(i * 7, 3, 0)
    part.Anchored = true
    part.BrickColor = i == 1 and BrickColor.new("Lime green") or BrickColor.new("Deep blue")
    part.Material = Enum.Material.Neon
    part.Parent = folder
end

print("✓ Fila creada con 10 posiciones")
```

📖 **Para más detalles**: Consulta `ESTRUCTURA_MAPA.md`

## 🔧 Instalación en Roblox Studio

### 1. Configurar RemoteEvents

1. En **ReplicatedStorage**, crea un **Script**
2. Nómbralo `SetupRemoteEvents`
3. Copia el contenido de `src/ReplicatedStorage/RemoteEvents.lua`
4. Pega el código

### 2. Configurar el Servidor

1. En **ServerScriptService**, crea un **Script**
2. Nómbralo `GameManager`
3. Copia el contenido de `src/ServerScriptService/GameManager.lua`
4. Pega el código

### 3. Configurar la UI (OPCIONAL)

**Nota**: Los scripts de UI son solo lógica. Diseña tu propia interfaz.

#### Si quieres usar el teclado numérico:

1. Diseña tu UI con botones del 0-9
2. En **StarterGui**, crea un **ScreenGui**
3. Nómbralo `GuessingGameUI`
4. Crea un **LocalScript** (ModuleScript recomendado)
5. Copia el contenido de `src/StarterGui/GameGui/NumpadController.lua`

#### Para la lógica general de UI:

1. Crea otro **LocalScript**
2. Copia el contenido de `src/StarterGui/GameGui/GameUILogic.lua`

### Estructura Final

```
Workspace/
  └── 📁 LinePositions
      ├── Part1
      ├── Part2
      ├── Part3
      └── ...

ServerScriptService/
  └── 📄 GameManager (Script)

ReplicatedStorage/
  └── 📄 SetupRemoteEvents (Script)

StarterGui/
  └── 📺 GuessingGameUI (ScreenGui) [Tu diseño personalizado]
      ├── 📄 GameUILogic (LocalScript)
      └── 📄 NumpadController (LocalScript/ModuleScript)
```

## 🎯 Cómo Funciona

### Flujo del Juego

1. **Inicio**: El servidor genera un número secreto entre 1 y 500
2. **Posicionamiento**: Los jugadores se colocan automáticamente en la fila física
3. **Turno**: El jugador en **Part1** (primera posición) tiene el turno
4. **Adivinanza**: El jugador ingresa un número (TextBox o Teclado Numérico)
5. **Validación**: El servidor responde:
   - "Más alto ↑" si el número es menor
   - "Más bajo ↓" si el número es mayor
   - "¡CORRECTO! ¡Ganaste! 🎉" si acierta
6. **Avance de fila**: 
   - El jugador que jugó se teletransporta al final
   - Todos avanzan una posición hacia adelante
   - El siguiente jugador ahora está en Part1
7. **Victoria**: Cuando alguien acierta, el juego se reinicia tras 5 segundos

### Sistema de Fila Física

```
Antes del turno:
[Jugador1] [Jugador2] [Jugador3] [Jugador4]
   Part1      Part2      Part3      Part4
   🎯 TURNO

Jugador1 hace su intento → Fila avanza:
[Jugador2] [Jugador3] [Jugador4] [Jugador1]
   Part1      Part2      Part3      Part4
   🎯 TURNO
```

### Comunicación Cliente-Servidor

| RemoteEvent | Dirección | Propósito |
|------------|-----------|-----------|
| `SubmitGuess` | Cliente → Servidor | Enviar intento |
| `GuessResult` | Servidor → Cliente | Respuesta del intento |
| `TurnUpdate` | Servidor → Cliente | Actualizar turno |
| `GameState` | Servidor → Cliente | Mensajes generales |

## 🎨 Diseñar tu Propia UI

Los scripts proporcionados son **solo lógica**. Tú diseñas la UI como quieras.

### GameUILogic.lua - Variables a configurar:

```lua
local SCREEN_GUI_NAME = "GuessingGameUI"
local TURN_LABEL_NAME = "TurnLabel"           
local GAME_STATE_LABEL_NAME = "GameStateLabel"
local ATTEMPTS_LABEL_NAME = "AttemptsLabel"   
local RESULT_LABEL_NAME = "ResultLabel"
```

### NumpadController.lua - Variables a configurar:

```lua
local NUMPAD_FRAME_NAME = "NumpadFrame"
local DISPLAY_LABEL_NAME = "DisplayLabel"

-- Nombres de botones
local BUTTON_NAMES = {
    [0] = "Button0",
    [1] = "Button1",
    -- ... etc
}
```

### Ejemplo de Estructura UI:

```
ScreenGui "GuessingGameUI"
├── Frame "MainFrame"
│   ├── TextLabel "TurnLabel"
│   ├── TextLabel "GameStateLabel"
│   ├── TextLabel "AttemptsLabel"
│   └── TextLabel "ResultLabel"
│
└── Frame "NumpadFrame"
    ├── TextLabel "DisplayLabel"
    ├── TextButton "Button0"
    ├── TextButton "Button1"
    ├── ... (Button2-Button9)
    ├── TextButton "ButtonClear"
    └── TextButton "ButtonSubmit"
```

## ⚙️ Configuración Avanzada

### GameManager.lua (Servidor)

```lua
-- Rango del número secreto
local MIN_NUMBER = 1
local MAX_NUMBER = 500

-- Configuración de animación
local TWEEN_TIME = 0.8              -- Tiempo de movimiento
local TWEEN_STYLE = Enum.EasingStyle.Quad
local TWEEN_DIRECTION = Enum.EasingDirection.InOut
```

### Características Opcionales

El servidor incluye:
- ✅ **Indicador visual**: BillboardGui "▼ TU TURNO ▼" sobre el jugador
- ✅ **Logs detallados**: Seguimiento en Output console
- ✅ **Manejo de errores**: Validación robusta

## 🐛 Solución de Problemas

### "LinePositions not found"
❌ **Problema**: No existe la carpeta en Workspace  
✅ **Solución**: Crea `workspace.LinePositions` con Parts (ver arriba)

### "No hay suficientes posiciones"
❌ **Problema**: Más jugadores que posiciones  
✅ **Solución**: Crea más Parts (10-20 recomendado)

### "Los jugadores no se mueven"
❌ **Problema**: Parts no ancladas o mal nombradas  
✅ **Solución**: 
- Verifica `part.Anchored = true`
- Nombres exactos: `Part1`, `Part2`, etc.
- Sin saltos en numeración

### "El teclado no funciona"
❌ **Problema**: UI no coincide con nombres del script  
✅ **Solución**: Actualiza los nombres en `NumpadController.lua`

## 📊 Arquitectura del Código

### Servidor (GameManager.lua)

**Funciones principales:**

- `initializeLinePositions()`: Carga y ordena las posiciones
- `teleportPlayerToPosition(player, index)`: Mueve con Tween
- `updatePhysicalLine()`: Actualiza posiciones de todos
- `moveLineForward()`: Avanza la fila (primero→último)
- `createTurnIndicator(player)`: Crea flecha visual
- `addPlayerToQueue(player)`: Agrega y posiciona
- `removePlayerFromQueue(player)`: Remueve y reorganiza

### Cliente (NumpadController.lua)

**Funciones principales:**

- `addDigit(digit)`: Añade dígito al display
- `clearAll()`: Borra el número
- `submitNumber()`: Envía al servidor
- `updateNumpadState(yourTurn)`: Habilita/deshabilita
- `connectButtons()`: Conecta eventos de botones

## 🎓 Aprendizaje

Este proyecto enseña:

- 📡 **RemoteEvents**: Comunicación cliente-servidor
- 🎮 **Sistemas de turnos**: Gestión de colas
- 🎨 **TweenService**: Animaciones suaves
- 🗺️ **Manipulación del Workspace**: Posicionamiento dinámico
- 🖼️ **UI dinámica**: Interfaces reactivas
- 🔐 **Seguridad**: Validación servidor-side
- 👥 **Multijugador**: Sincronización de estado

## 🚀 Mejoras Futuras Sugeridas

- ⏱️ Temporizador por turno con barra de progreso
- 🏆 Sistema de puntos basado en intentos
- 📊 Tabla de clasificación persistente
- 🎨 Efectos de partículas en las posiciones
- 🔊 Sonidos de victoria/derrota
- 💬 Emotes o reacciones de jugadores
- 🌈 Temas visuales (día/noche, neón, etc.)
- 🎯 Modos de juego especiales (tiempo límite, rangos variables)

## 📝 Notas Importantes

- El juego inicia automáticamente cuando el primer jugador se une
- Se pausa si todos los jugadores salen
- Los turnos se ajustan automáticamente cuando jugadores entran/salen
- El movimiento de la fila espera a que termine la animación
- El indicador visual solo aparece sobre el jugador del turno

## 📚 Documentación Adicional

- 📖 `ESTRUCTURA_MAPA.md` - Guía detallada del mapa y posiciones
- 📖 `INSTALACION_RAPIDA.md` - Guía rápida de instalación
- 💾 `src/` - Código fuente comentado

## 📄 Licencia

Código libre para usar, modificar y distribuir en proyectos personales y educativos.

---

**¡Disfruta del juego! 🎉**
