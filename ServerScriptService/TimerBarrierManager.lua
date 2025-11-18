--[[
	TimerBarrierManager.lua
	Sistema de barrera invisible individual por jugador

	Coloca este script en: ServerScriptService

	IMPORTANTE:
	- La Part "TimerBarrier" en Workspace debe tener CanCollide = false
	- Este script crea una barrera INVISIBLE que solo bloquea durante 15 minutos
	- Cada jugador tiene su propia barrera invisible
	- Después de 15 minutos, la barrera invisible se desactiva para ese jugador
]]

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================
-- CONFIGURACIÓN
-- ============================================
local BARRIER_NAME = "TimerBarrier" -- Nombre de la Part VISIBLE en Workspace (con CanCollide = false)
local TIMER_DURATION = 15 * 60 -- 15 minutos en segundos

-- ============================================
-- TABLA DE ESTADO
-- ============================================
-- Rastrear qué jugadores completaron el timer
-- Key: UserId, Value: true si completó
local CompletedPlayers = {}

-- ============================================
-- BARRERA INVISIBLE
-- ============================================
local invisibleBarrier = nil

-- ============================================
-- CREAR REMOTEEVENT
-- ============================================
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "TimerBarrierEvent"
remoteEvent.Parent = ReplicatedStorage

local timerDuration = Instance.new("IntValue")
timerDuration.Name = "TimerDuration"
timerDuration.Value = TIMER_DURATION
timerDuration.Parent = ReplicatedStorage

print("=== Timer Barrier System Iniciado ===")

-- ============================================
-- CONFIGURAR COLLISION GROUPS
-- ============================================
local function SetupCollisionGroups()
	-- Jugadores que AÚN tienen barrera (colisionan con barrera invisible)
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithBarrier")
	end

	-- Jugadores que ya NO tienen barrera (NO colisionan)
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithoutBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithoutBarrier")
	end

	-- Grupo para la barrera invisible
	if not PhysicsService:IsCollisionGroupRegistered("InvisibleBarrier") then
		PhysicsService:RegisterCollisionGroup("InvisibleBarrier")
	end

	-- Configurar colisiones
	PhysicsService:CollisionGroupSetCollidable("PlayersWithBarrier", "InvisibleBarrier", true)  -- SÍ colisionan
	PhysicsService:CollisionGroupSetCollidable("PlayersWithoutBarrier", "InvisibleBarrier", false)  -- NO colisionan

	print("✅ Collision Groups configurados")
end

-- ============================================
-- CREAR BARRERA INVISIBLE
-- ============================================
local function CreateInvisibleBarrier()
	-- Buscar la barrera visible en Workspace
	local visibleBarrier = workspace:FindFirstChild(BARRIER_NAME)

	if not visibleBarrier then
		warn("⚠️ ERROR: No se encontró '" .. BARRIER_NAME .. "' en Workspace")
		return false
	end

	print("✅ Barrera visible encontrada: " .. visibleBarrier.Name)
	print("   CanCollide debe estar en false (verificar en propiedades)")

	-- Crear barrera invisible en la misma posición
	invisibleBarrier = Instance.new("Part")
	invisibleBarrier.Name = "InvisibleTimerBarrier"
	invisibleBarrier.Size = visibleBarrier.Size
	invisibleBarrier.Position = visibleBarrier.Position
	invisibleBarrier.Rotation = visibleBarrier.Rotation
	invisibleBarrier.Anchored = true
	invisibleBarrier.CanCollide = true  -- Esta SÍ tiene colisión
	invisibleBarrier.Transparency = 1  -- Completamente invisible
	invisibleBarrier.Material = Enum.Material.ForceField
	invisibleBarrier.CollisionGroup = "InvisibleBarrier"
	invisibleBarrier.Parent = workspace

	print("✅ Barrera invisible creada")
	print("   Posición: " .. tostring(invisibleBarrier.Position))
	print("   Tamaño: " .. tostring(invisibleBarrier.Size))

	return true
end

-- ============================================
-- ASIGNAR COLLISION GROUP A JUGADOR
-- ============================================
local function SetPlayerCollisionGroup(player, groupName)
	local character = player.Character
	if not character then
		return
	end

	-- Asignar a todas las partes
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end

	-- Nuevas partes que se agreguen
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = groupName
		end
	end)
end

-- ============================================
-- CUANDO JUGADOR ENTRA
-- ============================================
local function OnPlayerAdded(player)
	print("👤 Jugador conectado: " .. player.Name)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)

		-- Verificar si ya completó
		if CompletedPlayers[player.UserId] then
			-- Ya completó - NO colisiona con barrera invisible
			SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")
			print("✅ " .. player.Name .. " - Puede pasar (ya completó)")
		else
			-- No ha completado - SÍ colisiona con barrera invisible
			SetPlayerCollisionGroup(player, "PlayersWithBarrier")
			print("🚫 " .. player.Name .. " - Bloqueado por 15 minutos")
		end
	end)
end

-- ============================================
-- CUANDO JUGADOR SALE
-- ============================================
local function OnPlayerRemoving(player)
	CompletedPlayers[player.UserId] = nil
	print("👋 " .. player.Name .. " salió - Estado limpiado")
end

-- ============================================
-- MANEJAR EVENTOS DEL CLIENTE
-- ============================================
remoteEvent.OnServerEvent:Connect(function(player, action)
	if action == "TimerCompleted" then
		print("⏰ Timer completado: " .. player.Name)

		-- Marcar como completado
		CompletedPlayers[player.UserId] = true

		-- Cambiar collision group (ahora NO colisiona con barrera invisible)
		SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")

		print("✅ " .. player.Name .. " ahora puede pasar la barrera")

		-- Confirmar al cliente
		remoteEvent:FireClient(player, "BarrierDisabled")

	elseif action == "GetStatus" then
		-- Cliente solicita estado
		local hasCompleted = CompletedPlayers[player.UserId] or false

		remoteEvent:FireClient(player, "StatusResponse", {
			hasCompleted = hasCompleted,
			timerDuration = TIMER_DURATION
		})

		print("📡 Estado enviado a " .. player.Name .. ": " .. (hasCompleted and "Completado" or "Activo"))
	end
end)

-- ============================================
-- INICIALIZAR
-- ============================================
SetupCollisionGroups()

if not CreateInvisibleBarrier() then
	warn("⚠️ El sistema no pudo inicializarse")
	warn("⚠️ Crea una Part llamada '" .. BARRIER_NAME .. "' en Workspace")
	warn("⚠️ Y asegúrate de que CanCollide = false")
	return
end

-- Conectar eventos
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Jugadores ya en el juego
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("=== Timer Barrier System Listo ===")
print("")
print("📋 La Part '" .. BARRIER_NAME .. "' debe tener CanCollide = false")
print("📋 La barrera invisible bloquea a los jugadores por 15 minutos")
print("")
print("🎮 Comandos:")
print("   _G.CheckPlayer('nombre') - Ver estado")
print("   _G.ForceComplete('nombre') - Completar timer")
print("   _G.ResetAll() - Resetear todos")

-- ============================================
-- COMANDOS DE DEBUG
-- ============================================
_G.CheckPlayer = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado")
		return
	end

	local completed = CompletedPlayers[player.UserId] or false

	print("━━━━━━━━━━━━━━━━━━━━")
	print("Jugador: " .. player.Name)
	print("Estado: " .. (completed and "✅ Completado" or "⏰ Activo"))
	print("Puede pasar: " .. (completed and "SÍ" or "NO"))
	print("━━━━━━━━━━━━━━━━━━━━")
end

_G.ForceComplete = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado")
		return
	end

	CompletedPlayers[player.UserId] = true
	SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")
	print("✅ Forzado: " .. player.Name .. " puede pasar")
end

_G.ResetAll = function()
	print("🔄 Reseteando todos...")
	CompletedPlayers = {}

	for _, player in pairs(Players:GetPlayers()) do
		SetPlayerCollisionGroup(player, "PlayersWithBarrier")
		print("   🚫 " .. player.Name .. " - Bloqueado")
	end
end
