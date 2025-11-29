-- StarterGui > PrincipalGui > Frame > PlayerStatsDisplay
-- Actualiza los displays de Nivel, Experiencia y Velocidad en la GUI principal
-- INSTRUCCIONES: Pegar este script como LocalScript en StarterGui > PrincipalGui > Frame

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local LevelManager = require(Modules:WaitForChild("LevelManager"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LevelUpEvent = RemoteEvents:WaitForChild("LevelUp")

-- Referencias a los TextLabels (DEBES CREAR ESTOS EN LA GUI)
-- Si no existen, el script los ignorará sin dar error
local levelLabel = script.Parent:FindFirstChild("LevelDisplay")
local expLabel = script.Parent:FindFirstChild("ExpDisplay")
local speedLabel = script.Parent:FindFirstChild("SpeedDisplay")

-- Variables de estado
local currentLevel = 0
local currentEXP = 0
local currentSpeed = 24  -- Velocidad base

-- Formatea números con separadores de miles
local function formatNumber(num)
	local formatted = tostring(num)
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted
end

-- Actualiza el display de nivel
local function updateLevelDisplay()
	if levelLabel then
		levelLabel.Text = string.format("Nivel: %d", currentLevel)
	end
end

-- Actualiza el display de experiencia
local function updateExpDisplay()
	if expLabel then
		-- Obtener EXP requerido para el siguiente nivel
		local requiredEXP = LevelManager.GetXPRequired(currentLevel)

		if requiredEXP then
			expLabel.Text = string.format("EXP: %s / %s", formatNumber(currentEXP), formatNumber(requiredEXP))
		else
			-- Si está en nivel máximo
			expLabel.Text = string.format("EXP: %s (MAX)", formatNumber(currentEXP))
		end
	end
end

-- Actualiza el display de velocidad
local function updateSpeedDisplay()
	if speedLabel then
		speedLabel.Text = string.format("Velocidad: %d", math.floor(currentSpeed))
	end
end

-- Actualiza todos los displays
local function updateAllDisplays()
	updateLevelDisplay()
	updateExpDisplay()
	updateSpeedDisplay()
end

-- Obtiene los datos del jugador desde leaderstats
local function getPlayerStats()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local levelValue = leaderstats:FindFirstChild("Level")
	local expValue = leaderstats:FindFirstChild("CurrentEXP")

	if levelValue then
		currentLevel = levelValue.Value
		currentSpeed = LevelManager.GetRunSpeed(currentLevel)
	end

	if expValue then
		currentEXP = expValue.Value
	end

	return true
end

-- Configurar listeners para cambios en leaderstats
local function setupLeaderstatsListeners()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[PlayerStatsDisplay] No se encontraron leaderstats")
		return
	end

	-- Esperar los valores
	local levelValue = leaderstats:WaitForChild("Level", 5)
	local expValue = leaderstats:WaitForChild("CurrentEXP", 5)

	-- Listener para cambios en Level
	if levelValue then
		levelValue:GetPropertyChangedSignal("Value"):Connect(function()
			currentLevel = levelValue.Value
			currentSpeed = LevelManager.GetRunSpeed(currentLevel)
			updateAllDisplays()
		end)

		-- Inicializar valor
		currentLevel = levelValue.Value
		currentSpeed = LevelManager.GetRunSpeed(currentLevel)
	end

	-- Listener para cambios en CurrentEXP
	if expValue then
		expValue:GetPropertyChangedSignal("Value"):Connect(function()
			currentEXP = expValue.Value
			updateExpDisplay()
		end)

		-- Inicializar valor
		currentEXP = expValue.Value
	end

	-- Actualizar displays iniciales
	updateAllDisplays()
end

-- Escuchar evento de subida de nivel (para actualización inmediata)
if LevelUpEvent then
	LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
		currentLevel = newLevel
		currentSpeed = newSpeed
		updateAllDisplays()
	end)
end

-- Inicializar
task.spawn(function()
	task.wait(1)  -- Esperar a que leaderstats se cree
	if getPlayerStats() then
		updateAllDisplays()
	end
	setupLeaderstatsListeners()
end)

print("[PlayerStatsDisplay] ✅ Sistema de displays de stats iniciado")
