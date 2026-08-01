-- ============================================================================
-- Companion Wardrobe
-- Loadout Import / Export
--
-- Responsibilities:
-- - Export loadouts into a portable text format.
-- - Import and validate shared loadout data.
-- - Enforce schema compatibility and companion matching.
-- - Sanitize imported data before applying it.
--
-- Notes:
-- - Uses deterministic serialization for stable exports.
-- - Companion restrictions prevent cross-companion imports.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.EXPORT_KEY_ORDER = {
    schema = 1,
    version = 2,
    companion = 3,
    loadout = 4,

    defId = 10,
    name = 11,
    createdAt = 12,

    gear = 20,
    skills = 21,

    id = 30,
    link = 31,
}

function MHCWL.GetExportSortedKeys(value)
    local keys = {}

    for key, _ in pairs(value or {}) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        local orderA = MHCWL.EXPORT_KEY_ORDER[a] or 1000
        local orderB = MHCWL.EXPORT_KEY_ORDER[b] or 1000

        if orderA ~= orderB then
            return orderA < orderB
        end

        if type(a) == type(b) then
            return a < b
        end

        return tostring(a) < tostring(b)
    end)

    return keys
end

function MHCWL.SerializeExportKey(key)
    if type(key) == "number" then
        return "[" .. tostring(key) .. "]"
    end

    if type(key) == "string"
    and string.match(key, "^[%a_][%w_]*$") then
        return key
    end

    return "[\"" .. MHCWL.ExportEscapeString(key) .. "\"]"
end

-- Build the normalized export structure used by serialization.
function MHCWL.BuildExportData(index, includeGear, includeSkills)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return nil end

    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    if not setup then return nil end

    includeGear = includeGear ~= false
    includeSkills = includeSkills ~= false

    return {
        schema = "MHCWL_EXPORT",
        version = 1,

        companion = {
            defId = GetActiveCompanionDefId(),
            name = companionData.name,
        },

        loadout = {
            name = setup.name or GetString(MHCWL_EXPORTED_LOADOUT),
            createdAt = GetTimeStamp(),

            gear = includeGear and (setup.gear or {}) or nil,
            skills = includeSkills and (setup.skills or {}) or nil,
        },
    }
end

function MHCWL.ExportEscapeString(value)
    value = tostring(value or "")
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, "\n", "\\n")
    value = string.gsub(value, "\r", "\\r")
    value = string.gsub(value, "\"", "\\\"")
    return value
end

function MHCWL.SerializeExportValue(value, indent)
    indent = indent or 0
    local pad = string.rep("    ", indent)
    local nextPad = string.rep("    ", indent + 1)

    local valueType = type(value)

    if valueType == "string" then
        return "\"" .. MHCWL.ExportEscapeString(value) .. "\""
    end

    if valueType == "number" then
        return tostring(value)
    end

    if valueType == "boolean" then
        return value and "true" or "false"
    end

    if valueType == "table" then
        local parts = {}

        table.insert(parts, "{")

        for _, key in ipairs(MHCWL.GetExportSortedKeys(value)) do
            local childValue = value[key]
            local keyText = MHCWL.SerializeExportKey(key)

            table.insert(parts,
                nextPad
                .. keyText
                .. " = "
                .. MHCWL.SerializeExportValue(childValue, indent + 1)
                .. ","
            )
        end

        table.insert(parts, pad .. "}")

        return table.concat(parts, "\n")
    end

    return "nil"
end

-- Convert export data into the text format used for sharing and backup.
function MHCWL.SerializeExport(data)
    return "MHCWL_EXPORT_V1 = " .. MHCWL.SerializeExportValue(data, 0)
end

-- Parse a quoted string from Companion Wardrobe export text.
function MHCWL.ParseExportString(text, pos)
    local result = {}
    local length = #text

    pos = pos + 1

    while pos <= length do
        local char = string.sub(text, pos, pos)

        if char == "\"" then
            return table.concat(result), pos + 1
        end

        if char == "\\" then
            local nextChar = string.sub(text, pos + 1, pos + 1)

            if nextChar == "n" then
                table.insert(result, "\n")
            elseif nextChar == "r" then
                table.insert(result, "\r")
            elseif nextChar == "\\" then
                table.insert(result, "\\")
            elseif nextChar == "\"" then
                table.insert(result, "\"")
            else
                return nil, nil
            end

            pos = pos + 2
        else
            table.insert(result, char)
            pos = pos + 1
        end
    end

    return nil, nil
end

-- Skip whitespace while parsing Companion Wardrobe export text.
function MHCWL.SkipExportWhitespace(text, pos)
    while true do
        local char = string.sub(text, pos, pos)

        if char ~= " "
        and char ~= "\n"
        and char ~= "\r"
        and char ~= "\t" then
            return pos
        end

        pos = pos + 1
    end
end

-- Parse a single value from Companion Wardrobe export text.
function MHCWL.ParseExportValue(text, pos)
    pos = MHCWL.SkipExportWhitespace(text, pos)

    local char = string.sub(text, pos, pos)

    if char == "\"" then
        return MHCWL.ParseExportString(text, pos)
    end

    if char == "{" then
        return MHCWL.ParseExportTable(text, pos)
    end

    local rest = string.sub(text, pos)

    local numberText = string.match(rest, "^-?%d+%.?%d*")

    if numberText and numberText ~= "" then
        return tonumber(numberText), pos + #numberText
    end

    if string.sub(text, pos, pos + 3) == "true" then
        return true, pos + 4
    end

    if string.sub(text, pos, pos + 4) == "false" then
        return false, pos + 5
    end

    if string.sub(text, pos, pos + 2) == "nil" then
        return nil, pos + 3, true
    end

    return nil, nil
end

-- Parse a table key from Companion Wardrobe export text.
function MHCWL.ParseExportKey(text, pos)
    pos = MHCWL.SkipExportWhitespace(text, pos)

    local char = string.sub(text, pos, pos)

    if char == "[" then
        pos = MHCWL.SkipExportWhitespace(text, pos + 1)

        local key

        if string.sub(text, pos, pos) == "\"" then
            key, pos = MHCWL.ParseExportString(text, pos)

            if key == nil then
                return nil, nil
            end
        else
            local rest = string.sub(text, pos)
            local numberText = string.match(rest, "^-?%d+")

            if not numberText then
                return nil, nil
            end

            key = tonumber(numberText)
            pos = pos + #numberText
        end

        pos = MHCWL.SkipExportWhitespace(text, pos)

        if string.sub(text, pos, pos) ~= "]" then
            return nil, nil
        end

        return key, pos + 1
    end

    local rest = string.sub(text, pos)
    local key = string.match(rest, "^[%a_][%w_]*")

    if key then
        return key, pos + #key
    end

    return nil, nil
end

-- Parse a table from Companion Wardrobe export text without executing code.
function MHCWL.ParseExportTable(text, pos)
    local result = {}

    pos = pos + 1

    while true do
        pos = MHCWL.SkipExportWhitespace(text, pos)

        local char = string.sub(text, pos, pos)

        if char == "}" then
            return result, pos + 1
        end

        local key
        key, pos = MHCWL.ParseExportKey(text, pos)

        if key == nil then
            return nil, nil
        end

        pos = MHCWL.SkipExportWhitespace(text, pos)

        if string.sub(text, pos, pos) ~= "=" then
            return nil, nil
        end

        local value
        local parsedNil

        value, pos, parsedNil = MHCWL.ParseExportValue(text, pos + 1)

        if pos == nil then
            return nil, nil
        end

        if parsedNil then
            result[key] = nil
        else
            result[key] = value
        end

        pos = MHCWL.SkipExportWhitespace(text, pos)

        char = string.sub(text, pos, pos)

        if char == "," then
            pos = pos + 1
        elseif char ~= "}" then
            return nil, nil
        end
    end
end

-- Validate and deserialize import text before any loadout data is applied.
function MHCWL.ParseImportText(text)
    text = tostring(text or "")
    text = zo_strtrim(text)

    if text == "" then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_EMPTY)
    end

    if not string.find(text, "^MHCWL_EXPORT_V1%s*=") then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_FORMAT_INVALID)
    end

    local dataText = string.gsub(
        text,
        "^MHCWL_EXPORT_V1%s*=%s*",
        "",
        1
    )

    local data
    local pos

    data, pos = MHCWL.ParseExportValue(dataText, 1)

    if type(data) ~= "table" then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_DATA_INVALID)
    end

    pos = MHCWL.SkipExportWhitespace(dataText, pos)

    if pos <= #dataText then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_FORMAT_INVALID)
    end

    if data.schema ~= "MHCWL_EXPORT" then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_INVALID_SCHEMA)
    end

    if data.version ~= 1 then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_INVALID_VERSION)
    end

    if type(data.loadout) ~= "table" then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_NO_DATA_LOADOUT)
    end

    if type(data.loadout.gear) ~= "table"
    and type(data.loadout.skills) ~= "table" then
        return nil, GetString(MHCWL_NOTIFY_IMPORT_NO_DATA_LOADOUT)
    end

    return data, nil
end

-- Apply validated import data to a new or existing loadout.
function MHCWL.ApplyImportedLoadout(data, targetIndex, overwrite, importGear, importSkills, importAsFavorite)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        return false, GetString(MHCWL_NOTIFY_IMPORT_NO_ACTIVE_COMPANION)
    end

    MHCWL.EnsureCompanionSetups(companionData)

    local loadout = data and data.loadout
    if type(loadout) ~= "table" then
        return false, GetString(MHCWL_NOTIFY_IMPORT_NO_DATA_LOADOUT)
    end

    importGear = importGear ~= false
    importSkills = importSkills ~= false

    local importCompanion = data.companion
    local activeCompanionDefId = GetActiveCompanionDefId()

    if type(importCompanion) ~= "table"
    or importCompanion.defId ~= activeCompanionDefId then
        return false, GetString(MHCWL_NOTIFY_IMPORT_WRONG_COMPANION)
    end

    local index

    if overwrite then
        index = tonumber(targetIndex)

        if not index or not companionData.setups[index] then
            return false, GetString(MHCWL_NOTIFY_IMPORT_INVALID_TARGET)
        end

        if companionData.setups[index].locked then
            return false, GetString(MHCWL_NOTIFY_LOCKED)
        end
    else
        index = MHCWL.AddSetup(companionData)

        if not index then
            return false, GetString(MHCWL_NOTIFY_IMPORT_MAX_LOADOUT_COUNT)
        end
    end

    if type(loadout.gear) ~= "table" then
        MHCWL.Debug("Import: invalid gear data detected, sanitized.")
    end

    local sanitizedGear = type(loadout.gear) == "table" and loadout.gear or {}

    if type(loadout.skills) ~= "table" then
        MHCWL.Debug("Import: invalid skills data detected, sanitized.")
    end

    local sanitizedSkills = type(loadout.skills) == "table" and loadout.skills or {}

    local existingSetup = companionData.setups[index] or {}
    local importedName = tostring(loadout.name or GetString(MHCWL_IMPORTED_LOADOUT))

    if not overwrite then
        local baseName = importedName
        local suffix = 1

        local function NameExists(name)
            for setupIndex, setup in pairs(companionData.setups) do
                if setupIndex ~= index
                and setup
                and tostring(setup.name or "") == name then
                    return true
                end
            end

            return false
        end

        while NameExists(importedName) do
            importedName = string.format("%s (%d)", baseName, suffix)
            suffix = suffix + 1
        end
    end

    companionData.setups[index] = {
        name = importedName,
        locked = false,
        isFavorite = importAsFavorite == true,
        useColorWhenFavorite = existingSetup.useColorWhenFavorite or false,
        nameColorSlot = existingSetup.nameColorSlot,

        gear = importGear and sanitizedGear or (existingSetup.gear or {}),
        skills = importSkills and sanitizedSkills or (existingSetup.skills or {}),
    }

    companionData.activeSetup = index
    companionData.activePage = math.ceil(index / MHCWL.LOADOUTS_PER_PAGE)

    return true, index
end