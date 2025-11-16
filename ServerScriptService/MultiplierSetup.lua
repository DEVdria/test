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
clientScript.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local button = script.Parent
local MULTIPLIER_COST = 10000

local COLOR_DEFAULT = Color3.fromRGB(85, 170, 255)
local COLOR_HOVER = Color3.fromRGB(100, 190, 255)
local COLOR_PRESSED = Color3.fromRGB(70, 150, 230)
local COLOR_DISABLED = Color3.fromRGB(60, 60, 60)

local canClick = false
local purchaseMultiplierEvent = nil
local isInitialized = false

print("🎮 Iniciando botón de multiplicador...")

local function formatMoney(amount)
	local str = tostring(amount)
	local result = ""
	local len = string.len(str)

	for i = 1, len do
		result = result .. string.sub(str, i, i)
		if (len - i) % 3 == 0 and i ~= len then
			result = result .. ","
		end
	end

	return result
end

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

local function updateButtonText()
	if not isInitialized then
		return
	end

	local currentMultiplier = getCurrentMultiplier()
	local nextMultiplier = math.floor((currentMultiplier + 0.1) * 10 + 0.5) / 10
	local currentMoney = getCurrentMoney()
	local canAfford = currentMoney >= MULTIPLIER_COST

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

button.MouseButton1Click:Connect(function()
	if not canClick or not purchaseMultiplierEvent then
		print("⚠️ No se puede comprar: canClick=" .. tostring(canClick) .. ", event=" .. tostring(purchaseMultiplierEvent ~= nil))
		return
	end

	local currentMoney = getCurrentMoney()
	if currentMoney < MULTIPLIER_COST then
		local originalColor = button.BackgroundColor3
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		task.wait(0.2)
		button.BackgroundColor3 = originalColor
		return
	end

	button.BackgroundColor3 = COLOR_PRESSED
	button.Text = "⏳ COMPRANDO..."
	canClick = false

	purchaseMultiplierEvent:FireServer()
	print("📤 Solicitud de compra enviada")

	task.wait(0.5)
	updateButtonText()
end)

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

task.spawn(function()
	button.Text = "⏳ Esperando servidor...\n(Sistemas cargando)"
	button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

	-- Esperar a que exista leaderstats (máximo 15 segundos)
	print("⏳ Esperando leaderstats...")
	local leaderstats = player:WaitForChild("leaderstats", 15)

	if not leaderstats then
		button.Text = "❌ ERROR\nLeaderstats no encontrado\n(¿MoneyManager activo?)"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		warn("❌ No se encontró leaderstats para " .. player.Name)
		return
	end

	print("✅ Leaderstats encontrado")

	-- Esperar a Money
	print("⏳ Esperando Money...")
	local moneyStat = leaderstats:WaitForChild("Money", 15)

	if not moneyStat then
		button.Text = "❌ ERROR\nMoney no encontrado"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		warn("❌ No se encontró Money para " .. player.Name)
		return
	end

	print("✅ Money encontrado")

	-- Esperar a Multiplicador
	print("⏳ Esperando Multiplicador...")
	button.Text = "⏳ Esperando multiplicador...\n(Casi listo)"

	local multiplierStat = leaderstats:WaitForChild("Multiplicador", 15)

	if not multiplierStat then
		button.Text = "❌ ERROR\nMultiplicador no encontrado\n(¿MultiplierSystem activo?)"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		warn("❌ No se encontró Multiplicador para " .. player.Name)
		return
	end

	print("✅ Multiplicador encontrado")

	-- Esperar a RemoteEvent
	print("⏳ Esperando RemoteEvent...")
	button.Text = "⏳ Conectando...\n(Último paso)"

	local waitTime = 0
	while not ReplicatedStorage:FindFirstChild("PurchaseMultiplier") and waitTime < 15 do
		task.wait(0.5)
		waitTime = waitTime + 0.5
	end

	purchaseMultiplierEvent = ReplicatedStorage:FindFirstChild("PurchaseMultiplier")

	if not purchaseMultiplierEvent then
		button.Text = "❌ ERROR\nRemoteEvent no encontrado\n(¿MultiplierSystem activo?)"
		button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		warn("❌ No se encontró PurchaseMultiplier RemoteEvent")
		return
	end

	print("✅ RemoteEvent encontrado")

	-- Todo listo, activar botón
	isInitialized = true

	-- Observar cambios
	multiplierStat.Changed:Connect(function()
		updateButtonText()
	end)

	moneyStat.Changed:Connect(function()
		updateButtonText()
	end)

	-- Primera actualización
	updateButtonText()

	-- Actualizar periódicamente
	task.spawn(function()
		while true do
			task.wait(2)
			updateButtonText()
		end
	end)

	print("✅ Botón de multiplicador completamente inicializado para " .. player.Name)
end)
]=]
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
