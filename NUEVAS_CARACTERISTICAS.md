# 🆕 NUEVAS CARACTERÍSTICAS - Sistema de Dinero Expandido

## 📦 Sistema de Cofres Múltiples

### **Tipos de Cofres Disponibles**

El sistema ahora incluye **4 tipos diferentes de cofres** con diferentes recompensas, cooldowns y efectos visuales:

| Tipo | Icono | Recompensa | Cooldown | Color |
|------|-------|-----------|----------|-------|
| **Cofre Común** | 📦 | $25 - $50 | 20 seg | Verde |
| **Cofre Raro** | 💎 | $75 - $150 | 45 seg | Azul |
| **Cofre Épico** | 👑 | $200 - $400 | 90 seg | Morado |
| **Cofre Legendario** | 🏆 | $500 - $1000 | 180 seg | Dorado |

### **Características de los Cofres**

✨ **Efectos Visuales Únicos:**
- Partículas de colores según la rareza
- Brillo y luz ambiental
- Animación de rotación al abrirse
- Material Neon temporal

🎮 **Mecánicas:**
- Cooldown individual por cofre (no global)
- Recompensas aleatorias dentro del rango
- ProximityPrompt con tiempo de espera según rareza
- Integración con sistema de misiones

### **Instalación de Cofres**

1. En **Workspace**, crea una **Part**
2. Nómbrala exactamente como uno de estos:
   - `CommonChest` (Cofre Común)
   - `RareChest` (Cofre Raro)
   - `EpicChest` (Cofre Épico)
   - `LegendaryChest` (Cofre Legendario)
3. El script aplicará automáticamente:
   - Color del cofre
   - ProximityPrompt configurado
   - Efectos y recompensas

### **Script Requerido**

Ubicación: `ServerScriptService/MultiChestScript.lua`

**⚠️ IMPORTANTE:** Este script **reemplaza** al `ChestScript.lua` original. Puedes eliminar el antiguo o mantener ambos.

---

## 🎯 Sistema de Misiones

### **¿Qué son las Misiones?**

Las misiones son objetivos que los jugadores pueden completar para ganar dinero extra. Cada jugador recibe **3 misiones aleatorias** al unirse al juego.

### **Tipos de Misiones Disponibles**

| Misión | Objetivo | Recompensa | Tipo |
|--------|----------|------------|------|
| 🚶 **Caminante Incansable** | Caminar 1000 studs | $100 | Distancia |
| 📦 **Cazador de Tesoros** | Abrir 5 cofres | $150 | Cofres |
| 💸 **Gran Comprador** | Gastar $200 en tienda | $75 | Compras |
| ⏰ **Jugador Dedicado** | Jugar 15 minutos | $200 | Tiempo |
| 💰 **Millonario en Camino** | Ganar $500 en total | $250 | Dinero |

### **Características del Sistema**

📊 **Seguimiento Automático:**
- Progreso actualizado en tiempo real
- Barra visual de progreso
- Notificaciones al completar

🎨 **Interfaz Visual:**
- Panel lateral con botón toggle (📋)
- Animaciones suaves
- Diseño moderno y limpio
- Notificación especial al completar

🔄 **Integración Completa:**
- Se conecta automáticamente con:
  - Sistema de cofres
  - Sistema de tienda
  - Sistema de dinero
  - Movimiento del jugador
  - Tiempo de juego

### **Scripts Requeridos**

**Servidor:**
- `ServerScriptService/QuestSystem.lua`

**Cliente:**
- `StarterPlayer/StarterPlayerScripts/QuestUI.lua`

### **Cómo Usar las Misiones**

1. **Al unirse al juego:**
   - Cada jugador recibe 3 misiones aleatorias
   - Aparece un botón 📋 en el lado izquierdo de la pantalla

2. **Ver misiones:**
   - Haz clic en el botón 📋 para abrir/cerrar el panel
   - El panel muestra todas tus misiones activas

3. **Completar misiones:**
   - El progreso se actualiza automáticamente
   - Cuando completas una misión:
     - Recibes el dinero instantáneamente
     - Aparece una notificación especial
     - La misión se marca como completada

4. **Reinicio:**
   - Las misiones se reinician al salir y volver a entrar
   - En el futuro se pueden añadir misiones diarias

---

## 🎮 Guía de Uso para Jugadores

### **Estrategia Óptima**

1. **Prioriza cofres legendarios** - Mayor recompensa
2. **Completa misiones fáciles primero** - Dinero rápido
3. **Combina objetivos** - Abre cofres mientras caminas
4. **Revisa tus misiones** - Saber en qué enfocarte

### **Consejos**

💡 **Para ganar dinero rápido:**
- Busca cofres comunes (cooldown corto)
- Completa la misión de caminar (se hace sola)
- Juega durante 15 minutos para la misión de tiempo

💡 **Para maximizar ganancias:**
- Espera los cofres legendarios
- Completa todas las misiones ($775 total)
- Gasta dinero en la tienda para la misión de compras

---

## ⚙️ Personalización para Desarrolladores

### **Configurar Tipos de Cofres**

En `MultiChestScript.lua`, modifica la tabla `CHEST_TYPES`:

```lua
CommonChest = {
    DisplayName = "Cofre Común",
    Reward = {Min = 25, Max = 50},    -- Cambia la recompensa
    Cooldown = 20,                      -- Cambia el cooldown (segundos)
    Color = Color3.fromRGB(76, 209, 55), -- Cambia el color
    ParticleColor = ColorSequence.new(Color3.fromRGB(76, 209, 55)),
    Icon = "📦",                        -- Cambia el ícono
    Rarity = 1                          -- Cambia la rareza (afecta efectos)
}
```

### **Configurar Misiones**

En `QuestSystem.lua`, modifica la tabla `QUEST_TEMPLATES`:

```lua
{
    Id = "walk_distance",               -- ID único
    Name = "Caminante Incansable",      -- Nombre visible
    Description = "Camina {goal} studs", -- {goal} se reemplaza automáticamente
    Type = "Distance",                   -- Tipo de seguimiento
    Goal = 1000,                         -- Objetivo a alcanzar
    Reward = 100,                        -- Recompensa en dinero
    Icon = "🚶"                         -- Ícono
}
```

### **Tipos de Seguimiento Disponibles**

- `Distance` - Distancia caminada (en studs)
- `ChestCollect` - Cofres abiertos
- `MoneySpent` - Dinero gastado en tienda
- `PlayTime` - Tiempo jugado (en minutos)
- `MoneyEarned` - Dinero ganado total

### **Añadir Nuevos Tipos de Misiones**

1. Crea el template en `QUEST_TEMPLATES`
2. Añade el seguimiento en `QuestSystem.lua`
3. Llama a `_G.QuestSystem.UpdateProgress(player, "TuTipo", cantidad)`

**Ejemplo: Misión de Saltos**

```lua
-- En QuestSystem.lua - QUEST_TEMPLATES
{
    Id = "jump_count",
    Name = "Saltador Experto",
    Description = "Salta {goal} veces",
    Type = "Jumps",
    Goal = 50,
    Reward = 75,
    Icon = "🦘"
}

-- En un nuevo script que detecte saltos
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        humanoid.Jumping:Connect(function()
            if _G.QuestSystem then
                _G.QuestSystem.UpdateProgress(player, "Jumps", 1)
            end
        end)
    end)
end)
```

---

## 📊 Comparativa de Sistemas

### **Antes vs Ahora**

| Característica | Antes | Ahora |
|----------------|-------|-------|
| Tipos de cofres | 1 | 4 |
| Recompensa de cofres | $50 fijo | $25-$1000 variable |
| Cooldown | 30s global | 20s-180s individual |
| Efectos visuales | Básicos | Avanzados con partículas |
| Misiones | ❌ | ✅ 5 tipos diferentes |
| UI de misiones | ❌ | ✅ Panel interactivo |
| Formas de ganar dinero | 2 | 7+ |

### **Ganancias Potenciales**

**Por sesión de 30 minutos:**

| Actividad | Cantidad | Ganancia |
|-----------|----------|----------|
| Cofres comunes | ~6 | $150-$300 |
| Cofres raros | ~2 | $150-$300 |
| Cofres épicos | ~1 | $200-$400 |
| Misiones completadas | 3 | $525-$775 |
| **TOTAL** | | **$1,025-$1,775** |

---

## 🔧 Solución de Problemas

### **Los cofres no aparecen o no funcionan:**

1. Verifica el nombre exacto de la Part:
   - `CommonChest`, `RareChest`, `EpicChest`, `LegendaryChest`
   - ⚠️ Distingue mayúsculas y minúsculas

2. Asegúrate de que `MultiChestScript.lua` esté en ServerScriptService

3. Revisa la consola (F9) para mensajes de error

### **Las misiones no se actualizan:**

1. Verifica que `QuestSystem.lua` esté en ServerScriptService
2. Verifica que `QuestUI.lua` esté en StarterPlayerScripts
3. Asegúrate de que MoneyManager esté cargado primero
4. Revisa la consola para errores

### **El botón de misiones no aparece:**

1. Reinicia el juego en Studio
2. Verifica que el script esté en StarterPlayerScripts (no en StarterGui)
3. Revisa la consola del cliente

### **Las misiones no dan dinero:**

1. Verifica que MoneyManager esté funcionando
2. Asegúrate de que `_G.MoneyManager` esté definido
3. Revisa la consola del servidor

---

## 🎨 Capturas de Ejemplo

### **Cofres:**
- Verde brillante = Común
- Azul brillante = Raro
- Morado brillante = Épico
- Dorado brillante = Legendario

### **Panel de Misiones:**
- Botón 📋 en lado izquierdo
- Panel deslizable con animación
- Barras de progreso animadas
- Marca ✓ al completar

---

## 🚀 Próximas Características Sugeridas

Ideas para expandir aún más el sistema:

1. **Misiones Diarias:**
   - Reset cada 24 horas
   - Misiones más difíciles con mejores recompensas
   - Sistema de racha

2. **Logros:**
   - Logros permanentes
   - Recompensas únicas
   - Badges de Roblox

3. **Sistema de Niveles:**
   - XP basado en actividad
   - Desbloquear recompensas por nivel
   - Multiplicadores de dinero

4. **Cofres Especiales:**
   - Cofres con timer de spawn
   - Cofres que requieren llaves
   - Cofres ocultos

5. **Más Tipos de Misiones:**
   - Misiones de combate
   - Misiones sociales (jugar con amigos)
   - Misiones de exploración
   - Misiones de minijuegos

---

## 📋 Lista de Scripts

### **Nuevos Scripts (Añadir):**

**ServerScriptService:**
- ✅ `MultiChestScript.lua` - Sistema de cofres múltiples
- ✅ `QuestSystem.lua` - Sistema de misiones

**StarterPlayerScripts:**
- ✅ `QuestUI.lua` - Interfaz de misiones

### **Scripts Modificados:**

- ✅ `MoneyManager.lua` - Integración con misiones
- ✅ `ShopScript.lua` - Registra compras para misiones
- ✅ `MultiChestScript.lua` - Registra cofres para misiones

### **Scripts Opcionales (Mantener o Eliminar):**

- ⚠️ `ChestScript.lua` - Reemplazado por MultiChestScript.lua

---

## 🎉 ¡Disfruta el Sistema Expandido!

Ahora tu juego tiene:
- ✅ **4 tipos de cofres** con recompensas variables
- ✅ **Sistema completo de misiones** con 5 tipos
- ✅ **UI interactiva** para seguimiento de progreso
- ✅ **Integración automática** entre todos los sistemas
- ✅ **Múltiples formas** de ganar dinero

**¡Que tus jugadores disfruten la experiencia mejorada!** 🚀
