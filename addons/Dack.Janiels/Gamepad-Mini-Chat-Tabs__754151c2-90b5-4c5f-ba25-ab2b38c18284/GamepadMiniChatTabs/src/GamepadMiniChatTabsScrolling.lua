--- @class GamepadMiniChatTabsScrollManager : GamepadMiniChatTabsBaseModule
--- @field keybindStripDescriptor table Keybind strip configuration
--- @field scrollIndicator userdata? Visual indicator for scroll position
--- @field lastScrollTime number Last time scroll was performed
--- @field scrollRepeatDelay number Delay between scroll repeats in seconds
--- @field fastScrollMultiplier integer Multiplier for fast scrolling
local GamepadMiniChatTabsScrollManager = GamepadMiniChatTabsBaseModule:Subclass();

--- Creates a new scroll manager instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsScrollManager
function GamepadMiniChatTabsScrollManager:New(manager)
    local obj = GamepadMiniChatTabsBaseModule.New(self, manager);
    return obj;
end;

--- Initializes the scroll manager
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsScrollManager:Initialize(manager)
    GamepadMiniChatTabsBaseModule.Initialize(self, manager);

    self.lastScrollTime = 0;
    self.scrollRepeatDelay = 0.1;
    self.fastScrollMultiplier = 5;
end;

--- Called when the module should perform its initialization
function GamepadMiniChatTabsScrollManager:OnInitialize()
    -- Disabled for now
    -- self:RegisterKeybinds()
    -- self:SetupScrollIndicator()
    self:HookMessageAdding()
end;

--- Sets up the scroll position indicator
function GamepadMiniChatTabsScrollManager:SetupScrollIndicator()
    if not self:IsChatSystemAvailable() then
        return;
    end;

    local chatSystem = self:GetChatSystem();
    if not chatSystem then return; end;
    local chatControl = chatSystem.control;
    self.scrollIndicator = WINDOW_MANAGER:CreateControl("GamepadMiniChatTabsScrollIndicator", chatControl, CT_LABEL);
    self.scrollIndicator:SetFont("ZoFontGamepad20");
    self.scrollIndicator:SetText("MORE");
    self.scrollIndicator:SetColor(1, 1, 0, 1);
    self.scrollIndicator:SetAnchor(BOTTOM, chatControl, BOTTOM, 0, -10);
    self.scrollIndicator:SetHidden(true);
end;

--- Updates the scroll indicator visibility
function GamepadMiniChatTabsScrollManager:UpdateScrollIndicator()
    if not self.scrollIndicator or not self:IsChatSystemAvailable() then
        return;
    end;

    local container = self:GetContainer();
    if not container then return; end;

    if container:IsScrolledUp() then
        self.scrollIndicator:SetHidden(false);
    else
        self.scrollIndicator:SetHidden(true);
    end;
end;

--- Registers keybind descriptors and input handlers
function GamepadMiniChatTabsScrollManager:RegisterKeybinds()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT;

        {
            name = "Scroll Up";
            keybind = "UI_SHORTCUT_LEFT_STICK_UP";
            ethereal = true;
            handlesKeyUp = false;
            callback = function ()
                self:ScrollByLines(-1);
            end;
        };

        {
            name = "Scroll Down";
            keybind = "UI_SHORTCUT_LEFT_STICK_DOWN";
            ethereal = true;
            handlesKeyUp = false;
            callback = function ()
                self:ScrollByLines(1);
            end;
        };

        {
            name = "Page Up";
            keybind = "UI_SHORTCUT_LEFT_TRIGGER";
            callback = function ()
                self:ScrollByPage(-1);
            end;
        };

        {
            name = "Page Down";
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER";
            callback = function ()
                self:ScrollByPage(1);
            end;
        };
    };

    self:RegisterInputHandlers();
end;

--- Registers input handlers for scrolling when chat is visible
function GamepadMiniChatTabsScrollManager:RegisterInputHandlers()
    local manager = self;

    local function OnUpdate()
        if not manager:IsChatSystemAvailable() then
            return;
        end;

        local chatSystem = manager:GetChatSystem();
        if not chatSystem or not chatSystem.control or chatSystem.control:IsHidden() then
            return;
        end;

        if not chatSystem.hasFocus then
            return;
        end;

        local container = manager:GetContainer();
        if not container then
            return;
        end;

        local leftStickY = GetGamepadLeftStickY(false);
        local rightTrigger = GetGamepadRightTriggerMagnitude();
        local leftTrigger = GetGamepadLeftTriggerMagnitude();

        if leftStickY > 0.3 then
            manager:ScrollByLines(1);
        elseif leftStickY < -0.3 then
            manager:ScrollByLines(-1);
        elseif rightTrigger > 0.5 then
            manager:ScrollByPage(1);
        elseif leftTrigger > 0.5 then
            manager:ScrollByPage(-1);
        end;
    end;

    EVENT_MANAGER:RegisterForUpdate("GamepadMiniChatTabsScrolling", 0, OnUpdate);
end;

--- Called when the module should become active
function GamepadMiniChatTabsScrollManager:OnActivate()
    -- Disabled for now
    -- self:UpdateScrollIndicator()
end;

--- Called when the module should become inactive
function GamepadMiniChatTabsScrollManager:OnDeactivate()
    -- Disabled for now
    EVENT_MANAGER:UnregisterForUpdate("GamepadMiniChatTabsScrolling");
    if self.scrollIndicator then
        self.scrollIndicator:SetHidden(true);
    end;
end;

--- Scrolls by a number of lines
--- @param direction integer Direction to scroll (-1 for up, 1 for down)
function GamepadMiniChatTabsScrollManager:ScrollByLines(direction)
    local container = self:GetContainer();
    if not container then return; end;

    local currentTime = GetFrameTimeSeconds();
    if currentTime - self.lastScrollTime < self.scrollRepeatDelay then
        return;
    end;
    self.lastScrollTime = currentTime;

    container:ScrollByOffset(direction);
    self:UpdateScrollIndicator();
end;

--- Scrolls by a full page
--- @param direction integer Direction to scroll (-1 for up, 1 for down)
function GamepadMiniChatTabsScrollManager:ScrollByPage(direction)
    local container = self:GetContainer();
    if not container or not container.currentBuffer then
        return;
    end;

    local visibleLines = container.currentBuffer:GetNumVisibleLines() or 10;
    local scrollAmount = direction * visibleLines;

    container:ScrollByOffset(scrollAmount);
    self:UpdateScrollIndicator();
end;

--- Scrolls to the top of the buffer
function GamepadMiniChatTabsScrollManager:ScrollToTop()
    local container = self:GetContainer();
    if not container then return; end;

    container:SetScroll(1);
    self:UpdateScrollIndicator();
end;

--- Scrolls to the bottom of the buffer
function GamepadMiniChatTabsScrollManager:ScrollToBottom()
    local container = self:GetContainer();
    if not container then return; end;

    container:ScrollToBottom();
    self:UpdateScrollIndicator();
end;

--- Hooks message adding to update scroll indicator
function GamepadMiniChatTabsScrollManager:HookMessageAdding()
    local container = self:GetContainer();
    if not container or not container.AddEventMessageToWindow then
        return;
    end;

    local manager = self;
    local originalAddMessage = container.AddEventMessageToWindow;
    function container:AddEventMessageToWindow(...)
        local result = originalAddMessage(self, ...);
        manager:UpdateScrollIndicator();
        return result;
    end;
end;

local scrollManager = GamepadMiniChatTabsScrollManager:New(GAMEPAD_MINI_CHAT_TABS);
GAMEPAD_MINI_CHAT_TABS:RegisterModule("scrolling", scrollManager);
