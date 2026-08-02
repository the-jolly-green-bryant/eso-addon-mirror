local LAM = LibAddonMenu2
Puma = Puma or {}
Puma.isLoaded = Puma.isLoaded or false
PumaSettings = PumaSettings or {}
local function PumaSettings_isEnabled()
    if Puma.db.enableUptime then
        return false
    else
        return true
    end
end
local function PumaSettings_Initialize()
    local panelData = {
        type = "panel",
        name = "Puma",
        displayName = "Puma Settings",
        author = "Pixelles",
        version = Puma.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    PumaSettings.settingsPanel = LAM:RegisterAddonPanel("PumaPanel", panelData)
    Puma.db = ZO_SavedVars:New("PumaSettings", 2, nil, Puma.defaults_db)
    local optionsData = {
        {
            type = "slider",
            name = "X Position Container",
            tooltip = "Adjust the horizontal position of the text label (moves right as value increases).",
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 2,
            getFunc = function() return Puma.db.x  end,
            setFunc = function(value)
                Puma.db.x = value
                Puma:SetAppearance()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Y Position Container",
            tooltip = "Adjust the vertical position of the text label (moves down as value increases).",
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 2,
            getFunc = function() return Puma.db.y end,
            setFunc = function(value)
                Puma.db.y = value
                Puma:SetAppearance()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Text Scale",
            tooltip = "Adjust the size of the text label (1.0 is default, 4.0 is four times larger).",
            min = 1.0,
            max = 10.0,
            step = 0.01,
            getFunc = function() return Puma.db.scale end,
            setFunc = function(value)
                Puma.db.scale = value
                Puma:SetAppearance()
            end,
            default = 1.0,
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Adjust the font size of the text label.",
            min = 10,
            max = 100,
            step = 1,
            getFunc = function() return Puma.db.fontSize end,
            setFunc = function(value)
                Puma.db.fontSize = value
                Puma:SetAppearance()
            end,
            default = 24,
        },
        {
            type = "editbox",
            name = "Text Color",
            tooltip = "Adjust the color of the text label using hexadecimal.",
            getFunc = function() return Puma.db.hexcolor end,
            setFunc = function(value)
                Puma.db.hexcolor = value
                Puma:SetAppearance()
            end,
            default = "3CB043",
        },
        {
            type = "checkbox",
            name = "Toggle Brutality/Sorcery Detector",
            tooltip = "Toggle Major Brutality/Sorcery Detector",
            getFunc = function() return Puma.db.brutalityAlert end,
            setFunc = function(value)
                Puma.db.brutalityAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Minor Courage Detector",
            tooltip = "Toggle Minor Courage Detector",
            getFunc = function() return Puma.db.minorCourageAlert end,
            setFunc = function(value)
                Puma.db.minorCourageAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Minor Mending Detector",
            tooltip = "Toggle Minor Mending Detector",
            getFunc = function() return Puma.db.minorMendingAlert end,
            setFunc = function(value)
                Puma.db.minorMendingAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Minor Resolve Detector",
            tooltip = "Toggle Minor Resolve Detector",
            getFunc = function() return Puma.db.minorResolveAlert end,
            setFunc = function(value)
                Puma.db.minorResolveAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Major Courage Detector",
            tooltip = "Toggle Major Courage Detector",
            getFunc = function() return Puma.db.courageAlert end,
            setFunc = function(value)
                Puma.db.courageAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Major Mending Detector",
            tooltip = "Toggle Major Mending Detector",
            getFunc = function() return Puma.db.mendingAlert end,
            setFunc = function(value)
                Puma.db.mendingAlert = value
            end,
            default = true
        },
        {
            type = "checkbox",
            name = "Toggle Major Resolve Detector",
            tooltip = "Toggle Major Resolve Detector",
            getFunc = function() return Puma.db.resolveAlert end,
            setFunc = function(value)
                Puma.db.resolveAlert = value
            end,
            default = true
        },
        {
            type = "header",
            name = "Uptimes",
        },
        {
            type = "checkbox",
            name = "Toggle Uptime Bar",
            tooltip = "Show or hide the Srendarr-style uptime status bar.",
            getFunc = function() return Puma.db.enableUptime end,
            setFunc = function(value)
                Puma.db.enableUptime = value
            end,
            default = true
        },
        {
            type = "dropdown",
            name = "Choose what uptime to monitor",
            choices = Puma.db.data,
            choicesValues = Puma.db.data,
            getFunc = function() return Puma.db.selection end,
            setFunc = function(value) 
                Puma.db.selection = value
            end,
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
        {
            type = "editbox",
            name = "Bar Color",
            tooltip = "Adjust the fill color of the uptime bar using hexadecimal.",
            getFunc = function() return Puma.db.uptimeColor end,
            setFunc = function(value)
                Puma.db.uptimeColor = value
                Puma:SetAppearance()
            end,
            default = "FF6A00",
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
        {
            type = "slider",
            name = "X Position Uptime Bar",
            tooltip = "Adjust the horizontal position of the uptime bar.",
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return Puma.db.notifx end,
            setFunc = function(value)
                Puma.db.notifx = value
                Puma:SetAppearance()
            end,
            default = 0,
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
        {
            type = "slider",
            name = "Y Position Uptime Bar",
            tooltip = "Adjust the vertical position of the uptime bar.",
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return Puma.db.notify end,
            setFunc = function(value)
                Puma.db.notify = value
                Puma:SetAppearance()
            end,
            default = 0,
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
        {
            type = "slider",
            name = "Uptime Bar Width",
            tooltip = "Adjust the width of the uptime status bar.",
            min = 120,
            max = 700,
            step = 2,
            getFunc = function() return Puma.db.barWidth end,
            setFunc = function(value)
                Puma.db.barWidth = value
                Puma:SetAppearance()
            end,
            default = 340,
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
        {
            type = "slider",
            name = "Uptime Bar Height",
            tooltip = "Adjust the height of the uptime status bar.",
            min = 10,
            max = 50,
            step = 1,
            getFunc = function() return Puma.db.barHeight end,
            setFunc = function(value)
                Puma.db.barHeight = value
                Puma:SetAppearance()
            end,
            default = 24,
            disabled = function ()
                return not Puma.db.enableUptime
            end
        },
    }

    LAM:RegisterOptionControls("PumaPanel", optionsData)
    if Puma.isLoaded then
        Puma:SetAppearance()
    end
    -- Refresh appearance on settings initialization
end
EVENT_MANAGER:RegisterForEvent("PumaSettings", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == "Puma" then
    if Puma.isLoaded then
        PumaSettings_Initialize()
    end
    end
end)
