AntiDK = AntiDK or {}

local LAM = LibAddonMenu2

function AntiDK:CreateSettings()
    local panelData = {
        type = "panel",
        name = "AntiDK",
        displayName = "Anti DK",
        author = "Vixen Hunny",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsTable = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Enable AntiDK",
            tooltip = "Enable or disable the Anti DK addon",
            getFunc = function() return AntiDK.settings.enabled end,
            setFunc = function(value) AntiDK.settings.enabled = value end,
            width = "full",
        },
        {
            type = "header",
            name = "Stun Dodge Settings",
        },
        {
            type = "checkbox",
            name = "Show Stun Dodge",
            tooltip = "Display stun dodge alerts",
            getFunc = function() return AntiDK.settings.showStunDodge end,
            setFunc = function(value) AntiDK.settings.showStunDodge = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Buggy Stun Duration",
            tooltip = "Display stun duration information",
            getFunc = function() return AntiDK.settings.showBuggyStunDuration end,
            setFunc = function(value) AntiDK.settings.showBuggyStunDuration = value end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Stun Warning Color",
            tooltip = "Color for stun warnings",
            getFunc = function()
                local hex = AntiDK.settings.stunhex
                return {hex.r, hex.g, hex.b}
            end,
            setFunc = function(r, g, b)
                AntiDK.settings.stunhex.r = r
                AntiDK.settings.stunhex.g = g
                AntiDK.settings.stunhex.b = b
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Power Leech Settings",
        },
        {
            type = "checkbox",
            name = "Show Power Lash Stacks",
            tooltip = "Display Power Leech stack count",
            getFunc = function() return AntiDK.settings.showPLStacks end,
            setFunc = function(value) AntiDK.settings.showPLStacks = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Power Lash Duration",
            tooltip = "Display Power Leech duration",
            getFunc = function() return AntiDK.settings.showPLDuration end,
            setFunc = function(value) AntiDK.settings.showPLDuration = value end,
            width = "full",
        },
        {
            type = "header",
            name = "Molten Whip Settings",
        },
        {
            type = "checkbox",
            name = "Show Molten Whip Stacks",
            tooltip = "Display Molten Whip stack count",
            getFunc = function() return AntiDK.settings.showMoltenWhipStacks end,
            setFunc = function(value) AntiDK.settings.showMoltenWhipStacks = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Molten Whip Duration",
            tooltip = "Display Molten Whip duration",
            getFunc = function() return AntiDK.settings.showMoltenWhipDuration end,
            setFunc = function(value) AntiDK.settings.showMoltenWhipDuration = value end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Molten Whip Warning Color",
            tooltip = "Color for Molten Whip warnings",
            getFunc = function()
                local hex = AntiDK.settings.whiphex
                return {hex.r, hex.g, hex.b}
            end,
            setFunc = function(r, g, b)
                AntiDK.settings.whiphex.r = r
                AntiDK.settings.whiphex.g = g
                AntiDK.settings.whiphex.b = b
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Corrosive Armor Settings",
        },
        {
            type = "checkbox",
            name = "Show Corrosive Armor Active",
            tooltip = "Display when Corrosive Armor is active",
            getFunc = function() return AntiDK.settings.showCorrosiveactive end,
            setFunc = function(value) AntiDK.settings.showCorrosiveactive = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Corrosive Armor Duration",
            tooltip = "Display Corrosive Armor duration",
            getFunc = function() return AntiDK.settings.showCorroDuration end,
            setFunc = function(value) AntiDK.settings.showCorroDuration = value end,
            width = "full",
        },
        {
            type = "header",
            name = "UI Settings",
        },
        {
            type = "slider",
            name = "UI Scale",
            tooltip = "Adjust the scale of the UI",
            min = 0.5,
            max = 10.0,
            step = 0.1,
            getFunc = function() return AntiDK.settings.uiScale end,
            setFunc = function(value)
                AntiDK.settings.uiScale = value
                if AntiDK.CenterWindow then
                    AntiDK.CenterWindow:SetScale(value)
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "UI Position X",
            tooltip = "Move tracker horizontally",
            min = -2000,
            max = 2000,
            step = 5,
            getFunc = function() return AntiDK.settings.posX or 0 end,
            setFunc = function(value)
                AntiDK.settings.posX = value
                if AntiDK.ApplyPositionSettings then
                    AntiDK:ApplyPositionSettings()
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "UI Position Y",
            tooltip = "Move tracker vertically",
            min = -2000,
            max = 2000,
            step = 5,
            getFunc = function() return AntiDK.settings.posY or -90 end,
            setFunc = function(value)
                AntiDK.settings.posY = value
                if AntiDK.ApplyPositionSettings then
                    AntiDK:ApplyPositionSettings()
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto Hide Tracker",
            tooltip = "Hide tracker automatically when no tracked DK abilities are active",
            getFunc = function() return AntiDK.settings.autoHideEnabled ~= false end,
            setFunc = function(value)
                AntiDK.settings.autoHideEnabled = value
                if AntiDK.CenterWindow and not value then
                    AntiDK.CenterWindow:SetHidden(false)
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Auto Hide Delay",
            tooltip = "Seconds to wait before hiding after no active abilities",
            min = 0,
            max = 30,
            step = 0.5,
            getFunc = function() return AntiDK.settings.autoHideDelay or 0 end,
            setFunc = function(value)
                AntiDK.settings.autoHideDelay = value
            end,
            disabled = function() return AntiDK.settings.autoHideEnabled == false end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Tracker Backdrop",
            tooltip = "Show or hide the main window backdrop and title strip",
            getFunc = function() return AntiDK.settings.showBackdrop == true end,
            setFunc = function(value)
                AntiDK.settings.showBackdrop = value
                if AntiDK.ApplyBackdropSettings then
                    AntiDK:ApplyBackdropSettings()
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Backdrop Opacity",
            tooltip = "Adjust opacity of the main backdrop when enabled",
            min = 0.1,
            max = 1.0,
            step = 0.05,
            getFunc = function() return AntiDK.settings.backdropOpacity or 0.6 end,
            setFunc = function(value)
                AntiDK.settings.backdropOpacity = value
                if AntiDK.ApplyBackdropSettings then
                    AntiDK:ApplyBackdropSettings()
                end
            end,
            disabled = function() return not (AntiDK.settings.showBackdrop == true) end,
            width = "full",
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Adjust the font size",
            min = 10,
            max = 40,
            step = 1,
            getFunc = function() return AntiDK.settings.fontSize end,
            setFunc = function(value) AntiDK.settings.fontSize = value end,
            width = "full",
        },
        {
            type = "slider",
            name = "Center Timer Font Size",
            tooltip = "Adjust the center screen timer font size (Shattering Rocks & Fossilize)",
            min = 20,
            max = 80,
            step = 5,
            getFunc = function() return AntiDK.settings.centerTimerFontSize or 40 end,
            setFunc = function(value) AntiDK.settings.centerTimerFontSize = value end,
            width = "full",
        },
    }
    
    LAM:RegisterAddonPanel("AntiDK_Settings", panelData)
    LAM:RegisterOptionControls("AntiDK_Settings", optionsTable)
end