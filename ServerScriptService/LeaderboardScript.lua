--[[
═══════════════════════════════════════════════════════════════
    LEADERBOARD SCRIPT - Tabla de Clasificación Global
    Ubicación: ServerScriptService

    Cómo usar:
    1. Crea una Part en Workspace y nómbrala "LeaderboardDisplay"
    2. Este script creará automáticamente el SurfaceGui
    3. Se actualiza cada 10 segundos

    Funcionalidad:
    - Muestra los top jugadores con más dinero
    - Actualización automática
    - Diseño visual atractivo
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")

-- CONFIGURACIÓN
local UPDATE_INTERVAL = 10 -- Actualizar cada 10 segundos
local TOP_PLAYERS_COUNT = 10 -- Número de jugadores a mostrar

--[[
    Función: Obtener top jugadores por dinero
    Retorna: Array de jugadores ordenados por dinero
--]]
local function getTopPlayers()
	local playerList = {}

	-- Recolectar todos los jugadores con su dinero
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				table.insert(playerList, {
					Name = player.Name,
					Money = money.Value,
					DisplayName = player.DisplayName
				})
			end
		end
	end

	-- Ordenar por dinero (de mayor a menor)
	table.sort(playerList, function(a, b)
		return a.Money > b.Money
	end)

	-- Retornar solo los top jugadores
	local topPlayers = {}
	for i = 1, math.min(TOP_PLAYERS_COUNT, #playerList) do
		table.insert(topPlayers, playerList[i])
	end

	return topPlayers
end

--[[
    Función: Crear la UI del leaderboard
    Parámetros: part - La part donde se mostrará el leaderboard
--]]
local function createLeaderboardUI(part)
	-- Limpiar SurfaceGui existente
	local existingGui = part:FindFirstChild("LeaderboardGui")
	if existingGui then
		existingGui:Destroy()
	end

	-- Crear SurfaceGui
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "LeaderboardGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(800, 1000)
	surfaceGui.LightInfluence = 0
	surfaceGui.Parent = part

	-- Frame principal
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = surfaceGui

	-- Barra de título
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 100)
	titleBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	-- Título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🏆 TOP JUGADORES 🏆"
	titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextSize = 50
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.Parent = titleBar

	-- ScrollingFrame para la lista
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, -40, 1, -140)
	scrollFrame.Position = UDim2.new(0, 20, 0, 120)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 10
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
	scrollFrame.Parent = mainFrame

	-- Layout para los jugadores
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = scrollFrame

	return surfaceGui, scrollFrame
end

--[[
    Función: Actualizar el leaderboard
    Parámetros: scrollFrame - El frame donde se mostrarán los jugadores
--]]
local function updateLeaderboard(scrollFrame)
	-- Limpiar contenido anterior
	for _, child in pairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Obtener top jugadores
	local topPlayers = getTopPlayers()

	-- Crear entrada para cada jugador
	for rank, playerData in ipairs(topPlayers) do
		-- Frame del jugador
		local playerFrame = Instance.new("Frame")
		playerFrame.Name = "Player_" .. rank
		playerFrame.Size = UDim2.new(1, 0, 0, 70)
		playerFrame.LayoutOrder = rank
		playerFrame.BorderSizePixel = 0
		playerFrame.Parent = scrollFrame

		-- Color según ranking
		if rank == 1 then
			playerFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Oro
		elseif rank == 2 then
			playerFrame.BackgroundColor3 = Color3.fromRGB(192, 192, 192) -- Plata
		elseif rank == 3 then
			playerFrame.BackgroundColor3 = Color3.fromRGB(205, 127, 50) -- Bronce
		else
			playerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Normal
		end

		-- Esquinas redondeadas
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = playerFrame

		-- Número de ranking
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, 80, 1, 0)
		rankLabel.Position = UDim2.new(0, 10, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. rank
		rankLabel.TextSize = 40
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = playerFrame

		-- Color del texto según ranking
		if rank <= 3 then
			rankLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- Nombre del jugador
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 400, 1, 0)
		nameLabel.Position = UDim2.new(0, 100, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = playerData.Name
		nameLabel.TextSize = 30
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = playerFrame

		if rank <= 3 then
			nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- Dinero
		local moneyLabel = Instance.new("TextLabel")
		moneyLabel.Size = UDim2.new(0, 200, 1, 0)
		moneyLabel.Position = UDim2.new(1, -210, 0, 0)
		moneyLabel.BackgroundTransparency = 1
		moneyLabel.Text = "$" .. tostring(playerData.Money)
		moneyLabel.TextSize = 32
		moneyLabel.Font = Enum.Font.GothamBold
		moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
		moneyLabel.Parent = playerFrame

		if rank <= 3 then
			moneyLabel.TextColor3 = Color3.fromRGB(0, 100, 0)
		else
			moneyLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
		end
	end

	-- Actualizar tamaño del canvas
	local listLayout = scrollFrame:FindFirstChildOfClass("UIListLayout")
	if listLayout then
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
	end
end

--[[
    Función: Configurar un leaderboard
    Parámetros: part - La part del leaderboard
--]]
local function setupLeaderboard(part)
	-- Crear UI
	local surfaceGui, scrollFrame = createLeaderboardUI(part)

	-- Actualizar inmediatamente
	updateLeaderboard(scrollFrame)

	-- Actualizar periódicamente
	spawn(function()
		while part and part.Parent do
			wait(UPDATE_INTERVAL)
			if scrollFrame and scrollFrame.Parent then
				updateLeaderboard(scrollFrame)
			else
				break
			end
		end
	end)

	print("Leaderboard configurado: " .. part:GetFullName())
end

--[[
    Buscar y configurar todos los leaderboards en Workspace
--]]
local function findAndSetupLeaderboards()
	for _, obj in pairs(game.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "LeaderboardDisplay" then
			setupLeaderboard(obj)
		end
	end
end

-- Configurar leaderboards existentes
findAndSetupLeaderboards()

-- Configurar nuevos leaderboards que se añadan
game.Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "LeaderboardDisplay" then
		setupLeaderboard(obj)
	end
end)

-- Actualizar todos los leaderboards cuando cambia el dinero
Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if leaderstats then
		local money = leaderstats:WaitForChild("Money", 10)
		if money then
			money.Changed:Connect(function()
				-- Actualizar todos los leaderboards
				for _, obj in pairs(game.Workspace:GetDescendants()) do
					if obj:IsA("SurfaceGui") and obj.Name == "LeaderboardGui" then
						local scrollFrame = obj:FindFirstChild("MainFrame")
						if scrollFrame then
							scrollFrame = scrollFrame:FindFirstChild("ScrollFrame")
							if scrollFrame then
								updateLeaderboard(scrollFrame)
							end
						end
					end
				end
			end)
		end
	end
end)

print("Sistema de leaderboard inicializado")
