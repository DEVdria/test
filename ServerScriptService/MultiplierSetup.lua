--[[
═══════════════════════════════════════════════════════════════
    MULTIPLIER SETUP - Instalación Automática del Multiplicador
    Ubicación: ServerScriptService

    INSTRUCCIONES:
    1. Coloca este script en ServerScriptService
    2. Ejecuta el juego UNA SOLA VEZ
    3. La Part aparecerá en el Workspace automáticamente
    4. ELIMINA ESTE SCRIPT después de la primera ejecución

    El script crea:
    - Part en el Workspace (MultiplierPart)
    - SurfaceGui con botón funcional
    - LocalScript del cliente integrado
═══════════════════════════════════════════════════════════════
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Verificar que no exista ya
if Workspace:FindFirstChild("MultiplierPart") then
	warn("⚠️ MultiplierPart ya existe en el Workspace. Eliminando este script.")
	script:Destroy()
	return
end

print("🔧 Instalando sistema de multiplicadores en el Workspace...")

-- ====================================
-- CREAR LA PART
-- ====================================
local part = Instance.new("Part")
part.Name = "MultiplierPart"
part.Size = Vector3.new(8, 6, 1)
part.Position = Vector3.new(0, 10, 0) -- Ajusta esta posición según tu mapa
part.Anchored = true
part.CanCollide = false
part.Material = Enum.Material.SmoothPlastic
part.BrickColor = BrickColor.new("Deep blue")
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.Parent = Workspace

-- Añadir brillo
local pointLight = Instance.new("PointLight")
pointLight.Brightness = 2
pointLight.Range = 15
pointLight.Color = Color3.fromRGB(85, 170, 255)
pointLight.Parent = part

-- ====================================
-- CREAR SURFACEGUI
-- ====================================
local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Name = "MultiplierGui"
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.CanvasSize = Vector2.new(800, 600)
surfaceGui.LightInfluence = 0
surfaceGui.AlwaysOnTop = false
surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surfaceGui.PixelsPerStud = 100
surfaceGui.Parent = part

-- ====================================
-- CREAR FRAME DE FONDO
-- ====================================
local backgroundFrame = Instance.new("Frame")
backgroundFrame.Name = "Background"
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
backgroundFrame.BorderSizePixel = 0
backgroundFrame.Parent = surfaceGui

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 20)
bgCorner.Parent = backgroundFrame

-- ====================================
-- CREAR BOTÓN DE COMPRA
-- ====================================
local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.Size = UDim2.new(0.9, 0, 0.85, 0)
buyButton.Position = UDim2.new(0.05, 0, 0.075, 0)
buyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
buyButton.BorderSizePixel = 0
buyButton.Text = "💰 COMPRAR MULTIPLICADOR 💰\n\nCargando..."
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.Font = Enum.Font.GothamBold
buyButton.TextScaled = true
buyButton.Parent = backgroundFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 15)
btnCorner.Parent = buyButton

local btnPadding = Instance.new("UIPadding")
btnPadding.PaddingTop = UDim.new(0.05, 0)
btnPadding.PaddingBottom = UDim.new(0.05, 0)
btnPadding.PaddingLeft = UDim.new(0.05, 0)
btnPadding.PaddingRight = UDim.new(0.05, 0)
btnPadding.Parent = buyButton

-- ====================================
-- CREAR LOCALSCRIPT DEL CLIENTE
-- ====================================
local clientScript = Instance.new("LocalScript")
clientScript.Name = "MultiplierButtonClient"
clientScript.Source = [[
--[[
    MULTIPLIER BUTTON CLIENT - Script Local del Botón
    Este script maneja la interacción del jugador con el botón
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Referencias
local button = script.Parent
local MULTIPLIER_COST = 10000

-- Colores
local COLOR_DEFAULT = Color3.fromRGB(85, 170, 255)
local COLOR_HOVER = Color3.fromRGB(100, 190, 255)
local COLOR_PRESSED = Color3.fromRGB(70, 150, 230)
local COLOR_DISABLED = Color3.fromRGB(60, 60, 60)

-- Variables
local canClick = true
local purchaseMultiplierEvent = nil

--[[
    Función: Esperar a que existan los RemoteEvents
--]]
local function waitForRemoteEvents()
	local maxWait = 10
	local waited = 0

	while not ReplicatedStorage:FindFirstChild("PurchaseMultiplier") and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5
	end

	if ReplicatedStorage:FindFirstChild("PurchaseMultiplier") then
		purchaseMultiplierEvent = ReplicatedStorage.PurchaseMultiplier
		return true
	else
		warn("❌ No se pudo encontrar PurchaseMultiplier RemoteEvent")
		return false
	end
end

--[[
    Función: Obtener multiplicador actual del jugador
--]]
local function getCurrentMultiplier()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local multiplierStat = leaderstats:FindFirstChild("Multiplicador")
		if multiplierStat then
			return multiplierStat.Value
		end
	end
	return 1.0
end

--[[
    Función: Obtener dinero actual del jugador
--]]
local function getCurrentMoney()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyStat = leaderstats:FindFirstChild("Money")
		if moneyStat then
			return moneyStat.Value
		end
	end
	return 0
end

--[[
    Función: Actualizar texto del botón
--]]
local function updateButtonText()
	local currentMultiplier = getCurrentMultiplier()
	local nextMultiplier = math.floor((currentMultiplier + 0.1) * 10 + 0.5) / 10
	local currentMoney = getCurrentMoney()

	local canAfford = currentMoney >= MULTIPLIER_COST

	-- Formatear dinero con comas
	local function formatMoney(amount)
		local formatted = tostring(amount)
		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if k == 0 then break end
		end
		return formatted
	end

	if canAfford then
		button.Text = string.format(
			"💰 COMPRAR MULTIPLICADOR 💰\n\n" ..
			"Actual: x%.1f → Siguiente: x%.1f\n\n" ..
			"Costo: $%s\n" ..
			"Tu dinero: $%s ✅",
			currentMultiplier,
			nextMultiplier,
			formatMoney(MULTIPLIER_COST),
			formatMoney(currentMoney)
		)
		button.BackgroundColor3 = COLOR_DEFAULT
		canClick = true
	else
		button.Text = string.format(
			"💰 COMPRAR MULTIPLICADOR 💰\n\n" ..
			"Actual: x%.1f → Siguiente: x%.1f\n\n" ..
			"Costo: $%s\n" ..
			"Tu dinero: $%s ❌",
			currentMultiplier,
			nextMultiplier,
			formatMoney(MULTIPLIER_COST),
			formatMoney(currentMoney)
		)
		button.BackgroundColor3 = COLOR_DISABLED
		canClick = false
	end
end

--[[
    Evento: Click en el botón
--]]
button.MouseButton1Click:Connect(function()
	if not canClick or not purchaseMultiplierEvent then
		return
	end

	local currentMoney = getCurrentMoney()
	if currentMoney < MULTIPLIER_COST then
		-- Mostrar feedback visual
		local originalColor = button.BackgroundColor3
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		task.wait(0.2)
		button.BackgroundColor3 = originalColor
		return
	end

	-- Efecto visual de clic
	button.BackgroundColor3 = COLOR_PRESSED
	button.Text = "⏳ COMPRANDO..."
	canClick = false

	-- Enviar solicitud al servidor
	purchaseMultiplierEvent:FireServer()

	-- Esperar respuesta
	task.wait(0.5)

	-- Restaurar
	updateButtonText()
end)

--[[
    Efectos hover
--]]
button.MouseEnter:Connect(function()
	if canClick then
		button.BackgroundColor3 = COLOR_HOVER
	end
end)

button.MouseLeave:Connect(function()
	if canClick then
		button.BackgroundColor3 = COLOR_DEFAULT
	elseif getCurrentMoney() < MULTIPLIER_COST then
		button.BackgroundColor3 = COLOR_DISABLED
	end
end)

--[[
    Observar cambios en leaderstats
--]]
local function watchLeaderstats()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		warn("❌ No se encontró leaderstats")
		return
	end

	-- Observar multiplicador
	local multiplierStat = leaderstats:WaitForChild("Multiplicador", 10)
	if multiplierStat then
		multiplierStat.Changed:Connect(function()
			updateButtonText()
		end)
	end

	-- Observar dinero
	local moneyStat = leaderstats:WaitForChild("Money", 10)
	if moneyStat then
		moneyStat.Changed:Connect(function()
			updateButtonText()
		end)
	end
end

-- Inicialización
task.spawn(function()
	-- Esperar a RemoteEvents
	local success = waitForRemoteEvents()
	if not success then
		button.Text = "❌ ERROR\nNo se pudo conectar al servidor"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		return
	end

	-- Esperar leaderstats
	task.wait(1)

	-- Configurar observadores
	watchLeaderstats()

	-- Primera actualización
	updateButtonText()

	-- Actualizar periódicamente
	task.spawn(function()
		while true do
			task.wait(2)
			updateButtonText()
		end
	end)

	print("✅ Botón de multiplicador inicializado para " .. player.Name)
end)
]]
clientScript.Parent = buyButton

-- ====================================
-- MENSAJES DE CONFIRMACIÓN
-- ====================================
print("✅ MultiplierPart creada exitosamente en el Workspace!")
print("📍 Posición: " .. tostring(part.Position))
print("💡 Ajusta la posición de la Part según tu mapa")
print("🗑️ ELIMINA este script (MultiplierSetup) de ServerScriptService")

-- Auto-eliminar el script después de 5 segundos
task.wait(5)
print("🗑️ Auto-eliminando script de instalación...")
script:Destroy()
