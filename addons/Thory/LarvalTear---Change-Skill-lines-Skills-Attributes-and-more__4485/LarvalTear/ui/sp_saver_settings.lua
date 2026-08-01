local Addon = LarvalTearMod
local SpSaverModes = Addon.Common.SpSaverModes
local LTM_UI = Addon.UI
local LTM_UI_DISPATCH = Addon.UI.Dispatch
local LTM_UI_SP_SAVER_SETTINGS = Addon.UI.SpSaverSettings
local LTM_UI_STRINGS = Addon.UI.Strings

local POPUP_WIDTH = 620
local POPUP_HEIGHT = 420
local POPUP_PADDING = 22
local TAB_WIDTH = 210
local TAB_HEIGHT = 34
local DROPDOWN_WIDTH = POPUP_WIDTH - (POPUP_PADDING * 2)
local DROPDOWN_HEIGHT = 32
local ACTIVE_MODE_TEXT_KEYS = {
    active_priority = "sp_saver.active.active_priority",
    skip_skill_changes = "sp_saver.active.skip_skill_changes",
}
local PASSIVE_MODE_TEXT_KEYS = {
    best_effort = "sp_saver.passive.best_effort",
    all_or_nothing = "sp_saver.passive.all_or_nothing",
    preserve_current = "sp_saver.passive.preserve_current",
}

local function BuildModeOptions(modeOrder, textKeys)
    local options = {}
    for _, mode in ipairs(modeOrder) do
        options[#options + 1] = {
            value = mode,
            textKey = textKeys[mode],
        }
    end
    return options
end

local ACTIVE_OPTIONS = BuildModeOptions(SpSaverModes.ActiveModes, ACTIVE_MODE_TEXT_KEYS)
local PASSIVE_OPTIONS = BuildModeOptions(SpSaverModes.PassiveModes, PASSIVE_MODE_TEXT_KEYS)

local function GetText(key, params)
    if type(LTM_UI_STRINGS) == "table" and type(LTM_UI_STRINGS.GetText) == "function" then
        return LTM_UI_STRINGS:GetText(key, params)
    end

    return key
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

local function IsCheckButtonChecked(checkButton)
    if checkButton == nil then
        return false
    end

    if type(ZO_CheckButton_IsChecked) == "function" then
        return ZO_CheckButton_IsChecked(checkButton) == true
    end

    return checkButton.checked == true
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

    local label = CreateLabel(button, "$(parent)Label", text, "ZoFontGame")
    label:SetAnchorFill(button)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    button:SetHandler("OnClicked", onClick)
    button.background = background
    button.label = label
    return button
end

local function CreateDropdownRow(parent, namePrefix, labelText, top, tooltipText)
    local label = CreateLabel(parent, namePrefix .. "Label", labelText, "ZoFontGame")
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
    if comboBox ~= nil then
        comboBox:SetSortsItems(false)
        comboBox:ClearItems()
    end

    dropdown.comboBox = comboBox
    return {
        label = label,
        dropdown = dropdown,
        comboBox = comboBox,
    }
end

local function FindOptionText(options, selectedValue)
    for _, option in ipairs(options) do
        if option.value == selectedValue then
            return GetText(option.textKey)
        end
    end

    return GetText(options[1].textKey)
end

local function RefreshDropdown(row, options, selectedValue, onSelected, enabled)
    if type(row) ~= "table" or row.comboBox == nil then
        return
    end

    row.comboBox:SetSortsItems(false)
    row.comboBox:ClearItems()
    for _, option in ipairs(options) do
        local capturedValue = option.value
        row.comboBox:AddItem(row.comboBox:CreateItemEntry(GetText(option.textKey), function()
            onSelected(capturedValue)
        end))
    end
    row.comboBox:SetSelectedItemText(FindOptionText(options, selectedValue))

    enabled = enabled ~= false
    if type(row.comboBox.SetEnabled) == "function" then
        row.comboBox:SetEnabled(enabled)
    end
    if type(row.dropdown.SetMouseEnabled) == "function" then
        row.dropdown:SetMouseEnabled(enabled)
    end
    if type(row.dropdown.SetAlpha) == "function" then
        row.dropdown:SetAlpha(enabled and 1.0 or 0.48)
    end
    if type(row.label.SetAlpha) == "function" then
        row.label:SetAlpha(enabled and 1.0 or 0.55)
    end
end

local function LogSaveError(err)
    if err ~= nil and type(LTM_UI.LogActionError) == "function" then
        LTM_UI:LogActionError("common.save", err)
    end
end

function LTM_UI_SP_SAVER_SETTINGS:Create(parent)
    if self.overlay ~= nil or parent == nil then
        return
    end

    local overlay = WINDOW_MANAGER:CreateControl("LTM_SpSaverSettingsOverlay", parent, CT_CONTROL)
    overlay:ClearAnchors()
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

    local panel = CreateBackdrop(overlay, "LTM_SpSaverSettingsPanel")
    panel:ClearAnchors()
    panel:SetAnchor(CENTER, overlay, CENTER, 0, 0)
    panel:SetDimensions(POPUP_WIDTH, POPUP_HEIGHT)
    panel:SetMouseEnabled(true)
    SetControlDrawOrder(panel, 42)
    self.panel = panel

    local title = CreateLabel(panel, "$(parent)Title", GetText("sp_saver.title"), "ZoFontWinH2")
    title:ClearAnchors()
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 14)
    title:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -(POPUP_PADDING + 34), 14)
    title:SetHeight(30)

    local closeButton = WINDOW_MANAGER:CreateControl("$(parent)CloseButton", panel, CT_BUTTON)
    closeButton:ClearAnchors()
    closeButton:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -POPUP_PADDING, 16)
    closeButton:SetDimensions(24, 24)
    closeButton:SetClickSound(SOUNDS.DEFAULT_CLICK)
    SetControlDrawOrder(closeButton, 45)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetDisabledTexture("/esoui/art/buttons/decline_disabled.dds")
    SetTextTooltip(closeButton, GetText("common.close"))
    closeButton:SetHandler("OnClicked", function()
        LTM_UI_SP_SAVER_SETTINGS:Close()
    end)

    local globalTab = CreateTabButton(panel, "$(parent)GlobalTab", GetText("sp_saver.tab.global"), function()
        LTM_UI_SP_SAVER_SETTINGS:SetTab("global")
    end)
    globalTab:ClearAnchors()
    globalTab:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 54)
    self.globalTab = globalTab

    local buildTab = CreateTabButton(panel, "$(parent)BuildTab", GetText("sp_saver.tab.build"), function()
        LTM_UI_SP_SAVER_SETTINGS:SetTab("build")
    end)
    buildTab:ClearAnchors()
    buildTab:SetAnchor(LEFT, globalTab, RIGHT, 8, 0)
    self.buildTab = buildTab

    local content = WINDOW_MANAGER:CreateControl("$(parent)Content", panel, CT_CONTROL)
    content:ClearAnchors()
    content:SetAnchor(TOPLEFT, panel, TOPLEFT, POPUP_PADDING, 98)
    content:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -POPUP_PADDING, -POPUP_PADDING)
    SetControlDrawOrder(content, 43)
    self.content = content

    local globalPanel = WINDOW_MANAGER:CreateControl("$(parent)GlobalPanel", content, CT_CONTROL)
    globalPanel:SetAnchorFill(content)
    SetControlDrawOrder(globalPanel, 44)
    self.globalPanel = globalPanel

    local globalDescription = CreateLabel(globalPanel, "$(parent)Description", GetText("sp_saver.global.description"), "ZoFontGame")
    globalDescription:ClearAnchors()
    globalDescription:SetAnchor(TOPLEFT, globalPanel, TOPLEFT, 0, 0)
    globalDescription:SetDimensions(DROPDOWN_WIDTH, 58)
    globalDescription:SetVerticalAlignment(TEXT_ALIGN_TOP)

    self.globalActiveRow = CreateDropdownRow(
        globalPanel,
        "LTM_SpSaverGlobalActive",
        GetText("sp_saver.active.label"),
        68,
        GetText("sp_saver.active.note")
    )

    local globalActiveNote = CreateLabel(globalPanel, "$(parent)ActiveNote", GetText("sp_saver.active.note"), "ZoFontGameSmall")
    globalActiveNote:ClearAnchors()
    globalActiveNote:SetAnchor(TOPLEFT, globalPanel, TOPLEFT, 0, 132)
    globalActiveNote:SetDimensions(DROPDOWN_WIDTH, 20)
    globalActiveNote:SetColor(0.70, 0.74, 0.80, 1.0)
    SetTextTooltip(globalActiveNote, GetText("sp_saver.active.note"))

    self.globalPassiveRow = CreateDropdownRow(
        globalPanel,
        "LTM_SpSaverGlobalPassive",
        GetText("sp_saver.passive.label"),
        166,
        ""
    )

    local buildPanel = WINDOW_MANAGER:CreateControl("$(parent)BuildPanel", content, CT_CONTROL)
    buildPanel:SetAnchorFill(content)
    buildPanel:SetHidden(true)
    SetControlDrawOrder(buildPanel, 44)
    self.buildPanel = buildPanel

    local overrideCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Override", buildPanel, "ZO_CheckButton")
    overrideCheckbox:ClearAnchors()
    overrideCheckbox:SetAnchor(TOPLEFT, buildPanel, TOPLEFT, 0, 0)
    overrideCheckbox:SetDimensions(22, 22)
    SetControlDrawOrder(overrideCheckbox, 45)
    SetControlDrawOrder(overrideCheckbox:GetNamedChild("Button"), 46)
    SetControlDrawOrder(overrideCheckbox:GetNamedChild("Text"), 46)
    SetControlDrawOrder(overrideCheckbox:GetNamedChild("Label"), 46)
    if type(ZO_CheckButton_SetLabelText) == "function" then
        ZO_CheckButton_SetLabelText(overrideCheckbox, "")
    end

    local overrideLabel = CreateLabel(
        buildPanel,
        "$(parent)OverrideDisplayText",
        GetText("sp_saver.build.override"),
        "ZoFontGame"
    )
    overrideLabel:ClearAnchors()
    overrideLabel:SetAnchor(TOPLEFT, overrideCheckbox, TOPRIGHT, 8, 0)
    overrideLabel:SetAnchor(TOPRIGHT, buildPanel, TOPRIGHT, 0, 0)
    overrideLabel:SetHeight(22)
    if type(overrideLabel.SetVerticalAlignment) == "function" then
        overrideLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    overrideLabel:SetMouseEnabled(true)
    SetControlDrawOrder(overrideLabel, 46)
    SetTextTooltip(overrideCheckbox, GetText("sp_saver.build.description"))
    SetTextTooltip(overrideLabel, GetText("sp_saver.build.description"))

    local function SaveOverrideToggle(_, isChecked)
        if overrideCheckbox.ltmSuppressToggle then
            return
        end
        LTM_UI_SP_SAVER_SETTINGS:SaveBuildSetting("useOverride", isChecked == true)
    end

    if type(ZO_CheckButton_SetToggleFunction) == "function" then
        ZO_CheckButton_SetToggleFunction(overrideCheckbox, SaveOverrideToggle)
    end
    overrideLabel:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if upInside ~= true or mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end

        local isChecked = not IsCheckButtonChecked(overrideCheckbox)
        if type(ZO_CheckButton_SetCheckState) == "function" then
            ZO_CheckButton_SetCheckState(overrideCheckbox, isChecked)
        end
        SaveOverrideToggle(overrideCheckbox, isChecked)
    end)
    self.overrideCheckbox = overrideCheckbox
    self.overrideLabel = overrideLabel

    local buildDescription = CreateLabel(buildPanel, "$(parent)Description", GetText("sp_saver.build.description"), "ZoFontGame")
    buildDescription:ClearAnchors()
    buildDescription:SetAnchor(TOPLEFT, buildPanel, TOPLEFT, 0, 42)
    buildDescription:SetDimensions(DROPDOWN_WIDTH, 58)
    buildDescription:SetVerticalAlignment(TEXT_ALIGN_TOP)

    self.buildActiveRow = CreateDropdownRow(
        buildPanel,
        "LTM_SpSaverBuildActive",
        GetText("sp_saver.active.label"),
        110,
        GetText("sp_saver.active.note")
    )

    local buildActiveNote = CreateLabel(buildPanel, "$(parent)ActiveNote", GetText("sp_saver.active.note"), "ZoFontGameSmall")
    buildActiveNote:ClearAnchors()
    buildActiveNote:SetAnchor(TOPLEFT, buildPanel, TOPLEFT, 0, 174)
    buildActiveNote:SetDimensions(DROPDOWN_WIDTH, 20)
    buildActiveNote:SetColor(0.70, 0.74, 0.80, 1.0)
    SetTextTooltip(buildActiveNote, GetText("sp_saver.active.note"))
    self.buildActiveNote = buildActiveNote

    self.buildPassiveRow = CreateDropdownRow(
        buildPanel,
        "LTM_SpSaverBuildPassive",
        GetText("sp_saver.passive.label"),
        208,
        ""
    )
end

function LTM_UI_SP_SAVER_SETTINGS:SetTab(tabId)
    self.activeTab = tabId == "global" and "global" or "build"
    local globalActive = self.activeTab == "global"
    if self.globalPanel ~= nil then
        self.globalPanel:SetHidden(not globalActive)
    end
    if self.buildPanel ~= nil then
        self.buildPanel:SetHidden(globalActive)
    end

    for tabKey, button in pairs({ global = self.globalTab, build = self.buildTab }) do
        local active = tabKey == self.activeTab
        if button ~= nil and button.background ~= nil then
            button.background:SetCenterColor(active and 0.25 or 0.10, active and 0.28 or 0.11, active and 0.34 or 0.14, 1.0)
            button.background:SetEdgeColor(active and 0.72 or 0.35, active and 0.76 or 0.38, active and 0.84 or 0.44, 1.0)
        end
        if button ~= nil and button.label ~= nil then
            button.label:SetColor(active and 1.0 or 0.75, active and 1.0 or 0.78, active and 1.0 or 0.84, 1.0)
        end
    end

    if globalActive then
        self:RefreshGlobalControls()
    else
        self:RefreshBuildControls()
    end
end

function LTM_UI_SP_SAVER_SETTINGS:RefreshGlobalControls()
    local settings = LTM_UI_DISPATCH:GetGlobalSpSaverSettings()

    RefreshDropdown(self.globalActiveRow, ACTIVE_OPTIONS, settings.activeMode, function(value)
        local _, err = LTM_UI_DISPATCH:SetGlobalSpSaverActiveMode(value)
        LogSaveError(err)
        LTM_UI_SP_SAVER_SETTINGS:RefreshGlobalControls()
    end, true)
    RefreshDropdown(self.globalPassiveRow, PASSIVE_OPTIONS, settings.passiveMode, function(value)
        local _, err = LTM_UI_DISPATCH:SetGlobalSpSaverPassiveMode(value)
        LogSaveError(err)
        LTM_UI_SP_SAVER_SETTINGS:RefreshGlobalControls()
    end, true)
end

function LTM_UI_SP_SAVER_SETTINGS:RefreshBuildControls()
    local settings, err = LTM_UI_DISPATCH:GetCardSpSaverSettings(self.cardId)
    if type(settings) ~= "table" then
        LogSaveError(err)
        return
    end
    self.buildSettings = settings

    if self.overrideCheckbox ~= nil then
        self.overrideCheckbox.ltmSuppressToggle = true
        if type(ZO_CheckButton_SetCheckState) == "function" then
            ZO_CheckButton_SetCheckState(self.overrideCheckbox, self.buildSettings.useOverride)
        end
        self.overrideCheckbox.ltmSuppressToggle = false
    end

    local enabled = self.buildSettings.useOverride == true
    RefreshDropdown(self.buildActiveRow, ACTIVE_OPTIONS, self.buildSettings.activeMode, function(value)
        LTM_UI_SP_SAVER_SETTINGS:SaveBuildSetting("activeMode", value)
    end, enabled)
    RefreshDropdown(self.buildPassiveRow, PASSIVE_OPTIONS, self.buildSettings.passiveMode, function(value)
        LTM_UI_SP_SAVER_SETTINGS:SaveBuildSetting("passiveMode", value)
    end, enabled)
    if self.buildActiveNote ~= nil then
        self.buildActiveNote:SetAlpha(enabled and 1.0 or 0.55)
    end
end

function LTM_UI_SP_SAVER_SETTINGS:SaveBuildSetting(key, value)
    if type(self.buildSettings) ~= "table" then
        return
    end

    local settings = {
        useOverride = self.buildSettings.useOverride == true,
        activeMode = self.buildSettings.activeMode,
        passiveMode = self.buildSettings.passiveMode,
    }
    if key == "useOverride" then
        settings.useOverride = value == true
    elseif key == "activeMode" then
        settings.activeMode = value
    elseif key == "passiveMode" then
        settings.passiveMode = value
    else
        return
    end

    local savedSettings, err = LTM_UI_DISPATCH:SetCardSpSaverSettings(self.cardId, settings)
    if type(savedSettings) ~= "table" then
        LogSaveError(err)
        return
    end
    self.buildSettings = savedSettings
    self:RefreshBuildControls()
end

function LTM_UI_SP_SAVER_SETTINGS:Open(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return false
    end

    if self.overlay == nil then
        self:Create(LTM_UI.frontOverlayRoot)
    end
    if self.overlay == nil then
        return false
    end

    if type(LTM_UI.HideDialog) == "function" then
        LTM_UI:HideDialog()
    end
    self.cardId = cardId
    self.overlay:SetHidden(false)
    self:SetTab("build")
    return true
end

function LTM_UI_SP_SAVER_SETTINGS:Close()
    if self.overlay ~= nil then
        self.overlay:SetHidden(true)
    end
    self.cardId = nil
    self.buildSettings = nil
    if type(ClearTooltip) == "function" and InformationTooltip then
        ClearTooltip(InformationTooltip)
    end
end
