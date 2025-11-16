--[[
═══════════════════════════════════════════════════════════════
    QUEST UI - Interfaz de Misiones
    Ubicación: StarterPlayer > StarterPlayerScripts

    Funcionalidad:
    - Muestra misiones activas del jugador
    - Actualiza progreso en tiempo real
    - Animaciones al completar misiones
    - Botón para abrir/cerrar panel de misiones
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a RemoteEvents
local questUpdateEvent = ReplicatedStorage:WaitForChild("QuestUpdate")
local questCompleteEvent = ReplicatedStorage:WaitForChild("QuestComplete")

-- Variable para almacenar la UI actual
local questGui = nil
local questPanel = nil
local isPanelOpen = false
local currentQuests = {}

--[[
    Función: Crear un elemento de misión
    Parámetros:
        quest - Datos de la misión
        parent - Frame padre
--]]
local function createQuestItem(quest, index, parent)
	-- Frame de la misión
	local questFrame = Instance.new("Frame")
	questFrame.Name = "Quest_" .. quest.Id
	questFrame.Size = UDim2.new(1, -20, 0, 80)
	questFrame.Position = UDim2.new(0, 10, 0, (index - 1) * 90)
	questFrame.BackgroundColor3 = quest.Completed and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(45, 45, 45)
	questFrame.BorderSizePixel = 0
	questFrame.Parent = parent

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = questFrame

	-- Ícono
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 50, 0, 50)
	iconLabel.Position = UDim2.new(0, 10, 0.5, -25)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = quest.Icon
	iconLabel.TextSize = 32
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = questFrame

	-- Nombre de la misión
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -140, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = questFrame

	-- Descripción
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -140, 0, 15)
	descLabel.Position = UDim2.new(0, 70, 0, 32)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = quest.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Parent = questFrame

	-- Barra de progreso de fondo
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -80, 0, 8)
	progressBg.Position = UDim2.new(0, 70, 1, -20)
	progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = questFrame

	local progressBgCorner = Instance.new("UICorner")
	progressBgCorner.CornerRadius = UDim.new(0, 4)
	progressBgCorner.Parent = progressBg

	-- Barra de progreso
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	local progressPercent = math.clamp(quest.Progress / quest.Goal, 0, 1)
	progressBar.Size = UDim2.new(progressPercent, 0, 1, 0)
	progressBar.BackgroundColor3 = quest.Completed and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(52, 152, 219)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBg

	local progressBarCorner = Instance.new("UICorner")
	progressBarCorner.CornerRadius = UDim.new(0, 4)
	progressBarCorner.Parent = progressBar

	-- Texto de progreso
	local progressText = Instance.new("TextLabel")
	progressText.Name = "ProgressText"
	progressText.Size = UDim2.new(1, 0, 1, 0)
	progressText.BackgroundTransparency = 1
	progressText.Text = quest.Progress .. "/" .. quest.Goal
	progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressText.TextSize = 11
	progressText.Font = Enum.Font.GothamBold
	progressText.Parent = progressBg

	-- Recompensa
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0, 60, 0, 20)
	rewardLabel.Position = UDim2.new(1, -70, 0, 10)
	rewardLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	rewardLabel.BorderSizePixel = 0
	rewardLabel.Text = "+$" .. quest.Reward
	rewardLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	rewardLabel.TextSize = 14
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.Parent = questFrame

	local rewardCorner = Instance.new("UICorner")
	rewardCorner.CornerRadius = UDim.new(0, 5)
	rewardCorner.Parent = rewardLabel

	-- Marca de completado
	if quest.Completed then
		local checkMark = Instance.new("TextLabel")
		checkMark.Size = UDim2.new(0, 30, 0, 30)
		checkMark.Position = UDim2.new(1, -40, 0.5, -15)
		checkMark.BackgroundTransparency = 1
		checkMark.Text = "✓"
		checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkMark.TextSize = 24
		checkMark.Font = Enum.Font.GothamBold
		checkMark.Parent = questFrame
	end

	return questFrame
end

--[[
    Función: Actualizar panel de misiones
    Parámetros: quests - Array de misiones
--]]
local function updateQuestPanel(quests)
	if not questPanel then return end

	local questList = questPanel:FindFirstChild("QuestList")
	if not questList then return end

	-- Limpiar misiones anteriores
	for _, child in pairs(questList:GetChildren()) do
		if child.Name:match("Quest_") then
			child:Destroy()
		end
	end

	-- Crear elementos de misión
	for index, quest in ipairs(quests) do
		createQuestItem(quest, index, questList)
	end
end

--[[
    Función: Crear UI de misiones
--]]
local function createQuestUI()
	-- Crear ScreenGui principal
	questGui = Instance.new("ScreenGui")
	questGui.Name = "QuestGui"
	questGui.ResetOnSpawn = false
	questGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	questGui.Parent = playerGui

	-- Botón para abrir/cerrar panel
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 60, 0, 60)
	toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
	toggleButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "📋"
	toggleButton.TextSize = 32
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Parent = questGui

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleButton

	-- Panel de misiones
	questPanel = Instance.new("Frame")
	questPanel.Name = "QuestPanel"
	questPanel.Size = UDim2.new(0, 400, 0, 350)
	questPanel.Position = UDim2.new(0, -420, 0.5, -175)
	questPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	questPanel.BorderSizePixel = 0
	questPanel.Parent = questGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 15)
	panelCorner.Parent = questPanel

	-- Barra de título
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = questPanel

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 15)
	titleCorner.Parent = titleBar

	-- Título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "📋 MISIONES"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 22
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Lista de misiones
	local questList = Instance.new("Frame")
	questList.Name = "QuestList"
	questList.Size = UDim2.new(1, 0, 1, -60)
	questList.Position = UDim2.new(0, 0, 0, 60)
	questList.BackgroundTransparency = 1
	questList.Parent = questPanel

	-- Evento del botón toggle
	toggleButton.MouseButton1Click:Connect(function()
		isPanelOpen = not isPanelOpen

		local targetPosition
		if isPanelOpen then
			targetPosition = UDim2.new(0, 100, 0.5, -175)
		else
			targetPosition = UDim2.new(0, -420, 0.5, -175)
		end

		local tween = TweenService:Create(
			questPanel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = targetPosition}
		)
		tween:Play()
	end)

	-- Efecto hover en botón
	toggleButton.MouseEnter:Connect(function()
		toggleButton.BackgroundColor3 = Color3.fromRGB(70, 170, 240)
	end)

	toggleButton.MouseLeave:Connect(function()
		toggleButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
	end)
end

--[[
    Función: Animación de misión completada
    Parámetros: quest - La misión completada
--]]
local function showQuestCompleteAnimation(quest)
	-- Crear notificación especial
	local completeGui = Instance.new("ScreenGui")
	completeGui.Name = "QuestCompleteGui"
	completeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	completeGui.DisplayOrder = 200
	completeGui.Parent = playerGui

	local completeFrame = Instance.new("Frame")
	completeFrame.Size = UDim2.new(0, 400, 0, 100)
	completeFrame.Position = UDim2.new(0.5, -200, 0.5, -50)
	completeFrame.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
	completeFrame.BorderSizePixel = 0
	completeFrame.Parent = completeGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = completeFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.Position = UDim2.new(0, 0, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎉 ¡MISIÓN COMPLETADA! 🎉"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 20
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = completeFrame

	local questLabel = Instance.new("TextLabel")
	questLabel.Size = UDim2.new(1, 0, 0, 25)
	questLabel.Position = UDim2.new(0, 0, 0, 45)
	questLabel.BackgroundTransparency = 1
	questLabel.Text = quest.Icon .. " " .. quest.Name
	questLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	questLabel.TextSize = 18
	questLabel.Font = Enum.Font.Gotham
	questLabel.Parent = completeFrame

	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(1, 0, 0, 20)
	rewardLabel.Position = UDim2.new(0, 0, 0, 75)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = "Recompensa: +$" .. quest.Reward
	rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	rewardLabel.TextSize = 16
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.Parent = completeFrame

	-- Animación
	completeFrame.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(
		completeFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 400, 0, 100)}
	)
	tween:Play()

	-- Destruir después de 3 segundos
	task.delay(3, function()
		local fadeTween = TweenService:Create(
			completeFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Linear),
			{BackgroundTransparency = 1}
		)
		fadeTween:Play()

		for _, child in pairs(completeFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				TweenService:Create(
					child,
					TweenInfo.new(0.3, Enum.EasingStyle.Linear),
					{TextTransparency = 1}
				):Play()
			end
		end

		task.wait(0.3)
		completeGui:Destroy()
	end)
end

-- Crear la UI cuando el script se carga
createQuestUI()

-- Escuchar actualizaciones de misiones
questUpdateEvent.OnClientEvent:Connect(function(quests)
	currentQuests = quests
	updateQuestPanel(quests)
end)

-- Escuchar misiones completadas
questCompleteEvent.OnClientEvent:Connect(function(quest)
	showQuestCompleteAnimation(quest)
	task.wait(0.5)
	updateQuestPanel(currentQuests)
end)

print("📋 UI de misiones cargada correctamente")
