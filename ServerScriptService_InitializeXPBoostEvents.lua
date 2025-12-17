-- ServerScriptService > InitializeXPBoostEvents (Script)
-- Crea los RemoteEvents necesarios para el sistema de boosts de XP
-- EJECUTAR UNA SOLA VEZ y luego eliminar o desactivar

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Buscar o crear carpeta RemoteEvents
local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEvents then
	remoteEvents = Instance.new("Folder")
	remoteEvents.Name = "RemoteEvents"
	remoteEvents.Parent = ReplicatedStorage
	print("[InitializeXPBoostEvents] ✅ Carpeta RemoteEvents creada")
end

-- Lista de RemoteEvents necesarios para el sistema de boosts
local eventsToCreate = {
	{Type = "RemoteFunction", Name = "GetXPBoost"},  -- Para obtener información del boost actual
	{Type = "RemoteEvent", Name = "XPBoostPurchased"},  -- Para notificar compras
}

-- Crear cada evento si no existe
for _, eventData in ipairs(eventsToCreate) do
	local existing = remoteEvents:FindFirstChild(eventData.Name)

	if not existing then
		local newEvent
		if eventData.Type == "RemoteEvent" then
			newEvent = Instance.new("RemoteEvent")
		elseif eventData.Type == "RemoteFunction" then
			newEvent = Instance.new("RemoteFunction")
		end

		newEvent.Name = eventData.Name
		newEvent.Parent = remoteEvents

		print(string.format("[InitializeXPBoostEvents] ✅ %s '%s' creado", eventData.Type, eventData.Name))
	else
		print(string.format("[InitializeXPBoostEvents] ℹ️ %s ya existe", eventData.Name))
	end
end

print("[InitializeXPBoostEvents] ═══════════════════════════════════════")
print("[InitializeXPBoostEvents] ✅ Todos los RemoteEvents creados")
print("[InitializeXPBoostEvents] 📘 Ahora puedes eliminar o desactivar este script")
print("[InitializeXPBoostEvents] ═══════════════════════════════════════")
