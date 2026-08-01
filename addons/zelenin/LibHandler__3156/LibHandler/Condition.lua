local class = ZO_InitializingObject:Subclass()
libHandlerCondition = class

function class:Initialize(owner, condition, handler, timeOut)
    self.owner = owner
    self.name = string.format("%sCondition", self.owner.name)

    self.condition = condition
    self.handler = handler

    local updateName = string.format("%s-%d", self.name, self.owner:getNextHandlerId())

    if self:handle() == false then
        EVENT_MANAGER:RegisterForUpdate(updateName, timeOut, function()
            if self:handle() == true then
                EVENT_MANAGER:UnregisterForUpdate(updateName)
            end
        end)
    end
end

function class:handle()
    if self.condition() == true then
        self.handler()
        return true
    end

    return false
end
