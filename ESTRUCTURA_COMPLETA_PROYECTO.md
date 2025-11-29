# 📁 ESTRUCTURA COMPLETA DEL PROYECTO - Sistema de Orbs con Niveles

## 🗂️ VISTA GENERAL DE LA ESTRUCTURA

```
ROBLOX STUDIO
│
├─ ReplicatedStorage
│   ├─ Modules (Folder)
│   │   ├─ OrbConfig (ModuleScript)
│   │   ├─ OrbManager (ModuleScript)
│   │   └─ LevelManager (ModuleScript)
│   │
│   └─ RemoteEvents (Folder)
│       ├─ OrbCollected (RemoteEvent)
│       ├─ RequestRebirthPurchase (RemoteEvent)
│       ├─ ShowOrbNotification (RemoteEvent)
│       ├─ LevelUp (RemoteEvent)
│       └─ MaxLevelReached (RemoteEvent)
│
├─ ServerScriptService
│   ├─ InitializeServer (Script)
│   ├─ DataManager (Script)
│   ├─ MoneyManager (Script)
│   ├─ RebirthManager (Script)
│   ├─ OrbGenerator (Script)
│   ├─ AutoConfigureZones (Script)
│   └─ VerifySetup (Script)
│
├─ StarterGui
│   ├─ PrincipalGui (ScreenGui)
│   │   └─ Frame
│   │       ├─ LevelDisplay (TextLabel) ← TÚ LO CREAS
│   │       ├─ ExpDisplay (TextLabel) ← TÚ LO CREAS
│   │       ├─ SpeedDisplay (TextLabel) ← TÚ LO CREAS
│   │       ├─ PlayerStatsDisplay (LocalScript)
│   │       ├─ Rebirths (TextButton)
│   │       │   └─ RebirthButtonScript (LocalScript)
│   │       └─ [otros elementos de tu GUI...]
│   │
│   ├─ RebirthGui (ScreenGui)
│   │   └─ Frame
│   │       ├─ Title (TextLabel)
│   │       ├─ PriceLabel (TextLabel)
│   │       ├─ MultiplierLabel (TextLabel)
│   │       ├─ CurrentLevelCapLabel (TextLabel) ← TÚ LO CREAS
│   │       ├─ NextLevelCapLabel (TextLabel) ← TÚ LO CREAS
│   │       ├─ PurchaseButton (TextButton)
│   │       ├─ CloseButton (TextButton)
│   │       └─ RebirthGuiScript (LocalScript)
│   │
│   ├─ OrbNotifications (ScreenGui) ← TÚ LO CREAS
│   │   └─ Container (Frame) ← TÚ LO CREAS
│   │       └─ NotificationTemplate (Frame) ← TÚ LO DISEÑAS
│   │           ├─ EXPLabel (TextLabel) ← OBLIGATORIO
│   │           ├─ OrbTypeLabel (TextLabel) ← OPCIONAL
│   │           ├─ OrbIcon (Frame/ImageLabel) ← OPCIONAL
│   │           ├─ UICorner ← OPCIONAL
│   │           └─ UIStroke ← OPCIONAL
│   │
│   ├─ OrbNotificationManager (LocalScript)
│   └─ MaxLevelNotification (LocalScript)
│
├─ StarterPlayer
│   ├─ StarterCharacterScripts
│   │   └─ Running (LocalScript) ← REEMPLAZAR CON Running_MODIFIED.lua
│   │
│   └─ StarterPlayerScripts
│       └─ OrbClientManager (LocalScript)
│
└─ Workspace
    └─ Zones (Folder) ← TÚ LO CREAS
        ├─ Zone1 (Part)
        ├─ Zone2 (Part)
        └─ Zone3 (Part)
```

---

## 📂 DETALLES DE CADA CARPETA

### 🔵 ReplicatedStorage

**Propósito:** Almacena módulos y eventos compartidos entre servidor y cliente.

#### Modules (Folder)
Contiene ModuleScripts que pueden ser requeridos tanto por el servidor como por el cliente.

**OrbConfig.lua** - Configuración de orbs y sistema de rebirths
- Define tipos de orbs (Yellow, Green, Blue)
- EXP y dinero que dan los orbs
- Configuración de rebirths (costos, multiplicadores)
- Configuración de zonas
- Funciones de cálculo (RebirthCost, EXPMultiplier)

**OrbManager.lua** - Gestión de instancias de orbs (cliente)
- Pool de orbs reutilizables
- Creación y reciclaje de orbs
- Configuración visual de orbs

**LevelManager.lua** - Sistema de niveles y progresión
- Tabla de niveles (0-40)
- XP requerido por nivel
- Velocidad de sprint por nivel
- Level caps por rebirth
- Funciones de level-up

#### RemoteEvents (Folder)
Eventos para comunicación cliente-servidor.

**OrbCollected** - Cliente → Servidor
- Se dispara cuando el cliente toca un orb
- Parámetros: orbType (string)

**RequestRebirthPurchase** - Cliente ⇄ Servidor
- Cliente → Servidor: Solicitar compra de rebirth
- Servidor → Cliente: Resultado de la compra (success, message, data)

**ShowOrbNotification** - Servidor → Cliente
- Muestra notificación flotante de orb recogido
- Parámetros: orbType, expAmount, orbColor

**LevelUp** - Servidor → Cliente
- Notifica cuando el jugador sube de nivel
- Parámetros: newLevel, newSpeed

**MaxLevelReached** - Servidor → Cliente
- Notifica cuando alcanza el nivel máximo
- Parámetros: currentLevel, rebirths

---

### 🔴 ServerScriptService

**Propósito:** Scripts que se ejecutan solo en el servidor.

**InitializeServer.lua** - Inicialización del servidor
- Se ejecuta primero
- Verifica que existen carpetas necesarias
- Inicializa sistemas en orden correcto

**DataManager.lua** - Gestión de datos persistentes
- Integración con DataStore
- Guardado y carga de datos de jugadores
- Manejo de sesiones
- Funciones: GetData, SetData, SaveData, ProcessRebirth
- Crea leaderstats (Money, Rebirths, Level, CurrentEXP)
- Sistema de auto-guardado cada 5 minutos

**MoneyManager.lua** - Gestión de recolección de orbs
- Procesa evento OrbCollected
- Valida recolección (cooldown anti-exploit)
- Da dinero y EXP al jugador
- Procesa level-ups automáticos
- Dispara eventos de notificaciones

**RebirthManager.lua** - Gestión de rebirths
- Procesa compras de rebirth
- Valida que el jugador tenga suficiente dinero
- Resetea nivel y EXP
- Aumenta multiplicador de EXP
- Calcula level caps

**OrbGenerator.lua** - Generación de orbs en el servidor
- Lee configuración de zonas
- Genera posiciones aleatorias dentro de zonas
- Envía posiciones a todos los clientes
- Sistema de regeneración automática

**AutoConfigureZones.lua** - Configuración automática de zonas
- Detecta Parts en carpeta Zones
- Asigna atributos automáticamente
- Configuración por defecto

**VerifySetup.lua** - Verificación de instalación
- Diagnóstico del sistema
- Reporta qué falta o está mal configurado
- Útil para debugging

---

### 🟢 StarterGui

**Propósito:** Interfaces de usuario (GUIs) que se copian a cada jugador.

#### PrincipalGui (ScreenGui)
GUI principal que muestra estadísticas del jugador.

**Elementos que TÚ debes crear:**
- **LevelDisplay** (TextLabel) - Muestra nivel actual
- **ExpDisplay** (TextLabel) - Muestra EXP actual / EXP requerido
- **SpeedDisplay** (TextLabel) - Muestra velocidad de sprint

**PlayerStatsDisplay.lua** (LocalScript)
- Actualiza los 3 TextLabels automáticamente
- Escucha cambios en leaderstats
- Calcula velocidad desde nivel
- Formatea números con separadores de miles

#### RebirthGui (ScreenGui)
GUI de compra de rebirths.

**Elementos existentes:**
- Title, PriceLabel, MultiplierLabel
- PurchaseButton, CloseButton

**Elementos que TÚ debes crear:**
- **CurrentLevelCapLabel** (TextLabel) - Muestra nivel máximo actual
- **NextLevelCapLabel** (TextLabel) - Muestra nivel máximo siguiente

**RebirthGuiScript.lua** (LocalScript)
- Gestiona la interfaz de rebirth
- Muestra costos y multiplicadores
- Valida compra
- Actualiza información en tiempo real

#### OrbNotifications (ScreenGui)
Sistema de notificaciones de orbs.

**TÚ debes crear todo esto:**
- OrbNotifications (ScreenGui)
- Container (Frame)
- NotificationTemplate (Frame con elementos)

**Ver:** `GUIA_DISEÑO_NOTIFICACIONES.md` para detalles completos.

**OrbNotificationManager.lua** (LocalScript)
- Clona el template cuando recoges orbs
- Actualiza datos (EXP, color)
- Anima entrada y salida
- Gestiona cola de notificaciones (máx 5)

**MaxLevelNotification.lua** (LocalScript)
- Muestra notificación cuando alcanzas nivel máximo
- Sugiere comprar rebirth

---

### 🟡 StarterPlayer

**Propósito:** Scripts que se copian a cada jugador al unirse.

#### StarterCharacterScripts
Scripts que se ejecutan en el personaje del jugador.

**Running.lua** (LocalScript)
- ⚠️ **REEMPLAZAR** con Running_MODIFIED.lua
- Gestiona sprint del jugador
- Usa velocidad basada en nivel (no acumulada)
- Escucha eventos de level-up

#### StarterPlayerScripts
Scripts que se ejecutan en el jugador (no en el personaje).

**OrbClientManager.lua** (LocalScript)
- Recibe posiciones de orbs del servidor
- Crea orbs visibles solo para el cliente
- Detecta colisiones con orbs
- Envía evento OrbCollected al servidor
- Elimina orbs después de recogerlos

---

### 🌍 Workspace

**Propósito:** Entorno físico del juego.

#### Zones (Folder)
Carpeta que contiene zonas de spawn de orbs.

**TÚ debes crear:**
- Parts (Zone1, Zone2, Zone3, etc.)
- AutoConfigureZones los configurará automáticamente

**Propiedades recomendadas:**
```
Name: Zone1, Zone2, etc.
Transparency: 0.8
CanCollide: false
Anchored: true
Color: Cualquier color (visual de referencia)
```

**Atributos (auto-configurados):**
- ZoneName: Nombre de la zona
- OrbTypes: "Yellow,Green,Blue"
- MaxOrbs: 5
- SpawnHeight: 5

---

## 🔄 FLUJO DE DATOS

### 📥 Cuando un jugador se une:

```
1. DataManager.PlayerAdded
   ↓
2. Carga datos del DataStore
   ↓
3. Crea leaderstats (Money, Rebirths, Level, CurrentEXP)
   ↓
4. OrbGenerator genera posiciones
   ↓
5. Envía posiciones a OrbClientManager
   ↓
6. Cliente crea orbs visibles
```

### 🎯 Cuando recoges un orb:

```
1. OrbClientManager.OnTouch (CLIENTE)
   ↓
2. Dispara OrbCollected → Servidor
   ↓
3. MoneyManager.ProcessOrbCollection (SERVIDOR)
   ↓
4. Valida (cooldown, tipo de orb)
   ↓
5. Calcula EXP (base * multiplicador)
   ↓
6. Añade dinero y EXP (DataManager)
   ↓
7. Dispara ShowOrbNotification → Cliente
   ↓
8. OrbNotificationManager muestra notificación (CLIENTE)
   ↓
9. Procesa level-ups (loop)
   ↓
10. Dispara LevelUp → Cliente (si subió)
    ↓
11. Running script actualiza velocidad (CLIENTE)
```

### 🔄 Cuando compras un rebirth:

```
1. RebirthGui.PurchaseButton (CLIENTE)
   ↓
2. Dispara RequestRebirthPurchase → Servidor
   ↓
3. RebirthManager.ProcessRebirth (SERVIDOR)
   ↓
4. Valida dinero suficiente
   ↓
5. DataManager.ProcessRebirth
   ↓
6. Resta dinero
   ↓
7. Aumenta Rebirths
   ↓
8. Resetea Level y CurrentEXP a 0
   ↓
9. Aumenta EXPMultiplier
   ↓
10. Dispara RequestRebirthPurchase → Cliente (resultado)
    ↓
11. RebirthGui muestra resultado (CLIENTE)
```

### 💾 Guardado de datos:

```
Auto-guardado cada 5 minutos (DataManager)
   ↓
DataManager.AutoSaveLoop
   ↓
Para cada jugador conectado:
   ↓
DataStore:UpdateAsync(userId, data)
```

---

## 📊 DATOS ALMACENADOS

### DataStore (Persistente):
```lua
{
    Money = number,
    Rebirths = number,
    Level = number,
    CurrentEXP = number,
    EXPMultiplier = number,
    LastSave = number (timestamp)
}
```

### Leaderstats (Visible en juego):
```
Money (IntValue)
Rebirths (IntValue)
Level (IntValue)
CurrentEXP (IntValue)
```

---

## 🎨 GUIs QUE DEBES DISEÑAR

### 1. PrincipalGui - TextLabels de stats

**Ubicación:** `StarterGui > PrincipalGui > Frame`

**Crear:**
- **LevelDisplay** (TextLabel)
  - Texto inicial: "Nivel: 0"
  - Actualizado automáticamente por PlayerStatsDisplay

- **ExpDisplay** (TextLabel)
  - Texto inicial: "EXP: 0 / 50"
  - Actualizado automáticamente por PlayerStatsDisplay

- **SpeedDisplay** (TextLabel)
  - Texto inicial: "Velocidad: 24"
  - Actualizado automáticamente por PlayerStatsDisplay

**Propiedades sugeridas:**
```
BackgroundTransparency: 1
TextColor3: Blanco
TextSize: 18-20
Font: Gotham o GothamBold
TextXAlignment: Left (o Center según tu diseño)
```

### 2. RebirthGui - TextLabels de level caps

**Ubicación:** `StarterGui > RebirthGui > Frame`

**Crear:**
- **CurrentLevelCapLabel** (TextLabel)
  - Texto inicial: "Nivel Máximo Actual: 20"
  - Color: Blanco

- **NextLevelCapLabel** (TextLabel)
  - Texto inicial: "Nivel Máximo con Rebirth: 30"
  - Color: Verde brillante

**Ver:** `GUIA_INSTALACION_SISTEMA_NIVELES.md` para detalles.

### 3. OrbNotifications - Sistema de notificaciones

**Ubicación:** `StarterGui`

**Crear:**
- OrbNotifications (ScreenGui)
- Container (Frame)
- NotificationTemplate (Frame)
  - EXPLabel (TextLabel) - OBLIGATORIO
  - OrbTypeLabel (TextLabel) - OPCIONAL
  - OrbIcon (Frame) - OPCIONAL
  - UICorner - OPCIONAL
  - UIStroke - OPCIONAL

**Ver:** `GUIA_DISEÑO_NOTIFICACIONES.md` para guía completa de diseño.

---

## 🔧 CONFIGURACIÓN EDITABLE

### OrbConfig.lua - Configuración de orbs

```lua
-- Cambiar EXP que dan los orbs
Yellow = {
    EXPReward = 5,  ← CAMBIAR AQUÍ
    MoneyReward = 10,
    -- ...
}

-- Cambiar costos de rebirth
BaseRebirthCost = 15000,  ← CAMBIAR AQUÍ
RebirthCostMultiplier = 1.5,

-- Cambiar multiplicador de EXP
BaseEXPMultiplier = 1.1,  ← CAMBIAR AQUÍ (110%)
EXPMultiplierIncrease = 0.05,  ← Por cada rebirth (+5%)
```

### LevelManager.lua - Sistema de niveles

```lua
-- Cambiar niveles y velocidades
LevelManager.Levels = {
    [0] = {XPRequired = 50, RunSpeed = 24},
    [1] = {XPRequired = 100, RunSpeed = 26},
    -- ... EDITAR AQUÍ
}

-- Cambiar level caps
LevelManager.LevelCaps = {
    [0] = 20,  ← 0 rebirths = nivel 20 máximo
    [1] = 30,  ← 1 rebirth = nivel 30 máximo
    [2] = 40,  ← 2 rebirths = nivel 40 máximo
}
```

### OrbNotificationManager.lua - Configuración de notificaciones

```lua
local MAX_NOTIFICATIONS = 5  ← Máximo simultáneo
local NOTIFICATION_LIFETIME = 2  ← Duración (segundos)
local NOTIFICATION_SPACING = 10  ← Espacio entre ellas (px)
```

---

## 🧪 TESTING Y VERIFICACIÓN

### Checklist de instalación:

#### ReplicatedStorage:
- [ ] Existe carpeta Modules
- [ ] OrbConfig.lua está en Modules
- [ ] OrbManager.lua está en Modules
- [ ] LevelManager.lua está en Modules
- [ ] Existe carpeta RemoteEvents
- [ ] 5 RemoteEvents creados (OrbCollected, RequestRebirthPurchase, ShowOrbNotification, LevelUp, MaxLevelReached)

#### ServerScriptService:
- [ ] Todos los scripts están presentes
- [ ] InitializeServer se ejecuta primero

#### StarterGui:
- [ ] PrincipalGui existe con 3 TextLabels (Level, Exp, Speed)
- [ ] PlayerStatsDisplay.lua está en PrincipalGui/Frame
- [ ] RebirthGui existe con 2 TextLabels nuevos (CurrentLevelCap, NextLevelCap)
- [ ] OrbNotifications existe con Container y NotificationTemplate
- [ ] OrbNotificationManager.lua está en StarterGui
- [ ] MaxLevelNotification.lua está en StarterGui

#### StarterPlayer:
- [ ] Running.lua fue reemplazado con Running_MODIFIED.lua
- [ ] OrbClientManager.lua está en StarterPlayerScripts

#### Workspace:
- [ ] Existe carpeta Zones
- [ ] Al menos 1 Part (Zone1) dentro de Zones

### Test básico:

1. **Iniciar el juego**
   - No debe haber errores en Output
   - Leaderstats deben aparecer (Money, Rebirths, Level, CurrentEXP)

2. **Recoger un orb**
   - Debe aparecer notificación flotante
   - Money debe aumentar
   - CurrentEXP debe aumentar
   - Si tienes suficiente EXP, debe subir de nivel

3. **Abrir RebirthGui**
   - Debe mostrar precio correcto
   - Debe mostrar nivel máximo actual y siguiente
   - Debe mostrar multiplicador actual y siguiente

4. **Comprar rebirth** (si tienes dinero)
   - Nivel y EXP deben resetear a 0
   - Rebirths debe aumentar en 1
   - Nivel máximo debe aumentar

---

## 📚 GUÍAS ADICIONALES

- **GUIA_INSTALACION_SISTEMA_NIVELES.md** - Instalación paso a paso del sistema completo
- **GUIA_DISEÑO_NOTIFICACIONES.md** - Cómo diseñar la interfaz de notificaciones
- **CONFIGURACION_INICIAL_RAPIDA.md** - Setup rápido para empezar
- **SOLUCION_ERRORES_REQUIRE.md** - Solución a errores de require()

---

## 🎯 RESUMEN

**Total de archivos:**
- 3 ModuleScripts (ReplicatedStorage)
- 5 RemoteEvents (ReplicatedStorage)
- 7 Scripts del servidor (ServerScriptService)
- 6 LocalScripts del cliente (StarterGui + StarterPlayer)
- 3 GUIs para diseñar (PrincipalGui, RebirthGui, OrbNotifications)

**Sistema completamente modular:**
- ✅ Fácil de configurar (OrbConfig, LevelManager)
- ✅ Fácil de extender (añadir nuevos tipos de orbs)
- ✅ Fácil de personalizar (GUIs diseñadas por ti)
- ✅ Robusto (validación servidor-lado, anti-exploit)
- ✅ Optimizado (pool de orbs, auto-guardado)

---

**¿Necesitas más ayuda?** Consulta las guías específicas para cada componente.
