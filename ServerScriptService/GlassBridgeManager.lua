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

	local currentZ = Config.StartPosition.Z

	for row = 1, Config.NumberOfRows do
		-- Avanzar en Z
		currentZ = currentZ + Config.PanelSize.Z + Config.GapBetweenRows

		-- Determinar qué panel es seguro
		local safeSide = CorrectPath[row]

		-- Posición del panel izquierdo
		local leftPosition = Vector3.new(
			Config.StartPosition.X - (Config.PanelSize.X / 2 + Config.GapBetweenPanels / 2),
			Config.StartPosition.Y,
			currentZ
		)

		-- Posición del panel derecho
		local rightPosition = Vector3.new(
			Config.StartPosition.X + (Config.PanelSize.X / 2 + Config.GapBetweenPanels / 2),
			Config.StartPosition.Y,
			currentZ
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

	-- Plataforma de inicio
	local startPos = Config.StartPosition - Vector3.new(0, 0, 10)
	Effects.CreateStartPlatform(startPos, Vector3.new(20, 1, 10))

	-- Plataforma de victoria
	local winZ = Config.StartPosition.Z + (Config.NumberOfRows * (Config.PanelSize.Z + Config.GapBetweenRows)) + 15
	local winPos = Vector3.new(Config.StartPosition.X, Config.StartPosition.Y, winZ)
	Effects.CreateWinPlatform(winPos, Vector3.new(20, 1, 10))

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
