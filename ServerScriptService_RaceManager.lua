-- ServerScriptService > RaceManager (Script)
-- Gestiona el sistema de carreras automáticas

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local RaceConfig = require(Modules:WaitForChild("RaceConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RaceWarningEvent = RemoteEvents:WaitForChild("RaceWarning")
local RaceStartEvent = RemoteEvents:WaitForChild("RaceStart")
local JoinRaceEvent = RemoteEvents:WaitForChild("JoinRace")
local RaceEndEvent = RemoteEvents:WaitForChild("RaceEnd")
local RaceCountdownEvent = RemoteEvents:WaitForChild("RaceCountdown")

-- Esperar DataManager
repeat task.wait(0.1) until _G.DataManager
local DataManager = _G.DataManager

-- ==================== VARIABLES ====================

local raceActive = false
local participants = {}  -- {player, finishTime, finishPosition, distance}
local raceStartTime = 0

-- Referencias a objetos del mundo
local waitZone = nil
local raceBarrier = nil
local raceFinish = nil

-- ==================== FUNCIONES DE UTILIDAD ====================

-- Encuentra los objetos necesarios en Workspace
local function findRaceObjects()
	waitZone = Workspace:FindFirstChild(RaceConfig.WAIT_ZONE_NAME)
	raceBarrier = Workspace:FindFirstChild(RaceConfig.BARRIER_NAME)
	raceFinish = Workspace:FindFirstChild(RaceConfig.FINISH_NAME)

	if not waitZone then
		warn("[RaceManager] ⚠️ No se encontró WaitZone en Workspace")
		return false
	end

	if not raceBarrier then
		warn("[RaceManager] ⚠️ No se encontró RaceBarrier en Workspace")
		return false
	end

	if not raceFinish then
		warn("[RaceManager] ⚠️ No se encontró RaceFinish en Workspace")
		return false
	end

	print("[RaceManager] ✅ Objetos de carrera encontrados")
	return true
end

-- Teletransporta un jugador a la zona de espera
local function teleportToWaitZone(player)
	local character = player.Character
	if not character then return false end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end

	humanoidRootPart.CFrame = waitZone.CFrame + Vector3.new(0, 3, 0)
	return true
end

-- Teletransporta un jugador al spawn
local function teleportToSpawn(player)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	humanoidRootPart.CFrame = CFrame.new(RaceConfig.SPAWN_POSITION)
end

-- Calcula la distancia de un jugador a la meta
local function getDistanceToFinish(player)
	local character = player.Character
	if not character then return 0 end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return 0 end

	return (raceFinish.Position - humanoidRootPart.Position).Magnitude
end

-- ==================== GESTIÓN DE PARTICIPANTES ====================

-- Añade un jugador a la carrera
local function addParticipant(player)
	if raceActive then
		return false, "La carrera ya ha comenzado"
	end

	-- Verificar si ya está en la carrera
	for _, p in ipairs(participants) do
		if p.player == player then
			return false, "Ya estás participando"
		end
	end

	-- Teletransportar a zona de espera
	if not teleportToWaitZone(player) then
		return false, "Error al teletransportar"
	end

	-- Añadir a participantes
	table.insert(participants, {
		player = player,
		finishTime = nil,
		finishPosition = nil,
		distance = 0
	})

	print(string.format("[RaceManager] ➕ %s se unió a la carrera (%d participantes)", player.Name, #participants))
	return true
end

-- Marca a un jugador como que terminó la carrera
local function markPlayerFinished(player)
	for _, p in ipairs(participants) do
		if p.player == player and not p.finishTime then
			local finishTime = tick() - raceStartTime
			p.finishTime = finishTime
			p.finishPosition = raceFinish.Position
			print(string.format("[RaceManager] 🏁 %s terminó la carrera en %.2f segundos", player.Name, finishTime))
			return true
		end
	end
	return false
end

-- ==================== CICLO DE CARRERA ====================

-- Fase 1: Aviso de carrera (10 segundos antes)
local function announceRace()
	print("[RaceManager] 📢 Anunciando carrera...")

	for i = RaceConfig.WARNING_TIME, 1, -1 do
		local message = string.format(RaceConfig.Messages.Warning, i)
		RaceWarningEvent:FireAllClients(message, i)
		task.wait(1)
	end

	print("[RaceManager] ✅ Aviso completado")
end

-- Fase 2: Inicio de inscripción
local function startRegistration()
	print("[RaceManager] 📝 Inscripción iniciada")

	participants = {}  -- Limpiar participantes anteriores

	-- Notificar a todos que pueden unirse
	RaceStartEvent:FireAllClients()

	-- Esperar el tiempo de decisión (para que vean los botones y decidan)
	print(string.format("[RaceManager] ⏰ Esperando %d segundos para decisiones...", RaceConfig.DECISION_TIME))
	task.wait(RaceConfig.DECISION_TIME)
end

-- Fase 3: Zona de espera y cuenta regresiva
local function waitingPhase()
	print(string.format("[RaceManager] ⏳ Fase de espera iniciada (%d participantes)", #participants))

	-- Verificar que hay al menos 1 participante (permite carreras con 1+ jugadores)
	if #participants == 0 then
		print("[RaceManager] ❌ No hay participantes. Cancelando carrera.")
		RaceEndEvent:FireAllClients({Cancelled = true, Reason = RaceConfig.Messages.NoParticipants})
		return false
	end

	-- Activar barrera
	raceBarrier.CanCollide = true
	raceBarrier.Transparency = 0.5  -- Hacerla visible durante la cuenta regresiva

	-- Cuenta regresiva
	for i = RaceConfig.WAIT_TIME, 1, -1 do
		local message = string.format(RaceConfig.Messages.CountingDown, i)
		RaceCountdownEvent:FireAllClients(message, i)
		task.wait(1)
	end

	-- Desactivar barrera
	raceBarrier.CanCollide = false
	raceBarrier.Transparency = 1  -- Hacerla invisible

	print("[RaceManager] ✅ Barrera desactivada. ¡Carrera iniciada!")
	RaceCountdownEvent:FireAllClients(RaceConfig.Messages.RaceBegin, 0)

	return true
end

-- Otorga premio a un jugador
local function givePrize(player, reward, place)
	if not player or not player.Parent then return end

	-- Dar XP (usando MoneyManager)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local currentEXP = leaderstats:FindFirstChild("CurrentEXP")
		if currentEXP then
			DataManager.AddEXP(player, reward.XP)
			print(string.format("[RaceManager] 💎 %s recibió %d XP", player.Name, reward.XP))
		end

		-- Dar Money
		DataManager.AddMoney(player, reward.Money)
		print(string.format("[RaceManager] 💰 %s recibió %d Money", player.Name, reward.Money))

		-- Dar Win (solo al primero)
		if reward.AddWin then
			local wins = leaderstats:FindFirstChild("Wins")
			if wins then
				wins.Value = wins.Value + 1
				-- Actualizar en DataManager
				DataManager.SetValue(player, "Wins", wins.Value)
				print(string.format("[RaceManager] 🏆 %s recibió 1 Win (Total: %d)", player.Name, wins.Value))
			end
		end
	end
end

-- Fase 4: Carrera activa
local function runRace()
	print("[RaceManager] 🏃 Carrera en progreso...")

	raceActive = true
	raceStartTime = tick()

	-- Conectar detección de meta
	local finishConnection = raceFinish.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			markPlayerFinished(player)
		end
	end)

	-- Esperar hasta que termine la carrera
	local elapsed = 0
	while elapsed < RaceConfig.MAX_RACE_TIME do
		task.wait(0.5)
		elapsed = tick() - raceStartTime

		-- Verificar si todos terminaron
		local allFinished = true
		for _, p in ipairs(participants) do
			if not p.finishTime and p.player.Parent then
				allFinished = false
				break
			end
		end

		if allFinished then
			print("[RaceManager] ✅ Todos los participantes terminaron")
			break
		end
	end

	-- Desconectar evento
	finishConnection:Disconnect()

	-- Si se acabó el tiempo, actualizar distancias
	if elapsed >= RaceConfig.MAX_RACE_TIME then
		print("[RaceManager] ⏱️ Tiempo máximo alcanzado")
		for _, p in ipairs(participants) do
			if not p.finishTime and p.player.Parent then
				p.distance = getDistanceToFinish(p.player)
			end
		end
	end

	raceActive = false
	print("[RaceManager] 🏁 Carrera terminada")
end

-- Calcula el ranking y otorga premios
local function calculateResults()
	print("[RaceManager] 📊 Calculando resultados...")

	-- Ordenar participantes
	table.sort(participants, function(a, b)
		-- Primero, los que terminaron (menor tiempo = mejor)
		if a.finishTime and b.finishTime then
			return a.finishTime < b.finishTime
		elseif a.finishTime then
			return true  -- a terminó, b no
		elseif b.finishTime then
			return false  -- b terminó, a no
		else
			-- Ninguno terminó, ordenar por distancia (menor distancia a meta = mejor)
			return a.distance < b.distance
		end
	end)

	-- Crear tabla de resultados
	local results = {
		First = nil,
		Second = nil,
		Third = nil
	}

	-- Asignar lugares y otorgar premios
	for i, p in ipairs(participants) do
		if i == 1 then
			results.First = {Name = p.player.Name, UserId = p.player.UserId}
			givePrize(p.player, RaceConfig.Rewards.First, 1)
		elseif i == 2 then
			results.Second = {Name = p.player.Name, UserId = p.player.UserId}
			givePrize(p.player, RaceConfig.Rewards.Second, 2)
		elseif i == 3 then
			results.Third = {Name = p.player.Name, UserId = p.player.UserId}
			givePrize(p.player, RaceConfig.Rewards.Third, 3)
		end

		if i <= 3 then
			print(string.format("[RaceManager] 🏆 Lugar %d: %s", i, p.player.Name))
		end
	end

	return results
end

-- Teletransporta a todos los participantes al spawn
local function teleportAllToSpawn()
	print("[RaceManager] 🚀 Teletransportando participantes al spawn...")

	for _, p in ipairs(participants) do
		if p.player and p.player.Parent then
			task.spawn(function()
				teleportToSpawn(p.player)
			end)
		end
	end
end

-- Ejecuta un ciclo completo de carrera
local function runRaceCycle()
	print("[RaceManager] ═══════════════════════════════════════")
	print("[RaceManager] 🏁 Iniciando ciclo de carrera")
	print("[RaceManager] ═══════════════════════════════════════")

	-- Fase 1: Aviso
	announceRace()

	-- Fase 2: Inicio de inscripción
	startRegistration()

	-- Fase 3: Zona de espera
	local shouldContinue = waitingPhase()
	if not shouldContinue then
		return  -- Carrera cancelada
	end

	-- Fase 4: Carrera
	runRace()

	-- Calcular resultados
	local results = calculateResults()

	-- Enviar resultados a todos los clientes
	RaceEndEvent:FireAllClients(results)

	-- Teletransportar a todos
	task.wait(5)  -- Esperar 5 segundos para que vean el podio
	teleportAllToSpawn()

	print("[RaceManager] ✅ Ciclo de carrera completado")
	print("[RaceManager] ═══════════════════════════════════════")
end

-- ==================== EVENTOS ====================

-- Manejar solicitud de unirse a carrera
JoinRaceEvent.OnServerEvent:Connect(function(player)
	local success, message = addParticipant(player)

	if success then
		JoinRaceEvent:FireClient(player, {Success = true})
	else
		JoinRaceEvent:FireClient(player, {Success = false, Message = message})
	end
end)

-- ==================== INICIALIZACIÓN ====================

task.spawn(function()
	-- Esperar a que el juego esté listo
	task.wait(5)

	-- Buscar objetos necesarios
	if not findRaceObjects() then
		warn("[RaceManager] ❌ No se pudieron encontrar los objetos necesarios. Sistema de carreras desactivado.")
		return
	end

	print("[RaceManager] ✅ Sistema de carreras inicializado")
	print(string.format("[RaceManager] ⏱️ Intervalo entre carreras: %d segundos", RaceConfig.RACE_INTERVAL))

	-- Ciclo infinito de carreras
	while true do
		task.wait(RaceConfig.RACE_INTERVAL)
		task.spawn(runRaceCycle)
	end
end)

print("[RaceManager] ✅ RaceManager cargado")
