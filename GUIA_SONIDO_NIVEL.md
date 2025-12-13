# 🔊 GUÍA - Sonido de Subida de Nivel

## 📋 RESUMEN

Sistema para reproducir un sonido personalizado cada vez que el jugador sube de nivel.

---

## 🎵 INSTALACIÓN

### PASO 1: Añadir el LocalScript

1. Ve a **StarterGui** en Roblox Studio
2. Insert Object → **LocalScript**
3. Renombrar a: **LevelUpSound**
4. Pegar contenido de: `StarterGui_LevelUpSound.lua`

### PASO 2: Añadir el Sound

1. Selecciona el LocalScript **LevelUpSound** que acabas de crear
2. Insert Object → **Sound** (dentro del LocalScript)
3. Renombrar a: **LevelUpSound** (nombre exacto)

### PASO 3: Configurar el SoundId

1. Selecciona el **Sound** que acabas de crear
2. En Properties, busca la propiedad **SoundId**
3. Pegar el ID del sonido que quieras usar

---

## 🎼 CONSEGUIR SONIDOS

### Opción 1: Usar sonidos de Roblox

Busca sonidos en el catálogo de Roblox:
1. Ve a: https://create.roblox.com/marketplace/audio
2. Busca "level up" o el sonido que quieras
3. Copia el ID del Asset
4. Pégalo en SoundId con formato: `rbxassetid://ID_AQUI`

### Opción 2: Subir tu propio sonido

1. Ve a https://create.roblox.com/dashboard/creations
2. Click en "Audio" → "Upload Audio"
3. Sube tu archivo de audio (.mp3 u .ogg)
4. Una vez aprobado, copia el Asset ID
5. Úsalo en SoundId: `rbxassetid://ID_AQUI`

### Opción 3: Sonidos recomendados

Aquí hay algunos IDs de sonidos populares de level up:

| Tipo | SoundId | Descripción |
|---|---|---|
| **Clásico** | rbxassetid://3398620867 | Sonido de level up estilo RPG |
| **Victory** | rbxassetid://2865228021 | Fanfarria de victoria |
| **Achievement** | rbxassetid://3362036950 | Sonido de logro desbloqueado |
| **Power Up** | rbxassetid://3362044465 | Power up estilo videojuego |
| **Ding** | rbxassetid://156785206 | Ding simple y limpio |
| **Sparkle** | rbxassetid://3396838725 | Efecto de brillo mágico |
| **Fanfare** | rbxassetid://1841427728 | Fanfarria épica |

**NOTA:** Los IDs anteriores pueden cambiar o no estar disponibles. Usa el marketplace de Roblox para encontrar sonidos actuales.

---

## ⚙️ CONFIGURACIÓN DEL SOUND

### Propiedades básicas:

```
SoundId: rbxassetid://ID_AQUI   (REQUERIDO)
Volume: 0.5                      (0 a 1, ajusta el volumen)
Pitch: 1                         (0.5 a 2, cambia el tono)
RollOffMaxDistance: 10000        (distancia máxima del sonido)
RollOffMinDistance: 10           (distancia mínima del sonido)
```

### Ejemplos de configuración:

#### Sonido normal:
```
SoundId: rbxassetid://3398620867
Volume: 0.5
Pitch: 1
```

#### Sonido más agudo (épico):
```
SoundId: rbxassetid://3398620867
Volume: 0.7
Pitch: 1.2
```

#### Sonido más grave (dramático):
```
SoundId: rbxassetid://3398620867
Volume: 0.6
Pitch: 0.8
```

---

## 🔍 VERIFICACIÓN

### Checklist:

1. ✅ LocalScript **LevelUpSound** existe en StarterGui
2. ✅ Sound **LevelUpSound** existe dentro del LocalScript
3. ✅ SoundId está configurado (no vacío)
4. ✅ Volume está entre 0 y 1
5. ✅ RemoteEvent **LevelUp** existe en ReplicatedStorage/RemoteEvents

### Test:

1. **Inicia el juego**
2. **Verifica Output:**
   ```
   [LevelUpSound] ✅ Sistema de sonido de subida de nivel inicializado
   [LevelUpSound] Sonido configurado: rbxassetid://XXXXX
   ```
3. **Recoge orbs o estrellas hasta subir de nivel**
4. **Debe reproducirse el sonido** 🔊

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "No se encontró Sound 'LevelUpSound'"

**Solución:**
1. Asegúrate de que el Sound está DENTRO del LocalScript
2. El nombre debe ser exactamente "LevelUpSound" (sin espacios)

### ❌ Error: "El Sound no tiene SoundId configurado"

**Solución:**
1. Selecciona el Sound
2. En Properties, busca SoundId
3. Pega un Asset ID válido: `rbxassetid://12345678`

### ❌ Error: "No se encontró RemoteEvent 'LevelUp'"

**Solución:**
1. Ve a ReplicatedStorage > RemoteEvents
2. Verifica que existe un RemoteEvent llamado "LevelUp"
3. Si no existe, créalo

### ⚠️ El sonido no se reproduce

**Verifica:**
1. El SoundId es válido (prueba reproducirlo manualmente en Studio)
2. El Volume no está en 0
3. El sonido no está silenciado (Mute = false)
4. Revisa el Output por errores

### ⚠️ El sonido se reproduce múltiples veces

**Causa:** El jugador subió varios niveles a la vez (mucho EXP de golpe)

**Esto es normal** si el jugador acumula suficiente EXP para subir varios niveles. El sonido se reproducirá por cada nivel.

---

## 🎨 PERSONALIZACIÓN AVANZADA

### Añadir efecto de sonido con delay

Si quieres que el sonido tenga un pequeño delay antes de reproducirse:

```lua
-- En StarterGui_LevelUpSound.lua, línea 43:
LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
	-- Esperar 0.2 segundos antes de reproducir
	task.wait(0.2)

	if levelUpSound and not levelUpSound.IsPlaying then
		levelUpSound:Play()
		print(string.format("[LevelUpSound] 🔊 Sonido de nivel %d reproducido", newLevel))
	end
end)
```

### Diferentes sonidos por nivel

Si quieres diferentes sonidos según el nivel alcanzado:

```lua
-- Crear múltiples Sounds dentro del LocalScript:
-- - LevelUpSound1 (para niveles 1-10)
-- - LevelUpSound2 (para niveles 11-20)
-- - LevelUpSound3 (para niveles 21+)

LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
	local soundToPlay

	if newLevel <= 10 then
		soundToPlay = script:FindFirstChild("LevelUpSound1")
	elseif newLevel <= 20 then
		soundToPlay = script:FindFirstChild("LevelUpSound2")
	else
		soundToPlay = script:FindFirstChild("LevelUpSound3")
	end

	if soundToPlay and not soundToPlay.IsPlaying then
		soundToPlay:Play()
	end
end)
```

### Aumentar pitch con el nivel

Para que el sonido sea más agudo a medida que subes de nivel:

```lua
LevelUpEvent.OnClientEvent:Connect(function(newLevel, newSpeed)
	if levelUpSound then
		-- Aumentar pitch con el nivel (1.0 a 1.5)
		levelUpSound.Pitch = math.min(1 + (newLevel * 0.02), 1.5)

		if not levelUpSound.IsPlaying then
			levelUpSound:Play()
		end
	end
end)
```

---

## 💡 TIPS

1. **Volumen recomendado:** 0.3 - 0.7 (no muy alto para no molestar)
2. **Duración ideal:** 1-3 segundos (sonidos cortos y satisfactorios)
3. **Prueba varios sonidos** hasta encontrar el que más te guste
4. **No uses sonidos con copyright** si vas a publicar tu juego
5. **Combina con efectos visuales** para mejor experiencia (partículas, GUI, etc.)

---

## 📊 ESTRUCTURA FINAL

```
StarterGui
└─ LevelUpSound (LocalScript)
   └─ LevelUpSound (Sound)
      Propiedades:
      - SoundId: rbxassetid://XXXXX
      - Volume: 0.5
      - Pitch: 1
```

---

## 🎯 RESUMEN

**Para añadir sonido de subida de nivel:**
1. Crear LocalScript "LevelUpSound" en StarterGui
2. Crear Sound "LevelUpSound" dentro del LocalScript
3. Configurar SoundId con el ID que quieras
4. Ajustar Volume y Pitch a tu gusto
5. ¡Listo! El sonido se reproducirá automáticamente al subir de nivel

**El sistema se encarga de:**
- ✅ Escuchar evento de subida de nivel
- ✅ Reproducir sonido automáticamente
- ✅ Evitar que el sonido se reproduzca múltiples veces al mismo tiempo
- ✅ Logs para debugging

**TÚ controlas:**
- ✅ Qué sonido usar (SoundId)
- ✅ Volumen del sonido (Volume)
- ✅ Tono del sonido (Pitch)
- ✅ Cualquier otra propiedad del Sound

---

¡Sistema de sonido completamente personalizable! 🔊🎵✨
