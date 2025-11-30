--[[
	EJEMPLO: SCRIPT PARA GUI DE RECOMPENSA DE MASCOTAS

	Coloca este LocalScript dentro de tu GUI de recompensa.

	Estructura esperada de la GUI:
	ScreenGui/
	  └── RewardFrame (Frame)
	      ├── ViewportFrame (ViewportFrame)    -- Para mostrar modelo 3D
	      ├── PetName (TextLabel)
	      ├── Rarity (TextLabel)
	      ├── Multiplier (TextLabel)
	      ├── CloseButton (TextButton)
	      ├── NextButton (TextButton)          -- Si abriste 3 huevos
	      └── PrevButton (TextButton)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ViewportUtil = require(ReplicatedStorage:WaitForChild("ViewportUtil"))
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))
local ShowPetRewardRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ShowPetReward")

local player = Players.LocalPlayer

-- Referencias a la GUI
local gui = script.Parent
local viewportFrame = gui:WaitForChild("ViewportFrame")
local petNameLabel = gui:WaitForChild("PetName")
local rarityLabel = gui:WaitForChild("Rarity")
local multiplierLabel = gui:WaitForChild("Multiplier")
local closeButton = gui:WaitForChild("CloseButton")
local nextButton = gui:WaitForChild("NextButton")
local prevButton = gui:WaitForChild("PrevButton")

-- Estado
local currentPets = {}
local currentIndex = 1
local currentViewportData = nil

-- ============================================
-- FUNCIÓN: MOSTRAR MASCOTA
-- ============================================
local function showPet(pet)
	if not pet then return end

	-- Limpiar viewport anterior
	if currentViewportData then
		ViewportUtil.CleanupViewport(currentViewportData)
	end

	-- Mostrar nueva mascota con rotación
	currentViewportData = ViewportUtil.ShowPetInViewport(
		viewportFrame,
		pet.Name,
		true,  -- Auto-rotar
		1      -- Velocidad
	)

	-- Actualizar labels
	petNameLabel.Text = pet.Name
	rarityLabel.Text = pet.Rarity
	multiplierLabel.Text = "Multiplicador: x" .. pet.xpMultiplier

	-- Color de rareza
	local rarityConfig = PetConfig.Rarities[pet.Rarity]
	if rarityConfig then
		rarityLabel.TextColor3 = rarityConfig.Color
	end

	-- Animación de entrada
	gui.Size = UDim2.new(0, 0, 0, 0)
	gui.Visible = true

	local tween = TweenService:Create(gui, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
		Size = UDim2.new(0.5, 0, 0.6, 0)
	})
	tween:Play()
end

-- ============================================
-- RECIBIR RESULTADO DEL SERVIDOR
-- ============================================
ShowPetRewardRemote.OnClientEvent:Connect(function(status, data)
	if status == "Success" then
		-- data = tabla de mascotas
		currentPets = data
		currentIndex = 1

		-- Mostrar primera mascota
		showPet(currentPets[currentIndex])

		-- Mostrar botones de navegación si hay múltiples mascotas
		if #currentPets > 1 then
			nextButton.Visible = true
			prevButton.Visible = true
		else
			nextButton.Visible = false
			prevButton.Visible = false
		end

	elseif status == "NotEnoughMoney" then
		-- Crear notificación de error
		local errorGui = Instance.new("ScreenGui")
		errorGui.Name = "ErrorNotification"
		errorGui.Parent = player.PlayerGui

		local errorFrame = Instance.new("Frame")
		errorFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
		errorFrame.Position = UDim2.new(0.35, 0, 0.45, 0)
		errorFrame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		errorFrame.Parent = errorGui

		local errorText = Instance.new("TextLabel")
		errorText.Size = UDim2.new(1, 0, 1, 0)
		errorText.BackgroundTransparency = 1
		errorText.Text = "💰 Dinero insuficiente\nNecesitas: " .. data.Required
		errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
		errorText.TextScaled = true
		errorText.Parent = errorFrame

		-- Auto-destruir después de 3 segundos
		task.delay(3, function()
			errorGui:Destroy()
		end)

	elseif status == "NoGamepass" then
		-- Notificación de gamepass
		local errorGui = Instance.new("ScreenGui")
		errorGui.Name = "GamepassNotification"
		errorGui.Parent = player.PlayerGui

		local errorFrame = Instance.new("Frame")
		errorFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
		errorFrame.Position = UDim2.new(0.35, 0, 0.45, 0)
		errorFrame.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		errorFrame.Parent = errorGui

		local errorText = Instance.new("TextLabel")
		errorText.Size = UDim2.new(1, 0, 1, 0)
		errorText.BackgroundTransparency = 1
		errorText.Text = "⭐ Necesitas el Gamepass\npara usar esta función"
		errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
		errorText.TextScaled = true
		errorText.Parent = errorFrame

		task.delay(3, function()
			errorGui:Destroy()
		end)

	elseif status == "AutoOpenStopped" then
		print("[PetReward] Auto-open detenido:", data.Reason)
	end
end)

-- ============================================
-- BOTÓN: SIGUIENTE MASCOTA
-- ============================================
nextButton.MouseButton1Click:Connect(function()
	currentIndex = currentIndex + 1
	if currentIndex > #currentPets then
		currentIndex = 1
	end
	showPet(currentPets[currentIndex])
end)

-- ============================================
-- BOTÓN: MASCOTA ANTERIOR
-- ============================================
prevButton.MouseButton1Click:Connect(function()
	currentIndex = currentIndex - 1
	if currentIndex < 1 then
		currentIndex = #currentPets
	end
	showPet(currentPets[currentIndex])
end)

-- ============================================
-- BOTÓN: CERRAR
-- ============================================
closeButton.MouseButton1Click:Connect(function()
	-- Limpiar viewport
	if currentViewportData then
		ViewportUtil.CleanupViewport(currentViewportData)
		currentViewportData = nil
	end

	-- Ocultar GUI
	gui.Visible = false

	-- Limpiar datos
	currentPets = {}
	currentIndex = 1
end)

print("[PetReward] Sistema de recompensas cargado ✓")
