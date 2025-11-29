-- StarterGui > PrincipalGui > Frame > SpeedDisplayScript
-- Actualiza el display de velocidad acumulada en la GUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateSpeedDisplayEvent = RemoteEvents:WaitForChild("UpdateSpeedDisplay")

-- Referencia al TextLabel de velocidad (debe estar en la misma carpeta Frame)
local speedLabel = script.Parent:WaitForChild("SpeedDisplay")

-- Velocidad actual
local currentSpeed = 0

-- Actualiza el texto del label
local function updateDisplay(speed)
	currentSpeed = speed or 0

	-- Formatear el texto (puedes personalizarlo)
	speedLabel.Text = string.format("Velocidad: +%d", math.floor(currentSpeed))
end

-- Escuchar actualizaciones del servidor
UpdateSpeedDisplayEvent.OnClientEvent:Connect(function(newSpeed)
	updateDisplay(newSpeed)
end)

-- Inicializar con 0
updateDisplay(0)
