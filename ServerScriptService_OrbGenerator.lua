-- ServerScriptService > OrbGenerator
-- Genera datos de orbs para que los clientes los visualicen

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local OrbConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbConfig"))
local OrbManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbManager"))
local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
local MoneyManager = require(ServerScriptService:WaitForChild("MoneyManager"))
local RebirthManager = require(ServerScriptService:WaitForChild("RebirthManager"))

local OrbGenerator = {}

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

	-- Nota: Los clientes crearán sus propios orbs visuales basados en estos datos
	-- Esto se hace a través de una función remota o replicación

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

-- Elimina un orb específico por ID (cuando un jugador lo recoge)
function OrbGenerator.RemoveOrb(orbId, zoneName)
	if not activeOrbs[zoneName] then return false end

	for i, orb in ipairs(activeOrbs[zoneName]) do
		if orb.Id == orbId then
			table.remove(activeOrbs[zoneName], i)
			return true
		end
	end

	return false
end

-- Obtiene todos los orbs activos (para nuevos jugadores)
function OrbGenerator.GetAllActiveOrbs()
	local allOrbs = {}

	for zoneName, orbs in pairs(activeOrbs) do
		for _, orb in ipairs(orbs) do
			table.insert(allOrbs, orb)
		end
	end

	return allOrbs
end

-- Obtiene orbs de una zona específica
function OrbGenerator.GetOrbsInZone(zoneName)
	return activeOrbs[zoneName] or {}
end

-- Inicia el generador de orbs para todas las zonas
function OrbGenerator.StartGeneration()
	-- Generar orbs continuamente para cada zona
	for _, zoneConfig in ipairs(OrbConfig.Zones) do
		task.spawn(function()
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
end

-- Inicializa el generador
function OrbGenerator.Initialize()
	-- Inicializar sistemas dependientes
	DataManager.Initialize()
	MoneyManager.Initialize()
	RebirthManager.Initialize()

	-- Esperar a que las zonas estén configuradas
	task.wait(2)

	-- Iniciar generación
	OrbGenerator.StartGeneration()

	print("[OrbGenerator] ✅ Sistema de orbs iniciado")
end

-- Iniciar automáticamente
OrbGenerator.Initialize()

return OrbGenerator
