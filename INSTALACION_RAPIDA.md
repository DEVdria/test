# 🚀 Guía de Instalación Rápida

## Pasos para Instalar en Roblox Studio

### 1️⃣ ReplicatedStorage
```
1. Click derecho en ReplicatedStorage
2. Insert Object → Script
3. Renombrar a "SetupRemoteEvents"
4. Copiar código de: src/ReplicatedStorage/RemoteEvents.lua
5. Pegar en el script
```

### 2️⃣ ServerScriptService
```
1. Click derecho en ServerScriptService
2. Insert Object → Script
3. Renombrar a "GameManager"
4. Copiar código de: src/ServerScriptService/GameManager.lua
5. Pegar en el script
```

### 3️⃣ StarterGui
```
1. Click derecho en StarterGui
2. Insert Object → ScreenGui
3. Renombrar a "GuessingGameUI"
4. Click derecho en el ScreenGui
5. Insert Object → LocalScript
6. Renombrar a "GameUI"
7. Copiar código de: src/StarterGui/GameGui/GameUI.lua
8. Pegar en el LocalScript
```

### ✅ Verificación

Presiona F5 para probar. Deberías ver:
- ✓ UI del juego en pantalla
- ✓ Mensaje "Nuevo juego" en la consola
- ✓ RemoteEvents creados en ReplicatedStorage

### ⚠️ Errores Comunes

**"RemoteEvents not found"**
- Verifica que SetupRemoteEvents sea un Script (no LocalScript)

**"UI no aparece"**
- Verifica que GameUI sea un LocalScript (no Script)
- Debe estar dentro de un ScreenGui

**"No funciona el turno"**
- Espera a que haya al menos 2 jugadores
- Revisa la consola de salida (F9)

---

📖 Para más detalles, consulta README.md
