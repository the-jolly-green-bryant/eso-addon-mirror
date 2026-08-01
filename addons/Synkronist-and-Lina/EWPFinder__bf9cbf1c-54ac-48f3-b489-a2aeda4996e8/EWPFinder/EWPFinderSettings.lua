local LAM = LibAddonMenu2
EWPFinder = EWPFinder or {}
EWPFinderSettings = EWPFinderSettings or {}
local function EWPFinderSettings_Initialize()
    local panelData = {
        type = "panel",
        name = "EWPFinder",
        displayName = "EWPFinder Settings",
        author = "Synkronist and Lina",
        version = EWPFinder.version,
    }
    EWPFinderSettings.settingsPanel = LAM:RegisterAddonPanel("EWPFinderSettingsPanel", panelData)
    EWPFinder.db = ZO_SavedVars:New("EWPFinderSettings", 3, nil, EWPFinder.defaults_db)
    local optionsData = {
        {
            type = "slider",
            name = "X Position WD/SD",
            tooltip = "Adjust the horizontal position of the text label (moves right as value increases).",
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return EWPFinder.db.location.x end,
            setFunc = function(value)
                EWPFinder.db.location.x = value
                EWPFinder:SetAppearance()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Y Position WD/SD",
            tooltip = "Adjust the vertical position of the text label (moves down as value increases).",
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return EWPFinder.db.location.y end,
            setFunc = function(value)
                EWPFinder.db.location.y = value
                EWPFinder:SetAppearance()
            end,
            default = 520,
        },
        {
            type = "slider",
            name= "X Position Buff Timer",
            tooltip = "Adjust the X position buff timer label",
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return EWPFinder.db.locationbuff.x end,
            setFunc = function(value)
                EWPFinder.db.locationbuff.x = value
                EWPFinder:SetAppearance() end,
            default = 500
        },
        {
            type = "slider",
            name= "Y Position Buff Timer",
            tooltip = "Adjust the Y position buff timer label",
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return EWPFinder.db.locationbuff.y end,
            setFunc = function(value)
                EWPFinder.db.locationbuff.y = value
                EWPFinder:SetAppearance() end,
            default = 580
        },
        {
            type = "slider",
            name = "X Position Status Bars",
            tooltip = "Adjust the horizontal position of the Major Brutality/Sorcery status bars.",
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return EWPFinder.db.locationup.x end,
            setFunc = function(value)
                EWPFinder.db.locationup.x = value
                EWPFinder:SetAppearance()
            end,
            default = 530
        },
        {
            type = "slider",
            name = "Y Position Status Bars",
            tooltip = "Adjust the vertical position of the Major Brutality/Sorcery status bars.",
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return EWPFinder.db.locationup.y end,
            setFunc = function(value)
                EWPFinder.db.locationup.y = value
                EWPFinder:SetAppearance()
            end,
            default = 626
        },
        {
            type = "slider",
            name = "Text Scale",
            tooltip = "Adjust the size of the text label (1.0 is default, 4.0 is four times larger).",
            min = 1.0,
            max = 4.0,
            step = 0.1,
            getFunc = function() return EWPFinder.db.settings.customScale end,
            setFunc = function(value)
                EWPFinder.db.settings.customScale = value
                EWPFinder:SetAppearance()
            end,
            default = 1.0,
        },
        {
            type = "editbox",
            name = "Text Color",
            tooltip = "Adjust the color of the text label using hexadecimal.",
            getFunc = function() return EWPFinder.db.settings.hexcolor end,
            setFunc = function(value)
                EWPFinder.db.settings.hexcolor = value
                EWPFinder:SetAppearance()
            end,
            default = "E58A2B",
        },
        {
            type = "editbox",
            name = "Status Bar Label Color",
            tooltip = "Adjust the color tint used for status bar labels using hexadecimal.",
            getFunc = function() return EWPFinder.db.settings.uptimecolor end,
            setFunc = function(value)
                EWPFinder.db.settings.uptimecolor = value
                EWPFinder:SetAppearance()
            end,
            default = "F2BA6A",
        },
        {
            type = "editbox",
            name = "Buff off Color",
            tooltip = "Adjust the color of the text label using hexadecimal.",
            getFunc = function() return EWPFinder.db.settings.inactivecolor end,
            setFunc = function(value)
                EWPFinder.db.settings.inactivecolor = value
                EWPFinder:SetAppearance()
            end,
            default = "C63422",
        },
        {
            type = "checkbox",
            name = "Toggle Uptime Bars",
            tooltip = "Toggle visibility of the Major Brutality/Sorcery status bars.",
            getFunc = function() return EWPFinder.db.settings.enableUp end,
            setFunc = function(value)
                EWPFinder.db.settings.enableUp = value
                EWPFinder:SetBuffAppearance(value)
            end,
            default = true,
        },

        {
            type = "checkbox",
            name = "Toggle Damage Buff",
            tooltip = "Toggle Major Brutality/Sorcery Detector",
            getFunc = function() return EWPFinder.db.settings.enablebuff end,
            setFunc = function(value)
                EWPFinder.db.settings.enablebuff = value
                EWPFinder:SetBuffAppearance(value)
            end,
            default = true,
        }
    }

    LAM:RegisterOptionControls("EWPFinderSettingsPanel", optionsData)
    if EWPFinder.isLoaded then
        EWPFinder:SetAppearance()
    end
    -- Refresh appearance on settings initialization
end
EVENT_MANAGER:RegisterForEvent("EWPFinderSettings", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == "EWPFinder" then
    if EWPFinder.isLoaded then
        EWPFinderSettings_Initialize()
    end
    end
end)
