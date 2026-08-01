DragonNextLocation.MapPins = {}
DragonNextLocation.MapPins.__index = DragonNextLocation.MapPins

--[[
-- Instanciate a new MapPins "object"
--
-- @param dragon The Dragon instance linked to the mapPin
--
-- @return DragonNextLocation.MapPins
--]]
function DragonNextLocation.MapPins:new(dragon)
    local newMapPin = {
        dragon   = dragon,
        pinTag   = "",
        position = {-1, -1},
    }

    newMapPin.pinTag = string.format(
        "DragonNextLocation_Dragon%d",
        dragon.WEInstanceId
    )

    local newPinIdx = DragonNextLocation.MapPinsList.nbPin + 1
    DragonNextLocation.MapPinsList.pinList[newPinIdx] = newMapPin
    DragonNextLocation.MapPinsList.nbPin              = newPinIdx

    setmetatable(newMapPin, self)
    return newMapPin
end

--[[
-- Called when the player open a map.
-- Add (or not) the pin on the map
--]]
function DragonNextLocation.MapPins:addPin()
    if LibWorldEvents.Dragons.ZoneInfo.onMap == false then
        return
    end

    if not DragonNextLocation.libMapPins:IsEnabled(DragonNextLocation.MapPinsList.pinType) then
        return
    end

    if GetMapType() > MAPTYPE_ZONE then
        return
    end

    local currentZoneName   = LibWorldEvents.Zone.info.mapName
    local displayedZoneName = DragonNextLocation.libMapPins:GetZoneAndSubzone(true)

    -- Add pin only if the displayed map is a map with dragon
    if currentZoneName ~= displayedZoneName then
        return
    end

    DragonNextLocation.libMapPins:CreatePin(
        DragonNextLocation.MapPinsList.pinType,
        self.pinTag,
        self.position[1],
        self.position[2]
    )
end

--[[
-- To change pin position
--
-- @param table position The new pins position.
--  Key 1 is the normalised position for x
--  Key 2 is the normalised position for y
--]]
function DragonNextLocation.MapPins:changePosition(position)
    self.position = position
    DragonNextLocation.libMapPins:RefreshPins(DragonNextLocation.MapPinsList.pinType)
end

--[[
-- To hide a pin (set position to -1/-1)
--]]
function DragonNextLocation.MapPins:hide()
    self:changePosition({-1, -1})
end
