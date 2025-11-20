-- ServerScriptService > DevProductTester
-- SCRIPT DE PRUEBAS - Permite probar Developer Products sin comprarlos
-- ELIMINAR O DESHABILITAR EN PRODUCCIÓN

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ⚠️ CAMBIAR A false PARA DESHABILITAR EL MODO DE PRUEBA
local TESTING_MODE = true

if not TESTING_MODE then
	script:Destroy()
	return
end

print("⚠️ MODO DE PRUEBA ACTIVADO - DevProductTester habilitado")

-- Esperar a que ShopRemotes esté disponible
local ShopRemotesModule = require(ReplicatedStorage:WaitForChild("ShopRemotes"))

-- Crear RemoteEvent para testing
local TestProductRemote = Instance.new("RemoteEvent")
TestProductRemote.Name = "TestDeveloperProduct"
TestProductRemote.Parent = ReplicatedStorage:WaitForChild("ShopRemotes")

-- Simular efectos de Developer Products
local PRODUCT_EFFECTS = {
	KillAll = function(player)
		print("🧪 TEST: " .. player.Name .. " activó Kill All")
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
		message.Text = "🧪 TEST: " .. player.Name .. " usó Kill All!"
		message.Parent = game.Workspace
		wait(3)
		message:Destroy()
	end,

	RagdollAll = function(player)
		print("🧪 TEST: " .. player.Name .. " activó Launch All")
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
		message.Text = "🧪 TEST: " .. player.Name .. " lanzó a todos al cielo! 🚀"
		message.Parent = game.Workspace
		wait(3)
		message:Destroy()
	end,

	Explosion = function(player)
		print("🧪 TEST: " .. player.Name .. " activó Explosion")
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
	end,

	SpeedBoostAll = function(player)
		print("🧪 TEST: " .. player.Name .. " activó Speed Boost All")
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
		message.Text = "🧪 TEST: " .. player.Name .. " dio Speed Boost a todos por 30 segundos!"
		message.Parent = game.Workspace
		wait(3)
		message:Destroy()
	end
}

-- Manejar solicitudes de testing
TestProductRemote.OnServerEvent:Connect(function(player, productKey)
	local effect = PRODUCT_EFFECTS[productKey]

	if effect then
		print("🧪 Ejecutando efecto de prueba: " .. productKey)
		local success, err = pcall(function()
			effect(player)
		end)

		if not success then
			warn("🧪 Error en efecto de prueba: " .. tostring(err))
		end
	else
		warn("🧪 Producto de prueba no encontrado: " .. tostring(productKey))
	end
end)

print("🧪 DevProductTester listo - Los jugadores pueden probar productos gratis")
print("⚠️ RECUERDA DESHABILITAR ESTE SCRIPT EN PRODUCCIÓN (TESTING_MODE = false)")
