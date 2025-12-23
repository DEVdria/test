-- ServerScriptService > InitializeServer
-- Script principal que inicializa todos los sistemas del servidor
-- Este debe ser un Script normal (NO ModuleScript)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)

if not Modules then
	error("[InitializeServer] ❌ No se encontró la carpeta Modules en ReplicatedStorage")
	return
end

if not RemoteEvents then
	error("[InitializeServer] ❌ No se encontró la carpeta RemoteEvents en ReplicatedStorage")
	return
end

print("[InitializeServer] ✅ Módulos cargados correctamente")

-- Esperar a que todos los scripts estén cargados
task.wait(0.5)

-- Los scripts DataManager, MoneyManager, RebirthManager y AutoConfigureZones
-- se ejecutan automáticamente porque son Scripts normales.
-- Solo necesitamos esperar a que se inicialicen.

print("[InitializeServer] ✅ Sistema del servidor inicializado")
