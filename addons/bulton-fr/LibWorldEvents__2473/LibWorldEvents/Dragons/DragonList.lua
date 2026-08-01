LibWorldEvents.Dragons.DragonList = {}

-- @var table List of all dragons instancied
LibWorldEvents.Dragons.DragonList.list = {}

-- @var number Number of item in list
LibWorldEvents.Dragons.DragonList.nb   = 0

-- @var table Map table with WEInstanceId as key, and index in list as value
LibWorldEvents.Dragons.DragonList.WEInstanceIdToListIdx = {}

--[[
-- Reset the list
--]]
function LibWorldEvents.Dragons.DragonList:reset()
    self.list                  = {}
    self.nb                    = 0
    self.WEInstanceIdToListIdx = {}

    LibWorldEvents.Dragons.ZoneInfo.repopTime = 0

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonList.reset,
        self
    )
end

--[[
-- Add a new dragon to the list
--
-- @param Dragon dragon : The dragon instance to add
--]]
function LibWorldEvents.Dragons.DragonList:add(dragon)
    local newIdx = self.nb + 1

    self.list[newIdx] = dragon
    self.nb           = newIdx

    self.WEInstanceIdToListIdx[dragon.WEInstanceId] = newIdx

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonList.add,
        self,
        dragon
    )
end

--[[
-- Execute the callback for all dragon
--
-- @param function callback : A callback called for each dragon in the list.
-- The callback take the dragon instance as parameter.
--]]
function LibWorldEvents.Dragons.DragonList:execOnAll(callback)
    local dragonIdx = 1

    for dragonIdx = 1, self.nb do
        callback(self.list[dragonIdx])
    end
end

--[[
-- Obtain the dragon instance for a WEInstanceId
--
-- @param number WEInstanceId
--
-- @return Dragon
--]]
function LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(WEInstanceId)
    local dragonIdx = self.WEInstanceIdToListIdx[WEInstanceId]

    return self.list[dragonIdx]
end

--[[
-- To update the list : remove all dragon or create all dragon compared to Zone info.
--]]
function LibWorldEvents.Dragons.DragonList:update()
    if LibWorldEvents.Zone.changedZone == true then
        self:removeAll()
    end

    if LibWorldEvents.Dragons.ZoneInfo.onMap == true and self.nb == 0 then
        self:createAll()
    end

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonList.update,
        self
    )
end

--[[
-- Remove all dragon instance in the list and reset GUI items list
--]]
function LibWorldEvents.Dragons.DragonList:removeAll()
    self:reset()

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonList.removeAll,
        self
    )
end

--[[
-- Create a dragon instance for each dragon in the zone, and add it to the list.
--]]
function LibWorldEvents.Dragons.DragonList:createAll()
    self:removeAll()

    for dragonIdx, WEInstanceId in ipairs(LibWorldEvents.Zone.info.list.WEInstanceId) do
        local dragon = LibWorldEvents.Dragons.Dragon:new(dragonIdx, WEInstanceId)

        self:add(dragon)
    end

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragonList.createAll,
        self
    )
end
