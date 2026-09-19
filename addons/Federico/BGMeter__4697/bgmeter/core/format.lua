
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local F = {}

function F.abbrev(n)
    n = n or 0
    if n < 0 then return "-" .. F.abbrev(-n) end
    if n < 1000 then
        return tostring(math.floor(n + 0.5))
    elseif n < 1000000 then
        local k = n / 1000
        if k < 10 then return string.format("%.1fk", k) end
        return string.format("%dk", math.floor(k + 0.5))
    else
        return string.format("%.2fM", n / 1000000)
    end
end

function F.commas(n)
    n = math.floor((n or 0) + 0.5)
    local sign = ""
    if n < 0 then sign, n = "-", -n end
    local s = tostring(n)
    local out, count = "", 0
    for i = #s, 1, -1 do
        out = s:sub(i, i) .. out
        count = count + 1
        if count % 3 == 0 and i > 1 then out = "," .. out end
    end
    return sign .. out
end

function F.bytes(n)
    n = n or 0
    if n < 1024 then return string.format("%d B", math.floor(n + 0.5)) end
    if n < 1024 * 1024 then return string.format("%d KB", math.floor(n / 1024 + 0.5)) end
    return string.format("%.1f MB", n / (1024 * 1024))
end

function F.hexc(c)
    return string.format("%02x%02x%02x",
        math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

function F.ago(ts, now)
    if not ts or ts <= 0 then return nil end
    if now == nil then
        local A = BGMeter.zenimax.api
        now = (type(A.get_timestamp) == "function") and A.get_timestamp() or nil
    end
    if not now or now <= ts then return nil end
    local s = now - ts
    if s < 3600 then return math.floor(s / 60) .. " min ago" end
    if s < 86400 then return math.floor(s / 3600) .. " h ago" end
    return math.floor(s / 86400) .. " d ago"
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
