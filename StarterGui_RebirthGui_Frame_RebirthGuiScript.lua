-- StarterGui > RebirthGui > Frame > RebirthGuiScript
-- Gestiona la interfaz de Rebirths

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local OrbConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("OrbConfig"))
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestRebirthPurchaseEvent = RemoteEvents:WaitForChild("RequestRebirthPurchase")

-- Referencias a elementos de la GUI
local rebirthFrame = script.Parent
local titleLabel = rebirthFrame:WaitForChild("Title")
local priceLabel = rebirthFrame:WaitForChild("PriceLabel")
local multiplierLabel = rebirthFrame:WaitForChild("MultiplierLabel")
local purchaseButton = rebirthFrame:WaitForChild("PurchaseButton")
local closeButton = rebirthFrame:WaitForChild("CloseButton")

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
	local currentMultiplier = OrbConfig.CalculateSpeedMultiplier(rebirthsValue)
	local nextMultiplier = OrbConfig.CalculateSpeedMultiplier(rebirthsValue + 1)

	-- Actualizar labels
	priceLabel.Text = string.format("Precio: $%s", formatNumber(cost))
	multiplierLabel.Text = string.format("Multiplicador: x%.2f → x%.2f", currentMultiplier, nextMultiplier)

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
