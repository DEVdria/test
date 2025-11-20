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
		Description = "Lanza a todos los jugadores hacia el cielo",
		Effect = function(purchaser)
			-- Lanzar a todos hacia arriba
			print(purchaser.Name .. " usó Ragdoll All!")

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					local rootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoid and rootPart then
						-- Hacer que el jugador se ponga en PlatformStand (pierde control)
						humanoid.PlatformStand = true

						-- Crear BodyVelocity para lanzarlo hacia arriba
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-20, 20), -- Movimiento horizontal aleatorio en X
							math.random(80, 120),  -- Fuerza principal hacia arriba
							math.random(-20, 20)  -- Movimiento horizontal aleatorio en Z
						)
						bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
						bodyVelocity.Parent = rootPart

						-- Crear BodyAngularVelocity para que gire en el aire
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(-10, 10),
							math.random(-10, 10),
							math.random(-10, 10)
						)
						bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
						bodyAngularVelocity.Parent = rootPart

						-- Después de 1.5 segundos, quitar las fuerzas para que caiga naturalmente
						task.delay(1.5, function()
							if bodyVelocity and bodyVelocity.Parent then
								bodyVelocity:Destroy()
							end
							if bodyAngularVelocity and bodyAngularVelocity.Parent then
								bodyAngularVelocity:Destroy()
							end
						end)

						-- Después de 3 segundos, devolver el control al jugador
						task.delay(3, function()
							if humanoid and humanoid.Parent then
								humanoid.PlatformStand = false
							end
						end)
					end
				end
			end

			-- Mensaje en el servidor
			local message = Instance.new("Message")
			message.Text = purchaser.Name .. " lanzó a todos al cielo! 🚀"
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
-- VERIFICACIÓN DE CONFIGURACIÓN
-- ====================================

-- Verificar que los IDs estén configurados
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 VERIFICANDO CONFIGURACIÓN DE DEVELOPER PRODUCTS")
local hasInvalidIds = false
for key, data in pairs(DEVELOPER_PRODUCTS) do
	if data.ID == 0 then
		warn("⚠️ " .. key .. ": ID NO CONFIGURADO (actualmente 0)")
		hasInvalidIds = true
	else
		print("✅ " .. key .. ": ID configurado (" .. data.ID .. ")")
	end
end

if hasInvalidIds then
	warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	warn("⚠️ ADVERTENCIA: Hay Developer Products sin configurar")
	warn("⚠️ Los productos con ID = 0 NO funcionarán")
	warn("⚠️ Configura los IDs reales en DeveloperProductManager.lua")
	warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
else
	print("✅ Todos los Developer Products tienen IDs configurados")
end
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

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
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("📦 PROCESANDO COMPRA DE DEVELOPER PRODUCT")
	print("PlayerId: " .. tostring(receiptInfo.PlayerId))
	print("ProductId: " .. tostring(receiptInfo.ProductId))
	print("PurchaseId: " .. tostring(receiptInfo.PurchaseId))
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	-- Buscar al jugador
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		warn("⚠️ Jugador no encontrado (UserId: " .. userId .. ") - Intentará procesar después")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print("✅ Jugador encontrado: " .. player.Name)

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
		warn("❌ Producto no reconocido con ID: " .. productId)
		warn("⚠️ Verifica que el ID en DeveloperProductManager coincida con el de Roblox.com")
		warn("⚠️ IDs configurados actualmente:")
		for key, data in pairs(DEVELOPER_PRODUCTS) do
			warn("   - " .. key .. ": " .. tostring(data.ID))
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print("✅ Producto identificado: " .. productData.Name .. " (Key: " .. productKey .. ")")

	-- Ejecutar el efecto del producto
	print("🔄 Ejecutando efecto del producto...")
	local success, errorMsg = pcall(function()
		productData.Effect(player)
	end)

	-- Limpiar compra en progreso
	local purchaseKey = userId .. "_" .. productId
	purchasesInProgress[purchaseKey] = nil

	if success then
		print("✅ ¡Efecto ejecutado correctamente!")
		print("✅ " .. player.Name .. " compró y usó: " .. productData.Name)
		print("✅ Compra marcada como PurchaseGranted")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("❌ Error al ejecutar efecto del producto: " .. tostring(errorMsg))
		warn("❌ La compra NO se procesó - el jugador recibirá reembolso")
		warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Verificar si ya existe un ProcessReceipt
if MarketplaceService.ProcessReceipt ~= nil then
	warn("⚠️ ADVERTENCIA: Ya existe un ProcessReceipt configurado!")
	warn("⚠️ Esto puede causar conflictos. Asegúrate de que no haya otros scripts manejando compras.")
end

-- Asignar el callback
MarketplaceService.ProcessReceipt = processReceipt
print("✅ ProcessReceipt configurado correctamente para Developer Products")

-- Limpiar compras en progreso cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	for key in pairs(purchasesInProgress) do
		if key:match("^" .. player.UserId .. "_") then
			purchasesInProgress[key] = nil
		end
	end
end)

print("DeveloperProductManager cargado correctamente")
