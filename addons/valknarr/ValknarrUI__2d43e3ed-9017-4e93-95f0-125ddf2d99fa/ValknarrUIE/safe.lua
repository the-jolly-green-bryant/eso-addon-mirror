-- Shared pcall wrappers. The editor, grid, platform helper, and adapters
-- each used to ship their own copy, with slightly different missing-method
-- behaviour. One module so a control that has no SetAnchor fails the same
-- way everywhere.

ValknarrUIESafe = ValknarrUIESafe or {}

local Safe = ValknarrUIESafe

-- pcall object[method](object, ...). A missing method is false, "missing:X"
-- rather than a Lua error, so callers can treat both as "did not run".
function Safe.Call(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, "missing:" .. tostring(method)
    end
    return pcall(object[method], object, ...)
end

-- Like Call, but a successful call is just true. Adapters that only care
-- whether ClearAnchors/SetAnchor ran use this so they do not have to
-- discard extra returns.
function Safe.Try(object, method, ...)
    local ok, err = Safe.Call(object, method, ...)
    if ok then
        return true
    end
    return false, err
end

-- Call a global function with no arguments. Nil if it is missing or errors
-- (IsConsoleUI on PC, ZO_IsConsoleOrGameCoreUI on older API versions).
function Safe.Global(name)
    local fn = _G[name]
    if type(fn) ~= "function" then
        return nil
    end
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

return Safe
