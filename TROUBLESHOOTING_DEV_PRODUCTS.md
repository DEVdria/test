# 🔧 Guía de Solución de Problemas - Developer Products

## ❌ Problema: Developer Products no funcionan en el juego publicado

Si los Developer Products funcionan en Studio (con SHIFT) pero NO en el juego publicado, sigue estos pasos:

---

## 📋 CHECKLIST COMPLETA

### ✅ PASO 1: Verificar Configuración del Juego

1. **Abre Game Settings en Studio** (Alt+S o Home > Game Settings)
2. Ve a la pestaña **Security**
3. Verifica estas configuraciones:

   ```
   ✅ Allow Third Party Sales: ON (verde)
   ✅ Enable Studio Access to API Services: ON (verde)
   ```

4. Click en **Save**
5. **Cierra y vuelve a abrir Studio** para que los cambios tomen efecto

**IMPORTANTE:** Si estas opciones están OFF (gris/rojo), los Developer Products **NUNCA** funcionarán.

---

### ✅ PASO 2: Crear Developer Products en Roblox.com

1. Ve a [Roblox.com](https://www.roblox.com)
2. Entra a tu juego
3. Ve a **Monetization** > **Developer Products**
4. Click en **Create a Developer Product**
5. Crea cada producto:
   - **Kill All Players** (ejemplo: 25 Robux)
   - **Launch All** (ejemplo: 20 Robux)
   - **Explosion** (ejemplo: 30 Robux)
   - **Speed Boost All** (ejemplo: 15 Robux)

6. **Anota los IDs** de cada producto

**Cómo obtener el ID:**
- Después de crear el producto, haz clic en él
- La URL será algo como: `https://www.roblox.com/developer-products/configure?id=123456789`
- El número después de `id=` es el **Product ID**
- Ejemplo: `123456789`

---

### ✅ PASO 3: Configurar los IDs en el Código

Abre `ServerScriptService > DeveloperProductManager.lua` y busca la sección `DEVELOPER_PRODUCTS` (línea ~16):

```lua
local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 123456789, -- ⬅️ PONER AQUÍ EL ID REAL (sin comillas)
		Name = "Kill All Players",
		-- ...
	},

	RagdollAll = {
		ID = 987654321, -- ⬅️ PONER AQUÍ EL ID REAL
		Name = "Ragdoll All Players",
		-- ...
	},

	Explosion = {
		ID = 555666777, -- ⬅️ PONER AQUÍ EL ID REAL
		Name = "Explosion",
		-- ...
	},

	SpeedBoostAll = {
		ID = 111222333, -- ⬅️ PONER AQUÍ EL ID REAL
		Name = "Speed Boost All",
		-- ...
	}
}
```

**IMPORTANTE:**
- Los IDs son **números**, NO strings
- ✅ Correcto: `ID = 123456789`
- ❌ Incorrecto: `ID = "123456789"` (con comillas)
- ❌ Incorrecto: `ID = 0` (sin configurar)

---

### ✅ PASO 4: Publicar el Juego

1. En Studio: **File** > **Publish to Roblox**
2. Espera a que termine de publicar
3. **IMPORTANTE:** Los Developer Products **NO funcionan en Studio Play Mode**
4. Debes probar en el juego real desde Roblox.com

---

### ✅ PASO 5: Verificar el Script con Logging Mejorado

Ahora el script tiene **logging detallado**. Cuando inicies el servidor, deberías ver:

#### **En la consola del servidor (Output):**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 VERIFICANDO CONFIGURACIÓN DE DEVELOPER PRODUCTS
✅ KillAll: ID configurado (123456789)
✅ RagdollAll: ID configurado (987654321)
✅ Explosion: ID configurado (555666777)
✅ SpeedBoostAll: ID configurado (111222333)
✅ Todos los Developer Products tienen IDs configurados
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ProcessReceipt configurado correctamente para Developer Products
DeveloperProductManager cargado correctamente
```

Si ves **advertencias en amarillo**, significa que algo está mal configurado.

---

### ✅ PASO 6: Probar una Compra Real

1. **Publica el juego** (si no lo has hecho ya)
2. **Únete al juego** desde Roblox.com (NO desde Studio)
3. Abre el **panel Troll**
4. Click en un Developer Product (SIN presionar SHIFT)
5. Debería aparecer el **prompt de compra de Roblox**

#### **Si el prompt NO aparece:**
- Verifica que el ID esté configurado
- Verifica que "Allow Third Party Sales" esté ON
- Revisa la consola del servidor para errores

#### **Si el prompt aparece pero nada pasa después de comprar:**
- Ve a la consola del servidor (Output) en Studio
- Deberías ver algo como:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 PROCESANDO COMPRA DE DEVELOPER PRODUCT
PlayerId: 123456
ProductId: 987654321
PurchaseId: abc123def456
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Jugador encontrado: TuNombre
✅ Producto identificado: Kill All Players (Key: KillAll)
🔄 Ejecutando efecto del producto...
✅ ¡Efecto ejecutado correctamente!
✅ TuNombre compró y usó: Kill All Players
✅ Compra marcada como PurchaseGranted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🐛 ERRORES COMUNES

### ❌ Error: "Producto no reconocido con ID: 123456789"

**Causa:** El ID del producto comprado no coincide con ningún ID configurado en el código.

**Solución:**
1. Verifica que copiaste correctamente el ID desde Roblox.com
2. Asegúrate de que el ID en `DeveloperProductManager.lua` sea exactamente el mismo
3. NO uses comillas alrededor del número

---

### ❌ Error: "ID NO CONFIGURADO (actualmente 0)"

**Causa:** No has configurado el ID del producto.

**Solución:**
1. Ve a Roblox.com y crea el Developer Product
2. Copia el ID
3. Reemplaza el `0` en `DeveloperProductManager.lua` con el ID real

---

### ❌ No aparece el prompt de compra

**Causa:** "Allow Third Party Sales" está desactivado.

**Solución:**
1. Game Settings > Security
2. Allow Third Party Sales = **ON**
3. Guardar y **reiniciar Studio**
4. Publicar de nuevo

---

### ❌ Error: "Ya existe un ProcessReceipt configurado"

**Causa:** Otro script está intentando manejar compras.

**Solución:**
1. Busca en ServerScriptService si hay otros scripts de compras
2. Elimina o deshabilita scripts duplicados
3. Solo debe haber UN script con `MarketplaceService.ProcessReceipt`

---

### ❌ El jugador recibe reembolso después de comprar

**Causa:** El efecto del producto está fallando (error en el código).

**Solución:**
1. Revisa la consola del servidor
2. Busca mensajes de error en rojo
3. El logging mostrará exactamente dónde falló el efecto

---

## 🔍 CÓMO DEBUGGEAR

### Opción 1: Usar el Modo de Prueba (GRATIS)

En Studio o en el juego publicado:
1. Mantén presionada la tecla **SHIFT**
2. Haz clic en un Developer Product
3. El efecto se ejecutará **gratis** sin compra
4. Verás mensajes de prueba en la consola

### Opción 2: Ver la Consola del Servidor

Si tienes acceso al servidor (en Studio con Server mode):
1. Ve a **View** > **Output** en Studio
2. Inicia el juego en modo Server
3. Observa los mensajes cuando alguien compra
4. Todos los pasos se muestran con emojis:
   - ✅ = Exitoso
   - ❌ = Error
   - ⚠️ = Advertencia
   - 🔄 = Procesando

---

## 📞 ÚLTIMO RECURSO

Si nada funciona después de seguir todos los pasos:

1. **Verifica que el juego esté publicado** (no en Draft)
2. **Espera 5-10 minutos** después de configurar (a veces Roblox tarda en actualizar)
3. **Prueba con un producto pequeño** (ejemplo: 1 Robux) para testing
4. **Revisa la consola del servidor** para ver mensajes de error específicos
5. **Copia los mensajes de error** exactos y analízalos

---

## ✅ CONFIRMACIÓN DE QUE FUNCIONA

Sabrás que está funcionando cuando:

1. ✅ En la consola ves: "✅ Todos los Developer Products tienen IDs configurados"
2. ✅ Al hacer clic (sin SHIFT) aparece el prompt de Roblox
3. ✅ Después de comprar, ves: "📦 PROCESANDO COMPRA DE DEVELOPER PRODUCT"
4. ✅ El efecto se ejecuta (Kill All mata a todos, etc.)
5. ✅ Ves: "✅ Compra marcada como PurchaseGranted"

---

**Última actualización:** Sistema con logging mejorado para debugging fácil
