-- AccountHold/src/core/Surface.lua
--
-- FOUNDATION MODULE. The install / teardown / gating contract for anything this
-- add-on attaches to a base-game screen.
--
-- WHY THIS EXISTS
-- ---------------
-- An audit of the twelve modules under ui/ found the same lifecycle re-derived
-- in each, and re-derived incompletely:
--
--   * TEARDOWN EXISTS IN 2 OF 12 MODULES. Ten surfaces cannot be removed once
--     added. That is not a tidiness problem -- it is why the feature gates do
--     not work. A gate that is only consulted at install time cannot take a
--     surface away when the player turns the feature off.
--   * THERE ARE 7 IsEnabled() CALLS ACROSS ALL 12 UI MODULES. Most surfaces are
--     not gated at all. `config/FeatureAccess.lua` reads like a rollout control
--     and largely is not one.
--   * Install failure is handled ad hoc. Some modules log, some are silent, and
--     ArmoryScreen_Gamepad is 2,904 lines with 58 pcall sites and no diagnostics
--     at all -- so "the tab did not appear" is currently unanswerable.
--
-- Surface makes the lifecycle DECLARATIVE. A module says what it is, which
-- feature owns it, how to attach and how to detach; Surface owns when.
--
-- WHAT IT DELIBERATELY DOES NOT DO
-- --------------------------------
-- It does not know what a row, a scene or a keybind IS. The audit found three
-- genuinely different attach seams with different failure modes -- appending to
-- a base list, registering a scene, and wrapping base-game functions -- and
-- pretending they are one thing would be a false abstraction that hides exactly
-- the risk that matters. `attach` and `detach` stay the caller's, because that
-- is the part that is genuinely different. Everything AROUND them is identical
-- and lives here.
--
-- NON-GOAL: adopting this is opt-in and incremental. No existing module is
-- changed by this file, and nothing is required to register.
--
-- ESO runs Lua 5.1: no goto, no bitwise operators. Must LOAD under
-- tests/zos_mock.lua with none of the ZO_* globals present.

AccountHold = AccountHold or {}
AccountHold.Core = AccountHold.Core or {}
AccountHold.Core.Surface = AccountHold.Core.Surface or {}

local Surface = AccountHold.Core.Surface

-- ---------------------------------------------------------------------------
-- Foundation deps, resolved at call time so this file loads standalone.
-- ---------------------------------------------------------------------------

local function safe()
    local c = AccountHold and AccountHold.Core
    local S = c and c.Safe
    return (type(S) == "table") and S or nil
end

local function call(fn, ...)
    local S = safe()
    if S ~= nil then return S.Call(fn, ...) end
    if type(fn) ~= "function" then return false, nil end
    local ok, res = pcall(fn, ...)
    return ok, (ok and res or nil)
end

local log
local function logger()
    if log then return log end
    local c = AccountHold and AccountHold.Core
    local L = c and c.Log
    if type(L) == "table" and type(L.For) == "function" then
        log = L.For("surface")
    else
        log = { Warn = function() end, Info = function() end, Error = function() end }
    end
    return log
end

-- ---------------------------------------------------------------------------
-- States
--
-- A surface is always in exactly one. `gated` and `unavailable` are distinct
-- from `failed` on purpose: only `failed` is worth retrying. Conflating them is
-- how a retry loop ends up hammering an install that can never succeed.
-- ---------------------------------------------------------------------------

Surface.PENDING     = "pending"      -- registered, not yet attempted
Surface.INSTALLED   = "installed"    -- attached; handle held for detach
Surface.GATED       = "gated"        -- feature is off; deliberately not attached
Surface.FAILED      = "failed"       -- attach failed; retryable
Surface.UNAVAILABLE = "unavailable"  -- attach says it can never work here; do not retry

Surface._registry = Surface._registry or {}
Surface._order    = Surface._order or {}

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------

-- Register(spec) -> true | false
--
-- spec = {
--   id       = "qol/clearAll",   -- REQUIRED, unique. Identity for teardown.
--   feature  = "qol",            -- optional gate key; nil = always allowed.
--   attach   = function(ctx) ... end,   -- REQUIRED. Return a handle (any
--                                       -- non-nil) on success, nil on failure,
--                                       -- or false to mean "never retry".
--   detach   = function(ctx, handle) end,  -- optional but strongly advised.
--   retry    = true,             -- retry a FAILED attach on the next Sync.
-- }
--
-- Re-registering the same id REPLACES the spec, detaching first if it was
-- installed -- a reload must not leak the previous attachment.
function Surface.Register(spec)
    if type(spec) ~= "table" then
        logger():Warn("Register: spec must be a table.")
        return false
    end
    if type(spec.id) ~= "string" or spec.id == "" then
        logger():Warn("Register: a surface needs a non-empty string id.")
        return false
    end
    if type(spec.attach) ~= "function" then
        logger():Warn("Register(%s): attach must be a function.", spec.id)
        return false
    end

    local existing = Surface._registry[spec.id]
    if existing ~= nil then
        Surface.Remove(spec.id)
    else
        Surface._order[#Surface._order + 1] = spec.id
    end

    Surface._registry[spec.id] = {
        id      = spec.id,
        feature = (type(spec.feature) == "string") and spec.feature or nil,
        attach  = spec.attach,
        detach  = (type(spec.detach) == "function") and spec.detach or nil,
        retry   = spec.retry ~= false,
        state   = Surface.PENDING,
        handle  = nil,
        error   = nil,
        attempts = 0,
    }
    return true
end

function Surface.Get(id)
    return Surface._registry[id]
end

function Surface.State(id)
    local e = Surface._registry[id]
    return e and e.state or nil
end

-- Deterministic registration order; never rely on pairs().
function Surface.Ids()
    local out = {}
    for i = 1, #Surface._order do
        if Surface._registry[Surface._order[i]] ~= nil then
            out[#out + 1] = Surface._order[i]
        end
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Gating
--
-- Consulted on EVERY Sync, not once at install. That is the whole point: a gate
-- read only at install time cannot remove a surface when the feature is turned
-- off, which is why ten of the twelve current surfaces ignore their gate in
-- practice.
-- ---------------------------------------------------------------------------

function Surface.IsAllowed(entry)
    if entry == nil then return false end
    if entry.feature == nil then return true end   -- ungated surface

    local F = AccountHold and AccountHold.Features
    if type(F) ~= "table" or type(F.IsEnabled) ~= "function" then
        -- No gate system loaded. FAIL CLOSED for a surface that declared a
        -- feature: shipping a gated surface ungated is the worse error.
        return false
    end
    local ok, res = call(function() return F:IsEnabled(entry.feature) end)
    return (ok and res) and true or false
end

-- ---------------------------------------------------------------------------
-- Attach / detach
-- ---------------------------------------------------------------------------

local function attachOne(entry, ctx)
    entry.attempts = entry.attempts + 1
    local ok, handle = call(entry.attach, ctx)

    if not ok then
        entry.state = Surface.FAILED
        entry.error = "attach threw"
        logger():Warn("%s: attach threw; NOT installed.", entry.id)
        return false
    end

    -- `false` is the explicit "this can never work here" signal, distinct from
    -- nil ("not right now"). Only nil is retried.
    if handle == false then
        entry.state = Surface.UNAVAILABLE
        entry.error = "attach reported unavailable"
        logger():Info("%s: unavailable here; will not retry.", entry.id)
        return false
    end

    if handle == nil then
        entry.state = Surface.FAILED
        entry.error = "attach returned nil"
        logger():Warn("%s: attach failed (attempt %d).", entry.id, entry.attempts)
        return false
    end

    entry.handle = handle
    entry.state  = Surface.INSTALLED
    entry.error  = nil
    logger():Info("%s: installed.", entry.id)
    return true
end

local function detachOne(entry, ctx)
    if entry.state ~= Surface.INSTALLED then return end
    if entry.detach ~= nil then
        local ok = call(entry.detach, ctx, entry.handle)
        if not ok then
            logger():Warn("%s: detach threw; treating as removed.", entry.id)
        end
    else
        -- Registering without a detach is legal but is the defect this module
        -- exists to surface, so it is named rather than passed over.
        logger():Warn("%s: no detach provided - the surface cannot be removed.", entry.id)
    end
    entry.handle = nil
    entry.state  = Surface.PENDING
end

-- ---------------------------------------------------------------------------
-- Sync -- the one entry point
--
-- Reconciles every registered surface against its gate. Installs what should be
-- present, removes what should not, retries what failed. Idempotent: calling it
-- twice with nothing changed does nothing the second time.
--
-- Call it at load, after the player is in the world, and whenever a feature
-- toggle changes.
-- ---------------------------------------------------------------------------

function Surface.Sync(ctx)
    local installed, removed, failed = 0, 0, 0

    local ids = Surface.Ids()
    for i = 1, #ids do
        local entry = Surface._registry[ids[i]]
        local allowed = Surface.IsAllowed(entry)

        if not allowed then
            if entry.state == Surface.INSTALLED then
                detachOne(entry, ctx)
                removed = removed + 1
            end
            entry.state = Surface.GATED

        elseif entry.state == Surface.INSTALLED then
            -- already correct; nothing to do

        elseif entry.state == Surface.UNAVAILABLE then
            -- deliberately sticky; never retried

        elseif entry.state == Surface.FAILED and not entry.retry then
            -- opted out of retrying

        else
            if attachOne(entry, ctx) then
                installed = installed + 1
            else
                if entry.state == Surface.FAILED then failed = failed + 1 end
            end
        end
    end

    return { installed = installed, removed = removed, failed = failed }
end

-- Remove one surface entirely: detach if installed, then forget it.
function Surface.Remove(id, ctx)
    local entry = Surface._registry[id]
    if entry == nil then return false end
    detachOne(entry, ctx)
    Surface._registry[id] = nil
    return true
end

-- Detach everything but keep the registrations, so a later Sync can restore.
function Surface.TeardownAll(ctx)
    local ids, n = Surface.Ids(), 0
    for i = 1, #ids do
        local entry = Surface._registry[ids[i]]
        if entry.state == Surface.INSTALLED then
            detachOne(entry, ctx)
            n = n + 1
        end
    end
    return n
end

-- Drop every registration. Primarily for tests.
function Surface.Reset(ctx)
    Surface.TeardownAll(ctx)
    Surface._registry = {}
    Surface._order    = {}
end

-- ---------------------------------------------------------------------------
-- Diagnostics
--
-- Answers "why is my tab not there?" in one call -- currently the single most
-- expensive question to answer in this add-on.
-- ---------------------------------------------------------------------------

function Surface.Report()
    local out = {}
    local ids = Surface.Ids()
    for i = 1, #ids do
        local e = Surface._registry[ids[i]]
        out[#out + 1] = {
            id       = e.id,
            feature  = e.feature,
            state    = e.state,
            attempts = e.attempts,
            error    = e.error,
            hasDetach = e.detach ~= nil,
        }
    end
    return out
end

-- One short line per surface. Console players read diagnostics in chat, where a
-- multi-line dump is unusable.
function Surface.ReportLines()
    local rows, out = Surface.Report(), {}
    for i = 1, #rows do
        local r = rows[i]
        local line = r.id .. " = " .. r.state
        if r.feature then line = line .. " (" .. r.feature .. ")" end
        if r.error then line = line .. " - " .. r.error end
        if not r.hasDetach then line = line .. " [NO DETACH]" end
        out[#out + 1] = line
    end
    return out
end

return Surface
