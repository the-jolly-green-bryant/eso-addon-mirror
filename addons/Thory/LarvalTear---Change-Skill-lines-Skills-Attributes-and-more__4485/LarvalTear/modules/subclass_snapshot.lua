local Addon = LarvalTearMod
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot
local Util = Addon.Common.Util

local function BuildLineIdSet(lines)
    local seen = {}
    local ordered = {}

    for _, line in ipairs(lines or {}) do
        local skillLineId = type(line) == "table" and line.skillLineId or nil
        if type(skillLineId) == "number" and not seen[skillLineId] then
            seen[skillLineId] = true
            ordered[#ordered + 1] = skillLineId
        end
    end

    table.sort(ordered)
    return ordered
end

local function BuildSkillLineIdMap(lines)
    local map = {}

    for _, line in ipairs(lines or {}) do
        if type(line) == "table" and type(line.skillLineId) == "number" then
            map[line.skillLineId] = line
        end
    end

    return map
end

local function ResolveClassName(skillLineData, classId)
    local className = Util:SafeCallMethod(skillLineData, "GetClassName")
    if className ~= nil and className ~= "" then
        return className
    end

    if type(GetClassName) == "function" and classId ~= nil then
        return Util:SafeCall(GetClassName, GENDER_MALE or 0, classId)
    end

    return nil
end

local function AnnotateMainClassLines(lines, baseClassId)
    for _, line in ipairs(lines or {}) do
        if type(line) == "table" then
            line.isMainClassLine = baseClassId ~= nil and line.classId == baseClassId or false
        end
    end
end

local function ResolveSkillLineName(skillLineData, skillLineId)
    local skillLineName = Util:SafeCallMethod(skillLineData, "GetName")
    if skillLineName ~= nil and skillLineName ~= "" then
        return skillLineName
    end

    if type(GetSkillLineNameById) == "function" and skillLineId ~= nil then
        return Util:SafeCall(GetSkillLineNameById, skillLineId)
    end

    return nil
end

local function BuildEmptyClassInfo(context)
    return {
        characterId = context and context.characterId or nil,
        baseClassId = context and context.baseClassId or nil,
        subclassingAvailable = nil,
    }
end

function LTM_SUBCLASS_SNAPSHOT:CaptureCurrentClassInfo(context)
    local classInfo = BuildEmptyClassInfo(context)

    if classInfo.baseClassId == nil and type(GetUnitClassId) == "function" then
        local ok, classId = pcall(GetUnitClassId, "player")
        if ok then
            classInfo.baseClassId = classId
            if type(context) == "table" and context.baseClassId == nil then
                context.baseClassId = classId
            end
        end
    end

    if type(GetSubclassingAccessLevel) == "function" then
        local ok, accessLevel = pcall(GetSubclassingAccessLevel)
        if ok then
            classInfo.subclassingAvailable = accessLevel
        end
    end

    return classInfo
end

function LTM_SUBCLASS_SNAPSHOT:CollectAllClassSkillLines()
    local skillLines = {}
    local diagnostics = {
        classCount = 0,
        enumeratedLineCount = 0,
        usingSkillsDataManager = type(SKILLS_DATA_MANAGER) == "table",
        missingSkillLineDataCount = 0,
    }

    local numClasses = Util:SafeCall(GetNumClasses) or 0
    diagnostics.classCount = numClasses

    for classIndex = 1, numClasses do
        local classId = Util:SafeCall(GetClassIdByIndex, classIndex)
        if classId ~= nil then
            local numSkillLines = Util:SafeCall(GetNumSkillLinesForClass, classId) or 0
            for skillLineIndex = 1, numSkillLines do
                local skillLineId = Util:SafeCall(GetSkillLineIdForClass, classId, skillLineIndex)
                if skillLineId ~= nil then
                    diagnostics.enumeratedLineCount = diagnostics.enumeratedLineCount + 1

                    local skillLineData = type(SKILLS_DATA_MANAGER) == "table"
                        and Util:SafeCallMethod(SKILLS_DATA_MANAGER, "GetSkillLineDataById", skillLineId)
                        or nil

                    if skillLineData == nil then
                        diagnostics.missingSkillLineDataCount = diagnostics.missingSkillLineDataCount + 1
                    end

                    local resolvedClassId = Util:SafeCallMethod(skillLineData, "GetClassId") or classId
                    local line = {
                        skillLineId = skillLineId,
                        classId = resolvedClassId,
                        skillLineName = ResolveSkillLineName(skillLineData, skillLineId),
                        className = ResolveClassName(skillLineData, resolvedClassId),
                        isActive = Util:SafeCallMethod(skillLineData, "IsActive") == true,
                        isDiscovered = Util:SafeCallMethod(skillLineData, "IsDiscovered") == true,
                        isPlayerClassSkillLine = Util:SafeCallMethod(skillLineData, "IsPlayerClassSkillLine") == true,
                        classIndex = classIndex,
                        skillLineIndex = skillLineIndex,
                    }

                    if line.isPlayerClassSkillLine == false and type(IsPlayerClassSkillLineById) == "function" then
                        line.isPlayerClassSkillLine = Util:SafeCall(IsPlayerClassSkillLineById, skillLineId) == true
                    end

                    skillLines[#skillLines + 1] = line
                end
            end
        end
    end

    return skillLines, diagnostics
end

function LTM_SUBCLASS_SNAPSHOT:FilterActiveClassSkillLines(skillLines)
    local activeSkillLines = {}

    for _, line in ipairs(skillLines or {}) do
        if type(line) == "table" and line.isActive == true then
            activeSkillLines[#activeSkillLines + 1] = line
        end
    end

    table.sort(activeSkillLines, function(left, right)
        return (left.skillLineId or 0) < (right.skillLineId or 0)
    end)

    return activeSkillLines
end

function LTM_SUBCLASS_SNAPSHOT:BuildSnapshotResult(context, allSkillLines, activeSkillLines, diagnostics)
    local classInfo = self:CaptureCurrentClassInfo(context)
    AnnotateMainClassLines(allSkillLines, classInfo.baseClassId)
    AnnotateMainClassLines(activeSkillLines, classInfo.baseClassId)

    local activeSkillLineIds = BuildLineIdSet(activeSkillLines)
    local result = {
        ok = true,
        capturedAt = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or nil,
        classInfo = classInfo,
        allSkillLines = allSkillLines,
        allSkillLineById = BuildSkillLineIdMap(allSkillLines),
        activeLines = activeSkillLines,
        activeSkillLines = activeSkillLines,
        activeSkillLineIds = activeSkillLineIds,
        activeLineBySlot = {},
        diagnostics = diagnostics or {},
    }

    result.diagnostics.activeCount = #activeSkillLines
    result.diagnostics.activeSkillLineIds = activeSkillLineIds
    return result
end

function LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)
    local allSkillLines, diagnostics = self:CollectAllClassSkillLines()
    local activeSkillLines = self:FilterActiveClassSkillLines(allSkillLines)
    diagnostics = diagnostics or {}
    diagnostics.source = "runtime_class_skill_line_enumeration"
    diagnostics.enumerationImplemented = true

    local state = self:BuildSnapshotResult(context, allSkillLines, activeSkillLines, diagnostics)

    return state
end
