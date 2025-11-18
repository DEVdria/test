--[[
	TimerBarrierManager.lua
	Servidor del sistema de temporizador con barrera local

	Coloca este script en: ServerScriptService

	IMPORTANTE:
	- La Part "TimerBarrier" en Workspace debe tener CanCollide = false
	- Cada cliente crea su propia barrera LOCAL que solo él ve
	- El servidor solo rastrea quién completó el timer
	- Al completar, la barrera local se destruye para ese jugador
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================
-- CONFIGURACIÓN
-- ============================================
local TIMER_DURATION = 15 * 60 -- 15 minutos en segundos

-- ============================================
-- TABLA DE ESTADO
-- ============================================
-- Rastrear qué jugadores completaron el timer
local CompletedPlayers = {}

-- ============================================
-- CREAR REMOTEEVENT
-- ============================================
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "TimerBarrierEvent"
remoteEvent.Parent = ReplicatedStorage

local timerDuration = Instance.new("IntValue")
timerDuration.Name = "TimerDuration"
timerDuration.Value = TIMER_DURATION
timerDuration.Parent = ReplicatedStorage

print("=== Timer Barrier System Iniciado ===")
print("Duración del timer: " .. TIMER_DURATION .. " segundos (" .. (TIMER_DURATION/60) .. " minutos)")

-- ============================================
-- CUANDO JUGADOR ENTRA
-- ============================================
local function OnPlayerAdded(player)
	print("👤 " .. player.Name .. " conectado")
end

-- ============================================
-- CUANDO JUGADOR SALE
-- ============================================
local function OnPlayerRemoving(player)
	-- Limpiar estado cuando el jugador sale
	CompletedPlayers[player.UserId] = nil
	print("👋 " .. player.Name .. " salió - Estado limpiado")
end

-- ============================================
-- MANEJAR EVENTOS DEL CLIENTE
-- ============================================
remoteEvent.OnServerEvent:Connect(function(player, action)
	if action == "TimerCompleted" then
		-- El cliente notifica que completó el timer
		print("⏰ " .. player.Name .. " completó el timer")

		-- Marcar como completado
		CompletedPlayers[player.UserId] = true

		-- Confirmar al cliente
		remoteEvent:FireClient(player, "BarrierDisabled")

	elseif action == "GetStatus" then
		-- El cliente solicita su estado
		local hasCompleted = CompletedPlayers[player.UserId] or false

		-- Enviar respuesta
		remoteEvent:FireClient(player, "StatusResponse", {
			hasCompleted = hasCompleted,
			timerDuration = TIMER_DURATION
		})

		print("📡 Estado enviado a " .. player.Name .. ": " .. (hasCompleted and "Completado" or "Activo"))
	end
end)

-- ============================================
-- CONECTAR EVENTOS
-- ============================================
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Jugadores ya en el juego
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("=== Timer Barrier System Listo ===")
print("")
print("🎮 Comandos de Debug:")
print("   _G.CheckPlayer('nombre') - Ver estado de un jugador")
print("   _G.ForceComplete('nombre') - Forzar completar timer")
print("   _G.ResetPlayer('nombre') - Resetear timer de un jugador")
print("   _G.ResetAll() - Resetear todos los timers")
print("   _G.ListPlayers() - Ver estado de todos los jugadores")

-- ============================================
-- COMANDOS DE DEBUG
-- ============================================
_G.CheckPlayer = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	local completed = CompletedPlayers[player.UserId] or false

	print("━━━━━━━━━━━━━━━━━━━━━━")
	print("Jugador: " .. player.Name)
	print("UserId: " .. player.UserId)
	print("Estado: " .. (completed and "✅ Completado" or "⏰ Activo"))
	print("Barrera: " .. (completed and "Destruida" or "Presente"))
	print("━━━━━━━━━━━━━━━━━━━━━━")
end

_G.ForceComplete = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	CompletedPlayers[player.UserId] = true

	-- Notificar al cliente para que destruya su barrera
	remoteEvent:FireClient(player, "ForceDestroy")

	print("✅ Forzado: " .. player.Name .. " - Barrera destruida")
end

_G.ResetPlayer = function(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("⚠️ Jugador no encontrado: " .. playerName)
		return
	end

	CompletedPlayers[player.UserId] = nil

	-- Notificar al cliente para que recree su barrera
	remoteEvent:FireClient(player, "ForceReset")

	print("🔄 Reseteado: " .. player.Name .. " - Barrera recreada")
end

_G.ResetAll = function()
	print("🔄 Reseteando todos los timers...")
	CompletedPlayers = {}

	for _, player in pairs(Players:GetPlayers()) do
		remoteEvent:FireClient(player, "ForceReset")
		print("   🔄 " .. player.Name .. " - Timer reseteado")
	end

	print("✅ Todos los timers han sido reseteados")
end

_G.ListPlayers = function()
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("JUGADORES CONECTADOS:")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	for _, player in pairs(Players:GetPlayers()) do
		local completed = CompletedPlayers[player.UserId] or false
		print(player.Name .. " → " .. (completed and "✅ Completado" or "⏰ Activo"))
	end

	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end
