local DE = DynamicEncounterTracker
local WM = WINDOW_MANAGER

DE.WINDOW_MIN_WIDTH = 480
DE.WINDOW_MAX_WIDTH = 980
DE.WINDOW_MIN_HEIGHT = 150
DE.MINIMAL_MIN_HEIGHT = 66
DE.WINDOW_DEFAULT_HEIGHT = 190
DE.WINDOW_DEFAULT_WIDTH = 580
DE.CHEST_ALERT_MIN_WIDTH = 320
DE.CHEST_ALERT_MAX_WIDTH = 900
DE.CHEST_ALERT_HEIGHT = 86

local ROW_LABEL_LEFT = 18
local ROW_LABEL_WIDTH = 155
local ROW_VALUE_LEFT = 175
local ROW_RIGHT_MARGIN = 30
local FRAME_THICKNESS = 2
local RESIZE_HANDLE_SIZE = 28

local function SetLabelColor(label, color)
    label:SetColor(color[1], color[2], color[3], color[4] or 1)
end

local function FormatCountdown(seconds)
    seconds = zo_max(0, zo_floor(seconds + 0.5))
    local minutes = zo_floor(seconds / 60)
    local remainder = seconds % 60
    return string.format("%02d:%02d", minutes, remainder)
end


local function FormatProgressPercent(currentProgress, maxProgress)
    if type(currentProgress) ~= "number" or type(maxProgress) ~= "number" or maxProgress <= 0 then
        return nil
    end

    local percent = zo_floor((currentProgress / maxProgress) * 100 + 0.5)
    return string.format("%d%%", percent)
end

local function ColorToHex(color)
    local r = zo_floor(zo_clamp((color and color[1]) or 1, 0, 1) * 255 + 0.5)
    local g = zo_floor(zo_clamp((color and color[2]) or 1, 0, 1) * 255 + 0.5)
    local b = zo_floor(zo_clamp((color and color[3]) or 1, 0, 1) * 255 + 0.5)
    return string.format("%02X%02X%02X", r, g, b)
end

local function ColorizeText(text, color)
    return string.format("|c%s%s|r", ColorToHex(color), text)
end

function DE:CreateRow(parent, name, y, allowWrap)
    local row = {
        allowWrap = allowWrap == true,
        baseHeight = 26,
    }

    row.label = WM:CreateControl(name .. "Label", parent, CT_LABEL)
    row.label:SetAnchor(TOPLEFT, parent, TOPLEFT, ROW_LABEL_LEFT, y)
    row.label:SetDimensions(ROW_LABEL_WIDTH, row.baseHeight)
    row.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    row.label:SetMaxLineCount(1)

    row.value = WM:CreateControl(name .. "Value", parent, CT_LABEL)
    row.value:SetAnchor(TOPLEFT, parent, TOPLEFT, ROW_VALUE_LEFT, y)
    row.value:SetHeight(row.baseHeight)
    row.value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.value:SetVerticalAlignment(TEXT_ALIGN_TOP)

    if row.allowWrap then
        row.value:SetMaxLineCount(0)
        if TEXT_WRAP_MODE_TRUNCATE then
            row.value:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        end
    else
        row.value:SetMaxLineCount(1)
        row.value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    return row
end

function DE:SaveWindowPosition(control)
    local _, point, _, relativePoint, x, y = control:GetAnchor(0)
    self.sv.position.point = point
    self.sv.position.relativePoint = relativePoint
    self.sv.position.x = x
    self.sv.position.y = y
end

function DE:SaveWindowSize(control)
    local width = zo_clamp(zo_floor(control:GetWidth() + 0.5), self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    local height = self.currentWindowHeight or self.WINDOW_DEFAULT_HEIGHT
    self.sv.size.width = width
    self.sv.size.height = height
end

function DE:SetWindowWidth(width)
    if not self.window then
        return
    end

    width = zo_clamp(zo_floor(width + 0.5), self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    local height = self.currentWindowHeight or self.WINDOW_DEFAULT_HEIGHT
    self.window:SetDimensions(width, height)
    self.sv.size.width = width
    self.sv.size.height = height
    self:RefreshUI()
end

function DE:SetChestAlertWidth(width)
    if not self.centerAlertWindow then
        return
    end

    width = zo_clamp(zo_floor(width + 0.5), self.CHEST_ALERT_MIN_WIDTH, self.CHEST_ALERT_MAX_WIDTH)
    self.centerAlertWindow:SetDimensions(width, self.CHEST_ALERT_HEIGHT)
    self.sv.chestAlertSize.width = width
    self.sv.chestAlertSize.height = self.CHEST_ALERT_HEIGHT
end

function DE:CreateFrameLine(name, parent)
    local line = WM:CreateControl(name, parent, CT_TEXTURE)
    line:SetTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    return line
end

function DE:CreateUI()
    local window = WM:CreateTopLevelWindow("DynamicEncounterTrackerWindow")
    self.window = window
    local savedWidth = zo_clamp(self.sv.size.width or self.WINDOW_DEFAULT_WIDTH, self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    self.currentWindowHeight = self.WINDOW_DEFAULT_HEIGHT
    window:SetDimensions(savedWidth, self.currentWindowHeight)
    window:SetDimensionConstraints(self.WINDOW_MIN_WIDTH, self.currentWindowHeight, self.WINDOW_MAX_WIDTH, self.currentWindowHeight)
    window:SetResizeHandleSize(RESIZE_HANDLE_SIZE)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(10)
    window:SetHidden(true)

    local position = self.sv.position
    window:SetAnchor(position.point or TOPLEFT, GuiRoot, position.relativePoint or TOPLEFT, position.x or 200, position.y or 200)

    window:SetHandler("OnMoveStop", function(control)
        self:SaveWindowPosition(control)
        self:SaveWindowSize(control)
    end)
    window:SetHandler("OnResizeStop", function(control)
        self:SaveWindowSize(control)
        self:RefreshUI()
    end)

    local background = WM:CreateControl("DynamicEncounterTrackerWindowBackground", window, CT_BACKDROP)
    self.background = background
    background:SetAnchorFill(window)
    background:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")

    self.frameLines = {
        top = self:CreateFrameLine("DynamicEncounterTrackerWindowFrameTop", window),
        bottom = self:CreateFrameLine("DynamicEncounterTrackerWindowFrameBottom", window),
        left = self:CreateFrameLine("DynamicEncounterTrackerWindowFrameLeft", window),
        right = self:CreateFrameLine("DynamicEncounterTrackerWindowFrameRight", window),
    }
    self.frameLines.top:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    self.frameLines.top:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    self.frameLines.top:SetHeight(FRAME_THICKNESS)
    self.frameLines.bottom:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 0, 0)
    self.frameLines.bottom:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    self.frameLines.bottom:SetHeight(FRAME_THICKNESS)
    self.frameLines.left:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    self.frameLines.left:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 0, 0)
    self.frameLines.left:SetWidth(FRAME_THICKNESS)
    self.frameLines.right:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    self.frameLines.right:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    self.frameLines.right:SetWidth(FRAME_THICKNESS)

    local title = WM:CreateControl("DynamicEncounterTrackerWindowTitle", window, CT_LABEL)
    self.titleLabel = title
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 7)
    title:SetAnchor(TOPRIGHT, window, TOPRIGHT, -44, 7)
    title:SetHeight(31)
    title:SetText(self:T("DE_ADDON_NAME"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetMaxLineCount(1)

    local divider = WM:CreateControl("DynamicEncounterTrackerWindowDivider", window, CT_TEXTURE)
    self.divider = divider
    divider:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 39)
    divider:SetAnchor(TOPRIGHT, window, TOPRIGHT, -14, 39)
    divider:SetHeight(1)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")

    self.rows = {
        zone = self:CreateRow(window, "DynamicEncounterTrackerZone", 45, false),
        event = self:CreateRow(window, "DynamicEncounterTrackerEvent", 72, true),
        status = self:CreateRow(window, "DynamicEncounterTrackerStatus", 99, true),
        currentSection = self:CreateRow(window, "DynamicEncounterTrackerCurrentSection", 126, true),
        hint = self:CreateRow(window, "DynamicEncounterTrackerHint", 153, true),
        minimal = self:CreateRow(window, "DynamicEncounterTrackerMinimal", 6, false),
        minimalParticipation = self:CreateRow(window, "DynamicEncounterTrackerMinimalParticipation", 6, false),
    }

    self.rows.zone.label:SetText(self:T("DE_LABEL_ZONE"))
    self.rows.event.label:SetText(self:T("DE_LABEL_EVENT"))
    self.rows.status.label:SetText(self:T("DE_LABEL_STATUS"))
    self.rows.currentSection.label:SetText(self:T("DE_LABEL_SECTION"))
    self.rows.hint.label:SetText(self:T("DE_LABEL_HINT"))
    self.rows.minimal.label:SetHidden(true)
    self.rows.minimal.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.rows.minimalParticipation.label:SetHidden(true)
    self.rows.minimalParticipation.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self:ModuleHook("debug", "CreateStatusRows", window)


    title:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not self.sv.locked then
            window:StartMoving()
        end
    end)
    title:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    local closeButton = WM:CreateControlFromVirtual("DynamicEncounterTrackerWindowClose", window, "ZO_CloseButton")
    self.closeButton = closeButton
    closeButton:ClearAnchors()
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 8)
    closeButton:SetHandler("OnClicked", function()
        self.sv.showWindow = false
        self:RefreshVisibility()
    end)

    local minimalToggle = WM:CreateControl("DynamicEncounterTrackerWindowMinimalToggle", window, CT_LABEL)
    self.minimalToggle = minimalToggle
    minimalToggle:SetDimensions(20, 20)
    minimalToggle:SetAnchor(BOTTOMRIGHT, closeButton, BOTTOMLEFT, -4, -3)
    minimalToggle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    minimalToggle:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    minimalToggle:SetMouseEnabled(true)
    minimalToggle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self.sv.minimalMode = not self.sv.minimalMode
            self:RefreshUI()
            self:RefreshSettingsPanel()
        end
    end)

    local resizeHandle = WM:CreateControl("DynamicEncounterTrackerWindowResizeHandle", window, CT_CONTROL)
    self.resizeHandle = resizeHandle
    resizeHandle:SetDimensions(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
    resizeHandle:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    -- Visual marker only. Mouse input intentionally remains on the top-level
    -- window so SetResizeHandleSize can provide ESO's native resize cursor and
    -- drag behavior in the lower-right corner.
    resizeHandle:SetMouseEnabled(false)

    self.resizeHandleLines = {
        outerHorizontal = self:CreateFrameLine("DynamicEncounterTrackerWindowResizeOuterHorizontal", resizeHandle),
        outerVertical = self:CreateFrameLine("DynamicEncounterTrackerWindowResizeOuterVertical", resizeHandle),
        innerHorizontal = self:CreateFrameLine("DynamicEncounterTrackerWindowResizeInnerHorizontal", resizeHandle),
        innerVertical = self:CreateFrameLine("DynamicEncounterTrackerWindowResizeInnerVertical", resizeHandle),
    }
    self.resizeHandleLines.outerHorizontal:SetAnchor(BOTTOMRIGHT, resizeHandle, BOTTOMRIGHT, -3, -3)
    self.resizeHandleLines.outerHorizontal:SetDimensions(15, 2)
    self.resizeHandleLines.outerVertical:SetAnchor(BOTTOMRIGHT, resizeHandle, BOTTOMRIGHT, -3, -3)
    self.resizeHandleLines.outerVertical:SetDimensions(2, 15)
    self.resizeHandleLines.innerHorizontal:SetAnchor(BOTTOMRIGHT, resizeHandle, BOTTOMRIGHT, -7, -7)
    self.resizeHandleLines.innerHorizontal:SetDimensions(8, 2)
    self.resizeHandleLines.innerVertical:SetAnchor(BOTTOMRIGHT, resizeHandle, BOTTOMRIGHT, -7, -7)
    self.resizeHandleLines.innerVertical:SetDimensions(2, 8)



    local centerAlert = WM:CreateTopLevelWindow("DynamicEncounterTrackerCenterChestAlert")
    self.centerAlertWindow = centerAlert
    local alertWidth = zo_clamp(
        self.sv.chestAlertSize.width or self.defaults.chestAlertSize.width,
        self.CHEST_ALERT_MIN_WIDTH,
        self.CHEST_ALERT_MAX_WIDTH
    )
    centerAlert:SetDimensions(alertWidth, self.CHEST_ALERT_HEIGHT)
    centerAlert:SetClampedToScreen(true)
    local alertPosition = self.sv.chestAlertPosition
    centerAlert:SetAnchor(
        alertPosition.point or CENTER,
        GuiRoot,
        alertPosition.relativePoint or CENTER,
        alertPosition.x or 0,
        alertPosition.y or 0
    )
    centerAlert:SetDrawLayer(DL_OVERLAY)
    centerAlert:SetDrawTier(DT_HIGH)
    centerAlert:SetDrawLevel(100)
    centerAlert:SetHidden(true)
    centerAlert:SetHandler("OnMoveStop", function(control)
        self:SaveChestAlertPosition(control)
    end)
    centerAlert:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsChestAlertPreviewMovable() then
            control:StartMoving()
        end
    end)
    centerAlert:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
        end
    end)

    local centerAlertBackground = WM:CreateControl("DynamicEncounterTrackerCenterChestAlertBackground", centerAlert, CT_BACKDROP)
    self.centerAlertBackground = centerAlertBackground
    centerAlertBackground:SetAnchorFill(centerAlert)
    centerAlertBackground:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    centerAlertBackground:SetMouseEnabled(false)

    local centerAlertLabel = WM:CreateControl("DynamicEncounterTrackerCenterChestAlertLabel", centerAlert, CT_LABEL)
    self.centerAlertLabel = centerAlertLabel
    centerAlertLabel:SetAnchorFill(centerAlert)
    centerAlertLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    centerAlertLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    centerAlertLabel:SetMaxLineCount(2)
    centerAlertLabel:SetMouseEnabled(false)

    self.centerAlertFrameLines = {
        top = self:CreateFrameLine("DynamicEncounterTrackerCenterAlertFrameTop", centerAlert),
        bottom = self:CreateFrameLine("DynamicEncounterTrackerCenterAlertFrameBottom", centerAlert),
        left = self:CreateFrameLine("DynamicEncounterTrackerCenterAlertFrameLeft", centerAlert),
        right = self:CreateFrameLine("DynamicEncounterTrackerCenterAlertFrameRight", centerAlert),
    }
    self.centerAlertFrameLines.top:SetAnchor(TOPLEFT, centerAlert, TOPLEFT, 0, 0)
    self.centerAlertFrameLines.top:SetAnchor(TOPRIGHT, centerAlert, TOPRIGHT, 0, 0)
    self.centerAlertFrameLines.top:SetHeight(FRAME_THICKNESS)
    self.centerAlertFrameLines.bottom:SetAnchor(BOTTOMLEFT, centerAlert, BOTTOMLEFT, 0, 0)
    self.centerAlertFrameLines.bottom:SetAnchor(BOTTOMRIGHT, centerAlert, BOTTOMRIGHT, 0, 0)
    self.centerAlertFrameLines.bottom:SetHeight(FRAME_THICKNESS)
    self.centerAlertFrameLines.left:SetAnchor(TOPLEFT, centerAlert, TOPLEFT, 0, 0)
    self.centerAlertFrameLines.left:SetAnchor(BOTTOMLEFT, centerAlert, BOTTOMLEFT, 0, 0)
    self.centerAlertFrameLines.left:SetWidth(FRAME_THICKNESS)
    self.centerAlertFrameLines.right:SetAnchor(TOPRIGHT, centerAlert, TOPRIGHT, 0, 0)
    self.centerAlertFrameLines.right:SetAnchor(BOTTOMRIGHT, centerAlert, BOTTOMRIGHT, 0, 0)
    self.centerAlertFrameLines.right:SetWidth(FRAME_THICKNESS)

    -- Dedicated full-window drag surface for the settings preview.
    -- Backdrop, label and frame controls stay mouse-transparent.
    local centerAlertDragSurface = WM:CreateControl("DynamicEncounterTrackerCenterChestAlertDragSurface", centerAlert, CT_CONTROL)
    self.centerAlertDragSurface = centerAlertDragSurface
    centerAlertDragSurface:SetAnchorFill(centerAlert)
    centerAlertDragSurface:SetMouseEnabled(false)
    centerAlertDragSurface:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsChestAlertPreviewMovable() then
            centerAlert:StartMoving()
        end
    end)
    centerAlertDragSurface:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            centerAlert:StopMovingOrResizing()
            self:SaveChestAlertPosition(centerAlert)
        end
    end)

    self:RefreshWindowLayout()
    self:ApplyAppearance()
    self:ApplyLockState()
    self:ApplyChestAlertInteraction()
    self:RefreshUI()
end


function DE:GetRowBaseHeight()
    return zo_max(26, (tonumber(self.sv.textSize) or 18) + 8)
end

function DE:PositionRow(row, y, rowHeight)
    local availableWidth = zo_max(80, self.window:GetWidth() - ROW_VALUE_LEFT - ROW_RIGHT_MARGIN)

    row.label:ClearAnchors()
    row.label:SetAnchor(TOPLEFT, self.window, TOPLEFT, ROW_LABEL_LEFT, y)
    row.label:SetDimensions(ROW_LABEL_WIDTH, rowHeight)

    row.value:ClearAnchors()
    row.value:SetAnchor(TOPLEFT, self.window, TOPLEFT, ROW_VALUE_LEFT, y)
    row.value:SetDimensions(availableWidth, rowHeight)
end

function DE:MeasureRowHeight(row)
    local baseHeight = self:GetRowBaseHeight()
    if not row.allowWrap then
        return baseHeight
    end

    local availableWidth = zo_max(80, self.window:GetWidth() - ROW_VALUE_LEFT - ROW_RIGHT_MARGIN)
    row.value:SetWidth(availableWidth)
    row.value:SetHeight(0)

    local textHeight = row.value.GetTextHeight and row.value:GetTextHeight() or 0
    if type(textHeight) ~= "number" or textHeight <= 0 then
        textHeight = baseHeight
    end

    return zo_max(baseHeight, math.ceil(textHeight + 4))
end

function DE:RefreshMinimalToggleControl()
    if not self.minimalToggle then
        return
    end

    self.minimalToggle:SetText("_")
end

function DE:MeasureLabelTextWidth(label)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, self.window, TOPLEFT, 0, 0)
    label:SetWidth(self.WINDOW_MAX_WIDTH)
    label:SetHeight(0)

    local textWidth = label.GetTextWidth and label:GetTextWidth() or 0
    if type(textWidth) ~= "number" or textWidth <= 0 then
        textWidth = 60
    end
    return textWidth
end

function DE:RefreshWindowLayoutMinimal()
    local row = self.rows.minimal
    local participationRow = self.rows.minimalParticipation
    local rowY = 45
    row.value:SetHidden(false)

    self.titleLabel:SetText(self:T("DE_ADDON_NAME_SHORT"))

    local participationText, participationColor = self:GetMinimalParticipationLine()
    local showParticipationRow = participationText ~= nil
    participationRow.value:SetHidden(not showParticipationRow)
    if showParticipationRow then
        participationRow.value:SetText(participationText)
        SetLabelColor(participationRow.value, participationColor)
    end

    local statusTextWidth = self:MeasureLabelTextWidth(row.value)
    local titleTextWidth = self:MeasureLabelTextWidth(self.titleLabel)
    local participationTextWidth = showParticipationRow and self:MeasureLabelTextWidth(participationRow.value) or 0
    local textHeight = self:MeasureRowHeight(row)

    local closeButtonVisible = self.closeButton and not self.closeButton:IsHidden()
    local minimalToggleVisible = self.minimalToggle and not self.minimalToggle:IsHidden()
    local minimalRightMargin
    if closeButtonVisible and minimalToggleVisible then
        minimalRightMargin = 44
    elseif closeButtonVisible or minimalToggleVisible then
        minimalRightMargin = 24
    else
        minimalRightMargin = ROW_LABEL_LEFT -- neither button visible: mirror the left margin for a symmetric, centered look
    end
    local safetyMargin = 24 -- guards against GetTextWidth rounding/measurement slack
    local contentWidth = zo_max(statusTextWidth, titleTextWidth, participationTextWidth)
    local width = zo_clamp(math.ceil(contentWidth) + safetyMargin + ROW_LABEL_LEFT + minimalRightMargin, 60, self.WINDOW_MAX_WIDTH)

    row.value:ClearAnchors()
    row.value:SetAnchor(TOPLEFT, self.window, TOPLEFT, ROW_LABEL_LEFT, rowY)
    row.value:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -minimalRightMargin, rowY)
    row.value:SetHeight(textHeight)

    local contentBottom = rowY + math.ceil(textHeight)
    if showParticipationRow then
        local participationRowY = contentBottom + 1
        participationRow.value:ClearAnchors()
        participationRow.value:SetAnchor(TOPLEFT, self.window, TOPLEFT, ROW_LABEL_LEFT, participationRowY)
        participationRow.value:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -minimalRightMargin, participationRowY)
        participationRow.value:SetHeight(textHeight)
        contentBottom = participationRowY + math.ceil(textHeight)
    end

    local height = zo_max(self.MINIMAL_MIN_HEIGHT, contentBottom + 11)

    self.titleLabel:ClearAnchors()
    self.titleLabel:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 7)
    self.titleLabel:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -minimalRightMargin, 7)
    self.titleLabel:SetHeight(31)

    self.currentWindowHeight = height
    self.window:SetDimensionConstraints(60, height, self.WINDOW_MAX_WIDTH, height)
    self.window:SetDimensions(width, height)
end

function DE:RefreshWindowLayout()
    if not self.window or not self.rows then
        return
    end

    self:RefreshMinimalToggleControl()

    if self.sv.minimalMode then
        self.rows.zone.label:SetHidden(true)
        self.rows.zone.value:SetHidden(true)
        self.rows.event.label:SetHidden(true)
        self.rows.event.value:SetHidden(true)
        self.rows.status.label:SetHidden(true)
        self.rows.status.value:SetHidden(true)
        self.rows.currentSection.label:SetHidden(true)
        self.rows.currentSection.value:SetHidden(true)
        self.rows.hint.label:SetHidden(true)
        self.rows.hint.value:SetHidden(true)

        self:RefreshWindowLayoutMinimal()
        self.sv.size.height = self.currentWindowHeight
        return
    end

    self.rows.minimal.value:SetHidden(true)
    self.rows.minimalParticipation.value:SetHidden(true)
    self.titleLabel:SetText(self:T("DE_ADDON_NAME"))
    self.titleLabel:ClearAnchors()
    self.titleLabel:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 7)
    self.titleLabel:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -44, 7)
    self.titleLabel:SetHeight(31)

    local y = 45
    local rowGap = 1

    local function Place(row, visible)
        row.label:SetHidden(not visible)
        row.value:SetHidden(not visible)
        if visible then
            local rowHeight = self:MeasureRowHeight(row)
            self:PositionRow(row, y, rowHeight)
            y = y + rowHeight + rowGap
        end
    end

    Place(self.rows.zone, true)
    Place(self.rows.event, true)
    Place(self.rows.status, true)
    Place(self.rows.currentSection, self.sv.showPhase ~= false)
    Place(self.rows.hint, self.sv.showHintInStatusWindow ~= false)

    local debugY = self:ModuleHook("debug", "LayoutStatusRows", self.window, y)
    if type(debugY) == "number" then
        y = debugY
    end

    local newHeight = zo_max(self.WINDOW_MIN_HEIGHT, y + 11)
    self.currentWindowHeight = newHeight
    local width = zo_clamp(self.sv.size.width or self.WINDOW_DEFAULT_WIDTH, self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    self.window:SetDimensionConstraints(self.WINDOW_MIN_WIDTH, newHeight, self.WINDOW_MAX_WIDTH, newHeight)
    self.window:SetDimensions(width, newHeight)
    self.sv.size.height = newHeight
end


function DE:SaveChestAlertPosition(control)
    local _, point, _, relativePoint, x, y = control:GetAnchor(0)
    self.sv.chestAlertPosition.point = point
    self.sv.chestAlertPosition.relativePoint = relativePoint
    self.sv.chestAlertPosition.x = x
    self.sv.chestAlertPosition.y = y
end

function DE:IsChestAlertPreviewMovable()
    return self.settingsPanelOpen == true
        and self.sv.enabled
        and self.sv.showChestHints
        and self.sv.showCenterChestAlert
        and self.sv.chestAlertMovable
end

function DE:ApplyChestAlertInteraction()
    if not self.centerAlertWindow or not self.sv then
        return
    end

    local movable = self:IsChestAlertPreviewMovable()
    self.centerAlertWindow:SetMovable(movable)
    self.centerAlertWindow:SetMouseEnabled(movable)
    if self.centerAlertDragSurface then
        self.centerAlertDragSurface:SetMouseEnabled(movable)
    end
end

function DE:ShowChestAlertPreview()
    if not self.centerAlertWindow then
        return
    end

    self.centerAlertGeneration = (self.centerAlertGeneration or 0) + 1
    self.centerAlertPreviewActive = true
    self.state.centerChestAlertText = self:T("DE_CHEST_ALERT_TEST")
    self.state.centerChestAlertUntil = nil
    self.centerAlertLabel:SetText(self.state.centerChestAlertText)
    self.centerAlertWindow:SetHidden(false)
    self:ApplyChestAlertInteraction()
end

function DE:UpdateChestAlertPreview()
    if self:IsChestAlertPreviewMovable() then
        self:ShowChestAlertPreview()
        return
    end

    self:ApplyChestAlertInteraction()
    if self.centerAlertPreviewActive then
        self:HideCenterChestAlert()
    end
end

function DE:HideCenterChestAlert()
    self.centerAlertGeneration = (self.centerAlertGeneration or 0) + 1
    self.centerAlertPreviewActive = false
    self.state.centerChestAlertText = nil
    self.state.centerChestAlertUntil = nil
    if self.centerAlertWindow then
        self.centerAlertWindow:SetHidden(true)
    end
    self:ApplyChestAlertInteraction()
end

function DE:ShowCenterChestAlert(text)
    if not self.centerAlertWindow
        or not self.sv
        or not self.sv.showChestHints
        or not self.sv.showCenterChestAlert then
        return false
    end

    local duration = zo_clamp(tonumber(self.sv.centerChestAlertSeconds) or self.centerChestAlertDefaultSeconds or 5, 1, 30)
    self.centerAlertGeneration = (self.centerAlertGeneration or 0) + 1
    local generation = self.centerAlertGeneration
    self.centerAlertPreviewActive = false
    self.state.centerChestAlertText = text or self:T("DE_CHEST_ALERT_REWARD")
    self.state.centerChestAlertUntil = GetTimeStamp() + duration
    self.centerAlertLabel:SetText(self.state.centerChestAlertText)
    self.centerAlertWindow:SetHidden(false)
    self:ApplyChestAlertInteraction()

    zo_callLater(function()
        if generation == self.centerAlertGeneration then
            self:HideCenterChestAlert()
            if self.settingsPanelOpen then
                self:UpdateChestAlertPreview()
            end
        end
    end, duration * 1000)
    return true
end

function DE:ApplyLockState()
    if not self.window then
        return
    end

    local unlocked = not self.sv.locked
    self.window:SetMovable(unlocked)
    self.window:SetMouseEnabled(unlocked)
    self.window:SetResizeHandleSize(unlocked and RESIZE_HANDLE_SIZE or 0)
    self.titleLabel:SetMouseEnabled(unlocked)
    self.closeButton:SetHidden(not unlocked or self.sv.showCloseButton == false)
    self.minimalToggle:SetHidden(not unlocked or self.sv.showMinimalToggleButton == false)
    self.resizeHandle:SetHidden(not unlocked)
    self.resizeHandle:SetMouseEnabled(false)
    self:ApplyChestAlertInteraction()
end

function DE:ApplyAppearance()
    if not self.window then
        return
    end

    local size = self.sv.textSize
    local normalFont = string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", size)
    local boldFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thin", size)
    local titleFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size + 4)

    self.titleLabel:SetFont(titleFont)
    self.minimalToggle:SetFont(boldFont)
    SetLabelColor(self.minimalToggle, self.sv.colors.label)
    local alertTextSize = zo_clamp(tonumber(self.sv.chestAlertTextSize) or 28, 16, 42)
    self.centerAlertLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", alertTextSize))

    for _, row in pairs(self.rows) do
        row.label:SetFont(normalFont)
        row.value:SetFont(boldFont)
        SetLabelColor(row.label, self.sv.colors.label)
    end

    SetLabelColor(self.titleLabel, self.sv.colors.title)

    local frame = self.sv.colors.frame
    local divider = self.sv.colors.border
    self.background:SetCenterColor(0.015, 0.018, 0.02, self.sv.backgroundOpacity)
    local alertBackground = self.sv.chestAlertColors.background
    local alertText = self.sv.chestAlertColors.text
    self.centerAlertBackground:SetCenterColor(
        alertBackground[1],
        alertBackground[2],
        alertBackground[3],
        alertBackground[4] or 1
    )
    SetLabelColor(self.centerAlertLabel, alertText)
    self.divider:SetColor(divider[1], divider[2], divider[3], (divider[4] or 1) * 0.65)

    for _, line in pairs(self.frameLines) do
        line:SetColor(frame[1], frame[2], frame[3], frame[4] or 1)
    end
    for _, line in pairs(self.resizeHandleLines) do
        line:SetColor(frame[1], frame[2], frame[3], frame[4] or 1)
    end
    local alertFrame = self.sv.chestAlertColors.frame
    for _, line in pairs(self.centerAlertFrameLines) do
        line:SetColor(alertFrame[1], alertFrame[2], alertFrame[3], alertFrame[4] or 1)
    end
    self:ModuleHook("debug", "ApplyStatusAppearance", normalFont, boldFont, divider)
end


function DE:GetParticipationStatusTextAndColor()
    local participationState = self.state.participationDisplayState
    if participationState == self.PARTICIPATION_DETECTED then
        return self:T("DE_PARTICIPATION_DETECTED"), self.sv.colors.active
    elseif participationState == self.PARTICIPATION_OPEN then
        return self:T("DE_PARTICIPATION_OPEN"), self.sv.colors.value
    end

    return self:T("DE_PARTICIPATION_UNKNOWN"), self.sv.colors.cooldown
end

function DE:GetMinimalParticipationLine()
    if self.state.status ~= self.STATUS_ACTIVE then
        return nil
    end
    if self.sv.showParticipationInStatus == false then
        return nil
    end
    if self.state.participationDisplayState ~= self.PARTICIPATION_DETECTED then
        return nil
    end

    return self:T("DE_PARTICIPATION_DETECTED"), self.sv.colors.active
end

function DE:GetStatusTextAndColor(includeParticipation)
    local status = self.state.status
    if includeParticipation == nil then
        includeParticipation = true
    end

    if status == self.STATUS_ACTIVE then
        local parts = { self:T("DE_STATUS_UP") }
        if self.sv.showStepInStatus ~= false then
            local ordinal = self.state.currentStepOrdinal
            local total = self.state.currentStepTotal
            local stepText
            if ordinal and total then
                stepText = string.format("%d/%d", ordinal, total)
            elseif total then
                stepText = string.format("?/%d", total)
            else
                stepText = "-"
            end

            local stepPart = self:T("DE_STATUS_STEP_FMT", stepText)
            if self.sv.showStepProgressInStatus ~= false then
                local progressPercent = FormatProgressPercent(self.state.currentProgress, self.state.maxProgress) or "-"
                stepPart = string.format("%s (%s)", stepPart, progressPercent)
            end
            parts[#parts + 1] = stepPart
        elseif self.sv.showStepProgressInStatus ~= false then
            local progressPercent = FormatProgressPercent(self.state.currentProgress, self.state.maxProgress) or "-"
            parts[#parts + 1] = self:T("DE_STATUS_PROGRESS_FMT", progressPercent)
        end

        if includeParticipation and self.sv.showParticipationInStatus ~= false then
            local participationText, participationColor = self:GetParticipationStatusTextAndColor()
            parts[#parts + 1] = ColorizeText(participationText, participationColor)
        end

        return table.concat(parts, " · "), self.sv.colors.active
    elseif status == self.STATUS_COOLDOWN then
        if self.sv.showRespawnTimer == false then
            return self:T("DE_STATUS_COOLDOWN"), self.sv.colors.cooldown
        end

        local phase, seconds = self:GetRespawnPhase(GetTimeStamp())
        if phase == self.RESPAWN_PHASE_COOLDOWN then
            return self:T("DE_STATUS_COOLDOWN_FMT", FormatCountdown(seconds)), self.sv.colors.cooldown
        elseif phase == self.RESPAWN_PHASE_WINDOW then
            return self:T("DE_STATUS_SPAWN_WINDOW_FMT", FormatCountdown(seconds)), self.sv.colors.cooldown
        elseif phase == self.RESPAWN_PHASE_OVERDUE then
            if self.sv.showRespawnOverrun ~= false then
                return self:T("DE_STATUS_SPAWN_EXPECTED_OVERDUE_FMT", FormatCountdown(seconds)), self.sv.colors.cooldown
            end
            return self:T("DE_STATUS_SPAWN_EXPECTED"), self.sv.colors.cooldown
        end

        return self:T("DE_STATUS_COOLDOWN"), self.sv.colors.cooldown
    elseif status == self.STATUS_UNSUPPORTED then
        return self:T("DE_STATUS_NO_EVENTS"), self.sv.colors.unknown
    end

    return self:T("DE_STATUS_UNKNOWN"), self.sv.colors.unknown
end


function DE:GetCurrentSectionText()
    if self.state.status ~= self.STATUS_ACTIVE then
        return "-"
    end

    if self.sv.showPhase and self.state.phaseName and self.state.phaseName ~= "" then
        return self.state.phaseName
    end

    return self:T("DE_SECTION_FALLBACK")
end


function DE:GetHintTextAndColor()
    if self.sv.showHintInStatusWindow ~= false
        and self.state.chestHintText
        and self.state.chestHintUntil
        and GetTimeStamp() < self.state.chestHintUntil then
        return self.state.chestHintText, self.sv.colors.cooldown
    end

    if self.state.status == self.STATUS_COOLDOWN and self.sv.showRespawnTimer ~= false then
        local phase = self:GetRespawnPhase(GetTimeStamp())
        if phase == self.RESPAWN_PHASE_WINDOW and self.sv.showSpawnWindowHint ~= false then
            return self:T("DE_HINT_SPAWN_WINDOW"), self.sv.colors.cooldown
        elseif phase == self.RESPAWN_PHASE_OVERDUE and self.sv.showSpawnWindowHint ~= false then
            return self:T("DE_HINT_SPAWN_OVERDUE"), self.sv.colors.cooldown
        end
    end

    if self.state.status == self.STATUS_ACTIVE
        and self.state.phaseHintText
        and self.state.phaseHintText ~= "" then
        return self.state.phaseHintText, self.sv.colors.value
    end

    return "-", self.sv.colors.value
end




function DE:RefreshUI()
    if not self.window or not self.sv then
        return
    end

    local active = self.state.status == self.STATUS_ACTIVE
    self.rows.zone.value:SetText(self.state.zoneName ~= "" and self.state.zoneName or "--")
    self.rows.event.value:SetText(active and (self.state.eventName or "-") or "-")
    self.rows.currentSection.value:SetText(self:GetCurrentSectionText())

    local statusText, statusColor = self:GetStatusTextAndColor()
    self.rows.status.value:SetText(statusText)
    SetLabelColor(self.rows.status.value, statusColor)

    local minimalStatusText, minimalStatusColor = self:GetStatusTextAndColor(false)
    self.rows.minimal.value:SetText(string.format("%s %s", self:T("DE_LABEL_STATUS"), minimalStatusText))
    SetLabelColor(self.rows.minimal.value, minimalStatusColor)

    local hintText, hintColor = self:GetHintTextAndColor()
    self.rows.hint.value:SetText(hintText)
    SetLabelColor(self.rows.hint.value, hintColor)

    self:ModuleHook("debug", "RefreshStatusRows", active)

    SetLabelColor(self.rows.zone.value, self.sv.colors.value)
    SetLabelColor(self.rows.event.value, self.sv.colors.value)
    SetLabelColor(self.rows.currentSection.value, self.sv.colors.value)

    self:RefreshWindowLayout()
    self:RefreshVisibility()
end

function DE:IsWorldMapScene(scene)
    if not scene then
        return false
    end

    local worldMapScene = SCENE_MANAGER:GetScene("worldMap")
    local gamepadWorldMapScene = SCENE_MANAGER:GetScene("gamepad_worldMap")
    return scene == worldMapScene or scene == gamepadWorldMapScene
end

function DE:IsHudScene(scene)
    return scene ~= nil and (scene == HUD_SCENE or scene == HUD_UI_SCENE)
end

function DE:ShouldShowInCurrentScene()
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene then
        return false
    end

    if self:IsWorldMapScene(scene) then
        return self.sv.showOnWorldMap
    end

    if not self.sv.hideInMenus then
        return true
    end

    return self:IsHudScene(scene)
end

function DE:RefreshVisibility()
    if not self.window or not self.sv then
        return
    end

    local shouldShow = self.state.runtimeEnabled
        and self.state.zoneRuntimeActive
        and self.sv.enabled
        and self.sv.showWindow
        and self:ShouldShowInCurrentScene()

    if shouldShow and not self.state.zoneEncounterConfigs then
        shouldShow = false
    end

    self.window:SetHidden(not shouldShow)
end

function DE:RegisterSceneCallback()
    if self.sceneCallback then
        return
    end

    self.sceneCallback = function(scene, _, newState)
        if not self.state.runtimeEnabled or not self.state.zoneRuntimeActive then
            return
        end

        if newState == SCENE_SHOWN and self:IsWorldMapScene(scene) then
            self:UpdateCurrentZone(false)
            self:ScanActiveWorldEvents()
        end

        self:RefreshVisibility()
    end
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", self.sceneCallback)
end

function DE:UnregisterSceneCallback()
    if not self.sceneCallback then
        return
    end

    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", self.sceneCallback)
    self.sceneCallback = nil
end

function DE:ResetWindowPosition()
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)

    self.sv.position.point = TOPLEFT
    self.sv.position.relativePoint = TOPLEFT
    self.sv.position.x = 200
    self.sv.position.y = 200
end

function DE:ResetChestAlertPosition()
    self.centerAlertWindow:ClearAnchors()
    self.centerAlertWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    self.sv.chestAlertPosition.point = CENTER
    self.sv.chestAlertPosition.relativePoint = CENTER
    self.sv.chestAlertPosition.x = 0
    self.sv.chestAlertPosition.y = 0
    self:UpdateChestAlertPreview()
end

function DE:ResetWindowSize()
    self:SetWindowWidth(self.defaults.size.width)
end

local function CopyColorValues(source)
    return { source[1], source[2], source[3], source[4] or 1 }
end

function DE:ResetStatusWindowAppearance()
    self.sv.textSize = self.defaults.textSize
    self.sv.backgroundOpacity = self.defaults.backgroundOpacity
    self.sv.size.width = self.defaults.size.width
    for colorName, defaultColor in pairs(self.defaults.colors) do
        self.sv.colors[colorName] = CopyColorValues(defaultColor)
    end
    self:SetWindowWidth(self.defaults.size.width)
    self:ApplyAppearance()
    self:RefreshUI()
end

function DE:ResetChestAlertAppearance()
    self.sv.chestAlertTextSize = self.defaults.chestAlertTextSize
    self.sv.chestAlertSize.width = self.defaults.chestAlertSize.width
    self.sv.chestAlertSize.height = self.defaults.chestAlertSize.height
    for colorName, defaultColor in pairs(self.defaults.chestAlertColors) do
        self.sv.chestAlertColors[colorName] = CopyColorValues(defaultColor)
    end
    self:SetChestAlertWidth(self.defaults.chestAlertSize.width)
    self:ApplyAppearance()
    self:UpdateChestAlertPreview()
end
