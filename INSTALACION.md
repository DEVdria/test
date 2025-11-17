# 🎵 Sistema de Música para Roblox - Guía de Instalación Completa

Esta guía te llevará paso a paso para instalar el sistema completo de música en tu juego de Roblox.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación Paso a Paso](#instalación-paso-a-paso)
3. [Configurar tus Propias Canciones](#configurar-tus-propias-canciones)
4. [Características del Sistema](#características-del-sistema)
5. [Solución de Problemas](#solución-de-problemas)
6. [Personalización Avanzada](#personalización-avanzada)

---

## 📌 Requisitos Previos

- Roblox Studio instalado
- Un proyecto de Roblox abierto
- Acceso a la Toolbox de Roblox para buscar audios

---

## 🚀 Instalación Paso a Paso

### **PASO 1: Configurar SongsConfig (ModuleScript)**

1. En **Roblox Studio**, abre el **Explorer** (panel de la izquierda)
2. Busca **ReplicatedStorage** en el árbol de jerarquía
3. Haz clic derecho en **ReplicatedStorage** → **Insert Object** → **ModuleScript**
4. Renombra el ModuleScript a: **`SongsConfig`** (sin extensión .lua)
5. Haz doble clic en **SongsConfig** para abrirlo
6. **BORRA TODO** el contenido actual
7. Copia y pega el contenido completo del archivo: **`src/MusicSystem/SongsConfig.lua`**
8. Guarda el archivo (Ctrl + S)

**✅ Verificación:** Deberías ver en Explorer:
```
ReplicatedStorage
└── SongsConfig (ModuleScript)
```

---

### **PASO 2: Instalar el Script Principal (LocalScript)**

1. En el **Explorer**, busca **StarterPlayer**
2. Dentro de **StarterPlayer**, busca **StarterPlayerScripts**
3. Haz clic derecho en **StarterPlayerScripts** → **Insert Object** → **LocalScript**
4. Renombra el LocalScript a: **`MusicPlayerScript`**
5. Haz doble clic en **MusicPlayerScript** para abrirlo
6. **BORRA TODO** el contenido actual
7. Copia y pega el contenido completo del archivo: **`src/MusicSystem/MusicPlayerScript.lua`**
8. Guarda el archivo (Ctrl + S)

**✅ Verificación:** Deberías ver en Explorer:
```
StarterPlayer
└── StarterPlayerScripts
    └── MusicPlayerScript (LocalScript)
```

---

### **PASO 3: ¡Prueba el Sistema!**

1. Presiona el botón **Play** (F5) en Roblox Studio
2. Deberías ver:
   - **UI en la esquina inferior izquierda** con el nombre de la canción
   - **Botón de Play/Pause** (⏸️)
   - **Botón de lista de canciones** (📜)
3. La música debería empezar a sonar automáticamente
4. Haz clic en el botón 📜 para abrir el selector de canciones
5. Selecciona diferentes canciones para probar

**🎉 Si todo funciona, ¡la instalación está completa!**

---

## 🎼 Configurar tus Propias Canciones

### **Método 1: Obtener IDs de Audio de la Toolbox**

1. En Roblox Studio, abre la **Toolbox** (View → Toolbox)
2. Cambia a la pestaña **Marketplace**
3. En el filtro, selecciona **Audio**
4. Busca música que te guste (por ejemplo: "background music", "epic music", "calm music")
5. **Haz clic derecho** en un audio → **Copy Asset ID to Clipboard**
6. Anota el ID (será un número como `1837879082`)

### **Método 2: Buscar en el Catálogo Web de Roblox**

1. Ve a: https://www.roblox.com/catalog
2. Filtra por **Audio**
3. Busca la música que quieras
4. Haz clic en el audio para ver los detalles
5. Copia el número del URL (ejemplo: en `roblox.com/library/1234567/Song-Name`, el ID es `1234567`)

---

### **Agregar tus Canciones al Sistema**

1. Abre **ReplicatedStorage → SongsConfig** en Roblox Studio
2. Encuentra la sección `SongsConfig.Songs = { ... }`
3. Edita las canciones existentes o agrega nuevas:

```lua
SongsConfig.Songs = {
	{
		Name = "Mi Canción Favorita",        -- Nombre que verán los jugadores
		AssetId = "rbxassetid://1234567890"  -- ID del audio (reemplaza 1234567890)
	},
	{
		Name = "Música de Batalla",
		AssetId = "rbxassetid://9876543210"
	},
	-- Agrega tantas canciones como quieras
	{
		Name = "Tema Épico",
		AssetId = "rbxassetid://1111111111"
	}
}
```

**⚠️ IMPORTANTE:**
- El formato debe ser: `"rbxassetid://ID_AQUÍ"`
- NO olvides las comas entre las canciones (excepto en la última)
- Puedes agregar infinitas canciones

---

### **Cambiar Configuración por Defecto**

En **SongsConfig**, puedes modificar:

```lua
SongsConfig.DefaultSong = 1       -- Canción que suena al inicio (1 = primera, 2 = segunda, etc.)
SongsConfig.DefaultVolume = 0.5   -- Volumen (0 = mudo, 1 = máximo)
```

---

## 🌟 Características del Sistema

### **UI Principal (Esquina Inferior Izquierda)**

- ✅ Nombre de la canción actual
- ✅ Botón Play/Pause (⏸️/▶️)
- ✅ Botón para abrir el selector de canciones (📜)
- ✅ Diseño moderno con animaciones suaves

### **Panel Selector de Canciones**

- ✅ Lista completa de todas las canciones disponibles
- ✅ Scroll automático si hay muchas canciones
- ✅ Indicador visual de la canción que está sonando (barra verde)
- ✅ Números para identificar cada canción
- ✅ Efecto hover al pasar el mouse
- ✅ Botón de cerrar (✕)

### **Sistema de Reproducción**

- ✅ Los sonidos se crean automáticamente en **SoundService**
- ✅ Reproducción en loop (la canción se repite automáticamente)
- ✅ Cambio instantáneo entre canciones
- ✅ Pausa y reanudación sin problemas
- ✅ Compatible con todos los audios de la Toolbox

---

## 🔧 Solución de Problemas

### **Problema: No suena ninguna música**

**Soluciones:**
1. Verifica que los IDs de audio sean correctos
2. Algunos audios de Roblox pueden estar deshabilitados por copyright
3. Abre la consola de Output (View → Output) para ver errores
4. Asegúrate de que el formato sea: `"rbxassetid://ID"`

### **Problema: La UI no aparece**

**Soluciones:**
1. Verifica que **MusicPlayerScript** esté en **StarterPlayerScripts**
2. Verifica que **SongsConfig** esté en **ReplicatedStorage**
3. Revisa la consola de Output para ver errores
4. Asegúrate de que sean del tipo correcto (LocalScript y ModuleScript)

### **Problema: "SongsConfig is not a valid member of ReplicatedStorage"**

**Soluciones:**
1. Verifica que el ModuleScript se llame EXACTAMENTE: **`SongsConfig`**
2. Verifica que esté en **ReplicatedStorage** (NO en ServerStorage u otro lugar)
3. Reinicia el juego (Stop + Play)

### **Problema: La canción se corta o no hace loop**

**Soluciones:**
1. Esto ya está configurado automáticamente (`sound.Looped = true`)
2. Si persiste, puede ser un problema con el audio específico
3. Prueba con otro audio de la Toolbox

---

## 🎨 Personalización Avanzada

### **Cambiar Colores de la UI**

En **MusicPlayerScript**, busca estas líneas y modifica los valores RGB:

```lua
-- Color del frame principal
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

-- Color del botón Play/Pause
ppButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

-- Color del botón selector
selectorBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)

-- Color del panel selector
selectorPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
```

### **Cambiar Posición de la UI**

Para mover la UI a otra esquina, modifica:

```lua
-- Esquina inferior izquierda (actual)
mainFrame.Position = UDim2.new(0, 20, 1, -100)

-- Esquina inferior derecha
mainFrame.Position = UDim2.new(1, -320, 1, -100)

-- Esquina superior izquierda
mainFrame.Position = UDim2.new(0, 20, 0, 20)

-- Esquina superior derecha
mainFrame.Position = UDim2.new(1, -320, 0, 20)
```

### **Cambiar Tamaño de la UI**

```lua
-- Hacer la UI más grande
mainFrame.Size = UDim2.new(0, 400, 0, 100)

-- Hacer la UI más pequeña
mainFrame.Size = UDim2.new(0, 250, 0, 60)
```

### **Agregar Más Funcionalidades**

El script está completamente comentado y organizado. Puedes agregar:
- Botones de siguiente/anterior canción
- Barra de progreso
- Control de volumen
- Modo aleatorio (shuffle)
- Listas de reproducción personalizadas

---

## 📂 Estructura Final del Proyecto

Después de la instalación, tu Explorer debería verse así:

```
ReplicatedStorage
└── SongsConfig (ModuleScript) ← Configuración de canciones

StarterPlayer
└── StarterPlayerScripts
    └── MusicPlayerScript (LocalScript) ← Script principal

SoundService
└── [Los sonidos se crean automáticamente aquí cuando el juego inicia]
```

---

## ✅ Lista de Verificación Final

- [ ] **SongsConfig** está en **ReplicatedStorage** como **ModuleScript**
- [ ] **MusicPlayerScript** está en **StarterPlayerScripts** como **LocalScript**
- [ ] Has configurado al menos una canción con un ID válido
- [ ] Has probado el juego presionando Play (F5)
- [ ] La UI aparece en la esquina inferior izquierda
- [ ] La música suena correctamente
- [ ] Puedes cambiar entre canciones
- [ ] El botón Play/Pause funciona

---

## 🎯 Próximos Pasos

1. **Personaliza las canciones** según el tema de tu juego
2. **Ajusta los colores** para que coincidan con tu estilo visual
3. **Prueba con diferentes audios** de la Toolbox
4. **Comparte tu juego** y obtén feedback de los jugadores

---

## 📞 Soporte

Si tienes problemas:
1. Revisa la sección de [Solución de Problemas](#solución-de-problemas)
2. Verifica la consola de **Output** en Roblox Studio
3. Asegúrate de seguir todos los pasos exactamente como se indica

---

**¡Disfruta de tu nuevo sistema de música! 🎵🎮**
