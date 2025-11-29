# 🎮 GUÍA COMPLETA DE INSTALACIÓN - SISTEMA DE ORBS DE VELOCIDAD

## 📋 ÍNDICE
1. [Requisitos Previos](#requisitos-previos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Configuración de Zonas](#configuración-de-zonas)
5. [Configuración de GUI](#configuración-de-gui)
6. [Pruebas y Verificación](#pruebas-y-verificación)
7. [Personalización](#personalización)
8. [Solución de Problemas](#solución-de-problemas)

---

## 🔧 REQUISITOS PREVIOS

Antes de empezar, asegúrate de tener:

- ✅ Roblox Studio instalado
- ✅ Tu sistema de running ya funcionando (con animaciones Sprint y Jump)
- ✅ Las carpetas workspace/FX y ReplicatedStorage/VFX/Dust existentes
- ✅ Tu GUI PrincipalGui ya creada

---

## 📁 ESTRUCTURA DEL PROYECTO

```
ReplicatedStorage/
├── RemoteEvents/ (Folder) - CREAR
│   ├── OrbCollected (RemoteEvent)
│   ├── RequestRebirthPurchase (RemoteEvent)
│   └── UpdateSpeedDisplay (RemoteEvent)
├── Modules/ (Folder) - CREAR
│   ├── OrbConfig (ModuleScript)
│   └── OrbManager (ModuleScript)
└── VFX/ - YA EXISTE
    └── Dust

ServerScriptService/
├── DataManager (Script)
├── OrbGenerator (Script)
├── MoneyManager (Script)
└── RebirthManager (Script)

StarterPlayer/
├── StarterPlayerScripts/
│   └── OrbClientManager (LocalScript)
└── StarterCharacterScripts/
    ├── Running (LocalScript) - REEMPLAZAR
    ├── Sprint (Animation) - YA EXISTE
    └── Jump (Animation) - YA EXISTE

StarterGui/
├── PrincipalGui/ - YA EXISTE
│   └── Frame/
│       ├── Cash (ImageButton) - YA EXISTE
│       ├── Invite (ImageButton) - YA EXISTE
│       ├── Shop (ImageButton) - YA EXISTE
│       ├── Rebirths (ImageButton) - AÑADIR
│       │   └── RebirthButtonScript (LocalScript)
│       ├── SpeedDisplay (TextLabel) - AÑADIR
│       └── SpeedDisplayScript (LocalScript) - AÑADIR
└── RebirthGui/ - CREAR NUEVA
    └── Frame/
        ├── Title (TextLabel)
        ├── PriceLabel (TextLabel)
        ├── MultiplierLabel (TextLabel)
        ├── PurchaseButton (TextButton)
        ├── CloseButton (TextButton)
        └── RebirthGuiScript (LocalScript)

Workspace/
├── FX/ (Folder) - YA EXISTE
├── OrbsFolder/ (Folder) - Se crea automáticamente
└── Zones/ (Folder) - Se crea automáticamente
```

---

## 🚀 INSTALACIÓN PASO A PASO

### PASO 1: Crear RemoteEvents

1. En **ReplicatedStorage**, crea una carpeta llamada `RemoteEvents`
2. Dentro de esta carpeta, crea 3 **RemoteEvent**:
   - `OrbCollected`
   - `RequestRebirthPurchase`
   - `UpdateSpeedDisplay`

### PASO 2: Crear Módulos

1. En **ReplicatedStorage**, crea una carpeta llamada `Modules`
2. Dentro de esta carpeta, crea 2 **ModuleScript**:
   - `OrbConfig` → Pega el código de `ReplicatedStorage_Modules_OrbConfig.lua`
   - `OrbManager` → Pega el código de `ReplicatedStorage_Modules_OrbManager.lua`

### PASO 3: Crear Scripts del Servidor

En **ServerScriptService**, crea 4 **Script** normales (NO LocalScript):

1. `DataManager` → Pega el código de `ServerScriptService_DataManager.lua`
2. `OrbGenerator` → Pega el código de `ServerScriptService_OrbGenerator.lua`
3. `MoneyManager` → Pega el código de `ServerScriptService_MoneyManager.lua`
4. `RebirthManager` → Pega el código de `ServerScriptService_RebirthManager.lua`

### PASO 4: Crear Scripts del Cliente

#### A) En StarterPlayerScripts:
1. Crea un **LocalScript** llamado `OrbClientManager`
2. Pega el código de `StarterPlayer_StarterPlayerScripts_OrbClientManager.lua`

#### B) En StarterCharacterScripts:
1. **REEMPLAZA** el contenido de tu LocalScript `Running` existente
2. Pega el código de `StarterPlayer_StarterCharacterScripts_Running.lua`
3. Asegúrate de que las animaciones Sprint y Jump sigan dentro del script Running

### PASO 5: Configurar GUI Principal (PrincipalGui)

1. En **StarterGui > PrincipalGui > Frame**:

#### A) Añadir Botón de Rebirths:
   - Crea un **ImageButton** llamado `Rebirths`
   - Diseña el botón como prefieras (imagen, color, tamaño)
   - Dentro de este botón, crea un **LocalScript** llamado `RebirthButtonScript`
   - Pega el código de `StarterGui_PrincipalGui_Frame_Rebirths_RebirthButtonScript.lua`

#### B) Añadir Display de Velocidad:
   - Crea un **TextLabel** llamado `SpeedDisplay`
   - Diseña el label como prefieras (fuente, color, posición)
   - En el Frame (NO dentro del TextLabel), crea un **LocalScript** llamado `SpeedDisplayScript`
   - Pega el código de `StarterGui_PrincipalGui_Frame_SpeedDisplayScript.lua`

### PASO 6: Crear GUI de Rebirths

1. En **StarterGui**, crea un **ScreenGui** llamado `RebirthGui`
2. Configura la propiedad `Enabled` de RebirthGui a **false** (empieza oculto)
3. Dentro de RebirthGui, crea un **Frame**
4. Dentro del Frame, crea los siguientes elementos:

   - **Title** (TextLabel) - Título de la GUI
   - **PriceLabel** (TextLabel) - Muestra el precio
   - **MultiplierLabel** (TextLabel) - Muestra multiplicadores
   - **PurchaseButton** (TextButton) - Botón de compra
   - **CloseButton** (TextButton) - Botón para cerrar
   - **RebirthGuiScript** (LocalScript) - Pega el código de `StarterGui_RebirthGui_Frame_RebirthGuiScript.lua`

**Diseño sugerido de RebirthGui:**
```
Frame (centrado, tamaño: {0.4, 0},{0.5, 0})
├── Title - Posición arriba
├── PriceLabel - Debajo del título
├── MultiplierLabel - Debajo del precio
├── PurchaseButton - Centro inferior
└── CloseButton - Esquina superior derecha
```

---

## 🗺️ CONFIGURACIÓN DE ZONAS

Las zonas se configuran en el archivo `OrbConfig` (ReplicatedStorage > Modules > OrbConfig).

### Configuración Actual (Predeterminada):

```lua
OrbConfig.Zones = {
    {
        Name = "Zone1",
        Position = Vector3.new(0, 10, 0),        -- Centro de la zona
        Size = Vector3.new(50, 0, 50),           -- 50x50 studs
        SpawnHeight = 10,                        -- Altura de spawn
        OrbTypes = {"Yellow", "Green"},          -- Tipos de orbs
        MaxOrbs = 15,                            -- Máximo simultáneo
        RespawnTime = 3                          -- Tiempo entre spawns
    },
    {
        Name = "Zone2",
        Position = Vector3.new(100, 10, 0),
        Size = Vector3.new(50, 0, 50),
        SpawnHeight = 10,
        OrbTypes = {"Green", "Blue"},
        MaxOrbs = 12,
        RespawnTime = 4
    },
}
```

### Para Añadir Más Zonas:

Copia y pega este bloque dentro de `OrbConfig.Zones`:

```lua
{
    Name = "Zone3",                              -- Nombre único
    Position = Vector3.new(X, Y, Z),             -- Posición en el mundo
    Size = Vector3.new(AnchuraX, 0, AnchuraZ),   -- Tamaño del área
    SpawnHeight = 15,                            -- Altura fija de spawn
    OrbTypes = {"Yellow", "Blue"},               -- Tipos permitidos
    MaxOrbs = 10,                                -- Cantidad máxima
    RespawnTime = 5                              -- Segundos entre spawns
},
```

### Añadir Nuevos Tipos de Orbs:

En `OrbConfig.OrbTypes`, añade:

```lua
Purple = {
    Name = "Purple",
    SpeedBonus = 5,                              -- Velocidad que otorga
    MoneyReward = 100,                           -- Dinero que otorga
    Color = Color3.fromRGB(150, 0, 255),         -- Color RGB
    Size = Vector3.new(3, 3, 3),                 -- Tamaño
    Material = Enum.Material.Neon,
    Transparency = 0.2,
    ParticleColor = ColorSequence.new(Color3.fromRGB(150, 0, 255))
},
```

---

## 🎨 CONFIGURACIÓN DE GUI

### SpeedDisplay (TextLabel)

Propiedades sugeridas:
- **Text:** "Velocidad: +0"
- **TextScaled:** true
- **BackgroundTransparency:** 0.5
- **Position/Size:** Según tu diseño

### RebirthGui

Configura el estilo según tu diseño. El script maneja automáticamente:
- Actualización de precios
- Verificación de dinero suficiente
- Cambios de color del botón
- Mensajes de error/éxito

---

## ✅ PRUEBAS Y VERIFICACIÓN

### Checklist de Pruebas:

1. **Inicio del Juego:**
   - [ ] No hay errores en Output
   - [ ] Aparecen zonas visuales en Workspace
   - [ ] Se crean leaderstats (Money, Rebirths)

2. **Sistema de Orbs:**
   - [ ] Los orbs aparecen en las zonas correctas
   - [ ] Solo tú ves tus orbs (prueba con 2 jugadores)
   - [ ] Al tocar un orb desaparece
   - [ ] El contador de velocidad aumenta
   - [ ] Recibes dinero al recoger orbs

3. **Sistema de Running:**
   - [ ] Al presionar Shift corres más rápido
   - [ ] La velocidad incluye la acumulada de orbs
   - [ ] Las animaciones funcionan correctamente

4. **Sistema de Rebirths:**
   - [ ] El botón Rebirths abre la GUI
   - [ ] La información se actualiza correctamente
   - [ ] Puedes comprar un rebirth si tienes dinero
   - [ ] La velocidad se resetea después del rebirth
   - [ ] El multiplicador aumenta

5. **Persistencia de Datos:**
   - [ ] Sal del juego y vuelve a entrar
   - [ ] Tus datos se guardan (dinero, rebirths, velocidad)

---

## 🎯 PERSONALIZACIÓN

### Cambiar Velocidades de Orbs:

En `OrbConfig.OrbTypes`, modifica `SpeedBonus`:
```lua
Yellow = {
    SpeedBonus = 2,  -- Cambia de 1 a 2
    ...
}
```

### Cambiar Precios de Rebirths:

En `OrbConfig.Rebirth`:
```lua
BaseCost = 20000,              -- Primer rebirth: $20,000
CostMultiplier = 2,            -- Cada rebirth cuesta el doble
BaseSpeedMultiplier = 1.2,     -- +20% por rebirth
```

### Cambiar Colores de Orbs:

En `OrbConfig.OrbTypes`, modifica `Color`:
```lua
Color = Color3.fromRGB(R, G, B),
```

### Cambiar Distancia de Recolección:

En `OrbConfig.General`:
```lua
CollectionDistance = 10,  -- Aumentar de 8 a 10 studs
```

---

## 🛠️ SOLUCIÓN DE PROBLEMAS

### Los orbs no aparecen:
- ✅ Verifica que OrbGenerator esté en ServerScriptService
- ✅ Revisa Output por errores
- ✅ Asegúrate de que las zonas estén configuradas en OrbConfig

### No se guarda la velocidad:
- ✅ Verifica que DataManager esté en ServerScriptService
- ✅ Asegúrate de tener DataStore habilitado (Game Settings > Security)
- ✅ Revisa Output por errores de DataStore

### El botón de rebirth no funciona:
- ✅ Verifica que RebirthButtonScript esté dentro del ImageButton Rebirths
- ✅ Asegúrate de que RebirthGui exista en StarterGui
- ✅ Revisa que los nombres sean exactos (mayúsculas/minúsculas)

### La velocidad no se aplica al correr:
- ✅ Verifica que reemplazaste el script Running completo
- ✅ Asegúrate de que UpdateSpeedDisplay esté en RemoteEvents
- ✅ Revisa que las animaciones Sprint y Jump estén dentro del script Running

### Errores de "attempt to index nil":
- ✅ Verifica que todos los RemoteEvents estén creados correctamente
- ✅ Asegúrate de que los nombres sean exactos
- ✅ Revisa que las carpetas Modules y RemoteEvents existan en ReplicatedStorage

### Los orbs atraviesan el suelo:
- ✅ Ajusta SpawnHeight en la configuración de zonas
- ✅ Asegúrate de que la altura sea apropiada para tu terreno

---

## 📞 SOPORTE ADICIONAL

Si tienes problemas:
1. Revisa el **Output** en Roblox Studio para ver errores específicos
2. Verifica que todos los nombres coincidan exactamente (mayúsculas/minúsculas)
3. Asegúrate de haber completado todos los pasos de instalación
4. Prueba en modo de juego local primero antes de publicar

---

## 🎉 CARACTERÍSTICAS IMPLEMENTADAS

✅ **Sistema de Orbs:**
- Orbs solo visibles para cada cliente
- 3 tipos de orbs (Amarillo, Verde, Azul) con diferentes bonificaciones
- Sistema de zonas con spawns aleatorios
- Efectos visuales y de partículas
- Persistencia de datos

✅ **Sistema de Running:**
- Integración completa con velocidad acumulada
- Efectos visuales (polvo, líneas)
- Soporte móvil y PC
- Animaciones suaves

✅ **Sistema de Dinero:**
- Leaderstats automáticas
- Recompensas por orbs
- Guardado automático

✅ **Sistema de Rebirths:**
- GUI personalizable
- Multiplicadores de velocidad
- Sistema de costos escalables
- Validación servidor-side

✅ **Seguridad:**
- Validaciones anti-exploit
- Cooldowns anti-spam
- Procesamiento servidor-side
- Datos encriptados en DataStore

---

## 📝 NOTAS FINALES

- El sistema está **completamente optimizado** y sin warnings
- **Seguro** contra exploits comunes
- **Escalable** - fácil de añadir más tipos de orbs y zonas
- **Personalizable** - todos los valores en archivos de configuración
- **Sin código omitido** - sistema completo y funcional

¡Disfruta tu sistema de orbs de velocidad! 🚀
