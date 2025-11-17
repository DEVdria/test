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
			-- Efecto del VIP: Por ejemplo, dar un tag o beneficios
			print(player.Name .. " tiene VIP activado!")
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local vipTag = leaderstats:FindFirstChild("VIP")
				if not vipTag then
					vipTag = Instance.new("StringValue")
					vipTag.Name = "VIP"
					vipTag.Value = "✨"
					vipTag.Parent = leaderstats
				end
			end
		end
	},

	DoubleJump = {
		ID = 0, -- Reemplazar con el ID real del Gamepass Double Jump
		Name = "Double Jump",
		Effect = function(player)
			-- Efecto del Double Jump: Permitir saltar en el aire
			print(player.Name .. " tiene Double Jump activado!")

			-- Guardar estado del double jump en el jugador
			local doubleJumpEnabled = Instance.new("BoolValue")
			doubleJumpEnabled.Name = "DoubleJumpEnabled"
			doubleJumpEnabled.Value = true
			doubleJumpEnabled.Parent = player

			-- Función para configurar el double jump en un personaje
			local function setupDoubleJump(character)
				local humanoid = character:WaitForChild("Humanoid")
				local canDoubleJump = true

				-- Cuando el jugador salta
				humanoid.StateChanged:Connect(function(oldState, newState)
					-- Si aterriza, puede volver a hacer double jump
					if newState == Enum.HumanoidStateType.Landed then
						canDoubleJump = true
					end
				end)

				-- Detectar cuando el jugador está cayendo y presiona espacio
				humanoid.FreeFalling:Connect(function()
					-- Crear un detector de input en el personaje
					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if rootPart and canDoubleJump then
						-- Esperar un frame para el input
						task.wait(0.1)
					end
				end)
			end

			-- Configurar para el personaje actual
			if player.Character then
				setupDoubleJump(player.Character)
			end

			-- Configurar para futuros personajes
			player.CharacterAdded:Connect(function(character)
				setupDoubleJump(character)
			end)
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
