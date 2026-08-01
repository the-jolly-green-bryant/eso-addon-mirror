---------------------------------
-- SETTINGS, GLOBALS AND DEFAULTS
---------------------------------
XYZMonitor = {
    name = "XYZMonitor",
    author = "@Duesentrieb",
    version = "20251203-0001",

    ------------------------------------------------------------
    -- FEEL FREE TO ADJUST THIS FOUR VARIABLES TO YOUR NEEDS!
    ------------------------------------------------------------
    -- 1) COLOR OF THE TEXT NOTIFICATION IN RGBA {r, g, b, a}
    -- r = red (0 to 1)
    -- g = green (0 to 1)
    -- b = blue (0 to 1)
    -- a = alpha (0 to 1)
    fontColor = {1, 1, 1, 1}, -- white
    ------------------------------------------------------------
    -- 2) FONT SIZE OF THE TEXT NOTIFICATION
    fontSize = 20,
    ------------------------------------------------------------
    -- 3) ENABLE SNAP TO HORIZONTAL / VERTICAL CENTER WHEN CLOSE
    enableSnapToGrid = true,
    ------------------------------------------------------------
    -- 4) TIME IN MS (SECONDS * 1000) TO REFRESH THE POSITION
    updateTimeMS = 1000,
    ------------------------------------------------------------
    -- BE CAREFULL WHEN CHANGING ANYTHING BELOW THIS LINE!
    ------------------------------------------------------------

    -- this is how it will look ingame
    displayText = "03.12.2025 17:37:43 Zone:1427 X:109883 Y:13899 Z:23304",
    stringZone = "Zone:0000",
    stringX = "X:000000",
    stringY = "Y:00000", -- this is "vertical" in ESO coordinates
    stringZ = "Z:000000",

    default = {
        offsetX = 0,
        offsetY = 0,
    },

    SV = {},
    SVVersion = 1,
    SVName = "XYZMonitorVariables",
}

local XYZ = XYZMonitor

local display = GetControl("XYZMonitorControl")
local label = GetControl("XYZMonitorControlLabel")
local backdrop = GetControl("XYZMonitorControlBackdrop")

--------------------------------------------
-- UPDATES POSITION, STRINGS AND DISPLAYTEXT
--------------------------------------------
function XYZ.updatePosition()
    local timeStamp = os.date("%d.%m.%Y %H:%M:%S", GetTimeStamp())

    local zone, x, y, z = GetUnitWorldPosition("player")
    if not zone then zone = 0 end
    if not x then x = 0 end
    if not y then y = 0 end
    if not z then z = 0 end

    XYZ.displayText = string.format("%s  ID:%i  X:%i  Y:%i  Z:%i", timeStamp, zone, x, y, z)

    XYZ.updateNotification()
end

--------------------------------
-- UPDATES THE NOTIFICATION TEXT
--------------------------------
function XYZ.updateNotification()
    label:SetText(XYZ.displayText)

    local r, g, b, a = unpack(XYZ.fontColor)
    label:SetColor(r, g, b, a)

    label:SetFont("$(BOLD_FONT)|" .. XYZ.fontSize .. "|soft-shadow-thin") --|soft-shadow-thick

    local width = label:GetStringWidth(label:GetText())
    local height = label:GetTextHeight()
    display:SetDimensions(width, height)
end

------------------------------
-- SNAP TO GRID AND SAVE TO SV
------------------------------
function XYZ.savePosition()
    local SNAP_THRESHOLD_DIVISOR = 20
    local centerX, centerY = display:GetCenter()

    local screenCenterX = GuiRoot:GetWidth() / 2
    local screenCenterY = GuiRoot:GetHeight() / 2

    local offsetX = centerX - screenCenterX
    local offsetY = centerY - screenCenterY

    if XYZ.enableSnapToGrid then
        if math.abs(offsetX) < GuiRoot:GetWidth() / SNAP_THRESHOLD_DIVISOR then offsetX = 0 end
        if math.abs(offsetY) < GuiRoot:GetHeight() / SNAP_THRESHOLD_DIVISOR then offsetY = 0 end
    end

    XYZ.SV.offsetX = offsetX
    XYZ.SV.offsetY = offsetY

    display:ClearAnchors()
    display:SetAnchor(CENTER, GuiRoot, CENTER, XYZ.SV.offsetX , XYZ.SV.offsetY)
end

----------------------------------------------------
-- CENTER OF THE SCREEN (SLIGHTLY OFFSET VERTICALLY)
----------------------------------------------------
function XYZ.setDefaultPosition()
    local offsetY = GuiRoot:GetHeight() / 4

    display:ClearAnchors()
    display:SetAnchor(CENTER, GuiRoot, CENTER, 0, -offsetY)

    XYZ.savePosition()
end

------------------------------------------
-- HIDES TEXT WHEN IN MENU / INVENTORY ETC
------------------------------------------
---@param _ any
---@param scene any
------------------------------------------
function XYZ.onSceneChange(_, scene)
    if scene == SCENE_SHOWN then
        display:SetHidden(false)
    else
        display:SetHidden(true)
    end
end

-----------------------
-- ENABLE EVENT_MANAGER
-----------------------
function XYZ.enableAddon()
    EVENT_MANAGER:RegisterForUpdate("XYZMonitor", XYZ.updateTimeMS, XYZ.updatePosition)
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", XYZ.onSceneChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", XYZ.onSceneChange)
end

---------------------------------------
-- INITIALIZE OF SV, DISPLAY AND ENABLE
---------------------------------------
function XYZ.initializeAddon()
    XYZ.SV = ZO_SavedVars:NewAccountWide(XYZ.SVName, XYZ.SVVersion, nil, XYZ.default)

    if (XYZ.SV.offsetX == XYZ.default.offsetX and XYZ.SV.offsetY == XYZ.default.offsetY) then
        XYZ.setDefaultPosition()
    else
        display:ClearAnchors()
        display:SetAnchor(CENTER, GuiRoot, CENTER, XYZ.SV.offsetX , XYZ.SV.offsetY)
    end

    XYZ.enableAddon()
    display:SetHidden(false)
    backdrop:SetHidden(true)
    XYZ.updateNotification()
end

-------------------------------------------------
-- EVENT MANAGER INITIAL CALL EVENT_ADD_ON_LOADED
-------------------------------------------------
---@param event any
---@param addonName any
function XYZ.onAddOnLoaded(event, addonName)
    if addonName == XYZ.name then
        XYZ.initializeAddon()

        EVENT_MANAGER:UnregisterForEvent(XYZ.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(XYZ.name, EVENT_ADD_ON_LOADED, XYZ.onAddOnLoaded)