# 📦 Sistema de Compras para Roblox - Instrucciones de Instalación

## 🎯 Resumen del Sistema

Este sistema incluye:
- **Gamepasses**: VIP, Speed Boost, Double Jump (desde el botón Shop)
- **Developer Products**: Kill All, Ragdoll All, Explosion, Speed Boost All (desde el botón Troll)
- Interfaz completa con UI automática
- Sistema servidor-cliente seguro

---

## 📁 Estructura de Archivos Creados

### ReplicatedStorage
```
ReplicatedStorage/
└── ShopRemotes.lua (ModuleScript)
```

### ServerScriptService
```
ServerScriptService/
├── GamepassManager.lua (Script)
└── DeveloperProductManager.lua (Script)
```

### StarterGui
```
StarterGui/
├── ShopFrameManager.lua (LocalScript)
└── TrollPanelManager.lua (LocalScript)
```

---

## 🔧 PASOS DE INSTALACIÓN

### PASO 1: Colocar los Scripts del Servidor

1. Abre **ServerScriptService** en Roblox Studio
2. Crea un nuevo **Script** llamado `GamepassManager`
3. Copia el contenido de `ServerScriptService/GamepassManager.lua`
4. Crea otro **Script** llamado `DeveloperProductManager`
5. Copia el contenido de `ServerScriptService/DeveloperProductManager.lua`

### PASO 2: Colocar el ModuleScript en ReplicatedStorage

1. Abre **ReplicatedStorage** en Roblox Studio
2. Crea un nuevo **ModuleScript** llamado `ShopRemotes`
3. Copia el contenido de `ReplicatedStorage/ShopRemotes.lua`

### PASO 3: Colocar los LocalScripts en StarterGui

1. Abre **StarterGui > ScreenGui** en Roblox Studio
2. Crea un nuevo **LocalScript** llamado `ShopFrameManager`
3. Copia el contenido de `StarterGui/ShopFrameManager.lua`
4. Crea otro **LocalScript** llamado `TrollPanelManager`
5. Copia el contenido de `StarterGui/TrollPanelManager.lua`

**IMPORTANTE**: Ambos LocalScripts deben estar dentro de **ScreenGui**, NO dentro de Frame ni ShopFrame.

---

## 🎮 CREAR GAMEPASSES Y DEVELOPER PRODUCTS

### Crear Gamepasses

1. Ve a la página de tu juego en Roblox.com
2. Ve a **Monetization > Passes** (o **Create** > **Game Passes**)
3. Haz clic en **Create a Pass**
4. Crea estos gamepasses:
   - **VIP Pass** (nombre, descripción, imagen, precio)
   - **Speed Boost**
   - **Double Jump**
5. **Copia el ID de cada gamepass** (es el número en la URL)

Ejemplo de URL: `https://www.roblox.com/game-pass/123456789/VIP-Pass`
El ID es: `123456789`

### Crear Developer Products

1. Ve a la página de tu juego en Roblox.com
2. Ve a **Monetization > Developer Products**
3. Haz clic en **Create a Developer Product**
4. Crea estos productos:
   - **Kill All Players** (nombre, descripción, precio)
   - **Ragdoll All Players**
   - **Explosion**
   - **Speed Boost All**
5. **Copia el ID de cada developer product**

---

## ⚙️ CONFIGURAR LOS IDS

### En GamepassManager.lua (ServerScriptService)

Busca la sección `CONFIGURACIÓN DE GAMEPASSES` (línea ~16) y reemplaza los IDs:

```lua
local GAMEPASSES = {
	VIP = {
		ID = 123456789, -- ⬅️ PON AQUÍ EL ID REAL DE TU GAMEPASS VIP
		Name = "VIP",
		-- ...
	},

	SpeedBoost = {
		ID = 987654321, -- ⬅️ PON AQUÍ EL ID REAL DE SPEED BOOST
		Name = "Speed Boost",
		-- ...
	},

	DoubleJump = {
		ID = 555666777, -- ⬅️ PON AQUÍ EL ID REAL DE DOUBLE JUMP
		Name = "Double Jump",
		-- ...
	}
}
```

### En DeveloperProductManager.lua (ServerScriptService)

Busca la sección `CONFIGURACIÓN DE DEVELOPER PRODUCTS` (línea ~16) y reemplaza los IDs:

```lua
local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 111222333, -- ⬅️ PON AQUÍ EL ID REAL DE KILL ALL
		Name = "Kill All Players",
		-- ...
	},

	RagdollAll = {
		ID = 444555666, -- ⬅️ PON AQUÍ EL ID REAL DE RAGDOLL ALL
		Name = "Ragdoll All Players",
		-- ...
	},

	Explosion = {
		ID = 777888999, -- ⬅️ PON AQUÍ EL ID REAL DE EXPLOSION
		Name = "Explosion",
		-- ...
	},

	SpeedBoostAll = {
		ID = 123123123, -- ⬅️ PON AQUÍ EL ID REAL DE SPEED BOOST ALL
		Name = "Speed Boost All",
		-- ...
	}
}
```

---

## 🎨 VERIFICAR TU ESTRUCTURA DE UI

Tu estructura debe quedar así:

```
StarterGui
└── ScreenGui
    ├── ShopFrameManager (LocalScript) ⬅️ NUEVO
    ├── TrollPanelManager (LocalScript) ⬅️ NUEVO
    ├── Frame
    │   ├── UIListLayout
    │   ├── Invite (TextButton)
    │   ├── Shop (TextButton)
    │   └── Troll (TextButton)
    │
    ├── ShopFrame
    │   ├── Frame (título)
    │   ├── ScrollingFrame (aquí van los gamepasses)
    │   └── Cerrar (TextButton)
    │
    └── TrollFrame ⬅️ SE CREA AUTOMÁTICAMENTE
        ├── TitleFrame
        ├── ScrollingFrame
        └── Cerrar
```

**NOTA**: El `TrollFrame` se crea automáticamente cuando se ejecuta `TrollPanelManager.lua`, NO necesitas crearlo manualmente.

---

## ✅ PROBAR EL SISTEMA

### Prueba en Roblox Studio (modo Play Solo)

**IMPORTANTE**: En Studio, las compras NO funcionarán realmente, pero puedes:
1. Verificar que los botones abren los paneles correctamente
2. Verificar que no hay errores en la consola
3. Ver que los prompts de compra intentan abrirse

### Prueba en el Juego Publicado

1. **Publica tu juego** en Roblox
2. **Únete al juego** desde el sitio web de Roblox
3. Haz clic en el botón **Shop**
   - Deberías ver los 3 gamepasses
   - Al hacer clic, se abre el prompt de compra de Roblox
4. Haz clic en el botón **Troll**
   - Deberías ver los 4 developer products
   - Al hacer clic, se abre el prompt de compra de Roblox
5. **Compra un gamepass o producto** (con Robux reales o de prueba)
6. Verifica que el efecto se activa correctamente

---

## 🎯 CÓMO FUNCIONA

### Gamepasses (Shop)

1. Jugador hace clic en el botón **Shop**
2. Se abre `ShopFrame` con los gamepasses
3. Jugador hace clic en un gamepass
4. `ShopFrameManager` (cliente) envía evento al servidor
5. `GamepassManager` (servidor) verifica y muestra el prompt de compra
6. Si el jugador compra, el servidor activa el efecto automáticamente
7. Si el jugador ya lo tenía, el efecto se activa al entrar al juego

### Developer Products (Troll)

1. Jugador hace clic en el botón **Troll**
2. Se abre `TrollFrame` con los developer products
3. Jugador hace clic en un producto
4. `TrollPanelManager` (cliente) envía evento al servidor
5. `DeveloperProductManager` (servidor) muestra el prompt de compra
6. Cuando se completa la compra, el servidor ejecuta el efecto inmediatamente

---

## 🛠️ PERSONALIZACIÓN

### Cambiar Efectos de Gamepasses

En `GamepassManager.lua`, modifica la función `Effect` de cada gamepass:

```lua
VIP = {
	ID = 123456789,
	Name = "VIP",
	Effect = function(player)
		-- ⬅️ AQUÍ PUEDES PONER TU CÓDIGO PERSONALIZADO
		print(player.Name .. " tiene VIP!")
		-- Ejemplo: dar dinero extra
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				coins.Value = coins.Value + 1000
			end
		end
	end
}
```

### Cambiar Efectos de Developer Products

En `DeveloperProductManager.lua`, modifica la función `Effect` de cada producto:

```lua
KillAll = {
	ID = 111222333,
	Name = "Kill All Players",
	Effect = function(purchaser)
		-- ⬅️ AQUÍ PUEDES PONER TU CÓDIGO PERSONALIZADO
		for _, player in pairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end
		end
	end
}
```

### Agregar Más Gamepasses o Productos

1. **En el servidor**: Agrega la entrada en `GAMEPASSES` o `DEVELOPER_PRODUCTS`
2. **En el cliente**: Agrega la entrada en `ShopFrameManager.lua` o `TrollPanelManager.lua`
3. **Importante**: La `Key` debe ser la misma en ambos lados

---

## ❗ SOLUCIÓN DE PROBLEMAS

### "No se abre el prompt de compra"
- Verifica que los IDs estén correctos (sin comillas, solo números)
- Asegúrate de estar probando en el juego publicado, NO en Studio
- Revisa la consola de salida (Output) para errores

### "El efecto no se activa después de comprar"
- Verifica que la función `Effect` no tenga errores
- Revisa la consola del servidor para mensajes de error
- Asegúrate de que `ProcessReceipt` esté configurado correctamente

### "Los botones no aparecen"
- Verifica que los LocalScripts estén en `ScreenGui`, no dentro de Frame
- Asegúrate de que `ShopFrame` y `Frame` existan con los nombres exactos
- Revisa la consola del cliente para errores

### "Error: ShopRemotes not found"
- Asegúrate de que `ShopRemotes.lua` está en `ReplicatedStorage`
- Verifica que sea un **ModuleScript**, no un Script normal
- Espera unos segundos después de iniciar el juego

---

## 📝 NOTAS IMPORTANTES

1. **Los IDs son números**, no strings. NO uses comillas:
   - ✅ Correcto: `ID = 123456789`
   - ❌ Incorrecto: `ID = "123456789"`

2. **Las Keys deben coincidir** entre cliente y servidor:
   - Servidor: `VIP = { ... }`
   - Cliente: `Key = "VIP"`

3. **Los Developer Products se pueden comprar múltiples veces**, los Gamepasses solo una vez

4. **Siempre prueba en el juego publicado**, no en Studio

5. **Revisa la consola de Output** para mensajes de error o confirmación

---

## 🎉 ¡Listo!

Tu sistema de compras está completo. Si tienes algún problema, revisa:
1. Los IDs están configurados correctamente
2. Los scripts están en las ubicaciones correctas
3. No hay errores en la consola
4. Estás probando en el juego publicado

¡Disfruta de tu sistema de monetización! 💰
