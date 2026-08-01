local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts

local function Rainbowify(str)
    local rainbow = ""
    for i = 1, #str do
        local r, g, b = Crutch.ConvertHSLToRGB((i - 1) / #str, 1, 0.5)
        rainbow = string.format("%s|c%02x%02x%02x%s",
            rainbow,
            math.floor(r * 255),
            math.floor(g * 255),
            math.floor(b * 255),
            string.sub(str, i, i))
    end
    return rainbow
end
CAE.Utils.Rainbowify = Rainbowify
