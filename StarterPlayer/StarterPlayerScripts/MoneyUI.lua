--[[
═══════════════════════════════════════════════════════════════
    MONEY UI - Interfaz de Dinero del Jugador
    Ubicación: StarterPlayer > StarterPlayerScripts

    Funcionalidad:
    - Muestra el dinero del jugador en la esquina superior derecha
    - Se actualiza automáticamente cuando cambia el dinero
    - Crea la UI dinámicamente
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que se cree la carpeta leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local money = leaderstats:WaitForChild("Money")

--[[
    Crear UI del Dinero
--]]
local function createMoneyUI()
	-- Crear ScreenGui principal
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MoneyDisplay"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Frame contenedor
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 250, 0, 80)
	mainFrame.Position = UDim2.new(1, -270, 0, 20)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Esquinas redondeadas
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Sombra (efecto visual)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 6, 1, 6)
	shadow.Position = UDim2.new(0, -3, 0, -3)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.7
	shadow.BorderSizePixel = 0
	shadow.ZIndex = mainFrame.ZIndex - 1
	shadow.Parent = mainFrame

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 12)
	shadowCorner.Parent = shadow

	-- Ícono de moneda
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(0, 50, 0, 50)
	iconLabel.Position = UDim2.new(0, 10, 0.5, -25)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "💰"
	iconLabel.TextSize = 32
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = mainFrame

	-- Label de título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0, 170, 0, 20)
	titleLabel.Position = UDim2.new(0, 70, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "DINERO"
	titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = mainFrame

	-- Label del dinero
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(0, 170, 0, 35)
	moneyLabel.Position = UDim2.new(0, 70, 0, 35)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "$" .. tostring(money.Value)
	moneyLabel.TextColor3 = Color3.fromRGB(85, 255, 127)
	moneyLabel.TextSize = 24
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moneyLabel.Parent = mainFrame

	-- Actualizar cuando cambia el dinero
	money.Changed:Connect(function(newValue)
		moneyLabel.Text = "$" .. tostring(newValue)

		-- Efecto de pulso al cambiar
		moneyLabel:TweenSize(
			UDim2.new(0, 180, 0, 40),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Elastic,
			0.3,
			true
		)

		wait(0.3)

		moneyLabel:TweenSize(
			UDim2.new(0, 170, 0, 35),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Elastic,
			0.3,
			true
		)
	end)

	-- Animación de entrada
	mainFrame.Position = UDim2.new(1, 0, 0, 20)
	mainFrame:TweenPosition(
		UDim2.new(1, -270, 0, 20),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)
end

-- Crear la UI cuando el script se carga
createMoneyUI()

print("UI de dinero cargada correctamente")
