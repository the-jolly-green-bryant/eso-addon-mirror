-- AccountHold/ui/CollectionsClearAll_Gamepad.lua
--
-- Epic 0008 (QoL). A HOLD-to-activate keybind on the gamepad Collections book
-- that clears every "new" notification the add-on can reach: inventory, craft
-- bag, bank, collectibles and item sets.
--
-- The counting and clearing all live in src/Notifications.lua. This file is
-- only the surface: a keybind, a label, and a hold timer.
--
-- ---------------------------------------------------------------------------
-- WHY THIS IS NOT THE Y BUTTON
-- ---------------------------------------------------------------------------
-- The feature was specified as "Hold Y". Y (UI_SHORTCUT_TERTIARY) is NOT
-- available on this screen. ZO_GamepadCollectionsBook builds four keybind
-- groups (collectionsbook_gamepad.lua:399) and swaps between them as the player
-- navigates, and TERTIARY is registered in three of them:
--     :477  subcategory list   (conditional on the outfit-styles category)
--     :545  outfit-styles grid (NO visible guard -- always registered)
--     :708  collection list    (conditional)
-- A conditional `visible` hides a button but does NOT stop the descriptor being
-- registered, so it is still a collision.
--
-- Colliding is not a soft failure. AddKeybindButton on a slot the scene already
-- owns reaches HandleDuplicateAddKeybind and calls RemoveKeybindButton on the
-- EXISTING descriptor (zo_keybindstrip.lua:342-343) -- which can rip out the
-- player's Back button and strand them on a console with no pointer. This
-- add-on has already ended a session that way once (README.md, "Xbox / PS5
-- quick reference").
--
-- So the slot is NEGOTIATED, not asserted: TryBind walks a candidate list and
-- keeps the first slot that binds cleanly, exactly as Input:PushSingleButton
-- does for the Character-screen entry point. QUINARY is first because it is the
-- only slot that appears nowhere in collectionsbook_gamepad.lua. TERTIARY is
-- deliberately ABSENT from the candidate list.
--
-- See docs/research/API_REFERENCE.md, "Gamepad collections book", for the full
-- slot inventory with line numbers.
--
-- ---------------------------------------------------------------------------
-- HOW THE HOLD WORKS
-- ---------------------------------------------------------------------------
-- There is no `holdDuration` field on a keybind descriptor -- that name does not
-- exist anywhere in esoui. The base game implements holds with
-- `handlesKeyUp = true` plus its own timer; the callback receives ONE boolean,
-- false on press and true on release. Modelled on the Tamriel Tomes battle-pass
-- claim (tamrieltomesscreen_gamepad.lua + tamrieltomesrewardtile_shared.lua),
-- which fires at 0.65s and guards with a `claimRewardRequested` flag so a hold
-- cannot double-submit. We use the same threshold and the same latch.
--
-- Because clearing is IRREVERSIBLE and account-wide, the hold IS the confirm
-- step -- a mis-press does nothing, which is the whole reason it is a hold and
-- not a press.
--
-- ESO runs Lua 5.1: no goto, no bitwise operators. This file must LOAD under
-- tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.CollectionsClearAllGamepad = AccountHold.UI.CollectionsClearAllGamepad or {}

local Clear = AccountHold.UI.CollectionsClearAllGamepad

-- collectionsbook_gamepad.lua:17
local SCENE_NAME  = "gamepadCollectionsBook"
local SCENE_GLOBAL = "GAMEPAD_COLLECTIONS_BOOK_SCENE"

-- tamrieltomesrewardtile_shared.lua: CLAIM_REWARD_COMPLETE_SECONDS = 0.65
local HOLD_MS = 650

-- Ordered candidates.
--
-- CONFIRMED ON XBOX HARDWARE (2026-07-28): the abstract slots map to
--     PRIMARY = A, SECONDARY = X, TERTIARY = Y,
--     QUATERNARY = HOLD X, QUINARY = HOLD Y
-- This mapping appears in NO esoui file -- the default gamepad bindings live in
-- the engine binary -- so it cost a hardware round-trip. See
-- docs/research/API_REFERENCE.md, "Xbox gamepad button mapping".
--
-- Two things follow. First, QUINARY IS "Hold Y", so this feature landed exactly
-- where it was originally specified, by a different route than expected: the
-- literal "Hold Y" is QUINARY, not TERTIARY plus a timer. Second, both QUINARY
-- and QUATERNARY are ENGINE-LEVEL HOLD slots, so either is an appropriate home
-- for a destructive bulk action and neither can be triggered by a stray tap.
--
-- The candidate list is therefore hold-capable slots ONLY. An earlier revision
-- listed UI_SHORTCUT_RIGHT_STICK as a fallback, which was wrong: a stick CLICK
-- is not a hold, so falling back to it would have produced a row labelled
-- "Hold:" that fires instantly on a single click -- on an irreversible,
-- account-wide action.
--
-- TERTIARY (plain Y) is absent for a different reason: it is already claimed in
-- three of the collections book's four keybind groups.
local SLOTS = {
    "UI_SHORTCUT_QUINARY",     -- Hold Y  (verified: this is the one that binds here)
    "UI_SHORTCUT_QUATERNARY",  -- Hold X  (fallback; claimed on the collection list)
}

Clear._SCENE_NAME = SCENE_NAME
Clear._HOLD_MS    = HOLD_MS
Clear._SLOTS      = SLOTS

-- ---------------------------------------------------------------------------
-- Foundation layer
-- ---------------------------------------------------------------------------

local function safe()
    local core = AccountHold and AccountHold.Core
    local S = core and core.Safe
    if type(S) == "table" then return S end
    return nil
end

local function text(id, fallback, ...)
    local core = AccountHold and AccountHold.Core
    local T = core and core.Text
    if type(T) == "table" and type(T.Format) == "function" then
        return T.Format(id, fallback, ...)
    end
    return fallback
end

local log
local function logger()
    if log then return log end
    local core = AccountHold and AccountHold.Core
    local L = core and core.Log
    if type(L) == "table" and type(L.For) == "function" then
        log = L.For("qol/clearall")
    else
        log = { Warn = function() end, Info = function() end, Error = function() end }
    end
    return log
end

local function method(obj, name)
    local S = safe()
    if S ~= nil then return S.Method(obj, name) end
    if obj == nil then return nil end
    local ok, fn = pcall(function() return obj[name] end)
    if ok and type(fn) == "function" then return fn end
    return nil
end

local function globalObj(name)
    local S = safe()
    if S ~= nil then return S.Obj(name) end
    local ok, v = pcall(function() return _G[name] end)
    if ok then return v end
    return nil
end

-- ---------------------------------------------------------------------------
-- Gating
--
-- Evaluated at VISIBILITY time, never cached, so toggling the feature takes
-- effect without a reload -- the contract every epic-0008 action follows.
-- ---------------------------------------------------------------------------

function Clear.IsEnabled()
    local F = AccountHold and AccountHold.Features
    if type(F) ~= "table" or type(F.IsEnabled) ~= "function" then return false end
    local ok, res = pcall(F.IsEnabled, F, "qol")
    return (ok and res) and true or false
end

local function model()
    local N = AccountHold and AccountHold.Notifications
    if type(N) == "table" then return N end
    return nil
end

-- ---------------------------------------------------------------------------
-- Clock. GetGameTimeMilliseconds is the real API; GetFrameTimeMilliseconds is
-- the fallback (and is what the harness provides). Resolved per call so a test
-- can advance either.
-- ---------------------------------------------------------------------------

function Clear.Now()
    local S = safe()
    for _, name in ipairs({ "GetGameTimeMilliseconds", "GetFrameTimeMilliseconds" }) do
        local fn = S and S.Fn(name) or nil
        if fn == nil then
            local ok, v = pcall(function() return _G[name] end)
            fn = (ok and type(v) == "function") and v or nil
        end
        if fn ~= nil then
            local ok, ms = pcall(fn)
            if ok and type(ms) == "number" then return ms end
        end
    end
    return 0
end

-- ---------------------------------------------------------------------------
-- Hold state machine
-- ---------------------------------------------------------------------------

Clear._holdStart = nil
Clear._fired     = false

function Clear.IsHolding()
    return Clear._holdStart ~= nil
end

-- 0..1 progress through the hold. Drives the label.
function Clear.HoldProgress()
    if Clear._holdStart == nil then return 0 end
    local elapsed = Clear.Now() - Clear._holdStart
    if elapsed <= 0 then return 0 end
    if elapsed >= HOLD_MS then return 1 end
    return elapsed / HOLD_MS
end

function Clear.BeginHold()
    if Clear._holdStart ~= nil then return end   -- already holding; ignore repeats
    Clear._holdStart = Clear.Now()
    Clear._fired     = false
end

-- Called on release AND polled while held. Fires exactly once, when the
-- threshold is reached. Returns cleared-count when it fired, nil otherwise.
function Clear.TickHold()
    if Clear._holdStart == nil or Clear._fired then return nil end
    if (Clear.Now() - Clear._holdStart) < HOLD_MS then return nil end
    Clear._fired = true                           -- latch BEFORE acting
    return Clear.Perform()
end

-- Release. Fires if the threshold was reached, otherwise cancels silently --
-- an early release must do nothing at all, or the hold is not a confirm step.
function Clear.EndHold()
    local result = Clear.TickHold()
    Clear._holdStart = nil
    Clear._fired     = false
    return result
end

-- ---------------------------------------------------------------------------
-- The action
-- ---------------------------------------------------------------------------

function Clear.Perform()
    if not Clear.IsEnabled() then return nil end
    local N = model()
    if N == nil then return nil end

    local before = N.Summary()
    local ok, cleared = pcall(N.ClearAll)
    if not ok then
        logger():Error("ClearAll failed: %s", tostring(cleared))
        return nil
    end
    cleared = (type(cleared) == "number") and cleared or 0

    Clear.Announce(cleared, before)
    logger():Info("cleared %d new-item marker(s)", cleared)
    return cleared
end

-- Wording is deliberately honest about persistence. Bag markers are a Lua-cache
-- write with no C call behind them (see docs/research/API_REFERENCE.md), so they
-- come back on reload; collectible and item-set clears persist. Telling the
-- player "cleared everything" would be a lie they discover on next login.
function Clear.Message(cleared, before)
    if cleared == nil or cleared <= 0 then
        return text("SI_ACCOUNTHOLD_QOL_CLEARALL_NONE", "Nothing was marked new.")
    end
    local sessionOnly = (type(before) == "table" and before.sessionOnly) or 0
    if sessionOnly > 0 then
        return text("SI_ACCOUNTHOLD_QOL_CLEARALL_DONE_SESSION",
                    "Cleared %d new marker(s). %d were inventory markers, which return after a reload.",
                    cleared, sessionOnly)
    end
    return text("SI_ACCOUNTHOLD_QOL_CLEARALL_DONE", "Cleared %d new marker(s).", cleared)
end

function Clear.Announce(cleared, before)
    local msg = Clear.Message(cleared, before)
    local N = AccountHold and AccountHold.Notify
    if type(N) == "table" and type(N.Alert) == "function" then
        if pcall(N.Alert, N, msg) then return end
    end
    if AccountHold and type(AccountHold.Log) == "function" then
        pcall(AccountHold.Log, AccountHold, "%s", msg)
    end
end

-- ---------------------------------------------------------------------------
-- Keybind descriptor
-- ---------------------------------------------------------------------------

function Clear.Label()
    if Clear.IsHolding() then
        return text("SI_ACCOUNTHOLD_QOL_CLEARALL_HOLDING", "Clearing...")
    end
    local N = model()
    local total = 0
    if N ~= nil then
        local ok, s = pcall(N.Summary)
        if ok and type(s) == "table" and type(s.total) == "number" then total = s.total end
    end
    return text("SI_ACCOUNTHOLD_QOL_CLEARALL_HOLD",
                "Hold: Clear all new notifications (%d)", total)
end

function Clear.BuildDescriptor(slot)
    local desc = {
        keybind      = slot,
        handlesKeyUp = true,
        name         = function() return Clear.Label() end,
        -- Visible whenever the FEATURE is on, even at zero. An action that
        -- vanishes is indistinguishable from one that is broken, and this
        -- add-on has a long history of surfaces silently not appearing.
        visible      = function() return Clear.IsEnabled() end,
        -- handlesKeyUp: ONE boolean, false on press, true on release.
        callback     = function(isKeyUp)
            if isKeyUp then Clear.EndHold() else Clear.BeginHold() end
        end,
    }
    local S = safe()
    if S ~= nil and type(S.Harden) == "function" then
        S.Harden({ desc }, "qol/clearall")
    end
    return desc
end

-- ---------------------------------------------------------------------------
-- Attach / detach
-- ---------------------------------------------------------------------------

-- Try each candidate slot until one binds without collision. Returns the
-- descriptor that was registered, or nil when every candidate was taken --
-- in which case we add NOTHING, which is the correct failure.
function Clear.TryBind(slots)
    local strip = globalObj("KEYBIND_STRIP")
    local add = method(strip, "AddKeybindButton")
    -- Older/stripped clients (and the harness) may only offer the group API.
    local addGroup = (add == nil) and method(strip, "AddKeybindButtonGroup") or nil
    if add == nil and addGroup == nil then
        logger():Warn("no KEYBIND_STRIP add method - clear-all button NOT added.")
        return nil
    end

    for _, slot in ipairs(slots or SLOTS) do
        local desc = Clear.BuildDescriptor(slot)
        local ok
        if add ~= nil then
            ok = pcall(add, strip, desc)
        else
            ok = pcall(addGroup, strip, { alignment = KEYBIND_STRIP_ALIGN_LEFT, desc })
        end
        if ok then
            Clear._descriptor = desc
            Clear._slot       = slot
            Clear._usedGroup  = (add == nil)
            logger():Info("clear-all button bound to %s.", slot)
            return desc
        end
    end

    logger():Warn("every candidate keybind slot was taken - clear-all button NOT added.")
    return nil
end

function Clear.Unbind()
    local desc = Clear._descriptor
    if desc == nil then return end
    local strip = globalObj("KEYBIND_STRIP")
    if Clear._usedGroup then
        local rm = method(strip, "RemoveKeybindButtonGroup")
        if rm ~= nil then pcall(rm, strip, { alignment = KEYBIND_STRIP_ALIGN_LEFT, desc }) end
    else
        local rm = method(strip, "RemoveKeybindButton")
        if rm ~= nil then pcall(rm, strip, desc) end
    end
    Clear._descriptor = nil
    Clear._slot       = nil
    Clear._holdStart  = nil
    Clear._fired      = false
end

-- Scene wiring. Add on SCENE_SHOWING and remove on SCENE_HIDDEN, matching the
-- base game (siegebar.lua:46-55). SCENE_SHOWN is too late: it fires only after
-- fragments finish.
function Clear:Initialize(addonRef)
    self.addon = addonRef

    local scene = globalObj(SCENE_GLOBAL)
    local register = method(scene, "RegisterCallback")
    if register == nil then
        logger():Warn("%s has no RegisterCallback - clear-all NOT installed.", SCENE_GLOBAL)
        return false
    end

    local ok = pcall(register, scene, "StateChange", function(_oldState, newState)
        -- Compared by VALUE against the globals, which may be absent in a
        -- stripped environment; fall back to the known state strings.
        local showing = globalObj("SCENE_SHOWING")
        local hidden  = globalObj("SCENE_HIDDEN")
        if newState == showing or newState == "showing" then
            if Clear.IsEnabled() then Clear.TryBind() end
        elseif newState == hidden or newState == "hidden" then
            Clear.Unbind()
        end
    end)

    if not ok then
        logger():Warn("could not register StateChange - clear-all NOT installed.")
        return false
    end

    self._installed = true
    logger():Info("installed on %s.", SCENE_NAME)
    return true
end

function Clear:Teardown()
    Clear.Unbind()
    self._installed = false
end

return Clear
