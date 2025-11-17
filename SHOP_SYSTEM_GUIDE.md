

# 🛒 Sistema de Tienda Completo para Roblox - Guía de Instalación

Sistema completo de compras de Gamepasses y Developer Products con interfaz profesional.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Obtener IDs de Productos](#obtener-ids-de-productos)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Instalación Paso a Paso](#instalación-paso-a-paso)
5. [Configuración de Productos](#configuración-de-productos)
6. [Pruebas del Sistema](#pruebas-del-sistema)
7. [Solución de Problemas](#solución-de-problemas)
8. [Personalización](#personalización)

---

## 📌 Requisitos Previos

- Roblox Studio instalado
- Un juego publicado en Roblox
- Al menos 1 Gamepass creado
- Al menos 1 Developer Product creado
- Permisos de edición en el juego

---

## 🎫 Obtener IDs de Productos

### **PASO 1: Crear Gamepasses**

1. Ve a: https://create.roblox.com/creations
2. Selecciona tu juego
3. Ve a **"Passes"** (Game Passes)
4. Haz clic en **"Create a Pass"**
5. Configura:
   - **Name:** Nombre del gamepass (ej: "VIP Pass")
   - **Description:** Descripción de qué incluye
   - **Price:** Precio en Robux
   - **Image:** Imagen del gamepass (1024x1024 recomendado)
6. Haz clic en **"Create Pass"**
7. **COPIA EL ID** que aparece en la URL:
   ```
   https://www.roblox.com/game-pass/123456789/VIP-Pass
                                    ↑↑↑↑↑↑↑↑↑
                                    Este es el ID
   ```

**Repite este proceso para cada gamepass que quieras crear.**

---

### **PASO 2: Crear Developer Products**

1. Ve a: https://create.roblox.com/creations
2. Selecciona tu juego
3. Ve a **"Developer Products"**
4. Haz clic en **"Create a Developer Product"**
5. Configura:
   - **Name:** Nombre del producto (ej: "100 Coins")
   - **Description:** Descripción del producto
   - **Price:** Precio en Robux
   - **Image:** Imagen del producto
6. Haz clic en **"Create"**
7. **COPIA EL ID** del producto (similar al gamepass)

**Repite para cada producto que quieras.**

**Productos recomendados para trolleo:**
- Kill Everyone (ID: ?)
- Ragdoll Everyone (ID: ?)
- Tornado (ID: ?)
- Explode Everyone (ID: ?)
- Speed Boost Everyone (ID: ?)

---

## 📂 Estructura del Proyecto

Así debe quedar tu juego en Roblox Studio:

```
ReplicatedStorage
└── ShopSystem (Folder)
    └── ProductsConfig (ModuleScript)

ServerScriptService
└── ShopSystem (Folder)
    ├── PurchaseHandler (Script)
    └── GamepassHandler (Script)

StarterGui
└── ScreenGui
    ├── Frame
    │   ├── Shop (Button) → LocalScript
    │   └── Troll (Button) → LocalScript
    │
    ├── ShopFrame
    │   └── LocalScript
    │
    └── TrollFrame (se crea automáticamente)
```

---

## 🚀 Instalación Paso a Paso

### **PASO 1: Configurar ReplicatedStorage**

1. Abre tu juego en Roblox Studio
2. En el **Explorer**, busca **ReplicatedStorage**
3. Haz clic derecho → **Insert Object** → **Folder**
4. Renombra la carpeta a: `ShopSystem`
5. Dentro de `ShopSystem`, inserta un **ModuleScript**
6. Renombra el ModuleScript a: `ProductsConfig`
7. Abre `ProductsConfig` y **BORRA TODO**
8. Copia el contenido de: `src/ShopSystem/Shared/ProductsConfig.lua`
9. Pega en el ModuleScript
10. **Guarda** (Ctrl + S)

✅ **Verificación:** `ReplicatedStorage > ShopSystem > ProductsConfig`

---

### **PASO 2: Configurar ServerScriptService**

1. En el **Explorer**, busca **ServerScriptService**
2. Haz clic derecho → **Insert Object** → **Folder**
3. Renombra a: `ShopSystem`
4. Dentro de `ShopSystem`, inserta un **Script** (NO LocalScript)
5. Renombra a: `PurchaseHandler`
6. Abre el script y **BORRA TODO**
7. Copia el contenido de: `src/ShopSystem/Server/PurchaseHandler.lua`
8. Pega y **guarda**

9. Inserta otro **Script** en la carpeta `ShopSystem`
10. Renombra a: `GamepassHandler`
11. Abre el script y **BORRA TODO**
12. Copia el contenido de: `src/ShopSystem/Server/GamepassHandler.lua`
13. Pega y **guarda**

✅ **Verificación:**
```
ServerScriptService > ShopSystem > PurchaseHandler (Script)
ServerScriptService > ShopSystem > GamepassHandler (Script)
```

---

### **PASO 3: Configurar StarterGui (Botón Shop)**

1. En el **Explorer**, busca: `StarterGui > ScreenGui > Frame > Shop`
2. Haz clic derecho en el botón **Shop** → **Insert Object** → **LocalScript**
3. Si ya existe un "LocalScript shop", ábrelo y reemplaza su contenido
4. Copia el contenido de: `src/ShopSystem/Client/ShopButtonHandler.lua`
5. Pega y **guarda**

✅ **Verificación:** `StarterGui > ScreenGui > Frame > Shop > LocalScript`

---

### **PASO 4: Configurar StarterGui (Botón Troll)**

1. Busca: `StarterGui > ScreenGui > Frame > Troll`
2. Haz clic derecho en el botón **Troll** → **Insert Object** → **LocalScript**
3. Abre el LocalScript
4. Copia el contenido de: `src/ShopSystem/Client/TrollButtonHandler.lua`
5. Pega y **guarda**

✅ **Verificación:** `StarterGui > ScreenGui > Frame > Troll > LocalScript`

---

### **PASO 5: Configurar StarterGui (ShopFrame)**

1. Busca: `StarterGui > ScreenGui > ShopFrame`
2. Si existe un LocalScript dentro, **BÓRRALO**
3. Haz clic derecho en **ShopFrame** → **Insert Object** → **LocalScript**
4. Abre el LocalScript
5. Copia el contenido de: `src/ShopSystem/Client/ShopFrameHandler.lua`
6. Pega y **guarda**

✅ **Verificación:** `StarterGui > ScreenGui > ShopFrame > LocalScript`

---

## ⚙️ Configuración de Productos

### **Configurar tus IDs reales**

1. Abre: `ReplicatedStorage > ShopSystem > ProductsConfig`
2. Busca las secciones de Gamepasses y Developer Products
3. Reemplaza los IDs de ejemplo con tus IDs reales:

```lua
-- ANTES (ejemplo)
GamepassId = 123456789,  -- REEMPLAZA CON TU ID REAL

-- DESPUÉS (tu ID real)
GamepassId = 987654321,  -- ← Tu ID aquí
```

### **Ejemplo completo de configuración:**

```lua
ProductsConfig.Gamepasses = {
	{
		Name = "VIP Pass",
		Description = "Acceso a áreas VIP",
		GamepassId = TU_ID_AQUI,  -- ← Reemplaza con tu ID
		Price = 100,
		Benefits = {"Acceso VIP", "2x velocidad"},
		OnOwned = function(player)
			-- Tu código aquí
		end
	}
}
```

**Repite para cada producto.**

---

## 🧪 Pruebas del Sistema

### **Prueba 1: Verificar que todo carga**

1. Presiona **Play** (F5) en Roblox Studio
2. Abre la **consola de Output** (View → Output)
3. Deberías ver:
   ```
   ✅ ShopFrame inicializado correctamente
   ✅ TrollButton configurado correctamente
   ✅ ShopButton configurado correctamente
   ✅ Sistema de compras inicializado correctamente
   ✅ GamepassHandler inicializado correctamente
   ```

Si ves estos mensajes, ¡todo está bien!

---

### **Prueba 2: Abrir la tienda**

1. Mientras el juego está corriendo, haz clic en el botón **Shop**
2. Debería aparecer el **ShopFrame** con la lista de gamepasses
3. Deberías ver tus gamepasses listados

---

### **Prueba 3: Abrir panel de Troll**

1. Haz clic en el botón **Troll**
2. Debería aparecer el **TrollFrame** con los productos de trolleo
3. Deberías ver productos como "Kill Everyone", "Ragdoll Everyone", etc.

---

### **Prueba 4: Intentar comprar (en Studio)**

**NOTA:** No puedes comprar en Studio, pero puedes verificar que el prompt aparece:

1. Haz clic en "Comprar" en un gamepass
2. Debería aparecer el prompt de compra de Roblox
3. Cierra el prompt (no puedes comprar en Studio)

---

### **Prueba 5: Compra real (en juego publicado)**

1. **Publica tu juego** (File → Publish to Roblox)
2. Abre el juego desde Roblox (no Studio)
3. Haz clic en Shop → Comprar un gamepass
4. **Completa la compra**
5. El beneficio debería activarse automáticamente

---

## ❗ Solución de Problemas

### **Problema: "ProductsConfig is not a valid member of ReplicatedStorage"**

**Solución:**
1. Verifica que `ProductsConfig` esté en `ReplicatedStorage > ShopSystem`
2. Verifica que sea un **ModuleScript** (NO Script ni LocalScript)
3. Verifica que el nombre sea EXACTAMENTE `ProductsConfig`

---

### **Problema: "ShopFrame no aparece al hacer clic en Shop"**

**Solución:**
1. Verifica que `ShopFrame` exista en `StarterGui > ScreenGui`
2. Verifica que `ShopFrame.Visible` esté en `false` por defecto
3. Abre la consola de Output y busca errores
4. Verifica que el LocalScript esté en el botón Shop

---

### **Problema: "Las compras no se procesan"**

**Solución:**
1. Verifica que `PurchaseHandler` esté en `ServerScriptService` como **Script**
2. Abre Output y busca errores
3. Verifica que los IDs de productos sean correctos
4. Asegúrate de haber publicado el juego (no funciona en Studio)

---

### **Problema: "Los beneficios de gamepasses no se activan"**

**Solución:**
1. Verifica que `GamepassHandler` esté en `ServerScriptService`
2. Abre Output y busca:
   ```
   🔍 Verificando gamepasses para: [NombreJugador]
   ✅ [NombreJugador] tiene el gamepass: [Nombre]
   ```
3. Si no aparece, verifica los IDs de gamepasses
4. Verifica que la función `OnOwned` esté definida en `ProductsConfig`

---

### **Problema: "Productos Troll no hacen nada"**

**Solución:**
1. Verifica que los IDs de Developer Products sean correctos
2. Abre Output en el servidor (View → Output → Server)
3. Busca mensajes de error al comprar
4. Verifica que `PurchaseHandler` esté procesando la compra:
   ```
   ✅ Compra procesada exitosamente
   ```

---

## 🎨 Personalización

### **Cambiar colores de la tienda**

En `ShopFrameHandler.lua`, busca:

```lua
-- Color de fondo de botones de gamepass
button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)

-- Color del borde
stroke.Color = Color3.fromRGB(70, 130, 220)

-- Color del botón "Comprar"
buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
```

---

### **Agregar más gamepasses**

1. Crea el gamepass en https://create.roblox.com
2. Copia el ID
3. Abre `ProductsConfig`
4. Agrega una nueva entrada en `ProductsConfig.Gamepasses`:

```lua
{
	Name = "Nuevo Gamepass",
	Description = "Descripción",
	GamepassId = TU_NUEVO_ID,
	Price = 50,
	Benefits = {"Beneficio 1", "Beneficio 2"},
	OnOwned = function(player)
		-- Tu código aquí
	end
}
```

---

### **Agregar más productos de trolleo**

1. Crea el Developer Product en create.roblox.com
2. Copia el ID
3. Abre `ProductsConfig`
4. Agrega una nueva entrada en `ProductsConfig.DeveloperProducts`:

```lua
{
	Name = "🎉 Nuevo Troll",
	Description = "Hace algo divertido",
	ProductId = TU_NUEVO_ID,
	Price = 50,
	Category = "troll",
	OnPurchase = function(player)
		-- Código de qué hace este producto
		-- Ejemplo: dar items, matar jugadores, etc.
		return true  -- Retornar true si fue exitoso
	end
}
```

---

### **Personalizar beneficios de gamepasses**

Los beneficios se configuran en la función `OnOwned`:

```lua
OnOwned = function(player)
	-- Ejemplo 1: Dar velocidad extra
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 50
		end
	end

	-- Ejemplo 2: Dar monedas
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + 1000
		end
	end

	-- Ejemplo 3: Dar tag VIP
	local vipTag = Instance.new("BoolValue")
	vipTag.Name = "VIP"
	vipTag.Value = true
	vipTag.Parent = player
end
```

---

### **Personalizar efectos de productos**

Los efectos se configuran en la función `OnPurchase`:

```lua
OnPurchase = function(player)
	-- Ejemplo: Dar coins
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + 100
		end
	end

	return true  -- IMPORTANTE: retornar true
end
```

---

## 📊 Características del Sistema

### **✅ Gamepasses:**
- UI profesional con scroll
- Indicador de "Ya tienes esto" (Owned)
- Compra con un clic
- Activación automática de beneficios
- Verificación al unirse al juego

### **✅ Developer Products:**
- Productos normales (coins, items, etc.)
- Productos de trolleo (kill all, ragdoll, etc.)
- Procesamiento seguro en el servidor
- Efectos instantáneos
- Panel dedicado para trolls

### **✅ Seguridad:**
- Todas las compras se procesan en el servidor
- Validación de productos
- Protección contra exploits
- Sistema de retry automático

### **✅ UI Responsive:**
- Compatible con PC, móvil y tablet
- Botones grandes para touch
- Scroll automático
- Animaciones suaves

---

## 🎓 Conceptos Clave

### **Gamepasses vs Developer Products**

| Característica | Gamepasses | Developer Products |
|----------------|------------|-------------------|
| **Compras** | Una sola vez | Múltiples veces (consumibles) |
| **Uso** | Beneficios permanentes | Efectos temporales/consumibles |
| **Ejemplos** | VIP, doble salto, velocidad | Coins, vidas, power-ups |
| **Verificación** | `UserOwnsGamePassAsync` | `ProcessReceipt` |

### **Dónde va cada código**

| Tipo de Script | Ubicación | Propósito |
|----------------|-----------|-----------|
| **ModuleScript** | ReplicatedStorage | Configuración compartida |
| **Script** | ServerScriptService | Lógica del servidor |
| **LocalScript** | StarterGui | Interfaz de usuario |

---

## 📝 Checklist de Instalación

Antes de probar el sistema:

- [ ] ProductsConfig está en ReplicatedStorage
- [ ] PurchaseHandler está en ServerScriptService
- [ ] GamepassHandler está en ServerScriptService
- [ ] LocalScript está en botón Shop
- [ ] LocalScript está en botón Troll
- [ ] LocalScript está en ShopFrame
- [ ] Todos los IDs de productos están configurados
- [ ] El juego está publicado
- [ ] Has probado en el juego real (no Studio)

---

## 🚨 IMPORTANTE

### **No funcionará en Roblox Studio:**

- ❌ No puedes comprar en Studio
- ❌ Los beneficios no se guardarán en Studio
- ✅ Debes probar en el juego PUBLICADO

### **Para probar:**
1. Publica tu juego (File → Publish)
2. Abre el juego desde Roblox.com
3. Prueba las compras ahí

---

## 🎉 ¡Listo!

Si seguiste todos los pasos correctamente, deberías tener:

✅ Tienda de gamepasses funcional
✅ Tienda de productos funcional
✅ Panel de trolleo funcional
✅ Sistema de compras seguro
✅ Beneficios automáticos

¡Disfruta de tu sistema de tienda completo! 🛒🎮

---

**¿Necesitas ayuda?** Revisa la sección de [Solución de Problemas](#solución-de-problemas)
