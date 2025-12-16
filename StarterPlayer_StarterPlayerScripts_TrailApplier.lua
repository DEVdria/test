-- StarterPlayer > StarterPlayerScripts > TrailApplier (LocalScript)
-- Aplica trails al jugador (R6)
-- Soporta trails simples (solo Torso) y trails de cuerpo completo (todas las partes)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Esperar módulos y eventos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TrailConfig = require(Modules:WaitForChild("TrailConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local EquipTrailEvent = RemoteEvents:WaitForChild("EquipTrail")
local GetTrailDataEvent = RemoteEvents:WaitForChild("GetTrailData")

-- ==================== VARIABLES ====================

local currentTrails = {}  -- Tabla de todas las trails aplicadas
local currentEquippedID = nil  -- ID de la trail equipada

-- Partes del cuerpo R6 (excluyendo Head)
local BODY_PARTS = {"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

-- ==================== FUNCIONES ====================

-- Remueve todas las trails actuales del jugador
local function removeAllTrails()
	for _, trailData in pairs(currentTrails) do
		if trailData.trail then
			trailData.trail:Destroy()
		end
	end
	currentTrails = {}
	print("[TrailApplier] 🗑️ Todas las trails removidas")
end

-- Crea una trail individual en una parte del cuerpo
local function createSingleTrail(part, trailConfig, index)
	-- Crear attachments para la trail
	local attachment0 = Instance.new("Attachment")
	attachment0.Name = string.format("TrailAttachment%d_0", index)

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = string.format("TrailAttachment%d_1", index)

	-- Posicionar attachments según la parte del cuerpo
	if part.Name == "Torso" then
		attachment0.Position = Vector3.new(0, 1, 0)   -- Arriba
		attachment1.Position = Vector3.new(0, -1, 0)  -- Abajo
	elseif part.Name:find("Arm") then
		attachment0.Position = Vector3.new(0, 0.5, 0)  -- Arriba del brazo
		attachment1.Position = Vector3.new(0, -0.5, 0) -- Abajo del brazo
	elseif part.Name:find("Leg") then
		attachment0.Position = Vector3.new(0, 0.5, 0)  -- Arriba de la pierna
		attachment1.Position = Vector3.new(0, -0.5, 0) -- Abajo de la pierna
	end

	attachment0.Parent = part
	attachment1.Parent = part

	-- Crear la Trail
	local trail = Instance.new("Trail")
	trail.Name = string.format("PlayerTrail_%d", index)

	-- Configurar attachments
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1

	-- Aplicar configuración visual de TrailConfig
	trail.Texture = trailConfig.Texture
	trail.Color = trailConfig.Color
	trail.Transparency = trailConfig.Transparency
	trail.Lifetime = trailConfig.Lifetime
	trail.MinLength = trailConfig.MinLength
	trail.WidthScale = trailConfig.WidthScale

	-- Propiedades adicionales para mejor apariencia
	trail.LightEmission = 0.5  -- Un poco de brillo
	trail.LightInfluence = 0.2
	trail.FaceCamera = true    -- Siempre mira a la cámara

	-- Añadir a la parte del cuerpo
	trail.Parent = part

	return trail
end

-- Aplica una trail simple (solo en Torso)
local function applySimpleTrail(trailConfig)
	local torso = character:FindFirstChild("Torso")
	if not torso then
		warn("[TrailApplier] ⚠️ No se encontró Torso (¿el personaje es R6?)")
		return
	end

	local trail = createSingleTrail(torso, trailConfig, 1)
	table.insert(currentTrails, {part = "Torso", trail = trail})

	print(string.format("[TrailApplier] ✅ Trail simple '%s' aplicada al Torso", trailConfig.Name))
end

-- Aplica trails a todo el cuerpo (excepto Head)
local function applyFullBodyTrails(trailConfig)
	local trailsPerPart = trailConfig.TrailsPerPart or 2
	local totalTrails = 0

	for _, partName in ipairs(BODY_PARTS) do
		local part = character:FindFirstChild(partName)

		if part then
			-- Crear múltiples trails por parte
			for i = 1, trailsPerPart do
				local trail = createSingleTrail(part, trailConfig, totalTrails + i)
				table.insert(currentTrails, {part = partName, trail = trail})
			end

			totalTrails = totalTrails + trailsPerPart
			print(string.format("[TrailApplier] ✅ %d trails aplicadas a %s", trailsPerPart, partName))
		else
			warn(string.format("[TrailApplier] ⚠️ No se encontró parte del cuerpo: %s", partName))
		end
	end

	print(string.format("[TrailApplier] ✅ Trail de cuerpo completo '%s' aplicada - Total: %d trails", trailConfig.Name, totalTrails))
end

-- Aplica la trail equipada al personaje
local function applyTrail(trailID)
	-- Remover trails anteriores
	removeAllTrails()

	-- Si trailID es nil, solo remover
	if not trailID then
		return
	end

	-- Obtener configuración de la trail
	local trailConfig = TrailConfig.GetTrail(trailID)
	if not trailConfig then
		warn(string.format("[TrailApplier] ⚠️ No se encontró config para trail: %s", trailID))
		return
	end

	-- Verificar si es una trail de cuerpo completo
	if trailConfig.ApplyToAllParts then
		applyFullBodyTrails(trailConfig)
	else
		applySimpleTrail(trailConfig)
	end

	currentEquippedID = trailID
end

-- Obtiene la trail equipada del servidor
local function loadEquippedTrail()
	print("[TrailApplier] 📡 Solicitando trail equipada del servidor...")

	local success, trailData = pcall(function()
		return GetTrailDataEvent:InvokeServer()
	end)

	if success and trailData and trailData.EquippedTrail then
		applyTrail(trailData.EquippedTrail)
	else
		warn("[TrailApplier] ⚠️ No se pudo cargar la trail equipada")
		-- Aplicar trail por defecto
		local defaultTrail = TrailConfig.GetDefaultTrail()
		if defaultTrail then
			applyTrail(defaultTrail.ID)
		end
	end
end

-- ==================== EVENTOS ====================

-- Escuchar cuando se equipa una nueva trail
EquipTrailEvent.OnClientEvent:Connect(function(result)
	if result.Success and result.TrailID then
		applyTrail(result.TrailID)
	end
end)

-- Manejar cuando el personaje reaparece (muerte/respawn)
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Esperar a que el personaje esté completamente cargado
	task.wait(0.5)

	-- Reaplicar la trail equipada
	if currentEquippedID then
		applyTrail(currentEquippedID)
	else
		loadEquippedTrail()
	end
end)

-- ==================== INICIALIZACIÓN ====================

-- Cargar trail equipada al iniciar
task.wait(2)  -- Esperar a que todo el sistema esté listo
loadEquippedTrail()

print("[TrailApplier] ✅ Sistema de aplicación de trails iniciado")

-- ==================== NOTAS ====================
--[[
	TRAILS SIMPLES (solo Torso):
	- Trails con ApplyToAllParts = false (o sin esa propiedad)
	- Se aplica 1 trail al Torso
	- Ejemplo: Fire, Lightning, Rainbow

	TRAILS DE CUERPO COMPLETO:
	- Trails con ApplyToAllParts = true
	- Se aplica a: Torso, Left Arm, Right Arm, Left Leg, Right Leg
	- NO se aplica a Head
	- Número de trails por parte: TrailsPerPart (default: 2)
	- Ejemplo: FullBody (2 trails × 5 partes = 10 trails totales)

	PERSONALIZACIÓN:
	- Para cambiar las posiciones de los attachments, edita la función createSingleTrail()
	- Para añadir más partes del cuerpo, edita la tabla BODY_PARTS
	- Para cambiar el número de trails por parte, modifica TrailsPerPart en TrailConfig
]]
