local Addon = LarvalTearMod
local M = Addon.Modules.SkillSnapshotAudit
local Util = Addon.Common.Util

local function ResolveAvailablePoints()
    if type(GetAvailableSkillPoints) == "function" then
        local value = Util:SafeCall(GetAvailableSkillPoints)
        if type(value) == "number" then
            return value
        end
    end

    if type(SKILL_POINT_ALLOCATION_MANAGER) == "table"
        and type(SKILL_POINT_ALLOCATION_MANAGER.GetAvailableSkillPoints) == "function" then
        local value = Util:SafeCall(SKILL_POINT_ALLOCATION_MANAGER.GetAvailableSkillPoints, SKILL_POINT_ALLOCATION_MANAGER)
        if type(value) == "number" then
            return value
        end
    end

    return nil
end

local function ResolveText(value, fallback)
    if type(value) == "string" and value ~= "" then
        if type(zo_strformat) == "function" then
            local formatted = Util:SafeCall(zo_strformat, "<<C:1>>", value)
            if type(formatted) == "string" and formatted ~= "" then
                return formatted
            end
        end
        return value
    end

    return fallback
end

local function ResolveMorphLabel(currentMorphSlot)
    if currentMorphSlot == MORPH_SLOT_BASE then
        return "B"
    elseif currentMorphSlot == MORPH_SLOT_MORPH_1 then
        return "M1"
    elseif currentMorphSlot == MORPH_SLOT_MORPH_2 then
        return "M2"
    end

    return "?"
end

local function ResolveSkillTypeName(skillTypeData)
    return ResolveText(Util:SafeCallMethod(skillTypeData, "GetName"), tostring(Util:SafeCallMethod(skillTypeData, "GetSkillType") or "?"))
end

local function ResolveLineName(skillLineData)
    return ResolveText(Util:SafeCallMethod(skillLineData, "GetName"), tostring(Util:SafeCallMethod(skillLineData, "GetId") or "?"))
end

local function ResolveSkillName(skillData)
    return ResolveText(Util:SafeCallMethod(skillData, "GetName"), tostring(Util:SafeCallMethod(skillData, "GetProgressionId") or "?"))
end

local function BuildSkillEntry(skillData, skillIndex)
    local pointsAllocated = tonumber(Util:SafeCallMethod(skillData, "GetNumPointsAllocated")) or 0
    local purchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
    if not purchased and pointsAllocated <= 0 then
        return nil
    end

    local name = ResolveSkillName(skillData)
    local isPassive = Util:SafeCallMethod(skillData, "IsPassive") == true
    local entry = {
        skillIndex = tonumber(skillIndex) or 0,
        name = name,
        isPassive = isPassive,
        purchased = purchased,
        pointsAllocated = pointsAllocated,
        progressionId = tonumber(Util:SafeCallMethod(skillData, "GetProgressionId")) or nil,
        currentMorphSlot = Util:SafeCallMethod(skillData, "GetCurrentMorphSlot"),
        currentRank = tonumber(Util:SafeCallMethod(skillData, "GetCurrentRank")) or 0,
        numRanks = tonumber(Util:SafeCallMethod(skillData, "GetNumRanks")) or 0,
        isAutoGrant = Util:SafeCallMethod(skillData, "IsAutoGrant") == true,
        costMultiplier = tonumber(Util:SafeCallMethod(skillData, "GetSkillPointCostMultiplier")) or nil,
    }

    if isPassive then
        entry.kind = "passive"
        entry.detailText = string.format(
            "P: %s [r%d/%d] %dpt",
            name,
            entry.currentRank,
            entry.numRanks,
            pointsAllocated
        )
        return entry
    end

    entry.kind = "active"
    entry.detailText = string.format(
        "A: %s [%s] %dpt",
        name,
        ResolveMorphLabel(entry.currentMorphSlot),
        pointsAllocated
    )
    return entry
end

local function BuildLineSnapshot(skillTypeName, skillLineData)
    local linePointsAllocated = tonumber(Util:SafeCallMethod(skillLineData, "GetNumPointsAllocated")) or 0
    local isActive = Util:SafeCallMethod(skillLineData, "IsActive") == true
    local isDiscovered = Util:SafeCallMethod(skillLineData, "IsDiscovered") == true
    local isClassSkillLine = Util:SafeCallMethod(skillLineData, "IsClassSkillLine") == true
    local isPlayerClassSkillLine = Util:SafeCallMethod(skillLineData, "IsPlayerClassSkillLine") == true
    local isClassMastery = Util:SafeCallMethod(skillLineData, "IsClassMastery") == true

    local entry = {
        skillTypeName = skillTypeName,
        skillLineId = tonumber(Util:SafeCallMethod(skillLineData, "GetId")) or 0,
        skillLineName = ResolveLineName(skillLineData),
        linePointsAllocated = linePointsAllocated,
        isActive = isActive,
        isDiscovered = isDiscovered,
        isClassSkillLine = isClassSkillLine,
        isPlayerClassSkillLine = isPlayerClassSkillLine,
        isClassMastery = isClassMastery,
        activePurchasedCount = 0,
        activeMorphedCount = 0,
        passivePurchasedCount = 0,
        skills = {},
        details = {},
    }

    local numSkills = tonumber(Util:SafeCallMethod(skillLineData, "GetNumSkills")) or 0
    for skillIndex = 1, numSkills do
        local skillData = Util:SafeCallMethod(skillLineData, "GetSkillDataByIndex", skillIndex)
        if type(skillData) == "table" then
            local purchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
            local isPassive = Util:SafeCallMethod(skillData, "IsPassive") == true
            if purchased then
                if isPassive then
                    entry.passivePurchasedCount = entry.passivePurchasedCount + 1
                else
                    entry.activePurchasedCount = entry.activePurchasedCount + 1
                    local currentMorphSlot = Util:SafeCallMethod(skillData, "GetCurrentMorphSlot")
                    if currentMorphSlot ~= nil and currentMorphSlot ~= MORPH_SLOT_BASE then
                        entry.activeMorphedCount = entry.activeMorphedCount + 1
                    end
                end
            end

            local skillEntry = BuildSkillEntry(skillData, skillIndex)
            if type(skillEntry) == "table" then
                entry.skills[#entry.skills + 1] = skillEntry
            end

            local detailKind = type(skillEntry) == "table" and skillEntry.kind or nil
            local detailText = type(skillEntry) == "table" and skillEntry.detailText or nil
            if type(detailText) == "string" and detailText ~= "" then
                entry.details[#entry.details + 1] = {
                    kind = detailKind,
                    text = detailText,
                }
            end
        end
    end

    return entry
end

function M:CaptureCurrentSnapshot()
    local snapshot = {
        capturedAt = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or nil,
        availablePoints = ResolveAvailablePoints(),
        totalAllocatedPoints = 0,
        visibleLineCount = 0,
        hiddenZeroLineCount = 0,
        lines = {},
    }

    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.SkillTypeIterator) ~= "function" then
        return snapshot, "skills_data_manager_unavailable"
    end

    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        local skillTypeName = ResolveSkillTypeName(skillTypeData)
        if type(skillTypeData) == "table"
            and type(skillTypeData.SkillLineIterator) == "function" then
            for _, skillLineData in skillTypeData:SkillLineIterator() do
                local lineEntry = BuildLineSnapshot(skillTypeName, skillLineData)
                snapshot.totalAllocatedPoints = snapshot.totalAllocatedPoints + (lineEntry.linePointsAllocated or 0)

                local shouldShow = lineEntry.isDiscovered == true
                    or lineEntry.isActive == true
                    or (lineEntry.linePointsAllocated or 0) > 0
                    or #lineEntry.details > 0
                if shouldShow then
                    snapshot.visibleLineCount = snapshot.visibleLineCount + 1
                    snapshot.lines[#snapshot.lines + 1] = lineEntry
                else
                    snapshot.hiddenZeroLineCount = snapshot.hiddenZeroLineCount + 1
                end
            end
        end
    end

    table.sort(snapshot.lines, function(left, right)
        if left.skillTypeName == right.skillTypeName then
            return (left.skillLineId or 0) < (right.skillLineId or 0)
        end
        return tostring(left.skillTypeName) < tostring(right.skillTypeName)
    end)

    return snapshot, nil
end

function M:FormatSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return "snapshot unavailable"
    end

    local lines = {}
    lines[#lines + 1] = string.format(
        "Available: %s pt / Allocated: %s pt / Visible Lines: %s / Hidden Zero Lines: %s",
        tostring(snapshot.availablePoints or "?"),
        tostring(snapshot.totalAllocatedPoints or 0),
        tostring(snapshot.visibleLineCount or 0),
        tostring(snapshot.hiddenZeroLineCount or 0)
    )
    lines[#lines + 1] = ""

    local currentSkillTypeName = nil
    for _, lineEntry in ipairs(snapshot.lines or {}) do
        if currentSkillTypeName ~= lineEntry.skillTypeName then
            currentSkillTypeName = lineEntry.skillTypeName
            lines[#lines + 1] = string.format("[%s]", tostring(currentSkillTypeName))
        end

        lines[#lines + 1] = string.format(
            "- %s (id=%s, pts=%s, active=%s, discovered=%s, actives=%s, morphs=%s, passives=%s)",
            tostring(lineEntry.skillLineName or "?"),
            tostring(lineEntry.skillLineId or 0),
            tostring(lineEntry.linePointsAllocated or 0),
            tostring(lineEntry.isActive == true),
            tostring(lineEntry.isDiscovered == true),
            tostring(lineEntry.activePurchasedCount or 0),
            tostring(lineEntry.activeMorphedCount or 0),
            tostring(lineEntry.passivePurchasedCount or 0)
        )

        for _, detail in ipairs(lineEntry.details or {}) do
            lines[#lines + 1] = "  " .. tostring(detail.text)
        end
    end

    return table.concat(lines, "\n")
end

function M:CaptureAndFormatSnapshot()
    local snapshot, err = self:CaptureCurrentSnapshot()
    local text = self:FormatSnapshot(snapshot)
    return {
        snapshot = snapshot,
        text = text,
        error = err,
    }
end
