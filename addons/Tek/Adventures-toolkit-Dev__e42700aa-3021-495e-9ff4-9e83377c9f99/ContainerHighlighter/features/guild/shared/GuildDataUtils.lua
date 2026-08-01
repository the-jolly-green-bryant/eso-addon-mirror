-- Shared guild data helper utilities used by guild feature modules.
NWT.GuildDataUtils = NWT.GuildDataUtils or {}

function NWT.GuildDataUtils.SafeNumber(value, defaultValue)
    local n = tonumber(value)
    if n == nil then return defaultValue or 0 end
    return n
end

function NWT.GuildDataUtils.SafeTable(value)
    if type(value) == "table" then return value end
    return {}
end
