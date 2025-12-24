-- ServerScriptService > StepManager (Script)
-- Gestiona la experiencia otorgada por pasos

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar DataManager
repeat task.wait(0.1) until _G.DataManager
local DataManager = _G.DataManager

-- Crear/Obtener RemoteEvents
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = ReplicatedStorage
end

-- RemoteEvent para añadir EXP por paso
local AddStepEXPEvent = RemoteEvents:FindFirstChild("AddStepEXP")
if not AddStepEXPEvent then
	AddStepEXPEvent = Instance.new("RemoteEvent")
	AddStepEXPEvent.Name = "AddStepEXP"
	AddStepEXPEvent.Parent = RemoteEvents
end

-- RemoteEvent para mostrar notificación de paso
local ShowStepNotificationEvent = RemoteEvents:FindFirstChild("ShowStepNotification")
if not ShowStepNotificationEvent then
	ShowStepNotificationEvent = Instance.new("RemoteEvent")
	ShowStepNotificationEvent.Name = "ShowStepNotification"
	ShowStepNotificationEvent.Parent = RemoteEvents
end

print("[StepManager] ✅ RemoteEvents creados")

-- ==================== CONFIGURACIÓN ====================
local EXP_PER_STEP = 1              -- EXP otorgada por cada paso

-- ==================== COOLDOWN ANTI-EXPLOIT ====================
local playerCooldowns = {}          -- {[player] = lastStepTime}
local STEP_COOLDOWN = 0.1           -- Mínimo 0.1 segundos entre pasos (anti-spam)

-- ==================== FUNCIÓN PARA OTORGAR EXP ====================

local function giveStepEXP(player)
	-- Verificar cooldown (anti-exploit)
	local currentTime = tick()
	local lastTime = playerCooldowns[player] or 0

	if currentTime - lastTime < STEP_COOLDOWN then
		return false  -- Ignorar si es muy rápido
	end

	playerCooldowns[player] = currentTime

	-- Verificar que el jugador existe
	if not player or not player.Parent then
		return false
	end

	-- Verificar que el personaje existe y está vivo
	local character = player.Character
	if not character or not character:FindFirstChild("Humanoid") then
		return false
	end

	local humanoid = character.Humanoid
	if humanoid.Health <= 0 then
		return false
	end

	-- Obtener datos del jugador para aplicar multiplicador
	local playerData = DataManager.GetData(player)
	if not playerData then
		return false
	end

	-- Obtener multiplicador de EXP (por rebirths)
	local expMultiplier = playerData.EXPMultiplier or 1
	local baseEXP = EXP_PER_STEP
	local finalEXP = math.floor(baseEXP * expMultiplier)

	-- Otorgar EXP MULTIPLICADO
	local success = DataManager.AddEXP(player, finalEXP)

	if success then
		-- Enviar notificación al cliente con el EXP base, multiplicador y total
		ShowStepNotificationEvent:FireClient(player, baseEXP, expMultiplier, finalEXP)
		return true
	end

	return false
end

-- ==================== ESCUCHAR EVENTO ====================

AddStepEXPEvent.OnServerEvent:Connect(function(player)
	giveStepEXP(player)
end)

-- Limpiar cooldowns cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player] = nil
end)

print("[StepManager] ✅ Sistema de pasos del servidor inicializado")
print(string.format("[StepManager] 🎯 %d EXP por paso", EXP_PER_STEP))
