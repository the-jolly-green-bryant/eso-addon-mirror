local DCP = DynamicCP

-- "tree"
DCP.RED = "Red"
DCP.GREEN = "Green"
DCP.BLUE = "Blue"
local OFFSETS = { -- For slotIndex
    [DCP.GREEN] = 0,
    [DCP.BLUE] = 4,
    [DCP.RED] = 8,
}

local COLORS = {
    [DCP.GREEN] = "a5d752",
    [DCP.BLUE] = "59bae7",
    [DCP.RED] = "e46b2e",
}

local function IsTreeValid(tree)
    if (not OFFSETS[tree]) then return false end
    return true
end


---------------------------------------------------------------------
local pendingSets = {} -- {[uniqueName] = {Red = "Red1", Green = "Green2"}}


---------------------------------------------------------------------
-- Gets all slottable sets for a tree
-- @param tree - "Red" "Green" "Blue" or you can use DynamicCP.RED DynamicCP.GREEN DynamicCP.BLUE
-- @return a table of format {[slotSetId] = {name = "Slot Set Name", [1] = 12, [2] = 34, [3] = 56, [4] = 78}} where the numbers are champion skill IDs
function DCP.GetSlottableSets(tree)
    if (not IsTreeValid(tree)) then
        DCP.msg("Invalid tree: " .. tree)
        return
    end

    return ZO_DeepTableCopy(DCP.savedOptions.slotGroups[tree])
end


---------------------------------------------------------------------
-- Queues a slottable set to be committed
-- @param uniqueName - a unique name, e.g. your addon name. This avoids multiple addons trying to slot CP at once
-- @param tree - "Red" "Green" "Blue" or you can use DynamicCP.RED DynamicCP.GREEN DynamicCP.BLUE
-- @param slotSetId - the ID of the slot set to equip, i.e. the key from DynamicCP.GetSlottableSets(tree)
function DCP.QueueSlottableSet(uniqueName, tree, slotSetId)
    if (not IsTreeValid(tree)) then
        DCP.msg("Invalid tree: " .. tree)
        return
    end

    if (not pendingSets[uniqueName]) then
        pendingSets[uniqueName] = {}
    end
    pendingSets[uniqueName][tree] = slotSetId
end


---------------------------------------------------------------------
-- Clears the slottable set queue for your addon. Should be used when cancelling a respec
-- @param uniqueName - a unique name, e.g. your addon name
function DCP.ClearSlottableSetQueue(uniqueName)
    pendingSets[uniqueName] = nil
end


---------------------------------------------------------------------
-- Sends a champion purchase request with all the slottable sets you have previously queued
-- @param uniqueName - a unique name, e.g. your addon name
-- @param suppressMessages - whether to not print messages of what slottables were slotted
function DCP.CommitSlottableSets(uniqueName, suppressMessages)
    local sets = pendingSets[uniqueName]
    if (ZO_IsTableEmpty(sets)) then return end

    -- Do a first pass to collect wanted skillIds because we don't want to prepare purchase request if unneeded
    local desiredSlottables = {} -- {[slotIndex] = skillId}
    local valid = {}
    local alreadySlotted = {}
    local unavailable = {}

    for tree, slotSetId in pairs(sets) do
        if (slotSetId ~= -1) then
            local slotSet = DCP.savedOptions.slotGroups[tree][slotSetId]
            if (slotSet) then
                for i = 1, 4 do
                    local skillId = slotSet[i]
                    if (skillId) then
                        if (GetSlotBoundId(OFFSETS[tree] + i, HOTBAR_CATEGORY_CHAMPION) == skillId) then
                            DCP.dbg(GetChampionSkillName(skillId) .. " already slotted in " .. (OFFSETS[tree] + i))
                            table.insert(alreadySlotted, zo_strformat("|c<<2>><<C:1>>|r", GetChampionSkillName(skillId), COLORS[tree]))
                        elseif (WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))) then
                            desiredSlottables[OFFSETS[tree] + i] = skillId
                            table.insert(valid, zo_strformat("|c<<2>><<C:1>>|r", GetChampionSkillName(skillId), COLORS[tree]))
                        else
                            table.insert(unavailable, zo_strformat("|c<<2>><<C:1>>|r", GetChampionSkillName(skillId), COLORS[tree]))
                        end
                    end
                end
            else
                if (not suppressMessages) then
                    DCP.msg(string.format("|cFF0000Unable to apply slottable set %s in %s tree; was it deleted?", slotSetId, tree))
                end
            end
        end
    end

    -- Actual purchase request if there are things to slot
    if (next(desiredSlottables)) then
        PrepareChampionPurchaseRequest(false)
        for slotIndex, skillId in pairs(desiredSlottables) do
            AddHotbarSlotToChampionPurchaseRequest(slotIndex, skillId)
        end
        SendChampionPurchaseRequest()
        PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end

    -- Feedback
    if (not suppressMessages) then
        if (#valid > 0) then
            DCP.msg("Slotting: " .. table.concat(valid, "|cAAAAAA, |r"))
        end
        if (#alreadySlotted > 0) then
            DCP.msg("Already slotted: " .. table.concat(alreadySlotted, "|cAAAAAA, |r"))
        end
        if (#unavailable > 0) then
            DCP.msg("Unavailable: " .. table.concat(unavailable, "|cAAAAAA, |r"))
        end
    end

    pendingSets[uniqueName] = nil
end
