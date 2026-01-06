# 🎮 Juego de Adivinanza - Roblox

Un juego multijugador por turnos donde los jugadores deben adivinar un número secreto entre 1 y 500. El servidor responde con pistas "Más alto" o "Más bajo" hasta que alguien acierta.

## 📋 Características

- ✅ Sistema de turnos automático
- ✅ Número secreto generado por el servidor (anti-trampas)
- ✅ Validación de entrada del lado del servidor
- ✅ Interfaz de usuario intuitiva y moderna
- ✅ Manejo robusto de jugadores que entran/salen
- ✅ Contador de intentos por ronda
- ✅ Reinicio automático cuando alguien gana
- ✅ Mensajes de retroalimentación visual

## 📁 Estructura del Proyecto

```
src/
├── ServerScriptService/
│   └── GameManager.lua          ← Script principal del servidor (Script)
│
├── ReplicatedStorage/
│   └── RemoteEvents.lua         ← Crea los RemoteEvents (Script)
│
└── StarterGui/
    └── GameGui/
        └── GameUI.lua           ← Interfaz del cliente (LocalScript)
```

## 🔧 Instalación en Roblox Studio

Sigue estos pasos para instalar el juego en tu proyecto de Roblox:

### 1. Configurar RemoteEvents

1. En **ReplicatedStorage**, crea un **Script** (NO LocalScript)
2. Nómbralo `SetupRemoteEvents` o similar
3. Copia el contenido de `src/ReplicatedStorage/RemoteEvents.lua`
4. Pega el código en el script

### 2. Configurar el Servidor

1. En **ServerScriptService**, crea un **Script**
2. Nómbralo `GameManager`
3. Copia el contenido de `src/ServerScriptService/GameManager.lua`
4. Pega el código en el script

### 3. Configurar la Interfaz

1. En **StarterGui**, crea un **ScreenGui**
2. Nómbralo `GuessingGameUI`
3. Dentro del ScreenGui, crea un **LocalScript**
4. Nómbralo `GameUI`
5. Copia el contenido de `src/StarterGui/GameGui/GameUI.lua`
6. Pega el código en el LocalScript

### Estructura Final en Roblox Studio

```
ServerScriptService/
  └── 📄 GameManager (Script)

ReplicatedStorage/
  └── 📄 SetupRemoteEvents (Script)

StarterGui/
  └── 📺 GuessingGameUI (ScreenGui)
      └── 📄 GameUI (LocalScript)
```

## 🎯 Cómo Funciona

### Flujo del Juego

1. **Inicio**: El servidor genera un número secreto entre 1 y 500
2. **Turnos**: Los jugadores se turnan en el orden en que se unieron
3. **Adivinanza**: El jugador actual ingresa un número en el TextBox
4. **Validación**: El servidor valida el intento y responde:
   - "Más alto ↑" si el número es menor que el secreto
   - "Más bajo ↓" si el número es mayor que el secreto
   - "¡CORRECTO! ¡Ganaste! 🎉" si acierta
5. **Siguiente turno**: El turno pasa automáticamente al siguiente jugador
6. **Victoria**: Cuando alguien acierta, el juego se reinicia tras 5 segundos

### Comunicación Cliente-Servidor

El juego usa **RemoteEvents** para comunicación segura:

#### RemoteEvents Creados

| Nombre | Dirección | Propósito |
|--------|-----------|-----------|
| `SubmitGuess` | Cliente → Servidor | Enviar intento de adivinanza |
| `GuessResult` | Servidor → Cliente | Respuesta del intento |
| `TurnUpdate` | Servidor → Cliente | Actualizar información de turno |
| `GameState` | Servidor → Cliente | Mensajes generales del juego |

## 🎨 Interfaz de Usuario

La UI incluye:

- **Título**: Nombre del juego
- **Estado del juego**: Mensajes generales (ej: "Nuevo juego iniciado")
- **Información de turno**: Muestra de quién es el turno
- **Contador de intentos**: Total de intentos en la ronda actual
- **Campo de entrada**: TextBox para escribir el número
- **Botón de envío**: Botón para confirmar el intento
- **Resultado**: Muestra la respuesta del servidor con colores:
  - 🟢 Verde: Victoria
  - 🔵 Azul: Pista (más alto/bajo)
  - 🔴 Rojo: Error

## 🔒 Seguridad Anti-Trampas

El juego implementa varias medidas de seguridad:

1. ✅ **Número secreto en servidor**: El cliente nunca conoce el número
2. ✅ **Validación de turnos**: Solo el jugador actual puede enviar intentos
3. ✅ **Validación de entrada**: Se valida que sea un número en rango válido
4. ✅ **RemoteEvents seguros**: Toda la lógica crítica está en el servidor

## ⚙️ Configuración

Puedes personalizar estos valores en `GameManager.lua`:

```lua
local MIN_NUMBER = 1           -- Número mínimo
local MAX_NUMBER = 500         -- Número máximo
local TURN_TIMEOUT = 30        -- Segundos por turno (funcionalidad base)
```

## 🐛 Solución de Problemas

### El juego no inicia

- ✅ Verifica que `SetupRemoteEvents` sea un **Script** (no LocalScript)
- ✅ Asegúrate de que esté en **ReplicatedStorage**
- ✅ Revisa la consola de salida para errores

### No aparece la UI

- ✅ Verifica que `GameUI` sea un **LocalScript**
- ✅ Debe estar dentro de un **ScreenGui** en **StarterGui**
- ✅ Revisa la consola del cliente (F9 en prueba)

### Los turnos no funcionan

- ✅ Verifica que los RemoteEvents se hayan creado correctamente
- ✅ Revisa la consola del servidor para mensajes de error
- ✅ Asegúrate de que hay al menos 2 jugadores en el juego

## 📊 Arquitectura del Código

### Servidor (GameManager.lua)

**Funciones principales:**

- `generateSecretNumber()`: Genera número aleatorio
- `getCurrentPlayer()`: Obtiene el jugador del turno actual
- `broadcastTurnUpdate()`: Envía info de turno a todos los clientes
- `nextTurn()`: Avanza al siguiente jugador
- `addPlayerToQueue()`: Agrega jugador a la cola
- `removePlayerFromQueue()`: Remueve jugador de la cola
- `resetGame()`: Reinicia el juego con nuevo número

### Cliente (GameUI.lua)

**Funciones principales:**

- `updateButtonState()`: Actualiza UI según turno
- `showResult()`: Muestra resultado con color apropiado
- `submitGuess()`: Valida y envía intento al servidor

## 🎓 Aprendizaje

Este proyecto es excelente para aprender:

- 📡 **RemoteEvents**: Comunicación cliente-servidor
- 🎮 **Lógica de juego**: Sistemas de turnos
- 🖼️ **UI en Roblox**: Creación de interfaces
- 🔐 **Seguridad**: Validación del lado del servidor
- 👥 **Multijugador**: Manejo de múltiples jugadores

## 📝 Notas Adicionales

- El juego inicia automáticamente cuando el primer jugador se une
- Se pausa si todos los jugadores salen
- Los turnos se ajustan automáticamente cuando jugadores entran/salen
- El contador de intentos se reinicia en cada ronda nueva

## 🚀 Mejoras Futuras Posibles

- ⏱️ Temporizador visible por turno
- 🏆 Sistema de puntos/estadísticas
- 💬 Chat de pistas entre jugadores
- 🎨 Temas visuales personalizables
- 📊 Tabla de clasificación
- 🔊 Efectos de sonido

## 📄 Licencia

Este código es libre de usar, modificar y distribuir para proyectos personales y educativos.

---

**¡Diviértete jugando! 🎉**
