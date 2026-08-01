--- @class GamepadMiniChatTabsTabManager : GamepadMiniChatTabsBaseModule
--- @field tabBarControl userdata? The main tab bar container control
--- @field tabGroup table? ZO_TabButtonGroup for managing tabs
--- @field tabs table<integer, userdata> Array of tab button controls
--- @field activeTabIndex integer Currently active tab index
--- @field controlCounter integer Counter for unique control names
--- @field switchingTabs boolean Flag to prevent recursion during tab switching
--- @field maxVisibleTabs integer Maximum number of tabs to display (default: 3)
local GamepadMiniChatTabsTabManager = GamepadMiniChatTabsBaseModule:Subclass();

--- Creates a new tab manager instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsTabManager
function GamepadMiniChatTabsTabManager:New(manager)
    local obj = GamepadMiniChatTabsBaseModule.New(self, manager);
    return obj;
end;

--- Initializes the tab manager
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsTabManager:Initialize(manager)
    GamepadMiniChatTabsBaseModule.Initialize(self, manager);

    self.tabs = {};
    self.activeTabIndex = 1;
    self.controlCounter = 0;
    self.switchingTabs = false;
    self.maxVisibleTabs = 3;
end;

--- Called when the module should perform its initialization
function GamepadMiniChatTabsTabManager:OnInitialize()
    if not self:IsChatSystemAvailable() then
        return;
    end;

    local chatSystem = self:GetChatSystem();
    chatSystem.platformSettings.hideTabs = true;
    self:CreateTabBar();
    self:HookContainerMethods();
end;

--- Creates the tab bar UI
function GamepadMiniChatTabsTabManager:CreateTabBar()
    local chatSystem = self:GetChatSystem();
    local chatControl = chatSystem.control;

    self.tabBarControl = WINDOW_MANAGER:CreateControl("GamepadMiniChatTabsTabBar", chatControl, CT_CONTROL);
    self.tabBarControl:SetAnchor(BOTTOMLEFT, chatControl, TOPLEFT, 0, -45);
    self.tabBarControl:SetAnchor(BOTTOMRIGHT, chatControl, TOPRIGHT, 0, -45);
    self.tabBarControl:SetHeight(50);

    self.tabGroup = ZO_TabButtonGroup:New();

    self:RebuildTabs();
end;

--- Rebuilds all tabs from container windows
function GamepadMiniChatTabsTabManager:RebuildTabs()
    if not self.tabBarControl or not self:IsChatSystemAvailable() then
        return;
    end;

    for _, tabControl in ipairs(self.tabs) do
        self.tabGroup:Remove(tabControl);
        tabControl:SetHidden(true);
    end;
    ZO_ClearNumericallyIndexedTable(self.tabs);

    local container = self:GetContainer();
    if not container or not container.windows then
        return;
    end;

    local totalTabs = #container.windows;
    local xOffset = 0;
    local visibleCount = 0;

    for i, window in ipairs(container.windows) do
        local tabControl = self:CreateTab(i, window, xOffset);
        if tabControl then
            table.insert(self.tabs, tabControl);

            if not window.originalTab then
                window.originalTab = window.tab;
            end;
            window.tab = tabControl;
            tabControl.window = window;

            local shouldShow = self:ShouldShowTab(i, totalTabs);
            tabControl:SetHidden(not shouldShow);
            if shouldShow then
                visibleCount = visibleCount + 1;
                xOffset = xOffset + tabControl:GetWidth() + 2;
            end;
        end;
    end;

    self:UpdateTabVisibility();

    if #self.tabs > 0 and self.tabs[self.activeTabIndex] then
        local activeTab = self.tabs[self.activeTabIndex];
        activeTab:SetAlpha(1.0);
        self.tabGroup:SetClickedButton(activeTab);
    elseif #self.tabs > 0 then
        self.activeTabIndex = 1;
        local activeTab = self.tabs[1];
        activeTab:SetAlpha(1.0);
        self.tabGroup:SetClickedButton(activeTab);
    end;
end;

--- Determines if a tab should be visible based on overflow rules
--- @param tabIndex integer Tab index to check
--- @param totalTabs integer Total number of tabs
--- @return boolean
function GamepadMiniChatTabsTabManager:ShouldShowTab(tabIndex, totalTabs)
    if totalTabs <= self.maxVisibleTabs then
        return true;
    end;

    local visibleIndices = {};
    visibleIndices[self.activeTabIndex] = true;

    local remaining = self.maxVisibleTabs - 1;
    local offset = 1;
    while remaining > 0 do
        local leftIndex = self.activeTabIndex - offset;
        local rightIndex = self.activeTabIndex + offset;

        if leftIndex >= 1 and remaining > 0 then
            visibleIndices[leftIndex] = true;
            remaining = remaining - 1;
        end;

        if rightIndex <= totalTabs and remaining > 0 then
            visibleIndices[rightIndex] = true;
            remaining = remaining - 1;
        end;

        if leftIndex < 1 and rightIndex > totalTabs then
            break;
        end;

        offset = offset + 1;
    end;

    return visibleIndices[tabIndex] == true;
end;

--- Updates tab visibility and positioning based on active tab
function GamepadMiniChatTabsTabManager:UpdateTabVisibility()
    local container = self:GetContainer();
    if not container or not container.windows then
        return;
    end;

    local totalTabs = #container.windows;
    local xOffset = 0;

    for i, tabControl in ipairs(self.tabs) do
        local shouldShow = self:ShouldShowTab(i, totalTabs);
        tabControl:SetHidden(not shouldShow);

        if shouldShow then
            tabControl:ClearAnchors();
            tabControl:SetAnchor(LEFT, self.tabBarControl, LEFT, xOffset, 0);
            xOffset = xOffset + tabControl:GetWidth() + 2;
        end;
    end;
end;

--- Creates a single tab control
--- @param index integer Tab index
--- @param window table Window data
--- @param xOffset number X position offset
--- @return userdata? tabControl The created tab control or nil
function GamepadMiniChatTabsTabManager:CreateTab(index, window, xOffset)
    if not self.tabBarControl then
        return nil;
    end;

    local container = self:GetContainer();
    if not container then
        return nil;
    end;

    self.controlCounter = self.controlCounter + 1;
    local tabName = "GamepadMiniChatTabsTab" .. self.controlCounter;
    local tabControl = WINDOW_MANAGER:CreateControl(tabName, self.tabBarControl, CT_BUTTON);

    tabControl:SetAnchor(LEFT, self.tabBarControl, LEFT, xOffset, 0);
    tabControl:SetHeight(45);


    local unreadIndicator = WINDOW_MANAGER:CreateControl(tabName .. "Unread", tabControl, CT_TEXTURE);
    unreadIndicator:SetDimensions(32, 32);
    unreadIndicator:SetAnchor(TOPRIGHT, tabControl, TOPRIGHT, -2, 2);
    unreadIndicator:SetTexture("EsoUI/Art/HUD/Gamepad/gp_HUDNotification_notification.dds");
    unreadIndicator:SetHidden(true);

    local label = WINDOW_MANAGER:CreateControl(tabName .. "Text", tabControl, CT_LABEL);
    label:SetAnchor(CENTER);
    label:SetFont("ZoFontGamepad36");

    local tabText = container:GetTabName(index) or ("Tab " .. index);
    label:SetText(tabText);

    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER);
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER);
    label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA());
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE);

    tabControl.index = index;
    tabControl.window = window;
    tabControl.label = label;
    tabControl.unreadIndicator = unreadIndicator;
    tabControl.container = container;
    tabControl.hasUnreadMessages = false;

    tabControl:SetAlpha(0.5);

    local manager = self;
    local function OnTabSelected(tab)
        if not manager.switchingTabs then
            manager.switchingTabs = true;
            manager:SelectTab(tab.index);
            manager.switchingTabs = false;
        end;

        tab:SetAlpha(1.0, 0);

        if tab.unreadIndicator then
            tab.unreadIndicator:SetHidden(true);
            tab.hasUnreadMessages = false;
        end;
    end;

    local function OnTabUnselected(tab)
        tab:SetAlpha(0.5, 200);
    end;

    ZO_TabButton_Text_Initialize(tabControl, "SimpleText", label:GetText(), OnTabSelected, OnTabUnselected);
    self.tabGroup:Add(tabControl);

    tabControl:SetAlpha(0.5);

    label:SetFont("ZoFontGamepad36");
    label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE);
    label:SetWidth(0);

    local textWidth = label:GetTextWidth();
    local tabWidth = textWidth + 80;
    local tabHeight = 50;

    tabControl:SetDimensions(tabWidth, tabHeight);

    tabControl:SetHandler("OnMouseUp", function (control, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            self.tabGroup:SetClickedButton(control);
        end;
    end);

    return tabControl;
end;

--- Selects a tab by index
--- @param index integer Tab index to select
function GamepadMiniChatTabsTabManager:SelectTab(index)
    local container = self:GetContainer();
    if not container or not container.windows or not container.windows[index] then
        return;
    end;

    self.activeTabIndex = index;

    for i, window in ipairs(container.windows) do
        window:SetHidden(i ~= index);
    end;

    local currentWindow = container.windows[index];
    container.currentBuffer = currentWindow and currentWindow.buffer;

    if container.currentBuffer then
        container:UpdateInteractivity(container.currentBuffer:IsMouseEnabled());
    end;

    if currentWindow and currentWindow.markedForNotification then
        currentWindow.markedForNotification = false;
        if currentWindow.tab then
            ZO_TabButton_Text_RestoreDefaultColors(currentWindow.tab);
        end;
    end;

    if self.tabs[index] and not self.switchingTabs then
        self.switchingTabs = true;
        self.tabGroup:SetClickedButton(self.tabs[index]);
        self.switchingTabs = false;
    end;

    self:UpdateTabVisibility();
end;

--- Marks a tab as having unread messages
--- @param tabIndex integer Tab index to mark
function GamepadMiniChatTabsTabManager:MarkTabUnread(tabIndex)
    if not self.tabs or not self.tabs[tabIndex] then
        return;
    end;

    local tab = self.tabs[tabIndex];

    if tabIndex == self.activeTabIndex then
        return;
    end;

    if tab.unreadIndicator and not tab.hasUnreadMessages then
        tab.unreadIndicator:SetHidden(false);
        tab.hasUnreadMessages = true;
    end;
end;

--- Shows the tab bar
function GamepadMiniChatTabsTabManager:Show()
    if self.tabBarControl then
        self.tabBarControl:SetHidden(false);
    end;
end;

--- Hides the tab bar
function GamepadMiniChatTabsTabManager:Hide()
    if self.tabBarControl then
        self.tabBarControl:SetHidden(true);
    end;
end;

--- Hooks container methods to keep tabs synchronized
function GamepadMiniChatTabsTabManager:HookContainerMethods()
    if not self:IsChatSystemAvailable() then
        return;
    end;

    local manager = self;
    local container = manager:GetContainer();

    local originalAddWindow = container.AddWindow;
    function container:AddWindow(...)
        local result = originalAddWindow(self, ...);
        manager:RebuildTabs();

        -- Hook SetLineFade on new window buffer
        local tabIndex = #self.windows;
        if tabIndex > 0 then
            local window = self.windows[tabIndex];
            if window and window.buffer and window.buffer.SetLineFade then
                local originalSetLineFade = window.buffer.SetLineFade;
                function window.buffer:SetLineFade(fadeBegin, fadeDuration)
                    if GAMEPAD_MINI_CHAT_TABS and GAMEPAD_MINI_CHAT_TABS:GetDisableTextFade() then
                        -- Force never fade
                        originalSetLineFade(self, 0, 0);
                    else
                        -- Use original values
                        originalSetLineFade(self, fadeBegin, fadeDuration);
                    end;
                end;
            end;
        end;

        return result;
    end;

    local originalRemoveWindow = container.RemoveWindow;
    function container:RemoveWindow(...)
        local result = originalRemoveWindow(self, ...);
        manager:RebuildTabs();
        return result;
    end;

    local originalSetTabName = container.SetTabName;
    function container:SetTabName(tabIndex, name)
        local result = originalSetTabName(self, tabIndex, name);
        if manager.tabs[tabIndex] then
            local tab = manager.tabs[tabIndex];
            if tab and tab.label then
                tab.label:SetText(name);
                local textWidth = tab.label:GetTextWidth();
                tab:SetWidth(textWidth + 60);
                manager:RebuildTabs();
            end;
        end;
        return result;
    end;

    if container.AddEventMessageToWindow then
        local originalAddEventMessageToWindow = container.AddEventMessageToWindow;
        function container:AddEventMessageToWindow(window, ...)
            for tabIndex, win in ipairs(self.windows) do
                if win == window then
                    if manager and tabIndex ~= manager.activeTabIndex then
                        manager:MarkTabUnread(tabIndex);
                    end;
                    break;
                end;
            end;

            return originalAddEventMessageToWindow(self, window, ...);
        end;
    end;
end;

local tabManager = GamepadMiniChatTabsTabManager:New(GAMEPAD_MINI_CHAT_TABS);
GAMEPAD_MINI_CHAT_TABS:RegisterModule("tabs", tabManager);
