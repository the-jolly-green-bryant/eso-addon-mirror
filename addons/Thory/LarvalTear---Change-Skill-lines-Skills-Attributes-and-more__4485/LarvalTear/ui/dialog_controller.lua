local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_UI = Addon.UI
local LTM_UI_STRINGS = Addon.UI.Strings
local LTM_UI_DISPATCH = Addon.UI.Dispatch
local LTM_UI_DIALOGS = Addon.UI.Dialogs
local LTM_UI_QUICK_SETTINGS = Addon.UI.QuickSettings
local LTM_UI_DIALOG_LAYOUT = Addon.UI.LayoutConstants.Dialog

local UI_DIALOG_WIDTH = LTM_UI_DIALOG_LAYOUT.WIDTH
local UI_DIALOG_CONFIRM_HEIGHT = LTM_UI_DIALOG_LAYOUT.CONFIRM_HEIGHT
local UI_DIALOG_INPUT_HEIGHT = LTM_UI_DIALOG_LAYOUT.INPUT_HEIGHT
local UI_DIALOG_OVERWRITE_HEIGHT = LTM_UI_DIALOG_LAYOUT.OVERWRITE_HEIGHT
local UI_DIALOG_PAGE_REORDER_HEIGHT = LTM_UI_DIALOG_LAYOUT.PAGE_REORDER_HEIGHT
local UI_DIALOG_OUTER_PADDING = LTM_UI_DIALOG_LAYOUT.OUTER_PADDING
local UI_DIALOG_TITLE_HEIGHT = LTM_UI_DIALOG_LAYOUT.TITLE_HEIGHT
local UI_DIALOG_TITLE_BODY_GAP = LTM_UI_DIALOG_LAYOUT.TITLE_BODY_GAP
local UI_DIALOG_BODY_CONFIRM_HEIGHT = LTM_UI_DIALOG_LAYOUT.BODY_CONFIRM_HEIGHT
local UI_DIALOG_BODY_INPUT_HEIGHT = LTM_UI_DIALOG_LAYOUT.BODY_INPUT_HEIGHT
local UI_DIALOG_BODY_PAGE_REORDER_HEIGHT = LTM_UI_DIALOG_LAYOUT.BODY_PAGE_REORDER_HEIGHT
local UI_DIALOG_BODY_INPUT_GAP = LTM_UI_DIALOG_LAYOUT.BODY_INPUT_GAP
local UI_DIALOG_INPUT_LABEL_HEIGHT = LTM_UI_DIALOG_LAYOUT.INPUT_LABEL_HEIGHT
local UI_DIALOG_INPUT_EDIT_GAP = LTM_UI_DIALOG_LAYOUT.INPUT_EDIT_GAP
local UI_DIALOG_EDIT_HEIGHT = LTM_UI_DIALOG_LAYOUT.EDIT_HEIGHT
local UI_DIALOG_INPUT_NOTE_HEIGHT = LTM_UI_DIALOG_LAYOUT.INPUT_NOTE_HEIGHT
local UI_DIALOG_BUTTON_ROW_HEIGHT = LTM_UI_DIALOG_LAYOUT.BUTTON_ROW_HEIGHT
local UI_DIALOG_BUTTON_WIDTH = LTM_UI_DIALOG_LAYOUT.BUTTON_WIDTH
local UI_DIALOG_BUTTON_GAP = LTM_UI_DIALOG_LAYOUT.BUTTON_GAP
local UI_DIALOG_BUDGET_SHORT_WIDTH = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_WIDTH
local UI_DIALOG_BUDGET_SHORT_HEIGHT = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_HEIGHT
local UI_DIALOG_BUDGET_SHORT_BODY_HEIGHT = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_BODY_HEIGHT
local UI_DIALOG_BUDGET_SHORT_SUMMARY_ROW_MIN_HEIGHT = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_SUMMARY_ROW_MIN_HEIGHT
local UI_DIALOG_BUDGET_SHORT_SUMMARY_ROW_GAP = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_SUMMARY_ROW_GAP
local UI_DIALOG_BUDGET_SHORT_EXPECTED_MIN_HEIGHT = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_EXPECTED_MIN_HEIGHT
local UI_DIALOG_BUDGET_SHORT_EXPECTED_GAP = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_EXPECTED_GAP
local UI_DIALOG_BUDGET_SHORT_BUTTON_WIDTH = LTM_UI_DIALOG_LAYOUT.BUDGET_SHORT_BUTTON_WIDTH
local UI_DIALOG_SKILL_SNAPSHOT_WIDTH = LTM_UI_DIALOG_LAYOUT.SKILL_SNAPSHOT_WIDTH
local UI_DIALOG_SKILL_SNAPSHOT_HEIGHT = LTM_UI_DIALOG_LAYOUT.SKILL_SNAPSHOT_HEIGHT
local UI_DIALOG_SKILL_SNAPSHOT_BODY_HEIGHT = LTM_UI_DIALOG_LAYOUT.SKILL_SNAPSHOT_BODY_HEIGHT
local UI_DIALOG_TRANSFORM_SKILLS_WIDTH = LTM_UI_DIALOG_LAYOUT.TRANSFORM_SKILLS_WIDTH
local UI_DIALOG_TRANSFORM_SKILLS_HEIGHT = LTM_UI_DIALOG_LAYOUT.TRANSFORM_SKILLS_HEIGHT
local UI_DIALOG_TRANSFORM_SKILLS_BODY_HEIGHT = LTM_UI_DIALOG_LAYOUT.TRANSFORM_SKILLS_BODY_HEIGHT
local UI_DIALOG_OVERWRITE_OPTION_HEIGHT = LTM_UI_DIALOG_LAYOUT.OVERWRITE_OPTION_HEIGHT
local UI_DIALOG_OVERWRITE_OPTION_GAP = LTM_UI_DIALOG_LAYOUT.OVERWRITE_OPTION_GAP
local UI_DIALOG_OVERWRITE_PANEL_OFFSET_Y = LTM_UI_DIALOG_LAYOUT.OVERWRITE_PANEL_OFFSET_Y
local UI_DIALOG_PAGE_REORDER_PANEL_HEIGHT = LTM_UI_DIALOG_LAYOUT.PAGE_REORDER_PANEL_HEIGHT
local UI_DIALOG_PAGE_REORDER_ROW_HEIGHT = LTM_UI_DIALOG_LAYOUT.PAGE_REORDER_ROW_HEIGHT
local UI_DIALOG_PAGE_REORDER_ROW_GAP = LTM_UI_DIALOG_LAYOUT.PAGE_REORDER_ROW_GAP
local UI_DIALOG_PAGE_REORDER_BUTTON_WIDTH = LTM_UI_DIALOG_LAYOUT.PAGE_REORDER_BUTTON_WIDTH
local UI_RENAME_TEXT_MAX_UNITS = 18

local OVERWRITE_DIALOG_OPTIONS = {
    { id = "attributes", buttonTextKey = "dialog.overwrite_card.option.attributes", bodyTextKey = "dialog.overwrite_card.body.attributes" },
    { id = "class_skills", buttonTextKey = "dialog.overwrite_card.option.class_skills", bodyTextKey = "dialog.overwrite_card.body.class_skills" },
    { id = "equipment", buttonTextKey = "dialog.overwrite_card.option.equipment", bodyTextKey = "dialog.overwrite_card.body.equipment" },
    { id = "cp", buttonTextKey = "dialog.overwrite_card.option.cp", bodyTextKey = "dialog.overwrite_card.body.cp" },
    { id = "passives", buttonTextKey = "dialog.overwrite_card.option.passives", bodyTextKey = "dialog.overwrite_card.body.passives" },
    { id = "transform_werewolf", buttonTextKey = "dialog.overwrite_card.option.transform_werewolf", bodyTextKey = "dialog.overwrite_card.body.transform_werewolf" },
    { id = "transform_vampire", buttonTextKey = "dialog.overwrite_card.option.transform_vampire", bodyTextKey = "dialog.overwrite_card.body.transform_vampire" },
    { id = "all", buttonTextKey = "dialog.overwrite_card.option.all", bodyTextKey = "dialog.overwrite_card.body.all" },
}

function LTM_UI:GetOverwriteDialogOptions()
    return OVERWRITE_DIALOG_OPTIONS
end

local function GetText(key, params)
    if type(LTM_UI_STRINGS) == "table" and type(LTM_UI_STRINGS.GetText) == "function" then
        return LTM_UI_STRINGS:GetText(key, params)
    end

    return key
end

local function SetLabelText(control, text)
    if control ~= nil and type(control.SetText) == "function" then
        control:SetText(text or "")
    end
end

local function FindOverwriteDialogOption(overwriteType)
    for _, option in ipairs(OVERWRITE_DIALOG_OPTIONS) do
        if option.id == overwriteType then
            return option
        end
    end

    return nil
end

local function FindPageEntryById(pageEntries, pageId)
    if type(pageId) ~= "string" or pageId == "" then
        return nil
    end

    for _, entry in ipairs(pageEntries or {}) do
        if type(entry) == "table" and entry.pageId == pageId then
            return entry
        end
    end

    return nil
end

local function BuildReorderIdsFromEntries(reorderEntries)
    local ids = {}
    for _, entry in ipairs(reorderEntries or {}) do
        if type(entry) == "table" and type(entry.id) == "string" and entry.id ~= "" then
            ids[#ids + 1] = entry.id
        end
    end
    return ids
end

local function MoveArrayEntry(entries, fromIndex, toIndex)
    if type(entries) ~= "table"
        or type(fromIndex) ~= "number"
        or type(toIndex) ~= "number"
        or fromIndex < 1
        or toIndex < 1
        or fromIndex > #entries
        or toIndex > #entries
        or fromIndex == toIndex then
        return false
    end

    local entry = table.remove(entries, fromIndex)
    table.insert(entries, toIndex, entry)
    return true
end

local function GetWeightedTextUnits(text)
    if type(text) ~= "string" or text == "" then
        return 0
    end

    local units = 0
    local index = 1
    local length = #text
    while index <= length do
        local byte = string.byte(text, index)
        if byte == nil then
            break
        end

        if byte < 128 then
            units = units + 1
            index = index + 1
        elseif byte >= 240 then
            units = units + 2
            index = index + 4
        elseif byte >= 224 then
            units = units + 2
            index = index + 3
        elseif byte >= 192 then
            units = units + 2
            index = index + 2
        else
            units = units + 2
            index = index + 1
        end
    end

    return units
end

local function TruncateTextToWeightedUnits(text, maxUnits)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    maxUnits = tonumber(maxUnits) or 0
    if maxUnits <= 0 then
        return ""
    end

    local units = 0
    local index = 1
    local length = #text
    while index <= length do
        local byte = string.byte(text, index)
        if byte == nil then
            break
        end

        local charLength = 1
        local charUnits = 1
        if byte >= 240 then
            charLength = 4
            charUnits = 2
        elseif byte >= 224 then
            charLength = 3
            charUnits = 2
        elseif byte >= 192 then
            charLength = 2
            charUnits = 2
        elseif byte >= 128 then
            charLength = 1
            charUnits = 2
        end

        if units + charUnits > maxUnits then
            return string.sub(text, 1, index - 1)
        end

        units = units + charUnits
        index = index + charLength
    end

    return text
end

function LTM_UI:TruncateTextToWeightedUnits(text, maxUnits)
    return TruncateTextToWeightedUnits(text, maxUnits or UI_RENAME_TEXT_MAX_UNITS)
end

local function SetDialogControlDrawOrder(control, drawTier, drawLayer, drawLevel)
    if control == nil then
        return
    end

    if drawTier ~= nil and type(control.SetDrawTier) == "function" then
        control:SetDrawTier(drawTier)
    end

    if drawLayer ~= nil and type(control.SetDrawLayer) == "function" then
        control:SetDrawLayer(drawLayer)
    end

    if drawLevel ~= nil and type(control.SetDrawLevel) == "function" then
        control:SetDrawLevel(drawLevel)
    end
end

function LTM_UI:CreateDialogActionButton(parent, nameSuffix, onClick)
    local button = WINDOW_MANAGER:CreateControl(parent:GetName() .. nameSuffix, parent, CT_CONTROL)
    button:SetMouseEnabled(true)
    SetDialogControlDrawOrder(button, DT_HIGH, DL_OVERLAY, 24)

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", button, CT_BACKDROP)
    background:ClearAnchors()
    background:SetAnchorFill(button)
    background:SetCenterColor(0.0, 0.0, 0.0, 0.0)
    background:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
    if type(background.SetMouseEnabled) == "function" then
        background:SetMouseEnabled(false)
    end
    SetDialogControlDrawOrder(background, DT_HIGH, DL_OVERLAY, 24)
    button.background = background

    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", button, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(LEFT, button, LEFT, 12, 0)
    label:SetAnchor(RIGHT, button, RIGHT, -12, 0)
    label:SetFont("ZoFontGame")
    if type(label.SetHorizontalAlignment) == "function" then
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    if type(label.SetVerticalAlignment) == "function" then
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    SetDialogControlDrawOrder(label, DT_HIGH, DL_OVERLAY, 26)
    button.label = label

    local function ApplyVisual(_, state)
        if state == "danger" then
            background:SetCenterColor(0.0, 0.0, 0.0, 0.0)
            background:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
            label:SetColor(0.95, 0.76, 0.72, 1.0)
        elseif state == "danger_hover" then
            background:SetCenterColor(0.40, 0.16, 0.16, 1.0)
            background:SetEdgeColor(0.70, 0.32, 0.30, 1.0)
            label:SetColor(1.0, 0.82, 0.78, 1.0)
        elseif state == "pressed" then
            background:SetCenterColor(0.08, 0.24, 0.42, 0.96)
            background:SetEdgeColor(0.22, 0.46, 0.66, 1.0)
            label:SetColor(0.96, 0.98, 1.0, 1.0)
        elseif state == "hover" then
            background:SetCenterColor(0.14, 0.40, 0.70, 0.92)
            background:SetEdgeColor(0.30, 0.58, 0.82, 1.0)
            label:SetColor(1.0, 1.0, 1.0, 1.0)
        else
            background:SetCenterColor(0.0, 0.0, 0.0, 0.0)
            background:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
            label:SetColor(0.96, 0.97, 1.0, 1.0)
        end
    end

    button.ApplyVisualState = ApplyVisual
    button.isDanger = false

    button:SetHandler("OnMouseEnter", function(self)
        self:ApplyVisualState(self.isDanger and "danger_hover" or "hover")
    end)
    button:SetHandler("OnMouseExit", function(self)
        self:ApplyVisualState(self.isDanger and "danger" or "normal")
    end)
    button:SetHandler("OnMouseDown", function(self)
        if self.isDanger then
            self:ApplyVisualState("danger_hover")
        else
            self:ApplyVisualState("pressed")
        end
    end)
    button:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        self:ApplyVisualState(self.isDanger and "danger_hover" or "hover")
        if upInside == true
            and mouseButton == MOUSE_BUTTON_INDEX_LEFT
            and type(onClick) == "function" then
            onClick()
        end
    end)

    if type(label.SetMouseEnabled) == "function" then
        label:SetMouseEnabled(false)
    end

    button:ApplyVisualState("normal")
    return button
end

local function EstimateBudgetShortDialogLabelHeight(text, bodyWidth, minimumHeight)
    minimumHeight = tonumber(minimumHeight) or 0
    if type(text) ~= "string" or text == "" then
        return minimumHeight
    end

    local maxUnitsPerLine = math.max(1, math.floor(bodyWidth / 8))
    local lineCount = 1
    local lineUnits = 0
    local index = 1
    while index <= #text do
        local byte = string.byte(text, index)
        if byte == 10 then
            lineCount = lineCount + 1
            lineUnits = 0
            index = index + 1
        else
            local characterLength = 1
            local characterUnits = 1
            if byte ~= nil and byte >= 240 then
                characterLength = 4
                characterUnits = 2
            elseif byte ~= nil and byte >= 224 then
                characterLength = 3
                characterUnits = 2
            elseif byte ~= nil and byte >= 192 then
                characterLength = 2
                characterUnits = 2
            elseif byte ~= nil and byte >= 128 then
                characterUnits = 2
            end

            if lineUnits > 0 and lineUnits + characterUnits > maxUnitsPerLine then
                lineCount = lineCount + 1
                lineUnits = 0
            end
            lineUnits = lineUnits + characterUnits
            index = index + characterLength
        end
    end

    return math.max(minimumHeight, lineCount * 18)
end

local function GetBudgetShortDialogLabelHeight(control, text, panelWidth, minimumHeight)
    local bodyWidth = math.max(1, panelWidth - (UI_DIALOG_OUTER_PADDING * 2))
    local fallbackHeight = EstimateBudgetShortDialogLabelHeight(text, bodyWidth, minimumHeight)
    if control == nil or type(control.GetTextDimensions) ~= "function" then
        return fallbackHeight
    end

    if type(control.SetDimensions) == "function" then
        control:SetDimensions(bodyWidth, fallbackHeight)
    elseif type(control.SetWidth) == "function" then
        control:SetWidth(bodyWidth)
    end
    if type(control.SetText) == "function" then
        control:SetText(text or "")
    end

    local _, textHeight = control:GetTextDimensions()
    textHeight = tonumber(textHeight)
    if textHeight == nil or textHeight <= 0 then
        return fallbackHeight
    end

    return math.max(tonumber(minimumHeight) or 0, math.ceil(textHeight))
end

local function GetBudgetShortSummaryLayout(self, summaryTexts, panelWidth)
    local rowHeights = {}
    local summaryHeight = 0
    local summaryLabels = type(self) == "table" and self.dialogBudgetShortSummaryLabels or nil
    for index = 1, #(summaryLabels or {}) do
        local text = type(summaryTexts) == "table" and summaryTexts[index] or ""
        local rowHeight = GetBudgetShortDialogLabelHeight(
            summaryLabels[index],
            text,
            panelWidth,
            UI_DIALOG_BUDGET_SHORT_SUMMARY_ROW_MIN_HEIGHT
        )
        rowHeights[index] = rowHeight
        summaryHeight = summaryHeight + rowHeight
        if index < #summaryLabels then
            summaryHeight = summaryHeight + UI_DIALOG_BUDGET_SHORT_SUMMARY_ROW_GAP
        end
    end
    return summaryHeight, rowHeights
end

function LTM_UI:PositionDialogSections(bodyHeight, isPageReorder, isInput, bodyWidth, isBudgetShortConfirm, budgetSummaryRowHeights, budgetExpectedHeight)
    if self.dialogTitleRow then
        self.dialogTitleRow:ClearAnchors()
        self.dialogTitleRow:SetAnchor(TOPLEFT, self.dialogPanel, TOPLEFT, UI_DIALOG_OUTER_PADDING, UI_DIALOG_OUTER_PADDING)
        self.dialogTitleRow:SetAnchor(TOPRIGHT, self.dialogPanel, TOPRIGHT, -UI_DIALOG_OUTER_PADDING, UI_DIALOG_OUTER_PADDING)
        self.dialogTitleRow:SetHeight(UI_DIALOG_TITLE_HEIGHT)
    end

    bodyWidth = tonumber(bodyWidth) or 0
    if bodyWidth <= 0 and self.dialogPanel and type(self.dialogPanel.GetWidth) == "function" then
        bodyWidth = math.max(1, self.dialogPanel:GetWidth() - (UI_DIALOG_OUTER_PADDING * 2))
    end

    if self.dialogBodyLabel then
        self.dialogBodyLabel:ClearAnchors()
        self.dialogBodyLabel:SetAnchor(TOPLEFT, self.dialogTitleRow, BOTTOMLEFT, 0, UI_DIALOG_TITLE_BODY_GAP)
        self.dialogBodyLabel:SetDimensions(bodyWidth, bodyHeight)
    end

    local budgetSummaryAnchor = nil
    if isBudgetShortConfirm and type(self.dialogBudgetShortSummaryLabels) == "table" then
        budgetSummaryAnchor = self.dialogTitleRow
        for index, label in ipairs(self.dialogBudgetShortSummaryLabels) do
            local rowHeight = type(budgetSummaryRowHeights) == "table" and budgetSummaryRowHeights[index] or 0
            label:ClearAnchors()
            label:SetAnchor(
                TOPLEFT,
                budgetSummaryAnchor,
                BOTTOMLEFT,
                0,
                index == 1 and UI_DIALOG_TITLE_BODY_GAP or UI_DIALOG_BUDGET_SHORT_SUMMARY_ROW_GAP
            )
            label:SetDimensions(bodyWidth, rowHeight)
            budgetSummaryAnchor = label
        end
    end

    if self.dialogBudgetShortExpectedLabel then
        self.dialogBudgetShortExpectedLabel:ClearAnchors()
        if isBudgetShortConfirm then
            self.dialogBudgetShortExpectedLabel:SetAnchor(TOPLEFT, budgetSummaryAnchor or self.dialogBodyLabel, BOTTOMLEFT, 0, UI_DIALOG_BUDGET_SHORT_EXPECTED_GAP)
            self.dialogBudgetShortExpectedLabel:SetDimensions(bodyWidth, budgetExpectedHeight or 0)
        else
            self.dialogBudgetShortExpectedLabel:SetDimensions(bodyWidth, 0)
        end
    end

    if self.dialogInputLabel then
        self.dialogInputLabel:ClearAnchors()
        self.dialogInputLabel:SetAnchor(TOPLEFT, self.dialogBodyLabel, BOTTOMLEFT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogInputLabel:SetAnchor(TOPRIGHT, self.dialogBodyLabel, BOTTOMRIGHT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogInputLabel:SetHeight(UI_DIALOG_INPUT_LABEL_HEIGHT)
    end

    if self.dialogEditContainer then
        self.dialogEditContainer:ClearAnchors()
        self.dialogEditContainer:SetAnchor(TOPLEFT, self.dialogInputLabel, BOTTOMLEFT, 0, UI_DIALOG_INPUT_EDIT_GAP)
        self.dialogEditContainer:SetAnchor(TOPRIGHT, self.dialogInputLabel, BOTTOMRIGHT, 0, UI_DIALOG_INPUT_EDIT_GAP)
        self.dialogEditContainer:SetHeight(UI_DIALOG_EDIT_HEIGHT)
    end

    if self.dialogRenameHintLabel then
        self.dialogRenameHintLabel:ClearAnchors()
        self.dialogRenameHintLabel:SetAnchor(TOPLEFT, self.dialogEditContainer, BOTTOMLEFT, 0, 6)
        self.dialogRenameHintLabel:SetAnchor(TOPRIGHT, self.dialogEditContainer, BOTTOMRIGHT, 0, 6)
        self.dialogRenameHintLabel:SetHeight(UI_DIALOG_INPUT_NOTE_HEIGHT)
    end

    if self.dialogOverwriteButtonPanel then
        self.dialogOverwriteButtonPanel:ClearAnchors()
        self.dialogOverwriteButtonPanel:SetAnchor(TOPLEFT, self.dialogBodyLabel, BOTTOMLEFT, 0, UI_DIALOG_BODY_INPUT_GAP + UI_DIALOG_OVERWRITE_PANEL_OFFSET_Y)
        self.dialogOverwriteButtonPanel:SetAnchor(TOPRIGHT, self.dialogBodyLabel, BOTTOMRIGHT, 0, UI_DIALOG_BODY_INPUT_GAP + UI_DIALOG_OVERWRITE_PANEL_OFFSET_Y)
        local rowCount = #OVERWRITE_DIALOG_OPTIONS + 1
        self.dialogOverwriteButtonPanel:SetHeight(
            (UI_DIALOG_OVERWRITE_OPTION_HEIGHT * rowCount)
                + (UI_DIALOG_OVERWRITE_OPTION_GAP * math.max(rowCount - 1, 0))
        )
    end

    if self.dialogPageReorderPanel then
        self.dialogPageReorderPanel:ClearAnchors()
        self.dialogPageReorderPanel:SetAnchor(TOPLEFT, self.dialogBodyLabel, BOTTOMLEFT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogPageReorderPanel:SetAnchor(TOPRIGHT, self.dialogBodyLabel, BOTTOMRIGHT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogPageReorderPanel:SetHeight(UI_DIALOG_PAGE_REORDER_PANEL_HEIGHT)
    end

    if self.dialogButtonPanel then
        local buttonRowAnchorTarget = isBudgetShortConfirm and self.dialogBudgetShortExpectedLabel
            or (isPageReorder and self.dialogPageReorderPanel
                or (isInput and (self.dialogRenameHintLabel or self.dialogEditContainer) or self.dialogBodyLabel))
        self.dialogButtonPanel:ClearAnchors()
        self.dialogButtonPanel:SetAnchor(TOPLEFT, buttonRowAnchorTarget, BOTTOMLEFT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogButtonPanel:SetAnchor(TOPRIGHT, buttonRowAnchorTarget, BOTTOMRIGHT, 0, UI_DIALOG_BODY_INPUT_GAP)
        self.dialogButtonPanel:SetHeight(UI_DIALOG_BUTTON_ROW_HEIGHT)
    end
end

function LTM_UI:PositionDialogActionButtons(buttonWidth)
    if self.dialogConfirmButton then
        self.dialogConfirmButton:SetDimensions(buttonWidth, UI_DIALOG_BUTTON_ROW_HEIGHT)
        self.dialogConfirmButton:ClearAnchors()
        self.dialogConfirmButton:SetAnchor(RIGHT, self.dialogButtonPanel, RIGHT, 0, 0)
    end

    if self.dialogCancelButton then
        self.dialogCancelButton:SetDimensions(buttonWidth, UI_DIALOG_BUTTON_ROW_HEIGHT)
        self.dialogCancelButton:ClearAnchors()
        self.dialogCancelButton:SetAnchor(RIGHT, self.dialogConfirmButton, LEFT, -UI_DIALOG_BUTTON_GAP, 0)
    end
end

local function PositionPageReorderRow(rowControl, rowParent, yOffset)
    if rowControl == nil then
        return
    end

    rowControl:ClearAnchors()
    rowControl:SetAnchor(TOPLEFT, rowParent, TOPLEFT, 0, yOffset or 0)
    rowControl:SetAnchor(TOPRIGHT, rowParent, TOPRIGHT, 0, yOffset or 0)
    rowControl:SetHeight(UI_DIALOG_PAGE_REORDER_ROW_HEIGHT)
end

local function PositionPageReorderScrollChild(self, contentHeight)
    if self.dialogPageReorderScrollChild == nil or self.dialogPageReorderScrollContainer == nil then
        return
    end

    self.dialogPageReorderScrollChild:ClearAnchors()
    self.dialogPageReorderScrollChild:SetAnchor(TOPLEFT, self.dialogPageReorderScrollContainer, TOPLEFT, 0, 0)
    if self.dialogPageReorderScrollBar then
        self.dialogPageReorderScrollChild:SetAnchor(TOPRIGHT, self.dialogPageReorderScrollBar, TOPLEFT, -4, 0)
    else
        self.dialogPageReorderScrollChild:SetAnchor(TOPRIGHT, self.dialogPageReorderScrollContainer, TOPRIGHT, 0, 0)
    end
    self.dialogPageReorderScrollChild:SetHeight(math.max(contentHeight or 0, UI_DIALOG_PAGE_REORDER_PANEL_HEIGHT))
end

local function ApplyPageReorderRowDrawOrder(rowControl)
    if rowControl == nil then
        return
    end

    SetDialogControlDrawOrder(rowControl, DT_HIGH, DL_OVERLAY, 27)
    SetDialogControlDrawOrder(rowControl.background, DT_HIGH, DL_OVERLAY, 27)
    SetDialogControlDrawOrder(rowControl.nameLabel, DT_HIGH, DL_OVERLAY, 28)
    SetDialogControlDrawOrder(rowControl.currentLabel, DT_HIGH, DL_OVERLAY, 28)

    local buttons = { rowControl.upButton, rowControl.downButton }
    for _, button in ipairs(buttons) do
        SetDialogControlDrawOrder(button, DT_HIGH, DL_OVERLAY, 28)
        SetDialogControlDrawOrder(button and button.background, DT_HIGH, DL_OVERLAY, 28)
        SetDialogControlDrawOrder(button and button.label, DT_HIGH, DL_OVERLAY, 29)
    end
end

local function PositionPageReorderRowControls(rowControl, isPicker)
    if rowControl == nil then
        return
    end

    if rowControl.nameLabel then
        rowControl.nameLabel:ClearAnchors()
        rowControl.nameLabel:SetAnchor(LEFT, rowControl, LEFT, 12, 0)
        rowControl.nameLabel:SetAnchor(RIGHT, rowControl, RIGHT, isPicker and -96 or -152, 0)
    end

    if rowControl.currentLabel then
        rowControl.currentLabel:ClearAnchors()
        rowControl.currentLabel:SetAnchor(RIGHT, rowControl, RIGHT, isPicker and -12 or -148, 0)
        rowControl.currentLabel:SetDimensions(isPicker and 72 or 66, UI_DIALOG_PAGE_REORDER_ROW_HEIGHT)
    end

    if rowControl.upButton then
        rowControl.upButton:ClearAnchors()
        if isPicker then
            rowControl.upButton:SetAnchor(TOPLEFT, rowControl, TOPLEFT, -10000, -10000)
            rowControl.upButton:SetDimensions(1, 1)
        else
            rowControl.upButton:SetAnchor(RIGHT, rowControl, RIGHT, -74, 0)
            rowControl.upButton:SetDimensions(UI_DIALOG_PAGE_REORDER_BUTTON_WIDTH, 24)
        end
    end

    if rowControl.downButton then
        rowControl.downButton:ClearAnchors()
        if isPicker then
            rowControl.downButton:SetAnchor(TOPLEFT, rowControl, TOPLEFT, -10000, -10000)
            rowControl.downButton:SetDimensions(1, 1)
        else
            rowControl.downButton:SetAnchor(RIGHT, rowControl, RIGHT, -6, 0)
            rowControl.downButton:SetDimensions(UI_DIALOG_PAGE_REORDER_BUTTON_WIDTH, 24)
        end
    end
end

local RefreshPageReorderDialog
local SelectDialogEntry
local MovePageReorderEntry

local function CreatePageReorderRow(self, index)
    local parent = self.dialogPageReorderScrollChild or self.dialogPageReorderPanel
    local row = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Row" .. tostring(index), parent, CT_CONTROL)
    row:SetMouseEnabled(true)
    SetDialogControlDrawOrder(row, DT_HIGH, DL_OVERLAY, 27)

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", row, CT_BACKDROP)
    background:ClearAnchors()
    background:SetAnchorFill(row)
    background:SetCenterColor(0.08, 0.09, 0.11, 0.92)
    background:SetEdgeColor(0.24, 0.26, 0.30, 1.0)
    if type(background.SetMouseEnabled) == "function" then
        background:SetMouseEnabled(false)
    end
    SetDialogControlDrawOrder(background, DT_HIGH, DL_OVERLAY, 27)
    row.background = background

    row:SetHandler("OnMouseEnter", function(self)
        if self.isSelectable ~= true or not self.background or self.currentLabel and self.currentLabel:IsHidden() == false then
            return
        end
        self.background:SetCenterColor(0.11, 0.18, 0.25, 0.94)
        self.background:SetEdgeColor(0.34, 0.48, 0.62, 1.0)
    end)
    row:SetHandler("OnMouseExit", function(self)
        if self.isSelectable ~= true or not self.background or self.currentLabel and self.currentLabel:IsHidden() == false then
            return
        end
        self.background:SetCenterColor(0.08, 0.09, 0.11, 0.92)
        self.background:SetEdgeColor(0.24, 0.26, 0.30, 1.0)
    end)
    row:SetHandler("OnMouseUp", function(self, upInside)
        if upInside and self.isSelectable == true then
            SelectDialogEntry(LTM_UI, self.entryId)
        end
    end)

    local nameLabel = WINDOW_MANAGER:CreateControl("$(parent)Name", row, CT_LABEL)
    nameLabel:SetFont("ZoFontGame")
    nameLabel:SetColor(0.96, 0.97, 1.0, 1.0)
    if type(nameLabel.SetVerticalAlignment) == "function" then
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    SetDialogControlDrawOrder(nameLabel, DT_HIGH, DL_OVERLAY, 28)
    row.nameLabel = nameLabel

    local currentLabel = WINDOW_MANAGER:CreateControl("$(parent)Current", row, CT_LABEL)
    currentLabel:SetFont("ZoFontGameSmall")
    currentLabel:SetColor(0.84, 0.90, 0.98, 1.0)
    if type(currentLabel.SetHorizontalAlignment) == "function" then
        currentLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end
    if type(currentLabel.SetVerticalAlignment) == "function" then
        currentLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    currentLabel:SetHidden(true)
    SetDialogControlDrawOrder(currentLabel, DT_HIGH, DL_OVERLAY, 28)
    row.currentLabel = currentLabel

    local upButton = self:CreateDialogActionButton(row, "UpButton", function()
        MovePageReorderEntry(LTM_UI, row.entryId, "up")
    end)
    if upButton.label then
        upButton.label:SetFont("ZoFontGameSmall")
        SetLabelText(upButton.label, GetText("dialog.reorder_pages.move_up"))
    end
    row.upButton = upButton

    local downButton = self:CreateDialogActionButton(row, "DownButton", function()
        MovePageReorderEntry(LTM_UI, row.entryId, "down")
    end)
    if downButton.label then
        downButton.label:SetFont("ZoFontGameSmall")
        SetLabelText(downButton.label, GetText("dialog.reorder_pages.move_down"))
    end
    row.downButton = downButton
    PositionPageReorderRowControls(row, false)
    ApplyPageReorderRowDrawOrder(row)

    return row
end

function LTM_UI:RefreshOverwriteDialogBody(overwriteType)
    if self.currentDialogId ~= "OVERWRITE_CARD_PICKER" then
        return
    end

    local option = FindOverwriteDialogOption(overwriteType)
    local bodyTextKey = type(option) == "table" and option.bodyTextKey or "dialog.overwrite_card.body"
    local context = self.currentDialogContext or {}
    SetLabelText(self.dialogBodyLabel, GetText(bodyTextKey, {
        cardName = context.cardName or GetText("common.none"),
    }))
end

function LTM_UI:RefreshRenameInputHint()
    if self.dialogRenameHintLabel == nil then
        return
    end

    local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
    SetLabelText(self.dialogRenameHintLabel, GetText("dialog.rename.limit_hint", {
        count = GetWeightedTextUnits(inputValue),
        max = UI_RENAME_TEXT_MAX_UNITS,
    }))
end

local function RefreshPageReorderButtons(self, rowControl, index, totalCount)
    if type(rowControl) ~= "table" then
        return
    end

    local dialogContext = self.currentDialogContext or {}
    local isPicker = dialogContext.rowMode == "picker"
    local canMoveUp = type(index) == "number" and index > 1
    local canMoveDown = type(index) == "number" and type(totalCount) == "number" and index < totalCount

    if rowControl.upButton and type(rowControl.upButton.SetHidden) == "function" then
        rowControl.upButton:SetHidden(isPicker)
    end
    if rowControl.upButton and rowControl.upButton.label and type(rowControl.upButton.label.SetHidden) == "function" then
        rowControl.upButton.label:SetHidden(isPicker)
    end
    if rowControl.upButton and rowControl.upButton.label then
        SetLabelText(rowControl.upButton.label, isPicker and "" or GetText("dialog.reorder_pages.move_up"))
    end
    if rowControl.upButton and type(rowControl.upButton.SetEnabled) == "function" then
        rowControl.upButton:SetEnabled((not isPicker) and canMoveUp)
    end
    if rowControl.downButton and type(rowControl.downButton.SetHidden) == "function" then
        rowControl.downButton:SetHidden(isPicker)
    end
    if rowControl.downButton and rowControl.downButton.label and type(rowControl.downButton.label.SetHidden) == "function" then
        rowControl.downButton.label:SetHidden(isPicker)
    end
    if rowControl.downButton and rowControl.downButton.label then
        SetLabelText(rowControl.downButton.label, isPicker and "" or GetText("dialog.reorder_pages.move_down"))
    end
    if rowControl.downButton and type(rowControl.downButton.SetEnabled) == "function" then
        rowControl.downButton:SetEnabled((not isPicker) and canMoveDown)
    end
end

RefreshPageReorderDialog = function(self)
    if self.dialogPageReorderPanel == nil then
        return
    end

    local dialogContext = self.currentDialogContext or {}
    local reorderEntries = type(dialogContext.reorderEntries) == "table" and dialogContext.reorderEntries or {}
    local reorderCount = #reorderEntries
    local contentHeight = 0
    local currentTextKey = dialogContext.currentTextKey or "dialog.reorder_pages.current"
    local emptyTextKey = dialogContext.emptyTextKey or "dialog.reorder_pages.empty"
    local isPicker = dialogContext.rowMode == "picker"
    self.dialogPageReorderRows = self.dialogPageReorderRows or {}

    if self.dialogPageReorderEmptyLabel then
        self.dialogPageReorderEmptyLabel:SetHidden(reorderCount ~= 0)
        SetLabelText(self.dialogPageReorderEmptyLabel, GetText(emptyTextKey))
    end

    if self.dialogPageReorderScrollContainer then
        self.dialogPageReorderScrollContainer:SetHidden(reorderCount == 0)
    end
    PositionPageReorderScrollChild(self, UI_DIALOG_PAGE_REORDER_PANEL_HEIGHT)

    local rowParent = self.dialogPageReorderScrollChild or self.dialogPageReorderPanel

    for index, entry in ipairs(reorderEntries) do
        local rowControl = self.dialogPageReorderRows[index]
        if rowControl == nil then
            rowControl = CreatePageReorderRow(self, index)
            self.dialogPageReorderRows[index] = rowControl
        end

        rowControl.entryId = entry.id
        PositionPageReorderRow(rowControl, rowParent, contentHeight)
        ApplyPageReorderRowDrawOrder(rowControl)
        rowControl:SetHidden(false)
        rowControl.isSelectable = isPicker

        local isCurrent = entry.isCurrent == true
        if rowControl.background then
            if isCurrent then
                rowControl.background:SetCenterColor(0.14, 0.23, 0.32, 0.94)
                rowControl.background:SetEdgeColor(0.46, 0.62, 0.78, 1.0)
            else
                rowControl.background:SetCenterColor(0.08, 0.09, 0.11, 0.92)
                rowControl.background:SetEdgeColor(0.24, 0.26, 0.30, 1.0)
            end
        end
        if rowControl.nameLabel then
            rowControl.nameLabel:SetColor(0.96, 0.97, 1.0, 1.0)
            SetLabelText(rowControl.nameLabel, tostring(entry.name or entry.id))
        end
        if rowControl.currentLabel then
            rowControl.currentLabel:SetHidden(not isCurrent)
            SetLabelText(rowControl.currentLabel, GetText(currentTextKey))
        end

        PositionPageReorderRowControls(rowControl, isPicker)
        RefreshPageReorderButtons(self, rowControl, index, reorderCount)
        contentHeight = contentHeight + UI_DIALOG_PAGE_REORDER_ROW_HEIGHT + UI_DIALOG_PAGE_REORDER_ROW_GAP
    end

    for index = reorderCount + 1, #(self.dialogPageReorderRows or {}) do
        local rowControl = self.dialogPageReorderRows[index]
        if rowControl then
            rowControl:SetHidden(true)
        end
    end

    PositionPageReorderScrollChild(self, contentHeight)
    if self.dialogPageReorderScrollContainer and type(self.dialogPageReorderScrollContainer.UpdateScrollbars) == "function" then
        self.dialogPageReorderScrollContainer:UpdateScrollbars()
    end
    if self.dialogPageReorderScrollBar and type(self.dialogPageReorderScrollBar.SetHidden) == "function" then
        self.dialogPageReorderScrollBar:SetHidden(contentHeight <= UI_DIALOG_PAGE_REORDER_PANEL_HEIGHT)
    end

    if self.dialogConfirmButton and type(self.dialogConfirmButton.SetEnabled) == "function" then
        if isPicker then
            self.dialogConfirmButton:SetEnabled(reorderCount > 0 and type(dialogContext.selectedEntryId) == "string")
        else
            self.dialogConfirmButton:SetEnabled(reorderCount > 1)
        end
    end
end

SelectDialogEntry = function(self, entryId)
    local dialogContext = self.currentDialogContext or {}
    if dialogContext.rowMode ~= "picker" then
        return
    end

    local reorderEntries = type(dialogContext.reorderEntries) == "table" and dialogContext.reorderEntries or nil
    if type(reorderEntries) ~= "table" then
        return
    end

    dialogContext.selectedEntryId = nil
    for _, entry in ipairs(reorderEntries) do
        if type(entry) == "table" then
            entry.isCurrent = entry.id == entryId
            if entry.isCurrent then
                dialogContext.selectedEntryId = entry.id
            end
        end
    end

    RefreshPageReorderDialog(self)
end

MovePageReorderEntry = function(self, entryId, direction)
    local dialogContext = self.currentDialogContext or {}
    if dialogContext.rowMode == "picker" then
        SelectDialogEntry(self, entryId)
        return
    end

    local reorderEntries = type(dialogContext.reorderEntries) == "table" and dialogContext.reorderEntries or nil
    if type(reorderEntries) ~= "table" then
        return
    end

    local sourceIndex = nil
    for index, entry in ipairs(reorderEntries) do
        if type(entry) == "table" and entry.id == entryId then
            sourceIndex = index
            break
        end
    end

    if type(sourceIndex) ~= "number" then
        return
    end

    local targetIndex = direction == "up" and (sourceIndex - 1) or (sourceIndex + 1)
    if not MoveArrayEntry(reorderEntries, sourceIndex, targetIndex) then
        return
    end

    RefreshPageReorderDialog(self)
end

function LTM_UI:RunOverwrite(cardId, cardName, overwriteType)
    local build, err = LTM_UI_DISPATCH:OverwriteCard(cardId, overwriteType)
    if type(build) ~= "table" then
        self:LogActionError("common.overwrite", err)
        return
    end

    self:SelectCard(cardId)
    self:RefreshCardList()
    Log.WriteChat(GetText("status.overwritten." .. tostring(overwriteType or "all"), {
        cardName = build.displayName or build.name or cardName,
    }))
end

local RefreshDialogLayout

function LTM_UI:ShowDialog(dialogId, context)
    local definition = type(LTM_UI_DIALOGS) == "table" and type(LTM_UI_DIALOGS.Get) == "function"
        and LTM_UI_DIALOGS:Get(dialogId)
        or nil
    if type(definition) ~= "table" or not self.dialogOverlay then
        return
    end

    context = type(context) == "table" and context or {}
    self.currentDialogId = dialogId
    self.currentDialogContext = context
    self.openActionMenuCardId = nil
    self.openPageActionMenu = false
    self:RefreshSelectionState()

    local titleText = GetText(definition.titleTextKey)
    local bodyParams = {
        cardName = context.cardName or GetText("common.none"),
        pageName = context.pageName or GetText("common.none"),
        profileName = context.profileName or GetText("common.none"),
    }
    if type(context.params) == "table" then
        for key, value in pairs(context.params) do
            bodyParams[key] = value
        end
    end
    local bodyText = GetText(definition.bodyTextKey, bodyParams)
    local budgetSummaryTexts = {}
    if type(definition.budgetSummaryTextKeys) == "table" then
        for index, textKey in ipairs(definition.budgetSummaryTextKeys) do
            budgetSummaryTexts[index] = GetText(textKey, bodyParams)
        end
    end
    local budgetExpectedText = type(definition.budgetExpectedTextKey) == "string"
        and GetText(definition.budgetExpectedTextKey, bodyParams)
        or ""
    if definition.style == "snapshot_view" then
        bodyText = type(context.snapshotText) == "string" and context.snapshotText or bodyText
    end

    local isTransformSkills = definition.style == "transform_skills"
    local showBudgetShortSummary = type(definition.budgetSummaryTextKeys) == "table"
    if self.dialogBodyLabel then
        self.dialogBodyLabel:SetHidden(showBudgetShortSummary or isTransformSkills)
    end
    if type(self.dialogBudgetShortSummaryLabels) == "table" then
        for index, label in ipairs(self.dialogBudgetShortSummaryLabels) do
            label:SetHidden(not showBudgetShortSummary)
            SetLabelText(label, budgetSummaryTexts[index])
        end
    end
    if self.dialogBudgetShortExpectedLabel then
        self.dialogBudgetShortExpectedLabel:SetHidden(not showBudgetShortSummary)
        SetLabelText(self.dialogBudgetShortExpectedLabel, budgetExpectedText)
    end

    RefreshDialogLayout(self, definition, bodyText, budgetSummaryTexts, budgetExpectedText)

    SetLabelText(self.dialogTitleLabel, titleText)
    if self.dialogTitleLabel then
        self.dialogTitleLabel.ltmTooltipText = titleText
    end
    SetLabelText(self.dialogBodyLabel, bodyText)

    if self.dialogInputLabel then
        self.dialogInputLabel:SetHidden(definition.style ~= "input")
        SetLabelText(self.dialogInputLabel, GetText(definition.inputLabelTextKey or "dialog.rename_card.input"))
    end

    if self.dialogEditContainer then
        self.dialogEditContainer:SetHidden(definition.style ~= "input")
    end

    if self.dialogEditBox and self.dialogEditBox.SetText then
        self.dialogEditBox:SetText(TruncateTextToWeightedUnits(context.initialValue or "", UI_RENAME_TEXT_MAX_UNITS))
    end

    if self.dialogRenameHintLabel then
        local isRenameInput = dialogId == "RENAME_CARD_INPUT"
            or dialogId == "RENAME_PAGE_INPUT"
            or dialogId == "QUICKSLOT_RENAME_INPUT"
            or dialogId == "ALCHEMY_RECIPE_RENAME_INPUT"
            or dialogId == "ENCHANT_RECIPE_RENAME_INPUT"
        self.dialogRenameHintLabel:SetHidden(not isRenameInput)
        if isRenameInput then
            self:RefreshRenameInputHint()
        end
    end

    if self.dialogOverwriteButtonPanel then
        local showOverwriteButtons = definition.style == "overwrite_picker"
        self.dialogOverwriteButtonPanel:SetHidden(not showOverwriteButtons)
        if type(self.dialogOverwriteOptionButtons) == "table" then
            for _, optionButton in ipairs(self.dialogOverwriteOptionButtons) do
                optionButton:SetHidden(not showOverwriteButtons)
            end
        end
        if self.dialogOverwriteCancelButton then
            self.dialogOverwriteCancelButton:SetHidden(not showOverwriteButtons)
        end
    end

    if self.dialogCancelButton then
        local hasCancel = definition.cancelTextKey ~= nil
        self.dialogCancelButton:SetHidden(not hasCancel)
        if hasCancel then
            SetLabelText(self.dialogCancelButton.label, GetText(definition.cancelTextKey))
        end
    end

    if self.dialogConfirmButton then
        if type(self.dialogConfirmButton.SetEnabled) == "function" then
            self.dialogConfirmButton:SetEnabled(true)
        end
        SetLabelText(self.dialogConfirmButton.label, GetText(definition.confirmTextKey or "common.close"))
    end

    if self.dialogPageReorderPanel then
        local showPageReorder = definition.style == "page_reorder"
            or definition.style == "build_reorder"
            or definition.style == "page_picker"
        self.dialogPageReorderPanel:SetHidden(not showPageReorder)
        if self.dialogPageReorderEmptyLabel then
            self.dialogPageReorderEmptyLabel:SetHidden(not showPageReorder)
        end
        if self.dialogPageReorderScrollContainer then
            self.dialogPageReorderScrollContainer:SetHidden(not showPageReorder)
        end
        if showPageReorder then
            RefreshPageReorderDialog(self)
        end
    end

    if self.dialogTransformSkillsPanel then
        self.dialogTransformSkillsPanel:SetHidden(not isTransformSkills)
        if isTransformSkills and type(self.RefreshTransformSkillsDialog) == "function" then
            self:RefreshTransformSkillsDialog()
        end
    end

    if self.dialogButtonPanel then
        self.dialogButtonPanel:SetHidden(definition.style == "overwrite_picker")
    end
    if self.dialogCancelButton then
        self.dialogCancelButton:SetHidden(definition.style == "overwrite_picker" or definition.cancelTextKey == nil)
    end
    if self.dialogConfirmButton then
        self.dialogConfirmButton:SetHidden(definition.style == "overwrite_picker")
    end

    if definition.style == "overwrite_picker" then
        self:RefreshOverwriteDialogBody("all")
    end

    self.dialogOverlay:SetHidden(false)
end

function LTM_UI:HideDialog()
    self.currentDialogId = nil
    self.currentDialogContext = nil
    if self.dialogOverlay then
        self.dialogOverlay:SetHidden(true)
    end
    if self.dialogButtonPanel then
        self.dialogButtonPanel:SetHidden(true)
    end
    if self.dialogCancelButton then
        self.dialogCancelButton:SetHidden(true)
    end
    if self.dialogConfirmButton then
        self.dialogConfirmButton:SetHidden(true)
    end
    if self.dialogRenameHintLabel then
        self.dialogRenameHintLabel:SetHidden(true)
    end
    if self.dialogOverwriteButtonPanel then
        self.dialogOverwriteButtonPanel:SetHidden(true)
    end
    if type(self.dialogOverwriteOptionButtons) == "table" then
        for _, optionButton in ipairs(self.dialogOverwriteOptionButtons) do
            optionButton:SetHidden(true)
        end
    end
    if self.dialogOverwriteCancelButton then
        self.dialogOverwriteCancelButton:SetHidden(true)
    end
    if self.dialogPageReorderPanel then
        self.dialogPageReorderPanel:SetHidden(true)
    end
    if self.dialogPageReorderEmptyLabel then
        self.dialogPageReorderEmptyLabel:SetHidden(true)
    end
    if self.dialogPageReorderScrollContainer then
        self.dialogPageReorderScrollContainer:SetHidden(true)
    end
    if self.dialogTransformSkillsPanel then
        self.dialogTransformSkillsPanel:SetHidden(true)
    end
    if type(self.ClearTransformSkillsTooltip) == "function" then
        self:ClearTransformSkillsTooltip()
    end
end

function LTM_UI:CancelDialog()
    local dialogId = self.currentDialogId
    local context = self.currentDialogContext or {}
    self:HideDialog()

    if (dialogId == "APPLY_START_CONFIRM" or dialogId == "ROUTE_B_BUDGET_SHORT_CONFIRM" or dialogId == "SKILL_BUDGET_SHORT_CONFIRM")
        and type(context.onCancel) == "function" then
        context.onCancel()
    end
end

RefreshDialogLayout = function(self, definition, bodyText, budgetSummaryTexts, budgetExpectedText)
    if type(definition) ~= "table" or self.dialogPanel == nil then
        return
    end

    local isInput = definition.style == "input"
    local isOverwritePicker = definition.style == "overwrite_picker"
    local isTransformSkills = definition.style == "transform_skills"
    local isPageReorder = definition.style == "page_reorder"
        or definition.style == "build_reorder"
        or definition.style == "page_picker"
    local isBudgetShortConfirm = definition.dialogId == "ROUTE_B_BUDGET_SHORT_CONFIRM"
        or definition.dialogId == "SKILL_BUDGET_SHORT_CONFIRM"
    local panelHeight = isTransformSkills and UI_DIALOG_TRANSFORM_SKILLS_HEIGHT
        or (isOverwritePicker and UI_DIALOG_OVERWRITE_HEIGHT
            or (definition.style == "snapshot_view" and UI_DIALOG_SKILL_SNAPSHOT_HEIGHT
                or (isPageReorder and UI_DIALOG_PAGE_REORDER_HEIGHT
                    or (isInput and UI_DIALOG_INPUT_HEIGHT or UI_DIALOG_CONFIRM_HEIGHT))))
    local bodyHeight = isTransformSkills and UI_DIALOG_TRANSFORM_SKILLS_BODY_HEIGHT
        or (isOverwritePicker and 72
            or (definition.style == "snapshot_view" and UI_DIALOG_SKILL_SNAPSHOT_BODY_HEIGHT
                or (isPageReorder and UI_DIALOG_BODY_PAGE_REORDER_HEIGHT
                    or (isInput and UI_DIALOG_BODY_INPUT_HEIGHT or UI_DIALOG_BODY_CONFIRM_HEIGHT))))
    local budgetSummaryRowHeights = nil
    local budgetExpectedHeight = 0
    local panelWidth = isTransformSkills and UI_DIALOG_TRANSFORM_SKILLS_WIDTH
        or (isBudgetShortConfirm and UI_DIALOG_BUDGET_SHORT_WIDTH
            or (definition.style == "snapshot_view" and UI_DIALOG_SKILL_SNAPSHOT_WIDTH or UI_DIALOG_WIDTH))
    if isBudgetShortConfirm then
        bodyHeight, budgetSummaryRowHeights = GetBudgetShortSummaryLayout(self, budgetSummaryTexts, panelWidth)
        budgetExpectedHeight = GetBudgetShortDialogLabelHeight(
            self.dialogBudgetShortExpectedLabel,
            budgetExpectedText,
            panelWidth,
            UI_DIALOG_BUDGET_SHORT_EXPECTED_MIN_HEIGHT
        )
        panelHeight = bodyHeight
            + UI_DIALOG_BUDGET_SHORT_EXPECTED_GAP
            + budgetExpectedHeight
            + (UI_DIALOG_BUDGET_SHORT_HEIGHT - UI_DIALOG_BUDGET_SHORT_BODY_HEIGHT)
    end
    local buttonWidth = isBudgetShortConfirm and UI_DIALOG_BUDGET_SHORT_BUTTON_WIDTH or UI_DIALOG_BUTTON_WIDTH

    self.dialogPanel:SetDimensions(panelWidth, panelHeight)

    if self.dialogShade then
        self.dialogShade:SetCenterColor(0.0, 0.0, 0.0, isInput and 0.64 or 0.70)
    end

    self:PositionDialogSections(
        bodyHeight,
        isPageReorder,
        isInput,
        panelWidth - (UI_DIALOG_OUTER_PADDING * 2),
        isBudgetShortConfirm,
        budgetSummaryRowHeights,
        budgetExpectedHeight
    )
    if isTransformSkills and type(self.PositionTransformSkillsDialog) == "function" then
        self:PositionTransformSkillsDialog(panelWidth)
    end
    self:PositionDialogActionButtons(buttonWidth)

    if self.dialogConfirmButton then
        if definition.dialogId == "DELETE_CARD_CONFIRM" or definition.dialogId == "DELETE_PAGE_CONFIRM" then
            self.dialogConfirmButton.isDanger = true
            self.dialogConfirmButton:ApplyVisualState("danger")
        else
            self.dialogConfirmButton.isDanger = false
            self.dialogConfirmButton:ApplyVisualState("normal")
        end
    end

    if self.dialogCancelButton then
        self.dialogCancelButton.isDanger = false
        self.dialogCancelButton:ApplyVisualState("normal")
    end
end

function LTM_UI:ConfirmDialog()
    local dialogId = self.currentDialogId
    local context = self.currentDialogContext or {}
    if dialogId == nil then
        return
    end

    self:HideDialog()

    if dialogId == "TRANSFORM_SKILLS" then
        return
    end

    if dialogId == "APPLY_START_CONFIRM"
        or dialogId == "ROUTE_B_BUDGET_SHORT_CONFIRM"
        or dialogId == "SKILL_BUDGET_SHORT_CONFIRM"
        or dialogId == "QUICKSLOT_MISSING_CONFIRM" then
        if type(context.onConfirm) == "function" then
            context.onConfirm()
        end
        return
    end

    if dialogId == "DELETE_CARD_CONFIRM" then
        local result, err = LTM_UI_DISPATCH:DeleteCard(context.cardId)
        if type(result) ~= "table" then
            self:LogActionError("common.delete", err)
            return
        end

        self.selectedCardId = result.nextSelectedBuildId
        self.selectedBuildId = result.nextSelectedBuildId
        if self.expandedCardId == context.cardId then
            self.expandedCardId = nil
        end
        self.openActionMenuCardId = nil
        self:RefreshCardList()
        Log.WriteChat(GetText("status.deleted", { cardName = result.deletedBuildName or context.cardName }))
        return
    end

    if dialogId == "DELETE_PAGE_CONFIRM" then
        local result, err = LTM_UI_DISPATCH:DeletePage(context.pageId)
        if type(result) ~= "table" then
            self:LogActionError("common.delete", err)
            return
        end

        self.selectedBuildId = result.nextSelectedBuildId
        self.selectedCardId = result.nextSelectedBuildId
        self.expandedCardId = nil
        self.openActionMenuCardId = nil
        self.openPageActionMenu = false
        self.pendingCardListScroll = nil
        self:SetCardListScrollOffset(0)
        self:RefreshCardList()
        if self:GetRightPaneMode() == "target" then
            self:RefreshRightPanePanel()
        end
        Log.WriteChat(GetText("status.page_deleted", {
            pageName = result.deletedPageName or context.pageName,
        }))
        return
    end

    if dialogId == "REORDER_PAGES" then
        local result, err = LTM_UI_DISPATCH:SetPageOrder(BuildReorderIdsFromEntries(context.reorderEntries))
        if type(result) ~= "table" then
            self:LogActionError("page.action.reorder_pages", err)
            return
        end

        self.openPageActionMenu = false
        self:RefreshCardList()
        if self:GetRightPaneMode() == "target" then
            self:RefreshRightPanePanel()
        end
        Log.WriteChat(GetText("status.page_reordered"))
        return
    end

    if dialogId == "REORDER_BUILDS" then
        local result, err = LTM_UI_DISPATCH:SetBuildOrderForSelectedPage(BuildReorderIdsFromEntries(context.reorderEntries))
        if type(result) ~= "table" then
            self:LogActionError("page.action.sort", err)
            return
        end

        self.openPageActionMenu = false
        self.openActionMenuCardId = nil
        self:RefreshCardList()
        if self:GetRightPaneMode() == "target" then
            self:RefreshRightPanePanel()
        end
        Log.WriteChat(GetText("status.builds_reordered", {
            pageName = context.pageName or GetText("common.none"),
        }))
        return
    end

    if dialogId == "MOVE_BUILD_TO_PAGE" then
        local result, err = LTM_UI_DISPATCH:MoveCardToPage(context.cardId, context.selectedEntryId)
        if type(result) ~= "table" then
            self:LogActionError("card.action.move_page", err)
            return
        end

        self.selectedBuildId = result.targetSelectedBuildId
        self.selectedCardId = result.targetSelectedBuildId
        self.expandedCardId = result.targetSelectedBuildId
        self.openActionMenuCardId = nil
        self.openPageActionMenu = false
        self.pendingCardListScroll = nil
        self:SetCardListScrollOffset(0)
        self:QueueCardListScroll(result.targetSelectedBuildId, "center")
        self:RefreshCardList()
        if self:GetRightPaneMode() == "target" then
            self:RefreshRightPanePanel()
        end
        local targetPageEntry = FindPageEntryById(type(LTM_UI_DISPATCH) == "table" and LTM_UI_DISPATCH:GetPageEntries() or {}, result.targetPageId)
        Log.WriteChat(GetText("status.moved", {
            cardName = result.buildName or context.cardName or context.cardId,
            pageName = type(targetPageEntry) == "table" and (targetPageEntry.name or targetPageEntry.pageId) or result.targetPageId,
        }))
        return
    end

    if dialogId == "RENAME_CARD_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        local build, err = LTM_UI_DISPATCH:RenameCard(context.cardId, inputValue)
        if type(build) ~= "table" then
            self:LogActionError("common.rename", err)
            return
        end

        self:SelectCard(context.cardId)
        self:RefreshCardList()
        Log.WriteChat(GetText("status.renamed", { cardName = build.displayName or build.name or context.cardName }))
        return
    end

    if dialogId == "QUICKSLOT_RENAME_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        local profile, err = nil, "quickslot_ui_unavailable"
        if type(LTM_UI_QUICK_SETTINGS) == "table" and type(LTM_UI_QUICK_SETTINGS.RenameQuickSlotProfile) == "function" then
            profile, err = LTM_UI_QUICK_SETTINGS:RenameQuickSlotProfile(context.profileId, inputValue)
        end
        if type(profile) ~= "table" then
            self:LogActionError("common.rename", err)
            return
        end
        Log.WriteChat(GetText("status.renamed", { cardName = profile.displayName or profile.name or context.profileName }))
        return
    end

    if dialogId == "ALCHEMY_RECIPE_RENAME_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        if type(LTM_UI_QUICK_SETTINGS) ~= "table" or type(LTM_UI_QUICK_SETTINGS.RenameAlchemyRecipe) ~= "function" then
            self:LogActionError("common.rename", "alchemy_recipe_unavailable")
            return
        end

        local recipe = LTM_UI_QUICK_SETTINGS:RenameAlchemyRecipe(context.recipeId, inputValue)
        if type(recipe) ~= "table" then
            return
        end
        return
    end

    if dialogId == "ENCHANT_RECIPE_RENAME_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        if type(LTM_UI_QUICK_SETTINGS) ~= "table" or type(LTM_UI_QUICK_SETTINGS.RenameEnchantRecipe) ~= "function" then
            self:LogActionError("common.rename", "enchant_recipe_unavailable")
            return
        end

        local recipe = LTM_UI_QUICK_SETTINGS:RenameEnchantRecipe(context.recipeId, inputValue)
        if type(recipe) ~= "table" then
            return
        end
        return
    end

    if dialogId == "SCRIBING_RECIPE_RENAME_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        if type(LTM_UI_QUICK_SETTINGS) ~= "table" or type(LTM_UI_QUICK_SETTINGS.RenameScribingRecipe) ~= "function" then
            self:LogActionError("common.rename", "scribing_recipe_unavailable")
            return
        end

        local recipe = LTM_UI_QUICK_SETTINGS:RenameScribingRecipe(context.recipeId, inputValue)
        if type(recipe) ~= "table" then
            return
        end
        return
    end

    if dialogId == "RENAME_PAGE_INPUT" then
        local inputValue = self.dialogEditBox and self.dialogEditBox.GetText and self.dialogEditBox:GetText() or ""
        local page, err = LTM_UI_DISPATCH:RenamePage(context.pageId, inputValue)
        if type(page) ~= "table" then
            self:LogActionError("common.rename", err)
            return
        end

        self:RefreshCardList()
        Log.WriteChat(GetText("status.page_renamed", {
            pageName = page.name or context.pageName,
        }))
        return
    end
end
