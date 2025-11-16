# 🎯 Instrucciones: Instalación del Sistema de Multiplicadores

## 📦 ¿Qué hace este sistema?

- Permite a los jugadores comprar multiplicadores de dinero individuales
- Cada compra cuesta **$10,000**
- Cada compra aumenta el multiplicador en **+0.1** (x1.0 → x1.1 → x1.2, etc.)
- El multiplicador se aplica automáticamente a TODAS las recompensas de dinero
- Cada jugador tiene su propio multiplicador (visible en leaderstats)
- Se guarda en DataStore para persistencia entre sesiones

---

## 📋 Archivos Instalados

✅ **ServerScriptService/MultiplierSystem.lua** - Sistema servidor
✅ **ServerScriptService/MoneyManager.lua** - MODIFICADO para aplicar multiplicadores
✅ **MultiplierButtonClient.lua** - Script local para el botón

---

## 🔧 Instalación del Botón (Workspace)

### Paso 1: Crear la Part

1. En **Workspace**, crea una nueva **Part**
2. Nómbrala: `MultiplierPart`
3. Ajusta su tamaño y posición donde prefieras (recomendado: cerca del spawn)
4. Puedes cambiar su color para que destaque (ej: azul brillante)

### Paso 2: Crear el SurfaceGui

1. Dentro de **MultiplierPart**, inserta un **SurfaceGui**
2. Configura el SurfaceGui:
   - **Face**: `Front` (o la cara que mire hacia los jugadores)
   - **Adornee**: Selecciona `MultiplierPart`
   - **CanvasSize**: `{800, 600}` (recomendado)
   - **LightInfluence**: `0` (para que se vea bien iluminado)

### Paso 3: Crear el Botón

1. Dentro del **SurfaceGui**, inserta un **TextButton**
2. Nómbralo: `BuyButton`
3. Configura el botón (opcional, el script lo hará automáticamente):
   - **Size**: `{0.9, 0}, {0.9, 0}` (90% del SurfaceGui)
   - **Position**: `{0.05, 0}, {0.05, 0}` (centrado con margen)

### Paso 4: Instalar el Script

1. Dentro del **BuyButton**, inserta un **LocalScript**
2. Copia el contenido del archivo **MultiplierButtonClient.lua**
3. Pega el código en el LocalScript

### Estructura Final

```
Workspace
└── MultiplierPart (Part)
    └── SurfaceGui
        └── BuyButton (TextButton)
            └── LocalScript (con código de MultiplierButtonClient.lua)
```

---

## 🎮 Cómo Funciona

### Para el Jugador:

1. Se acerca a la Part del multiplicador
2. Ve su multiplicador actual (ej: "x1.0") y el siguiente (ej: "x1.1")
3. Ve el costo: "$10,000"
4. Presiona el botón
5. Si tiene suficiente dinero:
   - Se resta $10,000
   - Su multiplicador aumenta a x1.1
   - Recibe notificación: "🎉 ¡Multiplicador aumentado a x1.1!"
6. El botón se actualiza automáticamente

### Aplicación del Multiplicador:

El multiplicador se aplica **automáticamente** a:
- ✅ Cofres (ChestScript y MultiChestScript)
- ✅ Recompensas de misiones (QuestSystem)
- ✅ Recompensas de tiempo jugado (PlaytimeRewardSystem)
- ✅ Cualquier script que use `_G.AddMoney()`

**Ejemplo:**
- Cofre común da $50 base
- Jugador con x1.5 recibe: $50 × 1.5 = $75
- Jugador con x2.0 recibe: $50 × 2.0 = $100

---

## 📊 Estadística del Multiplicador

El multiplicador aparece en **leaderstats** como:
- **Nombre**: "Multiplicador"
- **Tipo**: NumberValue
- **Valor inicial**: 1.0
- **Visible en**: Leaderboard del juego

---

## 💾 Persistencia (DataStore)

- **DataStore**: `PlayerMultipliers_V1`
- **Clave**: `[UserId]_multiplier`
- **Guardado**:
  - Al salir del juego
  - Al cerrar el servidor
- **Cargado**:
  - Al entrar al juego

---

## 🎨 Personalización

### Cambiar el costo:

En **MultiplierSystem.lua**, línea 36:
```lua
local MULTIPLIER_COST = 10000  -- Cambia este valor
```

En **MultiplierButtonClient.lua**, línea 23:
```lua
local MULTIPLIER_COST = 10000  -- Cambia este valor
```

### Cambiar el incremento:

En **MultiplierSystem.lua**, línea 37:
```lua
local MULTIPLIER_INCREMENT = 0.1  -- Cambia a 0.2 para x1.2, etc.
```

### Cambiar colores del botón:

En **MultiplierButtonClient.lua**, líneas 25-27:
```lua
local COLOR_DEFAULT = Color3.fromRGB(85, 170, 255)  -- Azul
local COLOR_HOVER = Color3.fromRGB(100, 190, 255)   -- Azul claro
local COLOR_PRESSED = Color3.fromRGB(70, 150, 230)  -- Azul oscuro
```

---

## 🔍 Debugging

### Verificar que funciona:

1. **Consola del Servidor** (Output):
   ```
   ✅ DataStore de Multiplicadores inicializado
   ✨ Sistema de Multiplicadores cargado
   ✅ Multiplicador inicializado para [Jugador]: x1.0
   ```

2. **Consola del Cliente** (Output):
   ```
   ✅ Botón de multiplicador inicializado para [Jugador]
   ```

3. **Al comprar**:
   ```
   ✅ [Jugador] compró multiplicador: x1.0 → x1.1
   💰 [Jugador] ganó $55 (base: $50 × 1.1)
   ```

### Problemas comunes:

**El botón no aparece:**
- Verifica que el LocalScript esté dentro del TextButton
- Verifica que Face esté configurado correctamente
- Verifica que Adornee apunte a la Part

**El multiplicador no se aplica:**
- Verifica que MultiplierSystem.lua se cargue ANTES que MoneyManager.lua
- Verifica en Output que veas: "✨ Sistema de Multiplicadores cargado"

**No se puede comprar:**
- Verifica que tienes $10,000
- Verifica que los RemoteEvents existan en ReplicatedStorage
- Revisa Output por errores

---

## ✨ Ejemplo Completo de Uso

1. Jugador entra al juego con x1.0
2. Juega y gana dinero hasta tener $10,000
3. Va a la Part del multiplicador
4. Presiona el botón
5. Gasta $10,000 → Multiplicador sube a x1.1
6. Ahora cuando abre un cofre de $50, recibe $55
7. Sigue jugando y ahorra $10,000 otra vez
8. Compra de nuevo → x1.2
9. Cofre de $50 ahora da $60

---

## 🎯 Notas Importantes

- ✅ **Cada jugador** tiene su propio multiplicador
- ✅ **Todos ven el mismo botón**, pero cada uno ve su propio multiplicador
- ✅ **El multiplicador se aplica automáticamente** a todas las recompensas
- ✅ **No hay límite** de cuántas veces se puede comprar
- ✅ **Se guarda entre sesiones** en DataStore
- ✅ **Aparece en leaderstats** visible para todos

---

## 📞 Soporte

Si tienes problemas:
1. Revisa Output (F9) para ver errores
2. Verifica que todos los scripts estén en las ubicaciones correctas
3. Asegúrate que DataStore esté habilitado en Studio
4. Verifica que MultiplierSystem se cargue antes que los demás scripts

---

¡Listo! Ahora tus jugadores pueden aumentar sus ganancias comprando multiplicadores 💰✨
