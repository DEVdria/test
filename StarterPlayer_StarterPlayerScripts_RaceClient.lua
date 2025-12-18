-- StarterPlayer > StarterPlayerScripts > RaceClient (LocalScript)
-- Cliente del sistema de carreras
-- TÚ DISEÑAS LA GUI, este script solo la gestiona

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar módulos
local Modules = ReplicatedStorage:WaitForChild("Modules")
local RaceConfig = require(Modules:WaitForChild("RaceConfig"))

-- Esperar RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RaceWarningEvent = RemoteEvents:WaitForChild("RaceWarning")
local RaceStartEvent = RemoteEvents:WaitForChild("RaceStart")
local JoinRaceEvent = RemoteEvents:WaitForChild("JoinRace")
local RaceEndEvent = RemoteEvents:WaitForChild("RaceEnd")
local RaceCountdownEvent = RemoteEvents:WaitForChild("RaceCountdown")

-- ==================== BUSCAR GUI DISEÑADA POR EL USUARIO ====================

local playerGui = player:WaitForChild("PlayerGui")

-- GUI de aviso de carrera (FASE 1)
local raceWarningGui = playerGui:WaitForChild("RaceWarningGui", 10)
if not raceWarningGui then
	warn("[RaceClient] ❌ No se encontró RaceWarningGui")
	warn("[RaceClient] 📘 Crea un ScreenGui llamado 'RaceWarningGui' en StarterGui")
	return
end

local warningFrame = raceWarningGui:WaitForChild("WarningFrame", 5)
if not warningFrame then
	warn("[RaceClient] ❌ No se encontró WarningFrame")
	return
end

-- Elementos del aviso
local warningLabel = warningFrame:FindFirstChild("WarningLabel", true) or warningFrame:FindFirstChild("MessageLabel", true)
local warningCountdown = warningFrame:FindFirstChild("Countdown", true) or warningFrame:FindFirstChild("CountdownLabel", true)

-- GUI de decisión (FASE 2)
local raceDecisionGui = playerGui:WaitForChild("RaceDecisionGui", 10)
if not raceDecisionGui then
	warn("[RaceClient] ❌ No se encontró RaceDecisionGui")
	warn("[RaceClient] 📘 Crea un ScreenGui llamado 'RaceDecisionGui' en StarterGui")
	return
end

local decisionFrame = raceDecisionGui:WaitForChild("DecisionFrame", 5)
if not decisionFrame then
	warn("[RaceClient] ❌ No se encontró DecisionFrame")
	return
end

-- Elementos de decisión
local decisionLabel = decisionFrame:FindFirstChild("MessageLabel", true) or decisionFrame:FindFirstChild("TitleLabel", true)
local joinButton = decisionFrame:FindFirstChild("JoinButton", true) or decisionFrame:FindFirstChild("EnterButton", true)
local ignoreButton = decisionFrame:FindFirstChild("IgnoreButton", true) or decisionFrame:FindFirstChild("CancelButton", true)

-- GUI de cuenta regresiva en zona de espera (FASE 3)
local raceWaitGui = playerGui:FindFirstChild("RaceWaitGui")
local waitCountdownLabel = nil

if raceWaitGui then
	local waitFrame = raceWaitGui:FindFirstChild("WaitFrame", true)
	if waitFrame then
		waitCountdownLabel = waitFrame:FindFirstChild("CountdownLabel", true) or waitFrame:FindFirstChild("Countdown", true)
	end
end

-- GUI de resultados y podio (FINAL)
local raceResultsGui = playerGui:WaitForChild("RaceResultsGui", 10)
if not raceResultsGui then
	warn("[RaceClient] ❌ No se encontró RaceResultsGui")
	warn("[RaceClient] 📘 Crea un ScreenGui llamado 'RaceResultsGui' en StarterGui")
	return
end

local resultsFrame = raceResultsGui:WaitForChild("ResultsFrame", 5)
if not resultsFrame then
	warn("[RaceClient] ❌ No se encontró ResultsFrame")
	return
end

-- Elementos del podio
local firstPlaceLabel = resultsFrame:FindFirstChild("FirstPlace", true) or resultsFrame:FindFirstChild("Place1", true)
local secondPlaceLabel = resultsFrame:FindFirstChild("SecondPlace", true) or resultsFrame:FindFirstChild("Place2", true)
local thirdPlaceLabel = resultsFrame:FindFirstChild("ThirdPlace", true) or resultsFrame:FindFirstChild("Place3", true)

-- ImageLabels para mostrar iconos de jugadores (opcional)
local firstIcon = resultsFrame:FindFirstChild("FirstIcon", true)
local secondIcon = resultsFrame:FindFirstChild("SecondIcon", true)
local thirdIcon = resultsFrame:FindFirstChild("ThirdIcon", true)

-- Ocultar todas las GUIs al inicio
raceWarningGui.Enabled = false
raceDecisionGui.Enabled = false
if raceWaitGui then raceWaitGui.Enabled = false end
raceResultsGui.Enabled = false

-- ==================== VARIABLES ====================

local isParticipating = false

-- ==================== FUNCIONES ====================

-- Muestra el aviso de carrera (FASE 1)
local function showWarning(message, countdown)
	if warningLabel then
		warningLabel.Text = message
	end

	if warningCountdown then
		warningCountdown.Text = tostring(countdown)
	end

	raceWarningGui.Enabled = true
end

-- Oculta el aviso de carrera
local function hideWarning()
	raceWarningGui.Enabled = false
end

-- Muestra la GUI de decisión (FASE 2)
local function showDecision()
	if decisionLabel then
		decisionLabel.Text = RaceConfig.Messages.RaceStarted
	end

	raceDecisionGui.Enabled = true
end

-- Oculta la GUI de decisión
local function hideDecision()
	raceDecisionGui.Enabled = false
end

-- Muestra la cuenta regresiva en zona de espera (FASE 3)
local function showWaitCountdown(message, countdown)
	if raceWaitGui then
		raceWaitGui.Enabled = true

		if waitCountdownLabel then
			if countdown > 0 then
				waitCountdownLabel.Text = message
			else
				waitCountdownLabel.Text = message  -- "¡CARRERA INICIADA!"
			end
		end
	end
end

-- Oculta la GUI de espera
local function hideWaitCountdown()
	if raceWaitGui then
		raceWaitGui.Enabled = false
	end
end

-- Establece el thumbnail del jugador en un ImageLabel
local function setPlayerThumbnail(imageLabel, userId)
	if not imageLabel or not imageLabel:IsA("ImageLabel") then return end

	-- Obtener el thumbnail del jugador de forma asíncrona
	task.spawn(function()
		local success, thumbnailUrl = pcall(function()
			return Players:GetUserThumbnailAsync(
				userId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)

		if success and thumbnailUrl then
			imageLabel.Image = thumbnailUrl
			print(string.format("[RaceClient] ✅ Thumbnail cargado para UserId: %d", userId))
		else
			warn(string.format("[RaceClient] ⚠️ No se pudo cargar thumbnail para UserId: %d", userId))
			-- Dejar la imagen por defecto o vacía
		end
	end)
end

-- Muestra los resultados del podio (FINAL)
local function showResults(results)
	-- Actualizar labels de nombres e iconos
	if results.First and firstPlaceLabel then
		firstPlaceLabel.Text = "🥇 " .. results.First.Name
		if firstIcon then
			setPlayerThumbnail(firstIcon, results.First.UserId)
		end
	end

	if results.Second and secondPlaceLabel then
		secondPlaceLabel.Text = "🥈 " .. results.Second.Name
		if secondIcon then
			setPlayerThumbnail(secondIcon, results.Second.UserId)
		end
	end

	if results.Third and thirdPlaceLabel then
		thirdPlaceLabel.Text = "🥉 " .. results.Third.Name
		if thirdIcon then
			setPlayerThumbnail(thirdIcon, results.Third.UserId)
		end
	end

	raceResultsGui.Enabled = true
end

-- Oculta los resultados
local function hideResults()
	raceResultsGui.Enabled = false
end

-- Intenta unirse a la carrera
local function joinRace()
	print("[RaceClient] 🏃 Intentando unirse a la carrera...")

	isParticipating = true
	hideDecision()

	-- Enviar solicitud al servidor
	JoinRaceEvent:FireServer()
end

-- ==================== EVENTOS ====================

-- Evento de aviso (FASE 1 - 10 segundos antes)
RaceWarningEvent.OnClientEvent:Connect(function(message, countdown)
	showWarning(message, countdown)

	if countdown == 1 then
		-- Ocultar aviso justo antes de que empiece
		task.wait(1)
		hideWarning()
	end
end)

-- Evento de inicio de carrera (FASE 2 - mostrar botones)
RaceStartEvent.OnClientEvent:Connect(function()
	print("[RaceClient] 📢 Carrera iniciada - mostrando opciones")

	if not isParticipating then
		showDecision()

		-- Ocultar automáticamente después del tiempo de decisión
		task.delay(RaceConfig.DECISION_TIME, function()
			if not isParticipating then
				hideDecision()
				print("[RaceClient] ⏰ Tiempo de decisión agotado")
			end
		end)
	end
end)

-- Evento de cuenta regresiva en zona de espera (FASE 3)
RaceCountdownEvent.OnClientEvent:Connect(function(message, countdown)
	if isParticipating then
		showWaitCountdown(message, countdown)

		if countdown == 0 then
			-- Ocultar countdown cuando empiece la carrera
			task.wait(2)
			hideWaitCountdown()
		end
	end
end)

-- Evento de fin de carrera (FINAL - mostrar podio)
RaceEndEvent.OnClientEvent:Connect(function(results)
	print("[RaceClient] 🏁 Carrera terminada")

	-- Ocultar GUIs de carrera
	hideDecision()
	hideWaitCountdown()

	if results.Cancelled then
		-- Carrera cancelada
		print("[RaceClient] ❌ Carrera cancelada:", results.Reason)
	else
		-- Mostrar resultados
		showResults(results)

		-- Ocultar resultados después de 10 segundos
		task.wait(10)
		hideResults()
	end

	isParticipating = false
end)

-- Respuesta del servidor al intentar unirse
JoinRaceEvent.OnClientEvent:Connect(function(result)
	if result.Success then
		print("[RaceClient] ✅ Te uniste a la carrera exitosamente")
	else
		print("[RaceClient] ❌ No se pudo unir:", result.Message)
		isParticipating = false
	end
end)

-- Botón de unirse
if joinButton then
	joinButton.MouseButton1Click:Connect(function()
		joinRace()
	end)
end

-- Botón de ignorar
if ignoreButton then
	ignoreButton.MouseButton1Click:Connect(function()
		hideDecision()
		print("[RaceClient] ❌ Carrera ignorada")
	end)
end

print("[RaceClient] ✅ Sistema de carreras del cliente iniciado")

-- ==================== NOTAS DE USO ====================
--[[
	ESTRUCTURA REQUERIDA:

	StarterGui
	├─ RaceWarningGui (ScreenGui) ← FASE 1: Aviso
	│  └─ WarningFrame (Frame)
	│     ├─ WarningLabel (TextLabel) - Mensaje de aviso
	│     └─ Countdown (TextLabel) - Cuenta regresiva
	│
	├─ RaceDecisionGui (ScreenGui) ← FASE 2: Decisión
	│  └─ DecisionFrame (Frame)
	│     ├─ MessageLabel (TextLabel) - "Ha iniciado una carrera"
	│     ├─ JoinButton (TextButton) - Botón "Entrar"
	│     └─ IgnoreButton (TextButton) - Botón "Ignorar"
	│
	├─ RaceWaitGui (ScreenGui) [OPCIONAL] ← FASE 3: Espera
	│  └─ WaitFrame (Frame)
	│     └─ CountdownLabel (TextLabel) - Cuenta regresiva de 15s
	│
	└─ RaceResultsGui (ScreenGui) ← FINAL: Resultados
	   └─ ResultsFrame (Frame)
	      ├─ FirstPlace (TextLabel) - Nombre del 1er lugar
	      ├─ SecondPlace (TextLabel) - Nombre del 2do lugar
	      ├─ ThirdPlace (TextLabel) - Nombre del 3er lugar
	      ├─ FirstIcon (ImageLabel) [OPCIONAL] - Thumbnail del 1er lugar
	      ├─ SecondIcon (ImageLabel) [OPCIONAL] - Thumbnail del 2do lugar
	      └─ ThirdIcon (ImageLabel) [OPCIONAL] - Thumbnail del 3er lugar

	NOMBRES ALTERNATIVOS ACEPTADOS:
	- WarningLabel o MessageLabel
	- Countdown o CountdownLabel
	- JoinButton o EnterButton
	- IgnoreButton o CancelButton
	- FirstPlace o Place1
	- SecondPlace o Place2
	- ThirdPlace o Place3

	FUNCIONAMIENTO:
	1. FASE 1 (10s antes): Muestra RaceWarningGui con cuenta regresiva
	2. FASE 2 (al llegar a 0): Muestra RaceDecisionGui con botones Entrar/Ignorar
	3. FASE 3 (si entras): Te teletransporta y muestra RaceWaitGui con cuenta regresiva de 15s
	4. FASE 4 (carrera): La barrera se desactiva y empieza la carrera
	5. FINAL: Muestra RaceResultsGui con el podio top 3
	6. Todos son teletransportados a (0,2,0)

	OBJETOS NECESARIOS EN WORKSPACE (los creas tú):
	- WaitZone (Part) - Zona de espera donde se teletransportan
	- RaceBarrier (Part) - Barrera invisible que bloquea el inicio
	  * CanCollide = true durante la cuenta regresiva
	  * CanCollide = false cuando empieza la carrera
	- RaceFinish (Part) - Meta que detecta cuando los jugadores terminan
]]
