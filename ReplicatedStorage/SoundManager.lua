--[[
═══════════════════════════════════════════════════════════════
    SOUND MANAGER - Sistema de Sonidos del Juego
    Ubicación: ReplicatedStorage

    Funcionalidad:
    - Catálogo centralizado de todos los sonidos
    - IDs de sonidos organizados por categoría
    - Fácil de personalizar

    Cómo personalizar sonidos:
    1. Ve a la biblioteca de sonidos de Roblox: https://create.roblox.com/marketplace/audio
    2. Encuentra el sonido que quieras
    3. Copia el ID del sonido (aparece en la URL)
    4. Reemplaza el ID correspondiente en este script

    Ejemplo de IDs que puedes usar:
    - rbxassetid://3398620867 (Monedas - Sonido de dinero)
    - rbxassetid://5153845714 (Recompensa - Sonido de logro)
    - rbxassetid://6895079853 (Compra - Sonido de caja registradora)
    - rbxassetid://3194939814 (Cofre Raro - Sonido mágico)
    - rbxassetid://4590662766 (Cofre Épico - Sonido épico)
    - rbxassetid://3194939814 (Cofre Legendario - Sonido legendario)
═══════════════════════════════════════════════════════════════
--]]

local SoundManager = {}

--[[
    CATÁLOGO DE SONIDOS
    Organizado por categoría para fácil acceso
--]]
SoundManager.Sounds = {
    -- Sonidos de Cofres
    Chests = {
        CommonChest = {
            SoundId = "rbxassetid://3398620867", -- Sonido de monedas básico
            Volume = 0.5,
            PlaybackSpeed = 1.0
        },
        RareChest = {
            SoundId = "rbxassetid://3398620867", -- Sonido de monedas (más rápido)
            Volume = 0.6,
            PlaybackSpeed = 1.2
        },
        EpicChest = {
            SoundId = "rbxassetid://3194939814", -- Sonido mágico
            Volume = 0.7,
            PlaybackSpeed = 1.0
        },
        LegendaryChest = {
            SoundId = "rbxassetid://4590662766", -- Sonido épico/legendario
            Volume = 0.8,
            PlaybackSpeed = 1.0
        }
    },

    -- Sonidos de Recompensas
    Rewards = {
        PlaytimeReward = {
            SoundId = "rbxassetid://5153845714", -- Sonido de logro
            Volume = 0.6,
            PlaybackSpeed = 1.0
        },
        QuestComplete = {
            SoundId = "rbxassetid://5153845714", -- Sonido de logro
            Volume = 0.6,
            PlaybackSpeed = 1.1
        }
    },

    -- Sonidos de Tienda
    Shop = {
        Purchase = {
            SoundId = "rbxassetid://6895079853", -- Sonido de compra/caja registradora
            Volume = 0.5,
            PlaybackSpeed = 1.0
        },
        CannotAfford = {
            SoundId = "rbxassetid://2865227271", -- Sonido de error
            Volume = 0.4,
            PlaybackSpeed = 1.0
        }
    },

    -- Sonidos de Dinero
    Money = {
        Gain = {
            SoundId = "rbxassetid://3398620867", -- Sonido de monedas
            Volume = 0.4,
            PlaybackSpeed = 1.0
        }
    }
}

--[[
    Función: Obtener configuración de un sonido
    Parámetros:
        category - Categoría del sonido (ej: "Chests", "Rewards", "Shop")
        soundName - Nombre del sonido dentro de la categoría
    Retorna: Tabla con SoundId, Volume y PlaybackSpeed o nil
--]]
function SoundManager.GetSound(category, soundName)
    if SoundManager.Sounds[category] and SoundManager.Sounds[category][soundName] then
        return SoundManager.Sounds[category][soundName]
    else
        warn("⚠️ Sonido no encontrado: " .. category .. "." .. soundName)
        return nil
    end
end

--[[
    Función: Verificar si un sonido existe
    Parámetros:
        category - Categoría del sonido
        soundName - Nombre del sonido
    Retorna: true si existe, false si no
--]]
function SoundManager.SoundExists(category, soundName)
    return SoundManager.Sounds[category] and SoundManager.Sounds[category][soundName] ~= nil
end

return SoundManager
