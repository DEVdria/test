-- ServerScriptService > InitializeRaceEvents (Script)
-- Inicializa los RemoteEvents necesarios para el sistema de carreras
-- EJECUTAR SOLO UNA VEZ para crear los eventos

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de RemoteEvents si no existe
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = ReplicatedStorage
end

-- Lista de RemoteEvents necesarios para el sistema de carreras
local raceEvents = {
	"RaceWarning",      -- Aviso de carrera (10s antes)
	"RaceStart",        -- Inicio de inscripción
	"JoinRace",         -- Solicitud de unirse a carrera
	"RaceEnd",          -- Fin de carrera y resultados
	"RaceCountdown"     -- Cuenta regresiva en zona de espera
}

-- Crear RemoteEvents
for _, eventName in ipairs(raceEvents) do
	if not RemoteEvents:FindFirstChild(eventName) then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = RemoteEvents
		print(string.format("[InitializeRaceEvents] ✅ RemoteEvent creado: %s", eventName))
	else
		print(string.format("[InitializeRaceEvents] ℹ️ RemoteEvent ya existe: %s", eventName))
	end
end

print("[InitializeRaceEvents] ✅ Inicialización de RemoteEvents para carreras completada")

-- NOTA: Este script solo debe ejecutarse una vez para crear los eventos.
-- Después de crear los eventos, puedes eliminar este script o desactivarlo.
