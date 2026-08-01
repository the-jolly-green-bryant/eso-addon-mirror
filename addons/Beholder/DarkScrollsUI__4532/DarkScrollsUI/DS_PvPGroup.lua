-----------------------------------------------------------
-- DarkScrollsUI - DS_PvPGroup.lua
-- Custom group health bars with Bloodborne-style animation.
-- Disables native group frames and replaces them fully.
-----------------------------------------------------------

local GROUP_MAX     = 8
local BAR_H_DEFAULT = 8
local ROW_PADDING   = 15

-----------------------------------------------------------
-- VISUAL CONFIGURATION
-----------------------------------------------------------
local GroupBarVisualConfiguration = {
    DRAIN_LINGER_MS = 500,
    FILL_SPEED      = 0.8,
    TEX_DIRTY       = "DarkScrollsUI/Images/bar_dirty.dds",
    TEX_EDGE        = "DarkScrollsUI/Images/bar_edge.dds",
    EDGE_WIDTH      = 5,
    BG_COLOR        = {0.06, 0.06, 0.06, 0.95},
    BORDER_COLOR    = {0.45, 0.45, 0.45, 1},
}

-----------------------------------------------------------
-- DISABLE NATIVE GROUP FRAMES
-----------------------------------------------------------
function DarkScrollsUI.DisableNativeESOPlayerGroupFrames()
    ZO_UnitFramesGroups:SetHidden(true)
    zo_callLater(function()
        if UNIT_FRAMES and UNIT_FRAMES.DisableGroupAndRaidFrames then
            UNIT_FRAMES:DisableGroupAndRaidFrames()
        end
    end, 100)

    ZO_UnitFrames:UnregisterForEvent(EVENT_GROUP_UPDATE)
    ZO_UnitFrames:UnregisterForEvent(EVENT_GROUP_MEMBER_LEFT)
    ZO_UnitFrames:UnregisterForEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS)
end

-----------------------------------------------------------
-- PER-ROW ANIMATION (OnUpdate)
-----------------------------------------------------------
local function RowOnUpdate(self, timeSec)
    if self:IsHidden() or not self.fill or not self.drain or not self.dirty then return end

    local dt = timeSec - (self.lastTime or timeSec)
    self.lastTime = timeSec

    local a = self.animData
    if not a then return end

    -- Smooth fill interpolation
    local diff = a.targetPct - a.currentPct
    if math.abs(diff) > 0.001 then
        local step = GroupBarVisualConfiguration.FILL_SPEED * dt
        a.currentPct = diff > 0
            and math.min(a.currentPct + step, a.targetPct)
            or  math.max(a.currentPct - step, a.targetPct)
    else
        a.currentPct = a.targetPct
    end

    -- Orange damage trail
    if a.currentPct < a.drainPct then
        if GetGameTimeMilliseconds() > a.drainTimer then
            local drainStep = (GroupBarVisualConfiguration.FILL_SPEED * 0.5) * dt
            a.drainPct = math.max(a.drainPct - drainStep, a.currentPct)
        end
    else
        a.drainPct = a.currentPct
    end

    local maxW  = self.bar:GetWidth()
    local fillW  = math.max(1, maxW * a.currentPct)
    local drainW = math.max(1, maxW * a.drainPct)

    self.fill:SetWidth(fillW)
    self.dirty:SetWidth(fillW)
    self.drain:SetWidth(drainW)

    -- Dirty texture UV scroll
    local shift = (timeSec * 0.05) % 1
    self.dirty:SetTextureCoords(shift, shift + 1, 0, 1)
end

-----------------------------------------------------------
-- MEMBER BAR UPDATE
-----------------------------------------------------------
local function UpdateMemberBar(row, unitTag, isFakePct)
    if not row then return end

    local pct  = 0
    local name = ""

    if isFakePct then
        pct  = isFakePct
        name = "Group Member"
    else
        local isValid = IsUnitOnline and IsUnitOnline(unitTag)
        if not isValid or GetUnitName(unitTag) == "" then
            row:SetHidden(true)
            row.animData.initialized = false
            return
        end

        name = GetUnitName(unitTag)
        local hp, maxHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)
        maxHp = (maxHp and maxHp > 0) and maxHp or 1
        pct   = zo_clamp(hp / maxHp, 0, 1)
    end

    row.label:SetText(zo_strformat("<<1>>", name))

    local a = row.animData
    if not a.initialized then
        a.currentPct   = pct
        a.drainPct     = pct
        a.targetPct    = pct
        a.initialized  = true
    end

    if pct < a.targetPct then
        a.drainTimer = GetGameTimeMilliseconds() + GroupBarVisualConfiguration.DRAIN_LINGER_MS
    end
    if pct > a.targetPct then
        a.drainPct = math.max(a.drainPct, pct)
    end
    a.targetPct = pct

    row.fill:SetColor(0.6, 0, 0, 1)
    row:SetHidden(false)
end

-----------------------------------------------------------
-- GROUP FRAME UPDATE
-----------------------------------------------------------
function DarkScrollsUI.UpdatePvPGroupMemberInformation()
    local frame = DarkScrollsUI.PlayerGroupFrameDisplay
    if not frame then return end

    ZO_UnitFramesGroups:SetHidden(true)

    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive
    local inGroup   = IsUnitGrouped and IsUnitGrouped("player")

    if not inGroup and not isEditing then
        frame:SetHidden(true)
        return
    end

    local baseAlpha = (DarkScrollsUI.SavedVariables["DarkScrollsUI_PlayerGroupStatusFrame"] and DarkScrollsUI.SavedVariables["DarkScrollsUI_PlayerGroupStatusFrame"].a) or 1
    frame:SetAlpha(baseAlpha * (DarkScrollsUI.globalInterfaceFadeAlpha or 1))
    frame:SetHidden(false)

    if isEditing then
        for i = 1, GROUP_MAX do
            UpdateMemberBar(frame.rows[i], nil, 1 - (i - 1) * 0.15)
        end
    else
        for i = 1, GROUP_MAX do
            UpdateMemberBar(frame.rows[i], "group" .. i)
        end
    end
end

-----------------------------------------------------------
-- GROUP FRAME CREATION
-----------------------------------------------------------
function DarkScrollsUI.CreatePvPGroupFrameDisplay()
    DarkScrollsUI.DisableNativeESOPlayerGroupFrames()

    local wm   = WINDOW_MANAGER
    local name = "DarkScrollsUI_PlayerGroupStatusFrame"
    local s    = DarkScrollsUI.SavedVariables[name] or { l = 30, t = 300, w = 240, h = 180, a = 1, fs = 1 }
    DarkScrollsUI.SavedVariables[name] = s

    local frame = wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_BACKGROUND)
    frame:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    frame:SetMovable(not DarkScrollsUI.isInterfaceLocked)
    frame:SetDimensions(s.w, s.h)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)

    frame.bg = wm:CreateControl(name.."BG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()

    frame.rows = {}
    local rowH = math.floor((s.h - (GROUP_MAX - 1) * ROW_PADDING) / GROUP_MAX)

    for i = 1, GROUP_MAX do
        local row = wm:CreateControl(name .. "Row" .. i, frame, CT_CONTROL)
        if i == 1 then
            row:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
        else
            row:SetAnchor(TOPLEFT, frame.rows[i - 1], BOTTOMLEFT, 0, ROW_PADDING)
        end
        row:SetDimensions(s.w, rowH)

        row.animData = { currentPct = 1, targetPct = 1, drainPct = 1, drainTimer = 0, initialized = false }

        row.label = wm:CreateControl(row:GetName() .. "Label", row, CT_LABEL)
        row.label:SetAnchor(TOPLEFT, row, TOPLEFT, 2, -15)
        row.label:SetFont("ZoFontWinH5")
        row.label:SetDimensions(s.w * 0.5, rowH * 0.5)
        row.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

        row.bar = wm:CreateControl(row:GetName() .. "Bar", row, CT_BACKDROP)
        row.bar:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
        row.bar:SetDimensions(s.w * 0.5, BAR_H_DEFAULT)
        row.bar:SetCenterColor(unpack(GroupBarVisualConfiguration.BG_COLOR))
        row.bar:SetEdgeColor(unpack(GroupBarVisualConfiguration.BORDER_COLOR))
        row.bar:SetEdgeTexture("", 1, 1, 1)
        row.bar:SetDrawTier(DT_LOW)

        row.drain = wm:CreateControl(row:GetName() .. "Drain", row.bar, CT_TEXTURE)
        row.drain:SetAnchor(LEFT, row.bar, LEFT, 0, 0)
        row.drain:SetDimensions(s.w * 0.5, BAR_H_DEFAULT)
        row.drain:SetColor(0.8, 0.4, 0, 1)
        row.drain:SetDrawTier(DT_MEDIUM)
        row.drain:SetDrawLevel(1)

        row.fill = wm:CreateControl(row:GetName() .. "Fill", row.bar, CT_TEXTURE)
        row.fill:SetAnchor(LEFT, row.bar, LEFT, 0, 0)
        row.fill:SetDimensions(s.w * 0.5, BAR_H_DEFAULT)
        row.fill:SetDrawTier(DT_MEDIUM)
        row.fill:SetDrawLevel(2)

        row.dirty = wm:CreateControl(row:GetName() .. "Dirty", row.bar, CT_TEXTURE)
        row.dirty:SetAnchor(LEFT, row.bar, LEFT, 0, 0)
        row.dirty:SetDimensions(s.w * 0.5, BAR_H_DEFAULT)
        row.dirty:SetTexture(GroupBarVisualConfiguration.TEX_DIRTY)
        row.dirty:SetAddressMode(TEX_MODE_WRAP)
        row.dirty:SetAlpha(0.5)
        row.dirty:SetDrawTier(DT_MEDIUM)
        row.dirty:SetDrawLevel(3)

        row.edge = wm:CreateControl(row:GetName() .. "Edge", row.bar, CT_TEXTURE)
        row.edge:SetAnchor(RIGHT, row.fill, RIGHT, GroupBarVisualConfiguration.EDGE_WIDTH / 2, 0)
        row.edge:SetDimensions(GroupBarVisualConfiguration.EDGE_WIDTH, BAR_H_DEFAULT)
        row.edge:SetTexture(GroupBarVisualConfiguration.TEX_EDGE)
        row.edge:SetBlendMode(TEX_BLEND_MODE_ADD)
        row.edge:SetDrawTier(DT_HIGH)

        row.buffs = wm:CreateControlFromVirtual(row:GetName() .. "Buffs", row, "ZO_BuffDebuffContainerTemplate")
        row.buffs:SetAnchor(LEFT, row.bar, RIGHT, 10, 0)
        row.buffs:SetDimensions(100, BAR_H_DEFAULT)

        row:SetHandler("OnUpdate", RowOnUpdate)
        row:SetHidden(true)
        frame.rows[i] = row
    end

    DarkScrollsUI.PlayerGroupFrameDisplay = frame

    if DarkScrollsUI.SetupCommonInterfaceHandlers then DarkScrollsUI.SetupCommonInterfaceHandlers(frame) end
    if DarkScrollsUI.UpdateElementTextScaleValue     then DarkScrollsUI.UpdateElementTextScaleValue(frame)     end

    frame.bg:SetCenterColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.4)
    frame.bg:SetEdgeColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.8)
    frame.bg:SetEdgeTexture("", 1, 1, 2)

    local evNames = { EVENT_POWER_UPDATE, EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_UNIT_DEATH_STATE_CHANGED }
    for _, ev in ipairs(evNames) do
        EVENT_MANAGER:RegisterForEvent(name .. ev, ev, function() DarkScrollsUI.UpdatePvPGroupMemberInformation() end)
    end

    DarkScrollsUI.UpdatePvPGroupMemberInformation()
end
