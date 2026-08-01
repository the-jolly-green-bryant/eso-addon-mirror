--[[----------------------------------------------------------------------
    Dynamic Encounters : HUD panel
    Built entirely in code on our own TopLevelControl; never re-anchors or
    hooks any ZOS control, so it coexists peacefully with map/UI addons.
----------------------------------------------------------------------]]--

local HE = DynamicEncounters

local PANEL_WIDTH   = 300

-- DIAGNOSTIC MARKER: If you see DE-UI-v2 in chat but also old errors, two copies are loading.
if d and DynamicEncounters.sv and DynamicEncounters.sv.debugMode then d('[DE-UI-v2] DynamicEncountersUI LOADED') end

local ROW_HEIGHT    = 68
local ROW_COMPACT   = 28
local HEADER_HEIGHT = 26
local DISCLAIMER_HEIGHT = 16
local COLLAPSED_HEADER_H = 24
local PADDING       = 8
local ICON_SIZE     = 24
local UPDATE_PERIOD = 0.50 -- seconds (balanced: responsive timers without excess CPU)

HE.THEMES = {
    dark = {
        bg        = { 0.06, 0.07, 0.10 },
        border    = { 0.25, 0.55, 0.80, 0.9 },
        title     = { 0.40, 0.80, 1.00 },
        name      = { 0.92, 0.92, 0.92 },
        zone      = { 0.70, 0.72, 0.78 },
        live      = { 0.35, 1.00, 0.55 },
        soon      = { 1.00, 0.82, 0.30 },
        overdue   = { 1.00, 0.55, 0.30 },
        unknown   = { 0.55, 0.55, 0.58 },
        timer     = { 0.75, 0.78, 0.85 },
        here      = { 0.40, 0.80, 1.00 },
    },
    light = {
        bg        = { 0.92, 0.92, 0.90 },
        border    = { 0.30, 0.45, 0.60, 0.9 },
        title     = { 0.10, 0.35, 0.55 },
        name      = { 0.10, 0.10, 0.12 },
        zone      = { 0.25, 0.27, 0.32 },
        live      = { 0.05, 0.55, 0.20 },
        soon      = { 0.70, 0.50, 0.00 },
        overdue   = { 0.80, 0.30, 0.05 },
        unknown   = { 0.45, 0.45, 0.48 },
        timer     = { 0.30, 0.32, 0.40 },
        here      = { 0.10, 0.40, 0.65 },
    },
}

-- ordered list of customizable color slots (key, needsAlpha)
HE.THEME_SLOTS = {
    { key = "bg",      alpha = false },
    { key = "border",  alpha = true  },
    { key = "title",   alpha = false },
    { key = "name",    alpha = false },
    { key = "zone",    alpha = false },
    { key = "timer",   alpha = false },
    { key = "live",    alpha = false },
    { key = "soon",    alpha = false },
    { key = "overdue", alpha = false },
    { key = "unknown", alpha = false },
    { key = "here",    alpha = false },
}

local function CopyColor(c)
    return { c[1], c[2], c[3], c[4] }
end

function HE.GetDefaultCustomColors()
    local out = {}
    for _, slot in ipairs(HE.THEME_SLOTS) do
        out[slot.key] = CopyColor(HE.THEMES.dark[slot.key])
    end
    return out
end


local panel, rows, titleLabel, stepLabel, disclaimerLabel
local refreshPending = true
local combatHidden = false
local nextUpdate = 0

local function Theme()
    if HE.sv.theme == "custom" then
        local base, custom = HE.THEMES.dark, HE.sv.customColors or {}
        local merged = {}
        for _, slot in ipairs(HE.THEME_SLOTS) do
            merged[slot.key] = custom[slot.key] or base[slot.key]
        end
        return merged
    end
    return HE.THEMES[HE.sv.theme] or HE.THEMES.dark
end

-- ---------------------------------------------------------------------
-- construction
-- ---------------------------------------------------------------------

local function CreateRow(parent, index)
    local row = CreateControl("$(parent)Row" .. index, parent, CT_CONTROL)
    local contentW = PANEL_WIDTH - 2 * PADDING
    local textX = ICON_SIZE + 6
    local textW = contentW - textX
    row:SetDimensions(contentW, ROW_HEIGHT)

    row.icon = CreateControl("$(parent)Icon", row, CT_TEXTURE)
    row.icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    row.icon:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 4)

    -- Line 1: Encounter name (bold) Ã¢â‚¬â€ explicit dimensions, no dual anchors
    row.name = CreateControl("$(parent)Name", row, CT_LABEL)
    row.name:SetFont("ZoFontGameBold")
    row.name:SetDimensions(textW, 20)
    row.name:SetAnchor(TOPLEFT, row, TOPLEFT, textX, 2)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.name:SetVerticalAlignment(TEXT_ALIGN_TOP)

    -- Line 2: Zone name (prominent Ã¢â‚¬â€ upgraded from ZoFontGameSmall to ZoFontGame)
    row.zone = CreateControl("$(parent)Zone", row, CT_LABEL)
    row.zone:SetFont("ZoFontGame")
    row.zone:SetDimensions(textW, 20)
    row.zone:SetAnchor(TOPLEFT, row, TOPLEFT, textX, 24)
    row.zone:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.zone:SetVerticalAlignment(TEXT_ALIGN_TOP)

    -- Line 3: Status (bold, left) + Timer (small, right) Ã¢â‚¬â€ absolute Y positions
    row.status = CreateControl("$(parent)Status", row, CT_LABEL)
    row.status:SetFont("ZoFontGameBold")
    row.status:SetDimensions(math.floor(textW * 0.60), 18)
    row.status:SetAnchor(TOPLEFT, row, TOPLEFT, textX, 48)
    row.status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.status:SetVerticalAlignment(TEXT_ALIGN_TOP)

    row.timer = CreateControl("$(parent)Timer", row, CT_LABEL)
    row.timer:SetFont("ZoFontGameSmall")
    row.timer:SetDimensions(math.floor(textW * 0.40), 18)
    row.timer:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 48)
    row.timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.timer:SetVerticalAlignment(TEXT_ALIGN_TOP)

    -- Wayshrine/Map button: opens world map to this zone
    -- Uses row.zoneId (set by UI_Initialize) to avoid upvalue capture bugs
    row.travel = CreateControl("$(parent)Travel", row, CT_BUTTON)
    row.travel:SetDimensions(28, 28)
    row.travel:SetAnchor(RIGHT, row, RIGHT, -2, 0)
    row.travel:SetNormalTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    row.travel:SetMouseOverTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    row.travel:SetPressedTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    row.travel:SetEnabled(true)
    row.travel:SetMouseEnabled(true)
    row.travel:SetHandler("OnClicked", function()
        if not row.zoneId then return end
        -- Block during combat: ESO disables map/fast-travel in combat
        if IsUnitInCombat("player") then
            ZO_Tooltips_ShowTextTooltip(row.travel, TOP, "Cannot travel during combat")
            return
        end
        HE.OpenMapToZone(row.zoneId)
    end)
    row.travel:SetHandler("OnMouseEnter", function()
        if row.zoneId then
            ZO_Tooltips_ShowTextTooltip(row.travel, TOP, "Open map to " .. HE.GetZoneName(row.zoneId))
        end
    end)
    row.travel:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- Clock button: track encounter respawn via prediction-linked timer
    row.clockBtn = CreateControl("$(parent)Clock", row, CT_BUTTON)
    row.clockBtn:SetDimensions(22, 22)
    row.clockBtn:SetAnchor(RIGHT, row.travel, LEFT, -4, 3)
    row.clockBtn:SetFont("ZoFontGameSmall")
    row.clockBtn:SetText("T")
    row.clockBtn:SetHandler("OnClicked", function()
        if not row.zoneId then return end
        DynamicEncounters.Timers.TrackEncounter(row.zoneId)
    end)
    row.clockBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        if row.zoneId then
            ZO_Tooltips_ShowTextTooltip(row.clockBtn, TOP,
                "Track " .. HE.GetEncounterName(row.zoneId) .. " respawn timer")
        end
    end)
    row.clockBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    return row
end

function HE.UI_Initialize()
    panel = CreateTopLevelWindow("DynamicEncountersPanel")
    panel:SetClampedToScreen(true)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetDrawLayer(DL_CONTROLS)
    panel:SetDrawTier(DT_LOW)

    panel.bg = CreateControl("$(parent)Bg", panel, CT_BACKDROP)
    panel.bg:SetAnchorFill(panel)
    panel.bg:SetEdgeTexture("", 1, 1, 1)

    titleLabel = CreateControl("$(parent)Title", panel, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH4")
    titleLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, PADDING, 5)
    titleLabel:SetText(HE.GetString("PANEL_TITLE"))

    -- Collapse/expand toggle button (top-right corner)
    panel.collapseBtn = CreateControl("$(parent)Collapse", panel, CT_BUTTON)
    panel.collapseBtn:SetFont("ZoFontGame")
    panel.collapseBtn:SetDimensions(20, 20)
    panel.collapseBtn:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -PADDING, 3)
    panel.collapseBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    panel.collapseBtn:SetText(HE.sv.collapsed and "+" or "-")
    panel.collapseBtn:SetHandler("OnClicked", function()
        -- Do nothing when fully minimized (state changes would be invisible)
        if HE.sv.minimized then return end
        HE.sv.collapsed = not HE.sv.collapsed
        panel.collapseBtn:SetText(HE.sv.collapsed and "+" or "-")
        refreshPending = true
    end)
    panel.collapseBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        ZO_Tooltips_ShowTextTooltip(panel.collapseBtn, TOP, HE.sv.collapsed and "Expand panel" or "Collapse panel")
    end)
    panel.collapseBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- Full minimize button: to the LEFT of collapse button
    -- Shrinks panel to just the header bar (title + buttons)
    panel.minimizeBtn = CreateControl("$(parent)Minimize", panel, CT_BUTTON)
    panel.minimizeBtn:SetFont("ZoFontGame")
    panel.minimizeBtn:SetDimensions(20, 20)
    panel.minimizeBtn:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -PADDING - 22, 3)
    panel.minimizeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    panel.minimizeBtn:SetText(HE.sv.minimized and "v" or "^")
    panel.minimizeBtn:SetHandler("OnClicked", function()
        HE.sv.minimized = not HE.sv.minimized
        local lbl = panel.minimizeBtn:GetLabelControl()
        if lbl then lbl:SetText(HE.sv.minimized and "v" or "^") end
        refreshPending = true
    end)
    panel.minimizeBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        ZO_Tooltips_ShowTextTooltip(panel.minimizeBtn, TOP, HE.sv.minimized and "Restore panel" or "Minimize to header")
    end)
    panel.minimizeBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- Timer button: creates a new floating countdown timer widget
    panel.timerBtn = CreateControl("$(parent)Timer", panel, CT_BUTTON)
    panel.timerBtn:SetFont("ZoFontGame")
    panel.timerBtn:SetDimensions(20, 20)
    panel.timerBtn:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -PADDING - 88, 3)
    panel.timerBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    panel.timerBtn:SetText("T")
    panel.timerBtn:SetHandler("OnClicked", function()
        HE.Timers.CreateTimer()
    end)
    panel.timerBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        ZO_Tooltips_ShowTextTooltip(panel.timerBtn, TOP, "New countdown timer (right-click label to rename, shift+right-click to set duration)")
    end)
    panel.timerBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- Wayshrine button: assignable persistent wayshrine shortcut
    -- Right-click to assign a wayshrine via the picker; left-click to
    -- open the map to that wayshrine's zone.  Persists through reloads.
        -- Wayshrine button: assignable persistent wayshrine shortcut.
    -- Uses OnMouseUp (like custom timer WS buttons) so shift/button
    -- detection works reliably via handler parameters rather than
    -- polling IsShiftKeyDown() which can race with OnClicked.
    --
    -- SHIFT+LEFT  = assign nearest wayshrine
    -- SHIFT+RIGHT = open searchable wayshrine picker
    -- LEFT        = open map to wayshrine zone
    -- RIGHT       = fast travel with cost confirmation
    panel.wsBtn = CreateControl("$(parent)Wayshrine", panel, CT_BUTTON)
    panel.wsBtn:SetDimensions(22, 22)
    panel.wsBtn:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -PADDING - 66, 3)
    panel.wsBtn:SetNormalTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    panel.wsBtn:SetMouseOverTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    panel.wsBtn:SetPressedTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    panel.wsBtn:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift)
        if not upInside then return end
        local hw = HE.sv.headerWayshrine
        local T = DynamicEncounters.Timers

        -- SHIFT+LEFT: assign nearest discovered wayshrine
        if shift and button == MOUSE_BUTTON_INDEX_LEFT then
            local nearest = T.FindNearestWayshrine()
            if nearest and nearest.index then
                hw.nodeIndex = nearest.index
                hw.zoneId    = nearest.zoneId
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    zo_strformat("Header wayshrine set to <<1>>", nearest.name))
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    "No discovered wayshrine nearby")
            end
            return
        end

        -- SHIFT+RIGHT: open searchable wayshrine picker
        if shift and button == MOUSE_BUTTON_INDEX_RIGHT then
            T.ShowWayshrinePicker(function(data)
                hw.nodeIndex = data.index
                hw.zoneId    = data.zoneId
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    zo_strformat("Header wayshrine set to <<1>>", data.name))
            end)
            return
        end

        -- LEFT click (no shift): open map to assigned wayshrine's zone
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if not hw.nodeIndex then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    "Right-click or Shift+Right-click to assign a wayshrine first")
                return
            end
            if IsUnitInCombat("player") then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Cannot travel while in combat")
                return
            end
            -- Use wayshrinesByIndex for correct zone resolution (not GetZoneName)
            local entry = hw.nodeIndex and T.wayshrinesByIndex and T.wayshrinesByIndex[hw.nodeIndex]
            if entry and (entry.zoneId or entry.zoneName) then
                HE.OpenMapToZone(entry.zoneId, entry.zoneName)
            elseif hw.zoneId and hw.zoneId > 0 then
                HE.OpenMapToZone(hw.zoneId)
            else
                ZO_WorldMap_ShowWorldMap()
            end
            return
        end

        -- RIGHT click (no shift): fast travel with cost confirmation
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            if not hw.nodeIndex then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    "Right-click or Shift+Right-click to assign a wayshrine first")
                return
            end
            T.TravelToWayshrine(hw.nodeIndex)
            return
        end
    end)
    panel.wsBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        local hw = HE.sv.headerWayshrine
        local T = DynamicEncounters.Timers
        if hw.nodeIndex and T.wayshrinesByIndex then
            local entry = T.wayshrinesByIndex[hw.nodeIndex]
            local displayName = entry and entry.name
            local zoneName = entry and (entry.zoneName or (entry.zoneId and HE.GetZoneName(entry.zoneId)))
            if displayName then
                local tip = displayName
                if zoneName and zoneName ~= displayName then
                    tip = zo_strformat("<<1>> (<<2>>)", displayName, zoneName)
                end
                ZO_Tooltips_ShowTextTooltip(panel.wsBtn, TOP,
                    tip .. " | Left=Map  Right=Travel  Shift+Right=Change  Shift+Left=Nearest")
            else
                ZO_Tooltips_ShowTextTooltip(panel.wsBtn, TOP,
                    "Right-click=Travel  Shift+Right=Change  Shift+Left=Nearest  Left=Map")
            end
        else
            ZO_Tooltips_ShowTextTooltip(panel.wsBtn, TOP,
                "Right-click or Shift+Right-click to assign | Shift+Left for nearest | Left-click to open map")
        end
    end)
    panel.wsBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- (TM) Info button: opens a dismissable overlay with important notes
    panel.infoBtn = CreateControl("$(parent)Info", panel, CT_BUTTON)
    panel.infoBtn:SetFont("ZoFontGame")
    panel.infoBtn:SetDimensions(20, 20)
    panel.infoBtn:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -PADDING - 44, 3)
    panel.infoBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    panel.infoBtn:SetText("?")
    panel.infoBtn:SetHandler("OnClicked", function()
        HE.UI_ShowInfo()
    end)
    panel.infoBtn:SetHandler("OnMouseEnter", function()
        if not HE.sv.showHoverTooltips then return end
        ZO_Tooltips_ShowTextTooltip(panel.infoBtn, TOP, "Important notes about predictions")
    end)
    panel.infoBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    rows = {}
    local zoneIds = HE.GetSortedZoneIds()
    for i, zoneId in ipairs(zoneIds) do
        local row = CreateRow(panel, i)
        row.zoneId = zoneId
        rows[#rows + 1] = row
    end

    stepLabel = CreateControl("$(parent)Step", panel, CT_LABEL)
    stepLabel:SetFont("ZoFontGameSmall")
    stepLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    disclaimerLabel = CreateControl("$(parent)Disclaimer", panel, CT_LABEL)
    disclaimerLabel:SetFont("ZoFontGameSmall")
    disclaimerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    disclaimerLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    panel:SetHandler("OnMoveStop", function()
        HE.sv.left, HE.sv.top = panel:GetLeft(), panel:GetTop()
    end)

    panel:SetHandler("OnUpdate", function(_, frameTimeS)
        if frameTimeS < nextUpdate and not refreshPending then return end
        nextUpdate = frameTimeS + UPDATE_PERIOD
        refreshPending = false
        HE.UI_Refresh()
    end)

    -- polite scene behavior: fade with the HUD, hide in menus
    local fragment = ZO_HUDFadeSceneFragment:New(panel)
    HE.fragment = fragment
    local function AddToScene(sceneName)
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then scene:AddFragment(fragment) end
    end
    AddToScene("hud")
    AddToScene("hudui")

    HE.UI_ResetPosition(true)
    HE.UI_ApplyLock()
    HE.UI_ApplyStyle()
    HE.UI_ApplyVisibility()
end

-- ---------------------------------------------------------------------
-- application of settings
-- ---------------------------------------------------------------------

function HE.UI_ResetPosition(useSaved)
    panel:ClearAnchors()
    if useSaved and HE.sv.left and HE.sv.top then
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HE.sv.left, HE.sv.top)
    else
        panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -60, 260)
    end
end

function HE.UI_ApplyLock()
    panel:SetMovable(not HE.sv.locked)
    panel:SetMouseEnabled(not HE.sv.locked)
end

function HE.UI_ApplyStyle()
    local t = Theme()
    panel:SetScale(HE.sv.scale or 1)
    panel.bg:SetCenterColor(t.bg[1], t.bg[2], t.bg[3], HE.sv.opacity or 0.55)
    panel.bg:SetEdgeColor(unpack(t.border))
    titleLabel:SetColor(unpack(t.title))
    if panel.collapseBtn then
        local lbl = panel.collapseBtn:GetLabelControl()
        if lbl then lbl:SetColor(unpack(t.title)) end
    end
    if panel.minimizeBtn then
        local lbl = panel.minimizeBtn:GetLabelControl()
        if lbl then lbl:SetColor(unpack(t.title)) end
    end
    refreshPending = true
end

function HE.UI_ApplyVisibility()
    -- Use SetConditional on the scene fragment so the scene manager
    -- respects our visibility preference. This prevents the panel from
    -- reappearing after menu toggles. Falls back to SetHidden for safety.
    local shouldShow = HE.sv.shown and not combatHidden
    if HE.fragment then
        if HE.fragment.SetConditional then
            HE.fragment:SetConditional(function() return shouldShow end)
            -- SetConditional refreshes automatically; no manual call needed
        elseif HE.fragment.SetHiddenForReason then
            local INSTANT = 0
            HE.fragment:SetHiddenForReason("UserHidden", not HE.sv.shown, INSTANT, INSTANT)
            HE.fragment:SetHiddenForReason("InCombat", combatHidden, INSTANT, INSTANT)
        else
            panel:SetHidden(not shouldShow)
        end
    else
        panel:SetHidden(not shouldShow)
    end
    if shouldShow then refreshPending = true end
end

function HE.UI_SetCombatHidden(hidden)
    combatHidden = hidden
    HE.UI_ApplyVisibility()
end

function HE.UI_RequestRefresh()
    refreshPending = true
end

-- ---------------------------------------------------------------------
-- refresh
-- ---------------------------------------------------------------------

local STATE_COLOR_KEY = { live = "live", soon = "soon", overdue = "overdue", unknown = "unknown", estimated = "soon" }

function HE.UI_Refresh()
    if not panel or panel:IsHidden() then return end
    -- Guard: skip during loading screens (GetZoneName may return nil mid-transition)
    local pzn = GetUnitZone("player")
    if not pzn or pzn == "" then return end

    -- Full minimize: header bar only, hide everything else
    if HE.sv.minimized then
        for _, row in ipairs(rows) do
            row:SetHidden(true)
            row.travel:SetHidden(true)
        end
        if stepLabel then stepLabel:SetHidden(true) end
        if disclaimerLabel then disclaimerLabel:SetHidden(true) end
        -- Only minimize button visible when fully minimized
        if panel.collapseBtn then
            panel.collapseBtn:SetHidden(true)
        end
        if panel.minimizeBtn then
            panel.minimizeBtn:SetHidden(false)
            local mlbl = panel.minimizeBtn:GetLabelControl()
            if mlbl then mlbl:SetText("v") end
        end
        panel:SetDimensions(PANEL_WIDTH, HEADER_HEIGHT + PADDING)
        return
    end

    -- Not minimized: ensure minimize button shows correct state
    if panel.minimizeBtn then
        local mlbl = panel.minimizeBtn:GetLabelControl()
        if mlbl then mlbl:SetText("^") end
        panel.minimizeBtn:SetHidden(false)
    end
    -- Ensure collapse button is visible when not minimized
    if panel.collapseBtn then
        panel.collapseBtn:SetHidden(false)
        local clbl = panel.collapseBtn:GetLabelControl()
        if clbl then clbl:SetText(HE.sv.collapsed and "+" or "-") end
    end

    local t = Theme()
    local compact = HE.sv.compact
    local collapsed = HE.sv.collapsed
    local collapseMode = HE.sv.collapseMode or "status"
    local rowHeight
    if collapsed then
        if collapseMode == "name"   then rowHeight = ROW_COMPACT
        elseif collapseMode == "status" then rowHeight = 40
        else rowHeight = ROW_HEIGHT
        end
    else
        rowHeight = compact and ROW_COMPACT or ROW_HEIGHT
    end
    local y = HEADER_HEIGHT

    local shownAny = false
    for _, row in ipairs(rows) do
        local zoneId  = row.zoneId
        local tracked = HE.IsTracked(zoneId)
        local isHere  = (zoneId == HE.currentZoneId)

        -- Compute rowState ONCE (was being called twice in collapsed mode)
        local rowState = HE.GetRowState(zoneId) or { state = "unknown" }

        -- In collapsed mode: only show current zone + any LIVE encounters
        local show
        if collapsed then
            show = tracked and (isHere or rowState.state == "live")
        else
            show = tracked and (not HE.sv.onlyCurrent or isHere)
        end

        row:SetHidden(not show)
        if show then
            shownAny = true
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, panel, TOPLEFT, PADDING, y)
            row:SetDimensions(PANEL_WIDTH - 2 * PADDING, rowHeight)
            y = y + rowHeight + 2
            local stateColor = t[STATE_COLOR_KEY[rowState.state] or "unknown"]

            -- Dim non-current-zone predictions so "YOU ARE HERE" draws the eye first.
            -- Current-zone predictions stay at full brightness.
            -- Uses inline multiplication to avoid per-frame table allocation.
            if stateColor and not isHere and (rowState.state == "soon" or rowState.state == "overdue" or rowState.state == "estimated") then
                stateColor = { stateColor[1] * 0.7, stateColor[2] * 0.7, stateColor[3] * 0.7, stateColor[4] or 1 }
            end

            row.icon:SetTexture(rowState.state == "live" and HE.ICON_ACTIVE or HE.ICON_IDLE)
            row.icon:SetColor(unpack(stateColor))
            row.icon:SetDimensions(compact and 18 or ICON_SIZE, compact and 18 or ICON_SIZE)

            row.name:SetText(HE.GetEncounterName(zoneId))
            row.name:SetColor(unpack(t.name))

            -- Wayshrine button uses texture, tint to match zone color
            row.travel:SetNormalTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")

            -- Collapse-mode display: name/status/full determine what is visible
            local hideZone, hideStatus, hideTimer
            if collapsed then
                if collapseMode == "name" then
                    hideZone, hideStatus, hideTimer = true, true, true
                elseif collapseMode == "status" then
                    hideZone, hideStatus, hideTimer = true, false, true
                else -- "full"
                    hideZone, hideStatus, hideTimer = false, false, false
                end
            else
                hideZone = compact
                hideStatus = false
                hideTimer = false  -- always show T button for encounter pop-outs
            end

            if hideZone then
                row.zone:SetHidden(true)
            else
                row.zone:SetHidden(false)
                local zoneText = HE.GetZoneName(zoneId)
                if isHere then
                    zoneText = zoneText .. " " .. HE.GetString("YOU_ARE_HERE")
                    row.zone:SetColor(unpack(t.here))
                else
                    row.zone:SetColor(unpack(t.zone))
                end
                row.zone:SetText(zoneText)
            end

            if hideStatus then
                row.status:SetHidden(true)
            else
                row.status:SetHidden(false)
                -- Reposition status label based on collapse mode:
                -- "status" mode (40px row): status at Y=22, just below name
                -- Other modes: status at Y=48 (default position)
                if collapsed and collapseMode == "status" then
                    row.status:ClearAnchors()
                    row.status:SetAnchor(TOPLEFT, row, TOPLEFT, ICON_SIZE + 6, 22)
                else
                    row.status:ClearAnchors()
                    row.status:SetAnchor(TOPLEFT, row, TOPLEFT, ICON_SIZE + 6, 48)
                end
                row.status:SetText(rowState.statusText or "")
                row.status:SetColor(unpack(stateColor))
                -- Dynamic width: when timer is hidden or empty, status gets full
                -- text width so "last seen 14m 29s ago" never clips to "a".
                -- When timer is visible, keep the standard 60/40 split.
                local timerHidden = hideTimer or (rowState.timerText or "") == ""
                local fullTextW = (PANEL_WIDTH - 2 * PADDING) - (ICON_SIZE + 6)
                -- Subtract wayshrine button space when visible (18px button + 2px right margin)
                if HE.sv.showTravel and not collapsed then
                    fullTextW = fullTextW - 22
                end
                if timerHidden then
                    row.status:SetWidth(fullTextW)
                else
                    row.status:SetWidth(math.floor(fullTextW * 0.60))
                end
                -- Font fallback: extremely long text (e.g. after long AFK) uses
                -- a smaller font to guarantee it fits within the label bounds.
                -- Only call SetFont when the font actually needs to change.
                local statusText = rowState.statusText or ""
                local needSmallFont = (#statusText > 24)
                if needSmallFont ~= row._usingSmallFont then
                    row._usingSmallFont = needSmallFont
                    row.status:SetFont(needSmallFont and "ZoFontGameSmall" or "ZoFontGameBold")
                end
            end

            if hideTimer then
                row.timer:SetHidden(true)
            else
                row.timer:SetHidden(false)
                row.timer:SetText(rowState.timerText or "")
                row.timer:SetColor(unpack(t.timer))
            end

            -- Wayshrine button: hidden only if disabled by user setting
            row.travel:SetHidden(not HE.sv.showTravel)
            -- Re-anchor T button: use row edge when travel is hidden,
            -- travel's left edge when visible (prevents layout breaks).
            row.clockBtn:ClearAnchors()
            if row.travel:IsHidden() then
                row.clockBtn:SetAnchor(RIGHT, row, RIGHT, -2, 0)
            else
                row.clockBtn:SetAnchor(RIGHT, row.travel, LEFT, -4, 3)
            end
        else
            row.travel:SetHidden(true)
            row.clockBtn:ClearAnchors()
            row.clockBtn:SetAnchor(RIGHT, row, RIGHT, -2, 0)
        end
    end

    -- participation detail: the precise, server-authoritative stage timer
    -- Shown in normal mode and collapsed "full" mode; hidden in collapsed name/status
    local showStepLabel = not collapsed or collapseMode == "full"
    if showStepLabel then
        local part = HE.GetParticipationInfo()
        if part and type(part.stepName) == "string" and part.stepName ~= "" then
            local text = part.stepName
            if part.expireTime and part.expireTime > 0 then
                local remaining = math.max(0, part.expireTime - GetTimeStamp())
                text = text .. "  |cFFD700" .. HE.GetString("STEP_TIME_LEFT", HE.FormatDuration(remaining, true)) .. "|r"
            end
            if part.progress then
                text = text .. string.format("  (%d%%)", math.floor(part.progress * 100 + 0.5))
            end
            stepLabel:SetText(text)
            stepLabel:SetColor(unpack(t.name))
            stepLabel:ClearAnchors()
            stepLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, PADDING, y + 2)
            stepLabel:SetHidden(false)
            y = y + 20
        else
            stepLabel:SetHidden(true)
        end
    else
        stepLabel:SetHidden(true)
    end

    -- disclaimer footer: shown in normal mode and collapsed "full" mode
    local showDisclaimer = not collapsed or collapseMode == "full"
    if disclaimerLabel and showDisclaimer and HE.sv.showDisclaimer then
        disclaimerLabel:SetText(HE.GetString("DISCLAIMER"))
        disclaimerLabel:SetColor(unpack(t.unknown))
        disclaimerLabel:ClearAnchors()
        disclaimerLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, PADDING, y + 2)
        disclaimerLabel:SetDimensions(PANEL_WIDTH - 2 * PADDING, DISCLAIMER_HEIGHT)
        disclaimerLabel:SetHidden(false)
        y = y + DISCLAIMER_HEIGHT + 2
    else
        if disclaimerLabel then disclaimerLabel:SetHidden(true) end
    end

    if not shownAny then
        y = y + 4
    end
    panel:SetDimensions(PANEL_WIDTH, y + PADDING)
end

-- ---------------------------------------------------------------------
-- info overlay: dismissable full-screen notes (backdrop click / X / ESC).
-- CANONICAL PATTERN: a real ZO_Scene managed ONLY via
-- SCENE_MANAGER:Show/Hide. ZO_FadeSceneFragment toggles the TopLevelWindow;
-- ZO_KeybindStripFadeFragment owns the ESC keybind so it is ACTIVE while
-- the scene shows (a bare TopLevelWindow never activates the keybind strip).
--
-- Guards for known regressions:
--   * "open->close->open then stuck": scene+fragments are built ONCE and
--     reused; we never recreate them on subsequent opens.
--   * "lost POV / mouse stuck": cursor + UI mode are enabled on Showing and
--     ALWAYS restored on Hiding (fires even on interrupted hides), and we
--     never call SetHidden manually (which desynced the fade fragment).
-- ---------------------------------------------------------------------

local infoOverlay, infoBackdrop, infoPanel
local infoScene                      -- ZO_Scene, built once
local INFO_SCENE_NAME = "DynamicEncountersInfoScene"

local function BuildInfoOverlay()
    local contentW, contentH = 480, 680

    infoOverlay = CreateTopLevelWindow("DynamicEncountersInfo")
    infoOverlay:SetDrawLayer(DL_OVERLAY)
    infoOverlay:SetDrawTier(DT_HIGH)
    infoOverlay:SetAnchorFill(GuiRoot)
    infoOverlay:SetMouseEnabled(true)
    infoOverlay:SetHidden(true)

    -- backdrop: click anywhere outside the panel to dismiss
    infoBackdrop = CreateControl("$(parent)Backdrop", infoOverlay, CT_BACKDROP)
    infoBackdrop:SetAnchorFill(infoOverlay)
    infoBackdrop:SetCenterColor(0, 0, 0, 0.58)
    infoBackdrop:SetEdgeColor(0, 0, 0, 0)
    infoBackdrop:SetMouseEnabled(true)
    infoBackdrop:SetHandler("OnMouseUp", function()
        HE.UI_HideInfo()
    end)

    -- content panel (mouse-enabled so clicks on it don't fall through to backdrop)
    infoPanel = CreateControl("$(parent)Panel", infoOverlay, CT_BACKDROP)
    infoPanel:SetDimensions(contentW, contentH)
    infoPanel:SetAnchor(CENTER, infoOverlay, CENTER, 0, 0)
    infoPanel:SetCenterColor(0.06, 0.07, 0.10, 0.96)
    infoPanel:SetEdgeColor(0.25, 0.55, 0.80, 0.85)
    infoPanel:SetMouseEnabled(true)

    -- title
    local title = CreateControl("$(parent)Title", infoPanel, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetText(HE.GetString("PANEL_TITLE") .. " \226\128\148 Info")
    title:SetColor(0.40, 0.80, 1.00)
    title:SetAnchor(TOPLEFT, infoPanel, TOPLEFT, 16, 12)

    -- X close button: ESO's built-in close texture (always renders)
    local closeBtn = CreateControl("$(parent)Close", infoPanel, CT_BUTTON)
    closeBtn:SetDimensions(24, 24)
    closeBtn:SetAnchor(TOPRIGHT, infoPanel, TOPRIGHT, -8, 8)
    closeBtn:SetFont("ZoFontGame")
    closeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetText("X")
    closeBtn:SetNormalFontColor(0.7, 0.7, 0.7, 1)
    closeBtn:SetMouseOverFontColor(1, 0.3, 0.3, 1)
    closeBtn:SetHandler("OnClicked", function()
        HE.UI_HideInfo()
    end)
    closeBtn:SetHandler("OnMouseEnter", function()
        ZO_Tooltips_ShowTextTooltip(closeBtn, TOP, "Close (Esc)")
    end)
    closeBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- content text
    local content = CreateControl("$(parent)Content", infoPanel, CT_LABEL)
    content:SetFont("ZoFontGame")
    content:SetAnchor(TOPLEFT, infoPanel, TOPLEFT, 16, 48)
    content:SetDimensions(contentW - 32, contentH - 64)
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    content:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    content:SetWrapMode(TEXT_WRAP_MODE_NORMAL)
    content:SetColor(1, 1, 1)

    local infoText =
        "|c66CCFFImportant|r\n\n" ..
        "|cFFD700" .. HE.GetString("ARRIVE_EARLY") .. "|r\n" ..
        "Predictions are learned estimates, not official timers. " ..
        "Arrive a few minutes before the estimated time to be safe.\n\n" ..
        "|cFFD700" .. HE.GetString("DISCLAIMER") .. "|r\n" ..
        "The more full cycles the addon observes (encounter ending, " ..
        "then starting again), the more accurate the countdown becomes.\n\n" ..
        "|cFFD700Instance Variance|r\n" ..
        HE.GetString("NOTE_INSTANCE") .. "\n\n" ..
        "|cFFD700Tips|r\n" ..
        "- Stay through an encounter ending and the next one starting " ..
        "to build accuracy.\n" ..
        "- Loading screens may land you on a different server shard " ..
        "with a different clock.\n" ..
        "- Click the wayshrine icon to open the zone map.\n" ..
        "- The timer may briefly freeze after a zone change; " ..
        "waiting for the next active encounter resets it."

    content:SetText(infoText)

    -- Build the scene + fragments ONCE. The fade fragment toggles the
    -- overlay; the keybind-strip fragment activates ESC while shown.
    if not infoScene then
        infoScene = ZO_Scene:New(INFO_SCENE_NAME, SCENE_MANAGER)
        infoScene:AddFragment(ZO_FadeSceneFragment:New(infoOverlay))

        local keybindStripDescriptor = {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            {
                name = GetString(SI_DIALOG_CLOSE),
                keybind = "UI_SHORTCUT_NEGATIVE",  -- ESC / gamepad B
                callback = function() SCENE_MANAGER:Hide(INFO_SCENE_NAME) end,
                visible = function() return true end,
            },
        }
        -- Keybind strip via scene state-change callbacks (canonical ESO pattern).
        -- ZO_KeybindStripFadeFragment does not exist; KEYBIND_STRIP is always available.
        infoScene:RegisterCallback("StateChange", function(oldState, newState)
            if not KEYBIND_STRIP or not KEYBIND_STRIP.AddKeybindButtonGroup then return end
            local ok, err = pcall(function()
                if newState == SCENE_SHOWING then
                    KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
                elseif newState == SCENE_HIDING then
                    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
                end
            end)
            if not ok then d("[DynamicEncounters] KEYBIND_STRIP error: " .. tostring(err)) end
        end)

        -- Mouse-cursor release for this full-screen interactive window.
        -- (Note: SCENE_MANAGER:SetUIMode does NOT take a boolean;
        -- the scene enables its own mouse capture.) SetMouseEnabled(true)
        -- releases the cursor while shown and the scene restores it on hide,
        -- so the POV/mouse never gets stuck -- even on interrupted hides.
        -- NOTE: ZO_Scene has NO SetMouseEnabled method (that is a Control method).
        -- The scene manages cursor/mouse state via its fragments automatically.
        -- infoOverlay already has SetMouseEnabled(true) above.
    end
end

function HE.UI_ShowInfo()
    if not infoOverlay then
        BuildInfoOverlay()
    end
    if SCENE_MANAGER:IsShowing(INFO_SCENE_NAME) then return end  -- already open
    SCENE_MANAGER:Show(INFO_SCENE_NAME)
end

function HE.UI_HideInfo()
    if not infoScene then return end
    if SCENE_MANAGER:IsShowing(INFO_SCENE_NAME) then
        SCENE_MANAGER:Hide(INFO_SCENE_NAME)
    end
end
