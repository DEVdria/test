--[[
	CREATE REMOTE EVENTS (Ejecutar UNA SOLA VEZ)
	Ubicación: ServerScriptService

	Este script crea automáticamente todos los RemoteEvents necesarios.
	Después de ejecutarlo, ELIMINA este script.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear la carpeta RemoteEvents si no existe
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
	print("✅ Carpeta RemoteEvents creada")
else
	print("ℹ️ Carpeta RemoteEvents ya existe")
end

-- Lista de RemoteEvents a crear
local remoteEventNames = {
	"TrollEvent",
	"PurchaseEvent",
	"PromptPurchase",
	"OpenDonationGui"
}

-- Crear cada RemoteEvent
for _, eventName in ipairs(remoteEventNames) do
	if not remoteEventsFolder:FindFirstChild(eventName) then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = remoteEventsFolder
		print("✅ RemoteEvent creado:", eventName)
	else
		print("ℹ️ RemoteEvent ya existe:", eventName)
	end
end

print("🎉 Todos los RemoteEvents han sido configurados")
print("⚠️ IMPORTANTE: Ahora elimina este script (CreateRemoteEvents)")
