LibWorldEvents.Dragons.DragonStatus = {}

-- @var table : List of all status which can be defined
LibWorldEvents.Dragons.DragonStatus.list = {
    unknown = "unknown",
    killed  = "killed",
    waiting = "waiting",
    fight   = "fight",
    weak    = "weak",
    flying  = "flying",
}

-- @var table : All map pin available and the corresponding status
LibWorldEvents.Dragons.DragonStatus.mapPinList = {
    [MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY]   = LibWorldEvents.Dragons.DragonStatus.list.waiting,
    [MAP_PIN_TYPE_DRAGON_IDLE_WEAK]      = LibWorldEvents.Dragons.DragonStatus.list.waiting,
    [MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY] = LibWorldEvents.Dragons.DragonStatus.list.fight,
    [MAP_PIN_TYPE_DRAGON_COMBAT_WEAK]    = LibWorldEvents.Dragons.DragonStatus.list.weak,
}

--[[
-- Initialise the status for a dragon
--
-- @param Dragon dragon : The dragon with the status to initialise
--]]
function LibWorldEvents.Dragons.DragonStatus:initForDragon(dragon)
    local status = self:convertMapPin(dragon.unit.pin)
    dragon:resetWithStatus(status)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonStatus.initDragon,
        self,
        dragon
    )
end

--[[
-- Check the status for all dragon instancied
--]]
function LibWorldEvents.Dragons.DragonStatus:checkAllDragon()
    LibWorldEvents.Dragons.DragonList:execOnAll(self.checkForDragon)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonStatus.checkAll,
        self
    )
end

--[[
-- Check the status for a specific dragon.
-- It's a callback for DragonList:execOnAll
--
-- @param Dragon dragon The dragon to check
--]]
function LibWorldEvents.Dragons.DragonStatus.checkForDragon(dragon)
    dragon:updateUnit()

    local realStatus    = LibWorldEvents.Dragons.DragonStatus:convertMapPin(dragon.unit.pin)
    local waitingStatus = LibWorldEvents.Dragons.DragonStatus.list.waiting
    local flyingStatus  = LibWorldEvents.Dragons.DragonStatus.list.flying

    if realStatus == waitingStatus and dragon.status.current == flyingStatus then
        realStatus = flyingStatus
    end

    if dragon.status.current ~= realStatus then
        dragon:resetWithStatus(realStatus)
    end
    
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonStatus.check,
        LibWorldEvents.Dragons.DragonStatus,
        dragon
    )
end

--[[
-- Convert from MAP_PIN_TYPE_DRAGON_* constant to a status in the list
--
-- @param number mapPin The dragon map pin
--
-- @return string
--]]
function LibWorldEvents.Dragons.DragonStatus:convertMapPin(mapPin)
    local status = self.mapPinList[mapPin]

    if status == nil then
        return self.list.killed
    else
        return status
    end
end
