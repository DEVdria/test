-- ReplicatedStorage > RemoteEventsInitializer (Script)
-- Inicializa todos los RemoteEvents necesarios para el sistema de trails
-- SOLO EJECUTAR UNA VEZ al inicio del juego

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de RemoteEvents si no existe
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = ReplicatedStorage
end

-- Lista de RemoteEvents necesarios para el sistema de trails
local remoteEventsNeeded = {
	"RequestTrailPurchase",  -- Para comprar trails (RemoteEvent)
	"EquipTrail",            -- Para equipar trails (RemoteEvent)
	"GetTrailData"           -- Para obtener datos de trails (RemoteFunction)
}

-- Lista de RemoteFunctions necesarias
local remoteFunctionsNeeded = {
	"GetTrailData"           -- Obtener datos de trails del servidor
}

-- Crear RemoteEvents
for _, eventName in ipairs(remoteEventsNeeded) do
	if not RemoteEvents:FindFirstChild(eventName) then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = RemoteEvents
		print(string.format("[RemoteEventsInit] ✅ RemoteEvent creado: %s", eventName))
	else
		print(string.format("[RemoteEventsInit] ℹ️ RemoteEvent ya existe: %s", eventName))
	end
end

-- Crear RemoteFunctions
for _, functionName in ipairs(remoteFunctionsNeeded) do
	if not RemoteEvents:FindFirstChild(functionName) then
		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = functionName
		remoteFunction.Parent = RemoteEvents
		print(string.format("[RemoteEventsInit] ✅ RemoteFunction creada: %s", functionName))
	else
		print(string.format("[RemoteEventsInit] ℹ️ RemoteFunction ya existe: %s", functionName))
	end
end

print("[RemoteEventsInit] ✅ Inicialización de RemoteEvents para trails completada")
