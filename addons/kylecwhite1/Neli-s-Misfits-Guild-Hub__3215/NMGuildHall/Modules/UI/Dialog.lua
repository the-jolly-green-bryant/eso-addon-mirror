local Addon = NMGuildHall
local UI = Addon.UI

local DIALOG_SCENE_NAME = "NMGuildHallDialogScene"

-- Debug: gated by SavedVars debug flag (Addon.db.debug)
local function NMGH_Dbg(...)
    -- Hard gate so dialog/keybind instrumentation never shows unless explicitly enabled.
    if Addon and Addon.IsDebugEnabled then
        if not Addon:IsDebugEnabled() then
            return
        end
    elseif not (Addon and Addon.db and Addon.db.debug == true) then
        return
    end

    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end

    local msg = "[NMGH Dialog] " .. table.concat(parts, " ")
    if Addon and Addon.Message and Addon.Message.For then
        Addon.Message:For("UI"):Debug(msg)
    elseif CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(msg)
    end
end

local function ApplyCancelButtonStyle(button)
    button.background:SetCenterColor(0.12, 0.08, 0.08, 0.9)
    button.background:SetEdgeColor(0.55, 0.45, 0.45, 0.85)
    button.label:SetColor(1, 1, 1, 1)
end

-- Map button index to UI_SHORTCUT_* for display string lookup
local DIALOG_KEYBIND_DISPLAY = {
    [1] = "UI_SHORTCUT_PRIMARY",
    [2] = "UI_SHORTCUT_SECONDARY",
    [3] = "UI_SHORTCUT_TERTIARY",
    [4] = "UI_SHORTCUT_QUATERNARY",
    [5] = "UI_SHORTCUT_NEGATIVE",
}

-- Get a yellow key label for a button e.g. "|cffff00[E]|r "
local function GetDialogKeyLabel(buttonIndex)
    local actionName = DIALOG_KEYBIND_DISPLAY[buttonIndex]
    if not actionName then return "" end

    local bindingString = ZO_Keybindings_GetBindingStringFromAction(
        actionName,
        KEYBIND_TEXT_OPTIONS_FULL_NAME,
        KEYBIND_TEXTURE_OPTIONS_NONE
    )

    if bindingString and bindingString ~= "" then
        return string.format("|cffff00[%s]|r ", bindingString)
    end

    return ""
end

local function GetKeybindNameFromKeyCode(key, ctrl, alt, shift)
    -- Best-effort conversion from keycode -> display name ("E", "F", etc).
    -- API availability varies; fall back to nil (no key handling) if unknown.
    if ZO_Keybindings_GetStringFromKeyCode then
        local ok, s = pcall(ZO_Keybindings_GetStringFromKeyCode, key, ctrl, alt, shift)
        if ok and s and s ~= "" then
            return s
        end
    end
    if GetKeyName then
        local ok, s = pcall(GetKeyName, key)
        if ok and s and s ~= "" then
            return s
        end
    end
    return nil
end

local function TryResolveButtonIndexFromKey(key, ctrl, alt, shift)
    local keyName = GetKeybindNameFromKeyCode(key, ctrl, alt, shift)
    if not keyName or keyName == "" then
        -- Fallback for clients where keycode->string helpers are unavailable.
        if key == KEY_RETURN or key == KEY_NUMPADENTER or key == KEY_E then
            return 1
        end
        if key == KEY_R then
            return 2
        end
        if key == KEY_T then
            return 3
        end
        if key == KEY_F then
            return 4
        end
        if key == KEY_ESCAPE or key == KEY_X then
            return 5
        end
        return nil
    end

    local lowered = zo_strlower and zo_strlower(keyName) or string.lower(keyName)
    for idx = 1, 5 do
        local actionName = DIALOG_KEYBIND_DISPLAY[idx]
        if actionName then
            local bindingString = ZO_Keybindings_GetBindingStringFromAction(
                actionName,
                KEYBIND_TEXT_OPTIONS_FULL_NAME,
                KEYBIND_TEXTURE_OPTIONS_NONE
            )
            if bindingString and bindingString ~= "" then
                local bLower = zo_strlower and zo_strlower(bindingString) or string.lower(bindingString)
                if bLower == lowered then
                    return idx
                end
            end
        end
    end

    return nil
end

local function ExecuteDialogAction(self, config)
    if not config or config.enabled == false then
        return
    end

    self:HideDialog()
    if type(config.callback) == "function" then
        local ok, err = pcall(config.callback)
        if not ok and Addon and Addon.Message and Addon.Message.For then
            Addon.Message:For("Dialog"):Error("Dialog callback failed: {error}", {
                error = tostring(err)
            })
        end
    end
end

function UI:CancelDialog()
    -- Optional user feedback for cancel actions (keybind or click).
    if self.dialogOptions and self.dialogOptions.showCancelMessage ~= false then
        local msg = self.dialogOptions.cancelMessage
        if msg == nil or msg == "" then
            msg = GetString(NMGH_DIALOG_CANCELLED)
        end
        if Addon and Addon.Msg and type(Addon.Msg) == "function" then
            Addon:Msg(msg)
        end
    end
    self:HideDialog()
end

local function EnsureDialogButton(self, buttonIndex, parent, buttonWidth)
    local button = self.dialogButtons[buttonIndex]
    if button then
        return button
    end

    button = self:CreateBaseActionButton()
    button:SetParent(parent)
    button:SetDimensions(buttonWidth, 32)
    button.label:SetFont("ZoFontGameBold")
    self.dialogButtons[buttonIndex] = button
    return button
end

local function ApplyDialogButtonStyle(button, config)
    if config and config.enabled == false then
        button.background:SetCenterColor(0.05, 0.05, 0.05, 0.7)
        button.background:SetEdgeColor(0.2, 0.2, 0.2, 0.8)
        button.label:SetColor(0.4, 0.4, 0.4, 1)
    elseif config and config.color then
        button.background:SetCenterColor(0.1, 0.05, 0.05, 0.9)
        button.background:SetEdgeColor(unpack(config.color))
        button.label:SetColor(1, 1, 1, 1)
    else
        button.background:SetCenterColor(0.1, 0.05, 0.05, 0.9)
        button.background:SetEdgeColor(0.8, 0.2, 0.3, 0.8)
        button.label:SetColor(1, 1, 1, 1)
    end
end

-- Create the custom dialog overlay and controls (called once)
function UI:CreateCustomDialog()
    NMGH_Dbg("CreateCustomDialog: entry, dialogOverlay=", self.dialogOverlay)
    if self.dialogOverlay then
        return true
    end

    local overlay, overlayBg = self:_CreateOverlay({
        controlPrefix = "NMGuildHall_Dialog",
        onDismiss = function()
            self:CancelDialog()
        end,
        onKeyDown = function(key, ctrl, alt, shift)
            if key == KEY_ESCAPE then
                self:CancelDialog()
                return true
            end

            local idx = TryResolveButtonIndexFromKey(key, ctrl, alt, shift)
            if idx then
                self:DialogKeyPress(idx)
                return true
            end

            return false
        end,
    })
    if not overlay then
        return false
    end

    local dialog = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialog", overlay, CT_CONTROL)
    dialog:SetDimensions(500, 240)
    dialog:SetAnchor(CENTER, overlay, CENTER, 0, 0)

    local dialogBg = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogBG", dialog, CT_BACKDROP)
    dialogBg:SetAnchorFill()
    dialogBg:SetCenterColor(0.02, 0.02, 0.02, 1)
    dialogBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
    dialogBg:SetEdgeColor(0.8, 0.2, 0.3, 1)
    dialogBg:SetInsets(2, 2, -2, -2)

    local header = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogHeader", dialog, CT_TEXTURE)
    header:SetDimensions(500, 40)
    header:SetAnchor(TOP, dialog, TOP, 0, 0)
    header:SetTexture("EsoUI/Art/Performance/StatusMeter_BG.dds")
    header:SetColor(0.2, 0.05, 0.05, 1)

    local closeBtn = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogClose", dialog, CT_BUTTON)
    closeBtn:SetDimensions(24, 24)
    closeBtn:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -8, 8)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closeButton_up.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closeButton_over.dds")
    closeBtn:SetHandler("OnClicked", function()
        self:HideDialog()
    end)

    local title = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogTitle", dialog, CT_LABEL)
    title:SetFont("ZoFontWinH3")
    title:SetAnchor(TOP, dialog, TOP, 0, 8)
    title:SetColor(0.9, 0.2, 0.3, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local divider = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogDivider", dialog, CT_TEXTURE)
    divider:SetDimensions(440, 4)
    divider:SetAnchor(TOP, header, BOTTOM, 0, 0)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontal_divider.dds")
    divider:SetColor(0.8, 0.2, 0.3, 0.6)

    local body = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogBody", dialog, CT_LABEL)
    body:SetFont("ZoFontGameLarge")
    body:SetAnchor(TOP, divider, BOTTOM, 0, 30)
    body:SetWidth(440)
    body:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    body:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    body:SetColor(0.9, 0.9, 0.9, 1)
    if body.SetLineSpacing then
        body:SetLineSpacing(4)
    end

    local buttonContainer = WINDOW_MANAGER:CreateControl("NMGuildHall_CustomDialogButtonContainer", dialog, CT_CONTROL)
    buttonContainer:SetAnchor(BOTTOM, dialog, BOTTOM, 0, -25)
    buttonContainer:SetDimensions(440, 50)

    self.dialogOverlay = overlay
    self.dialogOverlayBg = overlayBg
    self.dialogControl = dialog
    self.dialogHeader = header
    self.dialogDivider = divider
    self.dialogTitle = title
    self.dialogBody = body
    self.dialogButtonContainer = buttonContainer
    self.dialogButtons = {}

    self:_AttachOverlayScene(overlay, DIALOG_SCENE_NAME, {
        createIfMissing = true,
        takeFocusOnShown = true,
        onStateChange = function(_, _, newState)
            NMGH_Dbg("CreateCustomDialog: StateChange newState=", tostring(newState))
            if newState == SCENE_SHOWN then
                if self.dialogKeybindDescriptor then
                    if not self._dialogKeybindsAdded then
                        KEYBIND_STRIP:AddKeybindButtonGroup(self.dialogKeybindDescriptor)
                        self._dialogKeybindsAdded = true
                    end
                    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.dialogKeybindDescriptor)
                    NMGH_Dbg("CreateCustomDialog: keybind strip added for scene")
                end
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                if self.dialogKeybindDescriptor and self._dialogKeybindsAdded then
                    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.dialogKeybindDescriptor)
                    self._dialogKeybindsAdded = false
                    NMGH_Dbg("CreateCustomDialog: keybind strip removed")
                end
            end
        end,
    })

    return true
end

function UI:_ResizeDialogForButtons(numButtons, desiredButtonWidth, spacing, minDialogWidth, forcedDialogWidth)
    if not self.dialogControl then
        return desiredButtonWidth, minDialogWidth or 500
    end

    local screenW = (GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1024
    local maxDialogWidth = math.max(500, screenW - 80) -- keep a margin so it never touches screen edges

    local outerPadding = 60 -- left+right padding inside the dialog
    local buttonWidth = desiredButtonWidth

    local function computeRequiredWidth(bw)
        return (numButtons * bw) + ((numButtons - 1) * spacing) + outerPadding
    end

    if forcedDialogWidth ~= nil then
        local dialogWidth = tonumber(forcedDialogWidth) or (minDialogWidth or 500)
        dialogWidth = math.max(minDialogWidth or 500, math.min(maxDialogWidth, dialogWidth))

        local innerWidth = dialogWidth - outerPadding
        local available = innerWidth - ((numButtons - 1) * spacing)
        buttonWidth = math.floor(available / numButtons)
        buttonWidth = math.max(110, buttonWidth)

        self.dialogControl:SetWidth(dialogWidth)
        if self.dialogHeader then
            self.dialogHeader:SetWidth(dialogWidth)
        end
        if self.dialogDivider then
            self.dialogDivider:SetWidth(innerWidth)
        end
        if self.dialogBody then
            self.dialogBody:SetWidth(innerWidth)
        end
        if self.dialogButtonContainer then
            self.dialogButtonContainer:SetWidth(innerWidth)
        end

        return buttonWidth, dialogWidth
    end

    local required = computeRequiredWidth(buttonWidth)
    local dialogWidth = math.max(minDialogWidth or 500, math.min(maxDialogWidth, required))

    -- If clamped, shrink buttons so all fit in one row.
    if required > maxDialogWidth then
        local available = maxDialogWidth - outerPadding - ((numButtons - 1) * spacing)
        buttonWidth = math.floor(available / numButtons)
        buttonWidth = math.max(110, buttonWidth)
        required = computeRequiredWidth(buttonWidth)
        dialogWidth = math.max(minDialogWidth or 500, math.min(maxDialogWidth, required))
    end

    local innerWidth = dialogWidth - outerPadding

    self.dialogControl:SetWidth(dialogWidth)
    if self.dialogHeader then
        self.dialogHeader:SetWidth(dialogWidth)
    end
    if self.dialogDivider then
        self.dialogDivider:SetWidth(innerWidth)
    end
    if self.dialogBody then
        self.dialogBody:SetWidth(innerWidth)
    end
    if self.dialogButtonContainer then
        self.dialogButtonContainer:SetWidth(innerWidth)
    end

    return buttonWidth, dialogWidth
end

function UI:ShowDialog(titleText, bodyText, buttonConfigs, options)
    buttonConfigs = buttonConfigs or {}
    options = options or {}

    if not self.dialogOverlay then
        local created = self:CreateCustomDialog()
        if created ~= true then
            return false
        end
    end

    if self.modalEditOverlay and self.modalEditOverlay.IsHidden then
        local ok, hidden = pcall(self.modalEditOverlay.IsHidden, self.modalEditOverlay)
        if ok and hidden ~= true then
            self:HideModalEdit({
                fireCancel = false,
                skipSound = true,
            })
        end
    end

    local sceneState = self:_GetSceneState(DIALOG_SCENE_NAME)
    local sceneIsShown = (sceneState == SCENE_SHOWN)
    local sceneIsVisible = (sceneState == SCENE_SHOWN or sceneState == SCENE_SHOWING)
    local previousKeybindDescriptor = self.dialogKeybindDescriptor

    if sceneIsShown and previousKeybindDescriptor and self._dialogKeybindsAdded then
        pcall(KEYBIND_STRIP.RemoveKeybindButtonGroup, KEYBIND_STRIP, previousKeybindDescriptor)
        self._dialogKeybindsAdded = false
    end

    self.lastDialogTitle = titleText
    self.lastDialogBody = bodyText
    self.lastButtonConfigs = buttonConfigs
    self.lastDialogOptions = options
    self.dialogOptions = {
        closeMainWindowOnDismiss = options.closeMainWindowOnDismiss == true,
        -- Cancel feedback is enabled by default (can be noisy; set showCancelMessage=false per dialog if undesired)
        showCancelMessage = options.showCancelMessage,
        cancelMessage = options.cancelMessage,
        -- Manual sizing overrides (optional)
        dialogWidth = options.dialogWidth,
        buttonWidth = options.buttonWidth,
    }

    self.dialogTitle:SetText(titleText or "")
    self.dialogBody:SetText(bodyText or "")

    for _, button in ipairs(self.dialogButtons) do
        button:SetHidden(true)
    end

    local numButtons = #buttonConfigs + 1 -- include explicit Cancel button
    local spacing = 20
    local buttonWidth = tonumber(options.buttonWidth) or 140

    -- Auto-size the dialog so the button row fits cleanly (especially for 4+Cancel).
    buttonWidth = select(1, self:_ResizeDialogForButtons(numButtons, buttonWidth, spacing, 500, options.dialogWidth))

    local totalWidth = (numButtons * buttonWidth) + ((numButtons - 1) * spacing)
    local startX = -(totalWidth / 2) + (buttonWidth / 2)

    -- Keybind strip: visual display only, callbacks are backup
    local keybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    }

    -- Cancel entry using UI_SHORTCUT_NEGATIVE for correct display
    table.insert(keybindDescriptor, {
        name = GetString(SI_DIALOG_CANCEL),
        keybind = DIALOG_KEYBIND_DISPLAY[5],
        callback = function()
            self:CancelDialog()
        end,
    })

    for i, config in ipairs(buttonConfigs) do
        local button = EnsureDialogButton(self, i, self.dialogButtonContainer, buttonWidth)
        button:ClearAnchors()
        button:SetAnchor(CENTER, self.dialogButtonContainer, CENTER, startX + (i - 1) * (buttonWidth + spacing), 0)
        button:SetDimensions(buttonWidth, 32)

        local keyText = GetDialogKeyLabel(i)
        button.label:SetText(keyText .. (config.text or "Button"))
        button.label:SetFont("ZoFontGameBold")

        local capturedConfig = config
        table.insert(keybindDescriptor, {
            name = config.text,
            keybind = DIALOG_KEYBIND_DISPLAY[i] or "UI_SHORTCUT_PRIMARY",
            callback = function()
                ExecuteDialogAction(self, capturedConfig)
            end,
            enabled = function()
                return capturedConfig.enabled ~= false
            end,
        })

        ApplyDialogButtonStyle(button, config)

        button:SetHandler("OnMouseEnter", function()
            if capturedConfig.enabled ~= false then
                button.background:SetCenterColor(0.2, 0.08, 0.1, 0.9)
                button.background:SetEdgeColor(1, 0.3, 0.4, 1)
            end
        end)

        button:SetHandler("OnMouseExit", function()
            if capturedConfig.enabled ~= false then
                ApplyDialogButtonStyle(button, capturedConfig)
            end
        end)

        button:SetHandler("OnClicked", function()
            ExecuteDialogAction(self, capturedConfig)
        end)

        button:SetHidden(false)
    end

    -- Visible cancel button (negative action)
    local cancelIndex = #buttonConfigs + 1
    local cancelButton = EnsureDialogButton(self, cancelIndex, self.dialogButtonContainer, buttonWidth)
    cancelButton:ClearAnchors()
    cancelButton:SetAnchor(CENTER, self.dialogButtonContainer, CENTER, startX + (cancelIndex - 1) * (buttonWidth + spacing), 0)
    cancelButton:SetDimensions(buttonWidth, 32)
    cancelButton.label:SetText(GetDialogKeyLabel(5) .. GetString(SI_DIALOG_CANCEL))
    cancelButton.label:SetFont("ZoFontGameBold")
    ApplyCancelButtonStyle(cancelButton)
    cancelButton:SetHandler("OnMouseEnter", function()
        cancelButton.background:SetCenterColor(0.18, 0.11, 0.11, 0.95)
        cancelButton.background:SetEdgeColor(0.75, 0.62, 0.62, 1)
    end)
    cancelButton:SetHandler("OnMouseExit", function()
        ApplyCancelButtonStyle(cancelButton)
    end)
    cancelButton:SetHandler("OnClicked", function()
        self:CancelDialog()
    end)
    cancelButton:SetHidden(false)

    -- Store descriptor for keybind strip (optional; action layer handles keys)
    self.dialogKeybindDescriptor = keybindDescriptor

    if sceneIsShown and self.dialogKeybindDescriptor then
        pcall(KEYBIND_STRIP.AddKeybindButtonGroup, KEYBIND_STRIP, self.dialogKeybindDescriptor)
        self._dialogKeybindsAdded = true
        pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, self.dialogKeybindDescriptor)
    end

    self.dialogOverlay:SetHidden(false)
    if sceneIsVisible ~= true then
        PlaySound(SOUNDS.DIALOG_SHOW)
    end

    NMGH_Dbg("ShowDialog: calling SCENE_MANAGER:Show ", DIALOG_SCENE_NAME)
    SCENE_MANAGER:Show(DIALOG_SCENE_NAME)
    NMGH_Dbg("ShowDialog: done")
    return true
end

function UI:HideDialog(opts)
    NMGH_Dbg("HideDialog: entry dialogOverlay=", self.dialogOverlay and "ok" or "nil")
    opts = opts or {}
    if not self.dialogOverlay then
        return
    end

    local overlayWasHidden = false
    if self.dialogOverlay.IsHidden then
        local ok, hidden = pcall(self.dialogOverlay.IsHidden, self.dialogOverlay)
        overlayWasHidden = ok and hidden == true
    end

    local sceneState = self:_GetSceneState(DIALOG_SCENE_NAME)
    local sceneIsVisible = (sceneState == SCENE_SHOWN or sceneState == SCENE_SHOWING)
    if sceneIsVisible then
        SCENE_MANAGER:Hide(DIALOG_SCENE_NAME)
    else
        self.dialogOverlay:SetHidden(true)
    end

    if not overlayWasHidden and opts.skipSound ~= true then
        PlaySound(SOUNDS.DIALOG_CLOSE)
    end

    local closeMainWindowOnDismiss = self.dialogOptions and self.dialogOptions.closeMainWindowOnDismiss == true
    self.dialogOptions = nil

    if closeMainWindowOnDismiss and opts.suppressParentHide ~= true then
        self:Hide()
    end
end

function UI:DialogKeyPress(buttonIndex)
    NMGH_Dbg("DialogKeyPress: buttonIndex=", buttonIndex, " lastButtonConfigs=", self.lastButtonConfigs and #self.lastButtonConfigs or "nil")
    if buttonIndex == 5 then
        self:CancelDialog()
        return
    end
    if not self.lastButtonConfigs then return end

    local config = self.lastButtonConfigs[buttonIndex]
    NMGH_Dbg("DialogKeyPress: config=", config and "ok" or "nil", " enabled=", config and config.enabled)
    ExecuteDialogAction(self, config)
end
