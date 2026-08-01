local EVENT_NAMESPACE = 'LIB_SUBZONES_EVENT_NAMESPACE'

local subzones

local function onZoneChanged(_, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    if subZoneName == '' or subZoneId == 0 then return end
    -- df('[%d] %s', subZoneId, subZoneName)
    subzones[subZoneName] = subZoneId
    -- d(subzones)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= 'LibSubzones' then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    local language = GetCVar('Language.2')
    LibSubzonesData = LibSubzonesData or {}

    subzones = LibSubzonesData[language] or {}
    LibSubzonesData[language] = subzones

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED, onZoneChanged)
end)

-- ----------------------------------------------------------------------------

function IMP_GetCurrentSubzoneId()
    return subzones[GetPlayerActiveSubzoneName()]
end