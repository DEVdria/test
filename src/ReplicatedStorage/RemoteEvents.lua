--[[
	REMOTE EVENTS - CONFIGURACIÓN
	Este script crea todos los RemoteEvents necesarios para la comunicación
	entre el servidor y los clientes.

	IMPORTANTE: Este script debe ejecutarse en ReplicatedStorage como un Script
	(no LocalScript) para que el servidor lo ejecute primero.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta para los RemoteEvents
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "RemoteEvents"
remoteFolder.Parent = ReplicatedStorage

-- ============================================================================
-- CREAR REMOTE EVENTS
-- ============================================================================

-- Cliente → Servidor: El jugador envía un intento de adivinanza
local submitGuess = Instance.new("RemoteEvent")
submitGuess.Name = "SubmitGuess"
submitGuess.Parent = remoteFolder

-- Servidor → Cliente: El servidor responde con el resultado del intento
local guessResult = Instance.new("RemoteEvent")
guessResult.Name = "GuessResult"
guessResult.Parent = remoteFolder

-- Servidor → Cliente: Actualiza información del turno actual
local turnUpdate = Instance.new("RemoteEvent")
turnUpdate.Name = "TurnUpdate"
turnUpdate.Parent = remoteFolder

-- Servidor → Cliente: Envía mensajes generales del estado del juego
local gameState = Instance.new("RemoteEvent")
gameState.Name = "GameState"
gameState.Parent = remoteFolder

print("✓ RemoteEvents creados exitosamente")
