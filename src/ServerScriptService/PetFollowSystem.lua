--[[
	PET FOLLOW SYSTEM - Sistema de seguimiento de mascotas

	Maneja:
	- Spawning de modelos de mascotas desde ReplicatedStorage
	- Seguimiento del jugador usando AlignPosition
	- Posicionamiento múltiple (varias mascotas sin encimarse)
	- Limpieza al desequipar
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Configuración
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

-- Carpeta de modelos de mascotas (el usuario los pondrá aquí)
local PetsModelsFolder = ReplicatedStorage:WaitForChild("PetsModels")

-- RemoteEvents
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local EquipPetRemote = RemoteEventsFolder:WaitForChild("EquipPet")
local UnequipPetRemote = RemoteEventsFolder:WaitForChild("UnequipPet")

-- Tabla de mascotas activas por jugador
-- Estructura: ActivePets[player][petUniqueID] = {Model, Attachment, AlignPosition}
local ActivePets = {}

-- ============================================
-- FUNCIÓN: CALCULAR POSICIÓN DE SEGUIMIENTO
-- ============================================
local function getFollowPosition(character, index)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	local distance = PetConfig.Settings.PetFollowDistance
	local spacing = PetConfig.Settings.PetSpacing

	-- Crear formación circular detrás del jugador
	local angle = math.rad((index - 1) * (360 / PetConfig.Settings.MaxEquippedPets))
	local offset = Vector3.new(
		math.sin(angle) * spacing,
		0,
		math.cos(angle) * spacing
	)

	return humanoidRootPart.CFrame * CFrame.new(offset + Vector3.new(0, 0, distance))
end

-- ============================================
-- FUNCIÓN: CREAR MASCOTA SIGUIENDO AL JUGADOR
-- ============================================
local function spawnPet(player, petData, index)
	local character = player.Character
	if not character then return nil end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end

	-- Buscar modelo de la mascota
	local petModel = PetsModelsFolder:FindFirstChild(petData.Name)
	if not petModel then
		warn("[PetFollow] Modelo no encontrado: " .. petData.Name)
		return nil
	end

	-- Clonar modelo
	local clonedPet = petModel:Clone()
	clonedPet.Name = petData.Name .. "_" .. petData.UniqueID

	-- Buscar PrimaryPart o crear una
	local petPrimaryPart = clonedPet.PrimaryPart or clonedPet:FindFirstChildWhichIsA("BasePart")
	if not petPrimaryPart then
		warn("[PetFollow] No se encontró BasePart en el modelo: " .. petData.Name)
		clonedPet:Destroy()
		return nil
	end

	-- Establecer PrimaryPart si no existe
	if not clonedPet.PrimaryPart then
		clonedPet.PrimaryPart = petPrimaryPart
	end

	-- Hacer todas las partes no colisionables
	for _, part in ipairs(clonedPet:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Massless = true
		end
	end

	-- Posicionar mascota inicialmente
	local startCFrame = getFollowPosition(character, index)
	if startCFrame then
		clonedPet:SetPrimaryPartCFrame(startCFrame)
	end

	-- Parent al workspace
	clonedPet.Parent = workspace

	-- ============================================
	-- CONFIGURAR ALIGNPOSITION
	-- ============================================

	-- Crear Attachment en la mascota
	local petAttachment = Instance.new("Attachment")
	petAttachment.Name = "PetAttachment"
	petAttachment.Parent = petPrimaryPart

	-- Crear Attachment en el jugador
	local playerAttachment = Instance.new("Attachment")
	playerAttachment.Name = "PetFollowAttachment_" .. index
	playerAttachment.Parent = humanoidRootPart

	-- Crear AlignPosition
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Name = "PetAlignPosition"
	alignPosition.Attachment0 = petAttachment
	alignPosition.Attachment1 = playerAttachment
	alignPosition.MaxForce = PetConfig.Settings.AlignPositionSettings.MaxForce
	alignPosition.Responsiveness = PetConfig.Settings.AlignPositionSettings.Responsiveness
	alignPosition.MaxVelocity = PetConfig.Settings.AlignPositionSettings.MaxVelocity
	alignPosition.RigidityEnabled = false
	alignPosition.Parent = petPrimaryPart

	-- Crear AlignOrientation (para que la mascota mire hacia adelante)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "PetAlignOrientation"
	alignOrientation.Attachment0 = petAttachment
	alignOrientation.Attachment1 = playerAttachment
	alignOrientation.MaxTorque = 10000
	alignOrientation.Responsiveness = 200
	alignOrientation.RigidityEnabled = false
	alignOrientation.Parent = petPrimaryPart

	-- ============================================
	-- ACTUALIZAR POSICIÓN DEL ATTACHMENT
	-- ============================================
	task.spawn(function()
		while clonedPet.Parent and character.Parent and humanoidRootPart.Parent do
			local targetCFrame = getFollowPosition(character, index)
			if targetCFrame then
				playerAttachment.WorldCFrame = targetCFrame
			end
			task.wait(0.1)
		end
	end)

	return {
		Model = clonedPet,
		Attachment = playerAttachment,
		AlignPosition = alignPosition
	}
end

-- ============================================
-- FUNCIÓN: ACTUALIZAR MASCOTAS EQUIPADAS
-- ============================================
local function updateEquippedPets(player, equippedPetsList)
	if not ActivePets[player] then
		ActivePets[player] = {}
	end

	local character = player.Character
	if not character then return end

	-- Remover mascotas que ya no están equipadas
	for petID, petData in pairs(ActivePets[player]) do
		local stillEquipped = false
		for _, equippedPet in ipairs(equippedPetsList) do
			if equippedPet.UniqueID == petID then
				stillEquipped = true
				break
			end
		end

		if not stillEquipped then
			-- Destruir mascota
			if petData.Model then
				petData.Model:Destroy()
			end
			if petData.Attachment then
				petData.Attachment:Destroy()
			end
			ActivePets[player][petID] = nil
		end
	end

	-- Spawn nuevas mascotas equipadas
	for index, equippedPet in ipairs(equippedPetsList) do
		if not ActivePets[player][equippedPet.UniqueID] then
			local petInstance = spawnPet(player, equippedPet, index)
			if petInstance then
				ActivePets[player][equippedPet.UniqueID] = petInstance
			end
		end
	end
end

-- ============================================
-- EQUIPAR MASCOTA
-- ============================================
EquipPetRemote.OnServerEvent:Connect(function(player, petUniqueID)
	-- Esperar a que el servidor procese el equipado
	task.wait(0.1)

	-- Obtener datos del servidor
	local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
	local PetSystemServer = ServerScriptService:WaitForChild("PetSystemServer")

	-- Obtener mascotas equipadas del jugador
	-- (Asumimos que PlayerData está accesible o creamos una función para obtenerlo)
end)

-- ============================================
-- DESEQUIPAR MASCOTA
-- ============================================
UnequipPetRemote.OnServerEvent:Connect(function(player, petUniqueID)
	task.wait(0.1)

	-- Remover mascota
	if ActivePets[player] and ActivePets[player][petUniqueID] then
		local petData = ActivePets[player][petUniqueID]
		if petData.Model then
			petData.Model:Destroy()
		end
		if petData.Attachment then
			petData.Attachment:Destroy()
		end
		ActivePets[player][petUniqueID] = nil
	end
end)

-- ============================================
-- ACTUALIZAR MASCOTAS AL REAPARECER
-- ============================================
Players.PlayerAdded:Connect(function(player)
	ActivePets[player] = {}

	player.CharacterAdded:Connect(function(character)
		-- Esperar a que el personaje cargue
		character:WaitForChild("HumanoidRootPart")

		-- Re-spawn mascotas equipadas
		-- (Esto requiere acceso a PlayerData, lo manejaremos desde PetSystemServer)
		task.wait(1)

		-- Limpiar mascotas antiguas
		for petID, petData in pairs(ActivePets[player]) do
			if petData.Model then
				petData.Model:Destroy()
			end
			if petData.Attachment then
				petData.Attachment:Destroy()
			end
		end
		ActivePets[player] = {}
	end)
end)

-- ============================================
-- LIMPIAR AL SALIR
-- ============================================
Players.PlayerRemoving:Connect(function(player)
	if ActivePets[player] then
		for petID, petData in pairs(ActivePets[player]) do
			if petData.Model then
				petData.Model:Destroy()
			end
			if petData.Attachment then
				petData.Attachment:Destroy()
			end
		end
		ActivePets[player] = nil
	end
end)

-- ============================================
-- FUNCIÓN PÚBLICA PARA ACTUALIZAR DESDE SERVIDOR
-- ============================================
local PetFollowSystem = {}

function PetFollowSystem.UpdatePets(player, equippedPetsList)
	updateEquippedPets(player, equippedPetsList)
end

return PetFollowSystem
