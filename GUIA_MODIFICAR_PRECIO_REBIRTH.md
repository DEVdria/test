# 💰 CÓMO MODIFICAR EL PRECIO DE REBIRTH

## 📍 Ubicación del archivo

**Archivo:** `ReplicatedStorage > Modules > OrbConfig`
**Tipo:** ModuleScript

---

## 🔧 DÓNDE MODIFICAR

Abre **OrbConfig** en Roblox Studio y busca la sección de **CONFIGURACIÓN DE REBIRTHS** (alrededor de la línea 95-105):

```lua
-- ==================== CONFIGURACIÓN DE REBIRTHS ====================
OrbConfig.Rebirth = {
	BaseCost = 15000,                            -- ← CAMBIAR AQUÍ
	CostMultiplier = 1.5,                        -- ← CAMBIAR AQUÍ
	BaseEXPMultiplier = 1.1,
	EXPMultiplierIncrease = 0.05,
}
```

---

## 💵 PARÁMETROS EXPLICADOS

### **BaseCost** - Precio del primer rebirth
```lua
BaseCost = 15000,  -- Primer rebirth cuesta $15,000
```

**Ejemplos:**
- `BaseCost = 10000` → Primer rebirth cuesta $10,000
- `BaseCost = 50000` → Primer rebirth cuesta $50,000
- `BaseCost = 100000` → Primer rebirth cuesta $100,000

---

### **CostMultiplier** - Cuánto aumenta el precio cada rebirth
```lua
CostMultiplier = 1.5,  -- Cada rebirth cuesta 50% más que el anterior
```

**Cómo funciona:**
```
Rebirth 1: $15,000
Rebirth 2: $15,000 × 1.5 = $22,500
Rebirth 3: $22,500 × 1.5 = $33,750
Rebirth 4: $33,750 × 1.5 = $50,625
```

**Ejemplos:**
- `CostMultiplier = 1.2` → Aumenta 20% cada vez (más fácil)
- `CostMultiplier = 1.5` → Aumenta 50% cada vez (balanceado)
- `CostMultiplier = 2.0` → Aumenta 100% cada vez (se duplica, más difícil)
- `CostMultiplier = 3.0` → Aumenta 200% cada vez (se triplica, muy difícil)

---

## 📊 TABLA DE PRECIOS POR CONFIGURACIÓN

### Configuración FÁCIL
```lua
BaseCost = 10000,
CostMultiplier = 1.2,
```
| Rebirth | Precio |
|---|---|
| 1 | $10,000 |
| 2 | $12,000 |
| 3 | $14,400 |
| 4 | $17,280 |
| 5 | $20,736 |

---

### Configuración NORMAL (Actual)
```lua
BaseCost = 15000,
CostMultiplier = 1.5,
```
| Rebirth | Precio |
|---|---|
| 1 | $15,000 |
| 2 | $22,500 |
| 3 | $33,750 |
| 4 | $50,625 |
| 5 | $75,937 |

---

### Configuración DIFÍCIL
```lua
BaseCost = 50000,
CostMultiplier = 2.0,
```
| Rebirth | Precio |
|---|---|
| 1 | $50,000 |
| 2 | $100,000 |
| 3 | $200,000 |
| 4 | $400,000 |
| 5 | $800,000 |

---

### Configuración MUY DIFÍCIL
```lua
BaseCost = 100000,
CostMultiplier = 3.0,
```
| Rebirth | Precio |
|---|---|
| 1 | $100,000 |
| 2 | $300,000 |
| 3 | $900,000 |
| 4 | $2,700,000 |
| 5 | $8,100,000 |

---

## 🎯 RECOMENDACIONES

### Para juegos CASUALES (fácil progresión):
```lua
BaseCost = 5000,
CostMultiplier = 1.3,
```

### Para juegos NORMALES (balanceado):
```lua
BaseCost = 15000,
CostMultiplier = 1.5,
```

### Para juegos COMPETITIVOS (difícil):
```lua
BaseCost = 25000,
CostMultiplier = 1.8,
```

### Para juegos GRIND (muy difícil):
```lua
BaseCost = 50000,
CostMultiplier = 2.5,
```

---

## 🔄 OTROS PARÁMETROS DE REBIRTH

En la misma sección puedes modificar:

### **BaseEXPMultiplier** - Multiplicador de EXP del primer rebirth
```lua
BaseEXPMultiplier = 1.1,  -- Primer rebirth da +10% EXP
```

**Ejemplos:**
- `BaseEXPMultiplier = 1.05` → +5% EXP (menos boost)
- `BaseEXPMultiplier = 1.1` → +10% EXP (actual)
- `BaseEXPMultiplier = 1.25` → +25% EXP (más boost)
- `BaseEXPMultiplier = 1.5` → +50% EXP (mucho boost)

---

### **EXPMultiplierIncrease** - Cuánto aumenta el multiplicador por rebirth
```lua
EXPMultiplierIncrease = 0.05,  -- Cada rebirth añade +5% más de EXP
```

**Cómo funciona:**
```
Rebirth 1: x1.10 EXP (10%)
Rebirth 2: x1.15 EXP (15%)
Rebirth 3: x1.20 EXP (20%)
Rebirth 4: x1.25 EXP (25%)
```

**Ejemplos:**
- `EXPMultiplierIncrease = 0.03` → +3% por rebirth (progresión lenta)
- `EXPMultiplierIncrease = 0.05` → +5% por rebirth (actual)
- `EXPMultiplierIncrease = 0.10` → +10% por rebirth (progresión rápida)

---

## 💡 EJEMPLOS DE CONFIGURACIÓN COMPLETA

### Juego CASUAL (Progresión rápida)
```lua
OrbConfig.Rebirth = {
	BaseCost = 5000,
	CostMultiplier = 1.2,
	BaseEXPMultiplier = 1.2,          -- +20% EXP desde rebirth 1
	EXPMultiplierIncrease = 0.10,     -- +10% adicional por rebirth
}
```

### Juego NORMAL (Balanceado)
```lua
OrbConfig.Rebirth = {
	BaseCost = 15000,
	CostMultiplier = 1.5,
	BaseEXPMultiplier = 1.1,          -- +10% EXP desde rebirth 1
	EXPMultiplierIncrease = 0.05,     -- +5% adicional por rebirth
}
```

### Juego COMPETITIVO (Grind medio)
```lua
OrbConfig.Rebirth = {
	BaseCost = 30000,
	CostMultiplier = 1.7,
	BaseEXPMultiplier = 1.15,         -- +15% EXP desde rebirth 1
	EXPMultiplierIncrease = 0.07,     -- +7% adicional por rebirth
}
```

### Juego GRIND (Progresión lenta, mucho farmeo)
```lua
OrbConfig.Rebirth = {
	BaseCost = 100000,
	CostMultiplier = 2.0,
	BaseEXPMultiplier = 1.1,          -- +10% EXP desde rebirth 1
	EXPMultiplierIncrease = 0.03,     -- +3% adicional por rebirth
}
```

---

## 📋 CHECKLIST

Después de modificar:

1. ✅ Guardaste el archivo en Roblox Studio
2. ✅ Probaste el precio en el juego (abre RebirthGui)
3. ✅ Verificaste que el precio se muestra correctamente
4. ✅ Probaste comprar un rebirth para verificar que funciona

---

## 🔍 FÓRMULA DE CÁLCULO

Si quieres calcular el precio de un rebirth específico:

```lua
Precio = BaseCost × (CostMultiplier ^ (Rebirths actuales))
```

**Ejemplo con BaseCost = 15000 y CostMultiplier = 1.5:**
```
Rebirth 1: 15000 × (1.5 ^ 0) = 15000
Rebirth 2: 15000 × (1.5 ^ 1) = 22500
Rebirth 3: 15000 × (1.5 ^ 2) = 33750
Rebirth 4: 15000 × (1.5 ^ 3) = 50625
```

---

## 🎯 RESUMEN RÁPIDO

**Para cambiar el precio de rebirths:**

1. Abre: `ReplicatedStorage > Modules > OrbConfig`
2. Busca: `OrbConfig.Rebirth`
3. Cambia:
   - `BaseCost` = Precio del primer rebirth
   - `CostMultiplier` = Cuánto aumenta cada vez
4. Guarda y prueba en el juego

**¡Así de simple!** 🎉
