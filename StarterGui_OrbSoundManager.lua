-- StarterGui > OrbSoundManager (LocalScript)
-- Reproduce sonidos cuando recoges orbs
-- TÚ PUEDES PERSONALIZAR LOS SONIDOS CAMBIANDO LOS IDs DE AUDIO

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not RemoteEvents then
	warn("[OrbSoundManager] ❌ No se encontró carpeta RemoteEvents")
	return
end

local ShowOrbNotificationEvent = RemoteEvents:WaitForChild("ShowOrbNotification", 10)
if not ShowOrbNotificationEvent then
	warn("[OrbSoundManager] ❌ No se encontró RemoteEvent ShowOrbNotification")
	return
end

-- ==================== CONFIGURACIÓN DE SONIDOS ====================
-- CAMBIA ESTOS IDs POR LOS SONIDOS QUE QUIERAS USAR
-- Busca sonidos en: https://www.roblox.com/develop (Audio)
-- O usa sonidos del catálogo de Roblox

local SOUND_IDS = {
	-- Puedes usar el mismo sonido para todos o diferentes por tipo
	Yellow = "rbxassetid://5051712449",  -- Sonido de "ding" agudo
	Green = "rbxassetid://5051712449",   -- Sonido de "ding" medio
	Blue = "rbxassetid://5051712449",    -- Sonido de "ding" grave

	-- Alternativas populares (descomenta para usar):
	-- Yellow = "rbxassetid://6895079853",  -- Coin collect
	-- Green = "rbxassetid://6895079853",
	-- Blue = "rbxassetid://6895079853",
}

-- Configuración de volumen y pitch
local SOUND_CONFIG = {
	Yellow = {
		Volume = 0.5,
		Pitch = 1.2,  -- Más agudo
		PlaybackSpeed = 1.2
	},
	Green = {
		Volume = 0.6,
		Pitch = 1.0,  -- Normal
		PlaybackSpeed = 1.0
	},
	Blue = {
		Volume = 0.7,
		Pitch = 0.8,  -- Más grave
		PlaybackSpeed = 0.9
	}
}

-- ==================== SISTEMA DE SONIDO ====================

-- Crear un SoundGroup para los sonidos de orbs (opcional)
local orbSoundGroup = Instance.new("SoundGroup")
orbSoundGroup.Name = "OrbSounds"
orbSoundGroup.Volume = 1.0  -- Volumen maestro de todos los sonidos de orbs
orbSoundGroup.Parent = SoundService

-- Pool de sonidos (reutilizar para mejor performance)
local soundPool = {}
local MAX_SOUNDS = 5  -- Máximo de sonidos simultáneos

-- Obtiene un sonido del pool o crea uno nuevo
local function getSound(orbType)
	-- Buscar sonido disponible en el pool
	for i, sound in ipairs(soundPool) do
		if not sound.IsPlaying then
			return sound
		end
	end

	-- Si no hay sonidos disponibles, crear uno nuevo (hasta el máximo)
	if #soundPool < MAX_SOUNDS then
		local sound = Instance.new("Sound")
		sound.SoundGroup = orbSoundGroup
		sound.Parent = SoundService
		table.insert(soundPool, sound)
		return sound
	end

	-- Si ya hay demasiados sonidos, usar el primero (lo interrumpirá)
	return soundPool[1]
end

-- Reproduce un sonido de orb
local function playOrbSound(orbType)
	local soundId = SOUND_IDS[orbType]
	local soundConfig = SOUND_CONFIG[orbType]

	if not soundId then
		warn("[OrbSoundManager] No se encontró sonido para orb tipo:", orbType)
		return
	end

	if not soundConfig then
		warn("[OrbSoundManager] No se encontró configuración para orb tipo:", orbType)
		return
	end

	-- Obtener sonido del pool
	local sound = getSound(orbType)

	-- Configurar propiedades
	sound.SoundId = soundId
	sound.Volume = soundConfig.Volume
	sound.PlaybackSpeed = soundConfig.PlaybackSpeed

	-- Reproducir
	sound:Play()
end

-- ==================== ESCUCHAR EVENTOS ====================

ShowOrbNotificationEvent.OnClientEvent:Connect(function(orbType, expAmount, orbColor)
	-- Reproducir sonido cuando se muestra la notificación
	playOrbSound(orbType)
end)

print("[OrbSoundManager] ✅ Sistema de sonidos de orbs iniciado")
print("[OrbSoundManager] 🔊 Volumen maestro:", orbSoundGroup.Volume)

-- ==================== NOTAS DE USO ====================
--[[
	CÓMO CAMBIAR LOS SONIDOS:

	1. Ve a https://www.roblox.com/develop
	2. Busca "Audio" en el catálogo
	3. Encuentra el sonido que quieras
	4. Copia el ID del sonido (número)
	5. Pega el ID en SOUND_IDS arriba

	EJEMPLOS DE IDs DE SONIDOS:
	- Coin collect: 6895079853
	- Ding: 5051712449
	- Pop: 6265367896
	- Chime: 6518811702
	- Bell: 5052053296

	CÓMO USAR DIFERENTES SONIDOS POR TIPO DE ORB:

	SOUND_IDS = {
		Yellow = "rbxassetid://6895079853",  -- Sonido de moneda
		Green = "rbxassetid://5051712449",   -- Sonido de ding
		Blue = "rbxassetid://6518811702",    -- Sonido de campanita
	}

	CÓMO AJUSTAR VOLUMEN Y PITCH:

	SOUND_CONFIG = {
		Yellow = {
			Volume = 0.5,        -- 0.0 a 1.0
			Pitch = 1.2,         -- Más alto = más agudo
			PlaybackSpeed = 1.0  -- Velocidad de reproducción
		}
	}

	CÓMO AJUSTAR VOLUMEN MAESTRO:

	Cambia la línea 43:
	orbSoundGroup.Volume = 0.8  -- Más bajo = más silencioso
]]
