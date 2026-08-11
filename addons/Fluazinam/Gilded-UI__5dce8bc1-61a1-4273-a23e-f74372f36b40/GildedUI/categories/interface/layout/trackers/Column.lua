if not GildedUI then return end

local Addon = GildedUI

-- Unused in apply (kept for existing saves).
local DEFAULT_POS_X = 1645
local DEFAULT_POS_Y = 0
local DEFAULT_SCALE = 1
local SCALE_MIN = 0.5
local SCALE_MAX = 1.5

-- Stock gamepad EndDun: TOPLEFT to GuiRoot TOPRIGHT (-275, y).
local ROOT_INSET_X = -275
local RIGHT_EDGE_OFFSET_X = 0

Addon.limits = Addon.limits or {}
Addon.limits.trackerColumnScale = { min = SCALE_MIN, max = SCALE_MAX }

Addon:RegisterDefaults({
    trackerColumnPosX = DEFAULT_POS_X,
    trackerColumnPosY = DEFAULT_POS_Y,
    trackerColumnScale = DEFAULT_SCALE,
    trackerColumnShowPreview = false,
})

local TRACKER_CONTROL_NAMES = {
    "ZO_EndDunHUDTracker",
    "ZO_AdvZoneHUDTracker",
    "ZO_DynamicEventsTracker_TL",
    "ZO_FocusedQuestTrackerPanel",
    "ZO_ZoneStoryTracker",
    "ZO_PromotionalEventTracker_TL",
    "ZO_HouseInformationTrackerTopLevel",
    "ZO_ActivityTracker",
    "ZO_ReadyCheckTrackerTopLevel",
    "ZO_BattlegroundHUDFragmentTopLevel",
}

local GHOST_LABELS = {
    "Infinite Archive",
    "Adventure Zone",
    "Dynamic Events",
    "Focused Quest",
    "Zone Story",
    "Golden Pursuits",
    "House",
    "Activity Finder",
    "Ready Check / BG",
}

local ROOT_CONTROL_NAME = "ZO_EndDunHUDTracker"
local GHOST_WIDTH = 280
local GHOST_ROW_HEIGHT = 36
local GHOST_GAP = 4

function Addon:SanitizeTrackerColumn()
    local limits = self.limits
    self:ClampSavedNumber("trackerColumnPosX", limits.posX)
    self:ClampSavedNumber("trackerColumnPosY", limits.posY)
    self:ClampSavedNumber("trackerColumnScale", limits.trackerColumnScale)
    self:SanitizeSavedBoolean("trackerColumnShowPreview")
end

function Addon:GetTrackerColumnControls()
    local controls = {}
    for i = 1, #TRACKER_CONTROL_NAMES do
        local control = _G[TRACKER_CONTROL_NAMES[i]]
        if control then
            controls[#controls + 1] = control
        end
    end
    return controls
end

-- Only move the column root. Leave every other tracker TL on stock anchors.
function Addon:ApplyTrackerColumnRootPosition()
    local sv = self.state.sv
    local root = _G[ROOT_CONTROL_NAME]
    if not sv or not root then return end

    local posY = sv.trackerColumnPosY or DEFAULT_POS_Y
    root:ClearAnchors()
    root:SetAnchor(TOPLEFT, GuiRoot, TOPRIGHT, ROOT_INSET_X, posY)
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, RIGHT_EDGE_OFFSET_X, posY)
end

local function ResetScaleExtras(control)
    if control.SetTransformScale then
        control:SetTransformScale(1)
    end
end

-- Undo container-anchor experiments so ZOS stock insets (-15, quest timer layout) return.
-- Only touch the Container — full RefreshAnchors would also reset the TL (and our root move).
local function RestoreStockContainerLayout(control)
    local container = control:GetNamedChild("Container")
    if not container then return end

    ResetScaleExtras(container)
    container:SetScale(1)

    local owner = control.owner
    if owner and owner.RefreshAnchorSetOnControl and owner.currentStyle then
        local style = owner.currentStyle
        owner:RefreshAnchorSetOnControl(
            container,
            style.CONTAINER_PRIMARY_ANCHOR,
            style.CONTAINER_SECONDARY_ANCHOR
        )
        return
    end

    -- Quest panel is not ZO_HUDTracker_Base; restore fill + platform quest anchors.
    if control == _G["ZO_FocusedQuestTrackerPanel"] then
        container:ClearAnchors()
        container:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
        if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.ApplyPlatformStyle then
            FOCUSED_QUEST_TRACKER:ApplyPlatformStyle()
        end
    end
end

-- Scale each top-level only. Do not re-anchor Containers — quest's QuestContainer is
-- pinned to TimerAnchor (sibling of Container), and HUD trackers use a -15 content inset.
local function ApplyScaleToTrackerControl(control, scale)
    ResetScaleExtras(control)
    RestoreStockContainerLayout(control)
    control:SetScale(scale)
end

-- Promotional + House pin RIGHT → GuiRoot at -15; gamepad Activity only hangs under House,
-- so it sits 15px further in than Archive/Quest. Keep vertical primary, flush X to 0.
local FLUSH_RIGHT_CONTROL_NAMES = {
    "ZO_PromotionalEventTracker_TL",
    "ZO_HouseInformationTrackerTopLevel",
}

-- After TL flush, these need the same -15 content inset Archive uses (Activity gamepad
-- stock has no container right inset — flush TL alone made it hug the screen).
-- Ready Check (Tribute/LFG "Waiting for players") has a Container but no stock -15.
local CONTENT_RIGHT_INSET = 15
local CONTENT_INSET_CONTROL_NAMES = {
    "ZO_PromotionalEventTracker_TL",
    "ZO_HouseInformationTrackerTopLevel",
    "ZO_ActivityTracker",
    "ZO_ReadyCheckTrackerTopLevel",
}

local function FlushTrackerRightEdge(control)
    local owner = control.owner
    if not owner or not owner.GetPrimaryAnchor then return end

    local primary = owner:GetPrimaryAnchor()
    control:ClearAnchors()
    if primary then
        primary:AddToControl(control)
    end
    control:SetAnchor(RIGHT, GuiRoot, RIGHT, 0, 0, ANCHOR_CONSTRAINS_X)
end

local function ApplyTrackerContentRightInset(control)
    local container = control:GetNamedChild("Container")
    if not container then return end

    local owner = control.owner
    local style = owner and owner.currentStyle
    container:ClearAnchors()
    if style and style.CONTAINER_PRIMARY_ANCHOR then
        style.CONTAINER_PRIMARY_ANCHOR:AddToControl(container)
        container:SetAnchor(TOPRIGHT, nil, nil, -CONTENT_RIGHT_INSET, 0)
    else
        container:SetAnchor(TOPRIGHT, control, TOPRIGHT, -CONTENT_RIGHT_INSET, 0)
    end
end

-- BG HUD has no Container; stock hangs TOPRIGHT under Activity. Pull the TL in by -15.
local function ApplyBattlegroundHudRightInset(control)
    local activity = _G["ZO_ActivityTracker"]
    if not control or not activity then
        return
    end
    control:ClearAnchors()
    control:SetAnchor(TOPRIGHT, activity, BOTTOMRIGHT, -CONTENT_RIGHT_INSET, 0)
end

function Addon:ApplyTrackerColumnRightFlush()
    for i = 1, #FLUSH_RIGHT_CONTROL_NAMES do
        local control = _G[FLUSH_RIGHT_CONTROL_NAMES[i]]
        if control then
            FlushTrackerRightEdge(control)
        end
    end
end

function Addon:ApplyTrackerColumnContentInsets()
    for i = 1, #CONTENT_INSET_CONTROL_NAMES do
        local control = _G[CONTENT_INSET_CONTROL_NAMES[i]]
        if control then
            ApplyTrackerContentRightInset(control)
        end
    end
    local bgHud = _G["ZO_BattlegroundHUDFragmentTopLevel"]
    if bgHud then
        ApplyBattlegroundHudRightInset(bgHud)
    end
end

function Addon:ApplyTrackerColumnScale()
    local sv = self.state.sv
    if not sv then return end

    local scale = sv.trackerColumnScale or DEFAULT_SCALE
    local controls = self:GetTrackerColumnControls()
    for i = 1, #controls do
        ApplyScaleToTrackerControl(controls[i], scale)
    end
    self:ApplyTrackerColumnRightFlush()
    self:ApplyTrackerColumnContentInsets()
end

function Addon:ScheduleTrackerColumnScale()
    if self.state.trackerColumnScaleId then
        zo_removeCallLater(self.state.trackerColumnScaleId)
        self.state.trackerColumnScaleId = nil
    end
    self.state.trackerColumnScaleId = zo_callLater(function()
        self.state.trackerColumnScaleId = nil
        if not Addon.state.trackerColumnApplying then
            Addon:ApplyTrackerColumnScale()
        end
    end, 0)
end

function Addon:EnsureTrackerColumnGhosts()
    if self.state.trackerColumnGhostRoot then return end
    self.state.trackerColumnGhostRoot = self:CreateLayoutGhostStack(
        self.name .. "_TrackerColumnGhosts",
        GHOST_LABELS,
        GHOST_WIDTH,
        GHOST_ROW_HEIGHT,
        GHOST_GAP
    )
end

function Addon:UpdateTrackerColumnPreview()
    local sv = self.state.sv
    if not sv then return end

    self:EnsureTrackerColumnGhosts()
    local root = self.state.trackerColumnGhostRoot
    if root and root.SetTransformScale then
        root:SetTransformScale(1)
    end
    self:ApplyLayoutGhostStack(
        root,
        nil,
        sv.trackerColumnPosY,
        sv.trackerColumnScale,
        sv.trackerColumnShowPreview == true,
        true
    )
end

function Addon:ApplyTrackerColumn()
    if self.state.trackerColumnApplying then return end
    self.state.trackerColumnApplying = true

    local sv = self.state.sv
    if sv then
        self:ApplyTrackerColumnRootPosition()
        self:ApplyTrackerColumnScale()
        self:UpdateTrackerColumnPreview()
    end

    self.state.trackerColumnApplying = false
end

function Addon:ApplyTrackerColumnDefaults()
    self:ApplyTrackerColumn()
end

function Addon:InitTrackerColumn()
    self:ApplyTrackerColumn()

    if self.state.trackerColumnHooked then return end
    self.state.trackerColumnHooked = true

    if ZO_EndlessDungeonHUDTracker and ZO_EndlessDungeonHUDTracker.RefreshAnchors then
        ZO_PostHook(ZO_EndlessDungeonHUDTracker, "RefreshAnchors", function()
            if Addon.state.trackerColumnApplying then return end
            Addon:ApplyTrackerColumnRootPosition()
            Addon:ScheduleTrackerColumnScale()
        end)
    end

    -- House/Promotional RefreshAnchors restore the -15 GuiRoot inset; re-flush afterward.
    if ZO_HUDTracker_Base and ZO_HUDTracker_Base.RefreshAnchors then
        ZO_PostHook(ZO_HUDTracker_Base, "RefreshAnchors", function()
            if Addon.state.trackerColumnApplying then return end
            Addon:ScheduleTrackerColumnScale()
        end)
    end

    -- Ready Check ApplyPlatformStyle restores stock anchors (no -15 container inset).
    if ZO_ReadyCheckTracker and ZO_ReadyCheckTracker.ApplyPlatformStyle then
        ZO_PostHook(ZO_ReadyCheckTracker, "ApplyPlatformStyle", function()
            if Addon.state.trackerColumnApplying then return end
            Addon:ScheduleTrackerColumnScale()
        end)
    end
    -- BattlegroundHUDFragment is file-local; hook the live fragment prototype.
    if BATTLEGROUND_HUD_FRAGMENT then
        local proto = getmetatable(BATTLEGROUND_HUD_FRAGMENT)
        proto = proto and proto.__index
        if proto and proto.ApplyPlatformStyle then
            ZO_PostHook(proto, "ApplyPlatformStyle", function()
                if Addon.state.trackerColumnApplying then return end
                Addon:ScheduleTrackerColumnScale()
            end)
        end
    end
end
