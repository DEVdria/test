--[[
	GLOBAL MONEY BOOST BUTTON - LocalScript
	Maneja la GUI del boost global de DINERO del servidor.

	ESTRUCTURA DE GUI ESPERADA:
	ScreenGui
	└── GlobalMoneyBoostFrame (Frame)
	    ├── MoneyBoostButton (TextButton)
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
local globalMoneyBoostFrame = screenGui:WaitForChild("GlobalMoneyBoostFrame")

local moneyBoostButton = globalMoneyBoostFrame:WaitForChild("MoneyBoostButton")  -- TextButton
local multiplierLabel = moneyBoostButton:WaitForChild("MultiplierLabel")  -- TextLabel dentro del botón
local priceLabel = moneyBoostButton:WaitForChild("PriceLabel")            -- TextLabel dentro del botón

local timerLabel = globalMoneyBoostFrame:WaitForChild("TimerLabel")    -- TextLabel
local statusLabel = globalMoneyBoostFrame:FindFirstChild("StatusLabel") -- TextLabel (opcional)

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GlobalMoneyBoostStateChangedEvent = RemotesFolder:WaitForChild("GlobalMoneyBoostStateChanged")
local RequestMoneyBoostStateFunction = RemotesFolder:WaitForChild("RequestMoneyBoostState")
local PurchaseGlobalMoneyBoostEvent = RemotesFolder:WaitForChild("PurchaseGlobalMoneyBoost")

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
			moneyBoostButton.Visible = true

			-- Actualizar labels dentro del botón
			multiplierLabel.Text = availableBoost.Name  -- "x2 MONEY SERVER"
			priceLabel.Text = tostring(availableBoost.Price)  -- "49"

			if statusLabel then
				statusLabel.Visible = true
				statusLabel.Text = "Sin boost de dinero activo"
			end
		else
			-- No debería pasar, pero por si acaso
			moneyBoostButton.Visible = false
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
		timerLabel.Text = string.format("⏰ %s | x%.1f MONEY",
			formatTime(currentState.TimeRemaining),
			currentState.Multiplier
		)

		-- Mostrar botón de UPGRADE si está disponible
		if availableBoost and availableBoost.IsUpgrade then
			moneyBoostButton.Visible = true

			-- Actualizar labels dentro del botón para el upgrade
			multiplierLabel.Text = string.format("🚀 %s", availableBoost.Name)  -- "🚀 x4 MONEY SERVER"
			priceLabel.Text = tostring(availableBoost.Price)  -- "129"
		else
			moneyBoostButton.Visible = false
		end

		if statusLabel then
			statusLabel.Visible = true
			statusLabel.Text = string.format("Boost de dinero activo por: %s", currentState.PurchasedBy or "Alguien")
		end

		return
	end

	-- ========================================
	-- CASO 3: Boost x4 activo (máximo nivel)
	-- ========================================
	if activeBoost == 2 then
		-- Mostrar temporizador
		timerLabel.Visible = true
		timerLabel.Text = string.format("⏰ %s | x%.1f MONEY",
			formatTime(currentState.TimeRemaining),
			currentState.Multiplier
		)

		-- No hay más upgrades disponibles
		moneyBoostButton.Visible = false

		if statusLabel then
			statusLabel.Visible = true
			statusLabel.Text = string.format("🔥 Boost máximo de dinero activo por: %s", currentState.PurchasedBy or "Alguien")
		end

		return
	end
end

-- ========================================
-- MANEJO DEL BOTÓN DE COMPRA
-- ========================================
moneyBoostButton.MouseButton1Click:Connect(function()
	local availableBoost = currentState.AvailableBoost

	if not availableBoost then
		warn("[GlobalMoneyBoostButton] ⚠️ No hay boost de dinero disponible para comprar")
		return
	end

	print(string.format("[GlobalMoneyBoostButton] 🛒 Solicitando compra de %s (ID: %d)", availableBoost.Name, availableBoost.ID))

	-- Solicitar compra al servidor
	PurchaseGlobalMoneyBoostEvent:FireServer(availableBoost.ID)
end)

-- ========================================
-- RECIBIR ACTUALIZACIONES DEL SERVIDOR
-- ========================================
GlobalMoneyBoostStateChangedEvent.OnClientEvent:Connect(function(stateData)
	print(string.format("[GlobalMoneyBoostButton] 📥 Estado recibido: Boost=%s, Mult=x%.1f, Tiempo=%ds",
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
		return RequestMoneyBoostStateFunction:InvokeServer()
	end)

	if success and stateData then
		print("[GlobalMoneyBoostButton] ✅ Estado inicial de dinero recibido del servidor")

		currentState.ActiveBoostID = stateData.ActiveBoostID
		currentState.Multiplier = stateData.Multiplier
		currentState.TimeRemaining = stateData.TimeRemaining
		currentState.PurchasedBy = stateData.PurchasedBy
		currentState.AvailableBoost = stateData.AvailableBoost

		updateGUI()
	else
		warn("[GlobalMoneyBoostButton] ❌ Error al solicitar estado inicial de dinero:", stateData)
	end
end)

print("[GlobalMoneyBoostButton] ✅ LocalScript de dinero inicializado")
