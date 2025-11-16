--[[
	MULTIPLIER BUTTON MODULE
	Este módulo contiene toda la lógica del botón de multiplicador
	Ubicación: ReplicatedStorage
--]]

local module = {}

function module.Init(button)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	local MULTIPLIER_COST = 10000

	local COLOR_DEFAULT = Color3.fromRGB(85, 170, 255)
	local COLOR_HOVER = Color3.fromRGB(100, 190, 255)
	local COLOR_PRESSED = Color3.fromRGB(70, 150, 230)
	local COLOR_DISABLED = Color3.fromRGB(60, 60, 60)

	local canClick = false
	local purchaseMultiplierEvent = nil
	local isInitialized = false

	print("🎮 Iniciando botón de multiplicador...")

	local function formatMoney(amount)
		local str = tostring(amount)
		local result = ""
		local len = string.len(str)

		for i = 1, len do
			result = result .. string.sub(str, i, i)
			if (len - i) % 3 == 0 and i ~= len then
				result = result .. ","
			end
		end

		return result
	end

	local function getCurrentMultiplier()
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local multiplierStat = leaderstats:FindFirstChild("Multiplicador")
			if multiplierStat then
				return multiplierStat.Value
			end
		end
		return 1.0
	end

	local function getCurrentMoney()
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local moneyStat = leaderstats:FindFirstChild("Money")
			if moneyStat then
				return moneyStat.Value
			end
		end
		return 0
	end

	local function updateButtonText()
		if not isInitialized then
			return
		end

		local currentMultiplier = getCurrentMultiplier()
		local nextMultiplier = math.floor((currentMultiplier + 0.1) * 10 + 0.5) / 10
		local currentMoney = getCurrentMoney()
		local canAfford = currentMoney >= MULTIPLIER_COST

		if canAfford then
			button.Text = string.format(
				"💰 COMPRAR MULTIPLICADOR 💰\n\n" ..
				"Actual: x%.1f → Siguiente: x%.1f\n\n" ..
				"Costo: $%s\n" ..
				"Tu dinero: $%s ✅",
				currentMultiplier,
				nextMultiplier,
				formatMoney(MULTIPLIER_COST),
				formatMoney(currentMoney)
			)
			button.BackgroundColor3 = COLOR_DEFAULT
			canClick = true
		else
			button.Text = string.format(
				"💰 COMPRAR MULTIPLICADOR 💰\n\n" ..
				"Actual: x%.1f → Siguiente: x%.1f\n\n" ..
				"Costo: $%s\n" ..
				"Tu dinero: $%s ❌",
				currentMultiplier,
				nextMultiplier,
				formatMoney(MULTIPLIER_COST),
				formatMoney(currentMoney)
			)
			button.BackgroundColor3 = COLOR_DISABLED
			canClick = false
		end
	end

	button.MouseButton1Click:Connect(function()
		if not canClick or not purchaseMultiplierEvent then
			print("⚠️ No se puede comprar: canClick=" .. tostring(canClick) .. ", event=" .. tostring(purchaseMultiplierEvent ~= nil))
			return
		end

		local currentMoney = getCurrentMoney()
		if currentMoney < MULTIPLIER_COST then
			local originalColor = button.BackgroundColor3
			button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			task.wait(0.2)
			button.BackgroundColor3 = originalColor
			return
		end

		button.BackgroundColor3 = COLOR_PRESSED
		button.Text = "⏳ COMPRANDO..."
		canClick = false

		purchaseMultiplierEvent:FireServer()
		print("📤 Solicitud de compra enviada")

		task.wait(0.5)
		updateButtonText()
	end)

	button.MouseEnter:Connect(function()
		if canClick then
			button.BackgroundColor3 = COLOR_HOVER
		end
	end)

	button.MouseLeave:Connect(function()
		if canClick then
			button.BackgroundColor3 = COLOR_DEFAULT
		elseif getCurrentMoney() < MULTIPLIER_COST then
			button.BackgroundColor3 = COLOR_DISABLED
		end
	end)

	task.spawn(function()
		button.Text = "⏳ Esperando servidor...\n(Sistemas cargando)"
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

		print("⏳ Esperando leaderstats...")
		local leaderstats = player:WaitForChild("leaderstats", 15)

		if not leaderstats then
			button.Text = "❌ ERROR\nLeaderstats no encontrado\n(¿MoneyManager activo?)"
			button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			warn("❌ No se encontró leaderstats para " .. player.Name)
			return
		end

		print("✅ Leaderstats encontrado")

		print("⏳ Esperando Money...")
		local moneyStat = leaderstats:WaitForChild("Money", 15)

		if not moneyStat then
			button.Text = "❌ ERROR\nMoney no encontrado"
			button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			warn("❌ No se encontró Money para " .. player.Name)
			return
		end

		print("✅ Money encontrado")

		print("⏳ Esperando Multiplicador...")
		button.Text = "⏳ Esperando multiplicador...\n(Casi listo)"

		local multiplierStat = leaderstats:WaitForChild("Multiplicador", 15)

		if not multiplierStat then
			button.Text = "❌ ERROR\nMultiplicador no encontrado\n(¿MultiplierSystem activo?)"
			button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			warn("❌ No se encontró Multiplicador para " .. player.Name)
			return
		end

		print("✅ Multiplicador encontrado")

		print("⏳ Esperando RemoteEvent...")
		button.Text = "⏳ Conectando...\n(Último paso)"

		local waitTime = 0
		while not ReplicatedStorage:FindFirstChild("PurchaseMultiplier") and waitTime < 15 do
			task.wait(0.5)
			waitTime = waitTime + 0.5
		end

		purchaseMultiplierEvent = ReplicatedStorage:FindFirstChild("PurchaseMultiplier")

		if not purchaseMultiplierEvent then
			button.Text = "❌ ERROR\nRemoteEvent no encontrado\n(¿MultiplierSystem activo?)"
			button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			warn("❌ No se encontró PurchaseMultiplier RemoteEvent")
			return
		end

		print("✅ RemoteEvent encontrado")

		isInitialized = true

		multiplierStat.Changed:Connect(function()
			updateButtonText()
		end)

		moneyStat.Changed:Connect(function()
			updateButtonText()
		end)

		updateButtonText()

		task.spawn(function()
			while true do
				task.wait(2)
				updateButtonText()
			end
		end)

		print("✅ Botón de multiplicador completamente inicializado para " .. player.Name)
	end)
end

return module
