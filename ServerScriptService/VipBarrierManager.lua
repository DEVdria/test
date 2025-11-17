-- ServerScriptService > VipBarrierManager
-- Gestiona las barreras VIP para que solo jugadores VIP puedan atravesarlas

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- ====================================
-- CONFIGURACIÓN DE COLLISION GROUPS
-- ====================================

-- Nombres de los grupos de colisión
local VIP_PLAYERS_GROUP = "VIPPlayers"
local VIP_BARRIER_GROUP = "VIPBarrier"
local DEFAULT_GROUP = "Default"

-- Crear los grupos de colisión si no existen
local function setupCollisionGroups()
	-- Crear grupo para jugadores VIP
	if not pcall(function()
		PhysicsService:GetCollisionGroupId(VIP_PLAYERS_GROUP)
	end) then
		PhysicsService:CreateCollisionGroup(VIP_PLAYERS_GROUP)
		print("Grupo de colisión '" .. VIP_PLAYERS_GROUP .. "' creado")
	end

	-- Crear grupo para barreras VIP
	if not pcall(function()
		PhysicsService:GetCollisionGroupId(VIP_BARRIER_GROUP)
	end) then
		PhysicsService:CreateCollisionGroup(VIP_BARRIER_GROUP)
		print("Grupo de colisión '" .. VIP_BARRIER_GROUP .. "' creado")
	end

	-- Configurar que los jugadores VIP NO colisionen con las barreras VIP
	PhysicsService:CollisionGroupSetCollidable(VIP_PLAYERS_GROUP, VIP_BARRIER_GROUP, false)
	print("Configurado: VIPPlayers NO colisiona con VIPBarrier")
end

-- Ejecutar la configuración
setupCollisionGroups()

-- ====================================
-- CONFIGURAR BARRERAS VIP
-- ====================================

-- Función para configurar una barrera VIP
local function setupVipBarrier(barrier)
	if not barrier:IsA("BasePart") then
		warn("VipBarrier debe ser una BasePart!")
		return
	end

	-- Agregar la barrera al grupo de colisión VIPBarrier
	PhysicsService:SetPartCollisionGroup(barrier, VIP_BARRIER_GROUP)

	-- Hacer la barrera semi-transparente para que se vea que es especial
	barrier.Transparency = 0.5
	barrier.CanCollide = true

	-- Agregar un color distintivo (dorado para VIP)
	barrier.BrickColor = BrickColor.new("Gold")
	barrier.Material = Enum.Material.Neon

	print("Barrera VIP configurada: " .. barrier.Name)
end

-- Buscar todas las partes llamadas "VipBarrier" en el Workspace
local function findAndSetupVipBarriers()
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant.Name == "VipBarrier" and descendant:IsA("BasePart") then
			setupVipBarrier(descendant)
		end
	end
end

-- Configurar barreras existentes
findAndSetupVipBarriers()

-- Detectar nuevas barreras que se agreguen
workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "VipBarrier" and descendant:IsA("BasePart") then
		wait(0.1) -- Pequeña espera para asegurar que la parte esté completamente cargada
		setupVipBarrier(descendant)
	end
end)

-- ====================================
-- GESTIÓN DE JUGADORES
-- ====================================

-- Función para verificar si un jugador tiene VIP
local function playerHasVIP(player)
	-- Verificar si el jugador tiene el BoolValue de VIP o similar
	-- (Esto debe coincidir con cómo GamepassManager marca a los VIP)

	-- Método 1: Buscar el tag VIP en la cabeza del personaje
	if player.Character then
		local head = player.Character:FindFirstChild("Head")
		if head and head:FindFirstChild("VIPTag") then
			return true
		end
	end

	-- Método 2: Podrías también verificar directamente con MarketplaceService
	-- pero es mejor usar el tag que ya crea GamepassManager

	return false
end

-- Función para agregar todas las partes del personaje al grupo VIP
local function setCharacterCollisionGroup(character, groupName)
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, groupName)
		end
	end
end

-- Función para configurar un jugador VIP
local function setupVipPlayer(player)
	local function onCharacterAdded(character)
		-- Esperar un poco para que el tag VIP se cree
		wait(1)

		if playerHasVIP(player) then
			-- Agregar todas las partes del personaje al grupo VIP
			setCharacterCollisionGroup(character, VIP_PLAYERS_GROUP)
			print(player.Name .. " (VIP) puede atravesar barreras VIP")

			-- Detectar nuevas partes que se agreguen al personaje
			character.DescendantAdded:Connect(function(descendant)
				if descendant:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(descendant, VIP_PLAYERS_GROUP)
				end
			end)
		else
			-- Jugador NO VIP - usar grupo default
			setCharacterCollisionGroup(character, DEFAULT_GROUP)
		end
	end

	-- Configurar para el personaje actual
	if player.Character then
		onCharacterAdded(player.Character)
	end

	-- Configurar para futuros personajes (cuando respawnee)
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- ====================================
-- EVENTOS DE JUGADORES
-- ====================================

-- Configurar jugadores existentes
for _, player in pairs(Players:GetPlayers()) do
	setupVipPlayer(player)
end

-- Configurar nuevos jugadores
Players.PlayerAdded:Connect(function(player)
	setupVipPlayer(player)
end)

print("VipBarrierManager cargado correctamente")
