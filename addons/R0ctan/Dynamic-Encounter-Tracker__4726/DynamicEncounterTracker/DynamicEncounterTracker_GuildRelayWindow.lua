local DE = DynamicEncounterTracker
local WM = WINDOW_MANAGER

-- This window is project-local because its chat transport and data model differ
-- from the shared timer-window implementations.
DE.GuildRelayWindow = DE.GuildRelayWindow or {}
local GRW = DE.GuildRelayWindow

local ROW_GAP = 2
local TITLE_HEIGHT = 26
local SEPARATOR_HEIGHT = 1
local WINDOW_PADDING = 6
local JUMP_ICON_SIZE = 28
local JUMP_ICON_GAP = 6
local MIN_LABEL_WIDTH = 220
local MEASURE_WIDTH = 2000
local NAME_TIME_GAP = 12

-- Bound list height; keep active entries, then the soonest cooldowns.
local MAX_DISPLAYED_ENTRIES = 15

-- Use dark text while the bright blink background is visible.
local BLINK_ON_TEXT_COLOR = { 0.08, 0.08, 0.06, 1 }

-- Keep timer formatting local to avoid a cross-file UI dependency.
local function FormatCountdown(seconds)
    seconds = zo_max(0, zo_floor((seconds or 0) + 0.5))
    local minutes = zo_floor(seconds / 60)
    local remainder = seconds % 60
    return string.format("%02d:%02d", minutes, remainder)
end

-- Blink is a hard one-second phase because Refresh runs once per second.
-- The return value lets callers switch to readable text during the bright phase.
local function ApplyRowHighlight(rowBg, highlightMode, warningColor, blinkColor)
    if highlightMode == "blink" then
        local isOn = (zo_floor(GetTimeStamp()) % 2) == 0
        local alpha = isOn and (blinkColor[4] or 1) or 0
        rowBg:SetCenterColor(blinkColor[1], blinkColor[2], blinkColor[3], alpha)
        return isOn
    elseif highlightMode == "warning" then
        rowBg:SetCenterColor(warningColor[1], warningColor[2], warningColor[3], warningColor[4] or 1)
    else
        rowBg:SetCenterColor(0, 0, 0, 0)
    end
    return false
end

local function NormalizeAnchor(anchor)
    if anchor == "left" or anchor == "center" then return anchor end
    return "right"
end

local function GetLeftFromSavedPosition(position, width)
    local anchor = NormalizeAnchor(position and position.anchor)
    local x = tonumber(position and position.x) or 0
    width = tonumber(width) or 0
    if anchor == "right" then
        return x - width
    elseif anchor == "center" then
        return x - (width / 2)
    end
    return x
end

local function GetAnchorXFromLeft(left, width, anchor)
    anchor = NormalizeAnchor(anchor)
    width = tonumber(width) or 0
    if anchor == "right" then
        return left + width
    elseif anchor == "center" then
        return left + (width / 2)
    end
    return left
end

function GRW:SavePosition()
    if not self.container or not self.sv then return end
    local left = self.container:GetLeft()
    local right = self.container:GetRight()
    local top = self.container:GetTop()
    if left == nil or right == nil or top == nil then return end

    -- ResetPosition may clear the saved position table.
    if type(self.sv.relayWindowPosition) ~= "table" then
        self.sv.relayWindowPosition = {}
    end

    local anchor = NormalizeAnchor(self.sv.relayWindowPosition.anchor)
    local width = right - left
    local x = GetAnchorXFromLeft(left, width, anchor)
    self.sv.relayWindowPosition.x = zo_round(x)
    self.sv.relayWindowPosition.y = zo_round(top)
    self.sv.relayWindowPosition.anchor = anchor
end

function GRW:ApplyPosition()
    if not self.container or self.isDragging then return end
    self.container:ClearAnchors()

    local position = self.sv.relayWindowPosition
    local anchor = NormalizeAnchor(position and position.anchor)
    if type(position) == "table" then
        local width = self.container:GetWidth() or 0
        local x = GetAnchorXFromLeft(GetLeftFromSavedPosition(position, width), width, anchor)
        if anchor == "right" then
            self.container:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, x, position.y)
        elseif anchor == "center" then
            self.container:SetAnchor(TOP, GuiRoot, TOPLEFT, x, position.y)
        else
            self.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, position.y)
        end
    else
        self.container:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -40, GuiRoot:GetHeight() * 0.3)
    end
end

-- Named handlers allow symmetric teardown without removing unrelated handlers.
local DRAG_MOUSE_DOWN_HANDLER_NAME = "DynamicEncounterTrackerGuildRelayWindowDragMouseDown"
local DRAG_MOUSE_UP_HANDLER_NAME = "DynamicEncounterTrackerGuildRelayWindowDragMouseUp"

function GRW:AttachDragHandlers(control)
    if not control or control._dynamicencountertrackerGrwDragAttached then return end
    control._dynamicencountertrackerGrwDragAttached = true
    self.dragAttachedControls = self.dragAttachedControls or {}
    self.dragAttachedControls[#self.dragAttachedControls + 1] = control
    control:SetHandler("OnMouseDown", function(_, button)
        if not self.sv.relayWindowLocked and button == MOUSE_BUTTON_INDEX_LEFT and self.container then
            self.isDragging = true
            self.container:StartMoving()
        end
    end, DRAG_MOUSE_DOWN_HANDLER_NAME)
    control:SetHandler("OnMouseUp", function()
        if not self.sv.relayWindowLocked and self.container then
            self.container:StopMovingOrResizing()
            self.isDragging = false
            self:SavePosition()
        end
    end, DRAG_MOUSE_UP_HANDLER_NAME)
end

function GRW:DetachDragHandlers(control)
    if not control or not control._dynamicencountertrackerGrwDragAttached then return end
    control:SetHandler("OnMouseDown", nil, DRAG_MOUSE_DOWN_HANDLER_NAME)
    control:SetHandler("OnMouseUp", nil, DRAG_MOUSE_UP_HANDLER_NAME)
    control._dynamicencountertrackerGrwDragAttached = nil
end

function GRW:ApplyWindowVisual()
    if not self.containerBg then return end
    local colors = self.sv.relayWindowColors
    local bg = colors.background
    self.containerBg:SetCenterColor(bg[1], bg[2], bg[3], bg[4] or 1)

    -- Hide both edge alpha and thickness to avoid a residual line.
    local border = colors.separator
    local showBorder = self.sv.relayWindowShowBorder
    if self.containerBorder then
        self.containerBorder:SetEdgeColor(border[1], border[2], border[3], showBorder and 0.9 or 0)
        self.containerBorder:SetEdgeTexture("", 8, 8, showBorder and 2 or 0)
    end

    if self.container and self.container.titleBar then
        local titleBar = colors.titleBar
        self.container.titleBar:SetCenterColor(titleBar[1], titleBar[2], titleBar[3], titleBar[4] or 1)
    end
    if self.container and self.container.titleLabel then
        local titleText = colors.titleText
        self.container.titleLabel:SetColor(titleText[1], titleText[2], titleText[3], titleText[4] or 1)
    end
end

-- Keep mouse input enabled; SetMovable alone controls locking for Lua-created windows.
function GRW:SetLocked(locked)
    self.sv.relayWindowLocked = locked and true or false
    if self.container then
        self.container:SetMovable(not self.sv.relayWindowLocked)
    end
    self:ApplyWindowVisual()
end

-- Border on/off toggle via slash command - mirrors the settings checkbox's
-- own setFunc, invoked via /dynet border.
function GRW:ToggleBorder()
    self.sv.relayWindowShowBorder = not self.sv.relayWindowShowBorder
    self:ApplyWindowVisual()
    DE:Print(DE:T(self.sv.relayWindowShowBorder and "DE_RELAY_WINDOW_BORDER_ON" or "DE_RELAY_WINDOW_BORDER_OFF"))
end

function GRW:CreateUI()
    if self.container then return end

    local c = WM:CreateTopLevelWindow("DynamicEncounterTrackerGuildRelayWindow")
    c:SetResizeToFitDescendents(false)
    c:SetClampedToScreen(true)
    c:SetDrawTier(DT_MEDIUM)
    c:SetDrawLayer(DL_CONTROLS)
    c:SetMouseEnabled(true)
    c:SetMovable(not self.sv.relayWindowLocked)
    -- Named handler allows symmetric teardown.
    c:SetHandler("OnMoveStop", function() self:SavePosition() end, "DynamicEncounterTrackerGuildRelayWindowMoveStop")

    c.bg = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowBg", c, CT_BACKDROP)
    c.bg:SetAnchorFill(c)
    -- CT_BACKDROP has a default edge unless explicitly cleared.
    c.bg:SetEdgeTexture(nil, 1, 1, 0)
    c.bg:SetEdgeColor(0, 0, 0, 0)
    c.bg:SetInsets(0, 0, 0, 0)
    c.bg:SetMouseEnabled(false)

    c.titleBar = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowTitleBar", c, CT_BACKDROP)
    c.titleBar:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)
    c.titleBar:SetAnchor(TOPRIGHT, c, TOPRIGHT, 0, 0)
    c.titleBar:SetHeight(TITLE_HEIGHT + WINDOW_PADDING)
    c.titleBar:SetEdgeTexture(nil, 1, 1, 0)
    c.titleBar:SetEdgeColor(0, 0, 0, 0)
    c.titleBar:SetInsets(0, 0, 0, 0)
    c.titleBar:SetMouseEnabled(true)
    self:AttachDragHandlers(c.titleBar)

    c.titleLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowTitle", c, CT_LABEL)
    c.titleLabel:SetAnchorFill(c.titleBar)
    c.titleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.titleLabel:SetFont("$(BOLD_FONT)|18")
    c.titleLabel:SetText(DE:T("DE_RELAY_WINDOW_TITLE"))
    c.titleLabel:SetMouseEnabled(true)
    self:AttachDragHandlers(c.titleLabel)

    -- The optional debug module is excluded from the production manifest.
    if self.addon and self.addon.HasDebugModule and self.addon:HasDebugModule() then
        c.devLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowDevLabel", c, CT_LABEL)
        c.devLabel:SetAnchor(BOTTOM, c, TOP, 0, -6)
        c.devLabel:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
        c.devLabel:SetColor(1, 0.2, 0.2, 1)
        c.devLabel:SetText(string.format("DEV BUILD %s", self.addon.version))
        c.devLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end

    -- A separate overlay keeps the border above title and rows.
    c.border = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowBorder", c, CT_BACKDROP)
    c.border:SetAnchorFill(c)
    c.border:SetInsets(0, 0, 0, 0)
    c.border:SetMouseEnabled(false)
    c.border:SetCenterColor(0, 0, 0, 0)
    c.border:SetDrawLayer(DL_OVERLAY)

    self.container = c
    self.containerBg = c.bg
    self.containerBorder = c.border
    self.rows = {}

    self:ApplyWindowVisual()
    self:ApplyPosition()
    self.container:SetHidden(true)
end

local function GetReporterJumpTooltip()
    return DE:T("DE_RELAY_WINDOW_JUMP_TOOLTIP")
end

function GRW:CreateRow(index)
    local row = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRow" .. index, self.container, CT_CONTROL)
    -- ESO requires a mouse-enabled parent for clickable child controls.
    row:SetMouseEnabled(true)

    row.bg = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowBg" .. index, row, CT_BACKDROP)
    row.bg:SetAnchorFill(row)
    row.bg:SetEdgeTexture(nil, 1, 1, 0)
    row.bg:SetEdgeColor(0, 0, 0, 0)
    row.bg:SetInsets(0, 0, 0, 0)
    row.bg:SetMouseEnabled(false)

    row.nameLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowName" .. index, row, CT_LABEL)
    row.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.nameLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    row.senderLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowSender" .. index, row, CT_LABEL)
    row.senderLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.senderLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    row.timeLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowTime" .. index, row, CT_LABEL)
    row.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.timeLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    row.jumpIcon = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowJump" .. index, row, CT_TEXTURE)
    row.jumpIcon:SetDimensions(JUMP_ICON_SIZE, JUMP_ICON_SIZE)
    row.jumpIcon:SetTexture("EsoUI/Art/ZoneStories/completionTypeIcon_wayshrine.dds")
    row.jumpIcon:SetMouseEnabled(true)
    -- Nested clickable controls require a controls draw layer in ESO.
    row.jumpIcon:SetDrawLayer(DL_CONTROLS)
    row.jumpIcon:SetColor(0.65, 0.65, 0.65, 1)
    -- Named handlers allow symmetric teardown.
    row.jumpIcon:SetHandler("OnMouseUp", function()
        local entry = row.boundEntry
        -- Preview entries have no real guild member to travel to.
        if not entry or entry.isPreview then return end
        DE:AcceptGuildRelayEntry(entry)
    end, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseUp")
    row.jumpIcon:SetHandler("OnMouseEnter", function(control)
        control:SetColor(1, 1, 1, 1)
        ZO_Tooltips_ShowTextTooltip(control, LEFT, GetReporterJumpTooltip())
    end, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseEnter")
    row.jumpIcon:SetHandler("OnMouseExit", function(control)
        control:SetColor(0.65, 0.65, 0.65, 1)
        ZO_Tooltips_HideTextTooltip()
    end, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseExit")

    row.separator = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowRowSep" .. index, self.container, CT_BACKDROP)
    row.separator:SetEdgeTexture(nil, 1, 1, 0)
    row.separator:SetEdgeColor(0, 0, 0, 0)
    row.separator:SetInsets(0, 0, 0, 0)
    row.separator:SetHeight(SEPARATOR_HEIGHT)

    return row
end

-- Active entries stay above cooldowns; the selected mode sorts within each group.
local function ActiveRunningLongestFirst(a, b)
    return (a.activeStartedAt or 0) < (b.activeStartedAt or 0)
end

local function SortedEntries(entries, sortMode)
    local activeList, cooldownList = {}, {}
    for _, entry in pairs(entries) do
        if entry.entryType == "active" then
            activeList[#activeList + 1] = entry
        else
            cooldownList[#cooldownList + 1] = entry
        end
    end

    local function ZoneName(entry)
        return zo_strformat(SI_ZONE_NAME, GetZoneNameById(entry.zoneId))
    end

    if sortMode == "zone" then
        table.sort(activeList, function(a, b) return ZoneName(a) < ZoneName(b) end)
        table.sort(cooldownList, function(a, b) return ZoneName(a) < ZoneName(b) end)
    else
        -- currentProgress is absent on estimated entries; activeStartedAt orders both sources.
        table.sort(activeList, ActiveRunningLongestFirst)
        table.sort(cooldownList, function(a, b) return (a.localRespawnAt or 0) < (b.localRespawnAt or 0) end)
    end

    local list = {}
    for _, e in ipairs(activeList) do list[#list + 1] = e end
    for _, e in ipairs(cooldownList) do list[#list + 1] = e end
    return list
end

-- Cap by urgency independently of the selected display sort.
local function CapEntriesForDisplay(entries)
    if #entries <= MAX_DISPLAYED_ENTRIES then
        return entries
    end

    local capped = {}
    for _, e in ipairs(entries) do
        capped[#capped + 1] = e
    end
    table.sort(capped, function(a, b)
        local aActive = a.entryType == "active"
        local bActive = b.entryType == "active"
        if aActive ~= bActive then
            return aActive
        end
        if aActive then
            return ActiveRunningLongestFirst(a, b)
        end
        return (a.localRespawnAt or 0) < (b.localRespawnAt or 0)
    end)

    local result = {}
    for i = 1, MAX_DISPLAYED_ENTRIES do
        result[i] = capped[i]
    end
    return result
end

function GRW:LayoutRows(entries)
    local colors = self.sv.relayWindowColors
    local fontSize = self.sv.relayWindowFontSize or 16
    local rowGap = ROW_GAP

    local nameFont = string.format("$(BOLD_FONT)|%d", fontSize)
    local timeFont = string.format("EsoUI/Common/Fonts/univers57.otf|%d", fontSize)
    local nameLineHeight = fontSize + 2
    local timeLineHeight = fontSize + 2
    local rowHeight = nameLineHeight + timeLineHeight

    local jumpIconSize = zo_max(JUMP_ICON_SIZE, zo_floor(rowHeight * 0.7 + 0.5))
    local jumpIconGap = zo_max(JUMP_ICON_GAP, zo_floor(jumpIconSize * 0.2 + 0.5))

    local function GetRowTexts(entry)
        local zoneName = zo_strformat(SI_ZONE_NAME, GetZoneNameById(entry.zoneId))
        -- Preview names may already include "@".
        local rawSenderName = tostring(entry.fromDisplayName)
        local senderText = rawSenderName:sub(1, 1) == "@" and rawSenderName or ("@" .. rawSenderName)
        local timeText
        if entry.entryType == "active" then
            -- Shared progress is a frozen snapshot; elapsed time avoids implying live updates.
            local elapsed = zo_max(0, GetTimeStamp() - (entry.activeStartedAt or GetTimeStamp()))
            local fmtKey = entry.activeSource == "estimated" and "DE_RELAY_WINDOW_ACTIVE_ESTIMATED_FMT" or "DE_RELAY_WINDOW_ACTIVE_SHARE_FMT"
            timeText = DE:T(fmtKey, FormatCountdown(elapsed))
        else
            timeText = FormatCountdown(zo_max(0, (entry.localRespawnAt or 0) - GetTimeStamp()))
        end
        return zoneName, senderText, timeText
    end

    -- A wide hidden label avoids clipping while measuring dynamic columns.
    local labelWidth = MIN_LABEL_WIDTH
    for _, entry in ipairs(entries) do
        local zoneName, senderText, timeText = GetRowTexts(entry)

        if not self.measureLabel then
            self.measureLabel = WM:CreateControl("DynamicEncounterTrackerGuildRelayWindowMeasureLabel", self.container, CT_LABEL)
            self.measureLabel:SetHidden(true)
        end
        local measureLabel = self.measureLabel
        measureLabel:SetDimensions(MEASURE_WIDTH, nameLineHeight)

        measureLabel:SetFont(nameFont)
        measureLabel:SetText(zoneName)
        labelWidth = zo_max(labelWidth, measureLabel:GetTextWidth() or 0)

        measureLabel:SetFont(timeFont)
        measureLabel:SetText(senderText)
        local senderWidth = measureLabel:GetTextWidth() or 0

        measureLabel:SetText(timeText)
        local timeWidth = measureLabel:GetTextWidth() or 0

        labelWidth = zo_max(labelWidth, senderWidth + NAME_TIME_GAP + timeWidth)
    end

    local contentWidth = labelWidth + jumpIconGap + jumpIconSize
    local y = TITLE_HEIGHT + WINDOW_PADDING

    -- Empty state: same row look as a real entry, but with placeholder text
    -- instead of name/time, no separator/jump icon - window stays visible
    -- (see ShouldShowWindow) instead of collapsing to a bare title bar.
    if #entries == 0 then
        if not self.rows[1] then
            self.rows[1] = self:CreateRow(1)
        end
        local row = self.rows[1]
        row.boundEntry = nil
        row:ClearAnchors()
        row.separator:ClearAnchors()
        row:SetHidden(false)
        row.separator:SetHidden(true)
        row.jumpIcon:SetHidden(true)

        row:SetDimensions(contentWidth, nameLineHeight)
        row:SetAnchor(TOPLEFT, self.container, TOPLEFT, WINDOW_PADDING, y)

        row.nameLabel:SetFont(nameFont)
        row.nameLabel:ClearAnchors()
        row.nameLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        row.nameLabel:SetDimensions(contentWidth, nameLineHeight)
        row.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.nameLabel:SetText(DE:T("DE_RELAY_WINDOW_EMPTY"))
        row.nameLabel:SetColor(colors.zoneText[1], colors.zoneText[2], colors.zoneText[3], colors.zoneText[4] or 1)
        -- Hide the backdrop because a transparent ESO backdrop may retain a faint edge.
        row.bg:SetHidden(true)

        row.senderLabel:SetHidden(true)
        row.timeLabel:SetHidden(true)

        y = y + nameLineHeight

        for i = 2, #self.rows do
            self.rows[i]:SetHidden(true)
            self.rows[i].separator:SetHidden(true)
        end

        local totalWidth = contentWidth + (WINDOW_PADDING * 2)
        local totalHeight = y + WINDOW_PADDING
        self.container:SetDimensions(totalWidth, zo_max(totalHeight, TITLE_HEIGHT + WINDOW_PADDING * 2))
        self:ApplyPosition()
        return
    end

    for i, row in ipairs(self.rows) do
        row:ClearAnchors()
        row.separator:ClearAnchors()
        local hasEntry = i <= #entries
        row:SetHidden(not hasEntry)
        row.separator:SetHidden(true)

        if hasEntry then
            local entry = entries[i]
            row.boundEntry = entry

            -- Pooled placeholder rows must restore their background.
            row.bg:SetHidden(false)

            row:SetDimensions(contentWidth, rowHeight)
            row:SetAnchor(TOPLEFT, self.container, TOPLEFT, WINDOW_PADDING, y)

            local zoneName, senderText, timeText = GetRowTexts(entry)

            local highlightMode
            if entry.entryType == "active" then
                highlightMode = "blink"
            else
                local remaining = zo_max(0, (entry.localRespawnAt or 0) - GetTimeStamp())
                highlightMode = (remaining <= (self.sv.relayWindowBlinkThresholdSeconds or 30)) and "warning" or "none"
            end
            local isBlinkOn = ApplyRowHighlight(row.bg, highlightMode, colors.warning, colors.blink)

            -- Keep text readable during the bright blink phase.
            local nameColor = isBlinkOn and BLINK_ON_TEXT_COLOR or colors.zoneText
            local timeColor = isBlinkOn and BLINK_ON_TEXT_COLOR or colors.playerText

            row.nameLabel:SetFont(nameFont)
            row.nameLabel:ClearAnchors()
            row.nameLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
            row.nameLabel:SetDimensions(labelWidth, nameLineHeight)
            row.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            row.nameLabel:SetColor(nameColor[1], nameColor[2], nameColor[3], nameColor[4] or 1)
            row.nameLabel:SetText(zoneName)

            row.timeLabel:SetHidden(false)
            row.jumpIcon:SetHidden(false)
            -- Reachability is rechecked immediately before the jump.
            row.jumpIcon:SetDimensions(jumpIconSize, jumpIconSize)
            row.jumpIcon:ClearAnchors()
            row.jumpIcon:SetAnchor(RIGHT, row, RIGHT, 0, 0)
            row.jumpIcon:SetAlpha(1)

            -- Reused labels take the measured column width; stale dimensions would clip names.
            row.senderLabel:SetFont(timeFont)
            row.senderLabel:SetText(senderText)
            row.senderLabel:SetHidden(false)
            row.senderLabel:ClearAnchors()
            row.senderLabel:SetAnchor(TOPLEFT, row.nameLabel, BOTTOMLEFT, 0, 0)
            row.senderLabel:SetDimensions(labelWidth, timeLineHeight)
            row.senderLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            row.senderLabel:SetColor(timeColor[1], timeColor[2], timeColor[3], timeColor[4] or 1)

            row.timeLabel:SetFont(timeFont)
            row.timeLabel:ClearAnchors()
            row.timeLabel:SetDimensions(labelWidth, timeLineHeight)
            row.timeLabel:SetAnchor(TOPRIGHT, row.nameLabel, BOTTOMRIGHT, 0, 0)
            row.timeLabel:SetColor(timeColor[1], timeColor[2], timeColor[3], timeColor[4] or 1)
            row.timeLabel:SetText(timeText)

            y = y + rowHeight

            if i < #entries then
                row.separator:SetHidden(false)
                local sepColor = colors.separator
                row.separator:SetCenterColor(sepColor[1], sepColor[2], sepColor[3], sepColor[4] or 1)
                row.separator:SetWidth(contentWidth)
                row.separator:SetAnchor(TOPLEFT, self.container, TOPLEFT, WINDOW_PADDING, y + (rowGap / 2))
                y = y + rowGap + SEPARATOR_HEIGHT
            end
        end
    end

    local totalWidth = contentWidth + (WINDOW_PADDING * 2)
    local totalHeight = y + WINDOW_PADDING
    self.container:SetDimensions(totalWidth, zo_max(totalHeight, TITLE_HEIGHT + WINDOW_PADDING * 2))
    self:ApplyPosition()
end

-- Runtime and window settings override preview visibility.
function GRW:ShouldShowWindow()
    if not self.addon or not self.addon.IsAddonRuntimeEnabled or not self.addon:IsAddonRuntimeEnabled() then
        return false
    end
    if self.sv.relayWindowShow == false then
        return false
    end

    if self.previewActive then
        return true
    end

    -- Match the main window's scene visibility; preview is the explicit exception.
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not self.addon:IsHudScene(scene) then
        return false
    end

    return true
end

function GRW:ApplyVisibility()
    if not self.container then return end
    self.container:SetHidden(not self:ShouldShowWindow())
end

-- A one-second tick keeps countdown/blink current and promotes expired cooldowns immediately.
function GRW:StartTick()
    self:StopTick()
    EVENT_MANAGER:RegisterForUpdate(self.addon.name .. "_GuildRelayWindowTick", 1000, function()
        self.addon:PromoteExpiredGuildRelayCooldowns()
        self:Refresh()
    end)
end

function GRW:StopTick()
    EVENT_MANAGER:UnregisterForUpdate(self.addon.name .. "_GuildRelayWindowTick")
end

function GRW:Refresh()
    if not self.container then return end
    self:ApplyVisibility()
    if not self:ShouldShowWindow() then
        self:StopTick()
        for _, row in ipairs(self.rows or {}) do
            row:SetHidden(true)
        end
        return
    end
    self:StartTick()

    -- Cap before display sorting so the selected sort cannot discard urgent entries.
    local rawEntries = {}
    for _, entry in pairs(self.addon.state.guildRelayEntries) do
        rawEntries[#rawEntries + 1] = entry
    end
    local cappedEntries = CapEntriesForDisplay(rawEntries)
    local entries = SortedEntries(cappedEntries, self.sv.relayWindowSortMode)
    for i = 1, zo_max(#entries, #self.rows) do
        if not self.rows[i] and i <= #entries then
            self.rows[i] = self:CreateRow(i)
        end
    end
    self:LayoutRows(entries)
end

-- A reserved sender keeps preview keys disjoint from real relay entries.
local PREVIEW_SENDER_NAME = "@PreviewGuildMember"

local function GetPreviewEntryKeys()
    local keys = {}
    for _, config in ipairs(DE:GetAllEncounterConfigsForSettings()) do
        keys[#keys + 1] = PREVIEW_SENDER_NAME .. "|" .. tostring(config.relayCode)
    end
    return keys
end

function GRW:PreviewOnce()
    self.previewActive = true
    local now = GetTimeStamp()
    local configs = DE:GetAllEncounterConfigsForSettings()
    local entries = self.addon.state.guildRelayEntries

    for i, config in ipairs(configs) do
        local key = PREVIEW_SENDER_NAME .. "|" .. tostring(config.relayCode)
        local entry = {
            fromDisplayName = PREVIEW_SENDER_NAME,
            config = config,
            guildId = nil,
            zoneId = config.zoneId,
            lastUpdatedAt = now,
            isPreview = true,
        }
        if i == 1 then
            entry.entryType = "active"
            entry.activeStartedAt = now - 90
            entry.currentProgress = 60
            entry.maxProgress = 100
        else
            entry.entryType = "cooldown"
            entry.localRespawnAt = now + (i * 300)
        end
        entries[key] = entry
    end
    self:Refresh()
end

function GRW:StopPreview()
    self.previewActive = false
    local entries = self.addon.state.guildRelayEntries
    for _, key in ipairs(GetPreviewEntryKeys()) do
        entries[key] = nil
    end
    self:Refresh()
end

function GRW:TogglePreview()
    if self.previewActive then
        self:StopPreview()
    else
        self:PreviewOnce()
    end
end

function GRW:ResetPosition()
    self.sv.relayWindowPosition = nil
    self:ApplyPosition()
end

function GRW:Initialize(addon)
    self.addon = addon
    self.sv = addon.sv

    self:CreateUI()
    self:Refresh()

    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(_, _, newState)
            if newState == SCENE_SHOWN or newState == SCENE_HIDDEN then
                self:Refresh()
            end
        end)
    end
end

-- Symmetric cleanup for every handler installed by this module.
function GRW:Teardown()
    self:StopTick()
    if self.container then
        self.container:SetHandler("OnMoveStop", nil, "DynamicEncounterTrackerGuildRelayWindowMoveStop")
    end
    for _, control in ipairs(self.dragAttachedControls or {}) do
        self:DetachDragHandlers(control)
    end
    self.dragAttachedControls = nil
    for _, row in ipairs(self.rows or {}) do
        if row.jumpIcon then
            row.jumpIcon:SetHandler("OnMouseUp", nil, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseUp")
            row.jumpIcon:SetHandler("OnMouseEnter", nil, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseEnter")
            row.jumpIcon:SetHandler("OnMouseExit", nil, "DynamicEncounterTrackerGuildRelayWindowRowJumpMouseExit")
        end
    end
end
