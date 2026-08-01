-- UI Constants
-- Dimensions now loaded from NMGuildHall.Constants.UI.WINDOW

-- Window management
local Addon = NMGuildHall
local UI = Addon.UI
local function UILogger()
    if Addon and Addon.Message and Addon.Message.For then
        return Addon.Message:For("UI")
    end
    return nil
end
local MAX_WINDOWS = 3
local windowCount = 0
local MAIN_WINDOW_NAME = "NMGuildHallWindow_1"
local TAB_ORDER = {"home", "teleport", "group", "campaign", "pledges"}
-- RESOURCE_TIMEOUT loaded from NMGuildHall.Constants.UI.WINDOW.RESOURCE_TIMEOUT_MS

local function NoOp()
end

local function GetNamedControl(name)
    if WINDOW_MANAGER and WINDOW_MANAGER.GetControlByName then
        return WINDOW_MANAGER:GetControlByName(name)
    end
    return nil
end

local function FlushEnsureReadyCallbacks(ui, success)
    local callbacks = ui._ensureReadyCallbacks or {}
    ui._ensureReadyCallbacks = {}
    ui._ensureReadyPending = false

    for _, callback in ipairs(callbacks) do
        if type(callback) == "function" then
            pcall(callback, success)
        end
    end
end

-- Shared local resources check helper
local function WaitForResources(callback, onTimeout)
    local startTime = GetGameTimeMilliseconds()

    local function CheckResources()
        -- UI should not depend on LibAddonMenu2 being loaded; only Settings requires it.
        local Constants = Addon and Addon.Constants
        local timeoutMs = (Constants and Constants.UI and Constants.UI.WINDOW and Constants.UI.WINDOW.RESOURCE_TIMEOUT_MS) or 10000
        if Constants then
            callback()
            return
        end

        if GetGameTimeMilliseconds() - startTime > timeoutMs then
            if type(onTimeout) == "function" then
                onTimeout()
            end
            local log = UILogger()
            if log then
                log:Error(GetString(NMGH_ERR_RESOURCE_TIMEOUT))
            end
            return
        end

        zo_callLater(CheckResources, 100)
    end

    CheckResources()
end

function UI:_ReacquireStaticControls()
    self.window = self.window or GetNamedControl(MAIN_WINDOW_NAME)
    self.background = self.background or GetNamedControl("NMGuildHall_MainWindowBG")
    self.titleBar = self.titleBar or GetNamedControl("NMGuildHall_TitleBar")
    self.header = self.header or GetNamedControl("NMGuildHall_Header")
    self.headerDragHandle = self.headerDragHandle or GetNamedControl("NMGuildHall_HeaderDragHandle")
    self.tabBar = self.tabBar or GetNamedControl("NMGuildHall_TabBar")
    self.footer = self.footer or GetNamedControl("NMGuildHall_Footer")
    self.queueStatusLabel = self.queueStatusLabel or GetNamedControl("NMGuildHall_FooterQueueLabel")
    self.content = self.content or GetNamedControl("NMGuildHall_ContentArea")
    self.contentBg = self.contentBg or GetNamedControl("NMGuildHall_ContentBG")

    self.tabs = self.tabs or {}
    for _, tabId in ipairs(TAB_ORDER) do
        if not self.tabs[tabId] then
            local tab = GetNamedControl("NMGuildHall_Tab_" .. tabId)
            if tab then
                tab.background = tab.background or GetNamedControl("NMGuildHall_Tab_" .. tabId .. "_BG")
                tab.label = tab.label or GetNamedControl("NMGuildHall_Tab_" .. tabId .. "_Label")
                tab.data = tab.data or { id = tabId }
                self.tabs[tabId] = tab
            end
        end
    end

    self.contentContainers = self.contentContainers or {}
    self.contentContainers.home = self.contentContainers.home or GetNamedControl("NMGuildHall_HomeContainer")
    self.contentContainers.teleport = self.contentContainers.teleport or GetNamedControl("NMGuildHall_TeleportContainer")
    self.contentContainers.campaign = self.contentContainers.campaign or GetNamedControl("NMGuildHall_CampaignContainer")
    self.contentContainers.pledges = self.contentContainers.pledges or GetNamedControl("NMGuildHall_PledgesContainer")
end

function UI:_EnsureStaticSections()
    self:_ReacquireStaticControls()

    if not self.window then
        return false
    end

    if not self.header then
        self:CreateHeader()
        self:_ReacquireStaticControls()
    end

    if not self.tabBar then
        self:CreateTabs()
        self:_ReacquireStaticControls()
    end

    if not self.content then
        self:CreateContentArea()
        self:_ReacquireStaticControls()
    else
        self.contentContainers = self.contentContainers or {}
        if not self.contentContainers.home and self.CreateHomeContent then
            self:CreateHomeContent()
        end
        if not self.contentContainers.teleport and self.CreateTeleportContent then
            self:CreateTeleportContent()
        end
        if not self.contentContainers.campaign and self.CreateCampaignContent then
            self:CreateCampaignContent()
        end
        if not self.contentContainers.pledges and self.CreatePledgesContent then
            self:CreatePledgesContent()
        end
        self:_ReacquireStaticControls()
    end

    if not self.footer then
        self:CreateFooter()
        self:_ReacquireStaticControls()
    end

    return self.header ~= nil
        and self.tabBar ~= nil
        and self.content ~= nil
        and self.footer ~= nil
end

-- Create the main window
function UI:Initialize()
    if self.initialized or self._initializing then
        return
    end

    self._initializing = true
    self._initToken = (self._initToken or 0) + 1
    local initToken = self._initToken

    local log = UILogger()
    if log then
        log:Debug(GetString(NMGH_DEBUG_UI_LOADED))
    end
    WaitForResources(function()
        if self._initToken ~= initToken or self.initialized then
            return
        end

        self._initializing = false
        if not self.window then
            self:CreateMainWindow()
        end

        if not self:_EnsureStaticSections() then
            self.initialized = false
            return
        end

        if NMGuildHall and NMGuildHall.Campaign and NMGuildHall.Campaign.AttachQueueLabel and self.queueStatusLabel then
            NMGuildHall.Campaign:AttachQueueLabel(self.queueStatusLabel)
        end

        if not self.teleportButtonPool then
            self:CreateTeleportButtonPool()
        end
        if not self.groupButtonPool then
            self:CreateGroupButtonPool()
        end
        self:RefreshContent()
        self.initialized = true

        -- Register group events for auto-refresh
        local function OnGroupUpdate()
            if self.isShowing and self.currentTab == "group" then
                self:UpdateGroupContent()
            end
        end
        
        local groupEvents = {
            EVENT_GROUP_MEMBER_JOINED,
            EVENT_GROUP_MEMBER_LEFT,
            EVENT_GROUP_UPDATE,
            EVENT_LEADER_UPDATE
        }
        
        for _, eventCode in ipairs(groupEvents) do
            if NMGuildHall and NMGuildHall.EventManager then
                NMGuildHall.EventManager:RegisterEvent(eventCode, OnGroupUpdate, "NMGuildHall_UI")
            else
                local ownerName = NMGuildHall.name .. "_UI_Group_" .. eventCode
                self.registeredEvents[eventCode] = ownerName
                EVENT_MANAGER:RegisterForEvent(ownerName, eventCode, OnGroupUpdate)
            end
        end

        -- Sync dialog keybinds if settings change
        local function OnKeybindsUpdated()
            if self.dialogOverlay and not self.dialogOverlay:IsHidden() then
                if self.lastDialogTitle and self.lastDialogBody and self.lastButtonConfigs then
                    self:ShowDialog(self.lastDialogTitle, self.lastDialogBody, self.lastButtonConfigs, self.lastDialogOptions)
                end
            end
        end
        if NMGuildHall and NMGuildHall.EventManager then
            NMGuildHall.EventManager:RegisterEvent(EVENT_KEYBINDING_SET, OnKeybindsUpdated, "NMGuildHall_UI")
        else
            local keybindOwner = "NMGuildHall_KeybindUpdate"
            EVENT_MANAGER:RegisterForEvent(keybindOwner, EVENT_KEYBINDING_SET, OnKeybindsUpdated)
            self.registeredEvents[EVENT_KEYBINDING_SET] = keybindOwner
        end

        -- Ensure all content containers start hidden
        for id, container in pairs(self.contentContainers) do
            container:SetHidden(true)
        end

        -- Start with window hidden
        self.window:SetHidden(true)
    end, function()
        if self._initToken == initToken then
            self._initializing = false
        end
    end)
end

function UI:CreateMainWindow()
    local Constants = NMGuildHall and NMGuildHall.Constants
    local windowConfig = Constants and Constants.UI and Constants.UI.WINDOW
    local defaultWidth = (windowConfig and windowConfig.DEFAULT_WIDTH) or 700
    local defaultHeight = (windowConfig and windowConfig.DEFAULT_HEIGHT) or 550
    local minWidth = (windowConfig and windowConfig.MIN_WIDTH) or defaultWidth
    local minHeight = (windowConfig and windowConfig.MIN_HEIGHT) or defaultHeight
    local maxWidth = (windowConfig and windowConfig.MAX_WIDTH) or defaultWidth
    local maxHeight = (windowConfig and windowConfig.MAX_HEIGHT) or defaultHeight

    if self.window then
        return self.window
    end

    local existingWindow = WINDOW_MANAGER:GetControlByName(MAIN_WINDOW_NAME)
    if existingWindow then
        self.window = existingWindow
        self.background = WINDOW_MANAGER:GetControlByName("NMGuildHall_MainWindowBG")
        self.titleBar = WINDOW_MANAGER:GetControlByName("NMGuildHall_TitleBar")
        return existingWindow
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow(MAIN_WINDOW_NAME)

    local db = (Addon and Addon.db) or (NMGuildHall and NMGuildHall.db) or {}

    -- Window resizing is intentionally disabled; always use configured defaults.
    local width = defaultWidth
    local height = defaultHeight
    window:SetDimensions(width, height)

    self:_ApplySavedAnchor(window, db, "windowX", "windowY", function(control)
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end, {
        clampToScreen = true,
        hasSavedFn = function(savedDb)
            local posSaved = savedDb and savedDb.windowPositionSaved == true
            if not posSaved and savedDb and savedDb.windowPositionSaved == nil
                and type(savedDb.windowX) == "number" and type(savedDb.windowY) == "number" then
                posSaved = not (savedDb.windowX == 0 and savedDb.windowY == 0)
            end
            return posSaved
        end,
    })

    window:SetMovable(false)
    window:SetMouseEnabled(true)
    window:SetKeyboardEnabled(true)
    window:SetClampedToScreen(true)
    if window.SetResizeHandleSize then
        window:SetResizeHandleSize(0) -- Disable resizing
    end
    window:SetHidden(true)

    self:_AttachPersistedMoveStop(window, db, "windowX", "windowY", function(control, savedDb)
        if savedDb then
            savedDb.windowPositionSaved = true
        end
        if control and control.SetMovable then
            control:SetMovable(false)
        end
    end)

    -- Save size on resize stop
    -- Resizing is disabled (resize handle size is 0), so we don't register any resize handlers.

    local bg = WINDOW_MANAGER:CreateControl("NMGuildHall_MainWindowBG", window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.07, 0.85)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
    bg:SetEdgeColor(0.4, 0.3, 0.2, 0.8)

    local titleBar = WINDOW_MANAGER:CreateControl("NMGuildHall_TitleBar", window, CT_TEXTURE)
    titleBar:SetHeight(40)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    titleBar:SetTexture("EsoUI/Art/Windows/window_top_edge.dds")
    titleBar:SetColor(0.8, 0.7, 0.5, 0.7)

    local cornerTL = WINDOW_MANAGER:CreateControl("NMGuildHall_CornerTL", window, CT_TEXTURE)
    cornerTL:SetDimensions(32, 32)
    cornerTL:SetAnchor(TOPLEFT, window, TOPLEFT, -2, -2)
    cornerTL:SetTexture("EsoUI/Art/Windows/window_corner_topleft.dds")

    local cornerTR = WINDOW_MANAGER:CreateControl("NMGuildHall_CornerTR", window, CT_TEXTURE)
    cornerTR:SetDimensions(32, 32)
    local cornerInset = 14
    cornerTR:SetAnchor(TOPRIGHT, window, TOPRIGHT, -cornerInset, -2)
    cornerTR:SetTexture("EsoUI/Art/Windows/window_corner_topright.dds")

    local cornerBL = WINDOW_MANAGER:CreateControl("NMGuildHall_CornerBL", window, CT_TEXTURE)
    cornerBL:SetDimensions(32, 32)
    cornerBL:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, -2, -cornerInset)
    cornerBL:SetTexture("EsoUI/Art/Windows/window_corner_bottomleft.dds")

    local cornerBR = WINDOW_MANAGER:CreateControl("NMGuildHall_CornerBR", window, CT_TEXTURE)
    cornerBR:SetDimensions(32, 32)
    cornerBR:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -cornerInset, -cornerInset)
    cornerBR:SetTexture("EsoUI/Art/Windows/window_corner_bottomright.dds")

    self.window = window
    self.background = bg
    self.titleBar = titleBar
end

function UI:CreateHeader()
    local Constants = NMGuildHall and NMGuildHall.Constants
    local windowConfig = Constants and Constants.UI and Constants.UI.WINDOW
    local defaultWidth = (windowConfig and windowConfig.DEFAULT_WIDTH) or 700
    local width = (self.window and self.window.GetWidth and self.window:GetWidth()) or defaultWidth
    local header = WINDOW_MANAGER:CreateControl("NMGuildHall_Header", self.window, CT_CONTROL)
    header:SetDimensions(width, 70)
    header:SetAnchor(TOP, self.window, TOP, 0, 0)

    -- Use ESO's header background texture with transparency
    local headerBg = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderBG", header, CT_TEXTURE)
    headerBg:SetAnchorFill()
    headerBg:SetTexture("EsoUI/Art/Windows/window_top_edge.dds")
    headerBg:SetColor(0.8, 0.7, 0.5, 0.6) -- More transparent

    -- Add header divider line using ESO texture
    local headerDivider = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderDivider", header, CT_TEXTURE)
    headerDivider:SetDimensions(width - 40, 2)
    headerDivider:SetAnchor(BOTTOM, header, BOTTOM, 0, -5)
    headerDivider:SetTexture("EsoUI/Art/Windows/window_divider.dds")
    headerDivider:SetColor(0.8, 0.2, 0.3, 1) -- Crimson color

    -- Title with icon positioned just before text, vertically centered
    local titleTop = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderTitleTop", header, CT_LABEL)
    titleTop:SetFont("ZoFontWinH2")
    titleTop:SetText(GetString(NMGH_NAME))
    titleTop:SetAnchor(CENTER, header, CENTER, 0, -14) -- Centered
    titleTop:SetColor(0.8, 0.2, 0.3, 1.0) -- Crimson color to match theme

    local titleBottom = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderTitleBottom", header, CT_LABEL)
    titleBottom:SetFont("ZoFontWinH2")
    titleBottom:SetText(GetString(NMGH_GUILD_HUB))
    titleBottom:SetAnchor(CENTER, header, CENTER, 0, 14) -- Centered
    titleBottom:SetColor(0.8, 0.2, 0.3, 1.0) -- Crimson color to match theme

    -- Separate icon control for precise positioning, anchored relative to the top text
    local titleIcon = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderIcon", header, CT_TEXTURE)
    titleIcon:SetDimensions(40, 40)
    -- Anchor to the left of the top title, adjusted vertically to be centered in the header
    -- titleTop is at Y=-14. We want icon at Y=0. So offset Y is +14.
    titleIcon:SetAnchor(RIGHT, titleTop, LEFT, -15, 14)
    local style = (NMGuildHall and NMGuildHall.db and NMGuildHall.db.chatIconStyle) or (NMGuildHall and NMGuildHall.defaults and NMGuildHall.defaults.chatIconStyle) or "new"
    local mono = NMGuildHall and NMGuildHall.db and NMGuildHall.db.monochromeIcon
    local textures = nil
    if NMGuildHall and NMGuildHall.Constants and NMGuildHall.Constants.CHAT_ICON then
        local sets = NMGuildHall.Constants.CHAT_ICON.SETS
        if sets and sets[style] then
            textures = sets[style]
        else
            textures = NMGuildHall.Constants.CHAT_ICON.TEXTURES
        end
    end
    if textures then
        if mono then
            titleIcon:SetTexture(textures.MONO)
        else
            titleIcon:SetTexture(textures.NORMAL)
        end
    end

    -- Close button using ESO textures
    local uiIcons = Constants and Constants.UI and Constants.UI.ICONS
    local closeBtn = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderCloseBtn", header, CT_BUTTON)
    closeBtn:SetDimensions(32, 32)
    closeBtn:SetAnchor(RIGHT, header, RIGHT, -10, 0)
    closeBtn:SetNormalTexture(uiIcons and uiIcons.CLOSE.NORMAL or "EsoUI/Art/Buttons/closebutton_up.dds")
    closeBtn:SetPressedTexture(uiIcons and uiIcons.CLOSE.PRESSED or "EsoUI/Art/Buttons/closebutton_down.dds")
    closeBtn:SetMouseOverTexture(uiIcons and uiIcons.CLOSE.OVER or "EsoUI/Art/Buttons/closebutton_over.dds")
    closeBtn:SetHandler("OnClicked", function()
        self:Hide()
    end)

    -- Settings button using ESO textures
    local settingsBtn = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderSettingsBtn", header, CT_BUTTON)
    settingsBtn:SetDimensions(32, 32)
    settingsBtn:SetAnchor(RIGHT, closeBtn, LEFT, -5, 0)
    settingsBtn:SetNormalTexture(uiIcons and uiIcons.SETTINGS.NORMAL or "EsoUI/Art/Buttons/settings_up.dds")
    settingsBtn:SetPressedTexture(uiIcons and uiIcons.SETTINGS.PRESSED or "EsoUI/Art/Buttons/settings_down.dds")
    settingsBtn:SetMouseOverTexture(uiIcons and uiIcons.SETTINGS.OVER or "EsoUI/Art/Buttons/settings_over.dds")
    settingsBtn:SetHandler("OnClicked", function()
        self:Hide()
        if LibAddonMenu2 and NMGuildHall.panel then
            LibAddonMenu2:OpenToPanel(NMGuildHall.panel)
        end
    end)

    -- Dedicated drag surface so only the header chrome initiates movement.
    local dragHandle = WINDOW_MANAGER:CreateControl("NMGuildHall_HeaderDragHandle", header, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, header, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(BOTTOMRIGHT, settingsBtn, BOTTOMLEFT, -10, 0)
    self:_AttachClickOrDrag(self.window, dragHandle, {
        dragThreshold = 4,
        canDrag = function()
            return self.window ~= nil and self.window:IsHidden() == false
        end,
        beforeStartDrag = function(control)
            if control and control.SetMovable then
                control:SetMovable(true)
            end
        end,
        afterStopDrag = function(control)
            if control and control.SetMovable then
                control:SetMovable(false)
            end
        end,
    })

    self.header = header
    self.headerDragHandle = dragHandle
end

function UI:CreateFooter()
    local Constants = NMGuildHall and NMGuildHall.Constants
    local windowConfig = Constants and Constants.UI and Constants.UI.WINDOW
    local defaultWidth = (windowConfig and windowConfig.DEFAULT_WIDTH) or 700
    local width = (self.window and self.window.GetWidth and self.window:GetWidth()) or defaultWidth
    local footer = WINDOW_MANAGER:CreateControl("NMGuildHall_Footer", self.window, CT_CONTROL)
    footer:SetDimensions(width, 40)
    footer:SetAnchor(BOTTOM, self.window, BOTTOM, 0, 0)

    -- Footer background
    local footerBg = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterBG", footer, CT_BACKDROP)
    footerBg:SetAnchorFill()
    footerBg:SetCenterColor(0.12, 0.12, 0.14, 1)
    footerBg:SetCenterColor(0.03, 0.03, 0.04, 0.8) -- More transparent
    footerBg:SetEdgeTexture("", 1, 1, 0, 0)

    -- Footer top border accent
    local footerAccent = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterAccent", footer, CT_TEXTURE)
    footerAccent:SetDimensions(width, 2)
    footerAccent:SetAnchor(TOP, footer, TOP, 0, 0)
    footerAccent:SetColor(0.8, 0.2, 0.3, 0.6)

    -- Reload UI button
    local reloadBtn = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterReloadBtn", footer, CT_BUTTON)
    reloadBtn:SetDimensions(130, 32)
    reloadBtn:SetAnchor(RIGHT, footer, RIGHT, -15, 0)

    local reloadBg = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterReloadBG", reloadBtn, CT_BACKDROP)
    reloadBg:SetAnchorFill()
    reloadBg:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Match action buttons
    reloadBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1) -- Power of 2 dimensions
    reloadBg:SetEdgeColor(0.8, 0.2, 0.3, 1.0) -- Crimson edges
    reloadBg:SetInsets(2, 2, -2, -2) -- Enhanced shadow for depth

    local reloadLabel = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterReloadLabel", reloadBtn, CT_LABEL)
    reloadLabel:SetFont("ZoFontGameBold")
    reloadLabel:SetText("|t18:18:EsoUI/Art/Housing/Gamepad/gp_toolicon_rotate_y.dds|t " .. GetString(NMGH_BUTTON_RELOAD_UI))
    reloadLabel:SetAnchor(CENTER, reloadBtn, CENTER, 0, 0)

    reloadBtn:SetHandler("OnClicked", function()
        ReloadUI()
    end)

    reloadBtn:SetHandler("OnMouseEnter", function()
        reloadBg:SetCenterColor(0.15, 0.15, 0.20, 0.95) -- Lighter hover
        reloadBg:SetEdgeColor(1.0, 0.3, 0.4, 1.0) -- Bright crimson edges
        reloadBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 8, 8, 1, 1) -- Thicker on hover
    end)

    reloadBtn:SetHandler("OnMouseExit", function()
        reloadBg:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Restore to normal
        reloadBg:SetEdgeColor(0.8, 0.2, 0.3, 1.0) -- Restore to crimson
        reloadBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1) -- Restore thickness
    end)

    local queueLabel = WINDOW_MANAGER:CreateControl("NMGuildHall_FooterQueueLabel", footer, CT_LABEL)
    queueLabel:SetFont("ZoFontGameSmall")
    queueLabel:SetColor(0.9, 0.9, 0.9, 1)
    queueLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    queueLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    queueLabel:SetAnchor(RIGHT, reloadBtn, LEFT, -20, 0)
    queueLabel:SetWidth(width - 180)
    queueLabel:SetHidden(true)
    self.queueStatusLabel = queueLabel
    if NMGuildHall and NMGuildHall.Campaign and NMGuildHall.Campaign.AttachQueueLabel then
        NMGuildHall.Campaign:AttachQueueLabel(queueLabel)
    end

    self.footer = footer
end

function UI:Show(targetTab)
    local requestedTab = targetTab or "home"
    local isReady = self.window and self.initialized == true and self.tabs and self.contentContainers

    if not isReady then
        if self.EnsureReady then
            self:EnsureReady(function(success)
                if success then
                    self:Show(requestedTab)
                end
            end)
            return
        end

        if NMGuildHall and NMGuildHall.Message then
            NMGuildHall.Message:For("UI"):Error(GetString(NMGH_ERROR_UI_NOT_READY))
        end
        return
    end

    self.window:SetHidden(false)
    self.isShowing = true
    self:SwitchTab(requestedTab)
end

function UI:ResetPosition()
    if Addon and Addon.db then
        Addon.db.windowX = (Addon.defaults and Addon.defaults.windowX) or 0
        Addon.db.windowY = (Addon.defaults and Addon.defaults.windowY) or 0
        Addon.db.windowPositionSaved = nil
    end

    if not self.window then
        return
    end

    self.window:ClearAnchors()
    self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    if self.window.SetMovable then
        self.window:SetMovable(false)
    end
end

function UI:EnsureReady(callback)
    local function IsReady()
        return self.window ~= nil and self.initialized == true and self.tabs ~= nil and self.contentContainers ~= nil
    end

    if IsReady() then
        if type(callback) == "function" then
            pcall(callback, true)
        end
        return
    end

    self._ensureReadyCallbacks = self._ensureReadyCallbacks or {}
    if type(callback) == "function" then
        table.insert(self._ensureReadyCallbacks, callback)
    end
    if self._ensureReadyPending then
        return
    end

    self._ensureReadyPending = true

    local log = UILogger()
    local Constants = Addon and Addon.Constants
    local timeoutMs = (Constants and Constants.UI and Constants.UI.WINDOW and Constants.UI.WINDOW.RESOURCE_TIMEOUT_MS) or 10000
    local startTime = GetGameTimeMilliseconds()
    local attemptedInit = false

    local function BeginInit()
        if attemptedInit or self._initializing then
            return
        end
        attemptedInit = true

        if not self.window then
            self.initialized = false
        end

        if Addon and Addon.InitializeUI then
            local ok, err = pcall(Addon.InitializeUI, Addon)
            if not ok and log then
                log:Error(GetString(NMGH_ERROR_UI_NOT_READY))
                log:Debug("UI self-heal init failed: {error}", { error = tostring(err) })
            end
        elseif log then
            log:Error(GetString(NMGH_ERROR_UI_NOT_READY))
        end
    end

    if not self._initializing then
        BeginInit()
    end

    local function WaitForReady()
        if IsReady() then
            FlushEnsureReadyCallbacks(self, true)
            return
        end

        if GetGameTimeMilliseconds() - startTime > timeoutMs then
            if log then
                log:Error(GetString(NMGH_ERROR_UI_NOT_READY))
            end
            FlushEnsureReadyCallbacks(self, false)
            return
        end

        if not self._initializing and not attemptedInit then
            BeginInit()
        end

        zo_callLater(WaitForReady, 100)
    end

    WaitForReady()
end

function UI:Hide()
    if self.dialogOverlay then
        self:HideDialog({
            skipSound = true,
            suppressParentHide = true,
        })
    end
    if self.modalEditOverlay then
        self:HideModalEdit({
            fireCancel = false,
            skipSound = true,
        })
    end

    if self.window then
        self.window:SetHidden(true)
    end
    self.isShowing = false
end

function UI:Toggle()
    if self.isShowing then
        self:Hide()
    else
        self:Show()
    end
end

function UI:Refresh()
    if self.currentTab == "pledges" then
        self:UpdatePledges()
    elseif self.currentTab == "group" then
        self:UpdateGroupContent()
    elseif self.currentTab == "teleport" then
        local searchText = self.teleportSearchBox and self.teleportSearchBox:GetText() or ""
        self:RefreshTeleportList(searchText)
    end
end

-- Cleanup function to prevent memory leaks
function UI:Cleanup()
    self._initToken = (self._initToken or 0) + 1
    self._initializing = false

    if self._teleportSearchDebounceHandle then
        zo_removeCallLater(self._teleportSearchDebounceHandle)
        self._teleportSearchDebounceHandle = nil
    end

    if self.dialogOverlay then
        self:HideDialog({
            skipSound = true,
            suppressParentHide = true,
        })
        self.dialogKeybindDescriptor = nil
        self._dialogKeybindsAdded = false
        self.lastDialogTitle = nil
        self.lastDialogBody = nil
        self.lastButtonConfigs = nil
        self.lastDialogOptions = nil
    end

    if self.modalEditOverlay then
        self:HideModalEdit({
            fireCancel = false,
            skipSound = true,
        })
    end

    -- Release pooled row objects, but keep the pools and static controls alive for runtime reinit.
    local pools = {
        { name = "teleportButtonPool", label = "teleport" },
        { name = "groupButtonPool", label = "group" },
        { name = "campaignRowPool", label = "campaign" }
    }

    for _, poolInfo in ipairs(pools) do
        local pool = self[poolInfo.name]
        if pool then
            local success, err = pcall(function()
                pool:ReleaseAllObjects()
            end)
            if not success then
                local log = UILogger()
                if log then
                    log:Warn(GetString(NMGH_ERR_UI_POOL_RELEASE_FAILED), {label = poolInfo.label, error = tostring(err)})
                end
            end
        end
    end

    -- Reset state
    self.currentTab = "home"
    self.isShowing = false
    self.groupContentInitialized = false
    self.initialized = false
    self.actionButtonCounter = 0
    self.teleportButtonCounter = 0
    self.campaignRowCounter = 0

    if NMGuildHall and NMGuildHall.EventManager then
        NMGuildHall.EventManager:UnregisterEventsByOwner("NMGuildHall_UI")
    else
        for eventName, ownerName in pairs(self.registeredEvents) do
            local success = pcall(function()
                EVENT_MANAGER:UnregisterForEvent(ownerName, eventName)
            end)
            if not success then
                if NMGuildHall and NMGuildHall.Message then
                    NMGuildHall.Message:For("UI"):Warn(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = tostring(eventName)})
                end
            end
        end
    end
    self.registeredEvents = {}

    -- Clear window
    if self.window then
        self.window:SetHidden(true)
    end

    if NMGuildHall and NMGuildHall.Message then
        NMGuildHall.Message:For("UI"):Debug(GetString(NMGH_DEBUG_UI_CLEANUP_DONE))
    end
end

-- Refresh content to fit new window size
function UI:RefreshContent()
    if not self.window then return end

    local width, height = self.window:GetDimensions()

    -- Resize top-level sections to follow the window dimensions.
    if self.titleBar then
        -- Stretches via anchors set in CreateMainWindow; nothing else needed.
    end

    if self.header then
        self.header:SetWidth(width)
        local headerDivider = WINDOW_MANAGER:GetControlByName("NMGuildHall_HeaderDivider")
        if headerDivider then
            headerDivider:SetWidth(width - 40)
        end
    end

    if self.footer then
        self.footer:SetWidth(width)
        local footerAccent = WINDOW_MANAGER:GetControlByName("NMGuildHall_FooterAccent")
        if footerAccent then
            footerAccent:SetWidth(width)
        end
        if self.queueStatusLabel then
            self.queueStatusLabel:SetWidth(width - 180)
        end
    end

    if self.tabBar then
        self.tabBar:SetWidth(width)
        -- Reflow tabs to fill the new width.
        if self.tabs then
            local order = {"home", "teleport", "group", "campaign", "pledges"}
            local numTabs = #order
            local tabGap = 4
            local tabWidth = math.floor((width - (numTabs - 1) * tabGap) / numTabs)
            for i, id in ipairs(order) do
                local tab = self.tabs[id]
                if tab then
                    tab:SetDimensions(tabWidth, 50)
                    tab:ClearAnchors()
                    tab:SetAnchor(LEFT, self.tabBar, LEFT, (i - 1) * (tabWidth + tabGap), 0)
                end
            end
        end
    end

    -- Update content area size
    if self.content then
        -- Matches CreateContentArea sizing (keep consistent margins/padding)
        local contentWidth = math.max(480, width - 20)
        local contentHeight = math.max(240, height - 175)
        self.content:SetDimensions(contentWidth, contentHeight)
    end

    -- Resize per-tab containers to match the content area
    if self.content and self.contentContainers then
        local cw, ch = self.content:GetDimensions()
        local containerW = math.max(200, cw - 20)
        local containerH = math.max(200, ch - 20)
        for _, container in pairs(self.contentContainers) do
            if container and container.SetDimensions then
                container:SetDimensions(containerW, containerH)
            end
        end

        -- Targeted resize for known scroll containers so bigger windows actually expose more content.
        local searchContainer = WINDOW_MANAGER:GetControlByName("NMGuildHall_TeleportSearchContainer")
        if searchContainer then
            searchContainer:SetWidth(math.max(200, containerW - 40))
        end
        local teleportScroll = WINDOW_MANAGER:GetControlByName("NMGuildHallTeleportScroll")
        if teleportScroll then
            teleportScroll:SetDimensions(containerW, math.max(100, containerH - 95))
        end

        local campaignDescription = WINDOW_MANAGER:GetControlByName("NMGuildHall_CampaignDescription")
        if campaignDescription then
            campaignDescription:SetWidth(math.max(200, containerW - 40))
        end
        local campaignScroll = WINDOW_MANAGER:GetControlByName("NMGuildHall_CampaignScroll")
        if campaignScroll then
            campaignScroll:SetDimensions(containerW, math.max(100, containerH - 110))
        end
    end

    -- Refresh current tab content
    if self.currentTab == "teleport" then
        self:RefreshTeleportList("")
    elseif self.currentTab == "group" then
        self:UpdateGroupContent()
    elseif self.currentTab == "pledges" then
        self:UpdatePledges()
    end

    if NMGuildHall and NMGuildHall.Message then
        NMGuildHall.Message:For("UI"):Debug(GetString(NMGH_DEBUG_CONTENT_REFRESHED), {width = width, height = height})
    end
end
