------------------------------------------------
-- XAM's Toolbox for Elder Scrolls Online
------------------------------------------------

XAM = {
    name            = "XAMToolbox",
    title           = "XAM's Toolbox",
    version         = "1.0.1",
    author          = "XAM",
    prefix          = "|cFF9900[XT]|r ",
    m               = {},
    d               = {},
    s               = {},
    o               = {},
}

local function OnAddOnLoaded(event, addonName)
    if addonName ~= XAM.name then return end

    XAM:loadSettings()
    XAM:loadModules()

    EVENT_MANAGER:UnregisterForEvent(XAM.name, EVENT_ADD_ON_LOADED)
end

-- Framework
function XAM:registerModule(module)
    XAM.m[#XAM.m + 1] = module
end
function XAM:loadModules()
    for _,module in ipairs(XAM.m) do
        XAM[module]()
    end
end

function XAM:loadSettings()
    XAM.d.debug = false
    XAM.s = ZO_SavedVars:NewAccountWide("XAMToolboxSettings", 1, nil, XAM.d)

    local panelData = {
        type                = "panel",
        name                = XAM.title,
        displayName         = XAM.title,
        author              = XAM.author,
        version             = XAM.version,
        slashCommand        = "/xtb",
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    XAM.o[#XAM.o + 1] = {
        type = "checkbox",
        name = "Debug",
        getFunc = function() return XAM.s.debug end,
        setFunc = function(value) XAM.s.debug = value end,
        default = XAM.d.debug,
        width = "full",
    }

    local LAM2 = LibAddonMenu2
    LAM2:RegisterAddonPanel(XAM.name, panelData)
    LAM2:RegisterOptionControls(XAM.name, XAM.o)
end

-- Useful Functions
function isEmpty(s)
    return s == nil or s == ''
end

-- Listen for addon to load
EVENT_MANAGER:RegisterForEvent(XAM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)