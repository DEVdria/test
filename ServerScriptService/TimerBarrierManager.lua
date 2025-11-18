--[[
	TimerBarrierManager.lua
	Script del servidor para manejar la barrera con temporizador individual

	Coloca este script en: ServerScriptService
]]

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Configuración
local BARRIER_NAME = "TimerBarrier" -- Nombre de la Part en Workspace
local TIMER_DURATION = 15 * 60 -- 15 minutos en segundos

-- NUEVA TABLA: Rastrear qué jugadores ya completaron su temporizador
-- Key: UserId del jugador, Value: true si completó
local PlayersWithCompletedTimer = {}

-- Crear RemoteEvent para comunicación cliente-servidor
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "TimerBarrierEvent"
remoteEvent.Parent = ReplicatedStorage

-- Crear IntValue para compartir el tiempo del temporizador
local timerValue = Instance.new("IntValue")
timerValue.Name = "TimerDuration"
timerValue.Value = TIMER_DURATION
timerValue.Parent = ReplicatedStorage

print("=== Timer Barrier Manager Iniciado ===")

-- Crear grupos de colisión
local function SetupCollisionGroups()
	-- Crear grupo para jugadores que AÚN tienen la barrera activa
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithBarrier")
	end

	-- Crear grupo para jugadores que ya NO tienen la barrera (pueden atravesarla)
	if not PhysicsService:IsCollisionGroupRegistered("PlayersWithoutBarrier") then
		PhysicsService:RegisterCollisionGroup("PlayersWithoutBarrier")
	end

	-- Crear grupo para la barrera
	if not PhysicsService:IsCollisionGroupRegistered("TimerBarrier") then
		PhysicsService:RegisterCollisionGroup("TimerBarrier")
	end

	-- Configurar colisiones:
	-- PlayersWithBarrier SÍ colisiona con TimerBarrier
	PhysicsService:CollisionGroupSetCollidable("PlayersWithBarrier", "TimerBarrier", true)

	-- PlayersWithoutBarrier NO colisiona con TimerBarrier (pueden atravesarla)
	PhysicsService:CollisionGroupSetCollidable("PlayersWithoutBarrier", "TimerBarrier", false)

	print("✅ Collision Groups configurados")
end

-- Configurar la barrera en Workspace
local function SetupBarrier()
	local barrier = workspace:FindFirstChild(BARRIER_NAME)

	if not barrier then
		warn("⚠️ No se encontró la Part llamada '" .. BARRIER_NAME .. "' en Workspace")
		warn("⚠️ Crea una Part en Workspace y nómbrala '" .. BARRIER_NAME .. "'")
		return
	end

	-- Asignar la barrera al grupo de colisión "TimerBarrier"
	for _, part in pairs(barrier:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "TimerBarrier"
		end
	end

	-- La barrera principal también
	if barrier:IsA("BasePart") then
		barrier.CollisionGroup = "TimerBarrier"
	end

	print("✅ Barrera configurada: " .. barrier.Name)
	print("   - Posición: " .. tostring(barrier.Position))
	print("   - Tamaño: " .. tostring(barrier.Size))
end

-- Configurar jugador al entrar
local function OnPlayerAdded(player)
	print("👤 Jugador conectado: " .. player.Name)

	-- Esperar a que el personaje cargue
	player.CharacterAdded:Connect(function(character)
		-- Esperar un momento para que el personaje se inicialice completamente
		task.wait(0.5)

		-- VERIFICAR si este jugador ya completó su temporizador antes
		local hasCompletedTimer = PlayersWithCompletedTimer[player.UserId]
		local collisionGroup = hasCompletedTimer and "PlayersWithoutBarrier" or "PlayersWithBarrier"

		-- Asignar al grupo correcto según si ya completó el temporizador
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = collisionGroup
			end
		end

		-- Detectar cuando se agregan nuevas partes al personaje (accesorios, etc.)
		character.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = collisionGroup
			end
		end)

		if hasCompletedTimer then
			print("✅ " .. player.Name .. " configurado con barrera DESACTIVADA (ya completó el temporizador)")
		else
			print("✅ " .. player.Name .. " configurado con barrera ACTIVA")
		end
	end)
end

-- Manejar cuando el temporizador de un jugador termina
remoteEvent.OnServerEvent:Connect(function(player, action)
	if action == "TimerEnded" then
		print("⏰ Temporizador terminado para: " .. player.Name)

		-- GUARDAR que este jugador completó su temporizador
		PlayersWithCompletedTimer[player.UserId] = true
		print("📝 Guardado: " .. player.Name .. " (UserId: " .. player.UserId .. ") completó el temporizador")

		local character = player.Character
		if not character then
			warn("⚠️ Character no encontrado para " .. player.Name)
			return
		end

		-- Cambiar el jugador al grupo "PlayersWithoutBarrier"
		-- Esto hace que pueda atravesar la barrera
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = "PlayersWithoutBarrier"
			end
		end

		print("✅ " .. player.Name .. " ahora puede atravesar la barrera")

		-- Opcional: Enviar confirmación al cliente
		remoteEvent:FireClient(player, "BarrierDisabled")

	elseif action == "RequestInitialState" then
		-- El cliente solicita el estado inicial/actualizado
		print("📡 " .. player.Name .. " solicitó estado inicial")

		local hasCompleted = PlayersWithCompletedTimer[player.UserId] or false
		local remainingTime = TIMER_DURATION

		-- Si ya completó, el tiempo restante es 0
		if hasCompleted then
			remainingTime = 0
		end

		-- Enviar estado al cliente
		local stateData = {
			hasCompleted = hasCompleted,
			timeRemaining = remainingTime
		}

		remoteEvent:FireClient(player, "InitialState", stateData)
		print("📡 Estado enviado a " .. player.Name .. ": Completado=" .. tostring(hasCompleted) .. ", Tiempo=" .. remainingTime)
	end
end)

-- Inicializar sistema
SetupCollisionGroups()
SetupBarrier()

-- Conectar eventos de jugadores
Players.PlayerAdded:Connect(OnPlayerAdded)

-- Limpiar datos cuando un jugador sale del juego (opcional - descomenta si quieres que el timer se resetee al salir)
Players.PlayerRemoving:Connect(function(player)
	-- Comentar la siguiente línea si quieres que el estado persista entre sesiones
	-- PlayersWithCompletedTimer[player.UserId] = nil
	print("👋 " .. player.Name .. " salió del juego")
end)

-- Configurar jugadores que ya estén en el juego
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("=== Timer Barrier System listo ===")
print("Comandos de debug:")
print("_G.ResetBarrier() - Reinicia la barrera para todos")
print("_G.DisableBarrier(playerName) - Desactiva barrera para un jugador")

-- Comandos globales de debug
_G.ResetBarrier = function()
	print("🔄 Reiniciando barreras...")
	-- Limpiar tabla de jugadores que completaron
	PlayersWithCompletedTimer = {}
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CollisionGroup = "PlayersWithBarrier"
				end
			end
			print("✅ " .. player.Name .. " - Barrera ACTIVA")
		end
	end
	print("📝 Tabla de temporizadores completados limpiada")
end

_G.DisableBarrier = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if player and player.Character then
		-- Agregar a la tabla de completados
		PlayersWithCompletedTimer[player.UserId] = true
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = "PlayersWithoutBarrier"
			end
		end
		print("✅ Barrera DESACTIVADA para " .. playerName)
		print("📝 Guardado en tabla de completados")
	else
		warn("⚠️ Jugador no encontrado: " .. playerName)
	end
end

_G.CheckBarrierStatus = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if player then
		local hasCompleted = PlayersWithCompletedTimer[player.UserId]
		if hasCompleted then
			print("✅ " .. playerName .. " - Temporizador COMPLETADO (puede atravesar)")
		else
			print("⏰ " .. playerName .. " - Temporizador ACTIVO (no puede atravesar)")
		end
	else
		warn("⚠️ Jugador no encontrado: " .. playerName)
	end
end
