local SWT = SamiWorldTimers

SWT.util = SWT.util or {}

local util = SWT.util

function util.colorText(text, hex)
    return "|c" .. hex .. text .. "|r"
end

function util.formatTime(sec)
    return string.format("%02d:%02d", math.floor(sec / 60), (sec % 60))
end

function util.getCurrentZoneId()
    return GetZoneId(GetUnitZoneIndex("player"))
end

function util.tableContains(t, elem)
    for _, v in pairs(t) do
        if v == elem then
            return true
        end
    end
    return false
end

function util.hexToRgb(hex)
    local clean = hex:gsub("#", "")
    if #clean >= 6 then
        local r = tonumber(clean:sub(1, 2), 16) or 255
        local g = tonumber(clean:sub(3, 4), 16) or 255
        local b = tonumber(clean:sub(5, 6), 16) or 255
        return r / 255, g / 255, b / 255, 1
    end
    return 1, 1, 1, 1
end

function util.rgbToHex(r, g, b)
    local rr = math.floor((r or 1) * 255 + 0.5)
    local gg = math.floor((g or 1) * 255 + 0.5)
    local bb = math.floor((b or 1) * 255 + 0.5)
    return string.format("%02X%02X%02X", rr, gg, bb)
end

function util.migrateSettings(settings)
    -- No migrations yet, but this is where you'd handle any changes to the settings structure in future versions
end
