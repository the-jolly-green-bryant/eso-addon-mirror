local Addon = TheSynapticRegistry
local Watch = {}

local ADDON_LOADED_NAMESPACE = Addon.EventNamespace .. ".Loader"
local SYNERGY_NAMESPACE = Addon.EventNamespace .. ".Synergy"
local COALESCE_NAMESPACE = Addon.EventNamespace .. ".Coalesce"
local READY_NAMESPACE = Addon.EventNamespace .. ".Ready"
local ACTIVATION_NAMESPACE_PREFIX = Addon.EventNamespace .. ".Activation"
local MARKER_COMBAT_NAMESPACE_PREFIX = Addon.EventNamespace .. ".MarkerCombat"
local MARKER_EFFECT_NAMESPACE_PREFIX = Addon.EventNamespace .. ".MarkerEffect"
local BROAD_COMBAT_SOURCE_NAMESPACE = Addon.EventNamespace .. ".BroadCombatSource"
local BROAD_COMBAT_TARGET_NAMESPACE = Addon.EventNamespace .. ".BroadCombatTarget"
local BROAD_EFFECT_NAMESPACE = Addon.EventNamespace .. ".BroadEffect"
local BROAD_EFFECT_PLAYER_NAMESPACE = Addon.EventNamespace .. ".BroadEffectPlayer"



local COALESCE_MS = 250




local SHARED_COOLDOWN_ABILITY_ID = 48052
local UNDAUNTED_COMMAND_ABILITY_ID = 55677
local WATCHED_ABILITY_IDS = { SHARED_COOLDOWN_ABILITY_ID, UNDAUNTED_COMMAND_ABILITY_ID }
local MARKER_ABILITY_IDS = {
    108799, 
    108802, 
    108821, 
    108924, 
}



local AR_EFFECT_GAINED = ACTION_RESULT_EFFECT_GAINED or 2240
local AR_EFFECT_GAINED_DURATION = ACTION_RESULT_EFFECT_GAINED_DURATION or 2245

Watch.loaded = false
Watch.coalescePending = false
Watch.lockoutUntilMs = nil
Watch.lastAlertMsByName = {}

local function logInfo(...)
    if Addon.Log and Addon.Log.Info then
        Addon.Log.Info(...)
    end
end

local function logWarn(...)
    if Addon.Log and Addon.Log.Warn then
        Addon.Log.Warn(...)
    end
end

local function hasMethod(owner, methodName)
    return owner ~= nil and type(owner[methodName]) == "function"
end

local function getNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

local function isGatePassed(settings)
    if not settings.groupOnly then
        return true
    end

    if type(IsUnitGrouped) == "function" then
        return IsUnitGrouped("player") == true
    end

    return true
end

local function cancelUpdate(namespace)
    if hasMethod(EVENT_MANAGER, "UnregisterForUpdate") then
        EVENT_MANAGER:UnregisterForUpdate(namespace)
    end
end

local function scheduleUpdate(namespace, delayMs, callback)
    if not hasMethod(EVENT_MANAGER, "RegisterForUpdate") then
        return false
    end

    cancelUpdate(namespace)
    EVENT_MANAGER:RegisterForUpdate(namespace, delayMs, function()
        cancelUpdate(namespace)
        callback()
    end)
    return true
end

local function handleOffered(name)
    local settings = Addon.GetSettings()

    if not settings.enabled or not isGatePassed(settings) then
        return
    end

    local nowMs = getNowMs()
    local lastMs = Watch.lastAlertMsByName[name]

    if lastMs and (nowMs - lastMs) < settings.alertThrottleMs then
        return
    end

    Watch.lastAlertMsByName[name] = nowMs

    
    
    if Addon.Alerts then
        Addon.Alerts.Show(string.format(Addon.Strings.offered, name), nil, Addon.AlertColors.offered)
    end

    if Addon.Diagnostics then
        Addon.Diagnostics.RecordOffer(name)
    end
end

local function evaluateSynergyState()
    if type(GetCurrentSynergyInfo) ~= "function" then
        return
    end

    local hasSynergy, name = GetCurrentSynergyInfo()

    if hasSynergy == true and type(name) == "string" and name ~= "" then
        handleOffered(name)
    elseif Addon.Alerts then
        Addon.Alerts.Hide()
    end
end

local function onSynergyChanged()
    if Addon.Diagnostics then
        Addon.Diagnostics.RecordSynergyEvent()
    end

    if Watch.coalescePending then
        return
    end

    local scheduled = scheduleUpdate(COALESCE_NAMESPACE, COALESCE_MS, function()
        Watch.coalescePending = false
        evaluateSynergyState()
    end)

    if scheduled then
        Watch.coalescePending = true
    else
        evaluateSynergyState()
    end
end

local function isLockoutActive()
    return Watch.lockoutUntilMs ~= nil and getNowMs() < Watch.lockoutUntilMs
end

local function startLockout(durationMs)
    local settings = Addon.GetSettings()

    Watch.lockoutUntilMs = getNowMs() + durationMs
    cancelUpdate(READY_NAMESPACE)

    if Addon.Diagnostics then
        Addon.Diagnostics.RecordLockout(durationMs)
    end

    if not settings.readyCue then
        return
    end

    scheduleUpdate(READY_NAMESPACE, durationMs, function()
        Watch.lockoutUntilMs = nil

        local currentSettings = Addon.GetSettings()

        if currentSettings.enabled and currentSettings.readyCue and isGatePassed(currentSettings) and Addon.Alerts then
            if Addon.Diagnostics then
                Addon.Diagnostics.RecordReadyCue()
            end

            Addon.Alerts.Show(Addon.Strings.ready, currentSettings.alertDurationMs, Addon.AlertColors.ready)
        end
    end)
end

local function onCombatActivation(
    _eventCode,
    result,
    isError,
    _abilityName,
    _abilityGraphic,
    _abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    _targetType,
    hitValue,
    _powerType,
    _damageType,
    _log,
    _sourceUnitId,
    _targetUnitId,
    abilityId,
    _overflow
)
    if isError == true then
        return
    end

    
    
    if COMBAT_UNIT_TYPE_PLAYER ~= nil and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if abilityId == SHARED_COOLDOWN_ABILITY_ID then
        if Addon.Diagnostics then
            Addon.Diagnostics.RecordActivation(abilityId, sourceName, targetName)
        end

        if result == AR_EFFECT_GAINED_DURATION and type(hitValue) == "number" and hitValue > 0 then
            startLockout(hitValue)
        elseif result == AR_EFFECT_GAINED and not isLockoutActive() then
            startLockout(Addon.DefaultLockoutMs)
        end

        return
    end

    if abilityId == UNDAUNTED_COMMAND_ABILITY_ID then
        if Addon.Diagnostics then
            Addon.Diagnostics.RecordActivation(abilityId, sourceName, targetName)
        end

        if not isLockoutActive() then
            startLockout(Addon.DefaultLockoutMs)
        end
    end
end

local function onMarkerCombat(
    _eventCode,
    result,
    isError,
    abilityName,
    _abilityGraphic,
    _abilityActionSlotType,
    sourceName,
    _sourceType,
    targetName,
    _targetType,
    hitValue,
    _powerType,
    _damageType,
    _log,
    _sourceUnitId,
    _targetUnitId,
    abilityId,
    _overflow
)
    if isError == true then
        return
    end

    if Addon.Diagnostics then
        Addon.Diagnostics.RecordCombatProbe(abilityId, abilityName, result, sourceName, targetName, hitValue)
    end
end

local function onMarkerEffect(
    _eventCode,
    changeType,
    _effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    _iconName,
    _buffType,
    _effectType,
    _abilityType,
    _statusEffectType,
    unitName,
    _unitId,
    abilityId,
    sourceType
)
    if Addon.Diagnostics then
        Addon.Diagnostics.RecordEffectProbe(
            changeType,
            effectName,
            unitTag,
            beginTime,
            endTime,
            stackCount,
            unitName,
            abilityId,
            sourceType
        )
    end
end

local function onBroadCombat(
    _eventCode,
    result,
    isError,
    abilityName,
    _abilityGraphic,
    _abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    _powerType,
    _damageType,
    _log,
    sourceUnitId,
    targetUnitId,
    abilityId,
    _overflow
)
    if isError == true then
        return
    end

    if Addon.Diagnostics then
        Addon.Diagnostics.RecordBroadCombat(
            result,
            abilityName,
            sourceName,
            sourceType,
            targetName,
            targetType,
            hitValue,
            sourceUnitId,
            targetUnitId,
            abilityId
        )
    end
end

local function onBroadEffect(
    _eventCode,
    changeType,
    _effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    _iconName,
    buffType,
    effectType,
    abilityType,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType
)
    if Addon.Diagnostics then
        Addon.Diagnostics.RecordBroadEffect(
            changeType,
            effectName,
            unitTag,
            beginTime,
            endTime,
            stackCount,
            unitName,
            abilityId,
            sourceType,
            unitId,
            buffType,
            effectType,
            abilityType,
            statusEffectType
        )
    end
end

local function registerSynergyEvent()
    if not hasMethod(EVENT_MANAGER, "RegisterForEvent") then
        return false
    end

    if type(EVENT_SYNERGY_ABILITY_CHANGED) ~= "number" then
        logWarn("EVENT_SYNERGY_ABILITY_CHANGED unavailable; the Registry stays inert.")
        return false
    end

    EVENT_MANAGER:RegisterForEvent(SYNERGY_NAMESPACE, EVENT_SYNERGY_ABILITY_CHANGED, onSynergyChanged)
    return true
end

local function registerActivationEvents()
    if not hasMethod(EVENT_MANAGER, "RegisterForEvent") or type(EVENT_COMBAT_EVENT) ~= "number" then
        return false
    end

    for index = 1, #WATCHED_ABILITY_IDS do
        local abilityId = WATCHED_ABILITY_IDS[index]
        local namespace = ACTIVATION_NAMESPACE_PREFIX .. abilityId

        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, onCombatActivation)

        if hasMethod(EVENT_MANAGER, "AddFilterForEvent") then
            if REGISTER_FILTER_ABILITY_ID ~= nil then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            end

            if REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE ~= nil and COMBAT_UNIT_TYPE_PLAYER ~= nil then
                EVENT_MANAGER:AddFilterForEvent(
                    namespace,
                    EVENT_COMBAT_EVENT,
                    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
                    COMBAT_UNIT_TYPE_PLAYER
                )
            end

            if REGISTER_FILTER_IS_ERROR ~= nil then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
            end
        end
    end

    return true
end

local function registerMarkerCombatProbes()
    if not hasMethod(EVENT_MANAGER, "RegisterForEvent") or type(EVENT_COMBAT_EVENT) ~= "number" then
        return false
    end

    for index = 1, #MARKER_ABILITY_IDS do
        local abilityId = MARKER_ABILITY_IDS[index]
        local namespace = MARKER_COMBAT_NAMESPACE_PREFIX .. abilityId

        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, onMarkerCombat)

        if hasMethod(EVENT_MANAGER, "AddFilterForEvent") then
            if REGISTER_FILTER_ABILITY_ID ~= nil then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            end

            if REGISTER_FILTER_IS_ERROR ~= nil then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
            end
        end
    end

    return true
end

local function registerMarkerEffectProbes()
    if not hasMethod(EVENT_MANAGER, "RegisterForEvent") or type(EVENT_EFFECT_CHANGED) ~= "number" then
        return false
    end

    for index = 1, #MARKER_ABILITY_IDS do
        local abilityId = MARKER_ABILITY_IDS[index]
        local namespace = MARKER_EFFECT_NAMESPACE_PREFIX .. abilityId

        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, onMarkerEffect)

        if hasMethod(EVENT_MANAGER, "AddFilterForEvent") then
            if REGISTER_FILTER_ABILITY_ID ~= nil then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
            end

            if REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE ~= nil and COMBAT_UNIT_TYPE_GROUP ~= nil then
                EVENT_MANAGER:AddFilterForEvent(
                    namespace,
                    EVENT_EFFECT_CHANGED,
                    REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
                    COMBAT_UNIT_TYPE_GROUP
                )
            end
        end
    end

    return true
end

local function unregisterBroadDiagnostics()
    if hasMethod(EVENT_MANAGER, "UnregisterForEvent") then
        if type(EVENT_COMBAT_EVENT) == "number" then
            EVENT_MANAGER:UnregisterForEvent(BROAD_COMBAT_SOURCE_NAMESPACE, EVENT_COMBAT_EVENT)
            EVENT_MANAGER:UnregisterForEvent(BROAD_COMBAT_TARGET_NAMESPACE, EVENT_COMBAT_EVENT)
        end

        if type(EVENT_EFFECT_CHANGED) == "number" then
            EVENT_MANAGER:UnregisterForEvent(BROAD_EFFECT_NAMESPACE, EVENT_EFFECT_CHANGED)
            EVENT_MANAGER:UnregisterForEvent(BROAD_EFFECT_PLAYER_NAMESPACE, EVENT_EFFECT_CHANGED)
        end
    end
end

local function registerBroadCombat(namespace, filterType)
    if filterType == nil or COMBAT_UNIT_TYPE_GROUP == nil then
        return false
    end

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, onBroadCombat)
    EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, filterType, COMBAT_UNIT_TYPE_GROUP)

    if REGISTER_FILTER_IS_ERROR ~= nil then
        EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    end

    return true
end

local function registerBroadEffect(namespace, targetType)
    if targetType == nil then
        return false
    end

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, onBroadEffect)
    EVENT_MANAGER:AddFilterForEvent(
        namespace,
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
        targetType
    )

    return true
end

local function setBroadDiagnostics(enabled)
    local settings = Addon.GetSettings()

    settings.diagnosticBroadEnabled = enabled == true
    unregisterBroadDiagnostics()

    if not settings.diagnosticBroadEnabled then
        if Addon.Diagnostics then
            Addon.Diagnostics.Render()
        end

        logInfo(Addon.Strings.broadDiagnosticsDisabled)
        return false
    end

    if not hasMethod(EVENT_MANAGER, "RegisterForEvent")
        or not hasMethod(EVENT_MANAGER, "AddFilterForEvent") then
        settings.diagnosticBroadEnabled = false
        logWarn("Wide diagnostics unavailable; required event filters are missing.")
        return false
    end

    local registered = false

    if type(EVENT_COMBAT_EVENT) == "number" then
        registered = registerBroadCombat(BROAD_COMBAT_SOURCE_NAMESPACE, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE)
            or registered
        registered = registerBroadCombat(BROAD_COMBAT_TARGET_NAMESPACE, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE)
            or registered
    end

    if type(EVENT_EFFECT_CHANGED) == "number" and REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE ~= nil then
        registered = registerBroadEffect(BROAD_EFFECT_NAMESPACE, COMBAT_UNIT_TYPE_GROUP)
            or registered
        registered = registerBroadEffect(BROAD_EFFECT_PLAYER_NAMESPACE, COMBAT_UNIT_TYPE_PLAYER)
            or registered
    end

    if not registered then
        settings.diagnosticBroadEnabled = false
        logWarn("Wide diagnostics unavailable; no broad event registration succeeded.")
        return false
    end

    if Addon.Diagnostics then
        Addon.Diagnostics.Render()
    end

    logInfo(Addon.Strings.broadDiagnosticsEnabled)
    return true
end

local function lockoutRemainingMs()
    if not isLockoutActive() then
        return 0
    end

    return Watch.lockoutUntilMs - getNowMs()
end

local function printStatus()
    local settings = Addon.GetSettings()

    logInfo(Addon.Strings.statusHeader, {
        enabled = settings.enabled,
        groupOnly = settings.groupOnly,
        readyCue = settings.readyCue,
        alertThrottleMs = settings.alertThrottleMs,
        lockoutRemainingMs = lockoutRemainingMs(),
    })
end

local function setEnabled(enabled)
    local settings = Addon.GetSettings()

    settings.enabled = enabled == true

    if settings.enabled then
        logInfo(Addon.Strings.enabled)
    else
        logInfo(Addon.Strings.disabled)

        if Addon.Alerts then
            Addon.Alerts.Hide()
        end
    end
end

local function setFlag(flagName, value)
    local settings = Addon.GetSettings()

    settings[flagName] = value
    logInfo("Setting updated.", { setting = flagName, value = value })
end

local function handleSlashCommand(rawArgs)
    local input = string.lower(tostring(rawArgs or ""))
    local command, argument = string.match(input, "^%s*(%S+)%s*(%S*)")
    command = command or "status"

    if command == "on" then
        setEnabled(true)
        return
    end

    if command == "off" then
        setEnabled(false)
        return
    end

    if command == "status" or command == "" then
        printStatus()
        return
    end

    if command == "report" then
        if Addon.Diagnostics then
            Addon.Diagnostics.Report()
        else
            logWarn("Diagnostics unavailable.")
        end

        return
    end

    if command == "cue" and (argument == "on" or argument == "off") then
        setFlag("readyCue", argument == "on")
        return
    end

    if command == "gate" and (argument == "on" or argument == "off") then
        setFlag("groupOnly", argument == "on")
        return
    end

    if command == "diag" and (argument == "on" or argument == "off") then
        if Addon.Diagnostics then
            Addon.Diagnostics.SetEnabled(argument == "on")
        else
            setFlag("diagnosticsEnabled", argument == "on")
        end

        if argument == "on" then
            logInfo(Addon.Strings.diagnosticsEnabled)
        else
            logInfo(Addon.Strings.diagnosticsDisabled)
        end

        return
    end

    if command == "diag" and argument == "reset" then
        if Addon.Diagnostics then
            Addon.Diagnostics.Reset()
        end

        logInfo(Addon.Strings.diagnosticsReset)
        return
    end

    if command == "broad" and (argument == "on" or argument == "off") then
        setBroadDiagnostics(argument == "on")
        return
    end

    logWarn(Addon.Strings.unknownCommand, { valid = Addon.Strings.validCommands })
end

local function registerSlashCommands()
    if type(SLASH_COMMANDS) ~= "table" then
        return
    end

    SLASH_COMMANDS["/synreg"] = handleSlashCommand
end

function Watch.Initialize()
    if Watch.loaded then
        return
    end

    Watch.loaded = true
    Addon.InitializeSettings()
    registerSlashCommands()

    if type(GetCurrentSynergyInfo) ~= "function" then
        logWarn("GetCurrentSynergyInfo unavailable; the Registry stays inert.")
        return
    end

    registerSynergyEvent()
    registerActivationEvents()
    registerMarkerCombatProbes()
    registerMarkerEffectProbes()

    if Addon.GetSettings().diagnosticBroadEnabled == true then
        setBroadDiagnostics(true)
    end

    logInfo("The Synaptic Registry is calibrated.")
end

local function onAddOnLoaded(_eventCode, addonName)
    if addonName ~= Addon.Name then
        return
    end

    if hasMethod(EVENT_MANAGER, "UnregisterForEvent") then
        EVENT_MANAGER:UnregisterForEvent(ADDON_LOADED_NAMESPACE, EVENT_ADD_ON_LOADED)
    end

    Watch.Initialize()
end

if hasMethod(EVENT_MANAGER, "RegisterForEvent") then
    EVENT_MANAGER:RegisterForEvent(ADDON_LOADED_NAMESPACE, EVENT_ADD_ON_LOADED, onAddOnLoaded)
else
    logWarn("EVENT_MANAGER unavailable; The Synaptic Registry loader not registered.")
end

Addon.SynergyWatch = Watch
