local Addon = LarvalTearMod
local LTM_SUBCLASS_NAME_HELPER = Addon.SubclassNameHelper
local LTM_SUBCLASS_NAME_LOCALIZATION = Addon.SubclassNameLocalization

local function GetStringValue(stringIdName, fallback)
    if type(stringIdName) ~= "string" or stringIdName == "" then
        return fallback
    end

    local stringId = rawget(_G, stringIdName)
    local value = type(GetString) == "function" and stringId ~= nil and GetString(stringId) or nil
    if type(value) ~= "string" or value == "" or value == stringIdName then
        return fallback
    end

    return value
end

local function GetUnknownName()
    return GetStringValue("SI_LTM_COMMON_UNKNOWN", "Unknown")
end

local function GetDefaultBuildName()
    return GetStringValue("SI_LTM_BUILD_CURRENT_NAME", "Current Build")
end

local function GetLocalizationRoot()
    local root = type(LTM_SUBCLASS_NAME_LOCALIZATION) == "table" and LTM_SUBCLASS_NAME_LOCALIZATION or nil
    if type(root) ~= "table" then
        return nil
    end

    local preferredEntries = root[Addon:GetClientLanguage()]
    if type(preferredEntries) == "table" then
        return preferredEntries
    end

    return type(root.en) == "table" and root.en or nil
end

local function ResolveRecordName(record, preferShort)
    if type(record) ~= "table" then
        return GetUnknownName()
    end

    local shortName = type(record.name_short) == "string" and record.name_short or ""
    local fullName = type(record.name_full) == "string" and record.name_full or ""
    if preferShort == true and shortName ~= "" then
        return shortName
    end

    if fullName ~= "" then
        return fullName
    end

    if shortName ~= "" then
        return shortName
    end

    return GetUnknownName()
end

local function ResolveClassIdFromLine(line)
    if type(line) ~= "table" then
        return nil
    end

    if type(line.classId) == "number" then
        return line.classId
    end

    local skillLineId = type(line.skillLineId) == "number" and line.skillLineId or nil
    local skillLineRecord = skillLineId ~= nil and LTM_SUBCLASS_NAME_HELPER:GetSkillLineRecord(skillLineId) or nil
    return type(skillLineRecord) == "table" and skillLineRecord.classId or nil
end

local function BuildDetailLabel(className, skillLineName, includeClass)
    if includeClass ~= false and className ~= "" and className ~= GetUnknownName() then
        return string.format("%s : %s", className, skillLineName)
    end

    return skillLineName
end

function LTM_SUBCLASS_NAME_HELPER:GetClassRecord(classId)
    if type(classId) ~= "number" then
        return nil
    end

    local root = GetLocalizationRoot()
    local classes = type(root) == "table" and root.classes or nil
    return type(classes) == "table" and classes[classId] or nil
end

function LTM_SUBCLASS_NAME_HELPER:GetSkillLineRecord(skillLineId)
    if type(skillLineId) ~= "number" then
        return nil
    end

    local root = GetLocalizationRoot()
    local skillLines = type(root) == "table" and root.skillLines or nil
    return type(skillLines) == "table" and skillLines[skillLineId] or nil
end

function LTM_SUBCLASS_NAME_HELPER:GetClassName(classId, options)
    local preferShort = type(options) == "table" and options.preferShort == true or false
    return ResolveRecordName(self:GetClassRecord(classId), preferShort)
end

function LTM_SUBCLASS_NAME_HELPER:GetSkillLineName(skillLineId, options)
    local preferShort = type(options) == "table" and options.preferShort == true or false
    return ResolveRecordName(self:GetSkillLineRecord(skillLineId), preferShort)
end

function LTM_SUBCLASS_NAME_HELPER:BuildBuildNameFromActiveLines(activeLines)
    local seenClassIds = {}
    local orderedNames = {}

    for _, line in ipairs(activeLines or {}) do
        local classId = ResolveClassIdFromLine(line)
        if type(classId) == "number" and not seenClassIds[classId] then
            seenClassIds[classId] = true
            orderedNames[#orderedNames + 1] = self:GetClassName(classId, {
                preferShort = true,
            })
        end
    end

    if #orderedNames == 0 then
        return GetDefaultBuildName()
    end

    return table.concat(orderedNames, " / ")
end

function LTM_SUBCLASS_NAME_HELPER:BuildDetailListFromActiveLines(activeLines, options)
    local names = {}
    local includeClass = type(options) ~= "table" or options.includeClass ~= false
    local preferClassShort = type(options) == "table" and options.preferClassShort == true or false
    local preferSkillLineShort = type(options) == "table" and options.preferSkillLineShort == true or false

    for _, line in ipairs(activeLines or {}) do
        local skillLineId = type(line) == "table" and line.skillLineId or nil
        if type(skillLineId) == "number" then
            local className = self:GetClassName(ResolveClassIdFromLine(line), {
                preferShort = preferClassShort,
            })
            local skillLineName = self:GetSkillLineName(skillLineId, {
                preferShort = preferSkillLineShort,
            })
            names[#names + 1] = BuildDetailLabel(className, skillLineName, includeClass)
        end
    end

    return names
end

function LTM_SUBCLASS_NAME_HELPER:BuildDetailListFromIds(skillLineIds, options)
    local names = {}
    local includeClass = type(options) ~= "table" or options.includeClass ~= false
    local preferClassShort = type(options) == "table" and options.preferClassShort == true or false
    local preferSkillLineShort = type(options) == "table" and options.preferSkillLineShort == true or false

    for _, skillLineId in ipairs(skillLineIds or {}) do
        if type(skillLineId) == "number" then
            local skillLineRecord = self:GetSkillLineRecord(skillLineId)
            local className = self:GetClassName(type(skillLineRecord) == "table" and skillLineRecord.classId or nil, {
                preferShort = preferClassShort,
            })
            local skillLineName = self:GetSkillLineName(skillLineId, {
                preferShort = preferSkillLineShort,
            })
            names[#names + 1] = BuildDetailLabel(className, skillLineName, includeClass)
        end
    end

    return names
end
