# Single Row Glass Panel System - Roblox Studio

Sistema de paneles de cristal de **una sola fila** con caída temporal para Roblox Studio. Cada panel tiene un tiempo de caída diferente que se activa cuando el jugador lo pisa.

## ⚠️ IMPORTANTE: No Conflicto con Glass Bridge

Este sistema es **completamente independiente** del sistema de Glass Bridge que puedas tener en tu juego. Usa nombres únicos y no interfiere con:
- GlassBridge (folder existente)
- GlassBridgeManager
- GlassPanel (ModuleScript)
- GlassBridgeEffects
- GlassBridgeClientEffects

**Diferencias clave:**
- Este sistema usa el folder `SingleRowGlass` (no `GlassBridge`)
- Los paneles se llaman `SinglePanel1`, `SinglePanel2`, etc. (no `Panel1`, `Panel2`)
- Es para una **sola fila** con tiempos de caída progresivos
- No requiere ModuleScripts ni RemoteEvents
- Funciona completamente del lado del cliente

## 📋 Características

- ✅ Sistema completamente del lado del cliente (LocalScript)
- ✅ Caída progresiva: cada panel reduce 0.1s el tiempo de caída
- ✅ Animaciones suaves con TweenService
- ✅ Respawn automático después de 15 segundos
- ✅ Detección precisa de colisión con el jugador
- ✅ Optimizado sin loops infinitos
- ✅ Funciona con cualquier número de paneles automáticamente
- ✅ Los paneles no desaparecen del servidor, solo simulan caída en cliente

## 📦 Instalación

### Paso 1: Crear el Folder de Paneles

1. En **Workspace**, crea un **Folder** llamado `SingleRowGlass` ⚠️ (NO `GlassRow` ni `GlassBridge`)
2. Dentro de este folder, crea las partes (paneles) con los siguientes nombres:
   - `SinglePanel1` ⚠️ (NO `Panel1`)
   - `SinglePanel2`
   - `SinglePanel3`
   - `SinglePanel4`
   - ... (tantos como necesites)

### Paso 2: Configurar las Partes

Cada panel debe tener las siguientes propiedades:

- **Anchored**: `true`
- **CanCollide**: `true`
- **Transparency**: `0.3` a `0.5` (opcional, para efecto de cristal)
- **Material**: `Glass` o `SmoothPlastic`
- **Size**: Recomendado `Vector3.new(4, 0.5, 4)` o similar

**Opcional para efecto visual:**
- **Color**: Azul claro o transparente
- **Reflectance**: `0.2` a `0.5`

### Paso 3: Instalar el Script

1. Abre **StarterPlayer** → **StarterPlayerScripts**
2. Crea un nuevo **LocalScript**
3. Copia todo el contenido de `SingleRowGlassSystem.lua` en el script
4. Nombra el script como `SingleRowGlassSystem` (opcional pero recomendado)

### Paso 4: Probar

1. Presiona **Play** (F5)
2. Camina sobre los paneles
3. Observa cómo cada panel cae después de su tiempo asignado

## ⚙️ Configuración

Puedes ajustar estos valores en la sección de configuración del script:

```lua
local BASE_FALL_TIME = 5.0 -- Tiempo de caída del primer panel (segundos)
local TIME_REDUCTION = 0.1 -- Reducción de tiempo por cada panel (segundos)
local RESPAWN_TIME = 15 -- Tiempo para que el panel reaparezca (segundos)
local FALL_DISTANCE = 20 -- Distancia que cae el panel (studs)
local FALL_TWEEN_TIME = 1.5 -- Duración de la animación de caída (segundos)
local RESPAWN_TWEEN_TIME = 1.0 -- Duración de la animación de respawn (segundos)
local ACTIVATION_RANGE = 0.5 -- Rango de detección (studs)
```

## 🎮 Funcionamiento

### Tiempos de Caída

Cada panel tiene un tiempo de caída calculado automáticamente:

| Panel | Tiempo de Caída |
|-------|----------------|
| Panel1 | 5.0 segundos |
| Panel2 | 4.9 segundos |
| Panel3 | 4.8 segundos |
| Panel4 | 4.7 segundos |
| Panel5 | 4.6 segundos |
| ... | ... |

### Ciclo de Vida de un Panel

1. **Jugador pisa el panel** → Se inicia el temporizador
2. **Espera su tiempo asignado** → (5.0s, 4.9s, 4.8s, etc.)
3. **Panel cae** → Animación de 1.5 segundos bajando 20 studs
4. **CanCollide = false** → El jugador ya no puede pararse en él
5. **Espera 15 segundos** → Tiempo de respawn
6. **Panel reaparece** → Animación de 1.0 segundos con efecto bounce
7. **CanCollide = true** → El panel está listo de nuevo
8. **Vuelve al estado inicial** → Puede ser activado nuevamente

### Características Técnicas

- **Detección de jugador**: Usa `RunService.Heartbeat` para actualización eficiente
- **Animaciones**: Implementadas con `TweenService` para suavidad
- **Estado local**: Cada cliente mantiene su propio estado de paneles
- **Optimización**: Solo actualiza cuando es necesario, sin loops innecesarios

## 🛠️ Ejemplo de Configuración de Paneles

Si quieres crear los paneles automáticamente, puedes usar este script en **ServerScriptService** (ejecutar una sola vez):

```lua
local workspace = game:GetService("Workspace")

-- Crear folder
local glassRow = Instance.new("Folder")
glassRow.Name = "SingleRowGlass" -- ⚠️ IMPORTANTE: Usar "SingleRowGlass", no "GlassRow"
glassRow.Parent = workspace

-- Configuración
local NUM_PANELS = 10 -- Número de paneles a crear
local PANEL_SIZE = Vector3.new(4, 0.5, 4)
local START_POSITION = Vector3.new(0, 5, 0)
local SPACING = 5 -- Espacio entre paneles

-- Crear paneles
for i = 1, NUM_PANELS do
    local panel = Instance.new("Part")
    panel.Name = "SinglePanel" .. i -- ⚠️ IMPORTANTE: Usar "SinglePanel", no "Panel"
    panel.Size = PANEL_SIZE
    panel.Position = START_POSITION + Vector3.new(0, 0, (i - 1) * SPACING)
    panel.Anchored = true
    panel.CanCollide = true
    panel.Material = Enum.Material.Glass
    panel.Transparency = 0.3
    panel.Color = Color3.fromRGB(173, 216, 230) -- Azul claro
    panel.Reflectance = 0.3
    panel.Parent = glassRow
end

print("Paneles creados:", NUM_PANELS)
```

## 📝 Notas Importantes

1. **Solo Cliente**: Todo el sistema funciona del lado del cliente. Los paneles nunca desaparecen realmente del servidor.

2. **Múltiples Jugadores**: Cada jugador verá su propia versión de los paneles cayendo. Lo que ve un jugador no afecta a otros.

3. **Rendimiento**: El sistema está optimizado para no crear lag. Usa `Heartbeat` en lugar de `RenderStepped` para mejor rendimiento.

4. **Nombres de Paneles**: Los paneles DEBEN llamarse `SinglePanel1`, `SinglePanel2`, `SinglePanel3`, etc. ⚠️ (NO `Panel1`, `Panel2`). El número es importante para calcular el tiempo de caída.

5. **Orden Automático**: Los paneles se ordenan automáticamente por número, no importa el orden en que los crees en el Workspace.

6. **Compatibilidad con Glass Bridge**: Este sistema NO interfiere con tu sistema de Glass Bridge existente. Usan nombres y folders completamente diferentes.

## 🐛 Solución de Problemas

### Los paneles no caen

- Verifica que el folder se llame exactamente `SingleRowGlass` (NO `GlassRow` ni `GlassBridge`)
- Verifica que los paneles se llamen `SinglePanel1`, `SinglePanel2`, etc. (NO `Panel1`, `Panel2`)
- Revisa la consola (F9) para ver mensajes de error
- Asegúrate de que el LocalScript esté en StarterPlayerScripts (NO en StarterPlayer o StarterCharacterScripts)

### El jugador atraviesa los paneles

- Asegúrate de que `CanCollide = true` en las propiedades del panel
- Verifica que los paneles estén `Anchored = true`

### Los tiempos no son correctos

- Revisa la configuración de `BASE_FALL_TIME` y `TIME_REDUCTION`
- Verifica que los números de los paneles sean correctos

### Los paneles no reaparecen

- Verifica el valor de `RESPAWN_TIME` en la configuración
- Revisa si hay errores en la consola

## 🎯 Ejemplo de Uso - Parkour

Este sistema es perfecto para crear parkour challenges:

1. Crea una fila de 20 paneles
2. El jugador debe correr rápido antes de que caigan
3. Los primeros paneles duran más, dando tiempo al jugador
4. Los últimos paneles caen más rápido, aumentando la dificultad

## 📄 Licencia

Este código es de uso libre para proyectos de Roblox.

## ✨ Créditos

Creado por Claude AI - 2025
