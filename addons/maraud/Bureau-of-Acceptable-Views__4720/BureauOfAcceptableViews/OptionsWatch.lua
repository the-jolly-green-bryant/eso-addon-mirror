-- ===========================================================================
-- OptionsWatch.lua
-- ---------------------------------------------------------------------------
-- One watcher for the ESO settings window, shared by every module that must
-- suspend while the player is editing the real camera settings.
--
-- Two modules independently grew the SAME options-window lifecycle:
-- ContextPresets and ShoulderControl each resolved
-- OPTIONS_WINDOW_FRAGMENT, registered their own StateChange callback, kept their
-- own `optionsOpen` boolean, and wrote near-identical OnOptionsOpened/Closed +
-- Register/UnregisterOptionsEvents. Only the PAYLOAD differed (what each does on
-- open/close). This module owns the fragment subscription and the canonical
-- open/closed state once; callers supply only the payload as callbacks.
--
-- Design rules (mirror the rest of the addon):
--   * ONE fragment callback for the whole addon, registered lazily the first
--     time anyone subscribes and never touched again. Per-subscriber add/remove
--     just edits a table -- no engine (un)registration churn.
--   * Canonical state. IsOpen() is the single source of truth for "the options
--     window is up", replacing three separate per-module flags. A module that
--     enables WHILE the window is already open (its LAM panel lives inside that
--     window) therefore reads the true state immediately, instead of missing the
--     SHOWN event it was not subscribed for.
--   * Payload only. onOpen/onClose describe what a module does when editing
--     starts/ends (revert to snapshot, restore base, push boost 0, ...). The
--     lifecycle -- when they fire -- belongs here.
--   * Lazy/guarded fragment resolution so a client build without the options
--     fragment simply never fires (the feature degrades, it does not error).
-- ===========================================================================

local addon = BureauOfAcceptableViews

addon.OptionsWatch = addon.OptionsWatch or {}
local OptionsWatch = addon.OptionsWatch

-- The options-window fragment (NOT the ESC/system menu), resolved once at load.
-- May be nil on an unexpected client build; every use is guarded.
local OPTIONS_FRAGMENT = OPTIONS_WINDOW_FRAGMENT

-- Canonical open/closed state and the subscriber registry. `subscribers[name]`
-- holds { onOpen = fn, onClose = fn }; `isOpen` mirrors the fragment's shown
-- state and is the value IsOpen() returns. `hooked` gates the one-time fragment
-- registration so we subscribe to the engine callback at most once.
local subscribers = {}
local isOpen      = false
local hooked      = false

-- Fan out an open/close edge to every subscriber. Reads the callback off each
-- entry and calls it if present; a subscriber may supply only one of the two.
local function Dispatch(edge)
    for _, sub in pairs(subscribers) do
        local callback = sub[edge]
        if callback then
            callback()
        end
    end
end

-- The single fragment callback for the whole addon. Translates the fragment's
-- shown/hidden transitions into isOpen edges and fans them out. Guarded against a
-- repeated same-state callback so a subscriber never sees two opens in a row.
local function OnFragmentStateChange(_, newState)
    if newState == SCENE_FRAGMENT_SHOWN then
        if isOpen then return end
        isOpen = true
        Dispatch("onOpen")
    elseif newState == SCENE_FRAGMENT_HIDDEN then
        if not isOpen then return end
        isOpen = false
        Dispatch("onClose")
    end
end

-- Register the addon-wide fragment callback once, on first subscribe. No-op when
-- the fragment is unavailable (older/newer client) or already hooked.
local function EnsureHooked()
    if hooked or not (OPTIONS_FRAGMENT and OPTIONS_FRAGMENT.RegisterCallback) then
        return
    end
    OPTIONS_FRAGMENT:RegisterCallback("StateChange", OnFragmentStateChange)
    hooked = true
end

-- Read the fragment's current state so a module enabled from within LAM does
-- not miss the already-fired SHOWN edge. Returns true only when this refresh
-- discovered a new open edge and dispatched it to all current subscribers.
local function RefreshOpenState()
    if not (OPTIONS_FRAGMENT and OPTIONS_FRAGMENT.GetState) then
        return false
    end

    local openNow = OPTIONS_FRAGMENT:GetState() == SCENE_FRAGMENT_SHOWN
    if openNow == isOpen then
        return false
    end

    isOpen = openNow
    Dispatch(openNow and "onOpen" or "onClose")
    return openNow
end

-- True while the ESO settings window is open. The single suspend-gate every
-- module reads (its Resolve/Reevaluate path) instead of a per-module flag.
function OptionsWatch.IsOpen()
    return isOpen
end

-- Subscribe a module under `name` to options open/close edges.
--   handlers.onOpen  : called when the settings window opens (edit begins)
--   handlers.onClose : called when it closes (edit ends)
-- Either handler may be omitted. Re-subscribing under the same name replaces the
-- handlers (idempotent). Registering the engine callback is deferred to here so
-- an addon that never subscribes never hooks the fragment at all.
--
function OptionsWatch.Subscribe(name, handlers)
    if type(name) ~= "string" or name == "" then
        return
    end
    local wasOpen = isOpen
    subscribers[name] = {
        onOpen  = handlers and handlers.onOpen,
        onClose = handlers and handlers.onClose,
    }
    EnsureHooked()

    -- First subscription may happen from an already-open LAM panel. Refreshing
    -- creates the missing edge; a late subscriber added after that edge receives
    -- its own synthetic onOpen so it immediately hands camera control back.
    local openedNow = RefreshOpenState()
    if isOpen and wasOpen and not openedNow then
        local onOpen = subscribers[name].onOpen
        if onOpen then
            onOpen()
        end
    end
end

-- Unsubscribe a module. Safe when it was never subscribed. The addon-wide
-- fragment callback stays registered (cheap, and usually re-subscribed shortly);
-- only the per-module entry is dropped, so its callbacks stop firing.
function OptionsWatch.Unsubscribe(name)
    subscribers[name] = nil
end