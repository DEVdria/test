--[[
	TROLL BUTTON - LocalScript
	Ubicación: StarterGui > TrollGui > ScreenGui > Frame > TrollButton

	Este script maneja el botón Troll que requiere comprar un Developer Product.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local button = script.Parent
local frame = button.Parent

-- Esperar a que los RemoteEvents estén disponibles
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TrollEvent = RemoteEvents:WaitForChild("TrollEvent")
local PurchaseEvent = RemoteEvents:WaitForChild("PurchaseEvent")
local PromptPurchase = RemoteEvents:WaitForChild("PromptPurchase")

-- Estado del producto
local hasPurchased = false

-- ============================================
-- FUNCIONES DE UI
-- ============================================

-- Actualizar el estado visual del botón
local function updateButtonState()
	if hasPurchased then
		button.Text = "🔥 TROLL 🔥"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)  -- Rojo brillante
		button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Blanco
	else
		button.Text = "🔒 TROLL (Comprar)"
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)  -- Gris
		button.TextColor3 = Color3.fromRGB(200, 200, 200)  -- Gris claro
	end
end

-- ============================================
-- MANEJO DE EVENTOS
-- ============================================

-- Cuando el jugador hace clic en el botón
button.MouseButton1Click:Connect(function()
	if not hasPurchased then
		-- Solicitar compra del producto
		print("Solicitando compra del producto Troll...")
		PromptPurchase:FireServer("TrollProduct")
	else
		-- Ejecutar el efecto Troll
		print("Activando efecto Troll...")
		TrollEvent:FireServer()

		-- Feedback visual
		button.Text = "💀 ACTIVADO 💀"
		task.wait(2)
		updateButtonState()
	end
end)

-- Escuchar respuestas del servidor
PurchaseEvent.OnClientEvent:Connect(function(eventType)
	if eventType == "TrollUnlocked" then
		hasPurchased = true
		updateButtonState()
		print("✅ Producto Troll desbloqueado!")

		-- Efecto visual de desbloqueo
		button.Text = "✅ DESBLOQUEADO!"
		task.wait(1.5)
		updateButtonState()
	end
end)

-- Inicializar el botón
updateButtonState()

print("✅ Troll Button script cargado")
