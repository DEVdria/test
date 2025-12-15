-- StarterGui > TrailShopGui (LocalScript)
-- Maneja la interfaz de la tienda de trails
-- TÚ DISEÑAS LA GUI, este script la conecta y gestiona

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Esperar módulos y eventos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TrailConfig = require(Modules:WaitForChild("TrailConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestTrailPurchaseEvent = RemoteEvents:WaitForChild("RequestTrailPurchase")
local EquipTrailEvent = RemoteEvents:WaitForChild("EquipTrail")
local GetTrailDataEvent = RemoteEvents:WaitForChild("GetTrailData")

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

local playerGui = player:WaitForChild("PlayerGui")

-- Buscar el ScreenGui de la tienda
local trailShopGui = playerGui:WaitForChild("TrailShopGui", 10)
if not trailShopGui then
	warn("[TrailShopGui] ❌ No se encontró ScreenGui 'TrailShopGui'")
	warn("[TrailShopGui] 📘 Crea un ScreenGui llamado 'TrailShopGui' en StarterGui")
	return
end

-- Buscar el Frame principal de la tienda
local shopFrame = trailShopGui:WaitForChild("ShopFrame", 5)
if not shopFrame then
	warn("[TrailShopGui] ❌ No se encontró Frame 'ShopFrame' dentro del ScreenGui")
	return
end

-- Buscar el botón para abrir la tienda
local openShopButton = trailShopGui:WaitForChild("OpenShopButton", 5)
if not openShopButton or not openShopButton:IsA("TextButton") then
	warn("[TrailShopGui] ❌ No se encontró TextButton 'OpenShopButton'")
	warn("[TrailShopGui] 📘 Añade un TextButton llamado 'OpenShopButton' al ScreenGui")
	return
end

-- Buscar botón para cerrar la tienda (opcional)
local closeButton = shopFrame:FindFirstChild("CloseButton", true)

-- Buscar contenedor de trails (donde se clonarán las trail cards)
local trailsContainer = shopFrame:FindFirstChild("TrailsContainer", true) or shopFrame:FindFirstChild("ScrollingFrame", true)
if not trailsContainer then
	warn("[TrailShopGui] ⚠️ No se encontró contenedor de trails (TrailsContainer o ScrollingFrame)")
	warn("[TrailShopGui] 📘 Se usará el ShopFrame directamente")
	trailsContainer = shopFrame
end

-- Buscar template de trail card (debe estar dentro del contenedor o del shopFrame)
local trailCardTemplate = shopFrame:FindFirstChild("TrailCardTemplate", true)
if not trailCardTemplate then
	warn("[TrailShopGui] ❌ No se encontró 'TrailCardTemplate'")
	warn("[TrailShopGui] 📘 Crea un Frame llamado 'TrailCardTemplate' para usar como plantilla")
	return
end

-- Ocultar template
trailCardTemplate.Visible = false

-- Ocultar tienda al inicio
shopFrame.Visible = false

-- ==================== VARIABLES ====================

local ownedTrails = {}
local equippedTrail = nil
local trailCards = {}  -- Guardar referencia a las cards creadas

-- ==================== FUNCIONES DE UTILIDAD ====================

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

-- ==================== FUNCIONES DE GUI ====================

-- Actualiza el contenido de una trail card
local function updateTrailCard(card, trail, owned, equipped)
	-- Buscar elementos dentro de la card (con nombres alternativos)
	local nameLabel = card:FindFirstChild("TrailName", true) or card:FindFirstChild("Name", true)
	local descLabel = card:FindFirstChild("Description", true) or card:FindFirstChild("Desc", true)
	local priceLabel = card:FindFirstChild("Price", true) or card:FindFirstChild("PriceLabel", true)
	local requirementsLabel = card:FindFirstChild("Requirements", true) or card:FindFirstChild("Reqs", true)
	local statusLabel = card:FindFirstChild("Status", true) or card:FindFirstChild("StatusLabel", true)
	local buyButton = card:FindFirstChild("BuyButton", true) or card:FindFirstChild("PurchaseButton", true)
	local equipButton = card:FindFirstChild("EquipButton", true)

	-- Actualizar nombre
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = trail.Name
	end

	-- Actualizar descripción
	if descLabel and descLabel:IsA("TextLabel") then
		descLabel.Text = trail.Description
	end

	-- Actualizar precio
	if priceLabel and priceLabel:IsA("TextLabel") then
		if trail.Price == 0 then
			priceLabel.Text = "GRATIS"
		else
			priceLabel.Text = string.format("⭐ %s Stars", formatNumber(trail.Price))
		end
	end

	-- Actualizar requisitos
	if requirementsLabel and requirementsLabel:IsA("TextLabel") then
		local reqs = {}
		if trail.RequiredLevel > 0 then
			table.insert(reqs, string.format("Nivel %d", trail.RequiredLevel))
		end
		if trail.RequiredRebirths > 0 then
			table.insert(reqs, string.format("%d Rebirths", trail.RequiredRebirths))
		end

		if #reqs > 0 then
			requirementsLabel.Text = table.concat(reqs, " • ")
		else
			requirementsLabel.Text = "Sin requisitos"
		end
	end

	-- Actualizar estado
	if statusLabel and statusLabel:IsA("TextLabel") then
		if equipped then
			statusLabel.Text = "✅ EQUIPADA"
			statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		elseif owned then
			statusLabel.Text = "✔️ COMPRADA"
			statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
		else
			statusLabel.Text = "🔒 BLOQUEADA"
			statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		end
	end

	-- Configurar botón de compra
	if buyButton and buyButton:IsA("TextButton") then
		if owned then
			buyButton.Text = "YA COMPRADA"
			buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			buyButton.Active = false
			buyButton.AutoButtonColor = false
		elseif trail.Price == 0 then
			buyButton.Text = "OBTENER GRATIS"
			buyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			buyButton.Active = true
			buyButton.AutoButtonColor = true
		else
			buyButton.Text = string.format("COMPRAR (%s⭐)", formatNumber(trail.Price))
			buyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			buyButton.Active = true
			buyButton.AutoButtonColor = true
		end

		-- Conectar evento de compra
		buyButton.MouseButton1Click:Connect(function()
			if not owned then
				print(string.format("[TrailShopGui] 🛒 Comprando trail: %s", trail.ID))
				RequestTrailPurchaseEvent:FireServer(trail.ID)
			end
		end)
	end

	-- Configurar botón de equipar
	if equipButton and equipButton:IsA("TextButton") then
		if not owned then
			equipButton.Visible = false
		elseif equipped then
			equipButton.Text = "EQUIPADA"
			equipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			equipButton.Active = false
			equipButton.AutoButtonColor = false
			equipButton.Visible = true
		else
			equipButton.Text = "EQUIPAR"
			equipButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
			equipButton.Active = true
			equipButton.AutoButtonColor = true
			equipButton.Visible = true

			-- Conectar evento de equipar
			equipButton.MouseButton1Click:Connect(function()
				print(string.format("[TrailShopGui] 👕 Equipando trail: %s", trail.ID))
				EquipTrailEvent:FireServer(trail.ID)
			end)
		end
	end
end

-- Crea una card para una trail
local function createTrailCard(trail, index)
	local card = trailCardTemplate:Clone()
	card.Name = "TrailCard_" .. trail.ID
	card.Visible = true
	card.Parent = trailsContainer

	-- Verificar si el jugador posee y tiene equipada esta trail
	local owned = table.find(ownedTrails, trail.ID) ~= nil
	local equipped = (equippedTrail == trail.ID)

	-- Actualizar contenido de la card
	updateTrailCard(card, trail, owned, equipped)

	-- Guardar referencia
	trailCards[trail.ID] = card

	return card
end

-- Refresca todas las trail cards
local function refreshTrailCards()
	-- Limpiar cards existentes
	for _, card in pairs(trailCards) do
		card:Destroy()
	end
	trailCards = {}

	-- Crear cards para todas las trails
	local allTrails = TrailConfig.GetAllTrails()
	for index, trail in ipairs(allTrails) do
		createTrailCard(trail, index)
	end

	print(string.format("[TrailShopGui] 🔄 Tienda refrescada - %d trails mostradas", #allTrails))
end

-- Carga los datos de trail del servidor
local function loadTrailData()
	print("[TrailShopGui] 📡 Cargando datos de trails...")

	local success, trailData = pcall(function()
		return GetTrailDataEvent:InvokeServer()
	end)

	if success and trailData then
		ownedTrails = trailData.OwnedTrails or {}
		equippedTrail = trailData.EquippedTrail

		print(string.format("[TrailShopGui] ✅ Datos cargados - Trails: %d, Equipada: %s",
			#ownedTrails, equippedTrail or "ninguna"))

		refreshTrailCards()
	else
		warn("[TrailShopGui] ⚠️ Error cargando datos de trails")
	end
end

-- Muestra la tienda con animación
local function openShop()
	loadTrailData()  -- Recargar datos al abrir

	shopFrame.Visible = true

	-- Animación de entrada (opcional, solo si quieres)
	shopFrame.Size = UDim2.new(0, 0, 0, 0)
	local openTween = TweenService:Create(
		shopFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0.7, 0, 0.8, 0)}  -- Ajusta el tamaño según tu diseño
	)
	openTween:Play()

	print("[TrailShopGui] 🛒 Tienda abierta")
end

-- Cierra la tienda con animación
local function closeShop()
	local closeTween = TweenService:Create(
		shopFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = UDim2.new(0, 0, 0, 0)}
	)
	closeTween:Play()

	closeTween.Completed:Connect(function()
		shopFrame.Visible = false
	end)

	print("[TrailShopGui] 🛒 Tienda cerrada")
end

-- ==================== EVENTOS ====================

-- Abrir tienda al hacer clic en el botón
openShopButton.MouseButton1Click:Connect(function()
	openShop()
end)

-- Cerrar tienda si existe el botón de cerrar
if closeButton and closeButton:IsA("TextButton") then
	closeButton.MouseButton1Click:Connect(function()
		closeShop()
	end)
end

-- Manejar respuesta de compra
RequestTrailPurchaseEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[TrailShopGui] ✅ %s", result.Message))

		-- Añadir a trails poseídas
		if not table.find(ownedTrails, result.TrailID) then
			table.insert(ownedTrails, result.TrailID)
		end

		-- Refrescar tienda
		refreshTrailCards()
	else
		warn(string.format("[TrailShopGui] ❌ %s", result.Message))
	end
end)

-- Manejar respuesta de equipamiento
EquipTrailEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[TrailShopGui] ✅ %s", result.Message))

		-- Actualizar trail equipada
		equippedTrail = result.TrailID

		-- Refrescar tienda
		refreshTrailCards()
	else
		warn(string.format("[TrailShopGui] ❌ %s", result.Message))
	end
end)

-- ==================== INICIALIZACIÓN ====================

-- Cargar datos iniciales
task.wait(2)  -- Esperar a que todo esté listo
loadTrailData()

print("[TrailShopGui] ✅ Sistema de tienda de trails iniciado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ TrailShopGui (ScreenGui)
	   ├─ OpenShopButton (TextButton) - Botón visible para abrir la tienda
	   └─ ShopFrame (Frame) - Frame principal de la tienda
	      ├─ CloseButton (TextButton) - OPCIONAL, botón para cerrar
	      ├─ TrailsContainer (ScrollingFrame o Frame) - OPCIONAL, contenedor de trails
	      └─ TrailCardTemplate (Frame) - Template de una trail card
	         ├─ TrailName (TextLabel) - OPCIONAL, nombre de la trail
	         ├─ Description (TextLabel) - OPCIONAL, descripción
	         ├─ Price (TextLabel) - OPCIONAL, precio
	         ├─ Requirements (TextLabel) - OPCIONAL, requisitos
	         ├─ Status (TextLabel) - OPCIONAL, estado (equipada/comprada/bloqueada)
	         ├─ BuyButton (TextButton) - OPCIONAL, botón de compra
	         └─ EquipButton (TextButton) - OPCIONAL, botón de equipar

	NOMBRES ALTERNATIVOS ACEPTADOS:
	- TrailName o Name
	- Description o Desc
	- Price o PriceLabel
	- Requirements o Reqs
	- Status o StatusLabel
	- BuyButton o PurchaseButton

	FUNCIONAMIENTO:
	- Click en OpenShopButton abre la tienda
	- La tienda muestra todas las trails disponibles
	- Trails compradas se marcan como "COMPRADA"
	- Trail equipada se marca como "EQUIPADA"
	- Botón de compra permite comprar nuevas trails
	- Botón de equipar permite cambiar la trail activa

	PERSONALIZACIÓN:
	- Diseña la GUI como quieras en StarterGui
	- El script solo gestiona la lógica y eventos
	- Puedes añadir más elementos visuales libremente
	- La animación de apertura/cierre puede modificarse en las funciones openShop/closeShop
]]
