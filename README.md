# 🎮 Sistema Completo de Orbs de Velocidad para Roblox

Sistema profesional y completo de orbs de velocidad con sistema de running, dinero, rebirths y persistencia de datos para Roblox.

---

## ✨ CARACTERÍSTICAS PRINCIPALES

### 🏃 Sistema de Velocidad y Running
- ✅ Integración completa con sistema de sprint existente
- ✅ Velocidad acumulada que se aplica solo al correr
- ✅ Efectos visuales (polvo, líneas de velocidad)
- ✅ Soporte para PC y móvil
- ✅ Cámara FOV dinámica

### 🔵 Sistema de Orbs
- ✅ Orbs visibles solo para cada cliente individualmente
- ✅ 3 tipos de orbs por defecto (Amarillo +1, Verde +2, Azul +3)
- ✅ Sistema de zonas con spawns aleatorios
- ✅ Generación automática por zona
- ✅ Efectos visuales (brillos, partículas, rotación, flotación)
- ✅ Fácilmente expandible para más tipos de orbs

### 💰 Sistema de Dinero
- ✅ Leaderstats automáticas (Money, Rebirths)
- ✅ Recompensas por recolección de orbs
- ✅ Persistencia de datos con DataStore
- ✅ Autoguardado cada 60 segundos

### 🔄 Sistema de Rebirths
- ✅ GUI completa y funcional
- ✅ Multiplicadores de velocidad escalables
- ✅ Sistema de costos progresivos
- ✅ Validación servidor-side
- ✅ Efectos visuales en la compra

### 🗺️ Sistema de Zonas
- ✅ Múltiples zonas configurables
- ✅ Tipos de orbs específicos por zona
- ✅ Áreas y alturas personalizables
- ✅ Visualización de zonas en el mundo

### 💾 Sistema de Datos
- ✅ DataStore con sistema de reintentos
- ✅ Guardado automático y al salir
- ✅ Protección contra pérdida de datos
- ✅ Estructura de datos validada

### 🔒 Seguridad
- ✅ Validación servidor-side de todas las acciones
- ✅ Sistema anti-spam con cooldowns
- ✅ Verificación de tipos de datos
- ✅ Protección contra exploits comunes

---

## 📁 ARCHIVOS INCLUIDOS

### 📚 Documentación (6 archivos)
- `README.md` - Este archivo
- `GUIA_COMPLETA_INSTALACION.md` - Guía paso a paso detallada
- `CONFIGURACION_INICIAL_RAPIDA.md` - Configuración rápida en 5 minutos
- `ESTRUCTURA_DEL_PROYECTO.md` - Estructura completa del proyecto
- `RESUMEN_ARCHIVOS_CODIGO.md` - Lista de todos los archivos de código
- `INSTRUCCIONES_REMOTEEVENTS.md` - Cómo crear los RemoteEvents
- `EJEMPLOS_PERSONALIZACION_AVANZADA.md` - Ejemplos de personalización

### 💻 Código (11 archivos .lua)

#### Módulos (2)
- `ReplicatedStorage_Modules_OrbConfig.lua` - Configuración centralizada
- `ReplicatedStorage_Modules_OrbManager.lua` - Gestión de orbs

#### Scripts del Servidor (4)
- `ServerScriptService_DataManager.lua` - Persistencia de datos
- `ServerScriptService_OrbGenerator.lua` - Generador de orbs
- `ServerScriptService_MoneyManager.lua` - Sistema de dinero
- `ServerScriptService_RebirthManager.lua` - Sistema de rebirths

#### Scripts del Cliente (2)
- `StarterPlayer_StarterPlayerScripts_OrbClientManager.lua` - Orbs del cliente
- `StarterPlayer_StarterCharacterScripts_Running.lua` - Sistema de running modificado

#### Scripts de GUI (3)
- `StarterGui_PrincipalGui_Frame_SpeedDisplayScript.lua` - Display de velocidad
- `StarterGui_RebirthGui_Frame_RebirthGuiScript.lua` - GUI de rebirths
- `StarterGui_PrincipalGui_Frame_Rebirths_RebirthButtonScript.lua` - Botón de rebirths

---

## 🚀 INICIO RÁPIDO

### Opción 1: Configuración Rápida (5 minutos)
Lee: `CONFIGURACION_INICIAL_RAPIDA.md`

### Opción 2: Guía Completa (15 minutos)
Lee: `GUIA_COMPLETA_INSTALACION.md`

---

## 📋 REQUISITOS PREVIOS

- ✅ Roblox Studio instalado
- ✅ Sistema de running con animaciones Sprint y Jump
- ✅ Carpetas: workspace/FX y ReplicatedStorage/VFX/Dust
- ✅ GUI PrincipalGui básica creada

---

## ⚙️ CONFIGURACIÓN BÁSICA

### Ajustar Posiciones de Zonas

En `OrbConfig.lua`, modifica:

```lua
Position = Vector3.new(X, Y, Z),  -- Posición de tu zona
SpawnHeight = 10,                 -- Altura sobre el suelo
```

### Ajustar Valores de Orbs

```lua
SpeedBonus = 1,      -- Velocidad que otorga
MoneyReward = 10,    -- Dinero que otorga
```

### Ajustar Precios de Rebirths

```lua
BaseCost = 15000,              -- Precio inicial
CostMultiplier = 1.5,          -- Incremento por rebirth
BaseSpeedMultiplier = 1.1,     -- Multiplicador de velocidad
```

---

## 📊 ESTRUCTURA DEL PROYECTO

```
ReplicatedStorage/
├── RemoteEvents/ (3 RemoteEvents)
├── Modules/ (2 ModuleScripts)
└── VFX/Dust (existente)

ServerScriptService/
├── DataManager
├── OrbGenerator
├── MoneyManager
└── RebirthManager

StarterPlayer/
├── StarterPlayerScripts/OrbClientManager
└── StarterCharacterScripts/Running (modificado)

StarterGui/
├── PrincipalGui/ (modificado)
└── RebirthGui/ (nuevo)

Workspace/
├── FX/ (existente)
├── OrbsFolder/ (auto-generado)
└── Zones/ (auto-generado)
```

---

## 🎯 CARACTERÍSTICAS TÉCNICAS

### Optimización
- Sistema de generación distribuida de orbs
- Limpieza automática de objetos temporales
- Caché de referencias frecuentes
- Sin loops infinitos sin delays
- Uso eficiente de task.spawn

### Seguridad
- Todas las transacciones validadas servidor-side
- Cooldowns anti-spam en recolección y compras
- Verificación de tipos de datos
- Sistema de reintentos para DataStore
- Protección contra valores negativos

### Escalabilidad
- Fácil añadir nuevos tipos de orbs
- Sistema modular de zonas
- Configuración centralizada
- Código documentado y organizado

---

## 📈 ESTADÍSTICAS DEL CÓDIGO

- **Total líneas de código:** ~2,000+
- **Archivos de código:** 11
- **Archivos de documentación:** 6
- **Sistemas implementados:** 6
- **RemoteEvents:** 3
- **Módulos:** 2

---

## 🎨 PERSONALIZACIÓN

El sistema es completamente personalizable:

- ✅ Añade nuevos tipos de orbs fácilmente
- ✅ Configura zonas ilimitadas
- ✅ Modifica efectos visuales
- ✅ Ajusta valores de velocidad y dinero
- ✅ Personaliza el sistema de rebirths
- ✅ Cambia la apariencia de la GUI

Ver `EJEMPLOS_PERSONALIZACION_AVANZADA.md` para ejemplos detallados.

---

## ✅ CHECKLIST DE INSTALACIÓN

- [ ] Crear RemoteEvents (3)
- [ ] Crear Módulos (2)
- [ ] Añadir Scripts del Servidor (4)
- [ ] Añadir Scripts del Cliente (2)
- [ ] Modificar script Running
- [ ] Configurar GUI principal
- [ ] Crear GUI de Rebirths
- [ ] Ajustar posiciones de zonas
- [ ] Probar en modo de juego local
- [ ] Verificar Output sin errores

---

## 🛠️ SOLUCIÓN DE PROBLEMAS

### ¿Problemas durante la instalación?
Lee: `GUIA_COMPLETA_INSTALACION.md` - Sección "Solución de Problemas"

### ¿Errores en Output?
1. Verifica nombres exactos de RemoteEvents
2. Asegúrate de que todos los scripts estén en sus ubicaciones correctas
3. Revisa que las carpetas Modules y RemoteEvents existan

### ¿Los orbs no aparecen?
1. Ajusta las posiciones de las zonas en OrbConfig
2. Verifica que SpawnHeight sea apropiado para tu terreno
3. Revisa Output por errores

---

## 🎉 CARACTERÍSTICAS DESTACADAS

### Para Jugadores
- Sistema de progresión satisfactorio
- Orbs visualmente atractivos con efectos
- Sistema de rebirths que reinicia pero mejora
- Velocidad creciente al correr
- Persistencia de datos (no pierdes progreso)

### Para Desarrolladores
- Código limpio y documentado
- Sistema modular y escalable
- Seguro contra exploits
- Fácil de personalizar
- Sin warnings ni errores
- Optimizado para rendimiento

---

## 🌟 TODO INCLUIDO

Este sistema incluye **TODO** lo necesario:

✅ Sistema de orbs completo
✅ Sistema de running integrado
✅ Sistema de dinero
✅ Sistema de rebirths
✅ Sistema de datos (DataStore)
✅ GUIs funcionales
✅ Efectos visuales
✅ Documentación completa
✅ Ejemplos de personalización
✅ Seguridad y optimización

**Sin código omitido. Sistema 100% funcional y listo para usar.**

---

## 🚀 ¡EMPEZAR AHORA!

1. Lee `CONFIGURACION_INICIAL_RAPIDA.md` para empezar en 5 minutos
2. O lee `GUIA_COMPLETA_INSTALACION.md` para instrucciones detalladas
3. Personaliza según tus necesidades
4. ¡Disfruta tu sistema de orbs!

---

**Creado con 💙 para la comunidad de Roblox**

Sistema profesional, optimizado, seguro y completamente funcional.

¡Que tu juego sea un éxito! 🎮✨
