# 🚨 GUÍA DE SOLUCIÓN DE ERRORES

## ERROR 1: "Attempted to call require with invalid argument(s)"

Este error significa que los módulos **OrbConfig** y **OrbManager** no están en la ubicación correcta.

### ✅ SOLUCIÓN:

1. **Verifica que en ReplicatedStorage tengas:**
   ```
   ReplicatedStorage
   ├── Modules (Folder)
   │   ├── OrbConfig (ModuleScript)
   │   └── OrbManager (ModuleScript)
   └── RemoteEvents (Folder)
       ├── OrbCollected (RemoteEvent)
       ├── RequestRebirthPurchase (RemoteEvent)
       └── UpdateSpeedDisplay (RemoteEvent)
   ```

2. **Los nombres deben ser EXACTOS:**
   - La carpeta debe llamarse exactamente `Modules` (con M mayúscula)
   - Los scripts deben ser `OrbConfig` y `OrbManager` (respetando mayúsculas)

---

## ERROR 2: Zonas no tienen tipos de orbs definidos

Las zonas se crean automáticamente pero **necesitan atributos configurados**.

### ✅ SOLUCIÓN OPCIÓN 1 (Automática):

Usa este script temporal para configurar las zonas. Crea un **Script** en **ServerScriptService** llamado `ConfigureZones`:

```lua
-- ServerScriptService > ConfigureZones (Script temporal)
-- Ejecuta este script UNA VEZ para configurar las zonas

local Workspace = game:GetService("Workspace")

-- Esperar a que las zonas existan
task.wait(2)

local zonesFolder = Workspace:WaitForChild("Zones", 10)

if zonesFolder then
    -- Configurar Zone1
    local zone1 = zonesFolder:FindFirstChild("Zone1")
    if zone1 then
        zone1:SetAttribute("ZoneName", "Zone1")
        zone1:SetAttribute("OrbTypes", "Yellow,Green")
        zone1:SetAttribute("MaxOrbs", 15)
        zone1:SetAttribute("SpawnHeight", 10)
        print("✅ Zone1 configurada")
    end

    -- Configurar Zone2
    local zone2 = zonesFolder:FindFirstChild("Zone2")
    if zone2 then
        zone2:SetAttribute("ZoneName", "Zone2")
        zone2:SetAttribute("OrbTypes", "Green,Blue")
        zone2:SetAttribute("MaxOrbs", 12)
        zone2:SetAttribute("SpawnHeight", 10)
        print("✅ Zone2 configurada")
    end

    print("✅ Zonas configuradas correctamente")
else
    warn("❌ No se encontró la carpeta Zones")
end
```

**Después de ejecutar este script UNA VEZ, puedes eliminarlo.**

### ✅ SOLUCIÓN OPCIÓN 2 (Manual):

1. Ejecuta el juego una vez para que se creen las zonas
2. Detén el juego
3. En **Workspace > Zones**, verás Zone1 y Zone2
4. Selecciona **Zone1** y en Properties añade estos **Attributes**:
   - `OrbTypes` (String): `Yellow,Green`
   - `MaxOrbs` (Number): `15`
   - `SpawnHeight` (Number): `10`

5. Selecciona **Zone2** y añade:
   - `OrbTypes` (String): `Green,Blue`
   - `MaxOrbs` (Number): `12`
   - `SpawnHeight` (Number): `10`

---

## ERROR 3: Leaderstats no aparecen

Esto es porque **DataManager no se está ejecutando** por el error de require.

### ✅ SOLUCIÓN:

Una vez que arregles el ERROR 1 (módulos), las leaderstats aparecerán automáticamente.

---

## 🔍 CHECKLIST COMPLETO DE VERIFICACIÓN

### Paso 1: Verificar ReplicatedStorage

- [ ] Existe la carpeta `Modules`
- [ ] Dentro de Modules hay un `ModuleScript` llamado `OrbConfig`
- [ ] Dentro de Modules hay un `ModuleScript` llamado `OrbManager`
- [ ] Existe la carpeta `RemoteEvents`
- [ ] Dentro de RemoteEvents hay 3 `RemoteEvent`: `OrbCollected`, `RequestRebirthPurchase`, `UpdateSpeedDisplay`

### Paso 2: Verificar el código de los módulos

**OrbConfig debe empezar con:**
```lua
-- ReplicatedStorage > Modules > OrbConfig
local OrbConfig = {}
...
return OrbConfig
```

**OrbManager debe empezar con:**
```lua
-- ReplicatedStorage > Modules > OrbManager
local OrbManager = {}
...
return OrbManager
```

### Paso 3: Verificar ServerScriptService

- [ ] Hay un `Script` llamado `DataManager`
- [ ] Hay un `Script` llamado `OrbGenerator`
- [ ] Hay un `Script` llamado `MoneyManager`
- [ ] Hay un `Script` llamado `RebirthManager`

### Paso 4: Configurar las zonas

Usa una de las dos opciones de arriba.

---

## 🎯 ORDEN DE EJECUCIÓN CORRECTO

1. **PRIMERO:** Crea la carpeta Modules en ReplicatedStorage
2. **SEGUNDO:** Crea los ModuleScripts OrbConfig y OrbManager dentro
3. **TERCERO:** Pega el código en cada módulo
4. **CUARTO:** Crea la carpeta RemoteEvents y los 3 RemoteEvent
5. **QUINTO:** Crea los scripts del servidor
6. **SEXTO:** Ejecuta el juego UNA VEZ
7. **SÉPTIMO:** Usa el script ConfigureZones para configurar las zonas
8. **OCTAVO:** Vuelve a ejecutar el juego

---

## 🛠️ SI TODAVÍA HAY ERRORES

Si después de seguir estos pasos aún tienes errores, verifica:

1. **Output debe mostrar:**
   ```
   ✅ Zone1 configurada
   ✅ Zone2 configurada
   ✅ Zonas configuradas correctamente
   [OrbGenerator] Sistema de orbs iniciado
   [OrbClient] Sistema de orbs del cliente iniciado
   ```

2. **NO debe mostrar:**
   - "Attempted to call require..."
   - "Zona Zone1 no tiene tipos de orbs definidos"

---

## 📸 CAPTURA DE CÓMO DEBE VERSE

### ReplicatedStorage debe verse así:
```
ReplicatedStorage
├── 📁 Modules
│   ├── 📜 OrbConfig (ModuleScript con ícono de engranaje)
│   └── 📜 OrbManager (ModuleScript con ícono de engranaje)
└── 📁 RemoteEvents
    ├── 📡 OrbCollected
    ├── 📡 RequestRebirthPurchase
    └── 📡 UpdateSpeedDisplay
```

### ServerScriptService debe verse así:
```
ServerScriptService
├── 📜 DataManager (Script con ícono de papel)
├── 📜 OrbGenerator (Script con ícono de papel)
├── 📜 MoneyManager (Script con ícono de papel)
└── 📜 RebirthManager (Script con ícono de papel)
```

---

## ⚠️ ERRORES COMUNES

### ❌ Error: Creaste "OrbConfig" como Script en lugar de ModuleScript
**✅ Solución:** Elimínalo y créalo como ModuleScript

### ❌ Error: Los módulos están en ReplicatedStorage directamente (sin carpeta Modules)
**✅ Solución:** Crea la carpeta Modules y muévelos dentro

### ❌ Error: La carpeta se llama "modules" (minúscula) en lugar de "Modules"
**✅ Solución:** Renombra a "Modules" con M mayúscula

### ❌ Error: Los RemoteEvents están como RemoteFunction
**✅ Solución:** Elimínalos y créalos como RemoteEvent

---

Sigue estos pasos y los errores se solucionarán. ¡Avísame si necesitas más ayuda!
