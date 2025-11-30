--[[
	PET SYSTEM SERVER - Script principal del servidor

	Maneja:
	- Compra de huevos (1, 3, auto-open)
	- Equipar/desequipar mascotas
	- Generar mascotas por probabilidad
	- Guardar/cargar datos
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Módulos
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))
local DataManager = require(ServerScriptService:WaitForChild("DataManager"))
local PetFollowSystem = require(ServerScriptService:WaitForChild("PetFollowSystem"))

-- RemoteEvents (los crearemos después)
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local OpenEggRemote = RemoteEventsFolder:WaitForChild("OpenEgg")
local EquipPetRemote = RemoteEventsFolder:WaitForChild("EquipPet")
local UnequipPetRemote = RemoteEventsFolder:WaitForChild("UnequipPet")
local ShowPetRewardRemote = RemoteEventsFolder:WaitForChild("ShowPetReward")
local AutoOpenToggleRemote = RemoteEventsFolder:WaitForChild("AutoOpenToggle")

-- RemoteFunctions
local GetInventoryFunction = RemoteEventsFolder:WaitForChild("GetInventory")

-- Datos de jugadores (tabla en memoria)
local PlayerData = {}

-- Estado de Auto-Open por jugador
local AutoOpenState = {}

-- ============================================
-- FUNCIÓN: GENERAR MASCOTA POR PROBABILIDAD
-- ============================================
local function generatePet(eggType)
	local eggConfig = PetConfig.Eggs[eggType]
	if not eggConfig then
		warn("[PetSystem] Tipo de huevo inválido: " .. tostring(eggType))
		return nil
	end

	-- Calcular probabilidades
	local totalChance = 0
	for _, pet in ipairs(eggConfig.Pets) do
		totalChance = totalChance + pet.Chance
	end

	local randomValue = math.random() * totalChance
	local cumulativeChance = 0

	for _, pet in ipairs(eggConfig.Pets) do
		cumulativeChance = cumulativeChance + pet.Chance
		if randomValue <= cumulativeChance then
			-- Generar mascota con ID único
			return {
				Name = pet.Name,
				Rarity = pet.Rarity,
				xpMultiplier = pet.xpMultiplier,
				UniqueID = DataManager.GenerateUniqueID(),
				Equipped = false
			}
		end
	end

	-- Fallback (no debería llegar aquí)
	local firstPet = eggConfig.Pets[1]
	return {
		Name = firstPet.Name,
		Rarity = firstPet.Rarity,
		xpMultiplier = firstPet.xpMultiplier,
		UniqueID = DataManager.GenerateUniqueID(),
		Equipped = false
	}
end

-- ============================================
-- FUNCIÓN: VERIFICAR GAMEPASS
-- ============================================
local function hasGamepass(player, gamepassId)
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)

	if success then
		return hasPass
	else
		warn("[PetSystem] Error verificando gamepass: " .. tostring(gamepassId))
		return false
	end
end

-- ============================================
-- FUNCIÓN: COBRAR MONEDA
-- ============================================
local function chargeCurrency(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local currency = leaderstats:FindFirstChild(PetConfig.CurrencyName)
	if not currency then return false end

	if currency.Value >= amount then
		currency.Value = currency.Value - amount
		return true
	end

	return false
end

-- ============================================
-- FUNCIÓN: VERIFICAR MONEDA
-- ============================================
local function hasCurrency(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local currency = leaderstats:FindFirstChild(PetConfig.CurrencyName)
	if not currency then return false end

	return currency.Value >= amount
end

-- ============================================
-- REMOTE EVENT: ABRIR HUEVO
-- ============================================
OpenEggRemote.OnServerEvent:Connect(function(player, eggType, openType)
	local eggConfig = PetConfig.Eggs[eggType]
	if not eggConfig then
		warn("[PetSystem] Huevo inválido: " .. tostring(eggType))
		return
	end

	local data = PlayerData[player]
	if not data then return end

	-- Determinar cantidad de huevos a abrir
	local count = 1
	if openType == "Triple" then
		-- Verificar gamepass
		if not hasGamepass(player, eggConfig.Gamepass_TripleOpen) then
			-- Enviar evento para que el cliente muestre mensaje
			ShowPetRewardRemote:FireClient(player, "NoGamepass", {Type = "Triple"})
			return
		end
		count = 3
	elseif openType == "Auto" then
		-- No debe llegar aquí, Auto-Open se maneja separado
		return
	end

	-- Verificar y cobrar dinero
	local totalCost = eggConfig.Price * count
	if not chargeCurrency(player, totalCost) then
		-- No tiene suficiente dinero
		ShowPetRewardRemote:FireClient(player, "NotEnoughMoney", {Required = totalCost})
		return
	end

	-- Generar mascotas
	local generatedPets = {}
	for i = 1, count do
		local pet = generatePet(eggType)
		if pet then
			table.insert(data.Pets, pet)
			table.insert(generatedPets, pet)
		end
	end

	-- Guardar datos
	DataManager.SaveData(player, data)

	-- Enviar mascotas generadas al cliente para mostrar GUI
	ShowPetRewardRemote:FireClient(player, "Success", generatedPets)
end)

-- ============================================
-- REMOTE EVENT: EQUIPAR MASCOTA
-- ============================================
EquipPetRemote.OnServerEvent:Connect(function(player, petUniqueID)
	local data = PlayerData[player]
	if not data then return end

	-- Buscar mascota
	local targetPet = nil
	for _, pet in ipairs(data.Pets) do
		if pet.UniqueID == petUniqueID then
			targetPet = pet
			break
		end
	end

	if not targetPet then
		warn("[PetSystem] Mascota no encontrada: " .. tostring(petUniqueID))
		return
	end

	-- Verificar si ya está equipada
	if targetPet.Equipped then
		return
	end

	-- Verificar límite de mascotas equipadas
	local equippedCount = 0
	for _, pet in ipairs(data.Pets) do
		if pet.Equipped then
			equippedCount = equippedCount + 1
		end
	end

	if equippedCount >= PetConfig.Settings.MaxEquippedPets then
		-- Ya tiene el máximo equipado
		return
	end

	-- Equipar
	targetPet.Equipped = true
	table.insert(data.EquippedPets, petUniqueID)

	-- Guardar
	DataManager.SaveData(player, data)

	-- Actualizar mascotas equipadas visualmente
	local equippedPets = {}
	for _, pet in ipairs(data.Pets) do
		if pet.Equipped then
			table.insert(equippedPets, pet)
		end
	end
	PetFollowSystem.UpdatePets(player, equippedPets)

	print("[PetSystem] " .. player.Name .. " equipó: " .. targetPet.Name)
end)

-- ============================================
-- REMOTE EVENT: DESEQUIPAR MASCOTA
-- ============================================
UnequipPetRemote.OnServerEvent:Connect(function(player, petUniqueID)
	local data = PlayerData[player]
	if not data then return end

	-- Buscar mascota
	local targetPet = nil
	for _, pet in ipairs(data.Pets) do
		if pet.UniqueID == petUniqueID then
			targetPet = pet
			break
		end
	end

	if not targetPet then return end

	-- Desequipar
	targetPet.Equipped = false

	-- Remover de lista de equipadas
	for i, id in ipairs(data.EquippedPets) do
		if id == petUniqueID then
			table.remove(data.EquippedPets, i)
			break
		end
	end

	-- Guardar
	DataManager.SaveData(player, data)

	-- Actualizar mascotas equipadas visualmente
	local equippedPets = {}
	for _, pet in ipairs(data.Pets) do
		if pet.Equipped then
			table.insert(equippedPets, pet)
		end
	end
	PetFollowSystem.UpdatePets(player, equippedPets)

	print("[PetSystem] " .. player.Name .. " desequipó: " .. targetPet.Name)
end)

-- ============================================
-- REMOTE EVENT: AUTO-OPEN TOGGLE
-- ============================================
AutoOpenToggleRemote.OnServerEvent:Connect(function(player, eggType, enabled)
	local eggConfig = PetConfig.Eggs[eggType]
	if not eggConfig then return end

	-- Verificar gamepass
	if not hasGamepass(player, eggConfig.Gamepass_AutoOpen) then
		ShowPetRewardRemote:FireClient(player, "NoGamepass", {Type = "Auto"})
		return
	end

	local data = PlayerData[player]
	if not data then return end

	-- Activar/desactivar auto-open
	if enabled then
		-- Iniciar auto-open
		if AutoOpenState[player] then
			-- Ya está activo
			return
		end

		AutoOpenState[player] = true

		task.spawn(function()
			while AutoOpenState[player] and player.Parent do
				-- Verificar dinero
				if not hasCurrency(player, eggConfig.Price) then
					-- No tiene dinero, detener auto-open
					AutoOpenState[player] = false
					ShowPetRewardRemote:FireClient(player, "AutoOpenStopped", {Reason = "NoMoney"})
					break
				end

				-- Cobrar
				if not chargeCurrency(player, eggConfig.Price) then
					AutoOpenState[player] = false
					break
				end

				-- Generar mascota
				local pet = generatePet(eggType)
				if pet then
					table.insert(data.Pets, pet)
				end

				-- Guardar cada 10 mascotas
				if #data.Pets % 10 == 0 then
					DataManager.SaveData(player, data)
				end

				-- Pequeña espera para no saturar
				task.wait(0.5)
			end

			-- Guardar al terminar
			DataManager.SaveData(player, data)
		end)
	else
		-- Desactivar auto-open
		AutoOpenState[player] = false
	end
end)

-- ============================================
-- REMOTE FUNCTION: OBTENER INVENTARIO
-- ============================================
GetInventoryFunction.OnServerInvoke = function(player)
	local data = PlayerData[player]
	if not data then
		return {Pets = {}, EquippedPets = {}}
	end

	-- Retornar copia del inventario
	return {
		Pets = data.Pets,
		EquippedPets = data.EquippedPets
	}
end

-- ============================================
-- PLAYER ADDED
-- ============================================
Players.PlayerAdded:Connect(function(player)
	-- Cargar datos
	local data = DataManager.LoadData(player)
	PlayerData[player] = data

	-- Setup auto-save
	DataManager.SetupAutoSave(player, PlayerData)

	-- Spawn mascotas equipadas cuando el personaje carga
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.wait(1) -- Esperar a que el personaje cargue completamente

		-- Obtener mascotas equipadas
		local equippedPets = {}
		for _, pet in ipairs(data.Pets) do
			if pet.Equipped then
				table.insert(equippedPets, pet)
			end
		end

		-- Spawn mascotas
		PetFollowSystem.UpdatePets(player, equippedPets)
	end)

	print("[PetSystem] Jugador conectado: " .. player.Name .. " | Mascotas: " .. #data.Pets)
end)

-- ============================================
-- PLAYER REMOVING
-- ============================================
Players.PlayerRemoving:Connect(function(player)
	-- Detener auto-open si está activo
	AutoOpenState[player] = false

	-- Guardar datos
	local data = PlayerData[player]
	if data then
		DataManager.SaveData(player, data)
	end

	-- Limpiar
	PlayerData[player] = nil
end)

-- ============================================
-- SHUTDOWN (guardar todos los datos)
-- ============================================
game:BindToClose(function()
	for player, data in pairs(PlayerData) do
		DataManager.SaveData(player, data)
	end
end)

print("[PetSystem] Sistema de mascotas iniciado ✓")
