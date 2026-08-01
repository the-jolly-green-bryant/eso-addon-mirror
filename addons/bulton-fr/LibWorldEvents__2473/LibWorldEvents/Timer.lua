LibWorldEvents.Timer = {}

-- @var string name The timer's name
LibWorldEvents.Timer.name = ""

-- @var number time The time in ms where update() which will be called
LibWorldEvents.Timer.time = 0

-- @var boolean enabled If the timer is enabled or not
LibWorldEvents.Timer.enabled = false

--[[
-- Enable the timer
--]]
function LibWorldEvents.Timer:enable()
    if self.enabled == true then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(
        self.name,
        self.time,
        function() self:update() end
    )
    self.enabled = true
end

--[[
-- Disable the timer
--]]
function LibWorldEvents.Timer:disable()
    if self.enabled == false then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.enabled = false
end

--[[
-- Callback function on timer.
--]]
function LibWorldEvents.Timer:update()
    
end

--[[
-- Call the method to enable or disable timer according to newStatus value
--
-- @param boolean newStatus : true to enable timer, false to disable it
--]]
function LibWorldEvents.Timer:changeStatus(newStatus)
    if newStatus == true then
        self:enable()
    else
        self:disable()
    end
end
