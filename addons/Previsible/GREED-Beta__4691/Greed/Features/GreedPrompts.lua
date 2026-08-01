Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local T = Internal.T
local DEFAULT_FONT_NAME = Internal.DEFAULT_FONT_NAME
local DEFAULT_TEXT_PROMPT_DURATION_MS = Internal.DEFAULT_TEXT_PROMPT_DURATION_MS
local DROP_TEXT_FADE_IN_MS = Internal.DROP_TEXT_FADE_IN_MS
local DROP_TEXT_FADE_OUT_MS = Internal.DROP_TEXT_FADE_OUT_MS
local DROP_TEXT_ALERT_STAGGER_MS = Internal.DROP_TEXT_ALERT_STAGGER_MS
local SPAULDER_OF_RUIN_ITEM_LINK = Internal.SPAULDER_OF_RUIN_ITEM_LINK
local SPAULDER_AURA_OF_PRIDE_ABILITY_ID = Internal.SPAULDER_AURA_OF_PRIDE_ABILITY_ID
local SPAULDER_AURA_DURATION_MS = Internal.SPAULDER_AURA_DURATION_MS
local SPAULDER_AURA_REVALIDATE_DELAY_MS = 500
local SPAULDER_USER_TOGGLE_WINDOW_MS = 3000
local SPAULDER_FADE_TOGGLE_CONFIRM_MS = 150
local SPAULDER_TRANSITION_SETTLE_MS = 2000
local SPAULDER_RELOAD_STATE_MAX_AGE_SECONDS = 120
local TEXT_PROMPT_SIZE_OPTIONS = Internal.TEXT_PROMPT_SIZE_OPTIONS
local TEXT_PROMPT_SIZE_BY_KEY = Internal.TEXT_PROMPT_SIZE_BY_KEY
local TEXT_PROMPT_SIZE_BY_LABEL = Internal.TEXT_PROMPT_SIZE_BY_LABEL
local TEXT_PROMPT_COLOR_BY_KEY = Internal.TEXT_PROMPT_COLOR_BY_KEY
local TEXT_PROMPT_COLOR_BY_LABEL = Internal.TEXT_PROMPT_COLOR_BY_LABEL
local PASTEL_RAINBOW_HEX = Internal.PASTEL_RAINBOW_HEX
local FONT_OPTION_BY_LABEL = Internal.FONT_OPTION_BY_LABEL
local COLORS = Internal.COLORS
local CallControlMethod = Internal.CallControlMethod
local GetControlDimension = Internal.GetControlDimension
local GetUtf8CharacterByteLength = Internal.GetUtf8CharacterByteLength
local CreatePromptDragSurface = Internal.CreatePromptDragSurface
local SetBackdropStyle = Internal.SetBackdropStyle
local SafeAnnounce = Internal.SafeAnnounce
local BuildFontString = Internal.BuildFontString

function Greed:GetPromptSettings(promptKey)
    self:InitializeTextPromptSettings()
    promptKey = promptKey == "spaulder" and "spaulder" or "drop"
    return self.savedVars.textPrompts[promptKey]
end

function Greed:IsPromptEnabled(promptKey)
    local settings = self:GetPromptSettings(promptKey)
    return settings and settings.enabled ~= false
end

function Greed:SetPromptEnabled(promptKey, enabled)
    local settings = self:GetPromptSettings(promptKey)
    settings.enabled = enabled ~= false
    if promptKey == "spaulder" then
        self.savedVars.textPrompts.spaulderTextEnabled = settings.enabled
    else
        self.savedVars.textPrompts.dropTextEnabled = settings.enabled
    end
    self:RefreshTextPromptMovement()
    self:ApplyTextPromptFont()
    self:RefreshSpaulderTextPrompt()
end

function Greed:SetPromptLocked(promptKey, locked)
    local settings = self:GetPromptSettings(promptKey)
    settings.locked = locked == true
    local dropSettings = self:GetPromptSettings("drop")
    local spaulderSettings = self:GetPromptSettings("spaulder")
    self.savedVars.textPrompts.locked = dropSettings.locked == true and spaulderSettings.locked == true
    self:RefreshTextPromptMovement()
    self:ApplyTextPromptFont()
    self:RefreshSpaulderTextPrompt()
end

function Greed:SetPromptFontByLabel(promptKey, label)
    local settings = self:GetPromptSettings(promptKey)
    settings.fontName = FONT_OPTION_BY_LABEL[label] and label or DEFAULT_FONT_NAME
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshDropOptionsState()
end

function Greed:SetPromptSizeByLabel(promptKey, label)
    local settings = self:GetPromptSettings(promptKey)
    local sizeOption = TEXT_PROMPT_SIZE_BY_LABEL[label] or TEXT_PROMPT_SIZE_BY_KEY.Normal
    settings.fontSize = sizeOption and sizeOption.key or "Normal"
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshDropOptionsState()
end

function Greed:SetPromptColorByLabel(promptKey, label)
    local settings = self:GetPromptSettings(promptKey)
    local colorOption = TEXT_PROMPT_COLOR_BY_LABEL[label] or TEXT_PROMPT_COLOR_BY_KEY.White
    settings.colorName = colorOption.key
    settings.color = self:CopyTable(colorOption.color)
    settings.rainbow = colorOption.rainbow == true
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshDropOptionsState()
end

function Greed:SetPromptStyleFlag(promptKey, flagName, value)
    local settings = self:GetPromptSettings(promptKey)
    settings[flagName] = value == true
    if flagName == "rainbow" then
        if value == true then
            settings.colorName = "Rainbow"
        elseif settings.colorName == "Rainbow" then
            settings.colorName = promptKey == "spaulder" and "Dark Red" or "White"
            local colorOption = TEXT_PROMPT_COLOR_BY_KEY[settings.colorName] or TEXT_PROMPT_COLOR_BY_KEY.White
            settings.color = self:CopyTable(colorOption.color)
        end
    end
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshDropOptionsState()
end

function Greed:GetPromptSizeData(promptKey)
    local settings = self:GetPromptSettings(promptKey)
    return TEXT_PROMPT_SIZE_BY_KEY[settings.fontSize] or TEXT_PROMPT_SIZE_BY_KEY.Normal or TEXT_PROMPT_SIZE_OPTIONS[3]
end

function Greed:GetTextPromptFont(promptKeyOrSize, sizeOrBold, boldArg)
    local promptKey = "drop"
    local size
    local bold

    if type(promptKeyOrSize) == "string" then
        promptKey = promptKeyOrSize == "spaulder" and "spaulder" or "drop"
        size = sizeOrBold
        bold = boldArg
    else
        -- Legacy call style: GetTextPromptFont(size, bold)
        size = promptKeyOrSize
        bold = sizeOrBold
    end

    local settings = self:GetPromptSettings(promptKey)
    local sizeData = self:GetPromptSizeData(promptKey)
    local fontSize = tonumber(size) or sizeData.size or 22
    return BuildFontString(settings.fontName, fontSize, "soft-shadow-thin")
end

function Greed:GetPromptColor(promptKey)
    local settings = self:GetPromptSettings(promptKey)
    local color = settings.color
    if type(color) ~= "table" or #color < 4 then
        local colorOption = TEXT_PROMPT_COLOR_BY_KEY[settings.colorName] or TEXT_PROMPT_COLOR_BY_KEY.White
        color = colorOption.color
    end
    return color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1
end

function Greed:HexToColorMarkup(hex)
    -- ESO color markup uses six hex digits. Adding alpha left stray hex text visible.
    return "|c" .. tostring(hex or "FFFFFF")
end

function Greed:ApplyPastelRainbowToPlainText(text)
    text = tostring(text or "")
    if text == "" then return text end

    local result = {}
    local colorIndex = 1
    local palette = PASTEL_RAINBOW_HEX
    local paletteCount = #palette

    local function appendRainbowPlain(plainText)
        local index = 1
        while index <= #plainText do
            local firstByte = plainText:byte(index)
            local charLength = GetUtf8CharacterByteLength(firstByte)
            local char = plainText:sub(index, math.min(#plainText, index + charLength - 1))
            if char == " " or char == "\n" or char == "\t" then
                table.insert(result, char)
            else
                local hex = palette[colorIndex] or "FFFFFF"
                table.insert(result, "|c" .. hex .. char .. "|r")
                colorIndex = colorIndex + 1
                if colorIndex > paletteCount then colorIndex = 1 end
            end
            index = index + charLength
        end
    end

    local index = 1
    while index <= #text do
        local coloredStart, coloredEnd = text:find("|c%x%x%x%x%x%x|H.-|h.-|h|r", index)
        local coloredStart8, coloredEnd8 = text:find("|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r", index)
        local linkStart, linkEnd = text:find("|H.-|h.-|h", index)
        local textureStart, textureEnd = text:find("|t.-|t", index)
        local startPos, endPos

        if coloredStart8 and (not coloredStart or coloredStart8 < coloredStart) then
            coloredStart, coloredEnd = coloredStart8, coloredEnd8
        end

        if coloredStart and (not linkStart or coloredStart <= linkStart) then
            startPos, endPos = coloredStart, coloredEnd
        elseif linkStart then
            startPos, endPos = linkStart, linkEnd
        end
        if textureStart and (not startPos or textureStart < startPos) then
            startPos, endPos = textureStart, textureEnd
        end

        if not startPos then
            appendRainbowPlain(text:sub(index))
            break
        end

        if startPos > index then
            appendRainbowPlain(text:sub(index, startPos - 1))
        end

        table.insert(result, text:sub(startPos, endPos))
        index = endPos + 1
    end

    return table.concat(result)
end

function Greed:FormatPromptText(promptKey, text)
    local settings = self:GetPromptSettings(promptKey)
    if settings.rainbow == true or settings.colorName == "Rainbow" then
        return self:ApplyPastelRainbowToPlainText(text)
    end
    return text
end

function Greed:SetLabelUnderline(label, enabled, baseName)
    if label and label.greedUnderline then
        label.greedUnderline:SetHidden(true)
    end
end

function Greed:ApplyPromptFormattingToLabel(promptKey, label, baseName)
    if not label then return end
    local settings = self:GetPromptSettings(promptKey)
    local sizeData = self:GetPromptSizeData(promptKey)
    local fontSize = sizeData.size or 36
    label:SetFont(self:GetTextPromptFont(promptKey, fontSize, settings.bold == true))
    local r, g, b, a = self:GetPromptColor(promptKey)
    label:SetColor(r, g, b, a)
    label:SetAlpha(1)
    if type(label.SetDimensions) == "function" then
        local fallbackWidth = promptKey == "spaulder" and 680 or 1480
        local width = GetControlDimension(label, "GetWidth", fallbackWidth)
        label:SetDimensions(width, math.max(34, fontSize + 16))
    end
    self:SetLabelUnderline(label, false, baseName)
end

function Greed:ApplyTextPromptFont()
    self:InitializeTextPromptSettings()

    if self.textPromptControls then
        for _, label in ipairs(self.textPromptControls.labels or {}) do
            self:ApplyPromptFormattingToLabel("drop", label)
        end
        if self.textPromptControls.previewLabel then
            self:ApplyPromptFormattingToLabel("drop", self.textPromptControls.previewLabel, "GreedDropTextPromptPreview")
            self.textPromptControls.previewLabel:SetText(self:FormatPromptText("drop", T("[Pillager's Restoration Staff] - Infused has dropped")))
        end
    end

    if self.spaulderPromptControls then
        if self.spaulderPromptControls.label then
            self:ApplyPromptFormattingToLabel("spaulder", self.spaulderPromptControls.label, "GreedSpaulderPromptActive")
            self.spaulderPromptControls.label:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
        end
        if self.spaulderPromptControls.previewLabel then
            self:ApplyPromptFormattingToLabel("spaulder", self.spaulderPromptControls.previewLabel, "GreedSpaulderPromptPreview")
            self.spaulderPromptControls.previewLabel:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
        end
    end

    if self.fontDebug then
        local dropSettings = self:GetPromptSettings("drop")
        local spaulderSettings = self:GetPromptSettings("spaulder")
        SafeAnnounce("Greed font debug: Drop Text font " .. tostring(dropSettings.fontName) .. " -> " .. tostring(self:GetTextPromptFont("drop")))
        SafeAnnounce("Greed font debug: Spaulder Text font " .. tostring(spaulderSettings.fontName) .. " -> " .. tostring(self:GetTextPromptFont("spaulder")))
    end
end

function Greed:CreatePromptMoveHandle(parent, baseName)
    if not WINDOW_MANAGER or not parent or not baseName then return nil end

    -- Keep the internal move handle for the existing movement wiring, but remove the
    -- visible hamburger/grip art. The prompt boxes themselves are draggable when unlocked.
    local handle = WINDOW_MANAGER:CreateControl(baseName .. "MoveHandle", parent, CT_CONTROL)
    handle:SetDimensions(1, 1)
    handle:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    handle:SetMouseEnabled(false)
    handle:SetHidden(true)
    CallControlMethod(handle, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(handle, "SetDrawTier", DT_HIGH)
    CallControlMethod(handle, "SetDrawLevel", 2200)

    return handle
end

function Greed:MakePromptPreviewMovable(promptKey, window, handle, positionKey, dragSurface)
    if not window then return end

    local isMoving = false
    local isStopping = false

    local function canMovePrompt()
        self:InitializeTextPromptSettings()
        local settings = self:GetPromptSettings(promptKey)
        return settings.enabled ~= false and settings.locked ~= true
    end

    local function startPromptMovement(button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if not canMovePrompt() then return end
        if isMoving == true then return end

        window:SetMouseEnabled(true)
        CallControlMethod(window, "SetClampedToScreen", true)
        isMoving = self:StartMovingControl(window) == true
    end

    local function stopPromptMovement(savePosition)
        if isMoving ~= true then
            CallControlMethod(window, "SetMovable", false)
            return
        end

        if isStopping == true then return end
        isStopping = true
        self:StopMovingControl(window)
        isMoving = false
        isStopping = false

        if savePosition ~= false then
            self:SaveWindowPosition(window, positionKey)
        end
    end

    if handle then
        handle:SetHandler("OnMouseDown", function(_, button)
            startPromptMovement(button)
        end)

        handle:SetHandler("OnMouseUp", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            stopPromptMovement(true)
        end)
    end

    window:SetHandler("OnMouseDown", function(_, button)
        startPromptMovement(button)
    end)

    window:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        stopPromptMovement(true)
    end)

    if dragSurface then
        dragSurface:SetHandler("OnMouseDown", function(_, button)
            startPromptMovement(button)
        end)

        dragSurface:SetHandler("OnMouseUp", function(_, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            stopPromptMovement(true)
        end)
    end

    window:SetHandler("OnMoveStop", function()
        stopPromptMovement(true)
    end)

    window:SetHandler("OnHide", function()
        stopPromptMovement(false)
    end)
end

function Greed:SetPromptPreviewDragState(controls, canDrag)
    if not controls then return end

    canDrag = canDrag == true
    if controls.window then
        controls.window:SetMouseEnabled(canDrag)
        CallControlMethod(controls.window, "SetMovable", canDrag)
        if canDrag then
            CallControlMethod(controls.window, "SetDrawLayer", DL_OVERLAY)
            CallControlMethod(controls.window, "SetDrawTier", DT_HIGH)
            CallControlMethod(controls.window, "SetDrawLevel", 2100)
            CallControlMethod(controls.window, "BringWindowToTop")
        end
    end
    if controls.previewBackdrop then
        controls.previewBackdrop:SetMouseEnabled(false)
    end
    if controls.previewLabel then
        controls.previewLabel:SetMouseEnabled(false)
    end
    if controls.label then
        controls.label:SetMouseEnabled(false)
    end
    for _, label in ipairs(controls.labels or {}) do
        if label then
            label:SetMouseEnabled(false)
        end
    end
    if controls.moveHandle then
        controls.moveHandle:SetHidden(true)
        controls.moveHandle:SetMouseEnabled(false)
    end
    if controls.dragSurface then
        controls.dragSurface:SetHidden(not canDrag)
        controls.dragSurface:SetMouseEnabled(canDrag)
        if canDrag then
            CallControlMethod(controls.dragSurface, "BringWindowToTop")
        end
    end
end

function Greed:CreateTextPromptControls()
    if self.textPromptControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedDropTextPromptWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(1480, 160)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, 210)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetClampedToScreen", true)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 600)

    local previewBackdrop = WINDOW_MANAGER:CreateControl("GreedDropTextPromptPreviewBackdrop", window, CT_BACKDROP)
    previewBackdrop:SetAnchorFill(window)
    previewBackdrop:SetMouseEnabled(false)
    previewBackdrop:SetHidden(true)
    SetBackdropStyle(previewBackdrop, { 0.020, 0.017, 0.012, 0.14 }, { COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 0.70 })

    local previewLabel = WINDOW_MANAGER:CreateControl("GreedDropTextPromptPreviewLabel", window, CT_LABEL)
    previewLabel:SetDimensions(1480, 32)
    previewLabel:SetAnchor(TOP, window, TOP, 0, 18)
    previewLabel:SetFont(self:GetTextPromptFont("drop"))
    previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    previewLabel:SetColor(self:GetPromptColor("drop"))
    previewLabel:SetText(self:FormatPromptText("drop", T("[Pillager's Restoration Staff] - Infused has dropped")))
    previewLabel:SetHidden(true)
    previewLabel:SetMouseEnabled(false)

    local labels = {}
    local alertContainers = {}
    for index = 1, 5 do
        local container = WINDOW_MANAGER:CreateControl("GreedDropTextPromptAlert" .. index, window, CT_CONTROL)
        container:SetDimensions(1480, 28)
        container:SetAnchor(TOP, window, TOP, 0, (index - 1) * 28)
        container:SetHidden(true)
        container:SetAlpha(0)
        container:SetMouseEnabled(false)
        CallControlMethod(container, "SetDrawLayer", DL_OVERLAY)
        CallControlMethod(container, "SetDrawTier", DT_HIGH)
        CallControlMethod(container, "SetDrawLevel", 650 + index)

        local label = WINDOW_MANAGER:CreateControl("GreedDropTextPromptLine" .. index, container, CT_LABEL)
        label:SetDimensions(1480, 28)
        label:SetAnchor(TOP, container, TOP, 0, 0)
        label:SetFont(self:GetTextPromptFont("drop"))
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(self:GetPromptColor("drop"))
        label:SetAlpha(1)
        label:SetHidden(true)
        label:SetMouseEnabled(false)
        labels[index] = label
        alertContainers[index] = container
    end

    local moveHandle = self:CreatePromptMoveHandle(window, "GreedDropTextPrompt")
    local dragSurface = CreatePromptDragSurface(window, "GreedDropTextPrompt")

    self.textPromptControls = {
        window = window,
        labels = labels,
        alertContainers = alertContainers,
        moveHandle = moveHandle,
        dragSurface = dragSurface,
        previewBackdrop = previewBackdrop,
        previewLabel = previewLabel,
        alerts = {},
    }

    self:MakePromptPreviewMovable("drop", window, moveHandle, "dropTextPrompt", dragSurface)
    self:SetPromptPreviewDragState(self.textPromptControls, false)
    self:RestoreWindowPosition(window, "dropTextPrompt")
end

function Greed:RefreshTextPromptFonts()
    self:ApplyTextPromptFont()
end

function Greed:IsDropOptionsWindowVisible()
    return self.dropOptionsControls
        and self.dropOptionsControls.window
        and self.dropOptionsControls.window.IsHidden
        and not self.dropOptionsControls.window:IsHidden()
end

function Greed:RefreshTextPromptMovement()
    self:InitializeTextPromptSettings()
    local dropSettings = self:GetPromptSettings("drop")
    local spaulderSettings = self:GetPromptSettings("spaulder")
    local dropCanDrag = self:IsPromptEnabled("drop") and dropSettings.locked ~= true
    local spaulderCanDrag = self:IsPromptEnabled("spaulder") and spaulderSettings.locked ~= true

    if self.textPromptControls then
        self:SetPromptPreviewDragState(self.textPromptControls, dropCanDrag)
        self:RefreshDropTextPromptPreview()
    end

    if self.spaulderPromptControls then
        self:SetPromptPreviewDragState(self.spaulderPromptControls, spaulderCanDrag)
        self:RefreshSpaulderTextPrompt()
    end
end

function Greed:RefreshDropTextPromptPreview()
    if not self.textPromptControls then return end

    self:InitializeTextPromptSettings()
    local settings = self:GetPromptSettings("drop")
    local unlocked = settings.locked ~= true
    local enabled = self:IsPromptEnabled("drop")
    local hasAlerts = #(self.textPromptControls.alerts or {}) > 0
    local optionsVisible = self:IsDropOptionsWindowVisible()
    local showPreview = enabled and unlocked and optionsVisible and not hasAlerts
    local canDrag = enabled and unlocked and (showPreview or hasAlerts)

    if not enabled then
        self.textPromptControls.alerts = {}
        for index, label in ipairs(self.textPromptControls.labels or {}) do
            local container = self.textPromptControls.alertContainers and self.textPromptControls.alertContainers[index]
            if container then
                container:SetHidden(true)
                container:SetAlpha(0)
            end
            label:SetHidden(true)
            label:SetAlpha(1)
        end
    end

    if self.textPromptControls.previewBackdrop then
        self.textPromptControls.previewBackdrop:SetHidden(not showPreview)
    end
    if self.textPromptControls.previewLabel then
        self.textPromptControls.previewLabel:SetHidden(not showPreview)
        if showPreview then
            self.textPromptControls.previewLabel:SetText(self:FormatPromptText("drop", T("[Pillager's Restoration Staff] - Infused has dropped")))
        end
    end
    if self.textPromptControls.window then
        self.textPromptControls.window:SetHidden(not showPreview and not hasAlerts)
    end

    self:SetPromptPreviewDragState(self.textPromptControls, canDrag)
    self:ApplyTextPromptFont()
    self:RefreshTextPromptUpdateHandler()
end

function Greed:AddDropTextAlert(entry, forceTestAlert)
    self:InitializeTextPromptSettings()
    if not self:IsPromptEnabled("drop") or not entry then return end

    -- Final safety gate: live floating Drop Text is only for wishlist/tracked items.
    -- The only exception is the Options > Test Drop Row button, so users can preview
    -- the Drop Text prompt without changing real loot behavior.
    local isTestDropTextPreview = forceTestAlert == true and entry.testRow == true and entry.source == "test"
    if entry.wishlistMatched ~= true and not isTestDropTextPreview then
        self:DropLogDebug("skipped Drop Text alert because item is not on wishlist: " .. tostring(entry.itemLink or entry.itemName or "unknown item"))
        return
    end

    self:CreateTextPromptControls()
    local itemText = entry.itemLink or entry.itemName or T("Item")
    local traitText = entry.traitName and entry.traitName ~= "" and entry.traitName ~= "trait unknown" and (" - " .. entry.traitName) or ""
    local text = self:FormatPromptText("drop", T("%s has dropped", itemText .. traitText))
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local alerts = self.textPromptControls.alerts or {}
    self.textPromptControls.alerts = alerts
    local createdAt = now
    local lastAlert = alerts[#alerts]
    if lastAlert and type(lastAlert.createdAt) == "number" then
        createdAt = math.max(now, lastAlert.createdAt + DROP_TEXT_ALERT_STAGGER_MS)
    end

    table.insert(alerts, {
        text = text,
        createdAt = createdAt,
        expiresAt = createdAt + DEFAULT_TEXT_PROMPT_DURATION_MS,
    })

    while #alerts > #(self.textPromptControls.labels or {}) do
        table.remove(alerts, 1)
    end

    self.textPromptControls.window:SetHidden(false)
    -- Do not refresh all Drop Text labels here. Reapplying formatting to every active
    -- alert resets label alpha and can make slow fades flicker. Each label is prepared
    -- once when its alert becomes visible; UpdateDropTextAlerts then only adjusts alpha.
    self:UpdateDropTextAlerts(true)
    self:RefreshTextPromptUpdateHandler()
end

function Greed:PrepareDropTextAlertLabel(index, label, alert, container)
    if not label or not alert then return end

    -- Only bind text/formatting when a different alert is assigned to this label.
    -- During fade ticks, UpdateDropTextAlerts should only change the parent container
    -- alpha. Fading the label itself can flicker in ESO as the font/shadow redraws.
    if label.greedDropTextAlert == alert and label.greedDropTextAlertText == alert.text then
        return
    end

    label.greedDropTextAlert = alert
    label.greedDropTextAlertText = alert.text
    label:SetText(alert.text or "")
    self:ApplyPromptFormattingToLabel("drop", label, "GreedDropTextPromptLine" .. tostring(index))
    label:SetAlpha(1)
    label:SetHidden(false)
    if container then
        container:SetAlpha(0)
    end
end

function Greed:HasActiveDropTextAlerts()
    return self.textPromptControls
        and type(self.textPromptControls.alerts) == "table"
        and #self.textPromptControls.alerts > 0
end

function Greed:IsSpaulderPulseVisible()
    local controls = self.spaulderPromptControls
    return controls
        and controls.label
        and controls.label.IsHidden
        and not controls.label:IsHidden()
end

function Greed:UpdateSpaulderPromptPulse()
    local controls = self.spaulderPromptControls
    if not controls or not controls.label or not controls.label.IsHidden or controls.label:IsHidden() then
        return false
    end

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local pulse = 0.55 + (math.abs(((now % 1600) / 800) - 1) * 0.45)
    controls.label:SetAlpha(pulse)
    if controls.label.greedUnderline then
        controls.label.greedUnderline:SetHidden(true)
    end

    return true
end

function Greed:RefreshTextPromptUpdateHandler()
    local watcher = self.textPromptWatcher
    if not watcher then return end

    local shouldRun = self:HasActiveDropTextAlerts() == true or self:IsSpaulderPulseVisible() == true
    if shouldRun and self.textPromptWatcherActive ~= true then
        watcher:SetHandler("OnUpdate", function()
            self:UpdateDropTextAlerts(true)
            self:UpdateSpaulderPromptPulse()
            self:RefreshTextPromptUpdateHandler()
        end)
        self.textPromptWatcherActive = true
    elseif not shouldRun and self.textPromptWatcherActive == true then
        watcher:SetHandler("OnUpdate", nil)
        self.textPromptWatcherActive = false
    end
end

function Greed:UpdateDropTextAlerts(skipHandlerRefresh)
    if not self.textPromptControls then return end

    self:InitializeTextPromptSettings()
    local enabled = self:IsPromptEnabled("drop")
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local alerts = self.textPromptControls.alerts or {}
    if not enabled then
        alerts = {}
        self.textPromptControls.alerts = alerts
    end

    for index = #alerts, 1, -1 do
        if (alerts[index].expiresAt or 0) <= now then
            table.remove(alerts, index)
        end
    end

    local hasActiveAlerts = #alerts > 0

    local alertContainers = self.textPromptControls.alertContainers or {}
    for index, label in ipairs(self.textPromptControls.labels or {}) do
        local alert = alerts[index]
        local container = alertContainers[index]
        if alert then
            local createdAt = alert.createdAt or ((alert.expiresAt or now) - DEFAULT_TEXT_PROMPT_DURATION_MS)
            if now < createdAt then
                if container then
                    container:SetHidden(true)
                    container:SetAlpha(0)
                end
                label:SetHidden(true)
                label:SetAlpha(1)
                if label.greedUnderline then label.greedUnderline:SetHidden(true) end
            else
                local remaining = math.max(0, (alert.expiresAt or now) - now)
                local age = math.max(0, now - createdAt)
                local fadeInAlpha = DROP_TEXT_FADE_IN_MS > 0 and math.min(1, age / DROP_TEXT_FADE_IN_MS) or 1
                local fadeOutAlpha = remaining < DROP_TEXT_FADE_OUT_MS and (remaining / DROP_TEXT_FADE_OUT_MS) or 1
                local alpha = math.max(0, math.min(1, math.min(fadeInAlpha, fadeOutAlpha)))
                self:PrepareDropTextAlertLabel(index, label, alert, container)
                label:SetAlpha(1)
                label:SetHidden(false)
                if container then
                    if type(container.IsHidden) ~= "function" or container:IsHidden() then
                        container:SetHidden(false)
                    end
                    container:SetAlpha(alpha)
                else
                    label:SetAlpha(alpha)
                end
                if label.greedUnderline then
                    label.greedUnderline:SetHidden(true)
                end
            end
        else
            label.greedDropTextAlert = nil
            label.greedDropTextAlertText = nil
            if container then
                container:SetHidden(true)
                container:SetAlpha(0)
            end
            label:SetHidden(true)
            label:SetAlpha(1)
            if label.greedUnderline then label.greedUnderline:SetHidden(true) end
        end
    end

    if self.textPromptControls.window then
        if hasActiveAlerts then
            if self.textPromptControls.previewBackdrop then
                self.textPromptControls.previewBackdrop:SetHidden(true)
            end
            if self.textPromptControls.previewLabel then
                self.textPromptControls.previewLabel:SetHidden(true)
            end
            self.textPromptControls.window:SetHidden(false)
        else
            self:RefreshDropTextPromptPreview()
        end
    end

    if skipHandlerRefresh ~= true then
        self:RefreshTextPromptUpdateHandler()
    end
end

function Greed:CreateSpaulderPromptControls()
    if self.spaulderPromptControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedSpaulderPromptWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(680, 82)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, 160)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetClampedToScreen", true)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 610)

    local previewBackdrop = WINDOW_MANAGER:CreateControl("GreedSpaulderPromptPreviewBackdrop", window, CT_BACKDROP)
    previewBackdrop:SetAnchorFill(window)
    previewBackdrop:SetMouseEnabled(false)
    previewBackdrop:SetHidden(true)
    SetBackdropStyle(previewBackdrop, { 0.020, 0.017, 0.012, 0.14 }, { COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 0.70 })

    local label = WINDOW_MANAGER:CreateControl("GreedSpaulderPromptLabel", window, CT_LABEL)
    label:SetAnchorFill(window)
    label:SetFont(self:GetTextPromptFont("spaulder"))
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(self:GetPromptColor("spaulder"))
    label:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
    label:SetMouseEnabled(false)

    local previewLabel = WINDOW_MANAGER:CreateControl("GreedSpaulderPromptPreviewLabel", window, CT_LABEL)
    previewLabel:SetAnchorFill(window)
    previewLabel:SetFont(self:GetTextPromptFont("spaulder"))
    previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    previewLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    previewLabel:SetColor(self:GetPromptColor("spaulder"))
    previewLabel:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
    previewLabel:SetMouseEnabled(false)
    previewLabel:SetHidden(true)

    local moveHandle = self:CreatePromptMoveHandle(window, "GreedSpaulderPrompt")
    local dragSurface = CreatePromptDragSurface(window, "GreedSpaulderPrompt")

    self.spaulderPromptControls = {
        window = window,
        label = label,
        previewBackdrop = previewBackdrop,
        previewLabel = previewLabel,
        moveHandle = moveHandle,
        dragSurface = dragSurface,
    }

    self:MakePromptPreviewMovable("spaulder", window, moveHandle, "spaulderPrompt", dragSurface)
    self:SetPromptPreviewDragState(self.spaulderPromptControls, false)
    self:RestoreWindowPosition(window, "spaulderPrompt")
end

function Greed:IsSpaulderEquipped()
    -- Read the actual worn shoulder slot first. Set-count APIs can briefly
    -- report zero while ESO moves the player between internal trial rooms.
    if BAG_WORN ~= nil and EQUIP_SLOT_SHOULDERS ~= nil then
        local spaulderItemId
        if type(GetItemLinkItemId) == "function" then
            local okSpaulderId, itemId = pcall(function()
                return GetItemLinkItemId(SPAULDER_OF_RUIN_ITEM_LINK)
            end)
            if okSpaulderId and type(itemId) == "number" and itemId > 0 then
                spaulderItemId = itemId
            end
        end

        if type(GetItemId) == "function" and type(spaulderItemId) == "number" then
            local okWornId, wornItemId = pcall(function()
                return GetItemId(BAG_WORN, EQUIP_SLOT_SHOULDERS)
            end)
            if okWornId and type(wornItemId) == "number" and wornItemId > 0 then
                return wornItemId == spaulderItemId
            end
        end

        if type(GetItemLink) == "function" then
            local okLink, itemLink = pcall(function()
                return GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS, LINK_STYLE_DEFAULT)
            end)
            if okLink and type(itemLink) == "string" and itemLink ~= "" then
                if type(GetItemLinkItemId) == "function" and type(spaulderItemId) == "number" then
                    local okLinkId, wornLinkItemId = pcall(function()
                        return GetItemLinkItemId(itemLink)
                    end)
                    if okLinkId and type(wornLinkItemId) == "number" and wornLinkItemId > 0 then
                        return wornLinkItemId == spaulderItemId
                    end
                end

                local itemName = itemLink
                if type(GetItemLinkName) == "function" then
                    local okName, name = pcall(function()
                        return GetItemLinkName(itemLink)
                    end)
                    if okName and type(name) == "string" then
                        itemName = name
                    end
                end

                itemName = string.lower(self:CleanEsoDisplayText(itemName))
                return itemName:find("spaulder of ruin", 1, true) ~= nil
            end
        end
    end

    -- Last-resort compatibility fallback for clients where direct slot item
    -- identity is unavailable.
    if type(GetItemLinkSetInfo) == "function" then
        local ok, hasSet, setName, numBonuses, numNormalEquipped = pcall(function()
            return GetItemLinkSetInfo(SPAULDER_OF_RUIN_ITEM_LINK, true)
        end)
        if ok and type(numNormalEquipped) == "number" then
            return numNormalEquipped >= 1
        end
    end

    return false
end

function Greed:IsPlayerCrouchedForSpaulder(stealthState)
    -- Prefer APIs that specifically report sneaking. GetUnitStealthState also
    -- includes detection/hidden states that can change during loading screens
    -- without the player actually pressing crouch.
    if type(IsUnitSneaking) == "function" then
        local ok, sneaking = pcall(function()
            return IsUnitSneaking("player")
        end)
        if ok and sneaking == true then return true end
    end

    if type(IsPlayerSneaking) == "function" then
        local ok, sneaking = pcall(IsPlayerSneaking)
        if ok and sneaking == true then return true end
    end

    if type(stealthState) ~= "number" and type(GetUnitStealthState) == "function" then
        local ok, state = pcall(function()
            return GetUnitStealthState("player")
        end)
        if ok then stealthState = state end
    end

    if type(stealthState) ~= "number" then return false end
    local noneState = type(STEALTH_STATE_NONE) == "number" and STEALTH_STATE_NONE or 0
    return stealthState ~= noneState and stealthState ~= 0
end

function Greed:BeginSpaulderTransitionGuard()
    self.spaulderTransitionToken = (self.spaulderTransitionToken or 0) + 1
    self.spaulderTransitionActive = true
    self:ClearSpaulderUserToggleExpectation()
    self:CancelSpaulderFadeToggleConfirmation()
    return self.spaulderTransitionToken
end

function Greed:ScheduleSpaulderTransitionGuardEnd()
    local token = self:BeginSpaulderTransitionGuard()
    local function finishTransition()
        if self.spaulderTransitionToken ~= token then return end
        self.spaulderTransitionActive = false
        self.spaulderPromptWasCrouched = false
    end

    if type(zo_callLater) == "function" then
        zo_callLater(finishTransition, SPAULDER_TRANSITION_SETTLE_MS)
    else
        finishTransition()
    end
end

function Greed:ClearSpaulderUserToggleExpectation()
    self.spaulderExpectedToggleActive = nil
    self.spaulderUserToggleAt = nil
end

function Greed:CancelSpaulderFadeToggleConfirmation()
    self.spaulderFadeToggleToken = (self.spaulderFadeToggleToken or 0) + 1
end

function Greed:ScheduleSpaulderFadeToggleConfirmation()
    self:CancelSpaulderFadeToggleConfirmation()
    local token = self.spaulderFadeToggleToken

    local function confirmFade()
        if self.spaulderFadeToggleToken ~= token then return end
        if self:IsSpaulderUserToggleExpected(false) then
            self:ClearSpaulderUserToggleExpectation()
            self:MarkSpaulderAuraActive(false)
        end
        self:RefreshSpaulderTextPrompt()
    end

    if type(zo_callLater) == "function" then
        zo_callLater(confirmFade, SPAULDER_FADE_TOGGLE_CONFIRM_MS)
    else
        confirmFade()
    end
end

function Greed:OnSpaulderStealthStateChanged(_, unitTag, stealthState)
    if unitTag ~= "player" then return end
    if self.spaulderTransitionActive == true then
        self.spaulderPromptWasCrouched = false
        self:ClearSpaulderUserToggleExpectation()
        return
    end

    local crouched = self:IsPlayerCrouchedForSpaulder(stealthState) == true
    local wasCrouched = self.spaulderPromptWasCrouched == true
    self.spaulderPromptWasCrouched = crouched
    if not crouched or wasCrouched then return end

    local auraActive = self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true
    self.spaulderExpectedToggleActive = not auraActive
    self.spaulderUserToggleAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
end

function Greed:IsSpaulderUserToggleExpected(active)
    if self.spaulderExpectedToggleActive ~= (active == true) then return false end
    if type(self.spaulderUserToggleAt) ~= "number" then return false end

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
    if type(now) ~= "number" or (now - self.spaulderUserToggleAt) > SPAULDER_USER_TOGGLE_WINDOW_MS then
        self:ClearSpaulderUserToggleExpectation()
        return false
    end

    return true
end

function Greed:GetCurrentSpaulderZoneId()
    if type(GetUnitWorldPosition) ~= "function" then return nil end

    local ok, zoneId = pcall(function()
        return GetUnitWorldPosition("player")
    end)
    if ok then
        return zoneId
    end

    return nil
end

function Greed:PersistSpaulderAuraState(active, zoneId)
    local prompts = self.savedVars and self.savedVars.textPrompts
    if type(prompts) ~= "table" then return end

    prompts.spaulderAuraActive = active == true
    prompts.spaulderAuraSavedAt = type(GetTimeStamp) == "function" and GetTimeStamp() or nil
    if active == true then
        prompts.spaulderAuraZoneId = zoneId or self:GetCurrentSpaulderZoneId()
    else
        prompts.spaulderAuraZoneId = nil
    end
end

function Greed:RestorePersistedSpaulderAuraState()
    local prompts = self.savedVars and self.savedVars.textPrompts
    if type(prompts) ~= "table" or prompts.spaulderAuraActive ~= true then
        return false
    end

    if type(GetTimeStamp) == "function" and type(prompts.spaulderAuraSavedAt) == "number" then
        local age = GetTimeStamp() - prompts.spaulderAuraSavedAt
        if age < 0 or age > SPAULDER_RELOAD_STATE_MAX_AGE_SECONDS then
            self:PersistSpaulderAuraState(false, self:GetCurrentSpaulderZoneId())
            return false
        end
    end

    -- The same trial can report different world/zone ids for internal rooms,
    -- and those ids may not be ready yet during /reloadui. A zone-id mismatch
    -- is therefore not proof that Spaulder was deactivated.
    local currentZoneId = self:GetCurrentSpaulderZoneId()
    self.spaulderCurrentZoneId = currentZoneId or prompts.spaulderAuraZoneId
    self.spaulderAuraEventKnown = true
    self.spaulderAuraEventActive = true
    self.spaulderAuraAssumedActive = true
    self.spaulderAuraRestoredFromReload = true
    self.spaulderAuraActivatedAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
    self:ScheduleSpaulderAuraExpirationRefresh()
    return true
end

function Greed:ResetSpaulderAuraState()
    local hadAuraState = self.spaulderAuraEventKnown == true
        or self.spaulderAuraEventActive == true
        or self.spaulderAuraAssumedActive == true
        or self.spaulderAuraActivatedAt ~= nil
    if hadAuraState then
        self.spaulderAuraStateGeneration = (self.spaulderAuraStateGeneration or 0) + 1
    end
    self.spaulderAuraEventKnown = false
    self.spaulderAuraEventActive = false
    self.spaulderAuraAssumedActive = false
    self.spaulderAuraActivatedAt = nil
    self.spaulderAuraExpirationToken = (self.spaulderAuraExpirationToken or 0) + 1
    self.spaulderPromptWasCrouched = false
    self:ClearSpaulderUserToggleExpectation()
    self:CancelSpaulderFadeToggleConfirmation()
    self.spaulderAuraRestoredFromReload = false
    self:PersistSpaulderAuraState(false, self:GetCurrentSpaulderZoneId())
end

function Greed:ScheduleSpaulderAuraExpirationRefresh()
    if type(zo_callLater) ~= "function" then return end

    self.spaulderAuraExpirationToken = (self.spaulderAuraExpirationToken or 0) + 1
    local token = self.spaulderAuraExpirationToken
    zo_callLater(function()
        if self.spaulderAuraExpirationToken ~= token then return end
        if self:IsSpaulderAuraTimerExpired() then
            self:MarkSpaulderAuraActive(false)
            self:RefreshSpaulderTextPrompt()
        end
    end, SPAULDER_AURA_DURATION_MS + 250)
end

function Greed:MarkSpaulderAuraActive(active)
    local nextActive = active == true
    local wasKnown = self.spaulderAuraEventKnown == true
    local wasActive = self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true
    if not wasKnown or wasActive ~= nextActive then
        self.spaulderAuraStateGeneration = (self.spaulderAuraStateGeneration or 0) + 1
    end
    self.spaulderAuraEventKnown = true
    self.spaulderAuraEventActive = nextActive
    self.spaulderAuraAssumedActive = nextActive
    self.spaulderAuraRestoredFromReload = false
    self:PersistSpaulderAuraState(nextActive, self:GetCurrentSpaulderZoneId())
    if nextActive then
        self.spaulderAuraActivatedAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
        self:ScheduleSpaulderAuraExpirationRefresh()
    else
        self.spaulderAuraActivatedAt = nil
        self.spaulderAuraExpirationToken = (self.spaulderAuraExpirationToken or 0) + 1
    end
end

function Greed:IsSpaulderAuraTimerExpired()
    if self.spaulderAuraEventActive ~= true or type(self.spaulderAuraActivatedAt) ~= "number" then
        return false
    end
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
    return type(now) == "number" and (now - self.spaulderAuraActivatedAt) >= SPAULDER_AURA_DURATION_MS
end

function Greed:UpdateSpaulderAuraState(spaulderEquipped, inDungeonOrTrial, auraDetected)
    local shouldTrack = spaulderEquipped == true and inDungeonOrTrial == true
    if not shouldTrack then
        -- Equipment/instance APIs can briefly report false while changing
        -- rooms. Do not destroy a known active state from a render refresh.
        -- A fresh login, a confirmed crouch-off fade, or actually replacing
        -- the shoulder piece clears the state through dedicated event paths.
        return
    end

    if self:IsSpaulderAuraTimerExpired() then
        self:MarkSpaulderAuraActive(false)
    end

    -- Buff scanning is positive evidence only. Missing buff data during a
    -- transition must never be treated as authoritative deactivation.
    if auraDetected == true then
        self:MarkSpaulderAuraActive(true)
    end
end

function Greed:IsSpaulderAuraAssumedActive(auraDetected)
    if self:IsSpaulderAuraTimerExpired() then
        self:MarkSpaulderAuraActive(false)
    end
    return auraDetected == true or self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true
end

function Greed:ScanPlayerAuraOfPride()
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return nil
    end

    local okCount, buffCount = pcall(function()
        return GetNumBuffs("player")
    end)
    if not okCount or type(buffCount) ~= "number" then return nil end

    for index = 1, buffCount do
        local results = { pcall(function()
            return GetUnitBuffInfo("player", index)
        end) }
        if results[1] == true then
            for resultIndex = 2, #results do
                local value = results[resultIndex]
                if type(value) == "number" and value == SPAULDER_AURA_OF_PRIDE_ABILITY_ID then
                    return true
                end
            end
        end
    end

    return false
end

function Greed:PlayerHasAuraOfPride()
    if self:IsSpaulderAuraTimerExpired() then
        self:MarkSpaulderAuraActive(false)
        return false
    end

    if self.spaulderAuraEventActive == true then
        return true
    end

    return self:ScanPlayerAuraOfPride() == true
end

function Greed:OnSpaulderCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if abilityId ~= nil and abilityId ~= SPAULDER_AURA_OF_PRIDE_ABILITY_ID then return end

    local gained = ACTION_RESULT_EFFECT_GAINED ~= nil and result == ACTION_RESULT_EFFECT_GAINED
    local gainedDuration = ACTION_RESULT_EFFECT_GAINED_DURATION ~= nil and result == ACTION_RESULT_EFFECT_GAINED_DURATION
    local refreshed = ACTION_RESULT_EFFECT_REFRESHED ~= nil and result == ACTION_RESULT_EFFECT_REFRESHED
    local updated = ACTION_RESULT_EFFECT_UPDATED ~= nil and result == ACTION_RESULT_EFFECT_UPDATED

    if gained or gainedDuration or refreshed or updated then
        self:CancelSpaulderFadeToggleConfirmation()
        self:MarkSpaulderAuraActive(true)
        if self:IsSpaulderUserToggleExpected(true) then
            self:ClearSpaulderUserToggleExpectation()
        end
        self:RefreshSpaulderTextPrompt()
        return
    end

    if ACTION_RESULT_EFFECT_FADED ~= nil and result == ACTION_RESULT_EFFECT_FADED then
        if self.spaulderTransitionActive == true then
            -- ESO emits a temporary fade while moving between some internal
            -- trial rooms. Keep the last authoritative state until a real
            -- player crouch toggle or a later gained event says otherwise.
            self:ClearSpaulderUserToggleExpectation()
            self:CancelSpaulderFadeToggleConfirmation()
            return
        end

        if self:IsSpaulderUserToggleExpected(false) then
            self:ClearSpaulderUserToggleExpectation()
            self:CancelSpaulderFadeToggleConfirmation()
            self:MarkSpaulderAuraActive(false)
            self:RefreshSpaulderTextPrompt()
            return
        end

        local auraWasActive = self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true
        if auraWasActive then
            -- Combat and crouch callbacks can be delivered in either order.
            -- Give an actual crouch event one short chance to confirm a real
            -- toggle. With no crouch confirmation, ignore the fade.
            self:ScheduleSpaulderFadeToggleConfirmation()
        end
    end
end

function Greed:RevalidateSpaulderAuraAfterTransition(token, scheduledStateGeneration, scheduledKnownActive)
    if token ~= nil and self.spaulderAuraRevalidationToken ~= token then return end

    self.spaulderAuraRevalidationPending = false
    self.spaulderAuraRevalidationReason = nil
    if type(scheduledStateGeneration) == "number" and (self.spaulderAuraStateGeneration or 0) ~= scheduledStateGeneration then return end
    if not self.savedVars or self:IsPromptEnabled("spaulder") ~= true then return end

    local spaulderEquipped = self:IsSpaulderEquipped()
    local inDungeonOrTrial = self:IsPlayerInDungeonOrTrial()
    if not spaulderEquipped or not inDungeonOrTrial then
        -- These APIs can be temporarily unavailable or false during room
        -- transitions. The UI will hide naturally when not applicable, but
        -- the active-state memory must survive.
        self:RefreshSpaulderTextPrompt()
        return
    end

    local auraDetected = self:ScanPlayerAuraOfPride()
    if auraDetected == true then
        self:MarkSpaulderAuraActive(true)
    end

    -- A false scan is not authoritative. Aura of Pride is not consistently
    -- exposed in the player buff list after internal doors or /reloadui.
    self:RefreshSpaulderTextPrompt()
end

function Greed:ScheduleSpaulderAuraRevalidation(reason)
    if self.spaulderAuraRevalidationPending == true then
        self.spaulderAuraRevalidationReason = reason or self.spaulderAuraRevalidationReason
        return
    end

    self.spaulderAuraRevalidationPending = true
    self.spaulderAuraRevalidationReason = reason
    self.spaulderAuraRevalidationToken = (self.spaulderAuraRevalidationToken or 0) + 1
    local token = self.spaulderAuraRevalidationToken
    local stateGeneration = self.spaulderAuraStateGeneration or 0
    local knownActive = self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true

    if type(zo_callLater) ~= "function" then
        self:RevalidateSpaulderAuraAfterTransition(token, stateGeneration, knownActive)
        return
    end

    zo_callLater(function()
        if self.spaulderAuraRevalidationToken ~= token then return end
        self:RevalidateSpaulderAuraAfterTransition(token, stateGeneration, knownActive)
    end, SPAULDER_AURA_REVALIDATE_DELAY_MS)
end

function Greed:OnSpaulderPlayerActivated(_, initial)
    local zoneId = self:GetCurrentSpaulderZoneId()
    if zoneId ~= nil then
        self.spaulderCurrentZoneId = zoneId
    end

    self:ScheduleSpaulderTransitionGuardEnd()

    if self.spaulderAuraEventActive ~= true and self.spaulderAuraAssumedActive ~= true then
        -- Addon startup and /reloadui can both arrive with initial=true, while
        -- ESO does not replay an already-active Spaulder combat event. A recent
        -- saved state inside a dungeon/trial is therefore the reliable reload
        -- continuation signal. A fresh login outside that context starts off.
        local restored = false
        if self:IsPlayerInDungeonOrTrial() == true then
            restored = self:RestorePersistedSpaulderAuraState()
        end
        if not restored and initial == true then
            self:ResetSpaulderAuraState()
        end
    elseif self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true then
        self:PersistSpaulderAuraState(true, zoneId)
    end

    self:ScheduleSpaulderAuraRevalidation("activated")
    self:RefreshSpaulderTextPrompt()
end

function Greed:OnSpaulderNeedsReactivation(reason)
    reason = reason or "reactivation"
    if reason == "transition" then
        self:ScheduleSpaulderTransitionGuardEnd()
        self:ScheduleSpaulderAuraRevalidation(reason)
        self:RefreshSpaulderTextPrompt()
        return
    end

    self:RefreshSpaulderTextPrompt()
    self:ScheduleSpaulderAuraRevalidation(reason)
end

function Greed:RegisterSpaulderCombatWatcher()
    if self.spaulderCombatWatcherRegistered == true then return end
    if not EVENT_MANAGER then return end

    local combatEventName = self.name .. "SpaulderAuraCombatEvent"
    if EVENT_COMBAT_EVENT ~= nil then
        EVENT_MANAGER:RegisterForEvent(combatEventName, EVENT_COMBAT_EVENT, function(...)
            self:OnSpaulderCombatEvent(...)
        end)
        if type(EVENT_MANAGER.AddFilterForEvent) == "function" and REGISTER_FILTER_ABILITY_ID ~= nil then
            pcall(function()
                if REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE ~= nil and COMBAT_UNIT_TYPE_PLAYER ~= nil then
                    EVENT_MANAGER:AddFilterForEvent(combatEventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SPAULDER_AURA_OF_PRIDE_ABILITY_ID, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                else
                    EVENT_MANAGER:AddFilterForEvent(combatEventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SPAULDER_AURA_OF_PRIDE_ABILITY_ID)
                end
            end)
        end
    end

    local inventoryEventName = self.name .. "SpaulderGearUpdate"
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(inventoryEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex)
            if bagId == BAG_WORN and slotIndex == EQUIP_SLOT_SHOULDERS and self:IsSpaulderEquipped() ~= true then
                self:ResetSpaulderAuraState()
            end
            self:RefreshSpaulderTextPrompt()
        end)
        if type(EVENT_MANAGER.AddFilterForEvent) == "function" and REGISTER_FILTER_BAG_ID ~= nil and BAG_WORN ~= nil then
            pcall(function()
                if REGISTER_FILTER_INVENTORY_UPDATE_REASON ~= nil and INVENTORY_UPDATE_REASON_DEFAULT ~= nil then
                    EVENT_MANAGER:AddFilterForEvent(inventoryEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
                else
                    EVENT_MANAGER:AddFilterForEvent(inventoryEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
                end
            end)
        end
    end

    if EVENT_PLAYER_DEACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderPlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function()
            if self.spaulderAuraEventActive == true or self.spaulderAuraAssumedActive == true then
                self:PersistSpaulderAuraState(true, self:GetCurrentSpaulderZoneId())
            end
            self:BeginSpaulderTransitionGuard()
        end)
    end

    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderPlayerActivated", EVENT_PLAYER_ACTIVATED, function(...)
            self:OnSpaulderPlayerActivated(...)
        end)
    end

    if EVENT_STEALTH_STATE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderStealthState", EVENT_STEALTH_STATE_CHANGED, function(...)
            self:OnSpaulderStealthStateChanged(...)
        end)
    end

    if EVENT_PLAYER_DEAD ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderPlayerDead", EVENT_PLAYER_DEAD, function()
            self:OnSpaulderNeedsReactivation()
        end)
    end

    if EVENT_PLAYER_ALIVE ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderPlayerAlive", EVENT_PLAYER_ALIVE, function()
            self:OnSpaulderNeedsReactivation()
        end)
    end

    if EVENT_RAID_TRIAL_FAILED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderTrialFailed", EVENT_RAID_TRIAL_FAILED, function()
            self:OnSpaulderNeedsReactivation()
        end)
    end

    if EVENT_ZONE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderZoneChanged", EVENT_ZONE_CHANGED, function()
            self:OnSpaulderNeedsReactivation("transition")
        end)
    end

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(self.name .. "SpaulderCombatState", EVENT_PLAYER_COMBAT_STATE, function()
            self:RefreshSpaulderTextPrompt()
        end)
    end

    self.spaulderCombatWatcherRegistered = true
end

function Greed:IsPlayerInDungeonOrTrial()
    if type(IsUnitInDungeon) == "function" then
        local ok, inDungeon = pcall(function()
            return IsUnitInDungeon("player")
        end)
        if ok and inDungeon == true then
            return true
        end
    end

    if type(GetCurrentZoneDungeonDifficulty) == "function" then
        local ok, difficulty = pcall(GetCurrentZoneDungeonDifficulty)
        if ok and type(difficulty) == "number" and difficulty > 0 then
            return true
        end
    end

    return false
end

function Greed:RefreshSpaulderTextPrompt()
    self:InitializeTextPromptSettings()
    self:CreateSpaulderPromptControls()
    local controls = self.spaulderPromptControls
    if not controls or not controls.window then return end

    local enabled = self:IsPromptEnabled("spaulder")
    local settings = self:GetPromptSettings("spaulder")
    local unlocked = settings.locked ~= true

    if not enabled then
        controls.window:SetHidden(true)
        if controls.previewBackdrop then controls.previewBackdrop:SetHidden(true) end
        if controls.previewLabel then controls.previewLabel:SetHidden(true) end
        if controls.label then controls.label:SetHidden(true) end
        self:SetPromptPreviewDragState(controls, false)
        self:RefreshTextPromptUpdateHandler()
        return
    end

    local spaulderEquipped = self:IsSpaulderEquipped()
    local inDungeonOrTrial = self:IsPlayerInDungeonOrTrial()
    local auraDetected = self:PlayerHasAuraOfPride()
    self:UpdateSpaulderAuraState(spaulderEquipped, inDungeonOrTrial, auraDetected)

    -- During startup/reload, ESO may not have populated the player's active
    -- effects yet. Keep the live reminder hidden until the existing one-shot
    -- aura revalidation resolves the previously unknown state.
    local auraValidationPending = self.spaulderAuraRevalidationPending == true
        and self.spaulderAuraEventKnown ~= true

    local shouldShow = spaulderEquipped
        and inDungeonOrTrial
        and not auraValidationPending
        and not self:IsSpaulderAuraAssumedActive(auraDetected)

    local showPreview = unlocked and self:IsDropOptionsWindowVisible()
    local showLivePrompt = shouldShow and not showPreview

    controls.window:SetHidden(not showPreview and not showLivePrompt)
    if controls.previewBackdrop then
        controls.previewBackdrop:SetHidden(not showPreview)
    end
    if controls.previewLabel then
        controls.previewLabel:SetHidden(not showPreview)
        if showPreview then
            controls.previewLabel:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
        end
    end
    if controls.label then
        controls.label:SetHidden(not showLivePrompt)
        controls.label:SetText(self:FormatPromptText("spaulder", T("Crouch to Activate Spaulder")))
    end

    self:SetPromptPreviewDragState(controls, unlocked and (showPreview or showLivePrompt))
    self:ApplyTextPromptFont()

    if showLivePrompt then
        self:UpdateSpaulderPromptPulse()
    elseif controls.label then
        controls.label:SetAlpha(1)
    end

    self:RefreshTextPromptUpdateHandler()
end

function Greed:StartTextPromptWatcher()
    self:CreateTextPromptControls()
    self:CreateSpaulderPromptControls()
    self:RefreshTextPromptMovement()
    self:RegisterSpaulderCombatWatcher()

    if self.textPromptWatcher or not WINDOW_MANAGER then return end

    local watcher = WINDOW_MANAGER:CreateControl("GreedTextPromptWatcher", GuiRoot, CT_CONTROL)
    watcher:SetMouseEnabled(false)

    self.textPromptWatcher = watcher

    -- Restore the last authoritative combat-event state before startup
    -- revalidation. This is required for /reloadui because ESO does not replay
    -- the already-active Spaulder combat event to the new Lua environment.
    self:RestorePersistedSpaulderAuraState()
    self:ScheduleSpaulderAuraRevalidation("startup")
    self:RefreshSpaulderTextPrompt()
    self:RefreshTextPromptUpdateHandler()
end
