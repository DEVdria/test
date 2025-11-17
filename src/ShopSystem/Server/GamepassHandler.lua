--[[
	GamepassHandler.lua - Activa beneficios de gamepasses cuando el jugador se une

	UBICACIÓN: ServerScriptService > ShopSystem > GamepassHandler (Script)

	INSTRUCCIONES:
	1. Este script debe estar en ServerScriptService
	2. Se ejecuta automáticamente cuando un jugador se une al juego
	3. Verifica qué gamepasses tiene el jugador y activa sus beneficios
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cargar configuración de gamepasses
local ProductsConfig = require(ReplicatedStorage:WaitForChild("ShopSystem"):WaitForChild("ProductsConfig"))

-- ==================== VERIFICAR GAMEPASSES ====================

local function checkGamepasses(player)
	print("🔍 Verificando gamepasses para:", player.Name)

	for _, gamepassData in ipairs(ProductsConfig.Gamepasses) do
		-- Verificar si el jugador tiene el gamepass
		local hasGamepass = false
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassData.GamepassId)
		end)

		if success and result then
			hasGamepass = true
			print("✅", player.Name, "tiene el gamepass:", gamepassData.Name)

			-- Ejecutar la función OnOwned
			if gamepassData.OnOwned then
				local execSuccess, execError = pcall(function()
					gamepassData.OnOwned(player)
				end)

				if not execSuccess then
					warn("❌ Error al activar gamepass", gamepassData.Name, ":", execError)
				end
			end
		elseif not success then
			warn("⚠️ Error al verificar gamepass", gamepassData.GamepassId, ":", result)
		end
	end
end

-- ==================== CUANDO EL JUGADOR SE UNE ====================

Players.PlayerAdded:Connect(function(player)
	-- Esperar a que el personaje cargue
	player.CharacterAdded:Connect(function(character)
		-- Verificar gamepasses
		task.wait(1)  -- Esperar un poco para que todo cargue
		checkGamepasses(player)
	end)

	-- Si ya tiene un personaje, verificar inmediatamente
	if player.Character then
		checkGamepasses(player)
	end
end)

-- ==================== CUANDO SE COMPRA UN GAMEPASS ====================

-- Detectar cuando se compra un gamepass mientras el jugador está en el juego
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
	if wasPurchased then
		print("🎉", player.Name, "compró el gamepass", gamepassId)

		-- Buscar el gamepass en la configuración
		local gamepassData = ProductsConfig:GetGamepass(gamepassId)

		if gamepassData and gamepassData.OnOwned then
			-- Activar el beneficio inmediatamente
			local success, error = pcall(function()
				gamepassData.OnOwned(player)
			end)

			if success then
				print("✅ Beneficio del gamepass activado para", player.Name)
			else
				warn("❌ Error al activar beneficio:", error)
			end
		end
	end
end)

-- ==================== COMANDO PARA FORZAR VERIFICACIÓN ====================

-- Útil para debugging
game:GetService("ServerStorage"):SetAttribute("ForceCheckGamepasses", false)

game:GetService("RunService").Heartbeat:Connect(function()
	if game:GetService("ServerStorage"):GetAttribute("ForceCheckGamepasses") then
		game:GetService("ServerStorage"):SetAttribute("ForceCheckGamepasses", false)

		for _, player in pairs(Players:GetPlayers()) do
			checkGamepasses(player)
		end

		print("🔄 Verificación forzada de gamepasses completada")
	end
end)

print("✅ GamepassHandler inicializado correctamente")
print("🎫 Gamepasses registrados:", #ProductsConfig.Gamepasses)
