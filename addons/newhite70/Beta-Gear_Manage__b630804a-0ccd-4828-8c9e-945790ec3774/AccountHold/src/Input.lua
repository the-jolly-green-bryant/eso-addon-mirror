-- Quartermaster/src/Input.lua
-- Keystrip descriptor builders for each scene/panel. On console this REPLACES
-- the Bindings.xml role (custom keybinds aren't user-rebindable on console
-- per amendment A2.2). Keystrips piggy-back on default UI_SHORTCUT_* slots
-- which ARE allowed.

AccountHold = AccountHold or {}
AccountHold.Input = AccountHold.Input or {}

local Input = AccountHold.Input
local addon

function Input:Initialize(addonRef)
    addon = addonRef
end

-- ---------------------------------------------------------------------------
-- Bank action panel keystrip — used by ui/BankActionPanel.lua
-- ---------------------------------------------------------------------------

function Input:BuildBankPanelKeystrip(panel)
    return {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,

        {
            name     = function() return GetString(SI_KEYBIND_ACCOUNTHOLD_DEPOSIT) end,
            keybind  = "UI_SHORTCUT_PRIMARY",
            visible  = function() return panel.role == "holder" and #panel.holds > 0 end,
            callback = function() panel:DepositAll() end,
        },
        {
            name     = function() return GetString(SI_KEYBIND_ACCOUNTHOLD_WITHDRAW) end,
            keybind  = "UI_SHORTCUT_PRIMARY",
            visible  = function() return panel.role == "requester" and #panel.holds > 0 end,
            callback = function() panel:WithdrawAll() end,
        },
        {
            name     = function() return GetString(SI_KEYBIND_ACCOUNTHOLD_REVIEW) end,
            keybind  = "UI_SHORTCUT_SECONDARY",
            visible  = function() return #panel.holds > 0 end,
            callback = function() panel:OpenReview() end,
        },
        {
            -- Feature F2: re-run a deposit/withdraw pass that was previously
            -- blocked because a container / the inventory was full.
            name     = function() return GetString(SI_KEYBIND_ACCOUNTHOLD_RETRY) end,
            keybind  = "UI_SHORTCUT_TERTIARY",
            visible  = function() return addon.Mover and addon.Mover:HasPendingRetry() end,
            callback = function() addon.Mover:RetryPending() end,
        },
        {
            name     = function() return GetString(SI_ACCOUNTHOLD_PANEL_CLOSE) end,
            keybind  = "UI_SHORTCUT_NEGATIVE",
            callback = function() panel:Close() end,
        },
    }
end

-- ---------------------------------------------------------------------------
-- Search scene keystrip — used by the legacy standalone scene. The
-- "Account Gear" inventory tab (ui/InventoryTab_*.lua) builds its own
-- keystrip in-place, so this builder is retained ONLY as a compatibility
-- shim for any external consumer of AccountHold.Input. Returns nil rather
-- than asserting so dead callers don't blow up the load.
-- ---------------------------------------------------------------------------

function Input:BuildSearchSceneKeystrip(scene)
    return nil
end

-- ---------------------------------------------------------------------------
-- Helpers used by UI modules to push/pop keystrips on scene state changes
--
-- CRASH SAFETY (console): on Xbox/PS5 there is no Lua-error window, so any
-- unhandled error thrown while the keybind strip is being built, updated,
-- or torn down surfaces as a hard "Error <code>" that breaks the whole
-- game session. Two classes of error caused this in practice:
--   1. A keybind SLOT COLLISION when AddKeybindButtonGroup is asked to bind
--      a UI_SHORTCUT_* slot the current scene already owns — this ASSERTS.
--   2. An error thrown INSIDE one of a button's name/visible/enabled/
--      callback closures, which ZOS invokes from its own update loop
--      (UpdateAllKeybindButtonGroups) — outside any pcall we control.
-- We defend against both: every ZOS keybind-strip call is pcall-wrapped,
-- and each button closure is hardened so a throw degrades gracefully
-- (button hides / does nothing) instead of taking down the game.
-- ---------------------------------------------------------------------------

-- Wrap a closure so it can never propagate an error to ZOS. On failure it
-- logs to the diagnostics ring buffer and returns `default`.
local function safeClosure(fn, default)
    if type(fn) ~= "function" then return fn end
    return function(...)
        local ok, a, b, c = pcall(fn, ...)
        if ok then return a, b, c end
        if addon and addon.Diagnostic then
            addon:Diagnostic("error", "keybind closure error: %s", tostring(a))
        end
        return default
    end
end

-- Track descriptors we've already hardened so push/pop stays reference-stable
-- (we harden IN PLACE — the caller keeps the same table it passed us).
local hardened = setmetatable({}, { __mode = "k" })

function Input:HardenDescriptor(descriptor)
    if type(descriptor) ~= "table" or hardened[descriptor] then return descriptor end
    for _, btn in ipairs(descriptor) do
        if type(btn) == "table" then
            if type(btn.name) == "function" then btn.name = safeClosure(btn.name, "") end
            btn.visible  = safeClosure(btn.visible,  false)
            btn.enabled  = safeClosure(btn.enabled,  true)
            btn.callback = safeClosure(btn.callback, nil)
        end
    end
    hardened[descriptor] = true
    return descriptor
end

-- Returns true when the group was successfully attached, false otherwise
-- (missing API, or a slot collision that we swallowed instead of crashing).
function Input:PushKeybinds(descriptor)
    if type(descriptor) ~= "table" then return false end
    self:HardenDescriptor(descriptor)
    if not (KEYBIND_STRIP and KEYBIND_STRIP.AddKeybindButtonGroup) then return false end
    local ok, err = pcall(KEYBIND_STRIP.AddKeybindButtonGroup, KEYBIND_STRIP, descriptor)
    if not ok then
        if addon and addon.Diagnostic then
            addon:Diagnostic("warn", "PushKeybinds failed (slot in use?): %s", tostring(err))
        end
        return false
    end
    return true
end

function Input:PopKeybinds(descriptor)
    if type(descriptor) ~= "table" then return end
    if not (KEYBIND_STRIP and KEYBIND_STRIP.RemoveKeybindButtonGroup) then return end
    pcall(KEYBIND_STRIP.RemoveKeybindButtonGroup, KEYBIND_STRIP, descriptor)
end

-- Attach a SINGLE button, trying each candidate keybind slot in turn until
-- one binds without colliding with the scene's existing keybinds. Returns
-- the descriptor that was actually registered (pass it back to PopKeybinds),
-- or nil if every candidate slot was already in use. This is how the
-- Character-screen entry point avoids the collision that previously crashed
-- the game on the inventory scene.
function Input:PushSingleButton(button, slots)
    slots = slots or {
        "UI_SHORTCUT_QUATERNARY",
        "UI_SHORTCUT_TERTIARY",
        "UI_SHORTCUT_SECONDARY",
        "UI_SHORTCUT_LEFT_TRIGGER",
        "UI_SHORTCUT_RIGHT_TRIGGER",
    }
    for _, slot in ipairs(slots) do
        local copy = {}
        for k, v in pairs(button) do copy[k] = v end
        copy.keybind = slot
        local descriptor = { alignment = KEYBIND_STRIP_ALIGN_LEFT, copy }
        if self:PushKeybinds(descriptor) then
            return descriptor
        end
    end
    return nil
end

-- Force the keystrip to re-evaluate button labels/visibility. Used when a
-- keybind's displayed name is dynamic (e.g. the gamepad gear scene's
-- category-cycle button shows the current category).
function Input:RefreshKeybinds()
    if KEYBIND_STRIP and KEYBIND_STRIP.UpdateAllKeybindButtonGroups then
        pcall(KEYBIND_STRIP.UpdateAllKeybindButtonGroups, KEYBIND_STRIP)
    end
end
