--[[
═══════════════════════════════════════════════════════════════
    SOUND PLAYER - Reproductor de Sonidos del Cliente
    Ubicación: StarterPlayer/StarterPlayerScripts

    Funcionalidad:
    - Escucha eventos del servidor para reproducir sonidos
    - Reproduce sonidos localmente para cada jugador
    - Usa el SoundManager para obtener configuraciones
═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar a que el SoundManager esté disponible
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))

-- Crear o encontrar el RemoteEvent para sonidos
local playSoundEvent = ReplicatedStorage:WaitForChild("PlaySound", 10)

if not playSoundEvent then
    warn("⚠️ RemoteEvent 'PlaySound' no encontrado")
    return
end

-- Contenedor para los sonidos (se crea en el jugador)
local soundContainer = Instance.new("Folder")
soundContainer.Name = "Sounds"
soundContainer.Parent = player:WaitForChild("PlayerGui")

--[[
    Función: Reproducir un sonido
    Parámetros:
        category - Categoría del sonido (ej: "Chests", "Shop", "Rewards")
        soundName - Nombre del sonido (ej: "CommonChest", "Purchase")
        position - Posición 3D donde reproducir el sonido (opcional)
--]]
local function playSound(category, soundName, position)
    -- Obtener configuración del sonido
    local soundConfig = SoundManager.GetSound(category, soundName)

    if not soundConfig then
        warn("⚠️ No se pudo reproducir sonido: " .. category .. "." .. soundName)
        return
    end

    -- Crear objeto Sound
    local sound = Instance.new("Sound")
    sound.SoundId = soundConfig.SoundId
    sound.Volume = soundConfig.Volume or 0.5
    sound.PlaybackSpeed = soundConfig.PlaybackSpeed or 1.0

    -- Si se proporciona una posición, hacer el sonido 3D
    if position then
        -- Crear una Part invisible en la posición para el sonido 3D
        local soundPart = Instance.new("Part")
        soundPart.Transparency = 1
        soundPart.CanCollide = false
        soundPart.Anchored = true
        soundPart.Size = Vector3.new(1, 1, 1)
        soundPart.Position = position
        soundPart.Parent = workspace

        sound.Parent = soundPart
        sound.RollOffMaxDistance = 100
        sound.RollOffMinDistance = 10

        -- Destruir la part después de que el sonido termine
        sound.Ended:Connect(function()
            task.wait(0.1)
            soundPart:Destroy()
        end)
    else
        -- Sonido 2D (se reproduce igual para todos)
        sound.Parent = soundContainer

        -- Destruir el sonido después de que termine
        sound.Ended:Connect(function()
            task.wait(0.1)
            sound:Destroy()
        end)
    end

    -- Reproducir el sonido
    sound:Play()

    -- Debug
    print("🔊 Reproduciendo: " .. category .. "." .. soundName)
end

--[[
    Escuchar eventos del servidor para reproducir sonidos
--]]
playSoundEvent.OnClientEvent:Connect(function(category, soundName, position)
    playSound(category, soundName, position)
end)

print("🔊 SoundPlayer inicializado correctamente")
