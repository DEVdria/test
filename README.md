# 💰 Sistema Completo de Dinero para Roblox

Sistema completo de dinero con leaderstats, UI, tienda, cofres con ProximityPrompt, leaderboard global y guardado de datos.

---

## 📋 Tabla de Contenidos

1. [Características](#características)
2. [Estructura de Archivos](#estructura-de-archivos)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Configuración de UI](#configuración-de-ui)
5. [Personalización](#personalización)
6. [Solución de Problemas](#solución-de-problemas)

---

## ✨ Características

✅ **Leaderstats automático** - Carpeta leaderstats con estadística Money creada automáticamente
✅ **UI de dinero** - Muestra el dinero del jugador en tiempo real
✅ **Sistema de cofres** - ProximityPrompt en cofres que otorgan dinero
✅ **Tienda funcional** - Compra items con tu dinero
✅ **Leaderboard global** - Muestra los jugadores con más dinero
✅ **Guardado de datos** - DataStore que guarda el dinero al salir
✅ **Sistema de cooldown** - Evita spam en los cofres
✅ **Protección contra exploits** - Validación en el servidor

---

## 📁 Estructura de Archivos

```
Roblox Game/
│
├── ServerScriptService/
│   ├── PlayerDataManager.lua          ← Leaderstats + DataStore
│   ├── ChestReward.lua                ← Sistema de cofres
│   ├── ShopHandler.lua                ← Lógica de la tienda
│   └── LeaderboardHandler.lua         ← Leaderboard global
│
├── ReplicatedStorage/
│   └── RemoteEvents/                  ← (Se crea automáticamente)
│       ├── GetShopItems
│       ├── PurchaseItem
│       └── GetLeaderboard
│
└── StarterGui/
    ├── MoneyUI/
    │   ├── MoneyDisplay.lua           ← UI de dinero (LocalScript)
    │   └── INSTRUCCIONES_UI.txt
    │
    ├── ShopUI/
    │   ├── ShopClient.lua             ← UI de tienda (LocalScript)
    │   └── INSTRUCCIONES_SHOP.txt
    │
    └── LeaderboardUI/
        ├── LeaderboardClient.lua      ← UI de leaderboard (LocalScript)
        └── INSTRUCCIONES_LEADERBOARD.txt
```

---

## 🚀 Instalación Paso a Paso

### **Paso 1: Scripts del Servidor**

1. Ve a **ServerScriptService** en Roblox Studio
2. Crea los siguientes **Scripts** (normales, NO LocalScripts):
   - `PlayerDataManager.lua`
   - `ChestReward.lua`
   - `ShopHandler.lua`
   - `LeaderboardHandler.lua`
3. Copia el contenido de cada archivo descargado a su respectivo script

### **Paso 2: Configurar UI de Dinero**

1. Ve a **StarterGui**
2. Crea un **ScreenGui** llamado `MoneyUI`
3. Dentro de MoneyUI:
   - Crea un **TextLabel** llamado `MoneyLabel`
   - Inserta el script `MoneyDisplay.lua` como **LocalScript** dentro de MoneyUI

**Propiedades recomendadas de MoneyLabel:**
```
- Text: "$0"
- Size: {0, 200},{0, 50}
- Position: {0.5, -100},{0.02, 0}
- BackgroundColor3: RGB(0, 0, 0)
- BackgroundTransparency: 0.3
- TextColor3: RGB(255, 215, 0)
- TextScaled: true
- Font: GothamBold
```

### **Paso 3: Configurar UI de Tienda**

1. En **StarterGui**, crea un **ScreenGui** llamado `ShopUI`
2. Dentro de ShopUI:
   - Crea un **Frame** llamado `ShopFrame`
   - Dentro de ShopFrame:
     - Crea un **ScrollingFrame** llamado `ItemsContainer`
     - Crea un **TextButton** llamado `CloseButton` (texto: "X")
   - Crea un **TextButton** llamado `OpenButton` (texto: "🛒 Tienda")
3. Inserta `ShopClient.lua` como **LocalScript** dentro de ShopUI

**Configuración rápida:**
- ShopFrame: Size `{0.6, 0},{0.7, 0}`, Visible = `false`
- OpenButton: Position `{0.5, -60},{0, 10}`, Size `{0, 120},{0, 50}`

### **Paso 4: Configurar UI de Leaderboard**

1. En **StarterGui**, crea un **ScreenGui** llamado `LeaderboardUI`
2. Dentro de LeaderboardUI:
   - Crea un **Frame** llamado `LeaderboardFrame`
   - Dentro de LeaderboardFrame:
     - Crea un **TextLabel** llamado `TitleLabel` (texto: "🏆 TOP JUGADORES")
     - Crea un **ScrollingFrame** llamado `PlayersContainer`
3. Inserta `LeaderboardClient.lua` como **LocalScript** dentro de LeaderboardUI

**Configuración rápida:**
- LeaderboardFrame: Size `{0, 350},{0, 450}`, Position `{1, -360},{0, 10}`

### **Paso 5: Crear Cofre en el Workspace**

1. Ve al **Workspace**
2. Crea una **Part** y nómbrala `Chest`
3. (Opcional) Inserta un **ProximityPrompt** dentro de la Part
   - Si no lo haces, el script lo creará automáticamente
4. Personaliza el cofre como quieras (tamaño, color, etc.)

---

## 🎨 Configuración de UI

### **UI de Dinero (MoneyUI)**

Para personalizar la apariencia del label de dinero:

```lua
-- En MoneyDisplay.lua, puedes cambiar:
moneyLabel.Text = "💰 $" .. formatNumber(money.Value)
-- Por ejemplo, cambiar el emoji o el formato
```

### **UI de Tienda (ShopUI)**

Para agregar items a la tienda, edita `ServerScriptService/ShopHandler.lua`:

```lua
-- En la tabla SHOP_ITEMS, agrega:
{
    ItemId = "mi_item",
    Name = "Mi Item",
    Description = "Descripción de mi item",
    Price = 500,
    Category = "Categoría",
    OnPurchase = function(player)
        -- Código cuando se compra
        print(player.Name .. " compró mi item")
    end
}
```

### **UI de Leaderboard (LeaderboardUI)**

Para cambiar cuántos jugadores se muestran en el top:

```lua
-- En ServerScriptService/LeaderboardHandler.lua
TopPlayersCount = 10, -- Cambia este número
```

---

## ⚙️ Personalización

### **Dinero Inicial**

```lua
-- En ServerScriptService/PlayerDataManager.lua
local DEFAULT_MONEY = 100 -- Cambia este valor
```

### **Recompensa del Cofre**

```lua
-- En ServerScriptService/ChestReward.lua
MinReward = 50,      -- Dinero mínimo
MaxReward = 200,     -- Dinero máximo
CooldownTime = 60,   -- Segundos de cooldown
```

### **Frecuencia de Guardado**

```lua
-- En ServerScriptService/PlayerDataManager.lua
AUTO_SAVE_INTERVAL = 300 -- Segundos (5 minutos por defecto)
```

### **Actualización del Leaderboard**

```lua
-- En ServerScriptService/LeaderboardHandler.lua
UpdateInterval = 60,  -- Segundos entre actualizaciones
```

---

## 🔧 Solución de Problemas

### **El dinero no se guarda**

1. Asegúrate de que **Studio Access to API Services** esté habilitado:
   - `Game Settings > Security > Enable Studio Access to API Services`
2. Publica tu juego en Roblox
3. Verifica la consola del servidor para errores de DataStore

### **La UI no aparece**

1. Verifica que los scripts estén en la ubicación correcta
2. Asegúrate de que sean **LocalScripts** los de StarterGui
3. Revisa la consola del cliente (F9 en el juego) para errores

### **El cofre no funciona**

1. Verifica que la Part se llame exactamente `Chest`
2. Asegúrate de que el script `ChestReward.lua` esté en ServerScriptService
3. Revisa la consola del servidor para mensajes de error

### **La tienda está vacía**

1. Verifica que `ShopHandler.lua` esté en ServerScriptService
2. Asegúrate de que `ReplicatedStorage/RemoteEvents` se haya creado
3. Revisa la consola del cliente y servidor para errores

### **El leaderboard no se actualiza**

1. Verifica que `LeaderboardHandler.lua` esté en ServerScriptService
2. Asegúrate de que los DataStores estén habilitados (ver primer problema)
3. Espera al menos 30 segundos para la primera actualización

---

## 📝 Notas Importantes

### **DataStore en Studio**

- Los DataStores solo funcionan si publicas tu juego
- En modo de prueba local, pueden no funcionar correctamente
- Habilita "Enable Studio Access to API Services" en Game Settings

### **RemoteEvents**

- Se crean automáticamente por los scripts
- No necesitas crearlos manualmente
- Se encuentran en `ReplicatedStorage/RemoteEvents`

### **Seguridad**

- Toda la lógica importante está en el servidor
- Los clientes solo pueden solicitar datos, no modificarlos directamente
- El sistema valida todas las compras en el servidor

---

## 🎮 Uso en el Juego

### **Para Jugadores:**

1. **Ver dinero**: Se muestra automáticamente en la parte superior
2. **Abrir tienda**: Presiona `E` o haz clic en el botón "🛒 Tienda"
3. **Comprar items**: Haz clic en el botón verde con el precio
4. **Abrir cofres**: Acércate a un cofre y presiona `E`
5. **Ver leaderboard**: Siempre visible en la esquina superior derecha

### **Para Desarrolladores:**

```lua
-- Obtener el dinero de un jugador
local money = player.leaderstats.Money.Value

-- Dar dinero a un jugador
player.leaderstats.Money.Value = player.leaderstats.Money.Value + 100

-- Quitar dinero a un jugador
player.leaderstats.Money.Value = player.leaderstats.Money.Value - 50
```

---

## 🆘 Soporte

Si tienes problemas:

1. Revisa la **consola del servidor** (View > Output en Studio)
2. Revisa la **consola del cliente** (F9 en el juego)
3. Lee los archivos `INSTRUCCIONES_*.txt` de cada carpeta
4. Verifica que todos los nombres coincidan exactamente

---

## 📄 Licencia

Este sistema es de uso libre para tu proyecto de Roblox.

---

## ✅ Lista de Verificación Final

Antes de probar tu juego, asegúrate de:

- [ ] Todos los scripts del servidor están en ServerScriptService
- [ ] Todos los LocalScripts de UI están en StarterGui
- [ ] Los ScreenGuis tienen los nombres correctos (MoneyUI, ShopUI, LeaderboardUI)
- [ ] Existe una Part llamada "Chest" en el Workspace
- [ ] Studio Access to API Services está habilitado
- [ ] El juego está publicado en Roblox

---

¡Disfruta tu sistema de dinero completo! 💰🎮