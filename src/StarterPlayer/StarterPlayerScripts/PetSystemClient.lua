--[[
	PET SYSTEM CLIENT - LocalScript principal del cliente

	Este script es un EJEMPLO de cómo conectar tus GUIs con el sistema.
	Tú deberás crear tus propias GUIs y usar este código como referencia.

	RemoteEvents disponibles:
	- OpenEgg: Abrir huevo (enviar: eggType, openType)
	- EquipPet: Equipar mascota (enviar: petUniqueID)
	- UnequipPet: Desequipar mascota (enviar: petUniqueID)
	- ShowPetReward: Recibir resultado de apertura de huevo
	- AutoOpenToggle: Activar/desactivar auto-open (enviar: eggType, enabled)
	- ShowEggUI: El servidor te dice que muestres la GUI de un huevo
	- HideEggUI: El servidor te dice que ocultes la GUI del huevo
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Módulos
local ViewportUtil = require(ReplicatedStorage:WaitForChild("ViewportUtil"))
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

-- RemoteEvents
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local OpenEggRemote = RemoteEventsFolder:WaitForChild("OpenEgg")
local ShowPetRewardRemote = RemoteEventsFolder:WaitForChild("ShowPetReward")
local ShowEggUIRemote = RemoteEventsFolder:WaitForChild("ShowEggUI")
local HideEggUIRemote = RemoteEventsFolder:WaitForChild("HideEggUI")

local player = Players.LocalPlayer

-- ============================================
-- EJEMPLO: MOSTRAR GUI DEL HUEVO
-- ============================================
ShowEggUIRemote.OnClientEvent:Connect(function(eggType)
	print("[PetClient] Mostrar GUI del huevo: " .. eggType)

	--[[
		AQUÍ DEBES MOSTRAR TU GUI DEL HUEVO

		Ejemplo:
		local eggGui = player.PlayerGui.EggShop.EggFrame
		eggGui.Visible = true
		eggGui.EggName.Text = PetConfig.Eggs[eggType].DisplayName
		eggGui.Price.Text = PetConfig.Eggs[eggType].Price

		-- Botón de abrir 1
		eggGui.OpenButton.MouseButton1Click:Connect(function()
			OpenEggRemote:FireServer(eggType, "Single")
		end)

		-- Botón de abrir 3
		eggGui.Open3Button.MouseButton1Click:Connect(function()
			OpenEggRemote:FireServer(eggType, "Triple")
		end)
	--]]
end)

-- ============================================
-- EJEMPLO: OCULTAR GUI DEL HUEVO
-- ============================================
HideEggUIRemote.OnClientEvent:Connect(function()
	print("[PetClient] Ocultar GUI del huevo")

	--[[
		AQUÍ DEBES OCULTAR TU GUI DEL HUEVO

		Ejemplo:
		local eggGui = player.PlayerGui.EggShop.EggFrame
		eggGui.Visible = false
	--]]
end)

-- ============================================
-- EJEMPLO: RECIBIR RESULTADO DE APERTURA
-- ============================================
ShowPetRewardRemote.OnClientEvent:Connect(function(status, data)
	if status == "Success" then
		-- data = tabla de mascotas generadas
		print("[PetClient] Mascotas obtenidas:", #data)

		--[[
			AQUÍ DEBES MOSTRAR LA GUI DE RECOMPENSA

			Ejemplo con ViewportUtil:

			local rewardGui = player.PlayerGui.PetReward
			rewardGui.Visible = true

			-- Mostrar primera mascota en ViewportFrame
			local pet = data[1]
			local viewportFrame = rewardGui.ViewportFrame

			ViewportUtil.ShowPetInViewport(viewportFrame, pet.Name, true, 1)

			-- Mostrar info
			rewardGui.PetName.Text = pet.Name
			rewardGui.Rarity.Text = pet.Rarity
			rewardGui.Rarity.TextColor3 = PetConfig.Rarities[pet.Rarity].Color
		--]]

	elseif status == "NoGamepass" then
		print("[PetClient] No tienes el gamepass necesario")
		-- Mostrar mensaje de error

	elseif status == "NotEnoughMoney" then
		print("[PetClient] No tienes suficiente dinero. Necesitas:", data.Required)
		-- Mostrar mensaje de error

	elseif status == "AutoOpenStopped" then
		print("[PetClient] Auto-open detenido:", data.Reason)
		-- Actualizar GUI
	end
end)

-- ============================================
-- EJEMPLO: CÓMO USAR VIEWPORTUTIL EN TUS GUIS
-- ============================================
--[[
	-- En tu GUI de inventario, cuando quieras mostrar una mascota:

	local ViewportUtil = require(ReplicatedStorage.ViewportUtil)

	local viewportFrame = script.Parent.PetDisplay -- Tu ViewportFrame
	local petName = "Dog" -- Nombre de la mascota

	-- Mostrar mascota con rotación automática
	local viewportData = ViewportUtil.ShowPetInViewport(viewportFrame, petName, true, 1)

	-- Cuando quieras cambiar de mascota:
	ViewportUtil.CleanupViewport(viewportData)
	viewportData = ViewportUtil.ShowPetInViewport(viewportFrame, "Cat", true, 1)

	-- O usar UpdatePetInViewport (hace cleanup automático):
	ViewportUtil.UpdatePetInViewport(viewportFrame, "Cat", true, 1)
--]]

print("[PetClient] Sistema de mascotas cliente iniciado ✓")
