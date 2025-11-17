-- ServerScriptService > GamepassManager
-- Maneja todas las compras y efectos de Gamepasses

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
			-- Aquí puedes agregar lógica como:
			-- - Dar más dinero
			-- - Desbloquear áreas
			-- - Cambiar el nombre con un tag especial
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

	SpeedBoost = {
		ID = 0, -- Reemplazar con el ID real del Gamepass Speed Boost
		Name = "Speed Boost",
		Effect = function(player)
			-- Efecto del Speed Boost: Aumentar velocidad del jugador
			print(player.Name .. " tiene Speed Boost activado!")
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = 32 -- Velocidad aumentada (default es 16)
		end
	},

	DoubleJump = {
		ID = 0, -- Reemplazar con el ID real del Gamepass Double Jump
		Name = "Double Jump",
		Effect = function(player)
			-- Efecto del Double Jump
			print(player.Name .. " tiene Double Jump activado!")
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.JumpPower = 100 -- Salto aumentado (default es 50)
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
