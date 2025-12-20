-- ServerScriptService > DailyRewardManager (Script)
-- Gestiona el sistema de recompensas diarias del servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DailyRewardConfig = require(Modules:WaitForChild("DailyRewardConfig"))

-- Esperar DataManager y BoostManager
repeat task.wait(0.1) until _G.DataManager
repeat task.wait(0.1) until _G.BoostManager
local DataManager = _G.DataManager
local BoostManager = _G.BoostManager

-- Esperar/Crear RemoteEvents
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- RemoteFunction para obtener información
local GetRewardInfoFunction = RemotesFolder:FindFirstChild(DailyRewardConfig.RemoteEvents.GetRewardInfo)
if not GetRewardInfoFunction then
	GetRewardInfoFunction = Instance.new("RemoteFunction")
	GetRewardInfoFunction.Name = DailyRewardConfig.RemoteEvents.GetRewardInfo
	GetRewardInfoFunction.Parent = RemotesFolder
end

-- RemoteEvent para reclamar recompensas
local ClaimRewardEvent = RemotesFolder:FindFirstChild(DailyRewardConfig.RemoteEvents.ClaimReward)
if not ClaimRewardEvent then
	ClaimRewardEvent = Instance.new("RemoteEvent")
	ClaimRewardEvent.Name = DailyRewardConfig.RemoteEvents.ClaimReward
	ClaimRewardEvent.Parent = RemotesFolder
end

print("[DailyRewardManager] ✅ RemoteEvents creados")

-- ==================== FUNCIONES DE DATASTORE ====================

-- Obtiene los datos de recompensas diarias del jugador
local function getDailyRewardData(player)
	local data = DataManager.GetData(player)
	if not data then return nil end

	-- Inicializar datos de Daily Rewards si no existen
	if not data.DailyRewards then
		data.DailyRewards = {
			CurrentDay = 1,                    -- Día actual en el ciclo (1-7)
			LastClaimTime = 0,                 -- Timestamp de última reclamación
			TotalClaimed = 0                   -- Total de recompensas reclamadas
		}
	end

	return data.DailyRewards
end

-- Guarda los datos de Daily Rewards
local function saveDailyRewardData(player)
	return DataManager.SaveData(player)
end

-- ==================== FUNCIONES DE LÓGICA ====================

-- Calcula si el jugador puede reclamar la recompensa
local function canClaimReward(dailyData)
	if not dailyData then return false end

	local timeSinceLastClaim = os.time() - dailyData.LastClaimTime
	return timeSinceLastClaim >= DailyRewardConfig.CLAIM_COOLDOWN
end

-- Calcula tiempo restante hasta que pueda reclamar
local function getTimeUntilClaim(dailyData)
	if not dailyData then return 0 end

	local timeSinceLastClaim = os.time() - dailyData.LastClaimTime
	local timeRemaining = DailyRewardConfig.CLAIM_COOLDOWN - timeSinceLastClaim

	return math.max(0, timeRemaining)
end

-- Obtiene información completa de recompensas para el cliente
local function getRewardInfo(player)
	local dailyData = getDailyRewardData(player)
	if not dailyData then
		return {Success = false, Message = "Error al cargar datos"}
	end

	local canClaim = canClaimReward(dailyData)
	local timeUntilClaim = getTimeUntilClaim(dailyData)

	-- Obtener información de boosts activos
	local activeBoosts = BoostManager.GetActiveBoosts(player)

	return {
		Success = true,
		CurrentDay = dailyData.CurrentDay,
		CanClaim = canClaim,
		TimeUntilClaim = timeUntilClaim,
		TotalClaimed = dailyData.TotalClaimed,
		ActiveBoosts = activeBoosts
	}
end

-- Aplica una recompensa al jugador
local function applyReward(player, reward)
	if reward.Type == "Money" then
		-- Dar dinero instantáneo
		DataManager.AddMoney(player, reward.MoneyAmount)
		return string.format("¡Recibiste %s monedas!", DailyRewardConfig.FormatNumber(reward.MoneyAmount))

	elseif reward.Type == "XPBoost" then
		-- Activar boost de XP
		BoostManager.ActivateBoost(player, "XP", reward.BoostMultiplier, reward.BoostDuration)
		local duration = DailyRewardConfig.FormatTime(reward.BoostDuration)
		return string.format("🔥 x%.0f XP activado durante %s", reward.BoostMultiplier, duration)

	elseif reward.Type == "MoneyBoost" then
		-- Activar boost de Money
		BoostManager.ActivateBoost(player, "Money", reward.BoostMultiplier, reward.BoostDuration)
		local duration = DailyRewardConfig.FormatTime(reward.BoostDuration)
		return string.format("💵 x%.0f Money activado durante %s", reward.BoostMultiplier, duration)

	elseif reward.Type == "DoubleBoost" then
		-- Activar ambos boosts (DÍA 7)
		BoostManager.ActivateBoost(player, "XP", reward.XPMultiplier, reward.BoostDuration)
		BoostManager.ActivateBoost(player, "Money", reward.MoneyMultiplier, reward.BoostDuration)
		local duration = DailyRewardConfig.FormatTime(reward.BoostDuration)
		return string.format("🔥 x%.0f XP + x%.0f Money durante %s",
			reward.XPMultiplier, reward.MoneyMultiplier, duration)
	end

	return "Recompensa reclamada"
end

-- ==================== EVENTOS REMOTOS ====================

-- Manejar solicitud de información
GetRewardInfoFunction.OnServerInvoke = function(player)
	return getRewardInfo(player)
end

-- Manejar reclamación de recompensa
ClaimRewardEvent.OnServerEvent:Connect(function(player)
	-- Validar que el jugador existe
	if not player or not player.Parent then return end

	-- Obtener datos
	local dailyData = getDailyRewardData(player)
	if not dailyData then
		ClaimRewardEvent:FireClient(player, {
			Success = false,
			Message = "Error al cargar datos"
		})
		return
	end

	-- Validar que puede reclamar
	if not canClaimReward(dailyData) then
		local timeRemaining = getTimeUntilClaim(dailyData)
		ClaimRewardEvent:FireClient(player, {
			Success = false,
			Message = string.format("Vuelve en %s", DailyRewardConfig.FormatTime(timeRemaining))
		})
		return
	end

	-- Obtener recompensa del día actual
	local reward = DailyRewardConfig.GetReward(dailyData.CurrentDay)
	if not reward then
		ClaimRewardEvent:FireClient(player, {
			Success = false,
			Message = "Error: Recompensa no encontrada"
		})
		return
	end

	-- Aplicar recompensa
	local message = applyReward(player, reward)

	-- Actualizar datos
	dailyData.LastClaimTime = os.time()
	dailyData.TotalClaimed = dailyData.TotalClaimed + 1

	-- Avanzar al siguiente día (ciclo 1-7)
	if dailyData.CurrentDay >= 7 then
		dailyData.CurrentDay = 1  -- Reiniciar ciclo
		print(string.format("[DailyRewardManager] 🔄 %s completó el ciclo de 7 días!", player.Name))
	else
		dailyData.CurrentDay = dailyData.CurrentDay + 1
	end

	-- Guardar datos
	saveDailyRewardData(player)

	-- Notificar éxito al cliente
	ClaimRewardEvent:FireClient(player, {
		Success = true,
		Message = message,
		RewardDay = reward.Day,
		RewardType = reward.Type,
		NextDay = dailyData.CurrentDay
	})

	print(string.format("[DailyRewardManager] 🎁 %s reclamó recompensa del Día %d: %s",
		player.Name, reward.Day, reward.DisplayName))
end)

-- ==================== EVENTOS DE JUGADOR ====================

-- Cuando un jugador entra, enviar notificación si tiene recompensa disponible
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que los datos se carguen
	task.wait(2)

	local dailyData = getDailyRewardData(player)
	if dailyData and canClaimReward(dailyData) then
		-- Enviar señal al cliente para abrir la GUI automáticamente
		task.wait(1)  -- Esperar un poco más para que la GUI esté lista
		local RewardAvailableEvent = RemotesFolder:FindFirstChild("DailyRewardAvailable")
		if not RewardAvailableEvent then
			RewardAvailableEvent = Instance.new("RemoteEvent")
			RewardAvailableEvent.Name = "DailyRewardAvailable"
			RewardAvailableEvent.Parent = RemotesFolder
		end

		RewardAvailableEvent:FireClient(player)
		print(string.format("[DailyRewardManager] 🔔 Notificación de recompensa enviada a %s", player.Name))
	end
end)

print("[DailyRewardManager] ✅ Sistema de recompensas diarias inicializado")
