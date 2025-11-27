--[[
	MÓDULO DE CONFIGURACIÓN GLOBAL
	Ubicación: ReplicatedStorage/Modules/Config
	Descripción: Contiene todas las configuraciones del sistema
]]

local Config = {}

-- CONFIGURACIÓN DE VELOCIDAD
Config.BaseWalkSpeed = 16 -- Velocidad base al caminar
Config.BaseSprintSpeed = 16 -- Velocidad base al correr (sin boost)

-- CONFIGURACIÓN DE ORBS
-- MODO DE SPAWN: "fixed" (posiciones fijas) o "zone" (zona aleatoria)
Config.OrbSpawnMode = "zone" -- Cambia a "fixed" para usar posiciones predefinidas

-- SPAWN EN ZONA ALEATORIA (solo se usa si OrbSpawnMode = "zone")
Config.OrbSpawnZone = {
	Center = Vector3.new(0, 5, 0), -- Centro de la zona
	Size = Vector3.new(50, 10, 50), -- Tamaño de la zona (X, Y, Z)
}
Config.OrbCount = 20 -- Cantidad de orbs a generar en la zona

-- SPAWN EN POSICIONES FIJAS (solo se usa si OrbSpawnMode = "fixed")
Config.OrbSpawnLocations = {
	-- Define aquí las posiciones donde aparecerán las orbs
	-- Formato: Vector3.new(x, y, z)
	Vector3.new(0, 5, 0),
	Vector3.new(10, 5, 10),
	Vector3.new(-10, 5, 10),
	Vector3.new(10, 5, -10),
	Vector3.new(-10, 5, -10),
	-- Añade más posiciones según necesites
}

Config.OrbSize = Vector3.new(2, 2, 2) -- Tamaño de las orbs
Config.OrbColor = Color3.fromRGB(255, 255, 0) -- Color amarillo
Config.OrbMaterial = Enum.Material.Neon
Config.OrbTransparency = 0.3
Config.OrbSpeedBoost = 1 -- Cuánta velocidad añade cada orb
Config.OrbMoneyReward = 10 -- Cuánto dinero da cada orb
Config.OrbRespawnTime = 30 -- Segundos para que reaparezca una orb

-- CONFIGURACIÓN DE SPRINT
Config.SprintKey = Enum.KeyCode.LeftShift -- Tecla para sprint en PC

-- CONFIGURACIÓN DE ANIMACIONES
-- Sprint Animation (déjalo vacío "" para desactivar)
Config.SprintAnimationId = "" -- Ejemplo: "rbxassetid://1234567890"

-- Jump Animation (déjalo vacío "" para desactivar)
Config.JumpAnimationId = "" -- Ejemplo: "rbxassetid://0987654321"

-- CONFIGURACIÓN DE ECONOMÍA
Config.StartingMoney = 0
Config.StartingRebirths = 0
Config.RebirthCost = 1000 -- Costo de dinero para hacer rebirth
Config.RebirthSpeedMultiplier = 1.5 -- Multiplicador de velocidad por rebirth

-- CONFIGURACIÓN DE REVIVIR
Config.RespawnTime = 5 -- Segundos para revivir automáticamente

return Config
