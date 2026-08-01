-- Beltalowda Mundus Composition
-- Scans group members' active effects to detect Mundus Stone (Boon) buffs.
-- Uses direct unit-tag buff reading (GetUnitBuffInfo) — no network broadcast
-- needed since mundus boons are visible permanent effects on all group members.
--
-- Architecturally parallel to BuffComposition.lua and SynergyComposition.lua.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.MundusComposition = {}

local MC = Beltalowda.Data.MundusComposition
local MD = Beltalowda.Data.MundusData

-- ============================================================================
-- State
-- ============================================================================

MC.initialized = false
MC.logger = nil

-- Group mundus data: mundusData[displayName] = { abilityId1, abilityId2, ... }
-- Most players have 1 entry; Twice-Born Star users may have 2.
MC.mundusData = {}

-- Callback name for change notifications
MC.CALLBACK_NAME = "BeltalowdaMundusCompositionChanged"

-- ============================================================================
-- Scanning
-- ============================================================================

--[[
    Scan a single unit tag's active effects for mundus stone buffs.
    @param unitTag: ESO unit tag (e.g., "player", "group1")
    @return: Array of mundus ability IDs found (empty if none)
]]--
function MC.ScanUnitMundus(unitTag)
    local mundusAbilities = {}
    local numBuffs = GetNumBuffs(unitTag)

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount,
              iconFilename, buffType, effectType, abilityType,
              statusEffectType, abilityId = GetUnitBuffInfo(unitTag, i)

        if abilityId and MD.IsMundusAbility(abilityId) then
            table.insert(mundusAbilities, abilityId)
        end
    end

    return mundusAbilities
end

--[[
    Scan all group members (including self) and update the mundus data table.
    Fires the change callback if any data changed.
]]--
function MC.ScanGroup()
    local groupSize = GetGroupSize()
    local newData = {}
    local changed = false

    if groupSize == 0 then
        -- Solo player — scan self
        local playerName = GetUnitName("player")
        if playerName and playerName ~= "" then
            local mundus = MC.ScanUnitMundus("player")
            newData[playerName] = mundus
        end
    else
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                local name = GetUnitName(unitTag)
                if name and name ~= "" then
                    local mundus = MC.ScanUnitMundus(unitTag)
                    newData[name] = mundus
                end
            end
        end
    end

    -- Check for changes
    for name, newMundus in pairs(newData) do
        local oldMundus = MC.mundusData[name]
        if not oldMundus or #oldMundus ~= #newMundus then
            changed = true
            break
        end
        for idx, id in ipairs(newMundus) do
            if oldMundus[idx] ~= id then
                changed = true
                break
            end
        end
        if changed then break end
    end

    -- Check for removed players
    if not changed then
        for name, _ in pairs(MC.mundusData) do
            if not newData[name] then
                changed = true
                break
            end
        end
    end

    if changed then
        MC.mundusData = newData
        MC.FireChangeEvent()

        if MC.logger then
            local summary = {}
            for name, mundus in pairs(newData) do
                local names = {}
                for _, abilityId in ipairs(mundus) do
                    table.insert(names, MD.GetMundusName(abilityId))
                end
                table.insert(summary, string.format("%s: %s", name,
                    #names > 0 and table.concat(names, " + ") or "(none)"))
            end
            MC.logger:Debug("Mundus data updated", table.concat(summary, ", "))
        end
    end
end

--[[
    Fire the change callback.
]]--
function MC.FireChangeEvent()
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks(MC.CALLBACK_NAME, MC.mundusData)
    end
end

-- ============================================================================
-- Group Membership Cleanup
-- ============================================================================

--[[
    Remove a departing member's mundus data and fire change event.
    @param unitTag: Unit tag (may already be invalid)
    @param characterName: Character name of the departed member
]]--
function MC.OnGroupMemberLeft(unitTag, characterName)
    local removed = false

    if characterName then
        local cleanName = zo_strformat("<<1>>", characterName)
        if MC.mundusData[cleanName] then
            MC.mundusData[cleanName] = nil
            removed = true
        end
        if MC.mundusData[characterName] then
            MC.mundusData[characterName] = nil
            removed = true
        end
    end

    -- Fallback: remove entries no longer in the group
    if not removed then
        local groupNames = {}
        local groupSize = GetGroupSize()
        for i = 1, groupSize do
            local tag = GetGroupUnitTagByIndex(i)
            if tag then
                local name = GetUnitName(tag)
                if name and name ~= "" then groupNames[name] = true end
            end
        end
        local myName = GetUnitName("player")
        if myName and myName ~= "" then groupNames[myName] = true end

        for name, _ in pairs(MC.mundusData) do
            if not groupNames[name] then
                MC.mundusData[name] = nil
                removed = true
            end
        end
    end

    if removed then
        MC.FireChangeEvent()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Get the mundus stone ability IDs for a given player name.
    @param playerName: Character display name
    @return: Array of ability IDs (may be empty), or nil if unknown
]]--
function MC.GetPlayerMundus(playerName)
    return MC.mundusData[playerName]
end

--[[
    Get the mundus stone ability IDs for a given unit tag.
    @param unitTag: ESO unit tag
    @return: Array of ability IDs (may be empty), or nil if unknown
]]--
function MC.GetUnitMundus(unitTag)
    local name = GetUnitName(unitTag)
    return name and MC.mundusData[name]
end

--[[
    Check if any group members are missing a mundus stone.
    @return: Array of player names with no mundus stone detected
]]--
function MC.GetPlayersWithoutMundus()
    local missing = {}
    for name, mundus in pairs(MC.mundusData) do
        if not mundus or #mundus == 0 then
            table.insert(missing, name)
        end
    end
    table.sort(missing)
    return missing
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

--[[
    Debounced group scan — schedules a scan after a short delay.
    Multiple rapid calls will be collapsed into a single scan.
]]--
function MC.ScheduleScan()
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMundusCompositionScan")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaMundusCompositionScan", 1000, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMundusCompositionScan")
        MC.ScanGroup()
    end)
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize mundus composition tracking.
    Registers for group change events and runs initial scan.
]]--
function MC.Initialize()
    if MC.initialized then return end

    -- Create logger
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        MC.logger = Beltalowda.Logger.CreateModuleLogger("MundusComp")
    end

    -- Register for group membership changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaMundusComp_GroupJoined",
        EVENT_GROUP_MEMBER_JOINED,
        function(eventCode)
            -- Delay scan to let buff data propagate
            zo_callLater(function() MC.ScanGroup() end, 2000)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaMundusComp_GroupLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function(eventCode, characterName, reason, wasLocalPlayer)
            if wasLocalPlayer then
                MC.mundusData = {}
                MC.FireChangeEvent()
            else
                MC.OnGroupMemberLeft(nil, characterName)
            end
        end
    )

    -- Re-scan on zone change (buff data becomes available after loading screen)
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaMundusComp_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            zo_callLater(function() MC.ScanGroup() end, 2500)
        end
    )

    -- Monitor effect changes to detect mundus stone additions/removals in real-time.
    -- Fires when any buff is gained or lost on any visible unit.
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaMundusComp_EffectChanged",
        EVENT_EFFECT_CHANGED,
        function(eventCode, changeType, effectSlot, effectName, unitTag,
                 beginTime, endTime, stackCount, iconName, buffType,
                 effectType, abilityType, statusEffectType, unitName,
                 unitId, abilityId, sourceType)
            if abilityId and MD.IsMundusAbility(abilityId) then
                MC.ScheduleScan()
            end
        end
    )

    -- Periodic scan as a safety net (every 15 seconds).
    -- Mundus stones are permanent, so infrequent polling is fine.
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaMundusCompositionPeriodic", 15000, function()
        MC.ScanGroup()
    end)

    -- Initial scan with delay to let game data settle
    zo_callLater(function()
        MC.ScanGroup()
    end, 3000)

    MC.initialized = true
end
