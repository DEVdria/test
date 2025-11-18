--[[
	TimerBarrierManager.lua
	Sistema de barrera individual con temporizador por jugador

	Coloca este script en: ServerScriptService

	CÓMO FUNCIONA:
	- Cada jugador tiene su propio temporizador de 15 minutos
	- El temporizador empieza cuando el jugador entra al juego
	- Cuando termina, la barrera se vuelve traspasable SOLO para ese jugador
	- El estado persiste si el jugador muere/respawnea
	- Se resetea cuando el jugador sale del juego
]]

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================
-- CONFIGURACIÓN
-- ============================================
local BARRIER_NAME = "TimerBarrier" -- Nombre de la Part en Workspace
local TIMER_DURATION = 15 * 60 -- 15 minutos en segundos (900 segundos)

-- ============================================
-- TABLA DE JUGADORES
-- ============================================
-- Rastrear qué jugadores ya completaron su temporizador
-- Key: UserId, Value: true si completó
local CompletedPlayers = {}

-- ============================================
-- CREAR REMOTEEVENT
-- ============================================
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "TimerBarrierEvent"
remoteEvent.Parent = ReplicatedStorage

-- Compartir duración del timer con los clientes
local timerDuration = Instance.new("IntValue")
timerDuration.Name = "TimerDuration"
timerDuration.Value = TIMER_DURATION
timerDuration.Parent = ReplicatedStorage

print("=== Timer Barrier System Iniciado ===")

-- ============================================
-- CONFIGURAR COLLISION GROUPS
-- ============================================
local function SetupCollisionGroups()
	-- Grupo para jugadores CON barrera activa (no pueden pasar)
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithBarrier")
	end

	-- Grupo para jugadores SIN barrera (pueden pasar)
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithoutBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithoutBarrier")
	end

	-- Grupo para la barrera
	if not PhysicsService:IsCollisionGroupRegistered("TimerBarrier") then
		PhysicsService:RegisterCollisionGroup("TimerBarrier")
	end

	-- Configurar colisiones
	PhysicsService:CollisionGroupSetCollidable("PlayersWithBarrier", "TimerBarrier", true)  -- SÍ colisionan
	PhysicsService:CollisionGroupSetCollidable("PlayersWithoutBarrier", "TimerBarrier", false)  -- NO colisionan

	print("✅ Collision Groups configurados")
end

-- ============================================
-- CONFIGURAR LA BARRERA
-- ============================================
local function SetupBarrier()
	local barrier = workspace:FindFirstChild(BARRIER_NAME)

	if not barrier then
		warn("⚠️ ERROR: No se encontró la Part '" .. BARRIER_NAME .. "' en Workspace")
		warn("⚠️ Por favor, crea una Part llamada '" .. BARRIER_NAME .. "' en Workspace")
		return false
	end

	-- Asignar la barrera al grupo "TimerBarrier"
	if barrier:IsA("BasePart") then
		barrier.CollisionGroup = "TimerBarrier"
	end

	-- Si tiene descendientes, también asignarlos
	for _, descendant in pairs(barrier:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "TimerBarrier"
		end
	end

	print("✅ Barrera configurada: " .. barrier.Name)
	print("   Posición: " .. tostring(barrier.Position))
	print("   Tamaño: " .. tostring(barrier.Size))
	return true
end

-- ============================================
-- ASIGNAR COLLISION GROUP A UN JUGADOR
-- ============================================
local function SetPlayerCollisionGroup(player, groupName)
	local character = player.Character
	if not character then
		return
	end

	-- Asignar a todas las partes del personaje
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end

	-- También asignar a nuevas partes que se agreguen (accesorios, etc.)
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = groupName
		end
	end)
end

-- ============================================
-- CUANDO UN JUGADOR ENTRA AL JUEGO
-- ============================================
local function OnPlayerAdded(player)
	print("👤 Jugador conectado: " .. player.Name)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.5) -- Esperar a que el personaje se inicialice

		-- Verificar si este jugador ya completó su temporizador
		if CompletedPlayers[player.UserId] then
			-- Ya completó - puede atravesar la barrera
			SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")
			print("✅ " .. player.Name .. " - Barrera DESACTIVADA (ya completó antes)")
		else
			-- No ha completado - barrera activa
			SetPlayerCollisionGroup(player, "PlayersWithBarrier")
			print("⏰ " .. player.Name .. " - Barrera ACTIVA (temporizador corriendo)")
		end
	end)
end

-- ============================================
-- CUANDO UN JUGADOR SALE DEL JUEGO
-- ============================================
local function OnPlayerRemoving(player)
	-- Limpiar el estado del jugador cuando sale
	CompletedPlayers[player.UserId] = nil
	print("👋 " .. player.Name .. " salió del juego - Estado limpiado")
end

-- ============================================
-- MANEJAR EVENTOS DEL CLIENTE
-- ============================================
remoteEvent.OnServerEvent:Connect(function(player, action)
	if action == "TimerCompleted" then
		-- El cliente notifica que el temporizador terminó
		print("⏰ Temporizador completado para: " .. player.Name)

		-- Guardar que este jugador completó
		CompletedPlayers[player.UserId] = true

		-- Cambiar su collision group
		SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")

		print("✅ " .. player.Name .. " ahora puede atravesar la barrera")

		-- Confirmar al cliente
		remoteEvent:FireClient(player, "BarrierDisabled")

	elseif action == "GetStatus" then
		-- El cliente pregunta si ya completó el temporizador
		local hasCompleted = CompletedPlayers[player.UserId] or false

		-- Enviar respuesta
		remoteEvent:FireClient(player, "StatusResponse", {
			hasCompleted = hasCompleted,
			timerDuration = TIMER_DURATION
		})

		print("📡 Enviado estado a " .. player.Name .. ": " .. (hasCompleted and "Completado" or "Activo"))
	end
end)

-- ============================================
-- INICIALIZAR SISTEMA
-- ============================================
SetupCollisionGroups()

if not SetupBarrier() then
	warn("⚠️ El sistema no pudo inicializarse correctamente")
	warn("⚠️ Asegúrate de crear una Part llamada '" .. BARRIER_NAME .. "' en Workspace")
	return
end

-- Conectar eventos
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Configurar jugadores que ya estén en el juego
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("=== Timer Barrier System Listo ===")
print("")
print("📋 Comandos de Debug:")
print("   _G.CheckPlayer(nombre) - Ver estado de un jugador")
print("   _G.ForceComplete(nombre) - Forzar completar temporizador")
print("   _G.ResetPlayer(nombre) - Resetear temporizador de un jugador")
print("   _G.ResetAll() - Resetear todos los temporizadores")

-- ============================================
-- COMANDOS DE DEBUG
-- ============================================
_G.CheckPlayer = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	local hasCompleted = CompletedPlayers[player.UserId] or false

	print("━━━━━━━━━━━━━━━━━━━━━━")
	print("Jugador: " .. player.Name)
	print("UserId: " .. player.UserId)
	print("Estado: " .. (hasCompleted and "✅ Completado" or "⏰ Activo"))
	print("Puede pasar: " .. (hasCompleted and "SÍ" or "NO"))
	print("━━━━━━━━━━━━━━━━━━━━━━")
end

_G.ForceComplete = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	CompletedPlayers[player.UserId] = true
	SetPlayerCollisionGroup(player, "PlayersWithoutBarrier")
	print("✅ Forzado: " .. player.Name .. " - Barrera DESACTIVADA")
end

_G.ResetPlayer = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	CompletedPlayers[player.UserId] = nil
	SetPlayerCollisionGroup(player, "PlayersWithBarrier")
	print("🔄 Reseteado: " .. player.Name .. " - Barrera ACTIVA")
end

_G.ResetAll = function()
	print("🔄 Reseteando todos los temporizadores...")
	CompletedPlayers = {}

	for _, player in pairs(Players:GetPlayers()) do
		SetPlayerCollisionGroup(player, "PlayersWithBarrier")
		print("   ✅ " .. player.Name .. " - Barrera ACTIVA")
	end

	print("🔄 Todos los temporizadores han sido reseteados")
end
