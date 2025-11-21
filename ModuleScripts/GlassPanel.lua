--[[
	GlassPanel.lua
	Módulo para gestionar paneles individuales del Glass Bridge

	Coloca este script en: ReplicatedStorage > ModuleScripts
]]

local GlassPanel = {}
GlassPanel.__index = GlassPanel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("GlassBridgeConfig"))
local Effects = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("GlassBridgeEffects"))

-- Constructor
function GlassPanel.new(position, isSafe, rowNumber, side)
	local self = setmetatable({}, GlassPanel)

	self.Position = position
	self.IsSafe = isSafe
	self.RowNumber = rowNumber
	self.Side = side -- "Left" o "Right"
	self.HasBeenTouched = false
	self.Part = nil
	self.IsDestroyed = false -- Rastrear si está destruido
	self.RegenerationScheduled = false -- Rastrear si hay regeneración pendiente
	self.PlayersWhoActivated = {} -- Tabla para rastrear jugadores que ya activaron el efecto

	self:CreatePart()
	self:SetupTouchDetection()

	return self
end

-- Crear la parte física del panel
function GlassPanel:CreatePart()
	local panel = Instance.new("Part")
	panel.Name = "GlassPanel_Row" .. self.RowNumber .. "_" .. self.Side
	panel.Size = Config.PanelSize
	panel.Position = self.Position
	panel.Anchored = true
	panel.CanCollide = true
	panel.Material = Config.GlassMaterial
	panel.Transparency = Config.InitialTransparency
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth

	-- Color según si es seguro o falso (opcional para debug)
	if Config.ShowCorrectPath then
		panel.Color = self.IsSafe and Config.SafePanelColor or Config.FakePanelColor
	else
		-- Color por columna: izquierda azul, derecha rosa (más brillantes)
		if self.Side == "Left" then
			panel.Color = Color3.fromRGB(120, 180, 255) -- Azul más brillante
		else
			panel.Color = Color3.fromRGB(255, 180, 220) -- Rosa más brillante
		end
	end

	-- Agregar valor para identificar el tipo
	local safeValue = Instance.new("BoolValue")
	safeValue.Name = "IsSafe"
	safeValue.Value = self.IsSafe
	safeValue.Parent = panel

	-- Agregar al workspace
	panel.Parent = workspace:WaitForChild("GlassBridge")

	-- NUEVO: Agregar luz para hacer los cristales más atractivos
	local surfaceLight = Instance.new("SurfaceLight")
	surfaceLight.Name = "GlassLight"
	surfaceLight.Face = Enum.NormalId.Top
	surfaceLight.Brightness = 1.5
	surfaceLight.Range = 15

	-- Color de la luz según la columna
	if self.Side == "Left" then
		surfaceLight.Color = Color3.fromRGB(120, 180, 255) -- Luz azul
	else
		surfaceLight.Color = Color3.fromRGB(255, 180, 220) -- Luz rosa
	end

	surfaceLight.Parent = panel

	-- Agregar Decals si está habilitado (3 texturas diferentes con color según columna)
	if Config.UseDecals then
		-- Determinar color según la columna (más brillante)
		local decalColor
		if self.Side == "Left" then
			decalColor = Color3.fromRGB(120, 180, 255) -- Azul más brillante
		else
			decalColor = Color3.fromRGB(255, 180, 220) -- Rosa más brillante
		end
		Effects.CreateDecal(panel, Config.DecalTextures, decalColor)
	end

	self.Part = panel
end

-- Configurar detección de colisión
function GlassPanel:SetupTouchDetection()
	-- Detectar cuando un jugador pisa el panel
	self.Part.Touched:Connect(function(hit)
		self:OnTouch(hit)
	end)
end

-- Manejador de eventos de toque
function GlassPanel:OnTouch(hit)
	-- Si el panel está destruido, no hacer nada
	if self.IsDestroyed then
		return
	end

	-- Verificar si es un jugador
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local player = game.Players:GetPlayerFromCharacter(hit.Parent)

	if self.IsSafe then
		-- Panel seguro - efectos locales solo para el jugador que pisa

		-- Verificar si este jugador ya activó el efecto en este panel
		if player and self.PlayersWhoActivated[player.UserId] then
			-- El jugador ya activó el efecto, no activar de nuevo
			return
		end

		print(hit.Parent.Name .. " pisó un panel SEGURO (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

		-- Marcar que este jugador ya activó el efecto
		if player then
			self.PlayersWhoActivated[player.UserId] = true

			-- Conectar evento de muerte para resetear cuando muera
			local humanoid = hit.Parent:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Died:Connect(function()
					-- Resetear para que pueda activar de nuevo al respawnear
					self.PlayersWhoActivated[player.UserId] = nil
					print(player.Name .. " murió - Reset de activación para panel (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")
				end)
			end

			-- Disparar evento al cliente específico para efectos locales
			local effectEvent = ReplicatedStorage:FindFirstChild("GlassBridgeEffectEvent")
			if effectEvent then
				effectEvent:FireClient(player, "SafePanel", self.Part)
			end
		end
	else
		-- ACTUALIZADO: Panel falso - explosión y regeneración
		-- Evitar múltiples activaciones del panel falso
		if self.HasBeenTouched then
			return
		end

		self.HasBeenTouched = true
		print(hit.Parent.Name .. " pisó un panel FALSO (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

		-- NUEVO: Crear explosión si está habilitado
		if Config.ExplosionEnabled then
			-- Calcular fuerza basada en configuración
			local explosionForce = Config.ExplosionForce * 1000 -- Multiplicar para Roblox BlastPressure
			Effects.CreateExplosion(self.Part, explosionForce, Config.ExplosionRadius)
		end

		-- Desactivar colisión inmediatamente para que el jugador caiga
		self.Part.CanCollide = false

		-- Ejecutar efectos de rotura
		Effects.ShatterPanel(self.Part, Config.BreakDelay)

		-- Marcar como destruido
		self.IsDestroyed = true

		-- Matar al jugador o respawnearlo según configuración
		task.delay(Config.BreakDelay, function()
			if humanoid and humanoid.Health > 0 then
				if Config.RespawnOnDeath then
					humanoid.Health = 0 -- Esto hará que respawnee
				else
					-- Eliminar al jugador del juego
					humanoid.Health = 0
					if player then
						task.delay(2, function()
							player:Kick("¡Caíste del Glass Bridge!")
						end)
					end
				end
			end
		end)

		-- NUEVO: Programar regeneración después del delay configurado
		if not self.RegenerationScheduled then
			self.RegenerationScheduled = true
			task.delay(Config.RegenerateDelay, function()
				self:Regenerate()
			end)
		end
	end
end

-- NOTA: Ya no necesitamos OnTouchEnded porque rastreamos activación, no presencia
-- El reset se hace cuando el jugador muere, no cuando deja el panel

-- Regenerar el panel después de ser destruido
function GlassPanel:Regenerate()
	print("Regenerando panel (Fila " .. self.RowNumber .. " - " .. self.Side .. ")")

	-- Si el panel todavía existe, destruirlo primero
	if self.Part and self.Part.Parent then
		self.Part:Destroy()
	end

	-- Resetear estados
	self.HasBeenTouched = false
	self.IsDestroyed = false
	self.RegenerationScheduled = false
	self.PlayersWhoActivated = {} -- Limpiar la lista de jugadores que activaron

	-- Recrear el panel
	self:CreatePart()

	-- Reconectar la detección de toque
	self:SetupTouchDetection()

	-- Efecto visual de regeneración
	if self.Part then
		-- Empezar invisible y aparecer gradualmente
		self.Part.Transparency = 1

		local tweenService = game:GetService("TweenService")
		local tweenInfo = TweenInfo.new(
			0.5, -- Duración
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local goal = {
			Transparency = Config.InitialTransparency
		}

		local tween = tweenService:Create(self.Part, tweenInfo, goal)
		tween:Play()

		-- Efecto de partículas de regeneración
		local regenEffect = Instance.new("ParticleEmitter")
		regenEffect.Parent = self.Part
		regenEffect.Name = "RegenerationParticles"

		regenEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		regenEffect.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
		regenEffect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0)
		})
		regenEffect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})

		regenEffect.Lifetime = NumberRange.new(0.5, 1)
		regenEffect.Rate = 50
		regenEffect.Speed = NumberRange.new(5, 10)
		regenEffect.SpreadAngle = Vector2.new(180, 180)

		regenEffect:Emit(30)

		-- Sonido de regeneración
		local regenSound = Instance.new("Sound")
		regenSound.Parent = self.Part
		regenSound.SoundId = "rbxassetid://6895079853" -- Sonido de regeneración
		regenSound.Volume = 0.3
		regenSound.PlaybackSpeed = 1.5
		regenSound:Play()

		-- Limpiar efectos
		task.delay(2, function()
			if regenEffect then regenEffect:Destroy() end
			if regenSound then regenSound:Destroy() end
		end)
	end
end

-- Revelar si es seguro o falso (para debug)
function GlassPanel:Reveal()
	if self.IsSafe then
		self.Part.Color = Config.SafePanelColor
	else
		self.Part.Color = Config.FakePanelColor
	end
	self.Part.Transparency = 0.5
end

-- Destruir el panel
function GlassPanel:Destroy()
	if self.Part then
		self.Part:Destroy()
	end
end

return GlassPanel
