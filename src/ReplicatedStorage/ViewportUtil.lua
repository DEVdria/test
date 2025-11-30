--[[
	VIEWPORT UTIL - Utilidad para mostrar modelos 3D en ViewportFrames

	Funciones:
	- Crear ViewportFrame con modelo 3D
	- Rotación automática del modelo
	- Ajustar cámara para ver el modelo completo
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ViewportUtil = {}

-- Carpeta de modelos de mascotas
local PetsModelsFolder = ReplicatedStorage:WaitForChild("PetsModels")

-- ============================================
-- FUNCIÓN: OBTENER TAMAÑO DEL MODELO
-- ============================================
local function getModelSize(model)
	if not model.PrimaryPart then
		local firstPart = model:FindFirstChildWhichIsA("BasePart")
		if firstPart then
			model.PrimaryPart = firstPart
		end
	end

	local cframe, size = model:GetBoundingBox()
	return size
end

-- ============================================
-- FUNCIÓN: CREAR VIEWPORTFRAME CON MODELO
-- ============================================
--[[
	Parámetros:
	- viewportFrame: El ViewportFrame donde mostrar el modelo
	- petName: Nombre de la mascota (debe existir en ReplicatedStorage.PetsModels)
	- autoRotate: (opcional) Si debe rotar automáticamente (default: true)
	- rotationSpeed: (opcional) Velocidad de rotación (default: 1)

	Retorna:
	- Tabla con {Model, Camera, Connection} o nil si falla
--]]
function ViewportUtil.ShowPetInViewport(viewportFrame, petName, autoRotate, rotationSpeed)
	if autoRotate == nil then autoRotate = true end
	rotationSpeed = rotationSpeed or 1

	-- Validar ViewportFrame
	if not viewportFrame or not viewportFrame:IsA("ViewportFrame") then
		warn("[ViewportUtil] ViewportFrame inválido")
		return nil
	end

	-- Limpiar contenido anterior
	viewportFrame:ClearAllChildren()

	-- Buscar modelo
	local petModel = PetsModelsFolder:FindFirstChild(petName)
	if not petModel then
		warn("[ViewportUtil] Modelo no encontrado: " .. petName)
		return nil
	end

	-- Clonar modelo
	local clonedModel = petModel:Clone()

	-- Crear cámara
	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	-- Obtener tamaño del modelo
	local modelSize = getModelSize(clonedModel)

	-- Configurar cámara para ver todo el modelo
	local maxDimension = math.max(modelSize.X, modelSize.Y, modelSize.Z)
	local distance = maxDimension * 2.5

	-- Posicionar modelo en el centro del ViewportFrame
	local modelCFrame = CFrame.new(0, 0, 0)
	if clonedModel.PrimaryPart then
		clonedModel:SetPrimaryPartCFrame(modelCFrame)
	end

	-- Posicionar cámara
	camera.CFrame = CFrame.new(Vector3.new(distance * 0.5, distance * 0.3, distance), Vector3.new(0, 0, 0))
	camera.FieldOfView = 30

	-- Parent modelo al ViewportFrame
	clonedModel.Parent = viewportFrame

	-- ============================================
	-- AUTO-ROTACIÓN
	-- ============================================
	local rotationConnection = nil
	if autoRotate then
		local rotation = 0
		rotationConnection = RunService.RenderStepped:Connect(function(dt)
			if not viewportFrame.Parent then
				-- ViewportFrame fue destruido, detener rotación
				if rotationConnection then
					rotationConnection:Disconnect()
				end
				return
			end

			rotation = rotation + (dt * rotationSpeed * 50)
			if clonedModel.PrimaryPart then
				clonedModel:SetPrimaryPartCFrame(CFrame.Angles(0, math.rad(rotation), 0))
			end
		end)
	end

	-- Retornar referencias
	return {
		Model = clonedModel,
		Camera = camera,
		Connection = rotationConnection
	}
end

-- ============================================
-- FUNCIÓN: DETENER ROTACIÓN Y LIMPIAR
-- ============================================
function ViewportUtil.CleanupViewport(viewportData)
	if not viewportData then return end

	-- Desconectar rotación
	if viewportData.Connection then
		viewportData.Connection:Disconnect()
	end

	-- Destruir modelo
	if viewportData.Model then
		viewportData.Model:Destroy()
	end

	-- Destruir cámara
	if viewportData.Camera then
		viewportData.Camera:Destroy()
	end
end

-- ============================================
-- FUNCIÓN: ACTUALIZAR MODELO EN VIEWPORT
-- ============================================
function ViewportUtil.UpdatePetInViewport(viewportFrame, petName, autoRotate, rotationSpeed)
	-- Limpiar actual
	ViewportUtil.CleanupViewport({Model = viewportFrame:FindFirstChildWhichIsA("Model"), Camera = viewportFrame:FindFirstChildOfClass("Camera")})

	-- Mostrar nuevo
	return ViewportUtil.ShowPetInViewport(viewportFrame, petName, autoRotate, rotationSpeed)
end

return ViewportUtil
