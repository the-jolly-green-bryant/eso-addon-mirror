local DMC = DarkModeConsole

local function CreateSettingsMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS or not LHAS.AddAddon then
        return
    end

    local panel = LHAS:AddAddon(DMC.displayName,
    {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            DMC.ResetToDefaults()
        end,
    })
    if not panel then
        return
    end

    local ST = LHAS

    panel:AddSettings(
    {
        {
            type = ST.ST_LABEL,
            label = "Turns the gold gamepad HUD and menu borders black and darkens the window panes. Changes apply instantly.",
        },
        {
            type = ST.ST_CHECKBOX,
            label = "Enable Dark Mode",
            tooltip = "Master switch. Turning it off restores every recoloured element immediately.",
            default = DMC.defaults.enabled,
            getFunction = function()
                return DMC.IsEnabled()
            end,
            setFunction = function(value)
                DMC.SetEnabled(value)
            end,
        },
        {
            type = ST.ST_COLOR,
            label = "Border / accent colour",
            tooltip = "Colour used for the compass frame, action bar frames, buff frames, attribute bar frames, window rails, header dividers and tooltip edges. Pure black by default.",
            default = { DMC.defaults.borderColor.r, DMC.defaults.borderColor.g, DMC.defaults.borderColor.b, 1 },
            getFunction = function()
                return DMC.GetBorderColor()
            end,
            setFunction = function(r, g, b, a)
                DMC.SetBorderColor(r, g, b)
            end,
            disable = function()
                return not DMC.IsEnabled()
            end,
        },
        {
            type = ST.ST_CHECKBOX,
            label = "Darken backgrounds",
            tooltip = "Also tints window pane backgrounds, tooltip and dialog fills, and the backing of health / group bars.",
            default = DMC.defaults.darkenBackgrounds,
            getFunction = function()
                return DMC.GetDarkenBackgrounds()
            end,
            setFunction = function(value)
                DMC.SetDarkenBackgrounds(value)
            end,
            disable = function()
                return not DMC.IsEnabled()
            end,
        },
        {
            type = ST.ST_COLOR,
            label = "Background colour",
            tooltip = "Tint applied to the darkened backgrounds. Pure black by default.",
            default = { DMC.defaults.backgroundColor.r, DMC.defaults.backgroundColor.g, DMC.defaults.backgroundColor.b, 1 },
            getFunction = function()
                return DMC.GetBackgroundColor()
            end,
            setFunction = function(r, g, b, a)
                DMC.SetBackgroundColor(r, g, b)
            end,
            disable = function()
                return not DMC.IsEnabled() or not DMC.GetDarkenBackgrounds()
            end,
        },
        {
            type = ST.ST_BUTTON,
            label = "Re-apply theme",
            tooltip = "Runs a fresh pass over the whole interface. Useful if another addon repainted something after loading.",
            buttonText = "Re-apply",
            clickHandler = function()
                DMC.Reapply()
            end,
            disable = function()
                return not DMC.IsEnabled()
            end,
        },
    })
end

CALLBACK_MANAGER:RegisterCallback("DarkModeConsole_Initialized", function()
    local ok, err = pcall(CreateSettingsMenu)
    if not ok then
        d("[Dark Mode Console] settings menu unavailable: " .. tostring(err))
    end
end)
