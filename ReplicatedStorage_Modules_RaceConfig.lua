-- ReplicatedStorage > Modules > RaceConfig (ModuleScript)
-- Configuración del sistema de carreras

local RaceConfig = {}

-- ==================== CONFIGURACIÓN GENERAL ====================

-- Tiempo entre carreras (en segundos)
RaceConfig.RACE_INTERVAL = 120  -- 2 minutos

-- Tiempo de aviso antes de la carrera (en segundos)
RaceConfig.WARNING_TIME = 10

-- Tiempo de espera en la zona de espera (en segundos)
RaceConfig.WAIT_TIME = 15

-- Tiempo máximo de carrera (en segundos)
RaceConfig.MAX_RACE_TIME = 30

-- ==================== NOMBRES DE OBJETOS EN WORKSPACE ====================

-- Zona de espera (Part donde se teletransportan los jugadores)
RaceConfig.WAIT_ZONE_NAME = "WaitZone"

-- Barrera invisible (Part que bloquea el inicio)
RaceConfig.BARRIER_NAME = "RaceBarrier"

-- Meta de la carrera (Part que detecta cuando terminan)
RaceConfig.FINISH_NAME = "RaceFinish"

-- ==================== COORDENADAS ====================

-- Coordenadas de teletransporte al finalizar
RaceConfig.SPAWN_POSITION = Vector3.new(0, 2, 0)

-- ==================== PREMIOS ====================

RaceConfig.Rewards = {
	-- Primer lugar
	First = {
		XP = 30000,
		Money = 100000,
		AddWin = true  -- Solo el primero recibe un Win
	},

	-- Segundo lugar
	Second = {
		XP = 15000,
		Money = 50000,
		AddWin = false
	},

	-- Tercer lugar
	Third = {
		XP = 7500,
		Money = 25000,
		AddWin = false
	}
}

-- ==================== MENSAJES ====================

RaceConfig.Messages = {
	Warning = "¡Una carrera comenzará en %d segundos!",
	RaceStarted = "Ha iniciado una carrera",
	CountingDown = "La carrera comenzará en %d segundos...",
	RaceBegin = "¡CARRERA INICIADA!",
	RaceEnded = "¡Carrera terminada!",
	NoParticipants = "Nadie se unió a la carrera. Carrera cancelada."
}

return RaceConfig
