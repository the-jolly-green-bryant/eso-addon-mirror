-- =============================================================================
-- GroupGCDTracker_UI.lua  v1.3
-- =============================================================================
-- Draggable HUD panel.  Only members present in the current group are shown;
-- empty slots produce no row and the panel shrinks to fit.
-- When in a group the local player appears in a group slot, so the standalone
-- "player" tag is suppressed to prevent the name appearing twice.
-- A role indicator (D / H / T) is prepended to each member name.
-- Trans-pride colour scheme: navy backdrop · blue/pink bars · white text.
--
-- Toggle:         /ggcdui
-- Reposition:     drag the panel; position is saved to SavedVariables.
-- Settings:       LibAddonMenu-2.0 → "Group GCD Tracker" → HUD section.
-- =============================================================================

local ADDON_NAME = "GroupGCDTracker"
local GCDTracker = GroupGCDTracker   -- set by GroupGCDTracker.lua

-- ─── Layout constants ─────────────────────────────────────────────────────────
local FRAME_W    = 340
local ROW_H      = 26     -- timer label + bar
local ROW_PAD    = 1      -- gap between rows
local H_PAD      = 6      -- horizontal inset
local V_PAD      = 3      -- vertical inset before first row / after last
local HEADER_H   = 44     -- title(20) + sep + col-headers(18) + sep + pad
local NAME_W     = 86
local GCD_BAR_W  = 120
local PROX_BAR_W = 114
local BAR_GAP    = 4
local TIMER_H    = 14
local BAR_H      = 10
local MAX_ROWS   = 12
-- Width: 86 + 4 + 120 + 4 + 114 = 328 = FRAME_W - 2*H_PAD  ✓

-- ─── Colours ──────────────────────────────────────────────────────────────────
local C = {
    BORDER    = {0.357, 0.812, 0.980, 0.90},
    BG        = {0.051, 0.106, 0.165, 0.92},
    NAME_LIVE = {1.000, 1.000, 1.000, 1.00},
    COL_HDR   = {0.800, 0.800, 0.800, 0.80},
    BAR_BG    = {0.10,  0.10,  0.14,  0.80},
    GCD_FULL  = {0.180, 0.850, 0.180, 1.00},
    GCD_LOW   = {1.000, 0.200, 0.200, 1.00},
    PROX_FULL = {0.180, 0.850, 0.180, 1.00},
    PROX_HIGH = {1.000, 0.200, 0.200, 1.00},
    BAR_TEXT  = {1.000, 1.000, 1.000, 1.00},
    TITLE     = {0.357, 0.812, 0.980, 1.00},
}

-- ─── State ────────────────────────────────────────────────────────────────────
local frame          = nil
local rows           = {}      -- pool of MAX_ROWS pre-created row tables
local accumDt        = 0
local activeRowCount = 0       -- rows currently visible
local prevActiveTags = {}      -- change-detection: last active tag list
local prevShowGCD    = nil     -- change-detection: GCD column visibility (nil forces first-run apply)
local gcdHdrControl  = nil     -- GCD column header label
local proxHdrControl = nil     -- DET IN column header label
local memberHdrControl = nil   -- Member column header label
local titleControl   = nil     -- panel title label
local UPDATE_HZ      = 0.05   -- ~20 fps

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function Lerp4(t, c1, c2)
    return c1[1] + t * (c2[1] - c1[1]),
           c1[2] + t * (c2[2] - c1[2]),
           c1[3] + t * (c2[3] - c1[3]),
           c1[4] + t * (c2[4] - c1[4])
end

local function WHITE() return "/esoui/art/miscellaneous/progressbar_genericfill.dds" end

local function NameFont()
    local sz = (GCDTracker.settings and GCDTracker.settings.fontSizeName) or 20
    return "EsoUI/Common/Fonts/Univers67.otf|" .. sz .. "|soft-shadow-thick"
end

local function TimerFont()
    local sz = (GCDTracker.settings and GCDTracker.settings.fontSizeTimer) or 16
    return "EsoUI/Common/Fonts/Univers57.otf|" .. sz .. "|soft-shadow-thin"
end

local function HeaderFont()
    local sz = (GCDTracker.settings and GCDTracker.settings.fontSizeHeader) or 22
    return "EsoUI/Common/Fonts/Univers67.otf|" .. sz .. "|soft-shadow-thick"
end

--- Return a short coloured role prefix ("D ", "H ", "T ", or "") for a unitTag.
-- Reads GetGroupMemberRole(index) for group slots, GetSelectedLFGRole() for solo.
-- Handles both single-value and bitmask role returns.
local function GetRolePrefix(tag)
    local role = 0
    if tag == "player" then
        role = (GetSelectedLFGRole and GetSelectedLFGRole()) or 0
    else
        local idx = tonumber(tag:sub(6))
        if idx then
            role = (GetGroupMemberRole and GetGroupMemberRole(idx)) or 0
        end
    end
    if role == 0 then return "" end
    local t = LFG_ROLE_TANK or 4
    local h = LFG_ROLE_HEAL or 2
    local d = LFG_ROLE_DPS  or 1
    if (role % (t * 2)) >= t then return "|cFFD700T|r " end   -- Tank: gold
    if (role % (h * 2)) >= h then return "|c5BCEFAH|r " end   -- Heal: blue
    if (role % (d * 2)) >= d then return "|cF5A9B8D|r " end   -- DPS:  pink
    return ""
end

--- Returns true when the unit's selected LFG role is NOT Tank or Healer.
-- Units with role=0 (unassigned) are treated as DPS.
local function IsDPS(tag)
    local role = 0
    if tag == "player" then
        role = (GetSelectedLFGRole and GetSelectedLFGRole()) or 0
    else
        local idx = tonumber(tag:sub(6))
        if idx then
            role = (GetGroupMemberRole and GetGroupMemberRole(idx)) or 0
        end
    end
    local t = LFG_ROLE_TANK or 4
    local h = LFG_ROLE_HEAL or 2
    if (role % (t * 2)) >= t then return false end  -- Tank
    if (role % (h * 2)) >= h then return false end  -- Healer
    return true
end

--- Returns true when unitTag (or its player alias) has an armed prox det.
local function HasArmedProxDet(tag)
    local pd = GCDTracker._proxState[tag]
    if pd and pd.armed then return true end
    -- The local player appears under "player" in _proxState even when they
    -- occupy a numbered group slot; check the alias too.
    if tag ~= "player" then
        local gn = GetUnitName(tag)
        local pn = GetUnitName("player")
        if gn and pn and gn == pn then
            pd = GCDTracker._proxState["player"]
            if pd and pd.armed then return true end
        end
    end
    return false
end

--- Compute frame height for a given number of member rows.
local function CalcFrameH(n)
    if n < 1 then n = 1 end
    return HEADER_H + V_PAD + n * (ROW_H + ROW_PAD) - ROW_PAD + V_PAD
end

--- Apply auto-fit scale so the panel never overflows the screen.
-- uiScale from settings is treated as the upper bound.
local function ApplyFitScale(h)
    local sw, sh    = GuiRoot:GetWidth(), GuiRoot:GetHeight()
    local userScale = GCDTracker.settings.uiScale or 1.0
    frame:SetScale(math.min(userScale, sw / FRAME_W * 0.97, sh / h * 0.97))
end

-- ─── Row pool builder ─────────────────────────────────────────────────────────

--- Pre-create all controls for one pool row, anchored directly to the frame.
-- row:Reposition(yOff) moves each control individually when layout changes.
-- All controls are hidden until the OnUpdate loop assigns the row to an active unit.
local function CreateRow(parent)
    local row = {}
    local gcdX    = H_PAD + NAME_W + BAR_GAP
    local proxX   = gcdX + GCD_BAR_W + BAR_GAP
    local initY   = HEADER_H + V_PAD          -- row-1 y; all rows start here, hidden before render
    local initBarY = initY + TIMER_H

    -- Controls are created VISIBLE at a valid on-screen position so that ESO's
    -- render pipeline registers them.  SetHidden(false) is called explicitly to
    -- ensure this in all build variants.  row:SetVisible(false) at the end of
    -- this function hides them before the first frame renders (same Lua tick).
    -- This "prime" pattern avoids the xb1cert quirk where controls that are born
    -- hidden (SetHidden(true) at creation) can never be made visible later.

    row.name = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    row.name:SetFont(NameFont())
    row.name:SetColor(unpack(C.NAME_LIVE))
    row.name:SetText("")
    row.name:SetWidth(NAME_W)
    row.name:SetHeight(ROW_H)
    row.name:SetAnchor(TOPLEFT, parent, TOPLEFT, H_PAD, initY)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.name:SetHidden(false)

    row.gcdTimer = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    row.gcdTimer:SetFont(TimerFont())
    row.gcdTimer:SetColor(unpack(C.BAR_TEXT))
    row.gcdTimer:SetText("")
    row.gcdTimer:SetWidth(GCD_BAR_W)
    row.gcdTimer:SetHeight(TIMER_H)
    row.gcdTimer:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, initY)
    row.gcdTimer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.gcdTimer:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    row.gcdTimer:SetHidden(false)

    row.gcdBg = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    row.gcdBg:SetTexture(WHITE())
    row.gcdBg:SetColor(unpack(C.BAR_BG))
    row.gcdBg:SetDimensions(GCD_BAR_W, BAR_H)
    row.gcdBg:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, initBarY)
    row.gcdBg:SetHidden(false)

    row.gcdBar = WINDOW_MANAGER:CreateControl(nil, parent, CT_STATUSBAR)
    row.gcdBar:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    row.gcdBar:SetColor(unpack(C.GCD_FULL))
    row.gcdBar:SetDimensions(GCD_BAR_W, BAR_H)  -- full width: prime needs real pixels
    row.gcdBar:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, initBarY)
    row.gcdBar:SetMinMax(0, 1)
    row.gcdBar:SetHidden(false)

    row.proxTimer = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    row.proxTimer:SetFont(TimerFont())
    row.proxTimer:SetColor(unpack(C.BAR_TEXT))
    row.proxTimer:SetText("")
    row.proxTimer:SetWidth(PROX_BAR_W)
    row.proxTimer:SetHeight(TIMER_H)
    row.proxTimer:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, initY)
    row.proxTimer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.proxTimer:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    row.proxTimer:SetHidden(false)

    row.proxBg = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    row.proxBg:SetTexture(WHITE())
    row.proxBg:SetColor(unpack(C.BAR_BG))
    row.proxBg:SetDimensions(PROX_BAR_W, BAR_H)
    row.proxBg:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, initBarY)
    row.proxBg:SetHidden(false)

    row.proxBar = WINDOW_MANAGER:CreateControl(nil, parent, CT_STATUSBAR)
    row.proxBar:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    row.proxBar:SetColor(unpack(C.PROX_FULL))
    row.proxBar:SetMinMax(0, 1)
    row.proxBar:SetDimensions(PROX_BAR_W, BAR_H)  -- full width: prime needs real pixels
    
    row.proxBar:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, initBarY)

    row.proxBar:SetHidden(false)

    --- Reanchor all row controls to a new y-offset within the frame.
    function row:Reposition(yOff)
        self._yOff = yOff   -- stored so ApplyGCDVisibility can re-anchor prox controls
        local barY = yOff + TIMER_H
        self.name:ClearAnchors()
        self.name:SetAnchor(TOPLEFT, parent, TOPLEFT, H_PAD, yOff)
        self.gcdTimer:ClearAnchors()
        self.gcdTimer:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, yOff)
        self.gcdBg:ClearAnchors()
        self.gcdBg:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, barY)
        self.gcdBar:ClearAnchors()
        self.gcdBar:SetAnchor(TOPLEFT, parent, TOPLEFT, gcdX, barY)
        self.proxTimer:ClearAnchors()
        self.proxTimer:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, yOff)
        self.proxBg:ClearAnchors()
        self.proxBg:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, barY)
        self.proxBar:ClearAnchors()
        self.proxBar:SetAnchor(TOPLEFT, parent, TOPLEFT, proxX, barY)
    end

    --- Show or hide the GCD column; expand/contract the DET bar to fill the space.
    function row:ApplyGCDVisibility(showGCD)
        local yOff = self._yOff or initY
        local barY = yOff + TIMER_H
        local detX = showGCD and proxX or gcdX
        local detW = showGCD and PROX_BAR_W or (GCD_BAR_W + BAR_GAP + PROX_BAR_W)

        self.gcdTimer:SetHidden(not showGCD)
        self.gcdBg:SetHidden(not showGCD)
        self.gcdBar:SetHidden(not showGCD)

        self.proxTimer:ClearAnchors()
        self.proxTimer:SetAnchor(TOPLEFT, parent, TOPLEFT, detX, yOff)
        self.proxTimer:SetWidth(detW)
        self.proxBg:ClearAnchors()
        self.proxBg:SetAnchor(TOPLEFT, parent, TOPLEFT, detX, barY)
        self.proxBg:SetDimensions(detW, BAR_H)
        self.proxBar:ClearAnchors()
        self.proxBar:SetAnchor(TOPLEFT, parent, TOPLEFT, detX, barY)
        self.proxBar:SetDimensions(detW, BAR_H)
    end

    --- Show or hide all controls in this row.
    function row:SetVisible(visible)
        local h = not visible
        if h then
            -- Zero bar fill before hiding so OnUpdate always starts from 0
            self.gcdBar:SetValue(0)
            self.proxBar:SetValue(0)
        end
        self.name:SetHidden(h)
        self.gcdTimer:SetHidden(h)
        self.gcdBg:SetHidden(h)
        self.gcdBar:SetHidden(h)
        self.proxTimer:SetHidden(h)
        self.proxBg:SetHidden(h)
        self.proxBar:SetHidden(h)
    end

    -- Prime: hide after render-pipeline inclusion (no visible flash — all happens
    -- in the same Lua tick as BuildFrame, before the first frame is drawn).
    row:SetVisible(false)
    return row
end

-- ─── Frame builder ────────────────────────────────────────────────────────────

local function BuildFrame()
    local initH = CalcFrameH(1)   -- starts at 1-row height; expands in OnUpdate

    -- CreateTopLevelWindow is the correct frame type for a draggable ESO HUD.
    -- Row controls use a "prime" pattern: created visible, hidden immediately,
    -- so SetHidden can reliably toggle them later (xb1cert render-pipeline fix).
    frame = WINDOW_MANAGER:CreateTopLevelWindow("GroupGCDTrackerFrame")
    frame:SetDimensions(FRAME_W, initH)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetAlpha(GCDTracker.settings.uiOpacity or 0.9)

    -- Initial auto-fit scale
    local sw, sh    = GuiRoot:GetWidth(), GuiRoot:GetHeight()
    local userScale = GCDTracker.settings.uiScale or 1.0
    local fitScale  = math.min(userScale, sw / FRAME_W * 0.97, sh / initH * 0.97)
    frame:SetScale(fitScale)

    -- Restore saved position, clamped so the panel is fully on-screen
    local sx, sy = GCDTracker.settings.uiX, GCDTracker.settings.uiY
    if sx and sy then
        local maxX = math.max(0, sw - FRAME_W * fitScale)
        local maxY = math.max(0, sh - initH  * fitScale)
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            math.max(0, math.min(sx, maxX)),
            math.max(0, math.min(sy, maxY)))
    else
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    end

    frame:SetHandler("OnMoveStop", function(ctrl)
        GCDTracker.settings.uiX = ctrl:GetLeft()
        GCDTracker.settings.uiY = ctrl:GetTop()
    end)

    -- ── Title ─────────────────────────────────────────────────────────────────
    titleControl = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    titleControl:SetFont(HeaderFont())
    titleControl:SetColor(unpack(C.TITLE))
    titleControl:SetText("|c5BCEFAGroup GCD Tracker|r")
    titleControl:SetAnchor(TOPLEFT, frame, TOPLEFT, H_PAD, 0)
    titleControl:SetHeight(20)
    titleControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local sep1 = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    sep1:SetTexture(WHITE())
    sep1:SetColor(unpack(C.BORDER))
    sep1:SetDimensions(FRAME_W - H_PAD * 2, 1)
    sep1:SetAnchor(TOPLEFT, frame, TOPLEFT, H_PAD, 20)

    -- ── Column headers ────────────────────────────────────────────────────────
    local function ColHdr(text, x, w, col)
        local lbl = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
        lbl:SetFont(HeaderFont())
        lbl:SetColor(unpack(col or C.COL_HDR))
        lbl:SetText(text)
        lbl:SetWidth(w)
        lbl:SetHeight(18)
        lbl:SetAnchor(TOPLEFT, frame, TOPLEFT, x, 22)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return lbl
    end
    local gcdHdrX  = H_PAD + NAME_W + BAR_GAP
    local proxHdrX = gcdHdrX + GCD_BAR_W + BAR_GAP
    memberHdrControl = ColHdr("Member",  H_PAD,      NAME_W,      C.COL_HDR)
    gcdHdrControl  = ColHdr("GCD",    gcdHdrX,  GCD_BAR_W,   C.GCD_FULL)
    proxHdrControl = ColHdr("DET IN", proxHdrX, PROX_BAR_W,  C.PROX_FULL)

    local sep2 = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    sep2:SetTexture(WHITE())
    sep2:SetColor(unpack(C.BORDER))
    sep2:SetDimensions(FRAME_W - H_PAD * 2, 1)
    sep2:SetAnchor(TOPLEFT, frame, TOPLEFT, H_PAD, 41)

    -- ── Pre-create row pool (all hidden until assigned) ───────────────────────
    rows = {}
    for i = 1, MAX_ROWS do
        rows[i] = CreateRow(frame)
    end

    -- ── Per-frame update ──────────────────────────────────────────────────────
    -- NOTE: Registered on EVENT_MANAGER (not on frame) so that the loop keeps
    -- firing even when frame:SetHidden(true) is called (e.g. after detonation).
    -- ESO stops OnUpdate for hidden controls, which would prevent the frame from
    -- ever detecting the next armed prox-det and re-showing itself.
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_UI")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_UI", UPDATE_HZ * 1000, function()
        local elapsed = UPDATE_HZ   -- fixed interval; accumDt throttle not needed
        accumDt = accumDt + elapsed
        if accumDt < UPDATE_HZ then return end
        accumDt = accumDt - UPDATE_HZ

        -- ── 1. Build active unit list ───────────────────────────────────────
        -- Show all existing group members so GCD bars are always visible.
        -- Prox-det bars appear within these same rows when a detonation is armed.
        local active    = {}
        local groupSize = (GetGroupSize and GetGroupSize()) or 0
        if groupSize > 1 then
            for i = 1, math.min(groupSize, MAX_ROWS) do
                local t = "group" .. i
                if DoesUnitExist(t) then
                    active[#active + 1] = t
                end
            end
        else
            if DoesUnitExist("player") then
                active[1] = "player"
            end
        end

        local count = #active

        -- ── 2. Reposition row pool if group composition changed ─────────────
        local changed = (count ~= activeRowCount)
        if not changed then
            for i = 1, count do
                if prevActiveTags[i] ~= active[i] then
                    changed = true
                    break
                end
            end
        end

        if changed then
            activeRowCount = count
            prevActiveTags = {}
            for i = 1, count do prevActiveTags[i] = active[i] end

            for i = 1, MAX_ROWS do
                local row = rows[i]
                if i <= count then
                    local yOff = HEADER_H + V_PAD + (i - 1) * (ROW_H + ROW_PAD)
                    row:Reposition(yOff)
                    row:SetVisible(true)
                    row.unitTag = active[i]
                    row:ApplyGCDVisibility(not GCDTracker.settings.hideGCD)
                else
                    row:SetVisible(false)
                    row.unitTag = nil
                end
            end

            -- Resize and show/hide the panel based on active prox-det users.
            if count > 0 then
                local newH = CalcFrameH(count)
                frame:SetDimensions(FRAME_W, newH)
                ApplyFitScale(newH)
                frame:SetHidden(not GCDTracker.settings.showUI)
            else
                frame:SetHidden(true)
            end
        end

        -- ── GCD column visibility change ────────────────────────────────────
        local showGCD = not GCDTracker.settings.hideGCD
        if showGCD ~= prevShowGCD then
            prevShowGCD = showGCD
            if gcdHdrControl then gcdHdrControl:SetHidden(not showGCD) end
            if proxHdrControl then
                local hdrDetX = showGCD and (H_PAD + NAME_W + BAR_GAP + GCD_BAR_W + BAR_GAP)
                                         or (H_PAD + NAME_W + BAR_GAP)
                local hdrDetW = showGCD and PROX_BAR_W or (GCD_BAR_W + BAR_GAP + PROX_BAR_W)
                proxHdrControl:ClearAnchors()
                proxHdrControl:SetAnchor(TOPLEFT, frame, TOPLEFT, hdrDetX, 22)
                proxHdrControl:SetWidth(hdrDetW)
            end
            for i = 1, activeRowCount do
                if rows[i].unitTag then rows[i]:ApplyGCDVisibility(showGCD) end
            end
        end

        -- ── 3. Skip data updates if disabled ───────────────────────────────
        if not GCDTracker.settings.enabled
        or not GCDTracker.settings.showUI then return end

        local S   = GCDTracker.settings
        local now = GetGameTimeMilliseconds()

        -- ── 4. Update bars / labels for each visible row ────────────────────
        for i = 1, count do
            local row = rows[i]
            local tag = row.unitTag
            if not tag then break end

            -- Name with role prefix
            local raw      = GetUnitName(tag) or GetRawUnitName(tag) or tag
            local stripped = raw:match("^%^[MFNmfn](.+)$") or raw
            local name     = stripped:match("^([^@]+)") or stripped
            row.name:SetText(GetRolePrefix(tag) .. name)
            row.name:SetColor(unpack(S.colorNameLive))

            -- ESO's EVENT_EFFECT_CHANGED always keys the local player's state under
            -- "player" even when they occupy a group slot.  Detect this and resolve
            -- so both GCD and prox-det state are found regardless of event path.
            local stateTag = tag
            if tag ~= "player" then
                local gn = GetUnitName(tag)
                local pn = GetUnitName("player")
                if gn and pn and gn == pn then stateTag = "player" end
            end

            -- GCD bar (depletes left ? 0 as cooldown counts down)
            local gs = GCDTracker._gcdState[stateTag] or GCDTracker._gcdState[tag]
            if gs and gs.onGCD and gs.endTime > now then
                local dur = gs.endTime - gs.startTime
                local pct = math.max(0, (gs.endTime - now) / dur)
                row.gcdBar:SetValue(pct)
                if pct > 0.3 then
                    row.gcdBar:SetColor(unpack(S.colorGcdFull))
                else
                    row.gcdBar:SetColor(Lerp4(pct / 0.3, S.colorGcdLow, S.colorGcdFull))
                end
                row.gcdTimer:SetText(string.format("%.1fs", (gs.endTime - now) / 1000))
                row.gcdTimer:SetColor(unpack(S.colorBarText))
            else
                row.gcdBar:SetValue(0)
                if gs and gs.abilityName and gs.abilityName ~= "" then
                    row.gcdTimer:SetText(gs.abilityName)
                    row.gcdTimer:SetColor(0.60, 0.60, 0.60, 0.60)
                else
                    row.gcdTimer:SetText("")
                end
            end

            -- DET bar (remaining time shown as fraction of total duration)
            local pd = GCDTracker._proxState[stateTag] or GCDTracker._proxState[tag]
            if pd and not pd.armed then pd = nil end
            if pd then
                local dur       = pd.durationMs or S.proxDetDefaultDurationMs or 10000
                local endMs     = pd.endMs or (pd.startMs + dur)
                local remaining = math.max(0, endMs - now)
                local pct       = remaining / dur           -- 1 → 0
                if pct > 0.7 then
                    row.proxBar:SetColor(unpack(S.colorDetFull))
                    row.proxBar:SetValue(pct)
                else
                    row.proxBar:SetColor(Lerp4(pct / 0.6, S.colorDetHigh, S.colorDetFull))
                    row.proxBar:SetValue(pct)
                end
                row.proxTimer:SetText(string.format("%.1fs", remaining / 1000))
                row.proxTimer:SetColor(unpack(S.colorBarText))
            else
                row.proxBar:SetValue(0)
                row.proxTimer:SetText("")
            end
        end
    end)

    frame:SetHidden(not GCDTracker.settings.showUI)
end

-- ─── Public API (called from GroupGCDTracker.lua and LAM2 callbacks) ──────────

function GCDTracker:SetUIVisible(visible)
    if frame then frame:SetHidden(not visible) end
    self.settings.showUI = visible
end

function GCDTracker:SetUIOpacity(alpha)
    if frame then frame:SetAlpha(alpha) end
    self.settings.uiOpacity = alpha
end

function GCDTracker:SetUIScale(scale)
    self.settings.uiScale = scale   -- set first so ApplyFitScale reads new value
    if frame then
        ApplyFitScale(CalcFrameH(math.max(1, activeRowCount)))
    end
end

function GCDTracker:MoveUITo(x, y)
    if not frame then return end
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    self.settings.uiX = x
    self.settings.uiY = y
end

function GCDTracker:ResetUIPosition()
    if not frame then return end
    frame:ClearAnchors()
    frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.settings.uiX = nil
    self.settings.uiY = nil
end

function GCDTracker:RefreshFonts()
    if not frame then return end
    local nf = NameFont()
    local tf = TimerFont()
    local hf = HeaderFont()
    for _, row in ipairs(rows) do
        row.name:SetFont(nf)
        row.gcdTimer:SetFont(tf)
        row.proxTimer:SetFont(tf)
    end
    if titleControl      then titleControl:SetFont(hf)      end
    if memberHdrControl  then memberHdrControl:SetFont(hf)  end
    if gcdHdrControl     then gcdHdrControl:SetFont(hf)     end
    if proxHdrControl    then proxHdrControl:SetFont(hf)    end
end

function GCDTracker:ToggleUI()
    self:SetUIVisible(not self.settings.showUI)
end

function GCDTracker:InitUI()
    BuildFrame()
    SLASH_COMMANDS["/ggcdui"] = function() GCDTracker:ToggleUI() end
end
