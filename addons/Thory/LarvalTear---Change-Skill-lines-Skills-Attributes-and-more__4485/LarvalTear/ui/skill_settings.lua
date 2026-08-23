local Addon = LarvalTearMod
local SkillSettings = Addon.Common.SkillSettings
local LTM_UI = Addon.UI
local LTM_UI_DISPATCH = Addon.UI.Dispatch
local LTM_UI_SKILL_SETTINGS = Addon.UI.SkillSettings
local LTM_UI_STRINGS = Addon.UI.Strings

local POPUP_WIDTH = 700
local POPUP_HEIGHT = 690
local POPUP_PADDING = 22
local TAB_WIDTH = 210
local TAB_HEIGHT = 34
local DROPDOWN_WIDTH = POPUP_WIDTH - (POPUP_PADDING * 2)
local DROPDOWN_HEIGHT = 32

local ACTIVE_RESTORE_TEXT_KEYS = {
    required_only = "skill_settings.active_restore.required_only",
    exact = "skill_settings.active_restore.exact",
    clear_unused = "skill_settings.active_restore.clear_unused",
}
local PASSIVE_RESTORE_TEXT_KEYS = {
    none = "skill_settings.passive_restore.none",
    class_purchase_all = "skill_settings.passive_restore.class_purchase_all",
    class_exact = "skill_settings.passive_restore.class_exact",
    all_exact = "skill_settings.passive_restore.all_exact",
}
local PASSIVE_SHORTAGE_TEXT_KEYS = {
    best_effort = "skill_settings.passive_shortage.best_effort",
    all_or_nothing = "skill_settings.passive_shortage.all_or_nothing",
}
local ACTIVE_SHORTAGE_TEXT_KEYS = {
    active_priority = "skill_settings.active_shortage.active_priority",
    skip_all = "skill_settings.active_shortage.skip_all",
}

local function BuildOptions(modeOrder, textKeys)
    local options = {}
    for _, mode in ipairs(modeOrder) do
        options[#options + 1] = {
            value = mode,
            textKey = textKeys[mode],
        }
    end
    return options
end

local ACTIVE_RESTORE_OPTIONS = BuildOptions(SkillSettings.ActiveRestoreModes, ACTIVE_RESTORE_TEXT_KEYS)
local PASSIVE_RESTORE_OPTIONS = BuildOptions(SkillSettings.PassiveRestoreModes, PASSIVE_RESTORE_TEXT_KEYS)
local PASSIVE_SHORTAGE_OPTIONS = BuildOptions(SkillSettings.PassiveShortageModes, PASSIVE_SHORTAGE_TEXT_KEYS)
local ACTIVE_SHORTAGE_OPTIONS = BuildOptions(SkillSettings.ActiveShortageModes, ACTIVE_SHORTAGE_TEXT_KEYS)
local EDITABLE_FIELDS = {
    activeRestore = true,
    passiveRestore = true,
    passiveShortage = true,
    activeShortage = true,
}

local function GetText(key, params)
    return LTM_UI_STRINGS:GetText(key, params)
end

local function CopySettings(settings, includeOverride)
    local normalized = includeOverride
        and SkillSettings:NormalizeBuild(settings)
        or SkillSettings:NormalizeGlobal(settings)
    local result = {
        activeRestore = normalized.activeRestore,
        passiveRestore = normalized.passiveRestore,
        passiveShortage = normalized.passiveShortage,
        activeShortage = normalized.activeShortage,
    }
    if includeOverride then
        result.useOverride = normalized.useOverride == true
    end
    return result
end

function LTM_UI_SKILL_SETTINGS:BuildViewState(scope, globalSettings, cardState)
    local normalizedGlobal = CopySettings(globalSettings, false)
    if scope == "global" then
        return {
            scope = "global",
            settings = normalizedGlobal,
            editable = true,
            exactEnabled = false,
            activeSnapshotState = type(cardState) == "table" and cardState.activeSnapshotState or "missing",
            passiveSnapshotState = type(cardState) == "table" and cardState.passiveSnapshotState or "missing",
        }
    end

    local stored = CopySettings(type(cardState) == "table" and cardState.settings or nil, true)
    local useOverride = stored.useOverride == true
    local activeSnapshotState = type(cardState) == "table" and cardState.activeSnapshotState or "missing"
    return {
        scope = "build",
        settings = useOverride and stored or normalizedGlobal,
        storedSettings = stored,
        useOverride = useOverride,
        editable = useOverride,
        exactEnabled = useOverride and activeSnapshotState ~= "missing",
        activeSnapshotState = activeSnapshotState,
        passiveSnapshotState = type(cardState) == "table" and cardState.passiveSnapshotState or "missing",
    }
end

local function SetControlDrawOrder(control, drawLevel)
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
        control:SetDrawLevel(drawLevel)
    end
end

local function SetTextTooltip(control, text)
    if control == nil then
        return
    end
    control.ltmTooltipText = text or ""
    control:SetHandler("OnMouseEnter", function(self)
        if type(InitializeTooltip) == "function"
            and InformationTooltip
            and type(self.ltmTooltipText) == "string"
            and self.ltmTooltipText ~= "" then
            InitializeTooltip(InformationTooltip, self, TOP, 0, 0, BOTTOM)
            if type(SetTooltipText) == "function" then
                SetTooltipText(InformationTooltip, self.ltmTooltipText)
            end
        end
    end)
    control:SetHandler("OnMouseExit", function()
        if type(ClearTooltip) == "function" and InformationTooltip then
            ClearTooltip(InformationTooltip)
        end
    end)
end

local function CreateBackdrop(parent, name)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultBackdrop")
    backdrop:SetCenterColor(0.05, 0.06, 0.08, 1.0)
    backdrop:SetEdgeColor(0.70, 0.74, 0.80, 1.0)
    return backdrop
end

local function CreateLabel(parent, name, text, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(0.90, 0.90, 0.94, 1.0)
    label:SetText(text or "")
    SetControlDrawOrder(label, 45)
    return label
end

local function CreateTabButton(parent, name, text, onClick)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(TAB_WIDTH, TAB_HEIGHT)
    button:SetClickSound(SOUNDS.DEFAULT_CLICK)
    SetControlDrawOrder(button, 44)

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", button, CT_BACKDROP)
    background:SetAnchorFill(button)
    background:SetCenterColor(0.10, 0.11, 0.14, 1.0)
    background:SetEdgeColor(0.35, 0.38, 0.44, 1.0)
    SetControlDrawOrder(background, 44)

    local label = CreateLabel(button, "$(parent)Label", text)
    label:SetAnchorFill(button)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button:SetHandler("OnClicked", onClick)
    button.background = background
    button.label = label
    return button
end

local function CreateDropdownRow(parent, namePrefix, labelText, top, tooltipText)
    local label = CreateLabel(parent, namePrefix .. "Label", labelText)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, top)
    label:SetDimensions(DROPDOWN_WIDTH, 22)

    local dropdown = WINDOW_MANAGER:CreateControlFromVirtual(namePrefix .. "Dropdown", parent, "ZO_ComboBox")
    dropdown:ClearAnchors()
    dropdown:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 3)
    dropdown:SetDimensions(DROPDOWN_WIDTH, DROPDOWN_HEIGHT)
    SetControlDrawOrder(dropdown, 45)
    SetControlDrawOrder(dropdown:GetNamedChild("BG"), 46)
    SetControlDrawOrder(dropdown:GetNamedChild("SelectedItemText"), 47)
    SetControlDrawOrder(dropdown:GetNamedChild("OpenDropdown"), 47)
    SetTextTooltip(label, tooltipText)
    SetTextTooltip(dropdown, tooltipText)

    local comboBox = ZO_ComboBox_ObjectFromContainer(dropdown)
    comboBox:SetSortsItems(false)
    dropdown.comboBox = comboBox
    return { label = label, dropdown = dropdown, comboBox = comboBox }
end

local function FindOptionText(options, selectedValue)
    for _, option in ipairs(options) do
        if option.value == selectedValue then
            return GetText(option.textKey)
        end
    end
    return GetText(options[1].textKey)
end

local function SetRowEnabled(row, enabled)
    if type(row.comboBox.SetEnabled) == "function" then
        row.comboBox:SetEnabled(enabled)
    end
    row.dropdown:SetMouseEnabled(enabled)
    row.dropdown:SetAlpha(enabled and 1.0 or 0.48)
    row.label:SetAlpha(enabled and 1.0 or 0.55)
end

local function RefreshDropdown(row, options, selectedValue, onSelected, enabled, isOptionEnabled)
    row.comboBox:SetSortsItems(false)
    row.comboBox:ClearItems()
    for _, option in ipairs(options) do
        local capturedValue = option.value
        local optionEnabled = isOptionEnabled == nil or isOptionEnabled(capturedValue)
        row.comboBox:AddItem(row.comboBox:CreateItemEntry(GetText(option.textKey), function()
            onSelected(capturedValue)
        end, optionEnabled))
    end
    row.comboBox:SetSelectedItemText(FindOptionText(options, selectedValue))
    SetRowEnabled(row, enabled)
end

local function IsCheckButtonChecked(checkButton)
    if type(ZO_CheckButton_IsChecked) == "function" then
        return ZO_CheckButton_IsChecked(checkButton) == true
    end
    return checkButton.checked == true
end

local function LogSaveError(err)
    if err ~= nil then
        LTM_UI:LogActionError("common.save", err)
    end
end

local function RefreshArmoryPanels()
    LTM_UI:RefreshCardList()
    if LTM_UI.window and not LTM_UI.window:IsHidden()
        and LTM_UI:IsArmoryStationTabActive() then
        LTM_UI:RefreshRightPanePanel()
    end
end

local function GetSkillSnapshotSummaryText(view)
    local activeKey = type(view) == "table" and view.activeSnapshotState == "saved"
        and "skill_settings.snapshot_detail.active.saved"
        or "skill_settings.snapshot_detail.active.missing"
    local passiveKey = type(view) == "table" and view.passiveSnapshotState == "saved"
        and "skill_settings.snapshot_detail.passive.saved"
        or "skill_settings.snapshot_detail.passive.missing"
    return GetText("skill_settings.snapshot_detail.summary", {
        active = GetText(activeKey),
        passive = GetText(passiveKey),
    })
end

function LTM_UI_SKILL_SETTINGS:Create(parent)
    if self.overlay ~= nil or parent == nil then
        return
    end

    local overlay = WINDOW_MANAGER:CreateControl("LTM_SkillSettingsOverlay", parent, CT_CONTROL)
    overlay:SetAnchorFill(parent)
    overlay:SetHidden(true)
    overlay:SetMouseEnabled(true)
    SetControlDrawOrder(overlay, 40)
    self.overlay = overlay

    local shade = WINDOW_MANAGER:CreateControl("$(parent)Shade", overlay, CT_BACKDROP)
    shade:SetAnchorFill(overlay)
    shade:SetCenterColor(0.0, 0.0, 0.0, 0.84)
    shade:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
    shade:SetMouseEnabled(true)
    SetControlDrawOrder(shade, 41)

    local panel = CreateBackdrop(overlay, "LTM_SkillSettingsPanel")
    panel:ClearAnchors()
    panel:SetAnchor(CENTER, overlay, CENTER, 0, 0)
    panel:SetDimensions(POPUP_WIDTH, POPUP_HEIGHT)
    panel:SetMouseEnabled(true)
    SetControlDrawOrder(panel, 42)

    local title = CreateLabel(panel, "$(parent)Title", GetText("skill_settings.title"), "ZoFontWinH2")
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 14)
    title:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -(POPUP_PADDING + 34), 14)
    title:SetHeight(30)

    local closeButton = WINDOW_MANAGER:CreateControl("$(parent)CloseButton", panel, CT_BUTTON)
    closeButton:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -POPUP_PADDING, 16)
    closeButton:SetDimensions(24, 24)
    closeButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
    SetControlDrawOrder(closeButton, 45)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetDisabledTexture("/esoui/art/buttons/decline_disabled.dds")
    SetTextTooltip(closeButton, GetText("common.close"))
    closeButton:SetHandler("OnClicked", function() LTM_UI_SKILL_SETTINGS:Close() end)

    self.globalTab = CreateTabButton(panel, "$(parent)GlobalTab", GetText("skill_settings.tab.global"), function()
        LTM_UI_SKILL_SETTINGS:SetTab("global")
    end)
    self.globalTab:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 54)
    self.buildTab = CreateTabButton(panel, "$(parent)BuildTab", GetText("skill_settings.tab.build"), function()
        LTM_UI_SKILL_SETTINGS:SetTab("build")
    end)
    self.buildTab:SetAnchor(LEFT, self.globalTab, RIGHT, 8, 0)

    local content = WINDOW_MANAGER:CreateControl("$(parent)Content", panel, CT_CONTROL)
    content:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 98)
    content:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -POPUP_PADDING, -POPUP_PADDING)
    SetControlDrawOrder(content, 43)

    self.description = CreateLabel(content, "$(parent)Description", "")
    self.description:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 0)
    self.description:SetDimensions(DROPDOWN_WIDTH, 62)
    self.description:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.description:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if type(self.description.SetWrapMode) == "function" and TEXT_WRAP_MODE_DEFAULT ~= nil then
        self.description:SetWrapMode(TEXT_WRAP_MODE_DEFAULT)
    end

    self.overrideCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Override", content, "ZO_CheckButton")
    self.overrideCheckbox:ClearAnchors()
    self.overrideCheckbox:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 64)
    self.overrideCheckbox:SetDimensions(22, 22)
    SetControlDrawOrder(self.overrideCheckbox, 45)
    self.overrideLabel = CreateLabel(
        content,
        "$(parent)OverrideDisplayText",
        GetText("skill_settings.build.override")
    )
    self.overrideLabel:SetAnchor(TOPLEFT, self.overrideCheckbox, TOPRIGHT, 8, 0)
    self.overrideLabel:SetHeight(22)
    self.overrideLabel:SetMouseEnabled(true)
    SetTextTooltip(self.overrideCheckbox, GetText("skill_settings.build.override.tooltip"))
    SetTextTooltip(self.overrideLabel, GetText("skill_settings.build.override.tooltip"))

    local function SaveOverride(_, checked)
        if not LTM_UI_SKILL_SETTINGS.suppressOverride then
            LTM_UI_SKILL_SETTINGS:SaveBuildOverride(checked == true)
        end
    end
    if type(ZO_CheckButton_SetToggleFunction) == "function" then
        ZO_CheckButton_SetToggleFunction(self.overrideCheckbox, SaveOverride)
    end
    self.overrideLabel:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if upInside == true and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            local checked = not IsCheckButtonChecked(LTM_UI_SKILL_SETTINGS.overrideCheckbox)
            if type(ZO_CheckButton_SetCheckState) == "function" then
                ZO_CheckButton_SetCheckState(LTM_UI_SKILL_SETTINGS.overrideCheckbox, checked)
            end
            SaveOverride(nil, checked)
        end
    end)

    self.snapshotLabel = CreateLabel(content, "$(parent)Snapshot", "", "ZoFontGameSmall")
    self.snapshotLabel:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 88)
    self.snapshotLabel:SetDimensions(DROPDOWN_WIDTH, 22)
    self.snapshotLabel:SetColor(0.72, 0.76, 0.82, 1.0)

    local restoreHeader = CreateLabel(content, "$(parent)RestoreHeader", GetText("skill_settings.restore.header"), "ZoFontWinH4")
    restoreHeader:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 112)
    restoreHeader:SetDimensions(DROPDOWN_WIDTH, 24)

    self.activeRestoreRow = CreateDropdownRow(
        content,
        "LTM_SkillSettingsActiveRestore",
        GetText("skill_settings.active_restore.label"),
        140,
        GetText("skill_settings.active_restore.tooltip")
    )
    self.activeNote = CreateLabel(content, "$(parent)ActiveNote", "", "ZoFontGameSmall")
    self.activeNote:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 198)
    self.activeNote:SetDimensions(DROPDOWN_WIDTH, 34)
    self.activeNote:SetColor(0.78, 0.80, 0.86, 1.0)

    self.passiveRestoreRow = CreateDropdownRow(
        content,
        "LTM_SkillSettingsPassiveRestore",
        GetText("skill_settings.passive_restore.label"),
        234,
        GetText("skill_settings.passive_restore.tooltip")
    )

    local shortageHeader = CreateLabel(content, "$(parent)ShortageHeader", GetText("skill_settings.shortage.header"), "ZoFontWinH4")
    shortageHeader:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 314)
    shortageHeader:SetDimensions(DROPDOWN_WIDTH, 24)

    self.passiveShortageRow = CreateDropdownRow(content, "LTM_SkillSettingsPassiveShortage", GetText("skill_settings.passive_shortage.label"), 342, "")
    self.activeShortageRow = CreateDropdownRow(
        content,
        "LTM_SkillSettingsActiveShortage",
        GetText("skill_settings.active_shortage.label"),
        418,
        GetText("skill_settings.active_shortage.tooltip")
    )

    self.warningLabel = CreateLabel(content, "$(parent)Warning", "", "ZoFontGame")
    self.warningLabel:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 492)
    self.warningLabel:SetDimensions(DROPDOWN_WIDTH, 64)
    self.warningLabel:SetColor(1.0, 0.35, 0.22, 1.0)
end

function LTM_UI_SKILL_SETTINGS:SetTab(tabId)
    self.activeTab = tabId == "global" and "global" or "build"
    for key, button in pairs({ global = self.globalTab, build = self.buildTab }) do
        local active = key == self.activeTab
        button.background:SetCenterColor(active and 0.25 or 0.10, active and 0.28 or 0.11, active and 0.34 or 0.14, 1.0)
        button.background:SetEdgeColor(active and 0.72 or 0.35, active and 0.76 or 0.38, active and 0.84 or 0.44, 1.0)
        button.label:SetColor(active and 1.0 or 0.75, active and 1.0 or 0.78, active and 1.0 or 0.84, 1.0)
    end
    self:Refresh()
end

function LTM_UI_SKILL_SETTINGS:Refresh()
    local globalSettings = LTM_UI_DISPATCH:GetGlobalSkillSettings()
    local cardState, err = LTM_UI_DISPATCH:GetCardSkillSettingsState(self.cardId)
    if type(globalSettings) ~= "table" or type(cardState) ~= "table" then
        LogSaveError(err or "settings_unavailable")
        return
    end

    local view = self:BuildViewState(self.activeTab, globalSettings, cardState)
    self.viewState = view
    local isBuild = view.scope == "build"
    self.description:SetText(GetText(isBuild and "skill_settings.build.description" or "skill_settings.global.description"))
    self.overrideCheckbox:SetHidden(not isBuild)
    self.overrideLabel:SetHidden(not isBuild)
    self.suppressOverride = true
    if type(ZO_CheckButton_SetCheckState) == "function" then
        ZO_CheckButton_SetCheckState(self.overrideCheckbox, view.useOverride == true)
    end
    self.suppressOverride = false

    self.snapshotLabel:SetText(GetSkillSnapshotSummaryText(view))

    local function Save(field, value) LTM_UI_SKILL_SETTINGS:SaveSetting(field, value) end
    RefreshDropdown(self.activeRestoreRow, ACTIVE_RESTORE_OPTIONS, view.settings.activeRestore, function(value)
        Save("activeRestore", value)
    end, view.editable, function(value)
        return value ~= "exact" or view.exactEnabled == true
    end)
    RefreshDropdown(self.passiveRestoreRow, PASSIVE_RESTORE_OPTIONS, view.settings.passiveRestore, function(value)
        Save("passiveRestore", value)
    end, view.editable)
    RefreshDropdown(self.passiveShortageRow, PASSIVE_SHORTAGE_OPTIONS, view.settings.passiveShortage, function(value)
        Save("passiveShortage", value)
    end, view.editable)
    RefreshDropdown(self.activeShortageRow, ACTIVE_SHORTAGE_OPTIONS, view.settings.activeShortage, function(value)
        Save("activeShortage", value)
    end, view.editable)

    local activeNote = ""
    if not isBuild then
        activeNote = GetText("skill_settings.active_restore.exact.global_disabled")
    elseif view.activeSnapshotState == "missing" then
        activeNote = GetText("skill_settings.active_restore.exact.snapshot_missing")
    elseif view.settings.activeRestore == "exact" then
        activeNote = GetText("skill_settings.active_restore.exact.note")
    elseif view.useOverride ~= true then
        activeNote = GetText("skill_settings.build.using_global")
    end
    self.activeNote:SetText(activeNote)
    self.warningLabel:SetText(view.settings.activeRestore == "clear_unused"
        and GetText("skill_settings.active_restore.clear_warning") or "")
end

function LTM_UI_SKILL_SETTINGS:SaveSetting(field, value)
    if EDITABLE_FIELDS[field] ~= true or type(self.viewState) ~= "table" or self.viewState.editable ~= true then
        return
    end
    if field == "activeRestore" and value == "exact" and self.viewState.exactEnabled ~= true then
        return
    end

    if self.activeTab == "global" then
        local updated = CopySettings(self.viewState.settings, false)
        updated[field] = value
        local saved, err = LTM_UI_DISPATCH:SetGlobalSkillSettings(updated)
        if type(saved) ~= "table" then
            LogSaveError(err)
            return
        end
    else
        local updated = CopySettings(self.viewState.storedSettings, true)
        updated[field] = value
        local saved, err = LTM_UI_DISPATCH:SetCardSkillSettings(self.cardId, updated)
        if type(saved) ~= "table" then
            LogSaveError(err)
            return
        end
    end
    RefreshArmoryPanels()
    self:Refresh()
end

function LTM_UI_SKILL_SETTINGS:SaveBuildOverride(enabled)
    local cardState, err = LTM_UI_DISPATCH:GetCardSkillSettingsState(self.cardId)
    if type(cardState) ~= "table" then
        LogSaveError(err)
        return
    end
    local updated = CopySettings(cardState.settings, true)
    if enabled and updated.useOverride ~= true then
        local globalSettings = CopySettings(LTM_UI_DISPATCH:GetGlobalSkillSettings(), false)
        updated.activeRestore = globalSettings.activeRestore
        updated.passiveRestore = globalSettings.passiveRestore
        updated.passiveShortage = globalSettings.passiveShortage
        updated.activeShortage = globalSettings.activeShortage
    end
    updated.useOverride = enabled == true
    local saved, saveErr = LTM_UI_DISPATCH:SetCardSkillSettings(self.cardId, updated)
    if type(saved) ~= "table" then
        LogSaveError(saveErr)
        return
    end
    RefreshArmoryPanels()
    self:Refresh()
end

function LTM_UI_SKILL_SETTINGS:Open(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return false
    end
    if self.overlay == nil then
        self:Create(LTM_UI.frontOverlayRoot)
    end
    if self.overlay == nil then
        return false
    end
    LTM_UI:HideDialog()
    self.cardId = cardId
    self.overlay:SetHidden(false)
    self:SetTab("build")
    return true
end

function LTM_UI_SKILL_SETTINGS:Close()
    if self.overlay ~= nil then
        self.overlay:SetHidden(true)
    end
    self.cardId = nil
    self.viewState = nil
    if type(ClearTooltip) == "function" and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end
