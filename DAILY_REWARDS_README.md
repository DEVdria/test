# 🎁 Sistema de Daily Rewards - Guía Completa

Sistema completo de recompensas diarias diseñado para **maximizar retención** y **duración de sesión**.

---

## 📋 ARCHIVOS DEL SISTEMA

### 1. **ReplicatedStorage > Modules > DailyRewardConfig.lua** (ModuleScript)
Configuración del sistema. Aquí defines las 7 recompensas del ciclo.

**Recompensas actuales:**
- **Día 1:** x2 XP durante 10 minutos ⚡ *(Fuerte inicio para enganchar)*
- **Día 2:** 5,000 monedas 💰
- **Día 3:** x2 Money durante 15 minutos 💵
- **Día 4:** 10,000 monedas 💰
- **Día 5:** 15,000 monedas 💰
- **Día 6:** x2 XP durante 20 minutos ⚡
- **Día 7:** x2 XP + x2 Money durante 30 minutos 🔥 *(Gran final)*

---

### 2. **ServerScriptService > BoostManager.lua** (Script)
Gestiona los multiplicadores temporales de XP y Money.

**Características:**
- ✅ Hooks en `DataManager.AddEXP` y `DataManager.AddMoney`
- ✅ Validación del servidor (anti-exploit)
- ✅ Temporizadores precisos
- ✅ Limpieza automática al expirar
- ✅ Independiente de otros sistemas de boost

**API Global:**
```lua
_G.BoostManager.ActivateBoost(player, "XP", 2, 600)  -- x2 XP por 10 minutos
_G.BoostManager.ActivateBoost(player, "Money", 2, 900)  -- x2 Money por 15 minutos
_G.BoostManager.GetXPMultiplier(player)  -- Retorna multiplicador actual
_G.BoostManager.GetMoneyMultiplier(player)  -- Retorna multiplicador actual
```

---

### 3. **ServerScriptService > DailyRewardManager.lua** (Script)
Gestiona la lógica de reclamación y persistencia de datos.

**Reglas:**
- 🕐 Una recompensa cada 24 horas reales
- 🔄 No pierdes racha si no entras un día
- ⛔ No puedes reclamar días futuros
- ✅ Validación completa en servidor

**Cómo funciona:**
1. Jugador entra → Sistema verifica si pasaron 24h desde última reclamación
2. Si está disponible → Auto-abre la UI con señal al cliente
3. Jugador reclama → Aplica recompensa y avanza al siguiente día
4. Día 7 → Reinicia el ciclo al día 1

---

### 4. **StarterGui > DailyRewardGui > DailyRewardGui.lua** (LocalScript)
Controla toda la interfaz de usuario.

**Funcionalidades:**
- 📱 Auto-abre cuando hay recompensa disponible
- 🎨 Actualiza colores según estado (reclamado/disponible/bloqueado)
- ⏰ Contador de tiempo en tiempo real
- 🎵 Sonidos y animaciones al reclamar
- 🔥 Indicador de boost activo en pantalla
- 📊 Mensaje grande de celebración para boosts

---

## 🎨 CÓMO DISEÑAR LA UI

### **Estructura mínima requerida:**

```
StarterGui
└─ DailyRewardGui (ScreenGui)
   ├─ DailyRewardGui (LocalScript) ← EL SCRIPT VA AQUÍ
   ├─ DailyRewardFrame (Frame) ← Panel principal
   │  ├─ CloseButton (TextButton) ← Botón X para cerrar
   │  ├─ Day1 (Frame o ImageButton) ← Día 1
   │  │  ├─ Icon (TextLabel) ← Auto-poblado con "⚡"
   │  │  ├─ DayNumber (TextLabel) ← Auto-poblado "DÍA 1"
   │  │  ├─ RewardText (TextLabel) ← Auto-poblado "x2 XP - 10 min"
   │  │  ├─ Status (TextLabel) ← Auto-actualizado "✅ RECLAMADO" / "¡DISPONIBLE!" / "🔒 BLOQUEADO"
   │  │  └─ ClaimButton (TextButton) ← Solo visible si está disponible
   │  ├─ Day2 (Frame) ← Día 2... igual estructura
   │  ├─ Day3...
   │  ├─ Day4...
   │  ├─ Day5...
   │  ├─ Day6...
   │  └─ Day7 (Frame) ← Día 7
   └─ BoostIndicator (Frame) [OPCIONAL] ← Indicador de boost activo
      ├─ BoostText (TextLabel) ← "🔥 x2 XP"
      └─ BoostTimer (TextLabel) ← "9:45"
```

### **Configuración de cada elemento Día:**
Cada Frame/ImageButton de día (Day1, Day2, etc.) debe contener:
- **Icon** (TextLabel) → Se llena automáticamente con el emoji
- **DayNumber** (TextLabel) → Se llena con "DÍA X"
- **RewardText** (TextLabel) → Nombre de la recompensa
- **Status** (TextLabel) → Estado actual
- **ClaimButton** (TextButton) → Solo se muestra si está disponible

### **Tamaños recomendados:**
```lua
DailyRewardFrame:
  Size = {0.6, 0}, {0.7, 0}
  Position = {0.5, 0}, {0.5, 0}
  AnchorPoint = 0.5, 0.5

Day1, Day2... (cada uno):
  Size = {0.12, 0}, {0.35, 0}  -- Ajustar según diseño

ClaimButton:
  Size = {0.8, 0}, {0.2, 0}
```

---

## 🎨 PERSONALIZACIÓN

### **Cambiar recompensas:**
Edita `DailyRewardConfig.lua`:

```lua
{
	Day = 1,
	Type = "XPBoost",           -- Tipos: "Money", "XPBoost", "MoneyBoost", "DoubleBoost"
	BoostMultiplier = 2,        -- Para boosts
	BoostDuration = 600,        -- Segundos (600 = 10 minutos)
	MoneyAmount = 5000,         -- Para tipo "Money"
	DisplayName = "x2 XP - 10 min",
	Icon = "⚡",
	Description = "Texto descriptivo"
}
```

### **Cambiar cooldown (tiempo entre recompensas):**
Edita en `DailyRewardConfig.lua`:
```lua
DailyRewardConfig.CLAIM_COOLDOWN = 24 * 60 * 60  -- 24 horas en segundos
-- Para testing: 60 (1 minuto) o 300 (5 minutos)
```

### **Cambiar colores:**
Edita en `DailyRewardConfig.lua`:
```lua
DailyRewardConfig.Colors = {
	Claimed = Color3.fromRGB(0, 200, 0),       -- Verde
	Available = Color3.fromRGB(255, 215, 0),   -- Dorado
	Locked = Color3.fromRGB(100, 100, 100),    -- Gris
	Special = Color3.fromRGB(255, 100, 0)      -- Naranja (Día 7)
}
```

---

## 🔧 INTEGRACIÓN CON TU JUEGO

### **El sistema ya está integrado con:**
- ✅ `DataManager` (guarda progreso automáticamente)
- ✅ `DataManager.AddEXP` (aplica multiplicador de XP)
- ✅ `DataManager.AddMoney` (aplica multiplicador de Money)

### **No requiere cambios adicionales en:**
- Orb collectors
- Zone purchases
- Race rewards
- Level system
- Cualquier cosa que use `DataManager.AddEXP` o `AddMoney`

---

## 🎮 EXPERIENCIA DEL JUGADOR

### **Primera vez que entra:**
1. Espera 3 segundos (para que todo cargue)
2. **UI se abre automáticamente** con animación
3. Ve todos los 7 días del ciclo
4. **Día 1** está resaltado en dorado con botón "RECLAMAR"
5. Hace clic → Sonido de victoria + Mensaje grande "🔥 x2 XP ACTIVADO - 10:00"
6. Aparece **indicador de boost** en la esquina superior con countdown
7. Juega durante 10 minutos ganando **doble XP**

### **Días siguientes:**
- Si pasaron 24h → UI auto-abre al entrar
- Si no pasaron 24h → Botón muestra countdown "⏰ 5h 23m"
- Puede cerrar y abrir la UI cuando quiera
- **No pierde racha** si no entra un día

### **Día 7 (Gran recompensa):**
- Frame del día 7 tiene color **naranja** especial
- Al reclamar: "🔥 x2 XP + x2 Money durante 30:00"
- **Ambos boosts** aparecen en el indicador
- Máximo incentivo para quedarse jugando

---

## 🛡️ SEGURIDAD

### **Protecciones implementadas:**
1. ✅ **Validación en servidor** → Cliente no puede falsificar claims
2. ✅ **Timestamps del servidor** → `os.time()` no se puede manipular
3. ✅ **DataStore** → Progreso guardado permanentemente
4. ✅ **Cooldowns verificados** → No puede reclamar antes de 24h
5. ✅ **Boosts del servidor** → Multiplicadores aplicados server-side

### **Contra exploits comunes:**
- ❌ No puede reclamar días futuros
- ❌ No puede resetear el cooldown
- ❌ No puede modificar multiplicadores
- ❌ No puede extender duración de boosts

---

## 📊 ESTADÍSTICAS Y MÉTRICAS

### **Datos guardados por jugador:**
```lua
DailyRewards = {
	CurrentDay = 1,        -- Día actual (1-7)
	LastClaimTime = 0,     -- Unix timestamp
	TotalClaimed = 0       -- Total histórico
}
```

### **Para analytics:**
```lua
-- Obtener datos de un jugador:
local data = DataManager.GetData(player)
local dailyData = data.DailyRewards

print(dailyData.CurrentDay)      -- En qué día está
print(dailyData.TotalClaimed)    -- Cuántas recompensas ha reclamado en total
```

---

## 🐛 TESTING Y DEBUG

### **Testing rápido:**
1. Cambia el cooldown a 1 minuto:
```lua
DailyRewardConfig.CLAIM_COOLDOWN = 60  -- 1 minuto
```

2. Inicia el juego en modo Play
3. Espera 3 segundos → UI auto-abre
4. Reclama día 1 → Verifica que aparece el boost
5. Espera 1 minuto → UI auto-abre de nuevo
6. Ahora está en día 2

### **Verificar boosts activos:**
Verifica en el output:
```
[BoostManager] 🔥 Boost de XP activado para PlayerName: x2.0 durante 600 segundos
[DataManager] 💎 PlayerName recibió 100 XP (multiplicado por boost)
```

### **Forzar reset de datos (testing):**
En la consola del servidor:
```lua
local player = game.Players.PlayerName
local data = _G.DataManager.GetData(player)
data.DailyRewards = {
    CurrentDay = 1,
    LastClaimTime = 0,
    TotalClaimed = 0
}
_G.DataManager.SaveData(player)
```

---

## ❓ PREGUNTAS FRECUENTES

**P: ¿El jugador pierde su racha si no entra un día?**
R: NO. El sistema NO penaliza por ausencias. Si está en día 3 y no entra por una semana, cuando regrese seguirá en día 3.

**P: ¿Puede reclamar todos los días de golpe?**
R: NO. Solo puede reclamar 1 recompensa cada 24 horas.

**P: ¿Los boosts se acumulan con otros sistemas?**
R: NO. Este sistema modifica directamente `DataManager.AddEXP` y `AddMoney`. Si tienes otros multiplicadores, se aplicarían en secuencia.

**P: ¿Qué pasa si el jugador sale del juego con un boost activo?**
R: El boost se pierde. Es intencional para incentivar sesiones más largas.

**P: ¿Cómo agrego más días al ciclo?**
R: Añade más entradas al array `DailyRewardConfig.Rewards` y actualiza los botones en la UI (Day8, Day9, etc.)

**P: ¿Puedo cambiar el orden de las recompensas?**
R: Sí, pero asegúrate de que el campo `Day` coincida con su posición.

---

## 🚀 OPTIMIZACIÓN PARA RETENCIÓN

### **Por qué este diseño funciona:**

1. **Día 1 = Boost fuerte:**
   - El jugador QUIERE quedarse esos 10 minutos para aprovecharlo
   - No es dinero instantáneo que toma y se va
   - Genera engagement inmediato

2. **Mix de recompensas:**
   - Dinero instantáneo = satisfacción inmediata
   - Boosts = retención de sesión
   - Variedad = mantiene interés

3. **Día 7 épico:**
   - El jugador tiene razón para completar toda la semana
   - 30 minutos de doble ganancia = sesión larga garantizada

4. **No castiga ausencias:**
   - Reduce frustración
   - El jugador siempre se siente bienvenido
   - FOMO sin penalización

5. **Auto-open UI:**
   - El jugador no olvida reclamar
   - Fricción mínima
   - Refuerzo positivo constante

---

## 🎨 EJEMPLO DE DISEÑO VISUAL

```
╔══════════════════════════════════════════════╗
║         🎁 RECOMPENSAS DIARIAS 🎁           ║
╠══════════════════════════════════════════════╣
║  [✅]    [✅]    [✅]    [🔥]    [ ]    [ ]    [ ]  ║
║  DÍA 1  DÍA 2  DÍA 3  DÍA 4  DÍA 5  DÍA 6  DÍA 7 ║
║  x2 XP  5K💰  x2$   10K💰  15K💰  x2XP  ÉPICO ║
║                                               ║
║              ╔════════════╗                   ║
║              ║ ¡RECLAMAR! ║                   ║
║              ╚════════════╝                   ║
╚══════════════════════════════════════════════╝
```

---

## 📝 NOTAS FINALES

- **Coloca el LocalScript DENTRO del ScreenGui**, no suelto en StarterGui
- **Los nombres de los elementos importan** (Day1, Day2, ClaimButton, etc.)
- **El sistema es plug-and-play** si sigues la estructura
- **Personaliza colores, tamaños, fuentes** como quieras
- **El código está comentado** para facilitar modificaciones

---

¡Tu sistema de Daily Rewards está listo para aumentar la retención! 🚀
