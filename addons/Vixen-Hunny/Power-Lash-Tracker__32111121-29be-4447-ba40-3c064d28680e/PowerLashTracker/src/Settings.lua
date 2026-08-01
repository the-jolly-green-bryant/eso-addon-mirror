PLT = PLT or {}
PLT.Settings = PLT.Settings or {}
PLT.UI = PLT.UI or {}
LAM = LibAddonMenu2
function PLT:ResetSettings()
    PLT.savedVariables = ZO_SavedVars:NewAccountWide("PowerLashTrackerSavedVariables", 1, nil, PLT.defaultSettings)
    PLT:UpdateUI()
end
function PLT:CreateSettings()
    local panelData = {
        type = "panel",
        name = "Power Lash Tracker",
        displayName = "Power Lash Tracker",
        author = "Vixen Hunny",
        version = "1.0",
        registrerForRefresh = true,
        registerForDefaults = true,
    }
    local optionsPanel = LAM:RegisterAddonPanel("PowerLashTrackerOptions", panelData)

    local optionsData = {
        {
            type = "header",
            name = "Power Lash Tracker Settings",
        },
        {
            type = "checkbox",
            name = "Enable Tracker",
            tooltip = "Enable or disable the Power Lash Tracker.",
            getFunc = function() return PLT.savedVariables.enabled end,
            setFunc = function(value) PLT.savedVariables.enabled = value PLT:UpdateUI() end,
        },
        {
            type = "slider",
            name = "X Position",
            tooltip = "Set the X position of the Power Lash buff/cooldown",
            min = 1,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return PLT.savedVariables.xPosition end,
            setFunc = function(value) PLT.savedVariables.xPosition = value PLT:UpdateUI() end,
        },
        {
            type = "slider",
            name = "Y Position",
            tooltip = "Set the Y position of the Power Lash buff/cooldown",
            min = 1,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return PLT.savedVariables.yPosition end,
            setFunc = function(value) PLT.savedVariables.yPosition = value PLT:UpdateUI() end,
        },
        {
            type = "colorpicker",
            name = "Cooldown Bar Color",
            tooltip = "Set the color of the Power Lash cooldown bar.",
            getFunc = function() return PLT.savedVariables.cooldownBarColor.r, PLT.savedVariables.cooldownBarColor.g, PLT.savedVariables.cooldownBarColor.b, PLT.savedVariables.cooldownBarColor.a end,
            setFunc = function(r, g, b, a) PLT.savedVariables.cooldownBarColor = { r = r, g = g, b = b, a = a } PLT:UpdateUI() end,
        },
        {
            type = "editbox",
            name = "Cooldown Text Color",
            tooltip = "Set the color of the cooldown text (hex format, e.g., ff0000 for red).",
            getFunc = function() return PLT.savedVariables.cooldownTextColor end,
            setFunc = function(value) PLT.savedVariables.cooldownTextColor = value PLT:UpdateUI() end,
        },
        {
            type = "editbox",
            name = "Buff Text Color",
            tooltip = "Set the color of the buff text (hex format, e.g., 00ff00 for green).",
            getFunc = function() return PLT.savedVariables.buffTextColor end,
            setFunc = function(value) PLT.savedVariables.buffTextColor = value PLT:UpdateUI() end
        },
        {
            type = "slider",
            name = "UI Scale",
            tooltip = "Set the scale of the Power Lash Tracker UI.",
            min = 0.05,
            max = 10,
            step = 0.01,
            getFunc = function() return PLT.savedVariables.uiScale end,
            setFunc = function(value) PLT.savedVariables.uiScale = value PLT:UpdateUI() end,
        },
        {
            type = "description",
            text = "Note: Changes will take effect immediately.",
        },
        {
            type = "button",
            name = "Reset to Defaults",
            tooltip = "Reset all settings to their default values.",
            func = function() PLT:ResetSettings() end,
        }

    }
    LAM:RegisterOptionControls("PowerLashTrackerOptions", optionsData)
end