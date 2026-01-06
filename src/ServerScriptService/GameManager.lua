--[[
	GAME MANAGER - SERVIDOR CON FILA FÍSICA
	Este script maneja toda la lógica del juego de adivinanza en el servidor.
	Responsabilidades:
	- Generar el número secreto
	- Gestionar la cola de turnos de jugadores
	- Manejar la fila física en el mapa (LinePositions)
	- Teletransportar jugadores con animaciones suaves
	- Validar intentos y responder
	- Manejar jugadores que entran/salen
	- Reiniciar el juego cuando alguien gana
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ============================================================================
-- VARIABLES DEL JUEGO
-- ============================================================================

local secretNumber = 0          -- Número secreto actual
local playerQueue = {}           -- Cola de jugadores en orden de turnos
local totalAttempts = 0          -- Contador total de intentos en la ronda actual
local gameActive = false         -- Si el juego está activo

-- Configuración
local MIN_NUMBER = 1
local MAX_NUMBER = 500
local TURN_TIMEOUT = 30          -- Segundos por turno (opcional)

-- Configuración de la fila física
local LINE_POSITIONS_FOLDER_NAME = "LinePositions"
local TWEEN_TIME = 0.8           -- Tiempo de animación del movimiento (segundos)
local TWEEN_STYLE = Enum.EasingStyle.Quad
local TWEEN_DIRECTION = Enum.EasingDirection.InOut

-- Referencias
local linePositionsFolder = Workspace:WaitForChild(LINE_POSITIONS_FOLDER_NAME)
local linePositions = {}         -- Tabla ordenada de Parts de posiciones

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

-- Obtiene el jugador actual según el índice de turno (siempre es el primero)
local function getCurrentPlayer()
	if #playerQueue == 0 then
		return nil
	end
	return playerQueue[1]  -- El primero siempre tiene el turno
end

-- ============================================================================
-- SISTEMA DE POSICIONES FÍSICAS
-- ============================================================================

-- Inicializa y ordena las posiciones de la fila
local function initializeLinePositions()
	linePositions = {}

	-- Obtener todas las Parts de la carpeta
	local parts = linePositionsFolder:GetChildren()

	-- Filtrar solo las BaseParts y ordenarlas por nombre
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			table.insert(linePositions, part)
		end
	end

	-- Ordenar por nombre (Part1, Part2, Part3, etc.)
	table.sort(linePositions, function(a, b)
		-- Extraer el número del nombre
		local numA = tonumber(string.match(a.Name, "%d+")) or 0
		local numB = tonumber(string.match(b.Name, "%d+")) or 0
		return numA < numB
	end)

	print(string.format("[FILA] %d posiciones encontradas", #linePositions))
	for i, part in ipairs(linePositions) do
		print(string.format("  Posición %d: %s", i, part.Name))
	end
end

-- Teletransporta a un jugador a una posición específica con animación
local function teleportPlayerToPosition(player, positionIndex)
	if not linePositions[positionIndex] then
		warn(string.format("[FILA] Posición %d no existe", positionIndex))
		return
	end

	local character = player.Character
	if not character then
		warn(string.format("[FILA] %s no tiene personaje", player.Name))
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		warn(string.format("[FILA] %s no tiene HumanoidRootPart", player.Name))
		return
	end

	local targetPosition = linePositions[positionIndex].Position + Vector3.new(0, 3, 0)

	-- Crear Tween para movimiento suave
	local tweenInfo = TweenInfo.new(
		TWEEN_TIME,
		TWEEN_STYLE,
		TWEEN_DIRECTION
	)

	-- Usar CFrame para mantener la rotación
	local goal = {CFrame = CFrame.new(targetPosition) * CFrame.Angles(0, math.rad(180), 0)}
	local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)

	tween:Play()

	print(string.format("[FILA] %s → Posición %d (%s)",
		player.Name, positionIndex, linePositions[positionIndex].Name))
end

-- Actualiza las posiciones físicas de todos los jugadores en la fila
local function updatePhysicalLine()
	for i, player in ipairs(playerQueue) do
		-- Verificar que el jugador sigue conectado
		if Players:FindFirstChild(player.Name) then
			teleportPlayerToPosition(player, i)
		end
	end
end

-- Crea un indicador visual sobre el jugador que tiene el turno
local function createTurnIndicator(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Remover indicador anterior si existe
	local oldIndicator = head:FindFirstChild("TurnIndicator")
	if oldIndicator then
		oldIndicator:Destroy()
	end

	-- Crear nuevo indicador (BillboardGui con flecha o texto)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TurnIndicator"
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "▼ TU TURNO ▼"
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboard
end

-- Remueve el indicador de turno de un jugador
local function removeTurnIndicator(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local indicator = head:FindFirstChild("TurnIndicator")
	if indicator then
		indicator:Destroy()
	end
end

-- Actualiza los indicadores visuales de todos los jugadores
local function updateTurnIndicators()
	-- Remover todos los indicadores primero
	for _, player in ipairs(playerQueue) do
		removeTurnIndicator(player)
	end

	-- Crear indicador para el jugador actual
	local currentPlayer = getCurrentPlayer()
	if currentPlayer then
		createTurnIndicator(currentPlayer)
	end
end

-- Actualiza todos los clientes con información del turno actual
local function broadcastTurnUpdate()
	local currentPlayer = getCurrentPlayer()
	local currentPlayerName = currentPlayer and currentPlayer.Name or "Nadie"

	for _, player in ipairs(Players:GetPlayers()) do
		local isYourTurn = (player == currentPlayer)
		turnUpdateEvent:FireClient(player, currentPlayerName, isYourTurn, totalAttempts)
	end

	-- Actualizar indicadores visuales
	updateTurnIndicators()
end

-- Actualiza todos los clientes con el estado del juego
local function broadcastGameState(message)
	for _, player in ipairs(Players:GetPlayers()) do
		gameStateEvent:FireClient(player, message)
	end
end

-- Avanza la fila: el jugador actual va al final, todos avanzan una posición
local function moveLineForward()
	if #playerQueue == 0 then
		return
	end

	-- Tomar el primer jugador (el que acaba de jugar)
	local playerWhoPlayed = table.remove(playerQueue, 1)

	-- Ponerlo al final de la fila
	table.insert(playerQueue, playerWhoPlayed)

	print(string.format("[FILA] %s va al final. Nuevo turno: %s",
		playerWhoPlayed.Name,
		playerQueue[1] and playerQueue[1].Name or "Nadie"))

	-- Actualizar posiciones físicas de todos
	updatePhysicalLine()

	-- Esperar a que termine la animación antes de actualizar UI
	wait(TWEEN_TIME + 0.2)

	-- Actualizar información de turno en clientes
	broadcastTurnUpdate()
end

-- Agrega un jugador a la cola si no está ya
local function addPlayerToQueue(player)
	for _, p in ipairs(playerQueue) do
		if p == player then
			return false -- Ya está en la cola
		end
	end

	-- Agregar al final de la fila
	table.insert(playerQueue, player)

	print(string.format("[FILA] %s agregado a la fila (Posición %d)", player.Name, #playerQueue))

	-- Esperar a que el personaje esté listo
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart")

	-- Posicionar físicamente al jugador
	local positionIndex = #playerQueue
	if positionIndex <= #linePositions then
		teleportPlayerToPosition(player, positionIndex)
	else
		warn(string.format("[FILA] No hay suficientes posiciones para %d jugadores", #playerQueue))
	end

	return true
end

-- Remueve un jugador de la cola
local function removePlayerFromQueue(player)
	for i, p in ipairs(playerQueue) do
		if p == player then
			-- Remover indicador visual
			removeTurnIndicator(player)

			-- Remover de la tabla
			table.remove(playerQueue, i)

			print(string.format("[FILA] %s removido de la fila", player.Name))

			-- Actualizar posiciones físicas de todos los jugadores restantes
			if #playerQueue > 0 then
				updatePhysicalLine()
			end

			return true
		end
	end
	return false
end

-- Reinicia el juego completo
local function resetGame()
	secretNumber = generateSecretNumber()
	totalAttempts = 0
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
		moveLineForward()

	else
		-- Número muy alto
		guessResultEvent:FireClient(player, "Más bajo ↓", "hint")
		moveLineForward()
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
print("  Sistema de fila física: ACTIVADO")
print("=================================================")

-- Inicializar las posiciones de la fila
initializeLinePositions()

-- Agregar jugadores que ya estén en el juego
for _, player in ipairs(Players:GetPlayers()) do
	-- Esperar a que el personaje cargue
	spawn(function()
		if player.Character then
			addPlayerToQueue(player)
		else
			player.CharacterAdded:Wait()
			addPlayerToQueue(player)
		end
	end)
end

-- Iniciar el juego si hay jugadores (después de un pequeño delay)
wait(3)
if #playerQueue > 0 then
	resetGame()
end
