TrackersByJH = TrackersByJH or {}
local TBJH = TrackersByJH
TBJH.name = "TrackersByJH"
TBJH.version = "1.0.3"
TBJH.menus = TBJH.menus or {}

function TrackersByJH_RegisterMenu(name, controls)
    TBJH.menus[name] = controls
end

local function BuildMainMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    LAM:RegisterAddonPanel("TrackersByJHOptions", {
        type = "panel",
        name = "Trackers by JH",
        displayName = "Trackers by JH",
        author = "JH",
        version = TBJH.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local controls = {
        { type="description", text="All JH trackers in one menu. Open the tracker you want to configure below." },
        { type="submenu", name="Bright Harbinger Tracker", controls=TBJH.menus["Bright Harbinger Tracker"] or {} },
        { type="submenu", name="Alkosh Tracker", controls=TBJH.menus["Alkosh Tracker"] or {} },
        { type="submenu", name="Warmask Tracker", controls=TBJH.menus["Warmask Tracker"] or {} },
    }
    LAM:RegisterOptionControls("TrackersByJHOptions", controls)
end

local function OnLoaded(_, addonName)
    if addonName ~= TBJH.name then return end
    EVENT_MANAGER:UnregisterForEvent(TBJH.name .. "_Main", EVENT_ADD_ON_LOADED)
    -- The three tracker handlers initialize during the same EVENT_ADD_ON_LOADED.
    -- Delay the combined LAM page so all tracker option tables have been registered first.
    zo_callLater(BuildMainMenu, 500)
end

EVENT_MANAGER:RegisterForEvent(TBJH.name .. "_Main", EVENT_ADD_ON_LOADED, OnLoaded)
