local class = ZO_InitializingObject:Subclass()
libHandlerLimiterJob = class

function class:Initialize(handler, args)
    self.handler = handler
    self.args = args
    self.time = GetGameTimeMilliseconds()
end

function class:Execute()
    self.handler(unpack(self.args))
end

local class = ZO_InitializingObject:Subclass()
libHandlerLimiterRepeatable = class

function class:Initialize(owner, handler, timeout)
    self.owner = owner
    self.name = string.format("%sLimiterRepeatable", self.owner.name)

    assert(timeout > 0, "timeout must be a positive")

    self.handler = handler
    self.timeout = timeout
    self.lastJob = nil
end

function class:Trigger(...)
    local allArgs = { ... }

    if self.lastJob == nil then
        zo_callLater(function()
            self.lastJob:Execute()
            self.lastJob = nil
        end, self.timeout)
    end

    self.lastJob = libHandlerLimiterJob:New(self.handler, allArgs)
end

local class = ZO_InitializingObject:Subclass()
libHandlerLimiterNotRepeatable = class

function class:Initialize(owner, handler, timeout)
    self.owner = owner
    self.name = string.format("%sLimiterNotRepeatable", self.owner.name)

    assert(timeout > 0, "timeout must be a positive")

    self.handler = handler
    self.timeout = timeout
    self.counter = 0
end

function class:Trigger(...)
    local allArgs = { ... }

    self.counter = self.counter + 1

    local currentJob = libHandlerLimiterJob:New(self.handler, allArgs)

    zo_callLater(function()
        self.counter = self.counter - 1
        if self.counter == 0 then
            currentJob:Execute()
        end
    end, self.timeout)
end

local class = ZO_InitializingObject:Subclass()
libHandlerLimiter = class

function class:Initialize(owner, handler, timeout, repeatable)
    self.owner = owner
    self.name = string.format("%sLimiter", self.owner.name)

    assert(timeout > 0, "timeout must be a positive")

    repeatable = repeatable == nil and false or repeatable

    self.handler = handler
    self.timeout = timeout
    self.limiter = repeatable == true and libHandlerLimiterRepeatable:New(owner, handler, timeout) or libHandlerLimiterNotRepeatable:New(owner, handler, timeout)
end

function class:Trigger(...)
    self.limiter:Trigger(...)
end

local class = ZO_InitializingObject:Subclass()
libHandlerLimiterWithDependency = class

function class:Initialize(owner, handler, timeout, repeatable)
    self.owner = owner
    self.name = string.format("%sLimiterWithDependency", self.owner.name)

    self.handler = handler
    self.timeout = timeout
    self.repeatable = repeatable == nil and false or repeatable
    self.limiters = {}
end

local dependencyTypes = {
    ["function"] = true,
    ["number"] = true,
    ["string"] = true,
}

function class:Trigger(...)
    local allArgs = { ... }
    local numArgs = #allArgs

    local dependency = allArgs[1]

    local args = {}
    if numArgs > 1 then
        for i = 2, numArgs do
            table.insert(args, allArgs[i])
        end
    end

    assert(dependencyTypes[type(dependency)] == true, "dependency must be any types: function/number/string")

    local id = type(dependency) == "function" and dependency() or dependency

    assert(dependencyTypes[type(dependency)] == true, "id must be any types: number/string")

    if self.limiters[id] == nil then
        self.limiters[id] = libHandlerLimiter:New(self, self.handler, self.timeout, self.repeatable)
    end

    self.limiters[id]:Trigger(unpack(args))
end
