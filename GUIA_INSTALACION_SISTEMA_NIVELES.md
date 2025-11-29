# 📘 GUÍA DE INSTALACIÓN - Sistema de Niveles y EXP

## ✅ PASO 1: CREAR LOS 3 NUEVOS REMOTEEVENTS

En **ReplicatedStorage > RemoteEvents**, crea estos 3 RemoteEvents nuevos:

1. **ShowOrbNotification** (RemoteEvent)
2. **LevelUp** (RemoteEvent)
3. **MaxLevelReached** (RemoteEvent)

**Cómo crear:**
- Clic derecho en la carpeta `RemoteEvents`
- Insert Object → RemoteEvent
- Renombrar exactamente como se indica arriba

---

## ✅ PASO 2: AÑADIR/MODIFICAR MÓDULOS (ReplicatedStorage/Modules)

### 2.1 CREAR LevelManager.lua (NUEVO)
- Clic derecho en `ReplicatedStorage > Modules`
- Insert Object → ModuleScript
- Renombrar a: **LevelManager**
- Reemplazar todo el contenido con el archivo: `ReplicatedStorage_Modules_LevelManager.lua`

### 2.2 ACTUALIZAR OrbConfig.lua (MODIFICAR)
- Abrir: `ReplicatedStorage > Modules > OrbConfig`
- Reemplazar todo el contenido con el archivo: `ReplicatedStorage_Modules_OrbConfig.lua`

---

## ✅ PASO 3: ACTUALIZAR SCRIPTS DEL SERVIDOR (ServerScriptService)

### 3.1 ACTUALIZAR DataManager (MODIFICAR)
- Abrir: `ServerScriptService > DataManager`
- Reemplazar todo el contenido con el archivo: `ServerScriptService_DataManager.lua`

### 3.2 ACTUALIZAR MoneyManager (MODIFICAR)
- Abrir: `ServerScriptService > MoneyManager`
- Reemplazar todo el contenido con el archivo: `ServerScriptService_MoneyManager.lua`

### 3.3 ACTUALIZAR RebirthManager (MODIFICAR)
- Abrir: `ServerScriptService > RebirthManager`
- Reemplazar todo el contenido con el archivo: `ServerScriptService_RebirthManager.lua`

---

## ✅ PASO 4: ACTUALIZAR SCRIPTS DEL CLIENTE (StarterGui)

### 4.1 CREAR OrbNotificationManager.lua (NUEVO)
- Clic derecho en `StarterGui`
- Insert Object → LocalScript
- Renombrar a: **OrbNotificationManager**
- Pegar el contenido del archivo: `StarterGui_OrbNotificationManager.lua`

### 4.2 CREAR MaxLevelNotification.lua (NUEVO)
- Clic derecho en `StarterGui`
- Insert Object → LocalScript
- Renombrar a: **MaxLevelNotification**
- Pegar el contenido del archivo: `StarterGui_MaxLevelNotification.lua`

### 4.3 ACTUALIZAR RebirthGuiScript (MODIFICAR)
- Abrir: `StarterGui > RebirthGui > Frame > RebirthGuiScript`
- Reemplazar todo el contenido con el archivo: `StarterGui_RebirthGui_Frame_RebirthGuiScript.lua`

---

## ✅ PASO 5: AÑADIR TEXTLABELS AL REBIRTH GUI

### 🎯 IMPORTANTE: Añadir información de nivel máximo al RebirthGui

Debes crear **2 nuevos TextLabels** dentro del Frame de RebirthGui para mostrar el nivel máximo actual y el siguiente.

**Ubicación exacta:**
```
StarterGui
  └─ RebirthGui (ScreenGui)
      └─ Frame
          ├─ Title (TextLabel) - YA EXISTE
          ├─ PriceLabel (TextLabel) - YA EXISTE
          ├─ MultiplierLabel (TextLabel) - YA EXISTE
          ├─ CurrentLevelCapLabel (TextLabel) - ⭐ CREAR NUEVO
          ├─ NextLevelCapLabel (TextLabel) - ⭐ CREAR NUEVO
          ├─ PurchaseButton (TextButton) - YA EXISTE
          └─ CloseButton (TextButton) - YA EXISTE
```

### 📝 Paso a paso para crear los TextLabels:

#### 5.1 Crear CurrentLevelCapLabel (Nivel máximo actual)

1. Haz clic derecho en el **Frame** del RebirthGui
2. Insert Object → **TextLabel**
3. Renombrar a: **CurrentLevelCapLabel** (nombre exacto)
4. Configurar propiedades:

```
Name: CurrentLevelCapLabel
Size: UDim2.new(1, -40, 0, 30)
Position: UDim2.new(0, 20, 0, 120)  ← Ajusta según tu diseño
BackgroundTransparency: 1
Text: "Nivel Máximo Actual: 0"
TextColor3: Color3.fromRGB(255, 255, 255)
TextSize: 18
Font: Gotham
TextXAlignment: Left
```

#### 5.2 Crear NextLevelCapLabel (Nivel máximo siguiente)

1. Haz clic derecho en el **Frame** del RebirthGui
2. Insert Object → **TextLabel**
3. Renombrar a: **NextLevelCapLabel** (nombre exacto)
4. Configurar propiedades:

```
Name: NextLevelCapLabel
Size: UDim2.new(1, -40, 0, 30)
Position: UDim2.new(0, 20, 0, 155)  ← Justo debajo del anterior
BackgroundTransparency: 1
Text: "Nivel Máximo con Rebirth: 0"
TextColor3: Color3.fromRGB(100, 255, 100)
TextSize: 18
Font: GothamBold
TextXAlignment: Left
```

### 🎨 Sugerencias de diseño:

**Posicionamiento recomendado (de arriba a abajo):**
1. Title (ya existe)
2. PriceLabel (ya existe)
3. MultiplierLabel (ya existe)
4. **CurrentLevelCapLabel** ← NUEVO (Color blanco)
5. **NextLevelCapLabel** ← NUEVO (Color verde brillante)
6. PurchaseButton (ya existe)
7. CloseButton (ya existe)

**Ejemplo de posiciones sugeridas:**
- CurrentLevelCapLabel: `Position = UDim2.new(0, 20, 0, 120)`
- NextLevelCapLabel: `Position = UDim2.new(0, 20, 0, 155)`

> **Nota:** Ajusta la posición Y (segundo número) según el tamaño de tu Frame. Los valores 120 y 155 son ejemplos. Puedes modificarlos para que se vean bien en tu GUI.

---

## ✅ PASO 6: ACTUALIZAR RUNNING SCRIPT (StarterPlayer)

### 6.1 REEMPLAZAR Running.lua
- Navegar a: `StarterPlayer > StarterCharacterScripts > Running`
- Reemplazar todo el contenido con el archivo: `StarterPlayer_StarterCharacterScripts_Running_MODIFIED.lua`

**Alternativa:**
Si prefieres mantener el original como respaldo:
1. Renombra el actual a `Running_OLD`
2. Crea un nuevo LocalScript llamado `Running`
3. Pega el contenido del archivo `Running_MODIFIED.lua`

---

## ✅ PASO 7: CREAR TEXTLABEL DE LEVEL EN LEADERSTATS

### 7.1 Actualizar leaderstats
El sistema ahora muestra **Level** en lugar de **AccumulatedSpeed**.

**¿Qué hace el sistema automáticamente?**
- El DataManager ya crea el TextLabel de "Level" automáticamente
- Se actualiza en tiempo real cuando subes de nivel
- No necesitas hacer nada adicional

**Para verificar:**
1. Inicia el juego
2. Mira la pestaña de jugadores
3. Deberías ver:
   - 💰 Money
   - 🔄 Rebirths
   - ⭐ Level (NUEVO)

---

## ✅ PASO 8: ELIMINAR ARCHIVOS OBSOLETOS (Opcional)

Estos archivos ya no son necesarios con el nuevo sistema:

### Archivos a eliminar/desactivar:
- ❌ **SpeedDisplayScript** (si existe) - Ya no es necesario porque la velocidad viene del nivel
- ❌ **UpdateSpeedDisplay** (RemoteEvent, si existe) - Ya no se usa

---

## 📋 RESUMEN DE ARCHIVOS MODIFICADOS/CREADOS

### ✅ NUEVOS MÓDULOS
- ✅ `ReplicatedStorage/Modules/LevelManager` (NUEVO)

### ✅ MÓDULOS MODIFICADOS
- ✅ `ReplicatedStorage/Modules/OrbConfig` (MODIFICADO)

### ✅ SCRIPTS DEL SERVIDOR MODIFICADOS
- ✅ `ServerScriptService/DataManager` (MODIFICADO)
- ✅ `ServerScriptService/MoneyManager` (MODIFICADO)
- ✅ `ServerScriptService/RebirthManager` (MODIFICADO)

### ✅ SCRIPTS DEL CLIENTE NUEVOS
- ✅ `StarterGui/OrbNotificationManager` (NUEVO)
- ✅ `StarterGui/MaxLevelNotification` (NUEVO)

### ✅ SCRIPTS DEL CLIENTE MODIFICADOS
- ✅ `StarterGui/RebirthGui/Frame/RebirthGuiScript` (MODIFICADO)
- ✅ `StarterPlayer/StarterCharacterScripts/Running` (MODIFICADO)

### ✅ GUI - AÑADIR TEXTLABELS
- ✅ `StarterGui/RebirthGui/Frame/CurrentLevelCapLabel` (CREAR TEXTLABEL)
- ✅ `StarterGui/RebirthGui/Frame/NextLevelCapLabel` (CREAR TEXTLABEL)

### ✅ REMOTEEVENTS NUEVOS
- ✅ `ReplicatedStorage/RemoteEvents/ShowOrbNotification` (CREAR)
- ✅ `ReplicatedStorage/RemoteEvents/LevelUp` (CREAR)
- ✅ `ReplicatedStorage/RemoteEvents/MaxLevelReached` (CREAR)

---

## 🎯 CÓMO FUNCIONA EL NUEVO SISTEMA

### Cuando recoges un orb:
1. ✅ Recibes **EXP** (con multiplicador de rebirth)
2. ✅ Recibes **dinero**
3. ✅ Aparece **notificación flotante** mostrando +EXP (color del orb)
4. ✅ Si tienes suficiente EXP, **subes de nivel automáticamente**
5. ✅ Tu **velocidad de sprint cambia** según tu nuevo nivel
6. ✅ Si alcanzas tu **nivel máximo**, recibes una notificación especial

### Sistema de niveles:
- **Nivel 0** = 24 de velocidad (base)
- **Nivel 1** = 26 de velocidad
- **Nivel 2** = 28 de velocidad
- ... (aumenta +2 por nivel)
- **Nivel 40** = 104 de velocidad (máximo)

### Level Caps por Rebirths:
- **0 rebirths** = Máximo nivel **20**
- **1 rebirth** = Máximo nivel **30**
- **2 rebirths** = Máximo nivel **40**
- **3+ rebirths** = Máximo nivel **40** (cap final)

### Cuando compras un Rebirth:
- ✅ Tu nivel vuelve a **0**
- ✅ Tu EXP vuelve a **0**
- ✅ Tu **multiplicador de EXP** aumenta (+10% base + 5% por rebirth)
- ✅ Tu **nivel máximo** aumenta (si no estás en el cap final)
- ✅ La GUI muestra el cambio: "Nivel Máximo: 20 → 30"

---

## 🔍 VERIFICACIÓN FINAL

Después de implementar todo, verifica:

1. ✅ Los 3 nuevos RemoteEvents existen en ReplicatedStorage/RemoteEvents
2. ✅ LevelManager existe en ReplicatedStorage/Modules
3. ✅ Todos los scripts modificados están actualizados
4. ✅ Los 2 TextLabels nuevos están en RebirthGui/Frame con nombres correctos
5. ✅ El script Running está actualizado
6. ✅ No hay errores en el Output al iniciar el juego

### Test del sistema:
1. Inicia el juego
2. Recoge un orb amarillo
3. Verifica que aparezca la notificación flotante "+5 EXP"
4. Recoge suficientes orbs para subir de nivel
5. Verifica que aparezca "¡Nivel X alcanzado!"
6. Verifica que tu velocidad al correr haya aumentado
7. Abre el RebirthGui
8. Verifica que se muestren:
   - "Nivel Máximo Actual: X"
   - "Nivel Máximo con Rebirth: Y"
   - "Multiplicador EXP: x1.00 → x1.10"

---

## ❓ PROBLEMAS COMUNES

### Error: "LevelManager is not a valid member"
**Solución:** Asegúrate de que LevelManager.lua está en `ReplicatedStorage/Modules` y es un **ModuleScript**.

### Los TextLabels de nivel no aparecen en RebirthGui
**Solución:**
1. Verifica que los nombres sean **exactos**: `CurrentLevelCapLabel` y `NextLevelCapLabel`
2. Verifica que estén dentro del **Frame**, no en otra parte
3. Verifica que RebirthGuiScript esté actualizado

### Las notificaciones de orbs no aparecen
**Solución:**
1. Verifica que `ShowOrbNotification` RemoteEvent existe
2. Verifica que `OrbNotificationManager` está en StarterGui
3. Revisa el Output por errores

### No sube de nivel al recoger orbs
**Solución:**
1. Verifica que MoneyManager está actualizado
2. Verifica que `LevelUp` RemoteEvent existe
3. Verifica que DataManager está actualizado

---

## 🎉 ¡LISTO!

Tu sistema de niveles y EXP está completamente implementado.

**Características implementadas:**
✅ Sistema de niveles (0-40)
✅ Ganancia de EXP por orbs
✅ Notificaciones flotantes de EXP
✅ Notificación de subida de nivel
✅ Notificación de nivel máximo alcanzado
✅ Velocidad basada en nivel (no acumulada)
✅ Level caps por rebirths
✅ GUI de rebirth actualizada con información de niveles
✅ Sistema totalmente modular y editable

---

**¿Necesitas ayuda adicional?** Revisa los comentarios dentro de cada archivo para entender cómo funciona cada parte del sistema.
