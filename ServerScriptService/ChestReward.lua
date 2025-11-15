--[[
	ChestReward.lua
	UBICACIÓN: ServerScriptService

	DESCRIPCIÓN:
	Este script maneja el sistema de cofres con ProximityPrompt.
	Cuando un jugador activa el prompt, recibe dinero como recompensa.

	FUNCIONES:
	- Sistema de cooldown por jugador (evita spam)
	- Recompensas aleatorias o fijas
	- Efectos visuales al abrir cofre
	- Notificación al jugador

	CONFIGURACIÓN:
	- Coloca este script en ServerScriptService
	- Crea una Part en el Workspace y nómbrala "Chest"
	- Agrega un ProximityPrompt dentro de la Part "Chest"
]]

local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN DEL COFRE
-- ═══════════════════════════════════════════════════════════

local CHEST_SETTINGS = {
	-- Ubicación del cofre en el Workspace
	ChestName = "Chest", -- Nombre de la Part que será el cofre

	-- Recompensas
	MinReward = 50,      -- Dinero mínimo que otorga
	MaxReward = 200,     -- Dinero máximo que otorga
	UseRandomReward = true, -- true = aleatorio, false = cantidad fija (MinReward)

	-- Cooldown
	CooldownTime = 60,   -- Segundos antes de que el mismo jugador pueda usar el cofre otra vez

	-- ProximityPrompt Settings
	PromptText = "Abrir Cofre",
	HoldDuration = 1,    -- Segundos que hay que mantener presionado (0 = un click)
	MaxDistance = 8,     -- Distancia máxima para activar
}

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local PlayerCooldowns = {} -- Tabla para rastrear cooldowns de jugadores

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES
-- ═══════════════════════════════════════════════════════════

--[[
	Función: isOnCooldown
	Verifica si un jugador está en cooldown
	@param player - El jugador a verificar
	@return boolean - true si está en cooldown, false si puede usar el cofre
]]
local function isOnCooldown(player)
	if PlayerCooldowns[player.UserId] then
		local timeLeft = PlayerCooldowns[player.UserId] - tick()
		if timeLeft > 0 then
			return true, timeLeft
		else
			PlayerCooldowns[player.UserId] = nil
			return false, 0
		end
	end
	return false, 0
end

--[[
	Función: setCooldown
	Establece un cooldown para un jugador
	@param player - El jugador para establecer el cooldown
]]
local function setCooldown(player)
	PlayerCooldowns[player.UserId] = tick() + CHEST_SETTINGS.CooldownTime
end

--[[
	Función: getRewardAmount
	Calcula la cantidad de dinero a otorgar
	@return number - La cantidad de dinero
]]
local function getRewardAmount()
	if CHEST_SETTINGS.UseRandomReward then
		return math.random(CHEST_SETTINGS.MinReward, CHEST_SETTINGS.MaxReward)
	else
		return CHEST_SETTINGS.MinReward
	end
end

--[[
	Función: giveMoneyToPlayer
	Otorga dinero a un jugador
	@param player - El jugador que recibirá el dinero
	@param amount - La cantidad de dinero a otorgar
	@return boolean - true si se otorgó exitosamente, false si hubo error
]]
local function giveMoneyToPlayer(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("[ChestReward] No se encontró leaderstats para " .. player.Name)
		return false
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		warn("[ChestReward] No se encontró Money para " .. player.Name)
		return false
	end

	money.Value = money.Value + amount
	return true
end

--[[
	Función: playChestAnimation
	Reproduce una animación simple del cofre (opcional)
	@param chest - La Part del cofre
]]
local function playChestAnimation(chest)
	-- Animación simple: hacer que el cofre "salte"
	local originalPosition = chest.Position
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	-- Pequeño salto hacia arriba
	local targetPosition = originalPosition + Vector3.new(0, 2, 0)

	-- Usar coroutine para animación simple sin TweenService
	task.spawn(function()
		for i = 1, 10 do
			chest.Position = chest.Position + Vector3.new(0, 0.2, 0)
			task.wait(0.03)
		end
		for i = 1, 10 do
			chest.Position = chest.Position - Vector3.new(0, 0.2, 0)
			task.wait(0.03)
		end
		chest.Position = originalPosition -- Asegurar posición exacta
	end)
end

--[[
	Función: sendNotification
	Envía una notificación al jugador (usando StarterGui)
	@param player - El jugador que recibirá la notificación
	@param message - El mensaje a mostrar
]]
local function sendNotification(player, message, duration)
	-- Esto requiere un sistema de notificaciones en el cliente
	-- Por ahora, solo imprimiremos en la consola del servidor
	print("[ChestReward] " .. player.Name .. ": " .. message)

	-- TODO: Implementar sistema de notificaciones en el cliente
	-- usando RemoteEvents si quieres notificaciones visuales
end

--[[
	Función: onChestTriggered
	Se ejecuta cuando un jugador activa el ProximityPrompt del cofre
	@param player - El jugador que activó el prompt
	@param chest - La Part del cofre
]]
local function onChestTriggered(player, chest)
	-- Verificar cooldown
	local onCooldown, timeLeft = isOnCooldown(player)
	if onCooldown then
		local message = string.format("⏳ Debes esperar %.0f segundos antes de abrir otro cofre", timeLeft)
		sendNotification(player, message, 3)
		return
	end

	-- Calcular recompensa
	local reward = getRewardAmount()

	-- Otorgar dinero
	local success = giveMoneyToPlayer(player, reward)
	if not success then
		warn("[ChestReward] Error al otorgar dinero a " .. player.Name)
		return
	end

	-- Establecer cooldown
	setCooldown(player)

	-- Animación del cofre
	playChestAnimation(chest)

	-- Notificar al jugador
	local message = string.format("✅ ¡Has recibido $%d del cofre!", reward)
	sendNotification(player, message, 3)

	print(string.format("[ChestReward] %s abrió un cofre y recibió $%d", player.Name, reward))
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

--[[
	Función: setupChest
	Configura un cofre con su ProximityPrompt
	@param chest - La Part del cofre
]]
local function setupChest(chest)
	-- Buscar o crear ProximityPrompt
	local proximityPrompt = chest:FindFirstChildOfClass("ProximityPrompt")

	if not proximityPrompt then
		-- Crear ProximityPrompt si no existe
		proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Parent = chest
	end

	-- Configurar ProximityPrompt
	proximityPrompt.ActionText = CHEST_SETTINGS.PromptText
	proximityPrompt.HoldDuration = CHEST_SETTINGS.HoldDuration
	proximityPrompt.MaxActivationDistance = CHEST_SETTINGS.MaxDistance
	proximityPrompt.ObjectText = "Cofre"
	proximityPrompt.RequiresLineOfSight = false

	-- Conectar evento
	proximityPrompt.Triggered:Connect(function(player)
		onChestTriggered(player, chest)
	end)

	print("[ChestReward] Cofre configurado: " .. chest:GetFullName())
end

-- ═══════════════════════════════════════════════════════════
-- BÚSQUEDA Y CONFIGURACIÓN AUTOMÁTICA DE COFRES
-- ═══════════════════════════════════════════════════════════

-- Función para buscar cofres en el Workspace
local function findAndSetupChests()
	local workspace = game:GetService("Workspace")

	-- Buscar cofre por nombre
	local chest = workspace:FindFirstChild(CHEST_SETTINGS.ChestName)

	if chest and chest:IsA("BasePart") then
		setupChest(chest)
	else
		warn("[ChestReward] ⚠️ No se encontró un cofre llamado '" .. CHEST_SETTINGS.ChestName .. "' en el Workspace")
		warn("[ChestReward] 📝 Instrucciones:")
		warn("    1. Crea una Part en el Workspace")
		warn("    2. Nómbrala '" .. CHEST_SETTINGS.ChestName .. "'")
		warn("    3. El ProximityPrompt se creará automáticamente")
	end

	-- También buscar todos los objetos que contengan "Chest" en el nombre
	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("BasePart") and object.Name:match("Chest") and object ~= chest then
			setupChest(object)
		end
	end
end

-- Esperar a que el Workspace esté listo y buscar cofres
task.wait(1)
findAndSetupChests()

-- Limpiar cooldowns cuando un jugador sale
Players.PlayerRemoving:Connect(function(player)
	PlayerCooldowns[player.UserId] = nil
end)

print("[ChestReward] Sistema de cofres inicializado")
