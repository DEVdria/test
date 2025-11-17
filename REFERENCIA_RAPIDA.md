# 🚀 Referencia Rápida - Sistema de Música Roblox

Guía de consulta rápida para el sistema de música.

---

## 📍 Ubicaciones de Archivos

| Archivo | Tipo | Ubicación en Roblox Studio |
|---------|------|---------------------------|
| `SongsConfig.lua` | ModuleScript | **ReplicatedStorage** |
| `MusicPlayerScript.lua` | LocalScript | **StarterPlayer > StarterPlayerScripts** |

---

## ⚡ Instalación en 3 Pasos

```
1. SongsConfig.lua → ReplicatedStorage (ModuleScript)
2. MusicPlayerScript.lua → StarterPlayerScripts (LocalScript)
3. Presiona F5 para probar
```

---

## 🎵 Agregar/Editar Canciones

**Archivo:** `ReplicatedStorage → SongsConfig`

```lua
SongsConfig.Songs = {
	{
		Name = "Nombre de la Canción",
		AssetId = "rbxassetid://ID_DEL_AUDIO"
	},
	-- Agregar más canciones aquí
}
```

### Obtener ID de Audio:
1. Toolbox → Audio → Buscar música
2. Clic derecho → **Copy Asset ID**
3. Pegar en AssetId

---

## 🎨 Personalización Rápida

### Cambiar Posición de la UI

```lua
-- En MusicPlayerScript, buscar "mainFrame.Position"

-- Esquina inferior izquierda (default)
mainFrame.Position = UDim2.new(0, 20, 1, -100)

-- Esquina inferior derecha
mainFrame.Position = UDim2.new(1, -320, 1, -100)

-- Esquina superior izquierda
mainFrame.Position = UDim2.new(0, 20, 0, 20)

-- Esquina superior derecha
mainFrame.Position = UDim2.new(1, -320, 0, 20)
```

### Cambiar Colores

```lua
-- Frame principal (fondo oscuro)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

-- Botón selector (azul)
selectorBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)

-- Panel selector
selectorPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)

-- Botones de canciones
button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
```

### Cambiar Tamaño

```lua
-- UI principal
mainFrame.Size = UDim2.new(0, ANCHO, 0, ALTO)

-- Ejemplo: más grande
mainFrame.Size = UDim2.new(0, 400, 0, 100)

-- Ejemplo: más pequeño
mainFrame.Size = UDim2.new(0, 250, 0, 60)
```

### Ajustar Volumen

```lua
-- En SongsConfig
SongsConfig.DefaultVolume = 0.5  -- Rango: 0.0 a 1.0
```

### Cambiar Canción Inicial

```lua
-- En SongsConfig
SongsConfig.DefaultSong = 1  -- Primera canción
SongsConfig.DefaultSong = 3  -- Tercera canción
```

---

## 🔧 Solución de Problemas

| Problema | Solución |
|----------|----------|
| **No suena música** | 1. Verifica IDs de audio<br>2. Formato: `rbxassetid://ID`<br>3. Revisa Output (F9) |
| **UI no aparece** | 1. Scripts en lugares correctos<br>2. Tipos correctos (Local/Module)<br>3. Espera 1-2 segundos |
| **"SongsConfig not found"** | 1. Nombre exacto: `SongsConfig`<br>2. En ReplicatedStorage<br>3. Tipo: ModuleScript |
| **Canción no hace loop** | Ya configurado automáticamente (`Looped = true`) |

---

## 📊 Estructura del Código

### MusicPlayerScript.lua

```
┌─ CREACIÓN DE UI
│  ├─ createMusicPlayerUI()       → Crea toda la interfaz
│  └─ createSongButton()           → Crea botones de canciones
│
├─ CONTROL DE MÚSICA
│  ├─ createSound()                → Crea objeto Sound
│  ├─ updateUI()                   → Actualiza nombre e indicadores
│  ├─ playSong()                   → Reproduce música
│  ├─ pauseSong()                  → Pausa música
│  └─ changeSong()                 → Cambia a otra canción
│
├─ EVENTOS
│  └─ setupButtons()               → Configura clicks de botones
│
└─ INICIALIZACIÓN
   └─ initialize()                 → Inicia todo el sistema
```

### SongsConfig.lua

```
├─ Songs = {}                      → Lista de canciones
├─ DefaultSong                     → Canción inicial
└─ DefaultVolume                   → Volumen por defecto
```

---

## 🎮 Controles para el Jugador

| Control | Función |
|---------|---------|
| **⏸️** | Pausar música |
| **▶️** | Reanudar música |
| **📜** | Abrir lista de canciones |
| **Click en canción** | Cambiar a esa canción |
| **✕** | Cerrar lista de canciones |

---

## 📐 Dimensiones por Defecto

```lua
UI Principal:       300 x 80 px
Panel Selector:     320 x 400 px
Botón Play/Pause:   40 x 40 px
Botón Selector:     40 x 40 px
Botón de Canción:   Ancho completo x 50 px
```

---

## 🎨 Paleta de Colores por Defecto

```lua
Fondo principal:    RGB(30, 30, 35)     - Gris oscuro
Fondo panel:        RGB(35, 35, 40)     - Gris oscuro
Botón normal:       RGB(45, 45, 50)     - Gris medio
Botón hover:        RGB(60, 60, 70)     - Gris más claro
Botón selector:     RGB(70, 130, 220)   - Azul
Botón actual:       RGB(60, 120, 200)   - Azul oscuro
Indicador:          RGB(70, 220, 100)   - Verde
Botón cerrar:       RGB(220, 50, 50)    - Rojo
Texto:              RGB(255, 255, 255)  - Blanco
```

---

## 📁 Jerarquía en Explorer

```
├── ReplicatedStorage
│   └── SongsConfig (ModuleScript)
│
├── StarterPlayer
│   └── StarterPlayerScripts
│       └── MusicPlayerScript (LocalScript)
│
├── Players
│   └── [TuNombre]
│       └── PlayerGui
│           └── MusicPlayerUI (creado automáticamente)
│               ├── MainFrame
│               │   ├── MusicIcon
│               │   ├── SongNameLabel
│               │   ├── PlayPauseButton
│               │   └── SelectorButton
│               └── SongSelectorPanel
│                   ├── Title
│                   ├── CloseButton
│                   └── SongListFrame
│                       └── Song_1, Song_2, etc.
│
└── SoundService
    └── MusicPlayer_[NombreCanción] (creado automáticamente)
```

---

## 💡 Tips y Trucos

### Agregar Muchas Canciones Rápido

```lua
-- Copia este patrón
local songs = {
	{"Canción 1", "1234567"},
	{"Canción 2", "2345678"},
	{"Canción 3", "3456789"},
}

SongsConfig.Songs = {}
for i, data in ipairs(songs) do
	table.insert(SongsConfig.Songs, {
		Name = data[1],
		AssetId = "rbxassetid://" .. data[2]
	})
end
```

### Deshabilitar Animaciones (más rendimiento)

```lua
-- En setupButtons(), comenta las líneas con TweenService
-- O cambia TweenInfo.new(0.3) a TweenInfo.new(0)
```

### Agregar Texto de Debug

```lua
-- Al final de changeSong()
print("🎵 Reproduciendo:", songData.Name)
print("🆔 ID:", songData.AssetId)
print("🔊 Volumen:", currentSound.Volume)
```

---

## 🎓 Funciones Útiles

### Cambiar Canción desde Otro Script

```lua
-- En MusicPlayerScript, hacer la función global
_G.ChangeMusicSong = changeSong

-- Desde otro script
_G.ChangeMusicSong(3)  -- Cambiar a la canción 3
```

### Pausar/Reanudar desde Otro Script

```lua
-- En MusicPlayerScript
_G.PauseMusic = pauseSong
_G.PlayMusic = playSong

-- Desde otro script
_G.PauseMusic()
_G.PlayMusic()
```

### Obtener Canción Actual

```lua
-- En MusicPlayerScript
_G.GetCurrentSong = function()
	return currentSongIndex
end

-- Desde otro script
local cancionActual = _G.GetCurrentSong()
print("Canción actual:", cancionActual)
```

---

## 📞 Comandos de Debug (Output)

Al iniciar verás en Output (F9):

```
🎵 Inicializando Sistema de Música...
✅ UI creada correctamente
✅ Botones de canciones creados: 5
✅ Eventos configurados
✅ Sistema de Música iniciado correctamente
🎵 Reproduciendo: [Nombre de la canción]
```

Si ves errores:
- Lee el mensaje de error
- Verifica las ubicaciones de los scripts
- Revisa los nombres exactos

---

## ✅ Checklist Rápido

Antes de publicar tu juego:

- [ ] Todos los IDs de audio funcionan
- [ ] Has probado cambiar entre canciones
- [ ] Play/Pause funciona correctamente
- [ ] El panel se abre y cierra sin problemas
- [ ] Los colores coinciden con tu juego
- [ ] La posición de la UI no obstruye otros elementos
- [ ] El volumen es adecuado
- [ ] No hay errores en Output

---

**📖 Documentación Completa:**
- [INSTALACION.md](./INSTALACION.md) - Guía detallada
- [EJEMPLOS_AUDIO.md](./EJEMPLOS_AUDIO.md) - Cómo conseguir audios
- [README.md](./README.md) - Descripción general

---

**🎵 ¡Referencia Rápida Lista!**