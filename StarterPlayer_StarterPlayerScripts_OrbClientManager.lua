-- StarterPlayer > StarterPlayerScripts > OrbClientManager
-- Gestiona los orbs del lado del cliente (solo visibles para cada jugador)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local OrbConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbConfig"))
local OrbManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbManager"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local OrbCollectedEvent = RemoteEvents:WaitForChild("OrbCollected")

-- Carpeta para almacenar orbs del cliente
local orbsFolder = Workspace:FindFirstChild("OrbsFolder")
if not orbsFolder then
	orbsFolder = Instance.new("Folder")
	orbsFolder.Name = "OrbsFolder"
	orbsFolder.Parent = Workspace
end

-- Tabla para rastrear orbs recolectados (para que no reaparezcan)
local collectedOrbs = {}
local clientOrbs = {} -- Orbs visuales creados por el cliente

-- Genera orbs en una zona específica
local function generateOrbsInZone(zone)
	if not zone then return end

	local zoneName = zone.Name
	local maxOrbs = zone:GetAttribute("MaxOrbs") or 10
	local orbTypesString = zone:GetAttribute("OrbTypes")

	if not orbTypesString then
		warn(string.format("[OrbClient] Zona %s no tiene tipos de orbs definidos", zoneName))
		return
	end

	-- Parsear tipos de orbs
	local orbTypes = string.split(orbTypesString, ",")

	-- Contar orbs actuales en esta zona
	local currentOrbs = 0
	for _, orb in pairs(clientOrbs) do
		if orb:GetAttribute("Zone") == zoneName then
			currentOrbs = currentOrbs + 1
		end
	end

	-- Generar orbs faltantes
	while currentOrbs < maxOrbs do
		-- Seleccionar tipo aleatorio
		local orbType = orbTypes[math.random(1, #orbTypes)]

		-- Crear configuración de zona temporal
		local zoneConfig = {
			Name = zoneName,
			Position = zone.Position,
			Size = zone.Size,
			SpawnHeight = zone:GetAttribute("SpawnHeight") or 10
		}

		-- Generar posición aleatoria
		local position = OrbManager.GetRandomPositionInZone(zoneConfig)

		-- Crear orb visual
		local orb = OrbManager.CreateOrb(orbType, position)
		if orb then
			orb:SetAttribute("Zone", zoneName)
			orb:SetAttribute("SpawnTime", tick())
			orb.Parent = orbsFolder

			-- Añadir a la tabla de orbs
			table.insert(clientOrbs, orb)

			-- Añadir animación
			OrbManager.AnimateOrb(orb)

			currentOrbs = currentOrbs + 1
		end
	end
end

-- Recolectar un orb
local function collectOrb(orb)
	if not orb or not orb.Parent then return end

	local orbType = orb:GetAttribute("OrbType")
	if not orbType then return end

	-- Verificar si ya fue recolectado
	if collectedOrbs[orb] then return end

	-- Marcar como recolectado
	collectedOrbs[orb] = true

	-- Efecto visual
	OrbManager.PlayCollectionEffect(orb)

	-- Notificar al servidor
	OrbCollectedEvent:FireServer(orbType)

	-- Eliminar de la tabla local
	for i, clientOrb in ipairs(clientOrbs) do
		if clientOrb == orb then
			table.remove(clientOrbs, i)
			break
		end
	end

	-- Destruir el orb
	orb:Destroy()
end

-- Verificar recolección de orbs cercanos
local function checkOrbCollection()
	if not humanoidRootPart or not humanoidRootPart.Parent then
		-- Recargar character si murió
		character = player.Character
		if character then
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		end
		return
	end

	local playerPosition = humanoidRootPart.Position

	for _, orb in ipairs(clientOrbs) do
		if orb and orb.Parent and not collectedOrbs[orb] then
			local orbPosition = orb.Position

			if OrbManager.IsInCollectionRange(playerPosition, orbPosition) then
				collectOrb(orb)
			end
		end
	end
end

-- Limpiar orbs expirados
local function cleanupExpiredOrbs()
	local currentTime = tick()
	local lifetime = OrbConfig.General.OrbLifetime

	for i = #clientOrbs, 1, -1 do
		local orb = clientOrbs[i]
		if orb and orb.Parent then
			local spawnTime = orb:GetAttribute("SpawnTime") or currentTime
			local age = currentTime - spawnTime

			if age >= lifetime then
				orb:Destroy()
				table.remove(clientOrbs, i)
			end
		else
			-- Orb ya no existe, remover de la tabla
			table.remove(clientOrbs, i)
		end
	end
end

-- Inicializar sistema de orbs
local function initialize()
	-- Esperar a que las zonas estén cargadas
	local zonesFolder = Workspace:WaitForChild("Zones", 10)

	if not zonesFolder then
		warn("[OrbClient] No se encontró la carpeta Zones en Workspace")
		return
	end

	-- Generar orbs iniciales para cada zona
	for _, zone in ipairs(zonesFolder:GetChildren()) do
		if zone:IsA("BasePart") then
			generateOrbsInZone(zone)
		end
	end

	-- Loop de generación continua
	task.spawn(function()
		while true do
			task.wait(3) -- Verificar cada 3 segundos

			for _, zone in ipairs(zonesFolder:GetChildren()) do
				if zone:IsA("BasePart") then
					generateOrbsInZone(zone)
				end
			end
		end
	end)

	-- Loop de limpieza
	task.spawn(function()
		while true do
			task.wait(10) -- Limpiar cada 10 segundos
			cleanupExpiredOrbs()
		end
	end)

	-- Loop de recolección (cada frame para precisión)
	RunService.Heartbeat:Connect(function()
		checkOrbCollection()
	end)

	print("[OrbClient] Sistema de orbs del cliente iniciado")
end

-- Manejar muerte del personaje
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	collectedOrbs = {} -- Resetear orbs recolectados
end)

-- Iniciar
initialize()
