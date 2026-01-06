--[[
	NUMPAD CONTROLLER - CLIENTE (LocalScript)
	Este script maneja la lógica del teclado numérico (0-9)

	IMPORTANTE: Este es solo el código lógico. TÚ debes diseñar la UI.

	ESTRUCTURA REQUERIDA DE TU UI:
	- ScreenGui
	  └── NumpadFrame (Frame que contiene todo el teclado)
	      ├── DisplayLabel (TextLabel para mostrar el número)
	      ├── Button0 (TextButton)
	      ├── Button1 (TextButton)
	      ├── Button2 (TextButton)
	      ├── Button3 (TextButton)
	      ├── Button4 (TextButton)
	      ├── Button5 (TextButton)
	      ├── Button6 (TextButton)
	      ├── Button7 (TextButton)
	      ├── Button8 (TextButton)
	      ├── Button9 (TextButton)
	      ├── ButtonClear (TextButton para borrar)
	      └── ButtonSubmit (TextButton para enviar)

	Puedes nombrarlos como quieras, solo actualiza las variables abajo.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- CONFIGURACIÓN: CAMBIA ESTOS NOMBRES SEGÚN TU DISEÑO
-- ============================================================================

local SCREEN_GUI_NAME = "GuessingGameUI"      -- Nombre de tu ScreenGui
local NUMPAD_FRAME_NAME = "NumpadFrame"       -- Nombre del Frame del teclado
local DISPLAY_LABEL_NAME = "DisplayLabel"     -- Label que muestra el número

-- Nombres de los botones (puedes cambiarlos según tu diseño)
local BUTTON_NAMES = {
	[0] = "Button0",
	[1] = "Button1",
	[2] = "Button2",
	[3] = "Button3",
	[4] = "Button4",
	[5] = "Button5",
	[6] = "Button6",
	[7] = "Button7",
	[8] = "Button8",
	[9] = "Button9",
}

local CLEAR_BUTTON_NAME = "ButtonClear"       -- Botón para borrar
local SUBMIT_BUTTON_NAME = "ButtonSubmit"     -- Botón para enviar

-- ============================================================================
-- REMOTE EVENTS
-- ============================================================================

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local submitGuessEvent = remoteFolder:WaitForChild("SubmitGuess")
local guessResultEvent = remoteFolder:WaitForChild("GuessResult")

-- ============================================================================
-- VARIABLES
-- ============================================================================

local currentNumber = ""          -- Número actual siendo escrito
local maxDigits = 3               -- Máximo de dígitos (500 = 3 dígitos)
local isMyTurn = false            -- Si es el turno del jugador
local canSubmit = true            -- Control de spam

-- Referencias a elementos UI (se llenarán cuando tu UI esté lista)
local screenGui = nil
local numpadFrame = nil
local displayLabel = nil
local numberButtons = {}
local clearButton = nil
local submitButton = nil

-- ============================================================================
-- FUNCIONES DE LÓGICA
-- ============================================================================

-- Actualiza el display con el número actual
local function updateDisplay()
	if displayLabel then
		if currentNumber == "" then
			displayLabel.Text = "0"
		else
			displayLabel.Text = currentNumber
		end
	end
end

-- Añade un dígito al número actual
local function addDigit(digit)
	-- Verificar que no exceda el máximo de dígitos
	if #currentNumber >= maxDigits then
		return
	end

	-- Agregar el dígito
	currentNumber = currentNumber .. tostring(digit)

	-- Actualizar display
	updateDisplay()

	print("[NUMPAD] Dígito añadido: " .. digit .. " | Número actual: " .. currentNumber)
end

-- Borra el último dígito
local function backspace()
	if #currentNumber > 0 then
		currentNumber = string.sub(currentNumber, 1, -2)
		updateDisplay()
		print("[NUMPAD] Borrado | Número actual: " .. currentNumber)
	end
end

-- Borra todo el número
local function clearAll()
	currentNumber = ""
	updateDisplay()
	print("[NUMPAD] Todo borrado")
end

-- Envía el número al servidor
local function submitNumber()
	-- Verificar que sea tu turno
	if not isMyTurn then
		warn("[NUMPAD] No es tu turno")
		return
	end

	-- Prevenir spam
	if not canSubmit then
		warn("[NUMPAD] Espera a la respuesta del servidor")
		return
	end

	-- Verificar que haya un número ingresado
	if currentNumber == "" then
		warn("[NUMPAD] No has ingresado ningún número")
		return
	end

	-- Convertir a número
	local guessNumber = tonumber(currentNumber)

	if not guessNumber then
		warn("[NUMPAD] Número inválido")
		return
	end

	-- Enviar al servidor
	print("[NUMPAD] Enviando número: " .. guessNumber)
	canSubmit = false
	submitGuessEvent:FireServer(guessNumber)

	-- Limpiar el display
	clearAll()
end

-- Actualiza el estado del teclado según si es tu turno
local function updateNumpadState(yourTurn)
	isMyTurn = yourTurn

	-- Habilitar o deshabilitar botones según el turno
	local alpha = yourTurn and 1 or 0.5

	if numpadFrame then
		-- Cambiar transparencia de todo el frame
		for _, button in pairs(numberButtons) do
			if button then
				button.BackgroundTransparency = yourTurn and 0 or 0.3
			end
		end

		if clearButton then
			clearButton.BackgroundTransparency = yourTurn and 0 or 0.3
		end

		if submitButton then
			submitButton.BackgroundTransparency = yourTurn and 0 or 0.3
		end
	end
end

-- ============================================================================
-- CONECTAR BOTONES (llamar esta función cuando tu UI esté lista)
-- ============================================================================

local function connectButtons()
	-- Conectar botones numéricos (0-9)
	for digit = 0, 9 do
		local buttonName = BUTTON_NAMES[digit]
		local button = numpadFrame:FindFirstChild(buttonName)

		if button and button:IsA("TextButton") then
			numberButtons[digit] = button

			button.MouseButton1Click:Connect(function()
				if isMyTurn then
					addDigit(digit)
				end
			end)

			print("[NUMPAD] Botón conectado: " .. buttonName)
		else
			warn("[NUMPAD] No se encontró el botón: " .. buttonName)
		end
	end

	-- Conectar botón de borrar
	clearButton = numpadFrame:FindFirstChild(CLEAR_BUTTON_NAME)
	if clearButton and clearButton:IsA("TextButton") then
		clearButton.MouseButton1Click:Connect(function()
			if isMyTurn then
				clearAll()
			end
		end)
		print("[NUMPAD] Botón Clear conectado")
	else
		warn("[NUMPAD] No se encontró el botón: " .. CLEAR_BUTTON_NAME)
	end

	-- Conectar botón de enviar
	submitButton = numpadFrame:FindFirstChild(SUBMIT_BUTTON_NAME)
	if submitButton and submitButton:IsA("TextButton") then
		submitButton.MouseButton1Click:Connect(function()
			if isMyTurn then
				submitNumber()
			end
		end)
		print("[NUMPAD] Botón Submit conectado")
	else
		warn("[NUMPAD] No se encontró el botón: " .. SUBMIT_BUTTON_NAME)
	end

	print("✓ Numpad Controller inicializado correctamente")
end

-- ============================================================================
-- EVENTOS DEL SERVIDOR
-- ============================================================================

-- Cuando el servidor responde, permitir enviar de nuevo
guessResultEvent.OnClientEvent:Connect(function(message, resultType)
	canSubmit = true
	clearAll()  -- Limpiar display después de recibir respuesta
end)

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

-- Esperar a que tu UI esté lista
screenGui = playerGui:WaitForChild(SCREEN_GUI_NAME)
numpadFrame = screenGui:WaitForChild(NUMPAD_FRAME_NAME)
displayLabel = numpadFrame:WaitForChild(DISPLAY_LABEL_NAME)

-- Inicializar display
updateDisplay()

-- Conectar todos los botones
connectButtons()

-- ============================================================================
-- FUNCIÓN PÚBLICA: Llamar desde GameUI.lua cuando el turno cambie
-- ============================================================================

-- Exponer función para que otros scripts actualicen el estado
local module = {}
module.UpdateTurnState = updateNumpadState

return module

--[[
	INSTRUCCIONES PARA USAR ESTE SCRIPT:

	1. Diseña tu UI del teclado numérico como quieras
	2. Asegúrate de que los nombres coincidan con las variables arriba
	3. Coloca este LocalScript dentro del ScreenGui
	4. Desde GameUI.lua, llama a module.UpdateTurnState(true/false) cuando cambie el turno

	EJEMPLO desde otro script:

	local numpadController = require(script.Parent.NumpadController)
	numpadController.UpdateTurnState(true)  -- Habilitar teclado
	numpadController.UpdateTurnState(false) -- Deshabilitar teclado
]]
