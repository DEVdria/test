# 🚀 GUÍA DE INSTALACIÓN - UnifiedProcessReceipt

## ✅ PASO 1: Comentar la línea conflictiva en DonoBoard

En **Workspace > DonoBoard > MainScript**, busca esta línea (aproximadamente línea 94):

```lua
market.ProcessReceipt = receipt
```

**Cámbiala a:**

```lua
-- market.ProcessReceipt = receipt
```

⚠️ **IMPORTANTE:** Solo agrega `-- ` al inicio. Si no comentas esta línea, habrá conflicto y los productos no funcionarán.

---

## ✅ PASO 2: Deshabilitar DeveloperProductManager

En **ServerScriptService**, encuentra el script llamado `DeveloperProductManager`.

**Opciones:**
- **Opción A (Recomendada):** Click derecho → Properties → marca "Disabled" como ✅
- **Opción B:** Bórralo completamente (ya no lo necesitas)

---

## ✅ PASO 3: Configurar IDs de productos Troll

Abre **ServerScriptService > UnifiedProcessReceipt** y busca las líneas 37-165.

**Necesitas los IDs de tus 4 Developer Products de Troll:**

### Cómo obtener los IDs:

1. Ve a https://create.roblox.com/dashboard/creations
2. Click en tu juego
3. Ve a **Monetization > Developer Products**
4. Copia el ID de cada producto

### Reemplaza los IDs:

```lua
KillAll = {
    ID = 1234567890, -- ⬅️ PEGA AQUÍ el ID real (sin comillas)
    Name = "Kill All Players",
    -- ...
},

RagdollAll = {
    ID = 9876543210, -- ⬅️ PEGA AQUÍ el ID real
    Name = "Launch All",
    -- ...
},

Explosion = {
    ID = 5555555555, -- ⬅️ PEGA AQUÍ el ID real
    Name = "Explosion",
    -- ...
},

SpeedBoostAll = {
    ID = 7777777777, -- ⬅️ PEGA AQUÍ el ID real
    Name = "Speed Boost All",
    -- ...
}
```

⚠️ **Los IDs deben ser NÚMEROS, no strings (sin comillas).**

---

## ✅ PASO 4: Verificar que todo funcione

### Checklist:

- ✅ **DonoBoard:** La línea `market.ProcessReceipt = receipt` está comentada
- ✅ **DeveloperProductManager:** Está deshabilitado o borrado
- ✅ **UnifiedProcessReceipt:** Los 4 IDs de productos Troll están configurados (no son 0)
- ✅ **UnifiedProcessReceipt:** Los IDs de DonoBoard coinciden con el ModuleScript ✅ (ya están correctos)

### Probar en Roblox Studio:

1. **Output debe mostrar:**
   ```
   ✅ UnifiedProcessReceipt configurado correctamente
   ✅ Manejando productos de DonoBoard + Troll
   🔍 Verificando configuración de productos Troll:
   ✅ KillAll: ID configurado (1234567890)
   ✅ RagdollAll: ID configurado (9876543210)
   ...
   ```

2. **Si ves advertencias de ID = 0:**
   ```
   ⚠️ KillAll: ID NO CONFIGURADO (actualmente 0)
   ```
   → Significa que NO configuraste los IDs. Vuelve al PASO 3.

### Probar en el juego:

1. **Comprar un producto de DonoBoard** → Debe actualizar el leaderboard
2. **Comprar "Kill All"** → Debe matar a todos y mostrar mensaje
3. **Mantener SHIFT + Click en "Kill All"** → Modo de prueba gratis (solo en Studio si DevProductTester está activo)

---

## 🐛 Solución de Problemas

### Problema: "No aparece el prompt de compra al hacer clic"

**Causa:** Los IDs están mal configurados o son 0.

**Solución:**
1. Verifica que los IDs en `UnifiedProcessReceipt` (líneas 38, 61, 119, 138) NO sean 0
2. Verifica que coincidan con los IDs en create.roblox.com

---

### Problema: "Se cobran los Robux pero no pasa nada"

**Causa:** No comentaste la línea en MainScript del DonoBoard.

**Solución:**
1. Ve a `Workspace > DonoBoard > MainScript`
2. Busca `market.ProcessReceipt = receipt`
3. Agrégale `-- ` al inicio: `-- market.ProcessReceipt = receipt`

---

### Problema: "Los productos de DonoBoard no funcionan"

**Causa:** Los IDs en `UnifiedProcessReceipt` no coinciden con el ModuleScript.

**Solución:**
Los IDs ya están correctos en la línea 17-30 de UnifiedProcessReceipt:
- ✅ `[3459790777] = 1`
- ✅ `[3459790776] = 3`
- etc.

Si cambiaste los IDs en el ModuleScript del DonoBoard, debes actualizarlos también en UnifiedProcessReceipt.

---

## 📊 Entendiendo cómo funciona

**UnifiedProcessReceipt** actúa como un "router" que decide qué hacer cuando alguien compra un Developer Product:

```
Compra realizada
       ↓
UnifiedProcessReceipt recibe el ProductId
       ↓
   ¿Es un producto de DonoBoard? (verifica en DONOBOARD_PRODUCTS)
       ↓ SI                    ↓ NO
   Actualizar DataStore    ¿Es un producto Troll?
   ✅ PurchaseGranted           ↓ SI
                           Ejecutar efecto (Kill All, etc.)
                           ✅ PurchaseGranted
```

**Por eso es CRÍTICO que:**
1. Solo exista UN ProcessReceipt (el unificado)
2. Todos los IDs estén correctamente configurados

---

## 🎯 Resumen Rápido

1. ✅ Comenta `market.ProcessReceipt = receipt` en DonoBoard MainScript
2. ✅ Deshabilita `DeveloperProductManager.lua`
3. ✅ Configura los 4 IDs de productos Troll en `UnifiedProcessReceipt.lua`
4. ✅ Prueba en Studio: modo de testing con SHIFT funciona
5. ✅ Publica el juego y prueba compras reales

---

**¿Necesitas ayuda?** Si después de seguir estos pasos aún tienes problemas, dame:
1. Una captura del Output cuando el juego inicia
2. El mensaje de error exacto (si hay)
3. Confirmación de que completaste los PASOS 1, 2 y 3
