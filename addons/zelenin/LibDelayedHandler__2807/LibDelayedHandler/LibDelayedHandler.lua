local addon = ZO_Object:Subclass()
LibDelayedHandler = addon

function addon:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function addon:initialize(handler, timeout)
    self.counter = 0
    self.handler = handler
    self.timeout = timeout or 100
end

function addon:trigger()
    self.counter = self.counter + 1

    zo_callLater(function()
        self.counter = self.counter - 1
        if self.counter == 0 then
            self:handler()
        end
    end, self.timeout)
end
