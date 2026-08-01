LibWorldEvents.FlyTimer         = setmetatable({}, {__index = LibWorldEvents.Timer})
LibWorldEvents.FlyTimer.__index = LibWorldEvents.FlyTimer

-- @var number time The time in ms where update() which will be called
LibWorldEvents.FlyTimer.time = 1000

--[[
-- Instanciate a new FlyTimer "object"
--
-- @param dragon The dragon which will use the FlyTimer
--]]
function LibWorldEvents.FlyTimer:new(dragon)
    local newFlyTimer = {
        dragon = dragon
    }

    newFlyTimer.name = string.format(
        "LibWorldEvents_FlyTimer_%d",
        dragon.WEInstanceId
    )

    setmetatable(newFlyTimer, self)
    newFlyTimer:enable()

    return newFlyTimer
end

--[[
-- Callback function on timer.
-- Called each 1sec in dragons zone.
-- Check dragon position to know if dragon flying or has landed
--]]
function LibWorldEvents.FlyTimer:update()
    local timeSincePop = os.time() - self.dragon.fly.startTime
    local currentPos   = self.dragon:obtainPosition()
    local lastPos      = self.dragon.position
    local stopTimer    = false

    if timeSincePop > 15 and lastPos.x == currentPos.x and lastPos.y == currentPos.y and lastPos.z == currentPos.z then
        stopTimer = true
    else
        self.dragon:updatePosition(currentPos)

        if timeSincePop > 180 then -- 3min max after dragon pop
            stopTimer = true
        end
    end

    if stopTimer == true then
        self:disable()
    end
end

--[[
-- Override LibWorldEvents.Timer:disable() to sent the status "landed"
--]]
function LibWorldEvents.FlyTimer:disable()
    LibWorldEvents.Timer.disable(self)
    self.dragon:onLanded()
end
