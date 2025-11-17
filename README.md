# 🎵 Sistema de Música para Roblox

Sistema completo de música con interfaz gráfica para juegos de Roblox.

![Roblox](https://img.shields.io/badge/Roblox-Studio-blue)
![Lua](https://img.shields.io/badge/Lua-5.1-purple)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Características

- 🎮 **Interfaz intuitiva** en la esquina inferior izquierda
- 🎵 **Panel de selección** de canciones con scroll
- ⏯️ **Controles de reproducción** (Play/Pause)
- 🎨 **Diseño moderno** con animaciones suaves
- 🔄 **Reproducción en loop** automática
- 📜 **Lista completa** de canciones disponibles
- ✅ **Compatible con audios** de la Toolbox de Roblox
- 🎯 **Fácil de personalizar** y extender

---

## 📦 Componentes

### 1. **SongsConfig.lua** (ModuleScript)
Configuración de todas las canciones disponibles. Ubicación: `ReplicatedStorage`

### 2. **MusicPlayerScript.lua** (LocalScript)
Script principal que controla toda la funcionalidad. Ubicación: `StarterPlayerScripts`

---

## 🚀 Instalación Rápida

1. **Copia `SongsConfig.lua`** → ReplicatedStorage como **ModuleScript**
2. **Copia `MusicPlayerScript.lua`** → StarterPlayerScripts como **LocalScript**
3. **Configura tus canciones** en SongsConfig
4. **¡Presiona Play!** (F5)

📖 **Para instrucciones detalladas, lee:** [INSTALACION.md](./INSTALACION.md)

---

## 🎼 Configuración de Canciones

```lua
SongsConfig.Songs = {
	{
		Name = "Mi Canción",
		AssetId = "rbxassetid://1234567890"
	},
	{
		Name = "Otra Canción",
		AssetId = "rbxassetid://9876543210"
	}
}
```

### Obtener IDs de Audio:
1. Abre la **Toolbox** en Roblox Studio
2. Busca **Audio**
3. **Clic derecho** → **Copy Asset ID**
4. Pega en la configuración

---

## 🖼️ Vista Previa de la UI

### UI Principal:
- Nombre de la canción actual
- Botón Play/Pause (⏸️/▶️)
- Botón para abrir selector (📜)

### Panel Selector:
- Lista scrollable de canciones
- Indicador visual de canción actual (barra verde)
- Números de identificación
- Botón de cerrar (✕)

---

## 📂 Estructura de Archivos

```
src/
└── MusicSystem/
    ├── SongsConfig.lua          # Configuración de canciones
    └── MusicPlayerScript.lua    # Script principal

INSTALACION.md                   # Guía de instalación completa
README.md                        # Este archivo
```

---

## 🎯 Ubicación de Componentes en Roblox

```
ReplicatedStorage
└── SongsConfig (ModuleScript)

StarterPlayer
└── StarterPlayerScripts
    └── MusicPlayerScript (LocalScript)

SoundService
└── [Sonidos creados automáticamente]
```

---

## 🔧 Personalización

### Cambiar Posición
```lua
-- Esquina inferior izquierda (default)
mainFrame.Position = UDim2.new(0, 20, 1, -100)

-- Esquina inferior derecha
mainFrame.Position = UDim2.new(1, -320, 1, -100)
```

### Cambiar Colores
```lua
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
selectorBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
```

### Ajustar Volumen
```lua
SongsConfig.DefaultVolume = 0.5  -- 0 = mudo, 1 = máximo
```

---

## ❓ Solución de Problemas

### No suena música
- Verifica los IDs de audio
- Usa el formato: `"rbxassetid://ID"`
- Revisa la consola de Output

### UI no aparece
- Verifica que los scripts estén en las ubicaciones correctas
- Asegúrate de usar los tipos correctos (LocalScript/ModuleScript)

📖 **Más soluciones en:** [INSTALACION.md](./INSTALACION.md#solución-de-problemas)

---

## 📋 Requisitos

- Roblox Studio
- Conocimientos básicos de Lua (opcional)
- IDs de audio válidos

---

## 🎓 Aprendizaje

Este proyecto incluye:
- ✅ Creación dinámica de UI
- ✅ Manejo de eventos (MouseButton1Click, MouseEnter, etc.)
- ✅ Animaciones con TweenService
- ✅ ModuleScripts y configuración
- ✅ Gestión de sonidos en Roblox
- ✅ Organización de código limpio y comentado

---

## 📝 Licencia

MIT License - Libre para usar en tus proyectos

---

## 🌟 Características Futuras

Ideas para extender el sistema:
- [ ] Botones siguiente/anterior
- [ ] Barra de progreso de canción
- [ ] Control de volumen deslizante
- [ ] Modo aleatorio (shuffle)
- [ ] Listas de reproducción personalizadas
- [ ] Favoritos del jugador

---

## 💡 Contribuciones

¿Tienes ideas para mejorar el sistema? ¡Son bienvenidas!

---

**¡Disfruta creando tu juego con música! 🎮🎵**