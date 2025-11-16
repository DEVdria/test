# 💰 Sistema Completo de Dinero para Roblox

Sistema completo de dinero con leaderstats, UI, **tienda física**, cofres con ProximityPrompt, **leaderboard físico** y guardado de datos.

---

## 📋 Tabla de Contenidos

1. [Características](#características)
2. [Estructura de Archivos](#estructura-de-archivos)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Configuración de Elementos Físicos](#configuración-de-elementos-físicos)
5. [Personalización](#personalización)
6. [Solución de Problemas](#solución-de-problemas)

---

## ✨ Características

✅ **Leaderstats automático** - Carpeta leaderstats con estadística Money creada automáticamente
✅ **UI de dinero** - Muestra el dinero del jugador en tiempo real en pantalla
✅ **Sistema de cofres** - ProximityPrompt en cofres que otorgan dinero
✅ **Tienda física** - Stand físico en el mundo donde comprar items
✅ **Leaderboard físico** - Panel físico mostrando top jugadores
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
│   └── LeaderboardHandler.lua         ← Leaderboard global (backend)
│
├── ReplicatedStorage/
│   └── RemoteEvents/                  ← (Se crea automáticamente)
│       ├── GetShopItems
│       ├── PurchaseItem
│       └── GetLeaderboard
│
├── StarterGui/
│   └── MoneyUI/
│       ├── MoneyDisplay.lua           ← UI de dinero (LocalScript)
│       └── INSTRUCCIONES_UI.txt
│
└── Workspace/
    ├── LeaderboardPhysical/
    │   ├── LeaderboardPhysical.lua    ← Script para panel físico
    │   └── INSTRUCCIONES_LEADERBOARD_FISICO.txt
    │
    └── ShopPhysical/
        ├── ShopPhysical.lua           ← Script para tienda física
        └── INSTRUCCIONES_TIENDA_FISICA.txt
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

### **Paso 2: Configurar UI de Dinero (en pantalla)**

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

### **Paso 3: Crear Leaderboard Físico**

1. Ve al **Workspace**
2. Crea una **Part** y nómbrala `LeaderboardBoard`
3. Configura la Part:
   - Size: **16, 20, 1** (ancho, alto, profundidad)
   - Material: SmoothPlastic
   - Color: Negro o gris oscuro
   - **Anchored: true** (¡IMPORTANTE!)
   - CanCollide: false
4. Posiciónala en un lugar visible (ej: cerca del spawn)
5. Inserta el script `LeaderboardPhysical.lua` como **Script** dentro de la Part

**El script creará automáticamente:**
- SurfaceGui con el top de jugadores
- Título "🏆 TOP JUGADORES 🏆"
- Medallas para los primeros 3 lugares

📝 **Ver detalles completos en**: `Workspace/LeaderboardPhysical/INSTRUCCIONES_LEADERBOARD_FISICO.txt`

### **Paso 4: Crear Tienda Física**

1. Ve al **Workspace**
2. Crea una **Part** y nómbrala `ShopStand`
3. Configura la Part:
   - Size: **18, 14, 1** (ancho, alto, profundidad)
   - Material: SmoothPlastic
   - Color: Azul o tu preferencia
   - **Anchored: true** (¡IMPORTANTE!)
   - CanCollide: true
4. Posiciónala donde quieras la tienda
5. Inserta el script `ShopPhysical.lua` como **Script** dentro de la Part

**El script creará automáticamente:**
- SurfaceGui mostrando todos los items
- ProximityPrompts para comprar cada item
- Sistema de catálogo completo

**Cómo comprar:**
- Acércate a la tienda (dentro de 10 studs)
- Aparecerán prompts para cada item
- Mantén E presionado en el item que quieras comprar

📝 **Ver detalles completos en**: `Workspace/ShopPhysical/INSTRUCCIONES_TIENDA_FISICA.txt`

### **Paso 5: Crear Cofre en el Workspace**

1. Ve al **Workspace**
2. Crea una **Part** y nómbrala `Chest`
3. (Opcional) Inserta un **ProximityPrompt** dentro de la Part
   - Si no lo haces, el script lo creará automáticamente
4. Personaliza el cofre como quieras (tamaño, color, etc.)
5. **Anchored: true** (para que no se caiga)

---

## 🎨 Configuración de Elementos Físicos

### **Leaderboard Físico**

El leaderboard es un panel físico en el mundo que muestra:
- 🥇 Top 1 con medalla de oro
- 🥈 Top 2 con medalla de plata
- 🥉 Top 3 con medalla de bronce
- Hasta 10 jugadores en total
- Actualización automática cada 30 segundos

**Personalización:**
- Cambia el tamaño de la Part para mejor visibilidad
- Ajusta la propiedad `Face` del SurfaceGui para cambiar la cara visible
- Modifica `PlayersToShow` en el script para mostrar más/menos jugadores
- Agrega PointLights para iluminación dramática

### **Tienda Física**

La tienda es un stand físico que muestra todos los items disponibles:
- Grid con todos los items
- Nombre, descripción y precio de cada item
- ProximityPrompts individuales para cada compra
- Scroll automático si hay muchos items

**Cómo funciona:**
1. Los jugadores se acercan a la tienda
2. Ven todos los items disponibles en la pantalla
3. Aparecen ProximityPrompts al estar cerca
4. Presionan E para comprar el item deseado
5. Reciben confirmación o mensaje de error

**Agregar items:**
Edita `ServerScriptService/ShopHandler.lua` en la tabla `SHOP_ITEMS`:

```lua
{
    ItemId = "mi_item",
    Name = "Mi Item Personalizado",
    Description = "Descripción del item",
    Price = 500,
    Category = "Categoría",
    ImageId = "rbxassetid://123456", -- Opcional
    OnPurchase = function(player)
        -- Lo que sucede al comprar
        print(player.Name .. " compró mi item")
        -- Ejemplo: dar tool, aumentar stats, etc.
    end
}
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
-- En ServerScriptService/LeaderboardHandler.lua (backend)
UpdateInterval = 60,  -- Segundos entre actualizaciones

-- En Workspace/LeaderboardBoard/LeaderboardPhysical.lua (visual)
UpdateInterval = 30,  -- Segundos entre refrescos visuales
PlayersToShow = 10,   -- Cuántos jugadores mostrar
```

### **Distancia de la Tienda**

```lua
-- En Workspace/ShopStand/ShopPhysical.lua
MaxDistance = 10,  -- Distancia en studs para activar prompts
HoldDuration = 1,  -- Segundos para mantener E presionado
```

---

## 🔧 Solución de Problemas

### **El dinero no se guarda**

1. Asegúrate de que **Studio Access to API Services** esté habilitado:
   - `Game Settings > Security > Enable Studio Access to API Services`
2. Publica tu juego en Roblox
3. Verifica la consola del servidor para errores de DataStore

### **La UI de dinero no aparece**

1. Verifica que los scripts estén en la ubicación correcta
2. Asegúrate de que sea **LocalScript** en StarterGui
3. Revisa la consola del cliente (F9 en el juego) para errores

### **El leaderboard físico no se muestra**

1. Verifica que la Part se llame exactamente `LeaderboardBoard`
2. Asegúrate de que el script sea **Script** normal (NO LocalScript)
3. Verifica que `LeaderboardHandler.lua` esté en ServerScriptService
4. Comprueba que la Part tenga `Anchored = true`
5. Revisa Output para errores
6. Espera 30 segundos para la primera actualización

### **La tienda física está vacía**

1. Verifica que la Part se llame exactamente `ShopStand`
2. Asegúrate de que `ShopHandler.lua` esté en ServerScriptService
3. Verifica que haya items en la tabla SHOP_ITEMS
4. Revisa que `ReplicatedStorage/RemoteEvents` se haya creado
5. Comprueba la consola del servidor para errores

### **Los ProximityPrompts no aparecen en la tienda**

1. Acércate más a la tienda (máximo 10 studs de distancia)
2. Verifica que la Part tenga `CanCollide = true`
3. Asegúrate de estar en modo juego (no en modo edición)
4. Revisa que los items se hayan cargado correctamente

### **El cofre no funciona**

1. Verifica que la Part se llame exactamente `Chest`
2. Asegúrate de que el script `ChestReward.lua` esté en ServerScriptService
3. Verifica que la Part tenga `Anchored = true`
4. Revisa la consola del servidor para mensajes de error

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
- Los ProximityPrompts se manejan server-side

### **Elementos Físicos**

- **SIEMPRE** usa `Anchored = true` en las Parts
- Los scripts de elementos físicos deben ser Scripts normales (NO LocalScripts)
- Los SurfaceGui se crean automáticamente por los scripts
- Ajusta el tamaño de las Parts para mejor visibilidad

---

## 🎮 Uso en el Juego

### **Para Jugadores:**

1. **Ver dinero**: Se muestra automáticamente en la parte superior de la pantalla
2. **Ver leaderboard**: Ve al panel físico del leaderboard en el mundo
3. **Comprar items**: Ve a la tienda física, acércate y presiona E en el item deseado
4. **Abrir cofres**: Acércate a un cofre y presiona E
5. **Dinero se guarda**: Automáticamente cada 5 minutos y al salir

### **Para Desarrolladores:**

```lua
-- Obtener el dinero de un jugador
local money = player.leaderstats.Money.Value

-- Dar dinero a un jugador
player.leaderstats.Money.Value = player.leaderstats.Money.Value + 100

-- Quitar dinero a un jugador
player.leaderstats.Money.Value = player.leaderstats.Money.Value - 50

-- Verificar si un jugador puede comprar algo
local function canAfford(player, price)
    return player.leaderstats.Money.Value >= price
end
```

---

## 🆘 Soporte

Si tienes problemas:

1. Revisa la **consola del servidor** (View > Output en Studio)
2. Revisa la **consola del cliente** (F9 en el juego)
3. Lee los archivos `INSTRUCCIONES_*.txt` de cada carpeta
4. Verifica que todos los nombres coincidan exactamente
5. Asegúrate de que todas las Parts físicas tengan `Anchored = true`

---

## 📄 Licencia

Este sistema es de uso libre para tu proyecto de Roblox.

---

## ✅ Lista de Verificación Final

Antes de probar tu juego, asegúrate de:

- [ ] Todos los scripts del servidor están en ServerScriptService
- [ ] MoneyDisplay.lua (LocalScript) está en StarterGui/MoneyUI
- [ ] Existe una Part "LeaderboardBoard" en Workspace con su script
- [ ] Existe una Part "ShopStand" en Workspace con su script
- [ ] Existe una Part "Chest" en el Workspace
- [ ] TODAS las Parts físicas tienen `Anchored = true`
- [ ] Studio Access to API Services está habilitado
- [ ] El juego está publicado en Roblox (para DataStore)

---

## 🎨 Ideas de Construcción

### **Para el Leaderboard:**
- Construye un podio con 3 niveles para los top 3
- Agrega un marco dorado alrededor del panel
- Coloca PointLights con color dorado
- Crea una sala especial "Hall de la Fama"

### **Para la Tienda:**
- Construye un edificio o stand alrededor de la Part
- Agrega un mostrador frontal
- Coloca carteles decorativos
- Agrega NPCs vendedores (Models)
- Crea diferentes secciones de tienda con múltiples stands

### **Para los Cofres:**
- Duplica la Part Chest en varios lugares del mapa
- Usa diferentes colores para diferentes recompensas
- Agrega ParticleEmitters para efectos brillantes
- Coloca en lugares estratégicos o escondidos

---

¡Disfruta tu sistema de dinero completo con elementos físicos! 💰🎮
