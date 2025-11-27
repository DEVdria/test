--[[
	SCRIPT DE CONFIGURACIÓN DE REMOTE EVENTS (SERVIDOR)
	Ubicación: ServerScriptService/RemoteEventsSetup
	Descripción: Crea y gestiona todos los RemoteEvents del sistema
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de RemoteEvents si no existe
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Lista de RemoteEvents necesarios
local remoteEventsList = {
	"OrbCollected",      -- Cuando el cliente recoge una orb
	"RevivePlayer",      -- Cuando el jugador presiona revivir
	"PerformRebirth",    -- Cuando el jugador hace rebirth
	"RebirthCompleted"   -- Notifica al cliente que rebirth se completó
}

-- Crear cada RemoteEvent
for _, eventName in ipairs(remoteEventsList) do
	if not remoteEventsFolder:FindFirstChild(eventName) then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = remoteEventsFolder
		print("RemoteEvent creado: " .. eventName)
	else
		print("RemoteEvent ya existe: " .. eventName)
	end
end

print("RemoteEventsSetup completado exitosamente")
