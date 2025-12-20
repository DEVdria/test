-- ServerScriptService > BoostManager (Script)
-- Gestiona los multiplicadores temporales de XP y Money del servidor
-- Este sistema es independiente de los boosts globales y se usa para Daily Rewards

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar DataManager
repeat task.wait(0.1) until _G.DataManager
local DataManager = _G.DataManager

-- Esperar RemoteEvents
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- Crear RemoteEvent para actualizaciones de boost
local BoostUpdateEvent = RemotesFolder:FindFirstChild("DailyBoostUpdate")
if not BoostUpdateEvent then
	BoostUpdateEvent = Instance.new("RemoteEvent")
	BoostUpdateEvent.Name = "DailyBoostUpdate"
	BoostUpdateEvent.Parent = RemotesFolder
end

-- ==================== VARIABLES ====================

-- Almacenar boosts activos por jugador
-- Estructura: {player = {XPBoost = {multiplier, endTime}, MoneyBoost = {multiplier, endTime}}}
local activeBoosts = {}

-- ==================== MÓDULO GLOBAL ====================

_G.BoostManager = _G.BoostManager or {}
local BoostManager = _G.BoostManager

-- ==================== FUNCIONES PRIVADAS ====================

-- Envia actualización de boost al cliente
local function notifyClient(player, boostType, multiplier, timeRemaining)
	BoostUpdateEvent:FireClient(player, {
		BoostType = boostType,
		Multiplier = multiplier,
		TimeRemaining = timeRemaining,
		Active = timeRemaining > 0
	})
end

-- Limpia un boost expirado
local function clearBoost(player, boostType)
	if activeBoosts[player] and activeBoosts[player][boostType] then
		activeBoosts[player][boostType] = nil
		notifyClient(player, boostType, 1, 0)
		print(string.format("[BoostManager] ⏱️ Boost de %s expirado para %s", boostType, player.Name))
	end
end

-- ==================== FUNCIONES PÚBLICAS ====================

-- Activa un boost temporal para un jugador
function BoostManager.ActivateBoost(player, boostType, multiplier, duration)
	if not player or not player.Parent then return false end

	-- Validar parámetros
	if boostType ~= "XP" and boostType ~= "Money" then
		warn(string.format("[BoostManager] Tipo de boost inválido: %s", tostring(boostType)))
		return false
	end

	-- Inicializar tabla de boosts del jugador si no existe
	if not activeBoosts[player] then
		activeBoosts[player] = {}
	end

	-- Calcular tiempo de finalización
	local endTime = os.time() + duration

	-- Guardar boost
	activeBoosts[player][boostType] = {
		Multiplier = multiplier,
		EndTime = endTime
	}

	-- Notificar al cliente
	notifyClient(player, boostType, multiplier, duration)

	print(string.format("[BoostManager] 🔥 Boost de %s activado para %s: x%.1f durante %d segundos",
		boostType, player.Name, multiplier, duration))

	-- Programar limpieza del boost
	task.delay(duration, function()
		clearBoost(player, boostType)
	end)

	return true
end

-- Obtiene el multiplicador actual de XP para un jugador
function BoostManager.GetXPMultiplier(player)
	if not activeBoosts[player] or not activeBoosts[player].XP then
		return 1  -- Sin boost
	end

	local boost = activeBoosts[player].XP
	if os.time() >= boost.EndTime then
		-- Boost expirado
		clearBoost(player, "XP")
		return 1
	end

	return boost.Multiplier
end

-- Obtiene el multiplicador actual de Money para un jugador
function BoostManager.GetMoneyMultiplier(player)
	if not activeBoosts[player] or not activeBoosts[player].Money then
		return 1  -- Sin boost
	end

	local boost = activeBoosts[player].Money
	if os.time() >= boost.EndTime then
		-- Boost expirado
		clearBoost(player, "Money")
		return 1
	end

	return boost.Multiplier
end

-- Obtiene información de todos los boosts activos de un jugador
function BoostManager.GetActiveBoosts(player)
	local boosts = {
		XP = {Active = false, Multiplier = 1, TimeRemaining = 0},
		Money = {Active = false, Multiplier = 1, TimeRemaining = 0}
	}

	if not activeBoosts[player] then
		return boosts
	end

	-- Verificar boost de XP
	if activeBoosts[player].XP then
		local timeRemaining = activeBoosts[player].XP.EndTime - os.time()
		if timeRemaining > 0 then
			boosts.XP.Active = true
			boosts.XP.Multiplier = activeBoosts[player].XP.Multiplier
			boosts.XP.TimeRemaining = timeRemaining
		else
			clearBoost(player, "XP")
		end
	end

	-- Verificar boost de Money
	if activeBoosts[player].Money then
		local timeRemaining = activeBoosts[player].Money.EndTime - os.time()
		if timeRemaining > 0 then
			boosts.Money.Active = true
			boosts.Money.Multiplier = activeBoosts[player].Money.Multiplier
			boosts.Money.TimeRemaining = timeRemaining
		else
			clearBoost(player, "Money")
		end
	end

	return boosts
end

-- Cancela todos los boosts de un jugador
function BoostManager.ClearAllBoosts(player)
	if activeBoosts[player] then
		clearBoost(player, "XP")
		clearBoost(player, "Money")
		activeBoosts[player] = nil
		print(string.format("[BoostManager] 🧹 Todos los boosts limpiados para %s", player.Name))
	end
end

-- ==================== INTEGRACIÓN CON DATAMANAGER ====================

-- Hook en DataManager.AddEXP para aplicar multiplicador
if DataManager.AddEXP then
	local originalAddEXP = DataManager.AddEXP

	function DataManager.AddEXP(player, amount)
		local multiplier = BoostManager.GetXPMultiplier(player)
		local finalAmount = math.floor(amount * multiplier)

		-- Llamar función original con cantidad multiplicada
		return originalAddEXP(player, finalAmount)
	end

	print("[BoostManager] ✅ Hook de XP instalado en DataManager.AddEXP")
end

-- Hook en DataManager.AddMoney para aplicar multiplicador
if DataManager.AddMoney then
	local originalAddMoney = DataManager.AddMoney

	function DataManager.AddMoney(player, amount)
		local multiplier = BoostManager.GetMoneyMultiplier(player)
		local finalAmount = math.floor(amount * multiplier)

		-- Llamar función original con cantidad multiplicada
		return originalAddMoney(player, finalAmount)
	end

	print("[BoostManager] ✅ Hook de Money instalado en DataManager.AddMoney")
end

-- ==================== EVENTOS DE JUGADOR ====================

-- Limpiar boosts cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
	if activeBoosts[player] then
		activeBoosts[player] = nil
		print(string.format("[BoostManager] 🧹 Boosts limpiados para %s (salió del juego)", player.Name))
	end
end)

-- ==================== LOOP DE ACTUALIZACIÓN ====================

-- Enviar actualizaciones periódicas a los clientes
task.spawn(function()
	while true do
		task.wait(1)  -- Actualizar cada segundo

		for player, boosts in pairs(activeBoosts) do
			if player and player.Parent then
				-- Actualizar boost de XP
				if boosts.XP then
					local timeRemaining = boosts.XP.EndTime - os.time()
					if timeRemaining > 0 then
						notifyClient(player, "XP", boosts.XP.Multiplier, timeRemaining)
					else
						clearBoost(player, "XP")
					end
				end

				-- Actualizar boost de Money
				if boosts.Money then
					local timeRemaining = boosts.Money.EndTime - os.time()
					if timeRemaining > 0 then
						notifyClient(player, "Money", boosts.Money.Multiplier, timeRemaining)
					else
						clearBoost(player, "Money")
					end
				end
			else
				-- Jugador desconectado, limpiar
				activeBoosts[player] = nil
			end
		end
	end
end)

print("[BoostManager] ✅ Sistema de boosts temporales iniciado")
