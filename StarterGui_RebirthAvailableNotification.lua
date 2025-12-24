-- StarterGui > RebirthAvailableNotification (LocalScript)
-- Muestra una notificación cuando el jugador puede comprar un rebirth

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[RebirthAvailableNotification] ❌ No se encontró carpeta Modules")
	return
end

local RebirthConfig = require(Modules:WaitForChild("RebirthConfig", 10))
if not RebirthConfig then
	warn("[RebirthAvailableNotification] ❌ No se pudo cargar RebirthConfig")
	return
end

-- RemoteEvent para comprar rebirth
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase", 10)

-- ═══════════════════════════════════════════════════════════
-- BUSCAR GUI (TÚ DEBES CREARLA EN STARTERGUI)
-- ═══════════════════════════════════════════════════════════

--[[
	ESTRUCTURA REQUERIDA EN StarterGui:

	StarterGui
	└─ RebirthAvailableGui (ScreenGui)
	   └─ NotificationFrame (Frame) [Visible = false]
	      ├─ MessageLabel (TextLabel) <- "¡Puedes comprar un Rebirth!"
	      ├─ PurchaseButton (TextButton) <- "Comprar Rebirth"
	      └─ CloseButton (TextButton) <- "X" o "Cerrar"

	DISEÑA LA GUI COMO QUIERAS:
	- Colores, tamaños, posiciones
	- Efectos, animaciones, bordes
	- El código solo muestra/oculta y maneja los botones
]]

local rebirthAvailableGui = playerGui:WaitForChild("RebirthAvailableGui", 10)
if not rebirthAvailableGui then
	warn("[RebirthAvailableNotification] ❌ No se encontró ScreenGui 'RebirthAvailableGui'")
	warn("[RebirthAvailableNotification] 📘 Crea un ScreenGui llamado 'RebirthAvailableGui' en StarterGui")
	return
end

local notificationFrame = rebirthAvailableGui:WaitForChild("NotificationFrame", 5)
if not notificationFrame then
	warn("[RebirthAvailableNotification] ❌ No se encontró 'NotificationFrame'")
	warn("[RebirthAvailableNotification] 📘 Crea un Frame llamado 'NotificationFrame' (Visible = false)")
	return
end

local messageLabel = notificationFrame:FindFirstChild("MessageLabel")
local purchaseButton = notificationFrame:FindFirstChild("PurchaseButton")
local closeButton = notificationFrame:FindFirstChild("CloseButton")

if not messageLabel then
	warn("[RebirthAvailableNotification] ⚠️ No se encontró 'MessageLabel'")
end

if not purchaseButton then
	warn("[RebirthAvailableNotification] ❌ No se encontró 'PurchaseButton'")
	warn("[RebirthAvailableNotification] 📘 Crea un TextButton llamado 'PurchaseButton'")
	return
end

if not closeButton then
	warn("[RebirthAvailableNotification] ⚠️ No se encontró 'CloseButton'")
end

-- Asegurar que esté oculto inicialmente
notificationFrame.Visible = false

print("[RebirthAvailableNotification] ✅ GUI encontrada correctamente")

-- ═══════════════════════════════════════════════════════════
-- ESTADO
-- ═══════════════════════════════════════════════════════════

local currentRebirthLevel = 0  -- Nivel de rebirth actual
local hasShownNotification = false  -- Flag para evitar spam
local isPurchasing = false  -- Flag para evitar múltiples compras

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Muestra la notificación
local function showNotification()
	if notificationFrame.Visible then return end  -- Ya está visible

	notificationFrame.Visible = true
	hasShownNotification = true

	print("[RebirthAvailableNotification] 📢 Notificación mostrada: Rebirth disponible")
end

-- Oculta la notificación
local function hideNotification()
	notificationFrame.Visible = false
	print("[RebirthAvailableNotification] 🚫 Notificación ocultada")
end

-- Compra el rebirth (igual que el purchaseButton de RebirthGui)
local function purchaseRebirth()
	if isPurchasing then
		print("[RebirthAvailableNotification] ⏳ Ya hay una compra en proceso")
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local currentRebirths = leaderstats:FindFirstChild("Rebirths")
	local currentMoney = leaderstats:FindFirstChild("Money")

	if not currentRebirths or not currentMoney then return end

	local cost = RebirthConfig.GetRebirthCost(currentRebirths.Value)

	-- Verificar si puede comprar
	if currentMoney.Value < cost then
		print("[RebirthAvailableNotification] ❌ No hay suficiente dinero para comprar")

		-- Efecto visual en el botón (shake)
		if purchaseButton then
			local originalPosition = purchaseButton.Position
			for i = 1, 3 do
				purchaseButton.Position = originalPosition + UDim2.new(0, math.random(-5, 5), 0, 0)
				task.wait(0.05)
			end
			purchaseButton.Position = originalPosition
		end
		return
	end

	isPurchasing = true

	if purchaseButton then
		purchaseButton.Text = "PROCESANDO..."
	end

	print("[RebirthAvailableNotification] 💰 Enviando solicitud de rebirth al servidor...")

	-- Enviar solicitud al servidor
	RequestRebirthPurchaseEvent:FireServer()
end

-- Maneja la respuesta del servidor
local function handleRebirthResponse(result)
	isPurchasing = false

	if not purchaseButton then return end

	if result.Success then
		-- Éxito
		purchaseButton.Text = "¡REBIRTH EXITOSO!"

		print(string.format("[RebirthAvailableNotification] ✅ Rebirth exitoso: %s", result.Message or ""))

		task.wait(1.5)

		-- Ocultar la notificación después de comprar
		hideNotification()

		-- Restaurar texto del botón
		purchaseButton.Text = "Comprar Rebirth"
	else
		-- Error
		purchaseButton.Text = result.Message or "ERROR"

		print(string.format("[RebirthAvailableNotification] ❌ Error al comprar rebirth: %s", result.Message or "Error desconocido"))

		task.wait(2)
		purchaseButton.Text = "Comprar Rebirth"
	end
end

-- Verifica si el jugador puede comprar un rebirth
local function checkRebirthAvailability()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local money = leaderstats:FindFirstChild("Money")
	local rebirths = leaderstats:FindFirstChild("Rebirths")

	if not money or not rebirths then return end

	local currentMoney = money.Value
	local currentRebirths = rebirths.Value

	-- Si el nivel de rebirth cambió, resetear el flag
	if currentRebirths ~= currentRebirthLevel then
		currentRebirthLevel = currentRebirths
		hasShownNotification = false
		hideNotification()
	end

	-- Calcular costo del siguiente rebirth
	local cost = RebirthConfig.GetRebirthCost(currentRebirths)

	-- Verificar si tiene suficiente dinero y aún no se mostró la notificación
	if currentMoney >= cost and not hasShownNotification then
		showNotification()
	end
end

-- ═══════════════════════════════════════════════════════════
-- CONFIGURAR BOTONES
-- ═══════════════════════════════════════════════════════════

-- Botón de compra
if purchaseButton then
	purchaseButton.MouseButton1Click:Connect(purchaseRebirth)
	print("[RebirthAvailableNotification] 🔘 Botón de compra configurado")
end

-- Botón de cerrar
if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		hideNotification()
	end)
	print("[RebirthAvailableNotification] 🔘 Botón de cerrar configurado")
end

-- ═══════════════════════════════════════════════════════════
-- ESCUCHAR RESPUESTA DEL SERVIDOR
-- ═══════════════════════════════════════════════════════════

RequestRebirthPurchaseEvent.OnClientEvent:Connect(handleRebirthResponse)

-- ═══════════════════════════════════════════════════════════
-- MONITOREAR DINERO Y REBIRTHS
-- ═══════════════════════════════════════════════════════════

local function setupMonitoring()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[RebirthAvailableNotification] ❌ No se encontró leaderstats")
		return
	end

	local money = leaderstats:WaitForChild("Money", 5)
	local rebirths = leaderstats:WaitForChild("Rebirths", 5)

	if not money or not rebirths then
		warn("[RebirthAvailableNotification] ❌ No se encontró Money o Rebirths en leaderstats")
		return
	end

	-- Inicializar nivel de rebirth actual
	currentRebirthLevel = rebirths.Value

	-- Escuchar cambios en el dinero
	money:GetPropertyChangedSignal("Value"):Connect(checkRebirthAvailability)

	-- Escuchar cambios en los rebirths
	rebirths:GetPropertyChangedSignal("Value"):Connect(checkRebirthAvailability)

	-- Verificación inicial
	checkRebirthAvailability()

	print("[RebirthAvailableNotification] ✅ Monitoreo de dinero y rebirths iniciado")
	print(string.format("[RebirthAvailableNotification] 💰 Dinero actual: $%d", money.Value))
	print(string.format("[RebirthAvailableNotification] 🔄 Rebirths actuales: %d", rebirths.Value))
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZAR
-- ═══════════════════════════════════════════════════════════

setupMonitoring()

print("[RebirthAvailableNotification] 🎨 Diseña la GUI 'RebirthAvailableGui' en StarterGui")
print("[RebirthAvailableNotification] 📋 Incluye: NotificationFrame, MessageLabel, PurchaseButton, CloseButton")
