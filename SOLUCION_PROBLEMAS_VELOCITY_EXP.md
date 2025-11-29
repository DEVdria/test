# 🔧 SOLUCIÓN A PROBLEMAS DE VELOCIDAD, EXP Y DINERO

## 🐛 PROBLEMAS IDENTIFICADOS Y SOLUCIONADOS

### ❌ Problema 1: Velocidad no se guardaba
**Síntoma:** Al entrar al juego, la velocidad siempre era 24 (base) hasta subir de nivel, aunque tuvieras nivel 3.

**Causa:** El nivel (Level) y la experiencia (CurrentEXP) **NO estaban en leaderstats**, solo en memoria interna. El script de Running buscaba Level en leaderstats y no lo encontraba.

**✅ Solución:** Ahora DataManager crea **Level** y **CurrentEXP** en leaderstats al cargar el jugador.

---

### ❌ Problema 2: EXP Display no se actualizaba
**Síntoma:** El EXP Display se mantenía en "EXP: 0 / 50" aunque recogieras orbs, solo se actualizaba al subir de nivel.

**Causa:** CurrentEXP **NO estaba en leaderstats**, por lo que PlayerStatsDisplay no podía detectar cambios.

**✅ Solución:** Ahora CurrentEXP está en leaderstats y se actualiza en tiempo real cuando recoges orbs.

---

### ❌ Problema 3: Nivel no se guardaba correctamente
**Síntoma:** Entrabas en nivel 1 cuando deberías estar en nivel 3.

**Causa:** Aunque el nivel se guardaba en el DataStore, **NO se mostraba en leaderstats**, por lo que los scripts del cliente no podían leerlo.

**✅ Solución:** Ahora Level está en leaderstats y se carga correctamente al entrar al juego.

---

### ❌ Problema 4: TextLabel CASH no se actualizaba
**Síntoma:** El TextLabel "CASH" en PrincipalGui no mostraba el dinero del jugador.

**Causa:** No había ningún script que actualizara ese TextLabel.

**✅ Solución:** Creado script `CashDisplay.lua` que actualiza automáticamente el TextLabel CASH.

---

### ❌ Problema 5: No había sonido al recoger orbs
**Síntoma:** No se reproducía ningún sonido cuando recogías un orb.

**Causa:** El sistema no tenía sonidos implementados.

**✅ Solución:** Creado script `OrbSoundManager.lua` con sonidos personalizables para cada tipo de orb.

---

## 📦 ARCHIVOS MODIFICADOS/CREADOS

### ✅ ARCHIVOS MODIFICADOS

**ServerScriptService_DataManager.lua**
- ✅ Ahora crea **Level** y **CurrentEXP** en leaderstats (líneas 253-261)
- ✅ AddEXP actualiza leaderstats en tiempo real (líneas 164-178)
- ✅ SetLevel actualiza leaderstats en tiempo real (líneas 181-194)
- ✅ SetEXP actualiza leaderstats en tiempo real (líneas 197-210)
- ✅ ProcessRebirth actualiza Level y CurrentEXP en leaderstats (líneas 254-261)

### ✅ ARCHIVOS CREADOS

**StarterGui_PrincipalGui_Frame_CashDisplay.lua**
- Script que actualiza el TextLabel "CASH" con el dinero del jugador
- Formatea números con separadores de miles ($1,000, $10,000, etc.)
- Se actualiza en tiempo real cuando ganas dinero

**StarterGui_OrbSoundManager.lua**
- Sistema de sonidos para orbs
- Sonidos personalizables por tipo (Yellow, Green, Blue)
- Configuración de volumen, pitch y velocidad
- Pool de sonidos para mejor performance
- Comentarios extensos sobre cómo personalizar

---

## 🔧 INSTALACIÓN

### PASO 1: Actualizar DataManager

1. Abre Roblox Studio
2. Ve a **ServerScriptService > DataManager**
3. **Reemplaza TODO el contenido** con el archivo: `ServerScriptService_DataManager.lua`

**¿Qué hace esto?**
- Crea Level y CurrentEXP en leaderstats
- Guarda y carga correctamente el nivel y EXP
- Actualiza leaderstats en tiempo real

---

### PASO 2: Añadir script CashDisplay

1. Ve a **StarterGui > PrincipalGui > Frame**
2. Clic derecho en **Frame** → Insert Object → **LocalScript**
3. Renombrar a: **CashDisplay**
4. **Pegar el contenido** del archivo: `StarterGui_PrincipalGui_Frame_CashDisplay.lua`

**Requisito:** Debe existir un TextLabel llamado **CASH** en el mismo Frame.

**Si no tienes el TextLabel CASH:**
1. Clic derecho en **Frame** → Insert Object → **TextLabel**
2. Renombrar a: **CASH** (nombre exacto)
3. Configurar propiedades:
   ```
   Name: CASH
   Text: "$0"
   TextSize: 20-24
   Font: GothamBold
   TextColor3: Verde o Blanco
   ```

---

### PASO 3: Añadir sistema de sonidos

1. Ve a **StarterGui**
2. Clic derecho → Insert Object → **LocalScript**
3. Renombrar a: **OrbSoundManager**
4. **Pegar el contenido** del archivo: `StarterGui_OrbSoundManager.lua`

**¿Cómo funciona?**
- Reproduce un sonido automáticamente cuando recoges un orb
- Usa sonidos por defecto de Roblox (ID: 5051712449)
- Puedes personalizar los sonidos (ver sección abajo)

---

## 🔊 CÓMO PERSONALIZAR LOS SONIDOS

### Cambiar los sonidos de los orbs:

1. Abre el script **OrbSoundManager** en StarterGui
2. Busca la línea 21-26 (sección `SOUND_IDS`)
3. Cambia los IDs de audio:

```lua
local SOUND_IDS = {
	Yellow = "rbxassetid://TU_ID_AQUI",
	Green = "rbxassetid://TU_ID_AQUI",
	Blue = "rbxassetid://TU_ID_AQUI",
}
```

### ¿Dónde encontrar IDs de sonidos?

1. Ve a: https://www.roblox.com/develop
2. Busca "Audio" en el catálogo
3. Encuentra el sonido que quieras
4. Copia el ID (número)
5. Úsalo en el formato: `"rbxassetid://NUMERO"`

### Sonidos recomendados:

| Tipo | ID | Descripción |
|---|---|---|
| Coin collect | 6895079853 | Sonido de moneda clásico |
| Ding | 5051712449 | Campanita aguda |
| Pop | 6265367896 | Sonido de burbuja |
| Chime | 6518811702 | Campanita suave |
| Bell | 5052053296 | Campana |

### Ajustar volumen y pitch:

En el script, busca la línea 29-45 (sección `SOUND_CONFIG`):

```lua
local SOUND_CONFIG = {
	Yellow = {
		Volume = 0.5,        -- 0.0 (silencio) a 1.0 (máximo)
		Pitch = 1.2,         -- Más alto = más agudo
		PlaybackSpeed = 1.2  -- Velocidad de reproducción
	},
	Green = {
		Volume = 0.6,
		Pitch = 1.0,  -- Normal
		PlaybackSpeed = 1.0
	},
	Blue = {
		Volume = 0.7,
		Pitch = 0.8,  -- Más grave
		PlaybackSpeed = 0.9
	}
}
```

### Ejemplo: Diferentes sonidos por tipo de orb

```lua
local SOUND_IDS = {
	Yellow = "rbxassetid://6895079853",  -- Moneda (agudo)
	Green = "rbxassetid://5051712449",   -- Ding (medio)
	Blue = "rbxassetid://6518811702",    -- Campanita (grave)
}
```

---

## ✅ VERIFICACIÓN

### Checklist de instalación:

1. ✅ DataManager actualizado (ServerScriptService)
2. ✅ CashDisplay creado (StarterGui > PrincipalGui > Frame)
3. ✅ TextLabel "CASH" existe en PrincipalGui > Frame
4. ✅ OrbSoundManager creado (StarterGui)

### Test básico:

1. **Inicia el juego**
2. **Revisa leaderstats:**
   - Debe mostrar: Money, Rebirths, **Level**, **CurrentEXP**
3. **Recoge un orb:**
   - ✅ Debe sonar un "ding"
   - ✅ TextLabel CASH debe actualizarse (ej: $10)
   - ✅ ExpDisplay debe actualizarse (ej: "EXP: 5 / 50")
4. **Sube de nivel:**
   - ✅ LevelDisplay debe cambiar (ej: "Nivel: 1")
   - ✅ SpeedDisplay debe cambiar (ej: "Velocidad: 26")
5. **Sal y vuelve a entrar:**
   - ✅ Tu nivel debe mantenerse (ej: sigue en Nivel 1)
   - ✅ Tu velocidad debe aplicarse inmediatamente (26, no 24)
   - ✅ Tu dinero debe mantenerse

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### ❌ El EXP Display sigue sin actualizarse

**Verifica:**
1. DataManager está actualizado
2. Leaderstats muestra "CurrentEXP" en el juego
3. PlayerStatsDisplay está en PrincipalGui > Frame

### ❌ La velocidad sigue siendo 24 al entrar

**Verifica:**
1. Leaderstats muestra "Level" en el juego
2. Running script fue reemplazado con Running_MODIFIED.lua
3. Tu nivel es realmente > 0 (revisa leaderstats)

### ❌ El TextLabel CASH no se actualiza

**Verifica:**
1. El TextLabel se llama exactamente "CASH" (mayúsculas)
2. CashDisplay está en el mismo Frame que CASH
3. No hay errores en Output

### ❌ No suena ningún sonido al recoger orbs

**Verifica:**
1. OrbSoundManager está en StarterGui
2. RemoteEvent "ShowOrbNotification" existe en ReplicatedStorage/RemoteEvents
3. El volumen de tu juego no está en 0
4. Revisa Output por errores

### ❌ Error: "CurrentEXP is not a valid member of Folder"

**Solución:**
- DataManager no está actualizado
- Reemplaza DataManager con la nueva versión
- Reinicia el juego

---

## 📊 CÓMO FUNCIONA AHORA

### Al entrar al juego:

```
1. DataManager carga datos del DataStore
   ↓
2. Crea leaderstats con:
   - Money
   - Rebirths
   - Level ← NUEVO
   - CurrentEXP ← NUEVO
   ↓
3. Scripts del cliente leen leaderstats:
   - PlayerStatsDisplay lee Level y CurrentEXP
   - CashDisplay lee Money
   - Running script lee Level para obtener velocidad
   ↓
4. Velocidad se aplica inmediatamente según el nivel guardado
```

### Al recoger un orb:

```
1. Cliente toca orb
   ↓
2. Envía evento OrbCollected al servidor
   ↓
3. MoneyManager procesa:
   - Añade dinero → Actualiza leaderstats.Money
   - Añade EXP → Actualiza leaderstats.CurrentEXP ← NUEVO
   - Procesa level-up si es necesario
   ↓
4. Servidor envía ShowOrbNotification al cliente
   ↓
5. Cliente reproduce:
   - Notificación visual (OrbNotificationManager)
   - Sonido (OrbSoundManager) ← NUEVO
   ↓
6. GUIs se actualizan automáticamente:
   - CASH muestra nuevo dinero ← NUEVO
   - ExpDisplay muestra nuevo EXP ← NUEVO
   - LevelDisplay muestra nuevo nivel (si subió)
   - SpeedDisplay muestra nueva velocidad (si subió)
```

---

## 🎯 RESUMEN DE CAMBIOS

| Componente | Antes | Ahora |
|---|---|---|
| **Leaderstats** | Money, Rebirths | Money, Rebirths, **Level**, **CurrentEXP** |
| **Velocidad al entrar** | Siempre 24 | Se aplica según nivel guardado |
| **EXP Display** | No se actualiza | Se actualiza en tiempo real |
| **Nivel guardado** | No funcional | Funciona correctamente |
| **CASH Display** | No existía | Se actualiza automáticamente |
| **Sonidos** | No había | Sonidos personalizables |

---

## 🚀 PRÓXIMOS PASOS

1. ✅ Actualiza DataManager
2. ✅ Añade CashDisplay
3. ✅ Crea TextLabel CASH
4. ✅ Añade OrbSoundManager
5. ✅ Personaliza sonidos a tu gusto
6. ✅ ¡Prueba y disfruta!

---

**¿Necesitas más ayuda?** Revisa:
- `ESTRUCTURA_COMPLETA_PROYECTO.md` - Visión general del sistema
- `GUIA_INSTALACION_SISTEMA_NIVELES.md` - Instalación completa
- `GUIA_PRINCIPALGUI_TEXTLABELS.md` - Configuración de TextLabels
