--[[
	Glass Panel System - Client Side
	Sistema de paneles de cristal con caída temporal

	Autor: Claude AI
	Fecha: 2025-11-22

	INSTALACIÓN:
	1. Coloca este script en StarterPlayer > StarterPlayerScripts
	2. Crea un Folder en Workspace llamado "GlassRow"
	3. Dentro del folder, crea partes llamadas Panel1, Panel2, Panel3, etc.
	4. Asegúrate de que las partes tengan CanCollide = true inicialmente

	FUNCIONAMIENTO:
	- Panel #1 tarda 5.0 segundos en caer
	- Panel #2 tarda 4.9 segundos en caer
	- Panel #3 tarda 4.8 segundos en caer
	- Cada panel reduce 0.1 segundos respecto al anterior
	- La caída es solo visual del lado del cliente
	- Los paneles reaparecen después de 15 segundos
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuración
local GLASS_FOLDER_NAME = "GlassRow"
local BASE_FALL_TIME = 5.0 -- Tiempo de caída del primer panel
local TIME_REDUCTION = 0.1 -- Reducción de tiempo por cada panel
local RESPAWN_TIME = 15 -- Tiempo en segundos para que el panel reaparezca
local FALL_DISTANCE = 20 -- Distancia en studs que cae el panel
local FALL_TWEEN_TIME = 1.5 -- Duración de la animación de caída
local RESPAWN_TWEEN_TIME = 1.0 -- Duración de la animación de respawn
local ACTIVATION_RANGE = 0.5 -- Rango para detectar si el jugador está sobre el panel

-- Almacenamiento de estado de paneles
local panelStates = {} -- Guarda el estado de cada panel para este cliente

-- Información de tweens de animación
local TweenInfo_Fall = TweenInfo.new(
	FALL_TWEEN_TIME,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In,
	0,
	false,
	0
)

local TweenInfo_Respawn = TweenInfo.new(
	RESPAWN_TWEEN_TIME,
	Enum.EasingStyle.Bounce,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

--[[
	Función: getPanelNumber
	Extrae el número del panel desde su nombre (ej: "Panel1" -> 1)
]]
local function getPanelNumber(panelName)
	local number = tonumber(string.match(panelName, "%d+"))
	return number
end

--[[
	Función: calculateFallTime
	Calcula el tiempo de caída basado en el número del panel
	Panel 1 = 5.0s, Panel 2 = 4.9s, Panel 3 = 4.8s, etc.
]]
local function calculateFallTime(panelNumber)
	return BASE_FALL_TIME - ((panelNumber - 1) * TIME_REDUCTION)
end

--[[
	Función: isPlayerOnPanel
	Verifica si el jugador está pisando el panel
]]
local function isPlayerOnPanel(panel)
	if not humanoidRootPart then return false end

	local panelTop = panel.Position.Y + (panel.Size.Y / 2)
	local playerBottom = humanoidRootPart.Position.Y - (humanoidRootPart.Size.Y / 2)

	-- Verificar si el jugador está a la altura correcta
	if math.abs(playerBottom - panelTop) > ACTIVATION_RANGE then
		return false
	end

	-- Verificar si el jugador está dentro del área XZ del panel
	local panelX = panel.Position.X
	local panelZ = panel.Position.Z
	local panelSizeX = panel.Size.X / 2
	local panelSizeZ = panel.Size.Z / 2

	local playerX = humanoidRootPart.Position.X
	local playerZ = humanoidRootPart.Position.Z

	if playerX >= (panelX - panelSizeX) and playerX <= (panelX + panelSizeX) and
	   playerZ >= (panelZ - panelSizeZ) and playerZ <= (panelZ + panelSizeZ) then
		return true
	end

	return false
end

--[[
	Función: animatePanelFall
	Anima la caída del panel usando TweenService
]]
local function animatePanelFall(panel, originalPosition)
	local fallGoal = {
		CFrame = originalPosition * CFrame.new(0, -FALL_DISTANCE, 0)
	}

	local fallTween = TweenService:Create(panel, TweenInfo_Fall, fallGoal)
	fallTween:Play()

	return fallTween
end

--[[
	Función: animatePanelRespawn
	Anima el respawn del panel a su posición original
]]
local function animatePanelRespawn(panel, originalPosition)
	local respawnGoal = {
		CFrame = originalPosition
	}

	local respawnTween = TweenService:Create(panel, TweenInfo_Respawn, respawnGoal)
	respawnTween:Play()

	return respawnTween
end

--[[
	Función: activatePanel
	Activa el temporizador y las animaciones para un panel específico
]]
local function activatePanel(panel, panelNumber, fallTime)
	local state = panelStates[panel]

	-- Si el panel ya está activado o cayendo, no hacer nada
	if state.isActivated or state.isFalling then
		return
	end

	-- Marcar como activado
	state.isActivated = true
	state.activationTime = tick()

	-- Iniciar temporizador
	task.spawn(function()
		-- Esperar el tiempo de caída
		task.wait(fallTime)

		-- Marcar como cayendo
		state.isFalling = true
		state.canCollide = false

		-- Deshabilitar colisión (solo cliente)
		panel.CanCollide = false

		-- Animar caída
		local fallTween = animatePanelFall(panel, state.originalPosition)

		-- Esperar animación de caída
		fallTween.Completed:Wait()

		-- Esperar tiempo de respawn
		task.wait(RESPAWN_TIME)

		-- Habilitar colisión nuevamente
		panel.CanCollide = true
		state.canCollide = true

		-- Animar respawn
		local respawnTween = animatePanelRespawn(panel, state.originalPosition)

		-- Esperar animación de respawn
		respawnTween.Completed:Wait()

		-- Resetear estado
		state.isActivated = false
		state.isFalling = false
		state.activationTime = nil
	end)
end

--[[
	Función: initializePanel
	Inicializa el estado y configuración de un panel
]]
local function initializePanel(panel)
	local panelNumber = getPanelNumber(panel.Name)

	if not panelNumber then
		warn("Panel sin número válido:", panel.Name)
		return
	end

	local fallTime = calculateFallTime(panelNumber)

	-- Inicializar estado del panel
	panelStates[panel] = {
		panelNumber = panelNumber,
		fallTime = fallTime,
		originalPosition = panel.CFrame,
		isActivated = false,
		isFalling = false,
		canCollide = true,
		isPlayerOn = false
	}

	print(string.format("Panel %d inicializado - Tiempo de caída: %.1fs", panelNumber, fallTime))
end

--[[
	Función: setupPanels
	Configura todos los paneles encontrados en el folder
]]
local function setupPanels()
	local glassFolder = game.Workspace:FindFirstChild(GLASS_FOLDER_NAME)

	if not glassFolder then
		warn("No se encontró el folder:", GLASS_FOLDER_NAME)
		return
	end

	-- Obtener todos los paneles y ordenarlos por número
	local panels = {}
	for _, child in ipairs(glassFolder:GetChildren()) do
		if child:IsA("BasePart") and string.match(child.Name, "Panel%d+") then
			table.insert(panels, child)
		end
	end

	-- Ordenar paneles por número
	table.sort(panels, function(a, b)
		return getPanelNumber(a.Name) < getPanelNumber(b.Name)
	end)

	-- Inicializar cada panel
	for _, panel in ipairs(panels) do
		initializePanel(panel)
	end

	print(string.format("Sistema inicializado con %d paneles", #panels))
end

--[[
	Función: updatePanelDetection
	Actualiza la detección de jugador sobre paneles
]]
local function updatePanelDetection()
	-- Actualizar referencia al personaje si es necesario
	if not character or not character.Parent then
		character = player.Character
		if character then
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		else
			return
		end
	end

	if not humanoidRootPart then return end

	-- Verificar cada panel
	for panel, state in pairs(panelStates) do
		if panel and panel.Parent then
			local isOn = isPlayerOnPanel(panel)

			-- Si el jugador acaba de pisar el panel
			if isOn and not state.isPlayerOn then
				activatePanel(panel, state.panelNumber, state.fallTime)
			end

			-- Actualizar estado
			state.isPlayerOn = isOn
		end
	end
end

--[[
	INICIALIZACIÓN DEL SISTEMA
]]

-- Configurar paneles
setupPanels()

-- Actualizar detección en cada frame
RunService.Heartbeat:Connect(updatePanelDetection)

-- Manejar muerte del personaje
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")

	-- Resetear estados de paneles (opcional - puedes mantener el estado si quieres)
	-- para mantener los paneles cayendo incluso después de morir
end)

print("Glass Panel System cargado exitosamente")
