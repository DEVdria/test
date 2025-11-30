--[[
	EJEMPLO: SCRIPT PARA GUI DE INVENTARIO DE MASCOTAS

	Coloca este LocalScript dentro de tu GUI de inventario.

	Estructura esperada de la GUI:
	ScreenGui/
	  └── InventoryFrame (Frame)
	      ├── ScrollingFrame (ScrollingFrame)
	      ├── Template (Frame) -- Template oculto para cada mascota
	      │   ├── ViewportFrame (ViewportFrame)
	      │   ├── PetName (TextLabel)
	      │   ├── Rarity (TextLabel)
	      │   ├── Multiplier (TextLabel)
	      │   ├── EquipButton (TextButton)
	      │   └── EquippedIcon (ImageLabel)  -- Icono de "equipado"
	      ├── RefreshButton (TextButton)
	      └── CloseButton (TextButton)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ViewportUtil = require(ReplicatedStorage:WaitForChild("ViewportUtil"))
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

-- RemoteEvents
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local EquipPetRemote = RemoteEventsFolder:WaitForChild("EquipPet")
local UnequipPetRemote = RemoteEventsFolder:WaitForChild("UnequipPet")
local GetInventoryFunction = RemoteEventsFolder:WaitForChild("GetInventory")

local player = Players.LocalPlayer

-- Referencias a la GUI
local gui = script.Parent
local scrollingFrame = gui:WaitForChild("ScrollingFrame")
local template = gui:WaitForChild("Template")
local refreshButton = gui:WaitForChild("RefreshButton")
local closeButton = gui:WaitForChild("CloseButton")

-- Tabla de ViewportData para cleanup
local viewportDataList = {}

-- ============================================
-- FUNCIÓN: LIMPIAR INVENTARIO
-- ============================================
local function clearInventory()
	-- Limpiar viewports
	for _, viewportData in ipairs(viewportDataList) do
		ViewportUtil.CleanupViewport(viewportData)
	end
	viewportDataList = {}

	-- Limpiar frames
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") and child ~= template then
			child:Destroy()
		end
	end
end

-- ============================================
-- FUNCIÓN: ACTUALIZAR INVENTARIO
-- ============================================
local function updateInventory()
	-- Limpiar inventario actual
	clearInventory()

	-- Obtener inventario del servidor
	local inventory = GetInventoryFunction:InvokeServer()

	if not inventory or not inventory.Pets then
		warn("[Inventory] No se pudo obtener el inventario")
		return
	end

	local pets = inventory.Pets

	-- Ordenar por rareza (opcional)
	local rarityOrder = {
		Legendary = 5,
		Epic = 4,
		Rare = 3,
		Uncommon = 2,
		Common = 1
	}

	table.sort(pets, function(a, b)
		local orderA = rarityOrder[a.Rarity] or 0
		local orderB = rarityOrder[b.Rarity] or 0
		return orderA > orderB
	end)

	-- Crear frames para cada mascota
	for i, pet in ipairs(pets) do
		local petFrame = template:Clone()
		petFrame.Name = "Pet_" .. pet.UniqueID
		petFrame.Visible = true
		petFrame.Parent = scrollingFrame

		-- Posicionar (layout manual o usar UIGridLayout)
		-- Ejemplo con posición manual:
		local col = (i - 1) % 3
		local row = math.floor((i - 1) / 3)
		petFrame.Position = UDim2.new(0, col * 150, 0, row * 180)

		-- Mostrar modelo 3D
		local viewportData = ViewportUtil.ShowPetInViewport(
			petFrame.ViewportFrame,
			pet.Name,
			true,  -- Auto-rotar
			0.5    -- Velocidad más lenta
		)
		table.insert(viewportDataList, viewportData)

		-- Actualizar labels
		petFrame.PetName.Text = pet.Name
		petFrame.Rarity.Text = pet.Rarity
		petFrame.Multiplier.Text = "x" .. pet.xpMultiplier

		-- Color de rareza
		local rarityConfig = PetConfig.Rarities[pet.Rarity]
		if rarityConfig then
			petFrame.Rarity.TextColor3 = rarityConfig.Color
		end

		-- Botón equipar/desequipar
		local equipButton = petFrame.EquipButton
		local equippedIcon = petFrame.EquippedIcon

		if pet.Equipped then
			equipButton.Text = "Desequipar"
			equipButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			equippedIcon.Visible = true
		else
			equipButton.Text = "Equipar"
			equipButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
			equippedIcon.Visible = false
		end

		-- Evento del botón
		equipButton.MouseButton1Click:Connect(function()
			if pet.Equipped then
				UnequipPetRemote:FireServer(pet.UniqueID)
			else
				EquipPetRemote:FireServer(pet.UniqueID)
			end

			-- Esperar y refrescar
			task.wait(0.5)
			updateInventory()
		end)
	end

	-- Ajustar tamaño del ScrollingFrame
	local rows = math.ceil(#pets / 3)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 180)

	print("[Inventory] Inventario actualizado: " .. #pets .. " mascotas")
end

-- ============================================
-- BOTÓN: REFRESCAR
-- ============================================
refreshButton.MouseButton1Click:Connect(function()
	updateInventory()
end)

-- ============================================
-- BOTÓN: CERRAR
-- ============================================
closeButton.MouseButton1Click:Connect(function()
	gui.Visible = false
	clearInventory()
end)

-- ============================================
-- ABRIR INVENTARIO
-- ============================================
gui:GetPropertyChangedSignal("Visible"):Connect(function()
	if gui.Visible then
		updateInventory()
	else
		clearInventory()
	end
end)

-- Actualizar al inicio si está visible
if gui.Visible then
	updateInventory()
end

print("[Inventory] Sistema de inventario cargado ✓")
