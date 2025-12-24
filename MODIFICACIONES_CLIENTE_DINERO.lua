--[[
	═══════════════════════════════════════════════════════════
	MODIFICACIONES PARA EL CLIENTE - SISTEMA DE DINERO
	═══════════════════════════════════════════════════════════

	INSTRUCCIONES:
	1. Abre tu archivo MultiLevelGlassPanelClient.lua existente
	2. Busca las secciones indicadas abajo
	3. Agrega el código correspondiente en cada sección

	═══════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- SECCIÓN 1: AL INICIO DEL SCRIPT (después de las importaciones)
-- Busca donde dices: local CONFIG = {
-- ANTES de CONFIG, agrega:
-- ═══════════════════════════════════════════════════════════

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent para dar dinero
local givePanelMoneyEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if remoteEventsFolder then
	givePanelMoneyEvent = remoteEventsFolder:WaitForChild("GivePanelMoney", 10)
	if givePanelMoneyEvent then
		print("✅ RemoteEvent 'GivePanelMoney' encontrado")
	else
		warn("⚠️ No se encontró RemoteEvent 'GivePanelMoney'")
	end
else
	warn("⚠️ No se encontró carpeta RemoteEvents")
end


-- ═══════════════════════════════════════════════════════════
-- SECCIÓN 2: EN LA FUNCIÓN activatePanel()
-- Busca donde dice: data.isActive = true
-- DESPUÉS de data.startTime = tick(), agrega:
-- ═══════════════════════════════════════════════════════════

-- Ejemplo de cómo se ve la función completa:
--[[
local function activatePanel(panel, panelNumber, levelName, fallTime)
	local data = panelData[panel]

	if data.isActive then
		return
	end

	-- Marcar como activo
	data.isActive = true
	data.startTime = tick()

	-- ═══════════════════════════════════════════════════════════
	-- 💰 NUEVO: DAR DINERO AL PISAR EL PANEL
	-- ═══════════════════════════════════════════════════════════
	if givePanelMoneyEvent and panel then
		local moneyReward = panel:GetAttribute("MoneyReward")
		if moneyReward and moneyReward > 0 then
			-- Disparar evento al servidor para dar dinero
			local success = pcall(function()
				givePanelMoneyEvent:FireServer(panel)
			end)

			if success then
				print(string.format("💰 %s - PANEL %d: Solicitando %d de dinero",
					levelName, panelNumber, moneyReward))
			else
				warn(string.format("⚠️ Error al solicitar dinero para panel %d", panelNumber))
			end
		end
	end
	-- ═══════════════════════════════════════════════════════════

	-- Si es el ÚLTIMO panel del nivel, ocultar Progress Bar (meta alcanzada)
	if data.isLastPanel then
		print(string.format("🏁 %s - ¡META ALCANZADA! (Panel %d) - Ocultando Progress Bar", levelName, panelNumber))
		hideProgressBar()
	end

	-- ... resto del código de activatePanel (sonido, print, etc.)
end
]]


-- ═══════════════════════════════════════════════════════════
-- RESUMEN DE CAMBIOS
-- ═══════════════════════════════════════════════════════════

--[[
	CAMBIOS QUE NECESITAS HACER:

	1. Al inicio del archivo:
	   ✅ Agregar: local ReplicatedStorage = game:GetService("ReplicatedStorage")
	   ✅ Agregar el código para obtener givePanelMoneyEvent

	2. En activatePanel():
	   ✅ Después de data.startTime = tick()
	   ✅ Agregar el bloque de código que dice "💰 NUEVO: DAR DINERO"

	Eso es todo. El resto del cliente se queda igual.

	═══════════════════════════════════════════════════════════
	VERIFICACIÓN
	═══════════════════════════════════════════════════════════

	Cuando ejecutes el juego, deberías ver en el output:

	✅ RemoteEvent 'GivePanelMoney' encontrado
	💰 Level1 - PANEL 1: Solicitando 1 de dinero
	💰 Level1 - PANEL 2: Solicitando 1 de dinero

	Y en el servidor:
	[GlassPanelMoneyHandler] 💰 PlayerName recibió 1 de dinero (Level1 - Panel1)

	═══════════════════════════════════════════════════════════
]]
