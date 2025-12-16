--[[
	═══════════════════════════════════════════════════════════
	MULTI-LEVEL GLASS PANEL SERVER - MANEJADOR DE FÍSICA
	Script de servidor permanente para manejar la caída de paneles
	═══════════════════════════════════════════════════════════

	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)

	IMPORTANTE: Este script debe ejecutarse PERMANENTEMENTE.
	NO lo elimines después de crear los niveles.

	PROPÓSITO:
	- Recibir eventos del cliente cuando un jugador toca un panel
	- Ejecutar toda la lógica física de caída en el servidor
	- Garantizar que todos los clientes vean la misma física
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	RESPAWN_TIME = 3, -- Tiempo que el panel permanece caído antes de respawnear
	FALL_DISTANCE = 50, -- Distancia de caída
	FALL_DURATION = 1.5, -- Duración de la animación de caída
	RESPAWN_DURATION = 0.8, -- Duración de la animación de respawn
}

-- ═══════════════════════════════════════════════════════════
-- CREAR REMOTE EVENT
-- ═══════════════════════════════════════════════════════════

local panelActivatedEvent = ReplicatedStorage:FindFirstChild("PanelActivatedEvent")
if not panelActivatedEvent then
	panelActivatedEvent = Instance.new("RemoteEvent")
	panelActivatedEvent.Name = "PanelActivatedEvent"
	panelActivatedEvent.Parent = ReplicatedStorage
	print("✅ RemoteEvent 'PanelActivatedEvent' creado en ReplicatedStorage")
end

-- ═══════════════════════════════════════════════════════════
-- TABLA DE PANELES ACTIVOS
-- ═══════════════════════════════════════════════════════════

-- Estructura: panelStates[panel] = { isActive, originalCFrame, coroutine }
local panelStates = {}

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES DE ANIMACIÓN
-- ═══════════════════════════════════════════════════════════

local function createFallTween(panel, originalCFrame)
	local fallCFrame = originalCFrame * CFrame.new(0, -CONFIG.FALL_DISTANCE, 0)

	local tweenInfo = TweenInfo.new(
		CONFIG.FALL_DURATION,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)

	return TweenService:Create(panel, tweenInfo, {CFrame = fallCFrame})
end

local function createRespawnTween(panel, originalCFrame)
	local tweenInfo = TweenInfo.new(
		CONFIG.RESPAWN_DURATION,
		Enum.EasingStyle.Bounce,
		Enum.EasingDirection.Out
	)

	return TweenService:Create(panel, tweenInfo, {CFrame = originalCFrame})
end

-- ═══════════════════════════════════════════════════════════
-- LÓGICA DE CAÍDA DEL PANEL
-- ═══════════════════════════════════════════════════════════

local function activatePanel(player, panel, fallTime)
	-- Validaciones
	if not panel or not panel.Parent then
		warn("❌ Panel no válido o fue destruido")
		return
	end

	-- Verificar si ya está activo
	local state = panelStates[panel]
	if state and state.isActive then
		return -- Ya está cayendo
	end

	-- Obtener información del panel
	local levelFolder = panel.Parent
	local levelName = levelFolder and levelFolder.Name or "Unknown"
	local panelNumber = tonumber(panel.Name:match("%d+")) or 0

	-- Guardar CFrame original si no existe
	local originalCFrame = (state and state.originalCFrame) or panel.CFrame

	-- Marcar como activo
	panelStates[panel] = {
		isActive = true,
		originalCFrame = originalCFrame,
		coroutine = nil
	}

	print(string.format(
		"🎯 [SERVIDOR] %s - PANEL %d ACTIVADO por %s | Caerá en %.1f segundos",
		levelName,
		panelNumber,
		player.Name,
		fallTime
	))

	-- Ejecutar secuencia de caída en coroutine
	local fallCoroutine = task.spawn(function()
		local success, err = pcall(function()
			-- Esperar el tiempo antes de caer
			task.wait(fallTime)

			-- Verificar que el panel aún existe
			if not panel or not panel.Parent then
				panelStates[panel] = nil
				return
			end

			print(string.format("💥 [SERVIDOR] %s - PANEL %d CAYENDO", levelName, panelNumber))

			-- Deshabilitar colisión
			panel.CanCollide = false

			-- Hacer el panel completamente invisible
			local originalTransparency = panel.Transparency
			panel.Transparency = 1

			-- Ocultar todos los decals
			local decals = {}
			for _, child in ipairs(panel:GetChildren()) do
				if child:IsA("Decal") then
					table.insert(decals, {decal = child, wasVisible = child.Transparency})
					child.Transparency = 1
				end
			end

			-- Ocultar timer display
			local timerDisplay = panel:FindFirstChild("TimerDisplay")
			if timerDisplay then
				timerDisplay.Enabled = false
			end

			-- Animar caída
			local fallTween = createFallTween(panel, originalCFrame)
			fallTween:Play()
			fallTween.Completed:Wait()

			print(string.format("⌛ [SERVIDOR] %s - PANEL %d respawnea en %d segundos", levelName, panelNumber, CONFIG.RESPAWN_TIME))

			-- Esperar tiempo de respawn
			task.wait(CONFIG.RESPAWN_TIME)

			-- Verificar que el panel aún existe
			if not panel or not panel.Parent then
				panelStates[panel] = nil
				return
			end

			-- Reactivar colisión
			panel.CanCollide = true

			-- Restaurar transparencia original
			panel.Transparency = originalTransparency

			-- Restaurar decals
			for _, decalData in ipairs(decals) do
				decalData.decal.Transparency = decalData.wasVisible
			end

			-- Restaurar timer display
			if timerDisplay then
				timerDisplay.Enabled = true
			end

			-- Animar respawn
			local respawnTween = createRespawnTween(panel, originalCFrame)
			respawnTween:Play()
			respawnTween.Completed:Wait()

			print(string.format("✅ [SERVIDOR] %s - PANEL %d RESPAWNEADO", levelName, panelNumber))

			-- Resetear estado
			panelStates[panel] = {
				isActive = false,
				originalCFrame = originalCFrame,
				coroutine = nil
			}
		end)

		if not success then
			warn(string.format("❌ [SERVIDOR] Error en %s PANEL %d: %s", levelName, panelNumber, tostring(err)))
			if panel and panelStates[panel] then
				panelStates[panel].isActive = false
			end
		end
	end)

	-- Guardar referencia al coroutine
	panelStates[panel].coroutine = fallCoroutine
end

-- ═══════════════════════════════════════════════════════════
-- ESCUCHAR EVENTOS DEL CLIENTE
-- ═══════════════════════════════════════════════════════════

panelActivatedEvent.OnServerEvent:Connect(function(player, panelPath, fallTime)
	-- Validar parámetros
	if type(panelPath) ~= "string" then
		warn("❌ [SERVIDOR] PanelPath inválido recibido de", player.Name)
		return
	end

	if type(fallTime) ~= "number" or fallTime <= 0 then
		warn("❌ [SERVIDOR] FallTime inválido recibido de", player.Name, "para panel", panelPath)
		return
	end

	-- Buscar el panel en el workspace
	local panel = workspace:FindFirstChild(panelPath:match("^[^%.]+"), true)

	-- Buscar más específicamente si no se encontró
	if not panel then
		local pathParts = {}
		for part in panelPath:gmatch("[^%.]+") do
			table.insert(pathParts, part)
		end

		local current = workspace
		for _, partName in ipairs(pathParts) do
			current = current:FindFirstChild(partName)
			if not current then
				warn("❌ [SERVIDOR] No se encontró el panel:", panelPath, "de", player.Name)
				return
			end
		end
		panel = current
	end

	-- Activar el panel
	if panel and panel:IsA("BasePart") then
		activatePanel(player, panel, fallTime)
	else
		warn("❌ [SERVIDOR] Objeto no es un BasePart:", panelPath)
	end
end)

print("═══════════════════════════════════════════════════════")
print("✅ MULTI-LEVEL GLASS PANEL SERVER - INICIADO")
print("📡 Escuchando eventos de paneles activados...")
print("═══════════════════════════════════════════════════════")
