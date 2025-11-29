-- ServerScriptService > OrbGenerator
-- Genera datos de orbs para que los clientes los visualicen
-- NOTA: Este es un Script normal, NO ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Esperar a que los módulos estén disponibles
print("[OrbGenerator] Esperando módulos...")
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
	warn("[OrbGenerator] ❌ No se encontró la carpeta Modules")
	return
end

local OrbConfig = require(Modules:WaitForChild("OrbConfig", 10))
local OrbManager = require(Modules:WaitForChild("OrbManager", 10))

if not OrbConfig or not OrbManager then
	warn("[OrbGenerator] ❌ No se pudieron cargar los módulos")
	return
end

print("[OrbGenerator] ✅ Módulos cargados correctamente")

-- Tabla para almacenar orbs activos por zona
local activeOrbs = {}

-- Genera un ID único para cada orb
local function generateOrbId()
	return HttpService:GenerateGUID(false)
end

-- Crea un nuevo orb en una zona específica
local function spawnOrbInZone(zoneConfig)
	if not zoneConfig then return end

	-- Obtener orbs activos en esta zona
	local zoneName = zoneConfig.Name
	if not activeOrbs[zoneName] then
		activeOrbs[zoneName] = {}
	end

	-- Verificar si ya hay suficientes orbs
	local maxOrbs = zoneConfig.MaxOrbs or 10
	if #activeOrbs[zoneName] >= maxOrbs then
		return
	end

	-- Seleccionar tipo de orb aleatorio válido para esta zona
	local orbType = OrbConfig.GetRandomOrbTypeForZone(zoneName)
	if not orbType then
		warn(string.format("[OrbGenerator] No se pudo obtener tipo de orb para zona %s", zoneName))
		return
	end

	-- Generar posición aleatoria en la zona
	local position = OrbManager.GetRandomPositionInZone(zoneConfig)

	-- Crear datos del orb
	local orbData = {
		Id = generateOrbId(),
		Type = orbType,
		Position = position,
		Zone = zoneName,
		SpawnTime = tick()
	}

	-- Añadir a la lista de orbs activos
	table.insert(activeOrbs[zoneName], orbData)

	return orbData
end

-- Elimina orbs expirados
local function cleanupExpiredOrbs()
	local currentTime = tick()
	local lifetime = OrbConfig.General.OrbLifetime

	for zoneName, orbs in pairs(activeOrbs) do
		for i = #orbs, 1, -1 do
			local orb = orbs[i]
			local age = currentTime - orb.SpawnTime

			if age >= lifetime then
				table.remove(orbs, i)
			end
		end
	end
end

-- Inicia el generador de orbs para todas las zonas
local function startGeneration()
	print("[OrbGenerator] Iniciando generación de orbs...")

	-- Generar orbs continuamente para cada zona
	for _, zoneConfig in ipairs(OrbConfig.Zones) do
		task.spawn(function()
			print(string.format("[OrbGenerator] Iniciando generación para zona: %s", zoneConfig.Name))

			-- Loop de generación para esta zona
			while true do
				-- Generar orb si es necesario
				spawnOrbInZone(zoneConfig)

				-- Esperar antes del próximo spawn
				task.wait(zoneConfig.RespawnTime)
			end
		end)
	end

	-- Limpieza periódica de orbs expirados
	task.spawn(function()
		while true do
			task.wait(10) -- Limpiar cada 10 segundos
			cleanupExpiredOrbs()
		end
	end)

	print("[OrbGenerator] ✅ Sistema de orbs iniciado correctamente")
end

-- Esperar a que las zonas estén configuradas (por AutoConfigureZones)
task.wait(3)

-- Iniciar generación
startGeneration()
