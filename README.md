# 🎮 Sistemas Completos para Roblox

Colección de sistemas profesionales listos para usar en tus juegos de Roblox.

![Roblox](https://img.shields.io/badge/Roblox-Studio-blue)
![Lua](https://img.shields.io/badge/Lua-5.1-purple)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📦 Sistemas Incluidos

### 🛒 **Sistema de Tienda** (NUEVO)
Sistema completo de compras con Gamepasses y Developer Products, incluyendo panel de productos "Troll".

**Características:**
- Compra de Gamepasses con activación automática de beneficios
- Developer Products consumibles (monedas, power-ups, etc.)
- Panel especial de productos Troll (Kill All, Ragdoll, etc.)
- UI profesional y responsive
- Seguridad total en el servidor

📖 **Guía:** [SHOP_SYSTEM_GUIDE.md](./SHOP_SYSTEM_GUIDE.md)
📂 **Código:** [src/ShopSystem/](./src/ShopSystem/)

---

### 🎵 **Sistema de Música**
Sistema completo de música con interfaz gráfica para juegos de Roblox.

**Características:**
- Interfaz intuitiva en la esquina inferior izquierda
- Panel de selección de canciones con scroll
- Controles de reproducción (Play/Pause)
- Diseño moderno con animaciones suaves
- Reproducción en loop automática
- UI Responsive - se adapta a móviles, tablets y PC
- Detección inteligente de tipo de dispositivo

📖 **Guía:** [INSTALACION.md](./INSTALACION.md)
📂 **Código:** [src/MusicSystem/](./src/MusicSystem/)

---

## 🚀 Instalación Rápida

### Sistema de Tienda:
1. Lee la guía completa: [SHOP_SYSTEM_GUIDE.md](./SHOP_SYSTEM_GUIDE.md)
2. Configura tus IDs de productos en `ProductsConfig.lua`
3. Copia los scripts a las ubicaciones indicadas
4. ¡Publica y prueba en tu juego!

### Sistema de Música:
1. Copia `SongsConfig.lua` → ReplicatedStorage como **ModuleScript**
2. Copia `MusicPlayerScript.lua` → StarterPlayerScripts como **LocalScript**
3. Configura tus canciones en SongsConfig
4. ¡Presiona Play! (F5)

📖 **Documentación completa disponible en cada carpeta**

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
├── ShopSystem/                  # Sistema de Tienda (NUEVO)
│   ├── Client/                  # Scripts del cliente
│   │   ├── ShopFrameHandler.lua
│   │   ├── TrollButtonHandler.lua
│   │   └── ShopButtonHandler.lua
│   ├── Server/                  # Scripts del servidor
│   │   ├── PurchaseHandler.lua
│   │   └── GamepassHandler.lua
│   └── Shared/                  # Configuración compartida
│       └── ProductsConfig.lua
│
└── MusicSystem/                 # Sistema de Música
    ├── SongsConfig.lua
    └── MusicPlayerScript.lua

Documentación/
├── SHOP_SYSTEM_GUIDE.md         # Guía completa del sistema de tienda
├── INSTALACION.md               # Guía del sistema de música
├── RESPONSIVE_DESIGN.md         # Guía de UI responsive
├── EJEMPLOS_AUDIO.md            # Cómo conseguir IDs de audio
├── REFERENCIA_RAPIDA.md         # Referencia rápida
└── README.md                    # Este archivo
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

## 📱 UI Responsive (NUEVO)

El sistema ahora se adapta automáticamente a diferentes dispositivos:

### **Detección Automática:**
- 📱 **Móviles** - UI reducida al 70%, optimizada para pantallas pequeñas
- 📲 **Tablets** - UI al 85%, balance perfecto
- 🖥️ **Desktop** - UI completa al 100%

### **Características Responsive:**
- ✅ Tamaños ajustados según dispositivo
- ✅ Textos escalables en móviles
- ✅ Panel selector optimizado para touch
- ✅ Posiciones inteligentes

📖 **Guía completa:** [RESPONSIVE_DESIGN.md](./RESPONSIVE_DESIGN.md)

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