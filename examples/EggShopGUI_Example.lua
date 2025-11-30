--[[
	EJEMPLO: SCRIPT PARA GUI DE TIENDA DE HUEVOS

	Coloca este LocalScript dentro de tu GUI de tienda de huevos.

	Estructura esperada de la GUI:
	ScreenGui/
	  └── EggShopFrame (Frame)
	      ├── EggName (TextLabel)
	      ├── Price (TextLabel)
	      ├── OpenButton (TextButton)
	      ├── Open3Button (TextButton)
	      ├── AutoOpenToggle (TextButton)
	      └── CloseButton (TextButton)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

-- RemoteEvents
local OpenEggRemote = RemoteEventsFolder:WaitForChild("OpenEgg")
local AutoOpenToggleRemote = RemoteEventsFolder:WaitForChild("AutoOpenToggle")
local ShowEggUIRemote = RemoteEventsFolder:WaitForChild("ShowEggUI")
local HideEggUIRemote = RemoteEventsFolder:WaitForChild("HideEggUI")

local player = Players.LocalPlayer

-- Referencias a la GUI (ajusta según tu estructura)
local gui = script.Parent
local eggName = gui:WaitForChild("EggName")
local priceLabel = gui:WaitForChild("Price")
local openButton = gui:WaitForChild("OpenButton")
local open3Button = gui:WaitForChild("Open3Button")
local autoOpenToggle = gui:WaitForChild("AutoOpenToggle")
local closeButton = gui:WaitForChild("CloseButton")

-- Estado
local currentEggType = nil
local autoOpenEnabled = false

-- ============================================
-- MOSTRAR GUI DEL HUEVO
-- ============================================
ShowEggUIRemote.OnClientEvent:Connect(function(eggType)
	currentEggType = eggType
	local eggConfig = PetConfig.Eggs[eggType]

	if not eggConfig then
		warn("[EggShop] Configuración de huevo no encontrada: " .. eggType)
		return
	end

	-- Actualizar GUI
	eggName.Text = eggConfig.DisplayName
	priceLabel.Text = "💰 " .. eggConfig.Price

	-- Mostrar
	gui.Visible = true
end)

-- ============================================
-- OCULTAR GUI DEL HUEVO
-- ============================================
HideEggUIRemote.OnClientEvent:Connect(function()
	gui.Visible = false
	currentEggType = nil
	autoOpenEnabled = false
	autoOpenToggle.Text = "🔄 Auto-Open"
end)

-- ============================================
-- BOTÓN: ABRIR 1
-- ============================================
openButton.MouseButton1Click:Connect(function()
	if not currentEggType then return end

	-- Enviar al servidor
	OpenEggRemote:FireServer(currentEggType, "Single")
end)

-- ============================================
-- BOTÓN: ABRIR 3
-- ============================================
open3Button.MouseButton1Click:Connect(function()
	if not currentEggType then return end

	-- Enviar al servidor
	OpenEggRemote:FireServer(currentEggType, "Triple")
end)

-- ============================================
-- BOTÓN: AUTO-OPEN
-- ============================================
autoOpenToggle.MouseButton1Click:Connect(function()
	if not currentEggType then return end

	autoOpenEnabled = not autoOpenEnabled

	-- Enviar al servidor
	AutoOpenToggleRemote:FireServer(currentEggType, autoOpenEnabled)

	-- Actualizar UI
	if autoOpenEnabled then
		autoOpenToggle.Text = "⏹ Stop Auto-Open"
		autoOpenToggle.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
	else
		autoOpenToggle.Text = "🔄 Auto-Open"
		autoOpenToggle.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
	end
end)

-- ============================================
-- BOTÓN: CERRAR
-- ============================================
closeButton.MouseButton1Click:Connect(function()
	-- Forzar salida del rango (opcional)
	gui.Visible = false
end)

print("[EggShop] Sistema de tienda de huevos cargado ✓")
