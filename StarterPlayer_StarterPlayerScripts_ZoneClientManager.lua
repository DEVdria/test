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
local isInitialized = false
local hasReceivedServerData = false
local allZonesLoaded = false

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

	-- ARREGLO: Configurar MaxDistance para que se vea desde lejos
	surfaceGui.MaxDistance = 0  -- 0 = Sin límite de distancia (equivalente a math.huge)
	surfaceGui.AlwaysOnTop = false  -- Para que se renderice correctamente a distancia

	-- NUEVO: Cambiar CanCollide según si está desbloqueada
	zonePart.CanCollide = not isOwned  -- Bloqueada = CanCollide true, Desbloqueada = CanCollide false

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
		priceLabel.Visible = true  -- Asegurar que sea visible
	else
		-- Debug: avisar si no se encuentra el label
		if not priceLabel then
			print(string.format("[ZoneClientManager] ⚠️ No se encontró PriceLabel en zona '%s'", zonePart.Name))
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
			-- Desconectar todos los eventos previos creando un clon
			local newButton = purchaseButton:Clone()
			newButton.Parent = purchaseButton.Parent
			purchaseButton:Destroy()
			purchaseButton = newButton
		else
			purchaseButton.Text = "COMPRAR"
			purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			purchaseButton.Active = true

			-- Desconectar eventos previos clonando el botón
			local newButton = purchaseButton:Clone()
			newButton.Parent = purchaseButton.Parent
			purchaseButton:Destroy()
			purchaseButton = newButton

			-- Conectar evento de clic
			purchaseButton.MouseButton1Click:Connect(function()
				print(string.format("[ZoneClientManager] Comprando zona: %s", zoneConfig.ID))
				RequestZonePurchaseEvent:FireServer(zoneConfig.ID)
			end)
		end
		purchaseButton.Visible = true  -- Asegurar que sea visible
	else
		-- Debug: avisar si no se encuentra el botón
		if not purchaseButton then
			warn(string.format("[ZoneClientManager] ⚠️ No se encontró PurchaseButton en zona '%s'", zonePart.Name))
		end
	end

	print(string.format("[ZoneClientManager] ✅ Zona '%s' actualizada (Owned: %s)", zonePart.Name, tostring(isOwned)))
end

-- Fuerza la actualización de todas las zonas (útil después de recibir datos del servidor)
local function refreshAllZones()
	local buyZones = Workspace:FindFirstChild("Buy Zones")
	if not buyZones then return end

	print(string.format("[ZoneClientManager] 🔄 Refrescando todas las zonas... (Zonas poseídas: %d)", #ownedZones))

	for _, zonePart in ipairs(buyZones:GetChildren()) do
		if zonePart:IsA("BasePart") then
			local zoneConfig = ZoneConfig.GetZone(zonePart.Name)
			if zoneConfig then
				local isOwned = table.find(ownedZones, zonePart.Name) ~= nil
				updateZoneSurfaceGui(zonePart, zoneConfig, isOwned)
			end
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

	print(string.format("[ZoneClientManager] Inicializando zonas... (Zonas poseídas: %d)", #ownedZones))

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

	isInitialized = true
	print("[ZoneClientManager] ✅ Zonas inicializadas")
end

-- Actualiza el estado de una zona específica
local function updateZoneOwnership(zoneID, isOwned)
	-- Marcar que recibimos datos del servidor
	hasReceivedServerData = true

	-- Manejar señal de carga completa
	if zoneID == "ZONES_LOADED" then
		print(string.format("[ZoneClientManager] ✅ Todas las zonas cargadas del servidor (Total: %d)", #ownedZones))
		allZonesLoaded = true
		-- Si aún no está inicializado, inicializar ahora
		if not isInitialized then
			task.delay(0.2, function()
				if not isInitialized then
					initializeZones()
					task.wait(0.3)
					refreshAllZones()
				end
			end)
		end
		return
	end

	-- Manejar señal de reset completo
	if zoneID == "RESET_ALL" then
		print("[ZoneClientManager] 🔄 Reseteando todas las zonas...")
		ownedZones = {}
		-- Refrescar todas las zonas si ya está inicializado
		if isInitialized then
			refreshAllZones()
		end
		return
	end

	-- Actualizar estado local
	if isOwned and not table.find(ownedZones, zoneID) then
		table.insert(ownedZones, zoneID)
		print(string.format("[ZoneClientManager] ➕ Zona añadida: %s (Total: %d)", zoneID, #ownedZones))
	elseif not isOwned then
		-- Remover de la lista si no está owned
		local index = table.find(ownedZones, zoneID)
		if index then
			table.remove(ownedZones, index)
			print(string.format("[ZoneClientManager] ➖ Zona removida: %s (Total: %d)", zoneID, #ownedZones))
		end
	end

	-- Si ya está inicializado, actualizar inmediatamente
	if isInitialized then
		-- Buscar el Part de la zona
		local buyZones = Workspace:FindFirstChild("Buy Zones")
		if not buyZones then return end

		local zonePart = buyZones:FindFirstChild(zoneID)
		if not zonePart then
			-- No es error si no se encuentra, puede ser una zona que ya no existe
			return
		end

		local zoneConfig = ZoneConfig.GetZone(zoneID)
		if not zoneConfig then
			warn(string.format("[ZoneClientManager] ⚠️ No se encontró config para zona: %s", zoneID))
			return
		end

		-- Actualizar SurfaceGui
		updateZoneSurfaceGui(zonePart, zoneConfig, isOwned)
	end
end

-- Manejar respuesta de compra
RequestZonePurchaseEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print(string.format("[ZoneClientManager] ✅ %s", result.Message))
		-- La notificación la muestra ZoneCollisionGui para evitar duplicados
		-- La actualización vendrá por UpdateZoneOwnershipEvent
	else
		warn(string.format("[ZoneClientManager] ❌ %s", result.Message))
		-- La notificación la muestra ZoneCollisionGui para evitar duplicados
	end
end)

-- Escuchar actualizaciones de ownership (del servidor)
UpdateZoneOwnershipEvent.OnClientEvent:Connect(function(zoneID, isOwned)
	updateZoneOwnership(zoneID, isOwned)
end)

-- Esperar a que los datos del jugador y el workspace estén completamente cargados
local function waitForGameLoad()
	print("[ZoneClientManager] ⏳ Esperando carga del juego...")

	-- Esperar a que leaderstats estén disponibles (significa que DataManager cargó)
	local leaderstats = player:WaitForChild("leaderstats", 15)
	if not leaderstats then
		warn("[ZoneClientManager] ⚠️ Leaderstats no disponibles, continuando de todas formas...")
	else
		print("[ZoneClientManager] ✅ Leaderstats cargados")
	end

	-- Esperar a que el servidor envíe la señal ZONES_LOADED (máximo 15 segundos)
	print("[ZoneClientManager] ⏳ Esperando señal ZONES_LOADED del servidor...")
	local maxWait = 15
	local waited = 0
	while not allZonesLoaded and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5

		if waited % 2 == 0 then
			print(string.format("[ZoneClientManager] ⏳ Esperando... (%.1f/%.1f segundos, zonas recibidas: %d)", waited, maxWait, #ownedZones))
		end
	end

	if allZonesLoaded then
		print(string.format("[ZoneClientManager] ✅ Señal de carga completa recibida después de %.1f segundos", waited))
		print(string.format("[ZoneClientManager] ✅ Total de zonas recibidas: %d", #ownedZones))
		-- La inicialización ya se disparó desde updateZoneOwnership
	else
		warn(string.format("[ZoneClientManager] ⚠️ No se recibió señal ZONES_LOADED después de %d segundos", maxWait))
		warn(string.format("[ZoneClientManager] ⚠️ Zonas recibidas hasta ahora: %d", #ownedZones))
		warn("[ZoneClientManager] ⚠️ Inicializando de todas formas...")
		-- Inicializar de todas formas si no recibimos la señal
		if not isInitialized then
			initializeZones()
			task.wait(0.3)
			refreshAllZones()
		end
	end
end

-- Iniciar proceso de carga
task.spawn(waitForGameLoad)

print("[ZoneClientManager] ✅ Sistema de zonas del cliente cargado")
print(string.format("[ZoneClientManager] ⏳ Esperando datos del servidor..."))
