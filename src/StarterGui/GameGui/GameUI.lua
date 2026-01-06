--[[
	GAME UI - CLIENTE (LocalScript)
	Este script maneja toda la interfaz de usuario del juego.

	IMPORTANTE: Este debe ser un LocalScript dentro de ScreenGui

	Responsabilidades:
	- Crear y gestionar la interfaz gráfica
	- Enviar intentos al servidor
	- Recibir y mostrar respuestas
	- Actualizar información de turnos
	- Mostrar mensajes del juego
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- REMOTE EVENTS
-- ============================================================================

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local submitGuessEvent = remoteFolder:WaitForChild("SubmitGuess")
local guessResultEvent = remoteFolder:WaitForChild("GuessResult")
local turnUpdateEvent = remoteFolder:WaitForChild("TurnUpdate")
local gameStateEvent = remoteFolder:WaitForChild("GameState")

-- ============================================================================
-- CREAR INTERFAZ DE USUARIO
-- ============================================================================

-- ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GuessingGameUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame principal contenedor
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Título del juego
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🎮 ADIVINA EL NÚMERO 🎮"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Estado del juego (mensajes generales)
local gameStateLabel = Instance.new("TextLabel")
gameStateLabel.Name = "GameState"
gameStateLabel.Size = UDim2.new(0.9, 0, 0, 50)
gameStateLabel.Position = UDim2.new(0.05, 0, 0, 75)
gameStateLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
gameStateLabel.BorderSizePixel = 0
gameStateLabel.Text = "Esperando jugadores..."
gameStateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
gameStateLabel.TextSize = 16
gameStateLabel.Font = Enum.Font.Gotham
gameStateLabel.TextWrapped = true
gameStateLabel.Parent = mainFrame

local stateCorner = Instance.new("UICorner")
stateCorner.CornerRadius = UDim.new(0, 8)
stateCorner.Parent = gameStateLabel

-- Información del turno
local turnLabel = Instance.new("TextLabel")
turnLabel.Name = "TurnInfo"
turnLabel.Size = UDim2.new(0.9, 0, 0, 40)
turnLabel.Position = UDim2.new(0.05, 0, 0, 140)
turnLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
turnLabel.BorderSizePixel = 0
turnLabel.Text = "Turno: Esperando..."
turnLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
turnLabel.TextSize = 18
turnLabel.Font = Enum.Font.GothamBold
turnLabel.Parent = mainFrame

local turnCorner = Instance.new("UICorner")
turnCorner.CornerRadius = UDim.new(0, 8)
turnCorner.Parent = turnLabel

-- Contador de intentos
local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Name = "AttemptsCounter"
attemptsLabel.Size = UDim2.new(0.9, 0, 0, 30)
attemptsLabel.Position = UDim2.new(0.05, 0, 0, 190)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Text = "Intentos: 0"
attemptsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
attemptsLabel.TextSize = 14
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.Parent = mainFrame

-- TextBox para ingresar el número
local guessBox = Instance.new("TextBox")
guessBox.Name = "GuessInput"
guessBox.Size = UDim2.new(0.9, 0, 0, 50)
guessBox.Position = UDim2.new(0.05, 0, 0, 235)
guessBox.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
guessBox.BorderSizePixel = 0
guessBox.PlaceholderText = "Escribe un número (1-500)"
guessBox.Text = ""
guessBox.TextColor3 = Color3.fromRGB(255, 255, 255)
guessBox.TextSize = 20
guessBox.Font = Enum.Font.GothamBold
guessBox.ClearTextOnFocus = false
guessBox.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = guessBox

-- Botón de enviar
local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(0.9, 0, 0, 50)
submitButton.Position = UDim2.new(0.05, 0, 0, 300)
submitButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
submitButton.BorderSizePixel = 0
submitButton.Text = "ENVIAR"
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.TextSize = 20
submitButton.Font = Enum.Font.GothamBold
submitButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = submitButton

-- Label de resultado (respuesta del servidor)
local resultLabel = Instance.new("TextLabel")
resultLabel.Name = "Result"
resultLabel.Size = UDim2.new(0.9, 0, 0, 80)
resultLabel.Position = UDim2.new(0.05, 0, 0, 365)
resultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
resultLabel.BorderSizePixel = 0
resultLabel.Text = ""
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultLabel.TextSize = 24
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextWrapped = true
resultLabel.Parent = mainFrame

local resultCorner = Instance.new("UICorner")
resultCorner.CornerRadius = UDim.new(0, 8)
resultCorner.Parent = resultLabel

-- Créditos/Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(0.9, 0, 0, 30)
infoLabel.Position = UDim2.new(0.05, 0, 0, 460)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "¡Buena suerte! 🍀"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = mainFrame

-- ============================================================================
-- VARIABLES DEL CLIENTE
-- ============================================================================

local isMyTurn = false
local canSubmit = true  -- Control de spam

-- ============================================================================
-- FUNCIONES DE UI
-- ============================================================================

-- Actualiza el color del botón según si es tu turno
local function updateButtonState()
	if isMyTurn then
		submitButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
		submitButton.Text = "ENVIAR"
		guessBox.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	else
		submitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
		submitButton.Text = "ESPERA TU TURNO"
		guessBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	end
end

-- Muestra un mensaje de resultado con animación
local function showResult(message, resultType)
	resultLabel.Text = message

	-- Colores según el tipo de resultado
	if resultType == "win" then
		resultLabel.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
	elseif resultType == "error" then
		resultLabel.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
	elseif resultType == "hint" then
		resultLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
	else
		resultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	end

	-- Animación simple de escala
	resultLabel.Size = UDim2.new(0.9, 0, 0, 75)
	wait(0.1)
	resultLabel.Size = UDim2.new(0.9, 0, 0, 80)
end

-- ============================================================================
-- MANEJO DE EVENTOS DEL SERVIDOR
-- ============================================================================

-- Recibir resultado del intento
guessResultEvent.OnClientEvent:Connect(function(message, resultType)
	showResult(message, resultType)
	canSubmit = true
end)

-- Recibir actualización de turno
turnUpdateEvent.OnClientEvent:Connect(function(currentPlayerName, yourTurn, attempts)
	isMyTurn = yourTurn

	if yourTurn then
		turnLabel.Text = "🎯 ¡TU TURNO!"
		turnLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		turnLabel.Text = "Turno: " .. currentPlayerName
		turnLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
	end

	attemptsLabel.Text = "Intentos: " .. attempts
	updateButtonState()
end)

-- Recibir estado del juego
gameStateEvent.OnClientEvent:Connect(function(message)
	gameStateLabel.Text = message

	-- Limpiar resultado cuando empieza nueva ronda
	if string.find(message, "Nuevo juego") then
		resultLabel.Text = ""
		resultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		guessBox.Text = ""
	end
end)

-- ============================================================================
-- MANEJO DE ENTRADA DEL USUARIO
-- ============================================================================

-- Función para enviar el intento
local function submitGuess()
	-- Verificar que sea tu turno
	if not isMyTurn then
		showResult("¡No es tu turno!", "error")
		return
	end

	-- Prevenir spam de clics
	if not canSubmit then
		return
	end

	-- Obtener el número ingresado
	local inputText = guessBox.Text
	local guessNumber = tonumber(inputText)

	-- Validar que sea un número
	if not guessNumber then
		showResult("Por favor ingresa un número válido", "error")
		return
	end

	-- Enviar al servidor
	canSubmit = false
	submitGuessEvent:FireServer(guessNumber)

	-- Limpiar el campo
	guessBox.Text = ""
end

-- Click en el botón
submitButton.MouseButton1Click:Connect(submitGuess)

-- Enter en el TextBox
guessBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitGuess()
	end
end)

-- Efecto hover en el botón
submitButton.MouseEnter:Connect(function()
	if isMyTurn then
		submitButton.BackgroundColor3 = Color3.fromRGB(90, 200, 90)
	end
end)

submitButton.MouseLeave:Connect(function()
	if isMyTurn then
		submitButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
	end
end)

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

print("✓ Game UI cargada correctamente para " .. player.Name)
updateButtonState()
