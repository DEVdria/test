--[[
	ProductsConfig.lua - Configuración de Gamepasses y Developer Products

	UBICACIÓN: ReplicatedStorage > ShopSystem > ProductsConfig (ModuleScript)

	INSTRUCCIONES:
	1. Reemplaza los IDs de ejemplo con tus IDs reales de Roblox
	2. Para obtener IDs:
	   - Gamepasses: Ve a https://create.roblox.com/creations → Game Passes
	   - Developer Products: Ve a https://create.roblox.com/creations → Developer Products
	3. Copia el ID del producto y pégalo aquí
]]

local ProductsConfig = {}

-- ==================== GAMEPASSES ====================
--[[
	Los Gamepasses son compras únicas que otorgan beneficios permanentes
	Ejemplo: Velocidad extra, doble salto, VIP, etc.
]]

ProductsConfig.Gamepasses = {
	{
		Name = "VIP Pass",
		Description = "Acceso a áreas VIP y beneficios exclusivos",
		GamepassId = 123456789,  -- REEMPLAZA CON TU ID REAL
		Price = 100,  -- Robux (solo para mostrar, el precio real se establece en Roblox)
		Icon = "rbxassetid://0",  -- Opcional: imagen del gamepass
		Benefits = {
			"Acceso a zonas VIP",
			"2x velocidad de caminar",
			"Badge exclusivo"
		},
		-- Función que se ejecuta cuando el jugador tiene este gamepass
		OnOwned = function(player)
			-- Dar velocidad extra
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				player.Character.Humanoid.WalkSpeed = 32  -- Doble velocidad
			end

			-- Dar tag VIP
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local vipTag = Instance.new("BoolValue")
				vipTag.Name = "VIP"
				vipTag.Value = true
				vipTag.Parent = player
			end
		end
	},
	{
		Name = "Double Jump",
		Description = "Habilidad para saltar dos veces en el aire",
		GamepassId = 987654321,  -- REEMPLAZA CON TU ID REAL
		Price = 50,
		Icon = "rbxassetid://0",
		Benefits = {
			"Doble salto activado",
			"Alcanza lugares más altos"
		},
		OnOwned = function(player)
			-- El doble salto se maneja en un script aparte
			-- Este es solo un ejemplo de cómo detectar el gamepass
			local doubleJumpTag = Instance.new("BoolValue")
			doubleJumpTag.Name = "DoubleJumpEnabled"
			doubleJumpTag.Value = true
			doubleJumpTag.Parent = player
		end
	},
	{
		Name = "Premium Coins",
		Description = "Multiplica tus monedas ganadas x2",
		GamepassId = 111222333,  -- REEMPLAZA CON TU ID REAL
		Price = 150,
		Icon = "rbxassetid://0",
		Benefits = {
			"2x monedas por kills",
			"2x monedas por objetivos"
		},
		OnOwned = function(player)
			local coinMultiplier = Instance.new("NumberValue")
			coinMultiplier.Name = "CoinMultiplier"
			coinMultiplier.Value = 2
			coinMultiplier.Parent = player
		end
	}
}

-- ==================== DEVELOPER PRODUCTS ====================
--[[
	Los Developer Products son compras consumibles (se pueden comprar múltiples veces)
	Ejemplo: Monedas, vidas extra, power-ups temporales
]]

ProductsConfig.DeveloperProducts = {
	-- Productos normales de la tienda
	{
		Name = "100 Coins",
		Description = "Obtén 100 monedas al instante",
		ProductId = 1234567,  -- REEMPLAZA CON TU ID REAL
		Price = 10,
		Icon = "rbxassetid://0",
		Category = "normal",  -- normal o troll
		-- Función que se ejecuta cuando se compra
		OnPurchase = function(player)
			-- Dar monedas al jugador
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local coins = leaderstats:FindFirstChild("Coins")
				if coins then
					coins.Value = coins.Value + 100
				end
			end

			print(player.Name .. " compró 100 monedas")
			return true  -- Retornar true si la compra fue exitosa
		end
	},
	{
		Name = "500 Coins",
		Description = "Obtén 500 monedas - Mejor oferta!",
		ProductId = 7654321,  -- REEMPLAZA CON TU ID REAL
		Price = 40,
		Icon = "rbxassetid://0",
		Category = "normal",
		OnPurchase = function(player)
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local coins = leaderstats:FindFirstChild("Coins")
				if coins then
					coins.Value = coins.Value + 500
				end
			end
			return true
		end
	},

	-- ==================== PRODUCTOS TROLL ====================
	{
		Name = "☠️ Kill Everyone",
		Description = "Mata a todos los jugadores en el servidor",
		ProductId = 9998887,  -- REEMPLAZA CON TU ID REAL
		Price = 100,
		Icon = "rbxassetid://0",
		Category = "troll",
		OnPurchase = function(player)
			-- Esta función se ejecuta en el servidor
			-- Matar a todos los jugadores excepto al comprador
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character then
					local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.Health = 0
					end
				end
			end

			-- Mensaje en el chat
			local message = player.Name .. " compró Kill Everyone! ☠️"
			for _, p in pairs(game.Players:GetPlayers()) do
				game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireClient(
					p, {Text = message, Color = Color3.fromRGB(255, 0, 0)}
				)
			end

			return true
		end
	},
	{
		Name = "🤪 Ragdoll Everyone",
		Description = "Activa ragdoll para todos los jugadores por 10 segundos",
		ProductId = 7776665,  -- REEMPLAZA CON TU ID REAL
		Price = 75,
		Icon = "rbxassetid://0",
		Category = "troll",
		OnPurchase = function(player)
			-- Activar ragdoll para todos
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer.Character then
					local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
					if humanoid then
						-- Cambiar estado a ragdoll
						humanoid:ChangeState(Enum.HumanoidStateType.Physics)

						-- Restaurar después de 10 segundos
						task.delay(10, function()
							if humanoid and humanoid.Parent then
								humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
							end
						end)
					end
				end
			end

			return true
		end
	},
	{
		Name = "🌪️ Tornado",
		Description = "Lanza a todos los jugadores al aire",
		ProductId = 5554443,  -- REEMPLAZA CON TU ID REAL
		Price = 50,
		Icon = "rbxassetid://0",
		Category = "troll",
		OnPurchase = function(player)
			-- Lanzar a todos al aire
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local root = otherPlayer.Character.HumanoidRootPart
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(0, 100, 0)
					bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
					bodyVelocity.Parent = root

					-- Remover después de 1 segundo
					task.delay(1, function()
						if bodyVelocity and bodyVelocity.Parent then
							bodyVelocity:Destroy()
						end
					end)
				end
			end

			return true
		end
	},
	{
		Name = "🔥 Explode Everyone",
		Description = "Crea explosiones en todos los jugadores",
		ProductId = 3332221,  -- REEMPLAZA CON TU ID REAL
		Price = 80,
		Icon = "rbxassetid://0",
		Category = "troll",
		OnPurchase = function(player)
			-- Crear explosiones en todos
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local explosion = Instance.new("Explosion")
					explosion.Position = otherPlayer.Character.HumanoidRootPart.Position
					explosion.BlastRadius = 10
					explosion.BlastPressure = 500000
					explosion.Parent = workspace
				end
			end

			return true
		end
	},
	{
		Name = "⚡ Speed Boost Everyone",
		Description = "Da velocidad extrema a todos por 15 segundos",
		ProductId = 1119998,  -- REEMPLAZA CON TU ID REAL
		Price = 30,
		Icon = "rbxassetid://0",
		Category = "troll",
		OnPurchase = function(player)
			-- Dar velocidad a todos
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer.Character then
					local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
					if humanoid then
						local originalSpeed = humanoid.WalkSpeed
						humanoid.WalkSpeed = 100

						-- Restaurar después de 15 segundos
						task.delay(15, function()
							if humanoid and humanoid.Parent then
								humanoid.WalkSpeed = originalSpeed
							end
						end)
					end
				end
			end

			return true
		end
	}
}

-- ==================== FUNCIONES AUXILIARES ====================

-- Obtener gamepass por ID
function ProductsConfig:GetGamepass(gamepassId)
	for _, gamepass in ipairs(self.Gamepasses) do
		if gamepass.GamepassId == gamepassId then
			return gamepass
		end
	end
	return nil
end

-- Obtener developer product por ID
function ProductsConfig:GetDeveloperProduct(productId)
	for _, product in ipairs(self.DeveloperProducts) do
		if product.ProductId == productId then
			return product
		end
	end
	return nil
end

-- Obtener todos los productos de una categoría
function ProductsConfig:GetProductsByCategory(category)
	local products = {}
	for _, product in ipairs(self.DeveloperProducts) do
		if product.Category == category then
			table.insert(products, product)
		end
	end
	return products
end

return ProductsConfig
