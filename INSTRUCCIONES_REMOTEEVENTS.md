# INSTRUCCIONES PARA CREAR REMOTEEVENTS

## Ubicación
Todos los RemoteEvents deben estar en:
```
ReplicatedStorage > RemoteEvents (Folder)
```

## RemoteEvents Necesarios

### 1. OrbCollected
- **Tipo:** RemoteEvent
- **Nombre exacto:** `OrbCollected`
- **Función:** El cliente informa al servidor cuando recoge un orb
- **Dirección:** Cliente → Servidor

### 2. RequestRebirthPurchase
- **Tipo:** RemoteEvent
- **Nombre exacto:** `RequestRebirthPurchase`
- **Función:** El cliente solicita comprar un rebirth y el servidor responde con el resultado
- **Dirección:** Cliente ↔ Servidor (bidireccional)

### 3. UpdateSpeedDisplay
- **Tipo:** RemoteEvent
- **Nombre exacto:** `UpdateSpeedDisplay`
- **Función:** El servidor actualiza la velocidad acumulada en la GUI del cliente
- **Dirección:** Servidor → Cliente

## Cómo Crearlos en Roblox Studio

1. En el **Explorer**, navega a `ReplicatedStorage`

2. Si no existe, crea una carpeta llamada `RemoteEvents`:
   - Click derecho en ReplicatedStorage
   - Insert Object > Folder
   - Nombra la carpeta exactamente como: `RemoteEvents`

3. Dentro de la carpeta `RemoteEvents`, crea 3 RemoteEvents:
   - Click derecho en la carpeta RemoteEvents
   - Insert Object > RemoteEvent
   - Repite 3 veces

4. Renombra cada RemoteEvent exactamente como:
   - `OrbCollected`
   - `RequestRebirthPurchase`
   - `UpdateSpeedDisplay`

## Estructura Final en Explorer

```
ReplicatedStorage
└── RemoteEvents (Folder)
    ├── OrbCollected (RemoteEvent)
    ├── RequestRebirthPurchase (RemoteEvent)
    └── UpdateSpeedDisplay (RemoteEvent)
```

## Notas Importantes

- Los nombres deben ser **exactamente** como se muestran (respetando mayúsculas y minúsculas)
- NO cambies el tipo de objeto (deben ser RemoteEvent, no RemoteFunction)
- NO añadas scripts dentro de los RemoteEvents
- Todos deben estar en la carpeta RemoteEvents dentro de ReplicatedStorage
