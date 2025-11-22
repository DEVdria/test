--[[
	═══════════════════════════════════════════════════════════
	MOVING OBSTACLES SYSTEM - SERVER
	Sistema de obstáculos móviles que matan al jugador
	═══════════════════════════════════════════════════════════

	UBICACIÓN: ServerScriptService → Script (normal, NO LocalScript)

	CARACTERÍSTICAS:
	- Obstáculos se generan al final de la fila de paneles
	- Se mueven hacia el principio
	- Matan al jugador al tocarlos
	- Se destruyen al llegar al principio
	- Spawn continuo automático
]]

local TweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════

local CONFIG = {
	-- Referencias
	FOLDER_NAME = "TimedGlassRow",      -- Folder de paneles
	PANEL_PREFIX = "TimedPanel",        -- Prefijo de los paneles
	OBSTACLES_FOLDER = "MovingObstacles", -- Folder para obstáculos

	-- Spawn
	SPAWN_INTERVAL = 3,                 -- Segundos entre cada obstáculo
	MAX_OBSTACLES = 10,                 -- Máximo de obstáculos simultáneos

	-- Movimiento general
	MOVEMENT_DURATION = 15,             -- Segundos para recorrer toda la fila
	EASING_STYLE = Enum.EasingStyle.Linear,
	EASING_DIRECTION = Enum.EasingDirection.InOut,
	HEIGHT_ABOVE_PANELS = 2,            -- Studs arriba de los paneles

	-- TIPOS DE OBSTÁCULOS
	OBSTACLE_TYPES = {
		-- Tipo 1: Esfera que gira de izquierda a derecha
		SPINNING_BALL = {
			name = "Esfera Giratoria",
			shape = "Ball",
			size = Vector3.new(4, 4, 4),
			color = Color3.fromRGB(255, 0, 0),     -- Rojo
			material = Enum.Material.Neon,
			heightOffset = 2,                      -- Altura sobre paneles
			lateralMovement = true,                -- Se mueve de lado a lado
			lateralDistance = 8,                   -- Distancia lateral (studs)
			lateralSpeed = 2,                      -- Segundos para ir de un lado al otro
		},

		-- Tipo 2: Block bajo que se puede saltar
		LOW_BLOCK = {
			name = "Muro Bajo",
			shape = "Block",
			size = Vector3.new(6, 3, 1),           -- Ancho, Alto, Profundo
			color = Color3.fromRGB(255, 100, 0),   -- Naranja
			material = Enum.Material.Neon,
			heightOffset = 1.5,                    -- Más cerca del suelo
			lateralMovement = false,
		},

		-- Tipo 3: Block alto que NO se puede saltar
		HIGH_BLOCK = {
			name = "Muro Alto",
			shape = "Block",
			size = Vector3.new(6, 8, 1),           -- Muy alto
			color = Color3.fromRGB(150, 0, 255),   -- Morado
			material = Enum.Material.Neon,
			heightOffset = 4,                      -- Más alto
			lateralMovement = false,
		},
	},
}

-- ═══════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════

local obstaclesFolder
local panelsFolder
local activeObstacles = {}

-- ═══════════════════════════════════════════════════════════
-- FUNCIONES AUXILIARES
-- ═══════════════════════════════════════════════════════════

-- Obtener posición del primer y último panel
local function getPanelPositions()
	if not panelsFolder then
		return nil, nil
	end

	local panels = {}
	for _, child in ipairs(panelsFolder:GetChildren()) do
		if child:IsA("BasePart") and string.match(child.Name, CONFIG.PANEL_PREFIX .. "%d+") then
			local number = tonumber(string.match(child.Name, "%d+"))
			table.insert(panels, {part = child, number = number})
		end
	end

	if #panels == 0 then
		return nil, nil
	end

	-- Ordenar por número
	table.sort(panels, function(a, b)
		return a.number < b.number
	end)

	local firstPanel = panels[1].part
	local lastPanel = panels[#panels].part

	return firstPanel.Position, lastPanel.Position
end

-- Seleccionar tipo de obstáculo aleatorio
local function getRandomObstacleType()
	local types = {}
	for _, obstacleType in pairs(CONFIG.OBSTACLE_TYPES) do
		table.insert(types, obstacleType)
	end

	local randomIndex = math.random(1, #types)
	return types[randomIndex]
end

-- Crear obstáculo según el tipo
local function createObstacle(obstacleType)
	local obstacle = Instance.new("Part")

	-- Configurar forma
	if obstacleType.shape == "Ball" then
		obstacle.Shape = Enum.PartType.Ball
	else
		obstacle.Shape = Enum.PartType.Block
	end

	-- Configurar propiedades
	obstacle.Size = obstacleType.size
	obstacle.Material = obstacleType.material
	obstacle.Color = obstacleType.color
	obstacle.CanCollide = false  -- No bloquea físicamente
	obstacle.Anchored = true
	obstacle.Name = "MovingObstacle_" .. obstacleType.name

	return obstacle
end

-- Matar jugador al tocar el obstáculo
local function setupTouchKill(obstacle)
	obstacle.Touched:Connect(function(hit)
		-- Verificar si es un jugador
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			print(string.format("💀 %s tocó un obstáculo y murió", hit.Parent.Name))
			humanoid.Health = 0
		end
	end)
end

-- Limpiar obstáculo
local function cleanupObstacle(obstacle)
	-- Remover de la lista activa
	for i, obs in ipairs(activeObstacles) do
		if obs == obstacle then
			table.remove(activeObstacles, i)
			break
		end
	end

	-- Destruir
	if obstacle and obstacle.Parent then
		obstacle:Destroy()
	end
end

-- ═══════════════════════════════════════════════════════════
-- LÓGICA PRINCIPAL
-- ═══════════════════════════════════════════════════════════

-- Spawnear y mover un obstáculo
local function spawnObstacle()
	-- Verificar límite de obstáculos
	if #activeObstacles >= CONFIG.MAX_OBSTACLES then
		return
	end

	-- Obtener posiciones de inicio y fin
	local firstPos, lastPos = getPanelPositions()

	if not firstPos or not lastPos then
		warn("⚠️ No se encontraron paneles para generar obstáculos")
		return
	end

	-- Seleccionar tipo aleatorio
	local obstacleType = getRandomObstacleType()

	-- Crear obstáculo
	local obstacle = createObstacle(obstacleType)

	-- Posición inicial (al final, arriba de los paneles)
	local startPos = lastPos + Vector3.new(0, obstacleType.heightOffset, 0)
	obstacle.Position = startPos

	-- Parent y configurar
	obstacle.Parent = obstaclesFolder
	setupTouchKill(obstacle)

	-- Agregar a lista activa
	table.insert(activeObstacles, obstacle)

	print(string.format("🔴 %s spawneado | Total activos: %d", obstacleType.name, #activeObstacles))

	-- Posición final (al principio)
	local endPos = firstPos + Vector3.new(0, obstacleType.heightOffset, 0)

	-- Crear tween de movimiento principal (hacia adelante)
	local tweenInfo = TweenInfo.new(
		CONFIG.MOVEMENT_DURATION,
		CONFIG.EASING_STYLE,
		CONFIG.EASING_DIRECTION
	)

	local tween = TweenService:Create(obstacle, tweenInfo, {
		Position = endPos
	})

	-- Si tiene movimiento lateral (esfera giratoria)
	if obstacleType.lateralMovement then
		-- Crear movimiento de lado a lado
		task.spawn(function()
			local direction = 1  -- 1 = derecha, -1 = izquierda
			local lateralOffset = 0

			while obstacle and obstacle.Parent do
				-- Alternar dirección
				direction = direction * -1
				lateralOffset = direction * obstacleType.lateralDistance

				-- Calcular nueva posición (mantener Y, cambiar X)
				local currentPos = obstacle.Position
				local targetX = currentPos.X + lateralOffset

				-- Crear tween lateral
				local lateralTweenInfo = TweenInfo.new(
					obstacleType.lateralSpeed,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				)

				local lateralTween = TweenService:Create(obstacle, lateralTweenInfo, {
					Position = Vector3.new(targetX, currentPos.Y, currentPos.Z)
				})

				lateralTween:Play()
				lateralTween.Completed:Wait()
			end
		end)
	end

	-- Cuando termine el tween principal, destruir el obstáculo
	tween.Completed:Connect(function()
		print(string.format("🔴 %s llegó al final y será destruido", obstacleType.name))
		cleanupObstacle(obstacle)
	end)

	-- Iniciar movimiento principal
	tween:Play()
end

-- Loop de spawn continuo
local function startSpawning()
	task.spawn(function()
		while true do
			spawnObstacle()
			task.wait(CONFIG.SPAWN_INTERVAL)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════

local function initialize()
	print("═══════════════════════════════════════════════════════")
	print("MOVING OBSTACLES SYSTEM - INICIANDO")
	print("═══════════════════════════════════════════════════════")

	-- Buscar folder de paneles
	panelsFolder = workspace:WaitForChild(CONFIG.FOLDER_NAME, 10)

	if not panelsFolder then
		warn("❌ ERROR: No se encontró el folder de paneles:", CONFIG.FOLDER_NAME)
		warn("Asegúrate de que los paneles estén creados primero")
		return
	end

	print("✅ Folder de paneles encontrado:", panelsFolder.Name)

	-- Crear folder para obstáculos
	obstaclesFolder = workspace:FindFirstChild(CONFIG.OBSTACLES_FOLDER)
	if obstaclesFolder then
		obstaclesFolder:Destroy()
	end

	obstaclesFolder = Instance.new("Folder")
	obstaclesFolder.Name = CONFIG.OBSTACLES_FOLDER
	obstaclesFolder.Parent = workspace

	print("✅ Folder de obstáculos creado:", obstaclesFolder.Name)

	-- Verificar que hay paneles
	local firstPos, lastPos = getPanelPositions()
	if not firstPos or not lastPos then
		warn("❌ ERROR: No se encontraron paneles válidos")
		return
	end

	print("✅ Posiciones calculadas:")
	print("   Inicio:", firstPos)
	print("   Final:", lastPos)
	print("───────────────────────────────────────────────────────")
	print("⚙️ CONFIGURACIÓN:")
	print("   Intervalo de spawn:", CONFIG.SPAWN_INTERVAL, "segundos")
	print("   Duración de movimiento:", CONFIG.MOVEMENT_DURATION, "segundos")
	print("   Máximo simultáneo:", CONFIG.MAX_OBSTACLES)
	print("───────────────────────────────────────────────────────")
	print("🎯 TIPOS DE OBSTÁCULOS:")
	for typeName, obstacleType in pairs(CONFIG.OBSTACLE_TYPES) do
		if obstacleType.lateralMovement then
			print(string.format("   🔴 %s - Se mueve lateralmente", obstacleType.name))
		else
			print(string.format("   🔴 %s - Tamaño: %s", obstacleType.name, tostring(obstacleType.size)))
		end
	end
	print("───────────────────────────────────────────────────────")
	print("✅ SISTEMA INICIADO - Spawneando obstáculos...")
	print("═══════════════════════════════════════════════════════")

	-- Iniciar spawning
	startSpawning()
end

-- ═══════════════════════════════════════════════════════════
-- EJECUTAR
-- ═══════════════════════════════════════════════════════════

local success, err = pcall(initialize)

if not success then
	warn("❌ ERROR AL INICIAR SISTEMA DE OBSTÁCULOS:", err)
end
