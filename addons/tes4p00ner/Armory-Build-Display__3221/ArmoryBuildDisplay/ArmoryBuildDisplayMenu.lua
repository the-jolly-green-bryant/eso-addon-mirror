local ArmoryBuildDisplay = ArmoryBuildDisplay or {}

local LAM2 = LibAddonMenu2

function ArmoryBuildDisplay.CreateMenu()
    local panelData = {
        type = "panel",
        name = "Armory Build Display",
        author = "@tes4p00ner",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            ArmoryBuildDisplay.ApplySettings()
        end
    }

    local optionsData = {
        {
            type = "header",
            name = "General"
        },
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Enable or Disable " .. ArmoryBuildDisplay.displayName,
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("enabled")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("enabled", value)
            end,
            default = ArmoryBuildDisplay.defaults.enabled
        },
        {
            type = "slider",
            name = "Display Scale",
            tooltip = "Scale of the " .. ArmoryBuildDisplay.displayName .. ".",
            min = 35,
            max = 300,
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("displaySize")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("displaySize", value)
            end,
            default = ArmoryBuildDisplay.defaults.displaySize,
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "checkbox",
            name = "Hide on Primary Build",
            tooltip = "Hide the " .. ArmoryBuildDisplay.displayName .. " when the selected primary build is equiped.",
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("hideOnPrimaryBuild")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("hideOnPrimaryBuild", value)
            end,
            default = ArmoryBuildDisplay.defaults.hideOnPrimaryBuild,
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "dropdown",
            name = "Primary Build",
            tooltip = "Select the primary build.",
            choices = {unpack(ArmoryBuildDisplay.GetBuildsList(true))},
            choicesValues = {unpack(ArmoryBuildDisplay.GetBuildsIDList())},
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("primaryBuildID")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("primaryBuildID", value)
            end,
            default = ArmoryBuildDisplay.defaults.primaryBuildID,
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled")) or
                    not (ArmoryBuildDisplay.GetVar("hideOnPrimaryBuild"))
            end
        },
        {
            type = "header",
            name = "Build Text"
        },
        {
            type = "dropdown",
            name = "Armory Build Name Prefix",
            tooltip = "Prefix text to show before Armory Build Name.",
            choices = {"None", "Build:", "Armory:"},
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("prefix")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("prefix", value)
            end,
            default = ArmoryBuildDisplay.defaults.prefix,
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "colorpicker",
            name = "Text Color",
            tooltip = "Set the color of the build name Text",
            getFunc = function()
                return unpack(ArmoryBuildDisplay.GetVar("textColor"))
            end,
            setFunc = function(r, g, b, a)
                ArmoryBuildDisplay.SetVar("textColor", {r, g, b, a})
            end,
            width = "full",
            default = {
                r = ArmoryBuildDisplay.defaults.textColor[1],
                g = ArmoryBuildDisplay.defaults.textColor[2],
                b = ArmoryBuildDisplay.defaults.textColor[3],
                a = ArmoryBuildDisplay.defaults.textColor[4]
            },
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "header",
            name = "Build Icon"
        },
        {
            type = "checkbox",
            name = "Show Icon",
            tooltip = "Enable or Disable the build icon",
            getFunc = function()
                return ArmoryBuildDisplay.GetVar("showIcon")
            end,
            setFunc = function(value)
                ArmoryBuildDisplay.SetVar("showIcon", value)
            end,
            default = ArmoryBuildDisplay.defaults.showIcon,
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "colorpicker",
            name = "Icon Color",
            tooltip = "Set the color of the build icon",
            getFunc = function()
                return unpack(ArmoryBuildDisplay.GetVar("iconColor"))
            end,
            setFunc = function(r, g, b, a)
                ArmoryBuildDisplay.SetVar("iconColor", {r, g, b, a})
            end,
            width = "full",
            default = {
                r = ArmoryBuildDisplay.defaults.iconColor[1],
                g = ArmoryBuildDisplay.defaults.iconColor[2],
                b = ArmoryBuildDisplay.defaults.iconColor[3],
                a = ArmoryBuildDisplay.defaults.iconColor[4]
            },
            disabled = function()
                return not (ArmoryBuildDisplay.GetVar("showIcon") and ArmoryBuildDisplay.GetVar("enabled"))
            end
        },
        {
            type = "divider"
        },
        {
            type = "button",
            name = "Apply",
            tooltip = "Apply the new settings.",
            func = function()
                ArmoryBuildDisplay.ApplySettings()
            end,
            width = "full"
        }
    }

    LAM2:RegisterAddonPanel(ArmoryBuildDisplay.displayName, panelData)
    LAM2:RegisterOptionControls(ArmoryBuildDisplay.displayName, optionsData)
end
