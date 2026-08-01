PvPCooldownTracker.Tracking = {}

local EM = EVENT_MANAGER
local updateIntervalMs = 100
PvPCooldownTracker.first_run = true
-- ----------------------------------------------------------------------------
-- Callback Functions
-- ----------------------------------------------------------------------------

local function OnCooldownUpdated(setKey, eventCode, abilityId)
    -- When cooldown of this ability occurs, this function is continually called
    -- until the set is off cooldown.
    -- We can use the first call of this function to detect a proc state.

    local set = PvPCooldownTracker.Data.Sets[setKey]
    d(string.format("AbilityId: %s Set: %s", abilityId, setKey))
    -- Ignore if set is on cooldown
    if set.onCooldown == true then return end

    set.timeOfProc = GetGameTimeMilliseconds()

    -- Delay proc time by the current frame duration if lag compensation is enabled
    -- This helps mitigate false procs when the set is seen as off cooldown,
    -- but the COOLDOWN_UPDATED event is still being called.
    -- This delay aims to let COOLDOWN_UPDATED finish, which can vary depending
    -- on lag conditions, before deeming the set as off cooldown.
    if PvPCooldownTracker.preferences.lagCompensation then
        -- Add current frame delta - does NOT account for wide variances/spikes
        set.timeOfProc = set.timeOfProc + GetFrameDeltaTimeMilliseconds()
    end

    set.onCooldown = true
    PvPCooldownTracker.UI.PlaySound(PvPCooldownTracker.preferences.sets[setKey].sounds.onProc)
    EM:RegisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count", updateIntervalMs, function(...) PvPCooldownTracker.UI.Update(setKey) return end)

    PvPCooldownTracker:Trace(1, "Cooldown proc for <<1>> (<<2>>)", setKey, abilityId)
end

local function OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)

    local set = PvPCooldownTracker.Data.Sets[setKey]

    if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
        PvPCooldownTracker:Trace(1, "<<1>> (<<2>>) on Cooldown", abilityName, abilityId)
    elseif result == set.result then
        PvPCooldownTracker:Trace(1, "Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result)
        set.onCooldown = true
        set.enabled = true
        set.timeOfProc = GetGameTimeMilliseconds()
        PvPCooldownTracker.first_run = true
        PvPCooldownTracker.UI.PlaySound(PvPCooldownTracker.preferences.sets[setKey].sounds.onProc)
        EM:RegisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count", updateIntervalMs, function(...) PvPCooldownTracker.UI.Update(setKey) return end)
    else
        PvPCooldownTracker:Trace(1, "Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result)
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
    -- Exclude common unnecessary abilities
    local ignoreList = {
        sprint        = 973,
        sprintDrain   = 15356,
        block         = 14890,
        interrupt     = 55146,
        roll          = 28549,
        immov         = 29721,
        phase         = 98294,
        dodgeFatigue  = 69143,
    }

    for index, value in pairs(ignoreList) do
        if abilityId == value then return end
    end

    PvPCooldownTracker:Trace(1, "<<1>> (<<2>>) with result <<3>>", abilityName, abilityId, result)
end

local function OnEffectChangedUnfiltered(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Exclude common unnecessary abilities
    local ignoreList = {
        sprint        = 973,
        sprintDrain   = 15356,
        block         = 14890,
        interrupt     = 55146,
        roll          = 28549,
        immov         = 29721,
        phase         = 98294,
        dodgeFatigue  = 69143,
    }

    for index, value in pairs(ignoreList) do
        if abilityId == value then return end
    end

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
    local isPerfect = string.find(setKey, "Perfect")

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
    local set = PvPCooldownTracker.Data.Sets[setKey]

    -- Ignore sets not in our table
    if set == nil then return end


    -- Full bonus active
    if enabled then

        -- Check manual disable first
        if PvPCooldownTracker.character[set.procType][setKey] ~= nil
				and PvPCooldownTracker.character[set.procType][setKey] == false then
            -- Skip enabling set
            PvPCooldownTracker:Trace(1, "Force disabled <<1>>, skipping enable", setKey)
            return
        end

        -- Don't enable if already enabled
        if not set.enabled then
            PvPCooldownTracker:Trace(1, "Full set for: <<1>>, registering events", setKey)

            -- Set callback based on event
            local procFunction = nil
            if set.event == EVENT_ABILITY_COOLDOWN_UPDATED then
                procFunction = OnCooldownUpdated
            else
                procFunction = OnCombatEvent
            end

            -- Register events
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
        else
            PvPCooldownTracker:Trace(2, "Set already enabled for: <<1>>", setKey)
        end

    -- Full bonus not active
    else

        -- Don't disable if already disabled
        if set.enabled then
            PvPCooldownTracker:Trace(1, "Not active for: <<1>>, unregistering events", setKey)
            if type(set.id) == 'table' then
                for i=1, #set.id do
                    EM:UnregisterForEvent(PvPCooldownTracker.name .. "_" .. set.id[i], set.event)
                end
            else
                EM:UnregisterForEvent(PvPCooldownTracker.name .. "_" .. set.id, set.event)
            end
            set.enabled = false
            PvPCooldownTracker.UI.Draw(setKey)
        else
            PvPCooldownTracker:Trace(2, "Set already disabled for: <<1>>", setKey)
        end
    end

end

