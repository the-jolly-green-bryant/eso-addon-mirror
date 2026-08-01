-- CharacterMarkdown - API Layer - Character
-- Abstraction for character identity, race, class, and location

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.character = {}

local api = CM.api.character

-- =====================================================
-- FALLBACK LOOKUP TABLES
-- =====================================================

-- Race ID to name mapping (fallback if API fails)
local RACE_NAMES = CM.Constants.RACE_NAMES

-- Class ID to name mapping (fallback if API fails)
local CLASS_NAMES = CM.Constants.CLASS_NAMES

-- =====================================================
-- PUBLIC API
-- =====================================================

---Get the character's name and display name
---@return table {name=string, displayName=string}
function api.GetName()
    local name = CM.SafeCall(GetUnitName, "player")
    local displayName = CM.SafeCall(GetDisplayName)
    return {
        name = name or "Unknown",
        displayName = displayName or "Unknown",
    }
end

---Get the character's gender
---@return table {id=number, name=string}
function api.GetGender()
    local genderId = CM.SafeCall(GetUnitGender, "player")
    -- ESO Gender constants: 1 = Female, 2 = Male, 3 = Neuter (usually 1 or 2 for players)
    local genderName = "Unknown"
    if genderId == 1 then
        genderName = "Female"
    elseif genderId == 2 then
        genderName = "Male"
    end
    return {
        id = genderId,
        name = genderName,
    }
end

---Get the character's race
---@return table {id=number, name=string}
function api.GetRace()
    local raceId = CM.SafeCall(GetUnitRaceId, "player")

    local genderId = CM.SafeCall(GetUnitGender, "player") or GENDER_MALE

    -- Use GetRaceName() as documented in API_REFERENCE.md
    local raceName = CM.SafeCall(GetRaceName, genderId, raceId)

    -- Fallback to lookup table if API fails
    if (not raceName or raceName == "") and RACE_NAMES[raceId] then
        raceName = RACE_NAMES[raceId]
    end

    -- Format the name if we got one
    if raceName and raceName ~= "" then
        raceName = zo_strformat("<<1>>", raceName)
    end

    if not raceName or raceName == "" then
        CM.Error(
            string.format(
                "GetRace: Failed to get race name for raceId=%s. Tried GetRaceName() and lookup table",
                tostring(raceId)
            )
        )
        return {
            id = raceId,
            name = "Unknown",
        }
    end

    return {
        id = raceId,
        name = raceName,
    }
end

---Get the character's class
---@return table {id=number, name=string}
function api.GetClass()
    local classId = CM.SafeCall(GetUnitClassId, "player")

    if not classId or classId == 0 then
        CM.Error("GetClass: GetUnitClassId('player') returned nil or 0")
        return {
            id = nil,
            name = "Unknown",
        }
    end

    local genderId = CM.SafeCall(GetUnitGender, "player") or GENDER_MALE

    -- Use GetClassName() as documented in API_REFERENCE.md
    local className = CM.SafeCall(GetClassName, genderId, classId)

    -- Fallback to lookup table if API fails
    if (not className or className == "") and CLASS_NAMES[classId] then
        className = CLASS_NAMES[classId]
    end

    -- Format the name if we got one
    if className and className ~= "" then
        className = zo_strformat("<<1>>", className)
    end

    if not className or className == "" then
        CM.Error(
            string.format(
                "GetClass: Failed to get class name for classId=%s. Tried GetClassName() and lookup table",
                tostring(classId)
            )
        )
        return {
            id = classId,
            name = "Unknown",
        }
    end

    return {
        id = classId,
        name = className,
    }
end

---Get the character's alliance
---@return table {id=number}
function api.GetAlliance()
    local allianceId = CM.SafeCall(GetUnitAlliance, "player")
    -- Only return allianceId - alliance name requires GetAllianceName (alliance API)
    -- Name should be composed in collector using cross-API calls
    return {
        id = allianceId,
    }
end

---Get the character's level and XP
---@return table {level=number, xp=number, xpMax=number}
function api.GetLevel()
    local level = CM.SafeCall(GetUnitLevel, "player")
    local xp = CM.SafeCall(GetUnitXP, "player")
    local xpMax = CM.SafeCall(GetUnitXPMax, "player")
    return {
        level = level or 0,
        xp = xp or 0,
        xpMax = xpMax or 0,
    }
end

---Get the character's location
---@return table {zoneIndex=number, zoneId=number, zone=string, subzone=string, world=string}
function api.GetLocation()
    local zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player")
    local zoneId = zoneIndex and CM.SafeCall(GetZoneId, zoneIndex)
    local zoneName = CM.SafeCall(GetUnitZone, "player")
    local subzoneName = CM.SafeCall(GetPlayerActiveSubzoneName)
    local worldName = CM.SafeCall(GetWorldName)

    return {
        zoneIndex = zoneIndex,
        zoneId = zoneId,
        zone = zoneName or "Unknown",
        subzone = subzoneName or "",
        world = worldName or "Unknown",
    }
end

-- GetTitle() removed - titles have their own API module (CM.api.titles)

-- Composition functions moved to collector level
