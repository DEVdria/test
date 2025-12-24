-- ServerScriptService > RankTitleManager (Script)
-- Gestiona los títulos de rango sobre la cabeza de los jugadores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar módulo de configuración
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
if not Modules then
	warn("[RankTitleManager] ❌ No se encontró carpeta Modules")
	return
end

local RankConfig = require(Modules:WaitForChild("RankConfig", 10))
if not RankConfig then
	warn("[RankTitleManager] ❌ No se pudo cargar RankConfig")
	return
end

print("[RankTitleManager] ✅ RankConfig cargado")

-- Esperar DataManager
repeat task.wait(0.1) until _G.DataManager
local DataManager = _G.DataManager

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

-- Crea un BillboardGui con el título de rango sobre la cabeza del jugador
local function createRankTitle(character, rankInfo)
	local head = character:FindFirstChild("Head")
	if not head then
		warn("[RankTitleManager] ⚠️ No se encontró la cabeza del personaje")
		return nil
	end

	-- Eliminar título anterior si existe
	local existingTitle = head:FindFirstChild("RankTitle")
	if existingTitle then
		existingTitle:Destroy()
	end

	-- Crear BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RankTitle"
	billboard.Size = RankConfig.Visual.Size
	billboard.StudsOffset = Vector3.new(0, RankConfig.Visual.YOffset, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = math.huge  -- Visible a cualquier distancia
	billboard.Parent = head

	-- Crear TextLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TitleText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = RankConfig.Visual.BackgroundTransparency
	textLabel.Text = rankInfo.Title
	textLabel.Font = RankConfig.Visual.Font
	textLabel.TextSize = RankConfig.Visual.TextSize
	textLabel.TextColor3 = rankInfo.TextColor
	textLabel.TextStrokeColor3 = rankInfo.TextStrokeColor
	textLabel.TextStrokeTransparency = RankConfig.Visual.TextStrokeTransparency
	textLabel.TextScaled = true  -- Escala el texto para llenar el espacio disponible
	textLabel.Parent = billboard

	print(string.format("[RankTitleManager] 📝 Título creado: '%s' (Nivel %d)", rankInfo.Title, rankInfo.Level))
	return billboard
end

-- Actualiza el título de rango de un jugador
local function updateRankTitle(player, level)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Obtener información del rango
	local rankInfo = RankConfig.GetRankInfo(level)

	-- Buscar título existente
	local existingBillboard = head:FindFirstChild("RankTitle")
	if existingBillboard then
		local textLabel = existingBillboard:FindFirstChild("TitleText")
		if textLabel then
			-- Actualizar texto y colores
			textLabel.Text = rankInfo.Title
			textLabel.TextColor3 = rankInfo.TextColor
			textLabel.TextStrokeColor3 = rankInfo.TextStrokeColor
			print(string.format("[RankTitleManager] 🔄 Título actualizado para %s: '%s' (Nivel %d)", player.Name, rankInfo.Title, level))
		end
	else
		-- Crear nuevo título si no existe
		createRankTitle(character, rankInfo)
	end
end

-- Configura el título de rango cuando el personaje aparece
local function onCharacterAdded(player, character)
	-- Esperar a que la cabeza exista
	local head = character:WaitForChild("Head", 5)
	if not head then
		warn(string.format("[RankTitleManager] ⚠️ No se encontró la cabeza de %s", player.Name))
		return
	end

	-- Obtener nivel actual del jugador
	local playerData = DataManager.GetData(player)
	if not playerData then
		warn(string.format("[RankTitleManager] ⚠️ No se pudieron obtener datos de %s", player.Name))
		return
	end

	local currentLevel = playerData.Level or 1
	local rankInfo = RankConfig.GetRankInfo(currentLevel)

	-- Crear título inicial
	createRankTitle(character, rankInfo)
end

-- Configura los listeners para un jugador
local function setupPlayer(player)
	-- Escuchar cuando aparece el personaje
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	-- Si el personaje ya existe, configurarlo
	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	-- Escuchar cambios en el nivel (desde leaderstats)
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if leaderstats then
		local levelValue = leaderstats:FindFirstChild("Level")
		if levelValue then
			levelValue:GetPropertyChangedSignal("Value"):Connect(function()
				updateRankTitle(player, levelValue.Value)
			end)
			print(string.format("[RankTitleManager] 👂 Escuchando cambios de nivel para %s", player.Name))
		else
			warn(string.format("[RankTitleManager] ⚠️ No se encontró Level en leaderstats de %s", player.Name))
		end
	end
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

-- Configurar jugadores existentes
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		setupPlayer(player)
	end)
end

-- Configurar nuevos jugadores
Players.PlayerAdded:Connect(setupPlayer)

print("[RankTitleManager] ✅ Sistema de títulos de rango inicializado")
print(string.format("[RankTitleManager] 🎨 Fuente: %s", RankConfig.Visual.Font.Name))
print(string.format("[RankTitleManager] 📊 Rangos configurados: %d", #RankConfig.Ranks))
