-- StarterPlayer > StarterPlayerScripts > ZoneClientManager
-- Gestiona la actualización de SurfaceGuis en las zonas
-- TÚ DISEÑAS LAS SURFACEGUIS, este script solo actualiza los datos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ZoneConfig = require(Modules:WaitForChild("ZoneConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestZonePurchaseEvent = RemoteEvents:WaitForChild("RequestZonePurchase", 10)
local UpdateZoneOwnershipEvent = RemoteEvents:WaitForChild("UpdateZoneOwnership", 10)

if not RequestZonePurchaseEvent then
	warn("[ZoneClientManager] ❌ No se encontró RemoteEvent 'RequestZonePurchase'")
	warn("[ZoneClientManager] 📘 Crea este RemoteEvent en ReplicatedStorage/RemoteEvents")
	return
end

if not UpdateZoneOwnershipEvent then
	warn("[ZoneClientManager] ❌ No se encontró RemoteEvent 'UpdateZoneOwnership'")
	warn("[ZoneClientManager] 📘 Crea este RemoteEvent en ReplicatedStorage/RemoteEvents")
	return
end

-- Estado local de zonas poseídas
local ownedZones = {}

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

-- Actualiza la SurfaceGui de una zona
local function updateZoneSurfaceGui(zonePart, zoneConfig, isOwned)
	-- Buscar SurfaceGui en el Part
	local surfaceGui = zonePart:FindFirstChildOfClass("SurfaceGui")
	if not surfaceGui then
		warn(string.format("[ZoneClientManager] ⚠️ Part '%s' no tiene SurfaceGui", zonePart.Name))
		return
	end

	-- Buscar elementos por nombre (TÚ defines estos nombres en tu diseño)

	-- TextLabel para mostrar nombre de la zona (busca "ZoneName" o "NameLabel")
	local nameLabel = surfaceGui:FindFirstChild("ZoneName", true) or surfaceGui:FindFirstChild("NameLabel", true)
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = zoneConfig.Name
	end

	-- TextLabel para mostrar precio (busca "PriceLabel" o "Cost")
	local priceLabel = surfaceGui:FindFirstChild("PriceLabel", true) or surfaceGui:FindFirstChild("Cost", true)
	if priceLabel and priceLabel:IsA("TextLabel") then
		if zoneConfig.Price == 0 then
			priceLabel.Text = "GRATIS"
		else
			priceLabel.Text = string.format("$%s", formatNumber(zoneConfig.Price))
		end
	end

	-- TextLabel para requisitos (busca "RequirementsLabel" or "Requirements")
	local reqLabel = surfaceGui:FindFirstChild("RequirementsLabel", true) or surfaceGui:FindFirstChild("Requirements", true)
	if reqLabel and reqLabel:IsA("TextLabel") then
		local requirements = {}
		if zoneConfig.RequiredLevel > 0 then
			table.insert(requirements, string.format("Nivel %d", zoneConfig.RequiredLevel))
		end
		if zoneConfig.RequiredRebirths > 0 then
			table.insert(requirements, string.format("%d Rebirths", zoneConfig.RequiredRebirths))
		end

		if #requirements > 0 then
			reqLabel.Text = "Requisitos: " .. table.concat(requirements, ", ")
		else
			reqLabel.Text = ""
		end
	end

	-- Frame o TextLabel para mostrar estado (busca "StatusLabel" o "Status")
	local statusLabel = surfaceGui:FindFirstChild("StatusLabel", true) or surfaceGui:FindFirstChild("Status", true)
	if statusLabel then
		if isOwned then
			if statusLabel:IsA("TextLabel") then
				statusLabel.Text = "✅ DESBLOQUEADA"
				statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			elseif statusLabel:IsA("Frame") then
				statusLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			end
		else
			if statusLabel:IsA("TextLabel") then
				statusLabel.Text = "🔒 BLOQUEADA"
				statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			elseif statusLabel:IsA("Frame") then
				statusLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end
		end
	end

	-- TextButton para comprar (busca "PurchaseButton" or "BuyButton")
	local purchaseButton = surfaceGui:FindFirstChild("PurchaseButton", true) or surfaceGui:FindFirstChild("BuyButton", true)
	if purchaseButton and purchaseButton:IsA("TextButton") then
		if isOwned then
			purchaseButton.Text = "DESBLOQUEADA"
			purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			purchaseButton.Active = false
		else
			purchaseButton.Text = "COMPRAR"
			purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			purchaseButton.Active = true

			-- Conectar evento de clic
			purchaseButton.MouseButton1Click:Connect(function()
				print(string.format("[ZoneClientManager] Comprando zona: %s", zoneConfig.ID))
				RequestZonePurchaseEvent:FireServer(zoneConfig.ID)
			end)
		end
	end
end

-- Inicializa todas las zonas
local function initializeZones()
	-- Buscar carpeta Buy Zones en Workspace
	local buyZones = Workspace:FindFirstChild("Buy Zones")
	if not buyZones then
		warn("[ZoneClientManager] ❌ No se encontró carpeta 'Buy Zones' en Workspace")
		warn("[ZoneClientManager] 📘 Crea una carpeta llamada 'Buy Zones' en Workspace")
		return
	end

	-- Buscar todos los Parts en Buy Zones
	for _, zonePart in ipairs(buyZones:GetChildren()) do
		if zonePart:IsA("BasePart") then
			local zoneConfig = ZoneConfig.GetZone(zonePart.Name)

			if zoneConfig then
				local isOwned = table.find(ownedZones, zonePart.Name) ~= nil
				updateZoneSurfaceGui(zonePart, zoneConfig, isOwned)
			else
				warn(string.format("[ZoneClientManager] ⚠️ Part '%s' no tiene configuración en ZoneConfig", zonePart.Name))
			end
		end
	end
end

-- Actualiza el estado de una zona específica
local function updateZoneOwnership(zoneID, isOwned)
	-- Actualizar estado local
	if isOwned and not table.find(ownedZones, zoneID) then
		table.insert(ownedZones, zoneID)
	end

	-- Buscar el Part de la zona
	local buyZones = Workspace:FindFirstChild("Buy Zones")
	if not buyZones then return end

	local zonePart = buyZones:FindFirstChild(zoneID)
	if not zonePart then return end

	local zoneConfig = ZoneConfig.GetZone(zoneID)
	if not zoneConfig then return end

	-- Actualizar SurfaceGui
	updateZoneSurfaceGui(zonePart, zoneConfig, isOwned)

	print(string.format("[ZoneClientManager] Zona %s actualizada (Owned: %s)", zoneID, tostring(isOwned)))
end

-- Manejar respuesta de compra
RequestZonePurchaseEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[ZoneClientManager] ✅ %s", result.Message))
		-- La actualización vendrá por UpdateZoneOwnershipEvent
	else
		warn(string.format("[ZoneClientManager] ❌ %s", result.Message))
	end
end)

-- Escuchar actualizaciones de ownership
UpdateZoneOwnershipEvent.OnClientEvent:Connect(function(zoneID, isOwned)
	updateZoneOwnership(zoneID, isOwned)
end)

-- Inicializar al cargar
task.wait(2)  -- Esperar a que todo cargue
initializeZones()

print("[ZoneClientManager] ✅ Sistema de zonas del cliente inicializado")
print(string.format("[ZoneClientManager] Zonas poseídas: %d", #ownedZones))
