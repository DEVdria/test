--[[
	GLOBAL BOOST BUTTON - LocalScript
	Maneja la GUI del boost global de XP del servidor.

	ESTRUCTURA DE GUI ESPERADA:
	ScreenGui
	└── GlobalBoostFrame (Frame)
	    ├── BoostButton (TextButton)
	    │   ├── MultiplierLabel (TextLabel) - muestra "x2", "x4", etc
	    │   └── PriceLabel (TextLabel) - muestra solo el precio
	    ├── TimerLabel (TextLabel) - Muestra tiempo restante
	    └── StatusLabel (TextLabel) - Muestra estado actual (opcional)

	PERSONALIZA LOS NOMBRES SEGÚN TU GUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ========================================
-- REFERENCIAS A LA GUI
-- ========================================
-- IMPORTANTE: Ajusta estas rutas según tu estructura de GUI
local screenGui = script.Parent  -- Asume que el script está en el ScreenGui
local globalBoostFrame = screenGui:WaitForChild("GlobalBoostFrame")

local boostButton = globalBoostFrame:WaitForChild("BoostButton")  -- TextButton
local multiplierLabel = boostButton:WaitForChild("MultiplierLabel")  -- TextLabel dentro del botón
local priceLabel = boostButton:WaitForChild("PriceLabel")            -- TextLabel dentro del botón

local timerLabel = globalBoostFrame:WaitForChild("TimerLabel")    -- TextLabel
local statusLabel = globalBoostFrame:FindFirstChild("StatusLabel") -- TextLabel (opcional)

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GlobalBoostStateChangedEvent = RemotesFolder:WaitForChild("GlobalBoostStateChanged")
local RequestBoostStateFunction = RemotesFolder:WaitForChild("RequestBoostState")
local PurchaseGlobalBoostEvent = RemotesFolder:WaitForChild("PurchaseGlobalBoost")

-- ========================================
-- ESTADO LOCAL
-- ========================================
local currentState = {
	ActiveBoostID = nil,
	Multiplier = 1.0,
	TimeRemaining = 0,
	PurchasedBy = nil,
	AvailableBoost = nil,
}

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Formatea segundos a formato MM:SS
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d", minutes, secs)
end

-- Actualiza la GUI según el estado actual
local function updateGUI()
	local activeBoost = currentState.ActiveBoostID
	local availableBoost = currentState.AvailableBoost

	-- ========================================
	-- CASO 1: No hay boost activo
	-- ========================================
	if not activeBoost then
		timerLabel.Visible = false

		if availableBoost then
			-- Mostrar botón de compra del boost 1 (x2)
			boostButton.Visible = true

			-- Actualizar labels dentro del botón
			multiplierLabel.Text = availableBoost.Name  -- "x2 XP SERVER"
			priceLabel.Text = tostring(availableBoost.Price)  -- "49"

			if statusLabel then
				statusLabel.Visible = true
				statusLabel.Text = "Sin boost activo"
			end
		else
			-- No debería pasar, pero por si acaso
			boostButton.Visible = false
			timerLabel.Visible = false
			if statusLabel then
				statusLabel.Visible = false
			end
		end

		return
	end

	-- ========================================
	-- CASO 2: Boost x2 activo
	-- ========================================
	if activeBoost == 1 then
		-- Mostrar temporizador
		timerLabel.Visible = true
		timerLabel.Text = string.format("⏰ %s | x%.1f XP",
			formatTime(currentState.TimeRemaining),
			currentState.Multiplier
		)

		-- Mostrar botón de UPGRADE si está disponible
		if availableBoost and availableBoost.IsUpgrade then
			boostButton.Visible = true

			-- Actualizar labels dentro del botón para el upgrade
			multiplierLabel.Text = string.format("🚀 %s", availableBoost.Name)  -- "🚀 x4 XP SERVER"
			priceLabel.Text = tostring(availableBoost.Price)  -- "129"
		else
			boostButton.Visible = false
		end

		if statusLabel then
			statusLabel.Visible = true
			statusLabel.Text = string.format("Boost activo por: %s", currentState.PurchasedBy or "Alguien")
		end

		return
	end

	-- ========================================
	-- CASO 3: Boost x4 activo (máximo nivel)
	-- ========================================
	if activeBoost == 2 then
		-- Mostrar temporizador
		timerLabel.Visible = true
		timerLabel.Text = string.format("⏰ %s | x%.1f XP",
			formatTime(currentState.TimeRemaining),
			currentState.Multiplier
		)

		-- No hay más upgrades disponibles
		boostButton.Visible = false

		if statusLabel then
			statusLabel.Visible = true
			statusLabel.Text = string.format("🔥 Boost máximo activo por: %s", currentState.PurchasedBy or "Alguien")
		end

		return
	end
end

-- ========================================
-- MANEJO DEL BOTÓN DE COMPRA
-- ========================================
boostButton.MouseButton1Click:Connect(function()
	local availableBoost = currentState.AvailableBoost

	if not availableBoost then
		warn("[GlobalBoostButton] ⚠️ No hay boost disponible para comprar")
		return
	end

	print(string.format("[GlobalBoostButton] 🛒 Solicitando compra de %s (ID: %d)", availableBoost.Name, availableBoost.ID))

	-- Solicitar compra al servidor
	PurchaseGlobalBoostEvent:FireServer(availableBoost.ID)
end)

-- ========================================
-- RECIBIR ACTUALIZACIONES DEL SERVIDOR
-- ========================================
GlobalBoostStateChangedEvent.OnClientEvent:Connect(function(stateData)
	print(string.format("[GlobalBoostButton] 📥 Estado recibido: Boost=%s, Mult=x%.1f, Tiempo=%ds",
		tostring(stateData.ActiveBoostID or "NINGUNO"),
		stateData.Multiplier,
		stateData.TimeRemaining
	))

	-- Actualizar estado local
	currentState.ActiveBoostID = stateData.ActiveBoostID
	currentState.Multiplier = stateData.Multiplier
	currentState.TimeRemaining = stateData.TimeRemaining
	currentState.PurchasedBy = stateData.PurchasedBy
	currentState.AvailableBoost = stateData.AvailableBoost

	-- Actualizar GUI
	updateGUI()
end)

-- ========================================
-- ACTUALIZACIÓN AUTOMÁTICA DEL TEMPORIZADOR
-- ========================================
-- Actualiza el temporizador cada segundo localmente (sin esperar al servidor)
task.spawn(function()
	while true do
		task.wait(1)

		if currentState.ActiveBoostID and currentState.TimeRemaining > 0 then
			currentState.TimeRemaining = math.max(0, currentState.TimeRemaining - 1)
			updateGUI()
		end
	end
end)

-- ========================================
-- INICIALIZACIÓN
-- ========================================
-- Solicitar estado inicial al servidor
task.spawn(function()
	local success, stateData = pcall(function()
		return RequestBoostStateFunction:InvokeServer()
	end)

	if success and stateData then
		print("[GlobalBoostButton] ✅ Estado inicial recibido del servidor")

		currentState.ActiveBoostID = stateData.ActiveBoostID
		currentState.Multiplier = stateData.Multiplier
		currentState.TimeRemaining = stateData.TimeRemaining
		currentState.PurchasedBy = stateData.PurchasedBy
		currentState.AvailableBoost = stateData.AvailableBoost

		updateGUI()
	else
		warn("[GlobalBoostButton] ❌ Error al solicitar estado inicial:", stateData)
	end
end)

print("[GlobalBoostButton] ✅ LocalScript inicializado")
