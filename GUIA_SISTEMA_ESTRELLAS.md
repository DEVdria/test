# ⭐ GUÍA COMPLETA - Sistema de Estrellas Coleccionables

## 📋 RESUMEN DEL SISTEMA

El sistema de estrellas te permite crear objetos coleccionables que dan EXP y dinero repetidamente. A diferencia de los orbs, las estrellas:
- **NO desaparecen** después de tocarlas
- Tienen **cooldown de 3 segundos** por estrella
- Se pueden **recolectar infinitamente**
- Tienen **animación** (rotación + flotación)
- Son **visibles solo para el cliente** (como los orbs)

---

## 🌟 CARACTERÍSTICAS

### Animación automática:
- ✅ Rotación continua
- ✅ Flotación vertical (movimiento sinusoidal)
- ✅ Efecto visual de cooldown (encogimiento temporal)

### Recompensas configurables:
- ✅ EXP por recolección
- ✅ Dinero por recolección
- ✅ Multiplicador de EXP aplicado (por rebirths)

### Sistema de cooldown:
- ✅ 3 segundos por estrella (configurable)
- ✅ Cooldown individual por estrella
- ✅ No hay cooldown global
- ✅ Efecto visual durante cooldown

---

## 🔧 CONFIGURACIÓN DE ESTRELLAS

### Ubicación:
**Archivo:** `ReplicatedStorage > Modules > StarConfig`
**Tipo:** ModuleScript

### Estructura por defecto (star1 - star19):

```lua
StarConfig.Stars = {
	star1 = {
		EXPReward = 10,          -- EXP que da
		MoneyReward = 50,        -- Dinero que da
		Color = Color3.fromRGB(255, 255, 100),  -- Color amarillo
	},
	star2 = {
		EXPReward = 10,
		MoneyReward = 50,
		Color = Color3.fromRGB(255, 255, 100),
	},
	-- ... star3 a star19 con mismos valores
}
```

### Configuración general:

```lua
StarConfig.General = {
	CollectionCooldown = 3,      -- Segundos de cooldown
	CollectionDistance = 10,     -- Distancia para recolectar (studs)
	RotationSpeed = 45,          -- Velocidad de rotación (grados/segundo)
	BobHeight = 1.5,             -- Altura de flotación (studs)
	BobSpeed = 2,                -- Velocidad de flotación
}
```

---

## 🎨 PERSONALIZACIÓN DE RECOMPENSAS

### Estrellas con diferentes recompensas:

```lua
StarConfig.Stars = {
	-- Estrellas básicas (1-5)
	star1 = { EXPReward = 10, MoneyReward = 50, Color = Color3.fromRGB(255, 255, 100) },
	star2 = { EXPReward = 10, MoneyReward = 50, Color = Color3.fromRGB(255, 255, 100) },
	star3 = { EXPReward = 10, MoneyReward = 50, Color = Color3.fromRGB(255, 255, 100) },
	star4 = { EXPReward = 10, MoneyReward = 50, Color = Color3.fromRGB(255, 255, 100) },
	star5 = { EXPReward = 10, MoneyReward = 50, Color = Color3.fromRGB(255, 255, 100) },

	-- Estrellas intermedias (6-10) - MÁS RECOMPENSA
	star6 = { EXPReward = 20, MoneyReward = 100, Color = Color3.fromRGB(100, 255, 255) },
	star7 = { EXPReward = 20, MoneyReward = 100, Color = Color3.fromRGB(100, 255, 255) },
	star8 = { EXPReward = 20, MoneyReward = 100, Color = Color3.fromRGB(100, 255, 255) },
	star9 = { EXPReward = 20, MoneyReward = 100, Color = Color3.fromRGB(100, 255, 255) },
	star10 = { EXPReward = 20, MoneyReward = 100, Color = Color3.fromRGB(100, 255, 255) },

	-- Estrellas avanzadas (11-15) - MUCHA RECOMPENSA
	star11 = { EXPReward = 50, MoneyReward = 250, Color = Color3.fromRGB(255, 100, 255) },
	star12 = { EXPReward = 50, MoneyReward = 250, Color = Color3.fromRGB(255, 100, 255) },
	star13 = { EXPReward = 50, MoneyReward = 250, Color = Color3.fromRGB(255, 100, 255) },
	star14 = { EXPReward = 50, MoneyReward = 250, Color = Color3.fromRGB(255, 100, 255) },
	star15 = { EXPReward = 50, MoneyReward = 250, Color = Color3.fromRGB(255, 100, 255) },

	-- Estrellas legendarias (16-19) - MÁXIMA RECOMPENSA
	star16 = { EXPReward = 100, MoneyReward = 500, Color = Color3.fromRGB(255, 0, 0) },
	star17 = { EXPReward = 100, MoneyReward = 500, Color = Color3.fromRGB(255, 0, 0) },
	star18 = { EXPReward = 100, MoneyReward = 500, Color = Color3.fromRGB(255, 0, 0) },
	star19 = { EXPReward = 100, MoneyReward = 500, Color = Color3.fromRGB(255, 0, 0) },
}
```

---

## 🏗️ CREAR LAS ESTRELLAS EN WORKSPACE

### PASO 1: Crear carpeta Stars

1. Ve a **Workspace**
2. Insert Object → **Folder**
3. Renombrar a: **Stars** (nombre exacto)

### PASO 2: Crear modelos de estrellas

Para cada estrella (star1 a star19):

#### Opción 1: Estrella simple (Part única)

1. Insert Object → **Part**
2. Renombrar a: **star1** (o star2, star3, etc.)
3. Configurar propiedades:
   ```
   Size: (2, 2, 2) o el tamaño que quieras
   Shape: Ball o Block
   Material: Neon
   Color: Amarillo (255, 255, 100)
   Anchored: true
   CanCollide: false
   Transparency: 0
   ```

#### Opción 2: Estrella con modelo (Model + Part)

1. Insert Object → **Model**
2. Renombrar a: **star1**
3. Dentro del Model:
   - Insert Object → **Part** o **MeshPart**
   - Configurar propiedades:
     ```
     Material: Neon
     Color: (se aplicará automáticamente desde StarConfig)
     Anchored: true
     CanCollide: false
     ```

#### Opción 3: Estrella con SpecialMesh

1. Insert Object → **Part**
2. Renombrar a: **star1**
3. Insert Object → **SpecialMesh** (dentro del Part)
4. Configurar SpecialMesh:
   ```
   MeshType: FileMesh
   MeshId: rbxassetid://STAR_MESH_ID
   Scale: (1.5, 1.5, 1.5)
   ```

**Sugerencias de MeshId para estrellas:**
- rbxassetid://1290033 (estrella clásica)
- rbxassetid://14774856 (estrella puntiaguda)
- Usa tu propio modelo

---

## 🎨 COLORES RECOMENDADOS

### Por rareza:

| Tipo | Color RGB | Uso |
|---|---|---|
| **Común** | (255, 255, 100) | Amarillo - star1 a star5 |
| **Raro** | (100, 255, 255) | Cyan - star6 a star10 |
| **Épico** | (255, 100, 255) | Magenta - star11 a star15 |
| **Legendario** | (255, 0, 0) | Rojo - star16 a star19 |
| **Especial** | (255, 255, 255) | Blanco - Estrellas únicas |

### Por zona:

```lua
-- Zona 1 (inicial)
star1-5: Color3.fromRGB(255, 255, 100)  -- Amarillo

-- Zona 2
star6-10: Color3.fromRGB(100, 200, 255)  -- Azul claro

-- Zona 3
star11-15: Color3.fromRGB(255, 150, 0)  -- Naranja

-- Zona 4
star16-19: Color3.fromRGB(200, 0, 255)  -- Púrpura
```

---

## ⚙️ CONFIGURACIÓN AVANZADA

### Cambiar cooldown:

```lua
-- En StarConfig.lua, línea 28
CollectionCooldown = 5,  -- Cambiar a 5 segundos
```

### Cambiar distancia de recolección:

```lua
-- En StarConfig.lua, línea 29
CollectionDistance = 15,  -- Cambiar a 15 studs
```

### Cambiar velocidad de animación:

```lua
-- Rotación más rápida
RotationSpeed = 90,  -- 90 grados/segundo (más rápido)

-- Flotación más pronunciada
BobHeight = 3,       -- 3 studs de altura
BobSpeed = 3,        -- Más rápido
```

### Estrellas que solo den EXP:

```lua
star1 = {
	EXPReward = 50,
	MoneyReward = 0,  -- Sin dinero
	Color = Color3.fromRGB(100, 255, 100),
},
```

### Estrellas que solo den dinero:

```lua
star2 = {
	EXPReward = 0,  -- Sin EXP
	MoneyReward = 200,
	Color = Color3.fromRGB(255, 215, 0),
},
```

---

## 🔧 CREAR REMOTEEVENT NECESARIO

En **ReplicatedStorage > RemoteEvents**, crea:

1. **StarCollected** (RemoteEvent)

**Cómo crear:**
- Clic derecho en `RemoteEvents`
- Insert Object → RemoteEvent
- Renombrar exactamente a: **StarCollected**

---

## 📦 INSTALACIÓN COMPLETA

### PASO 1: Añadir módulo StarConfig

1. Ve a: `ReplicatedStorage > Modules`
2. Insert Object → **ModuleScript**
3. Renombrar a: **StarConfig**
4. Pegar contenido de: `ReplicatedStorage_Modules_StarConfig.lua`

### PASO 2: Añadir StarManager

1. Ve a: `ServerScriptService`
2. Insert Object → **Script**
3. Renombrar a: **StarManager**
4. Pegar contenido de: `ServerScriptService_StarManager.lua`

### PASO 3: Añadir StarClientManager

1. Ve a: `StarterPlayer > StarterPlayerScripts`
2. Insert Object → **LocalScript**
3. Renombrar a: **StarClientManager**
4. Pegar contenido de: `StarterPlayer_StarterPlayerScripts_StarClientManager.lua`

### PASO 4: Crear RemoteEvent

En `ReplicatedStorage > RemoteEvents`:
- Crear **StarCollected** (RemoteEvent)

### PASO 5: Crear carpeta Stars en Workspace

1. Crear carpeta **Stars** en Workspace
2. Crear Parts/Models con nombres: **star1, star2, star3, ..., star19**
3. Configurar cada estrella según el diseño que quieras

### PASO 6: Configurar recompensas en StarConfig

1. Abre: `ReplicatedStorage > Modules > StarConfig`
2. Modifica las recompensas según tus preferencias

---

## ✅ VERIFICACIÓN

### Checklist:

1. ✅ StarConfig existe en ReplicatedStorage/Modules
2. ✅ StarManager existe en ServerScriptService
3. ✅ StarClientManager existe en StarterPlayerScripts
4. ✅ RemoteEvent StarCollected existe en ReplicatedStorage/RemoteEvents
5. ✅ Carpeta Stars existe en Workspace
6. ✅ Al menos una estrella existe (star1)

### Test básico:

1. **Inicia el juego**
2. **Verifica Output:**
   ```
   [StarManager] ✅ Sistema de estrellas del servidor inicializado
   [StarClientManager] ✅ Sistema de estrellas del cliente inicializado
   [StarClientManager] ✅ Estrella star1 configurada para animación
   ```
3. **Observa las estrellas:**
   - Deben estar rotando
   - Deben estar flotando arriba y abajo
   - Deben tener el color configurado en StarConfig
4. **Acércate a una estrella**
5. **Debe recolectarse automáticamente:**
   - Notificación de EXP y dinero
   - Efecto visual de encogimiento
   - Después de 3 segundos, se puede recolectar de nuevo

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "No se encontró carpeta 'Stars' en Workspace"

**Solución:** Crea una carpeta llamada "Stars" (exacto) en Workspace

### ❌ Error: "No se encontró RemoteEvent 'StarCollected'"

**Solución:**
1. Ve a ReplicatedStorage > RemoteEvents
2. Insert Object → RemoteEvent
3. Renombrar a: StarCollected

### ❌ Las estrellas no se animan

**Verifica:**
1. StarClientManager está en StarterPlayerScripts
2. Las estrellas tienen un BasePart (Part o MeshPart)
3. No hay errores en Output

### ❌ Las estrellas no dan recompensas

**Verifica:**
1. StarManager está en ServerScriptService
2. RemoteEvent StarCollected existe
3. Estás lo suficientemente cerca (10 studs por defecto)
4. No hay cooldown activo

### ❌ Las estrellas desaparecen

**Esto no debería pasar.** Verifica:
1. El código no está modificado
2. No hay otros scripts eliminando las estrellas

### ❌ No se puede recolectar después del cooldown

**Verifica:**
1. Espera los 3 segundos completos
2. Mira Output para ver si hay errores
3. Verifica que StarManager esté funcionando

---

## 💡 TIPS AVANZADOS

### Distribuir estrellas por zonas:

```
Workspace
  └─ Stars
      ├─ star1 (Zona inicial, fácil acceso)
      ├─ star2 (Zona inicial)
      ├─ star3 (Zona inicial)
      ├─ star4 (Zona inicial)
      ├─ star5 (Zona inicial)
      ├─ star6 (Zona 2, recompensa media)
      ├─ star7 (Zona 2)
      ...
      ├─ star16 (Zona final, alta recompensa)
      ├─ star17 (Zona final)
      ├─ star18 (Zona final)
      └─ star19 (Zona final, lugar secreto)
```

### Crear estrellas secretas:

Coloca estrellas en lugares difíciles de alcanzar:
- Detrás de obstáculos
- En plataformas altas
- En áreas ocultas

### Progresión de recompensas:

```lua
-- Progresión lineal (10, 20, 30, 40...)
star1 = { EXPReward = 10, MoneyReward = 50 },
star2 = { EXPReward = 20, MoneyReward = 100 },
star3 = { EXPReward = 30, MoneyReward = 150 },
...

-- Progresión exponencial (10, 20, 40, 80...)
star1 = { EXPReward = 10, MoneyReward = 50 },
star2 = { EXPReward = 20, MoneyReward = 100 },
star3 = { EXPReward = 40, MoneyReward = 200 },
star4 = { EXPReward = 80, MoneyReward = 400 },
```

### Añadir efectos de partículas:

```lua
-- En Roblox Studio:
1. Selecciona el Part de la estrella
2. Insert Object → ParticleEmitter
3. Configurar:
   - Color: Color del brillo
   - Size: NumberSequence pequeño
   - Transparency: NumberSequence (0 → 1)
   - Rate: 10-20
   - Lifetime: 0.5-1
```

### Añadir luz brillante:

```lua
-- En Roblox Studio:
1. Selecciona el Part de la estrella
2. Insert Object → PointLight
3. Configurar:
   - Brightness: 5
   - Color: Color de la estrella
   - Range: 15
```

---

## 🎯 COMPARACIÓN CON ORBS

| Característica | Orbs | Estrellas |
|---|---|---|
| **Ubicación** | ServerStorage/Orbs | Workspace/Stars |
| **Visibilidad** | Solo cliente | Solo cliente |
| **Recompensa** | Solo EXP | EXP + Dinero |
| **Cooldown** | No | Sí (3 seg) |
| **Desaparece** | Sí (5 seg) | No |
| **Reaparece** | Sí (5 seg) | Siempre visible |
| **Recolectable** | 1 vez cada 5 seg | Infinitas veces |
| **Animación** | Rotación + flotación | Rotación + flotación |
| **Efecto visual** | Tween de tamaño | Shrink en cooldown |

---

## 📊 VALORES RECOMENDADOS

### Para juego fácil (farming rápido):

```lua
StarConfig.General = {
	CollectionCooldown = 2,      -- 2 segundos
	CollectionDistance = 15,     -- 15 studs (más fácil)
}

StarConfig.Stars = {
	star1 = { EXPReward = 20, MoneyReward = 100 },  -- Más recompensa
}
```

### Para juego normal (balance):

```lua
StarConfig.General = {
	CollectionCooldown = 3,      -- 3 segundos
	CollectionDistance = 10,     -- 10 studs
}

StarConfig.Stars = {
	star1 = { EXPReward = 10, MoneyReward = 50 },
}
```

### Para juego difícil (progresión lenta):

```lua
StarConfig.General = {
	CollectionCooldown = 5,      -- 5 segundos
	CollectionDistance = 7,      -- 7 studs (más difícil)
}

StarConfig.Stars = {
	star1 = { EXPReward = 5, MoneyReward = 25 },  -- Menos recompensa
}
```

---

## 🎯 RESUMEN

**Para crear el sistema de estrellas:**
1. Añadir StarConfig a Modules
2. Añadir StarManager a ServerScriptService
3. Añadir StarClientManager a StarterPlayerScripts
4. Crear RemoteEvent StarCollected
5. Crear carpeta Stars en Workspace con star1-star19
6. Configurar recompensas en StarConfig

**El sistema se encarga de:**
- ✅ Animar las estrellas (rotación + flotación)
- ✅ Detectar colisión con el jugador
- ✅ Aplicar cooldown de 3 segundos
- ✅ Dar EXP y dinero
- ✅ Aplicar multiplicador de EXP por rebirths
- ✅ Mostrar notificaciones
- ✅ Efecto visual de cooldown

**TÚ controlas:**
- ✅ Diseño de las estrellas (Part, Model, Mesh)
- ✅ Ubicación de cada estrella
- ✅ Recompensas de EXP y dinero
- ✅ Colores y efectos visuales
- ✅ Cooldown y distancia de recolección
- ✅ Cuántas estrellas crear (hasta 19 por defecto)

---

¡Sistema de estrellas completamente configurable! ⭐💎✨
