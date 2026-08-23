-- Pure display helpers. No ESO controls. Combat sustain is 100 Ultimate
-- every 10 seconds while transformed (Update 50); out of combat is free.

ValknarrThemeFormat = ValknarrThemeFormat or {}

local Format = ValknarrThemeFormat

Format.THEME_DEFAULT = "default"
Format.THEME_CLEAN = "clean"
Format.THEME_METAL = "metal"
Format.THEME_METAL1 = "metal"
Format.THEME_METAL2 = "metal"
Format.THEME_METAL3 = "metal"
Format.THEME_METAL4 = "metal"
Format.THEME_VALKNARR = "clean"

Format.WOLF_VANILLA = "vanilla"
Format.WOLF_CLEAN = "clean"
Format.WOLF_1 = "wolf1"
Format.WOLF_2 = "wolf2"
Format.WOLF_3 = "wolf3"
Format.WOLF_4 = "wolf4"
-- Old slash names. The painted snarling wolf is the default metal look.
Format.WOLF_METAL = "wolf2"
Format.WOLF_METAL1 = "wolf2"
Format.WOLF_METAL2 = "wolf2"

Format.ULTIMATE_TICK = 100
Format.TICK_SECONDS = 10
Format.RING_SEGMENTS = 12

function Format.NormalizeThemeId(value)
    if value == "valknarr" or value == Format.THEME_CLEAN then
        return Format.THEME_CLEAN
    end
    if value == "metal" or value == "metal1" or value == "metal2" or value == "metal3" or value == "metal4" then
        return Format.THEME_METAL
    end
    return Format.THEME_DEFAULT
end

function Format.NormalizeWolfId(value)
    if value == "valknarr" or value == Format.WOLF_CLEAN then
        return Format.WOLF_CLEAN
    end
    if value == "wolf1" or value == "wolf2" or value == "wolf3" or value == "wolf4" then
        return value
    end
    if value == "metal" or value == "metal1" or value == "metal2" then
        return Format.WOLF_2
    end
    return Format.WOLF_VANILLA
end

function Format.ResourcesThemed(themeId)
    local id = Format.NormalizeThemeId(themeId)
    return id == Format.THEME_CLEAN or id == Format.THEME_METAL
end

function Format.ResourcesMetal(themeId)
    return Format.NormalizeThemeId(themeId) == Format.THEME_METAL
end

function Format.WidgetVisible(wolfId, inForm)
    return Format.NormalizeWolfId(wolfId) ~= Format.WOLF_VANILLA and inForm and true or false
end

function Format.WolfMetal(wolfId)
    local id = Format.NormalizeWolfId(wolfId)
    return id == "wolf1" or id == "wolf2" or id == "wolf3" or id == "wolf4"
end

function Format.RingFilled(pct)
    pct = Format.Percent(pct, 100)
    local filled = math.floor((pct / 100) * Format.RING_SEGMENTS + 0.5)
    if filled < 0 then
        return 0
    end
    if filled > Format.RING_SEGMENTS then
        return Format.RING_SEGMENTS
    end
    return filled
end

function Format.Abbreviate(value)
    value = tonumber(value) or 0
    if value < 0 then
        value = 0
    end
    if value >= 10000 then
        return string.format("%.1fk", value / 1000)
    end
    return tostring(math.floor(value + 0.5))
end

function Format.Percent(current, maximum)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then
        return 0
    end
    local pct = math.floor((current / maximum) * 100 + 0.5)
    if pct < 0 then
        return 0
    end
    if pct > 100 then
        return 100
    end
    return pct
end

function Format.ResourceLine(current, maximum)
    local pct = Format.Percent(current, maximum)
    return Format.Abbreviate(current) .. "  " .. tostring(pct) .. "%"
end

function Format.FuryLine(current, maximum)
    return "Fury  " .. tostring(Format.Percent(current, maximum)) .. "%"
end

function Format.SustainIsLow(ultimate, inCombat)
    if not inCombat then
        return false
    end
    return (tonumber(ultimate) or 0) < Format.ULTIMATE_TICK
end

function Format.SustainSeconds(ultimate, inCombat)
    if not inCombat then
        return nil
    end
    local ult = tonumber(ultimate) or 0
    if ult < 0 then
        ult = 0
    end
    return math.floor(ult / Format.ULTIMATE_TICK) * Format.TICK_SECONDS
end

function Format.SustainLine(ultimate, inCombat)
    local ult = math.floor((tonumber(ultimate) or 0) + 0.5)
    if ult < 0 then
        ult = 0
    end
    if not inCombat then
        return "Ult  " .. tostring(ult)
    end
    if Format.SustainIsLow(ult, true) then
        return "Ult  " .. tostring(ult) .. "   too low"
    end
    local seconds = Format.SustainSeconds(ult, true)
    return "Ult  " .. tostring(ult) .. "   ~" .. tostring(seconds) .. "s"
end

return Format
