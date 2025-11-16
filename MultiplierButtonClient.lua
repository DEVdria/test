--[[
═══════════════════════════════════════════════════════════════
    MULTIPLIER BUTTON CLIENT - Script Local del Botón
    Ubicación: Workspace > MultiplierPart > SurfaceGui > TextButton

    INSTRUCCIONES DE INSTALACIÓN:
    1. Crea una Part en el Workspace llamada "MultiplierPart"
    2. Añade un SurfaceGui a la Part
       - Face: Front (o la cara que prefieras)
       - Adornee: MultiplierPart (selecciona la Part)
    3. Dentro del SurfaceGui, crea:
       - Frame principal (opcional, para diseño)
       - TextButton llamado "BuyButton"
    4. Pega este script dentro del TextButton como LocalScript
    5. El botón mostrará el multiplicador actual del jugador

    Funcionalidad:
    - Muestra el multiplicador actual del jugador
    - Muestra el costo de la siguiente compra
    - Al hacer clic, envía solicitud de compra al servidor
    - Solo el jugador que hace clic ve su propio multiplicador
═══════════════════════════════════════════════════════════════
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a RemoteEvents
local purchaseMultiplierEvent = ReplicatedStorage:WaitForChild("PurchaseMultiplier")

-- Referencia al botón (este script debe estar dentro del TextButton)
local button = script.Parent

-- Configuración
local MULTIPLIER_COST = 10000

-- Colores
local COLOR_DEFAULT = Color3.fromRGB(85, 170, 255)
local COLOR_HOVER = Color3.fromRGB(100, 190, 255)
local COLOR_PRESSED = Color3.fromRGB(70, 150, 230)

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
    Función: Actualizar texto del botón
--]]
local function updateButtonText()
	local currentMultiplier = getCurrentMultiplier()
	local nextMultiplier = math.floor((currentMultiplier + 0.1) * 10 + 0.5) / 10

	button.Text = string.format(
		"💰 COMPRAR MULTIPLICADOR 💰\n\n" ..
		"Actual: x%.1f → Siguiente: x%.1f\n" ..
		"Costo: $%s",
		currentMultiplier,
		nextMultiplier,
		tostring(MULTIPLIER_COST)
	)
end

--[[
    Configurar estilo del botón
--]]
local function setupButtonStyle()
	-- Tamaño y posición (ajustar según necesites)
	button.Size = UDim2.new(0.9, 0, 0.9, 0)
	button.Position = UDim2.new(0.05, 0, 0.05, 0)
	button.BackgroundColor3 = COLOR_DEFAULT
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.BorderSizePixel = 0

	-- Esquinas redondeadas
	local corner = button:FindFirstChild("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 15)
		corner.Parent = button
	end

	-- Padding para el texto
	local padding = button:FindFirstChild("UIPadding")
	if not padding then
		padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0.05, 0)
		padding.PaddingBottom = UDim.new(0.05, 0)
		padding.PaddingLeft = UDim.new(0.05, 0)
		padding.PaddingRight = UDim.new(0.05, 0)
		padding.Parent = button
	end
end

--[[
    Evento: Cuando se hace clic en el botón
--]]
button.MouseButton1Click:Connect(function()
	-- Efecto visual de clic
	button.BackgroundColor3 = COLOR_PRESSED
	task.wait(0.1)
	button.BackgroundColor3 = COLOR_DEFAULT

	-- Enviar solicitud al servidor
	purchaseMultiplierEvent:FireServer()

	-- Actualizar texto después de un momento
	task.wait(0.5)
	updateButtonText()
end)

--[[
    Efecto hover
--]]
button.MouseEnter:Connect(function()
	button.BackgroundColor3 = COLOR_HOVER
end)

button.MouseLeave:Connect(function()
	button.BackgroundColor3 = COLOR_DEFAULT
end)

--[[
    Actualizar cuando cambia el multiplicador
--]]
local function watchMultiplier()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if leaderstats then
		local multiplierStat = leaderstats:WaitForChild("Multiplicador", 10)
		if multiplierStat then
			-- Actualizar cuando cambia
			multiplierStat.Changed:Connect(function()
				updateButtonText()
			end)
		end
	end
end

-- Inicializar
setupButtonStyle()
updateButtonText()
watchMultiplier()

-- Actualizar texto cada 5 segundos (por si acaso)
task.spawn(function()
	while true do
		task.wait(5)
		updateButtonText()
	end
end)

print("✅ Botón de multiplicador inicializado para " .. player.Name)
