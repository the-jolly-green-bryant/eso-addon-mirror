Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local T = Internal.T
local MAIN_WINDOW_DEFAULT_WIDTH = Internal.MAIN_WINDOW_DEFAULT_WIDTH
local MAIN_WINDOW_DEFAULT_HEIGHT = Internal.MAIN_WINDOW_DEFAULT_HEIGHT
local TRACKING_SCOPE_CHOICES = Internal.TRACKING_SCOPE_CHOICES
local CHAMPION_POINTS_SCENE_NAMES = Internal.CHAMPION_POINTS_SCENE_NAMES
local SAVED_VAR_DEFAULTS = Internal.SAVED_VAR_DEFAULTS
local DROP_LOG_MAX_ENTRIES = Internal.DROP_LOG_MAX_ENTRIES
local DROP_LOG_MAX_VISIBLE_ROWS = Internal.DROP_LOG_MAX_VISIBLE_ROWS
local DROP_LOG_DEFAULT_WIDTH = Internal.DROP_LOG_DEFAULT_WIDTH
local DROP_LOG_DEFAULT_HEIGHT = Internal.DROP_LOG_DEFAULT_HEIGHT
local DROP_LOG_MIN_WIDTH = Internal.DROP_LOG_MIN_WIDTH
local DROP_LOG_MIN_HEIGHT = Internal.DROP_LOG_MIN_HEIGHT
local DROP_LOG_MAX_WIDTH = Internal.DROP_LOG_MAX_WIDTH
local DROP_LOG_MAX_HEIGHT = Internal.DROP_LOG_MAX_HEIGHT
local DEFAULT_DROP_ASK_MESSAGE = Internal.DEFAULT_DROP_ASK_MESSAGE
local DROP_LOG_PAGE_FILTER_ALL = Internal.DROP_LOG_PAGE_FILTER_ALL
local DROP_LOG_PAGE_FILTER_ALL_DROPS = Internal.DROP_LOG_PAGE_FILTER_ALL_DROPS
local DROP_LOG_DEFAULT_OPACITY = Internal.DROP_LOG_DEFAULT_OPACITY
local DROP_LOG_TEXT_SIZES = Internal.DROP_LOG_TEXT_SIZES
local DEFAULT_DROP_LOG_TEXT_SIZE_INDEX = Internal.DEFAULT_DROP_LOG_TEXT_SIZE_INDEX
local DROP_LOG_TEXT_SIZE_VERSION = Internal.DROP_LOG_TEXT_SIZE_VERSION
local DEFAULT_FONT_NAME = Internal.DEFAULT_FONT_NAME
local TEXT_PROMPT_SIZE_LABELS = Internal.TEXT_PROMPT_SIZE_LABELS
local TEXT_PROMPT_SIZE_BY_KEY = Internal.TEXT_PROMPT_SIZE_BY_KEY
local TEXT_PROMPT_COLOR_LABELS = Internal.TEXT_PROMPT_COLOR_LABELS
local TEXT_PROMPT_COLOR_BY_KEY = Internal.TEXT_PROMPT_COLOR_BY_KEY
local FONT_OPTION_BY_LABEL = Internal.FONT_OPTION_BY_LABEL
local TAMRIEL_TOMES_CONTROL_NAMES = Internal.TAMRIEL_TOMES_CONTROL_NAMES
local TAMRIEL_TOMES_SCENE_NAMES = {
    "TamrielTomesSceneKeyboard",
    "TamrielTomesIntroSceneKeyboard",
    "TamrielTomesPurchaseSceneKeyboard",
}
local DROP_LOG_TRAIT_FILTERS = Internal.DROP_LOG_TRAIT_FILTERS
local COLORS = Internal.COLORS
local CallControlMethod = Internal.CallControlMethod
local GetControlDimension = Internal.GetControlDimension
local AllowMultilineLabelText = Internal.AllowMultilineLabelText
local SetBackdropStyle = Internal.SetBackdropStyle
local SetButtonText = Internal.SetButtonText
local SetSimpleTooltip = Internal.SetSimpleTooltip
local AddDropListButtonIcon = Internal.AddDropListButtonIcon
local AddResizeGripIcon = Internal.AddResizeGripIcon
local SafeAnnounce = Internal.SafeAnnounce
local TrimText = Internal.TrimText
local BuildFontString = Internal.BuildFontString
local StyleTransparentTextButton = Internal.StyleTransparentTextButton

local function GetDropListColorCode(color)
    color = color or COLORS.gold
    local red = math.max(0, math.min(255, math.floor(((color[1] or 1) * 255) + 0.5)))
    local green = math.max(0, math.min(255, math.floor(((color[2] or 1) * 255) + 0.5)))
    local blue = math.max(0, math.min(255, math.floor(((color[3] or 1) * 255) + 0.5)))
    return string.format("|c%02X%02X%02X", red, green, blue)
end

local DROP_LOG_WANTED_TEXT_COLOR = GetDropListColorCode(COLORS.gold)
local DROP_LOG_TEXT_RESET = "|r"

local function SetDropListActionButtonTextColor(button, color)
    if not button then return end
    color = color or COLORS.text
    CallControlMethod(button, "SetNormalFontColor", color[1], color[2], color[3], color[4])
    CallControlMethod(button, "SetMouseOverFontColor", 1, 0.95, 0.72, 1)
    CallControlMethod(button, "SetPressedFontColor", COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1)
end

function Greed:InitializeDropLogSettings()
    if type(self.savedVars.dropLog) ~= "table" then
        self.savedVars.dropLog = {}
    end

    if type(self.savedVars.dropLog.entries) ~= "table" then
        self.savedVars.dropLog.entries = {}
    end
    while #self.savedVars.dropLog.entries > DROP_LOG_MAX_ENTRIES do
        table.remove(self.savedVars.dropLog.entries)
    end

    if type(self.savedVars.dropLog.askMessage) ~= "string" or self.savedVars.dropLog.askMessage == "" then
        self.savedVars.dropLog.askMessage = DEFAULT_DROP_ASK_MESSAGE
    end

    if type(self.savedVars.dropLog.width) ~= "number" then
        self.savedVars.dropLog.width = DROP_LOG_DEFAULT_WIDTH
    end
    if type(self.savedVars.dropLog.height) ~= "number" then
        self.savedVars.dropLog.height = DROP_LOG_DEFAULT_HEIGHT
    end
    if type(self.savedVars.dropLog.textSize) ~= "number" then
        self.savedVars.dropLog.textSize = DEFAULT_DROP_LOG_TEXT_SIZE_INDEX
    elseif self.savedVars.dropLog.textSizeVersion ~= DROP_LOG_TEXT_SIZE_VERSION then
        local oldIndex = math.floor(self.savedVars.dropLog.textSize)
        if oldIndex == 1 then
            self.savedVars.dropLog.textSize = 2
        elseif oldIndex == 2 then
            self.savedVars.dropLog.textSize = 3
        elseif oldIndex == 3 then
            self.savedVars.dropLog.textSize = 4
        else
            self.savedVars.dropLog.textSize = DEFAULT_DROP_LOG_TEXT_SIZE_INDEX
        end
        self.savedVars.dropLog.textSizeVersion = DROP_LOG_TEXT_SIZE_VERSION
    else
        self.savedVars.dropLog.textSizeVersion = DROP_LOG_TEXT_SIZE_VERSION
    end
    if type(self.savedVars.dropLog.scrollOffset) ~= "number" then
        self.savedVars.dropLog.scrollOffset = 0
    end
    if type(self.savedVars.dropLog.opacity) ~= "number" then
        self.savedVars.dropLog.opacity = DROP_LOG_DEFAULT_OPACITY
    end
    if type(self.savedVars.dropLog.fontName) ~= "string" or not FONT_OPTION_BY_LABEL[self.savedVars.dropLog.fontName] then
        self.savedVars.dropLog.fontName = DEFAULT_FONT_NAME
    end
    if type(self.savedVars.dropLog.traitFilters) ~= "table" then
        self.savedVars.dropLog.traitFilters = {}
    end
    if type(self.savedVars.dropLog.pageFilterName) ~= "string" or self.savedVars.dropLog.pageFilterName == "" then
        self.savedVars.dropLog.pageFilterName = DROP_LOG_PAGE_FILTER_ALL_DROPS
    end

    local pageFilter = self.savedVars.dropLog.pageFilterName
    local specialDropLogFilter = pageFilter == DROP_LOG_PAGE_FILTER_ALL or pageFilter == DROP_LOG_PAGE_FILTER_ALL_DROPS
    if not specialDropLogFilter and not self:GetPageDataByName(pageFilter) then
        self.savedVars.dropLog.pageFilterName = DROP_LOG_PAGE_FILTER_ALL_DROPS
    end

    self.savedVars.dropLog.width = math.max(DROP_LOG_MIN_WIDTH, math.min(DROP_LOG_MAX_WIDTH, self.savedVars.dropLog.width))
    self.savedVars.dropLog.height = math.max(DROP_LOG_MIN_HEIGHT, math.min(DROP_LOG_MAX_HEIGHT, self.savedVars.dropLog.height))
    self.savedVars.dropLog.textSize = math.max(1, math.min(#DROP_LOG_TEXT_SIZES, math.floor(self.savedVars.dropLog.textSize)))
    self.savedVars.dropLog.textSizeVersion = DROP_LOG_TEXT_SIZE_VERSION
    self.savedVars.dropLog.scrollOffset = math.max(0, math.floor(self.savedVars.dropLog.scrollOffset or 0))
    self.savedVars.dropLog.opacity = math.max(0, math.min(0.95, self.savedVars.dropLog.opacity or DROP_LOG_DEFAULT_OPACITY))
    if type(self.savedVars.dropLog.enabled) ~= "boolean" then
        self.savedVars.dropLog.enabled = true
    end
    self.savedVars.dropLog.onlyMissing = self.savedVars.dropLog.onlyMissing ~= false
    self.savedVars.dropLog.hideInMenus = self.savedVars.dropLog.hideInMenus ~= false
    self.savedVars.dropLog.trackGroupLoot = self.savedVars.dropLog.trackGroupLoot ~= false
    self.savedVars.dropLog.showAccountNames = self.savedVars.dropLog.showAccountNames == true
    self.savedVars.dropLog.debugLoot = self.savedVars.dropLog.debugLoot == true
    self.savedVars.dropLog.locked = self.savedVars.dropLog.locked == true
    self.savedVars.dropLog.currentPageOnly = self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL and self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL_DROPS
end


function Greed:ShouldProcessDropLoot()
    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()

    return self.savedVars.dropLog.enabled == true or self:IsPromptEnabled("drop")
end


function Greed:GetDropLogTextSizeData()
    self:InitializeDropLogSettings()
    local index = self.savedVars.dropLog.textSize or 2
    index = math.max(1, math.min(#DROP_LOG_TEXT_SIZES, math.floor(index)))
    self.savedVars.dropLog.textSize = index
    local sizeData = self:CopyTable(DROP_LOG_TEXT_SIZES[index])
    sizeData.font = BuildFontString(self.savedVars.dropLog.fontName, sizeData.size or 16)
    sizeData.titleFont = BuildFontString(self.savedVars.dropLog.fontName, 18, "soft-shadow-thick")
    sizeData.smallFont = BuildFontString(self.savedVars.dropLog.fontName, 14)
    return sizeData, index
end

function Greed:GetDropListFont(size)
    self:InitializeDropLogSettings()
    return BuildFontString(self.savedVars.dropLog.fontName, size or 16)
end

function Greed:ApplyDropListFont()
    local controls = self.dropListControls
    if not controls then return end

    local textSize = self:GetDropLogTextSizeData()
    local rowFont = textSize.font or BuildFontString(self.savedVars.dropLog.fontName, 16)
    local smallFont = textSize.smallFont or BuildFontString(self.savedVars.dropLog.fontName, 14)
    local titleFont = textSize.titleFont or BuildFontString(self.savedVars.dropLog.fontName, 18, "soft-shadow-thick")

    if controls.title then controls.title:SetFont(titleFont) end
    if controls.subtitle then controls.subtitle:SetFont(smallFont) end
    if controls.emptyLabel then controls.emptyLabel:SetFont(rowFont) end

    local buttonFont = BuildFontString(self.savedVars.dropLog.fontName, math.max(14, (textSize.size or 16) - 1))
    local titleButtonFont = BuildFontString(self.savedVars.dropLog.fontName, 16)
    for _, button in ipairs({ controls.settingsButton, controls.clearButton, controls.closeButton }) do
        CallControlMethod(button, "SetFont", titleButtonFont)
    end

    for _, rowControl in ipairs(controls.rows or {}) do
        if rowControl.text then rowControl.text:SetFont(rowFont) end
        for _, button in ipairs({ rowControl.itemButton, rowControl.messageButton, rowControl.removeButton }) do
            CallControlMethod(button, "SetFont", buttonFont)
        end
    end

    if self.fontDebug then
        SafeAnnounce("Greed font debug: applied Drop List font " .. tostring(self.savedVars.dropLog.fontName or DEFAULT_FONT_NAME) .. " -> " .. tostring(rowFont))
    end
end

function Greed:ChangeDropLogTextSize(delta)
    self:InitializeDropLogSettings()
    local current = self.savedVars.dropLog.textSize or 2
    local nextSize = math.max(1, math.min(#DROP_LOG_TEXT_SIZES, current + (delta or 0)))
    self.savedVars.dropLog.textSize = nextSize
    self:LayoutDropListWindow()
    self:ApplyDropListFont()
    self:RefreshDropListWindow()
    self:RefreshDropOptionsState()
end

function Greed:SaveDropListSize()
    local controls = self.dropListControls
    if not controls or not controls.window then return end

    self:InitializeDropLogSettings()
    local width = GetControlDimension(controls.window, "GetWidth", DROP_LOG_DEFAULT_WIDTH)
    local height = GetControlDimension(controls.window, "GetHeight", DROP_LOG_DEFAULT_HEIGHT)
    self.savedVars.dropLog.width = math.max(DROP_LOG_MIN_WIDTH, math.min(DROP_LOG_MAX_WIDTH, width))
    self.savedVars.dropLog.height = math.max(DROP_LOG_MIN_HEIGHT, math.min(DROP_LOG_MAX_HEIGHT, height))
end

function Greed:StartDropListResize(edge)
    self:InitializeDropLogSettings()
    if self.savedVars.dropLog.locked == true then return end

    local controls = self.dropListControls
    if not controls or not controls.window or not GetUIMousePosition then return end

    local mouseX, mouseY = GetUIMousePosition()
    self.dropListResize = {
        edge = edge or "right",
        startMouseX = mouseX or 0,
        startMouseY = mouseY or 0,
        startWidth = GetControlDimension(controls.window, "GetWidth", DROP_LOG_DEFAULT_WIDTH),
        startHeight = GetControlDimension(controls.window, "GetHeight", DROP_LOG_DEFAULT_HEIGHT),
        startLeft = controls.window:GetLeft() or 0,
        startTop = controls.window:GetTop() or 0,
    }

    controls.window:SetHandler("OnUpdate", function()
        self:UpdateDropListResize()
    end)
end

function Greed:UpdateDropListResize()
    local controls = self.dropListControls
    local resize = self.dropListResize
    if not controls or not controls.window or not resize or not GetUIMousePosition then return end

    local mouseX, mouseY = GetUIMousePosition()
    local deltaX = (mouseX or resize.startMouseX) - resize.startMouseX
    local deltaY = (mouseY or resize.startMouseY) - resize.startMouseY
    local nextWidth
    local nextLeft = resize.startLeft

    if resize.edge == "left" then
        nextWidth = resize.startWidth - deltaX
        nextWidth = math.max(DROP_LOG_MIN_WIDTH, math.min(DROP_LOG_MAX_WIDTH, nextWidth))
        nextLeft = resize.startLeft + (resize.startWidth - nextWidth)
    else
        nextWidth = resize.startWidth + deltaX
        nextWidth = math.max(DROP_LOG_MIN_WIDTH, math.min(DROP_LOG_MAX_WIDTH, nextWidth))
    end

    local nextHeight = resize.startHeight + deltaY
    nextHeight = math.max(DROP_LOG_MIN_HEIGHT, math.min(DROP_LOG_MAX_HEIGHT, nextHeight))

    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, nextLeft, resize.startTop)
    controls.window:SetDimensions(nextWidth, nextHeight)
    self:LayoutDropListWindow()
end

function Greed:StopDropListResize()
    local controls = self.dropListControls
    if controls and controls.window then
        controls.window:SetHandler("OnUpdate", nil)
        self:SaveWindowPosition(controls.window, "dropList")
    end

    self.dropListResize = nil
    self:SaveDropListSize()
    self:LayoutDropListWindow()
    self:RefreshDropListWindow()
end

function Greed:MakeDropListWindowMovable(window, titleBar, titleLabel)
    if self:RestoreWindowPosition(window, "dropList") ~= true then
        self:ApplyDefaultWindowPositionIfMissing(window, "dropList")
    end
    local startLeft, startTop

    local function onMouseDown(_, button)
        self:InitializeDropLogSettings()
        if self.savedVars.dropLog.locked == true then return end
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        startLeft = window:GetLeft() or 0
        startTop = window:GetTop() or 0
        self:StartMovingControl(window)
    end

    local function onMouseUp(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        self:StopMovingControl(window)
        self:SaveWindowPosition(window, "dropList")
    end

    for _, handle in ipairs({ titleBar, titleLabel }) do
        if handle then
            CallControlMethod(handle, "SetMouseEnabled", true)
            handle:SetHandler("OnMouseDown", onMouseDown)
            handle:SetHandler("OnMouseUp", onMouseUp)
        end
    end
end

function Greed:ToggleDropListWindow()
    self:CreateDropListWindow()

    local isVisible = self.dropListControls and self.dropListControls.window and not self.dropListControls.window:IsHidden()
    if isVisible then
        self:HideDropListWindow(true)
    else
        self.savedVars.dropLog.enabled = true
        self:ShowDropListWindow(true)
    end

    self:RefreshDropOptionsState()
end

function Greed:ActivateDropListMenuHide(now)
    self:InitializeDropLogSettings()
    self.dropLogAutoHiddenForMenu = true
    self.dropLogMenuHideActive = true
    self.dropLogMenuHideLastSeen = now or self:GetNowMilliseconds()
    self.dropLogMenuClearSince = nil
    self.dropLogMenuHideWasEnabled = self.savedVars.dropLog.enabled == true
    if self.dropListControls and self.dropListControls.window then
        self.dropListControls.window:SetHidden(true)
    end
end

function Greed:ClearDropListMenuHideState()
    self.dropLogAutoHiddenForMenu = false
    self.dropLogMenuHideActive = false
    self.dropLogMenuClearSince = nil
    self.dropLogMenuHideLastSeen = nil
    self.dropLogMenuHideWasEnabled = false
end

function Greed:SetDropListTemporaryHideReason(reason, active)
    if type(reason) ~= "string" or reason == "" then return end

    self.dropLogTemporaryHideReasons = self.dropLogTemporaryHideReasons or {}
    self.dropLogTemporaryHideReasons[reason] = active == true or nil
end

function Greed:HasDropListTemporaryHideReason()
    local reasons = self.dropLogTemporaryHideReasons
    if type(reasons) ~= "table" then return false end

    for _, active in pairs(reasons) do
        if active == true then
            return true
        end
    end

    return false
end

function Greed:IsDropListLocked()
    self:InitializeDropLogSettings()
    return self.savedVars.dropLog.locked == true
end

function Greed:IsDropListMenuSuppressed()
    self:InitializeDropLogSettings()
    if self.savedVars.dropLog.hideInMenus == false then
        local reasons = self.dropLogTemporaryHideReasons
        return type(reasons) == "table" and reasons.tamrielTomes == true
    end

    if self.dropLogMenuHideActive == true or self.dropLogAutoHiddenForMenu == true then
        return true
    end

    return self:HasDropListTemporaryHideReason()
end

function Greed:ShowDropListWindow(enableLog)
    self:CreateDropListWindow()

    if enableLog ~= false then
        self.savedVars.dropLog.enabled = true
        self.dropLogMenuHideUserClosed = false
    end

    local manualShow = enableLog == true
    local now = self:GetNowMilliseconds()
    self:RefreshDropListNativeMenuSuppression()
    self:UpdateTamrielTomesSuppression()
    local shouldHide = self:HasDropListTemporaryHideReason()

    if shouldHide then
        self:ActivateDropListMenuHide(now)
        if self.ttDebug then
            SafeAnnounce("Greed TT debug: ShowDropListWindow blocked by active menu suppression.")
        end
    else
        if manualShow then
            self:ClearDropListMenuHideState()
        end
        self.dropListControls.window:SetHidden(false)
    end
    self:RefreshDropListWindow()
    self:RefreshTamrielTomesFallbackPolling()
end

function Greed:HideDropListWindow(disableLog)
    if disableLog then
        self.savedVars.dropLog.enabled = false
        self.dropLogMenuHideUserClosed = true
        self:ClearDropListMenuHideState()
    end

    if self.dropListControls and self.dropListControls.window then
        self.dropListControls.window:SetHidden(true)
    end

    self:RefreshTamrielTomesFallbackPolling()
    self:RefreshDropOptionsState()
end


function Greed:ApplyDropListBackdropOpacity()
    local controls = self.dropListControls
    if not controls or not controls.backdrop then return end
    self:InitializeDropLogSettings()
    local opacity = self.savedVars.dropLog.opacity or DROP_LOG_DEFAULT_OPACITY
    SetBackdropStyle(controls.backdrop, { 0.010, 0.009, 0.007, opacity }, COLORS.edge)
end

function Greed:SetDropListOpacity(opacity)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.opacity = math.max(0, math.min(0.95, opacity or DROP_LOG_DEFAULT_OPACITY))
    self:ApplyDropListBackdropOpacity()
    self:RefreshDropOptionsState()
end

function Greed:ChangeDropListOpacity(delta)
    self:InitializeDropLogSettings()
    self:SetDropListOpacity((self.savedVars.dropLog.opacity or DROP_LOG_DEFAULT_OPACITY) + (delta or 0))
end

function Greed:GetDropListOpacityPercent()
    self:InitializeDropLogSettings()
    return math.floor(((self.savedVars.dropLog.opacity or DROP_LOG_DEFAULT_OPACITY) * 100) + 0.5)
end

function Greed:RefreshDropListLockIcon()
    local controls = self.dropListControls
    local lockButton = controls and controls.lockButton
    if not lockButton then return end

    self:InitializeDropLogSettings()
    local locked = self.savedVars.dropLog.locked == true

    if lockButton.greedLockIcon then
        local color = locked and COLORS.gold or COLORS.text
        lockButton.greedLockIcon:SetColor(color[1], color[2], color[3], 1)
    end
end

function Greed:SetDropListLocked(locked)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.locked = locked == true
    self:RefreshDropListLockIcon()
    self:LayoutDropListWindow()
    self:RefreshDropOptionsState()
end

function Greed:ToggleDropListLocked()
    self:InitializeDropLogSettings()
    self:SetDropListLocked(not (self.savedVars.dropLog.locked == true))
end

function Greed:GetDropLogPageFilterName()
    self:InitializeDropLogSettings()
    return self.savedVars.dropLog.pageFilterName or DROP_LOG_PAGE_FILTER_ALL_DROPS
end

function Greed:SetDropLogPageFilterName(pageName)
    self:InitializeDropLogSettings()
    if pageName ~= DROP_LOG_PAGE_FILTER_ALL and pageName ~= DROP_LOG_PAGE_FILTER_ALL_DROPS and not self:GetPageDataByName(pageName) then
        pageName = DROP_LOG_PAGE_FILTER_ALL_DROPS
    end
    self.savedVars.dropLog.pageFilterName = pageName or DROP_LOG_PAGE_FILTER_ALL_DROPS
    self.savedVars.dropLog.currentPageOnly = self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL and self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL_DROPS
    self.savedVars.dropLog.scrollOffset = 0
    self:BuildDropListPageDropdown()
    self:RefreshDropOptionsState()
    self:RefreshDropListWindow()
end

function Greed:BuildDropListPageDropdown()
    local controls = self.dropListControls
    if not controls or not controls.pageDropdown or not ZO_ComboBox_ObjectFromContainer then return end

    self:InitializeDropLogSettings()
    local comboBox = ZO_ComboBox_ObjectFromContainer(controls.pageDropdown)
    if not comboBox then return end
    if comboBox.SetSortsItems then comboBox:SetSortsItems(false) end
    if comboBox.ClearItems then comboBox:ClearItems() end

    comboBox:AddItem(comboBox:CreateItemEntry(T("All Pages"), function()
        self:SetDropLogPageFilterName(DROP_LOG_PAGE_FILTER_ALL)
    end))

    for _, pageName in ipairs(self:GetPageNames()) do
        local selectedPageName = pageName
        comboBox:AddItem(comboBox:CreateItemEntry(selectedPageName, function()
            self:SetDropLogPageFilterName(selectedPageName)
        end))
    end

    comboBox:AddItem(comboBox:CreateItemEntry(T("All Drops"), function()
        self:SetDropLogPageFilterName(DROP_LOG_PAGE_FILTER_ALL_DROPS)
    end))

    local selected = self:GetDropLogPageFilterName()
    local selectedLabel = selected
    if selected == DROP_LOG_PAGE_FILTER_ALL then
        selectedLabel = T("All Pages")
    elseif selected == DROP_LOG_PAGE_FILTER_ALL_DROPS then
        selectedLabel = T("All Drops")
    end
    comboBox:SetSelectedItem(selectedLabel)
    self:LiftDropListPageDropdown()
end

function Greed:LiftDropListPageDropdown()
    local controls = self.dropListControls
    if not controls or not controls.pageDropdown then return end

    CallControlMethod(controls.pageDropdown, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(controls.pageDropdown, "SetDrawTier", DT_HIGH)
    CallControlMethod(controls.pageDropdown, "SetDrawLevel", 900)

    if not ZO_ComboBox_ObjectFromContainer then return end
    local comboBox = ZO_ComboBox_ObjectFromContainer(controls.pageDropdown)
    if not comboBox then return end

    local possibleDropdowns = {
        comboBox.m_dropdown,
        comboBox.dropdown,
        comboBox.m_dropdownObject,
        comboBox.m_container,
    }

    if type(comboBox.GetDropdownObject) == "function" then
        table.insert(possibleDropdowns, comboBox:GetDropdownObject())
    end

    for _, dropdown in ipairs(possibleDropdowns) do
        CallControlMethod(dropdown, "SetDrawLayer", DL_OVERLAY)
        CallControlMethod(dropdown, "SetDrawTier", DT_HIGH)
        CallControlMethod(dropdown, "SetDrawLevel", 950)
    end
end

function Greed:DropLogEntryPassesPageFilter(entry, ownedItemIndex)
    local filterName = self:GetDropLogPageFilterName()
    if filterName == DROP_LOG_PAGE_FILTER_ALL_DROPS then
        return entry ~= nil
    end

    if filterName == DROP_LOG_PAGE_FILTER_ALL then
        return self:IsDropLogEntryWishlistMatched(entry) and self:DropLogEntryPassesWishlistNeedFilter(entry, ownedItemIndex)
    end

    return self:DropLogEntryMatchesPage(entry, filterName) and self:DropLogEntryPassesWishlistNeedFilter(entry, ownedItemIndex)
end

function Greed:IsDropLogEntryWishlistMatched(entry)
    if not entry then return false end
    if type(entry.matchedPages) == "table" then
        for pageName, matched in pairs(entry.matchedPages) do
            if type(pageName) == "string" and matched == true then
                return true
            end
        end
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        local match = self:FindDropLogWishlistMatch(entry.itemLink)
        if match and type(match.matchedPages) == "table" then
            entry.wishlistMatched = true
            entry.matchedPages = match.matchedPages
            entry.matchedPageList = match.matchedPageList
            entry.pageName = match.pageName
            entry.setName = match.setName
            entry.slotLabel = match.slotLabel
            return true
        end

        return false
    end

    if entry.wishlistMatched == true then return true end

    -- Older saved entries predate the explicit flag but always carried pageName for wishlist matches.
    return entry.wishlistMatched ~= false and type(entry.pageName) == "string" and entry.pageName ~= ""
end

function Greed:DropLogEntryMatchesPage(entry, pageName)
    if not entry or type(pageName) ~= "string" or pageName == "" then return false end

    if type(entry.matchedPages) == "table" then
        return entry.matchedPages[pageName] == true
    end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        local match = self:FindDropLogWishlistMatch(entry.itemLink)
        if match and type(match.matchedPages) == "table" then
            entry.wishlistMatched = true
            entry.matchedPages = match.matchedPages
            entry.matchedPageList = match.matchedPageList
            entry.pageName = match.pageName
            entry.setName = match.setName
            entry.slotLabel = match.slotLabel
            return entry.matchedPages[pageName] == true
        end

        return false
    end

    return entry.wishlistMatched ~= false and entry.pageName == pageName
end

function Greed:DropLogEntryPassesWishlistNeedFilter(entry, ownedItemIndex)
    self:InitializeDropLogSettings()
    if self.savedVars.dropLog.onlyMissing == false then return true end
    if not entry then return true end

    if type(entry.itemLink) == "string" and entry.itemLink ~= "" then
        local match = self:FindDropLogWishlistMatch(entry.itemLink)
        local isActuallyOwned, actualKnown, ownedCount, neededCount = self:GetActualOwnedStateForDropMatch(match, ownedItemIndex)
        if actualKnown then
            entry.collected = isActuallyOwned == true
            entry.collectionKnown = true
            entry.ownedCount = ownedCount
            entry.neededCount = neededCount
            return isActuallyOwned ~= true
        end
    end

    if entry.collectionKnown == true then
        return entry.collected ~= true
    end

    return true
end

function Greed:DropLogEntryPassesLooterFilter(entry)
    self:InitializeDropLogSettings()
    if self.savedVars.dropLog.trackGroupLoot ~= false then return true end
    return entry and entry.selfLoot == true
end

function Greed:GetCanonicalDropTraitName(traitName)
    local normalized = tostring(traitName or "")
    if normalized == "" or normalized == "trait unknown" then
        return "Unknown"
    end
    local lowerTrait = string.lower(normalized)
    for _, traitOption in ipairs(DROP_LOG_TRAIT_FILTERS) do
        if string.lower(traitOption.key) == lowerTrait or string.lower(traitOption.label) == lowerTrait then
            return traitOption.key
        end
    end
    return "Unknown"
end

function Greed:GetSelectedDropLogTraitFilterCount()
    self:InitializeDropLogSettings()
    local selected = 0
    local filters = self.savedVars.dropLog.traitFilters or {}
    for _, traitOption in ipairs(DROP_LOG_TRAIT_FILTERS) do
        if filters[traitOption.key] == true then
            selected = selected + 1
        end
    end
    return selected
end

function Greed:DropLogEntryPassesTraitFilter(entry)
    self:InitializeDropLogSettings()
    local selected = self:GetSelectedDropLogTraitFilterCount()
    if selected == 0 or selected >= #DROP_LOG_TRAIT_FILTERS then return true end

    local traitName = self:GetCanonicalDropTraitName(entry and entry.traitName or "Unknown")
    return self.savedVars.dropLog.traitFilters[traitName] == true
end

function Greed:SetDropLogTraitFilter(traitName, enabled)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.traitFilters[traitName] = enabled == true or nil
    self.savedVars.dropLog.scrollOffset = 0
    self:RefreshDropTraitFilterState()
    self:RefreshDropListWindow()
end

function Greed:SetAllDropLogTraitFilters(enabled)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.traitFilters = {}
    if enabled == true then
        for _, traitOption in ipairs(DROP_LOG_TRAIT_FILTERS) do
            self.savedVars.dropLog.traitFilters[traitOption.key] = true
        end
    end
    self.savedVars.dropLog.scrollOffset = 0
    self:RefreshDropTraitFilterState()
    self:RefreshDropListWindow()
end

function Greed:CreateDropTraitFilterWindow()
    if self.dropTraitControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedDropTraitFilterWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(420, 360)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 190, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 310)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedDropTraitFilterBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedDropTraitFilterTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(420, 42)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedDropTraitFilterTitle", window, CT_LABEL)
    title:SetDimensions(310, 24)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 12)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Trait Filter"))
    title:SetMouseEnabled(true)

    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropTraitFilterClose", window, "ZO_DefaultButton")
    closeButton:SetDimensions(34, 26)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 10)
    SetButtonText(closeButton, "X")
    closeButton:SetHandler("OnClicked", function()
        self:HideDropTraitFilterWindow()
    end)

    local help = WINDOW_MANAGER:CreateControl("GreedDropTraitFilterHelp", window, CT_LABEL)
    help:SetDimensions(380, 22)
    help:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 4)
    help:SetFont("ZoFontGameSmall")
    help:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    help:SetText(T("None selected or all selected = show all traits."))

    local allButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropTraitFilterAll", window, "ZO_DefaultButton")
    allButton:SetDimensions(80, 28)
    allButton:SetAnchor(TOPLEFT, help, BOTTOMLEFT, 0, 8)
    SetButtonText(allButton, T("All"))
    allButton:SetHandler("OnClicked", function()
        self:SetAllDropLogTraitFilters(true)
    end)

    local noneButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropTraitFilterNone", window, "ZO_DefaultButton")
    noneButton:SetDimensions(80, 28)
    noneButton:SetAnchor(LEFT, allButton, RIGHT, 8, 0)
    SetButtonText(noneButton, T("None"))
    noneButton:SetHandler("OnClicked", function()
        self:SetAllDropLogTraitFilters(false)
    end)

    local checkboxes = {}
    local startY = 112
    local columnWidth = 135
    local rowHeight = 24
    for index, traitOption in ipairs(DROP_LOG_TRAIT_FILTERS) do
        local column = math.floor((index - 1) / 9)
        local row = (index - 1) % 9
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropTraitFilter" .. index, window, "ZO_CheckButton")
        checkbox:SetAnchor(TOPLEFT, window, TOPLEFT, 18 + (column * columnWidth), startY + (row * rowHeight))
        if ZO_CheckButton_SetLabelText then
            ZO_CheckButton_SetLabelText(checkbox, traitOption.label)
        end
        if ZO_CheckButton_SetToggleFunction then
            local savedTraitName = traitOption.key
            ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                control.greedChecked = checked == true
                self:SetDropLogTraitFilter(savedTraitName, control.greedChecked)
            end)
        end
        checkboxes[traitOption.key] = checkbox
    end

    self.dropTraitControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        checkboxes = checkboxes,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "dropTraitFilter")
end

function Greed:RefreshDropTraitFilterState()
    local controls = self.dropTraitControls
    if not controls or not controls.checkboxes then return end
    self:InitializeDropLogSettings()
    for traitName, checkbox in pairs(controls.checkboxes) do
        self:SetEditCheckboxState(checkbox, self.savedVars.dropLog.traitFilters[traitName] == true)
    end
end

function Greed:ShowDropTraitFilterWindow()
    self:CreateDropTraitFilterWindow()
    self:RefreshDropTraitFilterState()
    self.dropTraitControls.window:SetHidden(false)
end

function Greed:HideDropTraitFilterWindow()
    if self.dropTraitControls and self.dropTraitControls.window then
        self.dropTraitControls.window:SetHidden(true)
    end
end

function Greed:ToggleDropTraitFilterWindow()
    self:CreateDropTraitFilterWindow()
    if self.dropTraitControls.window:IsHidden() then
        self:ShowDropTraitFilterWindow()
    else
        self:HideDropTraitFilterWindow()
    end
end

function Greed:IsShownGreedWindow(controlSet)
    return controlSet and controlSet.window and controlSet.window.IsHidden and not controlSet.window:IsHidden()
end

function Greed:HideShownGreedWindow(controlSet)
    if self:IsShownGreedWindow(controlSet) then
        controlSet.window:SetHidden(true)
        return true
    end
    return false
end

function Greed:CloseShownGreedWindow(controlSet, closeCallback)
    if not self:IsShownGreedWindow(controlSet) then return false end

    if type(closeCallback) == "function" then
        closeCallback()
    else
        controlSet.window:SetHidden(true)
    end

    return true
end

function Greed:IsEscapeKey(keyCode)
    if keyCode == nil then return false end
    if keyCode == KEY_ESCAPE or keyCode == 27 then return true end
    if type(keyCode) ~= "string" then return false end

    local shortcut = string.upper(keyCode)
    return shortcut == "KEY_ESCAPE"
        or shortcut == "ESCAPE"
        or shortcut == "UI_SHORTCUT_EXIT"
        or shortcut == "UI_SHORTCUT_NEGATIVE"
end

function Greed:CloseTopGreedWindowFromEscape()
    if self:CloseShownGreedWindow(self.genericConfirmControls, function() self:HideGenericConfirm() end) then return true end
    if self:CloseShownGreedWindow(self.dropListClearControls, function() self:HideDropListClearConfirm() end) then return true end
    if self:CloseShownGreedWindow(self.dropTraitControls, function() self:HideDropTraitFilterWindow() end) then return true end
    if self:CloseShownGreedWindow(self.dropOptionsControls, function() self:HideDropOptionsWindow() end) then return true end
    if self:CloseShownGreedWindow(self.sourcesToFarmControls, function() self:HideSourcesToFarmWindow() end) then return true end
    if self:CloseShownGreedWindow(self.setsOverviewControls, function() self:HideSetsOverviewWindow() end) then return true end
    if self:CloseShownGreedWindow(self.addControls, function() self:HideAddSetWindow() end) then return true end
    if self:CloseShownGreedWindow(self.editControls, function() self:HideEditTrackedPiecesWindow() end) then return true end
    if self:CloseShownGreedWindow(self.removeControls, function() self:HideRemoveFavoriteDialog() end) then return true end
    if self:CloseShownGreedWindow(self.movePageControls, function() self:HideMovePageDialog() end) then return true end
    if self:CloseShownGreedWindow(self.deletePageControls, function() self:HideDeletePageDialog() end) then return true end
    if self:CloseShownGreedWindow(self.pageNameControls, function() self:HidePageNameDialog() end) then return true end
    if self:CloseShownGreedWindow(self.antiquityControls, function() self:HideAntiquityLeadsWindow() end) then return true end
    if not self:IsDropListLocked() and self:CloseShownGreedWindow(self.dropListControls, function() self:HideDropListWindow(true) end) then return true end
    if self.controls and self.controls.window and self.controls.window.IsHidden and not self.controls.window:IsHidden() then
        self:HideWindow()
        return true
    end
    return false
end

function Greed:GetSceneName(sceneOrName)
    if type(sceneOrName) == "string" then return sceneOrName end
    if sceneOrName and type(sceneOrName.GetName) == "function" then
        local ok, name = pcall(function() return sceneOrName:GetName() end)
        if ok and type(name) == "string" then return name end
    end
    return ""
end

function Greed:IsChampionPointsSceneName(sceneOrName)
    local sceneName = string.lower(self:GetSceneName(sceneOrName) or "")
    for _, championSceneName in ipairs(CHAMPION_POINTS_SCENE_NAMES) do
        if sceneName == string.lower(championSceneName) then
            return true
        end
    end

    return false
end

function Greed:IsChampionPointsSceneOpen()
    if not SCENE_MANAGER then return false end

    if type(SCENE_MANAGER.IsShowing) == "function" then
        for _, sceneName in ipairs(CHAMPION_POINTS_SCENE_NAMES) do
            local ok, isShowing = pcall(function()
                return SCENE_MANAGER:IsShowing(sceneName)
            end)
            if ok and isShowing == true then
                return true
            end
        end
    end

    if type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local ok, scene = pcall(function()
            return SCENE_MANAGER:GetCurrentScene()
        end)
        if ok and self:IsChampionPointsSceneName(scene) then
            return true
        end
    end

    return false
end

function Greed:ShouldHideLauncherForCurrentScene()
    return self.championPointsSceneActive == true or self:HasLauncherTemporaryHideReason() or self:IsChampionPointsSceneOpen()
end

function Greed:RefreshLauncherVisibility()
    local launcher = self.controls and self.controls.launcher or GreedLauncher
    if not launcher then return end

    local shouldHide = self:ShouldHideLauncherForCurrentScene() == true
    if shouldHide then
        if self.launcherHiddenForScene ~= true then
            self.launcherWasHiddenBeforeScene = launcher:IsHidden() == true
        end
        self.launcherHiddenForScene = true
        launcher:SetHidden(true)
    elseif self.launcherHiddenForScene == true then
        self.launcherHiddenForScene = false
        if self.launcherWasHiddenBeforeScene ~= true then
            launcher:SetHidden(false)
        end
        self.launcherWasHiddenBeforeScene = nil
    end
end

function Greed:IsEscapeMenuScene(sceneOrName)
    local sceneName = string.lower(self:GetSceneName(sceneOrName) or "")
    return sceneName == "gamemenu"
        or sceneName == "gamemenuingame"
        or sceneName == "gamemenukeyboard"
        or sceneName == "gamepadgamemenu"
end

function Greed:IsSceneShowingState(state)
    return (SCENE_SHOWING ~= nil and state == SCENE_SHOWING)
        or (SCENE_SHOWN ~= nil and state == SCENE_SHOWN)
        or state == "showing"
        or state == "shown"
        or state == "SHOWING"
        or state == "SHOWN"
end

function Greed:IsSceneHiddenState(state)
    return (SCENE_HIDING ~= nil and state == SCENE_HIDING)
        or (SCENE_HIDDEN ~= nil and state == SCENE_HIDDEN)
        or state == "hiding"
        or state == "hidden"
        or state == "HIDING"
        or state == "HIDDEN"
end

function Greed:IsNativeEscapePriorityActive()
    if self:IsTamrielTomesShown() then return true end

    if type(IsMenuVisible) == "function" then
        local ok, visible = pcall(IsMenuVisible)
        if ok and visible == true then return true end
    end

    if type(ZO_Dialogs_IsShowingDialog) == "function" then
        local ok, showingDialog = pcall(ZO_Dialogs_IsShowingDialog)
        if ok and showingDialog == true then return true end
    end

    local inputControlNames = {
        "ZO_ChatWindowTextEntryEditBox",
        "ZO_ChatWindowTextEntry",
        "ChatWindowTextEntryEditBox",
    }

    for _, controlName in ipairs(inputControlNames) do
        local control = rawget(_G, controlName)
        if control and type(control.HasFocus) == "function" then
            local ok, hasFocus = pcall(function()
                return control:HasFocus()
            end)
            if ok and hasFocus == true then return true end
        end
    end

    return false
end

function Greed:HideEscapeMenuScene(sceneOrName)
    if not SCENE_MANAGER then return end

    local sceneName = self:GetSceneName(sceneOrName)
    if sceneName ~= "" and type(SCENE_MANAGER.Hide) == "function" then
        pcall(function()
            SCENE_MANAGER:Hide(sceneName)
        end)
    end
end

function Greed:CloseForEscapeMenuScene(sceneOrName)
    if not self:IsEscapeMenuScene(sceneOrName) then return false end

    local now = self:GetNowMilliseconds()
    local suppressActive = type(self.escapeMenuSuppressUntil) == "number" and now <= self.escapeMenuSuppressUntil

    if suppressActive then
        self:HideEscapeMenuScene(sceneOrName)
        return true
    end

    if self:IsNativeEscapePriorityActive() then return false end

    if self:CloseTopGreedWindowFromEscape() then
        self.escapeMenuSuppressUntil = now + 350
        self:HideEscapeMenuScene(sceneOrName)
        return true
    end

    return false
end

function Greed:HandleEscapeKey(...)
    return false
end

function Greed:EnableEscapeForWindow(window)
    if not window then return end

    -- Greed windows stay non-modal for Tamriel Tomes and other UI/addons.
    -- X buttons close Greed popups; Greed does not capture keyboard or Esc.
    CallControlMethod(window, "SetKeyboardEnabled", false)
    window:SetHandler("OnKeyDown", nil)
    window:SetHandler("OnKeyUp", nil)
end

function Greed:RegisterEscapeCloseHandler()
    self.escapeCloseRegistered = true
    self:RegisterDropListMenuSceneCallbacks()
end

function Greed:RefreshDropResizeHandles()
    -- Resize grips are static pixel-art controls now. Keep this hook so layout can
    -- refresh safely without carrying the temporary arrow-test machinery.
end

function Greed:CreateDropListWindow()
    if self.dropListControls then return end

    self:InitializeDropLogSettings()
    local savedWidth = self.savedVars.dropLog.width or DROP_LOG_DEFAULT_WIDTH
    local savedHeight = self.savedVars.dropLog.height or DROP_LOG_DEFAULT_HEIGHT

    local window = WINDOW_MANAGER:CreateControl("GreedDropListWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(savedWidth, savedHeight)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 260, 40)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 240)

    local function onMouseWheel(_, delta)
        self:ScrollDropList(delta)
    end
    window:SetHandler("OnMouseWheel", onMouseWheel)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedDropListBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetMouseEnabled(true)
    backdrop:SetHandler("OnMouseWheel", onMouseWheel)
    SetBackdropStyle(backdrop, { 0.010, 0.009, 0.007, self.savedVars.dropLog.opacity or DROP_LOG_DEFAULT_OPACITY }, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedDropListTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(savedWidth, 42)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)
    titleBar:SetHandler("OnMouseWheel", onMouseWheel)

    local title = WINDOW_MANAGER:CreateControl("GreedDropListTitle", window, CT_LABEL)
    title:SetDimensions(300, 26)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 12)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Greed Drop List"))
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseWheel", onMouseWheel)

    local subtitle = WINDOW_MANAGER:CreateControl("GreedDropListSubtitle", window, CT_LABEL)
    subtitle:SetDimensions(420, 20)
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 0)
    subtitle:SetFont("ZoFontGameSmall")
    subtitle:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    subtitle:SetText(T("Showing the 60 most recent log entries."))
    subtitle:SetMouseEnabled(true)
    subtitle:SetHandler("OnMouseWheel", onMouseWheel)

    local settingsButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListSettings", window, "ZO_DefaultButton")
    settingsButton:SetDimensions(70, 28)
    SetButtonText(settingsButton, T("Options"))
    StyleTransparentTextButton(settingsButton)
    settingsButton:SetHandler("OnClicked", function()
        self:ShowDropOptionsWindow()
    end)
    SetSimpleTooltip(settingsButton, T("Drop List Options"))

    local clearButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListClear", window, "ZO_DefaultButton")
    clearButton:SetDimensions(70, 28)
    SetButtonText(clearButton, T("Clear"))
    StyleTransparentTextButton(clearButton)
    clearButton:SetHandler("OnClicked", function()
        self:ShowDropListClearConfirm()
    end)
    SetSimpleTooltip(clearButton, T("Clear List Log"))

    local pageDropdown = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListPageDropdown", window, "ZO_ComboBox")
    pageDropdown:SetDimensions(150, 28)

    local traitFilterButton = WINDOW_MANAGER:CreateControl("GreedDropListTraitFilter", window, CT_CONTROL)
    traitFilterButton:SetDimensions(32, 32)
    traitFilterButton:SetMouseEnabled(true)
    AddDropListButtonIcon(traitFilterButton, "GreedDropListTraitFilter", "filter")
    traitFilterButton:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ToggleDropTraitFilterWindow()
        end
    end)
    SetSimpleTooltip(traitFilterButton, T("Filter Traits"))

    local lockButton = WINDOW_MANAGER:CreateControl("GreedDropListLock", window, CT_CONTROL)
    lockButton:SetDimensions(32, 32)
    lockButton:SetMouseEnabled(true)
    AddDropListButtonIcon(lockButton, "GreedDropListLock", "lock")
    lockButton:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ToggleDropListLocked()
        end
    end)
    SetSimpleTooltip(lockButton, function()
        self:InitializeDropLogSettings()
        return self.savedVars.dropLog.locked == true and T("Unlock Drop List") or T("Lock Drop List")
    end)

    local closeButton = WINDOW_MANAGER:CreateControl("GreedDropListClose", window, CT_CONTROL)
    closeButton:SetDimensions(32, 30)
    closeButton:SetMouseEnabled(true)
    AddDropListButtonIcon(closeButton, "GreedDropListClose", "close")
    closeButton:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:HideDropListWindow(true)
        end
    end)
    SetSimpleTooltip(closeButton, T("Close Drop List"))

    local emptyLabel = WINDOW_MANAGER:CreateControl("GreedDropListEmpty", window, CT_LABEL)
    emptyLabel:SetDimensions(savedWidth - 34, 24)
    emptyLabel:SetFont("ZoFontGame")
    emptyLabel:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    emptyLabel:SetText(T("No wishlist drops logged yet."))
    emptyLabel:SetMouseEnabled(true)
    emptyLabel:SetHandler("OnMouseWheel", onMouseWheel)

    local rows = {}
    for index = 1, DROP_LOG_MAX_VISIBLE_ROWS do
        local row = WINDOW_MANAGER:CreateControl("GreedDropListRow" .. index, window, CT_CONTROL)
        row:SetDimensions(savedWidth - 40, 30)
        row:SetHidden(true)
        row:SetMouseEnabled(true)
        row:SetHandler("OnMouseWheel", onMouseWheel)

        local bg = WINDOW_MANAGER:CreateControl("GreedDropListRow" .. index .. "Bg", row, CT_BACKDROP)
        bg:SetAnchorFill(row)
        bg:SetMouseEnabled(false)
        SetBackdropStyle(bg, index % 2 == 0 and COLORS.rowAlt or COLORS.row, COLORS.mutedEdge)

        local text = WINDOW_MANAGER:CreateControl("GreedDropListRow" .. index .. "Text", row, CT_LABEL)
        text:SetDimensions(savedWidth - 150, 24)
        text:SetAnchor(LEFT, row, LEFT, 8, 0)
        text:SetFont("ZoFontGameSmall")
        text:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
        text:SetMouseEnabled(true)
        text:SetHandler("OnMouseWheel", onMouseWheel)

        local askButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListRow" .. index .. "Ask", row, "ZO_DefaultButton")
        askButton:SetDimensions(1, 1)
        askButton:SetHidden(true)
        askButton:SetMouseEnabled(false)
        SetButtonText(askButton, "")

        local itemButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListRow" .. index .. "Item", row, "ZO_DefaultButton")
        itemButton:SetDimensions(46, 24)
        SetButtonText(itemButton, T("Link"))
        StyleTransparentTextButton(itemButton)
        SetSimpleTooltip(itemButton, T("Link in Chat"))

        local messageButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListRow" .. index .. "Msg", row, "ZO_DefaultButton")
        messageButton:SetDimensions(46, 24)
        SetButtonText(messageButton, T("Msg"))
        StyleTransparentTextButton(messageButton)
        SetSimpleTooltip(messageButton, T("Message Player"))

        local removeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListRow" .. index .. "Remove", row, "ZO_DefaultButton")
        removeButton:SetDimensions(28, 24)
        SetButtonText(removeButton, "X")
        StyleTransparentTextButton(removeButton)
        SetSimpleTooltip(removeButton, T("Clear Item"))

        rows[index] = {
            row = row,
            text = text,
            askButton = askButton,
            itemButton = itemButton,
            messageButton = messageButton,
            removeButton = removeButton,
        }
    end

    local resizeLeftGrip = WINDOW_MANAGER:CreateControl("GreedDropListResizeLeftGrip", window, CT_LABEL)
    resizeLeftGrip:SetDimensions(32, 28)
    resizeLeftGrip:SetFont("ZoFontGameLarge")
    resizeLeftGrip:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    resizeLeftGrip:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    resizeLeftGrip:SetText("")
    AddResizeGripIcon(resizeLeftGrip, "GreedDropListResizeLeftGrip", "left")
    resizeLeftGrip:SetMouseEnabled(true)
    resizeLeftGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartDropListResize("left")
        end
    end)
    resizeLeftGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopDropListResize()
        end
    end)

    local resizeRightGrip = WINDOW_MANAGER:CreateControl("GreedDropListResizeRightGrip", window, CT_LABEL)
    resizeRightGrip:SetDimensions(32, 28)
    resizeRightGrip:SetFont("ZoFontGameLarge")
    resizeRightGrip:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    resizeRightGrip:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    resizeRightGrip:SetText("")
    AddResizeGripIcon(resizeRightGrip, "GreedDropListResizeRightGrip", "right")
    resizeRightGrip:SetMouseEnabled(true)
    resizeRightGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartDropListResize("right")
        end
    end)
    resizeRightGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopDropListResize()
        end
    end)

    window:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self.dropListResize then
            self:StopDropListResize()
        end
    end)

    self.dropListControls = {
        window = window,
        backdrop = backdrop,
        titleBar = titleBar,
        title = title,
        subtitle = subtitle,
        settingsButton = settingsButton,
        clearButton = clearButton,
        pageDropdown = pageDropdown,
        traitFilterButton = traitFilterButton,
        lockButton = lockButton,
        closeButton = closeButton,
        emptyLabel = emptyLabel,
        rows = rows,
        resizeLeftGrip = resizeLeftGrip,
        resizeRightGrip = resizeRightGrip,
        visibleRowCount = DROP_LOG_MAX_VISIBLE_ROWS,
    }

    self:RefreshDropListLockIcon()
    self:LayoutDropListWindow()
    self:BuildDropListPageDropdown()
    self:MakeDropListWindowMovable(window, titleBar, title)
end

function Greed:LayoutDropListWindow()
    local controls = self.dropListControls
    if not controls or not controls.window then return end

    self:InitializeDropLogSettings()
    local width = math.max(DROP_LOG_MIN_WIDTH, math.min(DROP_LOG_MAX_WIDTH, GetControlDimension(controls.window, "GetWidth", DROP_LOG_DEFAULT_WIDTH)))
    local height = math.max(DROP_LOG_MIN_HEIGHT, math.min(DROP_LOG_MAX_HEIGHT, GetControlDimension(controls.window, "GetHeight", DROP_LOG_DEFAULT_HEIGHT)))
    local textSize = self:GetDropLogTextSizeData()
    local rowHeight = textSize.rowHeight or 31
    local rowGap = 2
    local margin = 6
    local contentTop = 60
    local bottomPadding = 6
    local rowWidth = math.max(300, width - (margin * 2))
    local availableHeight = math.max(rowHeight, height - contentTop - bottomPadding)
    local visibleRows = math.max(1, math.min(#(controls.rows or {}), math.floor(availableHeight / (rowHeight + rowGap))))

    controls.window:SetDimensions(width, height)
    controls.titleBar:SetDimensions(width, 40)
    controls.title:SetDimensions(math.max(120, width - 450), 24)
    controls.title:SetFont(textSize.titleFont or "ZoFontGameBold")
    controls.subtitle:SetDimensions(math.max(220, width - 24), 18)
    controls.subtitle:SetFont(textSize.smallFont or "ZoFontGameSmall")

    controls.closeButton:ClearAnchors()
    controls.closeButton:SetAnchor(TOPRIGHT, controls.window, TOPRIGHT, -8, 7)

    controls.pageDropdown:ClearAnchors()
    controls.pageDropdown:SetAnchor(TOPRIGHT, controls.closeButton, TOPLEFT, -4, 0)
    controls.pageDropdown:SetDimensions(150, 28)
    CallControlMethod(controls.pageDropdown, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(controls.pageDropdown, "SetDrawTier", DT_HIGH)
    CallControlMethod(controls.pageDropdown, "SetDrawLevel", 900)

    controls.clearButton:ClearAnchors()
    controls.clearButton:SetAnchor(RIGHT, controls.pageDropdown, LEFT, -4, 0)
    StyleTransparentTextButton(controls.clearButton)
    CallControlMethod(controls.clearButton, "SetDrawLayer", DL_TEXT)
    CallControlMethod(controls.clearButton, "SetDrawTier", DT_HIGH)
    CallControlMethod(controls.clearButton, "SetDrawLevel", 920)

    controls.settingsButton:ClearAnchors()
    controls.settingsButton:SetAnchor(RIGHT, controls.clearButton, LEFT, -4, 0)
    controls.settingsButton:SetDimensions(70, 28)
    StyleTransparentTextButton(controls.settingsButton)
    CallControlMethod(controls.settingsButton, "SetDrawLayer", DL_TEXT)
    CallControlMethod(controls.settingsButton, "SetDrawTier", DT_HIGH)
    CallControlMethod(controls.settingsButton, "SetDrawLevel", 920)

    controls.traitFilterButton:ClearAnchors()
    controls.traitFilterButton:SetAnchor(RIGHT, controls.settingsButton, LEFT, -4, 0)
    controls.traitFilterButton:SetDimensions(32, 32)

    controls.lockButton:ClearAnchors()
    controls.lockButton:SetAnchor(RIGHT, controls.traitFilterButton, LEFT, -4, 0)
    controls.lockButton:SetDimensions(32, 32)

    controls.emptyLabel:ClearAnchors()
    controls.emptyLabel:SetAnchor(TOPLEFT, controls.window, TOPLEFT, margin, contentTop)
    controls.emptyLabel:SetDimensions(rowWidth, rowHeight)
    controls.emptyLabel:SetFont(textSize.font or "ZoFontGame")

    for index, rowControl in ipairs(controls.rows or {}) do
        local row = rowControl.row
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, controls.window, TOPLEFT, margin, contentTop + ((index - 1) * (rowHeight + rowGap)))
        row:SetDimensions(rowWidth, rowHeight)
        CallControlMethod(row, "SetDrawLayer", DL_CONTROLS)
        CallControlMethod(row, "SetDrawTier", DT_LOW)
        CallControlMethod(row, "SetDrawLevel", 10)

        local buttonHeight = math.max(22, rowHeight - 4)
        rowControl.removeButton:ClearAnchors()
        rowControl.removeButton:SetAnchor(RIGHT, row, RIGHT, -4, 0)
        rowControl.removeButton:SetDimensions(28, buttonHeight)
        rowControl.removeButton:SetMouseEnabled(true)
        CallControlMethod(rowControl.removeButton, "SetDrawLayer", DL_TEXT)
        CallControlMethod(rowControl.removeButton, "SetDrawTier", DT_HIGH)
        CallControlMethod(rowControl.removeButton, "SetDrawLevel", 80)

        rowControl.messageButton:ClearAnchors()
        rowControl.messageButton:SetAnchor(RIGHT, rowControl.removeButton, LEFT, -3, 0)
        rowControl.messageButton:SetDimensions(46, buttonHeight)
        rowControl.messageButton:SetMouseEnabled(true)
        CallControlMethod(rowControl.messageButton, "SetDrawLayer", DL_TEXT)
        CallControlMethod(rowControl.messageButton, "SetDrawTier", DT_HIGH)
        CallControlMethod(rowControl.messageButton, "SetDrawLevel", 80)

        rowControl.itemButton:ClearAnchors()
        rowControl.itemButton:SetAnchor(RIGHT, rowControl.messageButton, LEFT, -3, 0)
        rowControl.itemButton:SetDimensions(46, buttonHeight)
        rowControl.itemButton:SetMouseEnabled(true)
        CallControlMethod(rowControl.itemButton, "SetDrawLayer", DL_TEXT)
        CallControlMethod(rowControl.itemButton, "SetDrawTier", DT_HIGH)
        CallControlMethod(rowControl.itemButton, "SetDrawLevel", 80)

        rowControl.askButton:ClearAnchors()
        rowControl.askButton:SetAnchor(RIGHT, rowControl.itemButton, LEFT, -3, 0)
        rowControl.askButton:SetDimensions(1, buttonHeight)
        rowControl.askButton:SetHidden(true)

        rowControl.text:SetDimensions(math.max(140, rowWidth - 142), rowHeight - 2)
        rowControl.text:SetFont(textSize.font or "ZoFontGame")
        CallControlMethod(rowControl.text, "SetDrawLayer", DL_CONTROLS)
        CallControlMethod(rowControl.text, "SetDrawTier", DT_MEDIUM)
        CallControlMethod(rowControl.text, "SetDrawLevel", 30)
    end

    local locked = self.savedVars.dropLog.locked == true
    if controls.resizeLeftGrip then
        controls.resizeLeftGrip:ClearAnchors()
        controls.resizeLeftGrip:SetAnchor(BOTTOMLEFT, controls.window, BOTTOMLEFT, 7, -1)
        controls.resizeLeftGrip:SetHidden(locked)
    end
    if controls.resizeRightGrip then
        controls.resizeRightGrip:ClearAnchors()
        controls.resizeRightGrip:SetAnchor(BOTTOMRIGHT, controls.window, BOTTOMRIGHT, -7, -1)
        controls.resizeRightGrip:SetHidden(locked)
    end
    self:RefreshDropResizeHandles()

    controls.visibleRowCount = visibleRows
    self:ApplyDropListBackdropOpacity()
    self:BuildDropListPageDropdown()
    self:ApplyDropListFont()
end

function Greed:GetDropLogEntryDisplayName(entry)
    if not entry then return "Unknown" end

    self:InitializeDropLogSettings()
    local displayName = self:CleanEsoDisplayText(entry.looterDisplayName or "")
    if displayName == "" or displayName:sub(1, 1) ~= "@" then
        displayName = self:CleanEsoDisplayText(entry.rawReceivedBy or "")
    end
    if displayName == "" or displayName:sub(1, 1) ~= "@" then
        displayName = self:CleanEsoDisplayText(entry.receivedBy or "")
    end
    if self.savedVars.dropLog.showAccountNames == true and displayName ~= "" and displayName:sub(1, 1) == "@" then
        return displayName
    end

    local characterName = self:CleanEsoDisplayText(entry.looterCharacterName or entry.receivedBy or entry.rawReceivedBy or "")
    if characterName ~= "" then return characterName end

    return "Unknown"
end

function Greed:BuildDropListEntryText(entry, highlightWanted)
    if not entry then return "" end

    local playerText = self:GetDropLogEntryDisplayName(entry)
    local traitText = entry.traitName and entry.traitName ~= "" and (" - " .. entry.traitName) or (" - " .. T("trait unknown"))
    local timeText = entry.timestampText and entry.timestampText ~= "" and ("[" .. entry.timestampText .. "] ") or ""
    local itemText = entry.itemLink or entry.itemName or T("an item")

    if highlightWanted == true then
        local highlightedPrefix = DROP_LOG_WANTED_TEXT_COLOR .. timeText .. playerText
        local linkText = DROP_LOG_TEXT_RESET .. itemText
        local highlightedTrait = DROP_LOG_WANTED_TEXT_COLOR .. traitText .. DROP_LOG_TEXT_RESET
        return T("%s looted %s%s", highlightedPrefix, linkText, highlightedTrait)
    end

    -- The full item link/name already contains the item type, so do not repeat slot text here.
    return T("%s looted %s%s", timeText .. playerText, itemText, traitText)
end

function Greed:OpenDropListItemLink(entry, button)
    if not entry or type(entry.itemLink) ~= "string" or entry.itemLink == "" then return end

    local link = entry.itemLink
    local mouseButton = button or MOUSE_BUTTON_INDEX_LEFT
    local handled = false

    if type(ZO_LinkHandler_OnLinkMouseUp) == "function" then
        handled = pcall(function()
            ZO_LinkHandler_OnLinkMouseUp(link, mouseButton, self.dropListControls and self.dropListControls.window or GuiRoot)
        end)
    end

    if not handled and type(ZO_LinkHandler_OnLinkClicked) == "function" then
        handled = pcall(function()
            ZO_LinkHandler_OnLinkClicked(link, mouseButton)
        end)
    end

    if not handled and ItemTooltip and type(ItemTooltip.SetLink) == "function" then
        pcall(function()
            InitializeTooltip(ItemTooltip, self.dropListControls and self.dropListControls.window or GuiRoot, TOPLEFT, 0, 0)
            ItemTooltip:SetLink(link)
        end)
    end
end

function Greed:RefreshDropListWindow(ownedItemIndex)
    local controls = self.dropListControls
    if not controls then return end

    self:LayoutDropListWindow()

    local pageFilter = self:GetDropLogPageFilterName()
    if not ownedItemIndex and self.savedVars.dropLog.onlyMissing ~= false and pageFilter ~= DROP_LOG_PAGE_FILTER_ALL_DROPS then
        ownedItemIndex = self:BuildOwnedItemIndex()
    end

    local entries = self.savedVars.dropLog.entries or {}
    local displayEntries = {}
    local wantedHighlightContext = self:BuildDropLogActiveWishlistMatchContext()
    for sourceIndex, savedEntry in ipairs(entries) do
        self:EnsureDropLogEntryId(savedEntry)
        if self:DropLogEntryPassesLooterFilter(savedEntry) and self:DropLogEntryPassesPageFilter(savedEntry, ownedItemIndex) and self:DropLogEntryPassesTraitFilter(savedEntry) then
            table.insert(displayEntries, { entry = savedEntry, sourceIndex = sourceIndex })
        end
    end

    local entryCount = #displayEntries
    local visibleRows = controls.visibleRowCount or #(controls.rows or {})
    local maxScrollOffset = math.max(0, entryCount - visibleRows)
    local scrollOffset = math.max(0, math.min(maxScrollOffset, math.floor(self.savedVars.dropLog.scrollOffset or 0)))
    self.savedVars.dropLog.scrollOffset = scrollOffset

    local filterText = T("No Drop List entries for this page yet.")
    if pageFilter == DROP_LOG_PAGE_FILTER_ALL then
        filterText = T("No wishlist drops logged yet.")
    elseif pageFilter == DROP_LOG_PAGE_FILTER_ALL_DROPS then
        filterText = T("No drops logged yet.")
    end
    controls.emptyLabel:SetText(filterText)
    controls.emptyLabel:SetHidden(entryCount > 0)

    for index, rowControl in ipairs(controls.rows or {}) do
        local entryData = index <= visibleRows and displayEntries[scrollOffset + index] or nil
        local entry = entryData and entryData.entry or nil
        rowControl.row:SetHidden(entry == nil)
        rowControl.askButton:SetHidden(true)
        if entry then
            local highlightWanted = self:GetActiveDropLogWishlistMatch(entry, wantedHighlightContext) ~= nil
            rowControl.text:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
            rowControl.text:SetText(self:BuildDropListEntryText(entry, highlightWanted))
            rowControl.text:SetMouseEnabled(entry.itemLink ~= nil and entry.itemLink ~= "")
            rowControl.text:SetHandler("OnMouseWheel", function(_, delta)
                self:ScrollDropList(delta)
            end)
            rowControl.text:SetHandler("OnMouseUp", function(_, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    self:OpenDropListItemLink(entry, button)
                end
            end)
            rowControl.itemButton:SetHidden(entry.itemLink == nil or entry.itemLink == "")
            rowControl.itemButton:SetHandler("OnClicked", function()
                self:CopyDropLogItemLink(entry)
            end)
            SetDropListActionButtonTextColor(rowControl.itemButton, highlightWanted and COLORS.gold or COLORS.text)
            rowControl.messageButton:SetHidden(entry.selfLoot == true)
            rowControl.messageButton:SetHandler("OnClicked", function()
                self:CopyDropAskMessage(entry)
            end)
            SetDropListActionButtonTextColor(rowControl.messageButton, highlightWanted and COLORS.gold or COLORS.text)
            local removeEntryId = self:EnsureDropLogEntryId(entry)
            rowControl.removeButton.greedEntryId = removeEntryId
            rowControl.removeButton:SetHidden(false)
            rowControl.removeButton:SetMouseEnabled(true)
            rowControl.removeButton:SetHandler("OnClicked", function(control)
                self:RemoveDropLogEntryById(control and control.greedEntryId or removeEntryId)
            end)
            rowControl.removeButton:SetHandler("OnMouseUp", nil)
        else
            rowControl.text:SetMouseEnabled(false)
            rowControl.text:SetHandler("OnMouseUp", nil)
            rowControl.text:SetHandler("OnMouseWheel", nil)
            rowControl.itemButton:SetHidden(true)
            rowControl.messageButton:SetHidden(true)
            SetDropListActionButtonTextColor(rowControl.itemButton, COLORS.text)
            SetDropListActionButtonTextColor(rowControl.messageButton, COLORS.text)
            rowControl.removeButton:SetHidden(true)
            rowControl.removeButton.greedEntryId = nil
            rowControl.removeButton:SetHandler("OnClicked", nil)
            rowControl.removeButton:SetHandler("OnMouseUp", nil)
        end
    end

    self:UpdateDropListScrollbar(entryCount, visibleRows, scrollOffset)
end

function Greed:GetDropListDisplayEntryCount(ownedItemIndex)
    self:InitializeDropLogSettings()
    local pageFilter = self:GetDropLogPageFilterName()
    if not ownedItemIndex and self.savedVars.dropLog.onlyMissing ~= false and pageFilter ~= DROP_LOG_PAGE_FILTER_ALL_DROPS then
        ownedItemIndex = self:BuildOwnedItemIndex()
    end

    local entries = self.savedVars.dropLog.entries or {}
    local count = 0
    for _, savedEntry in ipairs(entries) do
        if self:DropLogEntryPassesLooterFilter(savedEntry) and self:DropLogEntryPassesPageFilter(savedEntry, ownedItemIndex) and self:DropLogEntryPassesTraitFilter(savedEntry) then
            count = count + 1
        end
    end
    return count
end

function Greed:SetDropListScrollOffset(offset)
    self:InitializeDropLogSettings()
    local controls = self.dropListControls
    local visibleRows = controls and controls.visibleRowCount or DROP_LOG_MAX_VISIBLE_ROWS
    local pageFilter = self:GetDropLogPageFilterName()
    local ownedItemIndex
    if self.savedVars.dropLog.onlyMissing ~= false and pageFilter ~= DROP_LOG_PAGE_FILTER_ALL_DROPS then
        ownedItemIndex = self:BuildOwnedItemIndex()
    end
    local entryCount = self:GetDropListDisplayEntryCount(ownedItemIndex)
    local maxScrollOffset = math.max(0, entryCount - visibleRows)
    self.savedVars.dropLog.scrollOffset = math.max(0, math.min(maxScrollOffset, math.floor(offset or 0)))
    self:RefreshDropListWindow(ownedItemIndex)
end

function Greed:ScrollDropList(delta)
    self:InitializeDropLogSettings()
    local nextOffset = (self.savedVars.dropLog.scrollOffset or 0) - (delta or 0)
    self:SetDropListScrollOffset(nextOffset)
end

function Greed:PageDropListScroll(direction)
    self:InitializeDropLogSettings()
    local controls = self.dropListControls
    local pageSize = math.max(1, (controls and controls.visibleRowCount or 1) - 1)
    local nextOffset = (self.savedVars.dropLog.scrollOffset or 0) + ((direction or 1) * pageSize)
    self:SetDropListScrollOffset(nextOffset)
end

function Greed:UpdateDropListScrollbar(entryCount, visibleRows, scrollOffset)
    local controls = self.dropListControls
    if controls and controls.scrollTrack then controls.scrollTrack:SetHidden(true) end
    if controls and controls.scrollThumb then controls.scrollThumb:SetHidden(true) end
end

function Greed:CreateDropListClearConfirmWindow()
    if self.dropListClearControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedDropListClearConfirmWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(420, 182)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetClampedToScreen", true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 1400)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedDropListClearConfirmBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedDropListClearConfirmTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(420, 46)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedDropListClearConfirmTitle", window, CT_LABEL)
    title:SetDimensions(380, 26)
    title:SetAnchor(TOP, window, TOP, 0, 15)
    title:SetFont("ZoFontGameBold")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(title, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Clear Drop List"))
    title:SetMouseEnabled(true)

    local message = WINDOW_MANAGER:CreateControl("GreedDropListClearConfirmMessage", window, CT_LABEL)
    message:SetDimensions(380, 60)
    message:SetAnchor(TOP, title, BOTTOM, 0, 14)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 3)
    message:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(message, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    message:SetText(T("This will clear the Drop List and can't be undone.\nAre you sure?"))

    local yesButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListClearConfirmYes", window, "ZO_DefaultButton")
    yesButton:SetDimensions(100, 30)
    yesButton:SetAnchor(BOTTOM, window, BOTTOM, -55, -16)
    SetButtonText(yesButton, T("Yes"))
    yesButton:SetHandler("OnClicked", function()
        self:ConfirmDropListClear()
    end)

    local noButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropListClearConfirmNo", window, "ZO_DefaultButton")
    noButton:SetDimensions(100, 30)
    noButton:SetAnchor(BOTTOM, window, BOTTOM, 55, -16)
    SetButtonText(noButton, T("No"))
    noButton:SetHandler("OnClicked", function()
        self:HideDropListClearConfirm()
    end)

    self.dropListClearControls = {
        window = window,
        titleBar = titleBar,
        title = title,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "dropListClearConfirm")
end

function Greed:ShowDropListClearConfirm()
    self:CreateDropListClearConfirmWindow()
    if self.dropListClearControls and self.dropListClearControls.window then
        local window = self.dropListClearControls.window
        window:ClearAnchors()
        if self.dropListControls and self.dropListControls.window and self.dropListControls.window.IsHidden and not self.dropListControls.window:IsHidden() then
            window:SetAnchor(CENTER, self.dropListControls.window, CENTER, 0, 0)
        else
            window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
        end
        window:SetMouseEnabled(true)
        CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
        CallControlMethod(window, "SetDrawTier", DT_HIGH)
        CallControlMethod(window, "SetDrawLevel", 1400)
        CallControlMethod(window, "BringWindowToTop")
        window:SetHidden(false)
    end
end

function Greed:HideDropListClearConfirm()
    if self.dropListClearControls and self.dropListClearControls.window then
        self.dropListClearControls.window:SetMouseEnabled(false)
        self.dropListClearControls.window:SetHidden(true)
    end
end

function Greed:ConfirmDropListClear()
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.entries = {}
    self.savedVars.dropLog.scrollOffset = 0
    self:HideDropListClearConfirm()
    self:RefreshDropListWindow()
end

function Greed:CreateDropOptionsWindow()
    if self.dropOptionsControls then return end

    local windowWidth = 1116
    local windowHeight = 732
    local marginX = 28
    local contentWidth = 980 - (marginX * 2)
    local leftX = marginX
    local rightX = 500
    local promptPanelWidth = 500
    local promptPanelGap = 40
    local promptRightX = leftX + promptPanelWidth + promptPanelGap
    local panelHeight = 146

    local window = WINDOW_MANAGER:CreateControl("GreedDropOptionsWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(windowWidth, windowHeight)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -10)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 280)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedDropOptionsBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedDropOptionsTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(windowWidth, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedDropOptionsTitle", window, CT_LABEL)
    title:SetDimensions(windowWidth - 60, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Greed Options"))
    title:SetMouseEnabled(true)

    local function makeHeader(name, text, x, y, width)
        local label = WINDOW_MANAGER:CreateControl(name, window, CT_LABEL)
        label:SetDimensions(width or 360, 22)
        label:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        label:SetFont("ZoFontGameBold")
        label:SetColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], COLORS.gold[4])
        label:SetText(text)
        label:SetMouseEnabled(false)
        return label
    end

    local function makePanel(name, x, y, width, height)
        local panel = WINDOW_MANAGER:CreateControl(name, window, CT_BACKDROP)
        panel:SetDimensions(width, height)
        panel:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        panel:SetMouseEnabled(false)
        SetBackdropStyle(panel, COLORS.panel, COLORS.mutedEdge)
        return panel
    end

    local function makeLabel(name, text, x, y, width)
        local label = WINDOW_MANAGER:CreateControl(name, window, CT_LABEL)
        label:SetDimensions(width or 180, 24)
        label:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        label:SetFont("ZoFontGameSmall")
        label:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
        label:SetText(text)
        label:SetMouseEnabled(false)
        return label
    end

    local function makeCheckbox(name, text, x, y, callback)
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(name, window, "ZO_CheckButton")
        checkbox:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        if ZO_CheckButton_SetLabelText then
            ZO_CheckButton_SetLabelText(checkbox, text)
        end
        if ZO_CheckButton_SetToggleFunction then
            ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                control.greedChecked = checked == true
                if callback then callback(control.greedChecked) end
            end)
        end
        return checkbox
    end

    local function makeDropdown(name, x, y, width)
        local dropdown = WINDOW_MANAGER:CreateControlFromVirtual(name, window, "ZO_ComboBox")
        dropdown:SetDimensions(width or 220, 28)
        dropdown:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        return dropdown
    end

    local function makeButton(name, text, x, y, width, callback)
        local button = WINDOW_MANAGER:CreateControlFromVirtual(name, window, "ZO_DefaultButton")
        button:SetDimensions(width or 118, 28)
        button:SetAnchor(TOPLEFT, window, TOPLEFT, x, y)
        SetButtonText(button, text)
        button:SetHandler("OnClicked", callback)
        return button
    end

    local y = 58

    makeHeader("GreedDropOptionsDropListHeader", T("General Behavior"), leftX, y, contentWidth)
    y = y + 30
    local toggle = makeCheckbox("GreedDropOptionsToggle", T("Toggle Drop List Window"), leftX, y, function(checked)
        self.savedVars.dropLog.enabled = checked == true
        if checked then self:ShowDropListWindow(false) else self:HideDropListWindow(false) end
    end)
    local hideMenusToggle = makeCheckbox("GreedDropOptionsHideMenus", T("Hide Drop List during menus"), rightX, y, function(checked)
        self.savedVars.dropLog.hideInMenus = checked == true
        self:UpdateDropListMenuVisibility()
    end)
    y = y + 30
    local groupLootToggle = makeCheckbox("GreedDropOptionsGroupLoot", T("Include other players' loot"), leftX, y, function(checked)
        self.savedVars.dropLog.trackGroupLoot = checked == true
        self:RefreshDropListWindow()
    end)
    local lockDropListToggle = makeCheckbox("GreedDropOptionsLockDropList", T("Lock Drop List window"), rightX, y, function(checked)
        self:SetDropListLocked(checked == true)
    end)
    y = y + 30
    local onlyMissingToggle = makeCheckbox("GreedDropOptionsOnlyMissing", T("Only log items I still need"), leftX, y, function(checked)
        self.savedVars.dropLog.onlyMissing = checked == true
        self:RefreshDropListWindow()
    end)
    local lockLauncherToggle = makeCheckbox("GreedDropOptionsLockLauncher", T("Lock Greed Launcher Icon"), rightX, y, function(checked)
        self:SetLauncherLocked(checked == true)
    end)
    y = y + 30
    local accountNamesToggle = makeCheckbox("GreedDropOptionsAccountNames", T("Show @Account Names in Drop List"), rightX, y, function(checked)
        self.savedVars.dropLog.showAccountNames = checked == true
        self:RefreshDropListWindow()
    end)
    makeLabel("GreedDropOptionsTrackingScopeLabel", T("Tracked List Scope"), leftX, y, 160)
    local trackingScopeDropdown = makeDropdown("GreedDropOptionsTrackingScopeDropdown", leftX + 170, y - 3, 220)

    y = y + 40
    makeHeader("GreedDropOptionsMessageHeader", T("Drop List Message / Appearance"), leftX, y, contentWidth)
    y = y + 28
    local messageLabel = makeLabel("GreedDropOptionsMessageLabel", T("Ask message. Use {item}, {player}, and {trait} if you want."), leftX, y, contentWidth)
    y = y + 24
    local editBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropOptionsMessageBackdrop", window, "ZO_EditBackdrop")
    editBackdrop:SetDimensions(contentWidth, 32)
    editBackdrop:SetAnchor(TOPLEFT, window, TOPLEFT, leftX, y)
    local editBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropOptionsMessageEdit", editBackdrop, "ZO_DefaultEditForBackdrop")
    editBox:SetAnchorFill(editBackdrop)
    editBox:SetMaxInputChars(240)

    y = y + 48
    makeLabel("GreedDropOptionsTextSizeLabel", T("Drop List text size"), leftX, y, 170)
    local textSizeValue = WINDOW_MANAGER:CreateControl("GreedDropOptionsTextSizeValue", window, CT_LABEL)
    textSizeValue:SetDimensions(110, 24)
    textSizeValue:SetAnchor(TOPLEFT, window, TOPLEFT, leftX + 190, y)
    textSizeValue:SetFont("ZoFontGame")
    textSizeValue:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    local textSmallerButton = makeButton("GreedDropOptionsTextSmaller", "A-", leftX + 310, y - 2, 46, function() self:ChangeDropLogTextSize(-1) end)
    StyleTransparentTextButton(textSmallerButton)
    local textLargerButton = makeButton("GreedDropOptionsTextLarger", "A+", leftX + 364, y - 2, 46, function() self:ChangeDropLogTextSize(1) end)
    StyleTransparentTextButton(textLargerButton)

    makeLabel("GreedDropOptionsDropListFontLabel", T("Greed Drop List Font"), rightX, y, 160)
    local dropListFontDropdown = makeDropdown("GreedDropOptionsDropListFontDropdown", rightX + 170, y - 3, 230)

    y = y + 38
    makeLabel("GreedDropOptionsOpacityLabel", T("Background opacity"), leftX, y, 170)
    local opacityValue = WINDOW_MANAGER:CreateControl("GreedDropOptionsOpacityValue", window, CT_LABEL)
    opacityValue:SetDimensions(70, 24)
    opacityValue:SetAnchor(TOPLEFT, window, TOPLEFT, leftX + 190, y)
    opacityValue:SetFont("ZoFontGame")
    opacityValue:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    local opacityLowerButton = makeButton("GreedDropOptionsOpacityLower", "-", leftX + 285, y - 2, 44, function() self:ChangeDropListOpacity(-0.10) end)
    StyleTransparentTextButton(opacityLowerButton)
    local opacityHigherButton = makeButton("GreedDropOptionsOpacityHigher", "+", leftX + 335, y - 2, 44, function() self:ChangeDropListOpacity(0.10) end)
    StyleTransparentTextButton(opacityHigherButton)
    local opacityZeroButton = makeButton("GreedDropOptionsOpacityZero", "0%", leftX + 385, y - 2, 54, function() self:SetDropListOpacity(0) end)
    StyleTransparentTextButton(opacityZeroButton)

    local promptControls = {}
    local function createPromptSection(promptKey, titleText, x, startY)
        local section = {}
        makePanel("GreedDropOptions" .. promptKey .. "Panel", x, startY, promptPanelWidth, panelHeight)

        local titleLabel = WINDOW_MANAGER:CreateControl("GreedDropOptions" .. promptKey .. "Header", window, CT_LABEL)
        titleLabel:SetDimensions(promptPanelWidth - 24, 22)
        titleLabel:SetAnchor(TOPLEFT, window, TOPLEFT, x + 12, startY + 10)
        titleLabel:SetFont("ZoFontGameBold")
        titleLabel:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
        titleLabel:SetText(titleText)
        titleLabel:SetMouseEnabled(false)

        local enabledToggle = makeCheckbox("GreedDropOptions" .. promptKey .. "Enabled", T("Enabled"), x + 12, startY + 40, function(checked)
            self:SetPromptEnabled(promptKey, checked)
        end)
        section.enabledToggle = enabledToggle

        local lockLabel = promptKey == "spaulder" and T("Lock Spaulder Text") or T("Lock Greed Text")
        local lockToggle = makeCheckbox("GreedDropOptions" .. promptKey .. "Lock", lockLabel, x + 210, startY + 40, function(checked)
            self:SetPromptLocked(promptKey, checked)
        end)
        section.lockToggle = lockToggle

        makeLabel("GreedDropOptions" .. promptKey .. "FontLabel", T("Font"), x + 12, startY + 74, 70)
        local fontDropdown = makeDropdown("GreedDropOptions" .. promptKey .. "FontDropdown", x + 82, startY + 70, 230)
        section.fontDropdown = fontDropdown

        makeLabel("GreedDropOptions" .. promptKey .. "SizeLabel", T("Size"), x + 12, startY + 110, 70)
        local sizeDropdown = makeDropdown("GreedDropOptions" .. promptKey .. "SizeDropdown", x + 82, startY + 106, 130)
        section.sizeDropdown = sizeDropdown

        makeLabel("GreedDropOptions" .. promptKey .. "ColorLabel", T("Color"), x + 230, startY + 110, 60)
        local colorDropdown = makeDropdown("GreedDropOptions" .. promptKey .. "ColorDropdown", x + 292, startY + 106, 130)
        section.colorDropdown = colorDropdown

        return section
    end

    y = y + 52
    makeHeader("GreedDropOptionsTextPromptsHeader", T("Text Prompts"), leftX, y, contentWidth)
    local promptPanelY = y + 30
    promptControls.drop = createPromptSection("drop", T("Greed Drop Text"), leftX, promptPanelY)
    promptControls.spaulder = createPromptSection("spaulder", T("Spaulder Text"), promptRightX, promptPanelY)

    local maintenanceY = promptPanelY + panelHeight + 24
    makeHeader("GreedDropOptionsMaintenanceLabel", T("Maintenance"), leftX, maintenanceY, contentWidth)
    maintenanceY = maintenanceY + 30
    local maintenanceButtonWidth = 130
    local maintenanceGap = math.max(12, math.floor((contentWidth - (maintenanceButtonWidth * 5)) / 4))
    local function maintenanceX(index)
        return leftX + (index - 1) * (maintenanceButtonWidth + maintenanceGap)
    end
    makeButton("GreedDropOptionsResetDropPosition", T("Reset Drop List"), maintenanceX(1), maintenanceY, maintenanceButtonWidth, function() self:ShowResetDropListConfirm() end)
    makeButton("GreedDropOptionsResetGreedPosition", T("Reset Greed"), maintenanceX(2), maintenanceY, maintenanceButtonWidth, function() self:ShowResetGreedConfirm() end)
    makeButton("GreedDropOptionsResetPopups", T("Reset Windows"), maintenanceX(3), maintenanceY, maintenanceButtonWidth, function() self:ResetWindowPositions() end)
    makeButton("GreedDropOptionsTestDrop", T("Test Drop Row"), maintenanceX(4), maintenanceY, maintenanceButtonWidth, function() self:AddDropLogTestEntry() end)
    makeButton("GreedDropOptionsClearHistory", T("Clear History"), maintenanceX(5), maintenanceY, maintenanceButtonWidth, function()
        self.savedVars.dropLog.entries = {}
        self.savedVars.dropLog.scrollOffset = 0
        self:RefreshDropListWindow()
    end)

    local saveButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropOptionsSave", window, "ZO_DefaultButton")
    saveButton:SetDimensions(100, 30)
    saveButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(saveButton, T("Save"))
    saveButton:SetHandler("OnClicked", function() self:SaveDropOptions() end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDropOptionsCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function() self:HideDropOptionsWindow() end)

    self.dropOptionsControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        toggle = toggle,
        groupLootToggle = groupLootToggle,
        onlyMissingToggle = onlyMissingToggle,
        lockLauncherToggle = lockLauncherToggle,
        accountNamesToggle = accountNamesToggle,
        trackingScopeDropdown = trackingScopeDropdown,
        hideMenusToggle = hideMenusToggle,
        lockDropListToggle = lockDropListToggle,
        promptControls = promptControls,
        dropListFontDropdown = dropListFontDropdown,
        editBox = editBox,
        textSizeValue = textSizeValue,
        opacityValue = opacityValue,
        saveButton = saveButton,
        cancelButton = cancelButton,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "dropOptions")
end

function Greed:ShowDropOptionsWindow()
    self:CreateDropOptionsWindow()
    self:RefreshDropOptionsState()
    self.dropOptionsControls.window:SetHidden(false)
    self:RefreshTextPromptMovement()
end

function Greed:HideDropOptionsWindow()
    if self.dropOptionsControls and self.dropOptionsControls.window then
        self.dropOptionsControls.window:SetHidden(true)
    end
    self:RefreshTextPromptMovement()
end

function Greed:ToggleDropOptionsWindow()
    if self.dropOptionsControls and self.dropOptionsControls.window and not self.dropOptionsControls.window:IsHidden() then
        self:HideDropOptionsWindow()
        return
    end

    self:ShowDropOptionsWindow()
end

function Greed:RefreshDropOptionsState()
    local controls = self.dropOptionsControls
    if not controls then return end

    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()
    self:InitializeAntiquityLeadSettings()

    self:SetEditCheckboxState(controls.toggle, self.savedVars.dropLog.enabled == true)
    self:SetEditCheckboxState(controls.groupLootToggle, self.savedVars.dropLog.trackGroupLoot ~= false)
    self:SetEditCheckboxState(controls.onlyMissingToggle, self.savedVars.dropLog.onlyMissing ~= false)
    self:SetEditCheckboxState(controls.hideMenusToggle, self.savedVars.dropLog.hideInMenus ~= false)
    self:SetEditCheckboxState(controls.lockDropListToggle, self.savedVars.dropLog.locked == true)
    self:SetEditCheckboxState(controls.lockLauncherToggle, self:IsLauncherLocked())
    self:SetEditCheckboxState(controls.accountNamesToggle, self.savedVars.dropLog.showAccountNames == true)
    self:ConfigureChoiceDropdown(controls.trackingScopeDropdown, TRACKING_SCOPE_CHOICES, self:GetTrackingScopeLabel(), function(label)
        self:SetTrackingScopeByLabel(label)
    end)
    if controls.lockPromptsToggle then
        self:SetEditCheckboxState(controls.lockPromptsToggle, self.savedVars.textPrompts.locked == true)
    end
    if controls.antiquityOtherToggle then
        self:SetEditCheckboxState(controls.antiquityOtherToggle, self.savedVars.antiquityLeads.showOtherPlayers == true)
    end
    if controls.editBox then
        controls.editBox:SetText(self.savedVars.dropLog.askMessage or DEFAULT_DROP_ASK_MESSAGE)
    end

    if controls.textSizeValue then
        local textSize = self:GetDropLogTextSizeData()
        controls.textSizeValue:SetText(textSize.label or T("Normal"))
    end
    if controls.opacityValue then
        controls.opacityValue:SetText(tostring(self:GetDropListOpacityPercent()) .. "%")
    end
    self:ConfigureFontDropdown(controls.dropListFontDropdown, self.savedVars.dropLog.fontName, function(label)
        self:SetDropLogFontByLabel(label)
    end)

    local promptControls = controls.promptControls or {}
    local function configurePrompt(promptKey)
        local prompt = self:GetPromptSettings(promptKey)
        local section = promptControls[promptKey]
        if not section then return end

        self:SetEditCheckboxState(section.enabledToggle, prompt.enabled ~= false)
        if section.lockToggle then
            self:SetEditCheckboxState(section.lockToggle, prompt.locked == true)
        end
        self:ConfigureFontDropdown(section.fontDropdown, prompt.fontName, function(label)
            self:SetPromptFontByLabel(promptKey, label)
        end)
        local sizeOption = TEXT_PROMPT_SIZE_BY_KEY[prompt.fontSize] or TEXT_PROMPT_SIZE_BY_KEY.Normal
        self:ConfigureChoiceDropdown(section.sizeDropdown, TEXT_PROMPT_SIZE_LABELS, sizeOption and sizeOption.label or T("Normal"), function(label)
            self:SetPromptSizeByLabel(promptKey, label)
        end)
        local colorOption = TEXT_PROMPT_COLOR_BY_KEY[prompt.colorName] or TEXT_PROMPT_COLOR_BY_KEY.White
        self:ConfigureChoiceDropdown(section.colorDropdown, TEXT_PROMPT_COLOR_LABELS, colorOption and colorOption.label or T("White"), function(label)
            self:SetPromptColorByLabel(promptKey, label)
        end)
    end

    configurePrompt("drop")
    configurePrompt("spaulder")
end

function Greed:SaveDropOptions()
    local controls = self.dropOptionsControls
    if not controls then return end

    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()
    self:InitializeAntiquityLeadSettings()

    local enabled = controls.toggle and controls.toggle.greedChecked == true
    local message = controls.editBox and TrimText(controls.editBox:GetText()) or ""
    if message == "" then
        message = DEFAULT_DROP_ASK_MESSAGE
    end

    self.savedVars.dropLog.enabled = enabled == true
    self.savedVars.dropLog.trackGroupLoot = not (controls.groupLootToggle and controls.groupLootToggle.greedChecked == false)
    self.savedVars.dropLog.onlyMissing = not (controls.onlyMissingToggle and controls.onlyMissingToggle.greedChecked == false)
    self.savedVars.dropLog.currentPageOnly = self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL and self.savedVars.dropLog.pageFilterName ~= DROP_LOG_PAGE_FILTER_ALL_DROPS
    self.savedVars.dropLog.hideInMenus = not (controls.hideMenusToggle and controls.hideMenusToggle.greedChecked == false)
    self.savedVars.dropLog.locked = controls.lockDropListToggle and controls.lockDropListToggle.greedChecked == true
    self.savedVars.dropLog.showAccountNames = controls.accountNamesToggle and controls.accountNamesToggle.greedChecked == true
    self:SetLauncherLocked(controls.lockLauncherToggle and controls.lockLauncherToggle.greedChecked == true)
    self.savedVars.dropLog.askMessage = message
    if controls.lockPromptsToggle then
        self.savedVars.textPrompts.locked = controls.lockPromptsToggle.greedChecked == true
    end

    local promptControls = controls.promptControls or {}
    local function savePrompt(promptKey)
        local section = promptControls[promptKey]
        local prompt = self:GetPromptSettings(promptKey)
        if not section then return end
        prompt.enabled = not (section.enabledToggle and section.enabledToggle.greedChecked == false)
        prompt.bold = false
        prompt.italic = false
        prompt.underline = false
        prompt.rainbow = prompt.colorName == "Rainbow"
        if section.lockToggle then
            prompt.locked = section.lockToggle.greedChecked == true
        end
        if promptKey == "spaulder" then
            self.savedVars.textPrompts.spaulderTextEnabled = prompt.enabled
        else
            self.savedVars.textPrompts.dropTextEnabled = prompt.enabled
        end
    end
    savePrompt("drop")
    savePrompt("spaulder")
    local dropPrompt = self:GetPromptSettings("drop")
    local spaulderPrompt = self:GetPromptSettings("spaulder")
    self.savedVars.textPrompts.locked = dropPrompt.locked == true and spaulderPrompt.locked == true

    if controls.antiquityOtherToggle then
        self.savedVars.antiquityLeads.showOtherPlayers = controls.antiquityOtherToggle.greedChecked == true
    end

    self:ApplyDropListFont()
    self:RefreshDropListWindow()
    self:ApplyTextPromptFont()
    self:RefreshTextPromptMovement()
    self:RefreshSpaulderTextPrompt()

    if self.savedVars.dropLog.enabled then
        self:ShowDropListWindow(false)
    else
        self:HideDropListWindow(false)
    end

    self:HideDropOptionsWindow()
end

function Greed:CreateGenericConfirmWindow()
    if self.genericConfirmControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedGenericConfirmWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(500, 190)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -10)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 300)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedGenericConfirmBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedGenericConfirmTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(500, 46)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedGenericConfirmTitle", window, CT_LABEL)
    title:SetDimensions(460, 26)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 15)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetMouseEnabled(true)

    local message = WINDOW_MANAGER:CreateControl("GreedGenericConfirmMessage", window, CT_LABEL)
    message:SetDimensions(460, 62)
    message:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 3)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

    local confirmButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedGenericConfirmYes", window, "ZO_DefaultButton")
    confirmButton:SetDimensions(110, 30)
    confirmButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -138, -16)
    SetButtonText(confirmButton, T("Confirm"))
    confirmButton:SetHandler("OnClicked", function()
        local callback = self.pendingGenericConfirmCallback
        self:HideGenericConfirm()
        if type(callback) == "function" then
            callback()
        end
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedGenericConfirmNo", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(110, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideGenericConfirm()
    end)

    self.genericConfirmControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        message = message,
        confirmButton = confirmButton,
        cancelButton = cancelButton,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "genericConfirm")
end

function Greed:ShowGenericConfirm(titleText, messageText, confirmText, callback)
    self:CreateGenericConfirmWindow()
    local controls = self.genericConfirmControls
    controls.title:SetText(titleText or T("Confirm"))
    controls.message:SetText(messageText or T("Are you sure?"))
    SetButtonText(controls.confirmButton, confirmText or T("Confirm"))
    self.pendingGenericConfirmCallback = callback
    controls.window:SetHidden(false)
end

function Greed:HideGenericConfirm()
    if self.genericConfirmControls and self.genericConfirmControls.window then
        self.genericConfirmControls.window:SetHidden(true)
    end
    self.pendingGenericConfirmCallback = nil
end

function Greed:ApplyDropListDefaultSettings(clearEntries)
    self:InitializeDropLogSettings()
    self.savedVars.dropLog.enabled = true
    self.savedVars.dropLog.askMessage = DEFAULT_DROP_ASK_MESSAGE
    if clearEntries == true then
        self.savedVars.dropLog.entries = {}
    else
        self.savedVars.dropLog.entries = self.savedVars.dropLog.entries or {}
    end
    self.savedVars.dropLog.width = DROP_LOG_DEFAULT_WIDTH
    self.savedVars.dropLog.height = DROP_LOG_DEFAULT_HEIGHT
    self.savedVars.dropLog.textSize = DEFAULT_DROP_LOG_TEXT_SIZE_INDEX
    self.savedVars.dropLog.textSizeVersion = DROP_LOG_TEXT_SIZE_VERSION
    self.savedVars.dropLog.fontName = DEFAULT_FONT_NAME
    self.savedVars.dropLog.onlyMissing = true
    self.savedVars.dropLog.currentPageOnly = false
    self.savedVars.dropLog.hideInMenus = true
    self.savedVars.dropLog.trackGroupLoot = true
    self.savedVars.dropLog.showAccountNames = false
    self.savedVars.dropLog.debugLoot = false
    self.savedVars.dropLog.locked = false
    self.savedVars.dropLog.opacity = DROP_LOG_DEFAULT_OPACITY
    self.savedVars.dropLog.pageFilterName = DROP_LOG_PAGE_FILTER_ALL_DROPS
    self.savedVars.dropLog.traitFilters = {}
    self.savedVars.dropLog.scrollOffset = 0
end

function Greed:ShowResetDropListConfirm()
    self:ShowGenericConfirm(
        T("Reset Drop List"),
        T("Reset Drop List settings, filters, size, and clear the Drop List log?"),
        T("Reset"),
        function()
            self:ResetDropListSettings()
        end
    )
end

function Greed:ResetDropListSettings()
    self:ApplyDropListDefaultSettings(true)
    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.dropList = nil

    if self.dropListControls and self.dropListControls.window then
        self.dropListControls.window:ClearAnchors()
        self.dropListControls.window:SetAnchor(CENTER, GuiRoot, CENTER, 260, 40)
        self.dropListControls.window:SetDimensions(DROP_LOG_DEFAULT_WIDTH, DROP_LOG_DEFAULT_HEIGHT)
    end

    self:RefreshDropListLockIcon()
    self:LayoutDropListWindow()
    self:RefreshDropListWindow()
    self:RefreshDropOptionsState()
    SafeAnnounce(T("Greed: Drop List reset."))
end

function Greed:ShowResetGreedConfirm()
    self:ShowGenericConfirm(
        T("Reset Greed"),
        T("Reset Greed options and window positions. Your Greed pages and tracked sets will be kept."),
        T("Reset"),
        function()
            self:ResetGreedSettings()
        end
    )
end

function Greed:ResetGreedSettings()
    self.savedVars.windowPositions = {}
    self.savedVars.launcher = self.savedVars.launcher or {}
    self.savedVars.launcher.locked = false
    self:ApplyDropListDefaultSettings(false)

    self.savedVars.textPrompts = self:CopyTable(SAVED_VAR_DEFAULTS.textPrompts)
    self.savedVars.antiquityLeads = self.savedVars.antiquityLeads or {}
    self.savedVars.antiquityLeads.showOtherPlayers = false
    self.savedVars.antiquityLeads.watched = self.savedVars.antiquityLeads.watched or {}
    self.savedVars.antiquityLeads.found = self.savedVars.antiquityLeads.found or {}

    self:ResetWindowPositions()
    self:RefreshTextPromptFonts()
    self:RefreshTextPromptMovement()
    self:RefreshSpaulderTextPrompt()
    self:RefreshDropOptionsState()
    SafeAnnounce(T("Greed: settings reset. Pages and tracked sets were preserved."))
end

function Greed:ResetWindowPositions()
    self.savedVars.windowPositions = {}

    if self.controls and self.controls.window then
        self.controls.window:ClearAnchors()
        self.controls.window:SetDimensions(MAIN_WINDOW_DEFAULT_WIDTH, MAIN_WINDOW_DEFAULT_HEIGHT)
        self:UpdateMainWindowLayout()
        self:ApplyDefaultWindowPosition(self.controls.window, "mainWindow")
    end
    if self.dropListControls and self.dropListControls.window then
        self.dropListControls.window:ClearAnchors()
        self:ApplyDefaultWindowPosition(self.dropListControls.window, "dropList")
    end
    if self.dropOptionsControls and self.dropOptionsControls.window then
        self.dropOptionsControls.window:ClearAnchors()
        self:ApplyDefaultWindowPosition(self.dropOptionsControls.window, "dropOptions")
    end
    if self.setsOverviewControls and self.setsOverviewControls.window then
        self.setsOverviewControls.window:ClearAnchors()
        self.setsOverviewControls.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    end
    if self.sourcesToFarmControls and self.sourcesToFarmControls.window then
        self.sourcesToFarmControls.window:ClearAnchors()
        self:ApplyDefaultWindowPosition(self.sourcesToFarmControls.window, "sourcesToFarm")
    end
    if self.textPromptControls and self.textPromptControls.window then
        self.textPromptControls.window:ClearAnchors()
        self.textPromptControls.window:SetAnchor(TOP, GuiRoot, TOP, 0, 210)
    end
    if self.spaulderPromptControls and self.spaulderPromptControls.window then
        self.spaulderPromptControls.window:ClearAnchors()
        self.spaulderPromptControls.window:SetAnchor(TOP, GuiRoot, TOP, 0, 160)
    end
    if self.spaulderPromptControls and self.spaulderPromptControls.window then
        self.spaulderPromptControls.window:ClearAnchors()
        self.spaulderPromptControls.window:SetAnchor(TOP, GuiRoot, TOP, 0, 160)
    end

    SafeAnnounce(T("Greed: window positions reset."))
end


function Greed:ResetDropListPosition()
    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.dropList = nil
    self.savedVars.dropLog.width = DROP_LOG_DEFAULT_WIDTH
    self.savedVars.dropLog.height = DROP_LOG_DEFAULT_HEIGHT

    if self.dropListControls and self.dropListControls.window then
        self.dropListControls.window:ClearAnchors()
        self.dropListControls.window:SetDimensions(DROP_LOG_DEFAULT_WIDTH, DROP_LOG_DEFAULT_HEIGHT)
        self:ApplyDefaultWindowPosition(self.dropListControls.window, "dropList")
        self:LayoutDropListWindow()
        self:RefreshDropListWindow()
    end

    SafeAnnounce(T("Greed: Drop List position and size reset."))
end

function Greed:ResetMainWindowPosition()
    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.mainWindow = nil

    if self.controls and self.controls.window then
        self.controls.window:ClearAnchors()
        self.controls.window:SetDimensions(MAIN_WINDOW_DEFAULT_WIDTH, MAIN_WINDOW_DEFAULT_HEIGHT)
        self:UpdateMainWindowLayout()
        self:ApplyDefaultWindowPosition(self.controls.window, "mainWindow")
    end

    SafeAnnounce(T("Greed: main window position and size reset."))
end

function Greed:ResetPopupPositions()
    self:ResetWindowPositions()
end

function Greed:IsSceneNameBlockingForDropList(sceneName)
    if type(sceneName) ~= "string" or sceneName == "" then return false end

    local lowerName = string.lower(sceneName)

    local exactBlockingScenes = {
        skills = true,
        skillskeyboard = true,
        skillsgamepad = true,
        inventory = true,
        inventorykeyboard = true,
        inventorygamepad = true,
        character = true,
        characterkeyboard = true,
        collectionsbook = true,
        collectionsbookkeyboard = true,
        itemsetsbook = true,
        itemsetsbookkeyboard = true,
        gamemenuingame = true,
        gamemenu = true,
        settings = true,
        settingskeyboard = true,
        helpcustomersupport = true,
        journal = true,
        journalkeyboard = true,
        map = true,
        worldmap = true,
        worldmapkeyboard = true,
        mailinbox = true,
        mailsend = true,
        tradinghouse = true,
        tradinghousekeyboard = true,
        bank = true,
        bankkeyboard = true,
        guildbank = true,
        store = true,
        storewindow = true,
        market = true,
        championperks = true,
        championperkskeyboard = true,
        crowncrates = true,
        groupmenu = true,
        groupmenukeyboard = true,
        dungeonfinder = true,
        smithing = true,
        alchemy = true,
        enchanting = true,
        provisioning = true,
        woodworking = true,
        clothier = true,
        jewelrycrafting = true,
    }

    if exactBlockingScenes[lowerName] == true then return true end

    -- ESO scene names vary by keyboard/gamepad and by addon/UI version.
    -- Match menu words, but do not treat plain cursor/HUD mode as a menu.
    local blockingPatterns = {
        "skill",
        "inventory",
        "character",
        "collection",
        "itemset",
        "item_set",
        "gamemenu",
        "settings",
        "journal",
        "worldmap",
        "map",
        "mail",
        "trading",
        "bank",
        "store",
        "market",
        "champion",
        "crown",
        "group",
        "dungeonfinder",
        "smith",
        "alchemy",
        "enchant",
        "provision",
        "woodwork",
        "clothier",
        "jewelry",
    }

    for _, pattern in ipairs(blockingPatterns) do
        if string.find(lowerName, pattern, 1, true) then
            return true
        end
    end

    return false
end

function Greed:IsBlockingMenuSceneOpen()
    if not SCENE_MANAGER then return false end

    local likelyScenes = {
        "skills", "skillsKeyboard", "skillsGamepad",
        "inventory", "inventoryKeyboard", "inventoryGamepad",
        "character", "characterKeyboard",
        "collectionsBook", "collectionsBookKeyboard",
        "itemSetsBook", "itemSetsBookKeyboard",
        "gameMenuInGame", "gameMenu", "settings", "settingsKeyboard",
        "journal", "journalKeyboard", "map", "worldMap", "worldMapKeyboard",
        "mailInbox", "mailSend", "tradingHouse", "tradingHouseKeyboard",
        "bank", "bankKeyboard", "guildBank", "store", "market",
        "championPerks", "championPerksKeyboard",
        "groupMenu", "groupMenuKeyboard", "dungeonFinder",
        "smithing", "alchemy", "enchanting", "provisioning",
        "woodworking", "clothier", "jewelryCrafting",
    }

    if type(SCENE_MANAGER.IsShowing) == "function" then
        for _, sceneName in ipairs(likelyScenes) do
            local ok, isShowing = pcall(function()
                return SCENE_MANAGER:IsShowing(sceneName)
            end)
            if ok and isShowing == true then
                return true
            end
        end
    end

    if type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local ok, scene = pcall(function()
            return SCENE_MANAGER:GetCurrentScene()
        end)
        if ok and scene and type(scene.GetName) == "function" then
            local okName, sceneName = pcall(function()
                return scene:GetName()
            end)
            if okName and self:IsSceneNameBlockingForDropList(sceneName) then
                return true
            end
        end
    end

    return false
end

function Greed:IsControlShown(control)
    if control == nil then
        return false
    end

    local controlType = type(control)
    if controlType ~= "userdata" and controlType ~= "table" then
        return false
    end

    if type(control.IsHidden) ~= "function" then
        return false
    end

    local ok, hidden = pcall(function()
        return control:IsHidden()
    end)

    return ok and hidden == false
end

function Greed:IsTamrielTomesSceneName(sceneOrName)
    local sceneName = string.lower(self:GetSceneName(sceneOrName) or "")
    if sceneName == "" then return false end

    for _, tamrielTomesSceneName in ipairs(TAMRIEL_TOMES_SCENE_NAMES) do
        if sceneName == string.lower(tamrielTomesSceneName) then
            return true
        end
    end

    return false
end

function Greed:IsTamrielTomesSceneOpen()
    if not SCENE_MANAGER then return false end

    if type(SCENE_MANAGER.IsShowing) == "function" then
        for _, sceneName in ipairs(TAMRIEL_TOMES_SCENE_NAMES) do
            local ok, isShowing = pcall(function()
                return SCENE_MANAGER:IsShowing(sceneName)
            end)
            if ok and isShowing == true then
                return true
            end
        end
    end

    if type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local ok, scene = pcall(function()
            return SCENE_MANAGER:GetCurrentScene()
        end)
        if ok and self:IsTamrielTomesSceneName(scene) then
            return true
        end
    end

    return false
end

function Greed:IsTamrielTomesShown()
    if self.tamrielTomesSceneActive == true or self:IsTamrielTomesSceneOpen() then
        return true
    end

    -- Keep the narrow known-control check only as a compatibility fallback.
    -- Do NOT scan _G broadly because private/protected globals can poison the callstack.
    for _, controlName in ipairs(TAMRIEL_TOMES_CONTROL_NAMES) do
        local control = rawget(_G, controlName)
        if self:IsControlShown(control) then
            return true
        end
    end

    return false
end

function Greed:GetNowMilliseconds(frameTimeSeconds)
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    return math.floor((frameTimeSeconds or 0) * 1000)
end

function Greed:IsGameCameraUIModeActiveSafe()
    if type(IsGameCameraUIModeActive) ~= "function" then return false end

    local ok, active = pcall(IsGameCameraUIModeActive)
    return ok and active == true
end

function Greed:ShouldHideDropListForMenu()
    self:InitializeDropLogSettings()

    return self:IsTamrielTomesShown()
        or (self.savedVars.dropLog.hideInMenus ~= false and self:IsBlockingMenuSceneOpen())
end

function Greed:GetTamrielTomesGreedWindowTargets()
    return {
        { key = "main", control = self.controls and self.controls.window },
        { key = "dropList", controlSet = self.dropListControls },
        { key = "dropOptions", controlSet = self.dropOptionsControls },
        { key = "dropTrait", controlSet = self.dropTraitControls },
        { key = "dropListClear", controlSet = self.dropListClearControls },
        { key = "sourcesToFarm", controlSet = self.sourcesToFarmControls },
        { key = "setsOverview", controlSet = self.setsOverviewControls },
        { key = "addSet", controlSet = self.addControls },
        { key = "editTrackedPieces", controlSet = self.editControls },
        { key = "removeFavorite", controlSet = self.removeControls },
        { key = "movePage", controlSet = self.movePageControls },
        { key = "deletePage", controlSet = self.deletePageControls },
        { key = "pageName", controlSet = self.pageNameControls },
        { key = "genericConfirm", controlSet = self.genericConfirmControls },
        { key = "antiquityLeads", controlSet = self.antiquityControls },
    }
end

function Greed:GetTamrielTomesTargetControl(target)
    if not target then return nil end
    if target.control then return target.control end
    if target.controlSet then return target.controlSet.window end
    return nil
end

function Greed:IsAnyTamrielTomesGreedWindowShown()
    for _, target in ipairs(self:GetTamrielTomesGreedWindowTargets()) do
        if self:IsControlShown(self:GetTamrielTomesTargetControl(target)) then
            return true
        end
    end

    return false
end

function Greed:SetLauncherTemporaryHideReason(reason, active)
    if type(reason) ~= "string" or reason == "" then return end

    self.launcherTemporaryHideReasons = self.launcherTemporaryHideReasons or {}
    self.launcherTemporaryHideReasons[reason] = active == true or nil
end

function Greed:HasLauncherTemporaryHideReason()
    local reasons = self.launcherTemporaryHideReasons
    if type(reasons) ~= "table" then return false end

    for _, active in pairs(reasons) do
        if active == true then
            return true
        end
    end

    return false
end

function Greed:IsTamrielTomesSuppressionRestoreBlocked()
    local dropReasons = self.dropLogTemporaryHideReasons
    if type(dropReasons) == "table" and dropReasons.tamrielTomes == true then
        return true
    end
    if type(dropReasons) == "table" and dropReasons.nativeMenu == true then
        return true
    end

    local launcherReasons = self.launcherTemporaryHideReasons
    if type(launcherReasons) == "table" and launcherReasons.tamrielTomes == true then
        return true
    end

    return self.championPointsSceneActive == true or self:IsChampionPointsSceneOpen() or self:IsTamrielTomesShown()
end

function Greed:RestoreTamrielTomesHiddenGreedWindowsIfReady()
    local hiddenTargets = self.tamrielTomesHiddenGreedWindows
    if type(hiddenTargets) ~= "table" then return end
    if self:IsTamrielTomesSuppressionRestoreBlocked() then return end

    self.tamrielTomesHiddenGreedWindows = nil
    for _, target in ipairs(self:GetTamrielTomesGreedWindowTargets()) do
        if hiddenTargets[target.key] == true then
            local control = self:GetTamrielTomesTargetControl(target)
            if control then
                control:SetHidden(false)
            end
        end
    end

    if self.dropListControls and hiddenTargets.dropList == true then
        self:RefreshDropListWindow()
    end
end

function Greed:ApplyTamrielTomesGreedWindowSuppression(active)
    if active == true then
        self.tamrielTomesHiddenGreedWindows = self.tamrielTomesHiddenGreedWindows or {}
        for _, target in ipairs(self:GetTamrielTomesGreedWindowTargets()) do
            local control = self:GetTamrielTomesTargetControl(target)
            if self:IsControlShown(control) then
                self.tamrielTomesHiddenGreedWindows[target.key] = true
                control:SetHidden(true)
            end
        end
    else
        self:RestoreTamrielTomesHiddenGreedWindowsIfReady()
    end
end

function Greed:DoesTamrielTomesControlExist()
    for _, controlName in ipairs(TAMRIEL_TOMES_CONTROL_NAMES) do
        if rawget(_G, controlName) ~= nil then
            return true
        end
    end

    return false
end

function Greed:UpdateTamrielTomesSuppression()
    self:InitializeDropLogSettings()
    local active = self:IsTamrielTomesShown()
    self:SetDropListTemporaryHideReason("tamrielTomes", active)
    self:SetLauncherTemporaryHideReason("tamrielTomes", active)
    self:ApplyTamrielTomesGreedWindowSuppression(active)
    self:RefreshLauncherVisibility()
    return active
end

function Greed:RefreshDropListNativeMenuSuppression()
    self:InitializeDropLogSettings()
    local active = self.savedVars.dropLog.hideInMenus ~= false and self:IsBlockingMenuSceneOpen()
    self:SetDropListTemporaryHideReason("nativeMenu", active)
    return active
end

function Greed:PrintTamrielTomesDebug()
    self:InitializeDropLogSettings()
    local ok, shouldHide = pcall(function()
        return self:ShouldHideDropListForMenu()
    end)
    if not ok then
        shouldHide = false
    end

    local currentSceneName = "none"
    if SCENE_MANAGER and type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local okScene, scene = pcall(function()
            return SCENE_MANAGER:GetCurrentScene()
        end)
        if okScene then
            currentSceneName = self:GetSceneName(scene)
            if currentSceneName == "" then
                currentSceneName = "unknown"
            end
        end
    end

    local suppressed = self:IsDropListMenuSuppressed()
    local now = self:GetNowMilliseconds()
    local sinceClear = self.dropLogMenuClearSince and (now - self.dropLogMenuClearSince) or nil
    local sinceSeen = self.dropLogMenuHideLastSeen and (now - self.dropLogMenuHideLastSeen) or nil
    SafeAnnounce("Greed TT debug: hideInMenus=" .. tostring(self.savedVars.dropLog.hideInMenus ~= false) .. ", shouldHide=" .. tostring(shouldHide) .. ", suppressed=" .. tostring(suppressed) .. ", latch=" .. tostring(self.dropLogAutoHiddenForMenu == true) .. ", active=" .. tostring(self.dropLogMenuHideActive == true) .. ", uiMode=" .. tostring(self:IsGameCameraUIModeActiveSafe()) .. ", scene=" .. tostring(currentSceneName))
    SafeAnnounce("Greed TT debug: lastSeenMsAgo=" .. tostring(sinceSeen or "nil") .. ", clearMs=" .. tostring(sinceClear or "nil") .. ", releaseDelay=1200, wasEnabled=" .. tostring(self.dropLogMenuHideWasEnabled == true) .. ", userClosed=" .. tostring(self.dropLogMenuHideUserClosed == true))
    for _, controlName in ipairs(TAMRIEL_TOMES_CONTROL_NAMES) do
        local control = rawget(_G, controlName)
        local found = control ~= nil
        local shown = self:IsControlShown(control)
        SafeAnnounce("Greed TT debug: " .. controlName .. " found=" .. tostring(found) .. ", shown=" .. tostring(shown))
    end
end

function Greed:ShouldRunTamrielTomesFallbackPolling()
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then return false end
    if type(EVENT_MANAGER.UnregisterForUpdate) ~= "function" then return false end

    local dropReasons = self.dropLogTemporaryHideReasons
    local launcherReasons = self.launcherTemporaryHideReasons
    if type(dropReasons) == "table" and dropReasons.tamrielTomes == true then return true end
    if type(launcherReasons) == "table" and launcherReasons.tamrielTomes == true then return true end
    if type(self.tamrielTomesHiddenGreedWindows) == "table" then return true end
    if not self:DoesTamrielTomesControlExist() then return false end

    local launcher = self.controls and self.controls.launcher or GreedLauncher
    return self:IsAnyTamrielTomesGreedWindowShown() or self:IsControlShown(launcher)
end

function Greed:RefreshTamrielTomesFallbackPolling()
    local updateName = self.name .. "TamrielTomesDropListFallback"
    local shouldRun = self:ShouldRunTamrielTomesFallbackPolling()

    if shouldRun and self.tamrielTomesFallbackRegistered ~= true then
        EVENT_MANAGER:RegisterForUpdate(updateName, 500, function()
            local ok, err = pcall(function()
                self:UpdateTamrielTomesSuppression()
                self:UpdateDropListMenuVisibility(true, true)
            end)
            if not ok and self.savedVars and self.savedVars.dropLog and self.savedVars.dropLog.debugLoot == true then
                SafeAnnounce("Greed: Tamriel Tomes Drop List fallback skipped an unsafe check: " .. tostring(err))
            end
        end)
        self.tamrielTomesFallbackRegistered = true
    elseif not shouldRun and self.tamrielTomesFallbackRegistered == true then
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        self.tamrielTomesFallbackRegistered = false
    end
end

function Greed:OnTamrielTomesSceneStateChanged(scene, newState)
    local sceneName = self:GetSceneName(scene)
    self.tamrielTomesActiveScenes = self.tamrielTomesActiveScenes or {}

    if self:IsSceneShowingState(newState) then
        self.tamrielTomesActiveScenes[sceneName] = true
    elseif self:IsSceneHiddenState(newState) then
        self.tamrielTomesActiveScenes[sceneName] = nil
    else
        return
    end

    local active = false
    for _, isActive in pairs(self.tamrielTomesActiveScenes) do
        if isActive == true then
            active = true
            break
        end
    end
    if not active then
        active = self:IsTamrielTomesSceneOpen()
    end

    self.tamrielTomesSceneActive = active
    self:UpdateTamrielTomesSuppression()
    self:UpdateDropListMenuVisibility(true, true)
    self:RefreshTamrielTomesFallbackPolling()
end

function Greed:OnDropListMenuSceneStateChanged(scene, oldState, newState)
    local sceneName = self:GetSceneName(scene)

    if self:IsTamrielTomesSceneName(sceneName) then
        self:OnTamrielTomesSceneStateChanged(scene, newState)
        return
    end

    if self:IsEscapeMenuScene(sceneName) and self:IsSceneShowingState(newState) then
        self:CloseForEscapeMenuScene(sceneName)
    end

    if not self:IsSceneNameBlockingForDropList(sceneName) then return end

    if self:IsSceneShowingState(newState) then
        self:SetDropListTemporaryHideReason("nativeMenu", self.savedVars.dropLog.hideInMenus ~= false)
    elseif self:IsSceneHiddenState(newState) then
        self:RefreshDropListNativeMenuSuppression()
    end

    self:UpdateDropListMenuVisibility(true, true)
    self:RestoreTamrielTomesHiddenGreedWindowsIfReady()
end

function Greed:RegisterDropListMenuSceneCallbacks()
    if self.dropListMenuSceneCallbacksRegistered == true then return end
    self.dropListMenuSceneCallbacksRegistered = true

    if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
        local ok = pcall(function()
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
                self:OnDropListMenuSceneStateChanged(scene, oldState, newState)
            end)
        end)
        if ok then
            self.dropListMenuSceneManagerCallbackRegistered = true
        end
    end
end

function Greed:OnChampionPointsSceneStateChanged(newState)
    if self:IsSceneShowingState(newState) then
        self.championPointsSceneActive = true
        self:RefreshLauncherVisibility()
    elseif self:IsSceneHiddenState(newState) then
        self.championPointsSceneActive = false
        self:RefreshLauncherVisibility()
        self:RestoreTamrielTomesHiddenGreedWindowsIfReady()
    end
end

function Greed:RegisterChampionPointsLauncherCallbacks()
    if self.championPointsLauncherCallbacksRegistered == true then return end
    self.championPointsLauncherCallbacksRegistered = true
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetScene) ~= "function" then return end

    for _, sceneName in ipairs(CHAMPION_POINTS_SCENE_NAMES) do
        local okScene, scene = pcall(function()
            return SCENE_MANAGER:GetScene(sceneName)
        end)
        if okScene and scene and type(scene.RegisterCallback) == "function" then
            pcall(function()
                scene:RegisterCallback("StateChange", function(oldState, newState)
                    self:OnChampionPointsSceneStateChanged(newState)
                end)
            end)
        end
    end
end

function Greed:StartDropListMenuWatcher()
    self:RegisterDropListMenuSceneCallbacks()
    self:RegisterChampionPointsLauncherCallbacks()
    self:RefreshDropListNativeMenuSuppression()
    self:UpdateTamrielTomesSuppression()
    self:UpdateDropListMenuVisibility(true)
    self:RefreshLauncherVisibility()
    self:RefreshTamrielTomesFallbackPolling()
end

function Greed:UpdateDropListMenuVisibility(fastReturn, skipNativeRefresh)
    self:InitializeDropLogSettings()
    local now = self:GetNowMilliseconds()
    if self.savedVars.dropLog.enabled ~= true then
        self:ClearDropListMenuHideState()
        self:RefreshTamrielTomesFallbackPolling()
        return
    end

    if skipNativeRefresh ~= true then
        if self.savedVars.dropLog.hideInMenus == false then
            self:SetDropListTemporaryHideReason("nativeMenu", false)
        else
            self:RefreshDropListNativeMenuSuppression()
        end
    end
    self:UpdateTamrielTomesSuppression()

    local shouldHide = self:HasDropListTemporaryHideReason()

    if shouldHide then
        local wasLatched = self.dropLogAutoHiddenForMenu == true
        self:ActivateDropListMenuHide(now)
        if self.ttDebug and not wasLatched then
            SafeAnnounce("Greed TT debug: Drop List hidden for menu.")
        end
        self:RefreshTamrielTomesFallbackPolling()
        return
    end

    if self.dropLogAutoHiddenForMenu == true then
        local wasEnabled = self.dropLogMenuHideWasEnabled == true
        self:ClearDropListMenuHideState()
        if self.dropListControls
            and self.dropListControls.window
            and self.savedVars.dropLog.enabled == true
            and wasEnabled
            and self.dropLogMenuHideUserClosed ~= true
        then
            self.dropListControls.window:SetHidden(false)
            self:RefreshDropListWindow()
        end
    end

    self:RefreshTamrielTomesFallbackPolling()
end
