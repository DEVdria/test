--[[
	TrollButtonHandler.lua - Maneja el botón Troll y el panel de productos

	UBICACIÓN: StarterGui > ScreenGui > Frame > Troll (Button) > LocalScript

	INSTRUCCIONES:
	1. Este script debe estar dentro del botón "Troll" como LocalScript
	2. Reemplaza el LocalScript existente o crea uno nuevo
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local trollButton = script.Parent  -- Botón Troll
local screenGui = trollButton.Parent.Parent  -- ScreenGui
local shopFrame = screenGui:WaitForChild("ShopFrame")

-- Crear TrollFrame si no existe
local trollFrame = screenGui:FindFirstChild("TrollFrame")
if not trollFrame then
	trollFrame = shopFrame:Clone()
	trollFrame.Name = "TrollFrame"
	trollFrame.Parent = screenGui
	trollFrame.Visible = false

	-- Cambiar colores para distinguirlo
	local gradient = trollFrame:FindFirstChild("UIGradient")
	if gradient then
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 20, 20)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 10, 10))
		}
	end

	-- Cambiar título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🤪 Troll Shop"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 24
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = trollFrame
end

-- Cuando se hace clic en el botón Troll
trollButton.MouseButton1Click:Connect(function()
	-- Ocultar ShopFrame si está visible
	shopFrame.Visible = false

	-- Mostrar TrollFrame
	trollFrame.Visible = not trollFrame.Visible

	-- Cargar productos de trolleo
	if trollFrame.Visible and _G.ShopFrame then
		task.wait(0.1)  -- Esperar a que se muestre
		_G.ShopFrame.ShowProducts("troll")
	end
end)

-- Cerrar TrollFrame con el botón Cerrar
local closeButton = trollFrame:FindFirstChild("Cerrar")
if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		trollFrame.Visible = false
	end)
end

print("✅ TrollButton configurado correctamente")
