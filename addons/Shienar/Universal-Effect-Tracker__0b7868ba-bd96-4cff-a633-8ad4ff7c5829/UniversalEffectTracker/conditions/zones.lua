UniversalTracker = UniversalTracker or {}

function UniversalTracker.isInZone(queriedZoneID)
    local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
    if zoneID == queriedZoneID then return true end
    return false
end

local firstLogin = true
local function onNewZone(_, isNotReloadUI)
    if firstLogin then
        firstLogin = false
    elseif isNotReloadUI then
         for k, v in pairs(UniversalTracker.savedVariables.trackerList) do
            if tonumber(v.requiredZoneID) then
                if UniversalTracker.isInZone(tonumber(v.requiredZoneID)) then
                    UniversalTracker.InitSingleDisplay(v)
                else
                    UniversalTracker.ReleaseSingleDisplay(v)
                end
            end
        end

        for k, v in pairs(UniversalTracker.characterSavedVariables.trackerList) do
            if tonumber(v.requiredZoneID) then
                if UniversalTracker.isInZone(tonumber(v.requiredZoneID)) then
                    UniversalTracker.InitSingleDisplay(v)
                else
                    UniversalTracker.ReleaseSingleDisplay(v)
                end
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent(UniversalTracker.name, EVENT_PLAYER_ACTIVATED, onNewZone)