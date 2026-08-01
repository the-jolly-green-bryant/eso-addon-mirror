
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local F = {}

function F.abbrev(n)
    n = n or 0
    if n < 1000 then
        return tostring(n)
    elseif n < 1000000 then
        local k = n / 1000
        if k < 10 then return string.format("%.1fk", k) end
        return string.format("%dk", math.floor(k + 0.5))
    else
        return string.format("%.2fM", n / 1000000)
    end
end

function F.commas(n)
    local s = tostring(math.floor((n or 0) + 0.5))
    local out, count = "", 0
    for i = #s, 1, -1 do
        out = s:sub(i, i) .. out
        count = count + 1
        if count % 3 == 0 and i > 1 then out = "," .. out end
    end
    return out
end

function F.duration(ms)
    local total = math.floor((ms or 0) / 1000)
    local m = math.floor(total / 60)
    local s = total % 60
    return string.format("%d:%02d", m, s)
end

function F.countdown(seconds)
    seconds = seconds or 0
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if d > 0 then return string.format("%dd %dh", d, h) end
    if h > 0 then return string.format("%dh %dm", h, m) end
    return string.format("%dm", m)
end

function F.signed(n)
    return "+" .. F.commas(n or 0)
end

function F.icon(path, size)
    if not path then return "" end
    size = size or 16
    return string.format("|t%d:%d:%s|t", size, size, path)
end

function F.per_minute(total, ms)
    local minutes = (ms or 0) / 60000
    if minutes <= 0 then return 0 end
    return total / minutes
end

BGMeter.Format = F
