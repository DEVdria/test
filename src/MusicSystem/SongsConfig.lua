--[[
	SongsConfig.lua
	Este es un ModuleScript que contiene todas las canciones disponibles

	INSTRUCCIONES:
	1. Este archivo debe ir en ReplicatedStorage como "SongsConfig"
	2. Para agregar más canciones, simplemente añade más entradas a la tabla Songs
	3. Puedes obtener IDs de audio de la Toolbox de Roblox

	Para encontrar IDs de audio:
	- Ve a la Toolbox en Roblox Studio
	- Busca "Audio" o "Music"
	- Haz clic derecho en un audio y selecciona "Copy Asset ID"
	- Pega el ID en la configuración abajo
]]

local SongsConfig = {}

-- Lista de todas las canciones disponibles
-- Cada canción tiene: Name (nombre que se muestra), AssetId (ID del audio)
SongsConfig.Songs = {
	{
		Name = "Happy Tune",
		AssetId = "rbxassetid://1837879082" -- Ejemplo de ID
	},
	{
		Name = "Adventure Music",
		AssetId = "rbxassetid://1843404009" -- Ejemplo de ID
	},
	{
		Name = "Calm Melody",
		AssetId = "rbxassetid://1841647093" -- Ejemplo de ID
	},
	{
		Name = "Epic Battle",
		AssetId = "rbxassetid://1838673350" -- Ejemplo de ID
	},
	{
		Name = "Peaceful Theme",
		AssetId = "rbxassetid://1842658901" -- Ejemplo de ID
	}
}

-- Configuración por defecto
SongsConfig.DefaultSong = 1 -- Índice de la canción que suena al inicio
SongsConfig.DefaultVolume = 0.5 -- Volumen por defecto (0-1)

return SongsConfig
