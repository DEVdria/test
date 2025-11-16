# Troll GUI - Instrucciones de Configuración

## Estructura en Roblox Studio:

```
StarterGui
└── TrollGui (ScreenGui)
    └── Frame
        └── TrollButton (TextButton)
            └── TrollButton.lua (LocalScript) ← Coloca aquí el script
```

## Pasos para crear la GUI:

### 1. Crear el ScreenGui:
- En **StarterGui**, crea un **ScreenGui**
- Nómbralo: `TrollGui`

### 2. Crear el Frame:
- Dentro de TrollGui, crea un **Frame**
- Propiedades recomendadas:
  - **Size**: `{0.3, 0}, {0.15, 0}` (UDim2)
  - **Position**: `{0.35, 0}, {0.85, 0}` (UDim2) - Abajo centro
  - **BackgroundColor3**: `RGB(30, 30, 30)` - Negro oscuro
  - **BackgroundTransparency**: `0.3`
  - **BorderSizePixel**: `2`
  - **AnchorPoint**: `0.5, 1`

### 3. Crear el TextButton:
- Dentro del Frame, crea un **TextButton**
- Nómbralo: `TrollButton`
- Propiedades recomendadas:
  - **Size**: `{0.9, 0}, {0.7, 0}` (UDim2)
  - **Position**: `{0.5, 0}, {0.5, 0}` (UDim2)
  - **AnchorPoint**: `0.5, 0.5`
  - **BackgroundColor3**: `RGB(100, 100, 100)` - Gris (bloqueado)
  - **Text**: `"🔒 TROLL (Comprar)"`
  - **TextScaled**: `true`
  - **Font**: `SourceSansBold` o `GothamBold`
  - **BorderSizePixel**: `2`

### 4. Agregar el LocalScript:
- Dentro de **TrollButton**, crea un **LocalScript**
- Nómbralo: `TrollButton`
- Copia el contenido de `TrollButton.lua` en este LocalScript

### 5. Opcional - UICorner:
- Agrega un **UICorner** dentro del Frame y del TrollButton para esquinas redondeadas
- **CornerRadius**: `UDim(0.1, 0)`

## Personalización:

Puedes personalizar los colores, tamaño y posición según tu preferencia.
El script cambiará automáticamente el color cuando el producto sea comprado.
