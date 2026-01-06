--[[
	GAME UI LOGIC - CLIENTE (LocalScript)
	Este script contiene SOLO LA LÓGICA del juego, sin crear UI.

	IMPORTANTE: TÚ diseñas la UI. Este script solo maneja la comunicación con el servidor.

	ESTRUCTURA REQUERIDA DE TU UI (opcional, puedes adaptar):
	- ScreenGui llamado "GuessingGameUI"
	  └── Tus frames y elementos personalizados
	      ├── TurnLabel (TextLabel) - para mostrar de quién es el turno
	      ├── GameStateLabel (TextLabel) - para mensajes del juego
	      ├── AttemptsLabel (TextLabel) - para contador de intentos
	      └── ResultLabel (TextLabel) - para mostrar resultado de intentos

	Cambia los nombres de las variables abajo según tu diseño.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- CONFIGURACIÓN: CAMBIA ESTOS NOMBRES SEGÚN TU DISEÑO UI
-- ============================================================================

local SCREEN_GUI_NAME = "GuessingGameUI"
local TURN_LABEL_NAME = "TurnLabel"           -- Label que muestra el turno
local GAME_STATE_LABEL_NAME = "GameStateLabel" -- Label de estado del juego
local ATTEMPTS_LABEL_NAME = "AttemptsLabel"   -- Label del contador
local RESULT_LABEL_NAME = "ResultLabel"       -- Label de resultados

-- ============================================================================
-- REMOTE EVENTS
-- ============================================================================

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local submitGuessEvent = remoteFolder:WaitForChild("SubmitGuess")
local guessResultEvent = remoteFolder:WaitForChild("GuessResult")
local turnUpdateEvent = remoteFolder:WaitForChild("TurnUpdate")
local gameStateEvent = remoteFolder:WaitForChild("GameState")

-- ============================================================================
-- VARIABLES
-- ============================================================================

local isMyTurn = false
local canSubmit = true

-- Referencias UI (se llenarán si existen)
local screenGui = nil
local turnLabel = nil
local gameStateLabel = nil
local attemptsLabel = nil
local resultLabel = nil

-- ============================================================================
-- FUNCIONES DE ACTUALIZACIÓN DE UI
-- ============================================================================

-- Actualiza la información del turno
local function updateTurnDisplay(playerName, yourTurn)
	if turnLabel then
		if yourTurn then
			turnLabel.Text = "🎯 ¡TU TURNO!"
		else
			turnLabel.Text = "Turno: " .. playerName
		end
	end

	print(string.format("[UI] Turno actualizado: %s | Es tu turno: %s", playerName, tostring(yourTurn)))
end

-- Actualiza el estado del juego
local function updateGameState(message)
	if gameStateLabel then
		gameStateLabel.Text = message
	end

	print("[UI] Estado del juego: " .. message)
end

-- Actualiza el contador de intentos
local function updateAttempts(attempts)
	if attemptsLabel then
		attemptsLabel.Text = "Intentos: " .. attempts
	end
end

-- Muestra un resultado
local function showResult(message, resultType)
	if resultLabel then
		resultLabel.Text = message

		-- Opcional: cambiar color según tipo (si tu UI lo permite)
		-- Puedes comentar esto si no quieres que el script modifique colores
		if resultLabel:IsA("TextLabel") then
			if resultType == "win" then
				resultLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			elseif resultType == "error" then
				resultLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			elseif resultType == "hint" then
				resultLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
			else
				resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end

	print(string.format("[UI] Resultado: %s (Tipo: %s)", message, resultType))
end

-- Limpia el resultado cuando empieza nueva ronda
local function clearResult()
	if resultLabel then
		resultLabel.Text = ""
	end
end

-- ============================================================================
-- FUNCIONES PÚBLICAS (para llamar desde otros scripts)
-- ============================================================================

-- Función para enviar un intento (llamar desde tu UI o NumpadController)
local function submitGuess(guessNumber)
	-- Verificar que sea tu turno
	if not isMyTurn then
		showResult("¡No es tu turno!", "error")
		return false
	end

	-- Prevenir spam
	if not canSubmit then
		return false
	end

	-- Validar que sea un número
	if type(guessNumber) ~= "number" then
		showResult("Número inválido", "error")
		return false
	end

	-- Enviar al servidor
	canSubmit = false
	submitGuessEvent:FireServer(guessNumber)

	print("[UI] Enviando intento: " .. guessNumber)
	return true
end

-- ============================================================================
-- EVENTOS DEL SERVIDOR
-- ============================================================================

-- Recibir resultado del intento
guessResultEvent.OnClientEvent:Connect(function(message, resultType)
	showResult(message, resultType)
	canSubmit = true
end)

-- Recibir actualización de turno
turnUpdateEvent.OnClientEvent:Connect(function(currentPlayerName, yourTurn, attempts)
	isMyTurn = yourTurn

	updateTurnDisplay(currentPlayerName, yourTurn)
	updateAttempts(attempts)

	-- Si tienes NumpadController, actualizar su estado
	local numpadController = script.Parent:FindFirstChild("NumpadController")
	if numpadController and numpadController:IsA("ModuleScript") then
		local success, module = pcall(require, numpadController)
		if success and module.UpdateTurnState then
			module.UpdateTurnState(yourTurn)
		end
	end
end)

-- Recibir estado del juego
gameStateEvent.OnClientEvent:Connect(function(message)
	updateGameState(message)

	-- Limpiar resultado cuando empieza nueva ronda
	if string.find(message, "Nuevo juego") then
		clearResult()
	end
end)

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

-- Intentar obtener referencias a elementos UI (si existen)
local success, screenGuiObj = pcall(function()
	return playerGui:WaitForChild(SCREEN_GUI_NAME, 5)
end)

if success and screenGuiObj then
	screenGui = screenGuiObj

	-- Obtener referencias a labels (si existen)
	turnLabel = screenGui:FindFirstChild(TURN_LABEL_NAME, true)
	gameStateLabel = screenGui:FindFirstChild(GAME_STATE_LABEL_NAME, true)
	attemptsLabel = screenGui:FindFirstChild(ATTEMPTS_LABEL_NAME, true)
	resultLabel = screenGui:FindFirstChild(RESULT_LABEL_NAME, true)

	if turnLabel then print("✓ TurnLabel encontrado") end
	if gameStateLabel then print("✓ GameStateLabel encontrado") end
	if attemptsLabel then print("✓ AttemptsLabel encontrado") end
	if resultLabel then print("✓ ResultLabel encontrado") end
else
	warn("[UI] No se encontró el ScreenGui: " .. SCREEN_GUI_NAME)
	warn("[UI] Diseña tu UI y asegúrate de que el nombre coincida")
end

print("✓ Game UI Logic inicializado")

-- ============================================================================
-- EXPORTAR FUNCIONES (para usar desde otros scripts)
-- ============================================================================

local module = {}
module.SubmitGuess = submitGuess
module.IsMyTurn = function() return isMyTurn end
module.CanSubmit = function() return canSubmit end

return module

--[[
	INSTRUCCIONES DE USO:

	1. Diseña tu UI como quieras en Roblox Studio
	2. Asegúrate de que tenga un ScreenGui llamado "GuessingGameUI"
	3. Dentro, crea los labels que necesites (TurnLabel, GameStateLabel, etc.)
	4. Actualiza los nombres en la sección de CONFIGURACIÓN arriba
	5. Coloca este LocalScript dentro del ScreenGui

	EJEMPLO para enviar un intento desde un botón:

	-- En el script de tu botón:
	local gameUILogic = require(script.Parent.GameUILogic)

	miBoton.MouseButton1Click:Connect(function()
	    local numero = tonumber(miTextBox.Text)
	    gameUILogic.SubmitGuess(numero)
	end)

	INTEGRACIÓN CON NUMPAD:
	El NumpadController se conectará automáticamente si existe como ModuleScript.
]]
