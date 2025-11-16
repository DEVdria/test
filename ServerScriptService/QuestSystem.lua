--[[
═══════════════════════════════════════════════════════════════
    QUEST SYSTEM - Sistema de Misiones
    Ubicación: ServerScriptService

    Funcionalidad:
    - Misiones diarias con diferentes objetivos
    - Seguimiento de progreso automático
    - Recompensas en dinero
    - Múltiples tipos de misiones
    - Sistema de reset diario
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIGURACIÓN DE MISIONES DISPONIBLES
local QUEST_TEMPLATES = {
	{
		Id = "walk_distance",
		Name = "Caminante Incansable",
		Description = "Camina {goal} studs",
		Type = "Distance",
		Goal = 1000,
		Reward = 100,
		Icon = "🚶"
	},
	{
		Id = "collect_chests",
		Name = "Cazador de Tesoros",
		Description = "Abre {goal} cofres",
		Type = "ChestCollect",
		Goal = 5,
		Reward = 150,
		Icon = "📦"
	},
	{
		Id = "spend_money",
		Name = "Gran Comprador",
		Description = "Gasta ${goal} en la tienda",
		Type = "MoneySpent",
		Goal = 200,
		Reward = 75,
		Icon = "💸"
	},
	{
		Id = "play_time",
		Name = "Jugador Dedicado",
		Description = "Juega durante {goal} minutos",
		Type = "PlayTime",
		Goal = 15,
		Reward = 200,
		Icon = "⏰"
	},
	{
		Id = "earn_money",
		Name = "Millonario en Camino",
		Description = "Gana ${goal} en total",
		Type = "MoneyEarned",
		Goal = 500,
		Reward = 250,
		Icon = "💰"
	}
}

-- Número de misiones activas por jugador
local ACTIVE_QUESTS_PER_PLAYER = 3

-- Almacenar misiones activas de jugadores
local playerQuests = {}

-- Crear RemoteEvents
local questUpdateEvent = ReplicatedStorage:FindFirstChild("QuestUpdate")
if not questUpdateEvent then
	questUpdateEvent = Instance.new("RemoteEvent")
	questUpdateEvent.Name = "QuestUpdate"
	questUpdateEvent.Parent = ReplicatedStorage
end

local questCompleteEvent = ReplicatedStorage:FindFirstChild("QuestComplete")
if not questCompleteEvent then
	questCompleteEvent = Instance.new("RemoteEvent")
	questCompleteEvent.Name = "QuestComplete"
	questCompleteEvent.Parent = ReplicatedStorage
end

local notificationEvent = ReplicatedStorage:FindFirstChild("SendNotification")
if not notificationEvent then
	notificationEvent = Instance.new("RemoteEvent")
	notificationEvent.Name = "SendNotification"
	notificationEvent.Parent = ReplicatedStorage
end

--[[
    Función: Seleccionar misiones aleatorias para un jugador
    Retorna: Array de misiones
--]]
local function selectRandomQuests()
	local selectedQuests = {}
	local availableQuests = {}

	-- Copiar todas las misiones disponibles
	for _, quest in ipairs(QUEST_TEMPLATES) do
		table.insert(availableQuests, quest)
	end

	-- Seleccionar aleatoriamente
	for i = 1, math.min(ACTIVE_QUESTS_PER_PLAYER, #availableQuests) do
		local randomIndex = math.random(1, #availableQuests)
		local selectedQuest = availableQuests[randomIndex]

		table.insert(selectedQuests, {
			Id = selectedQuest.Id,
			Name = selectedQuest.Name,
			Description = selectedQuest.Description:gsub("{goal}", tostring(selectedQuest.Goal)),
			Type = selectedQuest.Type,
			Goal = selectedQuest.Goal,
			Progress = 0,
			Reward = selectedQuest.Reward,
			Icon = selectedQuest.Icon,
			Completed = false
		})

		table.remove(availableQuests, randomIndex)
	end

	return selectedQuests
end

--[[
    Función: Inicializar misiones para un jugador
    Parámetros: player - El jugador
--]]
local function initializePlayerQuests(player)
	playerQuests[player.UserId] = selectRandomQuests()

	-- Enviar misiones al cliente
	questUpdateEvent:FireClient(player, playerQuests[player.UserId])

	print("📋 Misiones inicializadas para " .. player.Name)
end

--[[
    Función: Actualizar progreso de una misión
    Parámetros:
        player - El jugador
        questType - Tipo de misión
        amount - Cantidad de progreso a añadir
--]]
local function updateQuestProgress(player, questType, amount)
	if not playerQuests[player.UserId] then
		return
	end

	local quests = playerQuests[player.UserId]
	local anyUpdated = false

	for _, quest in ipairs(quests) do
		if quest.Type == questType and not quest.Completed then
			quest.Progress = math.min(quest.Progress + amount, quest.Goal)
			anyUpdated = true

			-- Verificar si la misión se completó
			if quest.Progress >= quest.Goal and not quest.Completed then
				quest.Completed = true

				-- Dar recompensa
				if _G.MoneyManager then
					_G.MoneyManager.AddMoney(player, quest.Reward)
				end

				-- Notificar al jugador
				questCompleteEvent:FireClient(player, quest)
				notificationEvent:FireClient(
					player,
					"🎉 ¡Misión Completada! " .. quest.Name .. " (+$" .. quest.Reward .. ")",
					Color3.fromRGB(85, 255, 127)
				)

				print("✅ " .. player.Name .. " completó misión: " .. quest.Name)
			end
		end
	end

	-- Enviar actualización al cliente
	if anyUpdated then
		questUpdateEvent:FireClient(player, quests)
	end
end

--[[
    Función: Rastrear distancia caminada
--]]
local function trackPlayerDistance()
	task.spawn(function()
		while true do
			task.wait(1)

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.MoveDirection.Magnitude > 0 then
						-- El jugador se está moviendo
						local speed = humanoid.WalkSpeed
						local distance = speed * 1 -- 1 segundo

						updateQuestProgress(player, "Distance", distance)
					end
				end
			end
		end
	end)
end

--[[
    Función: Rastrear tiempo jugado
--]]
local function trackPlayTime()
	task.spawn(function()
		while true do
			task.wait(60) -- Cada minuto

			for _, player in pairs(Players:GetPlayers()) do
				updateQuestProgress(player, "PlayTime", 1)
			end
		end
	end)
end

-- Cuando un jugador se une
Players.PlayerAdded:Connect(function(player)
	-- Esperar un poco para asegurar que MoneyManager esté cargado
	task.wait(1)
	initializePlayerQuests(player)
end)

-- Cuando un jugador sale
Players.PlayerRemoving:Connect(function(player)
	playerQuests[player.UserId] = nil
end)

-- Iniciar rastreadores
trackPlayerDistance()
trackPlayTime()

-- Exponer funciones globalmente para otros scripts
_G.QuestSystem = {
	UpdateProgress = updateQuestProgress,
	GetPlayerQuests = function(player)
		return playerQuests[player.UserId]
	end
}

print("═══════════════════════════════════════════════════════")
print("📋 Sistema de Misiones iniciado")
print("🎯 Misiones activas por jugador: " .. ACTIVE_QUESTS_PER_PLAYER)
print("🏆 Total de tipos de misiones: " .. #QUEST_TEMPLATES)
print("═══════════════════════════════════════════════════════")
