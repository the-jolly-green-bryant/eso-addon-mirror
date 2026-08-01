LibWorldEvents.Dragons.Dragon = {}
LibWorldEvents.Dragons.Dragon.__index = LibWorldEvents.Dragons.Dragon

--[[
-- Instanciate a new Dragon "object"
--
-- @param number dragonIdx The dragon index in DragonList.list
-- @param number WEInstanceId The dragon's WorldEventInstanceId
--
-- @return Dragon
--]]
function LibWorldEvents.Dragons.Dragon:new(dragonIdx, WEInstanceId)
    local newDragon = {
        eventType    = LibWorldEvents.Zone.worldEventMapType,
        eventIdx     = dragonIdx,
        WEInstanceId = WEInstanceId,
        WEId         = nil,
        title        = {
            cp = LibWorldEvents.Zone.info.list.title.cp[dragonIdx],
            ln = LibWorldEvents.Zone.info.list.title.ln[dragonIdx]
        },
        unit         = {
            tag = nil,
            pin = nil,
        },
        type         = {
            colorTxt  = "",
            colorRGB  = nil,
            name      = "",
            abilityId = 0,
            maxHP     = 0,
        },
        position     = {
            x = 0,
            y = 0,
            z = 0,
        },
        status       = {
            previous  = nil,
            current   = nil,
            time      = 0,
            justPoped = false,
        },
        repop        = {
            killTime  = 0,
            repopTime = 0,
        },
        fly          = {
            timer     = nil,
            startTime = 0,
        },
    }

    setmetatable(newDragon, self)

    newDragon:updateUnit()
    newDragon:updateType()
    LibWorldEvents.Dragons.DragonStatus:initForDragon(newDragon)

    -- Not need, already updated each 1 second
    -- LibWorldEvents.GUI:updateForDragon(newDragon)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.new,
        newDragon
    )

    return newDragon
end

--[[
-- Update the WorldEventId
--]]
function LibWorldEvents.Dragons.Dragon:updateWEId()
    self.WEId = GetWorldEventId(self.WEInstanceId)
end

--[[
-- Update the dragon's UnitTag and UnitPinType
--]]
function LibWorldEvents.Dragons.Dragon:updateUnit()
    self:updateWEId()

    self.unit.tag = GetWorldEventInstanceUnitTag(self.WEInstanceId, 1)
    self.unit.pin = GetWorldEventInstanceUnitPinType(self.WEInstanceId, self.unit.tag)
end

--[[
-- Update dragon type info
--]]
function LibWorldEvents.Dragons.Dragon:updateType()
    local typeInfo = LibWorldEvents.Dragons.DragonType:obtainForDragon(self)

    if typeInfo == nil then
        self.type.colorTxt  = ""
        self.type.colorRGB  = nil
        self.type.name      = ""
        self.type.abilityId = 0
        self.type.maxHP     = 0
    else
        self.type.colorTxt  = typeInfo.dragonColorTxt
        self.type.colorRGB  = typeInfo.dragonColorRGB
        self.type.name      = typeInfo.dragonName
        self.type.abilityId = typeInfo.abilityId
        self.type.maxHP     = typeInfo.maxHP
    end

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.changeType,
        self
    )
end

--[[
-- Update dragon position
--
-- @param table|nil position (default nil) Current position
--]]
function LibWorldEvents.Dragons.Dragon:updatePosition(position)
    if position == nil then
        local position = self:obtainPosition()
    end

    self.position.x = position.x
    self.position.y = position.y
    self.position.z = position.z
end

--[[
-- Obtain and return the current dragon position
--
-- @return table
--]]
function LibWorldEvents.Dragons.Dragon:obtainPosition()
    local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition(self.unit.tag)

    return {
        x = worldX,
        y = worldY,
        z = worldZ
    }
end

--[[
-- Change the dragon's current status
--
-- @param string newStatus The dragon's new status in DragonStatus.list
-- @param string unitTag (default nil) The new unitTag
-- @param number unitPin (default nil) The new unitPin
--]]
function LibWorldEvents.Dragons.Dragon:changeStatus(newStatus, unitTag, unitPin)
    self.status.previous = self.status.current
    self.status.current  = newStatus
    self.status.time     = os.time()

    if self.status.previous == nil or self.status.previous == self.status.current then
        self.status.time = 0
    end

    if unitTag ~= nil then
        self.unit.tag = unitTag
    end

    if unitPin ~= nil then
        self.unit.pin = unitPin
    end

    if self.unit.tag == "invalid" then
        self:updateUnit()
    end

    -- If dragon type info cannot be obtained when poped, we retry when status change
    if self.type.colorRGB == nil and newStatus ~= LibWorldEvents.Dragons.DragonStatus.list.killed then
        self:updateType()
    end

    -- To disable flyTimer if dragon change of status before the end of timer
    -- For example, sometimes, dragon go in fight before to be landed :o
    if self.fly.timer ~= nil and self.status.current ~= LibWorldEvents.Dragons.DragonStatus.list.flying then
        self.fly.timer:disable()
    end
    
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.changeStatus,
        self,
        newStatus
    )

    self:execStatusFunction()
end

--[[
-- Reset dragon's status info and define the status with newStatus.
--
-- @param string newStatus The dragon's new status in DragonStatus.list
--]]
function LibWorldEvents.Dragons.Dragon:resetWithStatus(newStatus)
    self.status.previous = nil
    self.status.current  = newStatus
    self.status.time     = 0

    self:updateType()

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.resetStatus,
        self,
        newStatus
    )
end

--[[
-- Execute the dedicated function for a status
--]]
function LibWorldEvents.Dragons.Dragon:execStatusFunction()
    if self.status.current == LibWorldEvents.Dragons.DragonStatus.list.killed then
        self:killed()
    elseif self.status.current == LibWorldEvents.Dragons.DragonStatus.list.waiting then
        self:waiting()
    elseif self.status.current == LibWorldEvents.Dragons.DragonStatus.list.fight then
        self:fight()
    elseif self.status.current == LibWorldEvents.Dragons.DragonStatus.list.weak then
        self:weak()
    elseif self.status.current == LibWorldEvents.Dragons.DragonStatus.list.flying then
        self:flying()
    end
end

--[[
-- Called when the dragon (re)pop
--]]
function LibWorldEvents.Dragons.Dragon:poped()
    self.justPoped       = true
    self.repop.repopTime = os.time()

    if self.unit.tag == "invalid" then
        self:updateUnit()
    end

    self:updateType()

    if self.repop.killTime ~= 0 then
        local diffTime = self.repop.repopTime - self.repop.killTime
        LibWorldEvents.Dragons.ZoneInfo.repopTime = diffTime
    end

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.poped,
        self
    )
end

--[[
-- Called when the dragon is killed
--]]
function LibWorldEvents.Dragons.Dragon:killed()
    self.repop.killTime = os.time()

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.killed,
        self
    )
end

--[[
-- Called when the dragon start to waiting
--]]
function LibWorldEvents.Dragons.Dragon:waiting()
    self.flyTimer = nil

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.waiting,
        self
    )
end

--[[
-- Called when the dragon go in fight
--]]
function LibWorldEvents.Dragons.Dragon:fight()
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.fight,
        self
    )
end

--[[
-- Called when the dragon is now weak
--]]
function LibWorldEvents.Dragons.Dragon:weak()
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.weak,
        self
    )
end

--[[
-- Called when the dragon start to fly
--]]
function LibWorldEvents.Dragons.Dragon:flying()
    self.fly.startTime = os.time()
    self.fly.timer     = LibWorldEvents.FlyTimer:new(self)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.flying,
        self
    )
end

--[[
-- Called when the dragon has landed
--]]
function LibWorldEvents.Dragons.Dragon:onLanded()
    local flyingStatus  = LibWorldEvents.Dragons.DragonStatus.list.flying
    local waitingStatus = LibWorldEvents.Dragons.DragonStatus.list.waiting

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.dragon.landed,
        self
    )

    if self.status.current == flyingStatus then
        self:changeStatus(waitingStatus)
    end
end
