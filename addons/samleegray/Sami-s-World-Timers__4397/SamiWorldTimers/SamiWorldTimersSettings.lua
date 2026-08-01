local LAM2 = LibAddonMenu2
local SWT = SamiWorldTimers
local util = SWT.util
local ui = SWT.ui

local function makeGuildDescription()
    local guildTitle = WINDOW_MANAGER:CreateControl("SamiWorldTimersGuildLogoTitle", 
        SamiWorldTimersGuildLogo, CT_LABEL)
    guildTitle:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thin")
    guildTitle:SetText("|cf939daLETHAL REJECTION")
    guildTitle:SetDimensions(240, 31)
    guildTitle:SetHorizontalAlignment(1)
    guildTitle:SetAnchor(TOP, SamiWorldTimersGuildLogo, BOTTOM, 0, 40)
    ui.guildTitle = guildTitle
    
    local guildLabel = WINDOW_MANAGER:CreateControl("SamiWorldTimersGuildLogoLabel", 
        guildTitle, CT_LABEL)
    guildLabel:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick")
    guildLabel:SetText("|C646464PC NA")
    guildLabel:SetDimensions(240, 21)
    guildLabel:SetHorizontalAlignment(1)
    guildLabel:SetAnchor(TOP, guildTitle, BOTTOM, 0, -5)
    ui.guildLabel = guildLabel

    ui.hideMePls:SetHidden(true)
end

function SWT.settingsInit()
    local panelData = {
        type = "panel",
        name = "Sami's World Timers",
        author = "@|cf500e2s|r|ceb00e5a|r|ce100e9m|r|cd700edi|r|cce00f0h|r|cc400f4a|r|cba00f8i|r|cb000fbz|r|ca600ffe|r",
        version = SWT.version,
        website = "https://lethalrejection.com"
    }

    LAM2:RegisterAddonPanel("SamiWorldTimersOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "This addon automatically tracks overland world boss respawn timers. When a boss dies, a countdown timer will appear on your screen. You can also manually add a timer using the /samiwt command followed by an optional boss name (e.g., /samiwt or /samiwt Boss Name).",
    }

    -- Timer Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Timer Options",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Timeout Duration",
        tooltip = "How long to keep a boss in the list after the timer ran out (Default: 8 seconds)",
        getFunc = function() return SWT.settings.timeoutDuration end,
        setFunc = function(value) SWT.settings.timeoutDuration = value end,
        min = 0,
        max = 60,
        step = 1,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Warning Duration",
        tooltip = "When remaining time is below this, use the warning color (Default: 60 seconds)",
        getFunc = function() return SWT.settings.warningDuration end,
        setFunc = function(value) SWT.settings.warningDuration = value end,
        min = 1,
        max = 300,
        step = 1,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Alert Duration",
        tooltip = "When remaining time is below this, use the alert color (Default: 15 seconds)",
        getFunc = function() return SWT.settings.alertDuration end,
        setFunc = function(value) SWT.settings.alertDuration = value end,
        min = 1,
        max = 120,
        step = 1,
    }

    -- Color Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Color Options",
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Default Text Color",
        tooltip = "Default color for timer text",
        getFunc = function() return util.hexToRgb(SWT.settings.defaultTextColour) end,
        setFunc = function(r, g, b) 
            SWT.settings.defaultTextColour = util.rgbToHex(r, g, b)
            SWT.ui.updateTextColors()
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Warning Color",
        tooltip = "Color used for warning timers",
        getFunc = function() return util.hexToRgb(SWT.settings.warningColour) end,
        setFunc = function(r, g, b) 
            SWT.settings.warningColour = util.rgbToHex(r, g, b)
            SWT.ui.updateTextColors()
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Alert Color",
        tooltip = "Color used for alert timers",
        getFunc = function() return util.hexToRgb(SWT.settings.alertColour) end,
        setFunc = function(r, g, b) 
            SWT.settings.alertColour = util.rgbToHex(r, g, b)
            SWT.ui.updateTextColors()
        end,
    }

    -- Background Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Background Options",
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Background Color",
        tooltip = "Color of the background behind timers",
        getFunc = function() return util.hexToRgb(SWT.settings.backgroundColor) end,
        setFunc = function(r, g, b) 
            SWT.settings.backgroundColor = util.rgbToHex(r, g, b)
            SWT.ui.updateBackgroundColor()
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Background Opacity",
        tooltip = "Opacity of the background (0 = transparent, 1 = opaque)",
        getFunc = function() return SWT.settings.backgroundOpacity end,
        setFunc = function(value) 
            SWT.settings.backgroundOpacity = value
            SWT.ui.updateBackgroundOpacity()
        end,
        min = 0,
        max = 1,
        step = 0.05,
    }

    -- Display Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Display Options",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Show Title",
        tooltip = "Show or hide the 'Boss Timers' title text",
        getFunc = function() return SWT.settings.showTitle end,
        setFunc = function(value) 
            SWT.settings.showTitle = value
            SWT.ui.updateTitleVisibility()
        end,
        default = SWT.defaults.showTitle,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Wipe Timers on Zone Change",
        tooltip = "Clear all tracked timers when changing zones",
        getFunc = function() return SWT.settings.wipeOnZoneChange end,
        setFunc = function(value) SWT.settings.wipeOnZoneChange = value end,
        default = SWT.defaults.wipeOnZoneChange,
    }

    -- Debug Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Debug",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Debug",
        tooltip = "Enable debug output in chat",
        getFunc = function() return SWT.settings.debug end,
        setFunc = function(value) SWT.settings.debug = value end,
        default = SWT.defaults.debug,
    }

    -- Guild Information
    optionsData[ #optionsData + 1 ] = {
        type = "texture",
        image = "SamiWorldTimers/samis-logo.dds",
        imageWidth = "192",
        imageHeight = "192",
        reference = "SamiWorldTimersGuildLogo"
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "HideMePls",
        getFunc = function()
            if SamiWorldTimersGuildLogo ~= nil then
                makeGuildDescription()
            end
            return false
        end,
        setFunc = function(value)
            return false
        end,
        default = false,
        disabled = true,
        reference = "SamiWorldTimersUI_HideMePls",
    }
    
    LAM2:RegisterOptionControls("SamiWorldTimersOptions", optionsData)
end
