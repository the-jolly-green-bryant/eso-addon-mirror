local Hooks = Reforged.Hooks

Hooks._applied = {}

-- Replaces a global function, storing the original in a closure.
-- Returns a restore function (not called automatically — hooks persist until /reloadui).
function Hooks.replace(globalName, fn)
    local original = _G[globalName]
    _G[globalName] = fn(original)
    Hooks._applied[#Hooks._applied + 1] = globalName
end

-- Wraps ZO_PreHook with tracking.
function Hooks.pre(obj, methodName, fn)
    ZO_PreHook(obj, methodName, fn)
    Hooks._applied[#Hooks._applied + 1] = tostring(obj) .. "." .. methodName .. " (pre)"
end

-- Wraps ZO_PostHook with tracking.
function Hooks.post(obj, methodName, fn)
    ZO_PostHook(obj, methodName, fn)
    Hooks._applied[#Hooks._applied + 1] = tostring(obj) .. "." .. methodName .. " (post)"
end
