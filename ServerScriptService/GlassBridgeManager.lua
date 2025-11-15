--[[
	GlassBridgeManager.lua
	Script principal para gestionar el minijuego Glass Bridge

	Coloca este script en: ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Esperar a que los módulos estén disponibles
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Config = require(ModuleScripts:WaitForChild("GlassBridgeConfig"))
local GlassPanel = require(ModuleScripts:WaitForChild("GlassPanel"))
local Effects = require(ModuleScripts:WaitForChild("GlassBridgeEffects"))

-- Variables globales
local GlassBridgeFolder
local AllPanels = {}
local CorrectPath = {} -- Almacena qué lado es seguro en cada fila

-- Inicializar el juego
local function Initialize()
	print("=== Inicializando Glass Bridge ===")

	-- Crear carpeta en workspace
	GlassBridgeFolder = Instance.new("Folder")
	GlassBridgeFolder.Name = "GlassBridge"
	GlassBridgeFolder.Parent = workspace

	-- Crear RemoteEvent para efectos locales del cliente
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GlassBridgeEffectEvent"
	remoteEvent.Parent = ReplicatedStorage

	-- Generar camino aleatorio
	GenerateRandomPath()

	-- Construir el puente
	BuildBridge()

	-- Crear plataformas de inicio y fin
	CreatePlatforms()

	print("=== Glass Bridge Generado Exitosamente ===")
	print("Filas totales: " .. Config.NumberOfRows)
	print("Camino correcto generado aleatoriamente")
end

-- Generar camino aleatorio (qué lado es seguro en cada fila)
function GenerateRandomPath()
	print("Generando camino aleatorio...")

	math.randomseed(tick())

	for row = 1, Config.NumberOfRows do
		-- Aleatoriamente elegir "Left" o "Right" como seguro
		local safeSide = (math.random(1, 2) == 1) and "Left" or "Right"
		CorrectPath[row] = safeSide

		print("Fila " .. row .. ": Panel seguro = " .. safeSide)
	end
end

-- Construir todo el puente
function BuildBridge()
	print("Construyendo puente...")

	local currentX = Config.StartPosition.X

	for row = 1, Config.NumberOfRows do
		-- Avanzar en X
		currentX = currentX + Config.PanelSize.X + Config.GapBetweenRows

		-- Determinar qué panel es seguro
		local safeSide = CorrectPath[row]

		-- Posición del panel izquierdo (ahora en -Z)
		local leftPosition = Vector3.new(
			currentX,
			Config.StartPosition.Y,
			Config.StartPosition.Z - (Config.PanelSize.Z / 2 + Config.GapBetweenPanels / 2)
		)

		-- Posición del panel derecho (ahora en +Z)
		local rightPosition = Vector3.new(
			currentX,
			Config.StartPosition.Y,
			Config.StartPosition.Z + (Config.PanelSize.Z / 2 + Config.GapBetweenPanels / 2)
		)

		-- Crear panel izquierdo
		local leftPanel = GlassPanel.new(
			leftPosition,
			safeSide == "Left", -- Es seguro si safeSide es "Left"
			row,
			"Left"
		)
		table.insert(AllPanels, leftPanel)

		-- Crear panel derecho
		local rightPanel = GlassPanel.new(
			rightPosition,
			safeSide == "Right", -- Es seguro si safeSide es "Right"
			row,
			"Right"
		)
		table.insert(AllPanels, rightPanel)
	end

	print("Puente construido: " .. #AllPanels .. " paneles creados")
end

-- Crear plataformas de inicio y victoria
function CreatePlatforms()
	print("Creando plataformas...")

	-- Plataforma de inicio (ahora antes en X)
	local startPos = Config.StartPosition - Vector3.new(10, 0, 0)
	Effects.CreateStartPlatform(startPos, Vector3.new(10, 1, 20))

	-- Plataforma de victoria (ahora después en X)
	local winX = Config.StartPosition.X + (Config.NumberOfRows * (Config.PanelSize.X + Config.GapBetweenRows)) + 15
	local winPos = Vector3.new(winX, Config.StartPosition.Y, Config.StartPosition.Z)
	Effects.CreateWinPlatform(winPos, Vector3.new(10, 1, 20))

	print("Plataformas creadas")
end

-- Reiniciar el puente (opcional)
function ResetBridge()
	print("Reiniciando Glass Bridge...")

	-- Destruir todos los paneles
	for _, panel in ipairs(AllPanels) do
		panel:Destroy()
	end
	AllPanels = {}
	CorrectPath = {}

	-- Limpiar carpeta
	if GlassBridgeFolder then
		GlassBridgeFolder:ClearAllChildren()
	end

	-- Regenerar
	GenerateRandomPath()
	BuildBridge()
	CreatePlatforms()

	print("Glass Bridge reiniciado")
end

-- Revelar el camino correcto (para testing/debug)
function RevealPath()
	print("Revelando camino correcto...")
	for _, panel in ipairs(AllPanels) do
		panel:Reveal()
	end
end

-- Comandos de consola (opcional)
_G.GlassBridge = {
	Reset = ResetBridge,
	Reveal = RevealPath,
	Config = Config
}

-- Iniciar el juego
Initialize()

print("Comandos disponibles:")
print("_G.GlassBridge.Reset() - Reinicia el puente")
print("_G.GlassBridge.Reveal() - Revela el camino correcto")
