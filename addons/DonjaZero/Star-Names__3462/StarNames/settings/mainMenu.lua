StarNames = StarNames or {}

function StarNames:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Star Names",
        displayName = "Star Names",
        author = StarNames.author,
        version = StarNames.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        ----------------------------------------------------------------
        -- Top level settings
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show extra debug info in chat",
            default = false,
            getFunc = function() return StarNames.savedOptions.debug end,
            setFunc = function(value)
                StarNames.savedOptions.debug = value
                StarNames.dbg("Settings: debug set to " .. tostring(StarNames.savedOptions.debug)) -- should never get a debug message that debug is set to false
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show labels on stars",
            tooltip = "Show the names of Champion Point stars",
            default = true,
            getFunc = function() return StarNames.savedOptions.showLabels end,
            setFunc = function(value)
                StarNames.savedOptions.showLabels = value
                StarNames.dbg("Settings: showLabels set to " .. tostring(StarNames.savedOptions.showLabels))
                StarNames.RefreshLabels(value)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show labels in main CP screen",
            tooltip = "Show the star names on the top level CP screen with all three constellations (can be crowded)",
            default = true,
            getFunc = function() return StarNames.savedOptions.showOnMainScreen end,
            setFunc = function(value)
                StarNames.savedOptions.showOnMainScreen = value
                StarNames.dbg("Settings: showOnMainScreen set to " .. tostring(StarNames.savedOptions.showOnMainScreen))
                StarNames.RefreshLabels(value)
            end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Passive star label color",
            tooltip = "Color of the labels for unslottable stars",
            default = ZO_ColorDef:New(1, 1, 0.5),
            getFunc = function() return unpack(StarNames.savedOptions.passiveLabelColor) end,
            setFunc = function(r, g, b)
                StarNames.savedOptions.passiveLabelColor = {r, g, b}
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
        {
            type = "slider",
            name = "Passive star label font size",
            tooltip = "Font size of the labels for unslottable stars",
            getFunc = function() return StarNames.savedOptions.passiveLabelSize end,
            default = 22,
            min = 8,
            max = 54,
            step = 1,
            setFunc = function(value)
                StarNames.savedOptions.passiveLabelSize = value
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
        {
            type = "colorpicker",
            name = "Slottable star label color",
            tooltip = "Color of the labels for slottable stars",
            default = ZO_ColorDef:New(1, 1, 1),
            getFunc = function() return unpack(StarNames.savedOptions.slottableLabelColor) end,
            setFunc = function(r, g, b)
                StarNames.savedOptions.slottableLabelColor = {r, g, b}
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
        {
            type = "slider",
            name = "Slottable star label font size",
            tooltip = "Font size of the labels for slottable stars",
            getFunc = function() return StarNames.savedOptions.slottableLabelSize end,
            default = 18,
            min = 8,
            max = 54,
            step = 1,
            setFunc = function(value)
                StarNames.savedOptions.slottableLabelSize = value
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
        {
            type = "colorpicker",
            name = "Star cluster label color",
            tooltip = "Color of the labels for star clusters",
            default = ZO_ColorDef:New(1, 0.7, 1),
            getFunc = function() return unpack(StarNames.savedOptions.clusterLabelColor) end,
            setFunc = function(r, g, b)
                StarNames.savedOptions.clusterLabelColor = {r, g, b}
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
        {
            type = "slider",
            name = "Star cluster label font size",
            tooltip = "Font size of the labels for star clusters",
            getFunc = function() return StarNames.savedOptions.clusterLabelSize end,
            default = 13,
            min = 8,
            max = 54,
            step = 1,
            setFunc = function(value)
                StarNames.savedOptions.clusterLabelSize = value
                StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            end,
            width = "half",
            disabled = function() return not StarNames.savedOptions.showLabels end
        },
    }

    StarNames.addonPanel = LAM:RegisterAddonPanel("StarNamesOptions", panelData)
    LAM:RegisterOptionControls("StarNamesOptions", optionsData)
end

function StarNames.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(StarNames.addonPanel)
end
