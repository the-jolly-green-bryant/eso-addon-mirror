local JCCB = JacobsChannelCastBar

function JCCB:RegisterSettings()
    local LAM2 = LibAddonMenu2
    if not LAM2 then
        d("[JacobsChannelCastBar] LibAddonMenu-2.0 not found.")
        return
    end

    local panelData = {
        type = "panel",
        name = "JacobsChannelCastBar",
        displayName = "JacobsChannelCastBar",
        author = "Jacobs",
        version = JCCB.version,
        slashCommand = "/jccb",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel("JacobsChannelCastBar_Panel", panelData)

    local options = {
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function() return JCCB.sv.enabled end,
            setFunc = function(v)
                JCCB.sv.enabled = v
                if not v then
                    JCCB:StopCast("disabled")
                else
                    JCCB:RefreshVisibility()
                end
            end,
            default = JCCB.defaults.enabled,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Unlock Bar",
            getFunc = function() return JCCB.sv.unlocked end,
            setFunc = function(v)
                JCCB.sv.unlocked = v
                JCCB:RefreshVisibility()
            end,
            default = JCCB.defaults.unlocked,
            width = "half",
        },

        { type = "divider" },

        {
            type = "checkbox",
            name = "Show Icon",
            getFunc = function() return JCCB.sv.showIcon end,
            setFunc = function(v)
                JCCB.sv.showIcon = v
                JCCB:ApplySettings()
                JCCB:RestorePosition()
            end,
            default = JCCB.defaults.showIcon,
            width = "half",
        },
        {
            type = "slider",
            name = "Bar Color Brightness",
            min = 0.00,
            max = 1.00,
            step = 0.01,
            getFunc = function() return JCCB.sv.colorBrightness end,
            setFunc = function(v)
                JCCB.sv.colorBrightness = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.colorBrightness,
            width = "half",
        },

        {
            type = "checkbox",
            name = "Debug Chat Output",
            getFunc = function() return JCCB.sv.debug end,
            setFunc = function(v)
                JCCB.sv.debug = v
            end,
            default = JCCB.defaults.debug,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Scan Mode",
            getFunc = function() return JCCB.sv.scanMode end,
            setFunc = function(v)
                JCCB.sv.scanMode = v
            end,
            default = JCCB.defaults.scanMode,
            width = "half",
        },

        { type = "divider" },

        {
            type = "slider",
            name = "Width",
            min = 120,
            max = 800,
            step = 2,
            getFunc = function() return JCCB.sv.width end,
            setFunc = function(v)
                JCCB.sv.width = v
                JCCB:ApplySettings()
                JCCB:RestorePosition()
            end,
            default = JCCB.defaults.width,
            width = "half",
        },
        {
            type = "slider",
            name = "Height",
            min = 10,
            max = 80,
            step = 1,
            getFunc = function() return JCCB.sv.height end,
            setFunc = function(v)
                JCCB.sv.height = v
                JCCB:ApplySettings()
                JCCB:RestorePosition()
            end,
            default = JCCB.defaults.height,
            width = "half",
        },
        {
            type = "slider",
            name = "Scale",
            min = 0.5,
            max = 2.0,
            step = 0.01,
            getFunc = function() return JCCB.sv.scale end,
            setFunc = function(v)
                JCCB.sv.scale = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.scale,
            width = "half",
        },
        {
            type = "slider",
            name = "Alpha",
            min = 0.1,
            max = 1.0,
            step = 0.01,
            getFunc = function() return JCCB.sv.alpha end,
            setFunc = function(v)
                JCCB.sv.alpha = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.alpha,
            width = "half",
        },
        {
            type = "slider",
            name = "Font Size",
            min = 12,
            max = 32,
            step = 1,
            getFunc = function() return JCCB.sv.fontSize end,
            setFunc = function(v)
                JCCB.sv.fontSize = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.fontSize,
            width = "half",
        },

        {
            type = "checkbox",
            name = "Reverse Fill Direction",
            getFunc = function() return JCCB.sv.reverseFill end,
            setFunc = function(v)
                JCCB.sv.reverseFill = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.reverseFill,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Show Skill Name",
            getFunc = function() return JCCB.sv.showName end,
            setFunc = function(v)
                JCCB.sv.showName = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.showName,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Show Timer",
            getFunc = function() return JCCB.sv.showTimer end,
            setFunc = function(v)
                JCCB.sv.showTimer = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.showTimer,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Show Background",
            getFunc = function() return JCCB.sv.showBackground end,
            setFunc = function(v)
                JCCB.sv.showBackground = v
                JCCB:ApplySettings()
            end,
            default = JCCB.defaults.showBackground,
            width = "half",
        },

        { type = "divider" },

        {
            type = "button",
            name = "Reset Position",
            func = function()
                JCCB.sv.x = 0
                JCCB.sv.y = 200
                JCCB:RestorePosition()
            end,
            width = "half",
        },
    }

    LAM2:RegisterOptionControls("JacobsChannelCastBar_Panel", options)
end