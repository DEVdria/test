# ESTRUCTURA DEL PROYECTO - SISTEMA DE ORBS DE VELOCIDAD

## 📁 Estructura Completa de Roblox Studio

```
ReplicatedStorage/
├── RemoteEvents/
│   ├── OrbCollected (RemoteEvent)
│   ├── RequestRebirthPurchase (RemoteEvent)
│   └── UpdateSpeedDisplay (RemoteEvent)
├── Modules/
│   ├── OrbConfig (ModuleScript)
│   └── OrbManager (ModuleScript)
└── VFX/
    └── Dust (Part con Attachment) - YA EXISTE

ServerScriptService/
├── DataManager (Script)
├── OrbGenerator (Script)
├── MoneyManager (Script)
└── RebirthManager (Script)

StarterPlayer/
└── StarterCharacterScripts/
    ├── Running (LocalScript) - MODIFICADO
    ├── Sprint (Animation) - YA EXISTE
    └── Jump (Animation) - YA EXISTE

StarterGui/
├── PrincipalGui/
│   └── Frame/
│       ├── Cash (ImageButton) - YA EXISTE
│       ├── Invite (ImageButton) - YA EXISTE
│       ├── Shop (ImageButton) - YA EXISTE
│       ├── Rebirths (ImageButton) - AÑADIR
│       ├── SpeedDisplay (TextLabel) - AÑADIR
│       └── SpeedDisplayScript (LocalScript) - NUEVO
├── RebirthGui/ - NUEVA
│   └── Frame/
│       ├── Title (TextLabel)
│       ├── PriceLabel (TextLabel)
│       ├── MultiplierLabel (TextLabel)
│       ├── PurchaseButton (TextButton)
│       ├── CloseButton (TextButton)
│       └── RebirthGuiScript (LocalScript) - NUEVO
└── MobileGUI/
    └── MobileButtons/
        ├── MobileScript (LocalScript) - YA EXISTE
        └── RunButton (ImageButton) - YA EXISTE

StarterPlayer/StarterPlayerScripts/
└── OrbClientManager (LocalScript) - NUEVO

Workspace/
├── FX/ (Folder) - YA EXISTE
├── OrbsFolder/ (Folder) - NUEVA (cliente creará orbs aquí)
└── Zones/ (Folder) - NUEVA
    ├── Zone1 (Part o Model con atributos)
    └── Zone2 (Part o Model con atributos)
```

## 📋 RemoteEvents Necesarios

Todos en `ReplicatedStorage/RemoteEvents/`:
- **OrbCollected**: Cliente → Servidor (informa recolección de orb)
- **RequestRebirthPurchase**: Cliente → Servidor (solicita comprar rebirth)
- **UpdateSpeedDisplay**: Servidor → Cliente (actualiza GUI de velocidad)

## 🎮 Configuración de Zonas

Las zonas se crean como **Parts** en `Workspace/Zones/` con los siguientes **Attributes**:
- `ZoneName` (String): "Zone1", "Zone2", etc.
- `OrbTypes` (String): "Yellow,Green" o "Green,Blue" (separados por comas)
- `SpawnHeight` (Number): Altura fija para spawns (ej: 10)

## ⚙️ Notas de Integración

1. **Sistema de Running**: Se modificará para leer la velocidad acumulada del jugador
2. **Orbs**: Solo visibles para cada cliente (generados localmente)
3. **Datos**: Guardados automáticamente cada 60s y al salir
4. **Seguridad**: Validación servidor-side de todas las transacciones
