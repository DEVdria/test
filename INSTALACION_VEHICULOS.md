# 🚗 Sistema de Compra de Vehículos - Guía de Instalación

## 📋 Descripción General

Este sistema permite bloquear vehículos (carros, helicópteros, etc.) descargados de la Toolbox y solo permitir su uso después de que los jugadores los compren con dinero.

**✅ Características:**
- Respeta completamente los scripts originales del creador
- Funciona con cualquier vehículo de la Toolbox
- **Las compras son temporales** (solo duran la sesión actual)
- Los jugadores pueden comprar el mismo vehículo múltiples veces
- Sistema de ProximityPrompt para comprar
- Bloquea asientos automáticamente

---

## 📁 Archivos del Sistema

### 1. **VehicleOwnershipManager.lua**
- **Ubicación:** `ServerScriptService`
- **Función:** Gestiona las compras y la propiedad de vehículos
- **¡YA ESTÁ INSTALADO!** ✅

### 2. **VehicleLocker.lua**
- **Ubicación:** Dentro de cada vehículo (como Script hijo del modelo)
- **Función:** Bloquea el uso del vehículo hasta que se compre

### 3. **VehiclePurchasePrompt.lua**
- **Ubicación:** Dentro de cada vehículo (como Script hijo del modelo)
- **Función:** Crea el ProximityPrompt para comprar

---

## 🛠️ Instalación Paso a Paso

### Paso 1: Descargar el Vehículo de la Toolbox

1. Ve a la **Toolbox** en Roblox Studio
2. Busca el vehículo que quieras (ej: "Car", "Helicopter")
3. **Inserta el modelo** en el Workspace
4. El modelo debería tener scripts internos del creador (NO los toques)

---

### Paso 2: Añadir VehicleLocker al Vehículo

1. Selecciona el **modelo del vehículo** en el Workspace
   - Debe ser el Model principal (no una Part interna)

2. Click derecho en el modelo → **Insert Object** → **Script**

3. Renombra el script a **"VehicleLocker"**

4. Abre el script y **pega el código de `VehicleLocker.lua`**
   - El código está en tu carpeta de proyecto

5. **IMPORTANTE:** Configura estas variables al inicio del script:
   ```lua
   local VEHICLE_NAME = "Carro"  -- Cambia esto al nombre de tu vehículo
   local LOCK_MESSAGE_ENABLED = true
   ```

   **Ejemplos:**
   - Para un carro: `VEHICLE_NAME = "Carro"`
   - Para un helicóptero: `VEHICLE_NAME = "Helicoptero"`
   - Para una moto: `VEHICLE_NAME = "Moto"`

---

### Paso 3: Añadir VehiclePurchasePrompt al Vehículo

1. Selecciona el **mismo modelo del vehículo** en el Workspace

2. Click derecho en el modelo → **Insert Object** → **Script**

3. Renombra el script a **"VehiclePurchasePrompt"**

4. Abre el script y **pega el código de `VehiclePurchasePrompt.lua`**

5. **IMPORTANTE:** Configura estas variables:
   ```lua
   local VEHICLE_NAME = "Carro"      -- DEBE ser IDÉNTICO al VehicleLocker
   local VEHICLE_PRICE = 1000        -- Precio en dinero
   local PROMPT_ICON = "🚗"          -- Icono (🚗 para carro, 🚁 para helicóptero)
   ```

   **Ejemplos de configuración:**

   **Para un carro:**
   ```lua
   local VEHICLE_NAME = "Carro"
   local VEHICLE_PRICE = 1000
   local PROMPT_ICON = "🚗"
   ```

   **Para un helicóptero:**
   ```lua
   local VEHICLE_NAME = "Helicoptero"
   local VEHICLE_PRICE = 5000
   local PROMPT_ICON = "🚁"
   ```

---

### Paso 4: Verificar Instalación

Tu vehículo debería verse así en el Explorador:

```
Workspace
└── TuVehiculo (Model)
    ├── VehicleLocker (Script) ← NUEVO
    ├── VehiclePurchasePrompt (Script) ← NUEVO
    ├── Seat (VehicleSeat) ← Del creador original
    ├── Body (Part) ← Del creador original
    └── [Otros scripts y parts del creador] ← NO TOCAR
```

---

## 🧪 Pruebas

### 1. Ejecuta el juego (F5)

### 2. Acércate al vehículo
   - Deberías ver un **ProximityPrompt** que dice:
   - `🚗 Carro`
   - `Comprar ($1000)`

### 3. Intenta sentarte en el vehículo SIN comprarlo
   - Te debería **expulsar** del asiento
   - Deberías ver un mensaje: `🔒 Debes comprar Carro para usarlo`

### 4. Compra el vehículo
   - Presiona E en el ProximityPrompt
   - Si tienes suficiente dinero, se restará y verás:
   - `🚗 ¡Compraste Carro!`

### 5. Ahora siéntate en el vehículo
   - Deberías poder usarlo normalmente
   - Los scripts originales del creador funcionarán

---

## 🔧 Configuración Avanzada

### Cambiar el precio de un vehículo

Abre **VehiclePurchasePrompt** dentro del vehículo:
```lua
local VEHICLE_PRICE = 5000  -- Cambia este número
```

### Deshabilitar el mensaje de bloqueo

Abre **VehicleLocker** dentro del vehículo:
```lua
local LOCK_MESSAGE_ENABLED = false  -- Cambia a false
```

### Añadir más vehículos

Repite los **Pasos 2 y 3** para cada vehículo nuevo:
1. Descarga el vehículo de la Toolbox
2. Añade VehicleLocker
3. Añade VehiclePurchasePrompt
4. Configura el nombre y precio únicos

**IMPORTANTE:** Cada vehículo debe tener un `VEHICLE_NAME` único.

---

## 🎮 Iconos Recomendados

| Vehículo | Icono | Código |
|----------|-------|--------|
| Carro | 🚗 | `"🚗"` |
| Helicóptero | 🚁 | `"🚁"` |
| Avión | ✈️ | `"✈️"` |
| Moto | 🏍️ | `"🏍️"` |
| Barco | 🚤 | `"🚤"` |
| Tanque | 🚜 | `"🚜"` |
| Camión | 🚚 | `"🚚"` |

---

## ❓ Preguntas Frecuentes

### ¿Puedo usar vehículos con scripts complicados?

**Sí.** Este sistema NO modifica los scripts originales. Solo añade una capa de bloqueo encima.

### ¿Funciona con vehículos gratis de la Toolbox?

**Sí.** Funciona con cualquier vehículo, incluso los que tienen muchos scripts internos.

### ¿Las compras se guardan si el jugador sale?

**NO.** Las compras son temporales y solo duran la sesión actual. Si el jugador sale del servidor, pierde el acceso al vehículo y debe volver a comprarlo.

### ¿Qué pasa si el vehículo no tiene PrimaryPart?

El sistema automáticamente busca la primera Part del modelo para colocar el ProximityPrompt.

### ¿Puedo tener varios vehículos del mismo tipo?

Sí, pero todos compartirán el mismo `VEHICLE_NAME`. Si compras uno, puedes usar todos los que tengan ese nombre.

Si quieres vehículos individuales, usa nombres diferentes:
- `"Carro1"`, `"Carro2"`, etc.

---

## 🐛 Solución de Problemas

### El ProximityPrompt no aparece

1. Verifica que **VehiclePurchasePrompt** esté como hijo del Model
2. Verifica que el vehículo tenga al menos una Part
3. Revisa la consola (F9) para ver errores

### Me expulsa del asiento incluso después de comprar

1. Verifica que `VEHICLE_NAME` sea IDÉNTICO en ambos scripts
2. Asegúrate de que VehicleOwnershipManager.lua esté en ServerScriptService
3. Revisa la consola (F9)

### El vehículo no se mueve

Este sistema NO afecta el funcionamiento del vehículo. Si no se mueve, es un problema con los scripts originales del creador, no con este sistema.

---

## 📝 Notas Importantes

✅ **NO modifiques** los scripts originales del creador del vehículo
✅ **Siempre** usa el mismo `VEHICLE_NAME` en VehicleLocker y VehiclePurchasePrompt
✅ **Reinicia** el juego después de hacer cambios para probar
✅ El sistema **respeta** completamente los scripts originales

---

## 🎉 ¡Todo Listo!

Tu sistema de compra de vehículos está instalado. Los jugadores ahora deben comprar los vehículos antes de usarlos.

¿Necesitas ayuda? Revisa la sección de Solución de Problemas o contacta al desarrollador.
