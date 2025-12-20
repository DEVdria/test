-- StarterPlayer > StarterPlayerScripts > StarClientManager
-- Gestiona la visualización y animación de estrellas (cliente)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local StarConfig = require(Modules:WaitForChild("StarConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StarCollectedEvent = RemoteEvents:WaitForChild("StarCollected", 10)

if not StarCollectedEvent then
	warn("[StarClientManager] ❌ No se encontró RemoteEvent 'StarCollected'")
	warn("[StarClientManager] 📘 Crea este RemoteEvent en ReplicatedStorage/RemoteEvents")
	return
end

-- Variables de estado
local starsFolder = nil
local animatedStars = {}  -- {[starModel] = {originalCFrame, time, ...}}
local collectedStars = {}  -- {[starID] = lastCollectionTime}

-- Buscar carpeta de estrellas
local function findStarsFolder()
	local folder = Workspace:FindFirstChild("Stars")
	if not folder then
		warn("[StarClientManager] ❌ No se encontró carpeta 'Stars' en Workspace")
		warn("[StarClientManager] 📘 Crea una carpeta llamada 'Stars' en Workspace con modelos star1, star2, etc.")
		return nil
	end
	return folder
end

-- Verifica si puede recolectar una estrella (cooldown local)
local function canCollectStar(starID)
	local lastCollection = collectedStars[starID]
	if not lastCollection then
		return true
	end

	local elapsed = tick() - lastCollection
	return elapsed >= StarConfig.General.CollectionCooldown
end

-- Aplica animación a una estrella
local function setupStarAnimation(starModel)
	-- Buscar la parte principal (puede ser un MeshPart, Part, etc.)
	local mainPart = starModel:IsA("BasePart") and starModel or starModel:FindFirstChildWhichIsA("BasePart", true)

	if not mainPart then
		warn(string.format("[StarClientManager] ⚠️ %s no tiene BasePart para animar", starModel.Name))
		return
	end

	-- Configurar propiedades visuales
	if StarConfig.IsValidStar(starModel.Name) then
		local config = StarConfig.GetStar(starModel.Name)

		-- Aplicar color si es un Part o MeshPart
		if mainPart:IsA("Part") or mainPart:IsA("MeshPart") then
			mainPart.Color = config.Color
			mainPart.Material = Enum.Material.Neon
		end
	end

	-- Guardar información para animación
	animatedStars[starModel] = {
		part = mainPart,
		originalCFrame = mainPart.CFrame,
		time = 0
	}

	print(string.format("[StarClientManager] ✅ Estrella %s configurada para animación", starModel.Name))
end

-- Detecta colisión con estrellas
local function checkStarCollection()
	if not humanoidRootPart or not humanoidRootPart.Parent then
		-- Recargar character si es necesario
		character = player.Character
		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end
		return
	end

	local playerPosition = humanoidRootPart.Position

	for starModel, data in pairs(animatedStars) do
		if starModel and starModel.Parent then
			local starPosition = data.part.Position
			local distance = (playerPosition - starPosition).Magnitude

			if distance <= StarConfig.General.CollectionDistance then
				local starID = starModel.Name

				-- Verificar si puede recolectar (cooldown)
				if StarConfig.IsValidStar(starID) and canCollectStar(starID) then
					-- Enviar al servidor
					StarCollectedEvent:FireServer(starID)

					-- Actualizar cooldown local
					collectedStars[starID] = tick()

					-- Efecto de fuego en el personaje (solo visible para el jugador)
					task.spawn(function()
						if character and character:FindFirstChild("HumanoidRootPart") then
							local fires = {}

							-- Crear efectos de fuego en las partes principales del personaje
							for _, part in ipairs(character:GetChildren()) do
								if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
									local fire = Instance.new("Fire")
									fire.Size = 5
									fire.Heat = 10
									fire.Color = Color3.fromRGB(255, 170, 0)  -- Naranja/Dorado
									fire.SecondaryColor = Color3.fromRGB(255, 85, 0)  -- Naranja oscuro
									fire.Parent = part
									table.insert(fires, fire)
								end
							end

							-- También agregar fuego al HumanoidRootPart
							local rootFire = Instance.new("Fire")
							rootFire.Size = 8
							rootFire.Heat = 15
							rootFire.Color = Color3.fromRGB(255, 170, 0)
							rootFire.SecondaryColor = Color3.fromRGB(255, 85, 0)
							rootFire.Parent = character.HumanoidRootPart
							table.insert(fires, rootFire)

							-- Eliminar todos los efectos después de 4 segundos
							task.wait(4)
							for _, fire in ipairs(fires) do
								if fire and fire.Parent then
									fire:Destroy()
								end
							end
						end
					end)

					-- Efecto visual de recolección (opcional)
					task.spawn(function()
						local originalSize = data.part.Size
						local shrinkTween = TweenService:Create(
							data.part,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1}
						)
						shrinkTween:Play()
						shrinkTween.Completed:Wait()

						-- Restaurar tamaño después del cooldown
						task.wait(StarConfig.General.CollectionCooldown - 0.2)
						data.part.Size = originalSize
						data.part.Transparency = 0
					end)
				end
			end
		end
	end
end

-- Anima las estrellas (rotación y flotación)
local function animateStars(deltaTime)
	for starModel, data in pairs(animatedStars) do
		if starModel and starModel.Parent and data.part and data.part.Parent then
			-- Actualizar tiempo
			data.time = data.time + deltaTime

			-- Rotación
			local rotationAngle = (data.time * StarConfig.General.RotationSpeed) % 360
			local rotation = CFrame.Angles(0, math.rad(rotationAngle), 0)

			-- Flotación (movimiento vertical sinusoidal)
			local bobOffset = math.sin(data.time * StarConfig.General.BobSpeed) * StarConfig.General.BobHeight
			local bobCFrame = CFrame.new(0, bobOffset, 0)

			-- Aplicar transformación
			data.part.CFrame = data.originalCFrame * bobCFrame * rotation
		end
	end
end

-- Cuenta cuántas stars hay en animatedStars
local function countStars()
	local count = 0
	for _ in pairs(animatedStars) do
		count = count + 1
	end
	return count
end

-- Inicializar estrellas
local function initializeStars()
	starsFolder = findStarsFolder()
	if not starsFolder then return end

	-- Buscar todos los modelos de estrellas
	for _, child in ipairs(starsFolder:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			-- Solo agregar si aún no está en la lista
			if not animatedStars[child] then
				setupStarAnimation(child)
			end
		end
	end

	print(string.format("[StarClientManager] ✅ %d estrellas inicializadas", countStars()))
end

-- Escuchar cuando se agreguen nuevas stars (para modo servidor/cliente)
local function listenForNewStars()
	if not starsFolder then return end

	starsFolder.ChildAdded:Connect(function(child)
		-- Esperar a que el objeto esté completamente replicado
		task.wait(0.5)

		if (child:IsA("Model") or child:IsA("BasePart")) and not animatedStars[child] then
			setupStarAnimation(child)
			print(string.format("[StarClientManager] ➕ Nueva estrella detectada: %s (Total: %d)", child.Name, countStars()))
		end
	end)

	-- También revisar si hay descendants que se agreguen después
	starsFolder.DescendantAdded:Connect(function(descendant)
		-- Si un BasePart se agrega a un Model que ya teníamos pero no pudimos inicializar
		if descendant:IsA("BasePart") then
			local starModel = descendant.Parent
			if starModel and (starModel:IsA("Model") or starModel:IsA("BasePart")) then
				-- Si el modelo existe pero no está animado, intentar configurarlo
				if starModel.Parent == starsFolder and not animatedStars[starModel] then
					task.wait(0.1)  -- Pequeña espera para asegurar replicación completa
					setupStarAnimation(starModel)
					print(string.format("[StarClientManager] 🔄 Estrella %s configurada después de replicación (Total: %d)", starModel.Name, countStars()))
				end
			end
		end
	end)
end

-- ==================== BUCLE DE ANIMACIÓN Y DETECCIÓN ====================

-- Animación
RunService.RenderStepped:Connect(function(deltaTime)
	animateStars(deltaTime)
end)

-- Detección de colisión (cada 0.1 segundos para optimizar)
task.spawn(function()
	while true do
		task.wait(0.1)
		checkStarCollection()
	end
end)

-- ==================== RECARGAR CUANDO EL PERSONAJE MUERE ====================

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- ==================== INICIALIZAR ====================

-- Esperar a que la carpeta Stars exista (importante para modo servidor/cliente)
task.spawn(function()
	print("[StarClientManager] ⏳ Esperando carpeta Stars...")

	-- Intentar encontrar la carpeta con reintentos
	local attempts = 0
	local maxAttempts = 20  -- 20 segundos máximo
	while not starsFolder and attempts < maxAttempts do
		starsFolder = Workspace:FindFirstChild("Stars")
		if not starsFolder then
			attempts = attempts + 1
			task.wait(1)
		end
	end

	if not starsFolder then
		warn("[StarClientManager] ❌ No se encontró carpeta Stars después de 20 segundos")
		return
	end

	print("[StarClientManager] ✅ Carpeta Stars encontrada")

	-- Esperar un poco más para que las stars se repliquen
	task.wait(2)

	-- Inicializar stars existentes
	initializeStars()

	-- Escuchar por nuevas stars (importante para replicación tardía en servidor/cliente)
	listenForNewStars()

	-- Revisar periódicamente si hay stars que no se inicializaron (fallback)
	task.spawn(function()
		task.wait(5)  -- Esperar 5 segundos adicionales
		if starsFolder then
			local uninitializedCount = 0
			for _, child in ipairs(starsFolder:GetChildren()) do
				if (child:IsA("Model") or child:IsA("BasePart")) and not animatedStars[child] then
					setupStarAnimation(child)
					uninitializedCount = uninitializedCount + 1
				end
			end

			if uninitializedCount > 0 then
				print(string.format("[StarClientManager] 🔄 Se inicializaron %d estrellas adicionales (replicación tardía)", uninitializedCount))
				print(string.format("[StarClientManager] ✅ Total de estrellas: %d", countStars()))
			end
		end
	end)

	print("[StarClientManager] ✅ Sistema de estrellas del cliente inicializado")
end)
