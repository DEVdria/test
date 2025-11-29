-- ServerScriptService > VerifySetup
-- Script de verificación para diagnosticar problemas de configuración
-- Ejecuta este script ANTES de los demás para verificar que todo esté correcto

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("========================================")
print("🔍 INICIANDO VERIFICACIÓN DEL SISTEMA")
print("========================================")

-- Verificar carpeta Modules
local modules = ReplicatedStorage:FindFirstChild("Modules")
if modules then
    print("✅ Carpeta 'Modules' encontrada en ReplicatedStorage")

    -- Verificar OrbConfig
    local orbConfig = modules:FindFirstChild("OrbConfig")
    if orbConfig and orbConfig:IsA("ModuleScript") then
        print("✅ OrbConfig encontrado (ModuleScript)")

        -- Intentar cargar
        local success, result = pcall(function()
            return require(orbConfig)
        end)

        if success then
            print("✅ OrbConfig se cargó correctamente")
            print("   - Tipos de orbs:", table.concat({"Yellow", "Green", "Blue"}, ", "))
            print("   - Zonas configuradas:", #result.Zones)
        else
            print("❌ ERROR al cargar OrbConfig:", result)
        end
    else
        print("❌ OrbConfig NO encontrado o no es ModuleScript")
        print("   SOLUCIÓN: Crea un ModuleScript llamado 'OrbConfig' en ReplicatedStorage/Modules")
    end

    -- Verificar OrbManager
    local orbManager = modules:FindFirstChild("OrbManager")
    if orbManager and orbManager:IsA("ModuleScript") then
        print("✅ OrbManager encontrado (ModuleScript)")

        -- Intentar cargar
        local success, result = pcall(function()
            return require(orbManager)
        end)

        if success then
            print("✅ OrbManager se cargó correctamente")
        else
            print("❌ ERROR al cargar OrbManager:", result)
        end
    else
        print("❌ OrbManager NO encontrado o no es ModuleScript")
        print("   SOLUCIÓN: Crea un ModuleScript llamado 'OrbManager' en ReplicatedStorage/Modules")
    end
else
    print("❌ Carpeta 'Modules' NO encontrada en ReplicatedStorage")
    print("   SOLUCIÓN: Crea una carpeta llamada 'Modules' en ReplicatedStorage")
end

print("")

-- Verificar carpeta RemoteEvents
local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if remoteEvents then
    print("✅ Carpeta 'RemoteEvents' encontrada")

    local requiredEvents = {
        "OrbCollected",
        "RequestRebirthPurchase",
        "UpdateSpeedDisplay"
    }

    for _, eventName in ipairs(requiredEvents) do
        local event = remoteEvents:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            print("✅ RemoteEvent '" .. eventName .. "' encontrado")
        else
            print("❌ RemoteEvent '" .. eventName .. "' NO encontrado")
            print("   SOLUCIÓN: Crea un RemoteEvent llamado '" .. eventName .. "' en ReplicatedStorage/RemoteEvents")
        end
    end
else
    print("❌ Carpeta 'RemoteEvents' NO encontrada")
    print("   SOLUCIÓN: Crea una carpeta llamada 'RemoteEvents' en ReplicatedStorage")
end

print("")
print("========================================")
print("🔍 VERIFICACIÓN COMPLETADA")
print("========================================")
print("")
print("Si ves ❌, sigue las soluciones indicadas")
print("Si todo tiene ✅, el sistema debería funcionar")
print("")
