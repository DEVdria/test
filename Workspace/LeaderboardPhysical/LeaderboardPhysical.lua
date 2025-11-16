--[[
	LeaderboardPhysical.lua
	UBICACIÓN: Workspace > LeaderboardBoard > LeaderboardPhysical (Script)

	DESCRIPCIÓN:
	Este script maneja un leaderboard físico en el mundo del juego.
	Muestra el top de jugadores en una pantalla usando SurfaceGui.

	REQUISITOS:
	- Debe estar dentro de una Part llamada "LeaderboardBoard"
	- La Part debe tener un SurfaceGui en una de sus caras
	- El SurfaceGui debe tener un Frame llamado "MainFrame"

	FUNCIONES:
	- Actualiza automáticamente el top de jugadores
	- Muestra medallas para los primeros 3 lugares
	- Formato con separadores de miles
	- Se actualiza cada 30 segundos
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	UpdateInterval = 30, -- Actualizar cada 30 segundos
	PlayersToShow = 10,  -- Número de jugadores a mostrar
	AnimateEntries = false, -- No animar en servidor
}

-- ═══════════════════════════════════════════════════════════
-- REFERENCIAS
-- ═══════════════════════════════════════════════════════════

-- Obtener la Part que contiene este script
local leaderboardPart = script.Parent
if not leaderboardPart:IsA("BasePart") then
	error("[LeaderboardPhysical] Este script debe estar dentro de una Part")
end

-- Esperar al RemoteFunction
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
	error("[LeaderboardPhysical] No se encontró RemoteEvents en ReplicatedStorage")
end

local getLeaderboardRemote = remoteEvents:WaitForChild("GetLeaderboard", 10)
if not getLeaderboardRemote then
	error("[LeaderboardPhysical] No se encontró GetLeaderboard RemoteFunction")
end

-- Buscar o crear SurfaceGui
local surfaceGui = leaderboardPart:FindFirstChildOfClass("SurfaceGui")
if not surfaceGui then
	surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "LeaderboardGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(800, 1000)
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 1.5
	surfaceGui.Parent = leaderboardPart
end

-- Buscar o crear Frame principal
local mainFrame = surfaceGui:FindFirstChild("MainFrame")
if not mainFrame then
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BackgroundTransparency = 0
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = surfaceGui
end

-- Crear título si no existe
local titleLabel = mainFrame:FindFirstChild("TitleLabel")
if not titleLabel then
	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Text = "🏆 TOP JUGADORES 🏆"
	titleLabel.Size = UDim2.new(1, 0, 0, 80)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.BackgroundTransparency = 0
	titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextSize = 48
	titleLabel.BorderSizePixel = 0

	-- UIPadding para el título
	local titlePadding = Instance.new("UIPadding")
	titlePadding.PaddingLeft = UDim.new(0, 20)
	titlePadding.PaddingRight = UDim.new(0, 20)
	titlePadding.Parent = titleLabel

	titleLabel.Parent = mainFrame
end

-- Crear contenedor de jugadores si no existe
local playersContainer = mainFrame:FindFirstChild("PlayersContainer")
if not playersContainer then
	playersContainer = Instance.new("Frame")
	playersContainer.Name = "PlayersContainer"
	playersContainer.Size = UDim2.new(1, -40, 1, -100)
	playersContainer.Position = UDim2.new(0, 20, 0, 90)
	playersContainer.BackgroundTransparency = 1
	playersContainer.Parent = mainFrame

	-- UIListLayout
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = playersContainer
end

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

--[[
	Función: formatNumber
	Formatea un número con separadores de miles
]]
local function formatNumber(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

--[[
	Función: getRankColor
	Obtiene el color según el ranking
]]
local function getRankColor(rank)
	if rank == 1 then
		return Color3.fromRGB(255, 215, 0) -- Oro
	elseif rank == 2 then
		return Color3.fromRGB(192, 192, 192) -- Plata
	elseif rank == 3 then
		return Color3.fromRGB(205, 127, 50) -- Bronce
	else
		return Color3.fromRGB(255, 255, 255) -- Blanco
	end
end

--[[
	Función: getRankEmoji
	Obtiene el emoji según el ranking
]]
local function getRankEmoji(rank)
	if rank == 1 then
		return "🥇"
	elseif rank == 2 then
		return "🥈"
	elseif rank == 3 then
		return "🥉"
	else
		return tostring(rank) .. "."
	end
end

--[[
	Función: createPlayerEntry
	Crea una entrada en el leaderboard para un jugador
]]
local function createPlayerEntry(playerData)
	-- Frame de la entrada
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Entry_" .. playerData.Rank
	entryFrame.Size = UDim2.new(1, 0, 0, 70)
	entryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	entryFrame.BorderSizePixel = 0

	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.15, 0)
	corner.Parent = entryFrame

	-- Rank Label
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Name = "RankLabel"
	rankLabel.Size = UDim2.new(0, 100, 1, 0)
	rankLabel.Position = UDim2.new(0, 10, 0, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = getRankEmoji(playerData.Rank)
	rankLabel.TextColor3 = getRankColor(playerData.Rank)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.TextSize = 36
	rankLabel.Parent = entryFrame

	-- Name Label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0, 350, 1, 0)
	nameLabel.Position = UDim2.new(0, 120, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 28
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entryFrame

	-- Money Label
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(0, 280, 1, 0)
	moneyLabel.Position = UDim2.new(1, -290, 0, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "💰 $" .. formatNumber(playerData.Money)
	moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextSize = 28
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
	moneyLabel.Parent = entryFrame

	return entryFrame
end

--[[
	Función: updateLeaderboard
	Actualiza el leaderboard con datos del servidor
]]
local function updateLeaderboard()
	-- Obtener datos del servidor
	local success, leaderboardData = pcall(function()
		return getLeaderboardRemote:InvokeServer()
	end)

	if not success then
		warn("[LeaderboardPhysical] Error al obtener leaderboard: " .. tostring(leaderboardData))
		return
	end

	-- Limpiar entradas existentes
	for _, child in ipairs(playersContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("^Entry_") then
			child:Destroy()
		end
	end

	-- Crear nuevas entradas
	for _, playerData in ipairs(leaderboardData) do
		if playerData.Rank <= CONFIG.PlayersToShow then
			local entry = createPlayerEntry(playerData)
			entry.Parent = playersContainer
		end
	end

	print("[LeaderboardPhysical] Leaderboard actualizado con " .. #leaderboardData .. " jugadores")
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

-- Actualizar por primera vez
task.wait(2)
updateLeaderboard()

-- Actualizar periódicamente
task.spawn(function()
	while true do
		task.wait(CONFIG.UpdateInterval)
		updateLeaderboard()
	end
end)

print("[LeaderboardPhysical] Leaderboard físico inicializado en: " .. leaderboardPart:GetFullName())
