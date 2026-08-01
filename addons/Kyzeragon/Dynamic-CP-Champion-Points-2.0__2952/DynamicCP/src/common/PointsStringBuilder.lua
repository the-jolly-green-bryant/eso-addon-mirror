local DCP = DynamicCP

-- This is the INDEX, not ID
local TREE_TO_DISCIPLINE = {
    Green = 1,
    Blue = 2,
    Red = 3,
}

local function GetTreeFromDisciplineIndex(disciplineIndex)
    for tree, index in pairs(TREE_TO_DISCIPLINE) do
        if (index == disciplineIndex) then
            return tree
        end
    end
end

---------------------------------------------------------------------
-- Get the slottables in the selected preset, or what would be
-- slotted automatically

-- TODO: remove for lite
local function GetSlottablesFromSlotSet(tree, slotSetId)
    return DynamicCP.savedOptions.slotGroups[tree][slotSetId]
end

-- TODO: this prob shouldn't be here, used in presets.lua too
-- slotSetId: optional; or it's obtained from cp
local function GetSlottablesDynamically(cp, tree, slotSetId)
    -- Return the slottables if this is a smart preset
    if (cp.slottables) then
        return cp.slottables
    end

    -- Return the slottables from the slot set if it exists
    local slotSetId = cp.slotSet or slotSetId
    if (slotSetId ~= nil) then
        local slotSet = GetSlottablesFromSlotSet(tree, slotSetId)
        if (slotSet ~= nil) then
            return slotSet
        end

        DynamicCP.dbg("|cFF0000Couldn't find slot set " .. slotSetId .. ", slotting automatically for now.|r")
    else
        DynamicCP.dbg("|cFF0000No slotSetId, slotting automatically.|r")
    end

    -- Otherwise, slot automatically. Collect slottables from the specified CP
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    local potentialSlottablesData = {}
    for skillId, numPoints in pairs(cp[disciplineIndex]) do
        local isSlottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))
        if (isSlottable and WouldChampionSkillNodeBeUnlocked(skillId, numPoints)) then
            table.insert(potentialSlottablesData, {skillId = skillId, points = numPoints, maxPoints = GetChampionSkillMaxPoints(skillId)})
        end
    end

    -- Sort by most maxed
    table.sort(potentialSlottablesData, function(item1, item2)
        local prop1 = item1.points / item1.maxPoints
        local prop2 = item2.points / item2.maxPoints
        if (prop1 == prop2) then
            if (item1.maxPoints == item2.maxPoints) then
                -- Last resort, sort by skill id
                return item1.skillId < item2.skillId
            end
            -- If proportions are equal, prioritize ones with higher max because idk
            return item1.maxPoints > item2.maxPoints
        end
        return prop1 > prop2
    end)

    -- Return the first 4
    local slottablesResult = {}
    for i = 1, 4 do
        if (potentialSlottablesData[i]) then
            local skillId = potentialSlottablesData[i].skillId
            slottablesResult[i] = skillId
        end
    end
    return slottablesResult
end
DynamicCP.GetSlottablesDynamically = GetSlottablesDynamically

-- Build string for the slottables in this CP
local function GenerateTreeSlottables(cp, tree, slotSetId)
    local color = {
        Green = "a5d752",
        Blue = "59bae7",
        Red = "e46b2e",
    }

    local slottables = GetSlottablesDynamically(cp, tree, slotSetId)
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    local result = {}
    for i = 1, 4 do
        local skillId = slottables[i]
        local skillName = ""
        if (skillId) then
            if (WouldChampionSkillNodeBeUnlocked(skillId, cp[disciplineIndex][skillId] or 0)) then
                skillName = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
            else
                -- Display in red if there aren't enough points
                skillName = zo_strformat("|cFF4444<<C:1>>|r", GetChampionSkillName(skillId))
            end
        end
        result[i] = zo_strformat("|c<<1>>(+) <<2>>:|r <<3>>", color[tree], i, skillName)
    end

    return result
end

-- Find and build string of the diff between two cp sets
-- result: the entire string
-- col1: array of the CP names
-- col2: array of the diff
local function GenerateDiff(before, after)
    local result = "Changes:"
    local col1 = {}
    local col2 = {}

    local numChanges = 0
    local assumedIndex = 1
    for disciplineIndex = 1, GetNumChampionDisciplines() do
        if (before[disciplineIndex] and after[disciplineIndex]) then
            assumedIndex = disciplineIndex
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                local first = before[disciplineIndex][skillId] or 0
                local second = after[disciplineIndex][skillId] or 0
                if (first ~= second and (first ~= 0 or second ~= 0)) then
                    local line = zo_strformat("\n|cBBBBBB<<C:1>>:  <<2>> → <<3>>",
                        GetChampionSkillName(skillId),
                        first,
                        second)

                    table.insert(col1, zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
                    if (first < second) then
                        line = line .. "|c00FF00↑|r"
                        table.insert(col2, zo_strformat("<<1>> → <<2>>|c00FF00↑|r", first, second))
                    else
                        line = line .. "|cFF0000↓|r"
                        table.insert(col2, zo_strformat("<<1>> → <<2>>|cFF0000↓|r", first, second))
                    end
                    result = result .. line
                    numChanges = numChanges + 1
                end
            end
        end
    end

    if (result == "Changes:") then
        result = "|cBBBBBBNo points changes.|r"
    end
    return result, numChanges, col1, col2, GenerateTreeSlottables(after, GetTreeFromDisciplineIndex(assumedIndex))
end
DCP.PointsStringBuilder.GenerateDiff = GenerateDiff

-- Build string for this CP, but only for certain tree
-- Called when loading or saving a preset
local function GenerateTree(cp, tree, slotSetId)
    local result = "|cBBBBBB"
    local col1 = {}
    local col2 = {}
    local numLines = 0

    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local points = cp[disciplineIndex][skillId]
        if (points ~= 0) then
            local line = zo_strformat("\n<<C:1>>:  <<2>>",
                GetChampionSkillName(skillId),
                points)
            result = result .. line
            numLines = numLines + 1
            table.insert(col1, zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
            table.insert(col2, zo_strformat("<<1>>", points))
        end
    end

    return result .. "|r", numLines, col1, col2, GenerateTreeSlottables(cp, tree, slotSetId)
end
DCP.PointsStringBuilder.GenerateTree = GenerateTree
