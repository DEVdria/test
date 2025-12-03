# 🗺️ GUÍA COMPLETA - Sistema de Compra de Zonas

## 📋 RESUMEN DEL SISTEMA

Este sistema te permite crear zonas que los jugadores pueden comprar con dinero. Cada zona tiene:
- **Precio** ($0 = gratis)
- **Requisitos de nivel**
- **Requisitos de rebirths**
- **SurfaceGui personalizada** (TÚ la diseñas)

---

## 🔧 CONFIGURACIÓN DE ZONAS

### Ubicación:
**Archivo:** `ReplicatedStorage > Modules > ZoneConfig`
**Tipo:** ModuleScript

### Cómo añadir zonas:

Abre **ZoneConfig** y edita la tabla `ZoneConfig.Zones`:

```lua
ZoneConfig.Zones = {
	{
		ID = "Zone1",                    -- Nombre del Part en Workspace
		Name = "Zona Inicial",           -- Nombre mostrado en la GUI
		Price = 0,                       -- $0 = gratis
		RequiredRebirths = 0,
		RequiredLevel = 0,
		IsDefault = true,                -- Se desbloquea al inicio
	},
	{
		ID = "Zone2",
		Name = "Zona Avanzada",
		Price = 5000,                    -- Cuesta $5,000
		RequiredRebirths = 0,
		RequiredLevel = 5,               -- Necesita nivel 5
		IsDefault = false,
	},
	{
		ID = "Zone3",
		Name = "Zona Experta",
		Price = 15000,
		RequiredRebirths = 1,            -- Necesita 1 rebirth
		RequiredLevel = 10,
		IsDefault = false,
	},
}
```

---

## 🏗️ CREAR LAS PARTS EN WORKSPACE

### PASO 1: Crear carpeta Buy Zones

1. Ve a **Workspace**
2. Insert Object → **Folder**
3. Renombrar a: **Buy Zones** (nombre exacto)

### PASO 2: Crear Parts de zonas

Para cada zona en ZoneConfig:

1. Insert Object → **Part**
2. Renombrar exactamente como el **ID** en ZoneConfig (ej: Zone1, Zone2)
3. Configurar propiedades:
   ```
   Size: (20, 15, 1) o el tamaño que quieras
   Anchored: true
   CanCollide: false
   Transparency: 0 o 0.5 (semi-transparente)
   Color: A tu gusto
   ```

---

## 🎨 DISEÑAR LAS SURFACEGUIS

### PASO 1: Crear SurfaceGui

1. Selecciona el **Part de la zona** (ej: Zone1)
2. Insert Object → **SurfaceGui**
3. Configurar propiedades:
   ```
   Face: Front (o la cara que quieras)
   CanvasSize: (800, 600) o más grande
   ```

### PASO 2: Estructura mínima requerida

El script busca estos elementos **por nombre**. Crea los que necesites:

```
Part (Zone1)
  └─ SurfaceGui
      ├─ ZoneName (TextLabel) ← OPCIONAL
      ├─ PriceLabel (TextLabel) ← OPCIONAL
      ├─ RequirementsLabel (TextLabel) ← OPCIONAL
      ├─ StatusLabel (TextLabel o Frame) ← OPCIONAL
      └─ PurchaseButton (TextButton) ← OBLIGATORIO
```

**IMPORTANTE:** Solo **PurchaseButton** es obligatorio. Los demás son opcionales.

---

## 🖼️ ELEMENTOS DE LA SURFACEGUI

### **ZoneName** (TextLabel) - Nombre de la zona
```
Nombre: ZoneName (o NameLabel)
Tipo: TextLabel
Text: (se actualiza automáticamente)
TextSize: 24
Font: GothamBold
```

**Qué hace:** Muestra el nombre de la zona (ej: "Zona Inicial")

---

### **PriceLabel** (TextLabel) - Precio
```
Nombre: PriceLabel (o Cost)
Tipo: TextLabel
Text: (se actualiza automáticamente)
TextSize: 32
Font: GothamBold
TextColor3: Amarillo (255, 255, 0)
```

**Qué hace:** Muestra el precio formateado (ej: "$5,000" o "GRATIS")

---

### **RequirementsLabel** (TextLabel) - Requisitos
```
Nombre: RequirementsLabel (o Requirements)
Tipo: TextLabel
Text: (se actualiza automáticamente)
TextSize: 18
Font: Gotham
TextWrapped: true
```

**Qué hace:** Muestra requisitos (ej: "Requisitos: Nivel 5, 1 Rebirths")

---

### **StatusLabel** (TextLabel o Frame) - Estado
```
Nombre: StatusLabel (o Status)
Tipo: TextLabel o Frame
Text: (se actualiza automáticamente si es TextLabel)
```

**Qué hace:**
- Si es **TextLabel**: Muestra "✅ DESBLOQUEADA" (verde) o "🔒 BLOQUEADA" (rojo)
- Si es **Frame**: Cambia color de fondo a verde o rojo

---

### **PurchaseButton** (TextButton) - Botón de compra ⚠️ OBLIGATORIO
```
Nombre: PurchaseButton (o BuyButton)
Tipo: TextButton
Size: {0.5, 0},{0.2, 0} (mitad del ancho, 20% alto)
Position: Centro inferior
Text: "COMPRAR"
TextSize: 24
Font: GothamBold
BackgroundColor3: Azul (0, 150, 255)
```

**Qué hace:**
- Si la zona está desbloqueada: Muestra "DESBLOQUEADA" (verde) y desactiva el botón
- Si está bloqueada: Muestra "COMPRAR" (azul) y permite hacer clic

---

## 📐 DISEÑO EJEMPLO 1: MINIMALISTA

```
SurfaceGui
  ├─ ZoneName (TextLabel)
  │   Size: {1, 0},{0.3, 0}
  │   Position: {0, 0},{0, 0}
  │   TextColor3: Blanco
  │
  ├─ PriceLabel (TextLabel)
  │   Size: {1, 0},{0.3, 0}
  │   Position: {0, 0},{0.3, 0}
  │   TextColor3: Amarillo
  │
  └─ PurchaseButton (TextButton)
      Size: {0.8, 0},{0.2, 0}
      Position: {0.1, 0},{0.7, 0}
```

---

## 📐 DISEÑO EJEMPLO 2: COMPLETO

```
SurfaceGui
  ├─ Background (Frame) ← Fondo decorativo
  │
  ├─ ZoneName (TextLabel)
  │   Position: {0, 0},{0, 10}
  │   Size: {1, 0},{0, 60}
  │   TextSize: 36
  │
  ├─ PriceLabel (TextLabel)
  │   Position: {0, 0},{0, 80}
  │   Size: {1, 0},{0, 80}
  │   TextSize: 48
  │
  ├─ RequirementsLabel (TextLabel)
  │   Position: {0, 0},{0, 170}
  │   Size: {1, 0},{0, 40}
  │   TextSize: 20
  │
  ├─ StatusLabel (TextLabel)
  │   Position: {0, 0},{0, 220}
  │   Size: {1, 0},{0, 40}
  │   TextSize: 24
  │
  └─ PurchaseButton (TextButton)
      Position: {0.1, 0},{0, 280}
      Size: {0.8, 0},{0, 60}
      TextSize: 28
```

---

## 🎨 PERSONALIZACIÓN AVANZADA

### Añadir íconos
```lua
-- Puedes añadir ImageLabels con íconos
ImageLabel (dentro de SurfaceGui)
  Name: CoinIcon
  Image: rbxassetid://TU_ID_AQUI
  Size: {0, 50},{0, 50}
  Position: Junto al precio
```

### Añadir efectos
```lua
-- UICorner para bordes redondeados
UICorner
  CornerRadius: {0, 15}
  Parent: PurchaseButton

-- UIStroke para bordes
UIStroke
  Color: Blanco
  Thickness: 3
  Parent: PurchaseButton
```

### Añadir gradientes
```lua
-- UIGradient para degradados
UIGradient
  Color: ColorSequence (de claro a oscuro)
  Rotation: 90
  Parent: Background Frame
```

---

## 🔧 CREAR REMOTEEVENTS NECESARIOS

En **ReplicatedStorage > RemoteEvents**, crea:

1. **RequestZonePurchase** (RemoteEvent)
2. **UpdateZoneOwnership** (RemoteEvent)

**Cómo crear:**
- Clic derecho en `RemoteEvents`
- Insert Object → RemoteEvent
- Renombrar exactamente como se indica

---

## 📦 INSTALACIÓN COMPLETA

### PASO 1: Añadir módulo ZoneConfig

1. Ve a: `ReplicatedStorage > Modules`
2. Insert Object → **ModuleScript**
3. Renombrar a: **ZoneConfig**
4. Pegar contenido de: `ReplicatedStorage_Modules_ZoneConfig.lua`

### PASO 2: Actualizar DataManager

1. Abre: `ServerScriptService > DataManager`
2. **Reemplazar TODO el contenido** con: `ServerScriptService_DataManager.lua`

**⚠️ IMPORTANTE:** DataManager ahora usa **PlayerData_V2** (nueva versión)

### PASO 3: Añadir ZoneManager

1. Ve a: `ServerScriptService`
2. Insert Object → **Script**
3. Renombrar a: **ZoneManager**
4. Pegar contenido de: `ServerScriptService_ZoneManager.lua`

### PASO 4: Añadir ZoneClientManager

1. Ve a: `StarterPlayer > StarterPlayerScripts`
2. Insert Object → **LocalScript**
3. Renombrar a: **ZoneClientManager**
4. Pegar contenido de: `StarterPlayer_StarterPlayerScripts_ZoneClientManager.lua`

### PASO 5: Crear RemoteEvents

En `ReplicatedStorage > RemoteEvents`:
- Crear **RequestZonePurchase** (RemoteEvent)
- Crear **UpdateZoneOwnership** (RemoteEvent)

### PASO 6: Configurar zonas en ZoneConfig

1. Abre: `ReplicatedStorage > Modules > ZoneConfig`
2. Añade tus zonas a la tabla `ZoneConfig.Zones`

### PASO 7: Crear Buy Zones en Workspace

1. Crear carpeta **Buy Zones** en Workspace
2. Crear Parts con nombres que coincidan con los IDs en ZoneConfig
3. Añadir SurfaceGui a cada Part
4. Diseñar la interfaz con los elementos descritos arriba

---

## ✅ VERIFICACIÓN

### Checklist:

1. ✅ ZoneConfig existe en ReplicatedStorage/Modules
2. ✅ DataManager actualizado (usa PlayerData_V2)
3. ✅ ZoneManager existe en ServerScriptService
4. ✅ ZoneClientManager existe en StarterPlayerScripts
5. ✅ 2 RemoteEvents creados (RequestZonePurchase, UpdateZoneOwnership)
6. ✅ Carpeta Buy Zones existe en Workspace
7. ✅ Parts creados con nombres correctos
8. ✅ Cada Part tiene SurfaceGui con PurchaseButton

### Test básico:

1. **Inicia el juego**
2. **Verifica Output:**
   ```
   [ZoneManager] ✅ Sistema de zonas inicializado
   [ZoneClientManager] ✅ Sistema de zonas del cliente inicializado
   ```
3. **Acércate a un Part de zona**
4. **La SurfaceGui debe mostrar:**
   - Nombre de la zona
   - Precio
   - Requisitos (si los hay)
   - Estado (bloqueada/desbloqueada)
   - Botón de compra
5. **Si es Zone1 (gratis):** Debe mostrar "DESBLOQUEADA"
6. **Si es Zone2 (de pago):** Debe mostrar "COMPRAR"
7. **Haz clic en "COMPRAR"**
8. **Debe descontar el dinero y desbloquear la zona**

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "No se encontró carpeta 'Buy Zones'"
**Solución:** Crea una carpeta llamada "Buy Zones" (exacto) en Workspace

### ❌ Part no tiene configuración en ZoneConfig
**Solución:** Verifica que el nombre del Part coincida exactamente con el ID en ZoneConfig

### ❌ Part no tiene SurfaceGui
**Solución:** Añade una SurfaceGui al Part

### ❌ No se puede comprar la zona
**Verifica:**
1. Tienes suficiente dinero
2. Cumples los requisitos de nivel/rebirths
3. No ya posees la zona
4. RemoteEvents existen

### ❌ La GUI no se actualiza
**Verifica:**
1. Los elementos tienen los nombres correctos
2. PurchaseButton existe
3. No hay errores en Output

---

## 💡 TIPS AVANZADOS

### Añadir más zonas fácilmente:

1. Abre ZoneConfig
2. Copia una zona existente
3. Cambia: ID, Name, Price, RequiredLevel, RequiredRebirths
4. Crea el Part en Workspace con el mismo nombre (ID)
5. Copia la SurfaceGui de otra zona
6. ¡Listo!

### Crear zonas temáticas:

```lua
-- Zona de principiantes
{ID = "BeginnerZone", Name = "Zona Novato", Price = 0, RequiredLevel = 0},

-- Zona intermedia
{ID = "IntermediateZone", Name = "Zona Intermedia", Price = 10000, RequiredLevel = 10},

-- Zona avanzada
{ID = "AdvancedZone", Name = "Zona Avanzada", Price = 50000, RequiredLevel = 20, RequiredRebirths = 1},

-- Zona VIP
{ID = "VIPZone", Name = "Zona VIP", Price = 200000, RequiredLevel = 30, RequiredRebirths = 3},
```

### Precios recomendados:

| Nivel | Precio recomendado |
|---|---|
| 0-5 | $0 - $5,000 |
| 5-10 | $5,000 - $15,000 |
| 10-15 | $15,000 - $50,000 |
| 15-20 | $50,000 - $150,000 |
| 20+ | $150,000+ |

---

## 🎯 RESUMEN

**Para añadir una zona:**
1. Añadirla a ZoneConfig con ID, nombre, precio y requisitos
2. Crear Part en Buy Zones/Workspace con el mismo ID
3. Añadir SurfaceGui al Part con PurchaseButton
4. Diseñar la interfaz a tu gusto

**El sistema se encarga de:**
- ✅ Verificar requisitos
- ✅ Procesar compras
- ✅ Guardar zonas compradas
- ✅ Actualizar GUIs automáticamente
- ✅ Persistir datos entre sesiones

**TÚ controlas:**
- ✅ Diseño visual completo
- ✅ Colores, fuentes, tamaños
- ✅ Efectos y decoraciones
- ✅ Cuántas zonas crear
- ✅ Precios y requisitos

---

¡Sistema modular y completamente personalizable! 🎨🗺️
