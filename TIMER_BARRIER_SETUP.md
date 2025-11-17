# 🕐 Sistema de Barrera con Temporizador Individual

Sistema completo para crear una barrera que se vuelve atravesable solo para jugadores individuales cuando su temporizador personal llega a 0.

---

## 📋 Características

✅ **Temporizador individual** - Cada jugador tiene su propio temporizador de 15 minutos
✅ **Colisión selectiva** - La barrera es sólida para algunos jugadores y atravesable para otros
✅ **UI en la barrera** - Cada jugador ve su propio tiempo en la Part
✅ **Sincronización cliente-servidor** - Usa RemoteEvents para comunicación
✅ **Sistema de Collision Groups** - Implementado con PhysicsService

---

## 🎯 Cómo Funciona

1. **Al inicio**: Todos los jugadores tienen la barrera ACTIVA (no pueden atravesarla)
2. **Durante el juego**: Cada jugador ve su temporizador personal de 15 minutos
3. **Cuando el temporizador llega a 0**:
   - El cliente notifica al servidor
   - El servidor cambia el collision group del jugador
   - El jugador ahora puede atravesar la barrera
   - La UI muestra "BARRERA DESACTIVADA"

---

## 🛠️ Instalación

### Paso 1: Crear la Part en Workspace

1. Abre **Roblox Studio**
2. En el explorador, ve a **Workspace**
3. Haz clic derecho → **Insert Object** → **Part**
4. Selecciona la Part y configúrala:
   - **Name**: `TimerBarrier` (IMPORTANTE: debe llamarse exactamente así)
   - **Size**: `Vector3.new(20, 10, 1)` (o el tamaño que prefieras)
   - **Position**: Colócala donde quieras en tu juego
   - **Anchored**: `true` (marcado)
   - **CanCollide**: `true` (marcado)
   - **Material**: `Neon` o `ForceField` (para que se vea llamativa)
   - **Color**: `Color3.fromRGB(255, 100, 100)` (rojo)
   - **Transparency**: `0.3` (semi-transparente)

### Paso 2: Scripts del Servidor

#### TimerBarrierManager.lua
**Ubicación**: `ServerScriptService > TimerBarrierManager` (Script normal)

Este script:
- Configura los Collision Groups
- Maneja la comunicación con los clientes
- Cambia el estado de colisión de cada jugador

### Paso 3: Scripts del Cliente

#### TimerBarrierClient.lua
**Ubicación**: `StarterPlayer > StarterPlayerScripts > TimerBarrierClient` (LocalScript)

Este script:
- Crea la UI del temporizador en la barrera
- Actualiza el contador cada segundo
- Notifica al servidor cuando el tiempo termina

---

## 📁 Estructura de Archivos

```
📦 Proyecto
├── 📂 Workspace
│   └── 📦 TimerBarrier (Part)
│       └── 🖼️ TimerSurfaceGui (se crea automáticamente)
│           └── 📄 MainFrame
│               ├── 📝 TimerLabel (muestra "15:00")
│               └── 📝 TitleLabel (muestra "⏰ BARRERA ACTIVA")
│
├── 📂 ServerScriptService
│   └── 📜 TimerBarrierManager.lua (Script)
│
├── 📂 StarterPlayer
│   └── 📂 StarterPlayerScripts
│       └── 📜 TimerBarrierClient.lua (LocalScript)
│
└── 📂 ReplicatedStorage
    ├── 🔔 TimerBarrierEvent (RemoteEvent - se crea automáticamente)
    └── 🔢 TimerDuration (IntValue - se crea automáticamente)
```

---

## ⚙️ Configuración

### Cambiar Duración del Temporizador

En `TimerBarrierManager.lua` (línea 12):
```lua
local TIMER_DURATION = 15 * 60 -- 15 minutos en segundos
```

Ejemplos:
- 5 minutos: `local TIMER_DURATION = 5 * 60`
- 30 segundos: `local TIMER_DURATION = 30`
- 1 hora: `local TIMER_DURATION = 60 * 60`

### Cambiar Nombre de la Barrera

Si quieres usar un nombre diferente para la Part:

**En `TimerBarrierManager.lua` (línea 11):**
```lua
local BARRIER_NAME = "MiBarrera" -- Cambia aquí
```

**En `TimerBarrierClient.lua` (línea 15):**
```lua
local BARRIER_NAME = "MiBarrera" -- Cambia aquí también
```

### Cambiar Cara del SurfaceGui

En `TimerBarrierClient.lua` (línea 46):
```lua
surfaceGui.Face = Enum.NormalId.Front -- Opciones: Front, Back, Top, Bottom, Left, Right
```

---

## 🎨 Personalización de la UI

### Colores del Temporizador

El color cambia automáticamente según el tiempo:

| Tiempo Restante | Color | Código |
|----------------|-------|--------|
| > 5 minutos | 🔴 Rojo | `Color3.fromRGB(255, 100, 100)` |
| 1-5 minutos | 🟠 Naranja | `Color3.fromRGB(255, 150, 50)` |
| < 1 minuto | 🔴 Rojo intenso | `Color3.fromRGB(255, 50, 50)` |
| Terminado | 🟢 Verde | `Color3.fromRGB(100, 255, 100)` |

### Tamaño del Texto

En `TimerBarrierClient.lua`, puedes ajustar:
```lua
surfaceGui.PixelsPerStud = 50 -- Aumenta para texto más grande
```

---

## 🎮 Comandos de Debug

Desde la consola del servidor, puedes usar:

### Resetear todas las barreras
```lua
_G.ResetBarrier()
```
Esto hace que TODOS los jugadores vuelvan a tener la barrera activa.

### Desactivar barrera para un jugador específico
```lua
_G.DisableBarrier("NombreDelJugador")
```
Ejemplo:
```lua
_G.DisableBarrier("Player1")
```

---

## 🔧 Collision Groups Explicados

Este sistema usa **3 Collision Groups**:

1. **PlayersWithBarrier** - Jugadores que AÚN tienen barrera
   - ✅ SÍ colisiona con TimerBarrier
   - Todos los jugadores empiezan aquí

2. **PlayersWithoutBarrier** - Jugadores sin barrera
   - ❌ NO colisiona con TimerBarrier
   - Los jugadores se mueven aquí cuando el temporizador termina

3. **TimerBarrier** - La barrera misma
   - Configurada para colisionar selectivamente

---

## 🐛 Solución de Problemas

### La barrera no aparece
- Verifica que la Part se llame exactamente `TimerBarrier`
- Revisa la consola del servidor para mensajes de error
- Asegúrate de que la Part esté en **Workspace** (no dentro de una carpeta)

### El temporizador no se muestra
- Verifica que `TimerBarrierClient.lua` esté en **StarterPlayerScripts**
- Asegúrate de que sea un **LocalScript**, no un Script normal
- Revisa la consola del cliente (F9) para errores

### Los jugadores atraviesan la barrera desde el inicio
- Verifica que `CanCollide = true` en la Part
- Revisa que el script del servidor se haya ejecutado (mira la consola)
- Usa `_G.ResetBarrier()` para resetear

### El temporizador no cuenta
- Asegúrate de que el LocalScript se esté ejecutando
- Verifica que `timeRemaining` tenga un valor válido
- Revisa la consola del cliente para errores

### La barrera no se desactiva cuando termina el tiempo
- Verifica que el RemoteEvent se haya creado en ReplicatedStorage
- Revisa la consola del servidor para ver si recibió el evento
- Comprueba que los Collision Groups se hayan configurado correctamente

---

## 📝 Notas Técnicas

### ¿Por qué usar Collision Groups?

Roblox no permite que una Part sea sólida para un jugador y atravesable para otro directamente. Los **Collision Groups** son la solución oficial de Roblox para este problema.

### ¿El temporizador persiste si el jugador muere?

Por defecto, el temporizador **SÍ persiste** incluso si el jugador respawnea. Si quieres que se reinicie al morir, descomenta las líneas en `TimerBarrierClient.lua` (líneas 199-202).

### ¿Puedo tener múltiples barreras?

Sí, pero necesitarás duplicar y modificar los scripts para cada barrera adicional, usando diferentes nombres y RemoteEvents.

---

## 🎯 Ejemplo de Uso

### Escenario: Zona VIP con Temporizador

1. Crea una barrera frente a una zona VIP
2. Los jugadores nuevos no pueden entrar (tienen la barrera activa)
3. Después de 15 minutos de juego, pueden acceder
4. Usa esto para recompensar a jugadores que permanecen en el juego

---

## 📊 Flujo de Datos

```
Cliente                         Servidor
   |                               |
   |-- Espera 15 minutos --------> |
   |                               |
   |-- TimerEnded (RemoteEvent) -> |
   |                               |
   |                          Cambia Collision Group
   |                          del jugador
   |                               |
   | <-- BarrierDisabled ----------|
   |                               |
Puede atravesar                Actualizado
la barrera
```

---

## ✅ Checklist de Instalación

- [ ] Part "TimerBarrier" creada en Workspace
- [ ] TimerBarrierManager.lua en ServerScriptService
- [ ] TimerBarrierClient.lua en StarterPlayerScripts
- [ ] Part configurada con Anchored = true y CanCollide = true
- [ ] Probado en modo de juego (Play)
- [ ] Temporizador visible en la barrera
- [ ] Barrera se desactiva cuando el temporizador llega a 0

---

## 🚀 Mejoras Futuras

Posibles expansiones del sistema:

1. **Sonido de cuenta regresiva** - Agregar tick en los últimos 10 segundos
2. **Efectos visuales** - Partículas cuando la barrera se desactiva
3. **Notificación en pantalla** - Mensaje grande cuando se desactiva
4. **Persistencia de datos** - Guardar el tiempo en DataStore
5. **Múltiples barreras** - Sistema para manejar varias barreras
6. **Powerups** - Items que reducen el tiempo del temporizador

---

¡Sistema listo para usar! 🎉
