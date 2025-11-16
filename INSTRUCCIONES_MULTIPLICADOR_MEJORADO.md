# 🚀 Instalación Rápida del Sistema de Multiplicadores

## ⚡ Método Automático (RECOMENDADO)

### Paso 1: Verificar que los scripts estén instalados

Asegúrate de tener estos scripts en **ServerScriptService**:
- ✅ `MultiplierSystem.lua`
- ✅ `MultiplierSetup.lua` (NUEVO)
- ✅ `MoneyManager.lua` (modificado)

### Paso 2: Ejecutar el juego

1. Presiona **F5** o haz clic en **Play**
2. Espera 5 segundos
3. Verás en la consola (F9):
   ```
   ✅ MultiplierPart creada exitosamente en el Workspace!
   📍 Posición: 0, 10, 0
   🗑️ Auto-eliminando script de instalación...
   ```

### Paso 3: Detener y ajustar posición

1. Presiona **F6** para detener
2. Ve al **Workspace** → Encontrarás **MultiplierPart**
3. Muévela a donde quieras (cerca del spawn, en tu lobby, etc.)
4. ¡Listo! Ya funciona

### Paso 4: Verificar que funciona

1. Ejecuta el juego de nuevo
2. Acércate a la Part
3. Deberías ver el botón con tu multiplicador actual
4. Si tienes $10,000, presiona el botón para comprar

---

## 📋 ¿Qué crea automáticamente?

El script **MultiplierSetup.lua** crea:

```
Workspace
└── MultiplierPart (Part azul brillante)
    ├── PointLight (luz azul)
    └── MultiplierGui (SurfaceGui)
        └── Background (Frame)
            └── BuyButton (TextButton)
                └── MultiplierButtonClient (LocalScript)
```

### Características de la Part:

- **Tamaño:** 8 x 6 x 1 studs
- **Color:** Azul profundo
- **Material:** SmoothPlastic
- **Luz:** Punto de luz azul brillante
- **Anclada:** Sí (no se cae ni se mueve)

### Características del Botón:

- **Muestra:**
  - Tu multiplicador actual (ej: x1.0)
  - El siguiente multiplicador (ej: x1.1)
  - El costo ($10,000)
  - Tu dinero actual
  - ✅ si puedes comprar / ❌ si no tienes suficiente

- **Colores:**
  - Azul brillante: Puedes comprar
  - Gris oscuro: No tienes suficiente dinero
  - Verde al pasar el mouse (hover)
  - Azul oscuro al hacer clic

- **Actualizaciones:**
  - Se actualiza cada 2 segundos
  - Se actualiza cuando cambia tu dinero
  - Se actualiza cuando cambia tu multiplicador

---

## 🎨 Personalización

### Cambiar la posición inicial:

En **MultiplierSetup.lua**, línea 35:
```lua
part.Position = Vector3.new(0, 10, 0) -- Cambia X, Y, Z aquí
```

### Cambiar el tamaño:

En **MultiplierSetup.lua**, línea 34:
```lua
part.Size = Vector3.new(8, 6, 1) -- Ancho, Alto, Profundidad
```

### Cambiar el color:

En **MultiplierSetup.lua**, línea 38:
```lua
part.BrickColor = BrickColor.new("Deep blue") -- Cambia el color
-- Opciones: "Bright red", "Bright green", "Bright yellow", etc.
```

### Cambiar el costo:

1. **MultiplierSystem.lua**, línea 36:
   ```lua
   local MULTIPLIER_COST = 10000  -- Cambia este valor
   ```

2. **MultiplierSetup.lua**, línea 120:
   ```lua
   local MULTIPLIER_COST = 10000  -- Debe ser el mismo
   ```

---

## 🔧 Solución de Problemas

### ❌ El botón dice "ERROR - No se pudo conectar al servidor"

**Causa:** MultiplierSystem.lua no se está ejecutando

**Solución:**
1. Verifica que `MultiplierSystem.lua` esté en **ServerScriptService**
2. Abre la consola (F9) y busca: `✨ Sistema de Multiplicadores cargado`
3. Si no aparece, revisa si hay errores en rojo

---

### ❌ El botón dice "Cargando..." y no cambia

**Causa:** El jugador no tiene leaderstats aún

**Solución:**
1. Espera 2-3 segundos más
2. Verifica que `MoneyManager.lua` esté cargado
3. Busca en consola: `👤 [TuNombre] se ha unido con $XXX`

---

### ❌ No veo la Part en el Workspace

**Causa:** El script no se ejecutó o ya se eliminó

**Solución:**
1. Verifica que ejecutaste el juego con el script presente
2. Si ya se eliminó automáticamente:
   - Copia el archivo desde el repositorio
   - Pégalo de nuevo en ServerScriptService
   - Ejecuta el juego una vez más

---

### ❌ El botón está muy pequeño/grande

**Causa:** La Part está muy lejos/cerca

**Solución:**
1. Ajusta el tamaño de la Part:
   ```lua
   part.Size = Vector3.new(10, 8, 1) -- Más grande
   part.Size = Vector3.new(6, 4, 1)  -- Más pequeño
   ```

2. O ajusta el `PixelsPerStud` en línea 56:
   ```lua
   surfaceGui.PixelsPerStud = 100 -- Más alto = botón más pequeño
   surfaceGui.PixelsPerStud = 50  -- Más bajo = botón más grande
   ```

---

## 📊 Cómo Funciona

### 1. Jugador ve el botón:
```
💰 COMPRAR MULTIPLICADOR 💰

Actual: x1.0 → Siguiente: x1.1

Costo: $10,000
Tu dinero: $8,500 ❌
```

### 2. Junta más dinero y el botón se actualiza:
```
💰 COMPRAR MULTIPLICADOR 💰

Actual: x1.0 → Siguiente: x1.1

Costo: $10,000
Tu dinero: $12,000 ✅
```

### 3. Hace clic y compra:
- Botón dice: "⏳ COMPRANDO..."
- Se resta $10,000
- Multiplicador sube a x1.1
- Notificación: "🎉 ¡Multiplicador aumentado a x1.1!"

### 4. Botón se actualiza:
```
💰 COMPRAR MULTIPLICADOR 💰

Actual: x1.1 → Siguiente: x1.2

Costo: $10,000
Tu dinero: $2,000 ❌
```

---

## 🎮 Ejemplo Completo

```
Jugador "SmySk1ll" entra al juego:
1. Ve la Part azul brillante
2. Se acerca y lee: "x1.0 → x1.1, $10,000, Tu dinero: $100 ❌"
3. Juega y gana dinero hasta tener $10,000
4. El botón cambia a: "Tu dinero: $10,000 ✅" (azul brillante)
5. Hace clic en el botón
6. Botón dice: "⏳ COMPRANDO..."
7. Recibe notificación: "🎉 ¡Multiplicador aumentado a x1.1!"
8. Su dinero: $10,000 - $10,000 = $0
9. Abre un cofre de $50 → Recibe $55 ($50 × 1.1)
10. Console muestra: "💰 SmySk1ll ganó $55 (base: $50 × 1.1)"
```

---

## ✅ Checklist de Instalación

- [ ] `MultiplierSystem.lua` en ServerScriptService
- [ ] `MultiplierSetup.lua` en ServerScriptService
- [ ] `MoneyManager.lua` actualizado (con multiplicadores)
- [ ] Ejecutar el juego una vez
- [ ] Ver mensaje: "✅ MultiplierPart creada exitosamente"
- [ ] Ajustar posición de la Part (opcional)
- [ ] Probar comprando un multiplicador

---

## 🎯 Diferencias con la Versión Anterior

| Característica | Versión Anterior | Versión Nueva (Automática) |
|----------------|------------------|---------------------------|
| **Instalación** | Manual, 7 pasos | Automática, 1 paso |
| **Errores** | Muchos posibles | Casi ninguno |
| **Configuración** | Compleja | Simple |
| **Script del cliente** | Copiar/pegar manualmente | Se crea automáticamente |
| **SurfaceGui** | Configurar a mano | Configurado perfectamente |
| **Posición** | Difícil de ajustar | Fácil de mover después |

---

## 💡 Consejos

1. **Posicionamiento:**
   - Coloca la Part cerca del spawn para que sea fácil de encontrar
   - Ponla flotando (Y alto) para que se vea desde lejos
   - Usa la luz para atraer atención

2. **Diseño:**
   - Puedes cambiar el color según tu tema
   - Puedes cambiar el Material a Neon para más brillo
   - Puedes añadir más decoración alrededor

3. **Economía:**
   - Ajusta el costo según tu economía
   - Si el dinero es fácil de conseguir: costo alto ($50,000)
   - Si el dinero es difícil: costo bajo ($5,000)

4. **Multiplicador:**
   - Puedes cambiar el incremento de 0.1 a 0.2 para saltos más grandes
   - No hay límite de compras, los jugadores pueden llegar a x10.0 o más

---

## 📞 Soporte Rápido

**¿No funciona?**
1. Abre la consola (F9)
2. Busca estos mensajes:
   - ✅ `Sistema de Multiplicadores cargado`
   - ✅ `MultiplierPart creada exitosamente`
   - ✅ `Botón de multiplicador inicializado`

**Si faltan:**
- Verifica que todos los scripts estén en ServerScriptService
- Asegúrate de ejecutar el juego, no solo abrir en edit mode
- Revisa que no haya errores en rojo en la consola

---

¡Listo! Con este método automático, la instalación es **100 veces más fácil** 🚀✨
