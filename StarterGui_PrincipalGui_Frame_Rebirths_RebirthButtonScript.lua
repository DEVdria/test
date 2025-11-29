-- StarterGui > PrincipalGui > Frame > Rebirths > RebirthButtonScript
-- Controla el botón de Rebirths en la GUI principal

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Referencia al botón de Rebirths (este script debe estar dentro del ImageButton "Rebirths")
local rebirthButton = script.Parent

-- Referencia a la GUI de Rebirths
local playerGui = player:WaitForChild("PlayerGui")
local rebirthGui = playerGui:WaitForChild("RebirthGui")

-- Al hacer clic, abrir/cerrar la GUI de Rebirths
rebirthButton.MouseButton1Click:Connect(function()
	rebirthGui.Enabled = not rebirthGui.Enabled
end)
