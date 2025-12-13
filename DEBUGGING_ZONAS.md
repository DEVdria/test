# 🔧 GUÍA DE DEBUGGING - Problema de Sincronización de Zonas

## ❌ PROBLEMA ACTUAL

Las zonas no se sincronizan al entrar al juego:
- Cliente muestra todas las zonas como "no owned" (0 zonas poseídas)
- Servidor tiene las zonas correctas (da error "ya posees esta zona")
- Cliente nunca recibe datos del servidor

---

## 🔍 PASO 1: VERIFICAR REMOTEEVENT

**CRÍTICO:** Verifica que existe el RemoteEvent `UpdateZoneOwnership`

### En Roblox Studio:

1. Ve a `ReplicatedStorage > RemoteEvents`
2. Busca un RemoteEvent llamado **UpdateZoneOwnership**
3. Si NO existe:
   - Clic derecho en `RemoteEvents`
   - Insert Object → **RemoteEvent**
   - Renombrar a: **UpdateZoneOwnership** (exacto, sin espacios)

### Verificación en Output:

Al iniciar el juego, debes ver en el **servidor**:
```
[ZoneManager] ✅ RemoteEvents encontrados
[ZoneManager] ✅ Sistema de zonas inicializado
```

Si ves:
```
[ZoneManager] ❌ No se encontró RemoteEvent 'UpdateZoneOwnership'
```
**→ El RemoteEvent no existe, créalo!**

---

## 🔍 PASO 2: VERIFICAR LOGS DEL SERVIDOR

Al entrar al juego, en el **Output del servidor** (NO cliente) debes ver:

```
[ZoneManager] 👤 Jugador conectado: TuNombre
[ZoneManager] ✅ Leaderstats encontrados para TuNombre
[ZoneManager] 📦 Zonas para TuNombre: 3 zonas
[ZoneManager] Lista de zonas: Way1, Zone1, Zone2
[ZoneManager] 📤 Enviando 3 zonas a TuNombre...
[ZoneManager] ✅ Zona 1/3 enviada: Way1
[ZoneManager] ✅ Zona 2/3 enviada: Zone1
[ZoneManager] ✅ Zona 3/3 enviada: Zone2
[ZoneManager] ✅ ZONES_LOADED enviado a TuNombre
```

### Si NO ves estos logs:

**Posibles causas:**
1. ZoneManager no se está ejecutando
   - Verifica que existe en `ServerScriptService`
   - Verifica que es un **Script** (NO LocalScript)

2. DataManager no cargó los datos
   - Busca logs de DataManager en Output

3. Hay un error en ZoneManager
   - Revisa Output por errores en rojo

---

## 🔍 PASO 3: VERIFICAR LOGS DEL CLIENTE

Al entrar al juego, en el **Output del cliente** debes ver:

```
[ZoneClientManager] ✅ Sistema de zonas del cliente cargado
[ZoneClientManager] ⏳ Esperando datos del servidor...
[ZoneClientManager] ⏳ Esperando carga del juego...
[ZoneClientManager] ✅ Leaderstats cargados
[ZoneClientManager] ⏳ Esperando señal ZONES_LOADED del servidor...
[ZoneClientManager] ➕ Zona añadida: Way1 (Total: 1)
[ZoneClientManager] ➕ Zona añadida: Zone1 (Total: 2)
[ZoneClientManager] ➕ Zona añadida: Zone2 (Total: 3)
[ZoneClientManager] ✅ Todas las zonas cargadas del servidor (Total: 3)
[ZoneClientManager] Inicializando zonas... (Zonas poseídas: 3)
```

### Si ves "Zonas poseídas: 0":

**→ El cliente NO está recibiendo datos del servidor**

Verifica:
1. ¿Existe el RemoteEvent UpdateZoneOwnership?
2. ¿El servidor muestra los logs de envío?
3. ¿Hay errores en Output?

---

## 🔍 PASO 4: VERIFICAR DATASTORE

Si el servidor dice "0 zonas" para el jugador:

1. Ve a `ServerScriptService > DataManager`
2. Busca la línea: `local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_V2")`
3. Verifica que dice `"PlayerData_V2"` (con V2)

Si tenías datos guardados con `"PlayerData_V1"`:
- Tus datos viejos están en V1
- Necesitas migrar o empezar de nuevo

---

## 🔧 SOLUCIONES COMUNES

### Solución 1: Recrear RemoteEvent

1. Elimina el RemoteEvent `UpdateZoneOwnership` si existe
2. Insert Object → RemoteEvent
3. Renombrar exactamente a: `UpdateZoneOwnership`
4. Reinicia el juego

### Solución 2: Verificar que ZoneManager está activo

En `ServerScriptService`, verifica:
- Existe `ZoneManager` (Script)
- Es un **Script** (icono azul con rayo)
- NO es un LocalScript (icono azul con persona)
- Está habilitado (no tiene X roja)

### Solución 3: Limpiar DataStore para testing

**ADVERTENCIA:** Esto borra todos los datos guardados

En `ServerScriptService > DataManager`, línea 19, cambia:
```lua
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_V3")  -- Cambiar a V3
```

Esto creará un DataStore nuevo y empezarás con datos frescos.

---

## 📊 COMPARAR TUS LOGS

### ✅ CORRECTO:

**Servidor:**
```
[ZoneManager] 👤 Jugador conectado: Player1
[ZoneManager] ✅ Leaderstats encontrados para Player1
[ZoneManager] 📦 Zonas para Player1: 3 zonas
[ZoneManager] 📤 Enviando 3 zonas a Player1...
[ZoneManager] ✅ Zona 1/3 enviada: Way1
[ZoneManager] ✅ ZONES_LOADED enviado a Player1
```

**Cliente:**
```
[ZoneClientManager] ✅ Leaderstats cargados
[ZoneClientManager] ➕ Zona añadida: Way1 (Total: 1)
[ZoneClientManager] ✅ Todas las zonas cargadas del servidor (Total: 3)
```

### ❌ INCORRECTO (tu caso actual):

**Servidor:**
- NO hay logs de ZoneManager

**Cliente:**
```
[ZoneClientManager] ⏳ Esperando... (2.0/15.0 segundos, zonas recibidas: 0)
[ZoneClientManager] ⏳ Esperando... (4.0/15.0 segundos, zonas recibidas: 0)
[ZoneClientManager] ⚠️ No se recibió señal ZONES_LOADED después de 15 segundos
[ZoneClientManager] Inicializando zonas... (Zonas poseídas: 0)
```

---

## 🎯 CHECKLIST COMPLETO

Verifica cada item:

### ReplicatedStorage
- [ ] Carpeta `RemoteEvents` existe
- [ ] RemoteEvent `UpdateZoneOwnership` existe (exacto)
- [ ] RemoteEvent `RequestZonePurchase` existe (exacto)

### ServerScriptService
- [ ] Script `ZoneManager` existe
- [ ] Script `DataManager` existe
- [ ] Ambos son **Scripts** (NO LocalScripts)

### ReplicatedStorage/Modules
- [ ] ModuleScript `ZoneConfig` existe

### Workspace
- [ ] Carpeta `Buy Zones` existe
- [ ] Contiene Parts con nombres de zonas (Way1, Zone1, etc.)

### Output al iniciar (Servidor)
- [ ] `[ZoneManager] ✅ Sistema de zonas inicializado`
- [ ] `[ZoneManager] 👤 Jugador conectado: ...`
- [ ] `[ZoneManager] 📤 Enviando X zonas a ...`

### Output al iniciar (Cliente)
- [ ] `[ZoneClientManager] ✅ Sistema de zonas del cliente cargado`
- [ ] `[ZoneClientManager] ➕ Zona añadida: ...`
- [ ] `[ZoneClientManager] ✅ Todas las zonas cargadas del servidor`

---

## 💡 SIGUIENTE PASO

**Envíame el Output COMPLETO del servidor** cuando entres al juego, especialmente:
- Cualquier log que empiece con `[ZoneManager]`
- Cualquier log que empiece con `[DataManager]`
- Cualquier error en rojo

Esto me ayudará a identificar exactamente dónde está fallando el sistema.
