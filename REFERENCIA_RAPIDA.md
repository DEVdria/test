# 📝 Referencia Rápida - Developer Products

## 🚀 Inicio Rápido (5 minutos)

### 1. Crear Developer Products
Ve a https://create.roblox.com/ → Tu Juego → Monetización → Developer Products
Crea 6 productos y copia sus IDs.

### 2. Configurar IDs
Abre `ServerScriptService/DeveloperProductsHandler.lua` y reemplaza los IDs en línea 14-21:
```lua
local PRODUCT_IDS = {
    TrollProduct = TU_ID_AQUI,
    Donacion1 = TU_ID_AQUI,
    -- etc...
}
```

### 3. Crear RemoteEvents
Ejecuta `ServerScriptService/CreateRemoteEvents.lua` una vez, luego elimínalo.

### 4. Crear las GUIs
Sigue las instrucciones en:
- `StarterGui/TrollGui/README.md`
- `StarterGui/DonacionesGui/README.md`

### 5. Crear el Cofre
Sigue las instrucciones en:
- `Workspace/DonationChest/README.md`

### 6. Publicar y Probar
Publica tu juego y pruébalo desde Roblox (no desde Studio).

---

## 📍 Ubicaciones de Archivos

### Scripts de Servidor (ServerScriptService):
- `DeveloperProductsHandler.lua` - Script principal **[CONFIGURAR IDS AQUÍ]**
- `CreateRemoteEvents.lua` - Ejecutar una vez y eliminar

### RemoteEvents (ReplicatedStorage/RemoteEvents):
- TrollEvent
- PurchaseEvent
- PromptPurchase
- OpenDonationGui

### GUI Troll (StarterGui/TrollGui):
- ScreenGui > Frame > TrollButton (TextButton)
  - LocalScript: `TrollButton.lua`

### GUI Donaciones (StarterGui/DonacionesGui):
- ScreenGui > MainFrame (Frame)
  - LocalScript: `DonationsScript.lua`
  - 5 TextButtons (Button1-5)

### Cofre (Workspace/DonationChest):
- Model > ChestPart (Part)
  - ProximityPrompt
  - Script: `ChestScript.lua`

---

## 🔑 IDs de Productos a Configurar

En `DeveloperProductsHandler.lua`, línea 14-21:

| Variable | Propósito | Precio Sugerido |
|----------|-----------|-----------------|
| TrollProduct | Desbloquear botón Troll | 25-50 Robux |
| Donacion1 | Donación pequeña | 5 Robux |
| Donacion2 | Donación mediana | 10 Robux |
| Donacion3 | Donación grande | 25 Robux |
| Donacion4 | Donación super | 50 Robux |
| Donacion5 | Donación mega | 100 Robux |

---

## ⚡ Comandos Principales

### Verificar estructura:
```
ServerScriptService/
  DeveloperProductsHandler.lua ✓

ReplicatedStorage/RemoteEvents/
  TrollEvent ✓
  PurchaseEvent ✓
  PromptPurchase ✓
  OpenDonationGui ✓
```

### Verificar en Output:
Al ejecutar el juego, deberías ver:
```
✅ Developer Products Handler cargado correctamente
⚠️ Recuerda configurar los IDs de productos en PRODUCT_IDS
✅ Troll Button script cargado
✅ Chest script cargado
✅ Donations GUI script cargado
```

---

## 🐛 Errores Comunes

| Error | Solución |
|-------|----------|
| "RemoteEvents not found" | Ejecutar CreateRemoteEvents.lua |
| "Producto no configurado" | Configurar IDs en DeveloperProductsHandler |
| Compras no funcionan | Debes probar en el juego publicado, no en Studio |
| Botón no se desbloquea | Verificar que el ID del TrollProduct sea correcto |
| Cofre no abre GUI | Verificar que DonacionesGui.Enabled = false inicialmente |

---

## 📞 Ayuda

Para más detalles, consulta: `INSTRUCCIONES_COMPLETAS.md`
