-- ChatLogPreserverLogDialog.lua: Gamepad log viewer dialog

---@class ChatLogPreserverLogDialog : ZO_Object
local ChatLogPreserverLogDialog = ZO_Object:Subclass()
local GenericGamepadDialog_OnInitialized = rawget(_G, "ZO_GenericGamepadDialog_OnInitialized")
---@type fun(name: string, data: any|nil, textParams: any|nil)
local ShowGamepadDialog = ZO_Dialogs_ShowGamepadDialog
---@type fun(nameOrDialog: any, releasedFromButton: any|nil, filterFunction: function|nil)
local ReleaseDialog = ZO_Dialogs_ReleaseDialog

function ChatLogPreserverLogDialog:New(...)
    ---@type ChatLogPreserverLogDialog
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ChatLogPreserverLogDialog:Initialize(control)
    self.control = control
    self.headerContainer = control:GetNamedChild("HeaderContainer")
    self.scrollContainer = control:GetNamedChild("Container")
    self.scrollChild = self.scrollContainer:GetNamedChild("ScrollChild")
    self.mainTextLabel = self.scrollChild:GetNamedChild("MainText")
    local backKeybindLabel = control:GetNamedChild("BackKeybind")
    if backKeybindLabel then
        local keybindLabelText = zo_strformat(SI_GAMEPAD_BACK_OPTION)
        backKeybindLabel:SetText(keybindLabelText)
    end

    self:InitializeDialog(control)
    self:BuildDialogInfo()
    ZO_Dialogs_RegisterCustomDialog("CHAT_LOG_PRESERVER_LOG_DIALOG", self.dialogInfo)
end

function ChatLogPreserverLogDialog:InitializeDialog(dialog)
    dialog.fragment = ZO_FadeSceneFragment:New(dialog)
    if GenericGamepadDialog_OnInitialized then
        GenericGamepadDialog_OnInitialized(dialog)
    end
    if self.scrollContainer and self.scrollContainer.SetScrollIndicatorEnabled then
        self.scrollContainer:SetScrollIndicatorEnabled(true)
    end
end

function ChatLogPreserverLogDialog:BuildDialogInfo()
    self.dialogInfo = {
        setup = function(...) self:DialogSetupFunction(...) end,
        customControl = self.control,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.CUSTOM,
        },
        title = {
            text = "Chat Log Preserver",
        },
        mainText = {
            text = "",
        },
        buttons = {
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = function()
                    self:Hide()
                end,
            },
        },
    }
end

function ChatLogPreserverLogDialog:IsVisible()
    return self.control and not self.control:IsHidden()
end

function ChatLogPreserverLogDialog:IsScrolledToBottom()
    local scroll = self.scrollContainer and self.scrollContainer.scroll
    if not scroll then
        return true
    end

    local _, verticalOffset = scroll:GetScrollOffsets()
    local _, verticalExtents = scroll:GetScrollExtents()
    if verticalExtents <= 0 then
        return true
    end

    return verticalOffset >= (verticalExtents - 1)
end

function ChatLogPreserverLogDialog:ScrollToBottom()
    local scrollContainer = self.scrollContainer
    local scroll = scrollContainer and scrollContainer.scroll
    if not scroll then
        return
    end

    local _, verticalExtents = scroll:GetScrollExtents()
    if verticalExtents <= 0 then
        return
    end

    if ZO_ScrollAnimation_MoveWindow then
        scrollContainer.scrollValue = 100
        ZO_ScrollAnimation_MoveWindow(scrollContainer, scrollContainer.scrollValue)
    else
        scroll:SetVerticalScroll(verticalExtents)
    end

    if ZO_UpdateScrollFade and ZO_GetScrollMaxFadeGradientSize and ZO_SCROLL_DIRECTION_VERTICAL then
        ZO_UpdateScrollFade(scrollContainer.useFadeGradient, scroll, ZO_SCROLL_DIRECTION_VERTICAL,
            ZO_GetScrollMaxFadeGradientSize(scrollContainer))
    end
end

function ChatLogPreserverLogDialog:GetDialogMaxLines()
    local scroll = self.scrollContainer and self.scrollContainer.scroll
    if not scroll or not self.mainTextLabel then
        return self.maxDialogLines
    end

    local scrollHeight = scroll:GetHeight()
    local fontHeight = self.mainTextLabel:GetFontHeight()
    if not scrollHeight or scrollHeight <= 0 or not fontHeight or fontHeight <= 0 then
        return self.maxDialogLines
    end

    local paddingY = 8
    local availableHeight = math.max(0, scrollHeight - paddingY)
    local visibleLines = math.floor(availableHeight / fontHeight)
    if visibleLines <= 0 then
        return self.maxDialogLines
    end

    self.maxDialogLines = visibleLines
    return self.maxDialogLines
end

function ChatLogPreserverLogDialog:SetHistoryText(history, maxLines)
    if not self.mainTextLabel then
        return nil
    end

    local effectiveMaxLines = maxLines or self:GetDialogMaxLines()
    local newestFirst = true
    local text = ChatLogPreserver.Utils.BuildHistoryText(history, effectiveMaxLines, newestFirst)
    self.mainTextLabel:SetText(text)
    return effectiveMaxLines
end

function ChatLogPreserverLogDialog:CacheHistorySignature(history, maxLines)
    local count = history and #history or 0
    local lastEntry = count > 0 and history[count] or nil
    self.lastHistoryCount = count
    self.lastHistoryMessage = lastEntry and lastEntry.message or nil
    self.lastHistoryCategory = lastEntry and lastEntry.category or nil
    self.lastHistoryMaxLines = maxLines
end

function ChatLogPreserverLogDialog:HasHistoryChanged(history, maxLines)
    local count = history and #history or 0
    local lastEntry = count > 0 and history[count] or nil
    if self.lastHistoryCount ~= count then
        return true
    end
    if self.lastHistoryMessage ~= (lastEntry and lastEntry.message or nil) then
        return true
    end
    if self.lastHistoryCategory ~= (lastEntry and lastEntry.category or nil) then
        return true
    end
    if self.lastHistoryMaxLines ~= maxLines then
        return true
    end
    return false
end

function ChatLogPreserverLogDialog:RefreshHistory(history, scrollToBottom)
    ---@type number|nil
    local maxLines = self:GetDialogMaxLines()
    ---@type number|nil
    local updatedMaxLines = self:SetHistoryText(history, maxLines)
    if scrollToBottom then
        self:ScrollToBottom()
    end
    self:CacheHistorySignature(history, updatedMaxLines)
end

function ChatLogPreserverLogDialog:RefreshIfVisible(history)
    if not self:IsVisible() then
        return
    end
    ---@type number|nil
    local maxLines = self:GetDialogMaxLines()
    if not self:HasHistoryChanged(history, maxLines) then
        return
    end

    local shouldScrollToBottom = self:IsScrolledToBottom()
    ---@type number|nil
    local updatedMaxLines = self:SetHistoryText(history, maxLines)
    if shouldScrollToBottom then
        self:ScrollToBottom()
    end
    self:CacheHistorySignature(history, updatedMaxLines)
end

function ChatLogPreserverLogDialog:DialogSetupFunction(dialog)
    dialog.headerData.titleTextAlignment = TEXT_ALIGN_CENTER
    ZO_GamepadGenericHeader_Refresh(dialog.header, dialog.headerData)

    local savedVars = ChatLogPreserver.state and ChatLogPreserver.state.savedVars
    self:RefreshHistory(savedVars and savedVars.history, true)
end

function ChatLogPreserverLogDialog:Show()
    ShowGamepadDialog("CHAT_LOG_PRESERVER_LOG_DIALOG", nil, nil)
end

function ChatLogPreserverLogDialog:Hide()
    ReleaseDialog("CHAT_LOG_PRESERVER_LOG_DIALOG", nil, nil)
end

function ChatLogPreserverLogDialog_OnInitialized(control)
    ChatLogPreserver.LogDialog = ChatLogPreserverLogDialog:New(control)
end
