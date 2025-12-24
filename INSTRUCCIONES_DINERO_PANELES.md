# 💰 SISTEMA DE DINERO PARA PANELES DE CRISTAL

## 📋 RESUMEN DE CAMBIOS

Se ha agregado un sistema de recompensas de dinero a los paneles de cristal. Cada nivel da una cantidad configurable de dinero cuando pisas sus paneles.

### ✨ Características Nuevas:

1. **Recompensas configurables por nivel**
   - Nivel 1 = 1 de dinero
   - Nivel 2 = 2 de dinero
   - Y así sucesivamente (puedes configurarlo en LEVELS)

2. **Dos SurfaceGui en cada panel:**
   - **Arriba (Top)**: Muestra el tiempo de caída
   - **Lado derecho (Right)**: Muestra el dinero que da (💰 rotado 90°)

3. **Sistema anti-exploit:**
   - Cooldown de 0.5 segundos por panel
   - Validación de cantidad máxima (1000)
   - Validación de existencia del panel

## 📦 ARCHIVOS CREADOS

### 1. `ServerScriptService_MultiLevelGlassPanelSetup_MODIFIED.lua`
**Ubicación:** ServerScriptService → Script normal

**Cambios:**
- Agregado `moneyReward` en cada nivel del array `LEVELS`
- Función `createTimerDisplay()` ahora crea 2 SurfaceGui:
  - Top: Tiempo de caída
  - Right: Dinero (rotado 90°)
- Los paneles ahora tienen atributos `MoneyReward` y `LevelName`
- Crea el RemoteEvent `GivePanelMoney`

### 2. `ServerScriptService_GlassPanelMoneyHandler.lua`
**Ubicación:** ServerScriptService → Script normal

**Qué hace:**
- Escucha el RemoteEvent `GivePanelMoney`
- Valida el panel y la cantidad de dinero
- Implementa anti-exploit con cooldown
- Llama a `DataManager.AddMoney()` para dar el dinero

### 3. Modificaciones al Cliente

En tu `MultiLevelGlassPanelClient.lua` existente, necesitas agregar:

#### Al inicio del script (después de las importaciones):

```lua
-- RemoteEvent para dar dinero
local givePanelMoneyEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GivePanelMoney", 10)
if not givePanelMoneyEvent then
	warn("⚠️ No se encontró RemoteEvent 'GivePanelMoney'")
end
```

#### En la función `activatePanel()`, justo después de marcar el panel como activo:

```lua
-- Marcar como activo
data.isActive = true
data.startTime = tick()

-- 💰 NUEVO: Dar dinero al pisar el panel
if givePanelMoneyEvent and panel then
	local moneyReward = panel:GetAttribute("MoneyReward")
	if moneyReward and moneyReward > 0 then
		givePanelMoneyEvent:FireServer(panel)
		print(string.format("💰 %s - PANEL %d: Solicitando %d de dinero", levelName, panelNumber, moneyReward))
	end
end
```

## 🔧 CÓMO CONFIGURAR EL DINERO POR NIVEL

En el archivo `ServerScriptService_MultiLevelGlassPanelSetup_MODIFIED.lua`, edita el array `LEVELS`:

```lua
{
	name = "Level1",
	numPanels = 32,
	moneyReward = 1,  -- 💰 CAMBIA ESTE VALOR

	timeGroups = { ... },
	-- resto de la configuración
},
```

**Ejemplos:**
- `moneyReward = 1` → Da 1 de dinero por panel
- `moneyReward = 5` → Da 5 de dinero por panel
- `moneyReward = 100` → Da 100 de dinero por panel

## 🎨 CÓMO SE VE

### Vista Superior (Top):
```
┌──────────┐
│  3.5 ⏱️  │  ← Tiempo de caída
└──────────┘
```

### Vista Lateral Derecha (Right):
```
│
│ 💰 5
│
│
```
(El texto está rotado 90° a la derecha)

## 🚀 PASOS DE INSTALACIÓN

### 1. **Servidor - Crear Paneles**
```
1. Elimina los paneles existentes si los hay
2. Pega ServerScriptService_MultiLevelGlassPanelSetup_MODIFIED.lua en ServerScriptService
3. Ejecuta el juego UNA VEZ
4. Espera a que termine de crear los 20 niveles
5. ELIMINA el script de setup
```

### 2. **Servidor - Manejador de Dinero**
```
1. Pega ServerScriptService_GlassPanelMoneyHandler.lua en ServerScriptService
2. Este script se queda permanentemente (NO lo elimines)
```

### 3. **Cliente - Modificaciones**
```
1. Abre tu MultiLevelGlassPanelClient.lua existente
2. Agrega el código del RemoteEvent al inicio
3. Agrega el código de dar dinero en activatePanel()
4. Guarda el archivo
```

### 4. **Probar**
```
1. Ejecuta el juego
2. Camina sobre los paneles
3. Deberías ver en el output:
   "💰 Level1 - PANEL 1: Solicitando 1 de dinero"
4. Tu dinero debería aumentar
```

## ⚠️ PROBLEMAS COMUNES

### El dinero no se da:
- ✅ Verifica que `DataManager` esté cargado y funcione
- ✅ Verifica que `DataManager.AddMoney()` exista
- ✅ Revisa el output del servidor para ver errores
- ✅ Asegúrate de que el RemoteEvent se creó correctamente

### Los SurfaceGui no se ven:
- ✅ Los SurfaceGui se ven mejor desde arriba/lateral
- ✅ Verifica que `LightInfluence = 0` esté configurado
- ✅ El texto de dinero está en el lado RIGHT del panel

### El cooldown es muy estricto:
- Puedes cambiar `PANEL_COOLDOWN = 0.5` a un valor menor en `GlassPanelMoneyHandler.lua`
- Ejemplo: `PANEL_COOLDOWN = 0.2` para 200ms

## 💡 MEJORAS OPCIONALES

### Cambiar el color del dinero según el nivel:
```lua
-- En createTimerDisplay(), línea del BackgroundColor3:
moneyText.BackgroundColor3 = levelConfig.color  -- Usa el color del nivel
```

### Agregar sonido al recibir dinero:
```lua
-- En el cliente, después de FireServer:
local moneySound = Instance.new("Sound")
moneySound.SoundId = "rbxassetid://5153510693"  -- Sonido de moneda
moneySound.Volume = 0.3
moneySound.Parent = workspace
moneySound:Play()
moneySound.Ended:Connect(function()
	moneySound:Destroy()
end)
```

### Mostrar notificación visual:
Puedes integrar con tu sistema de notificaciones existente para mostrar "+X 💰" flotante.

## 📊 EJEMPLO DE CONFIGURACIÓN COMPLETA

```lua
-- Nivel fácil: Poco dinero
{
	name = "Level1",
	numPanels = 32,
	moneyReward = 1,  -- Solo 1 de dinero
	-- ...
},

-- Nivel medio: Más dinero
{
	name = "Level10",
	numPanels = 25,
	moneyReward = 50,  -- 50 de dinero por panel
	-- ...
},

-- Nivel difícil: Mucho dinero
{
	name = "Level20",
	numPanels = 7,
	moneyReward = 500,  -- 500 de dinero por panel (alta recompensa)
	-- ...
},
```

## ✅ RESUMEN

Con este sistema, cada vez que un jugador pisa un panel:
1. El cliente detecta que pisó el panel
2. Dispara el RemoteEvent `GivePanelMoney` con el panel
3. El servidor valida el panel y la cantidad
4. El servidor da el dinero usando `DataManager.AddMoney()`
5. El jugador recibe el dinero

Todo con anti-exploit incluido y completamente configurable.
