if not GildedUI then return end

local Addon = GildedUI

-- Small LCM row factories shared by module menus. Call CreateSettingsHelpers()
-- once per BuildSettingsMenu so closures capture the current saved vars.
function Addon:CreateSettingsHelpers()
    local sv = self.state.sv
    local limits = self.limits
    local H = {}

    function H.Append(target, source)
        for i = 1, #source do
            target[#target + 1] = source[i]
        end
    end

    function H.Toggle(name, getFunc, setFunc, default, disabled)
        return {
            type = "toggle",
            name = name,
            getFunc = getFunc,
            setFunc = setFunc,
            default = default,
            disabled = disabled,
        }
    end

    function H.Slider(name, min, max, step, getFunc, setFunc, default, disabled)
        return {
            type = "slider",
            name = name,
            min = min,
            max = max,
            step = step,
            getFunc = getFunc,
            setFunc = setFunc,
            default = default,
            disabled = disabled,
            format = type(step) == "number" and step < 1 and "%.1f" or "%d",
        }
    end

    function H.FontSizeDropdown(sizeKey)
        local choices, values = {}, {}
        for i, item in ipairs(Addon.fontSizeItems) do
            choices[i] = item.name
            values[i] = item.value
        end
        return {
            type = "selector",
            name = "Font Size",
            choices = choices,
            choicesValues = values,
            getFunc = function() return sv[sizeKey] end,
            setFunc = function(value)
                sv[sizeKey] = value
                Addon:ApplyFont()
            end,
            default = Addon.defaults[sizeKey],
        }
    end

    -- withAlpha: persist/return channel 4. onChange: optional callback after write.
    function H.ColorPicker(name, colorKey, disabled, withAlpha, onChange)
        local defaultColor = Addon.defaults[colorKey]
        local defaultA = withAlpha and (defaultColor[4] or 1) or 1
        return {
            type = "colorpicker",
            name = name,
            getFunc = function()
                local color = sv[colorKey]
                return color[1], color[2], color[3], withAlpha and (color[4] or 1) or 1
            end,
            setFunc = function(r, g, b, a)
                local color = sv[colorKey]
                color[1] = r
                color[2] = g
                color[3] = b
                if withAlpha then
                    color[4] = a
                end
                if onChange then
                    onChange()
                end
            end,
            default = { defaultColor[1], defaultColor[2], defaultColor[3], defaultA },
            disabled = disabled,
        }
    end

    function H.BackgroundControls(backgroundKey, paddingKey, opacityKey)
        return {
            H.Toggle(
                "Show Background",
                function() return sv[backgroundKey] end,
                function(v)
                    sv[backgroundKey] = v
                    Addon:ApplyBackground()
                end,
                Addon.defaults[backgroundKey]
            ),
            H.Toggle(
                "Background Padding",
                function() return sv[paddingKey] end,
                function(v)
                    sv[paddingKey] = v
                    Addon:ApplyBackground()
                end,
                Addon.defaults[paddingKey],
                function() return not sv[backgroundKey] end
            ),
            H.Slider(
                "Background Opacity",
                limits.backgroundOpacity.min,
                limits.backgroundOpacity.max,
                0.1,
                function() return sv[opacityKey] end,
                function(v)
                    sv[opacityKey] = v
                    Addon:ApplyBackground()
                end,
                Addon.defaults[opacityKey],
                function() return not sv[backgroundKey] end
            ),
        }
    end

    function H.PositionSliders(xName, yName, posXKey, posYKey, applyFunc)
        return {
            H.Slider(
                xName,
                limits.posX.min,
                limits.posX.max,
                5,
                function() return sv[posXKey] end,
                function(v)
                    sv[posXKey] = v
                    applyFunc()
                end,
                Addon.defaults[posXKey]
            ),
            H.Slider(
                yName,
                limits.posY.min,
                limits.posY.max,
                5,
                function() return sv[posYKey] end,
                function(v)
                    sv[posYKey] = v
                    applyFunc()
                end,
                Addon.defaults[posYKey]
            ),
        }
    end

    function H.ColorTier(useColorsKey, goodName, midName, lowName, goodKey, midKey, lowKey)
        local disabled = function() return not sv[useColorsKey] end
        return {
            H.Toggle(
                "Use Colors",
                function() return sv[useColorsKey] end,
                function(v) sv[useColorsKey] = v end,
                Addon.defaults[useColorsKey]
            ),
            H.ColorPicker(goodName, goodKey, disabled),
            H.ColorPicker(midName, midKey, disabled),
            H.ColorPicker(lowName, lowKey, disabled),
        }
    end

    function H.IconPicker(iconKey, iconChoices, applyIcon)
        return {
            type = "iconpicker",
            name = "Icon",
            choices = iconChoices,
            getFunc = function() return sv[iconKey] end,
            setFunc = function(index)
                sv[iconKey] = index
                applyIcon()
            end,
            default = Addon.defaults[iconKey],
        }
    end

    return H
end
