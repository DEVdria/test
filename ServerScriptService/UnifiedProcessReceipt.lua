-- ServerScriptService > UnifiedProcessReceipt
-- Maneja TODOS los Developer Products del juego (DonoBoard + Troll Products)

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- ====================================
-- CONFIGURACIÓN DE LA DONOBOARD
-- ====================================

-- DataStore de la DonoBoard (debe coincidir con el nombre en la DonoBoard)
local DSLB = DataStoreService:GetOrderedDataStore("DonoPurchaseLB")

-- Productos de la DonoBoard (deben coincidir con el ModuleScript)
local DONOBOARD_PRODUCTS = {
	[1459790777] = 1,
	[1459790776] = 3,
	[1459790775] = 5,
	[1459790772] = 10,
	[1459790774] = 15,
	[1459790771] = 20,
	[1459793755] = 25,
	[1459793756] = 50,
	[1459793754] = 100,
	[1459793753] = 250,
	[1459793748] = 500,
	[1459793747] = 1000,
}

-- ====================================
-- CONFIGURACIÓN DE TROLL PRODUCTS
-- ====================================

local DEVELOPER_PRODUCTS = {
	KillAll = {
		ID = 0, -- ⬅️ REEMPLAZAR con ID real
		Name = "Kill All Players",
		Effect = function(player)
			print(player.Name .. " usó Kill All!")
			for _, p in pairs(Players:GetPlayers()) do
				local character = p.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.Health = 0
					end
				end
			end

			local message = Instance.new("Message")
			message.Text = player.Name .. " usó Kill All!"
			message.Parent = game.Workspace
			task.wait(3)
			message:Destroy()
		end
	},

	RagdollAll = {
		ID = 0, -- ⬅️ REEMPLAZAR con ID real
		Name = "Launch All",
		Effect = function(player)
			print(player.Name .. " usó Launch All!")
			for _, p in pairs(Players:GetPlayers()) do
				local character = p.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					local rootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoid and rootPart then
						humanoid.PlatformStand = true

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-20, 20),
							math.random(80, 120),
							math.random(-20, 20)
						)
						bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
						bodyVelocity.Parent = rootPart

						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(-10, 10),
							math.random(-10, 10),
							math.random(-10, 10)
						)
						bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
						bodyAngularVelocity.Parent = rootPart

						task.delay(1.5, function()
							if bodyVelocity and bodyVelocity.Parent then
								bodyVelocity:Destroy()
							end
							if bodyAngularVelocity and bodyAngularVelocity.Parent then
								bodyAngularVelocity:Destroy()
							end
						end)

						task.delay(3, function()
							if humanoid and humanoid.Parent then
								humanoid.PlatformStand = false
							end
						end)
					end
				end
			end

			local message = Instance.new("Message")
			message.Text = player.Name .. " lanzó a todos al cielo! 🚀"
			message.Parent = game.Workspace
			task.wait(3)
			message:Destroy()
		end
	},

	Explosion = {
		ID = 0, -- ⬅️ REEMPLAZAR con ID real
		Name = "Explosion",
		Effect = function(player)
			print(player.Name .. " usó Explosion!")
			local character = player.Character
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
		ID = 0, -- ⬅️ REEMPLAZAR con ID real
		Name = "Speed Boost All",
		Effect = function(player)
			print(player.Name .. " usó Speed Boost All!")
			for _, p in pairs(Players:GetPlayers()) do
				local character = p.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						local originalSpeed = humanoid.WalkSpeed
						humanoid.WalkSpeed = 50

						task.delay(30, function()
							if humanoid and humanoid.Parent then
								humanoid.WalkSpeed = originalSpeed
							end
						end)
					end
				end
			end

			local message = Instance.new("Message")
			message.Text = player.Name .. " dio Speed Boost a todos por 30 segundos!"
			message.Parent = game.Workspace
			task.wait(3)
			message:Destroy()
		end
	}
}

-- ====================================
-- PROCESSRECEIPT UNIFICADO
-- ====================================

local function unifiedProcessReceipt(receiptInfo)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("📦 PROCESANDO COMPRA UNIFICADA")
	print("PlayerId: " .. tostring(receiptInfo.PlayerId))
	print("ProductId: " .. tostring(receiptInfo.ProductId))
	print("CurrencySpent: " .. tostring(receiptInfo.CurrencySpent))
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local player = Players:GetPlayerByUserId(userId)

	if not player then
		warn("⚠️ Jugador no encontrado - Intentará procesar después")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print("✅ Jugador encontrado: " .. player.Name)

	-- ====================================
	-- VERIFICAR SI ES PRODUCTO DE DONOBOARD
	-- ====================================

	if DONOBOARD_PRODUCTS[productId] then
		print("💰 Producto de DonoBoard detectado")
		local success, err = pcall(function()
			DSLB:IncrementAsync(userId, receiptInfo.CurrencySpent)
		end)

		if success then
			print("✅ DonoBoard actualizada correctamente")
			print("✅ Compra marcada como PurchaseGranted")
			print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("❌ Error al actualizar DonoBoard: " .. tostring(err))
			warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	-- ====================================
	-- VERIFICAR SI ES PRODUCTO TROLL
	-- ====================================

	local trollProductKey = nil
	local trollProductData = nil

	for key, data in pairs(DEVELOPER_PRODUCTS) do
		if data.ID == productId then
			trollProductKey = key
			trollProductData = data
			break
		end
	end

	if trollProductData then
		print("🎮 Producto Troll detectado: " .. trollProductData.Name)
		print("🔄 Ejecutando efecto...")

		local success, err = pcall(function()
			trollProductData.Effect(player)
		end)

		if success then
			print("✅ Efecto ejecutado correctamente")
			print("✅ " .. player.Name .. " compró y usó: " .. trollProductData.Name)
			print("✅ Compra marcada como PurchaseGranted")
			print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("❌ Error al ejecutar efecto: " .. tostring(err))
			warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	-- ====================================
	-- PRODUCTO NO RECONOCIDO
	-- ====================================

	warn("❌ Producto no reconocido con ID: " .. productId)
	warn("⚠️ No es un producto de DonoBoard ni de Troll")
	warn("⚠️ Productos DonoBoard:")
	for id, price in pairs(DONOBOARD_PRODUCTS) do
		warn("   - ID: " .. id .. " (Precio: " .. price .. " Robux)")
	end
	warn("⚠️ Productos Troll:")
	for key, data in pairs(DEVELOPER_PRODUCTS) do
		warn("   - " .. key .. ": " .. tostring(data.ID))
	end
	warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- ====================================
-- ASIGNAR PROCESSRECEIPT
-- ====================================

-- Verificar si ya existe un ProcessReceipt
if MarketplaceService.ProcessReceipt ~= nil then
	warn("⚠️ ADVERTENCIA: Ya existe un ProcessReceipt configurado!")
	warn("⚠️ Será sobrescrito por el UnifiedProcessReceipt")
end

-- Asignar el ProcessReceipt unificado
MarketplaceService.ProcessReceipt = unifiedProcessReceipt

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ UnifiedProcessReceipt configurado correctamente")
print("✅ Manejando productos de DonoBoard + Troll")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ====================================
-- VERIFICACIÓN DE CONFIGURACIÓN
-- ====================================

print("🔍 Verificando configuración de productos Troll:")
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
	warn("⚠️ Hay productos Troll sin configurar - no funcionarán hasta que configures los IDs")
end
