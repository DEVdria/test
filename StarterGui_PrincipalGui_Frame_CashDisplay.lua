-- StarterGui > PrincipalGui > Frame > CashDisplay
-- Actualiza el TextLabel "CASH" con el dinero del jugador
-- INSTRUCCIONES: Pegar este script como LocalScript en StarterGui > PrincipalGui > Frame

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Referencia al TextLabel CASH (debe estar en la misma carpeta Frame)
local cashLabel = script.Parent:WaitForChild("CASH")

-- Variable de dinero actual
local currentMoney = 0

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

-- Actualiza el texto del label
local function updateDisplay(money)
	currentMoney = money or 0

	-- Formatear el texto (puedes personalizarlo)
	cashLabel.Text = string.format("$%s", formatNumber(math.floor(currentMoney)))
end

-- Configurar listener para cambios en leaderstats
local function setupMoneyListener()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("[CashDisplay] No se encontraron leaderstats")
		return
	end

	local money = leaderstats:WaitForChild("Money", 5)
	if not money then
		warn("[CashDisplay] No se encontró Money en leaderstats")
		return
	end

	-- Listener para cambios en Money
	money:GetPropertyChangedSignal("Value"):Connect(function()
		updateDisplay(money.Value)
	end)

	-- Inicializar valor
	updateDisplay(money.Value)
end

-- Inicializar
task.spawn(function()
	task.wait(1)  -- Esperar a que leaderstats se cree
	setupMoneyListener()
end)

print("[CashDisplay] ✅ Sistema de display de dinero iniciado")
