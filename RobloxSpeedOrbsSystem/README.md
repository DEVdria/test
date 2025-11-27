# 🎮 SISTEMA DE ORBS DE VELOCIDAD PARA ROBLOX

Sistema completo y optimizado de orbs de velocidad, sprint, economía y renacimientos para Roblox.

## 📋 CARACTERÍSTICAS

✅ **Sistema de Orbs (Pelotitas)**
- Orbs solo visibles para cada cliente
- Aumentan velocidad acumulada al recogerlas
- Se regeneran automáticamente después de 30 segundos
- Dan dinero al jugador

✅ **Sistema de Sprint**
- PC: Presiona SHIFT para correr
- Móvil: Botón dedicado en pantalla
- Velocidad base + boost acumulado de orbs
- NO modifica directamente Humanoid.WalkSpeed

✅ **Sistema de Economía**
- Leaderstats con Money y Rebirths
- Sistema de Rebirth que resetea progreso
- Multiplicador de velocidad por rebirth

✅ **Sistema de Revivir**
- Botón para revivir manualmente
- Auto-revivir después de 5 segundos
- Mantiene velocidad acumulada

✅ **Compatible con GUIs Personalizadas**
- Fácil integración con tus GUIs existentes
- Ejemplos de código incluidos

---

## 📁 ESTRUCTURA DEL PROYECTO

```
RobloxSpeedOrbsSystem/
│
├── ReplicatedStorage/
│   ├── Modules/
│   │   ├── Config.lua              (Configuración global)
│   │   ├── OrbsModule.lua          (Sistema de orbs - cliente)
│   │   ├── SprintModule.lua        (Sistema de sprint - cliente)
│   │   └── EconomyModule.lua       (Sistema de economía - servidor)
│   │
│   └── RemoteEvents/               (Se crea automáticamente)
│       ├── OrbCollected
│       ├── RevivePlayer
│       ├── PerformRebirth
│       └── RebirthCompleted
│
├── ServerScriptService/
│   ├── LeaderstatsScript.lua       (Crea leaderstats)
│   ├── RemoteEventsSetup.lua       (Crea RemoteEvents)
│   ├── ServerEventsHandler.lua     (Maneja eventos del servidor)
│   └── ReviveScript.lua            (Sistema de revivir)
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── ClientMain.lua          (Inicializa sistemas del cliente)
        └── CustomGUIHandler.lua    (Conecta tus GUIs personalizadas)
```

---

## 🚀 INSTALACIÓN PASO A PASO

### **PASO 1: CREAR CARPETAS EN ROBLOX STUDIO**

1. Abre Roblox Studio
2. Crea las siguientes carpetas:

**En ReplicatedStorage:**
- Crea una carpeta llamada `Modules`
- Crea una carpeta llamada `RemoteEvents` (opcional, se crea automáticamente)

**En StarterPlayer:**
- Si no existe, crea `StarterPlayerScripts`

---

### **PASO 2: COPIAR MÓDULOS**

**En ReplicatedStorage > Modules:**

1. **Config.lua**
   - Crea un ModuleScript llamado `Config`
   - Copia el código de: `ReplicatedStorage/Modules/Config.lua`

2. **OrbsModule.lua**
   - Crea un ModuleScript llamado `OrbsModule`
   - Copia el código de: `ReplicatedStorage/Modules/OrbsModule.lua`

3. **SprintModule.lua**
   - Crea un ModuleScript llamado `SprintModule`
   - Copia el código de: `ReplicatedStorage/Modules/SprintModule.lua`

4. **EconomyModule.lua**
   - Crea un ModuleScript llamado `EconomyModule`
   - Copia el código de: `ReplicatedStorage/Modules/EconomyModule.lua`

---

### **PASO 3: COPIAR SCRIPTS DE SERVIDOR**

**En ServerScriptService:**

1. **RemoteEventsSetup.lua**
   - Crea un Script llamado `RemoteEventsSetup`
   - Copia el código de: `ServerScriptService/RemoteEventsSetup.lua`

2. **LeaderstatsScript.lua**
   - Crea un Script llamado `LeaderstatsScript`
   - Copia el código de: `ServerScriptService/LeaderstatsScript.lua`

3. **ServerEventsHandler.lua**
   - Crea un Script llamado `ServerEventsHandler`
   - Copia el código de: `ServerScriptService/ServerEventsHandler.lua`

4. **ReviveScript.lua**
   - Crea un Script llamado `ReviveScript`
   - Copia el código de: `ServerScriptService/ReviveScript.lua`

---

### **PASO 4: COPIAR SCRIPTS DE CLIENTE**

**En StarterPlayer > StarterPlayerScripts:**

1. **ClientMain.lua**
   - Crea un LocalScript llamado `ClientMain`
   - Copia el código de: `StarterPlayer/StarterPlayerScripts/ClientMain.lua`

2. **CustomGUIHandler.lua**
   - Crea un LocalScript llamado `CustomGUIHandler`
   - Copia el código de: `StarterPlayer/StarterPlayerScripts/CustomGUIHandler.lua`
   - ⚠️ **IMPORTANTE:** Personaliza las rutas según tu GUI (ver sección de GUIs)

---

## 🎨 CONECTAR TUS GUIs PERSONALIZADAS

### **Elementos GUI Necesarios:**

Tu ScreenGui debe tener estos elementos (puedes usar los nombres que quieras):

1. **SpeedLabel** (TextLabel)
   - Muestra la velocidad actual

2. **SprintButton** (TextButton)
   - Botón para activar sprint en móvil
   - Se oculta automáticamente en PC

3. **ReviveButton** (TextButton)
   - Botón para revivir
   - Se muestra solo cuando el jugador está muerto

### **Configurar CustomGUIHandler.lua:**

Abre `CustomGUIHandler.lua` y modifica estas líneas:

```lua
-- CONFIGURACIÓN DE RUTAS - PERSONALIZA AQUÍ

-- Nombre de tu ScreenGui
local SCREEN_GUI_NAME = "MainGui" -- Cambia esto

-- Nombres de tus elementos
local SPEED_LABEL_NAME = "SpeedLabel" -- Cambia esto
local SPRINT_BUTTON_NAME = "SprintButton" -- Cambia esto
local REVIVE_BUTTON_NAME = "ReviveButton" -- Cambia esto
```

**Ejemplo:** Si tu GUI se llama "MyAwesomeGUI" y tu label se llama "VelocityText":

```lua
local SCREEN_GUI_NAME = "MyAwesomeGUI"
local SPEED_LABEL_NAME = "VelocityText"
```

---

## ⚙️ CONFIGURACIÓN

Abre `ReplicatedStorage/Modules/Config.lua` para personalizar:

### **Velocidad**
```lua
Config.BaseWalkSpeed = 16 -- Velocidad base al caminar
Config.BaseSprintSpeed = 16 -- Velocidad base al correr
```

### **Orbs**
```lua
Config.OrbSpawnLocations = {
    Vector3.new(0, 5, 0),
    Vector3.new(10, 5, 10),
    -- Añade más posiciones aquí
}

Config.OrbSpeedBoost = 1 -- Velocidad por orb
Config.OrbMoneyReward = 10 -- Dinero por orb
Config.OrbRespawnTime = 30 -- Segundos para respawn
```

### **Economía**
```lua
Config.StartingMoney = 0
Config.StartingRebirths = 0
Config.RebirthCost = 1000
Config.RebirthSpeedMultiplier = 1.5
```

---

## 🎮 USO DEL SISTEMA

### **Para Jugadores:**

**PC:**
- Presiona `SHIFT` para correr más rápido
- Recoge orbs amarillas para aumentar velocidad permanentemente
- Usa el botón de revivir cuando mueras

**Móvil:**
- Toca el botón de Sprint para correr
- Recoge orbs amarillas para aumentar velocidad
- Usa el botón de revivir cuando mueras

### **Para Desarrolladores:**

#### **Acceder a los Módulos desde otros scripts:**

```lua
-- Obtener velocidad acumulada del jugador
local speedBoost = _G.PlayerOrbsManager:GetSpeedBoost()

-- Verificar si está en sprint
local isSprinting = _G.PlayerSprintManager:IsSprinting()

-- Activar/desactivar sprint
_G.PlayerSprintManager:SetSprinting(true)
_G.PlayerSprintManager:ToggleSprint()

-- Resetear velocidad (útil para rebirth)
_G.PlayerOrbsManager:ResetSpeed()
```

#### **Hacer Rebirth desde un script:**

```lua
-- En el CLIENTE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local performRebirthEvent = ReplicatedStorage.RemoteEvents.PerformRebirth
performRebirthEvent:FireServer()
```

#### **Revivir desde un script:**

```lua
-- En el CLIENTE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local reviveEvent = ReplicatedStorage.RemoteEvents.RevivePlayer
reviveEvent:FireServer()
```

---

## 🔧 PERSONALIZACIÓN AVANZADA

### **Cambiar el Color de las Orbs:**

En `Config.lua`:
```lua
Config.OrbColor = Color3.fromRGB(255, 255, 0) -- Amarillo
```

### **Cambiar la Tecla de Sprint:**

En `Config.lua`:
```lua
Config.SprintKey = Enum.KeyCode.LeftShift -- SHIFT izquierdo
-- Puedes usar: LeftControl, Space, etc.
```

### **Añadir Efectos Visuales a las Orbs:**

Edita `OrbsModule.lua` en la función `CreateOrb`:

```lua
-- Añadir partículas
local particles = Instance.new("ParticleEmitter")
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Parent = orb
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### **Las Orbs no aparecen:**

1. Verifica que `ClientMain.lua` esté en `StarterPlayer/StarterPlayerScripts`
2. Revisa la Consola (F9) para errores
3. Verifica que las posiciones en `Config.OrbSpawnLocations` sean válidas

### **El Sprint no funciona:**

1. Verifica que `SprintModule.lua` esté en `ReplicatedStorage/Modules`
2. Asegúrate de que `ClientMain.lua` se esté ejecutando
3. Revisa la Consola para errores

### **La GUI no se actualiza:**

1. Verifica los nombres de los elementos en `CustomGUIHandler.lua`
2. Asegúrate de que `CustomGUIHandler.lua` esté en el LocalScript correcto
3. Verifica que el `SCREEN_GUI_NAME` coincida con tu GUI

### **Los eventos no funcionan:**

1. Verifica que `RemoteEventsSetup.lua` se ejecutó (revisa Output)
2. Asegúrate de que los RemoteEvents están en `ReplicatedStorage/RemoteEvents`
3. Verifica que `ServerEventsHandler.lua` esté activo

---

## 📊 LEADERSTATS

El sistema crea automáticamente estas estadísticas para cada jugador:

- **Money**: Dinero acumulado
- **Rebirths**: Número de renacimientos

Puedes acceder a ellas así:

```lua
local player = game.Players.LocalPlayer
local money = player.leaderstats.Money.Value
local rebirths = player.leaderstats.Rebirths.Value
```

---

## 🔒 SEGURIDAD

El sistema incluye:

- ✅ Validación de datos en el servidor
- ✅ Cooldown anti-spam para orbs
- ✅ Verificación de existencia de jugadores
- ✅ Prevención de exploits comunes

---

## 📝 NOTAS IMPORTANTES

1. **NO modifiques** `Humanoid.WalkSpeed` directamente en otros scripts, usa el sistema de sprint
2. **Las orbs son solo visibles para cada cliente**, no afectan a otros jugadores
3. **El auto-revivir** está configurado para 5 segundos (puedes cambiarlo en Config)
4. **Los RemoteEvents** se crean automáticamente al iniciar el juego

---

## 🎯 PRÓXIMOS PASOS

1. Personaliza las posiciones de las orbs en `Config.lua`
2. Crea tus GUIs personalizadas y conéctalas con `CustomGUIHandler.lua`
3. Ajusta los valores de velocidad, dinero y rebirth según tu juego
4. Añade efectos visuales y sonidos a tu gusto

---

## 📞 SOPORTE

Si encuentras problemas:

1. Revisa la sección de **Solución de Problemas**
2. Verifica la Consola (F9) en Roblox Studio
3. Asegúrate de haber seguido todos los pasos de instalación
4. Verifica que todos los archivos estén en las ubicaciones correctas

---

## ✨ CRÉDITOS

Sistema creado con las mejores prácticas de Roblox:
- Optimizado para rendimiento
- Sin warnings
- Código limpio y documentado
- Seguro contra exploits comunes

---

**¡Disfruta tu sistema de orbs de velocidad!** 🚀
