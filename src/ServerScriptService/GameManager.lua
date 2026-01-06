--[[
	GAME MANAGER - SERVIDOR
	Este script maneja toda la lógica del juego de adivinanza en el servidor.
	Responsabilidades:
	- Generar el número secreto
	- Gestionar la cola de turnos de jugadores
	- Validar intentos y responder
	- Manejar jugadores que entran/salen
	- Reiniciar el juego cuando alguien gana
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================================================
-- VARIABLES DEL JUEGO
-- ============================================================================

local secretNumber = 0          -- Número secreto actual
local playerQueue = {}           -- Cola de jugadores en orden de turnos
local currentTurnIndex = 1       -- Índice del jugador actual
local totalAttempts = 0          -- Contador total de intentos en la ronda actual
local gameActive = false         -- Si el juego está activo

-- Configuración
local MIN_NUMBER = 1
local MAX_NUMBER = 500
local TURN_TIMEOUT = 30          -- Segundos por turno (opcional)

-- ============================================================================
-- REMOTE EVENTS
-- ============================================================================

-- Esperar a que los RemoteEvents estén disponibles
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local submitGuessEvent = remoteFolder:WaitForChild("SubmitGuess")
local guessResultEvent = remoteFolder:WaitForChild("GuessResult")
local turnUpdateEvent = remoteFolder:WaitForChild("TurnUpdate")
local gameStateEvent = remoteFolder:WaitForChild("GameState")

-- ============================================================================
-- FUNCIONES AUXILIARES
-- ============================================================================

-- Genera un nuevo número secreto aleatorio
local function generateSecretNumber()
	math.randomseed(tick())
	return math.random(MIN_NUMBER, MAX_NUMBER)
end

-- Obtiene el jugador actual según el índice de turno
local function getCurrentPlayer()
	if #playerQueue == 0 then
		return nil
	end
	return playerQueue[currentTurnIndex]
end

-- Actualiza todos los clientes con información del turno actual
local function broadcastTurnUpdate()
	local currentPlayer = getCurrentPlayer()
	local currentPlayerName = currentPlayer and currentPlayer.Name or "Nadie"

	for _, player in ipairs(Players:GetPlayers()) do
		local isYourTurn = (player == currentPlayer)
		turnUpdateEvent:FireClient(player, currentPlayerName, isYourTurn, totalAttempts)
	end
end

-- Actualiza todos los clientes con el estado del juego
local function broadcastGameState(message)
	for _, player in ipairs(Players:GetPlayers()) do
		gameStateEvent:FireClient(player, message)
	end
end

-- Pasa al siguiente jugador en la cola
local function nextTurn()
	if #playerQueue == 0 then
		return
	end

	currentTurnIndex = currentTurnIndex + 1
	if currentTurnIndex > #playerQueue then
		currentTurnIndex = 1
	end

	broadcastTurnUpdate()
end

-- Agrega un jugador a la cola si no está ya
local function addPlayerToQueue(player)
	for _, p in ipairs(playerQueue) do
		if p == player then
			return false -- Ya está en la cola
		end
	end

	table.insert(playerQueue, player)
	return true
end

-- Remueve un jugador de la cola
local function removePlayerFromQueue(player)
	for i, p in ipairs(playerQueue) do
		if p == player then
			-- Ajustar el índice de turno si es necesario
			if i < currentTurnIndex then
				currentTurnIndex = currentTurnIndex - 1
			elseif i == currentTurnIndex and currentTurnIndex > #playerQueue - 1 then
				currentTurnIndex = 1
			end

			table.remove(playerQueue, i)
			return true
		end
	end
	return false
end

-- Reinicia el juego completo
local function resetGame()
	secretNumber = generateSecretNumber()
	totalAttempts = 0
	currentTurnIndex = 1
	gameActive = true

	print("[SERVIDOR] Nuevo número secreto: " .. secretNumber)

	broadcastGameState("¡Nuevo juego! Adivina el número entre " .. MIN_NUMBER .. " y " .. MAX_NUMBER)
	wait(0.5)
	broadcastTurnUpdate()
end

-- ============================================================================
-- MANEJO DE INTENTOS
-- ============================================================================

-- Maneja cuando un jugador envía un intento
submitGuessEvent.OnServerEvent:Connect(function(player, guessNumber)
	-- Verificar que el juego esté activo
	if not gameActive then
		guessResultEvent:FireClient(player, "El juego no está activo aún.", "neutral")
		return
	end

	-- Verificar que sea el turno del jugador
	local currentPlayer = getCurrentPlayer()
	if player ~= currentPlayer then
		guessResultEvent:FireClient(player, "¡No es tu turno!", "error")
		return
	end

	-- Validar que sea un número válido
	if type(guessNumber) ~= "number" then
		guessResultEvent:FireClient(player, "Por favor, ingresa un número válido.", "error")
		return
	end

	-- Validar que esté en el rango
	if guessNumber < MIN_NUMBER or guessNumber > MAX_NUMBER then
		guessResultEvent:FireClient(player,
			"El número debe estar entre " .. MIN_NUMBER .. " y " .. MAX_NUMBER,
			"error")
		return
	end

	-- Incrementar contador de intentos
	totalAttempts = totalAttempts + 1

	print(string.format("[SERVIDOR] %s intentó %d (Intento #%d)",
		player.Name, guessNumber, totalAttempts))

	-- Comparar con el número secreto
	if guessNumber == secretNumber then
		-- ¡GANÓ!
		local winMessage = string.format("¡%s GANÓ! El número era %d. Intentos: %d",
			player.Name, secretNumber, totalAttempts)

		guessResultEvent:FireClient(player, "¡CORRECTO! ¡Ganaste! 🎉", "win")
		broadcastGameState(winMessage)

		print("[SERVIDOR] " .. winMessage)

		-- Reiniciar después de 5 segundos
		gameActive = false
		wait(5)
		resetGame()

	elseif guessNumber < secretNumber then
		-- Número muy bajo
		guessResultEvent:FireClient(player, "Más alto ↑", "hint")
		nextTurn()

	else
		-- Número muy alto
		guessResultEvent:FireClient(player, "Más bajo ↓", "hint")
		nextTurn()
	end
end)

-- ============================================================================
-- MANEJO DE JUGADORES
-- ============================================================================

-- Cuando un jugador se une al juego
Players.PlayerAdded:Connect(function(player)
	print("[SERVIDOR] " .. player.Name .. " se unió al juego")

	-- Agregar a la cola
	addPlayerToQueue(player)

	-- Si es el primer jugador, iniciar el juego
	if #playerQueue == 1 then
		print("[SERVIDOR] Primer jugador detectado, iniciando juego...")
		wait(2)
		resetGame()
	else
		-- Enviar estado actual al nuevo jugador
		gameStateEvent:FireClient(player,
			"Te uniste al juego. Número entre " .. MIN_NUMBER .. " y " .. MAX_NUMBER)
		wait(0.5)
		broadcastTurnUpdate()
	end
end)

-- Cuando un jugador sale del juego
Players.PlayerRemoving:Connect(function(player)
	print("[SERVIDOR] " .. player.Name .. " salió del juego")

	-- Remover de la cola
	removePlayerFromQueue(player)

	-- Si no quedan jugadores, pausar el juego
	if #playerQueue == 0 then
		gameActive = false
		print("[SERVIDOR] No quedan jugadores, juego pausado")
	else
		-- Actualizar turnos
		broadcastTurnUpdate()
	end
end)

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

print("=================================================")
print("  JUEGO DE ADIVINANZA - SERVIDOR INICIADO")
print("  Rango: " .. MIN_NUMBER .. " - " .. MAX_NUMBER)
print("  Tiempo por turno: " .. TURN_TIMEOUT .. "s")
print("=================================================")

-- Agregar jugadores que ya estén en el juego
for _, player in ipairs(Players:GetPlayers()) do
	addPlayerToQueue(player)
end

-- Iniciar el juego si hay jugadores
if #playerQueue > 0 then
	wait(2)
	resetGame()
end
