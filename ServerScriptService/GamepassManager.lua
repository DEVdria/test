-- ServerScriptService > GamepassManager
-- Maneja todas las compras y efectos de Gamepasses

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Esperar a que ShopRemotes esté disponible
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))
local PurchaseGamepass = ShopRemotesModule.PurchaseGamepass
local CheckGamepassOwnership = ShopRemotesModule.CheckGamepassOwnership

-- ====================================
-- CONFIGURACIÓN DE GAMEPASSES
-- ====================================
-- IMPORTANTE: Reemplaza estos IDs con los IDs reales de tus Gamepasses
local GAMEPASSES = {
	VIP = {
		ID = 0, -- Reemplazar con el ID real del Gamepass VIP
		Name = "VIP",
		Effect = function(player)
			-- Efecto del VIP: Mostrar tag VIP sobre el jugador
			print(player.Name .. " tiene VIP activado!")

			-- Función para crear el BillboardGui sobre el jugador
			local function createVIPTag(character)
				-- Esperar a que la cabeza cargue
				local head = character:WaitForChild("Head")

				-- Verificar si ya tiene el tag VIP (evitar duplicados)
				if head:FindFirstChild("VIPTag") then
					return
				end

				-- Crear BillboardGui
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Name = "VIPTag"
				billboardGui.Adornee = head
				billboardGui.Size = UDim2.new(0, 100, 0, 40)
				billboardGui.StudsOffset = Vector3.new(0, 2.5, 0) -- Encima de la cabeza
				billboardGui.AlwaysOnTop = true
				billboardGui.Parent = head

				-- Frame contenedor
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Dorado
				frame.BorderSizePixel = 2
				frame.BorderColor3 = Color3.fromRGB(255, 255, 0)
				frame.Parent = billboardGui

				-- Esquinas redondeadas
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 8)
				corner.Parent = frame

				-- Texto VIP
				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = "✨ VIP ✨"
				textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
				textLabel.TextScaled = true
				textLabel.Font = Enum.Font.GothamBold
				textLabel.Parent = frame

				-- Padding para el texto
				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 5)
				padding.PaddingRight = UDim.new(0, 5)
				padding.PaddingTop = UDim.new(0, 5)
				padding.PaddingBottom = UDim.new(0, 5)
				padding.Parent = textLabel

				print("Tag VIP creado para " .. player.Name)
			end

			-- Crear el tag para el personaje actual
			if player.Character then
				createVIPTag(player.Character)
			end

			-- Crear el tag cada vez que el jugador respawnee
			player.CharacterAdded:Connect(function(character)
				createVIPTag(character)
			end)
		end
	},

	DoubleJump = {
		ID = 0, -- Reemplazar con el ID real del Gamepass Double Jump
		Name = "Double Jump",
		Effect = function(player)
			-- Efecto del Double Jump: Marcar al jugador como que tiene el gamepass
			print(player.Name .. " tiene Double Jump activado!")

			-- Verificar si ya tiene el BoolValue
			if not player:FindFirstChild("DoubleJumpEnabled") then
				-- Guardar estado del double jump en el jugador
				local doubleJumpEnabled = Instance.new("BoolValue")
				doubleJumpEnabled.Name = "DoubleJumpEnabled"
				doubleJumpEnabled.Value = true
				doubleJumpEnabled.Parent = player
				print("DoubleJumpEnabled agregado a " .. player.Name)
			end
		end
	},

	-- ====================================
	-- GAMEPASSES DE HERRAMIENTAS
	-- ====================================
	-- IMPORTANTE: Estos gamepasses requieren que tengas las herramientas en ServerStorage
	-- Los nombres de las herramientas en ServerStorage deben coincidir exactamente

	Espada = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Espada",
		ToolName = "Espada", -- Nombre del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Espada!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				-- Verificar si ya tiene el tool
				if backpack:FindFirstChild("Espada") or character:FindFirstChild("Espada") then
					return -- Ya lo tiene
				end

				-- Buscar el tool en ServerStorage
				local toolTemplate = ServerStorage:FindFirstChild("Espada")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Espada' entregado a " .. player.Name)
				else
					warn("Tool 'Espada' no encontrado en ServerStorage!")
				end
			end

			-- Dar el tool al personaje actual
			if player.Character then
				giveToolToPlayer(player.Character)
			end

			-- Dar el tool cada vez que respawnee
			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid") -- Esperar a que el humanoid cargue
				wait(0.5) -- Pequeña espera para asegurar que todo cargue
				giveToolToPlayer(character)
			end)
		end
	},

	BobinaGravedad = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Bobina de Gravedad",
		ToolName = "Bobina de gravedad", -- Nombre exacto del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Bobina de Gravedad!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				if backpack:FindFirstChild("Bobina de gravedad") or character:FindFirstChild("Bobina de gravedad") then
					return
				end

				local toolTemplate = ServerStorage:FindFirstChild("Bobina de gravedad")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Bobina de gravedad' entregado a " .. player.Name)
				else
					warn("Tool 'Bobina de gravedad' no encontrado en ServerStorage!")
				end
			end

			if player.Character then
				giveToolToPlayer(player.Character)
			end

			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				wait(0.5)
				giveToolToPlayer(character)
			end)
		end
	},

	BobinaVelocidad = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Bobina de Velocidad",
		ToolName = "Bobina de velocidad", -- Nombre exacto del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Bobina de Velocidad!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				if backpack:FindFirstChild("Bobina de velocidad") or character:FindFirstChild("Bobina de velocidad") then
					return
				end

				local toolTemplate = ServerStorage:FindFirstChild("Bobina de velocidad")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Bobina de velocidad' entregado a " .. player.Name)
				else
					warn("Tool 'Bobina de velocidad' no encontrado en ServerStorage!")
				end
			end

			if player.Character then
				giveToolToPlayer(player.Character)
			end

			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				wait(0.5)
				giveToolToPlayer(character)
			end)
		end
	},

	AlfombraMagica = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Alfombra Mágica",
		ToolName = "Alfombra magica", -- Nombre exacto del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Alfombra Mágica!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				if backpack:FindFirstChild("Alfombra magica") or character:FindFirstChild("Alfombra magica") then
					return
				end

				local toolTemplate = ServerStorage:FindFirstChild("Alfombra magica")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Alfombra magica' entregado a " .. player.Name)
				else
					warn("Tool 'Alfombra magica' no encontrado en ServerStorage!")
				end
			end

			if player.Character then
				giveToolToPlayer(player.Character)
			end

			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				wait(0.5)
				giveToolToPlayer(character)
			end)
		end
	},

	PistolaHiperlaser = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Pistola Hiperlaser",
		ToolName = "Pistola Hiperlaser", -- Nombre exacto del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Pistola Hiperlaser!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				if backpack:FindFirstChild("Pistola Hiperlaser") or character:FindFirstChild("Pistola Hiperlaser") then
					return
				end

				local toolTemplate = ServerStorage:FindFirstChild("Pistola Hiperlaser")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Pistola Hiperlaser' entregado a " .. player.Name)
				else
					warn("Tool 'Pistola Hiperlaser' no encontrado en ServerStorage!")
				end
			end

			if player.Character then
				giveToolToPlayer(player.Character)
			end

			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				wait(0.5)
				giveToolToPlayer(character)
			end)
		end
	},

	BobinaFusion = {
		ID = 0, -- Reemplazar con el ID real del Gamepass
		Name = "Bobina de Fusion",
		ToolName = "Bobina de Fusion", -- Nombre exacto del tool en ServerStorage
		Effect = function(player)
			print(player.Name .. " tiene el gamepass de Bobina de Fusion!")

			local function giveToolToPlayer(character)
				local backpack = player:FindFirstChild("Backpack")
				if not backpack then return end

				if backpack:FindFirstChild("Bobina de Fusion") or character:FindFirstChild("Bobina de Fusion") then
					return
				end

				local toolTemplate = ServerStorage:FindFirstChild("Bobina de Fusion")
				if toolTemplate then
					local toolClone = toolTemplate:Clone()
					toolClone.Parent = backpack
					print("Tool 'Bobina de Fusion' entregado a " .. player.Name)
				else
					warn("Tool 'Bobina de Fusion' no encontrado en ServerStorage!")
				end
			end

			if player.Character then
				giveToolToPlayer(player.Character)
			end

			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				wait(0.5)
				giveToolToPlayer(character)
			end)
		end
	}
}

-- ====================================
-- FUNCIONES DE GAMEPASS
-- ====================================

-- Verificar si un jugador tiene un gamepass
local function playerOwnsGamepass(player, gamepassId)
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)

	if success then
		return hasPass
	else
		warn("Error al verificar gamepass para " .. player.Name .. ": " .. tostring(hasPass))
		return false
	end
end

-- Activar el efecto de un gamepass
local function activateGamepassEffect(player, gamepassKey)
	local gamepassData = GAMEPASSES[gamepassKey]
	if gamepassData and gamepassData.Effect then
		gamepassData.Effect(player)
	end
end

-- Verificar y activar todos los gamepasses que el jugador posee
local function checkAndActivateGamepasses(player)
	for key, gamepassData in pairs(GAMEPASSES) do
		if gamepassData.ID ~= 0 then -- Solo verificar si el ID está configurado
			if playerOwnsGamepass(player, gamepassData.ID) then
				activateGamepassEffect(player, key)
			end
		end
	end
end

-- ====================================
-- EVENTOS DE JUGADORES
-- ====================================

-- Cuando un jugador entra al juego
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que el personaje cargue
	player.CharacterAdded:Connect(function(character)
		wait(0.5) -- Pequeña espera para asegurar que todo cargue
		checkAndActivateGamepasses(player)
	end)

	-- Si el personaje ya existe
	if player.Character then
		checkAndActivateGamepasses(player)
	end
end)

-- ====================================
-- MANEJO DE COMPRAS
-- ====================================

-- Cuando el cliente solicita comprar un gamepass
PurchaseGamepass.OnServerEvent:Connect(function(player, gamepassKey)
	local gamepassData = GAMEPASSES[gamepassKey]

	if not gamepassData then
		warn("Gamepass no encontrado: " .. tostring(gamepassKey))
		return
	end

	if gamepassData.ID == 0 then
		warn("El gamepass " .. gamepassKey .. " no tiene un ID configurado!")
		return
	end

	-- Verificar si ya lo tiene
	if playerOwnsGamepass(player, gamepassData.ID) then
		print(player.Name .. " ya tiene el gamepass " .. gamepassData.Name)
		activateGamepassEffect(player, gamepassKey)
		return
	end

	-- Prompt de compra
	local success, error = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, gamepassData.ID)
	end)

	if not success then
		warn("Error al mostrar prompt de gamepass: " .. tostring(error))
	end
end)

-- Cuando se completa una compra de gamepass
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
	if wasPurchased then
		-- Buscar qué gamepass fue comprado
		for key, gamepassData in pairs(GAMEPASSES) do
			if gamepassData.ID == gamepassId then
				print(player.Name .. " compró el gamepass " .. gamepassData.Name .. "!")
				activateGamepassEffect(player, key)
				break
			end
		end
	end
end)

-- Responder a solicitudes de verificación de propiedad
CheckGamepassOwnership.OnServerEvent:Connect(function(player, gamepassKey)
	local gamepassData = GAMEPASSES[gamepassKey]
	if gamepassData and gamepassData.ID ~= 0 then
		local hasPass = playerOwnsGamepass(player, gamepassData.ID)
		CheckGamepassOwnership:FireClient(player, gamepassKey, hasPass)
	end
end)

print("GamepassManager cargado correctamente")
