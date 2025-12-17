--[[
	CHEST TIMER DISPLAY - LocalScript
	Muestra el temporizador de cooldown en el BillboardGui del cofre.

	UBICACIÓN: Este script debe estar dentro del BillboardGui de cada cofre
	ESTRUCTURA:
	Workspace
	└── CHEST REWARD LEVEL
	    └── chest1 (Model)
	        └── touch (MeshPart)
	            └── BillboardGui
	                ├── Timer (TextLabel) ← Muestra el tiempo
	                └── ChestTimerDisplay (LocalScript) ← ESTE SCRIPT

	CONFIGURACIÓN:
	- El script detecta automáticamente qué cofre es según el nombre del modelo
	- Actualiza el Timer cada segundo
	- Muestra "READY!" cuando el cofre está disponible
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ========================================
-- REFERENCIAS
-- ========================================
local billboardGui = script.Parent
local timerLabel = billboardGui:WaitForChild("Timer")

-- Obtener el modelo del cofre (chest1, chest2, etc.)
local touchPart = billboardGui.Parent
local chestModel = touchPart.Parent
local chestName = chestModel.Name  -- "chest1", "chest2", etc.

-- ========================================
-- IMPORTAR CONFIG
-- ========================================
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChestRewardConfig = require(Modules:WaitForChild("ChestRewardConfig"))

-- Obtener configuración del cofre
local chestConfig = ChestRewardConfig.GetChestByModelName(chestName)
if not chestConfig then
	warn(string.format("[ChestTimerDisplay] ⚠️ No se encontró configuración para %s", chestName))
	timerLabel.Text = "ERROR"
	return
end

local chestID = chestConfig.ID

print(string.format("[ChestTimerDisplay] ✅ Iniciando display para %s (ID: %d)", chestName, chestID))

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetChestCooldownFunction = RemotesFolder:WaitForChild("GetChestCooldown")

-- ========================================
-- FUNCIONES
-- ========================================

-- Formatea segundos a HH:MM:SS o MM:SS
local function formatTime(seconds)
	return ChestRewardConfig.FormatTime(seconds)
end

-- Actualiza el display del temporizador
local function updateTimer()
	local success, remaining = pcall(function()
		return GetChestCooldownFunction:InvokeServer(chestID)
	end)

	if not success then
		warn(string.format("[ChestTimerDisplay] ❌ Error obteniendo cooldown para %s: %s", chestName, tostring(remaining)))
		timerLabel.Text = "??:??"
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)  -- Rojo para error
		return
	end

	if remaining and remaining > 0 then
		-- Mostrar tiempo restante
		timerLabel.Text = formatTime(remaining)
		timerLabel.TextColor3 = Color3.fromRGB(255, 170, 0)  -- Naranja para cooldown
	else
		-- Cofre disponible
		timerLabel.Text = "READY!"
		timerLabel.TextColor3 = Color3.fromRGB(0, 255, 100)  -- Verde para disponible
	end
end

-- ========================================
-- ACTUALIZACIÓN AUTOMÁTICA
-- ========================================

-- Actualizar inmediatamente
updateTimer()

-- Actualizar cada segundo
task.spawn(function()
	while true do
		task.wait(1)
		updateTimer()
	end
end)

print(string.format("[ChestTimerDisplay] ✅ Display activo para %s", chestName))
