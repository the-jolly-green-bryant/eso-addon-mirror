-- Quartermaster/src/Platform.lua
-- Thin wrappers around platform-detection APIs and the settings backend.
-- Centralising these makes it cheap to swap LHAS for LAM2 on PC later, and
-- keeps every other module free of `if IsConsoleUI() then` noise.

AccountHold = AccountHold or {}
AccountHold.Platform = AccountHold.Platform or {}

local Platform = AccountHold.Platform

-- ---------------------------------------------------------------------------
-- Platform / input mode
-- ---------------------------------------------------------------------------

function Platform.IsConsole()
    return IsConsoleUI()
end

function Platform.IsGamepad()
    return IsInGamepadPreferredMode()
end

function Platform.IsPC()
    return not IsConsoleUI()
end

-- True when free-text input is reachable for the current player.
-- StartChatInput / chat-bound edit controls are not available on console
-- (they hit private SetSettings paths). Free-text search is therefore PC-only.
function Platform.SupportsFreeTextSearch()
    return not IsConsoleUI()
end

-- True when the addon may register custom Bindings.xml entries that the player
-- can rebind in the in-game Controls menu. Console exposes no rebind UI for
-- addon bindings, so we rely on keystrip descriptors instead.
function Platform.SupportsCustomKeybinds()
    return not IsConsoleUI()
end

-- ---------------------------------------------------------------------------
-- Settings backend (LibHarvensAddonSettings on every platform; LAM2 may slot
-- in later for PC without touching ui/Settings.lua).
-- ---------------------------------------------------------------------------

-- Returns the settings backend module, or nil if no backend is loaded.
-- ui/Settings.lua calls this and degrades gracefully (no panel) if nil.
function Platform.GetSettingsBackend()
    -- LibHarvensAddonSettings is embedded under lib/ and registers itself as
    -- a global on load. Look it up at call time, not require time, so a
    -- missing lib doesn't break addon load.
    if LibHarvensAddonSettings then
        return {
            kind = "LHAS",
            lib  = LibHarvensAddonSettings,
        }
    end

    -- Future PC fallback: LibAddonMenu-2.0
    if LibStub and pcall(function() return LibStub("LibAddonMenu-2.0") end) then
        return {
            kind = "LAM2",
            lib  = LibStub("LibAddonMenu-2.0"),
        }
    end

    return nil
end

-- ---------------------------------------------------------------------------
-- Convenience: scene/screen helpers used by UI modules
-- ---------------------------------------------------------------------------

function Platform.GetCurrentSceneName()
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        return scene and scene:GetName() or nil
    end
    return nil
end
