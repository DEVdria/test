-- StarterPlayer > StarterPlayerScripts > ZoneCollisionGui (LocalScript)
-- Muestra una GUI cuando el jugador colisiona con una zona
-- TÚ DISEÑAS LA GUI, este script solo la muestra y conecta el botón de compra

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Esperar NotificationManager global
local NotificationManager = nil
task.spawn(function()
	local maxWait = 5
	local waited = 0
	while not _G.NotificationManager and waited < maxWait do
		task.wait(0.1)
		waited = waited + 0.1
	end
	NotificationManager = _G.NotificationManager
	if NotificationManager then
		print("[ZoneCollisionGui] ✅ NotificationManager conectado")
	else
		warn("[ZoneCollisionGui] ⚠️ NotificationManager no disponible - solo se mostrarán mensajes en output")
	end
end)

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestZonePurchaseEvent = RemoteEvents:WaitForChild("RequestZonePurchase", 10)

if not RequestZonePurchaseEvent then
	warn("[ZoneCollisionGui] ❌ No se encontró RemoteEvent 'RequestZonePurchase'")
	return
end

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

-- Buscar el ScreenGui que TÚ diseñaste
local playerGui = player:WaitForChild("PlayerGui")
local zoneGui = playerGui:WaitForChild("ZoneCollisionGui", 10)
if not zoneGui then
	warn("[ZoneCollisionGui] ❌ No se encontró ScreenGui 'ZoneCollisionGui'")
	warn("[ZoneCollisionGui] 📘 Crea un ScreenGui llamado 'ZoneCollisionGui' en StarterGui")
	warn("[ZoneCollisionGui] 📘 Dentro debe tener un Frame llamado 'ZoneFrame'")
	return
end

-- Buscar el Frame principal
local zoneFrame = zoneGui:WaitForChild("ZoneFrame", 5)
if not zoneFrame then
	warn("[ZoneCollisionGui] ❌ No se encontró Frame 'ZoneFrame' dentro del ScreenGui")
	return
end

-- Buscar elementos opcionales dentro del Frame (TÚ defines estos nombres)
local zoneNameLabel = zoneFrame:FindFirstChild("ZoneName", true) or zoneFrame:FindFirstChild("NameLabel", true)
local zonePriceLabel = zoneFrame:FindFirstChild("PriceLabel", true) or zoneFrame:FindFirstChild("Price", true)
local zoneRequirementsLabel = zoneFrame:FindFirstChild("Requirements", true) or zoneFrame:FindFirstChild("RequirementsLabel", true)
local zoneStatusLabel = zoneFrame:FindFirstChild("Status", true) or zoneFrame:FindFirstChild("StatusLabel", true)
local purchaseButton = zoneFrame:FindFirstChild("PurchaseButton", true) or zoneFrame:FindFirstChild("BuyButton", true)

-- Ocultar la GUI al inicio
zoneFrame.Visible = false

-- ==================== VARIABLES DE ESTADO ====================

local currentZone = nil  -- Zona actual en la que está el jugador
local currentZoneConfig = nil
local isOwned = false
local ownedZones = {}  -- Lista de zonas que posee el jugador

-- ==================== FUNCIONES ====================

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

-- Actualiza el contenido de la GUI
local function updateGuiContent(zonePart, zoneConfig, owned)
	-- Actualizar nombre de la zona
	if zoneNameLabel and zoneNameLabel:IsA("TextLabel") then
		zoneNameLabel.Text = zoneConfig.Name or zonePart.Name
	end

	-- Actualizar precio
	if zonePriceLabel and zonePriceLabel:IsA("TextLabel") then
		if zoneConfig.Price == 0 then
			zonePriceLabel.Text = "GRATIS"
		else
			zonePriceLabel.Text = string.format("$%s", formatNumber(zoneConfig.Price))
		end
	end

	-- Actualizar requisitos
	if zoneRequirementsLabel and zoneRequirementsLabel:IsA("TextLabel") then
		local requirements = {}
		if zoneConfig.RequiredLevel > 0 then
			table.insert(requirements, string.format("Nivel %d", zoneConfig.RequiredLevel))
		end
		if zoneConfig.RequiredRebirths > 0 then
			table.insert(requirements, string.format("%d Rebirths", zoneConfig.RequiredRebirths))
		end

		if #requirements > 0 then
			zoneRequirementsLabel.Text = "Requisitos: " .. table.concat(requirements, ", ")
		else
			zoneRequirementsLabel.Text = "Sin requisitos"
		end
	end

	-- Actualizar estado
	if zoneStatusLabel and zoneStatusLabel:IsA("TextLabel") then
		if owned then
			zoneStatusLabel.Text = "✅ YA POSEES ESTA ZONA"
			zoneStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			zoneStatusLabel.Text = "🔒 ZONA BLOQUEADA"
			zoneStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		end
	end

	-- Actualizar botón de compra
	if purchaseButton and purchaseButton:IsA("TextButton") then
		if owned then
			purchaseButton.Text = "YA COMPRADA"
			purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			purchaseButton.Active = false
			purchaseButton.AutoButtonColor = false
		else
			purchaseButton.Text = "COMPRAR ZONA"
			purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			purchaseButton.Active = true
			purchaseButton.AutoButtonColor = true
		end
	end
end

-- Muestra la GUI para una zona específica
local function showZoneGui(zonePart)
	-- No mostrar GUI si el ScreenGui está deshabilitado (modo configuración)
	if not zoneGui.Enabled then
		return
	end

	local zoneConfig = ZoneConfig.GetZone(zonePart.Name)
	if not zoneConfig then
		warn(string.format("[ZoneCollisionGui] ⚠️ No se encontró config para zona: %s", zonePart.Name))
		return
	end

	-- Verificar si el jugador posee esta zona
	isOwned = table.find(ownedZones, zonePart.Name) ~= nil

	-- No mostrar GUI para zonas ya compradas
	if isOwned then
		return
	end

	currentZone = zonePart
	currentZoneConfig = zoneConfig

	-- Actualizar contenido
	updateGuiContent(zonePart, zoneConfig, isOwned)

	-- Mostrar GUI
	zoneFrame.Visible = true

	print(string.format("[ZoneCollisionGui] 📋 Mostrando info de zona: %s", zonePart.Name))
end

-- Oculta la GUI
local function hideZoneGui()
	zoneFrame.Visible = false
	currentZone = nil
	currentZoneConfig = nil
	isOwned = false
	print("[ZoneCollisionGui] 📋 GUI ocultada")
end

-- Verifica si el jugador está tocando una zona
local function checkZoneCollision()
	local buyZones = Workspace:FindFirstChild("Buy Zones")
	if not buyZones then return end

	local touching = false
	local touchedZone = nil

	-- Verificar colisión con cada zona
	for _, zonePart in ipairs(buyZones:GetChildren()) do
		if zonePart:IsA("BasePart") then
			-- Calcular distancia entre jugador y zona
			local distance = (humanoidRootPart.Position - zonePart.Position).Magnitude
			local combinedSize = (humanoidRootPart.Size.Magnitude + zonePart.Size.Magnitude) / 2

			-- Si está tocando la zona (más cerca, sin margen adicional)
			if distance < combinedSize * 0.7 then  -- 70% del tamaño combinado (más cerca)
				touching = true
				touchedZone = zonePart
				break
			end
		end
	end

	-- Mostrar u ocultar GUI según colisión
	if touching and touchedZone then
		if currentZone ~= touchedZone then
			showZoneGui(touchedZone)
		end
	else
		if zoneFrame.Visible then
			hideZoneGui()
		end
	end
end

-- ==================== EVENTOS ====================

-- Conectar botón de compra
if purchaseButton then
	purchaseButton.MouseButton1Click:Connect(function()
		if not currentZoneConfig then return end
		if isOwned then return end  -- Ya posee la zona

		print(string.format("[ZoneCollisionGui] 🛒 Comprando zona: %s", currentZoneConfig.ID))
		RequestZonePurchaseEvent:FireServer(currentZoneConfig.ID)
	end)
end

-- Manejar respuesta de compra
RequestZonePurchaseEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[ZoneCollisionGui] ✅ %s", result.Message))

		-- Mostrar notificación de éxito
		if NotificationManager then
			NotificationManager.Success(result.Message, 3)
		end

		-- Actualizar lista de zonas poseídas
		if currentZone and not table.find(ownedZones, currentZone.Name) then
			table.insert(ownedZones, currentZone.Name)
		end
		-- Actualizar GUI
		if currentZone and currentZoneConfig then
			isOwned = true
			updateGuiContent(currentZone, currentZoneConfig, true)
		end
	else
		warn(string.format("[ZoneCollisionGui] ❌ %s", result.Message))

		-- Mostrar notificación de error
		if NotificationManager then
			NotificationManager.Error(result.Message, 4)
		end
	end
end)

-- Actualizar zonas poseídas desde el servidor
local UpdateZoneOwnershipEvent = RemoteEvents:FindFirstChild("UpdateZoneOwnershipEvent")
if UpdateZoneOwnershipEvent then
	UpdateZoneOwnershipEvent.OnClientEvent:Connect(function(zoneID, owned)
		if zoneID == "RESET_ALL" then
			ownedZones = {}
		elseif zoneID == "ZONES_LOADED" then
			-- Ignorar
		elseif owned and not table.find(ownedZones, zoneID) then
			table.insert(ownedZones, zoneID)
		end
	end)
end

-- Loop de detección de colisión (cada 0.2 segundos)
RunService.Heartbeat:Connect(function()
	-- Solo verificar cada cierto tiempo para mejor performance
	if tick() % 0.2 < 0.016 then  -- Aproximadamente cada 0.2 segundos
		checkZoneCollision()
	end
end)

-- Manejar cuando el personaje muere y reaparece
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	hideZoneGui()
end)

print("[ZoneCollisionGui] ✅ Sistema de GUI de colisión de zonas iniciado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	└─ ZoneCollisionGui (ScreenGui)
	   └─ ZoneFrame (Frame)
	      ├─ ZoneName (TextLabel) - OPCIONAL, muestra nombre de la zona
	      ├─ PriceLabel (TextLabel) - OPCIONAL, muestra precio
	      ├─ Requirements (TextLabel) - OPCIONAL, muestra requisitos
	      ├─ Status (TextLabel) - OPCIONAL, muestra si está bloqueada o comprada
	      └─ PurchaseButton (TextButton) - OPCIONAL, botón para comprar

	NOMBRES ALTERNATIVOS ACEPTADOS:
	- ZoneName o NameLabel
	- PriceLabel o Price
	- Requirements o RequirementsLabel
	- Status o StatusLabel
	- PurchaseButton o BuyButton

	FUNCIONAMIENTO:
	- Cuando el jugador se acerca a una zona (colisiona), se muestra la GUI
	- Cuando se aleja, se oculta la GUI
	- El botón de compra funciona igual que el de la SurfaceGui
	- NO SE MUESTRA en zonas ya compradas
	- NO SE MUESTRA si el ScreenGui está Disabled (útil para configurar sin interferencias)

	CONFIGURACIÓN:
	- Para configurar el GUI sin que aparezca: desactiva Enabled en ZoneCollisionGui
	- En modo juego/pruebas: activa Enabled para que funcione

	PERSONALIZACIÓN:
	- Ajusta la distancia de detección en línea 198: `if distance < combinedSize * 0.7`
	- Cambia 0.7 por un número mayor (ej: 1.0) para detectar desde más lejos
	- O menor (ej: 0.5) para que tenga que estar muy cerca

	EJEMPLO DE DISEÑO SIMPLE:

	1. Crea un ScreenGui llamado "ZoneCollisionGui"
	2. Dentro, crea un Frame llamado "ZoneFrame"
	   - Size: {0.4, 0}, {0.3, 0}
	   - Position: {0.5, 0}, {0.7, 0}
	   - AnchorPoint: 0.5, 0.5
	   - BackgroundColor3: 0, 0, 0
	   - BackgroundTransparency: 0.2
	3. Dentro del Frame, añade:
	   - TextLabel "ZoneName" - Nombre de la zona
	   - TextLabel "PriceLabel" - Precio
	   - TextLabel "Requirements" - Requisitos
	   - TextLabel "Status" - Estado
	   - TextButton "PurchaseButton" - Botón de compra

	El script actualizará automáticamente todo el contenido.
]]
