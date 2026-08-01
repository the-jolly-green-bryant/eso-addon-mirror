-- SmartTrader.lua: Root namespace
-- Type definitions are centralized in SmartTraderTypes.lua
SmartTrader = {
    name = "SmartTrader",
    version = "2.1.91",
    ---@type SmartTraderState
    state = nil
}

-- LibConsoleLogger is an optional diagnostic dependency. Without a hard
-- DependsOn, its global may not exist when this addon loads (or at all),
-- so the library is resolved at call time instead of being captured at
-- file scope. Method calls silently no-op when it is not installed.
local loggerProxy = setmetatable({}, {
    __index = function(proxy, methodName)
        local function forward(_, ...)
            local lib = _G["LibConsoleLogger"]
            local method = lib and lib[methodName]
            if type(method) == "function" then
                return method(lib, ...)
            end
        end
        rawset(proxy, methodName, forward)
        return forward
    end,
})

---Get the console logger. Safe to hold and call even when LibConsoleLogger
---is not installed or has not loaded yet.
---@return LibConsoleLogger
function SmartTrader.GetLogger()
    return loggerProxy --[[@as LibConsoleLogger]]
end
