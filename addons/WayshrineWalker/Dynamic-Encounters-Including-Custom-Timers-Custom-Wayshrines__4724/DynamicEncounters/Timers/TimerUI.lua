--[[----------------------------------------------------------------------
    Dynamic Encounters : Timer UI
    Floating timer widgets using ZO_ObjectPool (Lua-factory, no XML).
    Single OnUpdate on a hidden container updates all active timers.

    Features: per-timer lock button, drag (lockable), resize (S/M/L),
    custom duration prompt, wayshrine click-to-map, start/stop toggle,
    wall-clock expiry with sound + alert + flash.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

-- Configurable colors and threshold (overridden by settings at init)
local WARN_THRESHOLD  = 30
local COLOR_NORMAL    = { 1, 1, 1 }
local COLOR_WARNING   = { 1, 0.25, 0.25 }
local COLOR_RUNNING   = { 0.30, 0.80, 0.40 }
local COLOR_STOPPED   = { 0.60, 0.75, 0.95 }
local COLOR_EXPIRED   = { 0.90, 0.30, 0.20 }
local COLOR_STATUS    = { 0.95, 0.80, 0.35 }

-- Called from Settings_Initialize to load custom colors
function T.UI_GetWarnThreshold()
    return WARN_THRESHOLD
end

function T.UI_SetWarnThreshold(secs)
    WARN_THRESHOLD = math.max(0, math.floor(tonumber(secs) or 30))
end

function T.UI_SetColors(colors)
    if not colors then return end
    if colors.normal   then COLOR_NORMAL  = colors.normal  end
    if colors.warning  then COLOR_WARNING = colors.warning end
    if colors.running  then COLOR_RUNNING = colors.running end
    if colors.stopped  then COLOR_STOPPED = colors.stopped end
    if colors.expired  then COLOR_EXPIRED = colors.expired end
    if colors.status   then COLOR_STATUS  = colors.status  end
end

-- Icon mode: false = text glyphs (default), true = ESO textures
local ICON_MODE = false

function T.UI_GetIconMode()
    return ICON_MODE
end

function T.UI_SetIconMode(enabled)
    ICON_MODE = enabled and true or false
    -- Immediately refresh all active timers to switch appearance
    T.UI_RefreshAll()
end

-- Return current color table so settings panel can read actual values
function T.UI_GetColors()
    return {
        normal  = COLOR_NORMAL,
        warning = COLOR_WARNING,
        running = COLOR_RUNNING,
        stopped = COLOR_STOPPED,
        expired = COLOR_EXPIRED,
        status  = COLOR_STATUS,
    }
end
local UPDATE_INTERVAL = 0.25

local SIZE_DIMS = {
    [T.SIZE_SMALL]  = { w = 200, h = 60,  font = "ZoFontGameSmall", btn = 22 },
    [T.SIZE_MEDIUM] = { w = 300, h = 90,  font = "ZoFontGame",      btn = 28 },
    [T.SIZE_LARGE]  = { w = 400, h = 120, font = "ZoFontWinH3",     btn = 34 },
}


local timerPool
local nextUIUpdate = 0
local timerSceneHidden = false  -- true when HUD scene is hidden (menus, inventory)

-- -------------------------------------------------------------------
-- text-input dialog (registered once). Used for label + duration edits.
-- -------------------------------------------------------------------
local EDIT_DIALOG = "DYNAMICENCOUNTERS_TIMER_EDIT"
local editDialogCallback = nil

-- Travel confirmation dialog
local TRAVEL_DIALOG = "DYNAMICENCOUNTERS_TRAVEL_CONFIRM"

T.UI_EnsureTravelDialog = function()
    if ZO_Dialogs_FindDialog(TRAVEL_DIALOG) then return end
    ZO_Dialogs_RegisterCustomDialog(TRAVEL_DIALOG, {
        title = { text = "Fast Travel" },
        mainText = {
            text = function(dialog)
                local nodeIndex = dialog.data.nodeIndex
                local _, name = GetFastTravelNodeInfo(nodeIndex)
                local cost = GetRecallCost()
                if cost > 0 then
                    return zo_strformat("Travel to <<1>>?\nCost: <<2>> gold", name, cost)
                end
                return zo_strformat("Travel to <<1>>?\nCost: Free (at a wayshrine)", name)
            end,
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    FastTravelToNode(dialog.data.nodeIndex)
                end,
            },
            [2] = { text = SI_DIALOG_CANCEL },
        },
    })
end

-- Must be declared BEFORE EnsureEditDialog so the closure captures this local.
local _editDialogTitle = "Timer"

local function EnsureEditDialog()
    if ZO_Dialogs_FindDialog(EDIT_DIALOG) then return end
    ZO_Dialogs_RegisterCustomDialog(EDIT_DIALOG, {
        title = { text = function() return _editDialogTitle or "Timer" end },
        mainText = { text = "" },
        editBox = { defaultText = "", maxInputChars = 40 },
        setup = function(dialog, data)
            local eb = dialog:GetNamedChild("EditBox")
            if eb then
                eb:SetText(data.default or "")
                eb:TakeFocus()
            end
        end,
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    local eb = dialog and dialog:GetNamedChild("EditBox")
                    local text = eb and eb:GetText() or ""
                    local cb = editDialogCallback
                    editDialogCallback = nil
                    if eb then eb:LoseFocus() end  -- release keyboard so the game reclaims input
                    ZO_Dialogs_ReleaseDialog(EDIT_DIALOG)
                    if cb then cb(text) end
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)
                    editDialogCallback = nil
                    local eb = dialog and dialog:GetNamedChild("EditBox")
                    if eb then eb:LoseFocus() end  -- release keyboard on cancel too
                    ZO_Dialogs_ReleaseDialog(EDIT_DIALOG)
                end,
            },
        },
    })
end


-- Show the edit dialog. title: caption, default: starting text, onOk(text).
local function ShowEditDialog(title, default, onOk)
    EnsureEditDialog()
    _editDialogTitle = title or "Timer"
    editDialogCallback = onOk
    ZO_Dialogs_ShowDialog(EDIT_DIALOG, { title = _editDialogTitle, default = default })
end

-- iterate active controls safely
local function EachActive(fn)
    if not timerPool then return end
    for key, c in pairs(timerPool:GetActiveObjects()) do
        fn(c)
    end
end

function T.UI_Initialize()
    if timerPool then return end  -- idempotency guard (no double-init ghosts)

    local container = CreateTopLevelWindow("DynamicEncountersTimerContainer")
    -- Must NOT be hidden -- ESO does not fire OnUpdate on hidden windows.
    -- Keep it 1x1 pixel with no draw layer so it is invisible but still active.
    container:SetHidden(false)
    container:SetDimensions(1, 1)
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)

    -- ESO OnUpdate passes absolute time (seconds since game start), not delta.
    -- Compare against a next-update threshold to throttle UI refreshes.
    local nextUpdate = 0
    container:SetHandler("OnUpdate", function(_, timeS)
        if timeS < nextUpdate then return end
        nextUpdate = timeS + UPDATE_INTERVAL
        T.UI_RefreshAll()
    end)

    -- ZO_ObjectPool does NOT have GetNextControlId (that's ZO_ControlPool).
    -- Use our own counter instead.
    local poolIdCounter = 0
    timerPool = ZO_ObjectPool:New(
        function(pool)
            poolIdCounter = poolIdCounter + 1
            return T.UI_CreateTimerControl("DynamicEncountersTimer" .. poolIdCounter)
        end,
        function(control)
            T.UI_ResetControl(control)
        end
    )

    for id, timer in pairs(T.GetAllTimers()) do
        T.UI_CreateForTimer(timer)
    end

    -- Attach timers to the HUD scene so they hide in menus/inventory/map
    -- (same behavior as the main DE panel).
    local function AddTimerFragmentToScene(sceneName)
        local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                -- When the HUD scene hides (menus, inventory, map, etc.),
                -- hide all timer widgets. When it shows again, restore them.
                if newState == SCENE_HIDDEN then
                    timerSceneHidden = true
                    EachActive(function(c) c:SetHidden(true) end)
                elseif newState == SCENE_SHOWN then
                    timerSceneHidden = false
                    EachActive(function(c)
                        if c.timerId then c:SetHidden(false) end
                    end)
                end
            end)
        end
    end
    AddTimerFragmentToScene("hud")
    AddTimerFragmentToScene("hudui")
end

-- -------------------------------------------------------------------
-- widget factory
-- -------------------------------------------------------------------

function T.UI_CreateTimerControl(name)
    local c = CreateTopLevelWindow(name)
    c:SetClampedToScreen(true)
    c:SetMouseEnabled(true)
    c:SetMovable(true)
    c:SetDrawLayer(DL_CONTROLS)
    c:SetDrawTier(DT_MEDIUM)
    c:SetHidden(true)

    c.bg = CreateControl("$(parent)Bg", c, CT_BACKDROP)
    c.bg:SetAnchorFill(c)
    -- Backdrop must be mouse-enabled for drag to work on the full widget.
    -- The parent window (c) handles the actual moving via SetMovable.
    c.bg:SetMouseEnabled(true)
    c.bg:SetHandler("OnMouseDown", function()
        if not T.IsLocked(c.timerId) then c:StartMoving() end
    end)
    c.bg:SetHandler("OnMouseUp", function()
        c:StopMovingOrResizing()
    end)
    c.bg:SetCenterColor(0.05, 0.06, 0.10, 0.88)
    c.bg:SetEdgeColor(0.25, 0.55, 0.80, 0.70)

    c.label = CreateControl("$(parent)Label", c, CT_LABEL)
    c.label:SetAnchor(TOPLEFT, c, TOPLEFT, 30, 4)  -- right of lock button
    c.label:SetDimensions(160, 18)  -- explicit size so it always renders
    c.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    c.label:SetDrawLevel(2)  -- above backdrop
    c.label:SetFont("ZoFontGameSmall")  -- explicit font so text always renders
    c.label:SetColor(1, 1, 1)

    c.countdown = CreateControl("$(parent)Countdown", c, CT_LABEL)
    c.countdown:SetMouseEnabled(false)
    c.countdown:SetAnchor(CENTER, c, CENTER, 0, 2)
    c.countdown:SetDimensions(120, 24)  -- explicit size so it always renders
    c.countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.countdown:SetDrawLevel(2)  -- above backdrop
    c.countdown:SetColor(1, 1, 1)
    c.countdown:SetFont("ZoFontGame")

    -- per-timer lock button (top-left). Uses ESO lock textures.
    c.lockBtn = CreateControl("$(parent)Lock", c, CT_BUTTON)
    c.lockBtn:SetDimensions(24, 24)
    c.lockBtn:SetAnchor(TOPLEFT, c, TOPLEFT, 4, 2)
    c.lockBtn:SetMouseEnabled(true)
    c.lockBtn:SetDrawLevel(5)
    -- Lock button uses standard ESO texture swap on toggle
    -- Use 'locked_up' (padlock closed) and 'unlocked_up' (padlock open)
    c.lockBtn:SetNormalTexture("/esoui/art/miscellaneous/locked_up.dds")
    c.lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/locked_up.dds")
    c.lockBtn:SetHandler("OnClicked", function(self)
        if not c.timerId then return end
        local locked = T.ToggleLocked(c.timerId)
        c:SetMovable(not locked)
        local timer = T.GetTimer(c.timerId)
        if timer then T.UI_ApplyState(c, timer) end
    end)
    c.lockBtn:SetHandler("OnMouseEnter", function(self)
        local t = c.timerId and T.GetTimer(c.timerId)
        local state = (t and T.IsLocked(t.id)) and "Locked — position fixed, close button hidden (click to unlock)" or "Unlocked (click to lock position & hide close button)"
        ZO_Tooltips_ShowTextTooltip(self, TOP, state)
    end)
    c.lockBtn:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)

    -- start/stop button (bottom-left)
    c.toggleBtn = CreateControl("$(parent)Toggle", c, CT_LABEL)
    c.toggleBtn:SetFont("ZoFontGameLargeBold")
    c.toggleBtn:SetDimensions(28, 24)
    c.toggleBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.toggleBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.toggleBtn:SetColor(0.80, 0.80, 0.80, 1)
    c.toggleBtn:SetMouseEnabled(true)
    c.toggleBtn:SetHandler("OnMouseUp", function(self, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then return end
        if not c.timerId then return end
        T.ToggleTimer(c.timerId)
        local timer = T.GetTimer(c.timerId)
        if timer then T.UI_ApplyState(c, timer) end
    end)
    c.toggleBtn:SetHandler("OnMouseEnter", function(self)
        if not c.timerId then return end
        local timer = T.GetTimer(c.timerId)
        local stateText = "Start timer"
        if timer then
            if timer.expired then stateText = "Restart timer"
            elseif timer.state == T.STATE_RUNNING then stateText = "Pause timer"
            end
        end
        ZO_Tooltips_ShowTextTooltip(self, TOP, stateText)
    end)
    c.toggleBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- icon-mode toggle button (hidden by default; shown when ICON_MODE is true).
    -- Sits at the same position as the text toggle. Only ONE is visible at a time.
    c.toggleBtnIcon = CreateControl("$(parent)ToggleIcon", c, CT_BUTTON)
    c.toggleBtnIcon:SetDimensions(28, 28)
    c.toggleBtnIcon:SetAnchor(BOTTOMLEFT, c, BOTTOMLEFT, 8, -4)
    c.toggleBtnIcon:SetMouseEnabled(true)
    c.toggleBtnIcon:SetDrawLevel(5)
    c.toggleBtnIcon:SetHidden(true)  -- text mode is default
    c.toggleBtnIcon:SetHandler("OnClicked", function(self)
        if not c.timerId then return end
        T.ToggleTimer(c.timerId)
        local timer = T.GetTimer(c.timerId)
        if timer then T.UI_ApplyState(c, timer) end
    end)
    c.toggleBtnIcon:SetHandler("OnMouseEnter", function(self)
        if not c.timerId then return end
        local timer = T.GetTimer(c.timerId)
        local stateText = "Start timer"
        if timer then
            if timer.expired then stateText = "Restart timer"
            elseif timer.state == T.STATE_RUNNING then stateText = "Pause timer"
            end
        end
        ZO_Tooltips_ShowTextTooltip(self, TOP, stateText)
    end)
    c.toggleBtnIcon:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- close/delete button (top-right)
    c.closeBtn = CreateControl("$(parent)Close", c, CT_LABEL)
    c.closeBtn:SetFont("ZoFontGameLargeBold")
    c.closeBtn:SetDimensions(24, 24)
    c.closeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.closeBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.closeBtn:SetText("X")
    c.closeBtn:SetColor(0.50, 0.50, 0.50, 1)
    c.closeBtn:SetMouseEnabled(true)
    c.closeBtn:SetHandler("OnMouseUp", function(self, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then return end
        if not c.timerId then return end
        T.DeleteTimer(c.timerId, true)
    end)
    c.closeBtn:SetHandler("OnMouseEnter", function(self)
        self:SetColor(1, 0.30, 0.30, 1)
    end)
    c.closeBtn:SetHandler("OnMouseExit", function(self)
        self:SetColor(0.50, 0.50, 0.50, 1)
    end)

    -- wayshrine button (bottom-right)
    c.wsBtn = CreateControl("$(parent)Wayshrine", c, CT_BUTTON)
    c.wsBtn:SetDimensions(22, 22)
    c.wsBtn:SetNormalTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    c.wsBtn:SetMouseOverTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
    -- Don't hide wsBtn here; LayoutControls handles visibility
    c.wsBtn:SetHidden(false)
    c.wsBtn:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift)
        if not upInside then return end
        local timer = self.timerId and T.GetTimer(self.timerId)
        if not timer then return end

        -- SHIFT+LEFT-click: assign nearest (local) wayshrine
        if shift and button == MOUSE_BUTTON_INDEX_LEFT then
            local nearest = T.FindNearestWayshrine()
            if nearest then
                local tid = self.timerId
                -- Use the nearest wayshrine's own zoneId directly.
                -- If zoneId is nil (unresolved), the tooltip gracefully
                -- falls back to the wayshrine's own name via
                -- GetWayshrineZoneName, which is always correct since
                -- FindNearestWayshrine filters to poiType==1 (wayshrines only).
                T.SetWayshrine(tid, nearest.index, nearest.zoneId)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    zo_strformat("Linked to <<1>>", nearest.name))
            else
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE,
                    "No known wayshrines nearby")
            end
            return
        end

        -- SHIFT+RIGHT-click: open searchable picker of all wayshrines
        if shift and button == MOUSE_BUTTON_INDEX_RIGHT then
            T.ShowWayshrinePicker(function(data)
                local tid = self.timerId
                T.SetWayshrine(tid, data.index, data.zoneId)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
                    zo_strformat("Linked to <<1>>", data.name))
            end)
            return
        end

        -- Normal LEFT-click (no shift): open map at wayshrine location
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if IsUnitInCombat("player") then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Cannot travel while in combat")
                return
            end
            -- Open map to the wayshrine's zone
            local entry = timer.wayshrineNodeId and T.wayshrinesByIndex and T.wayshrinesByIndex[timer.wayshrineNodeId]
            if entry and (entry.zoneId or entry.zoneName) then
                HE.OpenMapToZone(entry.zoneId, entry.zoneName)
            elseif timer.wayshrineZoneId and timer.wayshrineZoneId > 0 then
                HE.OpenMapToZone(timer.wayshrineZoneId)
            else
                -- No zone resolved — just open the map
                ZO_WorldMap_ShowWorldMap()
            end
        end

        -- RIGHT-click (no shift): travel with confirmation
        if button == MOUSE_BUTTON_INDEX_RIGHT and not shift then
            if not timer.wayshrineNodeId then return end
            if IsUnitInCombat("player") then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Cannot travel while in combat")
                return
            end
            local known = GetFastTravelNodeInfo(timer.wayshrineNodeId)
            if not known then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Wayshrine not discovered")
                return
            end
            EnsureTravelDialog()
            ZO_Dialogs_ShowDialog(TRAVEL_DIALOG, { nodeIndex = timer.wayshrineNodeId })
        end
    end)
    c.wsBtn:SetHandler("OnMouseEnter", function(self)
        local timer = self.timerId and T.GetTimer(self.timerId)
        if not timer then return end
        local label
        if timer.wayshrineNodeId then
            -- Show the wayshrine's own name (from the fast travel node)
            -- plus its zone name for clarity. GetWayshrineZoneName returns
            -- the zone name when resolved, or falls back to the node name.
            local nodeName = T.GetWayshrineZoneName(timer.wayshrineNodeId, timer.wayshrineZoneId)
            if not nodeName or nodeName == "" then nodeName = "wayshrine" end

            -- Also fetch the node's display name directly so we can show
            -- both the wayshrine name and zone name when they differ.
            local entry = T.wayshrinesByIndex and T.wayshrinesByIndex[timer.wayshrineNodeId]
            local displayName = entry and entry.name or nodeName
            local zoneName = nil
            local zoneId = (entry and entry.zoneId) or timer.wayshrineZoneId
            -- Use entry.zoneName (set by hardcoded table) instead of GetZoneNameById
            -- which returns wrong names like Clean Test in some ESO versions.
            if entry and entry.zoneName and entry.zoneName ~= "" then
                zoneName = entry.zoneName
            elseif zoneId and zoneId > 0 then
                zoneName = GetZoneNameById(zoneId)
            end

            local header
            if zoneName and zoneName ~= "" and zoneName ~= displayName then
                header = "|c70CCFF" .. displayName .. "|r (|c88BBDD" .. zoneName .. "|r)"
            else
                header = "|c70CCFF" .. displayName .. "|r"
            end

            label = table.concat({
                header,
                "|c8899AALeft-click:|r open map",
                "|c8899AARight-click:|r travel there",
                "|c8899AASHIFT+Left:|r set nearest",
                "|c8899AASHIFT+Right:|r browse all",
            }, "\n")
        elseif timer.wayshrineZoneId then
            local zoneName = HE.GetZoneName(timer.wayshrineZoneId)
            if not zoneName or zoneName == "" then zoneName = "zone" end
            label = table.concat({
                "|c70CCFFZone:|r " .. zoneName,
                "|c8899AALeft-click:|r open map",
                "|c8899AASHIFT+Left:|r set nearest",
                "|c8899AASHIFT+Right:|r browse all",
            }, "\n")
        else
            label = table.concat({
                "|c8899AASHIFT+Left-click:|r set nearest",
                "|c8899AASHIFT+Right-click:|r browse all wayshrines",
            }, "\n")
        end
        ZO_Tooltips_ShowTextTooltip(self, TOP, label)
    end)
    c.wsBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    -- resize handle (bottom-right corner)
    c.resizeHandle = CreateControl("$(parent)Resize", c, CT_LABEL)
    c.resizeHandle:SetFont("ZoFontGameSmall")
    c.resizeHandle:SetDimensions(16, 16)
    c.resizeHandle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.resizeHandle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.resizeHandle:SetText("+")
    c.resizeHandle:SetColor(0.50, 0.50, 0.50, 1)
    c.resizeHandle:SetMouseEnabled(true)
    c.resizeHandle:SetHandler("OnMouseUp", function(self, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then return end
        if not c.timerId then return end
        if T.IsLocked(c.timerId) then return end
        local timer = T.GetTimer(c.timerId)
        if not timer then return end
        local nextSize = timer.size + 1
        if nextSize > T.SIZE_LARGE then nextSize = T.SIZE_SMALL end
        T.SetSize(c.timerId, nextSize)
    end)

    -- Use SetMovable + OnMoveStop like the main panel (smooth drag)
    c:SetHandler("OnMoveStop", function()
        T.SetPosition(c.timerId, c:GetLeft(), c:GetTop())
    end)

    -- right-click label to edit text; SHIFT+right-click to set duration
    c.label:SetMouseEnabled(true)
    c.label:SetHandler("OnMouseUp", function(_, button, upInside, ctrl, alt, shift)
        if button ~= MOUSE_BUTTON_INDEX_RIGHT or not upInside then return end
        if not c.timerId then return end
        if T.IsLocked(c.timerId) then return end
        if shift then
            T.UI_PromptEditDuration(c.timerId)
        else
            T.UI_PromptEditLabel(c.timerId)
        end
    end)
    c.label:SetHandler("OnMouseEnter", function(self)
        if not c.timerId then return end
        ZO_Tooltips_ShowTextTooltip(self, TOP,
            "Right-click: rename  |  Shift+Right-click: set duration")
    end)
    c.label:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    return c
end

-- -------------------------------------------------------------------
-- reset pooled control
-- -------------------------------------------------------------------

function T.UI_ResetControl(c)
    c.timerId = nil
    c.wsBtn.timerId = nil
    c.lockBtn.timerId = nil
    c.toggleBtn.timerId = nil
    c.closeBtn.timerId = nil
    c:SetHidden(true)
    c.label:SetText("")
    c.countdown:SetText("")
    c.toggleBtn:SetText("")
    c.toggleBtnIcon:SetHidden(true)
    c.wsBtn:SetHidden(true)
    c.resizeHandle:SetHidden(false)
    if c.flashAnim then c.flashAnim:Stop() end
end

-- -------------------------------------------------------------------
-- anchor helper (used on create, resize, wayshrine change)
-- -------------------------------------------------------------------

local function LayoutControls(c, timer)
    local dims = SIZE_DIMS[timer.size] or SIZE_DIMS[T.SIZE_MEDIUM]
    c:SetDimensions(dims.w, dims.h)
    c.label:SetFont(dims.font)
    c.countdown:SetFont(dims.font)

    c.toggleBtn:ClearAnchors()
    c.toggleBtn:SetAnchor(BOTTOMLEFT, c, BOTTOMLEFT, 8, -4)

    c.closeBtn:ClearAnchors()
    c.closeBtn:SetAnchor(TOPRIGHT, c, TOPRIGHT, -4, 4)
    -- closeBtn visibility is controlled by UI_ApplyState based on lock state

    c.wsBtn:ClearAnchors()
    c.wsBtn:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -2, -2)

    c.resizeHandle:ClearAnchors()
    -- ALWAYS show wayshrine button so users can assign one via SHIFT+click
    c.wsBtn:SetHidden(false)
    c.resizeHandle:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -24, -2)
end

-- -------------------------------------------------------------------
-- create UI for a timer
-- -------------------------------------------------------------------

function T.UI_CreateForTimer(timer)
    if not timerPool then return end
    local c, key = timerPool:AcquireObject()
    c.timerId = timer.id
    c.wsBtn.timerId = timer.id
    c.lockBtn.timerId = timer.id
    c.toggleBtn.timerId = timer.id
    c.closeBtn.timerId = timer.id
    c.poolKey = key
    c:SetHidden(timerSceneHidden)

    LayoutControls(c, timer)

    c:ClearAnchors()
    c:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, timer.left or 200, timer.top or 200)

    c.label:SetText(timer.label)
    T.UI_ApplyState(c, timer)
end

-- -------------------------------------------------------------------
-- core callbacks
-- -------------------------------------------------------------------

function T.UI_OnTimerCreated(timer) T.UI_CreateForTimer(timer) end

local function FindControl(id)
    local found
    EachActive(function(c) if c.timerId == id then found = c end end)
    return found
end

function T.UI_OnTimerDeleted(timer)
    if not timerPool then return end
    local c = FindControl(timer.id)
    if c then
        c:StopMovingOrResizing()
        timerPool:ReleaseObject(c.poolKey)
    end
end

function T.UI_OnTimerResized(timer)
    local c = FindControl(timer.id)
    if c then LayoutControls(c, timer) end
end

function T.UI_OnTimerMoved(timer)
    local c = FindControl(timer.id)
    if c then
        c:ClearAnchors()
        c:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, timer.left or 200, timer.top or 200)
    end
end

function T.UI_OnTimerLabelChanged(timer)
    local c = FindControl(timer.id)
    if c then c.label:SetText(timer.label) end
end

function T.UI_OnWayshrineChanged(timer)
    local c = FindControl(timer.id)
    if c then LayoutControls(c, timer) end
end

function T.UI_OnTimerExpired(timer)
    local c = FindControl(timer.id)
    PlaySound(SOUNDS.QUEST_COMPLETED)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
        zo_strformat("Timer '<<1>>' finished", timer.label))
    if c then
        if not c.flashAnim then c.flashAnim = ZO_AlphaAnimation:New(c) end
        c.flashAnim:PingPong(0.2, 1.0, 400, 6)
    end
end

-- -------------------------------------------------------------------
-- apply state visuals
-- -------------------------------------------------------------------

function T.UI_ApplyState(c, timer)
    local locked = T.IsLocked(timer.id)

    -- Determine which toggle control to show based on ICON_MODE
    if ICON_MODE then
        c.toggleBtn:SetHidden(true)
        c.toggleBtnIcon:SetHidden(false)

        if timer.expired then
            c.toggleBtnIcon:SetNormalTexture("/esoui/art/miscellaneous/restart_up.dds")
            c.toggleBtnIcon:SetMouseOverTexture("/esoui/art/miscellaneous/restart_up.dds")
            do local r,g,b = unpack(COLOR_EXPIRED); c.bg:SetEdgeColor(r,g,b, 0.95) end
        elseif timer.state == T.STATE_RUNNING then
            c.toggleBtnIcon:SetNormalTexture("/esoui/art/miscellaneous/pause_up.dds")
            c.toggleBtnIcon:SetMouseOverTexture("/esoui/art/miscellaneous/pause_up.dds")
            do local r,g,b = unpack(COLOR_RUNNING); c.bg:SetEdgeColor(r,g,b, 0.80) end
        else
            c.toggleBtnIcon:SetNormalTexture("/esoui/art/miscellaneous/play_up.dds")
            c.toggleBtnIcon:SetMouseOverTexture("/esoui/art/miscellaneous/play_up.dds")
            c.bg:SetEdgeColor(0.25, 0.55, 0.80, 0.70)
        end
    else
        -- Text glyph mode (default)
        c.toggleBtn:SetHidden(false)
        c.toggleBtnIcon:SetHidden(true)

        if timer.expired then
            c.toggleBtn:SetText("»")  -- restart: »
            do local r,g,b = unpack(COLOR_EXPIRED); c.toggleBtn:SetColor(r,g,b, 1) end
            do local r,g,b = unpack(COLOR_EXPIRED); c.bg:SetEdgeColor(r,g,b, 0.95) end
        elseif timer.state == T.STATE_RUNNING then
            c.toggleBtn:SetText("||")
            do local r,g,b = unpack(COLOR_RUNNING); c.toggleBtn:SetColor(r,g,b, 1) end
            do local r,g,b = unpack(COLOR_RUNNING); c.bg:SetEdgeColor(r,g,b, 0.80) end
        else
            c.toggleBtn:SetText(">")
            do local r,g,b = unpack(COLOR_STOPPED); c.toggleBtn:SetColor(r,g,b, 1) end
            c.bg:SetEdgeColor(0.25, 0.55, 0.80, 0.70)
        end
    end

    -- lock button texture + resize visibility
    if locked then
        -- Padlock closed = locked
        c.lockBtn:SetNormalTexture("/esoui/art/miscellaneous/locked_up.dds")
        c.lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/locked_up.dds")
    else
        -- Padlock open = unlocked
        c.lockBtn:SetNormalTexture("/esoui/art/miscellaneous/unlocked_up.dds")
        c.lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/unlocked_up.dds")
    end
    c.resizeHandle:SetHidden(locked)

    -- When locked, hide the close (X) button to prevent accidental deletion.
    -- Unlock to reveal it again.
    c.closeBtn:SetHidden(locked)
end

-- -------------------------------------------------------------------
-- countdown format
-- -------------------------------------------------------------------

local function FormatCountdown(remaining)
    if remaining <= 0 then return "0:00" end
    local totalSec = math.ceil(remaining)
    local mins = math.floor(totalSec / 60)
    local secs = totalSec % 60
    if mins >= 60 then
        local hrs = math.floor(mins / 60)
        mins = mins % 60
        return string.format("%d:%02d:%02d", hrs, mins, secs)
    end
    return string.format("%d:%02d", mins, secs)
end

-- -------------------------------------------------------------------
-- refresh loop (side-effect-free iteration; expiry queued)
-- -------------------------------------------------------------------

function T.UI_RefreshAll()
    if not timerPool then return end
    local expired = {}
    EachActive(function(c)
        if not c.timerId then return end
        local timer = T.GetTimer(c.timerId)
        if not timer then return end

        -- statusText (linked timers): show informative text instead of a dead
        -- "0:00" when there's no countdown to run (no prediction / active now).
        if timer.statusText then
            c.countdown:SetText(timer.statusText)
            c.countdown:SetColor(unpack(COLOR_STATUS))
        else
            local remaining = T.GetRemaining(c.timerId)
            c.countdown:SetText(FormatCountdown(remaining))

            if timer.state == T.STATE_RUNNING and remaining <= WARN_THRESHOLD then
                c.countdown:SetColor(unpack(COLOR_WARNING))
            else
                c.countdown:SetColor(unpack(COLOR_NORMAL))
            end

            if timer.state == T.STATE_RUNNING and remaining <= 0 then
                expired[#expired + 1] = c.timerId
            end
        end

        T.UI_ApplyState(c, timer)
    end)
    for _, id in ipairs(expired) do
        T.ExpireTimer(id)
    end
end

-- -------------------------------------------------------------------
-- label edit dialog
-- -------------------------------------------------------------------

function T.UI_PromptEditLabel(id)
    local timer = T.GetTimer(id)
    if not timer then return end
    ShowEditDialog("Timer Name", timer.label, function(text)
        if text and text ~= "" then T.SetLabel(id, text) end
    end)
end

-- -------------------------------------------------------------------
-- duration edit dialog  (accepts "60", "1:30", "90m", "45s")
-- -------------------------------------------------------------------

function T.UI_PromptEditDuration(id)
    local timer = T.GetTimer(id)
    if not timer then return end
    local d = timer.duration or 60
    local defaultText
    if d >= 60 then
        defaultText = string.format("%d:%02d", math.floor(d / 60), d % 60)
    else
        defaultText = tostring(d) .. "s"
    end
    ShowEditDialog("Duration", defaultText, function(text)
        local secs = T.ParseDuration(text)
        if secs then
            T.SetDuration(id, secs)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE,
                "Invalid duration. Use minutes (60), MM:SS (1:30), or suffix (90m).")
        end
    end)
end
