local OCP = OutfitCollectionProfiles

local COLORS = {
    title = ZO_ColorDef:New("F05A28"),
    text = ZO_ColorDef:New("E8E8E8"),
    muted = ZO_ColorDef:New("A0A0A0"),
    good = ZO_ColorDef:New("88E28A"),
}

local function CreateLabel(parent, name, font, color)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor((color or COLORS.text):UnpackRGBA())
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function CreateButton(parent, name, text, width)
    local button = CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    button:SetDimensions(width or 150, 28)
    button:SetText(text)
    return button
end

local function CreateDropdown(parent, name, width)
    local container = CreateControlFromVirtual(name, parent, "ZO_ComboBox")
    container:SetDimensions(width, 32)
    local combo = ZO_ComboBox_ObjectFromContainer(container)
    combo:SetSortsItems(false)
    combo:SetFont("ZoFontGame")
    combo:SetSpacing(4)
    return container, combo
end

function OCP.CreateWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("OCPWindow")
    OCP.window = window
    window:SetDimensions(700, 690)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("OCPWindowBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.025, 0.035, 0.05, 0.97)
    backdrop:SetEdgeColor(0.94, 0.35, 0.16, 0.85)
    backdrop:SetEdgeTexture(nil, 1, 1, 2)

    local title = CreateLabel(window, "OCPWindowTitle", "ZoFontWinH1", COLORS.title)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 14)
    title:SetText("Flamechasers Outfit Profiles")

    local subtitle = CreateLabel(window, "OCPWindowSubtitle", "ZoFontGameSmall", COLORS.muted)
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 1, 0)
    subtitle:SetText("Automatically links Collections appearance, mount and pet choices to outfit slots")

    local close = WINDOW_MANAGER:CreateControl("OCPWindowClose", window, CT_BUTTON)
    close:SetDimensions(28, 28)
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 12)
    close:SetFont("ZoFontWinH2")
    close:SetText("×")
    close:SetHandler("OnClicked", function() OCP.CloseWindow() end)

    local outfitLabel = CreateLabel(window, "OCPOutfitLabel", "ZoFontWinH4", COLORS.text)
    outfitLabel:SetDimensions(120, 32)
    outfitLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 72)
    outfitLabel:SetText("Configure:")

    local outfitContainer, outfitCombo = CreateDropdown(window, "OCPOutfitDropdown", 380)
    OCP.outfitCombo = outfitCombo
    outfitContainer:SetAnchor(LEFT, outfitLabel, RIGHT, 8, 0)

    local active = CreateLabel(window, "OCPActiveOutfit", "ZoFontGameSmall", COLORS.good)
    OCP.activeOutfitLabel = active
    active:SetDimensions(140, 32)
    active:SetAnchor(LEFT, outfitContainer, RIGHT, 10, 0)

    local headerCategory = CreateLabel(window, "OCPHeaderCategory", "ZoFontGameBold", COLORS.muted)
    headerCategory:SetDimensions(205, 28)
    headerCategory:SetAnchor(TOPLEFT, outfitLabel, BOTTOMLEFT, 0, 15)
    headerCategory:SetText("COLLECTION CATEGORY")

    local headerChoice = CreateLabel(window, "OCPHeaderChoice", "ZoFontGameBold", COLORS.muted)
    headerChoice:SetDimensions(420, 28)
    headerChoice:SetAnchor(LEFT, headerCategory, RIGHT, 6, 0)
    headerChoice:SetText("FOR THIS OUTFIT")

    OCP.rows = {}
    local previous = headerCategory
    for index, definition in ipairs(OCP.categoryDefinitions) do
        local row = WINDOW_MANAGER:CreateControl("OCPRow" .. index, window, CT_CONTROL)
        row:SetDimensions(650, 38)
        row:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, index == 1 and 2 or 0)

        if index % 2 == 0 then
            local stripe = WINDOW_MANAGER:CreateControl("OCPRowStripe" .. index, row, CT_BACKDROP)
            stripe:SetAnchorFill()
            stripe:SetCenterColor(1, 1, 1, 0.025)
            stripe:SetEdgeColor(0, 0, 0, 0)
        end

        local label = CreateLabel(row, "OCPRowLabel" .. index, "ZoFontGame", COLORS.text)
        label:SetDimensions(200, 34)
        label:SetAnchor(LEFT, row, LEFT, 4, 0)
        label:SetText(definition.label)

        local container, combo = CreateDropdown(row, "OCPRowDropdown" .. index, 420)
        container:SetAnchor(LEFT, label, RIGHT, 10, 0)
        OCP.rows[index] = { definition = definition, combo = combo, container = container }
        previous = row
    end

    local capture = CreateButton(window, "OCPCaptureButton", "Capture Current Appearance", 205)
    capture:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 24, -20)
    capture:SetHandler("OnClicked", function()
        OCP.CaptureCurrent(OCP.selectedOutfitIndex)
    end)

    local save = CreateButton(window, "OCPSaveButton", "Save Profile", 145)
    save:SetAnchor(LEFT, capture, RIGHT, 10, 0)
    save:SetHandler("OnClicked", function() OCP.RequestSaveDraft() end)

    local apply = CreateButton(window, "OCPApplyButton", "Apply Draft", 145)
    apply:SetAnchor(LEFT, save, RIGHT, 10, 0)
    apply:SetHandler("OnClicked", function()
        OCP.ApplyOutfitProfile(OCP.selectedOutfitIndex, "draft preview", OCP.GetDraftProfile())
    end)

    local delayLabel = CreateLabel(window, "OCPDelayLabel", "ZoFontGameSmall", COLORS.muted)
    delayLabel:SetDimensions(48, 28)
    delayLabel:SetAnchor(LEFT, apply, RIGHT, 8, 0)
    delayLabel:SetText("Delay:")

    local delayEdit = CreateControlFromVirtual("OCPDelayEdit", window, "ZO_DefaultEditForBackdrop")
    OCP.delayEdit = delayEdit
    delayEdit:SetDimensions(58, 28)
    delayEdit:ClearAnchors()
    delayEdit:SetAnchor(LEFT, delayLabel, RIGHT, 2, 0)
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
        InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, BOTTOMLEFT)
        SetTooltipText(InformationTooltip, "Seconds between Collection actions. ESO has a shared collectible cooldown; 2.5 seconds is the safe default. Allowed range: 0.5–10.0 seconds.")
    end)
    delayEdit:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    local help = CreateLabel(window, "OCPHelpText", "ZoFontGameSmall", COLORS.muted)
    help:SetDimensions(650, 25)
    help:SetAnchor(BOTTOMLEFT, capture, TOPLEFT, 0, -4)
    help:SetText("Capture fills a draft; Save commits it. Delay controls the pause between Collection actions (default 2.5s).")

    window:SetHandler("OnShow", function()
        OCP.activatedCursorForWindow = not IsGameCameraUIModeActive()
        if OCP.activatedCursorForWindow then SetGameCameraUIMode(true) end
        OCP.selectedOutfitIndex = OCP.GetEquippedOutfitIndex()
        OCP.LoadDraft(OCP.selectedOutfitIndex)
        OCP.RefreshWindow()
    end)
    window:SetHandler("OnHide", function()
        if OCP.activatedCursorForWindow and IsGameCameraUIModeActive() then
            SetGameCameraUIMode(false)
        end
        OCP.activatedCursorForWindow = false
    end)
end

function OCP.CloseWindow()
    if OCP.window and not OCP.window:IsHidden() then
        OCP.window:SetHidden(true)
    end
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

    combo:AddItem(combo:CreateItemEntry("— Keep Current —", function()
        OCP.SetDraftSetting(definition.key, "keep")
        OCP.RefreshCategoryRow(row)
    end))
    combo:AddItem(combo:CreateItemEntry("— Remove / None —", function()
        OCP.SetDraftSetting(definition.key, "none")
        OCP.RefreshCategoryRow(row)
    end))

    local selectedText = setting.mode == "none" and "— Remove / None —" or "— Keep Current —"
    for _, collectible in ipairs(OCP.GetCollectibles(definition)) do
        local id = collectible.id
        local name = collectible.name
        combo:AddItem(combo:CreateItemEntry(name, function()
            OCP.SetDraftSetting(definition.key, "item", id)
            OCP.RefreshCategoryRow(row)
        end))
        if setting.mode == "item" and tonumber(setting.collectibleId) == id then
            selectedText = name
        end
    end
    combo:SetSelectedItemText(selectedText)
end

function OCP.RefreshStatus()
    if not OCP.activeOutfitLabel then return end
    OCP.activeOutfitLabel:SetText("Active: " .. OCP.GetOutfitName(OCP.GetEquippedOutfitIndex()))
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
