-- CharacterMarkdown - LibSets Integration Helper
-- Safe wrapper for LibSets library functionality
-- Gracefully degrades when LibSets is not available

local CM = CharacterMarkdown

-- =====================================================
-- LIBRARY AVAILABILITY CHECK
-- =====================================================

local function IsLibSetsAvailable()
    return (LibSets ~= nil) and (type(LibSets) == "table")
end

-- =====================================================
-- SET TYPE CONSTANTS (from LibSets documentation)
-- =====================================================

local SET_TYPE_NAMES = {
    [1] = "Arena",
    [2] = "Battleground",
    [3] = "Crafted",
    [4] = "Cyrodiil",
    [5] = "DailyRandomDungeonAndICReward",
    [6] = "Dungeon",
    [7] = "Imperial City",
    [8] = "Monster",
    [9] = "Overland",
    [10] = "Special",
    [11] = "Trial",
    [12] = "Mythic",
    [13] = "Imperial City Monster",
    [14] = "Cyrodiil Monster",
    [15] = "Class",
}

-- =====================================================
-- SET TYPE NAME CONVERSION
-- =====================================================

local function GetSetTypeName(setType)
    if not setType or type(setType) ~= "number" then
        return nil
    end
    return SET_TYPE_NAMES[setType] or "Unknown"
end

-- =====================================================
-- SET INFORMATION RETRIEVAL
-- =====================================================

local function GetSetInfo(setName)
    if not IsLibSetsAvailable() or not setName then
        return nil
    end

    local setInfo = nil

    -- Try to get set info by name first
    local success, result = pcall(function()
        -- LibSets.GetSetInfo might accept setName or setId
        -- Try with setName first
        if LibSets.GetSetInfo then
            return LibSets.GetSetInfo(setName)
        end
        return nil
    end)

    if success and result then
        setInfo = result
    else
        -- Try alternative methods if GetSetInfo doesn't work directly
        -- Some LibSets versions might use different function names
        success, result = pcall(function()
            if LibSets.GetSetInfoByName then
                return LibSets.GetSetInfoByName(setName)
            end
            return nil
        end)

        if success and result then
            setInfo = result
        end
    end

    if not setInfo then
        return nil
    end

    -- Extract relevant information
    local info = {
        setId = setInfo.setId,
        setName = setInfo.setName or setName,
        setType = setInfo.setType,
        setTypeName = GetSetTypeName(setInfo.setType),
        dropLocations = {},
        dropMechanics = {},
        dlcId = setInfo.dlcId,
        chapterId = setInfo.chapterId,
        zoneIds = setInfo.zoneIds,
    }

    -- Extract drop locations (zone names)
    if setInfo.zoneIds and type(setInfo.zoneIds) == "table" then
        for _, zoneId in ipairs(setInfo.zoneIds) do
            if zoneId and type(zoneId) == "number" then
                local zoneName = GetZoneNameById(zoneId)
                if zoneName and zoneName ~= "" then
                    table.insert(info.dropLocations, {
                        zoneId = zoneId,
                        zoneName = zoneName,
                    })
                end
            end
        end
    end

    -- Extract drop mechanics
    if setInfo.dropMechanicIds and type(setInfo.dropMechanicIds) == "table" then
        for _, mechanicId in ipairs(setInfo.dropMechanicIds) do
            if mechanicId and type(mechanicId) == "number" then
                table.insert(info.dropMechanics, mechanicId)
            end
        end
    end

    -- Also check for dropMechanicNames if available
    if setInfo.dropMechanicNames and type(setInfo.dropMechanicNames) == "table" then
        info.dropMechanicNames = setInfo.dropMechanicNames
    end

    return info
end

-- =====================================================
-- DROP LOCATION FORMATTING
-- =====================================================

local function FormatDropLocations(dropLocations)
    if not dropLocations or #dropLocations == 0 then
        return nil
    end

    local locations = {}
    for _, location in ipairs(dropLocations) do
        if location.zoneName then
            table.insert(locations, location.zoneName)
        end
    end

    if #locations == 0 then
        return nil
    end

    return table.concat(locations, ", ")
end

-- =====================================================
-- DROP MECHANICS FORMATTING
-- =====================================================

local function FormatDropMechanics(dropMechanics, dropMechanicNames)
    if not dropMechanics and not dropMechanicNames then
        return nil
    end

    local mechanics = {}

    -- Use dropMechanicNames if available (more descriptive)
    if dropMechanicNames and type(dropMechanicNames) == "table" then
        for _, mechanicName in ipairs(dropMechanicNames) do
            if mechanicName and mechanicName ~= "" then
                table.insert(mechanics, mechanicName)
            end
        end
    elseif dropMechanics and type(dropMechanics) == "table" then
        -- Fall back to mechanic IDs if names not available
        for _, mechanicId in ipairs(dropMechanics) do
            if mechanicId and type(mechanicId) == "number" then
                -- Try to get a readable name for the mechanic
                local mechanicName = string.format("Mechanic %d", mechanicId)
                table.insert(mechanics, mechanicName)
            end
        end
    end

    if #mechanics == 0 then
        return nil
    end

    return table.concat(mechanics, ", ")
end

-- =====================================================
-- DLC/CHAPTER INFORMATION FORMATTING
-- =====================================================

local function FormatDLCInfo(dlcId, chapterId)
    if not dlcId and not chapterId then
        return nil
    end

    local parts = {}

    if dlcId and type(dlcId) == "number" then
        -- Try to get DLC name if possible
        local dlcName = string.format("DLC %d", dlcId)
        table.insert(parts, dlcName)
    end

    if chapterId and type(chapterId) == "number" then
        local chapterName = string.format("Chapter %d", chapterId)
        table.insert(parts, chapterName)
    end

    if #parts == 0 then
        return nil
    end

    return table.concat(parts, ", ")
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.utils = CM.utils or {}
CM.utils.LibSetsIntegration = {
    IsLibSetsAvailable = IsLibSetsAvailable,
    GetSetInfo = GetSetInfo,
    GetSetTypeName = GetSetTypeName,
    FormatDropLocations = FormatDropLocations,
    FormatDropMechanics = FormatDropMechanics,
    FormatDLCInfo = FormatDLCInfo,
}

return {
    IsLibSetsAvailable = IsLibSetsAvailable,
    GetSetInfo = GetSetInfo,
    GetSetTypeName = GetSetTypeName,
    FormatDropLocations = FormatDropLocations,
    FormatDropMechanics = FormatDropMechanics,
    FormatDLCInfo = FormatDLCInfo,
}
