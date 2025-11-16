--[[
	DONATIONS GUI SCRIPT - LocalScript
	Ubicación: StarterGui > DonacionesGui > ScreenGui > DonationsScript

	Este script maneja la GUI de donaciones con múltiples botones.
	Cada botón está conectado a un Developer Product diferente.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local screenGui = script.Parent
local mainFrame = screenGui:WaitForChild("MainFrame")
local closeButton = mainFrame:WaitForChild("CloseButton")
local donationsContainer = mainFrame:WaitForChild("DonationsContainer")

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local OpenDonationGui = RemoteEvents:WaitForChild("OpenDonationGui")
local PromptPurchase = RemoteEvents:WaitForChild("PromptPurchase")
local PurchaseEvent = RemoteEvents:WaitForChild("PurchaseEvent")

-- ============================================
-- CONFIGURACIÓN DE BOTONES DE DONACIÓN
-- ============================================

-- Configuración de cada botón (nombre, emoji, color)
local donationButtons = {
	{name = "Donacion1", text = "💵 5 Robux", color = Color3.fromRGB(85, 170, 255)},
	{name = "Donacion2", text = "💰 10 Robux", color = Color3.fromRGB(85, 255, 127)},
	{name = "Donacion3", text = "💎 25 Robux", color = Color3.fromRGB(170, 85, 255)},
	{name = "Donacion4", text = "👑 50 Robux", color = Color3.fromRGB(255, 215, 0)},
	{name = "Donacion5", text = "🌟 100 Robux", color = Color3.fromRGB(255, 85, 85)},
}

-- ============================================
-- FUNCIONES DE UI
-- ============================================

-- Abrir la GUI
local function openGui()
	screenGui.Enabled = true
	mainFrame.Visible = true

	-- Animación de entrada
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame:TweenSize(
		UDim2.new(0.4, 0, 0.6, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)
end

-- Cerrar la GUI
local function closeGui()
	-- Animación de salida
	mainFrame:TweenSize(
		UDim2.new(0, 0, 0, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Back,
		0.3,
		true,
		function()
			mainFrame.Visible = false
			screenGui.Enabled = false
		end
	)
end

-- ============================================
-- CREAR BOTONES DE DONACIÓN
-- ============================================

local function createDonationButtons()
	for index, buttonData in ipairs(donationButtons) do
		local button = donationsContainer:FindFirstChild("Button" .. index)

		if button and button:IsA("TextButton") then
			-- Configurar el botón
			button.Text = buttonData.text
			button.BackgroundColor3 = buttonData.color

			-- Evento de clic
			button.MouseButton1Click:Connect(function()
				print("Solicitando compra:", buttonData.name)
				PromptPurchase:FireServer(buttonData.name)

				-- Feedback visual
				local originalSize = button.Size
				button:TweenSize(
					UDim2.new(originalSize.X.Scale * 0.95, 0, originalSize.Y.Scale * 0.95, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.1,
					true,
					function()
						button:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
					end
				)
			end)

			-- Efecto hover
			button.MouseEnter:Connect(function()
				button.BackgroundTransparency = 0
				button.BorderSizePixel = 3
			end)

			button.MouseLeave:Connect(function()
				button.BackgroundTransparency = 0.1
				button.BorderSizePixel = 2
			end)
		end
	end
end

-- ============================================
-- EVENTOS
-- ============================================

-- Botón de cerrar
closeButton.MouseButton1Click:Connect(function()
	closeGui()
end)

-- Escuchar cuando el servidor dice que se abra la GUI
OpenDonationGui.OnClientEvent:Connect(function()
	openGui()
end)

-- Escuchar respuestas de compras exitosas
PurchaseEvent.OnClientEvent:Connect(function(eventType)
	if eventType == "DonationSuccess" then
		print("✅ ¡Donación exitosa! Gracias por tu apoyo")

		-- Mostrar mensaje de agradecimiento
		local thankYouLabel = mainFrame:FindFirstChild("ThankYouLabel")
		if thankYouLabel then
			thankYouLabel.Visible = true
			task.wait(2)
			thankYouLabel.Visible = false
		end
	end
end)

-- ============================================
-- INICIALIZACIÓN
-- ============================================

-- Inicialmente ocultar la GUI
screenGui.Enabled = false
mainFrame.Visible = false

-- Crear los botones
createDonationButtons()

print("✅ Donations GUI script cargado")
