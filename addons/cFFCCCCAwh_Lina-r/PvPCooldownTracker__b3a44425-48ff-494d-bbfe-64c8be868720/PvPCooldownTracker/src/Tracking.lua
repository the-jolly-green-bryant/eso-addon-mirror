PvPCooldownTracker = PvPCooldownTracker or {}
PvPCooldownTracker.Tracking = {}
d("[PvPCooldownTracker] Tracking.lua loaded - module created")

local EM = EVENT_MANAGER
local updateIntervalMs = 100
PvPCooldownTracker.first_run = PvPCooldownTracker.first_run or {}

local ignoreAbilityId = {
    [973] = true,
    [15356] = true,
    [14890] = true,
    [55146] = true,
    [28549] = true,
    [29721] = true,
    [98294] = true,
    [69143] = true,
}

local setAliases = {
    ["Two-Fanged Snake"] = "Twice-Fanged Serpent",
}

local function StartCooldown(setKey)
    local set = PvPCooldownTracker.Data.Sets[setKey]
    if not set then return end
    local savedSet = PvPCooldownTracker.preferences.sets[setKey]
    if not savedSet then return end

    set.timeOfProc = GetGameTimeMilliseconds()

    if PvPCooldownTracker.preferences.lagCompensation then
        set.timeOfProc = set.timeOfProc + GetFrameDeltaTimeMilliseconds()
    end

    local procDelayMs = tonumber(set.procDelayMs) or 0
    if procDelayMs > 0 then
        set.timeOfProc = set.timeOfProc + procDelayMs
    end

    set.onCooldown = true
    set.enabled = true
    set.justProcced = true
    PvPCooldownTracker.first_run[setKey] = true

    PvPCooldownTracker.UI.PlaySound(savedSet.sounds.onProc)
    EM:RegisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count", updateIntervalMs, function(...) PvPCooldownTracker.UI.Update(setKey) return end)
end
-- ----------------------------------------------------------------------------
-- Callback Functions
-- ----------------------------------------------------------------------------

local function OnCooldownUpdated(setKey, eventCode, abilityId)
    -- When cooldown of this ability occurs, this function is continually called
    -- until the set is off cooldown.
    -- We can use the first call of this function to detect a proc state.

    local set = PvPCooldownTracker.Data.Sets[setKey]

    -- Ignore if set is on cooldown
    if set.onCooldown == true then return end

    StartCooldown(setKey)

    PvPCooldownTracker:Trace(1, "Cooldown proc for <<1>> (<<2>>)", setKey, abilityId)
end

local function OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)

    local set = PvPCooldownTracker.Data.Sets[setKey]

    if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
        PvPCooldownTracker:Trace(1, "<<1>> (<<2>>) on Cooldown", abilityName, abilityId)
        return
    end

    if result == set.result then
        PvPCooldownTracker:Trace(1, "Name: <<1>> ID: <<2>> with result <<3>> INFO", abilityName, abilityId, result)
        StartCooldown(setKey)
    end

end

local function IsInCombat(_, inCombat)
    PvPCooldownTracker.isInCombat = inCombat
    PvPCooldownTracker:Trace(2, "In Combat: <<1>>", tostring(inCombat))
    PvPCooldownTracker.UI:SetCombatStateDisplay()
end

local function OnAlive()
    PvPCooldownTracker.isDead = false
    PvPCooldownTracker.UI:SetCombatStateDisplay()
end

local function OnDeath()
    PvPCooldownTracker.isDead = true
    PvPCooldownTracker.UI:SetCombatStateDisplay()
end

local function OnCombatEventUnfiltered(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if ignoreAbilityId[abilityId] then return end

    PvPCooldownTracker:Trace(1, "<<1>> (<<2>>) with result <<3>>", abilityName, abilityId, result)
end

local function OnEffectChangedUnfiltered(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if ignoreAbilityId[abilityId] then return end

    PvPCooldownTracker:Trace(1, "<<1>> (<<2>>) with change type <<3>> <<4>>", effectName, abilityId, changeType, iconName)
end

-- ----------------------------------------------------------------------------
-- Event Register/Unregister
-- ----------------------------------------------------------------------------

function PvPCooldownTracker.Tracking.RegisterUnfiltered()
    --EM:RegisterForEvent(PvPCooldownTracker.name .. "_UnfilteredEffect", EVENT_EFFECT_CHANGED, OnEffectChangedUnfiltered)
    --EM:AddFilterForEvent(PvPCooldownTracker.name .. "_UnfilteredEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(PvPCooldownTracker.name .. "_Unfiltered", EVENT_COMBAT_EVENT, OnCombatEventUnfiltered)
    EM:AddFilterForEvent(PvPCooldownTracker.name .. "_Unfiltered", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    PvPCooldownTracker:Trace(1, "Registered Unfiltered Events")
end

function PvPCooldownTracker.Tracking.UnregisterUnfiltered()
    EM:UnregisterForEvent(PvPCooldownTracker.name .. "_Unfiltered", EVENT_COMBAT_EVENT)
    PvPCooldownTracker:Trace(1, "Unregistered Unfiltered Events")
end

function PvPCooldownTracker.Tracking.RegisterEvents()
    EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_ALIVE, OnAlive)
    EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_DEAD, OnDeath)

    if not PvPCooldownTracker.preferences.showOutsideCombat then
        PvPCooldownTracker.Tracking.RegisterCombatEvent()
    end

    PvPCooldownTracker:Trace(2, "Registered Events")
end

function PvPCooldownTracker.Tracking.UnregisterEvents()
    EM:UnregisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_ALIVE)
    EM:UnregisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_DEAD)
    PvPCooldownTracker:Trace(2, "Unregistered Events")
end

function PvPCooldownTracker.Tracking.RegisterCombatEvent()
    EM:RegisterForEvent(PvPCooldownTracker.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, IsInCombat)
    PvPCooldownTracker:Trace(2, "Registered combat events")
end

function PvPCooldownTracker.Tracking.UnregisterCombatEvent()
    EM:UnregisterForEvent(PvPCooldownTracker.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
    PvPCooldownTracker:Trace(2, "Unregistered combat events")
end

-- ----------------------------------------------------------------------------
-- Utility Functions
-- ----------------------------------------------------------------------------

local function RenameWhenPerfectSet(setKey)
    -- Check for Perfect/Perfected
    local isPerfect = string.find(setKey, "Perfect", 1, true)

    -- Only if a perfect set is suspect do we run through
    -- our table of "Perfect" strings to replace
    if isPerfect ~= nil and isPerfect > 0 then
        PvPCooldownTracker:Trace(3, "Perfect suspect, string matches: <<1>>", isPerfect)

        -- Normalize Perfect and Non-Perfect variant names
        for _, perfectString in ipairs(PvPCooldownTracker.Data.PerfectString) do

            -- Find strings related to being Perfect
            local newSetKey, count = string.gsub(setKey, perfectString, "")

            -- Update name if a perfect version is detected
            if count > 0 then
                PvPCooldownTracker:Trace(1, "Found <<1>> version of <<2>>", perfectString, newSetKey)
                return newSetKey
            end

            PvPCooldownTracker:Trace(3, "Perfect suspect, but no match for \"<<1>>\"", perfectString)
        end
    end

    -- Return unmodified if perfect could not be matched
    return setKey

end

function PvPCooldownTracker:Debug(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, HitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not isError then
            d(string.format("Target Name: %s Ability ID: %d Ability Name: %s Result: %s Ability Graphic: %s",targetName, abilityId, abilityName, result, abilityGraphic))
    end
end

function PvPCooldownTracker.Tracking.EnableTrackingForSet(setKey, enabled)

    setKey = RenameWhenPerfectSet(setKey);
    setKey = setAliases[setKey] or setKey
    local set = PvPCooldownTracker.Data.Sets[setKey]

    -- Ignore sets not in our table
    if set == nil then return end


    -- Full bonus active
    if enabled then

        -- Check manual disable first
        if type(PvPCooldownTracker.character) == "table"
            and type(PvPCooldownTracker.character[set.procType]) == "table"
            and PvPCooldownTracker.character[set.procType][setKey] == false then
            -- Skip enabling set
            PvPCooldownTracker:Trace(1, "Force disabled <<1>>, skipping enable", setKey)
            return
        end

        PvPCooldownTracker:Trace(1, "Enabling tracking for <<1>>", setKey)

        -- Set callback based on event
        local procFunction = nil
        if set.event == EVENT_ABILITY_COOLDOWN_UPDATED then
            procFunction = OnCooldownUpdated
        else
            procFunction = OnCombatEvent
        end

        -- Register events (re-registering same event key is safe and refreshes stale callback state).
        if type(set.id) == 'table' then
            for i=1, #set.id do
                EM:RegisterForEvent(PvPCooldownTracker.name .. "_" .. set.id[i], set.event, function(...) procFunction(setKey, ...) end)
                EM:AddFilterForEvent(PvPCooldownTracker.name .. "_" .. set.id[i], set.event,
                    REGISTER_FILTER_ABILITY_ID, set.id[i],
                    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
            end
        else
            EM:RegisterForEvent(PvPCooldownTracker.name .. "_" .. set.id, set.event, function(...) procFunction(setKey, ...) end)
            EM:AddFilterForEvent(PvPCooldownTracker.name .. "_" .. set.id, set.event,
                REGISTER_FILTER_ABILITY_ID, set.id,
                REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end

        set.enabled = true
        PvPCooldownTracker.UI.Draw(setKey)

    -- Full bonus not active
    else

        -- If manually enabled in settings, don't let equipment callbacks disable it.
        -- This keeps the tracking toggle authoritative for users who want persistent tracking.
        if set.procType == "set"
            and type(PvPCooldownTracker.character) == "table"
            and type(PvPCooldownTracker.character[set.procType]) == "table"
            and PvPCooldownTracker.character[set.procType][setKey] == true then
            PvPCooldownTracker:Trace(2, "Manual setting keeps <<1>> enabled, skipping auto-disable", setKey)
            if not set.enabled then
                set.enabled = true
                PvPCooldownTracker.UI.Draw(setKey)
            end
            return
        end

        -- Don't disable if already disabled
        if set.enabled then
            PvPCooldownTracker:Trace(1, "Not active for: <<1>>, unregistering events", setKey)
            EM:UnregisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count")
            if type(set.id) == 'table' then
                for i=1, #set.id do
                    EM:UnregisterForEvent(PvPCooldownTracker.name .. "_" .. set.id[i], set.event)
                end
            else
                EM:UnregisterForEvent(PvPCooldownTracker.name .. "_" .. set.id, set.event)
            end
            set.enabled = false
            set.onCooldown = false
        else
            PvPCooldownTracker:Trace(2, "Set already disabled for: <<1>>", setKey)
        end
    end

end

if type(PvPCooldownTracker.Tracking.RegisterCombatEvent) ~= "function" then
    function PvPCooldownTracker.Tracking.RegisterCombatEvent()
        EM:RegisterForEvent(PvPCooldownTracker.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, IsInCombat)
        PvPCooldownTracker:Trace(2, "Registered combat events (fallback)")
    end
end

if type(PvPCooldownTracker.Tracking.UnregisterCombatEvent) ~= "function" then
    function PvPCooldownTracker.Tracking.UnregisterCombatEvent()
        EM:UnregisterForEvent(PvPCooldownTracker.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
        PvPCooldownTracker:Trace(2, "Unregistered combat events (fallback)")
    end
end

if type(PvPCooldownTracker.Tracking.RegisterEvents) ~= "function" then
    function PvPCooldownTracker.Tracking.RegisterEvents()
        EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_ALIVE, OnAlive)
        EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_DEAD, OnDeath)

        if not PvPCooldownTracker.preferences.showOutsideCombat then
            PvPCooldownTracker.Tracking.RegisterCombatEvent()
        end

        PvPCooldownTracker:Trace(2, "Registered Events (fallback)")
    end
end

if type(PvPCooldownTracker.Tracking.UnregisterEvents) ~= "function" then
    function PvPCooldownTracker.Tracking.UnregisterEvents()
        EM:UnregisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_ALIVE)
        EM:UnregisterForEvent(PvPCooldownTracker.name, EVENT_PLAYER_DEAD)
        PvPCooldownTracker:Trace(2, "Unregistered Events (fallback)")
    end
end

d("[PvPCooldownTracker] Tracking.lua ready - RegisterEvents type=" .. type(PvPCooldownTracker.Tracking.RegisterEvents))

