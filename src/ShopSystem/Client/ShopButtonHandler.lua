--[[
	ShopButtonHandler.lua - Maneja el botón Shop para abrir la tienda

	UBICACIÓN: StarterGui > ScreenGui > Frame > Shop (Button) > LocalScript

	INSTRUCCIONES:
	1. Este script debe estar dentro del botón "Shop" como LocalScript
	2. Reemplaza el "LocalScript shop" existente con este código
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local shopButton = script.Parent  -- Botón Shop
local screenGui = shopButton.Parent.Parent  -- ScreenGui
local shopFrame = screenGui:WaitForChild("ShopFrame")
local trollFrame = screenGui:FindFirstChild("TrollFrame")

-- Cuando se hace clic en el botón Shop
shopButton.MouseButton1Click:Connect(function()
	-- Ocultar TrollFrame si está visible
	if trollFrame then
		trollFrame.Visible = false
	end

	-- Toggle ShopFrame
	shopFrame.Visible = not shopFrame.Visible

	-- Cargar gamepasses cuando se abre
	if shopFrame.Visible and _G.ShopFrame then
		task.wait(0.1)  -- Esperar a que se muestre
		_G.ShopFrame.ShowGamepasses()
	end
end)

print("✅ ShopButton configurado correctamente")
