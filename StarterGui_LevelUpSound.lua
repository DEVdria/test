-- StarterGui > LevelUpSound
-- Reproduce un sonido cuando el jugador sube de nivel
-- INSTRUCCIONES:
-- 1. Pegar este script como LocalScript en StarterGui
-- 2. Crear un Sound dentro de este LocalScript llamado "LevelUpSound"
-- 3. Configurar el SoundId del Sound con el ID que quieras
-- 4. Ajustar Volume, Pitch, etc. según tus preferencias

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LevelUpEvent = RemoteEvents:WaitForChild("LevelUp", 10)

if not LevelUpEvent then
	warn("[LevelUpSound] ❌ No se encontró RemoteEvent 'LevelUp'")
	return
end

-- Buscar el Sound dentro del script
local levelUpSound = script:FindFirstChild("LevelUpSound")

if not levelUpSound then
	warn("[LevelUpSound] ⚠️ No se encontró Sound 'LevelUpSound' dentro del script")
	warn("[LevelUpSound] 📘 Crea un Sound llamado 'LevelUpSound' dentro de este LocalScript")
	warn("[LevelUpSound] 📘 Configura su SoundId con el sonido que quieras usar")
	return
end

-- Verificar que el sonido tenga un SoundId configurado
if levelUpSound.SoundId == "" then
	warn("[LevelUpSound] ⚠️ El Sound 'LevelUpSound' no tiene SoundId configurado")
	warn("[LevelUpSound] 📘 Configura la propiedad SoundId del Sound con un ID de Roblox")
	warn("[LevelUpSound] 📘 Ejemplo: rbxassetid://12345678")
	return
end

-- Escuchar cuando el jugador sube de nivel
LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
	-- Reproducir sonido
	if levelUpSound and not levelUpSound.IsPlaying then
		levelUpSound:Play()
		print(string.format("[LevelUpSound] 🔊 Sonido de nivel %d reproducido", newLevel))
	end
end)

print("[LevelUpSound] ✅ Sistema de sonido de subida de nivel inicializado")
print(string.format("[LevelUpSound] Sonido configurado: %s", levelUpSound.SoundId))
