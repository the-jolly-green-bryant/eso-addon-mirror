local Addon = LarvalTearMod
local LTM_UI = Addon.UI
local LTM_UI_STRINGS = Addon.UI.Strings
local LTM_UI_DISPATCH = Addon.UI.Dispatch

local KIND_ORDER = { "werewolf", "vampire" }
local SLOT_COUNT = 8
local SLOT_SIZE = 44
local SLOT_GAP = 5
local SECTION_GAP = 16
local SECTION_INSET = 14
local SECTION_HEIGHT = 250
local HEADER_HEIGHT = 46
local TITLE_HEIGHT = 22
local STATUS_TOP = 25
local STATUS_HEIGHT = 18
local HEADER_CONTENT_GAP = 10
local TAB_WIDTH = 86
local TAB_HEIGHT = 26
local TAB_GAP = 2
local TAB_GROUP_WIDTH = (TAB_WIDTH * 2) + TAB_GAP
local BAR_TOP_GAP = 10
local APPLY_ROW_TOP_GAP = 14
local APPLY_ROW_HEIGHT = 24
local CHECKBOX_SIZE = 18
local ACTION_ROW_TOP_GAP = 10
local ACTION_HEIGHT = 30
local ACTION_BUTTON_WIDTH = 190
local INTERACTIVE_DRAW_LEVEL = 28

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

local function SetDialogDrawOrder(control, drawLevel)
    if control == nil then
        return
    end
    if type(control.SetDrawTier) == "function" then
        control:SetDrawTier(DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" then
        control:SetDrawLayer(DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then
        control:SetDrawLevel(drawLevel or 25)
    end
end

local function SetMouseEnabled(control, enabled)
    if control ~= nil and type(control.SetMouseEnabled) == "function" then
        control:SetMouseEnabled(enabled == true)
    end
end

local function SetDialogActionButtonDrawOrder(button)
    if button == nil then
        return
    end
    SetDialogDrawOrder(button, INTERACTIVE_DRAW_LEVEL)
    SetDialogDrawOrder(button.background, INTERACTIVE_DRAW_LEVEL)
    SetDialogDrawOrder(button.label, INTERACTIVE_DRAW_LEVEL + 1)
end

local function CreateBackdrop(parent, nameSuffix)
    local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. nameSuffix, parent, CT_BACKDROP)
    control:SetCenterColor(0.07, 0.08, 0.10, 0.98)
    control:SetEdgeColor(0.30, 0.33, 0.38, 1.0)
    SetMouseEnabled(control, false)
    SetDialogDrawOrder(control, 25)
    return control
end

local function IndexEntries(entries)
    local byKind = {}
    for _, entry in ipairs(type(entries) == "table" and entries or {}) do
        if type(entry) == "table" and (entry.kind == "werewolf" or entry.kind == "vampire") then
            byKind[entry.kind] = entry
        end
    end
    return byKind
end

local function GetMorphBadge(skill)
    if type(skill) == "table" and skill.morphSlot == 1 then
        return "M1"
    end
    if type(skill) == "table" and skill.morphSlot == 2 then
        return "M2"
    end
    return "B"
end

local function GetRankText(skill)
    if type(skill) ~= "table" or skill.rank == nil then
        return "?"
    end
    return tostring(skill.rank)
end

local function ResolveBaseSkillName(skill)
    if type(skill) ~= "table"
        or (skill.morphSlot ~= 1 and skill.morphSlot ~= 2)
        or type(skill.progressionId) ~= "number"
        or type(GetProgressionSkillMorphSlotAbilityId) ~= "function"
        or type(GetAbilityName) ~= "function" then
        return nil
    end

    local baseMorphSlot = type(MORPH_SLOT_BASE) == "number" and MORPH_SLOT_BASE or 0
    local abilityOk, baseAbilityId = pcall(
        GetProgressionSkillMorphSlotAbilityId,
        skill.progressionId,
        baseMorphSlot
    )
    if not abilityOk or type(baseAbilityId) ~= "number" or baseAbilityId <= 0 then
        return nil
    end

    local nameOk, baseAbilityName = pcall(GetAbilityName, baseAbilityId)
    if not nameOk or type(baseAbilityName) ~= "string" or baseAbilityName == "" then
        return nil
    end
    return baseAbilityName
end

local function BuildSkillTooltipText(skill)
    local abilityName = type(skill) == "table" and skill.abilityName or nil
    if type(abilityName) ~= "string" or abilityName == "" then
        abilityName = tostring(type(skill) == "table" and skill.progressionId or "?")
    end
    local baseAbilityName = ResolveBaseSkillName(skill)
    if baseAbilityName == nil then
        return abilityName
    end
    return abilityName .. "\n" .. GetText("transform.skill.origin", { name = baseAbilityName })
end

local function ClearSkillTooltip()
    if type(ClearTooltip) == "function" and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end

local function ShowSkillTooltip(control, skill, slotIndex)
    if control == nil or type(skill) ~= "table"
        or not InformationTooltip
        or type(InitializeTooltip) ~= "function"
        or type(SetTooltipText) ~= "function" then
        return
    end
    if slotIndex <= (SLOT_COUNT / 2) then
        InitializeTooltip(InformationTooltip, control, LEFT, 8, 0, RIGHT)
    else
        InitializeTooltip(InformationTooltip, control, RIGHT, -8, 0, LEFT)
    end
    SetTooltipText(InformationTooltip, BuildSkillTooltipText(skill))
end

local function ConfigureSegmentedTabButton(button)
    if button == nil or button.background == nil or button.label == nil then
        return
    end
    button.ltmSelected = false
    button.ApplyVisualState = function(control, state)
        local selected = control.ltmSelected == true or state == "pressed"
        local hovered = state == "hover"
        if selected then
            control.background:SetCenterColor(
                hovered and 0.11 or 0.08,
                hovered and 0.32 or 0.24,
                hovered and 0.54 or 0.42,
                0.98
            )
            control.background:SetEdgeColor(0.34, 0.60, 0.82, 1.0)
            control.label:SetColor(1.0, 1.0, 1.0, 1.0)
        elseif hovered then
            control.background:SetCenterColor(0.13, 0.18, 0.24, 0.98)
            control.background:SetEdgeColor(0.42, 0.48, 0.56, 1.0)
            control.label:SetColor(0.96, 0.98, 1.0, 1.0)
        else
            control.background:SetCenterColor(0.07, 0.08, 0.10, 0.98)
            control.background:SetEdgeColor(0.30, 0.33, 0.38, 1.0)
            control.label:SetColor(0.72, 0.75, 0.80, 1.0)
        end
    end
    button:ApplyVisualState("normal")
end

local function SetActionButtonEnabled(button, enabled, danger)
    if button == nil then
        return
    end
    button.ltmEnabled = enabled == true
    button.isDanger = danger == true and enabled == true
    if type(button.SetMouseEnabled) == "function" then
        button:SetMouseEnabled(enabled == true)
    end
    if type(button.ApplyVisualState) == "function" then
        button:ApplyVisualState(button.isDanger and "danger" or "normal")
    end
    if button.label and not enabled then
        button.label:SetColor(0.42, 0.44, 0.48, 1.0)
    end
end

local function SetCheckButtonState(checkButton, checked, enabled)
    if checkButton == nil then
        return
    end
    checkButton.ltmRefreshing = true
    if type(ZO_CheckButton_SetCheckState) == "function" then
        ZO_CheckButton_SetCheckState(checkButton, checked == true)
    end
    if type(ZO_CheckButton_SetEnableState) == "function" then
        ZO_CheckButton_SetEnableState(checkButton, enabled == true)
    elseif type(checkButton.SetMouseEnabled) == "function" then
        checkButton:SetMouseEnabled(enabled == true)
    end
    checkButton.ltmRefreshing = false
end

local function RefreshExternalPanels()
    if type(LTM_UI.RefreshCardList) == "function" then
        LTM_UI:RefreshCardList()
    end
    if type(LTM_UI.RefreshRightPanePanel) == "function" then
        LTM_UI:RefreshRightPanePanel()
    end
end

local function RunMutation(actionKey, callback)
    local result, err = callback()
    if err ~= nil then
        if type(LTM_UI.LogActionError) == "function" then
            LTM_UI:LogActionError(actionKey, err)
        end
    else
        RefreshExternalPanels()
    end
    if type(LTM_UI.RefreshTransformSkillsDialog) == "function" then
        LTM_UI:RefreshTransformSkillsDialog()
    end
    if err ~= nil then
        return nil, err
    end
    return result, nil
end

local function CreateSkillSlot(parent, kind, index)
    local slot = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Slot" .. tostring(index), parent, CT_CONTROL)
    slot:SetDimensions(SLOT_SIZE, SLOT_SIZE)
    slot:SetMouseEnabled(true)
    SetDialogDrawOrder(slot, 27)

    local background = CreateBackdrop(slot, "Background")
    background:ClearAnchors()
    background:SetAnchorFill(slot)
    background:SetCenterColor(0.02, 0.02, 0.03, 1.0)
    background:SetEdgeColor(0.34, 0.36, 0.40, 1.0)
    SetMouseEnabled(background, false)
    SetDialogDrawOrder(background, 27)

    local icon = WINDOW_MANAGER:CreateControl(slot:GetName() .. "Icon", slot, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchorFill(slot)
    SetMouseEnabled(icon, false)
    SetDialogDrawOrder(icon, 28)

    local morph = WINDOW_MANAGER:CreateControl(slot:GetName() .. "Morph", slot, CT_LABEL)
    morph:ClearAnchors()
    morph:SetAnchor(TOPLEFT, slot, TOPLEFT, 2, 1)
    morph:SetDimensions(24, 14)
    morph:SetFont("ZoFontGameSmall")
    morph:SetColor(0.96, 0.90, 0.58, 1.0)
    SetMouseEnabled(morph, false)
    SetDialogDrawOrder(morph, 29)

    local rank = WINDOW_MANAGER:CreateControl(slot:GetName() .. "Rank", slot, CT_LABEL)
    rank:ClearAnchors()
    rank:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, -3, -1)
    rank:SetDimensions(20, 15)
    rank:SetFont("ZoFontGameSmall")
    rank:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    rank:SetColor(1.0, 1.0, 1.0, 1.0)
    SetMouseEnabled(rank, false)
    SetDialogDrawOrder(rank, 29)

    slot.icon = icon
    slot.morphLabel = morph
    slot.rankLabel = rank
    slot.ltmTransformKind = kind
    slot.ltmSlotIndex = index
    slot:SetHandler("OnMouseEnter", function(control)
        ShowSkillTooltip(control, control.ltmSkillEntry, control.ltmSlotIndex)
    end)
    slot:SetHandler("OnMouseExit", function()
        ClearSkillTooltip()
    end)
    return slot
end

local function CreateSection(self, parent, kind, index)
    local section = CreateBackdrop(parent, "Section" .. tostring(index))
    section:SetHeight(SECTION_HEIGHT)
    section.ltmTransformKind = kind

    local headerRow = WINDOW_MANAGER:CreateControl(section:GetName() .. "HeaderRow", section, CT_CONTROL)
    headerRow:ClearAnchors()
    headerRow:SetAnchor(TOPLEFT, section, TOPLEFT, SECTION_INSET, 10)
    headerRow:SetAnchor(TOPRIGHT, section, TOPRIGHT, -SECTION_INSET, 10)
    headerRow:SetHeight(HEADER_HEIGHT)
    SetMouseEnabled(headerRow, false)
    SetDialogDrawOrder(headerRow, 27)

    local tabGroup = WINDOW_MANAGER:CreateControl(section:GetName() .. "TabGroup", headerRow, CT_CONTROL)
    tabGroup:ClearAnchors()
    tabGroup:SetAnchor(TOPRIGHT, headerRow, TOPRIGHT, 0, 3)
    tabGroup:SetDimensions(TAB_GROUP_WIDTH, TAB_HEIGHT)
    SetMouseEnabled(tabGroup, false)
    SetDialogDrawOrder(tabGroup, 27)

    local title = WINDOW_MANAGER:CreateControl(section:GetName() .. "Title", headerRow, CT_LABEL)
    title:ClearAnchors()
    title:SetAnchor(TOPLEFT, headerRow, TOPLEFT, 0, 0)
    title:SetAnchor(TOPRIGHT, headerRow, TOPRIGHT, -(TAB_GROUP_WIDTH + HEADER_CONTENT_GAP), 0)
    title:SetHeight(TITLE_HEIGHT)
    title:SetFont("ZoFontWinH4")
    title:SetText(GetText(kind == "werewolf" and "transform.kind.werewolf" or "transform.kind.vampire"))
    title:SetColor(1.0, 1.0, 1.0, 1.0)
    SetMouseEnabled(title, false)
    if type(title.SetVerticalAlignment) == "function" then
        title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    SetDialogDrawOrder(title, 27)

    local status = WINDOW_MANAGER:CreateControl(section:GetName() .. "Status", headerRow, CT_LABEL)
    status:ClearAnchors()
    status:SetAnchor(TOPLEFT, headerRow, TOPLEFT, 0, STATUS_TOP)
    status:SetAnchor(
        TOPRIGHT,
        headerRow,
        TOPRIGHT,
        -(TAB_GROUP_WIDTH + HEADER_CONTENT_GAP),
        STATUS_TOP
    )
    status:SetHeight(STATUS_HEIGHT)
    status:SetFont("ZoFontGameSmall")
    SetMouseEnabled(status, false)
    if type(status.SetVerticalAlignment) == "function" then
        status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    SetDialogDrawOrder(status, 27)

    local targetButton = self:CreateDialogActionButton(tabGroup, "TargetButton", function()
        LTM_UI:SetTransformSkillsViewMode(kind, "target")
    end)
    targetButton:SetDimensions(TAB_WIDTH, TAB_HEIGHT)
    targetButton:ClearAnchors()
    targetButton:SetAnchor(TOPLEFT, tabGroup, TOPLEFT, 0, 0)
    SetLabelText(targetButton.label, GetText("transform.popup.target"))
    SetDialogActionButtonDrawOrder(targetButton)
    ConfigureSegmentedTabButton(targetButton)

    local currentButton = self:CreateDialogActionButton(tabGroup, "CurrentButton", function()
        LTM_UI:SetTransformSkillsViewMode(kind, "current")
    end)
    currentButton:SetDimensions(TAB_WIDTH, TAB_HEIGHT)
    currentButton:ClearAnchors()
    currentButton:SetAnchor(LEFT, targetButton, RIGHT, TAB_GAP, 0)
    SetLabelText(currentButton.label, GetText("transform.popup.current"))
    SetDialogActionButtonDrawOrder(currentButton)
    ConfigureSegmentedTabButton(currentButton)

    local bar = WINDOW_MANAGER:CreateControl(section:GetName() .. "Bar", section, CT_CONTROL)
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, headerRow, BOTTOMLEFT, 0, BAR_TOP_GAP)
    bar:SetAnchor(TOPRIGHT, headerRow, BOTTOMRIGHT, 0, BAR_TOP_GAP)
    bar:SetHeight(SLOT_SIZE)
    SetMouseEnabled(bar, false)
    SetDialogDrawOrder(bar, 27)

    local slots = {}
    for slotIndex = 1, SLOT_COUNT do
        local slot = CreateSkillSlot(bar, kind, slotIndex)
        slot:ClearAnchors()
        slot:SetAnchor(LEFT, bar, LEFT, (slotIndex - 1) * (SLOT_SIZE + SLOT_GAP), 0)
        slots[slotIndex] = slot
    end

    local empty = WINDOW_MANAGER:CreateControl(section:GetName() .. "Empty", bar, CT_LABEL)
    empty:ClearAnchors()
    empty:SetAnchorFill(bar)
    empty:SetFont("ZoFontGame")
    empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    empty:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    empty:SetColor(0.60, 0.62, 0.66, 1.0)
    empty:SetHidden(true)
    SetMouseEnabled(empty, false)
    SetDialogDrawOrder(empty, 29)

    local applyRow = WINDOW_MANAGER:CreateControl(section:GetName() .. "ApplyRow", section, CT_CONTROL)
    applyRow:ClearAnchors()
    applyRow:SetAnchor(TOPLEFT, bar, BOTTOMLEFT, 0, APPLY_ROW_TOP_GAP)
    applyRow:SetAnchor(TOPRIGHT, bar, BOTTOMRIGHT, 0, APPLY_ROW_TOP_GAP)
    applyRow:SetHeight(APPLY_ROW_HEIGHT)
    SetMouseEnabled(applyRow, false)
    SetDialogDrawOrder(applyRow, 27)

    local applyCheckbox = WINDOW_MANAGER:CreateControlFromVirtual(
        section:GetName() .. "ApplyCheckbox",
        applyRow,
        "ZO_CheckButton"
    )
    applyCheckbox:ClearAnchors()
    applyCheckbox:SetAnchor(LEFT, applyRow, LEFT, 0, 0)
    applyCheckbox:SetDimensions(CHECKBOX_SIZE, CHECKBOX_SIZE)
    if type(ZO_CheckButton_SetLabelText) == "function" then
        ZO_CheckButton_SetLabelText(applyCheckbox, GetText("transform.apply"))
    end
    if type(ZO_CheckButton_SetToggleFunction) == "function" then
        ZO_CheckButton_SetToggleFunction(applyCheckbox, function(checkButton, isChecked)
            if checkButton.ltmRefreshing then
                return
            end
            LTM_UI:RunTransformSkillsApply(kind, isChecked == true)
        end)
    end
    SetDialogDrawOrder(applyCheckbox, INTERACTIVE_DRAW_LEVEL)
    SetDialogDrawOrder(applyCheckbox.label, INTERACTIVE_DRAW_LEVEL + 1)

    local actionRow = WINDOW_MANAGER:CreateControl(section:GetName() .. "ActionRow", section, CT_CONTROL)
    actionRow:ClearAnchors()
    actionRow:SetAnchor(TOPLEFT, applyRow, BOTTOMLEFT, 0, ACTION_ROW_TOP_GAP)
    actionRow:SetAnchor(TOPRIGHT, applyRow, BOTTOMRIGHT, 0, ACTION_ROW_TOP_GAP)
    actionRow:SetHeight(ACTION_HEIGHT)
    SetMouseEnabled(actionRow, false)
    SetDialogDrawOrder(actionRow, 27)

    local overwriteButton = self:CreateDialogActionButton(actionRow, "OverwriteButton", function()
        LTM_UI:RunTransformSkillsOverwrite(kind)
    end)
    overwriteButton:ClearAnchors()
    overwriteButton:SetAnchor(TOPLEFT, actionRow, TOPLEFT, 0, 0)
    overwriteButton:SetDimensions(ACTION_BUTTON_WIDTH, ACTION_HEIGHT)
    SetLabelText(overwriteButton.label, GetText("transform.action.overwrite"))
    SetDialogActionButtonDrawOrder(overwriteButton)

    local deleteButton = self:CreateDialogActionButton(actionRow, "DeleteButton", function()
        LTM_UI:RunTransformSkillsDelete(kind)
    end)
    deleteButton:ClearAnchors()
    deleteButton:SetAnchor(TOPRIGHT, actionRow, TOPRIGHT, 0, 0)
    deleteButton:SetDimensions(ACTION_BUTTON_WIDTH, ACTION_HEIGHT)
    SetLabelText(deleteButton.label, GetText("transform.action.delete"))
    SetDialogActionButtonDrawOrder(deleteButton)

    return {
        root = section,
        headerRow = headerRow,
        tabGroup = tabGroup,
        statusLabel = status,
        targetButton = targetButton,
        currentButton = currentButton,
        slots = slots,
        emptyLabel = empty,
        applyRow = applyRow,
        applyCheckbox = applyCheckbox,
        actionRow = actionRow,
        overwriteButton = overwriteButton,
        deleteButton = deleteButton,
    }
end

function LTM_UI:CreateTransformSkillsDialogControls(parent)
    if parent == nil or self.dialogTransformSkillsPanel ~= nil then
        return
    end
    local panel = WINDOW_MANAGER:CreateControl(parent:GetName() .. "TransformSkillsPanel", parent, CT_CONTROL)
    panel:SetHidden(true)
    SetMouseEnabled(panel, false)
    SetDialogDrawOrder(panel, 23)
    self.dialogTransformSkillsPanel = panel
    self.dialogTransformSkillsSections = {}

    local previous = nil
    for index, kind in ipairs(KIND_ORDER) do
        local section = CreateSection(self, panel, kind, index)
        section.root:ClearAnchors()
        if previous == nil then
            section.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
        else
            section.root:SetAnchor(TOPLEFT, previous.root, TOPRIGHT, SECTION_GAP, 0)
        end
        self.dialogTransformSkillsSections[kind] = section
        previous = section
    end
end

function LTM_UI:PositionTransformSkillsDialog(panelWidth)
    if self.dialogTransformSkillsPanel == nil or self.dialogPanel == nil then
        return
    end
    local outerPadding = 20
    local titleGap = 14
    local buttonGap = 14
    local buttonHeight = 32
    local availableWidth = self.dialogOverlay and type(self.dialogOverlay.GetWidth) == "function"
        and tonumber(self.dialogOverlay:GetWidth())
        or nil
    local useStackedLayout = availableWidth ~= nil
        and availableWidth > 0
        and availableWidth < panelWidth + (outerPadding * 2)
    local actualPanelWidth = useStackedLayout
        and math.max(456, math.min(panelWidth, availableWidth - (outerPadding * 2)))
        or panelWidth
    local contentWidth = actualPanelWidth - (outerPadding * 2)
    local contentHeight = useStackedLayout
        and ((SECTION_HEIGHT * 2) + 10)
        or SECTION_HEIGHT
    local actualPanelHeight = contentHeight + 136
    local sectionWidth = useStackedLayout
        and contentWidth
        or math.floor((contentWidth - SECTION_GAP) / 2)

    self.dialogPanel:SetDimensions(actualPanelWidth, actualPanelHeight)

    self.dialogTransformSkillsPanel:ClearAnchors()
    self.dialogTransformSkillsPanel:SetAnchor(TOPLEFT, self.dialogTitleRow, BOTTOMLEFT, 0, titleGap)
    self.dialogTransformSkillsPanel:SetDimensions(contentWidth, contentHeight)
    local previousSection = nil
    for _, kind in ipairs(KIND_ORDER) do
        local section = self.dialogTransformSkillsSections
            and self.dialogTransformSkillsSections[kind]
            or nil
        if section and section.root then
            section.root:SetWidth(sectionWidth)
            if section.applyCheckbox and type(ZO_CheckButton_SetLabelWidth) == "function" then
                ZO_CheckButton_SetLabelWidth(
                    section.applyCheckbox,
                    sectionWidth - (SECTION_INSET * 2) - CHECKBOX_SIZE - 5
                )
            end
            section.root:ClearAnchors()
            if previousSection == nil then
                section.root:SetAnchor(TOPLEFT, self.dialogTransformSkillsPanel, TOPLEFT, 0, 0)
            elseif useStackedLayout then
                section.root:SetAnchor(TOPLEFT, previousSection.root, BOTTOMLEFT, 0, 10)
            else
                section.root:SetAnchor(TOPLEFT, previousSection.root, TOPRIGHT, SECTION_GAP, 0)
            end
            previousSection = section
        end
    end

    if self.dialogButtonPanel then
        self.dialogButtonPanel:ClearAnchors()
        self.dialogButtonPanel:SetAnchor(TOPLEFT, self.dialogTransformSkillsPanel, BOTTOMLEFT, 0, buttonGap)
        self.dialogButtonPanel:SetAnchor(TOPRIGHT, self.dialogTransformSkillsPanel, BOTTOMRIGHT, 0, buttonGap)
        self.dialogButtonPanel:SetHeight(buttonHeight)
    end
end

function LTM_UI:ShowTransformSkillsPopup(kind, cardId)
    local resolvedCardId = type(cardId) == "string" and cardId ~= "" and cardId
        or self.selectedCardId
        or self.selectedBuildId
    self:ShowDialog("TRANSFORM_SKILLS", {
        cardId = resolvedCardId,
        focusKind = kind == "vampire" and "vampire" or "werewolf",
        viewModeByKind = {
            werewolf = "target",
            vampire = "target",
        },
    })
end

function LTM_UI:SetTransformSkillsViewMode(kind, mode)
    local context = self.currentDialogContext
    if self.currentDialogId ~= "TRANSFORM_SKILLS"
        or type(context) ~= "table"
        or (kind ~= "werewolf" and kind ~= "vampire")
        or (mode ~= "target" and mode ~= "current") then
        return
    end
    context.viewModeByKind = type(context.viewModeByKind) == "table" and context.viewModeByKind or {}
    context.viewModeByKind[kind] = mode
    self:RefreshTransformSkillsDialog()
end

function LTM_UI:RunTransformSkillsApply(kind, enabled)
    local context = self.currentDialogContext or {}
    local cardId = context.cardId
    if self.currentDialogId ~= "TRANSFORM_SKILLS" or type(cardId) ~= "string" or cardId == "" then
        return nil, "build_id_missing"
    end
    return RunMutation("common.save", function()
        return LTM_UI_DISPATCH:SetCardTransformApply(cardId, kind, enabled == true)
    end)
end

function LTM_UI:RunTransformSkillsOverwrite(kind)
    local context = self.currentDialogContext or {}
    local cardId = context.cardId
    if self.currentDialogId ~= "TRANSFORM_SKILLS" or type(cardId) ~= "string" or cardId == "" then
        return nil, "build_id_missing"
    end
    return RunMutation("common.overwrite", function()
        return LTM_UI_DISPATCH:OverwriteCardTransform(cardId, kind)
    end)
end

function LTM_UI:RunTransformSkillsDelete(kind)
    local context = self.currentDialogContext or {}
    local cardId = context.cardId
    if self.currentDialogId ~= "TRANSFORM_SKILLS" or type(cardId) ~= "string" or cardId == "" then
        return nil, "build_id_missing"
    end
    return RunMutation("common.delete", function()
        return LTM_UI_DISPATCH:DeleteCardTransform(cardId, kind)
    end)
end

local function RefreshSkillSlots(section, entry)
    local skills = type(entry) == "table" and entry.skills or nil
    local hasSkills = type(skills) == "table" and #skills > 0
    section.emptyLabel:SetHidden(hasSkills)
    for index, slot in ipairs(section.slots or {}) do
        local skill = hasSkills and skills[index] or nil
        slot.ltmSkillEntry = skill
        slot:SetHidden(type(skill) ~= "table")
        if type(skill) == "table" then
            slot.icon:SetTexture(skill.iconTexture or "")
            if type(slot.icon.SetDesaturation) == "function" then
                slot.icon:SetDesaturation(skill.purchased == true and 0 or 1)
            end
            local brightness = skill.purchased == true and 1.0 or 0.30
            slot.icon:SetColor(brightness, brightness, brightness, 1.0)
            SetLabelText(slot.morphLabel, GetMorphBadge(skill))
            SetLabelText(slot.rankLabel, GetRankText(skill))
            slot.rankLabel:SetColor(
                skill.rank == nil and 0.92 or 1.0,
                skill.rank == nil and 0.72 or 1.0,
                skill.rank == nil and 0.34 or 1.0,
                1.0
            )
        end
    end
end

local function RefreshSection(section, kind, context, targetEntry, currentEntry)
    local mode = type(context.viewModeByKind) == "table" and context.viewModeByKind[kind] or "target"
    local displayedEntry = mode == "current" and currentEntry or targetEntry
    local hasTarget = type(targetEntry) == "table"
    local hasCurrent = type(currentEntry) == "table"
    local hasCard = type(context.cardId) == "string" and context.cardId ~= ""

    SetLabelText(
        section.statusLabel,
        hasTarget and GetText("transform.snapshot.saved") or GetText("transform.snapshot.missing")
    )
    section.statusLabel:SetColor(
        hasTarget and 0.66 or 0.88,
        hasTarget and 0.86 or 0.52,
        hasTarget and 0.68 or 0.48,
        1.0
    )

    if mode == "target" and not hasTarget then
        SetLabelText(section.emptyLabel, GetText("transform.snapshot.missing"))
    elseif mode == "current" and not hasCurrent then
        SetLabelText(section.emptyLabel, GetText("transform.current.unavailable"))
    end
    RefreshSkillSlots(section, displayedEntry)

    section.targetButton.ltmSelected = mode == "target"
    section.currentButton.ltmSelected = mode == "current"
    section.targetButton:ApplyVisualState(section.targetButton.ltmSelected and "pressed" or "normal")
    section.currentButton:ApplyVisualState(section.currentButton.ltmSelected and "pressed" or "normal")
    SetCheckButtonState(section.applyCheckbox, hasTarget and targetEntry.apply == true, hasTarget and hasCard)
    SetActionButtonEnabled(section.overwriteButton, hasCurrent and hasCard, false)
    SetActionButtonEnabled(section.deleteButton, hasTarget and hasCard, true)

    local focused = context.focusKind == kind
    section.root:SetEdgeColor(
        focused and 0.78 or 0.30,
        focused and 0.65 or 0.33,
        focused and 0.30 or 0.38,
        1.0
    )
end

function LTM_UI:RefreshTransformSkillsDialog()
    if self.currentDialogId ~= "TRANSFORM_SKILLS" then
        return
    end
    local context = self.currentDialogContext or {}
    context.viewModeByKind = type(context.viewModeByKind) == "table"
        and context.viewModeByKind
        or { werewolf = "target", vampire = "target" }
    local state = type(LTM_UI_DISPATCH.GetTransformSkillsPopupState) == "function"
        and LTM_UI_DISPATCH:GetTransformSkillsPopupState(context.cardId)
        or {}
    local targetByKind = IndexEntries(state.targetEntries)
    local currentByKind = IndexEntries(state.currentEntries)
    for _, kind in ipairs(KIND_ORDER) do
        local section = self.dialogTransformSkillsSections
            and self.dialogTransformSkillsSections[kind]
            or nil
        if section then
            RefreshSection(section, kind, context, targetByKind[kind], currentByKind[kind])
        end
    end
end

function LTM_UI:ClearTransformSkillsTooltip()
    ClearSkillTooltip()
end
