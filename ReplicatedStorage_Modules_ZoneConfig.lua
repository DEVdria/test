-- ReplicatedStorage > Modules > ZoneConfig
-- Configuración de zonas con compra

local ZoneConfig = {}

-- ==================== CONFIGURACIÓN DE ZONAS ====================
-- Cada zona tiene un precio y requisitos para desbloquear
ZoneConfig.Zones = {
	{
		ID = "Zone1",                        -- ID único de la zona (debe coincidir con el nombre del Part)
		Name = "Zona Inicial",               -- Nombre mostrado en la GUI
		Price = 0,                           -- Precio para desbloquear ($0 = gratis)
		RequiredRebirths = 0,                -- Rebirths necesarios para comprar
		RequiredLevel = 0,                   -- Nivel necesario para comprar
		IsDefault = true,                    -- Si es true, se desbloquea automáticamente al inicio
	},
	{
		ID = "Zone2",
		Name = "Zona Avanzada",
		Price = 5000,                        -- Cuesta $5,000
		RequiredRebirths = 0,                -- No necesita rebirths
		RequiredLevel = 5,                   -- Necesita nivel 5
		IsDefault = false,
	},
	-- AÑADE MÁS ZONAS AQUÍ:
	-- {
	--     ID = "Zone3",
	--     Name = "Zona Experta",
	--     Price = 15000,
	--     RequiredRebirths = 1,
	--     RequiredLevel = 10,
	--     IsDefault = false,
	-- },
	-- {
	--     ID = "Zone4",
	--     Name = "Zona Élite",
	--     Price = 50000,
	--     RequiredRebirths = 2,
	--     RequiredLevel = 20,
	--     IsDefault = false,
	-- },
}

-- ==================== FUNCIONES ÚTILES ====================

-- Obtiene la configuración de una zona por ID
function ZoneConfig.GetZone(zoneID)
	for _, zone in ipairs(ZoneConfig.Zones) do
		if zone.ID == zoneID then
			return zone
		end
	end
	return nil
end

-- Verifica si un zoneID es válido
function ZoneConfig.IsValidZone(zoneID)
	return ZoneConfig.GetZone(zoneID) ~= nil
end

-- Obtiene todas las zonas por defecto (gratis)
function ZoneConfig.GetDefaultZones()
	local defaults = {}
	for _, zone in ipairs(ZoneConfig.Zones) do
		if zone.IsDefault then
			table.insert(defaults, zone.ID)
		end
	end
	return defaults
end

-- Verifica si un jugador cumple los requisitos para comprar una zona
function ZoneConfig.CanPurchaseZone(zoneID, money, rebirths, level)
	local zone = ZoneConfig.GetZone(zoneID)
	if not zone then
		return false, "Zona no encontrada"
	end

	-- Verificar requisitos
	if money < zone.Price then
		return false, string.format("Necesitas $%d", zone.Price - money)
	end

	if rebirths < zone.RequiredRebirths then
		return false, string.format("Necesitas %d rebirths", zone.RequiredRebirths)
	end

	if level < zone.RequiredLevel then
		return false, string.format("Necesitas nivel %d", zone.RequiredLevel)
	end

	return true, "Puede comprar"
end

-- Ordena las zonas por orden de dificultad (precio)
function ZoneConfig.GetZonesSorted()
	local sorted = {}
	for _, zone in ipairs(ZoneConfig.Zones) do
		table.insert(sorted, zone)
	end

	table.sort(sorted, function(a, b)
		return a.Price < b.Price
	end)

	return sorted
end

return ZoneConfig
