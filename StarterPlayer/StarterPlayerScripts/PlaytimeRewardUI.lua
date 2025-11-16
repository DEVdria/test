--[[
═══════════════════════════════════════════════════════════════
    PLAYTIME REWARD UI - Interfaz de Recompensas por Tiempo
    Ubicación: StarterPlayer > StarterPlayerScripts

    Funcionalidad:
    - Botón al lado del display de dinero
    - Panel con recompensas por tiempo jugado
    - Muestra tiempo total jugado
    - Permite reclamar recompensas desbloqueadas
    - Totalmente responsive para todos los dispositivos
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a RemoteEvents
local getRewardsEvent = ReplicatedStorage:WaitForChild("GetPlaytimeRewards")
local claimRewardEvent = ReplicatedStorage:WaitForChild("ClaimPlaytimeReward")
local updatePlaytimeEvent = ReplicatedStorage:WaitForChild("UpdatePlaytime")

-- Variables globales
local rewardGui = nil
local rewardPanel = nil
local isPanelOpen = false
local currentPlaytime = 0
local currentRewards = {}

--[[
    Función: Formatear segundos a texto legible
    Parámetros: seconds - Segundos totales
    Retorna: String formateado (ej: "1h 23m")
--]]
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)

	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	else
		return string.format("%dm", minutes)
	end
end

--[[
    Función: Crear elemento de recompensa
    Parámetros:
        reward - Datos de la recompensa
        parent - Frame padre
--]]
local function createRewardItem(reward, parent)
	-- Frame de la recompensa (responsive)
	local rewardFrame = Instance.new("Frame")
	rewardFrame.Name = "Reward_" .. reward.Index
	rewardFrame.Size = UDim2.new(1, -20, 0, 90)
	rewardFrame.BackgroundColor3 = reward.IsClaimed and Color3.fromRGB(40, 40, 40) or (reward.CanClaim and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(50, 50, 50))
	rewardFrame.BorderSizePixel = 0
	rewardFrame.Parent = parent

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = rewardFrame

	-- Ícono (responsive)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0.12, 0, 0.5, 0)
	iconLabel.Position = UDim2.new(0.02, 0, 0.25, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = reward.Icon
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = rewardFrame

	-- Tiempo requerido (responsive)
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
	timeLabel.Position = UDim2.new(0.16, 0, 0.15, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = reward.Time .. " Minutos"
	timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timeLabel.TextScaled = true
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeLabel.Parent = rewardFrame

	-- Recompensa (responsive)
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0.3, 0, 0.35, 0)
	rewardLabel.Position = UDim2.new(0.16, 0, 0.5, 0)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = "💰 $" .. reward.Reward
	rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	rewardLabel.TextScaled = true
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardLabel.Parent = rewardFrame

	-- Botón de reclamar o estado (responsive)
	if reward.IsClaimed then
		-- Marca de completado
		local claimedLabel = Instance.new("TextLabel")
		claimedLabel.Size = UDim2.new(0.25, 0, 0.5, 0)
		claimedLabel.Position = UDim2.new(0.7, 0, 0.25, 0)
		claimedLabel.BackgroundTransparency = 1
		claimedLabel.Text = "✓ RECLAMADO"
		claimedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		claimedLabel.TextScaled = true
		claimedLabel.Font = Enum.Font.GothamBold
		claimedLabel.Parent = rewardFrame

	elseif reward.CanClaim then
		-- Botón para reclamar
		local claimButton = Instance.new("TextButton")
		claimButton.Name = "ClaimButton"
		claimButton.Size = UDim2.new(0.28, 0, 0.6, 0)
		claimButton.Position = UDim2.new(0.68, 0, 0.2, 0)
		claimButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		claimButton.BorderSizePixel = 0
		claimButton.Text = "RECLAMAR"
		claimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		claimButton.TextScaled = true
		claimButton.Font = Enum.Font.GothamBold
		claimButton.Parent = rewardFrame

		local claimCorner = Instance.new("UICorner")
		claimCorner.CornerRadius = UDim.new(0, 8)
		claimCorner.Parent = claimButton

		-- Efecto hover
		claimButton.MouseEnter:Connect(function()
			claimButton.BackgroundColor3 = Color3.fromRGB(60, 220, 130)
		end)

		claimButton.MouseLeave:Connect(function()
			claimButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		end)

		-- Evento de reclamar
		claimButton.MouseButton1Click:Connect(function()
			claimButton.Text = "..."
			claimButton.Active = false
			claimRewardEvent:FireServer(reward.Index)
		end)

	else
		-- Bloqueado
		local lockedLabel = Instance.new("TextLabel")
		lockedLabel.Size = UDim2.new(0.25, 0, 0.5, 0)
		lockedLabel.Position = UDim2.new(0.7, 0, 0.25, 0)
		lockedLabel.BackgroundTransparency = 1
		lockedLabel.Text = "🔒 BLOQUEADO"
		lockedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		lockedLabel.TextScaled = true
		lockedLabel.Font = Enum.Font.GothamBold
		lockedLabel.Parent = rewardFrame
	end

	-- Barra de progreso si está desbloqueado pero no reclamado
	if reward.IsUnlocked and not reward.IsClaimed then
		local progressFrame = Instance.new("Frame")
		progressFrame.Size = UDim2.new(0.95, 0, 0.06, 0)
		progressFrame.Position = UDim2.new(0.025, 0, 0.88, 0)
		progressFrame.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		progressFrame.BorderSizePixel = 0
		progressFrame.Parent = rewardFrame

		local progressCorner = Instance.new("UICorner")
		progressCorner.CornerRadius = UDim.new(0, 3)
		progressCorner.Parent = progressFrame
	end

	return rewardFrame
end

--[[
    Función: Actualizar panel de recompensas
    Parámetros:
        playtime - Tiempo total jugado en segundos
        rewards - Array de recompensas
--]]
local function updateRewardPanel(playtime, rewards)
	currentPlaytime = playtime
	currentRewards = rewards

	if not rewardPanel then return end

	-- Actualizar tiempo jugado
	local timeDisplay = rewardPanel:FindFirstChild("TimeDisplay")
	if timeDisplay then
		local timeLabel = timeDisplay:FindFirstChild("TimeLabel")
		if timeLabel then
			timeLabel.Text = formatTime(playtime)
		end
	end

	-- Actualizar lista de recompensas
	local rewardList = rewardPanel:FindFirstChild("RewardList")
	if rewardList then
		local scrollFrame = rewardList:FindFirstChild("ScrollFrame")
		if scrollFrame then
			-- Limpiar recompensas anteriores
			for _, child in pairs(scrollFrame:GetChildren()) do
				if child.Name:match("Reward_") then
					child:Destroy()
				end
			end

			-- Crear elementos de recompensa
			local yOffset = 0
			for _, reward in ipairs(rewards) do
				local rewardItem = createRewardItem(reward, scrollFrame)
				rewardItem.Position = UDim2.new(0, 10, 0, yOffset)
				yOffset = yOffset + 100
			end

			-- Actualizar tamaño del canvas
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
		end
	end
end

--[[
    Función: Crear UI de recompensas por tiempo
--]]
local function createPlaytimeRewardUI()
	-- Crear ScreenGui principal
	rewardGui = Instance.new("ScreenGui")
	rewardGui.Name = "PlaytimeRewardGui"
	rewardGui.ResetOnSpawn = false
	rewardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	rewardGui.Parent = playerGui

	-- Botón para abrir panel (responsive) - Al lado del MoneyUI
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0.08, 0, 0.08, 0)
	toggleButton.Position = UDim2.new(0.98, 0, 0.12, 0)
	toggleButton.AnchorPoint = Vector2.new(1, 0)
	toggleButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "🎁"
	toggleButton.TextScaled = true
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Parent = rewardGui

	-- Constraint para el botón
	local buttonConstraint = Instance.new("UISizeConstraint")
	buttonConstraint.MinSize = Vector2.new(60, 60)
	buttonConstraint.MaxSize = Vector2.new(100, 100)
	buttonConstraint.Parent = toggleButton

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleButton

	-- Panel de recompensas (responsive)
	rewardPanel = Instance.new("Frame")
	rewardPanel.Name = "RewardPanel"
	rewardPanel.Size = UDim2.new(0.35, 0, 0.65, 0)
	rewardPanel.Position = UDim2.new(1, 20, 0.5, 0)
	rewardPanel.AnchorPoint = Vector2.new(0, 0.5)
	rewardPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	rewardPanel.BorderSizePixel = 0
	rewardPanel.Parent = rewardGui

	-- Constraint para el panel
	local panelConstraint = Instance.new("UISizeConstraint")
	panelConstraint.MinSize = Vector2.new(350, 450)
	panelConstraint.MaxSize = Vector2.new(550, 700)
	panelConstraint.Parent = rewardPanel

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 15)
	panelCorner.Parent = rewardPanel

	-- Barra de título (responsive)
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 60)
	titleBar.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = rewardPanel

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 15)
	titleCorner.Parent = titleBar

	-- Título (responsive)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.85, 0, 0.9, 0)
	titleLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎁 RECOMPENSAS DE TIEMPO"
	titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Display de tiempo jugado (responsive)
	local timeDisplay = Instance.new("Frame")
	timeDisplay.Name = "TimeDisplay"
	timeDisplay.Size = UDim2.new(0.95, 0, 0, 70)
	timeDisplay.Position = UDim2.new(0.025, 0, 0, 70)
	timeDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	timeDisplay.BorderSizePixel = 0
	timeDisplay.Parent = rewardPanel

	local timeCorner = Instance.new("UICorner")
	timeCorner.CornerRadius = UDim.new(0, 10)
	timeCorner.Parent = timeDisplay

	local timeTitle = Instance.new("TextLabel")
	timeTitle.Size = UDim2.new(1, 0, 0.4, 0)
	timeTitle.Position = UDim2.new(0, 0, 0.1, 0)
	timeTitle.BackgroundTransparency = 1
	timeTitle.Text = "⏱️ TIEMPO TOTAL JUGADO"
	timeTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	timeTitle.TextScaled = true
	timeTitle.Font = Enum.Font.Gotham
	timeTitle.Parent = timeDisplay

	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "TimeLabel"
	timeLabel.Size = UDim2.new(1, 0, 0.45, 0)
	timeLabel.Position = UDim2.new(0, 0, 0.5, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = "0m"
	timeLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
	timeLabel.TextScaled = true
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.Parent = timeDisplay

	-- Lista de recompensas (responsive)
	local rewardList = Instance.new("Frame")
	rewardList.Name = "RewardList"
	rewardList.Size = UDim2.new(1, 0, 1, -150)
	rewardList.Position = UDim2.new(0, 0, 0, 150)
	rewardList.BackgroundTransparency = 1
	rewardList.Parent = rewardPanel

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = rewardList

	-- Evento del botón toggle (responsive)
	toggleButton.MouseButton1Click:Connect(function()
		isPanelOpen = not isPanelOpen

		local targetPosition
		if isPanelOpen then
			targetPosition = UDim2.new(0.63, 0, 0.5, 0)
			-- Solicitar actualización de datos
			getRewardsEvent:FireServer()
		else
			targetPosition = UDim2.new(1, 20, 0.5, 0)
		end

		local tween = TweenService:Create(
			rewardPanel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = targetPosition}
		)
		tween:Play()
	end)

	-- Efecto hover en botón
	toggleButton.MouseEnter:Connect(function()
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 205, 50)
	end)

	toggleButton.MouseLeave:Connect(function()
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	end)

	-- Animación de entrada del botón (responsive)
	toggleButton.Position = UDim2.new(1.2, 0, 0.12, 0)
	toggleButton:TweenPosition(
		UDim2.new(0.98, 0, 0.12, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)
end

-- Crear la UI cuando el script se carga
createPlaytimeRewardUI()

-- Escuchar actualizaciones de tiempo y recompensas
updatePlaytimeEvent.OnClientEvent:Connect(function(playtime, rewards)
	updateRewardPanel(playtime, rewards)
end)

-- Solicitar datos iniciales
task.wait(2)
getRewardsEvent:FireServer()

print("🎁 UI de recompensas por tiempo cargada correctamente")
