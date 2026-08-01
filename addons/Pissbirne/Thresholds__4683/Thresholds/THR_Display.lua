---------------------------------------------------------------------------
-- Thresholds - tracker frame
--
-- One row per tracked subject: name | live HP% | next armed threshold.
---------------------------------------------------------------------------

local THR = Thresholds

local PCT_COLUMN_WIDTH = 70
local NEXT_COLUMN_WIDTH = 60

-- hot path (runs per boss health tick)
local string_format = string.format
local math_floor = math.floor

-- HUD scene fragment that auto-hides the tracker in menus/map. It is active
-- only while frames are LOCKED; unlocking removes it so the tracker can be
-- dragged from any scene (incl. the settings panel), matching the alert.
local trackerFragment
local fragmentActive = nil

local function SetTrackerFragmentActive(active)
    if not trackerFragment or active == fragmentActive then return end
    fragmentActive = active
    if active then
        HUD_SCENE:AddFragment(trackerFragment)
        HUD_UI_SCENE:AddFragment(trackerFragment)
    else
        if HUD_SCENE:HasFragment(trackerFragment) then
            HUD_SCENE:RemoveFragment(trackerFragment)
        end
        if HUD_UI_SCENE:HasFragment(trackerFragment) then
            HUD_UI_SCENE:RemoveFragment(trackerFragment)
        end
        THR.frame:SetHidden(false) -- shown everywhere for positioning
    end
end

local function GetFont()
    return string.format("$(BOLD_FONT)|%d|soft-shadow-thin", THR.SV.frame.fontSize)
end

function THR.CreateDisplay()
    local wm = WINDOW_MANAGER
    local SV = THR.SV

    local frame = wm:CreateTopLevelWindow("Thresholds_TrackerFrame")
    frame:SetDimensions(THR.FRAME_WIDTH, THR.FRAME_PADDING * 2 + THR.ROW_HEIGHT)
    frame:SetClampedToScreen(true)
    frame:SetMovable(not SV.frame.locked)
    frame:SetMouseEnabled(not SV.frame.locked)
    frame:SetHandler("OnMoveStop", function()
        SV.frame.left = frame:GetLeft()
        SV.frame.top = frame:GetTop()
    end)
    frame:SetHidden(true)
    THR.frame = frame

    -- Inner content carries the background and rows. Scene visibility (hide
    -- in menus/map) is handled by a HUD fragment on the frame; this content's
    -- own hidden state carries the combat/lock/subjects logic, so the two
    -- never fight over frame:SetHidden.
    local content = wm:CreateControl("Thresholds_TrackerContent", frame, CT_CONTROL)
    content:SetAnchorFill(frame)
    content:SetHidden(true)
    THR.content = content

    local bg = wm:CreateControl("Thresholds_TrackerBG", content, CT_BACKDROP)
    bg:SetAnchorFill(content)
    bg:SetCenterColor(0, 0, 0, 0.45)
    bg:SetEdgeTexture("", 1, 1, 2, 0)
    bg:SetEdgeColor(0, 0, 0, 0.7)

    THR.rows = {}
    local innerWidth = THR.FRAME_WIDTH - THR.FRAME_PADDING * 2
    for i = 1, THR.MAX_ROWS do
        local row = wm:CreateControl("Thresholds_TrackerRow" .. i, content, CT_CONTROL)
        row:SetDimensions(innerWidth, THR.ROW_HEIGHT)
        if i == 1 then
            row:SetAnchor(TOPLEFT, content, TOPLEFT, THR.FRAME_PADDING, THR.FRAME_PADDING)
        else
            row:SetAnchor(TOPLEFT, THR.rows[i - 1].control, BOTTOMLEFT, 0, 0)
        end

        local nameLabel = wm:CreateControl("Thresholds_TrackerRowName" .. i, row, CT_LABEL)
        nameLabel:SetAnchor(LEFT, row, LEFT, 0, 0)
        nameLabel:SetWidth(innerWidth - PCT_COLUMN_WIDTH - NEXT_COLUMN_WIDTH)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        nameLabel:SetColor(0.9, 0.9, 0.9, 1)

        local pctLabel = wm:CreateControl("Thresholds_TrackerRowPct" .. i, row, CT_LABEL)
        pctLabel:SetAnchor(RIGHT, row, RIGHT, -NEXT_COLUMN_WIDTH, 0)
        pctLabel:SetWidth(PCT_COLUMN_WIDTH)
        pctLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        pctLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        pctLabel:SetColor(1, 1, 1, 1)

        local nextLabel = wm:CreateControl("Thresholds_TrackerRowNext" .. i, row, CT_LABEL)
        nextLabel:SetAnchor(RIGHT, row, RIGHT, 0, 0)
        nextLabel:SetWidth(NEXT_COLUMN_WIDTH - 4)
        nextLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        nextLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        nextLabel:SetColor(0.4, 0.8, 1, 1)

        row:SetHidden(true)
        THR.rows[i] = { control = row, name = nameLabel, pct = pctLabel, next = nextLabel }
    end

    -- Auto-hide the whole tracker in menus, the map, etc. via a HUD scene
    -- fragment while locked; unlocking removes it (see SetTrackerFragmentActive)
    -- so the frame can be dragged from any scene, matching the alert.
    trackerFragment = ZO_HUDFadeSceneFragment:New(frame)
    SetTrackerFragmentActive(SV.frame.locked)

    THR.UpdateDisplayFonts()
    THR.ApplyFramePosition()
end

function THR.UpdateDisplayFonts()
    if not THR.rows then return end
    local font = GetFont()
    for i = 1, THR.MAX_ROWS do
        THR.rows[i].name:SetFont(font)
        THR.rows[i].pct:SetFont(font)
        THR.rows[i].next:SetFont(font)
    end
end

function THR.ApplyFramePosition()
    local frame = THR.frame
    if not frame then return end
    local SV = THR.SV.frame
    frame:ClearAnchors()
    if SV.left and SV.top then
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.left, SV.top)
    else
        frame:SetAnchor(RIGHT, GuiRoot, RIGHT, -420, -120)
    end
end

function THR.ResetFramePosition()
    THR.SV.frame.left = nil
    THR.SV.frame.top = nil
    THR.ApplyFramePosition()
end

function THR.SetFrameLocked(locked)
    THR.SV.frame.locked = locked
    if THR.frame then
        THR.frame:SetMovable(not locked)
        THR.frame:SetMouseEnabled(not locked)
        SetTrackerFragmentActive(locked)
    end
    THR.SetAlertLocked(locked)
    THR.RefreshDisplay()
end

-- Runs on every boss health tick; each label caches what it last displayed
-- so unchanged ticks cost no string building and no SetText relayout.
local function FillRow(row, name, pct, nextValue)
    if row.lastName ~= name then
        row.lastName = name
        row.name:SetText(name)
    end
    local tenths = math_floor(pct * 10 + 0.5)
    if row.lastTenths ~= tenths then
        row.lastTenths = tenths
        row.pct:SetText(string_format("%.1f%%", tenths / 10))
    end
    if row.lastNext ~= nextValue then
        row.lastNext = nextValue
        if nextValue then
            row.next:SetText("> " .. THR.FormatPercentValue(nextValue))
        else
            row.next:SetText("-")
        end
    end
    row.control:SetHidden(false)
end

-- Rebuild every row from the current subject list and resize the frame.
function THR.RefreshDisplay()
    if not THR.frame then return end

    local list = {}
    for _, subject in pairs(THR.subjects) do
        list[#list + 1] = subject
    end
    table.sort(list, function(a, b)
        if a.tag ~= b.tag then return (a.tag or "") < (b.tag or "") end
        return a.name < b.name
    end)

    local shown = 0
    for i = 1, THR.MAX_ROWS do
        local subject = list[i]
        if subject then
            local nextEntry = subject.thresholds[subject.nextIdx]
            FillRow(THR.rows[i], subject.name, subject.lastPct or 100,
                nextEntry and nextEntry.value)
            shown = shown + 1
        else
            THR.rows[i].control:SetHidden(true)
        end
    end

    -- Placeholder row so the frame can be positioned outside of a fight.
    if shown == 0 and (THR.previewMode or not THR.SV.frame.locked) then
        local first = THR.SV.globalThresholds[1]
        if type(first) == "table" then first = first.pct end
        FillRow(THR.rows[1], "Boss Name", 100, first)
        shown = 1
    end

    THR.frame:SetHeight(THR.FRAME_PADDING * 2 + math.max(shown, 1) * THR.ROW_HEIGHT)
    THR.RefreshDisplayVisibility()
end

-- The HUD fragment hides the whole tracker in menus/map; this only decides
-- whether the content should be visible while on the HUD (lock/combat/subjects).
function THR.RefreshDisplayVisibility()
    if not THR.content then return end
    local SV = THR.SV

    local show = false
    if not SV.frame.locked then
        -- Unlocked via /thr for positioning on the HUD, if the tracker is on.
        show = SV.alerts.frame
    elseif THR.isEnabled and SV.alerts.frame and next(THR.subjects) ~= nil
            and (THR.isCombat or SV.frame.showOutOfCombat) then
        show = true
    end

    THR.content:SetHidden(not show)
end

-- Update a single row in place; falls back to a full refresh when the
-- subject is not currently displayed.
function THR.UpdateSubjectRow(subject)
    if not THR.rows then return end
    for i = 1, THR.MAX_ROWS do
        local row = THR.rows[i]
        if not row.control:IsHidden() and row.lastName == subject.name then
            local nextEntry = subject.thresholds[subject.nextIdx]
            FillRow(row, subject.name, subject.lastPct or 100,
                nextEntry and nextEntry.value)
            return
        end
    end
    THR.RefreshDisplay()
end
