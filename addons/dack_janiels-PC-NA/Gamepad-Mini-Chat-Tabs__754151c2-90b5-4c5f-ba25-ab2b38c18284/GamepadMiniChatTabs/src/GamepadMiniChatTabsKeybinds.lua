--- @class GamepadMiniChatTabsKeybindManager : GamepadMiniChatTabsBaseModule
--- @field keybindStripDescriptor table Keybind strip configuration
local GamepadMiniChatTabsKeybindManager = GamepadMiniChatTabsBaseModule:Subclass();

--- Creates a new keybind manager instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsKeybindManager
function GamepadMiniChatTabsKeybindManager:New(manager)
    local obj = GamepadMiniChatTabsBaseModule.New(self, manager);
    return obj;
end;

--- Initializes the keybind manager
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsKeybindManager:Initialize(manager)
    GamepadMiniChatTabsBaseModule.Initialize(self, manager);
end;

--- Called when the module should perform its initialization
function GamepadMiniChatTabsKeybindManager:OnInitialize()
    self:SetupKeybinds();
end;

--- Sets up keybind descriptors
function GamepadMiniChatTabsKeybindManager:SetupKeybinds()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT;

        {
            name = "Previous Tab";
            keybind = "UI_SHORTCUT_LEFT_STICK_LEFT";
            ethereal = true;
            callback = function ()
                self:SwitchToPreviousTab();
            end;
        };

        {
            name = "Next Tab";
            keybind = "UI_SHORTCUT_LEFT_STICK_RIGHT";
            ethereal = true;
            callback = function ()
                self:SwitchToNextTab();
            end;
        };

        {
            name = "First Tab";
            keybind = "UI_SHORTCUT_LEFT_BUMPER";
            visible = function ()
                return self:GetTabCount() > 1;
            end;
            callback = function ()
                self:SwitchToTab(1);
            end;
        };

        {
            name = "Last Tab";
            keybind = "UI_SHORTCUT_RIGHT_BUMPER";
            visible = function ()
                local tabCount = self:GetTabCount();
                return tabCount > 1;
            end;
            callback = function ()
                local tabCount = self:GetTabCount();
                self:SwitchToTab(tabCount);
            end;
        };

        {
            name = "Tab Menu";
            keybind = "UI_SHORTCUT_SECONDARY";
            callback = function ()
                local contextMenuManager = self.manager:GetModule("contextMenu");
                if contextMenuManager then
                    contextMenuManager:ShowRadialMenu();
                end;
            end;
        };
    };
end;

--- Called when the module should become active
function GamepadMiniChatTabsKeybindManager:OnActivate()
end;

--- Called when the module should become inactive
function GamepadMiniChatTabsKeybindManager:OnDeactivate()
end;

--- Switches to a specific tab index
--- @param tabIndex integer The tab index to switch to
function GamepadMiniChatTabsKeybindManager:SwitchToTab(tabIndex)
    local tabManager = self.manager:GetModule("tabs");
    if not tabManager or not tabManager.tabs then
        return;
    end;

    local numTabs = #tabManager.tabs;
    if tabIndex < 1 or tabIndex > numTabs then
        return;
    end;

    local tab = tabManager.tabs[tabIndex];
    if tab and tabManager.tabGroup then
        tabManager.tabGroup:SetClickedButton(tab);
        PlaySound(SOUNDS.DEFAULT_CLICK);
    end;
end;

--- Switches to the next tab
function GamepadMiniChatTabsKeybindManager:SwitchToNextTab()
    local tabManager = self.manager:GetModule("tabs");
    if not tabManager then
        return;
    end;

    local numTabs = #tabManager.tabs;
    if numTabs <= 1 then
        return;
    end;

    local nextIndex = tabManager.activeTabIndex + 1;
    if nextIndex > numTabs then
        nextIndex = 1;
    end;

    self:SwitchToTab(nextIndex);
end;

--- Switches to the previous tab
function GamepadMiniChatTabsKeybindManager:SwitchToPreviousTab()
    local tabManager = self.manager:GetModule("tabs");
    if not tabManager then
        return;
    end;

    local numTabs = #tabManager.tabs;
    if numTabs <= 1 then
        return;
    end;

    local prevIndex = tabManager.activeTabIndex - 1;
    if prevIndex < 1 then
        prevIndex = numTabs;
    end;

    self:SwitchToTab(prevIndex);
end;

local keybindManager = GamepadMiniChatTabsKeybindManager:New(GAMEPAD_MINI_CHAT_TABS);
GAMEPAD_MINI_CHAT_TABS:RegisterModule("keybinds", keybindManager);
