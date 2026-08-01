DragonNextLocation = {}

DragonNextLocation.name       = "DragonNextLocation"
DragonNextLocation.ready      = false
DragonNextLocation.savedVars  = nil
DragonNextLocation.libMapPins = LibMapPins

--[[
-- Addon initialiser
--]]
function DragonNextLocation:Initialise()
    DragonNextLocation.savedVars = ZO_SavedVars:NewAccountWide("DragonNextLocationSavedVariables", 1, nil, {})

    if DragonNextLocation.savedVars.mapPinsFilters == nil then
        DragonNextLocation.savedVars.mapPinsFilters = true
    end

    DragonNextLocation.MapPinsList:initialise()
    DragonNextLocation.ready = true
end
