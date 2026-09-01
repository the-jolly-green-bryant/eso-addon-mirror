-- ===========================================================================
-- Ease.lua
-- ---------------------------------------------------------------------------
-- One time-based easing primitive, shared by every module that glides a camera
-- value toward a target.
--
-- Three modules independently grew the SAME self-tearing-updater pattern:
-- DynamicFov (FOV smoothing), FovArbiter (FOV glide under a hold), and
-- ContextPresets (spatial transition). Each hand-rolled an
-- identical lifecycle -- register a temporary RegisterForUpdate, compute
-- t = (now - start) / duration, clamp it, write an interpolated value each
-- frame, land EXACTLY on the target on the final frame, then unregister itself.
-- Only the PAYLOAD differed (which value to write). This module owns the
-- lifecycle once; callers supply the payload as callbacks.
--
-- Design rules (mirror the rest of the addon):
--   * Self-tearing: an ease registers a temporary updater on Start and
--     unregisters it the instant it lands, aborts, or is Stopped -- so an idle
--     module carries no per-frame cost, exactly as the hand-rolled versions did.
--   * Timing only. The primitive owns WHEN (start, progress, land); the caller
--     owns WHAT (the value written each step). onStep(t) receives progress in
--     [0,1); onLand() performs the exact final write. Keeping interpolation
--     caller-side lets one ease drive a single scalar (FOV, boost) or many keys
--     (a spatial transition) with no special-casing here.
--   * Retarget in place. Calling Start again under the same name restarts the
--     clock over a fresh duration without touching the registration, so an
--     in-flight ease re-aims smoothly from wherever the caller reads "live".
--   * One ease == one name == one updater, so several eases run at once without
--     interfering (each module keeps its own unique name, as before). Collapsing
--     these onto a single shared tick is a later step; this module only unifies
--     the LOGIC, not the timer count, so each conversion stays behavior-identical.
-- ===========================================================================

local addon = BureauOfAcceptableViews

addon.Ease = addon.Ease or {}
local Ease = addon.Ease

-- Hot-path / library globals bound to locals once at load.
local EVENT_MANAGER           = EVENT_MANAGER
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

-- Registry of live eases, keyed by name. An entry exists ONLY while its updater
-- is registered, so `active[name] ~= nil` is exactly "this ease is running".
--   onStep : function(t)  -- t in [0,1), progress; caller writes the interp value
--   onLand : function()   -- called once at t>=1; caller writes the exact target
--   isLive : function()->bool or nil -- checked each frame; false ABANDONS the
--            ease (stop, no land) for one whose owner can vanish mid-glide
--   durMs  : total duration; startMs : GetGameTimeMilliseconds() at (re)start
local active = {}

Ease.Curves = Ease.Curves or {}

function Ease.Curves.Linear(t)
    return t
end

-- Fast initial response with a short settling tail.
function Ease.Curves.Responsive(t)
    local inverse = 1 - t
    return 1 - inverse * inverse * inverse
end

-- Symmetric acceleration/deceleration for deliberate cinematic motion.
function Ease.Curves.Smooth(t)
    if t < 0.5 then
        return 4 * t * t * t
    end
    local inverse = -2 * t + 2
    return 1 - (inverse * inverse * inverse) / 2
end

-- Forward declaration so Start's registered closure can reach the stepper.
local Tick

-- Tear down the named ease: unregister its updater and drop the registry entry.
-- Idempotent, so it doubles as the external cancel and the internal self-tear.
function Ease.Stop(name)
    if active[name] then
        EVENT_MANAGER:UnregisterForUpdate(name)
        active[name] = nil
    end
end

-- True while the named ease is running. Read by diagnostics and, later, by the
-- self-check to collapse the per-module "gliding while disabled" leak checks.
function Ease.IsActive(name)
    return active[name] ~= nil
end

-- Begin or RETARGET an ease under `name`.
--   spec.durMs  : total duration in ms. <= 0 lands immediately (onLand only, no
--                 updater), so "ease over no time" degrades to "be there now".
--   spec.onStep : function(t) called each frame with t in [0,1).
--   spec.onLand : function() called once when t reaches 1 (exact landing).
--   spec.isLive : optional function()->bool; when it returns false the ease is
--                 abandoned WITHOUT landing (e.g. a released FOV hold).
-- Returns true when an updater is now running, false on the immediate-land path.
function Ease.Start(name, spec)
    local durMs = spec.durMs or 0

    if durMs <= 0 then
        -- Nothing to animate over: cancel any in-flight ease under this name and
        -- land now, so the end state matches a full glide that reached t>=1.
        Ease.Stop(name)
        if spec.onLand then spec.onLand() end
        return false
    end

    local e = active[name]
    if e then
        -- Retarget in place: the updater is already registered, so just re-aim
        -- and restart the clock over a fresh window (no re-registration).
        e.onStep  = spec.onStep
        e.onLand  = spec.onLand
        e.isLive  = spec.isLive
        e.curve   = spec.curve
        e.durMs   = durMs
        e.startMs = GetGameTimeMilliseconds()
        return true
    end

    active[name] = {
        onStep  = spec.onStep,
        onLand  = spec.onLand,
        isLive  = spec.isLive,
        curve   = spec.curve,
        durMs   = durMs,
        startMs = GetGameTimeMilliseconds(),
    }
    EVENT_MANAGER:RegisterForUpdate(name, 0, function() Tick(name) end)
    return true
end

-- Per-frame stepper for one named ease. Assigned to the forward-declared local
-- (not a fresh global) so Start's closure resolves it. Aborts if the entry
-- vanished or its owner is no longer live; lands exactly on the final frame;
-- otherwise writes the interpolated step.
function Tick(name)
    local e = active[name]
    if e == nil then
        -- Defensive: entry gone but the updater somehow still firing. Unregister
        -- directly (Stop would be a no-op with no entry) and bail.
        EVENT_MANAGER:UnregisterForUpdate(name)
        return
    end

    -- Owner vanished mid-glide (e.g. a hold released): abandon WITHOUT landing,
    -- so we do not fight whatever now owns the value.
    if e.isLive and not e.isLive() then
        Ease.Stop(name)
        return
    end

    local t = (GetGameTimeMilliseconds() - e.startMs) / e.durMs
    if t < 0 then t = 0 end

    if t >= 1 then
        -- Land: clear state FIRST (mirrors ContextPresets.FinishTransition) so a
        -- re-entrant Start from within onLand registers cleanly, then write the
        -- exact target through the caller's landing callback.
        local onLand = e.onLand
        Ease.Stop(name)
        if onLand then onLand() end
        return
    end

    if e.onStep then
        local progress = e.curve and e.curve(t) or t
        if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end
        e.onStep(progress)
    end
end