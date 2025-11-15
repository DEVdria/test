--[[
	MoneyDisplay.lua
	UBICACIÓN: StarterGui > MoneyUI > MoneyDisplay (LocalScript)

	DESCRIPCIÓN:
	Este script muestra el dinero del jugador en la UI en tiempo real.
	Se actualiza automáticamente cuando el valor de Money cambia.

	REQUISITOS:
	- Debe estar dentro de un ScreenGui llamado "MoneyUI"
	- El ScreenGui debe tener un TextLabel llamado "MoneyLabel"

	FUNCIONES:
	- Actualización en tiempo real del dinero
	- Formato con separadores de miles (ej: 1,000)
	- Manejo de errores si no encuentra los elementos necesarios
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que el jugador esté completamente cargado
player:WaitForChild("leaderstats")

-- Referencias a la UI
local screenGui = script.Parent
local moneyLabel = screenGui:WaitForChild("MoneyLabel")

-- Referencia a la estadística de Money
local leaderstats = player.leaderstats
local money = leaderstats:WaitForChild("Money")

--[[
	Función: formatNumber
	Formatea un número con separadores de miles
	@param number - El número a formatear
	@return string - El número formateado (ej: 1,000)
]]
local function formatNumber(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

--[[
	Función: updateMoneyDisplay
	Actualiza el texto del label con el dinero actual
]]
local function updateMoneyDisplay()
	moneyLabel.Text = "💰 $" .. formatNumber(money.Value)
end

-- Actualizar por primera vez
updateMoneyDisplay()

-- Actualizar cada vez que el dinero cambie
money.Changed:Connect(updateMoneyDisplay)

print("[MoneyDisplay] UI de dinero inicializada para " .. player.Name)
