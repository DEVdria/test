--[[
	LeaderboardClient.lua
	UBICACIÓN: StarterGui > LeaderboardUI > LeaderboardClient (LocalScript)

	DESCRIPCIÓN:
	Este script muestra el leaderboard global en la UI del cliente.
	Se actualiza automáticamente cada cierto tiempo.

	REQUISITOS:
	- Debe estar dentro de un ScreenGui llamado "LeaderboardUI"
	- El ScreenGui debe tener:
		* Frame principal llamado "LeaderboardFrame"
		* ScrollingFrame llamado "PlayersContainer" (para la lista)
		* TextLabel llamado "TitleLabel" (título del leaderboard)

	FUNCIONES:
	- Muestra el top de jugadores con más dinero
	- Se actualiza automáticamente cada 30 segundos
	- Resalta al jugador local en el leaderboard si está en el top
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Esperar a RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getLeaderboardRemote = remoteEvents:WaitForChild("GetLeaderboard")

-- Referencias a la UI
local screenGui = script.Parent
local leaderboardFrame = screenGui:WaitForChild("LeaderboardFrame")
local playersContainer = leaderboardFrame:WaitForChild("PlayersContainer")
local titleLabel = leaderboardFrame:WaitForChild("TitleLabel")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	UpdateInterval = 30, -- Actualizar cada 30 segundos
	AnimateEntries = true, -- Animar las entradas
}

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
	@param rank - El puesto del jugador
	@return Color3 - El color del ranking
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
	@param rank - El puesto del jugador
	@return string - El emoji del ranking
]]
local function getRankEmoji(rank)
	if rank == 1 then
		return "🥇"
	elseif rank == 2 then
		return "🥈"
	elseif rank == 3 then
		return "🥉"
	else
		return "🏆"
	end
end

--[[
	Función: createPlayerEntry
	Crea una entrada en el leaderboard para un jugador
	@param playerData - Datos del jugador {Rank, Name, Money, UserId}
	@return Frame - El frame de la entrada
]]
local function createPlayerEntry(playerData)
	local isLocalPlayer = playerData.UserId == player.UserId

	-- Frame de la entrada
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Entry_" .. playerData.Rank
	entryFrame.Size = UDim2.new(1, -10, 0, 50)
	entryFrame.BackgroundColor3 = isLocalPlayer and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(40, 40, 40)
	entryFrame.BorderSizePixel = 0

	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = entryFrame

	-- Rank Label
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Name = "RankLabel"
	rankLabel.Size = UDim2.new(0, 60, 1, 0)
	rankLabel.Position = UDim2.new(0, 5, 0, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = getRankEmoji(playerData.Rank) .. " #" .. playerData.Rank
	rankLabel.TextColor3 = getRankColor(playerData.Rank)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.Parent = entryFrame

	-- Name Label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.5, -70, 1, 0)
	nameLabel.Position = UDim2.new(0, 70, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entryFrame

	-- Money Label
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(0.5, -10, 1, 0)
	moneyLabel.Position = UDim2.new(0.5, 0, 0, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "💰 $" .. formatNumber(playerData.Money)
	moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
	moneyLabel.Parent = entryFrame

	-- Efecto de resaltado para el jugador local
	if isLocalPlayer then
		-- Agregar borde brillante
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(100, 200, 255)
		stroke.Thickness = 2
		stroke.Parent = entryFrame
	end

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
		warn("[LeaderboardClient] Error al obtener leaderboard: " .. tostring(leaderboardData))
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
		local entry = createPlayerEntry(playerData)
		entry.Parent = playersContainer

		-- Animación de entrada (opcional)
		if CONFIG.AnimateEntries then
			entry.BackgroundTransparency = 1
			entry.Size = UDim2.new(1, -10, 0, 0)

			local targetSize = UDim2.new(1, -10, 0, 50)

			-- Animar con TweenService
			local TweenService = game:GetService("TweenService")
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local tween = TweenService:Create(entry, tweenInfo, {
				Size = targetSize,
				BackgroundTransparency = 0
			})

			tween:Play()
		end
	end

	-- Configurar UIListLayout si no existe
	if not playersContainer:FindFirstChildOfClass("UIListLayout") then
		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.Name
		listLayout.Padding = UDim.new(0, 5)
		listLayout.Parent = playersContainer
	end

	print("[LeaderboardClient] Leaderboard actualizado con " .. #leaderboardData .. " jugadores")
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

-- Actualizar por primera vez
task.wait(2) -- Esperar un poco para que todo esté cargado
updateLeaderboard()

-- Actualizar periódicamente
task.spawn(function()
	while true do
		task.wait(CONFIG.UpdateInterval)
		updateLeaderboard()
	end
end)

print("[LeaderboardClient] Sistema de leaderboard del cliente inicializado")
