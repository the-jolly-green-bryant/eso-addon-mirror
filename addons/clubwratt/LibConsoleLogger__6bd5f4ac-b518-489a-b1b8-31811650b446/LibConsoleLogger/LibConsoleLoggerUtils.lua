-- LibConsoleLoggerUtils.lua: helper utilities (pure)

LibConsoleLogger = LibConsoleLogger or {}
LibConsoleLogger.Utils = LibConsoleLogger.Utils or {}

local Utils = LibConsoleLogger.Utils

---@param value any
---@return string
function Utils.Trim(value)
    local s = tostring(value or "")
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")
    return s
end

---@param value any
---@return string
function Utils.NormalizeLine(value)
    local s = tostring(value or "")
    if s == "" then
        return "[Empty String]"
    end
    return s
end

---Trim and default the scheme: "192.168.1.50:7878" becomes "http://192.168.1.50:7878".
---An explicit scheme (http://, https://, ...) is left untouched.
---@param value any
---@return string
function Utils.NormalizeUrl(value)
    local url = Utils.Trim(value)
    if url == "" then
        return url
    end
    if url:find("^%a[%w+.%-]*://") then
        return url
    end
    return "http://" .. url
end

---@param webExport table|nil
---@return boolean
function Utils.HasConfiguredUrl(webExport)
    if not (webExport and webExport.GetUrl) then
        return false
    end
    local url = Utils.Trim(webExport.GetUrl(nil))
    return url ~= ""
end

---@param sink fun(line: any): boolean accepted
---@param t table
---@param indent string|nil
---@param tableHistory table<table, boolean>|nil
---@return boolean acceptedAny
function Utils.WalkTableWithSink(sink, t, indent, tableHistory)
    indent = indent or "."
    tableHistory = tableHistory or {}

    local acceptedAny = false
    for k, v in pairs(t) do
        local vType = type(v)
        acceptedAny = sink(string.format("%s(%s): %s = %s", indent, vType, tostring(k), tostring(v))) or acceptedAny
        if vType == "table" then
            if tableHistory[v] then
                acceptedAny = sink(indent .. "Avoiding cycle on table...") or acceptedAny
            else
                tableHistory[v] = true
                acceptedAny = Utils.WalkTableWithSink(sink, v, indent .. "  ", tableHistory) or acceptedAny
            end
        end
    end
    return acceptedAny
end
