--[[
	SCRIPT DE DIAGNÓSTICO
	Ejecuta este script TEMPORALMENTE para ver qué está pasando

	INSTALACIÓN:
	1. Reemplaza temporalmente tu LocalScript con este código
	2. Presiona Play
	3. Presiona F9 para ver la consola
	4. Camina sobre los paneles
	5. Copia toda la información de la consola y envíamela
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("═════════════════════════════════════════════")
print("DIAGNÓSTICO DEL SISTEMA DE PANELES")
print("═════════════════════════════════════════════")

-- Esperar al personaje
local character = player.Character or player.CharacterAdded:Wait()
print("✅ Personaje encontrado")

local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
print("✅ HumanoidRootPart encontrado")

-- Buscar el folder
local folder = workspace:WaitForChild("TimedGlassRow", 10)
if not folder then
	warn("❌ No se encontró TimedGlassRow")
	return
end
print("✅ Folder encontrado")

-- Esperar a que se carguen los paneles
task.wait(1)

-- Buscar todos los paneles
local panels = {}
for _, child in ipairs(folder:GetChildren()) do
	if child:IsA("BasePart") and string.match(child.Name, "TimedPanel%d+") then
		table.insert(panels, child)
	end
end

-- Ordenar por número
table.sort(panels, function(a, b)
	local numA = tonumber(string.match(a.Name, "%d+"))
	local numB = tonumber(string.match(b.Name, "%d+"))
	return numA < numB
end)

print("\n📊 PANELES ENCONTRADOS:", #panels)
for i, panel in ipairs(panels) do
	print(string.format("  %d. %s - Posición: %s", i, panel.Name, tostring(panel.Position)))
end

-- Tabla para rastrear qué paneles han sido pisados
local panelsTouched = {}
for _, panel in ipairs(panels) do
	panelsTouched[panel] = false
end

-- Función de detección
local function isPlayerOnPanel(panel)
	if not humanoidRootPart then return false end

	local panelX = panel.Position.X
	local panelZ = panel.Position.Z
	local panelSizeX = panel.Size.X / 2
	local panelSizeZ = panel.Size.Z / 2

	local playerX = humanoidRootPart.Position.X
	local playerZ = humanoidRootPart.Position.Z

	local inXRange = playerX >= (panelX - panelSizeX) and playerX <= (panelX + panelSizeX)
	local inZRange = playerZ >= (panelZ - panelSizeZ) and playerZ <= (panelZ + panelSizeZ)

	if not (inXRange and inZRange) then
		return false
	end

	local panelTop = panel.Position.Y + (panel.Size.Y / 2)
	local playerPos = humanoidRootPart.Position.Y
	local heightDiff = playerPos - panelTop

	if heightDiff >= -1 and heightDiff <= 4 then
		return true
	end

	return false
end

print("\n🔄 Iniciando monitoreo...")
print("Camina sobre los paneles y observa los mensajes\n")

-- Contador de checks
local checkCount = 0
local lastReportTime = tick()

-- Loop de detección
RunService.Heartbeat:Connect(function()
	if not character or not character.Parent then
		character = player.Character
		if character then
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		end
		return
	end

	checkCount = checkCount + 1

	-- Reportar cada 5 segundos
	if tick() - lastReportTime > 5 then
		print(string.format("\n⏱️ Sistema funcionando - Checks realizados: %d", checkCount))

		-- Contar cuántos paneles han sido tocados
		local touchedCount = 0
		for _, touched in pairs(panelsTouched) do
			if touched then touchedCount = touchedCount + 1 end
		end
		print(string.format("👟 Paneles pisados hasta ahora: %d de %d", touchedCount, #panels))

		lastReportTime = tick()
	end

	-- Verificar cada panel
	for i, panel in ipairs(panels) do
		if panel and panel.Parent then
			local isOn = isPlayerOnPanel(panel)

			if isOn and not panelsTouched[panel] then
				panelsTouched[panel] = true

				local panelNum = tonumber(string.match(panel.Name, "%d+"))

				print(string.format(
					"\n✅ PANEL %d DETECTADO (%s)",
					panelNum,
					panel.Name
				))
				print(string.format("   Posición panel: %s", tostring(panel.Position)))
				print(string.format("   Posición jugador: %s", tostring(humanoidRootPart.Position)))
				print(string.format("   Índice en lista: %d de %d", i, #panels))
			end
		else
			-- Panel no existe o fue eliminado
			if not panel then
				print(string.format("⚠️ Panel en índice %d es nil", i))
			elseif not panel.Parent then
				print(string.format("⚠️ Panel %s no tiene Parent", panel.Name))
			end
		end
	end
end)

print("\n═════════════════════════════════════════════")
print("DIAGNÓSTICO ACTIVO - Observa la consola")
print("═════════════════════════════════════════════")
