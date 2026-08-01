SustainMonitor = SustainMonitor or {}
local SM = SustainMonitor

local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local GetTimeString = GetTimeString
local mathFloor    = math.floor
local stringFormat = string.format

---------------------------------------------------------------------------
local LOG_MAX_ENTRIES = 2000
local LOG_SNAPSHOT_MS = 500
local logSnapshotTimer = 0
local combatStartMs    = 0

---------------------------------------------------------------------------
local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= SM.name then return end

    EVENT_MANAGER:UnregisterForEvent(SM.name .. "Load", EVENT_ADD_ON_LOADED)

    local worldName = SM.worldName
    SM.savedVars = ZO_SavedVars:NewAccountWide("SustainMonitorSV", 1, worldName, SM.defaults)
    SM.logVars   = ZO_SavedVars:NewAccountWide("SustainMonitorLog", 1, worldName, { entries = {}, info = "" })

    SM.InitCore()
    SM.InitWarnings()
    SM.CreateHUD()
    SM.InitSettings()
    SM.RegisterSlashCommands()
    SM.RegisterEvents()

    d("|cAAD1FF[Sustain Monitor]|r v" .. SM.version .. " loaded.")
end

---------------------------------------------------------------------------
function SM.LogEntry(entryType, data)
    local sv = SM.savedVars
    if not sv or not sv.debugMode then return end
    if not SM.logVars then return end

    local entries = SM.logVars.entries
    if not entries then return end
    if #entries >= LOG_MAX_ENTRIES then return end

    local now = GetGameTimeMilliseconds()
    local entry = {
        t  = now - combatStartMs,
        ty = entryType,
    }
    if data then
        for k, v in pairs(data) do
            entry[k] = v
        end
    end
    entries[#entries + 1] = entry
end

---------------------------------------------------------------------------
function SM.LogResourceSnapshot()
    local sv = SM.savedVars
    if not sv or not sv.debugMode then return end

    local now = GetGameTimeMilliseconds()
    if now - logSnapshotTimer < LOG_SNAPSHOT_MS then return end
    logSnapshotTimer = now

    for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA, POWERTYPE_HEALTH }) do
        local res = SM.GetResourceData(pt)
        if res then
            SM.LogEntry("SNAPSHOT", {
                pt   = pt,
                cur  = res.current,
                max  = res.max,
                pct  = mathFloor(res.currentPercent * 10) / 10,
                rate = mathFloor(res.burnRate),
                tte  = mathFloor(res.timeToEmpty * 10) / 10,
                cst  = res.castsRemaining or -1,
            })
        end
    end
end

---------------------------------------------------------------------------
function SM.LogCombatStart()
    local sv = SM.savedVars
    if not sv or not sv.debugMode then return end
    if not SM.logVars then return end

    SM.logVars.entries = {}
    combatStartMs = GetGameTimeMilliseconds()
    logSnapshotTimer = 0

    SM.logVars.info = stringFormat("Combat started at %s, style=%s",
        tostring(GetTimeString()), tostring(sv.displayStyle))

    SM.LogEntry("COMBAT_START", {
        ts = GetTimeString(),
    })

    for _, pt in ipairs({ POWERTYPE_MAGICKA, POWERTYPE_STAMINA, POWERTYPE_HEALTH }) do
        local res = SM.GetResourceData(pt)
        if res then
            SM.LogEntry("INITIAL_STATE", {
                pt   = pt,
                cur  = res.current,
                max  = res.max,
                pct  = mathFloor(res.currentPercent * 10) / 10,
                regen = res.regenRate,
            })
        end
    end

    SM.LogEntry("ABILITY_COSTS", {})
end

---------------------------------------------------------------------------
function SM.LogCombatEnd()
    local sv = SM.savedVars
    if not sv or not sv.debugMode then return end

    SM.LogEntry("COMBAT_END", {
        ts = GetTimeString(),
        duration_ms = GetGameTimeMilliseconds() - combatStartMs,
    })

    local count = SM.logVars and SM.logVars.entries and #SM.logVars.entries or 0
    d(stringFormat("|cAAD1FF[SM]|r Combat log: %d entries recorded. Type /reloadui to save to disk.", count))
end

---------------------------------------------------------------------------
function SM.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType,
    hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    if result == ACTION_RESULT_BEGIN and SM.TrackAbilityUsage then
        SM.TrackAbilityUsage(abilityId)
    end

    local sv = SM.savedVars
    if not sv or not sv.debugMode then return end

    if result ~= ACTION_RESULT_BEGIN
        and result ~= ACTION_RESULT_EFFECT_GAINED
        and result ~= ACTION_RESULT_DAMAGE
        and result ~= ACTION_RESULT_CRITICAL_DAMAGE
        and result ~= ACTION_RESULT_HEAL
        and result ~= ACTION_RESULT_CRITICAL_HEAL
        and result ~= ACTION_RESULT_POWER_ENERGIZE
        and result ~= ACTION_RESULT_HOT_TICK
        and result ~= ACTION_RESULT_DOT_TICK then
        return
    end

    SM.LogEntry("COMBAT", {
        ability  = abilityName,
        id       = abilityId,
        result   = result,
        value    = hitValue,
        pt       = powerType,
        target   = targetName,
    })
end

---------------------------------------------------------------------------
function SM.RegisterEvents()
    local em = EVENT_MANAGER

    em:RegisterForEvent(SM.name .. "Power", EVENT_POWER_UPDATE, SM.OnPowerUpdate)
    em:AddFilterForEvent(SM.name .. "Power", EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player")

    em:RegisterForEvent(SM.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, SM.OnCombatState)
    em:RegisterForEvent(SM.name .. "Activated", EVENT_PLAYER_ACTIVATED, SM.OnPlayerActivated)
    em:RegisterForEvent(SM.name .. "Dead",  EVENT_PLAYER_DEAD,  SM.OnPlayerDead)
    em:RegisterForEvent(SM.name .. "Alive", EVENT_PLAYER_ALIVE, SM.OnPlayerAlive)
    em:RegisterForEvent(SM.name .. "ItemUsed", EVENT_INVENTORY_ITEM_USED, SM.OnPotionUsed)

    if EVENT_ACTION_SLOTS_FULL_UPDATE then
        em:RegisterForEvent(SM.name .. "Slots", EVENT_ACTION_SLOTS_FULL_UPDATE, SM.OnActionSlotsUpdated)
    end

    if EVENT_COMBAT_EVENT then
        em:RegisterForEvent(SM.name .. "CombatLog", EVENT_COMBAT_EVENT, SM.OnCombatEvent)
        em:AddFilterForEvent(SM.name .. "CombatLog", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

    if EVENT_ACTIVE_QUICKSLOT_CHANGED then
        em:RegisterForEvent(SM.name .. "QuickslotChanged", EVENT_ACTIVE_QUICKSLOT_CHANGED, function()
            SM.ScanPotionType()
        end)
    end
end

---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SM.name .. "Load", EVENT_ADD_ON_LOADED, OnAddonLoaded)
