--[[
═══════════════════════════════════════════════════════════════
    CHEST SCRIPT - Sistema de Cofre con Recompensa
    Ubicación: ServerScriptService

    Cómo usar:
    1. Crea una Part en Workspace y nómbrala "TreasureChest"
    2. Añade un ProximityPrompt como hijo de la Part
    3. Este script detectará automáticamente todos los cofres

    Funcionalidad:
    - Detecta ProximityPrompt en cofres
    - Da dinero cuando un jugador activa el cofre
    - Tiempo de enfriamiento entre usos
    - Efectos visuales al recolectar
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear RemoteEvent para sonidos si no existe
local playSoundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
if not playSoundEvent then
	playSoundEvent = Instance.new("RemoteEvent")
	playSoundEvent.Name = "PlaySound"
	playSoundEvent.Parent = ReplicatedStorage
end

-- CONFIGURACIÓN
local CHEST_REWARD = 50 -- Dinero que otorga el cofre
local COOLDOWN_TIME = 30 -- Tiempo de espera entre usos (segundos)

-- Tabla para almacenar cooldowns por jugador
local playerCooldowns = {}

--[[
    Función: Verificar si el jugador puede usar el cofre
    Parámetros: player - El jugador que intenta usar el cofre
    Retorna: true si puede usar, false si está en cooldown
--]]
local function canUseChest(player)
	local userId = player.UserId
	local currentTime = tick()

	if playerCooldowns[userId] then
		local timeLeft = playerCooldowns[userId] - currentTime
		if timeLeft > 0 then
			return false, timeLeft
		end
	end

	return true, 0
end

--[[
    Función: Establecer cooldown para un jugador
    Parámetros: player - El jugador
--]]
local function setCooldown(player)
	local userId = player.UserId
	playerCooldowns[userId] = tick() + COOLDOWN_TIME
end

--[[
    Función: Crear efecto visual al abrir cofre
    Parámetros: chest - La part del cofre
--]]
local function createChestEffect(chest)
	-- Efecto de partículas (opcional)
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Speed = NumberRange.new(5, 10)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Parent = chest

	-- Cambiar color temporalmente
	local originalColor = chest.Color
	chest.Color = Color3.fromRGB(255, 215, 0) -- Dorado

	-- Remover efectos después de 1 segundo
	task.delay(1, function()
		particle.Enabled = false
		chest.Color = originalColor
		game:GetService("Debris"):AddItem(particle, 2)
	end)
end

--[[
    Función: Configurar un cofre
    Parámetros: chest - La part del cofre
--]]
local function setupChest(chest)
	-- Buscar o crear ProximityPrompt
	local proximityPrompt = chest:FindFirstChildOfClass("ProximityPrompt")

	if not proximityPrompt then
		-- Crear ProximityPrompt si no existe
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ObjectText = "Cofre del Tesoro"
		proximityPrompt.ActionText = "Abrir"
		proximityPrompt.MaxActivationDistance = 8
		proximityPrompt.HoldDuration = 1
		proximityPrompt.Parent = chest
	end

	-- Evento cuando se activa el prompt
	proximityPrompt.Triggered:Connect(function(player)
		-- Verificar cooldown
		local canUse, timeLeft = canUseChest(player)

		if not canUse then
			-- Notificar al jugador que debe esperar
			local event = ReplicatedStorage:FindFirstChild("SendNotification")
			if event then
				event:FireClient(player, "⏰ Debes esperar " .. math.ceil(timeLeft) .. " segundos", Color3.fromRGB(255, 170, 0))
			end
			return
		end

		-- Añadir dinero usando el MoneyManager
		if _G.MoneyManager then
			_G.MoneyManager.AddMoney(player, CHEST_REWARD)

			-- Establecer cooldown
			setCooldown(player)

			-- Crear efecto visual
			createChestEffect(chest)

			-- Notificar al jugador
			local event = ReplicatedStorage:FindFirstChild("SendNotification")
			if event then
				event:FireClient(player, "💰 +$" .. CHEST_REWARD .. " del cofre!", Color3.fromRGB(85, 255, 127))
			end

			-- Reproducir sonido de cofre
			playSoundEvent:FireClient(player, "Chests", "TreasureChest", chest.Position)

			print(player.Name .. " abrió un cofre y recibió $" .. CHEST_REWARD)
		else
			warn("MoneyManager no está disponible. Asegúrate de que el script MoneyManager esté en ServerScriptService.")
		end
	end)

	print("Cofre configurado: " .. chest:GetFullName())
end

--[[
    Buscar y configurar todos los cofres en Workspace
--]]
local function findAndSetupChests()
	for _, obj in pairs(game.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "TreasureChest" then
			setupChest(obj)
		end
	end
end

-- Configurar cofres existentes
findAndSetupChests()

-- Configurar nuevos cofres que se añadan
game.Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == "TreasureChest" then
		setupChest(obj)
	end
end)

-- Limpiar cooldowns cuando un jugador sale
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)

print("Sistema de cofres inicializado")
