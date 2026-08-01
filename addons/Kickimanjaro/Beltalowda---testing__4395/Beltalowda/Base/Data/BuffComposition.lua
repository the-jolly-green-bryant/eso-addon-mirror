-- Beltalowda Buff Composition
-- Scans local player's skill bars and gear for group-wide buff sources,
-- broadcasts a compact bitmask via LGB protocol 226, and aggregates
-- group-wide detected buff providers.
--
-- Architecturally parallel to SynergyComposition.lua.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.BuffComposition = {}

local BC = Beltalowda.Data.BuffComposition
local BuffDB = Beltalowda.Data.BuffDatabase

-- ============================================================================
-- Constants
-- ============================================================================

BC.MAX_BUFF_BITS = BuffDB.MAX_BUFF_BITS
BC.MAX_BITMASK_VALUE = BuffDB.MAX_BITMASK_VALUE

-- ============================================================================
-- State
-- ============================================================================

BC.initialized = false
BC.logger = nil

-- Local player's buff bitmask (what group buffs we provide)
BC.localBitmask = 0
BC.previousLocalBitmask = -1  -- Force initial broadcast

-- Group composition data: compositionData[displayName] = bitmask
-- Keyed by display name (not unit tag) so data survives unit tag reshuffles
BC.compositionData = {}

-- Aggregated group buff bitmask (bitwise OR of all members)
BC.groupBuffBitmask = 0

-- Local player's source details for icon resolution.
-- Maps buffId → abilityId of the slotted ability that provides the buff.
-- Only populated for the local player (we don't know remote players' sources).
BC.localSourceDetails = {}

-- Callback name for change notifications
BC.CALLBACK_NAME = "BeltalowdaBuffCompositionChanged"

-- ============================================================================
-- Bitmask Helpers
-- ============================================================================

--[[
    Set a bit in the bitmask for a given buff ID.
    @param bitmask: Current bitmask
    @param buffId: Buff ID (1-based)
    @return: Updated bitmask
]]--
function BC.SetBit(bitmask, buffId)
    if buffId < 1 or buffId > BC.MAX_BUFF_BITS then return bitmask end
    local bitPosition = buffId - 1
    local bitValue = 2 ^ bitPosition
    if BC.TestBit(bitmask, buffId) then
        return bitmask  -- Already set
    end
    return bitmask + bitValue
end

--[[
    Test if a bit is set in the bitmask for a given buff ID.
    @param bitmask: Bitmask to test
    @param buffId: Buff ID (1-based)
    @return: boolean
]]--
function BC.TestBit(bitmask, buffId)
    if buffId < 1 or buffId > BC.MAX_BUFF_BITS then return false end
    local bitPosition = buffId - 1
    local bitValue = 2 ^ bitPosition
    return math.floor(bitmask / bitValue) % 2 == 1
end

-- ============================================================================
-- Class Passive Detection
-- ============================================================================

--[[
    Check if the local player has a specific class passive purchased.
    Scans SKILL_TYPE_CLASS (1) skill lines for a passive with the given name.
    @param passiveName: The ability name to search for (e.g., "Maturation")
    @return: boolean — true if the passive is found and purchased
]]--
function BC.HasClassPassive(passiveName)
    -- SKILL_TYPE_CLASS = 1 in ESO
    local SKILL_TYPE_CLASS = 1
    local numSkillLines = GetNumSkillLines(SKILL_TYPE_CLASS)
    for skillLineIndex = 1, numSkillLines do
        local numAbilities = GetNumSkillAbilities(SKILL_TYPE_CLASS, skillLineIndex)
        for abilityIndex = 1, numAbilities do
            local name, _, _, isPassive, _, isPurchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, abilityIndex)
            if isPassive and isPurchased and name == passiveName then
                return true
            end
        end
    end
    return false
end

-- ============================================================================
-- Local Player Scanning
-- ============================================================================

--[[
    Scan the local player's skill bars and gear to build a buff bitmask.
    Checks action bar slots 3-8 on both bars for abilities that provide
    group-wide buffs, scans equipped sets via LibSetDetection, and checks
    class passives for buff sources (e.g., Warden Maturation → Minor Toughness).

    If the bitmask changed, broadcasts via protocol 226.
]]--
function BC.ScanLocalPlayer()
    local newBitmask = 0
    BC.localSourceDetails = {}

    -- Scan action bars: slots 3-8 on both hotbar 0 (front) and hotbar 1 (back)
    for hotbar = 0, 1 do
        for slot = 3, 8 do
            local abilityId = GetSlotBoundId(slot, hotbar)
            if abilityId and abilityId > 0 then
                -- Check for group-wide buff sources
                local buffName = BuffDB.GetBuffForAbility(abilityId)
                if buffName then
                    local def = BuffDB.BUFF_DEFINITIONS[buffName]
                    if def then
                        newBitmask = BC.SetBit(newBitmask, def.buffId)
                        BC.localSourceDetails[def.buffId] = abilityId
                    end
                end
                -- Check for individual buff sources (e.g., Shuffle → Major Evasion self-only)
                local indivBuffName = BuffDB.GetIndividualBuffForAbility(abilityId)
                if indivBuffName then
                    local def = BuffDB.BUFF_DEFINITIONS[indivBuffName]
                    if def and def.individualBuffId then
                        newBitmask = BC.SetBit(newBitmask, def.individualBuffId)
                        BC.localSourceDetails[def.individualBuffId] = abilityId
                    end
                end
            end
        end
    end

    -- Scan scribed abilities for buff sources (e.g., Banner Bearer + Immobilize focus)
    for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
        if def.scribingSources then
            for _, scribingSource in ipairs(def.scribingSources) do
                for hotbar = 0, 1 do
                    for slot = 3, 8 do
                        local slotAbilityId = GetSlotBoundId(slot, hotbar)
                        if slotAbilityId and slotAbilityId == scribingSource.craftedAbilityId then
                            -- This slot has the scribed ability — check its focus script
                            if GetCraftedAbilityActiveScriptIds then
                                local focusId = GetCraftedAbilityActiveScriptIds(slotAbilityId)
                                if focusId and focusId == scribingSource.focusScriptId then
                                    newBitmask = BC.SetBit(newBitmask, def.buffId)
                                    BC.localSourceDetails[def.buffId] = scribingSource.resolvedAbilityId or slotAbilityId
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Scan equipped sets via LibSetDetection
    if LibSetDetection and LibSetDetection.GetUnitSetData then
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData then
            for setId, setEntry in pairs(setData) do
                if type(setId) == "number" and BuffDB.GetBuffForSet(setId) then
                    -- Compute effective piece count: body + max(front, back)
                    local numEquip = setEntry.numEquip
                    if numEquip then
                        local bodyCount = numEquip.body or 0
                        local frontCount = numEquip.front or 0
                        local backCount = numEquip.back or 0
                        local pieces = bodyCount + math.max(frontCount, backCount)
                        local required = setEntry.maxEquip or 5
                        if pieces >= required then
                            local buffName = BuffDB.GetBuffForSet(setId)
                            local def = BuffDB.BUFF_DEFINITIONS[buffName]
                            if def then
                                newBitmask = BC.SetBit(newBitmask, def.buffId)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Scan class passives for buff sources (e.g., Warden Maturation → Minor Toughness)
    -- Iterates the player's class skill lines looking for purchased passives that
    -- match a classPassiveSources entry in BuffDatabase.
    for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
        if def.classPassiveSources then
            for _, passiveSource in ipairs(def.classPassiveSources) do
                if BC.HasClassPassive(passiveSource.abilityName) then
                    newBitmask = BC.SetBit(newBitmask, def.buffId)
                end
            end
        end
    end

    -- Check if bitmask changed
    if newBitmask ~= BC.previousLocalBitmask then
        BC.localBitmask = newBitmask
        BC.previousLocalBitmask = newBitmask

        if BC.logger then
            BC.logger:Debug("Local buff bitmask changed",
                string.format("bitmask=%d, buffs=%s", newBitmask, BC.BitmaskToString(newBitmask)))
        end

        -- Store our own data in the composition table (keyed by display name)
        local playerName = GetUnitName("player")
        if playerName and playerName ~= "" then
            BC.compositionData[playerName] = newBitmask
        end

        -- Broadcast to group
        local BeltalowdaNetwork = Beltalowda.network
        if BeltalowdaNetwork and BeltalowdaNetwork.BroadcastBuffComposition then
            BeltalowdaNetwork.BroadcastBuffComposition(newBitmask)
        end

        -- Re-aggregate and fire change event
        BC.AggregateGroupBitmask()
    end
end

-- ============================================================================
-- Group Aggregation
-- ============================================================================

--[[
    Aggregate all group members' bitmasks into a single group bitmask.
    Fires CALLBACK if the result changed.
]]--
function BC.AggregateGroupBitmask()
    local newGroupBitmask = 0

    for _, bitmask in pairs(BC.compositionData) do
        for buffId = 1, BC.MAX_BUFF_BITS do
            if BC.TestBit(bitmask, buffId) and not BC.TestBit(newGroupBitmask, buffId) then
                newGroupBitmask = BC.SetBit(newGroupBitmask, buffId)
            end
        end
    end

    if newGroupBitmask ~= BC.groupBuffBitmask then
        local oldBitmask = BC.groupBuffBitmask
        BC.groupBuffBitmask = newGroupBitmask

        if BC.logger then
            BC.logger:Info("Group buff bitmask changed",
                string.format("old=%d, new=%d, buffs=%s", oldBitmask, newGroupBitmask, BC.BitmaskToString(newGroupBitmask)))
        end

        BC.FireChangeEvent()
    end
end

--[[
    Fire the change callback.
]]--
function BC.FireChangeEvent()
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks(BC.CALLBACK_NAME, BC.groupBuffBitmask)
    end
end

-- ============================================================================
-- Network Receive Handler
-- ============================================================================

--[[
    Called when we receive a buff composition bitmask from a group member.
    @param unitTag: Sender's unit tag
    @param bitmask: Their buff bitmask
]]--
function BC.OnBuffCompositionReceived(unitTag, bitmask)
    if not unitTag or not bitmask then return end

    local name = GetUnitName(unitTag)
    if not name or name == "" then return end

    BC.compositionData[name] = bitmask

    if BC.logger then
        BC.logger:Debug("Buff composition received",
            string.format("from=%s (%s), bitmask=%d, buffs=%s",
                name, unitTag, bitmask, BC.BitmaskToString(bitmask)))
    end

    BC.AggregateGroupBitmask()
end

-- ============================================================================
-- Group Membership Cleanup
-- ============================================================================

--[[
    Remove a departing member's buff composition data and re-aggregate.
    @param unitTag: Unit tag of the departed member (may already be invalid)
    @param characterName: Character name of the departed member
]]--
function BC.OnGroupMemberLeft(unitTag, characterName)
    local removed = false

    if characterName then
        local cleanName = zo_strformat("<<1>>", characterName)
        if BC.compositionData[cleanName] then
            BC.compositionData[cleanName] = nil
            removed = true
        end
        if BC.compositionData[characterName] then
            BC.compositionData[characterName] = nil
            removed = true
        end
    end

    -- Fallback: remove entries for names no longer in the group
    if not removed then
        local groupNames = {}
        local groupSize = GetGroupSize()
        for i = 1, groupSize do
            local tag = GetGroupUnitTagByIndex(i)
            if tag then
                local name = GetUnitName(tag)
                if name and name ~= "" then
                    groupNames[name] = true
                end
            end
        end
        local myName = GetUnitName("player")
        if myName and myName ~= "" then
            groupNames[myName] = true
        end

        for name, _ in pairs(BC.compositionData) do
            if not groupNames[name] then
                BC.compositionData[name] = nil
                removed = true
            end
        end
    end

    if removed then
        if BC.logger then
            BC.logger:Debug("Removed buff composition data for departed member",
                tostring(characterName or unitTag))
        end
        BC.AggregateGroupBitmask()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Check if a specific buff is present in the group composition.
    @param buffId: Buff ID (1-based)
    @return: boolean
]]--
function BC.IsGroupBuffPresent(buffId)
    return BC.TestBit(BC.groupBuffBitmask, buffId)
end

--[[
    Get list of player names that provide a specific buff (from bitmask data).
    @param buffId: Buff ID (1-based)
    @return: Array of player display names (sorted alphabetically)
]]--
function BC.GetProvidersForBuff(buffId)
    local providers = {}
    for name, bitmask in pairs(BC.compositionData) do
        if BC.TestBit(bitmask, buffId) then
            table.insert(providers, name)
        end
    end
    table.sort(providers)
    return providers
end

--[[
    Get list of buff IDs that a specific player provides.
    @param unitTag: Player's unit tag
    @return: Array of buff IDs
]]--
function BC.GetPlayerBuffs(unitTag)
    local name = GetUnitName(unitTag)
    local bitmask = name and BC.compositionData[name]
    if not bitmask then return {} end

    local result = {}
    for buffId = 1, BC.MAX_BUFF_BITS do
        if BC.TestBit(bitmask, buffId) then
            if BuffDB.idToBuff[buffId] then
                table.insert(result, buffId)
            end
        end
    end
    return result
end

--[[
    Get the group buff bitmask.
    @return: Integer bitmask
]]--
function BC.GetGroupBitmask()
    return BC.groupBuffBitmask
end

--[[
    Get the ability ID that the local player uses to provide a specific buff.
    Used for icon resolution in the Group Composition panel.
    @param buffId: Buff ID (1-based)
    @return: Ability ID (number), or nil if not provided via an ability
]]--
function BC.GetLocalSourceAbilityId(buffId)
    return BC.localSourceDetails[buffId]
end

--[[
    Get the local player's buff bitmask.
    @return: Integer bitmask
]]--
function BC.GetLocalBitmask()
    return BC.localBitmask
end

--[[
    Count the total number of distinct tracked buffs provided across all group members.
    Counts each unique buffId once (from the aggregated group bitmask).
    @return: Integer count
]]--
function BC.CountGroupBuffs()
    local count = 0
    for buffId = 1, BC.MAX_BUFF_BITS do
        if BC.TestBit(BC.groupBuffBitmask, buffId) then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- Utility
-- ============================================================================

--[[
    Convert a bitmask to a human-readable string of buff names.
    @param bitmask: Integer bitmask
    @return: Comma-separated string of buff names
]]--
function BC.BitmaskToString(bitmask)
    local names = {}
    for buffId = 1, BC.MAX_BUFF_BITS do
        if BC.TestBit(bitmask, buffId) then
            local buffName = BuffDB.idToBuff[buffId]
            if buffName then
                if BuffDB.individualBitIds[buffId] then
                    table.insert(names, buffName .. " (self)")
                else
                    table.insert(names, buffName)
                end
            else
                table.insert(names, "#" .. buffId)
            end
        end
    end
    if #names == 0 then return "(none)" end
    return table.concat(names, ", ")
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

--[[
    Handle action bar slot changes.
]]--
function BC.OnActionSlotUpdated(eventCode, slotIndex)
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaBuffCompositionScan", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
        BC.ScanLocalPlayer()
    end)
end

--[[
    Handle full action bar update.
]]--
function BC.OnActionSlotsFullUpdate(eventCode)
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaBuffCompositionScan", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
        BC.ScanLocalPlayer()
    end)
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize buff composition tracking.
    Registers for skill bar and gear change events.
    Runs initial scan with a delay to let game data settle.
]]--
function BC.Initialize()
    if BC.initialized then return end

    -- Create logger
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        BC.logger = Beltalowda.Logger.CreateModuleLogger("BuffComp")
    end

    -- Register for action bar changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaBuffComp_SlotUpdate",
        EVENT_ACTION_SLOT_UPDATED,
        BC.OnActionSlotUpdated
    )
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaBuffComp_SlotsFullUpdate",
        EVENT_ACTION_SLOTS_FULL_UPDATE,
        BC.OnActionSlotsFullUpdate
    )

    -- Register for LibSetDetection gear changes
    if LibSetDetection and LibSetDetection.RegisterEvent and LSD_EVENT_DATA_UPDATE then
        LibSetDetection.RegisterEvent(
            LSD_EVENT_DATA_UPDATE,
            "BeltalowdaBuffComp_GearUpdate",
            function(unitTag)
                if unitTag == "player" or GetUnitName(unitTag) == GetUnitName("player") then
                    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
                    EVENT_MANAGER:RegisterForUpdate("BeltalowdaBuffCompositionScan", 500, function()
                        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaBuffCompositionScan")
                        BC.ScanLocalPlayer()
                    end)
                end
            end,
            LSD_UNIT_TYPE_PLAYER
        )
    end

    -- Register for group membership changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaBuffComp_GroupJoined",
        EVENT_GROUP_MEMBER_JOINED,
        function(eventCode)
            zo_callLater(function()
                BC.previousLocalBitmask = -1  -- Force re-broadcast
                BC.ScanLocalPlayer()
            end, 1500)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaBuffComp_GroupLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function(eventCode, characterName, reason, wasLocalPlayer)
            if wasLocalPlayer then
                BC.compositionData = {}
                BC.groupBuffBitmask = 0
                BC.FireChangeEvent()
            else
                BC.OnGroupMemberLeft(nil, characterName)
            end
        end
    )

    -- Initial scan with delay to let game data settle
    zo_callLater(function()
        BC.ScanLocalPlayer()
    end, 2000)

    BC.initialized = true
end
