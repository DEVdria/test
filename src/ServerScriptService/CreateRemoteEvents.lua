--[[
	CREATE REMOTE EVENTS - Script para crear los RemoteEvents necesarios

	Este script crea automáticamente todos los RemoteEvents necesarios
	para el sistema de mascotas.

	Ejecuta este script UNA VEZ para crear los eventos, luego puedes deshabilitarlo.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de RemoteEvents si no existe
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
	print("[Setup] Carpeta RemoteEvents creada")
end

-- Lista de RemoteEvents necesarios
local remoteEventNames = {
	"OpenEgg",           -- Cliente → Servidor: Abrir huevo
	"EquipPet",          -- Cliente → Servidor: Equipar mascota
	"UnequipPet",        -- Cliente → Servidor: Desequipar mascota
	"ShowPetReward",     -- Servidor → Cliente: Mostrar resultado de apertura
	"AutoOpenToggle",    -- Cliente → Servidor: Activar/desactivar auto-open
	"ShowEggUI",         -- Cliente → Servidor: Jugador entró en rango
	"HideEggUI",         -- Cliente → Servidor: Jugador salió del rango
}

-- Lista de RemoteFunctions necesarias
local remoteFunctionNames = {
	"GetInventory",      -- Cliente → Servidor: Obtener inventario de mascotas
}

-- Crear RemoteEvents
for _, eventName in ipairs(remoteEventNames) do
	if not remoteEventsFolder:FindFirstChild(eventName) then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = remoteEventsFolder
		print("[Setup] RemoteEvent creado: " .. eventName)
	else
		print("[Setup] RemoteEvent ya existe: " .. eventName)
	end
end

-- Crear RemoteFunctions
for _, functionName in ipairs(remoteFunctionNames) do
	if not remoteEventsFolder:FindFirstChild(functionName) then
		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = functionName
		remoteFunction.Parent = remoteEventsFolder
		print("[Setup] RemoteFunction creada: " .. functionName)
	else
		print("[Setup] RemoteFunction ya existe: " .. functionName)
	end
end

-- Crear carpeta para modelos de mascotas si no existe
local petsModelsFolder = ReplicatedStorage:FindFirstChild("PetsModels")
if not petsModelsFolder then
	petsModelsFolder = Instance.new("Folder")
	petsModelsFolder.Name = "PetsModels"
	petsModelsFolder.Parent = ReplicatedStorage
	print("[Setup] Carpeta PetsModels creada")
end

-- Crear carpeta de huevos en Workspace si no existe
local eggsFolder = workspace:FindFirstChild("Eggs")
if not eggsFolder then
	eggsFolder = Instance.new("Folder")
	eggsFolder.Name = "Eggs"
	eggsFolder.Parent = workspace
	print("[Setup] Carpeta Eggs creada en Workspace")
end

print("====================================")
print("[Setup] Sistema de mascotas configurado ✓")
print("====================================")
print("")
print("PRÓXIMOS PASOS:")
print("1. Añade tus modelos de mascotas a ReplicatedStorage.PetsModels")
print("2. Crea tus huevos en Workspace.Eggs")
print("3. Crea tus GUIs y conéctalas usando PetSystemClient como referencia")
print("4. Configura PetConfig.lua con tus mascotas y precios")
print("")
