if not GildedUI then return end

local Addon = GildedUI

function Addon:RegisterDefaults(chunk)
    self.defaults = self.defaults or {}
    for key, value in pairs(chunk) do
        self.defaults[key] = value
    end
end

function Addon:ClampSavedNumber(key, range)
    local sv = self.state.sv
    local defaults = self.defaults
    if type(sv[key]) ~= "number" then
        sv[key] = defaults[key]
    else
        sv[key] = zo_clamp(sv[key], range.min, range.max)
    end
end

function Addon:RoundSavedOpacity(key)
    local sv = self.state.sv
    if type(sv[key]) == "number" then
        sv[key] = zo_round(sv[key] * 10) / 10
    end
end

function Addon:SanitizeSavedColor(key, withAlpha)
    local sv = self.state.sv
    local default = self.defaults[key]
    local color = sv[key]
    if type(color) ~= "table" or type(color[1]) ~= "number" or type(color[2]) ~= "number" or type(color[3]) ~= "number" then
        if withAlpha then
            sv[key] = { default[1], default[2], default[3], default[4] or 1 }
        else
            sv[key] = { default[1], default[2], default[3] }
        end
    else
        color[1] = zo_clamp(color[1], 0, 1)
        color[2] = zo_clamp(color[2], 0, 1)
        color[3] = zo_clamp(color[3], 0, 1)
        if withAlpha then
            if type(color[4]) ~= "number" then
                color[4] = default[4] or 1
            else
                color[4] = zo_clamp(color[4], 0, 1)
            end
        end
    end
end

function Addon:SanitizeSavedBoolean(key)
    local sv = self.state.sv
    if type(sv[key]) ~= "boolean" then
        sv[key] = self.defaults[key]
    end
end

function Addon:SanitizeSavedFontSize(key)
    local sv = self.state.sv
    if not self.fontMap[sv[key]] then
        sv[key] = self.defaults[key]
    end
end

function Addon:GetIconPathForKey(iconKey, choices, noneIndex)
    local index = self.state.sv[iconKey]
    if index == noneIndex then
        return nil
    end
    return choices[index]
end

function Addon:IconPathToIndex(path, choices, fallback)
    if type(path) ~= "string" or path == "" then
        return fallback
    end

    for index = 1, #choices do
        if choices[index] == path then
            return index
        end
    end

    return fallback
end

function Addon:GetFontNameForSize(size)
    for _, item in ipairs(self.fontSizeItems) do
        if item.value == size then
            return item.name
        end
    end
    return "Small (16)"
end
