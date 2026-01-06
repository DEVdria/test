# 📝 Changelog

Registro de cambios del proyecto.

## [v2.0.0] - Sistema de Fila Física - 2024

### ✨ Nuevas Características

#### 🗺️ Sistema de Fila Física
- Los jugadores ahora se mueven físicamente en el mapa
- Carpeta `LinePositions` en Workspace con posiciones numeradas
- Teletransporte suave usando TweenService
- Animaciones fluidas al avanzar en la fila
- El jugador en la primera posición tiene el turno
- Al hacer un intento, el jugador va al final y todos avanzan

#### 🎮 Indicadores Visuales
- BillboardGui "▼ TU TURNO ▼" sobre el jugador actual
- Indicador se actualiza automáticamente
- Color verde brillante para mejor visibilidad

#### ⌨️ Teclado Numérico
- Nuevo script `NumpadController.lua`
- Botones estilo calculadora (0-9)
- Display numérico
- Botones de Clear y Submit
- Solo código lógico - UI personalizable

#### 🎨 UI Personalizable
- Scripts de UI ahora solo contienen lógica
- No crean elementos visuales automáticamente
- Permite diseño totalmente personalizado
- Variables configurables para nombres de elementos

### 🔧 Mejoras

#### GameManager.lua
- Agregado TweenService para animaciones
- Nueva función `initializeLinePositions()` - carga posiciones del mapa
- Nueva función `teleportPlayerToPosition()` - mueve con animación
- Nueva función `updatePhysicalLine()` - actualiza todos los jugadores
- Nueva función `moveLineForward()` - reemplaza `nextTurn()`
- Nuevas funciones `createTurnIndicator()` y `removeTurnIndicator()`
- Mejor manejo de jugadores que entran/salen
- El índice de turno ahora siempre es 1 (primera posición)

#### Estructura de Código
- Separación de lógica y presentación
- Código más modular y reutilizable
- Mejor organización con ModuleScripts opcionales
- Comentarios más detallados

### 📚 Documentación

- ✅ Nuevo archivo `ESTRUCTURA_MAPA.md` con guía completa del mapa
- ✅ README.md actualizado con instrucciones de fila física
- ✅ CHANGELOG.md creado
- ✅ Ejemplos de código para crear posiciones
- ✅ Guía de solución de problemas expandida

### 🔄 Cambios Importantes

- `currentTurnIndex` eliminado - siempre es posición 1
- `nextTurn()` reemplazado por `moveLineForward()`
- Los jugadores se agregan al final de la fila físicamente
- Se requiere configuración del mapa antes de jugar

## [v1.0.0] - Versión Inicial

### Características Base
- ✅ Sistema de turnos básico
- ✅ Número secreto del servidor
- ✅ RemoteEvents para comunicación
- ✅ UI creada automáticamente
- ✅ Validación de intentos
- ✅ Contador de intentos
- ✅ Manejo de jugadores entrando/saliendo
- ✅ Reinicio automático al ganar

---

**Formato**: `[Versión] - Nombre - Fecha`
