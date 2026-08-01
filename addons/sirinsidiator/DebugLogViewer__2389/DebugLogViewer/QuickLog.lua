local DLV = DebugLogViewer
local LDL = LibDebugLogger

local internal = DLV.internal
local gettext = internal.gettext
local osdate = os.date
local PrepareOutput = internal.PrepareOutput

local FADE_MODE_TIMER = internal.FADE_MODE_TIMER
local FADE_MODE_VISIBLE = internal.FADE_MODE_VISIBLE
local FADE_MODE_HIDDEN = internal.FADE_MODE_HIDDEN

local FADE_IN_DURATION = 350

local FONT_FACE = ZoFontChat:GetFontInfo()
local FONT_TEMPLATE = ("%s|%%d|%s"):format(FONT_FACE, "soft-shadow-thin")
local LOG_LINK_TYPE = "logdetail"
local LOG_FORMAT = "|H0:%s:%d|h[%s] [%s] |h%s"
local TIME_FORMAT = "%T.%%03.0f"


local QuickLog = ZO_Object:Subclass()
internal.class.QuickLog = QuickLog

function QuickLog:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function QuickLog:Initialize(saveData)
    local window = DebugLogWindow

    self.control = window
    self.saveData = saveData
    window.container = self
    self.buffer = window:GetNamedChild("Buffer")
    self.background = window:GetNamedChild("Bg")

    local scrollbar = window:GetNamedChild("Scrollbar")
    self.scrollbar = scrollbar
    self.scrollUpButton = scrollbar:GetNamedChild("ScrollUp")
    self.scrollDownButton = scrollbar:GetNamedChild("ScrollDown")
    self.scrollEndButton = scrollbar:GetNamedChild("ScrollEnd")

    scrollbar.container = self
    self:LoadPosition(saveData)

    local function savePosition() self:SavePosition() end
    window.OnResizeStop = savePosition
    window.OnMoveStop = savePosition
    window.OnMouseWheel = function(...) self:OnMouseWheel(...) end
    window.OnMouseEnter = function()
        self:OnMouseEnter()
    end
    window.OnLinkMouseUp = function(control, linkData, linkText, button, ctrl, alt, shift, command)
        local _, _, linkType, id = ZO_LinkHandler_ParseLink(linkText)
        if(linkType == LOG_LINK_TYPE)then
            PlaySound(SOUNDS["DEFAULT_CLICK"])
            internal:FireCallbacks("OpenLogDetails", tonumber(id))
        else
            ZO_LinkHandler_OnLinkMouseUp(linkText, button, control)
        end
    end
    window.OnScrollBarChanged = function(control, value, eventReason)
        if eventReason == EVENT_REASON_HARDWARE then
            self:SetScroll(value)
        end
    end
    window.ScrollByOffset = function(control, offset)
        self:ScrollByOffset(offset)
    end
    window.ScrollToBottom = function() self:ScrollToBottom() end
    window.ShowMenu = function() self:OnMenuClicked() end

    if(self:IsLocked()) then
        self:Lock()
    else
        self:Unlock()
    end

    self:SetFontSize(saveData.quickLog.fontSize)
    self:SetHistoryLength(saveData.quickLog.historyLength)
    self:UpdateBackgroundFade()
    self:UpdateLineFade()
    self:SyncScrollToBuffer()

    self.pendingEntries = {}
    self.flushPendingEntries = function()
        for i = 1, #self.pendingEntries do
            self:AddEntry(self.pendingEntries[i])
        end
        ZO_ClearNumericallyIndexedTable(self.pendingEntries)
        self.pendingHandler = nil
    end

    self.filter = internal.class.LogFilter:New()
    self.filter:SetStartTime(LDL:GetSessionStartTime())
    self.filter:SetTagFilter(saveData.quickLog.tagFilter)
    self.filter:SetLevelFilter(saveData.quickLog.levelFilter)
    self.filter:SetTagFilterBlacklist(true)
end

function QuickLog:ShouldRefresh()
    local saveData = self.saveData
    return saveData.quickLog.lineFade.mode == internal.FADE_MODE_TIMER and saveData.quickLog.lineFade.clearBuffer
end

function QuickLog:SetFontSize(size)
    self.buffer:SetFont(FONT_TEMPLATE:format(size))
end

function QuickLog:SetHistoryLength(lines)
    self.buffer:SetMaxHistoryLines(lines)
end

function QuickLog:UpdateBackgroundFade()
    local fade = self.saveData.quickLog.backgroundFade

    if(fade.mode == FADE_MODE_HIDDEN) then
        self.background:SetAlpha(0)
    else
        self.background:SetAlpha(1)
    end

    if(fade.mode == FADE_MODE_TIMER) then
        self.control:SetAlpha(0)
    else
        self.control:SetAlpha(1)
    end
end

function QuickLog:UpdateLineFade()
    local delay, duration
    local fade = self.saveData.quickLog.lineFade
    if(fade.mode == FADE_MODE_TIMER) then
        delay = fade.timeout
        duration = fade.duration
    end
    self.buffer:SetLineFade(delay, duration)
    self.buffer:SetClearBufferAfterFadeout(fade.clearBuffer)
end

function QuickLog:LoadPosition()
    local control, saveData = self.control, self.saveData
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saveData.quickLog.window.x, saveData.quickLog.window.y)
    control:SetDimensions(saveData.quickLog.window.width, saveData.quickLog.window.height)
    control:SetHidden(not saveData.quickLog.enabled)
end

function QuickLog:ResetPosition()
    local control, saveData = self.control, self.saveData
    local defaultData = internal.DEFAULT_SETTINGS
    saveData.quickLog.window.x, saveData.quickLog.window.y = defaultData.quickLog.window.x, defaultData.quickLog.window.y
    saveData.quickLog.window.width, saveData.quickLog.window.height = defaultData.quickLog.window.width, defaultData.quickLog.window.height
    self:LoadPosition()
end

function QuickLog:SavePosition()
    local control, saveData = self.control, self.saveData
    saveData.quickLog.window.x, saveData.quickLog.window.y = control:GetScreenRect()
    saveData.quickLog.window.width, saveData.quickLog.window.height = control:GetDimensions()
end

function QuickLog:SetScroll(value)
    local max = self:GetCurrentMaxScroll()

    self.scrollbar:SetValue(value)
    self.buffer:SetScrollPosition(max - value)

    self:UpdateScrollButtons()
end

function QuickLog:ScrollByOffset(offset)
    self:SetScroll(self.scrollbar:GetValue() + offset)
end

function QuickLog:ScrollToBottom()
    self:SetScroll(self:GetCurrentMaxScroll())
end

function QuickLog:GetCurrentMaxScroll()
    return self.buffer:GetNumHistoryLines()
end

function QuickLog:UpdateScrollVisibility()
    local visible = self.buffer:GetNumVisibleLines()
    local history = self.buffer:GetNumHistoryLines()
    local hide = history <= visible

    self.scrollbar:SetHidden(hide)
    self.scrollUpButton:SetHidden(hide)
    self.scrollDownButton:SetHidden(hide)
    self.scrollEndButton:SetHidden(hide)
end

function QuickLog:SyncScrollToBuffer()
    local max = self:GetCurrentMaxScroll()

    self.scrollbar:SetMinMax(1, max)
    self.scrollbar:SetValue(max - self.buffer:GetScrollPosition())

    self:UpdateScrollVisibility()
    self:UpdateScrollButtons()
end

local function GetNewScrollButtonState(scrollButton, disabled)
    if disabled then
        return BSTATE_DISABLED, disabled
    end

    local currentState = scrollButton:GetState()
    if currentState == BSTATE_DISABLED or currentState == BSTATE_DISABLED_PRESSED then
        return BSTATE_NORMAL, disabled
    end

    return currentState, disabled
end

function QuickLog:UpdateScrollButtons()
    local max = self:GetCurrentMaxScroll()
    local value = zo_round(self.scrollbar:GetValue())

    local enabled = max > 1

    if not enabled then
        --force the scroll bar to look like its at the bottom
        self.scrollbar:SetMinMax(0, 1)
        self.scrollbar:SetValue(1)
    end

    self.scrollbar:SetEnabled(enabled)

    local upDisabled = not enabled or value == 1
    self.scrollUpButton:SetState(GetNewScrollButtonState(self.scrollUpButton, upDisabled))

    local downDisabled = not enabled or value == max
    self.scrollDownButton:SetState(GetNewScrollButtonState(self.scrollDownButton, downDisabled))
    self.scrollEndButton:SetState(GetNewScrollButtonState(self.scrollEndButton, downDisabled))
end

function QuickLog:MonitorForMouseExit()
    self.FadeOutCheckOnUpdate = self.FadeOutCheckOnUpdate or function()
        if(not MouseIsOver(self.control) and not self.resizing and not self.isDragging) then
            self.control:SetHandler("OnUpdate", nil)
            self:OnMouseExit()
        else
            self.buffer:ShowFadedLines()
        end
    end

    self.control:SetHandler("OnUpdate", self.FadeOutCheckOnUpdate)
end

function QuickLog:OnMouseEnter()
    self:FadeIn()
    self.buffer:ShowFadedLines()
    self:MonitorForMouseExit()
end

function QuickLog:OnMouseExit()
    if(self.fadeAnim) then
        self.fadeAnim:Stop()
    end
    self:FadeOut()
end

function QuickLog:GetFadeAnimation()
    if(self.saveData.quickLog.backgroundFade.mode == FADE_MODE_VISIBLE) then return end

    if(not self.fadeAnim) then
        self.fadeAnim = ZO_AlphaAnimation:New(self.control)
    end

    return self.fadeAnim
end

function QuickLog:FadeOut(delay)
    local fadeAnimation = self:GetFadeAnimation()
    if(fadeAnimation) then
        fadeAnimation:SetMinMaxAlpha(0, 1)
        fadeAnimation:FadeOut(delay or self.saveData.quickLog.backgroundFade.timeout * 1000, self.saveData.quickLog.backgroundFade.duration * 1000)
    end
end

function QuickLog:FadeIn(delay, fadeOption)
    local fadeAnimation = self:GetFadeAnimation()
    if(fadeAnimation) then
        self.fadeAnim:SetMinMaxAlpha(0, 1)
        self.fadeAnim:FadeIn(delay or 0, FADE_IN_DURATION, fadeOption)
    end
end

function QuickLog:Show()
    self.control:SetHidden(false)
    self.saveData.quickLog.enabled = true
end

function QuickLog:Hide()
    self.control:SetHidden(true)
    self.saveData.quickLog.enabled = false
end

function QuickLog:IsShowing()
    return not self.control:IsHidden()
end

function QuickLog:OnMouseWheel(control, delta, ctrl, alt, shift)
    local buffer = self.buffer

    if shift then
        delta = delta * buffer:GetNumVisibleLines()
    elseif ctrl then
        delta = delta * buffer:GetNumHistoryLines()
    end

    self:ScrollByOffset(-delta)
end

function QuickLog:AddPendingEntry(entry)
    self.pendingEntries[#self.pendingEntries + 1] = entry
    if(not self.pendingHandler) then
        self.pendingHandler = zo_callLater(self.flushPendingEntries, 0)
    end
end

function QuickLog:AddEntry(entry)
    local time, formattedTime, count, level, tag, message, trace = unpack(entry.log)
    -- check filter for 'false' instead of using 'not', to double as a validation of the log level
    if(self.filter:ShouldShow(time, level, tag, message)) then
        local r, g, b = self:GetLevelColor(level)
        formattedTime = self:FormatTime(time)
        message = PrepareOutput(message)
        message = LOG_FORMAT:format(LOG_LINK_TYPE, entry.id, formattedTime, tag, message)
        self:AddMessage(message, r, g, b)
    end
end

function QuickLog:GetLevelColor(level)
    local color = self.saveData.quickLog.color[level]
    return unpack(color)
end

function QuickLog:GetFirstIndex(length)
    return math.max(1, length - self.saveData.quickLog.historyLength)
end

function QuickLog:FormatTime(timestamp)
    return osdate(TIME_FORMAT, timestamp / 1000):format(timestamp % 1000)
end

function QuickLog:AddMessage(message, r, g, b, colorId)
    self.buffer:AddMessage(message, r or 1, g or 1, b or 1, colorId)
    self:SyncScrollToBuffer() -- TODO don't sync on each message when bulk filling the buffer
end

function QuickLog:Clear()
    self.buffer:Clear()
end

function QuickLog:IsLocked()
    return self.saveData.quickLog.window.locked
end

function QuickLog:Lock()
    self.saveData.quickLog.window.locked = true
    self.control:SetMovable(false)
    self.control:SetResizeHandleSize(0)
end

function QuickLog:Unlock()
    self.saveData.quickLog.window.locked = false
    self.control:SetMovable(true)
    self.control:SetResizeHandleSize(5)
end

function QuickLog:OnMenuClicked()
    ClearMenu()

    -- TRANSLATORS: Menu entry in the settings context menu of the quick log
    AddCustomMenuItem(gettext("Toggle Log Viewer"), DLV.ToggleWindow)

    -- TRANSLATORS: Menu entry in the settings context menu of the quick log
    AddCustomMenuItem(gettext("Hide Quick Log"), function() self:Hide() end)

    if(self:IsLocked()) then
        -- TRANSLATORS: Menu entry in the settings context menu of the quick log
        AddCustomMenuItem(gettext("Unlock Position"), function() self:Unlock() end)
    else
        -- TRANSLATORS: Menu entry in the settings context menu of the quick log
        AddCustomMenuItem(gettext("Lock Position"), function() self:Lock() end)
        -- TRANSLATORS: Menu entry in the settings context menu of the quick log
        AddCustomMenuItem(gettext("Reset Position"), function() self:ResetPosition() end)
    end

    -- TRANSLATORS: Menu entry in the settings context menu of the quick log
    AddCustomMenuItem(gettext("Open Settings"), function() internal:FireCallbacks(internal.callback.OPEN_SETTINGS) end)

    ShowMenu(optionsButton)
end
