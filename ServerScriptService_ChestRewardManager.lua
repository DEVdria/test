--[[
	CHEST REWARD MANAGER
	Gestiona los cofres de recompensas temporales en Workspace/CHEST REWARD LEVEL.

	CARACTERÍSTICAS:
	- Los jugadores tocan la MeshPart "touch" para reclamar recompensas
	- Cooldown de 4 horas por cofre (configurable)
	- Muestra temporizador en BillboardGui
	- Guarda cooldowns en DataStore
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Importar configuración
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChestRewardConfig = require(Modules:WaitForChild("ChestRewardConfig"))

print("[ChestRewardManager] 🎁 Inicializando sistema de cofres...")

-- ========================================
-- VARIABLES
-- ========================================
local chestsFolder = Workspace:WaitForChild("CHEST REWARD LEVEL")
local activeConnections = {}  -- Almacena las conexiones de .Touched para limpieza

-- ========================================
-- REMOTES
-- ========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- RemoteFunction para obtener el tiempo restante del cooldown
local GetChestCooldownFunction = RemotesFolder:FindFirstChild("GetChestCooldown")
if not GetChestCooldownFunction then
	GetChestCooldownFunction = Instance.new("RemoteFunction")
	GetChestCooldownFunction.Name = "GetChestCooldown"
	GetChestCooldownFunction.Parent = RemotesFolder
	print("[ChestRewardManager] ✅ RemoteFunction 'GetChestCooldown' creada")
end

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene el tiempo restante de cooldown para un cofre
local function getRemainingCooldown(player, chestID)
	if not _G.DataManager then return 0 end

	local data = _G.DataManager.GetData(player)
	if not data or not data.ChestCooldowns then return 0 end

	local cooldownEnd = data.ChestCooldowns[tostring(chestID)]
	if not cooldownEnd then return 0 end

	local now = os.time()
	local remaining = cooldownEnd - now

	return math.max(0, remaining)
end

-- Establece el cooldown de un cofre
local function setChestCooldown(player, chestID, cooldownSeconds)
	if not _G.DataManager then return false end

	local data = _G.DataManager.GetData(player)
	if not data then return false end

	if not data.ChestCooldowns then
		data.ChestCooldowns = {}
	end

	-- Guardar el timestamp cuando expira el cooldown
	data.ChestCooldowns[tostring(chestID)] = os.time() + cooldownSeconds

	print(string.format("[ChestRewardManager] ⏰ Cooldown de %d segundos establecido para %s en chest%d",
		cooldownSeconds, player.Name, chestID))

	return true
end

-- Procesa el reclamo de un cofre
local function claimChest(player, chestID, chestConfig)
	-- Verificar cooldown
	local remaining = getRemainingCooldown(player, chestID)
	if remaining > 0 then
		local timeFormatted = ChestRewardConfig.FormatTime(remaining)
		warn(string.format("[ChestRewardManager] ⏳ %s intentó reclamar chest%d pero está en cooldown (%s restante)",
			player.Name, chestID, timeFormatted))
		return false
	end

	-- Otorgar recompensa
	if _G.DataManager and _G.DataManager.AddMoney then
		_G.DataManager.AddMoney(player, chestConfig.MoneyReward)
		print(string.format("[ChestRewardManager] 💰 %s reclamó chest%d y recibió %d dinero",
			player.Name, chestID, chestConfig.MoneyReward))
	end

	-- Establecer cooldown
	setChestCooldown(player, chestID, chestConfig.Cooldown)

	return true
end

-- ========================================
-- CONFIGURAR COFRES
-- ========================================

local function setupChest(chestModel, chestConfig)
	-- Buscar la MeshPart "touch"
	local touchPart = chestModel:FindFirstChild("touch")
	if not touchPart or not touchPart:IsA("BasePart") then
		warn(string.format("[ChestRewardManager] ❌ No se encontró 'touch' MeshPart en %s", chestModel.Name))
		return
	end

	-- Buscar el BillboardGui/Timer
	local billboardGui = touchPart:FindFirstChildOfClass("BillboardGui")
	local timerLabel
	if billboardGui then
		timerLabel = billboardGui:FindFirstChild("Timer")
		if timerLabel then
			print(string.format("[ChestRewardManager] ✅ Timer encontrado en %s", chestModel.Name))
		end
	end

	-- Configurar el evento Touched
	local connection = touchPart.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		-- Intentar reclamar el cofre
		local success = claimChest(player, chestConfig.ID, chestConfig)

		if success then
			print(string.format("[ChestRewardManager] ✅ %s reclamó %s exitosamente",
				player.Name, chestConfig.ModelName))
		else
			local remaining = getRemainingCooldown(player, chestConfig.ID)
			local timeFormatted = ChestRewardConfig.FormatTime(remaining)
			print(string.format("[ChestRewardManager] ⏳ %s debe esperar %s para reclamar %s",
				player.Name, timeFormatted, chestConfig.ModelName))
		end
	end)

	-- Almacenar la conexión para limpieza posterior
	table.insert(activeConnections, connection)

	print(string.format("[ChestRewardManager] 📦 Cofre %s configurado (Recompensa: %d, Cooldown: %s)",
		chestConfig.ModelName,
		chestConfig.MoneyReward,
		ChestRewardConfig.FormatTime(chestConfig.Cooldown)
	))
end

-- Inicializar todos los cofres
local function initializeChests()
	for _, chestConfig in ipairs(ChestRewardConfig.Chests) do
		local chestModel = chestsFolder:FindFirstChild(chestConfig.ModelName)

		if chestModel then
			setupChest(chestModel, chestConfig)
		else
			warn(string.format("[ChestRewardManager] ⚠️ No se encontró el modelo '%s' en CHEST REWARD LEVEL",
				chestConfig.ModelName))
		end
	end
end

-- ========================================
-- REMOTE FUNCTIONS
-- ========================================

-- Cuando un cliente solicita el cooldown de un cofre
GetChestCooldownFunction.OnServerInvoke = function(player, chestID)
	local remaining = getRemainingCooldown(player, chestID)
	return remaining
end

-- ========================================
-- INICIALIZACIÓN
-- ========================================

-- Esperar a que DataManager esté disponible
task.spawn(function()
	local attempts = 0
	while not _G.DataManager and attempts < 50 do
		task.wait(0.1)
		attempts = attempts + 1
	end

	if not _G.DataManager then
		warn("[ChestRewardManager] ❌ DataManager no disponible después de 5 segundos")
		return
	end

	-- Inicializar cofres
	initializeChests()

	print("[ChestRewardManager] ✅ Sistema de cofres inicializado")
	print(string.format("[ChestRewardManager] 📊 %d cofres configurados", #ChestRewardConfig.Chests))
end)

-- Limpieza al cerrar
game:BindToClose(function()
	for _, connection in ipairs(activeConnections) do
		connection:Disconnect()
	end
end)
