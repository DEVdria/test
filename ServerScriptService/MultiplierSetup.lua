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
-- VERIFICAR QUE EXISTE EL MODULESCRIPT
-- ====================================
local buttonModule = ReplicatedStorage:FindFirstChild("MultiplierButtonModule")
if not buttonModule then
	warn("❌ ERROR: MultiplierButtonModule no existe en ReplicatedStorage")
	warn("⚠️ Asegúrate de que el archivo MultiplierButtonModule.lua esté instalado")
	return
end

print("✅ MultiplierButtonModule encontrado en ReplicatedStorage")

-- ====================================
-- CREAR LOCALSCRIPT DEL CLIENTE
-- ====================================
local clientScript = Instance.new("LocalScript")
clientScript.Name = "MultiplierButtonClient"
clientScript.Parent = buyButton

-- Crear StringValue con las instrucciones del código a copiar
local instructions = Instance.new("StringValue")
instructions.Name = "INSTRUCCIONES_CODIGO"
instructions.Value = [[
-- COPIA ESTE CÓDIGO EN EL LOCALSCRIPT:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local buttonModule = require(ReplicatedStorage:WaitForChild("MultiplierButtonModule"))
buttonModule.Init(script.Parent)
]]
instructions.Parent = clientScript

print("")
print("⚠️ ═════════════════════════════════════════════════════")
print("⚠️ IMPORTANTE: El LocalScript necesita código manual")
print("⚠️ ═════════════════════════════════════════════════════")
print("")
print("📝 Sigue estos pasos:")
print("1. Ve a Workspace → MultiplierPart → MultiplierGui → Background → BuyButton")
print("2. Abre el LocalScript llamado 'MultiplierButtonClient'")
print("3. Copia y pega este código:")
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print([[local ReplicatedStorage = game:GetService("ReplicatedStorage")]])
print([[local buttonModule = require(ReplicatedStorage:WaitForChild("MultiplierButtonModule"))]])
print([[buttonModule.Init(script.Parent)]])
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("✅ Después de pegar el código, el botón funcionará correctamente")
print("")

-- ====================================
-- MENSAJES DE CONFIRMACIÓN
-- ====================================
print("✅ MultiplierPart creada exitosamente en el Workspace!")
print("📍 Posición: " .. tostring(part.Position))
print("💡 Ahora sigue las instrucciones de arriba para completar la instalación")
print("")
