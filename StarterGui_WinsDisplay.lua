--[[
	WINS DISPLAY - LocalScript
	Muestra el número de victorias (wins) del jugador en la GUI.

	ESTRUCTURA DE GUI ESPERADA:
	ScreenGui
	└── WinsFrame (Frame)
	    └── WinsLabel (TextLabel) ← Muestra el número de wins

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
local winsFrame = screenGui:WaitForChild("WinsFrame")
local winsLabel = winsFrame:WaitForChild("WinsLabel")  -- TextLabel que muestra el número

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

-- Crear RemoteFunction si no existe para solicitar wins
local GetWinsFunction = RemotesFolder:FindFirstChild("GetPlayerWins")
if not GetWinsFunction then
	-- Esperar un poco más por si el servidor lo está creando
	GetWinsFunction = RemotesFolder:WaitForChild("GetPlayerWins", 10)
end

-- ========================================
-- FUNCIONES
-- ========================================

-- Actualiza el display de wins
local function updateWinsDisplay(wins)
	winsLabel.Text = tostring(wins)
	print(string.format("[WinsDisplay] 📊 Wins actualizados: %d", wins))
end

-- Solicita las wins al servidor
local function requestWins()
	if not GetWinsFunction then
		warn("[WinsDisplay] ⚠️ GetPlayerWins RemoteFunction no encontrada")
		winsLabel.Text = "0"
		return
	end

	local success, wins = pcall(function()
		return GetWinsFunction:InvokeServer()
	end)

	if success and wins then
		updateWinsDisplay(wins)
	else
		warn("[WinsDisplay] ❌ Error al obtener wins:", wins)
		winsLabel.Text = "0"
	end
end

-- ========================================
-- INICIALIZACIÓN
-- ========================================

-- Solicitar wins iniciales
task.spawn(function()
	task.wait(1)  -- Esperar a que el jugador esté completamente cargado
	requestWins()
end)

-- Actualizar wins cada 5 segundos
task.spawn(function()
	while true do
		task.wait(5)
		requestWins()
	end
end)

print("[WinsDisplay] ✅ LocalScript de Wins inicializado")
