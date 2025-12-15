-- StarterGui > RebirthGui > Frame > RebirthGuiScript
-- Gestiona la interfaz de Rebirths

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local OrbConfig = require(Modules:WaitForChild("OrbConfig"))
local LevelManager = require(Modules:WaitForChild("LevelManager"))
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase")

-- Referencias a elementos de la GUI
local rebirthFrame = script.Parent
local titleLabel = rebirthFrame:WaitForChild("Title")
local priceLabel = rebirthFrame:WaitForChild("PriceLabel")
local purchaseButton = rebirthFrame:WaitForChild("PurchaseButton")
local closeButton = rebirthFrame:WaitForChild("CloseButton")

-- TextLabels para multiplicadores (OPCIONAL - crea estos en tu GUI)
local currentMultiplierLabel = rebirthFrame:FindFirstChild("CurrentMultiplierLabel") or rebirthFrame:FindFirstChild("CurrentMultiplier")
local nextMultiplierLabel = rebirthFrame:FindFirstChild("NextMultiplierLabel") or rebirthFrame:FindFirstChild("NextMultiplier")

-- TextLabels para nivel máximo (OPCIONAL - crea estos en tu GUI)
local currentLevelCapLabel = rebirthFrame:FindFirstChild("CurrentLevelCapLabel") or rebirthFrame:FindFirstChild("CurrentMaxLevel")
local nextLevelCapLabel = rebirthFrame:FindFirstChild("NextLevelCapLabel") or rebirthFrame:FindFirstChild("NextMaxLevel")

-- Estado
local isPurchasing = false

-- Formatea números con separadores de miles
local function formatNumber(num)
	local formatted = tostring(num)
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted
end

-- Actualiza la información mostrada en la GUI
local function updateRebirthInfo()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local currentRebirths = leaderstats:FindFirstChild("Rebirths")
	local currentMoney = leaderstats:FindFirstChild("Money")

	if not currentRebirths or not currentMoney then return end

	local rebirthsValue = currentRebirths.Value
	local moneyValue = currentMoney.Value

	-- Calcular información
	local cost = OrbConfig.CalculateRebirthCost(rebirthsValue)
	local currentMultiplier = OrbConfig.CalculateEXPMultiplier(rebirthsValue)
	local nextMultiplier = OrbConfig.CalculateEXPMultiplier(rebirthsValue + 1)
	local currentMaxLevel = LevelManager.GetMaxLevel(rebirthsValue)
	local nextMaxLevel = LevelManager.GetMaxLevel(rebirthsValue + 1)

	-- Actualizar precio
	priceLabel.Text = string.format("Precio: $%s", formatNumber(cost))

	-- Actualizar multiplicador actual (ej: "x1.4")
	if currentMultiplierLabel then
		currentMultiplierLabel.Text = string.format("x%.1f", currentMultiplier)
	end

	-- Actualizar multiplicador siguiente (ej: "x1.6")
	if nextMultiplierLabel then
		nextMultiplierLabel.Text = string.format("x%.1f", nextMultiplier)
	end

	-- Actualizar nivel máximo actual (ej: "Nivel 20")
	if currentLevelCapLabel then
		currentLevelCapLabel.Text = string.format("Nivel %d", currentMaxLevel)
	end

	-- Actualizar nivel máximo siguiente (ej: "Nivel 30")
	if nextLevelCapLabel then
		nextLevelCapLabel.Text = string.format("Nivel %d", nextMaxLevel)
	end

	-- Actualizar botón según si puede comprar
	local canAfford = moneyValue >= cost

	if canAfford then
		purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		purchaseButton.Text = "COMPRAR REBIRTH"
	else
		purchaseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		purchaseButton.Text = string.format("Necesitas $%s más", formatNumber(cost - moneyValue))
	end
end

-- Comprar rebirth
local function purchaseRebirth()
	if isPurchasing then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local currentRebirths = leaderstats:FindFirstChild("Rebirths")
	local currentMoney = leaderstats:FindFirstChild("Money")

	if not currentRebirths or not currentMoney then return end

	local cost = OrbConfig.CalculateRebirthCost(currentRebirths.Value)

	-- Verificar si puede comprar
	if currentMoney.Value < cost then
		-- Efecto de shake para indicar que no puede comprar
		local originalPosition = purchaseButton.Position
		for i = 1, 3 do
			purchaseButton.Position = originalPosition + UDim2.new(0, math.random(-5, 5), 0, 0)
			task.wait(0.05)
		end
		purchaseButton.Position = originalPosition
		return
	end

	isPurchasing = true
	purchaseButton.Text = "PROCESANDO..."

	-- Enviar solicitud al servidor
	RequestRebirthPurchaseEvent:FireServer()
end

-- Manejar respuesta del servidor
RequestRebirthPurchaseEvent.OnClientEvent:Connect(function(result)
	isPurchasing = false

	if result.Success then
		-- Éxito
		purchaseButton.Text = "REBIRTH EXITOSO!"
		purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

		task.wait(1)
		updateRebirthInfo()

		-- Cerrar GUI automáticamente después de comprar (opcional)
		-- task.wait(1)
		-- rebirthFrame.Parent.Enabled = false
	else
		-- Error
		purchaseButton.Text = result.Message or "ERROR"
		purchaseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

		task.wait(2)
		updateRebirthInfo()
	end
end)

-- Botón de compra
purchaseButton.MouseButton1Click:Connect(purchaseRebirth)

-- Botón de cerrar
closeButton.MouseButton1Click:Connect(function()
	rebirthFrame.Parent.Enabled = false
end)

-- Actualizar información cuando cambian los leaderstats
local function setupLeaderstatsListeners()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then return end

	local money = leaderstats:WaitForChild("Money", 5)
	local rebirths = leaderstats:WaitForChild("Rebirths", 5)

	if money then
		money:GetPropertyChangedSignal("Value"):Connect(updateRebirthInfo)
	end

	if rebirths then
		rebirths:GetPropertyChangedSignal("Value"):Connect(updateRebirthInfo)
	end

	updateRebirthInfo()
end

-- Actualizar cuando se abre la GUI
rebirthFrame.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if rebirthFrame.Parent.Enabled then
		updateRebirthInfo()
	end
end)

-- Inicializar
setupLeaderstatsListeners()
updateRebirthInfo()
