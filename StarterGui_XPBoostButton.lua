-- StarterGui > XPBoostButton > LocalScript
-- Cliente del sistema de boost de XP
-- Un solo botón en pantalla principal que se actualiza dinámicamente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local XPBoostConfig = require(Modules:WaitForChild("XPBoostConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GetXPBoostFunction = RemoteEvents:WaitForChild("GetXPBoost", 10)
local XPBoostPurchasedEvent = RemoteEvents:WaitForChild("XPBoostPurchased", 10)

if not GetXPBoostFunction then
	warn("[XPBoostButton] ❌ No se encontró RemoteFunction 'GetXPBoost'")
	return
end

if not XPBoostPurchasedEvent then
	warn("[XPBoostButton] ❌ No se encontró RemoteEvent 'XPBoostPurchased'")
	return
end

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

-- GUI principal (ScreenGui que contiene el botón)
local xpBoostGui = script.Parent

-- Botón principal
local boostButton = xpBoostGui:FindFirstChild("BoostButton", true) or xpBoostGui:FindFirstChild("XPBoostButton", true)

if not boostButton or not boostButton:IsA("TextButton") then
	warn("[XPBoostButton] ❌ No se encontró BoostButton (TextButton)")
	warn("[XPBoostButton] 📘 Crea un TextButton llamado 'BoostButton' en el ScreenGui")
	return
end

-- Labels dentro del botón
local multiplierLabel = boostButton:FindFirstChild("MultiplierLabel", true) or boostButton:FindFirstChild("BoostLabel", true)
local priceLabel = boostButton:FindFirstChild("PriceLabel", true) or boostButton:FindFirstChild("CostLabel", true)

-- Los labels son opcionales, pero es bueno tenerlos
if not multiplierLabel then
	warn("[XPBoostButton] ⚠️ No se encontró MultiplierLabel - solo se actualizará el botón")
end

if not priceLabel then
	warn("[XPBoostButton] ⚠️ No se encontró PriceLabel - solo se mostrará precio en el botón")
end

-- ==================== VARIABLES ====================

local currentBoostData = nil  -- Información del boost actual del servidor

-- ==================== FUNCIONES ====================

-- Actualiza la GUI con los datos actuales
local function updateGUI()
	if not currentBoostData then return end

	-- Si ya tiene el boost máximo
	if currentBoostData.HasMaxBoost then
		boostButton.Text = "XP Máxima"
		boostButton.Active = false
		boostButton.AutoButtonColor = false

		if multiplierLabel then
			multiplierLabel.Text = string.format("x%.1f", currentBoostData.CurrentMultiplier)
		end

		if priceLabel then
			priceLabel.Text = "MAX"
		end

		print("[XPBoostButton] ✅ Jugador tiene boost máximo")
		return
	end

	-- Hay un siguiente boost disponible
	local nextBoost = currentBoostData.NextBoost

	if nextBoost then
		-- Calcular el porcentaje de boost
		local boostPercent = (nextBoost.Multiplier - 1) * 100

		-- Actualizar texto del botón (opcional, puede estar vacío si usas labels)
		boostButton.Text = ""  -- Vacío para que solo se vean los labels
		boostButton.Active = true
		boostButton.AutoButtonColor = true

		-- Actualizar label de multiplicador
		if multiplierLabel then
			multiplierLabel.Text = string.format("+%d%% XP", boostPercent)
		else
			-- Si no hay label, mostrar en el botón
			boostButton.Text = string.format("+%d%% XP", boostPercent)
		end

		-- Actualizar label de precio
		if priceLabel then
			priceLabel.Text = tostring(nextBoost.Price)
		else
			-- Si no hay label de precio, agregarlo al texto del botón
			if boostButton.Text ~= "" then
				boostButton.Text = boostButton.Text .. " - " .. nextBoost.Price .. " Robux"
			else
				boostButton.Text = nextBoost.Price .. " Robux"
			end
		end

		print(string.format("[XPBoostButton] ✅ Mostrando boost nivel %d: +%d%% XP por %d Robux",
			nextBoost.Level, boostPercent, nextBoost.Price))
	else
		-- No debería llegar aquí, pero por si acaso
		boostButton.Text = "No disponible"
		boostButton.Active = false
		boostButton.AutoButtonColor = false
	end
end

-- Solicita datos del servidor
local function refreshBoostData()
	print("[XPBoostButton] 📡 Solicitando datos de boost...")

	-- Deshabilitar botón mientras carga
	boostButton.Text = "Cargando..."
	boostButton.Active = false
	boostButton.AutoButtonColor = false

	local success, boostData = pcall(function()
		return GetXPBoostFunction:InvokeServer()
	end)

	if not success then
		warn("[XPBoostButton] ❌ Error al obtener datos:", boostData)
		boostButton.Text = "Error"
		return
	end

	currentBoostData = boostData

	-- Actualizar GUI
	updateGUI()
end

-- Intenta comprar el boost
local function attemptPurchase()
	if not currentBoostData or not currentBoostData.NextBoost then
		warn("[XPBoostButton] ❌ No hay boost disponible para comprar")
		return
	end

	local nextBoost = currentBoostData.NextBoost

	print(string.format("[XPBoostButton] 🛒 Intentando comprar %s (Gamepass ID: %d)", nextBoost.Name, nextBoost.GamepassID))

	-- Verificar que el gamepass esté configurado
	if nextBoost.GamepassID == 0 then
		warn("[XPBoostButton] ❌ Gamepass ID no configurado para este boost")
		warn("[XPBoostButton] 📘 Edita ReplicatedStorage/Modules/XPBoostConfig")
		return
	end

	-- Abrir prompt de compra
	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, nextBoost.GamepassID)
	end)

	if not success then
		warn("[XPBoostButton] ❌ Error al abrir prompt de compra:", err)
	end
end

-- ==================== EVENTOS ====================

-- Botón de compra
boostButton.MouseButton1Click:Connect(function()
	-- Solo funcionar si el botón está activo
	if not boostButton.Active then
		return
	end

	attemptPurchase()
end)

-- Detectar cuando se completa una compra
XPBoostPurchasedEvent.OnClientEvent:Connect(function(boostLevel)
	print(string.format("[XPBoostButton] 🎉 Boost nivel %d comprado exitosamente", boostLevel))

	-- Refrescar datos
	task.wait(0.5)  -- Pequeña espera para que el servidor actualice
	refreshBoostData()
end)

-- ==================== INICIALIZACIÓN ====================

-- Cargar datos iniciales
task.spawn(function()
	task.wait(1)  -- Esperar a que todo cargue
	refreshBoostData()
end)

print("[XPBoostButton] ✅ Sistema de botón de boost de XP iniciado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ XPBoostButton (ScreenGui)
	   ├─ LocalScript (este script)
	   └─ BoostButton (TextButton) ← BOTÓN PRINCIPAL
	      ├─ MultiplierLabel (TextLabel) [OPCIONAL] - Muestra "+25% XP"
	      └─ PriceLabel (TextLabel) [OPCIONAL] - Muestra "29"

	NOMBRES ALTERNATIVOS ACEPTADOS:
	- BoostButton o XPBoostButton
	- MultiplierLabel o BoostLabel
	- PriceLabel o CostLabel

	EJEMPLO DE VALORES:
	Nivel 1:
	- MultiplierLabel.Text = "+25% XP"
	- PriceLabel.Text = "29"

	Nivel 2:
	- MultiplierLabel.Text = "+50% XP"
	- PriceLabel.Text = "79"

	Nivel 3:
	- MultiplierLabel.Text = "+100% XP"
	- PriceLabel.Text = "149"

	Boost Máximo:
	- MultiplierLabel.Text = "x2.0"
	- PriceLabel.Text = "MAX"
	- BoostButton.Text = "XP Máxima"
	- BoostButton.Active = false (deshabilitado)

	FUNCIONAMIENTO:
	1. Al iniciar, el botón solicita datos del servidor
	2. El botón muestra el siguiente boost disponible
	3. Los labels se actualizan automáticamente
	4. Al hacer clic, se abre la compra del gamepass
	5. Después de comprar, el botón se actualiza al siguiente nivel
	6. Cuando tiene el boost máximo, el botón se deshabilita

	NOTAS:
	- Los labels son OPCIONALES
	- Si no hay labels, toda la info se muestra en el texto del botón
	- El botón se actualiza automáticamente después de cada compra
]]
