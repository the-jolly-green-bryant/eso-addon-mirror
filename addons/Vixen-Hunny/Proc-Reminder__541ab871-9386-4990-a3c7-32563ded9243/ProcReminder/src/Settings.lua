ProcReminder = ProcReminder or {}
ProcReminder.name = "ProcReminder"
ProcReminder.version = "1.0.0"
ProcReminder.author = "Vixen Hunny"
ProcReminder.Data = ProcReminder.Data or {}
ProcReminder.Data.AbilityData = ProcReminder.Data.AbilityData or {}
local em = EVENT_MANAGER
local LAM = LibAddonMenu2
ProcReminder.defaults = {
    primColor      = {r = 1, g = 0.7, b = 0},   -- Gold
    secColor       = {r = 1, g = 1,   b = 1},   -- White
    statusBarColor = {r = 1, g = 0.5, b = 0},   -- Molten orange
    posX     = 0,
    posY     = -150,
    fontSize = 30,
    iconSize = 80,
    uiScale  = 1.0,
}
function ProcReminder:CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Proc Reminder",
        displayName = "Proc Reminder",
        author = "Vixen Hunny",
        version = ProcReminder.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ProcReminder.name.."Panel", panelData)
    local optionsData = {
        {
            type = "colorpicker",
            name = "Primary Color",
            tooltip = "Choose the primary color for the proc reminder text.",
            getFunc = function() return ProcReminder.settings.primColor.r, ProcReminder.settings.primColor.g, ProcReminder.settings.primColor.b end,
            setFunc = function(r, g, b) ProcReminder.settings.primColor = {r = r, g = g, b = b} end,
    },
    {
        type = "colorpicker",
        name = "Secondary Color",
        tooltip = "Choose the secondary color for the proc reminder text.",
        getFunc = function() return ProcReminder.settings.secColor.r, ProcReminder.settings.secColor.g, ProcReminder.settings.secColor.b end,
        setFunc = function(r, g, b) ProcReminder.settings.secColor = {r = r, g = g, b = b} end,
    },
    {
        type = "colorpicker",
        name = "Status Bar Color",
        tooltip = "Choose the color for the animated status bar display.",
        getFunc = function() return ProcReminder.settings.statusBarColor.r, ProcReminder.settings.statusBarColor.g, ProcReminder.settings.statusBarColor.b end,
        setFunc = function(r, g, b) ProcReminder.settings.statusBarColor = {r = r, g = g, b = b} end,
    },
    {
        type = "header",
        name = "Layout",
    },
    {
        type = "slider",
        name = "Font Size",
        tooltip = "Size of the proc name text.",
        min = 14, max = 64, step = 1,
        getFunc = function() return ProcReminder.settings.fontSize end,
        setFunc = function(v) ProcReminder.settings.fontSize = v; ProcReminder.UI:ApplySettings() end,
    },
    {
        type = "slider",
        name = "Icon Size",
        tooltip = "Size of the ability icon.",
        min = 32, max = 128, step = 2,
        getFunc = function() return ProcReminder.settings.iconSize end,
        setFunc = function(v) ProcReminder.settings.iconSize = v; ProcReminder.UI:ApplySettings() end,
    },
    {
        type = "slider",
        name = "UI Scale",
        tooltip = "Overall scale of the proc reminder.",
        min = 50, max = 200, step = 5,
        getFunc = function() return math.floor((ProcReminder.settings.uiScale or 1.0) * 100) end,
        setFunc = function(v) ProcReminder.settings.uiScale = v / 100; ProcReminder.UI:ApplySettings() end,
    },
    {
        type = "slider",
        name = "Position X",
        tooltip = "Horizontal offset from screen center.",
        min = -800, max = 800, step = 1,
        getFunc = function() return ProcReminder.settings.posX end,
        setFunc = function(v) ProcReminder.settings.posX = v; ProcReminder.UI:ApplySettings() end,
    },
    {
        type = "slider",
        name = "Position Y",
        tooltip = "Vertical offset from screen center. Negative = up.",
        min = -500, max = 500, step = 1,
        getFunc = function() return ProcReminder.settings.posY end,
        setFunc = function(v) ProcReminder.settings.posY = v; ProcReminder.UI:ApplySettings() end,
    },
}
    LAM:RegisterOptionControls(ProcReminder.name.."Panel", optionsData)
end