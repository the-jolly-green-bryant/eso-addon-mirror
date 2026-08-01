-- MultiMark v2.0
-- Up to 10 marker colors, multiple persistent markers per map.
--
-- Placing (console-safe, no keybinds needed):
--   * Place the game's waypoint -> colored marker (current color) saved there.
--   * Press the waypoint button again on the SAME spot -> marker cycles to the
--     next color. Keep pressing to cycle through all 10; it wraps around.
--   * /mmk -> drop a marker at your feet in the current color.
--
-- Color control:
--   * /mmk color <1-10>   * /mmk next   * /mmk prev
--   * PC: bind "Color 1..10" / "Next/Prev color" under Controls -> Add-Ons
--     (0-9 keys work well for the ten direct-color binds).

local ADDON_NAME = "MultiMark"
local PIN_PREFIX = "MultiMark_pin_"   -- 10 pin types: MultiMark_pin_1 .. _10

local COLORS = {
    { name = "Red",    r = 0.90, g = 0.15, b = 0.15 },
    { name = "Orange", r = 1.00, g = 0.55, b = 0.10 },
    { name = "Yellow", r = 1.00, g = 0.90, b = 0.20 },
    { name = "Green",  r = 0.20, g = 0.85, b = 0.25 },
    { name = "Cyan",   r = 0.15, g = 0.85, b = 0.90 },
    { name = "Blue",   r = 0.25, g = 0.45, b = 1.00 },
    { name = "Purple", r = 0.60, g = 0.30, b = 0.95 },
    { name = "Pink",   r = 1.00, g = 0.45, b = 0.80 },
    { name = "White",  r = 0.95, g = 0.95, b = 0.95 },
    { name = "Gray",   r = 0.45, g = 0.45, b = 0.45 },
}

local defaults = {
    markers         = {},   -- [mapKey] = { {x=,y=,label=,c=}, ... }
    captureWaypoint = true,
    currentColor    = 1,
    maxPerMap       = 50,
    pinSize         = 32,
    -- repeat-ping cycling: press waypoint again this close, this soon -> cycle
    cycleEpsilon    = 0.006,
    cycleSeconds    = 6,
    debug           = false,
}
local sv
local lastPlaced = nil   -- { mapKey=, index=, at= } for repeat-ping cycling

local function Dbg(msg) if sv and sv.debug then d("|cFFD700[MultiMark]|r " .. msg) end end
local function Msg(msg) d("|cFFD700[MultiMark]|r " .. msg) end

local function ColorName(c)
    local col = COLORS[c] or COLORS[1]
    return string.format("|c%02X%02X%02X%s|r",
        col.r * 255, col.g * 255, col.b * 255, col.name)
end

local function MapKey() return GetMapTileTexture() or "?" end

local function MarkersHere()
    sv.markers[MapKey()] = sv.markers[MapKey()] or {}
    return sv.markers[MapKey()]
end

local function RefreshAllPins()
    if not ZO_WorldMap_RefreshCustomPinsOfType then return end
    for c = 1, #COLORS do
        local id = _G[PIN_PREFIX .. c]
        if id then ZO_WorldMap_RefreshCustomPinsOfType(id) end
    end
end

-- ---------------------------------------------------------------------------
-- Color selection
-- ---------------------------------------------------------------------------
function MultiMark_SetColor(c)
    if not COLORS[c] then return end
    sv.currentColor = c
    Msg("Color: " .. ColorName(c))
end

function MultiMark_CycleColor(step)
    local c = ((sv.currentColor - 1 + step) % #COLORS) + 1
    MultiMark_SetColor(c)
end

-- ---------------------------------------------------------------------------
-- Markers
-- ---------------------------------------------------------------------------
local function AddMarker(x, y)
    local list = MarkersHere()
    if #list >= (sv.maxPerMap or defaults.maxPerMap) then
        Msg("Marker limit reached on this map. /mmk clearmap to reset.")
        return
    end
    local c = sv.currentColor or 1
    list[#list + 1] = { x = x, y = y, c = c, label = COLORS[c].name .. " marker" }
    lastPlaced = { mapKey = MapKey(), index = #list, at = GetTimeStamp() }
    Msg(string.format("Added %s (%d on this map)", ColorName(c), #list))
    RefreshAllPins()
end

-- Repeat-ping on the same spot cycles the just-placed marker's color
local function TryCycleExisting(x, y)
    if not lastPlaced or lastPlaced.mapKey ~= MapKey() then return false end
    if GetTimeStamp() - lastPlaced.at > (sv.cycleSeconds or 6) then return false end
    local m = MarkersHere()[lastPlaced.index]
    if not m then return false end
    local eps = sv.cycleEpsilon or defaults.cycleEpsilon
    if zo_abs(m.x - x) > eps or zo_abs(m.y - y) > eps then return false end

    m.c = (m.c % #COLORS) + 1
    m.label = COLORS[m.c].name .. " marker"
    sv.currentColor = m.c
    lastPlaced.at = GetTimeStamp()
    Msg("Marker color -> " .. ColorName(m.c))
    RefreshAllPins()
    return true
end

-- ---------------------------------------------------------------------------
-- Waypoint capture
-- ---------------------------------------------------------------------------
local function OnMapPing(_, pingEventType, pingType, pingTag, x, y, isPingOwner)
    Dbg(string.format("ping event=%s type=%s tag=%s x=%.4f y=%.4f owner=%s",
        tostring(pingEventType), tostring(pingType), tostring(pingTag),
        x or -1, y or -1, tostring(isPingOwner)))

    if not sv.captureWaypoint then return end
    if isPingOwner == false then return end
    if pingEventType ~= PING_EVENT_ADDED then return end
    if pingType ~= MAP_PIN_TYPE_PLAYER_WAYPOINT and pingType ~= MAP_PIN_TYPE_RALLY_POINT then return end
    if not x or not y or (x == 0 and y == 0) then return end

    if not TryCycleExisting(x, y) then
        AddMarker(x, y)
    end
end

-- ---------------------------------------------------------------------------
-- Pin rendering: self-drawn controls on the world map (HarvestMap-style).
-- The stock custom-pin API doesn't render on console, so we draw our own
-- texture controls anchored to the map container instead.
-- ---------------------------------------------------------------------------
local pinContainer = nil
local controlPool  = {}   -- reusable CT_TEXTURE controls
local usedControls = 0
local lastW, lastH = 0, 0

local PIN_TEXTURE = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds"

local function AcquireControl()
    usedControls = usedControls + 1
    local ctrl = controlPool[usedControls]
    if not ctrl then
        ctrl = WINDOW_MANAGER:CreateControl(nil, pinContainer, CT_TEXTURE)
        ctrl:SetTexture(PIN_TEXTURE)
        ctrl:SetDrawLevel(5)
        controlPool[usedControls] = ctrl
    end
    ctrl:SetHidden(false)
    return ctrl
end

local function HideAllControls()
    for i = 1, #controlPool do controlPool[i]:SetHidden(true) end
    usedControls = 0
end

local function RedrawPins()
    if not pinContainer then return end
    HideAllControls()
    if not sv then return end

    local list = sv.markers[MapKey()]
    if not list or #list == 0 then return end

    local w, h = ZO_WorldMapContainer:GetDimensions()
    if not w or w <= 0 then return end
    lastW, lastH = w, h

    local size = sv.pinSize or defaults.pinSize
    for i, m in ipairs(list) do
        local col = COLORS[m.c or 1] or COLORS[1]
        local ctrl = AcquireControl()
        ctrl:SetDimensions(size, size)
        ctrl:SetColor(col.r, col.g, col.b, 1)
        ctrl:ClearAnchors()
        ctrl:SetAnchor(CENTER, pinContainer, TOPLEFT, m.x * w, m.y * h)
    end
    Dbg(string.format("drew %d markers on %s (%dx%d)", #list, MapKey(), w, h))
end

local function RegisterPinRendering()
    if not ZO_WorldMapContainer then
        Msg("DIAG: ZO_WorldMapContainer missing - cannot draw markers.")
        return
    end
    pinContainer = WINDOW_MANAGER:CreateControl("MultiMark_Container", ZO_WorldMapContainer, CT_CONTROL)
    pinContainer:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)
    pinContainer:SetDimensions(1, 1)   -- children are anchored by offset; size irrelevant

    -- redraw when the map changes (same hook HarvestMap uses)
    ZO_PreHook("ZO_WorldMap_UpdateMap", function() zo_callLater(RedrawPins, 20) end)

    -- catch zoom / resize: cheap dimension check while the map is visible
    pinContainer:SetHandler("OnUpdate", function()
        if ZO_WorldMapContainer:IsHidden() then return end
        local w, h = ZO_WorldMapContainer:GetDimensions()
        if w ~= lastW or h ~= lastH then RedrawPins() end
    end)
end

local function RefreshAllPins() RedrawPins() end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/mmk"] = function(args)
        args = zo_strtrim(args or "")
        if args == "" then
            local x, y = GetMapPlayerPosition("player")
            if x then
                if not TryCycleExisting(x, y) then AddMarker(x, y) end
            end
            return
        end
        local cmd, rest = args:match("^(%S+)%s*(.*)$")
        cmd = zo_strlower(cmd)

        if cmd == "color" then
            local n = tonumber(rest)
            if n and COLORS[n] then MultiMark_SetColor(n)
            else Msg("Usage: /mmk color <1-10>") end
        elseif cmd == "next" then MultiMark_CycleColor(1)
        elseif cmd == "prev" then MultiMark_CycleColor(-1)
        elseif cmd == "colors" then
            for i in ipairs(COLORS) do Msg(i .. ". " .. ColorName(i)) end
        elseif cmd == "capture" then
            sv.captureWaypoint = not sv.captureWaypoint
            Msg("Waypoint capture: " .. (sv.captureWaypoint and "ON" or "OFF"))
        elseif cmd == "list" then
            local list = MarkersHere()
            if #list == 0 then Msg("No markers on this map.") return end
            for i, m in ipairs(list) do
                Msg(string.format("%d. %s (%.1f%%, %.1f%%)", i, ColorName(m.c or 1), m.x * 100, m.y * 100))
            end
        elseif cmd == "del" then
            local n = tonumber(rest)
            local list = MarkersHere()
            if n and list[n] then
                table.remove(list, n)
                if lastPlaced and lastPlaced.index == n then lastPlaced = nil end
                Msg("Removed marker " .. n)
                RefreshAllPins()
            else
                Msg("Usage: /mmk del <number>  (see /mmk list)")
            end
        elseif cmd == "clearmap" then
            sv.markers[MapKey()] = {}; lastPlaced = nil
            Msg("Cleared markers on this map."); RefreshAllPins()
        elseif cmd == "clearall" then
            sv.markers = {}; lastPlaced = nil
            Msg("Cleared all markers everywhere."); RefreshAllPins()
        elseif cmd == "debug" then
            sv.debug = not sv.debug; Msg("debug=" .. tostring(sv.debug))
        else
            Msg("/mmk | color <1-10> | next | prev | colors | capture | list | del <n> | clearmap | clearall | debug")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Optional LAM panel
-- ---------------------------------------------------------------------------
local panelBuilt = false
local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end
    panelBuilt = true

    local colorNames = {}
    for i, c in ipairs(COLORS) do colorNames[i] = c.name end

    LAM:RegisterAddonPanel("MultiMarkPanel", {
        type = "panel", name = "MultiMark",
        author = "@Dicen95728", version = "3.0", registerForRefresh = true,
    })
    LAM:RegisterOptionControls("MultiMarkPanel", {
        { type = "dropdown", name = "Current marker color",
          choices = colorNames,
          getFunc = function() return COLORS[sv.currentColor].name end,
          setFunc = function(v)
              for i, c in ipairs(COLORS) do if c.name == v then MultiMark_SetColor(i) end end
          end },
        { type = "checkbox", name = "Placing a waypoint also drops a marker",
          getFunc = function() return sv.captureWaypoint end,
          setFunc = function(v) sv.captureWaypoint = v end },
        { type = "slider", name = "Max markers per map", min = 10, max = 200, step = 10,
          getFunc = function() return sv.maxPerMap end,
          setFunc = function(v) sv.maxPerMap = v end },
        { type = "button", name = "Clear markers on current map",
          func = function() sv.markers[MapKey()] = {}; lastPlaced = nil; RefreshAllPins() end },
        { type = "button", name = "Clear ALL markers",
          func = function() sv.markers = {}; lastPlaced = nil; RefreshAllPins() end },
    })
end

-- ---------------------------------------------------------------------------
-- Keybind display names
-- ---------------------------------------------------------------------------
for i = 1, 10 do
    ZO_CreateStringId("SI_BINDING_NAME_MULTIMARK_COLOR_" .. i, "Select Color " .. i)
end
ZO_CreateStringId("SI_BINDING_NAME_MULTIMARK_NEXT_COLOR", "Next Marker Color")
ZO_CreateStringId("SI_BINDING_NAME_MULTIMARK_PREV_COLOR", "Previous Marker Color")

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("MultiMarkSV", 1, nil, defaults)
    if type(sv.markers) ~= "table" then sv.markers = {} end
    if not COLORS[sv.currentColor or 0] then sv.currentColor = 1 end

    RegisterPinRendering()
    RegisterSlash()
    BuildSettingsPanel()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAP_PING, OnMapPing)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
        if not panelBuilt then BuildSettingsPanel() end
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
