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

-- Buscar contenedor de trails (donde están tus frames manuales)
local trailsContainer = shopFrame:FindFirstChild("TrailsContainer", true) or shopFrame:FindFirstChild("ScrollingFrame", true)
if not trailsContainer then
	warn("[TrailShopGui] ⚠️ No se encontró contenedor de trails (TrailsContainer o ScrollingFrame)")
	warn("[TrailShopGui] 📘 Se usará el ShopFrame directamente")
	trailsContainer = shopFrame
end

print(string.format("[TrailShopGui] 📦 Contenedor de trails: %s", trailsContainer.Name))

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

-- Obtiene los frames que creaste manualmente en el contenedor
local function getManualTrailFrames()
	local frames = {}

	for _, child in ipairs(trailsContainer:GetChildren()) do
		-- Ignorar elementos que no son frames o que son UIListLayout, UIPadding, etc.
		if child:IsA("Frame") or child:IsA("GuiObject") then
			-- Ignorar si es un UILayout o UIConstraint
			if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and
			   not child:IsA("UIGridLayout") and not child:IsA("UICorner") then
				table.insert(frames, child)
			end
		end
	end

	-- Ordenar frames por LayoutOrder (o Position.Y si no tienen LayoutOrder)
	table.sort(frames, function(a, b)
		if a.LayoutOrder ~= b.LayoutOrder then
			return a.LayoutOrder < b.LayoutOrder
		else
			return a.Position.Y.Scale < b.Position.Y.Scale or
			       (a.Position.Y.Scale == b.Position.Y.Scale and a.Position.Y.Offset < b.Position.Y.Offset)
		end
	end)

	return frames
end

-- Refresca todas las trail cards (actualiza frames existentes)
local function refreshTrailCards()
	trailCards = {}  -- Limpiar referencias

	-- Obtener frames manuales que creaste
	local manualFrames = getManualTrailFrames()

	-- Obtener todas las trails disponibles
	local allTrails = TrailConfig.GetAllTrails()

	print(string.format("[TrailShopGui] 🔍 Frames encontrados: %d, Trails disponibles: %d", #manualFrames, #allTrails))

	-- Asociar cada frame con una trail por índice
	for index, trail in ipairs(allTrails) do
		local frame = manualFrames[index]

		if frame then
			-- Verificar si el jugador posee y tiene equipada esta trail
			local owned = table.find(ownedTrails, trail.ID) ~= nil
			local equipped = (equippedTrail == trail.ID)

			-- Actualizar contenido del frame
			updateTrailCard(frame, trail, owned, equipped)

			-- Guardar referencia
			trailCards[trail.ID] = frame

			print(string.format("[TrailShopGui] ✅ Frame '%s' asociado con trail '%s'", frame.Name, trail.ID))
		else
			warn(string.format("[TrailShopGui] ⚠️ No hay frame para la trail #%d (%s). Crea más frames en TrailsContainer.", index, trail.ID))
		end
	end

	-- Contar trails configuradas (trailCards es una tabla con claves string, no numérica)
	local count = 0
	for _ in pairs(trailCards) do
		count = count + 1
	end

	print(string.format("[TrailShopGui] 🔄 Tienda refrescada - %d trails configuradas", count))
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

-- Muestra la tienda (sin animación, respeta tu diseño)
local function openShop()
	loadTrailData()  -- Recargar datos al abrir
	shopFrame.Visible = true
	print("[TrailShopGui] 🛒 Tienda abierta")
end

-- Cierra la tienda
local function closeShop()
	shopFrame.Visible = false
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
	⚠️ IMPORTANTE: TÚ CREAS LOS FRAMES MANUALMENTE (NO SE CLONAN)

	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ TrailShopGui (ScreenGui)
	   ├─ TrailShopGui (LocalScript) ← Este script va AQUÍ
	   ├─ OpenShopButton (TextButton) - Botón visible para abrir la tienda
	   └─ ShopFrame (Frame) - Frame principal de la tienda
	      │  Properties: Visible = false (empieza oculto)
	      │
	      ├─ CloseButton (TextButton) - OPCIONAL, botón para cerrar
	      │
	      └─ TrailsContainer (ScrollingFrame o Frame) - Contenedor de tus frames
	         ├─ Frame1 (Frame) ← TÚ CREAS ESTE - Se asocia con Trail #1 (Fire)
	         │  ├─ TrailName (TextLabel) - OPCIONAL
	         │  ├─ Description (TextLabel) - OPCIONAL
	         │  ├─ Price (TextLabel) - OPCIONAL
	         │  ├─ Requirements (TextLabel) - OPCIONAL
	         │  ├─ Status (TextLabel) - OPCIONAL
	         │  ├─ BuyButton (TextButton) - OPCIONAL
	         │  └─ EquipButton (TextButton) - OPCIONAL
	         │
	         ├─ Frame2 (Frame) ← TÚ CREAS ESTE - Se asocia con Trail #2 (Lightning)
	         │  └─ (mismos elementos internos)
	         │
	         └─ Frame3 (Frame) ← TÚ CREAS ESTE - Se asocia con Trail #3 (Rainbow)
	            └─ (mismos elementos internos)

	CÓMO FUNCIONA:
	1. TÚ creas manualmente 1 Frame por cada trail que tengas en TrailConfig
	2. Actualmente hay 3 trails (Fire, Lightning, Rainbow), así que necesitas 3 frames
	3. El script detecta automáticamente los frames en orden (LayoutOrder o Position.Y)
	4. Frame #1 = Trail #1 (Fire), Frame #2 = Trail #2 (Lightning), etc.
	5. El script actualiza el contenido de cada frame con la info de su trail

	NOMBRES ALTERNATIVOS ACEPTADOS PARA ELEMENTOS INTERNOS:
	- TrailName o Name
	- Description o Desc
	- Price o PriceLabel
	- Requirements o Reqs
	- Status o StatusLabel
	- BuyButton o PurchaseButton

	FUNCIONAMIENTO:
	- Click en OpenShopButton → muestra ShopFrame (sin animación)
	- El script detecta tus frames y los llena con info de las trails
	- Trails compradas se marcan como "YA COMPRADA"
	- Trail equipada se marca como "EQUIPADA"
	- Botones funcionan automáticamente

	SI AÑADES MÁS TRAILS:
	- Edita TrailConfig y añade una nueva trail
	- Crea un nuevo Frame en TrailsContainer
	- El script lo detectará automáticamente

	EJEMPLO RÁPIDO:
	1. Crea TrailsContainer (ScrollingFrame)
	2. Dentro, crea 3 Frames (Frame1, Frame2, Frame3)
	3. Dentro de cada Frame, añade TextLabels y TextButtons con los nombres de arriba
	4. El script automáticamente los llenará con la info correcta
]]
