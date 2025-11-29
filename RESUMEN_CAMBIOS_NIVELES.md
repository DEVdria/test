# 🎯 RESUMEN: Sistema de Niveles y Experiencia

## ✅ ARCHIVOS YA CREADOS/MODIFICADOS

### 📘 Módulos Nuevos (ReplicatedStorage/Modules)
1. **LevelManager.lua** ✅ NUEVO
   - Sistema completo de niveles y velocidades
   - Tabla de Level Caps basada en Rebirths
   - Totalmente editable y modular

### 📝 Módulos Modificados
2. **OrbConfig.lua** ✅ MODIFICADO
   - Orbs ahora dan **EXPReward** en lugar de SpeedBonus
   - Yellow = 5 EXP
   - Green = 7 EXP
   - Blue = 10 EXP
   - Rebirth.BaseEXPMultiplier en lugar de BaseSpeedMultiplier

### 🖥️ Scripts del Servidor Modificados
3. **DataManager.lua** ✅ MODIFICADO
   - Estructura de datos actualizada:
     - `Level` (en lugar de AccumulatedSpeed)
     - `CurrentEXP` (nueva)
     - `EXPMultiplier` (en lugar de SpeedMultiplier)
   - Funciones nuevas:
     - `AddEXP()`
     - `SetLevel()`
     - `SetEXP()`
     - `ResetLevelAndEXP()`
   - ProcessRebirth ahora resetea Level y EXP

4. **MoneyManager.lua** ✅ MODIFICADO
   - Ahora da EXP en lugar de velocidad
   - Procesa subidas de nivel automáticamente
   - Envía notificaciones de orbs recolectados
   - Envía evento cuando subes de nivel
   - Detecta cuando alcanzas nivel máximo

### 🎨 Scripts de GUI Nuevos
5. **OrbNotificationManager.lua** ✅ NUEVO
   - Sistema de notificaciones flotantes
   - Máximo 5 notificaciones simultáneas
   - Animaciones de entrada/salida
   - TÚ diseñas el estilo visual

---

## 🔴 REMOTEEVENTS ADICIONALES NECESARIOS

Debes crear estos **3 nuevos RemoteEvents** en `ReplicatedStorage/RemoteEvents/`:

1. **ShowOrbNotification** (RemoteEvent)
   - Servidor → Cliente
   - Muestra notificación flotante al recoger orb

2. **LevelUp** (RemoteEvent)
   - Servidor → Cliente
   - Notifica cuando subes de nivel

3. **MaxLevelReached** (RemoteEvent)
   - Servidor → Cliente
   - Notifica cuando alcanzas tu nivel máximo

---

## 📋 ARCHIVOS QUE FALTAN POR CREAR/MODIFICAR

### 🎮 Scripts del Cliente
- [ ] **Running.lua** - Modificar para usar velocidad por nivel (no velocidad acumulada)
- [ ] **LevelUpNotification.lua** - Notificación cuando subes de nivel
- [ ] **MaxLevelNotification.lua** - Notificación cuando alcanzas nivel máximo

### 🖼️ Scripts de GUI
- [ ] **RebirthGuiScript.lua** - Añadir TextLabels de nivel máximo actual/siguiente
- [ ] **SpeedDisplayScript.lua** - Ya no necesario (la velocidad la da el nivel, no acumulada)

### ⚙️ Scripts del Servidor
- [ ] **RebirthManager.lua** - Modificar para mostrar level caps

---

## 🎯 CÓMO FUNCIONA EL NUEVO SISTEMA

### Cuando recoges un orb:
1. ✅ Recibes EXP (con multiplicador de rebirth)
2. ✅ Recibes dinero
3. ✅ Aparece notificación flotante mostrando +EXP
4. ✅ Si tienes suficiente EXP, subes de nivel automáticamente
5. ✅ Tu velocidad de sprint cambia según tu nivel

### Niveles y Velocidad:
- Nivel 0 = 24 velocidad
- Nivel 1 = 26 velocidad
- Nivel 2 = 28 velocidad
- ... hasta nivel 40 = 104 velocidad

### Level Caps por Rebirths:
- 0 rebirths = Máximo nivel 20
- 1 rebirth = Máximo nivel 30
- 2 rebirths = Máximo nivel 40
- etc.

### Cuando compras un Rebirth:
- Tu nivel vuelve a 0
- Tu EXP vuelve a 0
- Tu multiplicador de EXP aumenta
- Tu nivel máximo aumenta

---

## 🔧 LO QUE DEBES HACER AHORA

### 1. Crear los 3 RemoteEvents nuevos
En **ReplicatedStorage > RemoteEvents**, añade:
- ShowOrbNotification
- LevelUp
- MaxLevelReached

### 2. Actualizar archivos existentes en Roblox Studio
Reemplaza el contenido de:
- ReplicatedStorage/Modules/OrbConfig
- ServerScriptService/DataManager
- ServerScriptService/MoneyManager

### 3. Añadir archivos nuevos
- ReplicatedStorage/Modules/LevelManager (NUEVO)
- StarterGui/OrbNotificationManager (NUEVO LocalScript)

---

## ✅ PRÓXIMOS PASOS

Después de que implementes lo de arriba, necesitarás:

1. **Modificar Running.lua** para que use velocidad por nivel
2. **Modificar RebirthGui** para mostrar level caps
3. **Crear notificaciones de nivel máximo**
4. **Eliminar SpeedDisplayScript** (ya no es necesario)

---

¿Quieres que continúe creando los archivos restantes? 😊
