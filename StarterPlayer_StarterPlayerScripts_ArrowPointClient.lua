--[[
	ARROW POINT CLIENT - LocalScript
	Sistema de flechas direccionales que apuntan a objetivos en orden secuencial.
	Compatible con R6 y R15.

	UBICACIÓN: StarterPlayer/StarterPlayerScripts/ArrowPointClient

	CARACTERÍSTICAS:
	- Apunta al siguiente objetivo según atributo "Order"
	- Resalta objetivos con Highlight o SelectionBox
	- Detección por distancia o ProximityPrompt
	- Compatible con R6 (Torso) y R15 (UpperTorso)

	CONFIGURACIÓN DE OBJETIVOS:
	1. Coloca un Model o Part en Workspace
	2. Añade el tag "ArrowObjective" vía CollectionService
	3. Establece atributos:
	   - Order (number): Orden del objetivo (1, 2, 3, etc.)
	   - Distance (number, opcional): Distancia de detección (default: 15)
	   - Highlight (boolean, opcional): Si debe resaltarse (default: true)

	EJEMPLO DE USO:
	Model en Workspace llamado "Checkpoint1":
	- Tag: "ArrowObjective"
	- Atributos:
	  - Order = 1
	  - Distance = 20
	  - Highlight = true
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ========================================
-- IMPORTAR CONFIGURACIÓN
-- ========================================
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ArrowPointConfig = require(Modules:WaitForChild("ArrowPointConfig"))

print("[ArrowPointClient] 🎯 Sistema de flechas inicializado")

-- ========================================
-- VARIABLES
-- ========================================
local currentObjective = nil
local currentObjectiveOrder = 0
local beam = nil
local beamAttachment = nil
local targetAttachment = nil
local highlights = {}  -- Almacena highlights creados por el sistema
local originalHighlights = {}  -- Almacena highlights originales del objetivo

-- ========================================
-- FUNCIONES DE HIGHLIGHT
-- ========================================

-- Crea un Highlight para un Model
local function createModelHighlight(model)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = ArrowPointConfig.Highlight.Model.FillTransparency
	highlight.FillColor = ArrowPointConfig.Highlight.Model.FillColor
	highlight.OutlineColor = ArrowPointConfig.Highlight.Model.OutlineColor
	highlight.OutlineTransparency = ArrowPointConfig.Highlight.Model.OutlineTransparency
	highlight.Adornee = model
	highlight.Parent = model
	return highlight
end

-- Crea un Highlight para una Part opaca
local function createPartHighlight(part)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = ArrowPointConfig.Highlight.Part.FillTransparency
	highlight.FillColor = ArrowPointConfig.Highlight.Part.FillColor
	highlight.OutlineColor = ArrowPointConfig.Highlight.Part.OutlineColor
	highlight.OutlineTransparency = ArrowPointConfig.Highlight.Part.OutlineTransparency
	highlight.Adornee = part
	highlight.Parent = part
	return highlight
end

-- Crea un SelectionBox para una Part transparente
local function createSelectionBox(part)
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = ArrowPointConfig.Highlight.SelectionBox.Color3
	selectionBox.LineThickness = ArrowPointConfig.Highlight.SelectionBox.LineThickness
	selectionBox.Adornee = part
	selectionBox.Parent = part
	return selectionBox
end

-- Detecta si un highlight es original del objetivo o fue creado por el sistema
local function isOriginalHighlight(highlight, object)
	-- Guardar highlights originales cuando se detecta el objetivo
	if not originalHighlights[object] then
		originalHighlights[object] = {}
		for _, child in ipairs(object:GetDescendants()) do
			if child:IsA("Highlight") or child:IsA("SelectionBox") then
				table.insert(originalHighlights[object], child)
			end
		end
	end

	-- Verificar si este highlight está en la lista de originales
	for _, original in ipairs(originalHighlights[object]) do
		if original == highlight then
			return true
		end
	end

	return false
end

-- Añade highlight a un objetivo
local function addHighlight(object)
	-- Verificar si el objetivo quiere highlight
	local wantsHighlight = object:GetAttribute(ArrowPointConfig.Attributes.Highlight)
	if wantsHighlight == false then
		return  -- No añadir highlight si está explícitamente desactivado
	end

	local mainPart = ArrowPointConfig.GetMainPart(object)
	if not mainPart then
		warn("[ArrowPointClient] ⚠️ No se pudo obtener parte principal de", object.Name)
		return
	end

	local highlightObject

	if object:IsA("Model") then
		highlightObject = createModelHighlight(object)
	elseif object:IsA("BasePart") then
		if mainPart.Transparency >= 0.5 then
			highlightObject = createSelectionBox(mainPart)
		else
			highlightObject = createPartHighlight(mainPart)
		end
	end

	if highlightObject then
		highlights[object] = highlightObject
		print(string.format("[ArrowPointClient] ✨ Highlight añadido a %s", object.Name))
	end
end

-- Remueve highlight de un objetivo (solo si fue creado por el sistema)
local function removeHighlight(object)
	local highlightObject = highlights[object]

	if highlightObject then
		-- Solo remover si no es un highlight original
		if not isOriginalHighlight(highlightObject, object) then
			highlightObject:Destroy()
			print(string.format("[ArrowPointClient] 🗑️ Highlight removido de %s", object.Name))
		else
			print(string.format("[ArrowPointClient] 🔒 Highlight original preservado en %s", object.Name))
		end
		highlights[object] = nil
	end
end

-- ========================================
-- FUNCIONES DE BEAM
-- ========================================

-- Crea el attachment en el torso del jugador
local function createBeamAttachment()
	local torsoPart = ArrowPointConfig.GetTorsoPart(character)
	if not torsoPart then
		warn("[ArrowPointClient] ❌ No se encontró Torso/UpperTorso en el personaje")
		return false
	end

	-- Buscar o crear attachment
	beamAttachment = torsoPart:FindFirstChild(ArrowPointConfig.BeamAttachmentName)
	if not beamAttachment then
		beamAttachment = Instance.new("Attachment")
		beamAttachment.Name = ArrowPointConfig.BeamAttachmentName
		beamAttachment.Parent = torsoPart
	end

	print(string.format("[ArrowPointClient] ✅ Attachment creado en %s", torsoPart.Name))
	return true
end

-- Crea el Beam visual
local function createBeam()
	if not beamAttachment then
		warn("[ArrowPointClient] ❌ No hay attachment para el beam")
		return false
	end

	-- Crear beam
	beam = Instance.new("Beam")
	beam.Texture = ArrowPointConfig.Beam.Texture
	beam.Color = ArrowPointConfig.Beam.Color
	beam.Width0 = ArrowPointConfig.Beam.Width0
	beam.Width1 = ArrowPointConfig.Beam.Width1
	beam.FaceCamera = ArrowPointConfig.Beam.FaceCamera
	beam.LightEmission = ArrowPointConfig.Beam.LightEmission
	beam.Transparency = ArrowPointConfig.Beam.Transparency
	beam.TextureMode = ArrowPointConfig.Beam.TextureMode
	beam.TextureLength = ArrowPointConfig.Beam.TextureLength
	beam.TextureSpeed = ArrowPointConfig.Beam.TextureSpeed

	beam.Attachment0 = beamAttachment
	beam.Parent = beamAttachment.Parent

	print("[ArrowPointClient] ✅ Beam creado")
	return true
end

-- Actualiza el objetivo del beam
local function updateBeamTarget(targetObject)
	if not beam then return end

	-- Obtener parte principal del objetivo
	local mainPart = ArrowPointConfig.GetMainPart(targetObject)
	if not mainPart then
		warn("[ArrowPointClient] ⚠️ No se pudo obtener parte principal de", targetObject.Name)
		return
	end

	-- Buscar o crear attachment en el objetivo
	targetAttachment = mainPart:FindFirstChild("ArrowTargetAttachment")
	if not targetAttachment then
		targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "ArrowTargetAttachment"
		targetAttachment.Parent = mainPart
	end

	-- Conectar beam al objetivo
	beam.Attachment1 = targetAttachment

	print(string.format("[ArrowPointClient] 🎯 Beam apuntando a %s", targetObject.Name))
end

-- Oculta el beam
local function hideBeam()
	if beam then
		beam.Enabled = false
	end
end

-- Muestra el beam
local function showBeam()
	if beam then
		beam.Enabled = true
	end
end

-- ========================================
-- FUNCIONES DE OBJETIVOS
-- ========================================

-- Obtiene todos los objetivos ordenados
local function getObjectivesSorted()
	local objectives = CollectionService:GetTagged(ArrowPointConfig.ObjectiveTag)

	-- Filtrar objetivos con Order válido
	local validObjectives = {}
	for _, obj in ipairs(objectives) do
		local isValid, order = ArrowPointConfig.ValidateAttribute(obj, ArrowPointConfig.Attributes.Order, "number")
		if isValid and order then
			table.insert(validObjectives, {object = obj, order = order})
		else
			warn(string.format("[ArrowPointClient] ⚠️ Objetivo %s no tiene atributo Order válido", obj.Name))
		end
	end

	-- Ordenar por Order
	table.sort(validObjectives, function(a, b)
		return a.order < b.order
	end)

	return validObjectives
end

-- Busca el siguiente objetivo
local function findNextObjective()
	local objectives = getObjectivesSorted()

	for _, data in ipairs(objectives) do
		if data.order > currentObjectiveOrder then
			return data.object, data.order
		end
	end

	return nil, nil
end

-- Establece el objetivo actual
local function setCurrentObjective(objective, order)
	-- Remover highlight del objetivo anterior
	if currentObjective then
		removeHighlight(currentObjective)
	end

	currentObjective = objective
	currentObjectiveOrder = order

	if objective then
		print(string.format("[ArrowPointClient] 📍 Nuevo objetivo: %s (Order: %d)", objective.Name, order))

		-- Añadir highlight
		addHighlight(objective)

		-- Actualizar beam
		updateBeamTarget(objective)
		showBeam()
	else
		print("[ArrowPointClient] ✅ Todos los objetivos completados")
		hideBeam()
	end
end

-- Completa el objetivo actual
local function completeCurrentObjective()
	if not currentObjective then return end

	print(string.format("[ArrowPointClient] ✅ Objetivo completado: %s", currentObjective.Name))

	-- Remover highlight
	removeHighlight(currentObjective)

	-- Buscar siguiente objetivo
	local nextObjective, nextOrder = findNextObjective()
	setCurrentObjective(nextObjective, nextOrder)
end

-- ========================================
-- DETECCIÓN DE OBJETIVOS
-- ========================================

-- Verifica si el jugador está cerca del objetivo
local function checkDistance()
	if not currentObjective then return false end

	local mainPart = ArrowPointConfig.GetMainPart(currentObjective)
	if not mainPart then return false end

	local torsoPart = ArrowPointConfig.GetTorsoPart(character)
	if not torsoPart then return false end

	-- Obtener distancia configurada
	local detectionDistance = currentObjective:GetAttribute(ArrowPointConfig.Attributes.Distance)
		or ArrowPointConfig.DefaultDistance

	-- Calcular distancia
	local distance = (mainPart.Position - torsoPart.Position).Magnitude

	return distance <= detectionDistance
end

-- Verifica si hay un ProximityPrompt activado
local function checkProximityPrompt()
	if not currentObjective then return false end

	-- Buscar ProximityPrompt en el objetivo
	local proximityPrompt = currentObjective:FindFirstChildOfClass("ProximityPrompt", true)
	if not proximityPrompt then return false end

	-- Conectar evento triggered (solo una vez)
	if not proximityPrompt:GetAttribute("ArrowPoint_Connected") then
		proximityPrompt:SetAttribute("ArrowPoint_Connected", true)

		proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
			if playerWhoTriggered == player then
				print(string.format("[ArrowPointClient] 🎯 ProximityPrompt activado en %s", currentObjective.Name))
				completeCurrentObjective()
			end
		end)

		print(string.format("[ArrowPointClient] 🔌 ProximityPrompt conectado en %s", currentObjective.Name))
	end

	return false  -- La detección se maneja en el evento
end

-- ========================================
-- ACTUALIZACIÓN CONTINUA
-- ========================================

-- Loop principal de detección
local function startDetectionLoop()
	RunService.Heartbeat:Connect(function()
		if currentObjective then
			-- Si hay ProximityPrompt, usarlo; si no, usar distancia
			local hasProximityPrompt = currentObjective:FindFirstChildOfClass("ProximityPrompt", true) ~= nil

			if not hasProximityPrompt then
				-- Verificar por distancia
				if checkDistance() then
					completeCurrentObjective()
				end
			else
				-- Conectar ProximityPrompt si existe
				checkProximityPrompt()
			end
		end
	end)

	print("[ArrowPointClient] 🔄 Loop de detección iniciado")
end

-- ========================================
-- MANEJO DE NUEVOS OBJETIVOS (se conecta después de inicialización)
-- ========================================

local function connectObjectiveListeners()
	-- Cuando se añade un nuevo objetivo con el tag
	CollectionService:GetInstanceAddedSignal(ArrowPointConfig.ObjectiveTag):Connect(function(objective)
		print(string.format("[ArrowPointClient] 🆕 Nuevo objetivo detectado: %s", objective.Name))

		-- Si no hay objetivo actual, verificar si este es el siguiente
		if not currentObjective then
			local nextObjective, nextOrder = findNextObjective()
			if nextObjective then
				setCurrentObjective(nextObjective, nextOrder)
			end
		end
	end)

	-- Cuando se remueve un objetivo con el tag
	CollectionService:GetInstanceRemovedSignal(ArrowPointConfig.ObjectiveTag):Connect(function(objective)
		print(string.format("[ArrowPointClient] 🗑️ Objetivo removido: %s", objective.Name))

		-- Si era el objetivo actual, buscar el siguiente
		if objective == currentObjective then
			local nextObjective, nextOrder = findNextObjective()
			setCurrentObjective(nextObjective, nextOrder)
		end

		-- Limpiar highlight si existe
		removeHighlight(objective)
		originalHighlights[objective] = nil
	end)

	print("[ArrowPointClient] 🔌 Listeners de objetivos conectados")
end

-- ========================================
-- REINICIO AL RESPAWNEAR
-- ========================================

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Esperar a que el personaje cargue completamente
	task.wait(ArrowPointConfig.StartDelay)

	print("[ArrowPointClient] 🔄 Personaje respawneado, reiniciando sistema...")

	-- Recrear attachment y beam
	if createBeamAttachment() then
		createBeam()

		-- Restablecer objetivo actual
		if currentObjective then
			updateBeamTarget(currentObjective)
			showBeam()
		end
	end
end)

-- ========================================
-- INICIALIZACIÓN
-- ========================================

-- Esperar antes de iniciar
task.wait(ArrowPointConfig.StartDelay)

-- Crear beam en el personaje
if not createBeamAttachment() then
	warn("[ArrowPointClient] ❌ No se pudo crear attachment, esperando respawn...")
	return
end

if not createBeam() then
	warn("[ArrowPointClient] ❌ No se pudo crear beam, esperando respawn...")
	return
end

-- Buscar primer objetivo
local firstObjective, firstOrder = findNextObjective()
if firstObjective then
	setCurrentObjective(firstObjective, firstOrder)
else
	print("[ArrowPointClient] ⚠️ No se encontraron objetivos con el tag", ArrowPointConfig.ObjectiveTag)
	hideBeam()
end

-- Conectar listeners DESPUÉS de establecer el objetivo inicial
connectObjectiveListeners()

-- Iniciar loop de detección
startDetectionLoop()

print("[ArrowPointClient] ✅ Sistema de flechas completamente inicializado")
