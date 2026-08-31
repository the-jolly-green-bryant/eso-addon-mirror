local ADDON_NAME = "ChatEx"
local SAVED_VARIABLES_VERSION = 2
local DEFAULT_WIDTH = 445
local DEFAULT_HEIGHT = 267
local DEFAULT_MIN_WIDTH = 300
local DEFAULT_MAX_WIDTH = 550
local DEFAULT_MIN_HEIGHT = 170
local DEFAULT_MAX_HEIGHT = 380
local RESIZE_HANDLE_SIZE = 8
local FADE_ANIMATION_DURATION = 350
local FADE_ANIMATION_DELAY = 3000
local MINIMIZED_STATE_POLL_INTERVAL_MS = 250

local savedVariables
local mirrorsByTab = setmetatable({}, { __mode = "k" })
local mirrorsByName = {}
local nextMirrorControlId = 1
local activeDragMirror

local function GetChatSystem()
    return CHAT_SYSTEM or (ZO_GetChatSystem and ZO_GetChatSystem())
end

local function UseCanonicalSingleContainer()
    local chatSystem = GetChatSystem()
    if chatSystem and chatSystem.SetAllowMultipleContainers then
        chatSystem:SetAllowMultipleContainers(false)
    end
end

local function GetTabName(tab)
    return tab and (ZO_TabButton_Text_GetText(tab) or "") or ""
end

local function FindWindowForTab(tab)
    local container = tab and tab.container
    if not container or not container.windows then
        return nil, nil
    end
    local localIndex = tab.index
    local window = localIndex and container.windows[localIndex]
    if window and window.tab == tab then
        return window, localIndex
    end
    for index, candidate in ipairs(container.windows) do
        if candidate.tab == tab then
            return candidate, index
        end
    end
end

local function GetMirrorSettings(name)
    savedVariables.mirrors = savedVariables.mirrors or {}
    local settings = savedVariables.mirrors[name]
    if not settings then
        settings = { width = DEFAULT_WIDTH, height = DEFAULT_HEIGHT }
        savedVariables.mirrors[name] = settings
    end
    return settings
end

local function SaveMirrorGeometry(mirror)
    if not mirror or not mirror.control or not mirror.settings then
        return
    end
    local control = mirror.control
    local _, point, _, relativePoint, offsetX, offsetY = control:GetAnchor(0)
    mirror.settings.point = point
    mirror.settings.relativePoint = relativePoint
    mirror.settings.x = offsetX
    mirror.settings.y = offsetY
    mirror.settings.width, mirror.settings.height = control:GetDimensions()
end

local function GetMirrorDimensionConstraints()
    local chatSystem = GetChatSystem()
    return (chatSystem and chatSystem.minContainerWidth) or DEFAULT_MIN_WIDTH,
           (chatSystem and chatSystem.minContainerHeight) or DEFAULT_MIN_HEIGHT,
           (chatSystem and chatSystem.maxContainerWidth) or DEFAULT_MAX_WIDTH,
           (chatSystem and chatSystem.maxContainerHeight) or DEFAULT_MAX_HEIGHT
end

local function GetMirrorFadeAlphas()
    local chatSystem = GetChatSystem()
    local primary = chatSystem and chatSystem.primaryContainer
    if primary and primary.GetBackgroundColor then
        local _, _, _, minAlpha, maxAlpha = primary:GetBackgroundColor()
        return minAlpha or 0.25, maxAlpha or 1
    end
    return 0.25, 1
end

local function PrepareMirrorFade(mirror)
    if not mirror.fadeAnim then
        mirror.fadeAnim = ZO_AlphaAnimation:New(mirror.control)
    end
    local minAlpha, maxAlpha = GetMirrorFadeAlphas()
    mirror.fadeAnim:SetMinMaxAlpha(minAlpha, maxAlpha)
end

local function FadeMirrorIn(mirror, delay)
    if not mirror or not mirror.control then
        return
    end
    PrepareMirrorFade(mirror)
    mirror.fadeAnim:FadeIn(delay or 0, FADE_ANIMATION_DURATION)
    local buffer = mirror.window and mirror.window.buffer
    if buffer and buffer.ShowFadedLines then
        buffer:ShowFadedLines()
    end
end

local function FadeMirrorOut(mirror, delay)
    if not mirror or not mirror.control or mirror.moving or mirror.resizing then
        return
    end
    PrepareMirrorFade(mirror)
    mirror.fadeAnim:FadeOut(delay or FADE_ANIMATION_DELAY, FADE_ANIMATION_DURATION)
end

local function MonitorMirrorMouse(mirror)
    if mirror.mouseMonitorInstalled then
        return
    end
    mirror.mouseMonitorInstalled = true
    mirror.control:SetHandler("OnUpdate", function(control)
        local mouseOverHeader = mirror.header and MouseIsOver(mirror.header)
        local fadeIsPlaying = mirror.fadeAnim and mirror.fadeAnim:IsPlaying()
        if not MouseIsOver(control) and not mouseOverHeader and not mirror.moving and not mirror.resizing and not fadeIsPlaying then
            mirror.mouseMonitorInstalled = false
            control:SetHandler("OnUpdate", nil)
            FadeMirrorOut(mirror)
        end
    end)
end

local function ApplyPerfectPixelBackdrop(backdrop)
    if not PP or not PP.GetSavedVars or not PP.CreateBackground then
        return false
    end

    local settings = PP:GetSavedVars("ChatWindow")
    if not settings or settings.toggle ~= true then
        return false
    end

    local parent = backdrop:GetParent()
    if parent and not parent.PP_BG then
        PP:CreateBackground(backdrop,
            nil, nil, nil, 6, 6,
            nil, nil, nil, -6, -6,
            "ChatWindow")
    elseif PP.UpdateBackgrounds then
        PP:UpdateBackgrounds("ChatWindow")
    end
    return true
end

local function ApplyOptionalBackdrop(backdrop)
    if ApplyPerfectPixelBackdrop(backdrop) then
        return
    elseif pChat and pChat.db then
        local darkness = tonumber(pChat.db.windowDarkness) or 1
        if darkness == 0 then
            local blank = "/esoui/art/icons/heraldrycrests_misc_blank_01.dds"
            backdrop:SetEdgeTexture(blank, 256, 256, 32)
            backdrop:SetCenterTexture(blank)
        elseif darkness == 1 then
            backdrop:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
            backdrop:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
        else
            local percentage = zo_clamp((darkness - 1) * 10, 10, 100)
            backdrop:SetEdgeTexture(string.format("pChat/dds/chat_bg_edge_%d.dds", percentage), 256, 256, 32)
            backdrop:SetCenterTexture(string.format("pChat/dds/chat_bg_center_%d.dds", percentage))
        end
    elseif rChat and rChat.save then
        local darkness = tonumber(rChat.save.windowDarkness) or 1
        if darkness <= 1 then
            backdrop:SetCenterColor(0, 0, 0, 0)
            backdrop:SetEdgeColor(0, 0, 0, 0)
        else
            local percentage = zo_clamp((darkness - 1) * 10, 10, 100)
            backdrop:SetCenterColor(0, 0, 0, 1)
            backdrop:SetEdgeColor(0, 0, 0, 1)
            backdrop:SetEdgeTexture(string.format("rChat/dds/chat_bg_edge_%d.dds", percentage), 256, 256, 32)
            backdrop:SetCenterTexture(string.format("rChat/dds/chat_bg_center_%d.dds", percentage))
        end
    else
        backdrop:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
        backdrop:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    end
    backdrop:SetInsets(32, 32, -32, -32)
end

local function ClearOriginalBuffer(mirror)
    local window, localIndex = FindWindowForTab(mirror.sourceTab)
    if not window then
        return
    end
    local timestamp = GetTimeStamp()
    if pChat and pChat.pChatData then
        pChat.pChatData.tabNotBefore = pChat.pChatData.tabNotBefore or {}
        pChat.pChatData.tabNotBefore[localIndex] = timestamp
    end
    if rChat and rChat.data then
        rChat.data.tabNotBefore = rChat.data.tabNotBefore or {}
        rChat.data.tabNotBefore[localIndex] = timestamp
    end
    window.buffer:Clear()
    local container = mirror.sourceTab and mirror.sourceTab.container
    if container and container.SyncScrollToBuffer then
        container:SyncScrollToBuffer()
    end
end

local CloseMirror

local function ShowMirrorContextMenu(mirror)
    local container = mirror.sourceTab and mirror.sourceTab.container
    local window, localIndex = FindWindowForTab(mirror.sourceTab)
    if not container or not window or not localIndex then
        return
    end

    ClearMenu()
    if not ZO_Dialogs_IsShowingDialog() then
        AddMenuItem(GetString(SI_CHAT_CONFIG_CREATE_NEW), function()
            container.system:CreateNewChatTab(container.system.primaryContainer)
        end)
        if not window.combatLog then
            AddMenuItem(GetString(SI_CHAT_CONFIG_REMOVE), function()
                container:ShowRemoveTabDialog(localIndex)
            end)
        end
        AddMenuItem(GetString(SI_CHAT_CONFIG_OPTIONS), function()
            container:ShowOptions(localIndex)
        end)
        if pChat and pChat.db and PCHAT_CLEARBUFFER then
            AddMenuItem(GetString(PCHAT_CLEARBUFFER), function() ClearOriginalBuffer(mirror) end)
        elseif rChat and rChat.save and RCHAT_CLEARBUFFER then
            AddMenuItem(GetString(RCHAT_CLEARBUFFER), function() ClearOriginalBuffer(mirror) end)
        end
        AddMenuItem(GetString(CHATEX_SHOW_ORIGINAL_TAB), function() CloseMirror(mirror) end)
    end
    if window.combatLog then
        if container:AreTimestampsEnabled(localIndex) then
            AddMenuItem(GetString(SI_CHAT_CONFIG_HIDE_TIMESTAMP), function()
                container:SetTimestampsEnabled(localIndex, false)
            end)
        else
            AddMenuItem(GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), function()
                container:SetTimestampsEnabled(localIndex, true)
            end)
        end
    end
    AddMenuItem(GetString(SI_CHAT_CONFIG_RESET), function() ZO_Dialogs_ShowDialog("CHAT_RESET") end)
    ShowMenu(mirror.header)
end

local function ApplyMirrorVisibility(mirror)
    if not mirror or not mirror.sourceTab or not mirror.window then
        return
    end
    if not mirror.deferTabHide then
        mirror.sourceTab:SetHidden(true)
        mirror.sourceTab:SetMouseEnabled(false)
    end
    mirror.window:SetHidden(false)
end

local function RefreshAllMirrorVisibility()
    for _, mirror in pairs(mirrorsByName) do
        ApplyMirrorVisibility(mirror)
    end
end

local function SelectAnotherCanonicalTab(mirror)
    local container = mirror.sourceTab.container
    if not container or container.currentBuffer ~= mirror.window.buffer then
        return
    end
    for _, candidate in ipairs(container.windows or {}) do
        if candidate ~= mirror.window and not mirrorsByTab[candidate.tab] then
            container.tabGroup:SetClickedButton(candidate.tab)
            return
        end
    end
end

local function IsGlobalLayoutLocked()
    local chatSystem = GetChatSystem()
    local primary = chatSystem and chatSystem.primaryContainer
    local firstWindow = primary and primary.windows and primary.windows[1]
    return firstWindow and firstWindow.locked == true or false
end

local function ApplyMirrorLockState(mirror, locked)
    if not mirror or not mirror.control then
        return
    end

    mirror.locked = locked == true
    mirror.control:SetResizeHandleSize(mirror.locked and 0 or RESIZE_HANDLE_SIZE)

    if mirror.locked then
        mirror.control:StopMovingOrResizing()
        mirror.control:SetMovable(false)
        mirror.moving = false
        mirror.resizing = false
        SaveMirrorGeometry(mirror)
        if activeDragMirror == mirror then
            activeDragMirror = nil
        end
    end
end

local function ApplyGlobalLockState(locked)
    local chatSystem = GetChatSystem()
    local primary = chatSystem and chatSystem.primaryContainer
    if not primary then
        return
    end

    locked = locked == true
    for localIndex = 2, #(primary.windows or {}) do
        local window = primary.windows[localIndex]
        if window and window.locked ~= locked then
            window.locked = locked
            primary:SaveWindowSettings(localIndex)
        end
    end

    for _, mirror in pairs(mirrorsByName) do
        ApplyMirrorLockState(mirror, locked)
    end
end

local function MinimizeMirror(mirror)
    if not mirror or not mirror.control then
        return
    end

    SaveMirrorGeometry(mirror)
    mirror.control:StopMovingOrResizing()
    mirror.control:SetMovable(false)
    mirror.moving = false
    mirror.resizing = false
    mirror.control:SetHidden(true)
end

local function MaximizeMirror(mirror)
    if not mirror or not mirror.control then
        return
    end

    local settings = mirror.settings
    if settings then
        mirror.control:ClearAnchors()
        mirror.control:SetAnchor(settings.point or TOPLEFT, GuiRoot,
            settings.relativePoint or settings.point or TOPLEFT,
            settings.x or 0, settings.y or 0)
        mirror.control:SetDimensions(settings.width or DEFAULT_WIDTH, settings.height or DEFAULT_HEIGHT)
    end
    mirror.control:SetClampedToScreen(true)
    mirror.control:SetHidden(false)
    ApplyMirrorVisibility(mirror)
    FadeMirrorIn(mirror)
    MonitorMirrorMouse(mirror)
end

local function MinimizeAllMirrors()
    for _, mirror in pairs(mirrorsByName) do
        MinimizeMirror(mirror)
    end
end

local function MaximizeAllMirrors()
    RefreshAllMirrorVisibility()
    for _, mirror in pairs(mirrorsByName) do
        MaximizeMirror(mirror)
    end
    RefreshAllMirrorVisibility()
    zo_callLater(RefreshAllMirrorVisibility, 0)
end

local lastObservedMinimizedState

local function SynchronizeMirrorMinimizedState(force)
    local chatSystem = GetChatSystem()
    if not chatSystem or not chatSystem.IsMinimized then
        return
    end

    local minimized = chatSystem:IsMinimized() == true
    if not force and minimized == lastObservedMinimizedState then
        return
    end
    lastObservedMinimizedState = minimized

    if minimized then
        MinimizeAllMirrors()
    else
        MaximizeAllMirrors()
    end
end

local function BeginMovingMirror(mirror)
    if not mirror or not mirror.control or IsGlobalLayoutLocked() then
        return
    end
    mirror.control:SetMovable(true)
    mirror.moving = true
    FadeMirrorIn(mirror)
    mirror.control:StartMoving()
    activeDragMirror = mirror
end

local function StopMovingMirror(mirror)
    if not mirror or not mirror.control then
        return
    end
    mirror.control:StopMovingOrResizing()
    mirror.control:SetMovable(false)
    mirror.moving = false
    mirror.deferTabHide = false
    ApplyMirrorVisibility(mirror)
    SaveMirrorGeometry(mirror)
    if activeDragMirror == mirror then
        activeDragMirror = nil
    end
    MonitorMirrorMouse(mirror)
end

local function ReactivateMirror(mirror, tab, startAtTab)
    local window, localIndex = FindWindowForTab(tab)
    local container = tab and tab.container
    if not window or not container or not container:IsPrimary() or localIndex <= 1 then
        return nil
    end

    local name = GetTabName(tab)
    if name == "" then
        name = "Chat " .. tostring(localIndex)
    end
    local settings = GetMirrorSettings(name)

    mirror.name = name
    mirror.settings = settings
    mirror.sourceTab = tab
    mirror.window = window
    mirror.deferTabHide = startAtTab == true
    mirror.active = true

    local control = mirror.control
    control:ClearAnchors()
    if settings.point then
        control:SetAnchor(settings.point, GuiRoot, settings.relativePoint or settings.point, settings.x or 0, settings.y or 0)
    else
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tab:GetLeft() or 100, (tab:GetTop() or 100) + 8)
    end
    control:SetDimensions(settings.width or DEFAULT_WIDTH, settings.height or DEFAULT_HEIGHT)
    control:SetClampedToScreen(true)

    ZO_TabButton_Text_SetText(mirror.header, name)
    ApplyOptionalBackdrop(mirror.backdrop)
    window:SetParent(control)
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, control, TOPLEFT, 12, 4)
    window:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -28, -12)

    mirrorsByName[name] = mirror
    settings.active = true
    ApplyMirrorLockState(mirror, IsGlobalLayoutLocked())
    SelectAnotherCanonicalTab(mirror)
    ApplyMirrorVisibility(mirror)
    control:SetHidden(false)

    local chatSystem = GetChatSystem()
    if chatSystem and chatSystem:IsMinimized() then
        MinimizeMirror(mirror)
    elseif startAtTab then
        BeginMovingMirror(mirror)
    else
        FadeMirrorOut(mirror)
    end
    return mirror
end

local function CreateMirror(tab, startAtTab)
    local existing = mirrorsByTab[tab]
    if existing then
        if not existing.active then
            return ReactivateMirror(existing, tab, startAtTab)
        elseif startAtTab then
            BeginMovingMirror(existing)
        end
        return existing
    end

    local window, localIndex = FindWindowForTab(tab)
    local container = tab and tab.container
    if not window or not container or not container:IsPrimary() or localIndex <= 1 then
        return nil
    end

    local name = GetTabName(tab)
    if name == "" then
        name = "Chat " .. tostring(localIndex)
    end
    local settings = GetMirrorSettings(name)
    local controlName = "ChatExMirror" .. tostring(nextMirrorControlId)
    nextMirrorControlId = nextMirrorControlId + 1

    local wm = WINDOW_MANAGER
    local control = wm:CreateTopLevelWindow(controlName)
    control:SetDrawTier(DT_MEDIUM)
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(true)
    control:SetResizeHandleSize(RESIZE_HANDLE_SIZE)
    local minWidth, minHeight, maxWidth, maxHeight = GetMirrorDimensionConstraints()
    control:SetDimensionConstraints(minWidth, minHeight, maxWidth, maxHeight)
    control:SetDimensions(settings.width or DEFAULT_WIDTH, settings.height or DEFAULT_HEIGHT)
    control:ClearAnchors()
    if settings.point then
        control:SetAnchor(settings.point, GuiRoot, settings.relativePoint or settings.point, settings.x or 0, settings.y or 0)
    else
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tab:GetLeft() or 100, (tab:GetTop() or 100) + 8)
    end

    local backdrop = wm:CreateControl(controlName .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    ApplyOptionalBackdrop(backdrop)

    local header = CreateControlFromVirtual(controlName .. "Header", control, "ZO_ChatWindowTabTemplate")
    ZO_TabButton_Text_Initialize(header, "SimpleText", name)
    ZO_TabButton_Select(header, "preventcall")
    header:SetMouseEnabled(true)
    header:ClearAnchors()
    header:SetAnchor(BOTTOMLEFT, control, TOPLEFT, 14, 4)

    local mirror =
    {
        name = name,
        settings = settings,
        control = control,
        backdrop = backdrop,
        header = header,
        sourceTab = tab,
        window = window,
        deferTabHide = startAtTab == true,
        active = true,
    }

    header:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            BeginMovingMirror(mirror)
        end
    end)
    header:SetHandler("OnMouseEnter", function()
        FadeMirrorIn(mirror)
        MonitorMirrorMouse(mirror)
    end)
    header:SetHandler("OnMouseUp", function(_, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            StopMovingMirror(mirror)
        elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ShowMirrorContextMenu(mirror)
        end
    end)
    control:SetHandler("OnMouseWheel", function(_, delta)
        local buffer = mirror.window and mirror.window.buffer
        if buffer then
            local current = buffer:GetScrollPosition() or 0
            local maximum = buffer:GetNumHistoryLines() or 0
            buffer:SetScrollPosition(zo_clamp(current + (delta * 3), 0, maximum))
        end
    end)
    control:SetHandler("OnMouseEnter", function()
        FadeMirrorIn(mirror)
        MonitorMirrorMouse(mirror)
    end)
    control:SetHandler("OnResizeStart", function()
        if IsGlobalLayoutLocked() then
            control:StopMovingOrResizing()
            return
        end
        mirror.resizing = true
        FadeMirrorIn(mirror)
    end)
    control:SetHandler("OnResizeStop", function()
        mirror.resizing = false
        SaveMirrorGeometry(mirror)
        MonitorMirrorMouse(mirror)
    end)
    control:SetHandler("OnMoveStop", function() SaveMirrorGeometry(mirror) end)

    window:SetParent(control)
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, control, TOPLEFT, 12, 4)
    window:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -28, -12)

    local buffer = window.buffer
    if buffer and not buffer.chatExMouseEnterInstalled then
        buffer.chatExMouseEnterInstalled = true
        ZO_PreHookHandler(buffer, "OnMouseEnter", function()
            local activeMirror = mirrorsByTab[window.tab]
            if activeMirror and activeMirror.active then
                FadeMirrorIn(activeMirror)
                MonitorMirrorMouse(activeMirror)
            end
        end)
    end

    mirrorsByTab[tab] = mirror
    mirrorsByName[name] = mirror
    settings.active = true
    ApplyMirrorLockState(mirror, IsGlobalLayoutLocked())

    SelectAnotherCanonicalTab(mirror)
    ApplyMirrorVisibility(mirror)
    control:SetHidden(false)

    local chatSystem = GetChatSystem()
    if chatSystem and chatSystem:IsMinimized() then
        MinimizeMirror(mirror)
    elseif startAtTab then
        BeginMovingMirror(mirror)
    else
        FadeMirrorOut(mirror)
    end
    return mirror
end

CloseMirror = function(mirror)
    if not mirror then
        return
    end
    StopMovingMirror(mirror)

    local tab = mirror.sourceTab
    local window = mirror.window
    local container = tab and tab.container
    if window and container and container.windowContainer then
        window:SetParent(container.windowContainer)
        window:ClearAnchors()
        window:SetAnchorFill(container.windowContainer)
    end
    if tab then
        tab:SetMouseEnabled(true)
        tab:SetHidden(false)
    end

    mirror.settings.active = false
    mirror.active = false
    if mirrorsByName[mirror.name] == mirror then
        mirrorsByName[mirror.name] = nil
    end
    mirror.mouseMonitorInstalled = false
    mirror.control:SetHandler("OnUpdate", nil)
    mirror.control:SetHidden(true)

    if container then
        container:PerformLayout()
        if tab then
            container.tabGroup:SetClickedButton(tab)
        end
    end
end

local function FindPrimaryTabByName(name)
    local chatSystem = GetChatSystem()
    local container = chatSystem and chatSystem.primaryContainer
    if not container then
        return nil
    end
    for _, window in ipairs(container.windows or {}) do
        if GetTabName(window.tab) == name then
            return window.tab
        end
    end
end

local function RestoreMirrors()
    if not savedVariables or not savedVariables.mirrors then
        return
    end
    for name, settings in pairs(savedVariables.mirrors) do
        if settings.active then
            local tab = FindPrimaryTabByName(name)
            local _, localIndex = FindWindowForTab(tab)
            if tab and localIndex and localIndex > 1 then
                CreateMirror(tab, false)
            else
                settings.active = false
            end
        end
    end
    RefreshAllMirrorVisibility()
end

local function TryStartMirrorDrag(container, localIndex, tab)
    if not container or not container:IsPrimary() then
        return false
    end

    local window = localIndex and container.windows and container.windows[localIndex]
    if tab then
        window, localIndex = FindWindowForTab(tab)
    elseif window then
        tab = window.tab
    end

    if not window or not tab or not localIndex or localIndex <= 1 then
        return false
    end

    if IsGlobalLayoutLocked() then
        return true
    end

    return CreateMirror(tab, true) ~= nil
end

local function InstallHooks()
    ZO_PreHook("ZO_ChatSystem_OnDragStart", function(tab)
        return TryStartMirrorDrag(tab and tab.container, tab and tab.index, tab)
    end)

    ZO_PreHook(SharedChatContainer, "StartDraggingTab", function(container, localIndex)
        return TryStartMirrorDrag(container, localIndex)
    end)

    ZO_PreHook(SharedChatContainer, "RemoveWindow", function(container, localIndex)
        local window = container.windows and container.windows[localIndex]
        local tab = window and window.tab
        local mirror = tab and mirrorsByTab[tab]
        if mirror then
            if mirror.active then
                CloseMirror(mirror)
            end
            mirrorsByTab[tab] = nil
        end
    end)

    ZO_PreHook("ZO_ChatSystem_OnDragStop", function()
        if activeDragMirror then
            StopMovingMirror(activeDragMirror)
            return true
        end
        return false
    end)

    SecurePostHook(SharedChatContainer, "PerformLayout", RefreshAllMirrorVisibility)
    SecurePostHook(SharedChatContainer, "HandleTabClick", RefreshAllMirrorVisibility)
    SecurePostHook(ZO_ChatSystem, "Minimize", function() SynchronizeMirrorMinimizedState(true) end)
    SecurePostHook(ZO_ChatSystem, "Maximize", function() SynchronizeMirrorMinimizedState(true) end)
    SecurePostHook(ZO_ChatSystem, "ShowMinBar", function() SynchronizeMirrorMinimizedState(true) end)
    SecurePostHook(ZO_ChatSystem, "HideMinBar", function() SynchronizeMirrorMinimizedState(true) end)
    SecurePostHook(SharedChatContainer, "SetLocked", function(container, localIndex, locked)
        if container:IsPrimary() and localIndex == 1 then
            ApplyGlobalLockState(locked)
        end
    end)
    SecurePostHook(SharedChatContainer, "SetBackgroundColor", function(container)
        if container:IsPrimary() then
            for _, mirror in pairs(mirrorsByName) do
                if mirror.fadeAnim then
                    PrepareMirrorFade(mirror)
                end
            end
        end
    end)

    SecurePostHook(SharedChatContainer, "SetTabName", function(container, localIndex)
        local window = container.windows and container.windows[localIndex]
        local mirror = window and mirrorsByTab[window.tab]
        if not mirror then
            return
        end
        local oldName = mirror.name
        local newName = GetTabName(window.tab)
        if newName == "" then
            newName = "Chat " .. tostring(localIndex)
        end
        mirror.name = newName
        ZO_TabButton_Text_SetText(mirror.header, newName)
        if oldName ~= newName then
            if mirror.active then
                if mirrorsByName[oldName] == mirror then
                    mirrorsByName[oldName] = nil
                end
                mirrorsByName[newName] = mirror
            end
            savedVariables.mirrors[newName] = mirror.settings
            savedVariables.mirrors[oldName] = nil
        end
    end)

    if pChat and pChat.ChangeChatWindowDarkness then
        SecurePostHook(pChat, "ChangeChatWindowDarkness", function()
            for _, mirror in pairs(mirrorsByName) do
                ApplyOptionalBackdrop(mirror.backdrop)
            end
        end)
    end
    if rChat and rChat.ChangeChatWindowDarkness then
        SecurePostHook(rChat, "ChangeChatWindowDarkness", function()
            for _, mirror in pairs(mirrorsByName) do
                ApplyOptionalBackdrop(mirror.backdrop)
            end
        end)
    end
end

local function InitializeAfterChatLoad()
    UseCanonicalSingleContainer()
    local chatSystem = GetChatSystem()
    if not chatSystem or not chatSystem.loaded or not chatSystem.primaryContainer then
        zo_callLater(InitializeAfterChatLoad, 100)
        return
    end

    RestoreMirrors()
    ApplyGlobalLockState(IsGlobalLayoutLocked())
    SynchronizeMirrorMinimizedState(true)
    local updateName = ADDON_NAME .. "MinimizedState"
    EVENT_MANAGER:UnregisterForUpdate(updateName)
    EVENT_MANAGER:RegisterForUpdate(updateName, MINIMIZED_STATE_POLL_INTERVAL_MS, function()
        SynchronizeMirrorMinimizedState(false)
    end)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    savedVariables = ZO_SavedVars:NewAccountWide("ChatEx_SavedVariables", SAVED_VARIABLES_VERSION, nil,
    {
        mirrors = {},
    })
    savedVariables.mirrors = savedVariables.mirrors or {}

    UseCanonicalSingleContainer()
    InstallHooks()
end

local function OnPlayerActivated()
    UseCanonicalSingleContainer()
    zo_callLater(InitializeAfterChatLoad, 0)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
