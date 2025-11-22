# Timed Glass Panel System - Roblox Studio

Sistema de cristales con temporizador individual. Cada cristal tiene un tiempo diferente que se activa al pisarlo.

## ⚠️ NO CHOCA CON GLASS BRIDGE

Este sistema usa nombres completamente diferentes:
- **Folder:** `TimedGlassRow` (NO es GlassBridge)
- **Paneles:** `TimedPanel1`, `TimedPanel2`, etc.
- **Scripts:** Completamente independientes

## 🎯 Cómo Funciona

- **Panel 1:** Cae a los 5.0 segundos de pisarlo
- **Panel 2:** Cae a los 4.9 segundos de pisarlo
- **Panel 3:** Cae a los 4.8 segundos de pisarlo
- Cada panel reduce 0.1 segundos respecto al anterior
- La caída es solo visual (lado del cliente)
- Reaparece después de 15 segundos
- **Muestra en consola** qué panel estás tocando

## 📦 Instalación (2 Pasos)

### PASO 1: Crear los Paneles (Servidor)

1. Ve a **ServerScriptService**
2. Crea un **Script** (normal, NO LocalScript)
3. Copia el contenido de **`TimedGlassPanelSetup.lua`**
4. Presiona **Play (F5)** UNA SOLA VEZ
5. Verás en la consola que se crean los paneles
6. **Detén el juego**
7. **ELIMINA el script** (ya no lo necesitas)

**Resultado:** Se creará un folder `TimedGlassRow` en Workspace con todos los paneles.

### PASO 2: Instalar el Sistema del Cliente

1. Ve a **StarterPlayer** → **StarterPlayerScripts**
2. Crea un **LocalScript**
3. Copia el contenido de **`TimedGlassPanelClient.lua`**
4. Nombra el script `TimedGlassPanelClient`
5. Presiona **Play (F5)**
6. Presiona **F9** para ver la consola
7. Camina sobre los paneles

## 📊 Qué Verás en la Consola

Cuando el sistema se inicie:
```
═══════════════════════════════════════════════════════
TIMED GLASS PANEL SYSTEM - INICIANDO
═══════════════════════════════════════════════════════
✅ Folder encontrado: TimedGlassRow
✅ Paneles encontrados: 15
───────────────────────────────────────────────────────
📦 TimedPanel1 | Tiempo de caída: 5.0s
📦 TimedPanel2 | Tiempo de caída: 4.9s
📦 TimedPanel3 | Tiempo de caída: 4.8s
...
───────────────────────────────────────────────────────
✅ SISTEMA LISTO - Camina sobre los paneles
═══════════════════════════════════════════════════════
```

Cuando pises un panel:
```
👟 PISASTE PANEL 1 | Tiempo: 5.0s
⏱️ PANEL 1 ACTIVADO | Caerá en 5.0 segundos
💥 PANEL 1 CAYENDO
⌛ PANEL 1 respawnea en 15 segundos
✅ PANEL 1 RESPAWNEADO - Listo de nuevo
```

## ⚙️ Configuración

### En `TimedGlassPanelSetup.lua` (servidor):

```lua
NUM_PANELS = 15,                    -- Cuántos paneles crear
PANEL_SIZE = Vector3.new(5, 0.5, 5), -- Tamaño
START_POSITION = Vector3.new(0, 10, 0), -- Posición inicial
SPACING = 6,                        -- Espacio entre paneles
DIRECTION = "Z",                    -- X, Y, o Z
```

### En `TimedGlassPanelClient.lua` (cliente):

```lua
BASE_TIME = 5.0,         -- Tiempo del primer panel
TIME_REDUCTION = 0.1,    -- Reducción por panel
RESPAWN_TIME = 15,       -- Tiempo de respawn
FALL_DISTANCE = 30,      -- Distancia de caída
```

## 🔍 Estructura del Sistema

```
Workspace
└── TimedGlassRow (Folder)
    ├── TimedPanel1 (Part)
    ├── TimedPanel2 (Part)
    ├── TimedPanel3 (Part)
    └── ...

StarterPlayer
└── StarterPlayerScripts
    └── TimedGlassPanelClient (LocalScript)
```

## 🐛 Solución de Problemas

### "No se encontró el folder"
- Verifica que el folder se llame exactamente `TimedGlassRow`
- Ejecuta primero el script de servidor (Paso 1)

### "No se encontraron paneles"
- Los paneles deben llamarse `TimedPanel1`, `TimedPanel2`, etc.
- Ejecuta el script de servidor para crearlos automáticamente

### No pasa nada al pisar
- Verifica que el LocalScript esté en **StarterPlayerScripts**
- Presiona F9 y mira si hay errores en la consola
- Verifica que los paneles tengan `CanCollide = true`

### El panel no cae visualmente
- Es normal, solo cae del lado del cliente
- Otros jugadores verán su propia versión
- El servidor siempre ve los paneles en su lugar

## 📋 Checklist de Instalación

- [ ] Ejecuté `TimedGlassPanelSetup.lua` en ServerScriptService
- [ ] Se creó el folder `TimedGlassRow` en Workspace
- [ ] Eliminé el script de setup del servidor
- [ ] Copié `TimedGlassPanelClient.lua` en StarterPlayerScripts
- [ ] Es un **LocalScript** (no Script normal)
- [ ] Presioné F9 para ver la consola
- [ ] Veo los mensajes de inicialización
- [ ] Al caminar sobre los paneles veo mensajes

## ✅ Garantizado

✅ No interfiere con Glass Bridge
✅ Nombres completamente únicos
✅ Detección confiable por evento `.Touched`
✅ Mensajes claros en consola
✅ Fácil de debuggear

---

**Nota:** Este sistema es completamente independiente y puede coexistir con tu Glass Bridge sin problemas.
