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
    local line = WM:CreateControl(name, parent, CT_BACKDROP)
    line:SetEdgeTexture(nil, 1, 1, 0)
    line:SetEdgeColor(0, 0, 0, 0)
    line:SetInsets(0, 0, 0, 0)
    return line
end

-- Reproduces ZO_CloseButton's dim-normal/bright-hover look on controls that
-- have no dedicated mouseOver texture of their own (icon buttons using a
-- single generic texture, or the "_" minimal-toggle text label).
local HOVER_DIM_ALPHA = 0.6
function DE:AddHoverDimming(control)
    control:SetAlpha(HOVER_DIM_ALPHA)
    control:SetHandler("OnMouseEnter", function(c) c:SetAlpha(1) end, "DynamicEncounterTrackerHoverDimEnter")
    control:SetHandler("OnMouseExit", function(c) c:SetAlpha(HOVER_DIM_ALPHA) end, "DynamicEncounterTrackerHoverDimExit")
end

-- Dynamic tooltip text needs a direct hover handler instead of this fixed-text helper.
function DE:AddHoverTooltip(control, stringId)
    control:SetHandler("OnMouseEnter", function(c)
        ZO_Tooltips_ShowTextTooltip(c, TOP, self:T(stringId))
    end, "DynamicEncounterTrackerHoverTooltipEnter")
    control:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end, "DynamicEncounterTrackerHoverTooltipExit")
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
    -- Suppress saved-width layout updates while the user is actively resizing.
    window:SetHandler("OnResizeStart", function()
        self.isResizingWindow = true
    end)
    window:SetHandler("OnResizeStop", function(control)
        self.isResizingWindow = false
        self:SaveWindowSize(control)
        self:RefreshUI()
    end)

    local background = WM:CreateControl("DynamicEncounterTrackerWindowBackground", window, CT_BACKDROP)
    self.background = background
    background:SetAnchorFill(window)
    background:SetEdgeTexture(nil, 1, 1, 0)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetInsets(0, 0, 0, 0)

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

    if self:HasDebugModule() then
        local devLabel = WM:CreateControl("DynamicEncounterTrackerWindowDevLabel", window, CT_LABEL)
        self.devLabel = devLabel
        devLabel:SetAnchor(BOTTOM, window, TOP, 0, -6)
        devLabel:SetFont("$(BOLD_FONT)|28|soft-shadow-thick")
        devLabel:SetColor(1, 0.2, 0.2, 1)
        devLabel:SetText(string.format("DEV BUILD %s", self.version))
        devLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end

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

    -- ZO_CloseButton supplies its own state textures; custom icons need alpha dimming.
    local closeButton = WM:CreateControlFromVirtual("DynamicEncounterTrackerWindowClose", window, "ZO_CloseButton")
    self.closeButton = closeButton
    closeButton:ClearAnchors()
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 8)
    closeButton:SetHandler("OnClicked", function()
        self.sv.showWindow = false
        self:RefreshVisibility()
    end)
    self:AddHoverTooltip(closeButton, "DE_CLOSE_BUTTON_TOOLTIP")

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
    self:AddHoverDimming(minimalToggle)
    self:AddHoverTooltip(minimalToggle, "DE_MINIMAL_TOGGLE_BUTTON_TOOLTIP")

    -- CT_BUTTON (not CT_TEXTURE) so the control gets ESO's built-in button
    -- click priority, the same way ZO_CloseButton reliably receives clicks
    -- on top of this movable window's own drag area.
    local relayButton = WM:CreateControl("DynamicEncounterTrackerWindowRelayButton", window, CT_BUTTON)
    self.relayButton = relayButton
    relayButton:SetDimensions(26, 26)
    relayButton:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 6)
    relayButton:SetNormalTexture("EsoUI/Art/Mail/mail_inbox_unreadMessage.dds")
    relayButton:SetMouseEnabled(true)
    relayButton:SetHandler("OnClicked", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        self:ShowRelayShareDialog()
    end)
    self:AddHoverDimming(relayButton)
    -- A named handler lets dynamic tooltip logic coexist with hover dimming.
    relayButton:SetHandler("OnMouseEnter", function(control)
        local stringId = self.state.status == self.STATUS_ACTIVE and "DE_RELAY_ENCOUNTER_BUTTON_TOOLTIP" or "DE_RELAY_TIMER_BUTTON_TOOLTIP"
        ZO_Tooltips_ShowTextTooltip(control, TOP, self:T(stringId))
    end, "DynamicEncounterTrackerRelayButtonTooltipEnter")
    relayButton:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end, "DynamicEncounterTrackerRelayButtonTooltipExit")

    -- Request stays available without own state; sharing does not.
    local relayRequestButton = WM:CreateControl("DynamicEncounterTrackerWindowRelayRequestButton", window, CT_BUTTON)
    self.relayRequestButton = relayRequestButton
    relayRequestButton:SetDimensions(26, 26)
    relayRequestButton:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 6)
    relayRequestButton:SetNormalTexture("EsoUI/Art/Miscellaneous/help_icon.dds")
    relayRequestButton:SetMouseEnabled(true)
    relayRequestButton:SetHandler("OnClicked", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        self:ShowRelayRequestDialog()
    end)
    self:AddHoverDimming(relayRequestButton)
    self:AddHoverTooltip(relayRequestButton, "DE_RELAY_REQUEST_BUTTON_TOOLTIP")

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

    self:CreateRelayChannelDialog()
    self:CreateRelayEncounterChannelDialog()
    self:CreateRelayRequestChannelDialog()

    self:RefreshWindowLayout()
    self:ApplyAppearance()
    self:ApplyLockState()
    self:ApplyChestAlertInteraction()
    self:RefreshUI()
end

-- Options are listed top to bottom in this table's order. New channels (e.g.
-- future guild chat slots) can be appended here without further layout changes.
DE.RELAY_CHANNEL_DIALOG_OPTIONS = {
    { labelKey = "DE_RELAY_CHANNEL_SAY", channelType = CHAT_CHANNEL_SAY },
    { labelKey = "DE_RELAY_CHANNEL_ZONE", channelType = CHAT_CHANNEL_ZONE },
}

-- The say/zone options are always present and static (built once below). Guild
-- options are appended dynamically on every Show, since guild membership can
-- change between sessions - see RebuildRelayChannelDialogGuildButtons.
local RELAY_CHANNEL_DIALOG_BUTTON_HEIGHT = 26
local RELAY_CHANNEL_DIALOG_BUTTON_GAP = 6
local RELAY_CHANNEL_DIALOG_WIDTH = 220
local RELAY_CHANNEL_DIALOG_TOP_PADDING = 44
local RELAY_CHANNEL_DIALOG_BOTTOM_PADDING = 14
local RELAY_CHANNEL_DIALOG_SECTION_GAP = 16

function DE:CreateRelayChannelDialog()
    local optionCount = #self.RELAY_CHANNEL_DIALOG_OPTIONS
    local buttonHeight = RELAY_CHANNEL_DIALOG_BUTTON_HEIGHT
    local buttonGap = RELAY_CHANNEL_DIALOG_BUTTON_GAP
    local dialogWidth = RELAY_CHANNEL_DIALOG_WIDTH
    local topPadding = RELAY_CHANNEL_DIALOG_TOP_PADDING
    local optionsHeight = (optionCount * buttonHeight) + ((optionCount - 1) * buttonGap)

    local dialog = WM:CreateTopLevelWindow("DynamicEncounterTrackerRelayChannelDialog")
    self.relayChannelDialog = dialog
    dialog:SetDimensions(dialogWidth, topPadding + optionsHeight)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetDrawLayer(DL_OVERLAY)
    dialog:SetDrawTier(DT_HIGH)
    dialog:SetDrawLevel(200)
    dialog:SetHidden(true)
    dialog:SetMouseEnabled(true)
    dialog:SetKeyboardEnabled(true)
    dialog:SetHandler("OnKeyUp", function(_, key)
        if key == KEY_ESCAPE then
            self:HideRelayChannelChoiceDialog()
        end
    end)

    local underlay = WM:CreateControl("DynamicEncounterTrackerRelayChannelDialogUnderlay", GuiRoot, CT_TEXTURE)
    self.relayChannelDialogUnderlay = underlay
    underlay:SetAnchorFill(GuiRoot)
    underlay:SetColor(0, 0, 0, 0.55)
    underlay:SetDrawLayer(DL_OVERLAY)
    underlay:SetDrawTier(DT_HIGH)
    underlay:SetDrawLevel(199)
    underlay:SetHidden(true)
    underlay:SetMouseEnabled(true)
    underlay:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideRelayChannelChoiceDialog()
        end
    end)

    local background = WM:CreateControl("DynamicEncounterTrackerRelayChannelDialogBg", dialog, CT_BACKDROP)
    background:SetAnchorFill(dialog)
    background:SetCenterColor(0.015, 0.018, 0.02, 0.95)
    background:SetEdgeTexture(nil, 1, 1, 0)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetInsets(0, 0, 0, 0)

    local title = WM:CreateControl("DynamicEncounterTrackerRelayChannelDialogTitle", dialog, CT_LABEL)
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 14, 12)
    title:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -14, 12)
    title:SetHeight(22)
    title:SetText(self:T("DE_RELAY_CHANNEL_DIALOG_TITLE"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetFont("$(BOLD_FONT)|16|soft-shadow-thin")

    local function CreateDialogButton(name, labelText)
        local button = WM:CreateControlFromVirtual(name, dialog, "ZO_DefaultButton")
        button:SetDimensions(dialogWidth - 28, buttonHeight)
        button:SetText(labelText)
        return button
    end

    self.relayChannelDialogButtons = {}
    local previousButton
    for _, option in ipairs(self.RELAY_CHANNEL_DIALOG_OPTIONS) do
        local button = CreateDialogButton("DynamicEncounterTrackerRelayChannelDialogOption" .. #self.relayChannelDialogButtons + 1, self:T(option.labelKey))
        if previousButton then
            button:SetAnchor(TOP, previousButton, BOTTOM, 0, buttonGap)
        else
            button:SetAnchor(TOP, dialog, TOP, 0, topPadding)
        end
        button:SetHandler("OnClicked", function()
            local config = self.relayChannelDialogConfig
            self:HideRelayChannelChoiceDialog()
            self:SendRelayTimerMessage(config, option.channelType)
        end)
        self.relayChannelDialogButtons[#self.relayChannelDialogButtons + 1] = button
        previousButton = button
    end
    self.relayChannelDialogLastStaticButton = previousButton

    self.relayChannelDialogGuildHeader = nil
    self.relayChannelDialogGuildButtons = {}
    self.relayChannelDialogCancelButton = nil
end

-- Appends the player's current guild channels below the static say/zone options,
-- with a separating header, and resizes the dialog to fit. Rebuilt on every Show
-- since guild membership can change between sessions.
function DE:RebuildRelayChannelDialogGuildButtons()
    local buttonHeight = RELAY_CHANNEL_DIALOG_BUTTON_HEIGHT
    local buttonGap = RELAY_CHANNEL_DIALOG_BUTTON_GAP
    local dialogWidth = RELAY_CHANNEL_DIALOG_WIDTH
    local topPadding = RELAY_CHANNEL_DIALOG_TOP_PADDING
    local bottomPadding = RELAY_CHANNEL_DIALOG_BOTTOM_PADDING
    local cancelGap = 10
    local optionCount = #self.RELAY_CHANNEL_DIALOG_OPTIONS
    local staticOptionsHeight = (optionCount * buttonHeight) + ((optionCount - 1) * buttonGap)

    for _, button in ipairs(self.relayChannelDialogGuildButtons) do
        button:SetHidden(true)
        button:ClearAnchors()
    end

    local guildChannels = self:GetActiveGuildChannels()
    local anchorControl = self.relayChannelDialogLastStaticButton
    local bottomOffset = topPadding + staticOptionsHeight

    if not self.relayChannelDialogGuildHeader then
        local header = WM:CreateControl("DynamicEncounterTrackerRelayChannelDialogGuildHeader", self.relayChannelDialog, CT_LABEL)
        header:SetHeight(18)
        header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        header:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
        header:SetText(self:T("DE_RELAY_CHANNEL_DIALOG_GUILD_HEADER"))
        self.relayChannelDialogGuildHeader = header
    end
    local header = self.relayChannelDialogGuildHeader
    header:SetHidden(#guildChannels == 0)
    if #guildChannels > 0 then
        header:ClearAnchors()
        header:SetAnchor(TOP, anchorControl, BOTTOM, 0, RELAY_CHANNEL_DIALOG_SECTION_GAP)
        anchorControl = header
        bottomOffset = bottomOffset + RELAY_CHANNEL_DIALOG_SECTION_GAP + 18
    end

    local function AcquireGuildButton(index)
        local button = self.relayChannelDialogGuildButtons[index]
        if not button then
            button = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayChannelDialogGuildOption" .. index, self.relayChannelDialog, "ZO_DefaultButton")
            button:SetDimensions(dialogWidth - 28, buttonHeight)
            self.relayChannelDialogGuildButtons[index] = button
        end
        button:SetHidden(false)
        return button
    end

    for index, guildChannel in ipairs(guildChannels) do
        local button = AcquireGuildButton(index)
        button:SetText(self:T("DE_RELAY_CHANNEL_GUILD_FMT", guildChannel.guildIndex, guildChannel.guildName))
        button:ClearAnchors()
        button:SetAnchor(TOP, anchorControl, BOTTOM, 0, buttonGap)
        button:SetHandler("OnClicked", function()
            local config = self.relayChannelDialogConfig
            self:HideRelayChannelChoiceDialog()
            self:SendRelayTimerMessage(config, guildChannel.channelType)
        end)
        anchorControl = button
        bottomOffset = bottomOffset + buttonHeight + buttonGap
    end

    if not self.relayChannelDialogCancelButton then
        local cancelButton = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayChannelDialogCancel", self.relayChannelDialog, "ZO_DefaultButton")
        cancelButton:SetDimensions(dialogWidth - 28, buttonHeight)
        cancelButton:SetText(GetString(SI_DIALOG_CANCEL))
        cancelButton:SetHandler("OnClicked", function()
            self:HideRelayChannelChoiceDialog()
        end)
        self.relayChannelDialogCancelButton = cancelButton
    end
    local cancelButton = self.relayChannelDialogCancelButton
    cancelButton:ClearAnchors()
    cancelButton:SetAnchor(TOP, anchorControl, BOTTOM, 0, cancelGap)
    bottomOffset = bottomOffset + cancelGap + buttonHeight + bottomPadding

    self.relayChannelDialog:SetDimensions(dialogWidth, bottomOffset)
end

-- Say/zone requests require the implicit local encounter; guild requests do not.
function DE:CreateRelayRequestChannelDialog()
    local dialog = WM:CreateTopLevelWindow("DynamicEncounterTrackerRelayRequestChannelDialog")
    self.relayRequestChannelDialog = dialog
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetDrawLayer(DL_OVERLAY)
    dialog:SetDrawTier(DT_HIGH)
    dialog:SetDrawLevel(200)
    dialog:SetHidden(true)
    dialog:SetMouseEnabled(true)
    dialog:SetKeyboardEnabled(true)
    dialog:SetHandler("OnKeyUp", function(_, key)
        if key == KEY_ESCAPE then
            self:HideRelayRequestChannelChoiceDialog()
        end
    end)

    local underlay = WM:CreateControl("DynamicEncounterTrackerRelayRequestChannelDialogUnderlay", GuiRoot, CT_TEXTURE)
    self.relayRequestChannelDialogUnderlay = underlay
    underlay:SetAnchorFill(GuiRoot)
    underlay:SetColor(0, 0, 0, 0.55)
    underlay:SetDrawLayer(DL_OVERLAY)
    underlay:SetDrawTier(DT_HIGH)
    underlay:SetDrawLevel(199)
    underlay:SetHidden(true)
    underlay:SetMouseEnabled(true)
    underlay:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideRelayRequestChannelChoiceDialog()
        end
    end)

    local background = WM:CreateControl("DynamicEncounterTrackerRelayRequestChannelDialogBg", dialog, CT_BACKDROP)
    background:SetAnchorFill(dialog)
    background:SetCenterColor(0.015, 0.018, 0.02, 0.95)
    background:SetEdgeTexture(nil, 1, 1, 0)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetInsets(0, 0, 0, 0)

    local title = WM:CreateControl("DynamicEncounterTrackerRelayRequestChannelDialogTitle", dialog, CT_LABEL)
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 14, 12)
    title:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -14, 12)
    title:SetHeight(22)
    title:SetText(self:T("DE_RELAY_REQUEST_CHANNEL_DIALOG_TITLE"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetFont("$(BOLD_FONT)|16|soft-shadow-thin")

    self.relayRequestChannelDialogStaticButtons = {}
    self.relayRequestChannelDialogGuildHeader = nil
    self.relayRequestChannelDialogGuildButtons = {}
    self.relayRequestChannelDialogCancelButton = nil
end

function DE:RebuildRelayRequestChannelDialogButtons()
    local buttonHeight = RELAY_CHANNEL_DIALOG_BUTTON_HEIGHT
    local buttonGap = RELAY_CHANNEL_DIALOG_BUTTON_GAP
    local dialogWidth = RELAY_CHANNEL_DIALOG_WIDTH
    local topPadding = RELAY_CHANNEL_DIALOG_TOP_PADDING
    local bottomPadding = RELAY_CHANNEL_DIALOG_BOTTOM_PADDING
    local cancelGap = 10
    local dialog = self.relayRequestChannelDialog

    for _, button in ipairs(self.relayRequestChannelDialogStaticButtons) do
        button:SetHidden(true)
        button:ClearAnchors()
    end

    local config = self.relayRequestChannelDialogConfig
    local _, _, currentConfigs = self:GetCurrentZoneData()
    local inOwnZone = false
    if type(currentConfigs) == "table" then
        for _, candidate in ipairs(currentConfigs) do
            if candidate == config then
                inOwnZone = true
                break
            end
        end
    end

    -- Own state suppresses local requests; guild requests may still help other members.
    local relayState = self:EnsureRelayState()
    local ownTimerActive = self.state.status == self.STATUS_COOLDOWN and relayState.timerSource == "self"
    local ownEncounterActive = self.state.status == self.STATUS_ACTIVE and not self.state.activeSource
    if inOwnZone and (ownTimerActive or ownEncounterActive) then
        inOwnZone = false
    end

    local function AcquireStaticButton(index)
        local button = self.relayRequestChannelDialogStaticButtons[index]
        if not button then
            button = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayRequestChannelDialogStatic" .. index, dialog, "ZO_DefaultButton")
            button:SetDimensions(dialogWidth - 28, buttonHeight)
            self.relayRequestChannelDialogStaticButtons[index] = button
        end
        button:SetHidden(false)
        return button
    end

    local anchorControl
    local bottomOffset = topPadding
    if inOwnZone then
        for index, option in ipairs(self.RELAY_CHANNEL_DIALOG_OPTIONS) do
            local button = AcquireStaticButton(index)
            button:SetText(self:T(option.labelKey))
            button:ClearAnchors()
            if anchorControl then
                button:SetAnchor(TOP, anchorControl, BOTTOM, 0, buttonGap)
                bottomOffset = bottomOffset + buttonGap
            else
                button:SetAnchor(TOP, dialog, TOP, 0, topPadding)
            end
            button:SetHandler("OnClicked", function()
                self:HideRelayRequestChannelChoiceDialog()
                self:SendRelayTimerRequest(config, option.channelType)
            end)
            anchorControl = button
            bottomOffset = bottomOffset + buttonHeight
        end
    end

    local guildChannels = self:GetActiveGuildChannels()
    if not self.relayRequestChannelDialogGuildHeader then
        local header = WM:CreateControl("DynamicEncounterTrackerRelayRequestChannelDialogGuildHeader", dialog, CT_LABEL)
        header:SetHeight(18)
        header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        header:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
        header:SetText(self:T("DE_RELAY_CHANNEL_DIALOG_GUILD_HEADER"))
        self.relayRequestChannelDialogGuildHeader = header
    end
    local header = self.relayRequestChannelDialogGuildHeader
    header:SetHidden(#guildChannels == 0)
    if #guildChannels > 0 then
        header:ClearAnchors()
        if anchorControl then
            header:SetAnchor(TOP, anchorControl, BOTTOM, 0, RELAY_CHANNEL_DIALOG_SECTION_GAP)
            bottomOffset = bottomOffset + RELAY_CHANNEL_DIALOG_SECTION_GAP
        else
            header:SetAnchor(TOP, dialog, TOP, 0, topPadding)
        end
        anchorControl = header
        bottomOffset = bottomOffset + 18
    end

    local function AcquireGuildButton(index)
        local button = self.relayRequestChannelDialogGuildButtons[index]
        if not button then
            button = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayRequestChannelDialogGuild" .. index, dialog, "ZO_DefaultButton")
            button:SetDimensions(dialogWidth - 28, buttonHeight)
            self.relayRequestChannelDialogGuildButtons[index] = button
        end
        button:SetHidden(false)
        return button
    end

    for _, button in ipairs(self.relayRequestChannelDialogGuildButtons) do
        button:SetHidden(true)
        button:ClearAnchors()
    end

    for index, guildChannel in ipairs(guildChannels) do
        local button = AcquireGuildButton(index)
        button:SetText(self:T("DE_RELAY_CHANNEL_GUILD_FMT", guildChannel.guildIndex, guildChannel.guildName))
        button:ClearAnchors()
        button:SetAnchor(TOP, anchorControl, BOTTOM, 0, buttonGap)
        button:SetHandler("OnClicked", function()
            self:HideRelayRequestChannelChoiceDialog()
            self:SendRelayTimerRequest(config, guildChannel.channelType)
        end)
        anchorControl = button
        bottomOffset = bottomOffset + buttonGap + buttonHeight
    end

    if not self.relayRequestChannelDialogCancelButton then
        local cancelButton = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayRequestChannelDialogCancel", dialog, "ZO_DefaultButton")
        cancelButton:SetDimensions(dialogWidth - 28, buttonHeight)
        cancelButton:SetText(GetString(SI_DIALOG_CANCEL))
        cancelButton:SetHandler("OnClicked", function()
            self:HideRelayRequestChannelChoiceDialog()
        end)
        self.relayRequestChannelDialogCancelButton = cancelButton
    end
    local cancelButton = self.relayRequestChannelDialogCancelButton
    cancelButton:ClearAnchors()
    cancelButton:SetAnchor(TOP, anchorControl, BOTTOM, 0, cancelGap)
    bottomOffset = bottomOffset + cancelGap + buttonHeight + bottomPadding

    dialog:SetDimensions(dialogWidth, bottomOffset)
end

function DE:ShowRelayRequestChannelChoiceDialog(config)
    if not self.relayRequestChannelDialog then
        return
    end
    self.relayRequestChannelDialogConfig = config
    self:RebuildRelayRequestChannelDialogButtons()
    self.relayRequestChannelDialogUnderlay:SetHidden(false)
    self.relayRequestChannelDialog:SetHidden(false)
end

function DE:HideRelayRequestChannelChoiceDialog()
    if not self.relayRequestChannelDialog then
        return
    end
    self.relayRequestChannelDialogUnderlay:SetHidden(true)
    self.relayRequestChannelDialog:SetHidden(true)
    self.relayRequestChannelDialogConfig = nil
end

-- Guild requests use a wildcard; say and zone require the current configured encounter.
function DE:ShowRelayRequestDialog()
    local _, _, currentConfigs = self:GetCurrentZoneData()
    local config = (type(currentConfigs) == "table" and currentConfigs[1]) or nil
    self:ShowRelayRequestChannelChoiceDialog(config)
end

-- Keybinds can invoke this while the button is hidden, so missing shareable state is a no-op.
function DE:ShowRelayShareDialog()
    local relayState = self:EnsureRelayState()
    local ownTimerActive = self.state.status == self.STATUS_COOLDOWN and relayState.timerSource == "self"
    local ownEncounterActive = self.state.status == self.STATUS_ACTIVE and not self.state.activeSource
    if ownEncounterActive then
        self:ShowRelayEncounterChannelChoiceDialog(self.state.eventData)
    elseif ownTimerActive then
        self:ShowRelayChannelChoiceDialog(self.state.eventData)
    end
end

function DE:ShowRelayChannelChoiceDialog(config)
    if not self.relayChannelDialog then
        return
    end
    self.relayChannelDialogConfig = config
    self:RebuildRelayChannelDialogGuildButtons()
    self.relayChannelDialogUnderlay:SetHidden(false)
    self.relayChannelDialog:SetHidden(false)
end

function DE:HideRelayChannelChoiceDialog()
    if not self.relayChannelDialog then
        return
    end
    self.relayChannelDialogUnderlay:SetHidden(true)
    self.relayChannelDialog:SetHidden(true)
    self.relayChannelDialogConfig = nil
end

-- Unlike the Say/Zone channel dialog above, the guild option list is not known
-- until runtime (guild membership can change between sessions), so this dialog's
-- button set is rebuilt on every Show instead of being built once at UI setup.
function DE:CreateRelayEncounterChannelDialog()
    local dialog = WM:CreateTopLevelWindow("DynamicEncounterTrackerRelayEncounterChannelDialog")
    self.relayEncounterChannelDialog = dialog
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetDrawLayer(DL_OVERLAY)
    dialog:SetDrawTier(DT_HIGH)
    dialog:SetDrawLevel(200)
    dialog:SetHidden(true)
    dialog:SetMouseEnabled(true)
    dialog:SetKeyboardEnabled(true)
    dialog:SetHandler("OnKeyUp", function(_, key)
        if key == KEY_ESCAPE then
            self:HideRelayEncounterChannelChoiceDialog()
        end
    end)

    local underlay = WM:CreateControl("DynamicEncounterTrackerRelayEncounterChannelDialogUnderlay", GuiRoot, CT_TEXTURE)
    self.relayEncounterChannelDialogUnderlay = underlay
    underlay:SetAnchorFill(GuiRoot)
    underlay:SetColor(0, 0, 0, 0.55)
    underlay:SetDrawLayer(DL_OVERLAY)
    underlay:SetDrawTier(DT_HIGH)
    underlay:SetDrawLevel(199)
    underlay:SetHidden(true)
    underlay:SetMouseEnabled(true)
    underlay:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideRelayEncounterChannelChoiceDialog()
        end
    end)

    local background = WM:CreateControl("DynamicEncounterTrackerRelayEncounterChannelDialogBg", dialog, CT_BACKDROP)
    background:SetAnchorFill(dialog)
    background:SetCenterColor(0.015, 0.018, 0.02, 0.95)
    background:SetEdgeTexture(nil, 1, 1, 0)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetInsets(0, 0, 0, 0)
    self.relayEncounterChannelDialogBg = background

    local title = WM:CreateControl("DynamicEncounterTrackerRelayEncounterChannelDialogTitle", dialog, CT_LABEL)
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 14, 12)
    title:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -14, 12)
    title:SetHeight(22)
    title:SetText(self:T("DE_RELAY_ENCOUNTER_CHANNEL_DIALOG_TITLE"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetFont("$(BOLD_FONT)|16|soft-shadow-thin")
    self.relayEncounterChannelDialogTitle = title

    local emptyLabel = WM:CreateControl("DynamicEncounterTrackerRelayEncounterChannelDialogEmpty", dialog, CT_LABEL)
    emptyLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 14, 44)
    emptyLabel:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -14, 44)
    emptyLabel:SetText(self:T("DE_RELAY_ENCOUNTER_NO_GUILD"))
    emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    emptyLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    emptyLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    self.relayEncounterChannelDialogEmptyLabel = emptyLabel

    self.relayEncounterChannelDialogButtons = {}
end

function DE:RebuildRelayEncounterChannelDialogButtons()
    local dialogWidth = 220
    local buttonHeight = 26
    local buttonGap = 6
    local topPadding = 44
    local bottomPadding = 14
    local cancelGap = 10

    for _, button in ipairs(self.relayEncounterChannelDialogButtons) do
        button:SetHidden(true)
        button:ClearAnchors()
    end

    local guildChannels = self:GetActiveGuildChannels()
    local optionCount = #guildChannels
    self.relayEncounterChannelDialogEmptyLabel:SetHidden(optionCount > 0)

    local optionsHeight = optionCount > 0 and ((optionCount * buttonHeight) + ((optionCount - 1) * buttonGap)) or 0
    local dialogHeight = topPadding + optionsHeight + (optionCount > 0 and cancelGap or 0) + buttonHeight + bottomPadding
    if optionCount == 0 then
        dialogHeight = dialogHeight + 22 -- room for the "no guild" hint label
    end
    self.relayEncounterChannelDialog:SetDimensions(dialogWidth, dialogHeight)

    local function AcquireButton(index)
        local button = self.relayEncounterChannelDialogButtons[index]
        if not button then
            button = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayEncounterChannelDialogOption" .. index, self.relayEncounterChannelDialog, "ZO_DefaultButton")
            button:SetDimensions(dialogWidth - 28, buttonHeight)
            self.relayEncounterChannelDialogButtons[index] = button
        end
        button:SetHidden(false)
        return button
    end

    local previousButton
    local topAnchorOffset = optionCount > 0 and topPadding or (topPadding + 22)
    for index, guildChannel in ipairs(guildChannels) do
        local button = AcquireButton(index)
        button:SetText(self:T("DE_RELAY_CHANNEL_GUILD_FMT", guildChannel.guildIndex, guildChannel.guildName))
        if previousButton then
            button:SetAnchor(TOP, previousButton, BOTTOM, 0, buttonGap)
        else
            button:SetAnchor(TOP, self.relayEncounterChannelDialog, TOP, 0, topAnchorOffset)
        end
        button:SetHandler("OnClicked", function()
            local config = self.relayEncounterChannelDialogConfig
            self:HideRelayEncounterChannelChoiceDialog()
            self:SendRelayEncounterMessage(config, guildChannel.channelType)
        end)
        previousButton = button
    end

    if not self.relayEncounterChannelDialogCancelButton then
        local cancelButton = WM:CreateControlFromVirtual("DynamicEncounterTrackerRelayEncounterChannelDialogCancel", self.relayEncounterChannelDialog, "ZO_DefaultButton")
        cancelButton:SetDimensions(dialogWidth - 28, buttonHeight)
        cancelButton:SetText(GetString(SI_DIALOG_CANCEL))
        cancelButton:SetHandler("OnClicked", function()
            self:HideRelayEncounterChannelChoiceDialog()
        end)
        self.relayEncounterChannelDialogCancelButton = cancelButton
    end

    local cancelButton = self.relayEncounterChannelDialogCancelButton
    cancelButton:ClearAnchors()
    if previousButton then
        cancelButton:SetAnchor(TOP, previousButton, BOTTOM, 0, cancelGap)
    else
        cancelButton:SetAnchor(TOP, self.relayEncounterChannelDialogEmptyLabel, BOTTOM, 0, cancelGap)
    end
end

function DE:ShowRelayEncounterChannelChoiceDialog(config)
    if not self.relayEncounterChannelDialog then
        return
    end
    self.relayEncounterChannelDialogConfig = config
    self:RebuildRelayEncounterChannelDialogButtons()
    self.relayEncounterChannelDialogUnderlay:SetHidden(false)
    self.relayEncounterChannelDialog:SetHidden(false)
end

function DE:HideRelayEncounterChannelChoiceDialog()
    if not self.relayEncounterChannelDialog then
        return
    end
    self.relayEncounterChannelDialogUnderlay:SetHidden(true)
    self.relayEncounterChannelDialog:SetHidden(true)
    self.relayEncounterChannelDialogConfig = nil
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

-- Shared by both the normal and minimal window layouts to compute how far the
-- title needs to shift right to avoid overlapping the relay/request buttons -
-- 0, 1, or both of which may be visible at once (see RefreshRelayButton).
function DE:GetRelayButtonsTitleLeftMargin(baseMargin)
    baseMargin = baseMargin or ROW_LABEL_LEFT
    local relayButtonVisible = self.relayButton and not self.relayButton:IsHidden()
    local relayRequestButtonVisible = self.relayRequestButton and not self.relayRequestButton:IsHidden()
    if relayButtonVisible and relayRequestButtonVisible then
        return 62
    elseif relayButtonVisible or relayRequestButtonVisible then
        return 34
    end
    return baseMargin
end

function DE:RefreshRelayButton()
    if not self.relayButton then
        return
    end

    local relayState = self:EnsureRelayState()
    local ownTimerActive = self.state.status == self.STATUS_COOLDOWN and relayState.timerSource == "self"
    local ownEncounterActive = self.state.status == self.STATUS_ACTIVE and not self.state.activeSource

    local shouldShow
    if ownTimerActive then
        shouldShow = self.sv.relayShowButton ~= false
    elseif ownEncounterActive then
        shouldShow = self.sv.relayGuildShowButton ~= false
    else
        shouldShow = false
    end
    self.relayButton:SetHidden(not shouldShow)

    if self.relayRequestButton then
        local requestShouldShow = self.sv.relayRequestShowButton ~= false
        self.relayRequestButton:SetHidden(not requestShouldShow)

        self.relayRequestButton:ClearAnchors()
        if shouldShow then
            self.relayRequestButton:SetAnchor(TOPLEFT, self.window, TOPLEFT, 38, 6)
        else
            self.relayRequestButton:SetAnchor(TOPLEFT, self.window, TOPLEFT, 10, 6)
        end
    end
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
    local titleLeftMargin = self:GetRelayButtonsTitleLeftMargin()
    local safetyMargin = 24 -- guards against GetTextWidth rounding/measurement slack
    -- The title needs separate padding for relay buttons; other rows use the normal margin.
    local titleRowWidth = math.ceil(titleTextWidth) + titleLeftMargin
    local otherRowWidth = math.ceil(zo_max(statusTextWidth, participationTextWidth)) + ROW_LABEL_LEFT
    local contentWidth = zo_max(titleRowWidth, otherRowWidth)
    local width = zo_clamp(contentWidth + safetyMargin + minimalRightMargin, 60, self.WINDOW_MAX_WIDTH)

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
    self.titleLabel:SetAnchor(TOPLEFT, self.window, TOPLEFT, titleLeftMargin, 7)
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
    self:RefreshRelayButton()

    local showFrame
    if self.sv.minimalMode then
        showFrame = self.sv.minimalShowFrame
    else
        showFrame = self.sv.showFrame
    end
    for _, line in pairs(self.frameLines) do
        line:SetHidden(not showFrame)
    end

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
    self.titleLabel:SetAnchor(TOPLEFT, self.window, TOPLEFT, self:GetRelayButtonsTitleLeftMargin(18), 7)
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
    self.window:SetDimensionConstraints(self.WINDOW_MIN_WIDTH, newHeight, self.WINDOW_MAX_WIDTH, newHeight)
    -- During resizing, only the live control width is current; saved width is stale.
    if not self.isResizingWindow then
        local width = zo_clamp(self.sv.size.width or self.WINDOW_DEFAULT_WIDTH, self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
        self.window:SetDimensions(width, newHeight)
    else
        self.window:SetHeight(newHeight)
    end
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
    self.closeButton:SetHidden(self.sv.showCloseButton == false)
    self.minimalToggle:SetHidden(self.sv.showMinimalToggleButton == false)
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
        line:SetCenterColor(frame[1], frame[2], frame[3], frame[4] or 1)
    end
    local resizeHandleColor = self.sv.colors.label
    for _, line in pairs(self.resizeHandleLines) do
        line:SetCenterColor(resizeHandleColor[1], resizeHandleColor[2], resizeHandleColor[3], (resizeHandleColor[4] or 1) * 0.55)
    end
    local alertFrame = self.sv.chestAlertColors.frame
    for _, line in pairs(self.centerAlertFrameLines) do
        line:SetCenterColor(alertFrame[1], alertFrame[2], alertFrame[3], alertFrame[4] or 1)
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

    -- unknownSince is stamped only on a genuine transition, so this count-up stays stable.
    if self.sv.showUnknownCountUp ~= false and self.state.unknownSince then
        local elapsed = zo_max(0, GetTimeStamp() - self.state.unknownSince)
        return self:T("DE_STATUS_UNKNOWN_COUNTUP_FMT", FormatCountdown(elapsed)), self.sv.colors.unknown
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

    if self.statusWindowPreviewActive then
        self:RefreshStatusWindowPreview()
        self:RefreshWindowLayout()
        self:RefreshVisibility()
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

-- Preview uses a configured zone but placeholder encounter text because names come from ESO at runtime.
function DE:RefreshStatusWindowPreview()
    local configs = self:GetAllEncounterConfigsForSettings()
    local zoneText = (configs[1] and configs[1].relayZoneNameEn) or "--"

    self.rows.zone.value:SetText(zoneText)
    self.rows.event.value:SetText(self:T("DE_STATUS_PREVIEW_EVENT"))
    self.rows.currentSection.value:SetText(self:T("DE_STATUS_PREVIEW_SECTION"))

    self.rows.status.value:SetText(self:T("DE_STATUS_PREVIEW_STATUS"))
    SetLabelColor(self.rows.status.value, self.sv.colors.active)

    self.rows.minimal.value:SetText(string.format("%s %s", self:T("DE_LABEL_STATUS"), self:T("DE_STATUS_PREVIEW_STATUS")))
    SetLabelColor(self.rows.minimal.value, self.sv.colors.active)

    self.rows.hint.value:SetText(self:T("DE_STATUS_PREVIEW_HINT"))
    SetLabelColor(self.rows.hint.value, self.sv.colors.value)

    self:ModuleHook("debug", "RefreshStatusRows", true)

    SetLabelColor(self.rows.zone.value, self.sv.colors.value)
    SetLabelColor(self.rows.event.value, self.sv.colors.value)
    SetLabelColor(self.rows.currentSection.value, self.sv.colors.value)
end

function DE:ShowStatusWindowPreview()
    if not self.window or not self.sv then
        return
    end

    self.statusWindowPreviewActive = true
    self:RefreshUI()
end

function DE:HideStatusWindowPreview()
    if not self.statusWindowPreviewActive then
        return
    end

    self.statusWindowPreviewActive = false
    self:RefreshUI()
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

    if self.statusWindowPreviewActive then
        self.window:SetHidden(not (self.sv.enabled and self.sv.showWindow))
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

function DE:ResetGuildRelayWindowAppearance()
    self.sv.relayWindowShowBorder = self.defaults.relayWindowShowBorder
    self.sv.relayWindowFontSize = self.defaults.relayWindowFontSize
    self.sv.relayWindowSortMode = self.defaults.relayWindowSortMode
    self.sv.relayWindowBlinkThresholdSeconds = self.defaults.relayWindowBlinkThresholdSeconds
    self.sv.relayWindowCheckIntervalSeconds = self.defaults.relayWindowCheckIntervalSeconds
    self.sv.relayWindowActiveShareMaxAgeSeconds = self.defaults.relayWindowActiveShareMaxAgeSeconds
    self.sv.relayWindowActiveEstimatedMaxAgeSeconds = self.defaults.relayWindowActiveEstimatedMaxAgeSeconds
    for colorName, defaultColor in pairs(self.defaults.relayWindowColors) do
        self.sv.relayWindowColors[colorName] = CopyColorValues(defaultColor)
    end
    if self.GuildRelayWindow then
        self.GuildRelayWindow:ApplyWindowVisual()
        self.GuildRelayWindow:Refresh()
    end
    -- Re-arms the liveness tick with the restored interval, same reasoning
    -- as the check-interval slider's own setFunc.
    self:StartGuildRelayLivenessTick()
end
