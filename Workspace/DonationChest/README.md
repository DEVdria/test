# Donation Chest - Instrucciones de Configuración

## Estructura en Roblox Studio:

```
Workspace
└── DonationChest (Model)
    ├── ChestPart (Part) ← La parte principal del cofre
    │   └── ProximityPrompt
    └── ChestScript (Script) ← Coloca aquí el script del servidor
```

## Pasos para crear el cofre:

### 1. Crear el Modelo:
- En **Workspace**, crea un **Model**
- Nómbralo: `DonationChest`

### 2. Crear la Parte del Cofre:
- Dentro de DonationChest, crea una **Part**
- Nómbrala: `ChestPart`
- Propiedades recomendadas:
  - **Size**: `4, 3, 4` (o el tamaño que prefieras)
  - **BrickColor**: `Gold` o `Really red`
  - **Material**: `Wood` o `Metal`
  - **Anchored**: `true`
  - **CanCollide**: `true`
  - **Position**: Colócala donde quieras en tu mapa

### 3. Crear el ProximityPrompt:
- Dentro de **ChestPart**, crea un **ProximityPrompt**
- Propiedades recomendadas:
  - **ActionText**: `"Abrir"`
  - **ObjectText**: `"Cofre de Donaciones"`
  - **HoldDuration**: `0` (sin necesidad de mantener presionado)
  - **MaxActivationDistance**: `8`
  - **RequiresLineOfSight**: `true`
  - **KeyboardKeyCode**: `E`

### 4. Agregar el Script:
- Dentro del **Model DonationChest**, crea un **Script** (NO LocalScript)
- Nómbralo: `ChestScript`
- Copia el contenido de `ChestScript.lua` en este Script

### 5. Configurar PrimaryPart (Opcional):
- Selecciona el Model DonationChest
- En Properties, establece **PrimaryPart** como ChestPart

## Personalización Visual:

### Agregar un MeshPart (Opcional):
Si tienes un modelo de cofre personalizado:
1. Importa o crea tu mesh del cofre
2. Reemplaza ChestPart con tu MeshPart
3. Asegúrate de que el ProximityPrompt esté dentro de la parte principal

### Agregar efectos:
- Puedes agregar un **PointLight** dentro de ChestPart para que brille
- Puedes agregar **ParticleEmitters** para efectos de partículas
- Puedes agregar un **BillboardGui** con texto flotante encima

## Ejemplo de decoración:

```
ChestPart
├── ProximityPrompt
├── PointLight (Color: Yellow, Brightness: 2)
├── ParticleEmitter (Sparkles)
└── BillboardGui
    └── TextLabel ("💰 DONACIONES 💰")
```
