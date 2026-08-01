local FF = FatedFryer
local LAM = LibAddonMenu2

function FF.BuildMenu()
    local panel = {
        type = "panel",
        name = FF.name,
        displayName = "|cFFD54AFated Fryer|r",
        author = "VaalHazac",
        version = FF.version,
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("FatedFryerPanel", panel)

    local options = {
        {
            type = "checkbox",
            name = "Enable Addon",
            getFunc = function() return FF.settings.enabled end,
            setFunc = function(value)
                FF.settings.enabled = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Timer",
            getFunc = function() return FF.settings.showTimer end,
            setFunc = function(value)
                FF.settings.showTimer = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock Window",
            getFunc = function() return FF.settings.lockWindow end,
            setFunc = function(value)
                FF.settings.lockWindow = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Background",
            getFunc = function() return FF.settings.showBackground end,
            setFunc = function(value)
                FF.settings.showBackground = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Icon Size",
            min = 24,
            max = 64,
            step = 1,
            getFunc = function() return FF.settings.iconSize end,
            setFunc = function(value)
                FF.settings.iconSize = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Font Size",
            min = 20,
            max = 48,
            step = 1,
            getFunc = function() return FF.settings.fontSize end,
            setFunc = function(value)
                FF.settings.fontSize = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Spacing",
            min = 0,
            max = 12,
            step = 1,
            getFunc = function() return FF.settings.spacing end,
            setFunc = function(value)
                FF.settings.spacing = value
                FF.RefreshUI()
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Reset Position and Size",
            func = function()
                FF.ResetToDefaults()
            end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls("FatedFryerPanel", options)
end