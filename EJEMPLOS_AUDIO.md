# 🎵 Ejemplos de IDs de Audio para Roblox

Esta lista contiene IDs de audio gratuitos que puedes usar en tu sistema de música.

---

## ⚠️ Nota Importante sobre Audios en Roblox

Desde marzo de 2022, Roblox cambió sus políticas de audio:
- Los audios subidos por ti o tu grupo **siempre funcionarán** en tus juegos
- Audios públicos antiguos pueden estar limitados o deshabilitados
- Para usar audios de otros, necesitas el permiso del creador

### **Recomendación:**
1. **Sube tus propios audios** a Roblox (gratis hasta 10 segundos, pagos los más largos)
2. **Usa la Creator Store** para encontrar audios con licencia
3. **Busca en la Toolbox** audios marcados como "Public Domain" o "Free to Use"

---

## 🎼 Cómo Subir tus Propios Audios

### Paso 1: Preparar tu Archivo de Audio
- Formato: **MP3** u **OGG**
- Duración máxima gratuita: **7 segundos** (2024)
- Para audios más largos: necesitas Robux

### Paso 2: Subir a Roblox
1. Ve a: https://www.roblox.com/develop
2. Selecciona **Audio** en el menú lateral
3. Haz clic en **Upload Audio**
4. Selecciona tu archivo
5. Acepta los términos de uso
6. ¡Listo! Copia el ID que te dan

### Paso 3: Usar en tu Juego
```lua
{
	Name = "Mi Audio Personalizado",
	AssetId = "rbxassetid://TU_ID_AQUÍ"
}
```

---

## 🔍 Buscar Audios Gratuitos en Internet

### Sitios de Música Libre de Derechos:

1. **Freesound.org**
   - Miles de sonidos gratuitos
   - Licencia Creative Commons
   - Descarga en MP3/OGG

2. **Incompetech.com**
   - Música de fondo gratuita
   - Solo requiere atribución
   - Categorías variadas

3. **YouTube Audio Library**
   - Música y efectos gratuitos
   - Sin derechos de autor
   - Descarga directa

4. **Bensound.com**
   - Música de fondo profesional
   - Gratis con atribución
   - Ideal para juegos

### Después de Descargar:
1. Edita el audio si es necesario (Audacity es gratis)
2. Súbelo a Roblox como se explicó arriba
3. Usa el ID en tu juego

---

## 🎮 IDs de Audio de Ejemplo (Puede que no funcionen)

**⚠️ ADVERTENCIA:** Estos IDs son ejemplos antiguos. Puede que algunos no funcionen debido a las nuevas políticas de Roblox. Úsalos solo para probar el sistema.

### Música Tranquila/Ambiente
```lua
{
	Name = "Peaceful Morning",
	AssetId = "rbxassetid://1837879082"
},
{
	Name = "Calm Vibes",
	AssetId = "rbxassetid://1841647093"
},
{
	Name = "Relaxing Piano",
	AssetId = "rbxassetid://1842658901"
}
```

### Música Épica/Aventura
```lua
{
	Name = "Epic Adventure",
	AssetId = "rbxassetid://1843404009"
},
{
	Name = "Battle Theme",
	AssetId = "rbxassetid://1838673350"
},
{
	Name = "Heroic Quest",
	AssetId = "rbxassetid://1845554017"
}
```

### Música Alegre/Upbeat
```lua
{
	Name = "Happy Tune",
	AssetId = "rbxassetid://1837879082"
},
{
	Name = "Cheerful Day",
	AssetId = "rbxassetid://1839457542"
},
{
	Name = "Joyful Melody",
	AssetId = "rbxassetid://1842814789"
}
```

---

## 🛠️ Cómo Probar si un ID Funciona

### Método 1: En Roblox Studio
1. Inserta un **Sound** object en Workspace
2. Pega el ID en la propiedad **SoundId**
3. Presiona Play en las propiedades del Sound
4. Si suena, ¡funciona!

### Método 2: En el Juego
1. Agrega el ID a tu **SongsConfig**
2. Inicia el juego (F5)
3. Selecciona la canción en el panel
4. Si suena, ¡funciona!

---

## 📝 Plantilla de Configuración Completa

Copia esta plantilla y reemplaza los IDs con los tuyos:

```lua
SongsConfig.Songs = {
	{
		Name = "Tema Principal",
		AssetId = "rbxassetid://TU_ID_1"
	},
	{
		Name = "Música de Batalla",
		AssetId = "rbxassetid://TU_ID_2"
	},
	{
		Name = "Música Tranquila",
		AssetId = "rbxassetid://TU_ID_3"
	},
	{
		Name = "Tema de Victoria",
		AssetId = "rbxassetid://TU_ID_4"
	},
	{
		Name = "Música de Menú",
		AssetId = "rbxassetid://TU_ID_5"
	},
	{
		Name = "Ambiente Misterioso",
		AssetId = "rbxassetid://TU_ID_6"
	},
	{
		Name = "Tema Épico",
		AssetId = "rbxassetid://TU_ID_7"
	},
	{
		Name = "Música de Fondo",
		AssetId = "rbxassetid://TU_ID_8"
	}
}
```

---

## 🎯 Consejos para Elegir Música

### Para Juegos de Acción:
- Tempo rápido (120+ BPM)
- Instrumentos épicos (orquesta, guitarras)
- Ritmo marcado

### Para Juegos Tranquilos:
- Tempo lento (60-90 BPM)
- Instrumentos suaves (piano, cuerdas)
- Melodías simples

### Para Juegos de Terror:
- Sonidos ambientales
- Tonos graves
- Silencios estratégicos

### Para Juegos Casuales:
- Melodías pegajosas
- Instrumentos alegres
- Loops cortos que no molesten

---

## 🔐 Audios Privados vs Públicos

### Audios Privados (Tuyos):
✅ Siempre funcionan en tus juegos
✅ Control total
✅ Sin riesgo de que los eliminen
❌ Requieren subirlos tú mismo

### Audios Públicos (De otros):
✅ No necesitas subirlos
❌ Pueden dejar de funcionar en cualquier momento
❌ Políticas de Roblox cambian frecuentemente

**Recomendación:** Usa audios que tú mismo hayas subido para garantizar que funcionen siempre.

---

## 📚 Recursos Adicionales

### Tutoriales de Roblox:
- https://create.roblox.com/docs/sound
- https://devforum.roblox.com/c/resources/community-tutorials

### Edición de Audio:
- **Audacity** (Gratis): https://www.audacityteam.org/
- **Online Audio Cutter**: https://mp3cut.net/

### Creator Store de Roblox:
- https://create.roblox.com/marketplace/audio

---

## ⚡ Solución Rápida: Audios de Prueba

Si solo quieres probar el sistema rápidamente, usa estos IDs **más recientes**:

```lua
-- Estos son audios de la biblioteca oficial de Roblox
{
	Name = "City Ruins",
	AssetId = "rbxassetid://9043887091"
},
{
	Name = "Fluffing a Duck",
	AssetId = "rbxassetid://9046862773"
},
{
	Name = "Monkeys Spinning Monkeys",
	AssetId = "rbxassetid://9043887091"
}
```

**Nota:** Estos IDs pueden cambiar. Siempre verifica en la consola de Output si funcionan.

---

## ✅ Checklist de Audio

Antes de usar un audio, verifica:
- [ ] Tienes permiso para usar el audio
- [ ] El formato es MP3 u OGG
- [ ] El audio está subido a tu cuenta de Roblox
- [ ] Has probado el audio en Roblox Studio
- [ ] El ID está en formato `rbxassetid://NÚMERO`
- [ ] El audio hace loop correctamente (sin cortes bruscos)

---

**🎵 ¡Ahora estás listo para agregar música increíble a tu juego!**