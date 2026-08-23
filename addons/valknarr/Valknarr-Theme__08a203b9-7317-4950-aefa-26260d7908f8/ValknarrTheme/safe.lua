ValknarrThemeSafe = ValknarrThemeSafe or {}

local Safe = ValknarrThemeSafe

function Safe.Call(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, "missing:" .. tostring(method)
    end
    return pcall(object[method], object, ...)
end

function Safe.Try(object, method, ...)
    local ok, err = Safe.Call(object, method, ...)
    if ok then
        return true
    end
    return false, err
end

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
