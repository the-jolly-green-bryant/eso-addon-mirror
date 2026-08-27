local OCP = OutfitCollectionProfiles

local COLORS = {
    emberBright = ZO_ColorDef:New("E58A5A"),
    emberSoft = ZO_ColorDef:New("8F4C35"),
    text = ZO_ColorDef:New("EEE9E4"),
    muted = ZO_ColorDef:New("9D9894"),
    dim = ZO_ColorDef:New("686461"),
    good = ZO_ColorDef:New("79C98A"),
    warning = ZO_ColorDef:New("D8AA62"),
}

local function CreateLabel(parent, name, font, color)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor((color or COLORS.text):UnpackRGBA())
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function CreatePanel(parent, name, centerColor, edgeColor)
    local panel = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    panel:SetCenterColor(unpack(centerColor))
    panel:SetEdgeColor(unpack(edgeColor or { 0, 0, 0, 0 }))
    return panel
end

local function CreateOutline(parent, name, width, height, thickness, color)
    local outline = {}
    local function Line(suffix, lineWidth, lineHeight, point, relativePoint)
        local line = WINDOW_MANAGER:CreateControl(name .. suffix, parent, CT_TEXTURE)
        line:SetDimensions(lineWidth, lineHeight)
        line:SetAnchor(point, parent, relativePoint, 0, 0)
        line:SetColor(unpack(color))
        outline[#outline + 1] = line
    end
    Line("Top", width, thickness, TOP, TOP)
    Line("Bottom", width, thickness, BOTTOM, BOTTOM)
    Line("Left", thickness, height, LEFT, LEFT)
    Line("Right", thickness, height, RIGHT, RIGHT)
    return outline
end

local function SetOutlineColor(outline, color)
    for _, line in ipairs(outline) do line:SetColor(unpack(color)) end
end

local function CreateDropdown(parent, name, width)
    local container = CreateControlFromVirtual(name, parent, "ZO_ComboBox")
    container:SetDimensions(width, 34)
    local combo = ZO_ComboBox_ObjectFromContainer(container)
    -- ZO_ComboBox caches the container width during virtual-control
    -- initialization, before SetDimensions above has run. Keep that cached
    -- value synchronized and constrain the shared popup to the field width.
    combo.m_containerWidth = width
    local AddMenuItems = combo.AddMenuItems
    combo.AddMenuItems = function(self)
        AddMenuItems(self)
        self.m_dropdown:SetWidth(width)
    end
    combo:SetSortsItems(false)
    combo:SetFont("ZoFontGame")
    combo:SetSpacing(4)
    return container, combo
end

local function CreateActionButton(parent, name, text, width, primary)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(width, 40)
    button:SetText("")

    local shadow = CreatePanel(button, name .. "Shadow", { 0, 0, 0, 0.42 })
    shadow:SetAnchor(TOPLEFT, button, TOPLEFT, 3, 4)
    shadow:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, 3, 4)

    local background = CreatePanel(button, name .. "Background",
        primary and { 0.23, 0.075, 0.035, 0.97 } or { 0.025, 0.028, 0.034, 0.98 },
        primary and { 0.79, 0.35, 0.17, 0.90 } or { 0.35, 0.31, 0.29, 0.90 })
    background:SetAnchorFill()

    local accent = WINDOW_MANAGER:CreateControl(name .. "Accent", button, CT_TEXTURE)
    accent:SetDimensions(width, 2)
    accent:SetAnchor(BOTTOM, button, BOTTOM, 0, 0)
    accent:SetColor((primary and COLORS.emberBright or COLORS.emberSoft):UnpackRGBA())
    local normalOutlineColor = primary
        and { 0.79, 0.35, 0.17, 0.90 }
        or { 0.35, 0.31, 0.29, 0.90 }
    local outline = CreateOutline(button, name .. "Outline", width, 40, 1,
        normalOutlineColor)

    -- A separate label guarantees the text stays above the custom backdrop.
    local label = CreateLabel(button, name .. "Label", "ZoFontGameBold", COLORS.text)
    label:SetAnchorFill()
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(text)

    button:SetHandler("OnMouseEnter", function()
        background:SetCenterColor(primary and 0.32 or 0.08, primary and 0.10 or 0.07,
            primary and 0.045 or 0.065, 1)
        background:SetEdgeColor(COLORS.emberBright:UnpackRGBA())
        accent:SetColor(COLORS.emberBright:UnpackRGBA())
        SetOutlineColor(outline, { 0.90, 0.50, 0.29, 1 })
        label:SetColor(1, 1, 1, 1)
        if button.tooltipText then
            InitializeTooltip(InformationTooltip, button, TOPLEFT, 0, 6, BOTTOMLEFT)
            SetTooltipText(InformationTooltip, button.tooltipText)
        end
    end)
    button:SetHandler("OnMouseExit", function()
        background:SetCenterColor(unpack(primary
            and { 0.23, 0.075, 0.035, 0.97 }
            or { 0.025, 0.028, 0.034, 0.98 }))
        background:SetEdgeColor(unpack(primary
            and { 0.79, 0.35, 0.17, 0.90 }
            or { 0.35, 0.31, 0.29, 0.90 }))
        accent:SetColor((primary and COLORS.emberBright or COLORS.emberSoft):UnpackRGBA())
        SetOutlineColor(outline, normalOutlineColor)
        label:SetColor(COLORS.text:UnpackRGBA())
        ClearTooltip(InformationTooltip)
    end)
    button:SetHandler("OnMouseDown", function()
        background:SetCenterColor(0.018, 0.015, 0.014, 1)
        shadow:SetAlpha(0.35)
        label:SetColor(COLORS.emberBright:UnpackRGBA())
    end)
    button:SetHandler("OnMouseUp", function()
        background:SetCenterColor(primary and 0.32 or 0.08, primary and 0.10 or 0.07,
            primary and 0.045 or 0.065, 1)
        shadow:SetAlpha(1)
        label:SetColor(1, 1, 1, 1)
    end)
    button.label = label
    return button
end

local function ShowTooltip(control, text)
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 6, BOTTOMLEFT)
    SetTooltipText(InformationTooltip, text)
end

function OCP.HideOverwriteConfirmation()
    if OCP.overwriteModal then OCP.overwriteModal:SetHidden(true) end
    OCP.pendingOverwrite = nil
end

function OCP.ConfirmOverwriteConfirmation()
    local pending = OCP.pendingOverwrite
    if not pending then return end

    local confirmationType = pending.confirmationType
    local outfitIndex = pending.outfitIndex
    OCP.HideOverwriteConfirmation()

    if confirmationType == "capture" then
        OCP.ConfirmCapture(outfitIndex)
    elseif confirmationType == "draft" then
        OCP.SaveDraftConfirmed()
    end
end

function OCP.ShowOverwriteConfirmation(confirmationType, outfitIndex)
    if not OCP.overwriteModal or not OCP.window or OCP.window:IsHidden() then return end

    local outfitName = OCP.GetOutfitName(outfitIndex)
    local message
    if confirmationType == "capture" then
        message = string.format(
            "%s already has a saved Collection setup. Replace it with everything currently active?",
            outfitName)
    else
        message = string.format(
            "%s already has a saved Collection setup. Replace it with the settings currently shown?",
            outfitName)
    end

    OCP.pendingOverwrite = {
        confirmationType = confirmationType,
        outfitIndex = outfitIndex,
    }
    ClearTooltip(InformationTooltip)
    OCP.overwriteMessage:SetText(message)
    OCP.overwriteModal:SetHidden(false)
    OCP.overwriteModal:BringWindowToTop()
end

function OCP.CreateWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("OCPWindow")
    OCP.window = window
    window:SetDimensions(760, 744)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    -- Keep ESO's high-tier dropdown and tooltip top-level controls above this
    -- window. DL_OVERLAY here would outrank both despite their higher levels.
    window:SetDrawLayer(DL_CONTROLS)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(20)
    window:SetHidden(true)

    local backdrop = CreatePanel(window, "OCPWindowBackdrop",
        { 0.012, 0.016, 0.022, 0.985 }, { 0.38, 0.18, 0.11, 0.94 })
    backdrop:SetAnchorFill()
    CreateOutline(window, "OCPWindowOutline", 760, 744, 1,
        { 0.40, 0.20, 0.13, 0.96 })

    local header = CreatePanel(window, "OCPHeader", { 0.015, 0.022, 0.030, 0.995 })
    header:SetAnchor(TOPLEFT, window, TOPLEFT, 1, 1)
    header:SetAnchor(TOPRIGHT, window, TOPRIGHT, -1, 1)
    header:SetHeight(57)

    local brand = CreateLabel(header, "OCPBrand", "ZoFontGameBold", COLORS.emberBright)
    brand:SetAnchor(TOPLEFT, header, TOPLEFT, 18, 5)
    brand:SetText("FLAMECHASERS")

    local title = CreateLabel(header, "OCPTitle", "ZoFontWinH4", COLORS.text)
    title:SetAnchor(TOPLEFT, header, TOPLEFT, 18, 23)
    title:SetText("OUTFIT PROFILES")

    local tagline = CreateLabel(header, "OCPTagline", "ZoFontGameSmall", COLORS.muted)
    tagline:SetAnchor(LEFT, title, RIGHT, 20, 1)
    tagline:SetText("Collections styled to every outfit slot.")

    local close = WINDOW_MANAGER:CreateControl("OCPWindowClose", header, CT_BUTTON)
    close:SetDimensions(34, 34)
    close:SetAnchor(TOPRIGHT, header, TOPRIGHT, -10, 10)
    close:SetFont("ZoFontWinH2")
    close:SetText("X")
    close:SetNormalFontColor(COLORS.muted:UnpackRGBA())
    close:SetMouseOverFontColor(COLORS.emberBright:UnpackRGBA())
    close:SetPressedFontColor(1, 1, 1, 1)
    close:SetHandler("OnClicked", function() OCP.CloseWindow() end)

    local headerLine = WINDOW_MANAGER:CreateControl("OCPHeaderLine", window, CT_TEXTURE)
    headerLine:SetDimensions(758, 2)
    headerLine:SetAnchor(TOP, window, TOP, 0, 57)
    headerLine:SetColor(COLORS.emberSoft:UnpackRGBA())

    local section = CreateLabel(window, "OCPProfileSection", "ZoFontGameBold", COLORS.muted)
    section:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 69)
    section:SetText("OUTFIT PROFILE")

    local sectionLine = WINDOW_MANAGER:CreateControl("OCPProfileSectionLine", window, CT_TEXTURE)
    sectionLine:SetDimensions(568, 1)
    sectionLine:SetAnchor(LEFT, section, RIGHT, 12, 0)
    sectionLine:SetColor(0.42, 0.23, 0.17, 0.60)

    local profilePanel = CreatePanel(window, "OCPProfilePanel",
        { 0.025, 0.029, 0.036, 0.98 }, { 0.25, 0.20, 0.18, 0.85 })
    profilePanel:SetDimensions(712, 58)
    profilePanel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 91)
    CreateOutline(profilePanel, "OCPProfilePanelOutline", 712, 58, 1,
        { 0.27, 0.21, 0.18, 0.78 })

    local outfitLabel = CreateLabel(profilePanel, "OCPOutfitLabel", "ZoFontGameSmall", COLORS.muted)
    outfitLabel:SetDimensions(78, 34)
    outfitLabel:SetAnchor(LEFT, profilePanel, LEFT, 12, 0)
    outfitLabel:SetText("CONFIGURE")

    local outfitContainer, outfitCombo = CreateDropdown(profilePanel, "OCPOutfitDropdown", 318)
    OCP.outfitCombo = outfitCombo
    outfitContainer:SetAnchor(LEFT, outfitLabel, RIGHT, 3, 0)

    local active = CreateLabel(profilePanel, "OCPActiveOutfit", "ZoFontGameBold", COLORS.good)
    OCP.activeOutfitLabel = active
    active:SetDimensions(270, 22)
    active:SetAnchor(TOPLEFT, profilePanel, TOPLEFT, 430, 7)
    active:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    local status = CreateLabel(profilePanel, "OCPApplyStatus", "ZoFontGameSmall", COLORS.muted)
    OCP.applyStatusLabel = status
    status:SetDimensions(270, 21)
    status:SetAnchor(TOPLEFT, profilePanel, TOPLEFT, 430, 30)
    status:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    local headerCategory = CreateLabel(window, "OCPHeaderCategory", "ZoFontGameSmall", COLORS.dim)
    headerCategory:SetDimensions(210, 24)
    headerCategory:SetAnchor(TOPLEFT, window, TOPLEFT, 35, 157)
    headerCategory:SetText("COLLECTION CATEGORY")

    local headerChoice = CreateLabel(window, "OCPHeaderChoice", "ZoFontGameSmall", COLORS.dim)
    headerChoice:SetDimensions(470, 24)
    headerChoice:SetAnchor(LEFT, headerCategory, RIGHT, 7, 0)
    headerChoice:SetText("BEHAVIOR FOR THIS OUTFIT")

    OCP.rows = {}
    local previous = headerCategory
    for index, definition in ipairs(OCP.categoryDefinitions) do
        local row = WINDOW_MANAGER:CreateControl("OCPRow" .. index, window, CT_CONTROL)
        row:SetDimensions(712, 36)
        row:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, index == 1 and -11 or 0, 2)

        local rowPanel = CreatePanel(row, "OCPRowPanel" .. index,
            index % 2 == 0 and { 0.045, 0.047, 0.052, 0.94 }
                or { 0.026, 0.028, 0.033, 0.94 },
            { 0.12, 0.11, 0.105, 0.60 })
        rowPanel:SetAnchorFill()
        CreateOutline(row, "OCPRowOutline" .. index, 712, 36, 1,
            { 0.13, 0.115, 0.105, 0.58 })

        local modeBar = WINDOW_MANAGER:CreateControl("OCPRowMode" .. index, row, CT_TEXTURE)
        modeBar:SetDimensions(3, 34)
        modeBar:SetAnchor(LEFT, row, LEFT, 0, 0)
        modeBar:SetColor(COLORS.dim:UnpackRGBA())

        local label = CreateLabel(row, "OCPRowLabel" .. index, "ZoFontGame", COLORS.text)
        label:SetDimensions(201, 34)
        label:SetAnchor(LEFT, row, LEFT, 14, 0)
        label:SetText(definition.label)

        local container, combo = CreateDropdown(row, "OCPRowDropdown" .. index, 477)
        container:SetAnchor(LEFT, label, RIGHT, 8, 0)
        OCP.rows[index] = {
            definition = definition,
            combo = combo,
            container = container,
            modeBar = modeBar,
        }
        previous = row
    end

    local help = CreateLabel(window, "OCPHelpText", "ZoFontGameSmall", COLORS.muted)
    help:SetDimensions(712, 22)
    help:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, 4)
    help:SetText("NOT TRACKED leaves that category alone. UNEQUIP / NONE removes its active collectible.")

    local capture = CreateActionButton(window, "OCPCaptureButton", "CAPTURE CURRENT", 194, false)
    capture:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 24, -18)
    capture:SetHandler("OnClicked", function()
        OCP.CaptureCurrent(OCP.selectedOutfitIndex)
    end)
    capture.tooltipText = "Copies your current supported Collections into this unsaved draft."

    local save = CreateActionButton(window, "OCPSaveButton", "SAVE PROFILE", 170, true)
    save:SetAnchor(LEFT, capture, RIGHT, 12, 0)
    save:SetHandler("OnClicked", function() OCP.RequestSaveDraft() end)

    local apply = CreateActionButton(window, "OCPApplyButton", "PREVIEW DRAFT", 170, false)
    apply:SetAnchor(LEFT, save, RIGHT, 12, 0)
    apply:SetHandler("OnClicked", function()
        OCP.ApplyOutfitProfile(OCP.selectedOutfitIndex, "draft preview", OCP.GetDraftProfile())
    end)
    apply.tooltipText = "Applies the displayed draft once without saving it."

    local delayPanel = CreatePanel(window, "OCPDelayPanel",
        { 0.025, 0.028, 0.034, 0.98 }, { 0.28, 0.24, 0.22, 0.90 })
    delayPanel:SetDimensions(142, 40)
    delayPanel:SetAnchor(LEFT, apply, RIGHT, 12, 0)
    CreateOutline(delayPanel, "OCPDelayPanelOutline", 142, 40, 1,
        { 0.35, 0.31, 0.29, 0.90 })

    local delayLabel = CreateLabel(delayPanel, "OCPDelayLabel", "ZoFontGameSmall", COLORS.muted)
    delayLabel:SetDimensions(66, 34)
    delayLabel:SetAnchor(LEFT, delayPanel, LEFT, 9, 0)
    delayLabel:SetText("DELAY (S)")

    local delayEdit = CreateControlFromVirtual("OCPDelayEdit", delayPanel, "ZO_DefaultEditForBackdrop")
    OCP.delayEdit = delayEdit
    delayEdit:SetDimensions(55, 30)
    delayEdit:ClearAnchors()
    delayEdit:SetAnchor(RIGHT, delayPanel, RIGHT, -7, 0)
    delayEdit:SetFont("ZoFontGame")
    delayEdit:SetMaxInputChars(4)
    delayEdit:SetTextType(TEXT_TYPE_ALL)

    local function CommitDelay()
        local seconds = OCP.SetCollectibleDelaySeconds(delayEdit:GetText())
        delayEdit:SetText(string.format("%.1f", seconds))
    end
    delayEdit:SetHandler("OnFocusLost", CommitDelay)
    delayEdit:SetHandler("OnEnter", function(control) control:LoseFocus() end)
    delayEdit:SetHandler("OnMouseEnter", function(control)
        ShowTooltip(control, "Seconds between Collection actions. The safe default is 2.5; allowed range is 0.5–10.0.")
    end)
    delayEdit:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    -- This addon-owned confirmation overlay intentionally does not call ESO's
    -- global dialog manager. It therefore cannot release cursor/UI mode while
    -- the Outfit Profiles window remains open.
    local overwriteModal = WINDOW_MANAGER:CreateTopLevelWindow("OCPOverwriteModal")
    OCP.overwriteModal = overwriteModal
    overwriteModal:SetDimensions(760, 744)
    overwriteModal:SetAnchor(CENTER, window, CENTER, 0, 0)
    overwriteModal:SetDrawLayer(DL_OVERLAY)
    overwriteModal:SetDrawTier(DT_HIGH)
    overwriteModal:SetDrawLevel(110)
    overwriteModal:SetMouseEnabled(true)
    overwriteModal:SetClampedToScreen(true)
    overwriteModal:SetHidden(true)
    overwriteModal:SetHandler("OnMouseDown", function() end)

    local overwriteShade = CreatePanel(overwriteModal, "OCPOverwriteShade",
        { 0.002, 0.003, 0.005, 0.76 })
    overwriteShade:SetAnchorFill()

    local overwritePanel = CreatePanel(overwriteModal, "OCPOverwritePanel",
        { 0.014, 0.017, 0.022, 1 }, { 0.48, 0.24, 0.15, 1 })
    overwritePanel:SetDimensions(520, 230)
    overwritePanel:SetAnchor(CENTER, overwriteModal, CENTER, 0, 0)
    CreateOutline(overwritePanel, "OCPOverwriteOutline", 520, 230, 1,
        { 0.72, 0.34, 0.19, 1 })

    local overwriteHeader = CreatePanel(overwritePanel, "OCPOverwriteHeader",
        { 0.026, 0.025, 0.028, 1 })
    overwriteHeader:SetAnchor(TOPLEFT, overwritePanel, TOPLEFT, 1, 1)
    overwriteHeader:SetAnchor(TOPRIGHT, overwritePanel, TOPRIGHT, -1, 1)
    overwriteHeader:SetHeight(52)

    local overwriteTitle = CreateLabel(overwriteHeader, "OCPOverwriteTitle",
        "ZoFontWinH3", COLORS.text)
    overwriteTitle:SetAnchor(LEFT, overwriteHeader, LEFT, 20, 0)
    overwriteTitle:SetText("OVERWRITE PROFILE?")

    local overwriteLine = WINDOW_MANAGER:CreateControl("OCPOverwriteHeaderLine",
        overwritePanel, CT_TEXTURE)
    overwriteLine:SetDimensions(518, 2)
    overwriteLine:SetAnchor(TOP, overwritePanel, TOP, 0, 52)
    overwriteLine:SetColor(COLORS.emberBright:UnpackRGBA())

    local overwriteMessage = CreateLabel(overwritePanel, "OCPOverwriteMessage",
        "ZoFontGame", COLORS.muted)
    OCP.overwriteMessage = overwriteMessage
    overwriteMessage:SetDimensions(472, 82)
    overwriteMessage:SetAnchor(TOPLEFT, overwritePanel, TOPLEFT, 24, 72)
    overwriteMessage:SetVerticalAlignment(TEXT_ALIGN_TOP)
    overwriteMessage:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local overwriteCancel = CreateActionButton(overwritePanel,
        "OCPOverwriteCancel", "CANCEL", 210, false)
    overwriteCancel:SetAnchor(BOTTOMLEFT, overwritePanel, BOTTOMLEFT, 24, -20)
    overwriteCancel:SetHandler("OnClicked", function() OCP.HideOverwriteConfirmation() end)

    local overwriteConfirm = CreateActionButton(overwritePanel,
        "OCPOverwriteConfirm", "OVERWRITE", 210, true)
    overwriteConfirm:SetAnchor(BOTTOMRIGHT, overwritePanel, BOTTOMRIGHT, -24, -20)
    overwriteConfirm:SetHandler("OnClicked", function() OCP.ConfirmOverwriteConfirmation() end)

    window:SetHandler("OnShow", function()
        OCP.activatedCursorForWindow = not IsGameCameraUIModeActive()
        if OCP.activatedCursorForWindow then SetGameCameraUIMode(true) end
        OCP.selectedOutfitIndex = OCP.GetEquippedOutfitIndex()
        OCP.LoadDraft(OCP.selectedOutfitIndex)
        OCP.RefreshWindow()
    end)
    window:SetHandler("OnHide", function()
        OCP.HideOverwriteConfirmation()
        if OCP.activatedCursorForWindow and IsGameCameraUIModeActive() then
            SetGameCameraUIMode(false)
        end
        OCP.activatedCursorForWindow = false
    end)
end

function OCP.CloseWindow()
    if OCP.window and not OCP.window:IsHidden() then OCP.window:SetHidden(true) end
end

function OCP.RefreshOutfitDropdown()
    local combo = OCP.outfitCombo
    combo:ClearItems()
    for index = 0, OCP.GetNumOutfits() do
        local outfitIndex = index
        local name = OCP.GetOutfitName(index)
        combo:AddItem(combo:CreateItemEntry(name, function()
            OCP.selectedOutfitIndex = outfitIndex
            OCP.LoadDraft(outfitIndex)
            OCP.RefreshWindow()
        end))
    end
    combo:SetSelectedItemText(OCP.GetOutfitName(OCP.selectedOutfitIndex or 0))
end

function OCP.RefreshCategoryRow(row)
    local combo = row.combo
    local definition = row.definition
    local setting = OCP.GetDraftSetting(definition.key)
    combo:ClearItems()

    combo:AddItem(combo:CreateItemEntry("— Not Tracked —", function()
        OCP.SetDraftSetting(definition.key, "keep")
        OCP.RefreshCategoryRow(row)
        OCP.RefreshStatus()
    end))
    combo:AddItem(combo:CreateItemEntry("— Unequip / None —", function()
        OCP.SetDraftSetting(definition.key, "none")
        OCP.RefreshCategoryRow(row)
        OCP.RefreshStatus()
    end))

    local selectedText = setting.mode == "none" and "— Unequip / None —" or "— Not Tracked —"
    for _, collectible in ipairs(OCP.GetCollectibles(definition)) do
        local id = collectible.id
        local name = collectible.name
        combo:AddItem(combo:CreateItemEntry(name, function()
            OCP.SetDraftSetting(definition.key, "item", id)
            OCP.RefreshCategoryRow(row)
            OCP.RefreshStatus()
        end))
        if setting.mode == "item" and tonumber(setting.collectibleId) == id then
            selectedText = name
        end
    end
    combo:SetSelectedItemText(selectedText)

    if setting.mode == "item" then
        row.modeBar:SetColor(COLORS.emberBright:UnpackRGBA())
    elseif setting.mode == "none" then
        row.modeBar:SetColor(COLORS.warning:UnpackRGBA())
    else
        row.modeBar:SetColor(COLORS.dim:UnpackRGBA())
    end
end

function OCP.RefreshStatus()
    if OCP.activeOutfitLabel then
        OCP.activeOutfitLabel:SetText("ACTIVE  •  " .. OCP.GetOutfitName(OCP.GetEquippedOutfitIndex()))
    end
    if not OCP.applyStatusLabel then return end

    local state = OCP.applyState or "idle"
    local completed = tonumber(OCP.applyCompleted) or 0
    local total = tonumber(OCP.applyTotal) or 0
    local detail = OCP.applyDetail and ("  •  " .. OCP.applyDetail) or ""
    local text
    local color = COLORS.muted

    if state == "applying" then
        text = string.format("APPLYING  %d/%d%s", completed, total, detail)
        color = COLORS.emberBright
    elseif state == "waiting" then
        text = string.format("WAITING  %d/%d%s", completed, total, detail)
        color = COLORS.warning
    elseif state == "paused" then
        text = "PAUSED BY LOADING  •  resumes automatically"
        color = COLORS.warning
    elseif state == "complete" then
        text = "PROFILE APPLIED  •  idle until outfit changes"
        color = COLORS.good
    elseif state == "warning" then
        text = "FINISHED WITH A WARNING" .. detail
        color = COLORS.warning
    elseif state == "untracked" then
        text = "NO TRACKED ACTIONS  •  cosmetics left unchanged"
        color = COLORS.dim
    else
        text = "READY  •  waiting for an outfit change"
    end

    if OCP.draftDirty then text = "UNSAVED DRAFT  •  " .. text end
    OCP.applyStatusLabel:SetText(text)
    OCP.applyStatusLabel:SetColor(color:UnpackRGBA())
end

function OCP.RefreshWindow()
    if not OCP.window or OCP.window:IsHidden() then return end
    OCP.RefreshOutfitDropdown()
    for _, row in ipairs(OCP.rows) do OCP.RefreshCategoryRow(row) end
    OCP.RefreshStatus()
    if OCP.delayEdit and not OCP.delayEdit:HasFocus() then
        OCP.delayEdit:SetText(string.format("%.1f", tonumber(OCP.saved.collectibleDelaySeconds) or 2.5))
    end
end

function OCP.ToggleWindow()
    if not OCP.window then return end
    if OCP.window:IsHidden() then
        OCP.window:SetHidden(false)
    else
        OCP.CloseWindow()
    end
end
