# RemoteEvents Setup

## Instrucciones para crear los RemoteEvents en Roblox Studio:

1. Abre Roblox Studio
2. Ve a ReplicatedStorage
3. Crea una carpeta llamada "RemoteEvents"
4. Dentro de "RemoteEvents", crea los siguientes RemoteEvents:
   - **TrollEvent** (RemoteEvent)
   - **PurchaseEvent** (RemoteEvent)
   - **PromptPurchase** (RemoteEvent)
   - **OpenDonationGui** (RemoteEvent)

### Opción alternativa: Usar el script automático

Puedes crear un Script en ServerScriptService que se ejecute una vez para crear automáticamente estos RemoteEvents.
Luego elimina el script después de que se ejecute.

Ver: `CreateRemoteEvents.lua` (script incluido)
