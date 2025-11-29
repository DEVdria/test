-- ServerScriptService > AutoConfigureZones
-- Script que configura automáticamente las zonas con sus atributos
-- Este script se ejecuta automáticamente al iniciar el juego

local Workspace = game:GetService("Workspace")

-- Esperar a que el workspace esté listo
task.wait(1)

-- Buscar o crear carpeta de zonas
local zonesFolder = Workspace:FindFirstChild("Zones")
if not zonesFolder then
    zonesFolder = Instance.new("Folder")
    zonesFolder.Name = "Zones"
    zonesFolder.Parent = Workspace
    print("[AutoConfig] Carpeta Zones creada")
end

-- Configuración de zonas
local zoneConfigs = {
    {
        Name = "Zone1",
        Position = Vector3.new(0, 10, 0),
        Size = Vector3.new(50, 1, 50),
        OrbTypes = "Yellow,Green",
        MaxOrbs = 15,
        SpawnHeight = 10
    },
    {
        Name = "Zone2",
        Position = Vector3.new(100, 10, 0),
        Size = Vector3.new(50, 1, 50),
        OrbTypes = "Green,Blue",
        MaxOrbs = 12,
        SpawnHeight = 10
    }
}

-- Crear y configurar cada zona
for _, config in ipairs(zoneConfigs) do
    local zone = zonesFolder:FindFirstChild(config.Name)

    -- Crear zona si no existe
    if not zone then
        zone = Instance.new("Part")
        zone.Name = config.Name
        zone.Size = config.Size
        zone.Position = config.Position
        zone.Anchored = true
        zone.CanCollide = false
        zone.Transparency = 0.8
        zone.Color = Color3.fromRGB(100, 100, 255)
        zone.Material = Enum.Material.Neon
        zone.Parent = zonesFolder
        print(string.format("[AutoConfig] Zona %s creada", config.Name))
    end

    -- Configurar atributos (siempre, para asegurar que estén correctos)
    zone:SetAttribute("ZoneName", config.Name)
    zone:SetAttribute("OrbTypes", config.OrbTypes)
    zone:SetAttribute("MaxOrbs", config.MaxOrbs)
    zone:SetAttribute("SpawnHeight", config.SpawnHeight)

    print(string.format("[AutoConfig] ✅ %s configurada: Orbs=%s, Max=%d",
        config.Name, config.OrbTypes, config.MaxOrbs))
end

print("[AutoConfig] ✅ Todas las zonas configuradas correctamente")
