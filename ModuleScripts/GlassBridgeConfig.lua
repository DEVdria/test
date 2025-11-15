--[[
	GlassBridgeConfig.lua
	Módulo de configuración para el minijuego Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassBridgeConfig = {}

-- CONFIGURACIÓN DEL PUENTE
GlassBridgeConfig.NumberOfRows = 18 -- Número de filas del puente
GlassBridgeConfig.PanelSize = Vector3.new(6, 0.5, 6) -- Tamaño de cada panel
GlassBridgeConfig.GapBetweenPanels = 1 -- Espacio entre paneles (horizontal)
GlassBridgeConfig.GapBetweenRows = 0.5 -- Espacio entre filas

-- COLORES Y APARIENCIA
GlassBridgeConfig.SafePanelColor = Color3.fromRGB(100, 200, 255) -- Azul (inicialmente transparente)
GlassBridgeConfig.FakePanelColor = Color3.fromRGB(255, 100, 100) -- Rojo (inicialmente transparente)
GlassBridgeConfig.InitialTransparency = 0.3 -- Transparencia inicial (0.3 = semi-transparente)
GlassBridgeConfig.GlassMaterial = Enum.Material.Glass

-- EFECTOS DE ROTURA
GlassBridgeConfig.BreakDelay = 0.3 -- Segundos antes de que el panel se rompa
GlassBridgeConfig.ShatterParticles = true -- Activar partículas de rotura
GlassBridgeConfig.ShatterSound = true -- Activar sonido de rotura

-- GAMEPLAY
GlassBridgeConfig.FallHeight = 50 -- Altura de caída debajo del puente
GlassBridgeConfig.RespawnOnDeath = false -- Si true, respawnea; si false, elimina al jugador
GlassBridgeConfig.ShowCorrectPath = false -- Si true, muestra el camino correcto (modo debug)

-- PUNTOS DE INICIO Y FIN
GlassBridgeConfig.StartPosition = Vector3.new(0, 5, 0) -- Posición del primer panel
GlassBridgeConfig.WinPosition = Vector3.new(0, 5, 120) -- Posición de la plataforma de victoria

return GlassBridgeConfig
