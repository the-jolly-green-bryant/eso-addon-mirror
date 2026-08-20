-- Native gamepad chat adapter. Preview pins the real ZO_GamepadTextChat
-- window open while /uiedit is active. Do not write dummy lines into the
-- player's chat history — Maximize + StartVisibilityTimer is enough to
-- show the chrome and any existing messages.

ValknarrUIEGamepadChat = ValknarrUIEGamepadChat or {}

local Chat = ValknarrUIEGamepadChat
local Log = ValknarrUIELog
local Platform = ValknarrUIEPlatform
local Adapter = ValknarrUIEPlayerAttributes
local Safe = ValknarrUIESafe

local KEEP_ALIVE_MS = 1500
local KEEP_ALIVE_NAME = "ValknarrUIEChatPin"
local MIN_PIXEL_W = 200
local MIN_PIXEL_H = 120

local function PlatformUsesGamepadChat()
    if type(IsChatSystemAvailableForCurrentPlatform) == "function" then
        local ok, available = pcall(IsChatSystemAvailableForCurrentPlatform)
        if ok and available == false then
            return false
        end
    end
    if type(ZO_ChatSystem_DoesPlatformUseGamepadChatSystem) == "function" then
        local ok, uses = pcall(ZO_ChatSystem_DoesPlatformUseGamepadChatSystem)
        if ok and uses == false then
            return false
        end
    end
    if type(ZO_ChatSystem_ShouldUseKeyboardChatSystem) == "function" then
        local ok, keyboard = pcall(ZO_ChatSystem_ShouldUseKeyboardChatSystem)
        if ok and keyboard == true then
            return false
        end
    end
    return true
end

local function System()
    return _G.GAMEPAD_CHAT_SYSTEM
end

function Chat:Find()
    if not PlatformUsesGamepadChat() then
        if Log then
            Log:Debug("Gamepad chat not used on this platform")
        end
        return nil, "keyboard-or-unavailable"
    end

    local system = System()
    if system and system.primaryContainer then
        local control = system.primaryContainer.control
        if control and type(control.SetAnchor) == "function" then
            if Log then
                Log:Debug("Locate chat via GAMEPAD_CHAT_SYSTEM.primaryContainer.control")
            end
            return control, "GAMEPAD_CHAT_SYSTEM.primaryContainer.control"
        end
    end

    if system and system.control and type(system.control.SetAnchor) == "function" then
        if Log then
            Log:Debug("Locate chat via GAMEPAD_CHAT_SYSTEM.control")
        end
        return system.control, "GAMEPAD_CHAT_SYSTEM.control"
    end

    local named = _G.ZO_GamepadTextChat
    if named and type(named.SetAnchor) == "function" then
        if Log then
            Log:Debug("Locate chat via ZO_GamepadTextChat")
        end
        return named, "ZO_GamepadTextChat"
    end

    if Log then
        Log:Warn("Locate failed for chat")
    end
    return nil, "missing"
end

function Chat:Describe()
    local system = System()
    local control, source = self:Find()
    local hudEnabled = nil
    local minimized = nil
    local loaded = nil
    if system then
        if type(system.IsHUDEnabled) == "function" then
            local ok, value = pcall(system.IsHUDEnabled, system)
            if ok then
                hudEnabled = value
            end
        else
            hudEnabled = system.hudEnabled
        end
        if type(system.IsMinimized) == "function" then
            local ok, value = pcall(system.IsMinimized, system)
            if ok then
                minimized = value
            end
        else
            minimized = system.isMinimized
        end
        loaded = system.loaded
    end
    return {
        platformUsesGamepadChat = PlatformUsesGamepadChat(),
        gamepadChatSystem = system ~= nil,
        zoGamepadTextChat = _G.ZO_GamepadTextChat ~= nil,
        hudEnabled = hudEnabled,
        minimized = minimized,
        loaded = loaded,
        source = source or "missing",
        hasControl = control ~= nil,
    }
end

local function Unhide(control)
    if control and type(control.SetHidden) == "function" then
        pcall(control.SetHidden, control, false)
    end
end

function Chat:ShowChrome()
    local system = System()
    if not system then
        return
    end
    Unhide(system.control)
    if system.primaryContainer then
        Unhide(system.primaryContainer.control)
        Unhide(system.primaryContainer.windowContainer)
    end
    local bg = nil
    if system.control and type(system.control.GetNamedChild) == "function" then
        local ok, child = pcall(system.control.GetNamedChild, system.control, "Bg")
        if ok then
            bg = child
        end
    end
    Unhide(bg)
end

function Chat:KeepAlive()
    if not self.pinned then
        return
    end
    local system = System()
    if not system then
        return
    end
    -- Maximize() no-ops when already open, so the 20s fade timer would still
    -- fire. Refresh the timer every tick and only Maximize if minimized.
    Safe.Try(system, "StartVisibilityTimer")
    local minimized = system.isMinimized
    if type(system.IsMinimized) == "function" then
        local ok, value = pcall(system.IsMinimized, system)
        if ok then
            minimized = value
        end
    end
    if minimized then
        Safe.Try(system, "Maximize")
    end
    self:ShowChrome()
end

function Chat:StartKeepAlive()
    if self.keepAlive or not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    local ok, err = pcall(
        EVENT_MANAGER.RegisterForUpdate,
        EVENT_MANAGER,
        KEEP_ALIVE_NAME,
        KEEP_ALIVE_MS,
        function()
            Chat:KeepAlive()
        end
    )
    if ok then
        self.keepAlive = true
        if Log then
            Log:Debug("Chat keep-alive started")
        end
    elseif Log then
        Log:Warn("Chat keep-alive failed: " .. tostring(err))
    end
end

function Chat:StopKeepAlive()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, KEEP_ALIVE_NAME)
    end
    self.keepAlive = false
end

function Chat:PinOpen()
    if self.pinned then
        self:KeepAlive()
        return true
    end
    local system = System()
    if not system then
        if Log then
            Log:Warn("PinOpen skipped: GAMEPAD_CHAT_SYSTEM missing")
        end
        return false
    end

    self.savedHudEnabled = nil
    if type(system.IsHUDEnabled) == "function" then
        local ok, value = pcall(system.IsHUDEnabled, system)
        if ok then
            self.savedHudEnabled = value
        end
    elseif system.hudEnabled ~= nil then
        self.savedHudEnabled = system.hudEnabled and true or false
    end
    if type(system.IsMinimized) == "function" then
        local ok, value = pcall(system.IsMinimized, system)
        if ok then
            self.savedMinimized = value
        end
    else
        self.savedMinimized = system.isMinimized and true or false
    end

    -- In-memory only. Do not SetSetting / StartTextEntry — those would
    -- permanently flip the player's HUD-chat preference and steal input.
    Safe.Try(system, "SetHUDEnabled", true)
    Safe.Try(system, "RefreshVisibility")
    Safe.Try(system, "Maximize")
    self:ShowChrome()
    self.pinned = true
    self:HookResets()
    self:StartKeepAlive()
    self:KeepAlive()
    if Log then
        Log:Info("Chat preview pinned (native window, no dummy messages)")
    end
    return true
end

function Chat:Unpin()
    self:StopKeepAlive()
    if not self.pinned then
        return
    end
    self.pinned = false
    local system = System()
    if not system then
        return
    end
    if self.savedHudEnabled ~= nil then
        Safe.Try(system, "SetHUDEnabled", self.savedHudEnabled and true or false)
        Safe.Try(system, "RefreshVisibility")
    end
    if self.savedMinimized then
        Safe.Try(system, "Minimize")
    end
    if Log then
        Log:Info("Chat preview unpinned; HUD/minimized state restored")
    end
    self.savedHudEnabled = nil
    self.savedMinimized = nil
end

function Chat:OnNativeReset(reason)
    if self.reapplying then
        return
    end
    local callback = self.onReset
    if type(callback) ~= "function" then
        return
    end
    -- Apply in the same stack as LoadSettings / ResetContainerPositionAndSize.
    -- Those native methods run from events; delaying with zo_callLater can
    -- drop the protected-attribute context and leave chat on XML defaults.
    self.reapplying = true
    pcall(callback, reason or "chat-reset")
    self.reapplying = false
    if self.pinned then
        self:KeepAlive()
    end
end

function Chat:HookMinimize()
    local system = System()
    if not system or type(system.Minimize) ~= "function" or system.ValknarrUIEMinHooked then
        return
    end
    local original = system.Minimize
    system.Minimize = function(this, ...)
        -- Native chat fades after ~20s. That hide also pops our editor
        -- scene (grid/keybinds gone, sticks still moving, face buttons cast).
        if Chat.pinned then
            Chat:KeepAlive()
            return
        end
        return original(this, ...)
    end
    system.ValknarrUIEMinHooked = true
    if Log then
        Log:Debug("Hooked GAMEPAD_CHAT_SYSTEM:Minimize so the 20s fade cannot kill the editor")
    end
end

function Chat:HookResets()
    self:HookMinimize()
    if self.hooked then
        return
    end
    local system = System()
    if not system then
        return
    end

    local container = system.primaryContainer
    if container and type(container.LoadSettings) == "function" and not container.ValknarrUIEHooked then
        local original = container.LoadSettings
        container.LoadSettings = function(this, ...)
            original(this, ...)
            Chat:OnNativeReset("LoadSettings")
        end
        container.ValknarrUIEHooked = true
        self.hooked = true
        if Log then
            Log:Debug("Hooked GamepadChatContainer:LoadSettings")
        end
    end

    if type(system.ResetContainerPositionAndSize) == "function" and not system.ValknarrUIEHooked then
        local original = system.ResetContainerPositionAndSize
        system.ResetContainerPositionAndSize = function(this, ...)
            original(this, ...)
            Chat:OnNativeReset("ResetContainerPositionAndSize")
        end
        system.ValknarrUIEHooked = true
        self.hooked = true
        if Log then
            Log:Debug("Hooked GAMEPAD_CHAT_SYSTEM:ResetContainerPositionAndSize")
        end
    end
end

function Chat:Apply(control, position)
    if type(position) ~= "table" then
        return false
    end
    local target = control
    if not target then
        target = self:Find()
    end
    if not target then
        return false
    end
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(target)
    end

    local width, height = Adapter:GetScreenSize()
    if position.w and position.h and width and height then
        pcall(function()
            if type(target.SetDimensionConstraints) == "function" then
                target:SetDimensionConstraints(MIN_PIXEL_W, MIN_PIXEL_H, width, height)
            end
        end)
    end

    return Adapter:Apply(target, position.x, position.y, position.w, position.h)
end

function Chat:Initialize()
    self:HookResets()
end

return Chat
