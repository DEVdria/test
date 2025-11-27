# ⚡ GUÍA RÁPIDA DE INSTALACIÓN

## 🚀 5 PASOS PARA INSTALAR EL SISTEMA

### **PASO 1: CREAR CARPETAS**

En Roblox Studio:

1. **ReplicatedStorage** → Crear carpeta `Modules`
2. **ServerScriptService** → Ya existe
3. **StarterPlayer** → Verificar que existe `StarterPlayerScripts`

---

### **PASO 2: COPIAR MÓDULOS (ReplicatedStorage/Modules)**

Crea estos ModuleScripts:

| Nombre | Copiar código de |
|--------|------------------|
| `Config` | `ReplicatedStorage/Modules/Config.lua` |
| `OrbsModule` | `ReplicatedStorage/Modules/OrbsModule.lua` |
| `SprintModule` | `ReplicatedStorage/Modules/SprintModule.lua` |
| `EconomyModule` | `ReplicatedStorage/Modules/EconomyModule.lua` |

---

### **PASO 3: COPIAR SCRIPTS DEL SERVIDOR (ServerScriptService)**

Crea estos Scripts:

| Nombre | Copiar código de |
|--------|------------------|
| `RemoteEventsSetup` | `ServerScriptService/RemoteEventsSetup.lua` |
| `LeaderstatsScript` | `ServerScriptService/LeaderstatsScript.lua` |
| `ServerEventsHandler` | `ServerScriptService/ServerEventsHandler.lua` |
| `ReviveScript` | `ServerScriptService/ReviveScript.lua` |

---

### **PASO 4: COPIAR SCRIPTS DEL CLIENTE (StarterPlayer/StarterPlayerScripts)**

Crea estos LocalScripts:

| Nombre | Copiar código de |
|--------|------------------|
| `ClientMain` | `StarterPlayer/StarterPlayerScripts/ClientMain.lua` |
| `CustomGUIHandler` | `StarterPlayer/StarterPlayerScripts/CustomGUIHandler.lua` |

---

### **PASO 5: CONFIGURAR TU GUI**

1. Crea tu ScreenGui en `StarterGui`
2. Añade estos elementos:
   - `SpeedLabel` (TextLabel) - Para mostrar velocidad
   - `SprintButton` (TextButton) - Para sprint en móvil
   - `ReviveButton` (TextButton) - Para revivir

3. Abre `CustomGUIHandler.lua` y modifica:

```lua
local SCREEN_GUI_NAME = "TuNombreDeGUI"
local SPEED_LABEL_NAME = "TuSpeedLabel"
local SPRINT_BUTTON_NAME = "TuSprintButton"
local REVIVE_BUTTON_NAME = "TuReviveButton"
```

---

## ✅ VERIFICACIÓN

**Después de instalar, verifica:**

1. ⚙️ En Output (F9) deberías ver:
   ```
   RemoteEventsSetup completado exitosamente
   LeaderstatsScript cargado exitosamente
   ServerEventsHandler cargado exitosamente
   ReviveScript cargado exitosamente
   ClientMain cargado exitosamente
   CustomGUIHandler cargado exitosamente
   ```

2. 📊 Al jugar, deberías tener leaderstats:
   - Money
   - Rebirths

3. 🟡 Deberías ver orbs amarillas flotando en el mundo

4. ⌨️ Al presionar SHIFT (PC) deberías correr más rápido

---

## 🎯 CONFIGURACIÓN BÁSICA

### **Cambiar posiciones de las orbs:**

Abre `ReplicatedStorage/Modules/Config` y edita:

```lua
Config.OrbSpawnLocations = {
    Vector3.new(0, 5, 0),    -- Posición 1
    Vector3.new(10, 5, 10),  -- Posición 2
    -- Añade más posiciones...
}
```

### **Cambiar velocidad de boost:**

```lua
Config.OrbSpeedBoost = 1      -- Velocidad por orb
Config.OrbMoneyReward = 10    -- Dinero por orb
Config.OrbRespawnTime = 30    -- Segundos para respawn
```

---

## 🐛 PROBLEMAS COMUNES

| Problema | Solución |
|----------|----------|
| No aparecen orbs | Verifica `Config.OrbSpawnLocations` y que `ClientMain` se ejecute |
| Sprint no funciona | Revisa que `SprintModule` esté en `ReplicatedStorage/Modules` |
| GUI no funciona | Verifica nombres en `CustomGUIHandler.lua` |
| No hay leaderstats | Revisa que `LeaderstatsScript` se ejecutó (Output) |
| RemoteEvents no existen | Ejecuta `RemoteEventsSetup.lua` |

---

## 📋 CHECKLIST DE INSTALACIÓN

- [ ] Carpeta `Modules` creada en ReplicatedStorage
- [ ] 4 ModuleScripts en ReplicatedStorage/Modules
- [ ] 4 Scripts en ServerScriptService
- [ ] 2 LocalScripts en StarterPlayer/StarterPlayerScripts
- [ ] GUI creada en StarterGui
- [ ] Nombres configurados en CustomGUIHandler.lua
- [ ] Posiciones de orbs configuradas en Config.lua
- [ ] Juego probado en modo Play

---

## 🎮 PRUEBA RÁPIDA

1. **Presiona Play (F5)**
2. **Verifica:**
   - ✅ Leaderstats aparecen (Money, Rebirths)
   - ✅ Orbs amarillas visibles
   - ✅ Al tocar orb → Desaparece y suma dinero
   - ✅ SHIFT → Corres más rápido
   - ✅ Al morir → Botón de revivir aparece

3. **Si todo funciona:** ¡Instalación exitosa! 🎉

---

## 📞 SIGUIENTE PASO

Lee `README.md` para personalización avanzada y `EJEMPLOS_GUI.md` para diseños de GUI.

---

**¡Listo en 5 minutos!** ⚡
