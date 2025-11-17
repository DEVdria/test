# 🎮 Sistema de Compras para Roblox

Sistema completo de monetización con Gamepasses y Developer Products para tu juego de Roblox.

## 🌟 Características

### Gamepasses (Shop)
- ✨ **VIP Pass**: Beneficios exclusivos VIP
- 🏃 **Speed Boost**: Velocidad de movimiento aumentada
- 🦘 **Double Jump**: Salto más alto

### Developer Products (Troll)
- 💀 **Kill All**: Elimina a todos los jugadores
- 🤸 **Ragdoll All**: Pon a todos en ragdoll por 5 segundos
- 💥 **Explosion**: Crea una explosión masiva
- ⚡ **Speed Boost All**: Da velocidad a todos por 30 segundos

## 📦 Estructura del Proyecto

```
Roblox Game/
│
├── ReplicatedStorage/
│   └── ShopRemotes.lua (ModuleScript)
│
├── ServerScriptService/
│   ├── GamepassManager.lua (Script)
│   └── DeveloperProductManager.lua (Script)
│
└── StarterGui/
    └── ScreenGui/
        ├── ShopFrameManager.lua (LocalScript)
        ├── TrollPanelManager.lua (LocalScript)
        ├── Frame/
        │   ├── Shop (TextButton)
        │   └── Troll (TextButton)
        │
        ├── ShopFrame/ (Panel de Gamepasses)
        └── TrollFrame/ (Panel de Developer Products - se crea automáticamente)
```

## 🚀 Instalación Rápida

1. **Copia los archivos a tu juego de Roblox**:
   - `ReplicatedStorage/ShopRemotes.lua` → ModuleScript en ReplicatedStorage
   - `ServerScriptService/GamepassManager.lua` → Script en ServerScriptService
   - `ServerScriptService/DeveloperProductManager.lua` → Script en ServerScriptService
   - `StarterGui/ShopFrameManager.lua` → LocalScript en StarterGui > ScreenGui
   - `StarterGui/TrollPanelManager.lua` → LocalScript en StarterGui > ScreenGui

2. **Crea tus Gamepasses y Developer Products** en la página de tu juego en Roblox.com

3. **Configura los IDs**:
   - En `GamepassManager.lua`: Reemplaza los IDs de los gamepasses (línea ~16)
   - En `DeveloperProductManager.lua`: Reemplaza los IDs de los developer products (línea ~16)

4. **¡Listo!** Publica tu juego y prueba el sistema.

## 📖 Documentación Completa

Lee **INSTRUCCIONES_INSTALACION.md** para:
- Guía paso a paso detallada
- Cómo crear Gamepasses y Developer Products
- Cómo configurar los IDs
- Personalización de efectos
- Solución de problemas
- Agregar más productos

## 🔧 Configuración de IDs

### Gamepasses (en GamepassManager.lua)
```lua
local GAMEPASSES = {
	VIP = {
		ID = 0, -- ⬅️ Reemplazar con tu ID real
		-- ...
	},
	SpeedBoost = {
		ID = 0, -- ⬅️ Reemplazar con tu ID real
		-- ...
	},
	DoubleJump = {
		ID = 0, -- ⬅️ Reemplazar con tu ID real
		-- ...
	}
}
```

### Developer Products (en DeveloperProductManager.lua)
```lua
local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 0, -- ⬅️ Reemplazar con tu ID real
		-- ...
	},
	RagdollAll = {
		ID = 0, -- ⬅️ Reemplazar con tu ID real
		-- ...
	},
	-- ...
}
```

## 🎯 Cómo Funciona

### Flujo de Gamepasses
1. Jugador hace clic en botón "Shop"
2. Se abre panel con gamepasses disponibles
3. Al hacer clic en un gamepass, se muestra el prompt de compra de Roblox
4. Si ya lo tiene, se activa el efecto automáticamente
5. Los efectos se activan cada vez que el jugador entra al juego

### Flujo de Developer Products
1. Jugador hace clic en botón "Troll"
2. Se abre panel con developer products
3. Al hacer clic en un producto, se muestra el prompt de compra
4. Después de la compra, el efecto se ejecuta inmediatamente
5. Los productos se pueden comprar múltiples veces

## 🛡️ Seguridad

- ✅ Todas las compras se procesan en el servidor
- ✅ Verificación de propiedad de gamepasses
- ✅ Prevención de duplicación de compras
- ✅ Sistema de ProcessReceipt para developer products
- ✅ Manejo de errores con pcall

## 🎨 Personalización

### Cambiar Efectos
Edita las funciones `Effect` en:
- `GamepassManager.lua` para gamepasses
- `DeveloperProductManager.lua` para developer products

### Agregar Más Productos
1. Agrega la entrada en el servidor (GamepassManager o DeveloperProductManager)
2. Agrega la entrada en el cliente (ShopFrameManager o TrollPanelManager)
3. Asegúrate de que la `Key` coincida en ambos lados

### Cambiar Apariencia
Los scripts crean la UI automáticamente, pero puedes modificar:
- Colores: `BackgroundColor3`, `TextColor3`
- Tamaños: `Size`, `Position`
- Fuentes: `Font`, `TextSize`
- Iconos: `Icon` en los arrays de configuración

## 📝 Notas Importantes

- ⚠️ **Los IDs deben ser números**, no strings (sin comillas)
- ⚠️ **Las Keys deben coincidir** entre cliente y servidor
- ⚠️ **Prueba siempre en el juego publicado**, no en Studio
- ⚠️ **Los Developer Products son consumibles**, se pueden comprar múltiples veces
- ⚠️ **Los Gamepasses son permanentes**, solo se compran una vez

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| No se abre el prompt | Verifica los IDs y prueba en el juego publicado |
| Efecto no se activa | Revisa la consola para errores en la función Effect |
| Botones no aparecen | Verifica que los LocalScripts estén en ScreenGui |
| Error "ShopRemotes not found" | Asegúrate de que ShopRemotes.lua esté en ReplicatedStorage |

## 💡 Ejemplos de Uso

### Ejemplo: Dar dinero con VIP
```lua
Effect = function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + 1000
		end
	end
end
```

### Ejemplo: Teleportar con un Developer Product
```lua
Effect = function(purchaser)
	local character = purchaser.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.CFrame = CFrame.new(0, 100, 0) -- Teleport
		end
	end
end
```

## 📞 Soporte

Si encuentras problemas:
1. Lee **INSTRUCCIONES_INSTALACION.md**
2. Revisa la sección "Solución de Problemas"
3. Verifica la consola de Output en Roblox Studio
4. Asegúrate de que todos los IDs estén configurados correctamente

## 📄 Licencia

Este sistema es de uso libre para tu juego de Roblox.

---

**¡Feliz monetización! 💰**
