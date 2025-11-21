--[[
	GlassBridgeConfig.lua
	Módulo de configuración para el minijuego Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassBridgeConfig = {}

-- CONFIGURACIÓN DEL PUENTE
GlassBridgeConfig.NumberOfRows = 25 -- Número de filas del puente
GlassBridgeConfig.PanelSize = Vector3.new(10, 0.5, 10) -- Tamaño de cada panel
GlassBridgeConfig.GapBetweenPanels = 1 -- Espacio entre paneles (horizontal)
GlassBridgeConfig.GapBetweenRows = 0.5 -- Espacio entre filas

-- COLORES Y APARIENCIA
GlassBridgeConfig.SafePanelColor = Color3.fromRGB(100, 200, 255) -- Azul (inicialmente transparente)
GlassBridgeConfig.FakePanelColor = Color3.fromRGB(255, 100, 100) -- Rojo (inicialmente transparente)
GlassBridgeConfig.InitialTransparency = 0.3 -- Transparencia inicial (0.3 = semi-transparente)
GlassBridgeConfig.GlassMaterial = Enum.Material.Neon -- Material brillante que mantiene transparencia

-- EFECTOS DE ROTURA
GlassBridgeConfig.BreakDelay = 0.3 -- Segundos antes de que el panel se rompa
GlassBridgeConfig.ShatterParticles = true -- Activar partículas de rotura
GlassBridgeConfig.ShatterSound = true -- Activar sonido de rotura

-- NUEVOS EFECTOS (ACTUALIZADOS)
GlassBridgeConfig.UseDecals = true -- Agregar Decals a los paneles para mejor apariencia
GlassBridgeConfig.DecalTextures = { -- 3 texturas diferentes para los Decals
	"rbxassetid://6372755229", -- Textura 1 (vidrio agrietado)
	"rbxassetid://6372755229", -- Textura 2 (puedes cambiar este ID)
	"rbxassetid://6372755229"  -- Textura 3 (puedes cambiar este ID)
}
GlassBridgeConfig.ExplosionEnabled = true -- Activar explosión en paneles falsos
GlassBridgeConfig.ExplosionForce = 100 -- Fuerza de la explosión
GlassBridgeConfig.ExplosionRadius = 10 -- Radio de la explosión
GlassBridgeConfig.RegenerateDelay = 15 -- Segundos para regenerar paneles falsos destruidos
GlassBridgeConfig.AlwaysShowSafeGreen = false -- Paneles seguros NO permanecen verdes (efecto temporal)
GlassBridgeConfig.SafePanelCooldown = 2 -- Segundos de cooldown antes de que un panel seguro pueda activarse de nuevo

-- GAMEPLAY
GlassBridgeConfig.FallHeight = 50 -- Altura de caída debajo del puente
GlassBridgeConfig.RespawnOnDeath = false -- Si true, respawnea; si false, elimina al jugador
GlassBridgeConfig.ShowCorrectPath = false -- Si true, muestra el camino correcto (modo debug)

-- PUNTOS DE INICIO Y FIN
GlassBridgeConfig.StartPosition = Vector3.new(0, 5, 0) -- Posición del primer panel
GlassBridgeConfig.WinPosition = Vector3.new(0, 5, 120) -- Posición de la plataforma de victoria

return GlassBridgeConfig
