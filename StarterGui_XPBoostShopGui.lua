-- StarterGui > XPBoostShopGui > LocalScript
-- Cliente del sistema de boost de XP
-- TÚ DISEÑAS LA GUI, este script solo la gestiona

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
	warn("[XPBoostShopGui] ❌ No se encontró RemoteFunction 'GetXPBoost'")
	return
end

if not XPBoostPurchasedEvent then
	warn("[XPBoostShopGui] ❌ No se encontró RemoteEvent 'XPBoostPurchased'")
	return
end

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

local playerGui = player:WaitForChild("PlayerGui")

-- GUI principal (debe existir en StarterGui)
local xpBoostShopGui = script.Parent

-- Frame principal
local shopFrame = xpBoostShopGui:WaitForChild("ShopFrame", 5)
if not shopFrame then
	warn("[XPBoostShopGui] ❌ No se encontró ShopFrame")
	warn("[XPBoostShopGui] 📘 Crea un Frame llamado 'ShopFrame' dentro de XPBoostShopGui")
	return
end

-- Elementos de la GUI
local boostNameLabel = shopFrame:FindFirstChild("BoostNameLabel", true) or shopFrame:FindFirstChild("TitleLabel", true)
local boostDescriptionLabel = shopFrame:FindFirstChild("BoostDescriptionLabel", true) or shopFrame:FindFirstChild("DescriptionLabel", true)
local currentMultiplierLabel = shopFrame:FindFirstChild("CurrentMultiplierLabel", true) or shopFrame:FindFirstChild("CurrentBoostLabel", true)
local purchaseButton = shopFrame:FindFirstChild("PurchaseButton", true) or shopFrame:FindFirstChild("BuyButton", true)

-- Validar elementos esenciales
if not purchaseButton then
	warn("[XPBoostShopGui] ❌ No se encontró PurchaseButton")
	warn("[XPBoostShopGui] 📘 Crea un TextButton llamado 'PurchaseButton' dentro de ShopFrame")
	return
end

-- ==================== VARIABLES ====================

local currentBoostData = nil  -- Información del boost actual del servidor

-- ==================== FUNCIONES ====================

-- Solicita datos del servidor
local function refreshBoostData()
	print("[XPBoostShopGui] 📡 Solicitando datos de boost...")

	-- Deshabilitar botón mientras carga
	purchaseButton.Text = XPBoostConfig.Messages.Loading
	purchaseButton.Enabled = false

	local success, boostData = pcall(function()
		return GetXPBoostFunction:InvokeServer()
	end)

	if not success then
		warn("[XPBoostShopGui] ❌ Error al obtener datos:", boostData)
		purchaseButton.Text = "Error"
		return
	end

	currentBoostData = boostData

	-- Actualizar GUI
	updateGUI()
end

-- Actualiza la GUI con los datos actuales
local function updateGUI()
	if not currentBoostData then return end

	-- Actualizar multiplicador actual
	if currentMultiplierLabel then
		currentMultiplierLabel.Text = string.format("Boost Actual: x%.2f", currentBoostData.CurrentMultiplier)
	end

	-- Si ya tiene el boost máximo
	if currentBoostData.HasMaxBoost then
		if boostNameLabel then
			boostNameLabel.Text = "🎉 Boost Máximo"
		end

		if boostDescriptionLabel then
			boostDescriptionLabel.Text = "Has desbloqueado el boost de XP máximo"
		end

		purchaseButton.Text = XPBoostConfig.Messages.MaxBoostUnlocked
		purchaseButton.Enabled = false

		print("[XPBoostShopGui] ✅ Jugador tiene boost máximo")
		return
	end

	-- Hay un siguiente boost disponible
	local nextBoost = currentBoostData.NextBoost

	if nextBoost then
		-- Actualizar nombre
		if boostNameLabel then
			boostNameLabel.Text = nextBoost.Name
		end

		-- Actualizar descripción
		if boostDescriptionLabel then
			boostDescriptionLabel.Text = nextBoost.Description
		end

		-- Actualizar botón
		purchaseButton.Text = string.format(XPBoostConfig.Messages.PurchaseButton, nextBoost.Price)
		purchaseButton.Enabled = true

		print(string.format("[XPBoostShopGui] ✅ Mostrando boost nivel %d (x%.2f)", nextBoost.Level, nextBoost.Multiplier))
	else
		-- No debería llegar aquí, pero por si acaso
		purchaseButton.Text = "No disponible"
		purchaseButton.Enabled = false
	end
end

-- Intenta comprar el boost
local function attemptPurchase()
	if not currentBoostData or not currentBoostData.NextBoost then
		warn("[XPBoostShopGui] ❌ No hay boost disponible para comprar")
		return
	end

	local nextBoost = currentBoostData.NextBoost

	print(string.format("[XPBoostShopGui] 🛒 Intentando comprar %s (Gamepass ID: %d)", nextBoost.Name, nextBoost.GamepassID))

	-- Verificar que el gamepass esté configurado
	if nextBoost.GamepassID == 0 then
		warn("[XPBoostShopGui] ❌ Gamepass ID no configurado para este boost")
		warn("[XPBoostShopGui] 📘 Edita ReplicatedStorage/Modules/XPBoostConfig")
		return
	end

	-- Abrir prompt de compra
	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, nextBoost.GamepassID)
	end)

	if not success then
		warn("[XPBoostShopGui] ❌ Error al abrir prompt de compra:", err)
	end
end

-- ==================== EVENTOS ====================

-- Botón de compra
purchaseButton.MouseButton1Click:Connect(function()
	attemptPurchase()
end)

-- Detectar cuando se completa una compra
XPBoostPurchasedEvent.OnClientEvent:Connect(function(boostLevel)
	print(string.format("[XPBoostShopGui] 🎉 Boost nivel %d comprado exitosamente", boostLevel))

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

print("[XPBoostShopGui] ✅ Sistema de tienda de boosts de XP iniciado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ XPBoostShopGui (ScreenGui)
	   └─ ShopFrame (Frame)
	      ├─ BoostNameLabel (TextLabel) - Nombre del boost
	      ├─ BoostDescriptionLabel (TextLabel) - Descripción del boost
	      ├─ CurrentMultiplierLabel (TextLabel) - Multiplicador actual
	      └─ PurchaseButton (TextButton) - Botón de compra

	NOMBRES ALTERNATIVOS ACEPTADOS:
	- BoostNameLabel o TitleLabel
	- BoostDescriptionLabel o DescriptionLabel
	- CurrentMultiplierLabel o CurrentBoostLabel
	- PurchaseButton o BuyButton

	FUNCIONAMIENTO:
	1. Al abrir la GUI, se solicitan datos del servidor
	2. Se muestra el siguiente boost disponible para comprar
	3. Al presionar el botón, se abre el prompt de compra del gamepass
	4. Al completar la compra, la GUI se actualiza automáticamente
	5. Si ya tiene el boost máximo, el botón se deshabilita

	CONFIGURACIÓN DE GAMEPASSES:
	Ve a ReplicatedStorage > Modules > XPBoostConfig
	Cambia los valores de GamepassID por los IDs reales de tus gamepasses
]]
