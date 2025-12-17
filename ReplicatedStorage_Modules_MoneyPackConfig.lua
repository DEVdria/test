--[[
	MONEY PACK CONFIG
	Configuración de los packs de dinero disponibles en la tienda.

	Cada pack tiene:
	- ID: Identificador único
	- Name: Nombre del pack
	- MoneyAmount: Cantidad de dinero que otorga
	- Price: Precio en Robux
	- ProductID: ID del Dev Product de Roblox
	- Icon: Imagen del pack (opcional)
]]

local MoneyPackConfig = {}

-- ========================================
-- CONFIGURACIÓN DE PACKS DE DINERO
-- ========================================

MoneyPackConfig.Packs = {
	-- Pack 1: Starter Pack
	{
		ID = 1,
		Name = "Starter Pack",
		MoneyAmount = 1000,
		Price = 25,
		ProductID = 0,  -- REEMPLAZAR con tu Dev Product ID real
		Icon = "rbxassetid://0",  -- Opcional: ID de imagen
		Description = "Un pequeño impulso para comenzar"
	},

	-- Pack 2: Basic Pack
	{
		ID = 2,
		Name = "Basic Pack",
		MoneyAmount = 5000,
		Price = 99,
		ProductID = 0,  -- REEMPLAZAR con tu Dev Product ID real
		Icon = "rbxassetid://0",
		Description = "Pack básico de dinero"
	},

	-- Pack 3: Premium Pack
	{
		ID = 3,
		Name = "Premium Pack",
		MoneyAmount = 15000,
		Price = 249,
		ProductID = 0,  -- REEMPLAZAR con tu Dev Product ID real
		Icon = "rbxassetid://0",
		Description = "Para jugadores serios"
	},

	-- Pack 4: Mega Pack
	{
		ID = 4,
		Name = "Mega Pack",
		MoneyAmount = 50000,
		Price = 699,
		ProductID = 0,  -- REEMPLAZAR con tu Dev Product ID real
		Icon = "rbxassetid://0",
		Description = "¡Una fortuna instantánea!"
	},

	-- Pack 5: Ultra Pack
	{
		ID = 5,
		Name = "Ultra Pack",
		MoneyAmount = 150000,
		Price = 1499,
		ProductID = 0,  -- REEMPLAZAR con tu Dev Product ID real
		Icon = "rbxassetid://0",
		Description = "El pack definitivo"
	},
}

-- ========================================
-- FUNCIONES AUXILIARES
-- ========================================

-- Obtiene un pack por su ID
function MoneyPackConfig.GetPackByID(packID)
	for _, pack in ipairs(MoneyPackConfig.Packs) do
		if pack.ID == packID then
			return pack
		end
	end
	return nil
end

-- Obtiene un pack por su Product ID
function MoneyPackConfig.GetPackByProductID(productID)
	for _, pack in ipairs(MoneyPackConfig.Packs) do
		if pack.ProductID == productID then
			return pack
		end
	end
	return nil
end

-- Formatea números con separadores de miles
function MoneyPackConfig.FormatNumber(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

return MoneyPackConfig
