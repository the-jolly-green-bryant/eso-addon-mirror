-- Beltalowda Champion Point Composition
-- Detects the local player's slotted champion perks (4 per discipline × 3
-- disciplines = 12 slots) and shares them via protocol 225. Stores received
-- CP data per character for display in the Group Composition Panel.
--
-- Architecturally parallel to SynergyComposition.lua and BuffComposition.lua.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.ChampionPointComposition = {}

local CPC = Beltalowda.Data.ChampionPointComposition

-- ============================================================================
-- Constants
-- ============================================================================

CPC.SLOTS_PER_DISCIPLINE = 4
CPC.TOTAL_SLOTS = 12

-- Callback name for change notifications
CPC.CALLBACK_NAME = "BeltalowdaChampionPointCompositionChanged"

-- ============================================================================
-- State
-- ============================================================================

CPC.initialized = false
CPC.logger = nil

-- Local player's slotted CP data:
--   localSlots[disciplineId] = { championSkillId, ... } (4 entries, 0 = empty)
CPC.localSlots = {}

-- Flat 12-element array for broadcast (ordered by bar slot index)
CPC.localFlatSlots = {}

-- Discipline metadata: disciplineInfo[disciplineId] = { name, type, index }
CPC.disciplineInfo = {}

-- Ordered discipline IDs (by bar slot order)
CPC.orderedDisciplineIds = {}

-- Group CP data: cpData[displayName] = { [disciplineId] = { id1, id2, id3, id4 } }
CPC.cpData = {}

-- ============================================================================
-- Initialization Helpers
-- ============================================================================

--[[
    Populate the discipline metadata table from the ESO API.
    Maps each disciplineId → { name, type, index }.
]]--
function CPC.BuildDisciplineMap()
    CPC.disciplineInfo = {}
    local numDisc = GetNumChampionDisciplines()

    for i = 1, numDisc do
        local discId = GetChampionDisciplineId(i)
        CPC.disciplineInfo[discId] = {
            name = GetChampionDisciplineName(discId),
            type = GetChampionDisciplineType(discId),
            index = i,
        }
    end
end

--[[
    Build the ordered discipline list by walking the champion bar slots.
    The bar groups 4 consecutive slots per discipline, so iterating in order
    gives us the canonical display order (Warfare → Fitness → Craft).
]]--
function CPC.BuildSlotDisciplineOrder()
    CPC.orderedDisciplineIds = {}
    local seen = {}
    local startSlot, endSlot = GetAssignableChampionBarStartAndEndSlots()

    for slotIndex = startSlot, endSlot do
        local discId = GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        if discId and not seen[discId] then
            seen[discId] = true
            table.insert(CPC.orderedDisciplineIds, discId)
        end
    end
end

-- ============================================================================
-- Local CP Detection
-- ============================================================================

--[[
    Read the local player's champion bar and detect slotted perks.
    Stores the data both as a per-discipline table and a flat 12-element array.
    Broadcasts changes to the group and fires the change callback.
    @return boolean: true if the data changed
]]--
function CPC.ReadLocalChampionBar()
    -- Check if tracking is enabled
    if BeltalowdaVars and BeltalowdaVars.composition
            and BeltalowdaVars.composition.trackChampionPoints == false then
        return false
    end

    local startSlot, endSlot = GetAssignableChampionBarStartAndEndSlots()
    local newSlots = {}
    local flatSlots = {}
    local flatIdx = 1

    for slotIndex = startSlot, endSlot do
        local discId = GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        if discId then
            if not newSlots[discId] then
                newSlots[discId] = {}
            end

            -- GetSlotBoundId returns 0 for empty champion bar slots
            local skillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION) or 0

            table.insert(newSlots[discId], skillId)
            flatSlots[flatIdx] = skillId
            flatIdx = flatIdx + 1
        end
    end

    -- Pad to TOTAL_SLOTS (safety)
    while flatIdx <= CPC.TOTAL_SLOTS do
        flatSlots[flatIdx] = 0
        flatIdx = flatIdx + 1
    end

    -- Check for changes
    local changed = false
    for i = 1, CPC.TOTAL_SLOTS do
        if (CPC.localFlatSlots[i] or 0) ~= (flatSlots[i] or 0) then
            changed = true
            break
        end
    end

    if changed then
        CPC.localSlots = newSlots
        CPC.localFlatSlots = flatSlots

        -- Store under local player's name
        local playerName = GetUnitName("player")
        if playerName and playerName ~= "" then
            CPC.cpData[playerName] = CPC.DeepCopySlots(newSlots)
        end

        -- Broadcast to group
        local BeltalowdaNetwork = Beltalowda.network
        if BeltalowdaNetwork and BeltalowdaNetwork.BroadcastChampionPointComposition then
            BeltalowdaNetwork.BroadcastChampionPointComposition(flatSlots)
        end

        CPC.FireChangeEvent()

        if CPC.logger then
            CPC.logger:Debug("Champion bar updated", CPC.FormatSlotsForLog(newSlots))
        end
    end

    return changed
end

-- ============================================================================
-- Network Receive
-- ============================================================================

--[[
    Process champion point data received from a group member via protocol 225.
    @param unitTag: ESO unit tag of the sender
    @param cpSlots: 12-element array of champion skill IDs (0 = empty)
]]--
function CPC.OnChampionDataReceived(unitTag, cpSlots)
    if not cpSlots or #cpSlots < CPC.TOTAL_SLOTS then return end

    local name = GetUnitName(unitTag)
    if not name or name == "" then return end

    -- Convert flat array to per-discipline structure
    local structured = CPC.FlatToStructured(cpSlots)

    local prevData = CPC.cpData[name]
    local changed = not prevData

    if not changed then
        for _, discId in ipairs(CPC.orderedDisciplineIds) do
            local oldDisc = prevData[discId] or {}
            local newDisc = structured[discId] or {}
            for s = 1, CPC.SLOTS_PER_DISCIPLINE do
                if (oldDisc[s] or 0) ~= (newDisc[s] or 0) then
                    changed = true
                    break
                end
            end
            if changed then break end
        end
    end

    if changed then
        CPC.cpData[name] = structured
        CPC.FireChangeEvent()

        if CPC.logger then
            CPC.logger:Debug("CP data received",
                string.format("%s: %s", name, CPC.FormatSlotsForLog(structured)))
        end
    end
end

-- ============================================================================
-- Helpers
-- ============================================================================

--[[
    Convert a flat 12-element array (ordered by bar slot) into a per-discipline
    structure: { [disciplineId] = { skillId1, skillId2, skillId3, skillId4 } }
]]--
function CPC.FlatToStructured(flatSlots)
    local structured = {}
    local startSlot, endSlot = GetAssignableChampionBarStartAndEndSlots()
    local flatIdx = 1

    for slotIndex = startSlot, endSlot do
        local discId = GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        if discId then
            if not structured[discId] then
                structured[discId] = {}
            end
            table.insert(structured[discId], flatSlots[flatIdx] or 0)
            flatIdx = flatIdx + 1
        end
    end

    return structured
end

--[[
    Deep copy a per-discipline slots table.
]]--
function CPC.DeepCopySlots(slots)
    local copy = {}
    for discId, perks in pairs(slots) do
        copy[discId] = {}
        for i, v in ipairs(perks) do
            copy[discId][i] = v
        end
    end
    return copy
end

function CPC.FireChangeEvent()
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks(CPC.CALLBACK_NAME, CPC.cpData)
    end
end

--[[
    Format slotted CP data for debug logging.
]]--
function CPC.FormatSlotsForLog(slots)
    local parts = {}
    for _, discId in ipairs(CPC.orderedDisciplineIds) do
        local info = CPC.disciplineInfo[discId]
        local perks = slots[discId] or {}
        local names = {}
        for _, skillId in ipairs(perks) do
            if skillId and skillId > 0 then
                local skillName = GetChampionSkillName(skillId)
                table.insert(names, skillName or tostring(skillId))
            else
                table.insert(names, "—")
            end
        end
        table.insert(parts, string.format("%s: [%s]",
            info and info.name or tostring(discId),
            table.concat(names, ", ")))
    end
    return table.concat(parts, " | ")
end

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Get the champion point data for a given player name.
    @param playerName: Character display name
    @return: Table { [disciplineId] = { skillId, ... } } or nil if unknown
]]--
function CPC.GetPlayerChampionData(playerName)
    return CPC.cpData[playerName]
end

--[[
    Get the flat 12-element slot array for broadcasting.
    @return: Array of 12 champion skill IDs
]]--
function CPC.GetFlatSlotArray()
    return CPC.localFlatSlots
end

--[[
    Get the appropriate discipline icon texture for display.
    Uses the "slotted" texture when all 4 slots are filled, "empty" otherwise.
    @param disciplineId: Champion discipline ID
    @param filledCount: Number of filled slots (0-4)
    @return: Texture path string, or nil
]]--
function CPC.GetDisciplineIcon(disciplineId, filledCount)
    local info = CPC.disciplineInfo[disciplineId]
    if not info then return nil end

    local textures = ZO_GetChampionBarDisciplineTextures(info.type)
    if not textures then return nil end

    return (filledCount >= CPC.SLOTS_PER_DISCIPLINE) and textures.slotted or textures.empty
end

--[[
    Get the discipline name for a given discipline ID.
    @param disciplineId: Champion discipline ID
    @return: Localized discipline name string
]]--
function CPC.GetDisciplineName(disciplineId)
    local info = CPC.disciplineInfo[disciplineId]
    return info and info.name or "Unknown"
end

--[[
    Get the ordered list of discipline IDs (matching bar slot order).
    @return: Array of discipline IDs
]]--
function CPC.GetOrderedDisciplineIds()
    return CPC.orderedDisciplineIds
end

--[[
    Count the number of filled (non-zero) slots in a perks array.
    @param perks: Array of champion skill IDs
    @return: Number of filled slots
]]--
function CPC.CountFilledSlots(perks)
    if not perks then return 0 end
    local count = 0
    for _, skillId in ipairs(perks) do
        if skillId and skillId > 0 then
            count = count + 1
        end
    end
    return count
end

--[[
    Build a multi-line tooltip string for a discipline's slotted perks.
    @param disciplineId: Champion discipline ID
    @param perks: Array of champion skill IDs (4 entries, 0 = empty)
    @return: Tooltip string with discipline header and per-slot lines
]]--
function CPC.BuildDisciplineTooltip(disciplineId, perks)
    local discName = CPC.GetDisciplineName(disciplineId)
    local filled = CPC.CountFilledSlots(perks)
    local lines = { string.format("|cFFFFFF%s (%d/%d)|r", discName, filled, CPC.SLOTS_PER_DISCIPLINE) }

    for i = 1, CPC.SLOTS_PER_DISCIPLINE do
        local skillId = perks and perks[i] or 0
        if skillId and skillId > 0 then
            local skillName = GetChampionSkillName(skillId) or "Unknown"
            table.insert(lines, string.format("  |c00FF00%s|r", skillName))
        else
            table.insert(lines, "  |c888888— Empty —|r")
        end
    end

    return table.concat(lines, "\n")
end

-- ============================================================================
-- Group Membership Cleanup
-- ============================================================================

--[[
    Remove a departing member's CP data and fire change event.
    @param unitTag: Unit tag (may already be invalid)
    @param characterName: Character name of the departed member
]]--
function CPC.OnGroupMemberLeft(unitTag, characterName)
    local removed = false

    if characterName then
        local cleanName = zo_strformat("<<1>>", characterName)
        if CPC.cpData[cleanName] then
            CPC.cpData[cleanName] = nil
            removed = true
        end
        if CPC.cpData[characterName] then
            CPC.cpData[characterName] = nil
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

        for name, _ in pairs(CPC.cpData) do
            if not groupNames[name] then
                CPC.cpData[name] = nil
                removed = true
            end
        end
    end

    if removed then
        CPC.FireChangeEvent()
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize champion point composition tracking.
    Registers for champion bar change events and runs initial scan.
]]--
function CPC.Initialize()
    if CPC.initialized then return end

    -- Create logger
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        CPC.logger = Beltalowda.Logger.CreateModuleLogger("CPComp")
    end

    -- Build discipline metadata
    CPC.BuildDisciplineMap()
    CPC.BuildSlotDisciplineOrder()

    -- Initialize flat slots to zeros
    CPC.localFlatSlots = {}
    for i = 1, CPC.TOTAL_SLOTS do
        CPC.localFlatSlots[i] = 0
    end

    -- Register for champion purchase (CP respec / allocation changes)
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaCPComp_ChampionPurchase",
        EVENT_CHAMPION_PURCHASE_RESULT,
        function()
            zo_callLater(function() CPC.ReadLocalChampionBar() end, 500)
        end
    )

    -- Register for action slot updates (covers CP bar changes)
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaCPComp_ActionSlotsUpdated",
        EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
        function()
            zo_callLater(function() CPC.ReadLocalChampionBar() end, 500)
        end
    )

    -- Group membership changes
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaCPComp_GroupMemberLeft",
        EVENT_GROUP_MEMBER_LEFT,
        function(eventCode, characterName, reason, wasLocalPlayer)
            if wasLocalPlayer then
                CPC.cpData = {}
                CPC.FireChangeEvent()
            else
                CPC.OnGroupMemberLeft(nil, characterName)
            end
        end
    )

    -- Re-read on zone change / login
    EVENT_MANAGER:RegisterForEvent(
        "BeltalowdaCPComp_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            zo_callLater(function() CPC.ReadLocalChampionBar() end, 3000)
        end
    )

    -- Initial read with delay to let champion data settle
    -- (Must be explicit because Initialize is called from within
    -- EVENT_PLAYER_ACTIVATED, so the registered handler above
    -- only catches future activations, not the current one.)
    zo_callLater(function()
        CPC.ReadLocalChampionBar()
    end, 3000)

    CPC.initialized = true

    if CPC.logger then
        CPC.logger:Info("ChampionPointComposition initialized",
            string.format("%d disciplines, %d slots",
                #CPC.orderedDisciplineIds, CPC.TOTAL_SLOTS))
    end
end
