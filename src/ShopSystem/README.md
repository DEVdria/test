# 🛒 Sistema de Tienda para Roblox

Sistema completo de compras de Gamepasses y Developer Products con interfaz profesional.

---

## 📁 Estructura de Archivos

```
ShopSystem/
├── Client/                          # Scripts del cliente (LocalScripts)
│   ├── ShopFrameHandler.lua        # Maneja la UI de la tienda principal
│   ├── TrollButtonHandler.lua       # Maneja el botón y panel de Troll
│   └── ShopButtonHandler.lua        # Maneja el botón Shop
│
├── Server/                          # Scripts del servidor (Scripts)
│   ├── PurchaseHandler.lua         # Procesa compras de Developer Products
│   └── GamepassHandler.lua         # Activa beneficios de Gamepasses
│
└── Shared/                          # Configuración compartida (ModuleScripts)
    └── ProductsConfig.lua          # Configuración de todos los productos
```

---

## 🚀 Instalación Rápida

### **1. ReplicatedStorage**
```
ReplicatedStorage
└── ShopSystem (Folder)
    └── ProductsConfig (ModuleScript) ← Shared/ProductsConfig.lua
```

### **2. ServerScriptService**
```
ServerScriptService
└── ShopSystem (Folder)
    ├── PurchaseHandler (Script) ← Server/PurchaseHandler.lua
    └── GamepassHandler (Script) ← Server/GamepassHandler.lua
```

### **3. StarterGui**
```
StarterGui > ScreenGui
├── Frame
│   ├── Shop (Button)
│   │   └── LocalScript ← Client/ShopButtonHandler.lua
│   └── Troll (Button)
│       └── LocalScript ← Client/TrollButtonHandler.lua
│
└── ShopFrame
    └── LocalScript ← Client/ShopFrameHandler.lua
```

---

## ⚙️ Configuración

### **Obtener IDs de Productos**

1. **Gamepasses:** https://create.roblox.com/creations → Game Passes
2. **Developer Products:** https://create.roblox.com/creations → Developer Products
3. Copia el ID de la URL del producto

### **Configurar en ProductsConfig.lua**

```lua
ProductsConfig.Gamepasses = {
	{
		Name = "VIP Pass",
		GamepassId = TU_ID_AQUI,  -- ← Reemplaza con tu ID
		OnOwned = function(player)
			-- Tu código aquí
		end
	}
}
```

---

## 📚 Documentación Completa

Lee la guía completa en: [SHOP_SYSTEM_GUIDE.md](../../SHOP_SYSTEM_GUIDE.md)

---

## ✨ Características

- ✅ Compra de Gamepasses con un clic
- ✅ Compra de Developer Products consumibles
- ✅ Panel dedicado para productos "Troll"
- ✅ Activación automática de beneficios
- ✅ UI profesional y responsive
- ✅ Seguridad en el servidor
- ✅ Indicadores visuales de propiedad
- ✅ Sistema de retry automático
- ✅ Efectos instantáneos

---

## 🎮 Productos Incluidos

### **Gamepasses de Ejemplo:**
- VIP Pass (acceso VIP + 2x velocidad)
- Double Jump (salto doble)
- Premium Coins (2x monedas)

### **Developer Products Normales:**
- 100 Coins
- 500 Coins

### **Developer Products Troll:**
- ☠️ Kill Everyone (mata a todos)
- 🤪 Ragdoll Everyone (ragdoll global)
- 🌪️ Tornado (lanza a todos al aire)
- 🔥 Explode Everyone (explosiones)
- ⚡ Speed Boost Everyone (velocidad extrema)

---

## 🛠️ Personalización

### **Agregar nuevo Gamepass:**

```lua
{
	Name = "Nuevo Gamepass",
	Description = "Descripción del beneficio",
	GamepassId = TU_ID,
	Price = 100,
	Benefits = {"Beneficio 1", "Beneficio 2"},
	OnOwned = function(player)
		-- Código que se ejecuta cuando el jugador tiene el gamepass
	end
}
```

### **Agregar nuevo Developer Product:**

```lua
{
	Name = "Nuevo Producto",
	Description = "Qué hace este producto",
	ProductId = TU_ID,
	Price = 50,
	Category = "normal",  -- o "troll"
	OnPurchase = function(player)
		-- Código que se ejecuta al comprar
		return true  -- IMPORTANTE: retornar true si fue exitoso
	end
}
```

---

## 🔒 Seguridad

- ✅ Procesamiento en el servidor
- ✅ Validación de productos
- ✅ Protección contra exploits
- ✅ Verificación de propiedad

---

## 📊 Arquitectura

```
Cliente (LocalScript)                  Servidor (Script)
      ↓                                      ↓
1. Jugador presiona "Comprar"
      ↓
2. MarketplaceService:PromptPurchase
      ↓
3. Jugador completa compra
      ↓
                                       4. ProcessReceipt se llama
                                              ↓
                                       5. Busca producto en Config
                                              ↓
                                       6. Ejecuta OnPurchase
                                              ↓
                                       7. Retorna éxito/error
      ↓
8. UI se actualiza
```

---

## 💡 Tips

1. **Siempre prueba en el juego publicado**, no en Studio
2. **Verifica los IDs** antes de publicar
3. **Revisa Output** para mensajes de error
4. **Usa precios bajos** al principio para pruebas
5. **Respalda tu configuración** antes de hacer cambios grandes

---

## 🐛 Debugging

### **Mensajes de Output:**

```
✅ ShopFrame inicializado correctamente
✅ Sistema de compras inicializado correctamente
✅ GamepassHandler inicializado correctamente
📦 Productos registrados: 10
🎫 Gamepasses registrados: 3
```

### **Al comprar:**

```
🎉 [NombreJugador] compró el producto 1234567
✅ Compra procesada exitosamente:
   Jugador: [NombreJugador]
   Producto: 100 Coins
   ID: 1234567
```

---

## 📝 Licencia

MIT License - Libre para usar en tus proyectos de Roblox

---

**¡Sistema completo de tienda listo para usar! 🎮🛒**
