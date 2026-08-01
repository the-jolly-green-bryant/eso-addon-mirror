--- @class GamepadMiniChatTabsContextMenuManager : GamepadMiniChatTabsBaseModule
--- @field addonId string LibRadialMenu addon identifier
--- @field addonName string LibRadialMenu addon display name
local GamepadMiniChatTabsContextMenuManager = GamepadMiniChatTabsBaseModule:Subclass();

--- Creates a new context menu manager instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsContextMenuManager
function GamepadMiniChatTabsContextMenuManager:New(manager)
    local obj = GamepadMiniChatTabsBaseModule.New(self, manager);
    return obj;
end;

--- Initializes the context menu manager
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsContextMenuManager:Initialize(manager)
    GamepadMiniChatTabsBaseModule.Initialize(self, manager);
    self.addonId = "GamepadMiniChatTabs";
    self.addonName = "Gamepad Mini Chat Tabs";
end;

--- Called when the module should perform its initialization
function GamepadMiniChatTabsContextMenuManager:OnInitialize()
    if not LibRadialMenu then
        return;
    end;

    if not self:IsChatSystemAvailable() then
        return;
    end;

    LibRadialMenu:RegisterAddon(self.addonId, self.addonName);
    self:RegisterAllEntries();
end;

--- Registers all menu entries once at initialization
function GamepadMiniChatTabsContextMenuManager:RegisterAllEntries()
    if not LibRadialMenu then
        return;
    end;

    local manager = self.manager;

    LibRadialMenu:RegisterEntry(self.addonId, "Next Tab", "next_tab", "/esoui/art/miscellaneous/gamepad/spinner_arrow_right_up.dds", function ()
                                    local keybindManager = manager:GetModule("keybinds");
                                    if keybindManager then
                                        keybindManager:SwitchToNextTab();
                                    end;
                                end, "Switch to the next chat tab");

    LibRadialMenu:RegisterEntry(self.addonId, "Previous Tab", "previous_tab", "/esoui/art/miscellaneous/gamepad/spinner_arrow_left_up.dds", function ()
                                    local keybindManager = manager:GetModule("keybinds");
                                    if keybindManager then
                                        keybindManager:SwitchToPreviousTab();
                                    end;
                                end, "Switch to the previous chat tab");

    for tabIndex = 1, 10 do
        local entryId = "switch_to_tab_" .. tabIndex;
        local entryName = "Switch to Tab " .. tabIndex;
        LibRadialMenu:RegisterEntry(self.addonId, entryName, entryId, "/esoui/art/miscellaneous/gamepad/gp_icon_new.dds", function ()
                                        local container = manager:GetContainer();
                                        if not container or not container.windows or tabIndex > #container.windows then
                                            return;
                                        end;

                                        local tabManager = manager:GetModule("tabs");
                                        if tabManager and tabManager.activeTabIndex ~= tabIndex then
                                            tabManager:SelectTab(tabIndex);
                                        end;
                                    end, "Switch to chat tab " .. tabIndex);
    end;

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_CREATE_NEW), "create_new", "/esoui/art/miscellaneous/gamepad/spinnerplus_up.dds", function ()
                                    local container = manager:GetContainer();
                                    local chatSystem = manager:GetChatSystem();
                                    if container and chatSystem then
                                        chatSystem:CreateNewChatTab(container);
                                        local tabManager = manager:GetModule("tabs");
                                        if tabManager then
                                            tabManager:RebuildTabs();
                                        end;
                                    end;
                                end, "Create a new chat tab");

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_OPTIONS), "options", "/esoui/art/miscellaneous/gamepad/gp_icon_search_64.dds", function ()
                                    local container = manager:GetContainer();
                                    if container then
                                        local tabManager = manager:GetModule("tabs");
                                        local tabIndex = tabManager and tabManager.activeTabIndex or 1;
                                        container:ShowOptions(tabIndex);
                                    end;
                                end, "Configure tab options");

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_REMOVE), "remove_tab", "/esoui/art/miscellaneous/gamepad/spinnerminus_up.dds", function ()
                                    local container = manager:GetContainer();
                                    if not container then
                                        return;
                                    end;

                                    local tabManager = manager:GetModule("tabs");
                                    local tabIndex = tabManager and tabManager.activeTabIndex or 1;

                                    if container:IsPrimary() and tabIndex == 1 then
                                        return;
                                    end;

                                    local tabName = container:GetTabName(tabIndex);
                                    ZO_Dialogs_ShowGamepadDialog("GAMEPAD_CHAT_REMOVE_TAB",
                                                                 {
                                                                     container = container;
                                                                     tabIndex = tabIndex;
                                                                     tabName = tabName
                                                                 });
                                end, "Remove the current chat tab");

    LibRadialMenu:RegisterEntry(self.addonId, "Move Tab Left", "move_left", "/esoui/art/miscellaneous/gamepad/spinner_arrow_left_up.dds", function ()
                                    local container = manager:GetContainer();
                                    if not container then
                                        return;
                                    end;

                                    local tabManager = manager:GetModule("tabs");
                                    local tabIndex = tabManager and tabManager.activeTabIndex or 1;

                                    if tabIndex <= 1 then
                                        return;
                                    end;

                                    local newIndex = tabIndex - 1;
                                    TransferChatContainerTab(container.id, tabIndex, container.id, newIndex);

                                    local movedWindow = table.remove(container.windows, tabIndex);
                                    table.insert(container.windows, newIndex, movedWindow);

                                    container:UpdateTabIndices(math.min(tabIndex, newIndex));
                                    container:PerformLayout();

                                    if tabManager then
                                        tabManager:RebuildTabs();
                                        tabManager:SelectTab(newIndex);
                                    end;
                                end, "Move tab to the left");

    LibRadialMenu:RegisterEntry(self.addonId, "Move Tab Right", "move_right", "/esoui/art/miscellaneous/gamepad/spinner_arrow_right_up.dds", function ()
                                    local container = manager:GetContainer();
                                    if not container then
                                        return;
                                    end;

                                    local tabManager = manager:GetModule("tabs");
                                    local tabIndex = tabManager and tabManager.activeTabIndex or 1;

                                    if tabIndex >= #container.windows then
                                        return;
                                    end;

                                    local newIndex = tabIndex + 1;
                                    TransferChatContainerTab(container.id, tabIndex, container.id, newIndex);

                                    local movedWindow = table.remove(container.windows, tabIndex);
                                    table.insert(container.windows, newIndex, movedWindow);

                                    container:UpdateTabIndices(math.min(tabIndex, newIndex));
                                    container:PerformLayout();

                                    if tabManager then
                                        tabManager:RebuildTabs();
                                        tabManager:SelectTab(newIndex);
                                    end;
                                end, "Move tab to the right");

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_LOCK), "lock", "/esoui/art/miscellaneous/gamepad/gp_icon_locked32.dds", function ()
                                    local container = manager:GetContainer();
                                    if not container then
                                        return;
                                    end;

                                    local tabManager = manager:GetModule("tabs");
                                    local tabIndex = tabManager and tabManager.activeTabIndex or 1;

                                    if container:IsPrimary() and tabIndex == 1 then
                                        container:SetLocked(tabIndex, true);
                                    end;
                                end, "Lock the primary chat tab");

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_UNLOCK), "unlock", "/esoui/art/miscellaneous/gamepad/gp_icon_unlocked32.dds", function ()
                                    local container = manager:GetContainer();
                                    if not container then
                                        return;
                                    end;

                                    local tabManager = manager:GetModule("tabs");
                                    local tabIndex = tabManager and tabManager.activeTabIndex or 1;

                                    if container:IsPrimary() and tabIndex == 1 then
                                        container:SetLocked(tabIndex, false);
                                    end;
                                end, "Unlock the primary chat tab");

    LibRadialMenu:RegisterEntry(self.addonId, GetString(SI_CHAT_CONFIG_RESET), "reset", "/esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds", function ()
                                    ResetChatToDefaults();
                                    ReloadUI("ingame");
                                end, "Reset chat to default settings");
end;

--- Shows the radial menu for the current active tab
--- @param control userdata? The control to anchor the menu to
function GamepadMiniChatTabsContextMenuManager:ShowRadialMenu(control)
    if not LibRadialMenu then
        return;
    end;

    local container = self:GetContainer();
    if not container then
        return;
    end;

    local tabManager = self.manager:GetModule("tabs");
    if not tabManager or not tabManager.tabs then
        return;
    end;

    local activeTab = tabManager.tabs[tabManager.activeTabIndex];
    if not activeTab then
        return;
    end;

    local anchorControl = control or activeTab;
    LibRadialMenu:Show(self.addonId, anchorControl);
end;

local contextMenuManager = GamepadMiniChatTabsContextMenuManager:New(GAMEPAD_MINI_CHAT_TABS);
GAMEPAD_MINI_CHAT_TABS:RegisterModule("contextMenu", contextMenuManager);
