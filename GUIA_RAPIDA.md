# 🚀 GUÍA RÁPIDA - Sistema de Mascotas

**Instalación en 5 pasos para empezar rápido.**

---

## ⚡ PASO 1: Copiar Scripts

Copia todos los archivos de `src/` a tu juego de Roblox Studio siguiendo la estructura:

```
ServerScriptService/
  ├── CreateRemoteEvents
  ├── DataManager
  ├── PetSystemServer
  └── PetFollowSystem

ReplicatedStorage/
  ├── PetConfig
  └── ViewportUtil

StarterPlayer/StarterPlayerScripts/
  ├── EggProximityDetector
  └── PetSystemClient
```

---

## ⚡ PASO 2: Ejecutar Setup

1. Abre Roblox Studio
2. Dale **Play** (F5)
3. Verás en la consola: `Sistema de mascotas configurado ✓`
4. Detén el juego

Esto creará automáticamente:
- `ReplicatedStorage/RemoteEvents/` (con todos los eventos)
- `ReplicatedStorage/PetsModels/` (carpeta para tus modelos)
- `Workspace/Eggs/` (carpeta para tus huevos)

---

## ⚡ PASO 3: Configurar Moneda

1. Abre `ReplicatedStorage` → `PetConfig`
2. Cambia esta línea:

```lua
PetConfig.CurrencyName = "Coins"  -- Cambia "Coins" por TU moneda
```

**IMPORTANTE:** Debe coincidir con el nombre en `leaderstats`.

---

## ⚡ PASO 4: Crear Mascotas de Prueba

Crea 3 mascotas simples para probar:

### Mascota 1: Dog (Perro)
1. Crea un **Part** en Workspace (cualquier forma)
2. Selecciónalo → Ctrl+G para convertir en Model
3. Renombra el Model a: `Dog`
4. Selecciona el Model → Properties → `PrimaryPart` → Elige el Part
5. Mueve el Model a `ReplicatedStorage/PetsModels/`

### Mascota 2: Cat (Gato)
Repite lo mismo pero llámalo `Cat` y usa otro color.

### Mascota 3: Fox (Zorro)
Repite lo mismo pero llámalo `Fox` y usa otro color.

**Resultado:**
```
ReplicatedStorage/PetsModels/
  ├── Dog
  ├── Cat
  └── Fox
```

---

## ⚡ PASO 5: Crear Huevo de Prueba

1. Crea un **Part** en Workspace (forma de huevo o cubo)
2. Selecciónalo → Ctrl+G para convertir en Model
3. Renombra el Model a: `BasicEgg`
4. Selecciona el Model → Properties → `PrimaryPart` → Elige el Part
5. Mueve el Model a `Workspace/Eggs/`

**Resultado:**
```
Workspace/Eggs/
  └── BasicEgg
```

---

## ✅ PROBAR EL SISTEMA (Sin GUIs)

1. Dale **Play**
2. Acércate al huevo que creaste
3. Verás en la consola: `Mostrar GUI del huevo: BasicEgg`

**Esto significa que el sistema está funcionando.**

El huevo detectó tu proximidad y está listo para que conectes tu GUI.

---

## 🎨 PRÓXIMOS PASOS

### 1. Crear GUIs

Ve a la carpeta `examples/` y encontrarás 3 scripts de ejemplo:

- `EggShopGUI_Example.lua` - Para la GUI de compra de huevos
- `PetRewardGUI_Example.lua` - Para mostrar las mascotas obtenidas
- `InventoryGUI_Example.lua` - Para el inventario de mascotas

**Crea tus GUIs** y usa estos scripts como base.

### 2. Probar Apertura de Huevos

Una vez tengas la GUI del huevo funcionando:

1. Asegúrate de tener dinero (moneda configurada)
2. Presiona el botón "Abrir 1"
3. Deberías recibir una mascota aleatoria

### 3. Probar Equipar Mascotas

Desde tu GUI de inventario:

1. Equipar una mascota
2. La mascota debería aparecer siguiéndote en el mundo

---

## 🔑 CONFIGURACIÓN IMPORTANTE

### Cambiar Precios

En `PetConfig.lua`:

```lua
BasicEgg = {
    Price = 250,  -- Cambia esto
    -- ...
}
```

### Cambiar Probabilidades

```lua
Pets = {
    {Name = "Dog", Chance = 60},  -- 60%
    {Name = "Cat", Chance = 35},  -- 35%
    {Name = "Fox", Chance = 5},   -- 5%
}
-- Total debe sumar 100
```

### Cambiar IDs de Gamepasses

```lua
Gamepass_TripleOpen = 123456,  -- Tu ID aquí
Gamepass_AutoOpen = 7891011,   -- Tu ID aquí
```

**Para obtener el ID del gamepass:**
1. Crea el gamepass en Roblox.com
2. Copia el número de la URL

---

## 🎯 RECORDATORIOS

✅ **Los nombres deben coincidir:**
- Nombre del Model en `PetsModels` = `Name` en `PetConfig`
- Nombre del huevo en `Workspace/Eggs` = Clave en `PetConfig.Eggs`

✅ **Todos los Models necesitan `PrimaryPart`**

✅ **Las probabilidades deben sumar 100**

✅ **El `CurrencyName` debe coincidir con tu sistema de dinero**

---

## 🐛 PROBLEMAS COMUNES

### "RemoteEvent not found"
→ Ejecuta `CreateRemoteEvents` script

### "Modelo no encontrado"
→ Verifica que el nombre coincida exactamente (mayúsculas/minúsculas)

### Las mascotas no siguen
→ Verifica que el modelo tenga `PrimaryPart`
→ Verifica que el modelo esté en `ReplicatedStorage/PetsModels`

### No se guarda el inventario
→ Habilita DataStore en Game Settings

---

## 📚 DOCUMENTACIÓN COMPLETA

Lee `INSTRUCCIONES_SISTEMA_MASCOTAS.md` para la guía completa con:
- Estructura detallada
- Ejemplos de código
- RemoteEvents disponibles
- Configuración avanzada
- Troubleshooting completo

---

**¡Eso es todo! Ahora tienes el sistema funcionando.** 🎉
