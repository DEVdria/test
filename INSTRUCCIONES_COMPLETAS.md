# 🎮 Sistema de Developer Products para Roblox - Guía Completa

## 📋 Tabla de Contenidos
1. [Resumen del Sistema](#resumen-del-sistema)
2. [Crear Developer Products en Roblox](#crear-developer-products)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Configuración de IDs](#configuración-de-ids)
5. [Pruebas](#pruebas)
6. [Solución de Problemas](#solución-de-problemas)

---

## 🎯 Resumen del Sistema

Este sistema incluye:

### 1. **Botón Troll** (GUI del Jugador)
- Botón visible para todos los jugadores
- Requiere comprar un Developer Product para activarse
- Al activarse: mata a todos los jugadores del servidor
- Ubicación: GUI inferior centro de la pantalla

### 2. **Cofre de Donaciones** (Workspace)
- Objeto interactivo en el mundo
- Al tocarlo/activarlo: abre GUI de donaciones
- Usa ProximityPrompt para la interacción

### 3. **GUI de Donaciones**
- 5 botones de donación con diferentes valores
- Cada botón conectado a un Developer Product diferente
- Animaciones y feedback visual
- Mensaje de agradecimiento al donar

---

## 💎 Crear Developer Products en Roblox

### Paso 1: Acceder a la Página de Creación
1. Ve a [Roblox Creator Dashboard](https://create.roblox.com/)
2. Selecciona tu juego
3. Ve a **Monetización** > **Developer Products**
4. Haz clic en **"Create a Developer Product"**

### Paso 2: Crear Cada Producto

Necesitas crear **6 Developer Products** en total:

#### Producto 1: Troll
- **Name**: `Troll Effect`
- **Description**: `Unlock the Troll button to eliminate all players`
- **Price**: El precio que desees (ejemplo: 25 Robux)

#### Producto 2-6: Donaciones
- **Donación 1**
  - **Name**: `Small Donation`
  - **Price**: 5 Robux

- **Donación 2**
  - **Name**: `Medium Donation`
  - **Price**: 10 Robux

- **Donación 3**
  - **Name**: `Large Donation`
  - **Price**: 25 Robux

- **Donación 4**
  - **Name**: `Super Donation`
  - **Price**: 50 Robux

- **Donación 5**
  - **Name**: `Mega Donation`
  - **Price**: 100 Robux

### Paso 3: Copiar los IDs
Después de crear cada producto, Roblox te mostrará un **Product ID** (un número largo).
**¡GUARDA ESTOS IDs!** Los necesitarás en el siguiente paso.

---

## 🛠️ Instalación Paso a Paso

### PASO 1: Configurar RemoteEvents

**Opción A: Automática (Recomendada)**
1. Abre Roblox Studio con tu juego
2. Copia el script `ServerScriptService/CreateRemoteEvents.lua`
3. Pégalo en **ServerScriptService**
4. Ejecuta el juego (Play)
5. Espera a que aparezcan mensajes de confirmación en Output
6. **ELIMINA** el script `CreateRemoteEvents` después de ejecutarlo
7. Verifica que en `ReplicatedStorage/RemoteEvents` existan:
   - TrollEvent
   - PurchaseEvent
   - PromptPurchase
   - OpenDonationGui

**Opción B: Manual**
1. En **ReplicatedStorage**, crea una carpeta llamada `RemoteEvents`
2. Dentro de la carpeta, crea 4 **RemoteEvent**:
   - `TrollEvent`
   - `PurchaseEvent`
   - `PromptPurchase`
   - `OpenDonationGui`

---

### PASO 2: Instalar Script Principal del Servidor

1. Abre el archivo `ServerScriptService/DeveloperProductsHandler.lua`
2. Copia todo su contenido
3. En Roblox Studio, ve a **ServerScriptService**
4. Crea un nuevo **Script** (NO LocalScript)
5. Nómbralo: `DeveloperProductsHandler`
6. Pega el contenido del archivo

---

### PASO 3: Configurar GUI del Botón Troll

Sigue las instrucciones detalladas en: `StarterGui/TrollGui/README.md`

**Resumen rápido:**
1. En **StarterGui**, crea un **ScreenGui** llamado `TrollGui`
2. Dentro, crea una estructura de Frame > TextButton
3. Copia el script `TrollButton.lua` en un LocalScript dentro del botón
4. Configura las propiedades visuales según el README

---

### PASO 4: Configurar el Cofre de Donaciones

Sigue las instrucciones detalladas en: `Workspace/DonationChest/README.md`

**Resumen rápido:**
1. En **Workspace**, crea un **Model** llamado `DonationChest`
2. Dentro, crea una **Part** con un **ProximityPrompt**
3. Copia el script `ChestScript.lua` en un Script dentro del Model
4. Posiciona el cofre donde quieras en tu mapa

---

### PASO 5: Configurar GUI de Donaciones

Sigue las instrucciones detalladas en: `StarterGui/DonacionesGui/README.md`

**Resumen rápido:**
1. En **StarterGui**, crea un **ScreenGui** llamado `DonacionesGui`
2. Crea la estructura completa con MainFrame, botones, etc.
3. Copia el script `DonationsScript.lua` en un LocalScript
4. Configura las propiedades visuales según el README

---

## 🔑 Configuración de IDs

### ⚠️ IMPORTANTE: Configurar los Product IDs

Después de crear tus Developer Products, debes configurar sus IDs:

1. Abre el script **`DeveloperProductsHandler`** en ServerScriptService
2. Busca la sección `PRODUCT_IDS` (líneas 14-21)
3. Reemplaza los `0` con los IDs reales de tus productos:

```lua
local PRODUCT_IDS = {
    TrollProduct = 1234567890,  -- ← Reemplaza con el ID real
    Donacion1 = 1234567891,     -- ← Reemplaza con el ID real
    Donacion2 = 1234567892,     -- ← Reemplaza con el ID real
    Donacion3 = 1234567893,     -- ← Reemplaza con el ID real
    Donacion4 = 1234567894,     -- ← Reemplaza con el ID real
    Donacion5 = 1234567895,     -- ← Reemplaza con el ID real
}
```

4. Guarda el script

---

## 🧪 Pruebas

### Probar en Roblox Studio (Limitado)

Las compras **NO FUNCIONARÁN** en modo Play local porque MarketplaceService requiere un servidor real. Sin embargo, puedes probar:

1. Que las GUIs aparezcan correctamente
2. Que el cofre tenga el ProximityPrompt visible
3. Que al acercarte al cofre aparezca el prompt
4. Que no haya errores en el Output

### Probar en el Juego Publicado (Completo)

1. **Publica tu juego** en Roblox
2. **Únete al juego** desde el navegador o la app de Roblox
3. Prueba el botón Troll:
   - Debe estar bloqueado inicialmente
   - Al hacer clic, debe abrir la ventana de compra de Robux
   - Después de comprar, debe desbloquearse
   - Al hacer clic desbloqueado, debe matar a todos
4. Prueba el cofre:
   - Acércate y presiona E (o el botón en móvil)
   - Debe abrir la GUI de donaciones
5. Prueba las donaciones:
   - Haz clic en cualquier botón de donación
   - Debe abrir la ventana de compra
   - Después de comprar, debe mostrar el mensaje de agradecimiento

---

## 🐛 Solución de Problemas

### Problema: "RemoteEvents not found"
**Solución:**
- Asegúrate de haber ejecutado el script `CreateRemoteEvents.lua`
- Verifica que exista la carpeta `RemoteEvents` en `ReplicatedStorage`
- Verifica que los 4 RemoteEvents estén dentro de la carpeta

### Problema: "Producto no configurado o ID inválido"
**Solución:**
- Revisa el Output para ver qué producto está fallando
- Verifica que hayas configurado todos los IDs en `PRODUCT_IDS`
- Asegúrate de que los IDs sean números, no strings
- Verifica que los IDs sean correctos (cópialos de nuevo desde Creator Dashboard)

### Problema: El botón Troll no se desbloquea después de comprar
**Solución:**
- Verifica que el script `TrollButton.lua` esté correctamente ubicado
- Revisa el Output en busca de errores
- Asegúrate de que el evento `PurchaseEvent` esté funcionando
- Verifica que el ID del producto Troll sea correcto

### Problema: El cofre no abre la GUI
**Solución:**
- Verifica que el ProximityPrompt esté dentro de la parte del cofre
- Asegúrate de que el script `ChestScript.lua` esté en el Model, no en la Part
- Verifica que la GUI `DonacionesGui` tenga `Enabled = false` inicialmente
- Revisa que el RemoteEvent `OpenDonationGui` exista

### Problema: Las compras no funcionan en modo Play
**Solución:**
- Esto es **NORMAL**. MarketplaceService solo funciona en servidores reales de Roblox
- Debes publicar tu juego y probarlo desde el navegador o app de Roblox
- No puedes probar compras en Roblox Studio

### Problema: Los jugadores pueden usar el Troll sin comprar
**Solución:**
- Verifica que el script del servidor esté verificando `playersWithTroll[player.UserId]`
- Asegúrate de que el script `DeveloperProductsHandler` esté en ServerScriptService
- Revisa que no haya scripts adicionales que permitan usar el Troll sin autorización

---

## 📁 Estructura Final del Proyecto

```
ServerScriptService/
├── DeveloperProductsHandler.lua (Script principal)
└── CreateRemoteEvents.lua (Ejecutar una vez y eliminar)

ReplicatedStorage/
└── RemoteEvents/
    ├── TrollEvent (RemoteEvent)
    ├── PurchaseEvent (RemoteEvent)
    ├── PromptPurchase (RemoteEvent)
    └── OpenDonationGui (RemoteEvent)

StarterGui/
├── TrollGui (ScreenGui)
│   └── Frame
│       └── TrollButton (TextButton)
│           └── TrollButton.lua (LocalScript)
└── DonacionesGui (ScreenGui)
    └── MainFrame (Frame)
        ├── DonationsScript.lua (LocalScript)
        ├── Title (TextLabel)
        ├── CloseButton (TextButton)
        ├── ThankYouLabel (TextLabel)
        └── DonationsContainer (Frame)
            ├── UIGridLayout
            ├── Button1 (TextButton)
            ├── Button2 (TextButton)
            ├── Button3 (TextButton)
            ├── Button4 (TextButton)
            └── Button5 (TextButton)

Workspace/
└── DonationChest (Model)
    ├── ChestPart (Part)
    │   └── ProximityPrompt
    └── ChestScript.lua (Script)
```

---

## 🎨 Personalización Adicional

### Cambiar el efecto del Troll
Edita la función `executeTrollEffect` en `DeveloperProductsHandler.lua`:
```lua
local function executeTrollEffect(player)
    -- En lugar de matar, puedes hacer otras cosas:
    -- Teleportar a todos
    -- Cambiar la gravedad
    -- Hacer que todos salten
    -- etc.
end
```

### Agregar recompensas por donaciones
Edita la función `processDonation` en `DeveloperProductsHandler.lua`:
```lua
local function processDonation(player, productId)
    -- Dar monedas
    -- Dar items
    -- Dar puntos
    -- etc.
end
```

### Cambiar los precios y textos de donaciones
Edita el array `donationButtons` en `DonationsScript.lua`

---

## ✅ Checklist Final

Antes de publicar, verifica:
- [ ] Todos los Developer Products creados en Creator Dashboard
- [ ] IDs configurados en `DeveloperProductsHandler.lua`
- [ ] RemoteEvents creados en ReplicatedStorage
- [ ] Script principal en ServerScriptService
- [ ] GUI del Troll creada correctamente
- [ ] Cofre de donaciones en el Workspace
- [ ] GUI de donaciones creada correctamente
- [ ] No hay errores en Output
- [ ] Juego publicado en Roblox
- [ ] Pruebas realizadas en el juego publicado

---

## 📞 Soporte

Si tienes problemas:
1. Revisa el **Output** en Roblox Studio para ver errores
2. Verifica que seguiste todos los pasos
3. Asegúrate de probar en el juego publicado, no en Studio
4. Revisa la sección de Solución de Problemas

---

¡Listo! Tu sistema de Developer Products está completo. 🎉
