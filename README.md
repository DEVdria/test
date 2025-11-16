# 🎮 Sistema de Developer Products para Roblox

Sistema completo de monetización usando Developer Products de Roblox, con botón Troll y sistema de donaciones.

## 🌟 Características

### 1. Botón Troll
- GUI visible para todos los jugadores
- Requiere comprar un Developer Product para desbloquearse
- Al activarse: elimina a todos los jugadores del servidor
- Feedback visual de compra y activación

### 2. Cofre de Donaciones
- Objeto interactivo en el Workspace
- ProximityPrompt para activación fácil
- Abre GUI de donaciones al interactuar

### 3. GUI de Donaciones
- 5 niveles de donación configurables
- Cada botón conectado a un Developer Product diferente
- Animaciones fluidas y feedback visual
- Mensaje de agradecimiento al donar

## 📚 Documentación

- **[INSTRUCCIONES_COMPLETAS.md](./INSTRUCCIONES_COMPLETAS.md)** - Guía paso a paso completa
- **[REFERENCIA_RAPIDA.md](./REFERENCIA_RAPIDA.md)** - Referencia rápida de 5 minutos
- **Carpetas individuales** - Cada carpeta contiene su propio README con instrucciones específicas

## 🚀 Inicio Rápido

1. **Crear Developer Products** en [Roblox Creator Dashboard](https://create.roblox.com/)
2. **Configurar IDs** en `ServerScriptService/DeveloperProductsHandler.lua`
3. **Ejecutar** `CreateRemoteEvents.lua` una vez en Studio
4. **Crear las GUIs** siguiendo los READMEs en cada carpeta
5. **Publicar** tu juego y probar

## 📁 Estructura del Proyecto

```
├── ServerScriptService/
│   ├── DeveloperProductsHandler.lua    # Script principal del servidor
│   └── CreateRemoteEvents.lua          # Crear RemoteEvents (ejecutar una vez)
│
├── ReplicatedStorage/
│   └── RemoteEvents/                   # RemoteEvents para comunicación
│       └── README.md
│
├── StarterGui/
│   ├── TrollGui/                       # GUI del botón Troll
│   │   ├── TrollButton.lua
│   │   └── README.md
│   └── DonacionesGui/                  # GUI de donaciones
│       ├── DonationsScript.lua
│       └── README.md
│
├── Workspace/
│   └── DonationChest/                  # Cofre interactivo
│       ├── ChestScript.lua
│       └── README.md
│
├── INSTRUCCIONES_COMPLETAS.md          # Guía completa
└── REFERENCIA_RAPIDA.md                # Referencia rápida
```

## ⚠️ Importante

- **Los IDs de productos deben configurarse** en `DeveloperProductsHandler.lua`
- **Las compras solo funcionan en el juego publicado**, no en Roblox Studio
- **Todos los scripts están completamente documentados** en español
- **Cada carpeta tiene su propio README** con instrucciones específicas

## 🛠️ Tecnologías Usadas

- **Lua** - Lenguaje de programación de Roblox
- **MarketplaceService** - Sistema de monetización de Roblox
- **RemoteEvents** - Comunicación cliente-servidor
- **ProximityPrompt** - Interacción con objetos en el mundo
- **TweenService** - Animaciones fluidas (usado en los scripts)

## 📝 Notas

- Todos los scripts incluyen comentarios detallados en español
- El código es modular y fácil de personalizar
- Sistema de seguridad para prevenir uso no autorizado del botón Troll
- Feedback visual completo para todas las acciones

## 🎨 Personalización

Puedes personalizar:
- Precios de los Developer Products
- Colores y estilos de las GUIs
- Efecto del botón Troll (actualmente mata a todos)
- Recompensas por donaciones
- Cantidad de botones de donación

Consulta `INSTRUCCIONES_COMPLETAS.md` para detalles de personalización.

## 📄 Licencia

Este código es de uso libre para tu juego de Roblox.

---

**¿Necesitas ayuda?** Consulta la sección "Solución de Problemas" en `INSTRUCCIONES_COMPLETAS.md`