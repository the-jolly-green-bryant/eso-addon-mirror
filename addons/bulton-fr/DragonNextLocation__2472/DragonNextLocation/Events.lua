DragonNextLocation.Events = {}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function DragonNextLocation.Events.onLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == DragonNextLocation.name then
        DragonNextLocation:Initialise()
    end
end

--[[
-- Called when a new dragon instance is created
--
-- @param dragon The created Dragon instance
--]]
function DragonNextLocation.Events.onNewDragon(dragon)
    dragon.mapPins = DragonNextLocation.MapPins:new(dragon)
end

--[[
-- Called when a dragon start to fly to go at a different location
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- @param number oldWorldEventLocationId The old dragon's locationId
-- @param number newWorldEventLocationId The new dragon's locationId
--]]
function DragonNextLocation.Events.onWELocChanged(eventCode, worldEventInstanceId, oldWorldEventLocationId, newWorldEventLocationId)
    if DragonNextLocation.ready == false then
        return
    end

    local dragon = LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(worldEventInstanceId)
    if dragon == nil then -- no all loaded
        return
    end
    
    local position = DragonNextLocation.Zone:obtainPosition(dragon, newWorldEventLocationId)
    dragon.mapPins:changePosition(position)
end

--[[
-- Called when a dragon has landed
--
-- @param dragon The Dragon instance
--]]
function DragonNextLocation.Events.onDragonLanded(dragon)
    if DragonNextLocation.ready == false then
        return
    end

    dragon.mapPins:hide()
end
