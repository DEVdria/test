--[[
	LOCAL SCRIPT PARA GUIs PERSONALIZADAS
	Ubicación: StarterPlayer/StarterPlayerScripts/CustomGUIHandler
	Descripción: Conecta tus GUIs existentes con el sistema

	INSTRUCCIONES:
	1. Copia este script a un LocalScript dentro de tu ScreenGui
	2. Modifica las rutas de las GUIs según tu estructura
	3. Asegúrate de tener los elementos GUI creados con los nombres correctos
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--[[
	===========================================
	CONFIGURACIÓN DE RUTAS - PERSONALIZA AQUÍ
	===========================================
	Cambia estas rutas según la estructura de tu GUI
]]

-- Ruta a tu ScreenGui principal
local SCREEN_GUI_NAME = "MainGui" -- Cambia esto al nombre de tu ScreenGui

-- Nombres de los elementos de la GUI
local SPEED_LABEL_NAME = "SpeedLabel" -- TextLabel que muestra la velocidad
local SPRINT_BUTTON_NAME = "SprintButton" -- Botón de sprint para móvil
local REVIVE_BUTTON_NAME = "ReviveButton" -- Botón de revivir

--[[
	===========================================
	FIN DE CONFIGURACIÓN
	===========================================
]]

-- Esperar a que la GUI cargue
local screenGui = playerGui:WaitForChild(SCREEN_GUI_NAME, 10)

if not screenGui then
	warn("No se encontró el ScreenGui: " .. SCREEN_GUI_NAME)
	warn("Por favor verifica la ruta en CustomGUIHandler.lua")
	return
end

-- Obtener referencias a los elementos de la GUI
local speedLabel = screenGui:FindFirstChild(SPEED_LABEL_NAME, true) -- true = búsqueda recursiva
local sprintButton = screenGui:FindFirstChild(SPRINT_BUTTON_NAME, true)
local reviveButton = screenGui:FindFirstChild(REVIVE_BUTTON_NAME, true)

-- Verificar que los elementos existen
if not speedLabel then
	warn("No se encontró SpeedLabel: " .. SPEED_LABEL_NAME)
end

if not sprintButton then
	warn("No se encontró SprintButton: " .. SPRINT_BUTTON_NAME)
end

if not reviveButton then
	warn("No se encontró ReviveButton: " .. REVIVE_BUTTON_NAME)
end

-- Función para actualizar la velocidad en la GUI
local function UpdateSpeedDisplay()
	if not speedLabel then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Obtener velocidad actual
	local currentSpeed = humanoid.WalkSpeed

	-- Verificar si está en sprint
	local isSprinting = false
	if _G.PlayerSprintManager then
		isSprinting = _G.PlayerSprintManager:IsSprinting()
	end

	-- Actualizar texto
	local statusText = isSprinting and "Corriendo" or "Caminando"
	speedLabel.Text = string.format("Velocidad: %.1f (%s)", currentSpeed, statusText)
end

-- Actualizar velocidad cada frame
RunService.Heartbeat:Connect(UpdateSpeedDisplay)

-- BOTÓN DE SPRINT MÓVIL
if sprintButton then
	-- Detectar si es móvil
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	-- Mostrar/ocultar botón según plataforma
	sprintButton.Visible = isMobile

	-- Funcionalidad del botón
	local isSprintActive = false

	sprintButton.MouseButton1Click:Connect(function()
		if not _G.PlayerSprintManager then return end

		-- Toggle sprint
		_G.PlayerSprintManager:ToggleSprint()
		isSprintActive = not isSprintActive

		-- Cambiar color del botón para feedback visual
		if isSprintActive then
			sprintButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde cuando activo
		else
			sprintButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Blanco cuando inactivo
		end
	end)

	print("Botón de sprint configurado para móvil")
else
	warn("Botón de sprint no encontrado - No disponible para móvil")
end

-- BOTÓN DE REVIVIR
if reviveButton then
	reviveButton.MouseButton1Click:Connect(function()
		-- Verificar si el jugador está muerto
		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health > 0 then
			warn("No puedes revivir - no estás muerto")
			return
		end

		-- Enviar evento al servidor
		local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
		local reviveEvent = remoteEventsFolder:WaitForChild("RevivePlayer")
		reviveEvent:FireServer()

		print("Solicitando revivir...")
	end)

	-- Mostrar/ocultar botón según estado del jugador
	local function UpdateReviveButtonVisibility()
		local character = player.Character
		if not character then
			reviveButton.Visible = false
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			reviveButton.Visible = true
		else
			reviveButton.Visible = false
		end
	end

	-- Actualizar visibilidad cada frame
	RunService.Heartbeat:Connect(UpdateReviveButtonVisibility)

	-- Actualizar cuando el personaje cambia
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(UpdateReviveButtonVisibility)
	end)

	print("Botón de revivir configurado")
else
	warn("Botón de revivir no encontrado")
end

print("CustomGUIHandler cargado exitosamente")
