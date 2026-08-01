--- @class GamepadMiniChatTabsBaseModule : ZO_Object
--- @field protected manager GamepadMiniChatTabs Reference to the main manager
--- @field protected chatSystem table Reference to GAMEPAD_CHAT_SYSTEM
--- @field protected container table Reference to primary chat container
--- @field protected isInitialized boolean Whether module has been initialized
--- @field protected isActive boolean Whether module is currently active
GamepadMiniChatTabsBaseModule = ZO_Object:Subclass();

--- Creates a new module instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsBaseModule
function GamepadMiniChatTabsBaseModule:New(manager)
    local obj = ZO_Object.New(self);
    obj:Initialize(manager);
    return obj;
end;

--- Initializes the base module
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsBaseModule:Initialize(manager)
    self.manager = manager;
    self.isInitialized = false;
    self.isActive = false;
end;

--- Called when the module should perform its initialization
GamepadMiniChatTabsBaseModule:MUST_IMPLEMENT("OnInitialize");

--- Called when the module should become active
--- Optional: Only override if module needs activation logic
function GamepadMiniChatTabsBaseModule:OnActivate()
end;

--- Called when the module should become inactive
--- Optional: Only override if module needs deactivation logic
function GamepadMiniChatTabsBaseModule:OnDeactivate()
end;

--- Called when the module should clean up
--- Optional: Only override if module needs cleanup logic
function GamepadMiniChatTabsBaseModule:OnShutdown()
end;

--- Activates the module if not already active
function GamepadMiniChatTabsBaseModule:Activate()
    if self.isActive then
        return;
    end;

    self.isActive = true;
    self:OnActivate();
end;

--- Deactivates the module if currently active
function GamepadMiniChatTabsBaseModule:Deactivate()
    if not self.isActive then
        return;
    end;

    self.isActive = false;
    self:OnDeactivate();
end;

--- Initializes the module if not already initialized
function GamepadMiniChatTabsBaseModule:InitializeModule()
    if self.isInitialized then
        return;
    end;

    self.isInitialized = true;
    self:OnInitialize();
end;

--- Shuts down the module
function GamepadMiniChatTabsBaseModule:Shutdown()
    self:Deactivate();
    self:OnShutdown();
    self.isInitialized = false;
end;

--- Gets the chat system from the manager
--- @return table?
function GamepadMiniChatTabsBaseModule:GetChatSystem()
    return self.manager:GetChatSystem();
end;

--- Gets the container from the manager
--- @return table?
function GamepadMiniChatTabsBaseModule:GetContainer()
    return self.manager:GetContainer();
end;

--- Checks if the chat system is available
--- @return boolean
function GamepadMiniChatTabsBaseModule:IsChatSystemAvailable()
    local chatSystem = self:GetChatSystem();
    local container = self:GetContainer();
    return chatSystem ~= nil and container ~= nil;
end;

--- Gets the current active tab index
--- @return integer
function GamepadMiniChatTabsBaseModule:GetActiveTabIndex()
    local container = self:GetContainer();
    if not container or not container.windows then
        return 1;
    end;

    for i, window in ipairs(container.windows) do
        if not window:IsHidden() then
            return i;
        end;
    end;

    return 1;
end;

--- Safely gets the number of tabs
--- @return integer
function GamepadMiniChatTabsBaseModule:GetTabCount()
    local container = self:GetContainer();
    if not container or not container.windows then
        return 0;
    end;

    return #container.windows;
end;

GamepadMiniChatTabsBaseModule:IGNORE_UNIMPLEMENTED();

local GAMEPAD_MINI_CHAT_TABS_SV_VERSION = 1;
local GAMEPAD_MINI_CHAT_TABS_SV_NAMESPACE = "Settings";

--- @type table
local GAMEPAD_MINI_CHAT_TABS_DEFAULTS =
{
    disableTextFade = false;
};

--- Main addon manager class
--- @class GamepadMiniChatTabs : ZO_InitializingObject
--- @field name string Addon name
--- @field chatSystem table? Reference to GAMEPAD_CHAT_SYSTEM
--- @field container table? Reference to primary container
--- @field modules table<string, GamepadMiniChatTabsBaseModule> Registered modules
--- @field hooks table<string, function> Original hooked functions
--- @field isInitialized boolean Whether addon is initialized
local GamepadMiniChatTabs = ZO_InitializingObject:Subclass();

--- Creates a new GamepadMiniChatTabs instance
--- @return GamepadMiniChatTabs
function GamepadMiniChatTabs:New()
    local obj = ZO_InitializingObject.New(self);
    return obj;
end;

--- Initializes the addon
function GamepadMiniChatTabs:Initialize()
    self.name = "GamepadMiniChatTabs";
    self.modules = {};
    self.hooks = {};
    self.isInitialized = false;
    self.fadeHooksInstalled = false;
    self.savedVars = nil;

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function (_, addonName)
        self:OnAddOnLoaded(addonName);
    end);
end;

--- Called when an addon is loaded
--- @param addonName string The name of the loaded addon
function GamepadMiniChatTabs:OnAddOnLoaded(addonName)
    if addonName ~= self.name then
        return;
    end;

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED);

    self.savedVars = ZO_SavedVars:NewAccountWide("GamepadMiniChatTabs_SavedVariables", GAMEPAD_MINI_CHAT_TABS_SV_VERSION, GAMEPAD_MINI_CHAT_TABS_SV_NAMESPACE, GAMEPAD_MINI_CHAT_TABS_DEFAULTS);

    if not self:ShouldInitialize() then
        return;
    end;

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function ()
        self:OnPlayerActivated();
    end);
end;

--- Called when the player is activated
function GamepadMiniChatTabs:OnPlayerActivated()
    if self:PerformInitialization() then
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED);
    else
    end;
end;

--- Checks if the addon should initialize
--- @return boolean
function GamepadMiniChatTabs:ShouldInitialize()
    return ZO_ChatSystem_DoesPlatformUseGamepadChatSystem();
end;

--- Performs the main initialization
--- @return boolean success Whether initialization succeeded
function GamepadMiniChatTabs:PerformInitialization()
    if self.isInitialized then
        return true;
    end;

    self.chatSystem = GAMEPAD_CHAT_SYSTEM;
    if not self.chatSystem or not self.chatSystem.primaryContainer then
        return false;
    end;

    self.container = self.chatSystem.primaryContainer;

    self:SetupHooks();
    self:RegisterDialogs();
    self:InitializeModules();

    self:HookFadeOutLines();

    if self.container and self.container.FadeOutLines then
        self.container:FadeOutLines();
    end;

    self.isInitialized = true;
    return true;
end;

--- Registers a module
--- @param name string Module identifier
--- @param module GamepadMiniChatTabsBaseModule The module instance
function GamepadMiniChatTabs:RegisterModule(name, module)
    self.modules[name] = module;
end;

--- Gets a registered module
--- @param name string Module identifier
--- @return GamepadMiniChatTabsBaseModule?
function GamepadMiniChatTabs:GetModule(name)
    return self.modules[name];
end;

--- Initializes all registered modules
function GamepadMiniChatTabs:InitializeModules()
    for name, module in pairs(self.modules) do
        module:InitializeModule();
    end;
end;

--- Activates all modules
function GamepadMiniChatTabs:ActivateModules()
    for name, module in pairs(self.modules) do
        module:Activate();
    end;
end;

--- Deactivates all modules
function GamepadMiniChatTabs:DeactivateModules()
    for name, module in pairs(self.modules) do
        module:Deactivate();
    end;
end;

--- Gets the chat system
--- @return table?
function GamepadMiniChatTabs:GetChatSystem()
    return self.chatSystem;
end;

--- Gets the primary container
--- @return table?
function GamepadMiniChatTabs:GetContainer()
    return self.container;
end;

--- Gets whether text fade is disabled
--- @return boolean
function GamepadMiniChatTabs:GetDisableTextFade()
    if self.savedVars then
        return self.savedVars.disableTextFade == true;
    end;

    return GAMEPAD_MINI_CHAT_TABS_DEFAULTS.disableTextFade;
end;

--- Sets whether text fade is disabled
--- @param disabled boolean
function GamepadMiniChatTabs:SetDisableTextFade(disabled)
    if self.savedVars then
        self.savedVars.disableTextFade = disabled == true;
    end;
end;

--- Sets up all hooks in one centralized location
function GamepadMiniChatTabs:SetupHooks()
    self:HookShowContextMenu();
    self:HookShowOptions();
    self:HookChatLifecycle();
    self:HookChatRouter();
end;

--- Hook the context menu functionality
function GamepadMiniChatTabs:HookShowContextMenu()
    if not GamepadChatContainer then
        return;
    end;

    function GamepadChatContainer:ShowContextMenu(tabIndex)
        local contextMenuManager = GAMEPAD_MINI_CHAT_TABS:GetModule("contextMenu");
        if contextMenuManager and LibRadialMenu then
            tabIndex = tabIndex or (self.currentBuffer and self.currentBuffer:GetParent() and self.currentBuffer:GetParent().tab and self.currentBuffer:GetParent().tab.index);
            local window = self.windows[tabIndex];
            local control = window and window.tab;
            contextMenuManager:ShowRadialMenu(control);
        end;
    end;

    if not ZO_ChatWindow_OpenContextMenu then
        function ZO_ChatWindow_OpenContextMenu(control)
            if control.container then
                control.container:ShowContextMenu(control.index);
            end;
        end;
    end;
end;

--- Hook the options display
function GamepadMiniChatTabs:HookShowOptions()
    if not GamepadChatContainer then
        return;
    end;

    function GamepadChatContainer:ShowOptions(tabIndex)
        self:AddFadeInReference();

        local optionsManager = GAMEPAD_MINI_CHAT_TABS:GetModule("options");
        if optionsManager then
            optionsManager:Show(self, tabIndex);
        end;
    end;
end;

--- Hook chat system lifecycle events
function GamepadMiniChatTabs:HookChatLifecycle()
    if not self.chatSystem then
        return;
    end;

    local originalMaximize = self.chatSystem.Maximize;
    self.hooks.originalMaximize = originalMaximize;
    function self.chatSystem:Maximize()
        originalMaximize(self);
        if GAMEPAD_MINI_CHAT_TABS then
            GAMEPAD_MINI_CHAT_TABS:OnChatMaximized();
        end;
    end;

    local originalMinimize = self.chatSystem.Minimize;
    self.hooks.originalMinimize = originalMinimize;
    function self.chatSystem:Minimize()
        originalMinimize(self);
        if GAMEPAD_MINI_CHAT_TABS then
            GAMEPAD_MINI_CHAT_TABS:OnChatMinimized();
        end;
    end;
end;

--- Hooks CHAT_ROUTER to route messages to tabs based on filters
--- We handle routing ourselves since we're managing the tab system
function GamepadMiniChatTabs:HookChatRouter()
    if not CHAT_ROUTER then
        return;
    end;

    local manager = self;
    local container = manager.container;

    -- Prevent default routing from reaching our container
    if container and container.AddEventMessageToContainer then
        local originalAddEventMessageToContainer = container.AddEventMessageToContainer;
        function container:AddEventMessageToContainer(...)
            -- Skip default routing - we handle it manually
            return;
        end;
    end;

    local function OnFormattedChatMessage(formattedText, eventCategory, targetChannel, fromDisplayName, rawMessageText, narrationMessage, overrideColorDef)
        if not eventCategory then
            return;
        end;

        if not container or not container.windows then
            return;
        end;

        for tabIndex, window in ipairs(container.windows) do
            if IsChatContainerTabCategoryEnabled(container.id, tabIndex, eventCategory) then
                if container.AddEventMessageToWindow then
                    container:AddEventMessageToWindow(window, formattedText, eventCategory, narrationMessage, overrideColorDef);
                end;
            end;
        end;
    end;

    CHAT_ROUTER:RegisterCallback("FormattedChatMessage", OnFormattedChatMessage);
end;

--- Hooks FadeOutLines to respect the disable fade setting
function GamepadMiniChatTabs:HookFadeOutLines()
    if self.fadeHooksInstalled then
        return;
    end;

    if not self.container or not self.container.FadeOutLines then
        return;
    end;

    self.fadeHooksInstalled = true;

    local manager = self;
    local originalFadeOutLines = self.container.FadeOutLines;
    function self.container:FadeOutLines()
        if manager:GetDisableTextFade() then
            -- Disable fade - set to never fade
            local NEVER_FADE = 0;
            for tabIndex = 1, #self.windows do
                if self.windows[tabIndex].buffer then
                    self.windows[tabIndex].buffer:SetLineFade(NEVER_FADE, NEVER_FADE);
                end;
            end;
        else
            -- Use default fade behavior
            originalFadeOutLines(self);
        end;
    end;

    -- Also hook AddEventMessageToWindow to apply fade setting when messages are added
    if self.container.AddEventMessageToWindow then
        local originalAddEventMessageToWindow = self.container.AddEventMessageToWindow;
        function self.container:AddEventMessageToWindow(window, ...)
            local result = originalAddEventMessageToWindow(self, window, ...);

            -- Apply fade setting after message is added
            if manager:GetDisableTextFade() then
                local NEVER_FADE = 0;
                if window and window.buffer then
                    window.buffer:SetLineFade(NEVER_FADE, NEVER_FADE);
                end;
            end;

            return result;
        end;
    end;

    -- Hook SetLineFade directly on buffers to prevent fade when disabled
    for tabIndex = 1, #self.container.windows do
        local window = self.container.windows[tabIndex];
        if window and window.buffer and window.buffer.SetLineFade then
            local originalSetLineFade = window.buffer.SetLineFade;
            function window.buffer:SetLineFade(fadeBegin, fadeDuration)
                if manager:GetDisableTextFade() then
                    -- Force never fade
                    originalSetLineFade(self, 0, 0);
                else
                    -- Use original values
                    originalSetLineFade(self, fadeBegin, fadeDuration);
                end;
            end;
        end;
    end;
end;

--- Called when chat is maximized
function GamepadMiniChatTabs:OnChatMaximized()
    self:ActivateModules();
    local scrollManager = self:GetModule("scrolling");
    if scrollManager then
        scrollManager:OnActivate();
    end;

    -- Apply fade setting when maximized
    if self.container and self.container.FadeOutLines then
        self.container:FadeOutLines();
    end;
end;

--- Called when chat is minimized
function GamepadMiniChatTabs:OnChatMinimized()
    local scrollManager = self:GetModule("scrolling");
    if scrollManager then
        scrollManager:OnActivate();
    end;
    self:ActivateModules();
end;

--- Registers all dialogs
function GamepadMiniChatTabs:RegisterDialogs()
    ESO_Dialogs["GAMEPAD_CHAT_REMOVE_TAB"] =
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC;
        };

        title =
        {
            text = SI_PROMPT_TITLE_REMOVE_TAB;
        };

        mainText =
        {
            text = function (dialog)
                return zo_strformat(SI_CHAT_DIALOG_REMOVE_TAB, dialog.data.tabName);
            end;
        };

        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY";
                text = SI_DIALOG_ACCEPT;
                callback = function (dialog)
                    local container = dialog.data.container;
                    local tabIndex = dialog.data.tabIndex;

                    container:RemoveWindow(tabIndex);
                    container:PerformLayout();

                    local tabManager = GAMEPAD_MINI_CHAT_TABS:GetModule("tabs");
                    if tabManager then
                        tabManager:RebuildTabs();
                    end;

                    -- Call refresh callback if provided
                    if dialog.data.refreshCallback then
                        dialog.data.refreshCallback();
                    end;
                end;
            };
            {
                keybind = "DIALOG_NEGATIVE";
                text = SI_DIALOG_CANCEL;
            };
        };
    };
end;

GAMEPAD_MINI_CHAT_TABS = GamepadMiniChatTabs:New();
