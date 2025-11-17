-- ServerScriptService > DeveloperProductManager
-- Maneja todas las compras y efectos de Developer Products

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Esperar a que ShopRemotes esté disponible
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))
local PurchaseDeveloperProduct = ShopRemotesModule.PurchaseDeveloperProduct

-- ====================================
-- CONFIGURACIÓN DE DEVELOPER PRODUCTS
-- ====================================
-- IMPORTANTE: Reemplaza estos IDs con los IDs reales de tus Developer Products
local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 0, -- Reemplazar con el ID real del Developer Product
		Name = "Kill All Players",
		Description = "Mata a todos los jugadores del servidor",
		Effect = function(purchaser)
			-- Matar a todos los jugadores excepto al comprador (opcional)
			print(purchaser.Name .. " usó Kill All!")

			for _, player in pairs(Players:GetPlayers()) do
				-- Descomentar la siguiente línea si quieres que el comprador también muera
				-- if player ~= purchaser then
					local character = player.Character
					if character then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							humanoid.Health = 0
						end
					end
				-- end
			end

			-- Mensaje en el servidor
			local message = Instance.new("Message")
			message.Text = purchaser.Name .. " usó Kill All!"
			message.Parent = game.Workspace
			wait(3)
			message:Destroy()
		end
	},

	RagdollAll = {
		ID = 0, -- Reemplazar con el ID real del Developer Product
		Name = "Ragdoll All Players",
		Description = "Pone a todos los jugadores en ragdoll",
		Effect = function(purchaser)
			-- Poner a todos en ragdoll
			print(purchaser.Name .. " usó Ragdoll All!")

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						-- Cambiar el estado a Ragdoll
						humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)

						-- Opcional: Quitar el ragdoll después de 5 segundos
						task.delay(5, function()
							if humanoid and humanoid.Parent then
								humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
							end
						end)
					end
				end
			end

			-- Mensaje en el servidor
			local message = Instance.new("Message")
			message.Text = purchaser.Name .. " usó Ragdoll All!"
			message.Parent = game.Workspace
			wait(3)
			message:Destroy()
		end
	},

	Explosion = {
		ID = 0, -- Reemplazar con el ID real del Developer Product
		Name = "Explosion",
		Description = "Crea una explosión masiva",
		Effect = function(purchaser)
			print(purchaser.Name .. " usó Explosion!")

			-- Crear explosión en la posición del comprador
			local character = purchaser.Character
			if character then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					local explosion = Instance.new("Explosion")
					explosion.Position = rootPart.Position
					explosion.BlastRadius = 50
					explosion.BlastPressure = 500000
					explosion.Parent = game.Workspace
				end
			end
		end
	},

	SpeedBoostAll = {
		ID = 0, -- Reemplazar con el ID real del Developer Product
		Name = "Speed Boost All",
		Description = "Da velocidad a todos por 30 segundos",
		Effect = function(purchaser)
			print(purchaser.Name .. " usó Speed Boost All!")

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						local originalSpeed = humanoid.WalkSpeed
						humanoid.WalkSpeed = 50

						-- Restaurar velocidad después de 30 segundos
						task.delay(30, function()
							if humanoid and humanoid.Parent then
								humanoid.WalkSpeed = originalSpeed
							end
						end)
					end
				end
			end

			-- Mensaje en el servidor
			local message = Instance.new("Message")
			message.Text = purchaser.Name .. " dio Speed Boost a todos por 30 segundos!"
			message.Parent = game.Workspace
			wait(3)
			message:Destroy()
		end
	}
}

-- ====================================
-- MANEJO DE COMPRAS
-- ====================================

-- Tabla para rastrear compras pendientes (evitar duplicados)
local purchasesInProgress = {}

-- Cuando el cliente solicita comprar un developer product
PurchaseDeveloperProduct.OnServerEvent:Connect(function(player, productKey)
	local productData = DEVELOPER_PRODUCTS[productKey]

	if not productData then
		warn("Developer Product no encontrado: " .. tostring(productKey))
		return
	end

	if productData.ID == 0 then
		warn("El Developer Product " .. productKey .. " no tiene un ID configurado!")
		return
	end

	-- Evitar compras duplicadas simultáneas
	local purchaseKey = player.UserId .. "_" .. productData.ID
	if purchasesInProgress[purchaseKey] then
		warn("Compra ya en progreso para " .. player.Name)
		return
	end

	purchasesInProgress[purchaseKey] = true

	-- Prompt de compra
	local success, error = pcall(function()
		MarketplaceService:PromptProductPurchase(player, productData.ID)
	end)

	if not success then
		warn("Error al mostrar prompt de developer product: " .. tostring(error))
		purchasesInProgress[purchaseKey] = nil
	end
end)

-- Callback de procesamiento de compras
local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	-- Buscar al jugador
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		-- Jugador se desconectó, guardar para después si es necesario
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Buscar qué producto fue comprado
	local productKey = nil
	local productData = nil

	for key, data in pairs(DEVELOPER_PRODUCTS) do
		if data.ID == productId then
			productKey = key
			productData = data
			break
		end
	end

	if not productData then
		warn("Producto no reconocido: " .. productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Ejecutar el efecto del producto
	local success, error = pcall(function()
		productData.Effect(player)
	end)

	-- Limpiar compra en progreso
	local purchaseKey = userId .. "_" .. productId
	purchasesInProgress[purchaseKey] = nil

	if success then
		print(player.Name .. " compró y usó: " .. productData.Name)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("Error al ejecutar efecto del producto: " .. tostring(error))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Asignar el callback
MarketplaceService.ProcessReceipt = processReceipt

-- Limpiar compras en progreso cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	for key in pairs(purchasesInProgress) do
		if key:match("^" .. player.UserId .. "_") then
			purchasesInProgress[key] = nil
		end
	end
end)

print("DeveloperProductManager cargado correctamente")
