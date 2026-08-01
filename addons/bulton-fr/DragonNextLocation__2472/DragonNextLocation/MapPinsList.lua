DragonNextLocation.MapPinsList = {}

-- @var string The pinType used for DragonNextLocations pins
DragonNextLocation.MapPinsList.pinType = "DRAGON_NEXT_LOCATION_PIN_TYPE_DRAGON"

-- @var nil|number The pinTypeId returned by libMapPins
DragonNextLocation.MapPinsList.pinTypeId = nil

-- @var table The list of instancied MapPins to display
DragonNextLocation.MapPinsList.pinList = {}

-- @var number The number of item in pinList
DragonNextLocation.MapPinsList.nbPin = 0

--[[
-- Declare the pinType with LibMapPins, and add the pin filter.
--]]
function DragonNextLocation.MapPinsList:initialise()
    local pinLayoutData = {
        level = 50,
        texture = "DragonNextLocation/textures/dragonNextLocation.dds",
        size = 35,
    }

    self.pinTypeId = DragonNextLocation.libMapPins:AddPinType(
        self.pinType,
        self.onMapChange,
        nil,
        pinLayoutData,
        "Next dragon position"
    )

    DragonNextLocation.libMapPins:AddPinFilter(
        self.pinTypeId,
        "Dragon next location",
        false,
        DragonNextLocation.savedVars,
        "mapPinsFilters"
    )
end

--[[
-- Called when a map is displayed to add pins on the map.  
-- When the player open the map, the method is called.  
-- When the player change map to go in subzone or parent zone, the method is called.
--]]
function DragonNextLocation.MapPinsList.onMapChange()
    local pinIndex    = 1
    local pinInstance = nil

    for pinIndex = 1, DragonNextLocation.MapPinsList.nbPin do
        pinInstance = DragonNextLocation.MapPinsList.pinList[pinIndex]
        
        if pinInstance ~= nil then
            pinInstance:addPin()
        end
    end
end
