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

	-- Ícono (responsive)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0.15, 0, 0.6, 0)
	iconLabel.Position = UDim2.new(0.02, 0, 0.2, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = quest.Icon
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = questFrame

	-- Nombre de la misión (responsive)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, 0, 0.25, 0)
	nameLabel.Position = UDim2.new(0.2, 0, 0.1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = questFrame

	-- Descripción (responsive)
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
	descLabel.Position = UDim2.new(0.2, 0, 0.35, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = quest.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextScaled = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Parent = questFrame

	-- Barra de progreso de fondo (responsive)
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(0.75, 0, 0.12, 0)
	progressBg.Position = UDim2.new(0.2, 0, 0.75, 0)
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

	-- Texto de progreso (responsive)
	local progressText = Instance.new("TextLabel")
	progressText.Name = "ProgressText"
	progressText.Size = UDim2.new(1, 0, 1, 0)
	progressText.BackgroundTransparency = 1
	progressText.Text = quest.Progress .. "/" .. quest.Goal
	progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressText.TextScaled = true
	progressText.Font = Enum.Font.GothamBold
	progressText.Parent = progressBg

	-- Recompensa (responsive)
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0.18, 0, 0.25, 0)
	rewardLabel.Position = UDim2.new(0.8, 0, 0.1, 0)
	rewardLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	rewardLabel.BorderSizePixel = 0
	rewardLabel.Text = "+$" .. quest.Reward
	rewardLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	rewardLabel.TextScaled = true
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.Parent = questFrame

	local rewardCorner = Instance.new("UICorner")
	rewardCorner.CornerRadius = UDim.new(0, 5)
	rewardCorner.Parent = rewardLabel

	-- Marca de completado (responsive)
	if quest.Completed then
		local checkMark = Instance.new("TextLabel")
		checkMark.Size = UDim2.new(0.1, 0, 0.35, 0)
		checkMark.Position = UDim2.new(0.88, 0, 0.55, 0)
		checkMark.BackgroundTransparency = 1
		checkMark.Text = "✓"
		checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkMark.TextScaled = true
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

	-- Botón para abrir/cerrar panel (responsive)
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0.05, 0, 0.08, 0)
	toggleButton.Position = UDim2.new(0.96, 0, 0.5, 0)
	toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
	toggleButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "📋"
	toggleButton.TextScaled = true
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Parent = questGui

	-- Constraint para el botón
	local buttonConstraint = Instance.new("UISizeConstraint")
	buttonConstraint.MinSize = Vector2.new(50, 50)
	buttonConstraint.MaxSize = Vector2.new(70, 70)
	buttonConstraint.Parent = toggleButton

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleButton

	-- Panel de misiones (responsive)
	questPanel = Instance.new("Frame")
	questPanel.Name = "QuestPanel"
	questPanel.Size = UDim2.new(0.25, 0, 0.38, 0)
	questPanel.Position = UDim2.new(1, 20, 0.5, 0)
	questPanel.AnchorPoint = Vector2.new(0, 0.5)
	questPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	questPanel.BorderSizePixel = 0
	questPanel.Parent = questGui

	-- Constraint para el panel
	local panelConstraint = Instance.new("UISizeConstraint")
	panelConstraint.MinSize = Vector2.new(220, 240)
	panelConstraint.MaxSize = Vector2.new(380, 420)
	panelConstraint.Parent = questPanel

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

	-- Título (responsive)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.95, 0, 0.9, 0)
	titleLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "📋 MISIONES"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
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

	-- Evento del botón toggle (responsive)
	toggleButton.MouseButton1Click:Connect(function()
		isPanelOpen = not isPanelOpen

		local targetPosition
		if isPanelOpen then
			targetPosition = UDim2.new(0.73, 0, 0.5, 0)
		else
			targetPosition = UDim2.new(1, 20, 0.5, 0)
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
	completeFrame.Size = UDim2.new(0.25, 0, 0.11, 0)
	completeFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	completeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	completeFrame.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
	completeFrame.BorderSizePixel = 0
	completeFrame.Parent = completeGui

	-- Constraint para la notificación de completado
	local completeConstraint = Instance.new("UISizeConstraint")
	completeConstraint.MinSize = Vector2.new(240, 80)
	completeConstraint.MaxSize = Vector2.new(420, 120)
	completeConstraint.Parent = completeFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = completeFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.95, 0, 0.3, 0)
	titleLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎉 ¡MISIÓN COMPLETADA! 🎉"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = completeFrame

	local questLabel = Instance.new("TextLabel")
	questLabel.Size = UDim2.new(0.95, 0, 0.28, 0)
	questLabel.Position = UDim2.new(0.025, 0, 0.4, 0)
	questLabel.BackgroundTransparency = 1
	questLabel.Text = quest.Icon .. " " .. quest.Name
	questLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	questLabel.TextScaled = true
	questLabel.Font = Enum.Font.Gotham
	questLabel.Parent = completeFrame

	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0.95, 0, 0.22, 0)
	rewardLabel.Position = UDim2.new(0.025, 0, 0.73, 0)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = "Recompensa: +$" .. quest.Reward
	rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	rewardLabel.TextScaled = true
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.Parent = completeFrame

	-- Animación (responsive)
	completeFrame.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(
		completeFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0.25, 0, 0.11, 0)}
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
