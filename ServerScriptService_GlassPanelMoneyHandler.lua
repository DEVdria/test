--[[
	═══════════════════════════════════════════════════════════
	GLASS PANEL MONEY HANDLER - SERVER
	Maneja las recompensas de dinero cuando se pisan paneles
	═══════════════════════════════════════════════════════════
	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que DataManager esté disponible
if not _G.DataManager then
	warn("[GlassPanelMoneyHandler] ⚠️ Esperando a que DataManager se cargue...")

	local maxWait = 10
	local waited = 0
	while not _G.DataManager and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5
	end

	if not _G.DataManager then
		error("[GlassPanelMoneyHandler] ❌ DataManager no está disponible después de esperar")
		return
	end
end

local DataManager = _G.DataManager

-- Obtener RemoteEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	error("[GlassPanelMoneyHandler] ❌ No se encontró carpeta RemoteEvents")
	return
end

local givePanelMoneyEvent = remoteEventsFolder:WaitForChild("GivePanelMoney", 10)
if not givePanelMoneyEvent then
	error("[GlassPanelMoneyHandler] ❌ No se encontró RemoteEvent 'GivePanelMoney'")
	return
end

-- ═══════════════════════════════════════════════════════════
-- ANTI-EXPLOIT: Cooldown por panel
-- ═══════════════════════════════════════════════════════════

local playerPanelCooldowns = {} -- {[player.UserId] = {[panelName] = lastTime}}
local PANEL_COOLDOWN = 0.5 -- Medio segundo de cooldown por panel

local function canGiveMoney(player, panelName)
	local userId = player.UserId

	if not playerPanelCooldowns[userId] then
		playerPanelCooldowns[userId] = {}
	end

	local lastTime = playerPanelCooldowns[userId][panelName] or 0
	local currentTime = tick()

	if currentTime - lastTime < PANEL_COOLDOWN then
		return false
	end

	playerPanelCooldowns[userId][panelName] = currentTime
	return true
end

-- ═══════════════════════════════════════════════════════════
-- MANEJADOR DEL EVENTO
-- ═══════════════════════════════════════════════════════════

givePanelMoneyEvent.OnServerEvent:Connect(function(player, panel)
	-- Validar que el jugador existe
	if not player or not player:IsA("Player") then
		warn("[GlassPanelMoneyHandler] ⚠️ Jugador inválido")
		return
	end

	-- Validar que el panel existe y es un BasePart
	if not panel or not panel:IsA("BasePart") then
		warn("[GlassPanelMoneyHandler] ⚠️ Panel inválido recibido de", player.Name)
		return
	end

	-- Validar que el panel todavía existe en el workspace
	if not panel.Parent or not panel.Parent.Parent == workspace then
		warn("[GlassPanelMoneyHandler] ⚠️ Panel no está en workspace")
		return
	end

	-- Verificar cooldown (anti-exploit)
	if not canGiveMoney(player, panel:GetFullName()) then
		-- No mostrar warning, es normal que suceda en edge cases
		return
	end

	-- Leer el dinero del atributo del panel
	local baseMoney = panel:GetAttribute("MoneyReward")
	if not baseMoney or type(baseMoney) ~= "number" or baseMoney <= 0 then
		warn("[GlassPanelMoneyHandler] ⚠️ MoneyReward inválido en panel:", panel:GetFullName())
		return
	end

	-- Validar que no sea una cantidad ridícula (anti-exploit)
	if baseMoney > 1000 then
		warn("[GlassPanelMoneyHandler] 🚨 ANTI-EXPLOIT: Dinero sospechoso:", baseMoney, "de", player.Name)
		return
	end

	-- Aplicar multiplicador global de dinero (si existe)
	local globalMoneyMultiplier = 1
	if _G.GetServerMoneyMultiplier then
		globalMoneyMultiplier = _G.GetServerMoneyMultiplier()
	end

	-- Calcular dinero final con multiplicador
	local finalMoney = math.floor(baseMoney * globalMoneyMultiplier)

	-- Obtener el nombre del nivel
	local levelName = panel:GetAttribute("LevelName") or "Unknown"

	-- Dar dinero usando DataManager
	local success = pcall(function()
		DataManager.AddMoney(player, finalMoney)
	end)

	if success then
		if globalMoneyMultiplier > 1 then
			print(string.format("[GlassPanelMoneyHandler] 💰 %s recibió %d de dinero (base: %d, x%.1f global) (%s - %s)",
				player.Name, finalMoney, baseMoney, globalMoneyMultiplier, levelName, panel.Name))
		else
			print(string.format("[GlassPanelMoneyHandler] 💰 %s recibió %d de dinero (%s - %s)",
				player.Name, finalMoney, levelName, panel.Name))
		end
	else
		warn(string.format("[GlassPanelMoneyHandler] ❌ Error al dar dinero a %s", player.Name))
	end
end)

-- Limpiar cooldowns cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	playerPanelCooldowns[player.UserId] = nil
end)

print("[GlassPanelMoneyHandler] ✅ Sistema de dinero de paneles inicializado")
