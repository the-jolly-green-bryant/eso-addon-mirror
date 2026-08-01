BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

BSCAS.API = BSCAS.API or {}
BSCAS.callbackManager = BSCAS.callbackManager or ZO_CallbackObject:New()

function BSCAS.API.LoadBlockingPreset(name)
    if not name or not BSCAS:PresetExist(name) then return false end
    BSCAS.LoadSetting(name)
    BSCAS.callbackManager:FireCallbacks("BSCAS_BlockingPresetLoaded", name)
    return true
end

function BSCAS.API.LoadPriorityPreset(name)
    if not name or not BSCAS:PrioPresetExists(name) then return false end
    BSCAS:ApplyPrioPreset(name)
    BSCAS.callbackManager:FireCallbacks("BSCAS_PriorityPresetLoaded", name)
    return true
end

function BSCAS.API.LoadPresetPair(blockPreset, prioPreset)
    if blockPreset and BSCAS:PresetExist(blockPreset) then
        BSCAS.LoadSetting(blockPreset)
    end
    if prioPreset and BSCAS:PrioPresetExists(prioPreset) then
        BSCAS:ApplyPrioPreset(prioPreset)
    end
    BSCAS.callbackManager:FireCallbacks("BSCAS_PresetPairLoaded", blockPreset, prioPreset)
    return true
end