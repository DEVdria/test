# ⚡ CONFIGURACIÓN INICIAL RÁPIDA - 5 MINUTOS

Esta es una guía express para configurar rápidamente el sistema. Para instrucciones detalladas, consulta `GUIA_COMPLETA_INSTALACION.md`.

---

## 🎯 CONFIGURACIÓN BÁSICA DE ZONAS

Abre `ReplicatedStorage > Modules > OrbConfig` y modifica las zonas según la posición de tu mapa:

### Ejemplo de configuración simple:

```lua
-- En OrbConfig.Zones, cambia las posiciones:

{
    Name = "Zone1",
    Position = Vector3.new(0, 5, 0),          -- ← CAMBIA ESTO a la posición de tu zona 1
    Size = Vector3.new(50, 0, 50),            -- Área de 50x50 studs
    SpawnHeight = 5,                          -- ← CAMBIA ESTO según tu terreno
    OrbTypes = {"Yellow", "Green"},           -- Orbs amarillos y verdes
    MaxOrbs = 15,                             -- 15 orbs simultáneos
    RespawnTime = 3                           -- Spawn cada 3 segundos
},
```

### ¿Cómo encontrar la posición correcta?

1. En Roblox Studio, crea una **Part** en el lugar donde quieres la zona
2. Copia su **Position** (Vector3)
3. Pega ese Vector3 en `Position` de la zona
4. **SpawnHeight** debe ser la altura sobre el suelo (prueba con 5-10)

---

## 🎨 VALORES IMPORTANTES QUE PUEDES CAMBIAR

### Velocidad que dan los orbs:

```lua
-- En OrbConfig.OrbTypes:
Yellow = {
    SpeedBonus = 1,        -- ← Cambia esto (velocidad que otorga)
    MoneyReward = 10,      -- ← Cambia esto (dinero que otorga)
}
```

### Precio de rebirths:

```lua
-- En OrbConfig.Rebirth:
BaseCost = 15000,              -- ← Precio del primer rebirth
CostMultiplier = 1.5,          -- ← Cada rebirth cuesta 1.5x más
BaseSpeedMultiplier = 1.1,     -- ← Multiplicador base (1.1 = +10%)
```

### Distancia para recoger orbs:

```lua
-- En OrbConfig.General:
CollectionDistance = 8,        -- ← Distancia en studs para recoger
```

---

## 🚀 INICIO RÁPIDO - 3 PASOS

### PASO 1: Crear estructura básica (2 minutos)

En **ReplicatedStorage**:
```
1. Crea carpeta "RemoteEvents"
   - Añade RemoteEvent: "OrbCollected"
   - Añade RemoteEvent: "RequestRebirthPurchase"
   - Añade RemoteEvent: "UpdateSpeedDisplay"

2. Crea carpeta "Modules"
   - Añade ModuleScript: "OrbConfig" (pega código)
   - Añade ModuleScript: "OrbManager" (pega código)
```

En **ServerScriptService**:
```
Añade 4 Scripts:
- DataManager (pega código)
- OrbGenerator (pega código)
- MoneyManager (pega código)
- RebirthManager (pega código)
```

### PASO 2: Scripts del cliente (1 minuto)

En **StarterPlayer > StarterPlayerScripts**:
```
- Añade LocalScript: "OrbClientManager" (pega código)
```

En **StarterPlayer > StarterCharacterScripts**:
```
- REEMPLAZA el contenido de "Running" (pega código nuevo)
```

### PASO 3: GUI (2 minutos)

En **StarterGui > PrincipalGui > Frame**:
```
1. Añade ImageButton: "Rebirths"
   - Dentro añade LocalScript: "RebirthButtonScript"

2. Añade TextLabel: "SpeedDisplay"
   - En el Frame (no dentro del label) añade LocalScript: "SpeedDisplayScript"
```

En **StarterGui**:
```
1. Crea ScreenGui: "RebirthGui"
   - Enabled = false
   - Dentro crea Frame
     - Añade TextLabel: "Title"
     - Añade TextLabel: "PriceLabel"
     - Añade TextLabel: "MultiplierLabel"
     - Añade TextButton: "PurchaseButton"
     - Añade TextButton: "CloseButton"
     - Añade LocalScript: "RebirthGuiScript"
```

---

## ✅ VERIFICACIÓN RÁPIDA

Presiona **Play** en Roblox Studio y verifica:

1. **No hay errores rojos** en Output
2. **Aparecen zonas azules** en Workspace (carpeta Zones)
3. **Ves orbs flotando** en las zonas
4. **Al tocar un orb:**
   - Desaparece
   - Aumenta tu dinero (leaderstats)
   - Aumenta velocidad en el display
5. **Al presionar Shift:**
   - Corres más rápido
   - La velocidad incluye los orbs recogidos

---

## 🎯 AJUSTES RÁPIDOS COMUNES

### Los orbs están en el aire muy alto:
```lua
SpawnHeight = 5,  // Reduce este número
```

### Los orbs están bajo el suelo:
```lua
SpawnHeight = 15,  // Aumenta este número
```

### Quiero más orbs en la zona:
```lua
MaxOrbs = 30,  // Aumenta este número
```

### Los orbs aparecen muy lento:
```lua
RespawnTime = 1,  // Reduce este número (mínimo 0.5)
```

### Quiero recoger orbs desde más lejos:
```lua
CollectionDistance = 15,  // Aumenta este número
```

### Los rebirths son muy caros:
```lua
BaseCost = 5000,       // Reduce el precio inicial
CostMultiplier = 1.2,  // Reduce el incremento
```

### Los orbs dan muy poca velocidad:
```lua
// En cada tipo de orb, aumenta:
SpeedBonus = 5,  // Aumenta este número
```

---

## 🔧 SI ALGO NO FUNCIONA

### Revisa estos 3 puntos:

1. **Output** - ¿Hay errores rojos? Léelos y verifica nombres
2. **Nombres exactos** - Los RemoteEvents deben tener los nombres EXACTOS
3. **Ubicaciones** - Verifica que cada script esté en su carpeta correcta

### Error común: "attempt to index nil"
- Revisa que los RemoteEvents existan y tengan los nombres correctos
- Verifica que las carpetas Modules y RemoteEvents estén en ReplicatedStorage

### Los orbs no aparecen:
- Abre OrbConfig y ajusta la Position de las zonas
- Verifica que SpawnHeight sea correcto para tu terreno

---

## 📱 CONTACTOS Y ARCHIVOS

- **Guía completa:** `GUIA_COMPLETA_INSTALACION.md`
- **Estructura del proyecto:** `ESTRUCTURA_DEL_PROYECTO.md`
- **Lista de archivos:** `RESUMEN_ARCHIVOS_CODIGO.md`
- **RemoteEvents:** `INSTRUCCIONES_REMOTEEVENTS.md`

---

## 🎉 ¡LISTO!

Si seguiste estos pasos, tu sistema ya debería estar funcionando.

**Recuerda:**
- Ajusta las posiciones de las zonas según tu mapa
- Personaliza los valores en OrbConfig a tu gusto
- Diseña la GUI según tu estilo

¡Disfruta tu sistema de orbs! 🚀
