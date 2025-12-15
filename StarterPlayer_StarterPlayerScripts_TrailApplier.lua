-- StarterPlayer > StarterPlayerScripts > TrailApplier (LocalScript)
-- Aplica la trail equipada al Torso del jugador (R6)

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

local currentTrail = nil  -- Trail actual aplicada al Torso
local currentEquippedID = nil  -- ID de la trail equipada

-- ==================== FUNCIONES ====================

-- Remueve la trail actual del Torso
local function removeCurrentTrail()
	if currentTrail then
		currentTrail:Destroy()
		currentTrail = nil
		print("[TrailApplier] 🗑️ Trail removida del Torso")
	end
end

-- Aplica una trail al Torso del jugador (R6)
local function applyTrailToTorso(trailID)
	-- Remover trail anterior
	removeCurrentTrail()

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

	-- Obtener el Torso del personaje (R6)
	local torso = character:FindFirstChild("Torso")
	if not torso then
		warn("[TrailApplier] ⚠️ No se encontró Torso (¿el personaje es R6?)")
		return
	end

	-- Crear attachments para la trail en el Torso
	-- Attachment superior (parte alta del torso)
	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "TrailAttachment0"
	attachment0.Position = Vector3.new(0, 1, 0)  -- Arriba del torso
	attachment0.Parent = torso

	-- Attachment inferior (parte baja del torso)
	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "TrailAttachment1"
	attachment1.Position = Vector3.new(0, -1, 0)  -- Abajo del torso
	attachment1.Parent = torso

	-- Crear la Trail
	local trail = Instance.new("Trail")
	trail.Name = "PlayerTrail"

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

	-- Añadir al Torso
	trail.Parent = torso

	-- Guardar referencia
	currentTrail = trail
	currentEquippedID = trailID

	print(string.format("[TrailApplier] ✅ Trail '%s' aplicada al Torso", trailConfig.Name))
end

-- Obtiene la trail equipada del servidor
local function loadEquippedTrail()
	print("[TrailApplier] 📡 Solicitando trail equipada del servidor...")

	local success, trailData = pcall(function()
		return GetTrailDataEvent:InvokeServer()
	end)

	if success and trailData and trailData.EquippedTrail then
		applyTrailToTorso(trailData.EquippedTrail)
	else
		warn("[TrailApplier] ⚠️ No se pudo cargar la trail equipada")
		-- Aplicar trail por defecto
		local defaultTrail = TrailConfig.GetDefaultTrail()
		if defaultTrail then
			applyTrailToTorso(defaultTrail.ID)
		end
	end
end

-- ==================== EVENTOS ====================

-- Escuchar cuando se equipa una nueva trail
EquipTrailEvent.OnClientEvent:Connect(function(result)
	if result.Success and result.TrailID then
		applyTrailToTorso(result.TrailID)
	end
end)

-- Manejar cuando el personaje reaparece (muerte/respawn)
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Esperar a que el Torso esté disponible
	local torso = character:WaitForChild("Torso", 10)
	if not torso then
		warn("[TrailApplier] ⚠️ No se encontró Torso al reaparecer")
		return
	end

	-- Reaplicar la trail equipada
	task.wait(0.5)  -- Pequeña espera para asegurar que todo esté cargado
	if currentEquippedID then
		applyTrailToTorso(currentEquippedID)
	else
		loadEquippedTrail()
	end
end)

-- ==================== INICIALIZACIÓN ====================

-- Cargar trail equipada al iniciar
task.wait(2)  -- Esperar a que todo el sistema esté listo
loadEquippedTrail()

print("[TrailApplier] ✅ Sistema de aplicación de trails iniciado")
