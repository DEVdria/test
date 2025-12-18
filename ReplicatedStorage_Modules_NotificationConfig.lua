--[[
	NOTIFICATION CONFIG - ModuleScript
	Configuración para el sistema de notificaciones en pantalla

	UBICACIÓN: ReplicatedStorage/Modules/NotificationConfig
]]

local NotificationConfig = {}

-- ==================== CONFIGURACIÓN ====================

-- Tipos de notificaciones con sus colores
NotificationConfig.Types = {
	Success = {
		Color = Color3.fromRGB(0, 255, 0),  -- Verde
		Icon = "✅"
	},
	Error = {
		Color = Color3.fromRGB(255, 50, 50),  -- Rojo
		Icon = "❌"
	},
	Warning = {
		Color = Color3.fromRGB(255, 200, 0),  -- Amarillo/Naranja
		Icon = "⚠️"
	},
	Info = {
		Color = Color3.fromRGB(100, 200, 255),  -- Azul
		Icon = "ℹ️"
	},
	Money = {
		Color = Color3.fromRGB(255, 215, 0),  -- Dorado
		Icon = "💰"
	}
}

-- Duración por defecto de las notificaciones (segundos)
NotificationConfig.DefaultDuration = 3

-- Animación de entrada/salida
NotificationConfig.Animation = {
	TweenTime = 0.3,  -- Duración de la animación
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out
}

-- Posición inicial (fuera de pantalla, arriba)
NotificationConfig.StartPosition = UDim2.new(0.5, 0, -0.1, 0)

-- Posición visible (centro-superior de la pantalla)
NotificationConfig.VisiblePosition = UDim2.new(0.5, 0, 0.1, 0)

-- Espaciado entre múltiples notificaciones
NotificationConfig.StackOffset = 80  -- Píxeles

-- ==================== GUI CONFIGURATION ====================

-- Nombres de los elementos en la GUI (que el usuario diseña)
NotificationConfig.GuiNames = {
	ScreenGui = "NotificationGui",  -- ScreenGui en StarterGui
	Template = "NotificationTemplate",  -- Frame template
	Container = "NotificationsContainer",  -- Folder para notificaciones activas

	-- Elementos dentro del template
	MessageLabel = "Message",  -- TextLabel con el mensaje
	IconLabel = "Icon",  -- TextLabel con el icono (opcional)
	BackgroundFrame = "Background"  -- Frame de fondo (opcional)
}

-- ==================== FUNCIONES HELPER ====================

-- Obtiene la configuración de un tipo de notificación
function NotificationConfig.GetType(typeName)
	return NotificationConfig.Types[typeName] or NotificationConfig.Types.Info
end

-- Formatea un mensaje de error común
function NotificationConfig.FormatErrorMessage(message)
	-- Extraer información útil de mensajes comunes
	if string.find(message, "Necesitas %$") then
		return "💰 " .. message
	elseif string.find(message, "rebirths") then
		return "🔄 " .. message
	elseif string.find(message, "nivel") then
		return "⭐ " .. message
	end

	return message
end

return NotificationConfig
