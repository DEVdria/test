--[[
	SPIN PART - Hace girar una Part 180 grados
	Coloca este Script dentro de la Part que quieres girar.

	OPCIONES:
	- Giro instantáneo
	- Giro con animación suave (Tween)

	Cambia USE_TWEEN = true/false según lo que necesites.
]]

local TweenService = game:GetService("TweenService")

local part = script.Parent    -- La Part donde está este script

-- Configuración
local USE_TWEEN = true         -- true = animación suave | false = instantáneo
local TWEEN_TIME = 1.5         -- Duración de la animación (segundos)
local TWEEN_STYLE = Enum.EasingStyle.Quad
local TWEEN_DIRECTION = Enum.EasingDirection.InOut
local DELAY_BEFORE_SPIN = 2    -- Segundos antes de girar (0 = inmediato)

-- ============================================================================

wait(DELAY_BEFORE_SPIN)

-- Calcular la CFrame destino (rotación de 180 grados en Y)
local targetCFrame = part.CFrame * CFrame.Angles(0, math.rad(180), 0)

if USE_TWEEN then
	-- Giro animado con TweenService
	local tweenInfo = TweenInfo.new(TWEEN_TIME, TWEEN_STYLE, TWEEN_DIRECTION)
	local tween = TweenService:Create(part, tweenInfo, {CFrame = targetCFrame})
	tween:Play()

	tween.Completed:Connect(function()
		print("✓ Part giró 180 grados")
	end)
else
	-- Giro instantáneo
	part.CFrame = targetCFrame
	print("✓ Part giró 180 grados (instantáneo)")
end
