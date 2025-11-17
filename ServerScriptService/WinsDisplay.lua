--[[
═══════════════════════════════════════════════════════════════
    WINS DISPLAY - Muestra Wins arriba de jugadores
    Ubicación: ServerScriptService

    Funcionalidad:
    - Crea BillboardGui arriba de cada jugador mostrando sus Wins
    - Actualiza en tiempo real cuando cambian los Wins
    - Se recrea automáticamente al respawnear
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")

-- CONFIGURACIÓN
local DISPLAY_OFFSET = Vector3.new(0, 3, 0) -- Altura arriba de la cabeza
local TEXT_COLOR = Color3.fromRGB(255, 215, 0) -- Color dorado
local TEXT_SIZE = 24

--[[
    Función: Crear BillboardGui con los Wins
    Parámetros:
        character - El personaje del jugador
        player - El jugador
--]]
local function createWinsDisplay(character, player)
	-- Buscar la cabeza del personaje
	local head = character:WaitForChild("Head", 5)
	if not head then
		warn("No se encontró la cabeza de " .. player.Name)
		return
	end

	-- Verificar si ya existe un BillboardGui
	local existingBillboard = head:FindFirstChild("WinsBillboard")
	if existingBillboard then
		existingBillboard:Destroy()
	end

	-- Crear BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "WinsBillboard"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = DISPLAY_OFFSET
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	-- Crear TextLabel para mostrar los Wins
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "WinsText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = TEXT_SIZE
	textLabel.TextColor3 = TEXT_COLOR
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Parent = billboard

	-- Función para actualizar el texto
	local function updateWinsText()
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local wins = leaderstats:FindFirstChild("Wins")
			if wins then
				textLabel.Text = "🏆 " .. wins.Value .. " Wins"
			end
		end
	end

	-- Actualizar texto inicial
	updateWinsText()

	-- Escuchar cambios en los Wins
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local wins = leaderstats:FindFirstChild("Wins")
		if wins then
			wins:GetPropertyChangedSignal("Value"):Connect(function()
				updateWinsText()
			end)
		end
	end

	print("🏆 Display de Wins creado para " .. player.Name)
end

--[[
    Función: Configurar display para un jugador
    Parámetros: player - El jugador
--]]
local function setupPlayerDisplay(player)
	-- Esperar a que el jugador tenga leaderstats
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("No se encontraron leaderstats para " .. player.Name)
		return
	end

	-- Función para manejar cuando el personaje se carga
	local function onCharacterAdded(character)
		-- Esperar un momento para asegurar que el personaje esté completamente cargado
		task.wait(0.5)
		createWinsDisplay(character, player)
	end

	-- Si el personaje ya existe, crear display
	if player.Character then
		onCharacterAdded(player.Character)
	end

	-- Escuchar cuando el personaje se cargue (respawn)
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Configurar display para jugadores que ya están en el juego
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(function()
		setupPlayerDisplay(player)
	end)
end

-- Configurar display para nuevos jugadores que se unan
Players.PlayerAdded:Connect(function(player)
	setupPlayerDisplay(player)
end)

print("═══════════════════════════════════════════════════════")
print("🏆 Wins Display inicializado correctamente")
print("═══════════════════════════════════════════════════════")
