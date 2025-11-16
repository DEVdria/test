# 💰 Sistema Completo de Dinero para Roblox

Sistema profesional y completo de gestión de dinero para juegos de Roblox, incluyendo leaderstats, DataStore, UI, cofres, tienda y leaderboard global.

---

## 📋 Características

✅ **Leaderstats automáticos** - Carpeta leaderstats con estadística "Money" para cada jugador
✅ **UI de dinero** - Interfaz visual que muestra el dinero en tiempo real
✅ **Sistema de cofres** - ProximityPrompt para recolectar dinero de cofres
✅ **Tienda física** - Sistema de compras con interfaz visual
✅ **Leaderboard global** - Tabla clasificatoria que muestra a los jugadores más ricos
✅ **Guardado de datos** - DataStore para persistencia de dinero entre sesiones
✅ **Notificaciones** - Sistema de mensajes en pantalla

---

## 📁 Estructura de Archivos

```
ServerScriptService/
├── MoneyManager.lua          → Gestión de leaderstats y DataStore
├── ChestScript.lua           → Sistema de cofres con recompensas
├── ShopScript.lua            → Sistema de tienda
└── LeaderboardScript.lua     → Leaderboard físico global

StarterPlayer/StarterPlayerScripts/
├── MoneyUI.lua               → Interfaz de dinero del jugador
├── NotificationHandler.lua   → Sistema de notificaciones
└── ShopUI.lua                → Interfaz de la tienda
```

---

## 🔧 Instalación Paso a Paso

### **1. Configurar Scripts del Servidor**

1. Abre **Roblox Studio**
2. Ve a **ServerScriptService**
3. Crea los siguientes scripts **Script** (NO LocalScript):
   - `MoneyManager`
   - `ChestScript`
   - `ShopScript`
   - `LeaderboardScript`

4. Copia el contenido de cada archivo desde la carpeta `ServerScriptService/` a su script correspondiente

**⚠️ IMPORTANTE:** `MoneyManager.lua` debe cargarse PRIMERO. Asegúrate de que esté en la parte superior de ServerScriptService.

---

### **2. Configurar Scripts del Cliente**

1. Ve a **StarterPlayer** → **StarterPlayerScripts**
2. Si no existe la carpeta `StarterPlayerScripts`, créala manualmente
3. Dentro de `StarterPlayerScripts`, crea estos **LocalScript**:
   - `MoneyUI`
   - `NotificationHandler`
   - `ShopUI`

4. Copia el contenido de cada archivo desde la carpeta `StarterPlayer/StarterPlayerScripts/`

---

### **3. Habilitar API de Studio**

Para que el DataStore funcione en pruebas de Studio:

1. Ve a **Home** → **Game Settings** (o presiona `Alt + S`)
2. Navega a **Security**
3. Activa la opción: **Enable Studio Access to API Services**
4. Haz clic en **Save**

---

### **4. Crear Objetos en el Mundo (Workspace)**

#### **A) Cofre del Tesoro**

1. Inserta una **Part** en Workspace
2. Nómbrala: `TreasureChest`
3. Personaliza su apariencia (color, tamaño, forma)
4. El script creará automáticamente el ProximityPrompt

**Opcional:** Añade manualmente un ProximityPrompt como hijo de la Part para mayor control.

#### **B) Tienda**

1. Inserta una **Part** en Workspace
2. Nómbrala: `ShopStand`
3. Personaliza su apariencia (puedes crear un edificio, mostrador, etc.)
4. El script creará automáticamente el ProximityPrompt

#### **C) Leaderboard Físico**

1. Inserta una **Part** en Workspace
2. Nómbrala: `LeaderboardDisplay`
3. Configura el tamaño recomendado:
   - **Tamaño:** `(12, 1, 16)` o mayor
   - **Material:** Neon o SmoothPlastic
   - **Color:** A tu gusto
4. Rota la Part para que mire hacia donde quieres que los jugadores lo vean
5. El script creará automáticamente el SurfaceGui en la cara frontal

---

## ⚙️ Configuración Personalizada

### **MoneyManager.lua**

```lua
-- Línea 10: Cambiar dinero inicial
local DEFAULT_MONEY = 100  -- Cambia este valor
```

### **ChestScript.lua**

```lua
-- Línea 22-23: Configurar recompensa y cooldown
local CHEST_REWARD = 50      -- Dinero que otorga cada cofre
local COOLDOWN_TIME = 30     -- Segundos de espera entre usos
```

### **ShopScript.lua**

```lua
-- Línea 23-53: Modificar productos de la tienda
local SHOP_ITEMS = {
    {
        Name = "Espada Básica",
        Price = 100,
        Description = "Una espada simple para empezar",
        Icon = "🗡️",
        ItemType = "Tool"
    },
    -- Añade más productos aquí...
}
```

### **LeaderboardScript.lua**

```lua
-- Línea 20-21: Configurar actualización y cantidad de jugadores
local UPDATE_INTERVAL = 10       -- Actualizar cada X segundos
local TOP_PLAYERS_COUNT = 10     -- Número de jugadores a mostrar
```

---

## 🎮 Cómo Usar en el Juego

### **Para Jugadores:**

1. **Dinero inicial:** Al unirse, cada jugador recibe $100 (configurable)
2. **Ver dinero:** Se muestra automáticamente en la esquina superior derecha
3. **Cofres:** Acércate a un cofre y presiona el botón para recolectar dinero
4. **Tienda:** Acércate a la tienda y ábrela para comprar objetos
5. **Leaderboard:** Observa la tabla para ver quién tiene más dinero

### **Funciones Globales (Para Desarrolladores):**

El script expone funciones globales que puedes usar en otros scripts:

```lua
-- Añadir dinero a un jugador
_G.MoneyManager.AddMoney(player, 100)

-- Remover dinero de un jugador
local success = _G.MoneyManager.RemoveMoney(player, 50)

-- Obtener dinero actual de un jugador
local money = _G.MoneyManager.GetMoney(player)

-- Guardar datos manualmente
_G.MoneyManager.SaveData(player)
```

---

## 🛠️ Personalizar Objetos que da la Tienda

Por defecto, la tienda crea herramientas vacías. Para dar objetos reales:

### **Método 1: Crear herramientas en ServerStorage**

1. Crea tus herramientas (espadas, pociones, etc.) en **ServerStorage**
2. Nómbralas exactamente como en `SHOP_ITEMS` (ej: "Espada Básica")
3. Modifica `ShopScript.lua` línea 87-90:

```lua
-- Descomentar estas líneas:
local toolTemplate = game.ServerStorage:FindFirstChild(itemName)
if toolTemplate then
    local toolClone = toolTemplate:Clone()
    toolClone.Parent = player.Backpack
end
```

### **Método 2: Dar efectos especiales**

Modifica la función `giveItemToPlayer` en `ShopScript.lua` para añadir efectos:

```lua
if itemName == "Botas de Velocidad" then
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 32  -- Aumentar velocidad
        end
    end
end
```

---

## 📊 Cómo Funciona el DataStore

- **Auto-guardado:** Cada 5 minutos
- **Guardado al salir:** Cuando el jugador abandona el juego
- **Carga al unirse:** Al entrar al juego
- **Reintentos:** 3 intentos en caso de fallo
- **Nombre del DataStore:** `PlayerMoney_V1`

**⚠️ Advertencia:** Si cambias el nombre del DataStore, perderás todos los datos guardados.

---

## 🎨 Personalización Visual

### **Colores de la UI:**

**MoneyUI.lua:**
- Línea 46: Color del fondo → `Color3.fromRGB(35, 35, 35)`
- Línea 101: Color del dinero → `Color3.fromRGB(85, 255, 127)`

**ShopUI.lua:**
- Línea 127: Color de fondo → `Color3.fromRGB(30, 30, 30)`
- Línea 139: Color de barra de título → `Color3.fromRGB(85, 255, 127)`

---

## 🐛 Solución de Problemas

### **El dinero no se guarda:**
1. Verifica que **Enable Studio Access to API Services** esté activado
2. Publica el juego (File → Publish to Roblox)
3. En un juego publicado, el DataStore funciona correctamente

### **No aparece la UI del dinero:**
- Verifica que `MoneyUI.lua` esté en `StarterPlayerScripts`
- Revisa la consola de salida (F9) para errores

### **Los cofres/tiendas no funcionan:**
- Asegúrate de que las Parts se llamen exactamente `TreasureChest` y `ShopStand`
- Verifica que `MoneyManager.lua` se esté ejecutando (debe aparecer mensaje en Output)

### **El leaderboard no se muestra:**
- Verifica que la Part se llame `LeaderboardDisplay`
- Asegúrate de que sea una **Part** (no un Model u otro tipo)
- Revisa que la cara frontal esté orientada correctamente

### **Error "MoneyManager no está disponible":**
- `MoneyManager.lua` debe ejecutarse ANTES que los otros scripts
- Reinicia el juego en Studio

---

## 📝 Notas Adicionales

- **Rendimiento:** Todos los scripts están optimizados para bajo uso de memoria
- **Seguridad:** Las validaciones de compra se hacen en el servidor (anti-explot)
- **Escalabilidad:** Soporta miles de jugadores sin problemas
- **Multiplataforma:** Funciona en PC, móvil y consola

---

## 📞 Soporte

Si tienes problemas:

1. Revisa la **Consola de Salida** (F9 en Studio)
2. Asegúrate de seguir todos los pasos de instalación
3. Verifica que los nombres de los objetos sean exactos
4. Prueba en un servidor de prueba (no solo en Studio)

---

## 🎉 ¡Listo!

Tu sistema de dinero está completo y funcional. Puedes expandirlo añadiendo:

- Más productos en la tienda
- Diferentes tipos de cofres
- Misiones que den dinero
- Sistema de economía más complejo

**¡Diviértete creando tu juego!** 🚀
