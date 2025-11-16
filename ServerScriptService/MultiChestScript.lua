--[[
═══════════════════════════════════════════════════════════════
    MULTI-CHEST SCRIPT - Sistema de Cofres con Diferentes Tipos
    Ubicación: ServerScriptService

    Cómo usar:
    1. Crea Parts en Workspace con estos nombres EXACTOS:
       - "CommonChest" (Cofre Común - Verde)
       - "RareChest" (Cofre Raro - Azul)
       - "EpicChest" (Cofre Épico - Morado)
       - "LegendaryChest" (Cofre Legendario - Dorado)
    2. Los scripts crearán automáticamente ProximityPrompts
    3. Cada tipo tiene diferentes recompensas y cooldowns

    Funcionalidad:
    - 4 tipos diferentes de cofres
    - Recompensas escaladas por rareza
    - Cooldowns diferentes por tipo
    - Efectos visuales únicos por rareza
    - Sistema de partículas
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIGURACIÓN DE TIPOS DE COFRES
local CHEST_TYPES = {
	CommonChest = {
		DisplayName = "Cofre Común",
		Reward = {Min = 25, Max = 50},
		Cooldown = 20,
		Color = Color3.fromRGB(76, 209, 55), -- Verde
		ParticleColor = ColorSequence.new(Color3.fromRGB(76, 209, 55)),
		Icon = "📦",
		Rarity = 1
	},
	RareChest = {
		DisplayName = "Cofre Raro",
		Reward = {Min = 75, Max = 150},
		Cooldown = 45,
		Color = Color3.fromRGB(52, 152, 219), -- Azul
		ParticleColor = ColorSequence.new(Color3.fromRGB(52, 152, 219)),
		Icon = "💎",
		Rarity = 2
	},
	EpicChest = {
		DisplayName = "Cofre Épico",
		Reward = {Min = 200, Max = 400},
		Cooldown = 90,
		Color = Color3.fromRGB(155, 89, 182), -- Morado
		ParticleColor = ColorSequence.new(Color3.fromRGB(155, 89, 182)),
		Icon = "👑",
		Rarity = 3
	},
	LegendaryChest = {
		DisplayName = "Cofre Legendario",
		Reward = {Min = 500, Max = 1000},
		Cooldown = 180,
		Color = Color3.fromRGB(241, 196, 15), -- Dorado
		ParticleColor = ColorSequence.new(Color3.fromRGB(241, 196, 15)),
		Icon = "🏆",
		Rarity = 4
	}
}

-- Tabla para almacenar cooldowns por jugador y cofre
local playerCooldowns = {}

--[[
    Función: Obtener recompensa aleatoria según el tipo de cofre
    Parámetros: chestType - Configuración del tipo de cofre
    Retorna: Cantidad de dinero
--]]
local function getRandomReward(chestType)
	return math.random(chestType.Reward.Min, chestType.Reward.Max)
end

--[[
    Función: Verificar si el jugador puede usar el cofre
    Parámetros:
        player - El jugador
        chestId - ID único del cofre
    Retorna: true si puede usar, false si está en cooldown
--]]
local function canUseChest(player, chestId)
	local userId = player.UserId
	local currentTime = tick()

	if playerCooldowns[userId] and playerCooldowns[userId][chestId] then
		local timeLeft = playerCooldowns[userId][chestId] - currentTime
		if timeLeft > 0 then
			return false, timeLeft
		end
	end

	return true, 0
end

--[[
    Función: Establecer cooldown para un cofre específico
    Parámetros:
        player - El jugador
        chestId - ID único del cofre
        cooldownTime - Tiempo de cooldown
--]]
local function setCooldown(player, chestId, cooldownTime)
	local userId = player.UserId

	if not playerCooldowns[userId] then
		playerCooldowns[userId] = {}
	end

	playerCooldowns[userId][chestId] = tick() + cooldownTime
end

--[[
    Función: Crear efecto visual avanzado al abrir cofre
    Parámetros:
        chest - La part del cofre
        chestType - Configuración del tipo de cofre
--]]
local function createChestEffect(chest, chestType)
	-- Efecto de partículas con color específico
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Color = chestType.ParticleColor
	particle.Rate = 50 * chestType.Rarity
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Speed = NumberRange.new(5, 10 * chestType.Rarity)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particle.Parent = chest

	-- Cambiar color temporalmente
	local originalColor = chest.Color
	local originalMaterial = chest.Material

	chest.Color = chestType.Color
	chest.Material = Enum.Material.Neon

	-- Efecto de brillo
	local light = Instance.new("PointLight")
	light.Color = chestType.Color
	light.Brightness = 2 * chestType.Rarity
	light.Range = 10 * chestType.Rarity
	light.Parent = chest

	-- Animación de rotación
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
	bodyAngularVelocity.MaxTorque = Vector3.new(0, 100000, 0)
	bodyAngularVelocity.Parent = chest

	-- Remover efectos después de 2 segundos
	task.delay(2, function()
		particle.Enabled = false
		bodyAngularVelocity:Destroy()

		task.wait(1)
		light:Destroy()
		chest.Color = originalColor
		chest.Material = originalMaterial
		game:GetService("Debris"):AddItem(particle, 2)
	end)
end

--[[
    Función: Configurar un cofre
    Parámetros:
        chest - La part del cofre
        chestTypeName - Nombre del tipo de cofre
--]]
local function setupChest(chest, chestTypeName)
	local chestType = CHEST_TYPES[chestTypeName]

	if not chestType then
		warn("Tipo de cofre desconocido: " .. chestTypeName)
		return
	end

	-- ID único del cofre basado en su posición
	local chestId = chestTypeName .. "_" .. tostring(chest:GetFullName())

	-- Aplicar color al cofre
	chest.Color = chestType.Color
	chest.Material = Enum.Material.SmoothPlastic

	-- Buscar o crear ProximityPrompt
	local proximityPrompt = chest:FindFirstChildOfClass("ProximityPrompt")

	if not proximityPrompt then
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = chestType.Icon .. " " .. chestType.DisplayName
		proximityPrompt.ActionText = "Abrir"
		proximityPrompt.MaxActivationDistance = 8
		proximityPrompt.HoldDuration = 0.5 * chestType.Rarity
		proximityPrompt.Parent = chest
	end

	-- Evento cuando se activa el prompt
	proximityPrompt.Triggered:Connect(function(player)
		-- Verificar cooldown
		local canUse, timeLeft = canUseChest(player, chestId)

		if not canUse then
			-- Notificar al jugador que debe esperar
			local event = ReplicatedStorage:FindFirstChild("SendNotification")
			if event then
				event:FireClient(
					player,
					"⏰ Debes esperar " .. math.ceil(timeLeft) .. "s para abrir este cofre",
					Color3.fromRGB(255, 170, 0)
				)
			end
			return
		end

		-- Calcular recompensa
		local reward = getRandomReward(chestType)

		-- Añadir dinero usando el MoneyManager
		if _G.MoneyManager then
			_G.MoneyManager.AddMoney(player, reward)

			-- Establecer cooldown
			setCooldown(player, chestId, chestType.Cooldown)

			-- Crear efecto visual
			createChestEffect(chest, chestType)

			-- Actualizar progreso de misiones
			if _G.QuestSystem then
				_G.QuestSystem.UpdateProgress(player, "ChestCollect", 1)
				_G.QuestSystem.UpdateProgress(player, "MoneyEarned", reward)
			end

			-- Notificar al jugador
			local event = ReplicatedStorage:FindFirstChild("SendNotification")
			if event then
				event:FireClient(
					player,
					chestType.Icon .. " ¡+$" .. reward .. " del " .. chestType.DisplayName .. "!",
					chestType.Color
				)
			end

			print(player.Name .. " abrió " .. chestType.DisplayName .. " y recibió $" .. reward)
		else
			warn("MoneyManager no está disponible")
		end
	end)

	print("Cofre configurado: " .. chestType.DisplayName .. " en " .. chest:GetFullName())
end

--[[
    Buscar y configurar todos los cofres en Workspace
--]]
local function findAndSetupChests()
	for chestTypeName, _ in pairs(CHEST_TYPES) do
		for _, obj in pairs(game.Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name == chestTypeName then
				setupChest(obj, chestTypeName)
			end
		end
	end
end

-- Configurar cofres existentes
findAndSetupChests()

-- Configurar nuevos cofres que se añadan
game.Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and CHEST_TYPES[obj.Name] then
		task.wait(0.1) -- Esperar un poco para asegurar que esté completamente cargado
		setupChest(obj, obj.Name)
	end
end)

-- Limpiar cooldowns cuando un jugador sale
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)

print("═══════════════════════════════════════════════════════")
print("📦 Sistema de cofres múltiples inicializado")
print("✅ Tipos de cofres disponibles:")
for name, config in pairs(CHEST_TYPES) do
	print("   " .. config.Icon .. " " .. config.DisplayName .. ": $" .. config.Reward.Min .. "-$" .. config.Reward.Max)
end
print("═══════════════════════════════════════════════════════")
