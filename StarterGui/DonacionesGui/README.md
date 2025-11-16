# Donations GUI - Instrucciones de Configuración

## Estructura en Roblox Studio:

```
StarterGui
└── DonacionesGui (ScreenGui)
    ├── DonationsScript (LocalScript) ← Script principal
    └── MainFrame (Frame)
        ├── Title (TextLabel)
        ├── CloseButton (TextButton)
        ├── ThankYouLabel (TextLabel)
        └── DonationsContainer (Frame)
            ├── UIGridLayout
            ├── Button1 (TextButton)
            ├── Button2 (TextButton)
            ├── Button3 (TextButton)
            ├── Button4 (TextButton)
            └── Button5 (TextButton)
```

## Pasos para crear la GUI:

### 1. Crear el ScreenGui:
- En **StarterGui**, crea un **ScreenGui**
- Nómbralo: `DonacionesGui`
- **Enabled**: `false` (se activa cuando se abre el cofre)

### 2. Crear el MainFrame:
- Dentro de DonacionesGui, crea un **Frame**
- Nómbralo: `MainFrame`
- Propiedades:
  - **Size**: `{0.4, 0}, {0.6, 0}`
  - **Position**: `{0.5, 0}, {0.5, 0}`
  - **AnchorPoint**: `0.5, 0.5`
  - **BackgroundColor3**: `RGB(40, 40, 40)`
  - **BackgroundTransparency**: `0.1`
  - **BorderSizePixel**: `3`
  - **BorderColor3**: `RGB(255, 215, 0)` (Dorado)

### 3. Crear el Title (Título):
- Dentro de MainFrame, crea un **TextLabel**
- Nómbralo: `Title`
- Propiedades:
  - **Size**: `{1, 0}, {0.15, 0}`
  - **Position**: `{0, 0}, {0, 0}`
  - **BackgroundTransparency**: `1`
  - **Text**: `"💰 DONACIONES 💰"`
  - **TextScaled**: `true`
  - **Font**: `GothamBold` o `SourceSansBold`
  - **TextColor3**: `RGB(255, 215, 0)` (Dorado)

### 4. Crear el CloseButton:
- Dentro de MainFrame, crea un **TextButton**
- Nómbralo: `CloseButton`
- Propiedades:
  - **Size**: `{0.1, 0}, {0.1, 0}`
  - **Position**: `{0.9, 0}, {0.02, 0}`
  - **AnchorPoint**: `0.5, 0`
  - **BackgroundColor3**: `RGB(255, 85, 85)` (Rojo)
  - **Text**: `"X"`
  - **TextScaled**: `true`
  - **Font**: `GothamBold`
  - **TextColor3**: `RGB(255, 255, 255)`

### 5. Crear el ThankYouLabel (Mensaje de agradecimiento):
- Dentro de MainFrame, crea un **TextLabel**
- Nómbralo: `ThankYouLabel`
- Propiedades:
  - **Size**: `{0.8, 0}, {0.15, 0}`
  - **Position**: `{0.5, 0}, {0.5, 0}`
  - **AnchorPoint**: `0.5, 0.5`
  - **BackgroundColor3**: `RGB(85, 255, 127)` (Verde)
  - **BackgroundTransparency**: `0.2`
  - **Text**: `"✅ ¡GRACIAS POR TU DONACIÓN!"`
  - **TextScaled**: `true`
  - **Font**: `GothamBold`
  - **TextColor3**: `RGB(255, 255, 255)`
  - **Visible**: `false` (se muestra cuando donan)
  - **ZIndex**: `10`

### 6. Crear el DonationsContainer:
- Dentro de MainFrame, crea un **Frame**
- Nómbralo: `DonationsContainer`
- Propiedades:
  - **Size**: `{0.9, 0}, {0.7, 0}`
  - **Position**: `{0.5, 0}, {0.55, 0}`
  - **AnchorPoint**: `0.5, 0.5`
  - **BackgroundTransparency**: `1`

### 7. Agregar UIGridLayout:
- Dentro de DonationsContainer, crea un **UIGridLayout**
- Propiedades:
  - **CellPadding**: `{0.05, 0}, {0.05, 0}`
  - **CellSize**: `{0.45, 0}, {0.28, 0}`
  - **FillDirection**: `Horizontal`
  - **HorizontalAlignment**: `Center`
  - **VerticalAlignment**: `Top`
  - **SortOrder**: `Name`

### 8. Crear los 5 Botones de Donación:
Dentro de DonationsContainer, crea **5 TextButtons** con estos nombres:
- `Button1`
- `Button2`
- `Button3`
- `Button4`
- `Button5`

**Propiedades para TODOS los botones:**
- **Text**: `"Botón"` (el script lo cambiará automáticamente)
- **TextScaled**: `true`
- **Font**: `GothamBold`
- **TextColor3**: `RGB(255, 255, 255)`
- **BackgroundTransparency**: `0.1`
- **BorderSizePixel**: `2`
- **BorderColor3**: `RGB(255, 255, 255)`

### 9. Agregar el LocalScript:
- Dentro de **MainFrame**, crea un **LocalScript**
- Nómbralo: `DonationsScript`
- Copia el contenido de `DonationsScript.lua`

### 10. Opcional - UICorner:
Para esquinas redondeadas, agrega **UICorner** a:
- MainFrame (CornerRadius: `0.05, 0`)
- CloseButton (CornerRadius: `0.2, 0`)
- ThankYouLabel (CornerRadius: `0.1, 0`)
- Cada Button1-5 (CornerRadius: `0.1, 0`)

## Personalización:

### Cambiar los valores de donación:
Edita el script `DonationsScript.lua` en la sección `donationButtons`:
```lua
local donationButtons = {
    {name = "Donacion1", text = "💵 5 Robux", color = Color3.fromRGB(85, 170, 255)},
    {name = "Donacion2", text = "💰 10 Robux", color = Color3.fromRGB(85, 255, 127)},
    -- etc...
}
```

### Agregar más botones:
1. Crea más TextButtons (Button6, Button7, etc.)
2. Agrega más entradas en `donationButtons` en el script
3. Ajusta el `CellSize` del UIGridLayout si es necesario

### Cambiar colores y estilo:
Todos los colores pueden personalizarse en las propiedades de cada elemento.
