-- ===========================================================================
-- ContextPresets.lua
-- ---------------------------------------------------------------------------
-- Named bundles of camera settings, plus snapshot/restore.
--
-- A "preset" is a plain table of camera property values keyed by the same
-- internal names CameraSettings uses (distance, thirdPersonFov, shoulder, ...).
-- This module can:
--   * Snapshot()  -- read the current camera into a fresh preset table.
--   * Apply()     -- write a preset's values back onto the camera.
--   * Capture()/Restore() a single named "scratch" preset, used by callers
--     that want to stash the live camera, change it, then put it back exactly
--     (e.g. a temporary cinematic framing, or the emergency restore button).
--
-- Design notes:
--   * All engine I/O goes through CameraSettings; this module never touches
--     GetSetting/SetSetting directly, and unsupported properties are silently
--     skipped so an unexpected client build degrades instead of crashing.
--   * A preset only carries the keys it actually has a value for. Apply() only
--     writes those keys, so a partial preset (e.g. "just FOV and shoulder")
--     leaves every other camera property untouched.
--   * Nothing here is enabled by default or wired to SavedVariables; Settings.lua
--     owns persistence and decides when to call these.
-- ===========================================================================

local addon = BureauOfAcceptableViews
local private = addon.private

addon.ContextPresets = addon.ContextPresets or {}
local ContextPresets = addon.ContextPresets

local CameraSettings = addon.CameraSettings

-- Hot-path / library globals bound to locals once at load.
local ipairs   = ipairs
local pairs    = pairs
local type     = type
local tonumber = tonumber
local mathhuge = math.huge
local mathmax  = math.max
local IsUnitInCombat = IsUnitInCombat
local GetUnitStealthState = GetUnitStealthState
local IsMounted = IsMounted
local IsPlayerInWerewolfForm = IsPlayerInWerewolfForm
local IsUnitSwimming = IsUnitSwimming

-- Engine handle for this module's timers (coalesce, interaction-entry, sprint
-- poll) -- fixed-delay one-shots / polls that register directly. Bound once at
-- load. The spatial transition GLIDE no longer registers its own updater here --
-- it runs through the shared Ease primitive (below), which owns the frame timing.
local EVENT_MANAGER = EVENT_MANAGER

-- The shared easing primitive (Ease.lua) drives the spatial transition glide:
-- Ease owns register/progress/land/self-tear, this module supplies the payload
-- (interpolate the glide keys, then defer to the authoritative Apply on land).
-- Resolved eagerly because Ease loads before ContextPresets in the manifest.
local Ease = addon.Ease
local CameraResponse = addon.CameraResponse
local RESPONSE_OWNER = "ContextPresets"

-- The shared options-window watcher (OptionsWatch.lua): owns the fragment
-- subscription and the canonical IsOpen() suspend-gate, replacing this module's
-- own fragment callback + optionsOpen flag. Resolved eagerly (loads earlier).
local OptionsWatch = addon.OptionsWatch

-- Logging helpers are generated in the core file and exported on private.
-- Resolve them lazily so load order between files cannot break us.
local function LogWarn(...)
    if private.LogWarn then private.LogWarn(...) end
end

local function LogDebug(...)
    if private.LogDebug then private.LogDebug(...) end
end

local function LogInfo(...)
    if private.LogInfo then private.LogInfo(...) end
end

-- True when the ShoulderControl module currently owns the shoulder property (its
-- mode is auto or manual). While it does, ContextPresets cedes shoulder entirely:
-- it neither snapshots nor writes it, so exactly one module touches shoulder at a
-- time. Resolved lazily so file load order between the two modules cannot matter,
-- and so a missing module simply means "not owned" (presets manage shoulder as
-- before). See ShoulderControl.lua for the ownership contract.
local function ShoulderOwnedExternally()
    local shoulder = addon.ShoulderControl
    return shoulder ~= nil and shoulder.OwnsShoulder and shoulder.OwnsShoulder()
end

-- True while OffsetNudge is holding an axis bind. ContextPresets then skips
-- horizontalOffset and verticalOffset so a reassert or glide cannot fight the
-- live nudge. Recenter is a tap, not a hold, so it does not set this.
local HORIZONTAL_OFFSET_KEY = "horizontalOffset"
local VERTICAL_OFFSET_KEY = "verticalOffset"

local function OffsetNudgeOwnsAxes()
    local nudge = addon.OffsetNudge
    return nudge ~= nil and nudge.IsHolding and nudge.IsHolding()
end

local function SkipNudgeAxis(key)
    return OffsetNudgeOwnsAxes()
        and (key == HORIZONTAL_OFFSET_KEY or key == VERTICAL_OFFSET_KEY)
end

-- ---------------------------------------------------------------------------
-- Preset shape
-- ---------------------------------------------------------------------------
-- The ordered list of camera properties a preset may carry. Order is fixed so
-- Apply() writes deterministically (distance first, framing after) and so two
-- snapshots iterate identically. Keys must exist as CameraSettings descriptors;
-- anything CameraSettings does not support on this client is skipped at runtime.
local PRESET_KEYS = {
    "distance",
    "thirdPersonFov",
    "firstPersonFov",
    "horizontalOffset",
    "verticalOffset",
    "shoulder",
    "headBob",
    "screenShake",
}

-- Keys with special arbitration handling, named once to avoid stringly-typed
-- comparisons in Apply. FOV is owned by FovArbiter; distance changes here bypass
-- the zoom hook and so must trigger a dynamic-FOV reassert.
local FOV_KEY      = "thirdPersonFov"
local DISTANCE_KEY = "distance"
local SHOULDER_KEY = "shoulder"

-- ---------------------------------------------------------------------------
-- Snapshot / Apply
-- ---------------------------------------------------------------------------

-- Read the current camera into a fresh preset table. Only properties that are
-- supported on this client AND read back successfully are included, so the
-- result is always a faithful, replayable subset of the live camera state.
function ContextPresets.Snapshot()
    local preset = {}
    -- When ShoulderControl owns shoulder, skip it here so the captured base never
    -- carries shoulder -- hence a later restore never rewrites it, leaving that
    -- property entirely to ShoulderControl.
    local skipShoulder = ShoulderOwnedExternally()
    for _, key in ipairs(PRESET_KEYS) do
        if not (skipShoulder and key == SHOULDER_KEY) and CameraSettings.IsSupported(key) then
            local value, ok = CameraSettings.Get(key)
            if ok then
                preset[key] = value
            end
        end
    end
    return preset
end

-- Write a preset's values back onto the camera. Iterates PRESET_KEYS (not the
-- table) so writes are deterministic and unknown/extra keys in the preset are
-- ignored. Only keys the preset actually carries are written, leaving every
-- other camera property untouched. Returns the number of properties applied and
-- the number that failed, so callers can decide whether a partial apply matters.
--
-- isRestore distinguishes the two FOV semantics:
--   * false/nil (applying a preset bundle): FOV is *pinned* through an arbiter
--     hold so a later zoom tick cannot stomp the preset's framing.
--   * true (restoring the player's own snapshot): FOV is handed back to its
--     normal owner -- written directly, then any hold we took is released and
--     dynamic FOV reasserted -- so restoring never leaks a hold. A snapshot
--     always carries thirdPersonFov, so without this the FOV key would re-pin
--     on every preset->default exit and dynamic FOV would stay suppressed until
--     a /reloadui.
function ContextPresets.Apply(preset, isRestore)
    if type(preset) ~= "table" then
        LogWarn("ContextPresets.Apply: expected a table, got %s", type(preset))
        return 0, 0
    end

    local arbiter = addon.FovArbiter
    local applied, failed = 0, 0
    local skipShoulder = ShoulderOwnedExternally()
    if CameraResponse and CameraResponse.AcquireSmoothing then
        CameraResponse.AcquireSmoothing(RESPONSE_OWNER)
    end

    for _, key in ipairs(PRESET_KEYS) do
        local value = preset[key]
        if value ~= nil and not (skipShoulder and key == SHOULDER_KEY)
            and not SkipNudgeAxis(key)
            and CameraSettings.IsSupported(key) then
            if key == FOV_KEY and arbiter and not isRestore then
                -- FOV is arbitrated: pin it through a hold so a subsequent zoom
                -- change cannot stomp the preset's framing. The hold pins the
                -- value, so we do not also write it directly here.
                if arbiter.BeginHold("ContextPresets", value) then
                    applied = applied + 1
                else
                    failed = failed + 1
                end
            elseif CameraSettings.Set(key, value) then
                applied = applied + 1
                if key == DISTANCE_KEY and addon.ZoomReconciler and addon.ZoomReconciler.SyncIntent then
                    -- Distance was just written directly, bypassing the FPV-toggle
                    -- path ZoomReconciler owns. Re-seed its intent to match, so a
                    -- same-frame probe pair (PvpAlerts/Miat's) arriving afterwards
                    -- flips relative to THIS distance instead of a stale one.
                    addon.ZoomReconciler.SyncIntent(value)
                end
            else
                failed = failed + 1
            end
        end
    end

    -- Reconcile FOV ownership:
    --   * Restore, or a preset that omits FOV -> release any hold we previously
    --     took so dynamic FOV resumes, then (when the distance is known)
    --     reassert it at the restored/new distance. This is the path that keeps
    --     a leaked hold from killing dynamic FOV after a preset clears.
    --   * A preset that pins FOV -> the BeginHold above already owns it; done.
    if arbiter and (isRestore or preset[FOV_KEY] == nil) then
        arbiter.EndHold("ContextPresets")
        if preset[DISTANCE_KEY] ~= nil then
            arbiter.RequestDynamic(preset[DISTANCE_KEY])
        end
    end

    if CameraResponse and CameraResponse.ReleaseSmoothing then
        CameraResponse.ReleaseSmoothing(RESPONSE_OWNER)
    end

    LogDebug("ContextPresets.Apply: applied=%d, failed=%d", applied, failed)
    return applied, failed
end

-- ---------------------------------------------------------------------------
-- Named scratch slots (capture / restore)
-- ---------------------------------------------------------------------------
-- A small registry of named snapshots, for the "stash the live camera, change
-- it, then put it back" pattern. Each slot holds exactly one preset; capturing
-- again overwrites it. Kept in-memory only -- persistence is Settings.lua's job.
local slots = {}

-- Snapshot the current camera into the named slot, overwriting any previous
-- capture under that name. Returns the captured preset so callers can inspect
-- or persist it. The name is required; a nil/empty name is rejected.
function ContextPresets.Capture(name)
    if type(name) ~= "string" or name == "" then
        LogWarn("ContextPresets.Capture: a non-empty slot name is required")
        return nil
    end

    local preset = ContextPresets.Snapshot()
    slots[name] = preset
    LogDebug("ContextPresets.Capture: stored slot '%s'", name)
    return preset
end

-- Returns true if a capture exists under the given name.
function ContextPresets.HasCapture(name)
    return slots[name] ~= nil
end

-- Re-apply a previously captured slot onto the camera. Returns false when the
-- slot does not exist; otherwise returns Apply's (applied, failed) counts so a
-- partial restore is observable. The capture is left in place after a restore,
-- so the same stash can be restored more than once.
function ContextPresets.Restore(name)
    local preset = slots[name]
    if preset == nil then
        LogWarn("ContextPresets.Restore: no capture named '%s'", tostring(name))
        return false
    end

    LogDebug("ContextPresets.Restore: restoring slot '%s'", name)
    return ContextPresets.Apply(preset, true)
end

-- Forget a captured slot. Safe to call when the slot does not exist.
function ContextPresets.ClearCapture(name)
    slots[name] = nil
end

-- ===========================================================================
-- State-driven controller
-- ---------------------------------------------------------------------------
-- Everything above is the stateless primitive layer. The controller below adds
-- the actual feature: it watches the player's state (combat/werewolf/stealth/
-- interaction/mounted/swimming/sprint), picks the highest-priority ACTIVE state
-- that the user has
-- enabled, and applies that state's cinematic bundle -- snapshotting the live
-- camera the first time it changes anything so it can be restored exactly when
-- the player returns to the default state or the feature is switched off.
--
-- Design rules:
--   * OFF by default. Until Configure{enabled=true} runs, the controller
--     registers no events, starts no polling, and never touches the camera.
--   * Bundles are FIXED named constants (not per-state sliders) scaled by a
--     single global intensity multiplier, so the UI stays small but the values
--     can be expanded later without touching callers.
--   * Exactly one state is active at a time (highest priority wins). There is
--     no per-frame fighting: we only re-apply when the resolved state changes.
-- ===========================================================================

-- State identifiers. STATE_DEFAULT is the implicit "nothing special" state and
-- has no bundle (its "bundle" is the restored original snapshot).
local STATE_DEFAULT     = "default"
local STATE_COMBAT      = "combat"
local STATE_WEREWOLF    = "werewolf"
local STATE_STEALTH     = "stealth"
local STATE_INTERACTION = "interaction"
local STATE_MOUNTED     = "mounted"
local STATE_SWIMMING    = "swimming"
local STATE_SPRINT      = "sprint"

-- Resolution order, highest priority first. The first state in this list that
-- is both physically active AND enabled by the user becomes the active state.
-- NOTE: the approved spec listed combat > stealth > mounted > sprint and did
-- not place werewolf. Per user decision, werewolf sits ABOVE combat: it is a
-- special full-body transform the player can be in even outside of combat, so
-- its framing must win whenever active. Placing it below combat would let the
-- combat preset override the werewolf framing during fights, which is not the
-- intended behavior.
local STATE_PRIORITY = {
    STATE_WEREWOLF,
    STATE_COMBAT,
    STATE_STEALTH,
    STATE_INTERACTION,
    STATE_MOUNTED,
    STATE_SWIMMING,
    STATE_SPRINT,
}

-- Numeric priority rank derived from STATE_PRIORITY: lower number = higher
-- priority. Used by the anti-jitter coalescer to tell an escalation (entering a
-- higher-priority state) from a de-escalation (dropping toward default). Any
-- state not listed -- notably STATE_DEFAULT -- ranks below every special state.
local STATE_RANK = {}
for rank, stateId in ipairs(STATE_PRIORITY) do
    STATE_RANK[stateId] = rank
end
local externalProfile
local function PriorityRank(stateId)
    if externalProfile and stateId == externalProfile.stateId then
        return 0
    end
    return STATE_RANK[stateId] or mathhuge
end

-- Fixed cinematic bundles, expressed as OFFSETS from the player's own camera
-- (snapshotted at activation), not absolute values, so they layer on top of
-- whatever the player already runs. Offsets are scaled by the global intensity
-- multiplier before being applied. Absolute-only keys (e.g. FOV) use a target
-- that intensity blends toward from the snapshot.
local STATE_BUNDLES = {
    [STATE_COMBAT] = {
        fovTarget        = 60,    -- widen slightly for situational awareness
        distanceOffset   = 0.6,   -- pull back a touch
        verticalOffset   = 0.05,
    },
    [STATE_WEREWOLF] = {
        fovTarget        = 63,
        distanceOffset   = 1.2,   -- big beast, pull back more
        verticalOffset   = 0.10,
    },
    [STATE_STEALTH] = {
        fovTarget         = 50,    -- tighten in for a focused, sneaky feel
        distanceOffset    = -0.4,
        shoulderTarget    = 0.65,  -- over-the-shoulder framing
        screenShakeTarget = 0.0,   -- steady, calm hold while sneaking
        headBobTarget     = 0.0,   -- kill head bob for a focused first-person creep
    },
    [STATE_INTERACTION] = {
        fovTarget         = 48,    -- tighten in toward the NPC for a dialogue close-up
        distanceOffset    = -0.5,  -- pull in closer during the conversation
        screenShakeTarget = 0.0,   -- hold steady while talking
    },
    [STATE_MOUNTED] = {
        fovTarget        = 58,
        distanceOffset   = 1.0,   -- show the mount
        headBobTarget    = 0.0,   -- smooth ride: no first-person bobbing in the saddle
    },
    [STATE_SWIMMING] = {
        fovTarget        = 62,    -- open up for an expansive underwater feel
        distanceOffset   = 0.8,   -- pull back for a cinematic swimming shot
        verticalOffset   = 0.08,
    },
    [STATE_SPRINT] = {
        fovTarget        = 61,    -- subtle speed-sense widening
        distanceOffset   = 0.3,
    },
}

-- ---------------------------------------------------------------------------
-- Ready-made styles (per-state strength profiles)
-- ---------------------------------------------------------------------------
-- A "style" is the named preset a user picks per state from the settings
-- dropdown. It is NOT a different set of offsets -- the direction of each
-- bundle (combat widens, stealth tightens, ...) stays fixed so framing always
-- suits the state. A style only scales how STRONG that framing is, as a
-- multiplier on top of the global intensity. STYLE_OFF disables the state
-- entirely (same as the old per-state "off" toggle).
--
-- Strengths above 1.0 (action) can push a bundle past its nominal target; that
-- is intentional and safe -- CameraSettings clamps every write to the engine's
-- accepted range, so an over-strong style degrades to the range edge instead of
-- producing an invalid value.
local STYLE_OFF       = "off"
local STYLE_SUBTLE    = "subtle"
local STYLE_CINEMATIC = "cinematic"
local STYLE_ACTION    = "action"

local STYLE_STRENGTH = {
    [STYLE_OFF]       = 0,
    [STYLE_SUBTLE]    = 0.5,
    [STYLE_CINEMATIC] = 1.0,
    [STYLE_ACTION]    = 1.5,
}

-- Ordered for the settings dropdown and any iteration. Off first so it reads as
-- the neutral/disabled choice at the top of the list.
local STYLE_IDS = {
    STYLE_OFF,
    STYLE_SUBTLE,
    STYLE_CINEMATIC,
    STYLE_ACTION,
}

-- Coerce any value to a known style id, falling back to STYLE_OFF.
local function NormalizeStyle(style)
    if type(style) == "string" and STYLE_STRENGTH[style] ~= nil then
        return style
    end
    return STYLE_OFF
end

-- ---------------------------------------------------------------------------
-- Controller runtime state
-- ---------------------------------------------------------------------------
-- All inert until Configure{enabled=true}. stateStyles is the per-state user
-- choice map ([stateId] = style id; STYLE_OFF means the state is disabled).
-- intensity is the global multiplier applied on top of each style's strength
-- (0 = no effect, 1 = full style strength). stateIntensities is an additional
-- per-state multiplier ([stateId] = 0..1) that scales that one state on top of
-- the global intensity; a missing entry means 1.0 (no per-state attenuation),
-- so the effective strength is global * style * perState.
local controller = {
    enabled         = false,
    intensity       = 1.0,
    smooth          = true,    -- ease state transitions (spatial glide + FOV glide)
    stateStyles     = {},      -- [stateId] = style id (defaults to STYLE_OFF)
    stateIntensities = {},     -- [stateId] = 0..1 per-state multiplier (defaults to 1.0)
    stateCoalesceMs = {},      -- [stateId] = release delay in ms (defaults to 0 = off)
    activeState     = STATE_DEFAULT,
    physical        = {},      -- [stateId] = true while physically in that state
    restoreSlot     = "ContextPresets.controllerRestore",
    recovered       = false,   -- load-time snapshot recovery runs once per session
    ready           = false,   -- first apply waits for recovery + saved-zoom restore
    -- Sprint subscription state lives in SprintWatch (IsSubscribed),
    -- not a per-controller flag -- same pattern as OptionsWatch for the options
    -- window. The "options window is open" suspend-state lives in OptionsWatch
    -- (read via OptionsWatch.IsOpen()): while it is up we hand the live camera
    -- back to the pre-preset snapshot and suspend re-evaluation; on close we
    -- re-snapshot the edited base and re-apply.
}

-- A detector module may request one external profile without becoming another
-- camera owner. The profile still flows through this controller's snapshot,
-- transition, restore, shoulder-ownership, and FOV-arbitration paths. PvPMode
-- is the intended first consumer. A nil stateId means no external override.
externalProfile = {
    source  = nil,
    stateId = nil,
    bundle  = nil,
    failed  = 0,
}

-- The named scratch slot used to stash the player's pre-preset camera. Reusing
-- the Capture/Restore machinery above keeps a single restore path.
local RESTORE_SLOT = controller.restoreSlot

-- Mirror the in-memory restore snapshot into persistent storage (owned by
-- Settings) so a /reloadui, logout, or crash WHILE a preset is overriding the
-- camera can hand the player's real camera back next session instead of leaving
-- the preset's offsets baked into their settings. Resolved lazily so file load
-- order between Settings and this module cannot matter. Passing nil clears the
-- persisted copy. Best-effort: if Settings is unavailable the in-memory snapshot
-- still works for the current session.
local function PersistRestoreSnapshot(snapshot)
    local settings = addon.Settings
    if settings and settings.SetPresetRestoreSnapshot then
        settings.SetPresetRestoreSnapshot(snapshot)
    end
end

-- The base snapshot is committed inline in ApplyState, and only once a bundle has
-- actually resolved for the new state -- capturing before that is known would
-- leave a persisted snapshot for a camera nobody overrode. The "capture once"
-- rule still holds: ApplyState only writes the slot when it is empty, so the
-- snapshot always reflects the player's own framing from the first departure off
-- default -- never another state's bundle.

-- Hand the camera back to the captured snapshot and forget it everywhere: the
-- in-memory slot AND the persisted copy. Safe to call when nothing is captured
-- (still clears any stale persisted copy, which is the desired post-condition).
local function RestoreAndForget()
    if ContextPresets.HasCapture(RESTORE_SLOT) then
        local applied, failed = ContextPresets.Restore(RESTORE_SLOT)
        if applied == false or failed ~= 0 then
            LogWarn("ContextPresets: restore incomplete; retaining recovery snapshot")
            return false
        end
        ContextPresets.ClearCapture(RESTORE_SLOT)
    end
    PersistRestoreSnapshot(nil)
    return true
end

-- Clamp helper (kept local; mirrors DynamicFov's tiny local clamp so the module
-- has no hard dependency on private.ClampNumber across load order).
local function Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

-- The effective style id chosen for a state (STYLE_OFF when unset/disabled).
local function StyleForState(stateId)
    return NormalizeStyle(controller.stateStyles[stateId])
end

-- The per-state intensity multiplier for a state, clamped to 0..1. A missing or
-- non-numeric entry means 1.0 (no per-state attenuation), so states keep their
-- full style strength until the user dials one down.
local function IntensityForState(stateId)
    local value = tonumber(controller.stateIntensities[stateId])
    if value == nil then
        return 1.0
    end
    return Clamp(value, 0, 1)
end

-- Build the concrete preset to apply for a state, given the live snapshot and
-- the current intensity. Offsets are added to the snapshot and scaled by the
-- effective strength (global intensity * the state's chosen style strength *
-- the state's own intensity); *Target values blend from the snapshot toward the
-- target by that strength. A state set to STYLE_OFF resolves to strength 0 and
-- yields no preset. Returns a fresh preset table carrying only the keys it sets,
-- or nil when nothing to do.
local function ResolveBundle(stateId, snapshot)
    local isExternal = stateId == externalProfile.stateId
        and externalProfile.stateId ~= nil
        and type(externalProfile.bundle) == "table"
    local bundle = isExternal and externalProfile.bundle or STATE_BUNDLES[stateId]
    if not bundle or type(snapshot) ~= "table" then
        return nil
    end

    local k
    if isExternal then
        k = Clamp(tonumber(bundle.intensity) or 1.0, 0, 1)
    else
        local styleStrength = STYLE_STRENGTH[StyleForState(stateId)] or 0
        k = Clamp(controller.intensity, 0, 1) * styleStrength * IntensityForState(stateId)
    end
    if k <= 0 then
        return nil
    end
    local preset = {}

    if bundle.distanceOffset ~= nil and snapshot.distance ~= nil then
        local targetDistance = snapshot.distance + bundle.distanceOffset * k
        local includeDistance = true
        if isExternal and rawget(bundle, "distancePolicy") == "outwardOnly" then
            local liveDistance, ok = CameraSettings.Get(DISTANCE_KEY)
            if ok and liveDistance ~= nil then
                targetDistance = mathmax(targetDistance, liveDistance)
            else
                -- Strict fail-closed semantics: without the live distance we
                -- cannot prove this write only moves outward, so omit distance
                -- and leave the player's current zoom untouched.
                includeDistance = false
            end
        end
        if includeDistance then
            preset.distance = targetDistance
        end
    end
    if bundle.fovTarget ~= nil and snapshot.thirdPersonFov ~= nil then
        preset.thirdPersonFov = snapshot.thirdPersonFov
            + (bundle.fovTarget - snapshot.thirdPersonFov) * k
    end
    if bundle.shoulderTarget ~= nil and snapshot.shoulder ~= nil
        and not ShoulderOwnedExternally() then
        preset.shoulder = snapshot.shoulder
            + (bundle.shoulderTarget - snapshot.shoulder) * k
    end
    if bundle.verticalOffset ~= nil and snapshot.verticalOffset ~= nil then
        preset.verticalOffset = snapshot.verticalOffset + bundle.verticalOffset * k
    end
    -- screenShake / headBob are absolute 0..1 settings, so they blend from the
    -- snapshot toward a target by the effective strength (same semantics as
    -- fovTarget). At strength 0 nothing is written; at full strength the value
    -- lands on the target. CameraSettings clamps the result to the engine range.
    if bundle.screenShakeTarget ~= nil and snapshot.screenShake ~= nil then
        preset.screenShake = snapshot.screenShake
            + (bundle.screenShakeTarget - snapshot.screenShake) * k
    end
    if bundle.headBobTarget ~= nil and snapshot.headBob ~= nil then
        preset.headBob = snapshot.headBob
            + (bundle.headBobTarget - snapshot.headBob) * k
    end
    return preset
end

-- ---------------------------------------------------------------------------
-- State resolution + transitions
-- ---------------------------------------------------------------------------

-- Pick the highest-priority state that is both physically active and given a
-- non-Off style by the user. Falls back to STATE_DEFAULT when nothing qualifies.
local function ResolveActiveState()
    if externalProfile.stateId ~= nil and type(externalProfile.bundle) == "table" then
        return externalProfile.stateId
    end
    for _, stateId in ipairs(STATE_PRIORITY) do
        if controller.physical[stateId] and StyleForState(stateId) ~= STYLE_OFF then
            return stateId
        end
    end
    return STATE_DEFAULT
end

-- ---------------------------------------------------------------------------
-- Smooth transition glide (self-tearing-down updater)
-- ---------------------------------------------------------------------------
-- A state change normally snaps the camera to the new bundle. This layer eases
-- the *spatial* framing (distance + offsets) toward the target over a short
-- window instead, using the exact same discipline as DynamicFov's FOV glide: a
-- TEMPORARY RegisterForUpdate that unregisters itself the moment the transition
-- completes, so there is no standing per-frame cost when nothing is moving.
--
-- FOV is deliberately NOT glided here (that is the separate FovArbiter pass):
-- it keeps its current instant semantics -- pinned immediately on entry via
-- BeginHold. The final frame defers to ContextPresets.Apply(target, isRestore)
-- so a glided transition lands in EXACTLY the same camera state (every key, plus
-- FOV ownership reconciliation) an instant Apply would have produced.

-- Spatial keys eased frame-by-frame. FOV is excluded (arbitrated separately);
-- non-animatable keys (headBob, screenShake, ...) are written once at the end by
-- the authoritative Apply, so they snap rather than glide -- which is fine.
local GLIDE_KEYS = {
    DISTANCE_KEY,
    "horizontalOffset",
    "verticalOffset",
    SHOULDER_KEY,
}

local TRANSITION_UPDATE_NAME = "BAV_ContextPresets_Transition"
local TRANSITION_DURATION_MS = 250

-- Payload state for the in-flight spatial glide, read by the step/land closures
-- below. Held as module locals so those closures + the ease spec are built ONCE
-- (not per transition). keys is the per-transition array of { key, from, to }
-- (rebuilt each StartTransition since the animated key set varies); target/isRestore
-- are the authoritative landing arguments OnTransitionLand hands to Apply. "Is a
-- transition running" is now Ease.IsActive(TRANSITION_UPDATE_NAME), not a flag here.
local transitionKeys      = nil
local transitionTarget    = nil
local transitionIsRestore = false
local transitionClearsRestoreSnapshot = false

-- Cancel any in-flight transition glide. Idempotent (Ease.Stop is a no-op when not
-- running), so it also serves as the cancel path when a new transition interrupts
-- an in-flight one, and on disable / emergency restore.
local function StopTransition()
    Ease.Stop(TRANSITION_UPDATE_NAME)
    if CameraResponse and CameraResponse.ReleaseSmoothing then
        CameraResponse.ReleaseSmoothing(RESPONSE_OWNER)
    end
    transitionKeys      = nil
    transitionTarget    = nil
    transitionIsRestore = false
    transitionClearsRestoreSnapshot = false
end

-- Returns true while a transition glide is in progress (read by diagnostics).
function ContextPresets.IsTransitioning()
    return Ease.IsActive(TRANSITION_UPDATE_NAME)
end

-- Per-frame step: ease each glide key from its captured start toward the target
-- over the window. The animated key set is transitionKeys (built per transition in
-- StartTransition); the exact landing + FOV reconciliation happen in onLand. The
-- guard is belt-and-braces: Ease only calls this while the ease is live, which is
-- exactly the window transitionKeys is populated.
local function OnTransitionStep(t)
    if transitionKeys == nil then
        return
    end
    for _, g in ipairs(transitionKeys) do
        if (g.key ~= SHOULDER_KEY or not ShoulderOwnedExternally())
            and not SkipNudgeAxis(g.key) then
            CameraSettings.Set(g.key, g.from + (g.to - g.from) * t)
        end
    end
end

-- Land the transition: capture the authoritative args, CLEAR glide state first
-- (so a re-entrant transition started from within Apply -- e.g. a hold's EndHold
-- reasserting -- sees a clean slate), then defer to the proven instant Apply so
-- every key (including non-glided ones and FOV) reaches its exact target and FOV
-- ownership is reconciled identically to a non-glided transition. This is the old
-- FinishTransition, now driven by Ease on the final frame.
local function OnTransitionLand()
    local target = transitionTarget
    local isRestore = transitionIsRestore
    local clearsRestoreSnapshot = transitionClearsRestoreSnapshot
    StopTransition()
    local _, failed = ContextPresets.Apply(target or {}, isRestore)
    if controller.activeState == externalProfile.stateId then
        externalProfile.failed = failed
    end
    if clearsRestoreSnapshot and failed == 0 then
        ContextPresets.ClearCapture(RESTORE_SLOT)
        PersistRestoreSnapshot(nil)
    elseif clearsRestoreSnapshot then
        LogWarn("ContextPresets: smooth restore incomplete; retaining recovery snapshot")
    end
end

-- Transition payload, allocated once and reused across transitions (StartTransition
-- rewrites the module-local endpoints). durMs is fixed for presets, so the whole
-- spec is a constant.
local TRANSITION_SPEC = {
    durMs  = TRANSITION_DURATION_MS,
    onStep = OnTransitionStep,
    onLand = OnTransitionLand,
}

-- Begin (or retarget) a glide toward target. Cancels any in-flight glide first
-- so an interrupted transition retargets from the LIVE camera rather than a
-- stale start. When entering a state that pins FOV, the pin happens immediately
-- (instant FOV semantics); the spatial keys glide. If there is nothing to glide
-- (no readable spatial keys in the target) it falls straight through to the
-- authoritative instant Apply.
local function StartTransition(target, isRestore, clearRestoreSnapshotOnLand)
    StopTransition()

    local arbiter = addon.FovArbiter
    local durationMs = controller.smooth and TRANSITION_DURATION_MS or 0
    local curve = nil
    if CameraResponse then
        durationMs = CameraResponse.GetDurationMs()
        curve = CameraResponse.GetCurve()
    end

    -- When smoothing is off, every transition snaps: no spatial glide and an
    -- instant FOV pin. Defer straight to the authoritative Apply so the camera
    -- lands in exactly one step, identical to the pre-glide behavior.
    if durationMs <= 0 then
        local _, failed = ContextPresets.Apply(target or {}, isRestore)
        if clearRestoreSnapshotOnLand and failed == 0 then
            ContextPresets.ClearCapture(RESTORE_SLOT)
            PersistRestoreSnapshot(nil)
        elseif clearRestoreSnapshotOnLand then
            LogWarn("ContextPresets: restore incomplete; retaining recovery snapshot")
        end
        return
    end

    -- Own and ease FOV over the same window as the spatial keys, on BOTH paths:
    --   * entering a state that pins FOV -> glide toward the pinned value so FOV
    --     and framing land together instead of FOV snapping ahead.
    --   * restoring the snapshot -> take a TEMPORARY hold purely to own FOV
    --     during the glide (so a zoom tick cannot fight it) and ease toward the
    --     snapshot's FOV. OnTransitionLand -> Apply(target, isRestore) writes the
    --     exact value; on restore its EndHold then releases this hold (cancelling
    --     the glide) and reasserts dynamic FOV, so FOV still returns to its normal
    --     owner -- just smoothly instead of snapping.
    if type(target) == "table" and target[FOV_KEY] ~= nil
        and arbiter and CameraSettings.IsSupported(FOV_KEY) then
        arbiter.BeginHold("ContextPresets", target[FOV_KEY], durationMs)
    end

    local keys = {}
    if type(target) == "table" then
        for _, key in ipairs(GLIDE_KEYS) do
            local to = target[key]
            if to ~= nil and not (key == SHOULDER_KEY and ShoulderOwnedExternally())
                and not SkipNudgeAxis(key)
                and CameraSettings.IsSupported(key) then
                local from, ok = CameraSettings.Get(key)
                if ok and from ~= nil then
                    keys[#keys + 1] = { key = key, from = from, to = to }
                end
            end
        end
    end

    if #keys == 0 then
        -- Nothing animatable: behave exactly like the instant path.
        local _, failed = ContextPresets.Apply(target or {}, isRestore)
        if clearRestoreSnapshotOnLand and failed == 0 then
            ContextPresets.ClearCapture(RESTORE_SLOT)
            PersistRestoreSnapshot(nil)
        elseif clearRestoreSnapshotOnLand then
            LogWarn("ContextPresets: restore incomplete; retaining recovery snapshot")
        end
        return
    end

    -- Rewrite the shared endpoints and (re)start the ease over a fresh window.
    -- StopTransition at the top already cancelled any in-flight glide, so this
    -- registers cleanly; Ease drives OnTransitionStep each frame and OnTransitionLand
    -- on the final one (which defers to the authoritative Apply).
    transitionKeys      = keys
    transitionTarget    = target
    transitionIsRestore = isRestore
    transitionClearsRestoreSnapshot = clearRestoreSnapshotOnLand and true or false
    TRANSITION_SPEC.durMs = durationMs
    TRANSITION_SPEC.curve = curve
    if CameraResponse and CameraResponse.AcquireSmoothing then
        CameraResponse.AcquireSmoothing(RESPONSE_OWNER)
    end
    Ease.Start(TRANSITION_UPDATE_NAME, TRANSITION_SPEC)
end

-- Transition from the current active state to a newly resolved one. Snapshots
-- the live camera on the first departure from default, applies the new state's
-- bundle, and restores the snapshot when returning to default.
local function ApplyState(stateId, instant, force)
    if stateId == controller.activeState and not force then
        return
    end

    LogDebug("ContextPresets: state %s -> %s", controller.activeState, stateId)

    if stateId == STATE_DEFAULT then
        -- Returning to baseline: keep the captured snapshot through the entire
        -- glide and drop it only when that glide lands. A new state arriving mid-
        -- restore then reuses the original player base instead of capturing the
        -- partially restored camera as a new base.
        if ContextPresets.HasCapture(RESTORE_SLOT) then
            if instant then
                StopTransition()
                local _, failed = ContextPresets.Apply(slots[RESTORE_SLOT], true)
                if failed == 0 then
                    ContextPresets.ClearCapture(RESTORE_SLOT)
                    PersistRestoreSnapshot(nil)
                else
                    LogWarn("ContextPresets: instant restore incomplete; retaining recovery snapshot")
                end
            else
                StartTransition(slots[RESTORE_SLOT], true, true)
            end
        else
            PersistRestoreSnapshot(nil)
        end
        controller.activeState = STATE_DEFAULT
        return
    end

    -- Entering (or switching between) a special state. The base snapshot is taken
    -- once, on the first transition away from default, so restore returns the
    -- player's own framing rather than another state's bundle.
    --
    -- Resolve the bundle BEFORE committing anything: when it resolves to nil (the
    -- camera did not read back, or the effective strength is 0) this state has no
    -- override at all. Committing activeState in that case would leave the
    -- controller claiming a state whose bundle does not exist -- the eventual
    -- return to default would "restore" a camera nobody touched, and
    -- ReassertActive would keep re-pinning a phantom state after every zone
    -- change. So on a nil bundle we neither persist a snapshot nor move the state.
    local hadCapture = ContextPresets.HasCapture(RESTORE_SLOT)
    local snapshot = hadCapture and slots[RESTORE_SLOT] or ContextPresets.Snapshot()

    local preset = ResolveBundle(stateId, snapshot)
    if preset == nil then
        LogDebug("ContextPresets: state '%s' resolved to no bundle; staying at '%s'",
            tostring(stateId), tostring(controller.activeState))
        return
    end

    -- A bundle exists, so the camera IS about to be overridden: commit the base
    -- snapshot now (persisted so a session ending mid-preset recovers next load).
    if not hadCapture then
        slots[RESTORE_SLOT] = snapshot
        PersistRestoreSnapshot(snapshot)
    end

    if instant or (stateId == externalProfile.stateId
        and rawget(externalProfile.bundle, "instant")) then
        StopTransition()
        local _, failed = ContextPresets.Apply(preset, false)
        if stateId == externalProfile.stateId then
            externalProfile.failed = failed
        end
    else
        StartTransition(preset, false)
    end
    controller.activeState = stateId
end

-- ---------------------------------------------------------------------------
-- State-change coalescing (anti-jitter)
-- ---------------------------------------------------------------------------
-- Rapid state events -- combat ending and restarting half a second later, a
-- brief stealth blip, a quick dismount-then-fight -- would otherwise each kick
-- off their own camera transition, so the framing visibly jerks back and forth.
--
-- We damp this with a "fast-escalate / slow-release" rule, keyed off state
-- PRIORITY rather than elapsed time:
--   * ESCALATION (resolved state outranks the active one -- e.g. entering
--     combat, transforming) applies IMMEDIATELY, so reacting to danger stays
--     responsive. Applying also cancels any pending release.
--   * DE-ESCALATION (resolved state drops toward default / a lower-priority
--     state -- e.g. combat ending) is DEFERRED by the LEAVING state's own
--     release window and re-resolved THEN. That window is per-state and
--     USER-CONFIGURABLE (Settings pushes it in via Configure); it defaults to 0
--     for every state, meaning "release immediately, no coalescing", until the
--     user picks a delay in the options panel. Because the physical flags update
--     immediately, a quick out-and-back (combat ends, then restarts inside the
--     window) re-escalates and the deferred release nets to a no-op (ApplyState
--     skips when the resolved state already equals the active one). A drop that
--     really settled applies exactly once when the window elapses.
--
-- This fixes the old time-anchored model, where a release after a long combat
-- (longer than the window) applied instantly and never damped the very jitter
-- it was meant to catch. Mirrors the self-tearing-updater discipline used
-- elsewhere: the timer registers only while a release is pending and
-- unregisters itself the moment it fires.
local COALESCE_UPDATE_NAME = "BAV_ContextPresets_Coalesce"

-- Default release delay (ms) for a state with no stored value. 0 means "release
-- immediately, no coalescing" -- the shipped default for every state, so presets
-- do not damp state exits until the user opts a state into a delay. Per-state
-- values live in SavedVariables and are pushed in via Configure (stateCoalesce).
local DEFAULT_COALESCE_MS = 0

-- The release delay (ms) for leaving the given state, read from the user-set map.
-- A missing or non-numeric entry falls back to DEFAULT_COALESCE_MS; negatives are
-- clamped to 0. In practice we only ever look up the state we are actively leaving.
local function CoalesceDelayFor(stateId)
    local delay = tonumber(controller.stateCoalesceMs[stateId])
    if delay == nil then
        return DEFAULT_COALESCE_MS
    end
    if delay < 0 then
        return 0
    end
    return delay
end

-- pending gates the one-shot updater; nothing else runs while idle.
local coalesce = {
    pending = false,
}

-- Tear down the coalesce timer. Idempotent, so it doubles as the cancel path on
-- disable / emergency restore.
local function CancelCoalesce()
    if coalesce.pending then
        EVENT_MANAGER:UnregisterForUpdate(COALESCE_UPDATE_NAME)
        coalesce.pending = false
    end
end

-- Resolve and apply the active state RIGHT NOW. Cancels any pending release
-- first so a deferred fire cannot double-apply or undo this application.
local function ApplyResolvedNow()
    CancelCoalesce()
    local hasExternalProfile = externalProfile.stateId ~= nil
        and type(externalProfile.bundle) == "table"
    if not controller.enabled and not hasExternalProfile then
        return
    end
    ApplyState(ResolveActiveState())
end

-- One-shot coalesce updater: unregister immediately, then apply whatever state
-- is current at fire time. A burst of flips during the release window collapses
-- to this single evaluation -- and if the player re-escalated meanwhile, the
-- resolved state already equals the active one and ApplyState is a no-op.
local function OnCoalesceUpdate()
    CancelCoalesce()
    ApplyResolvedNow()
end

-- Arm the release timer, unless one is already pending (the in-flight timer will
-- resolve the latest state when it fires, so re-arming would only push the
-- settle point further out).
local function ScheduleCoalesce(delayMs)
    if coalesce.pending then
        return
    end
    if delayMs < 0 then delayMs = 0 end
    coalesce.pending = true
    EVENT_MANAGER:RegisterForUpdate(COALESCE_UPDATE_NAME, delayMs, OnCoalesceUpdate)
end

-- Recompute the active state from current inputs and apply per the fast-
-- escalate / slow-release rule: an escalation (resolved state outranks the active
-- one) applies immediately and cancels any pending release; a de-escalation toward
-- a lower-priority state is deferred by the leaving state's own release window
-- (CoalesceDelayFor) so a quick out-and-back collapses to a no-op instead of
-- jittering the camera. If a release timer is already armed, ScheduleCoalesce
-- leaves it in place -- it re-resolves the latest state when it fires, so the
-- newest change is still honoured without pushing the settle point further out.
local function Reevaluate()
    local hasExternalProfile = externalProfile.stateId ~= nil
        and type(externalProfile.bundle) == "table"
    if (not controller.enabled and not hasExternalProfile) or not controller.ready then
        return
    end

    -- While the options window is open the camera is intentionally handed back to
    -- the player's snapshot so they can edit the real settings. Don't fight that
    -- by re-applying a state mid-edit; OnOptionsClosed re-evaluates once on close.
    -- Read from the shared OptionsWatch (the single suspend-gate).
    if OptionsWatch.IsOpen() then
        return
    end

    local resolved = ResolveActiveState()
    if resolved == controller.activeState then
        return
    end

    -- An escalation must win now; cancel any pending release and apply.
    if PriorityRank(resolved) < PriorityRank(controller.activeState) then
        ApplyResolvedNow()
        return
    end

    -- De-escalation: defer by the slow-release window of the state we are LEAVING,
    -- so a fast re-escalation inside that window cancels it. Each state carries its
    -- own release delay, user-configured in the panel and pushed in via Configure;
    -- every state ships at 0 (release immediately) until the user opts one into a
    -- delay. A delay of 0 or below means release immediately.
    local delay = CoalesceDelayFor(controller.activeState)
    if delay > 0 then
        ScheduleCoalesce(delay)
    else
        ApplyResolvedNow()
    end
end

-- ---------------------------------------------------------------------------
-- Engine state inputs (events + shared sprint watch)
-- ---------------------------------------------------------------------------
local EVENT_NAMESPACE = "BAV_ContextPresets"
-- Sprint sampling lives in SprintWatch (one timer for the whole addon). This
-- module only subscribes while sprint has a non-Off style; the shared poll
-- starts/stops with the subscriber set. Resolved eagerly: SprintWatch loads
-- before ContextPresets in the manifest.
local SprintWatch = addon.SprintWatch
local SPRINT_WATCH_NAME = "ContextPresets"

-- Generic setter: record a physical state flag and re-evaluate if it flipped.
local function SetPhysical(stateId, active)
    active = active and true or false
    if controller.physical[stateId] == active then
        return
    end
    controller.physical[stateId] = active
    Reevaluate()
end

local function OnCombatState(_, inCombat)
    SetPhysical(STATE_COMBAT, inCombat)
end

local function OnStealthState(_, unitTag, stealthState)
    if unitTag ~= "player" then
        return
    end
    -- Treat both "hidden" and "will-be-seen" as stealthed for framing purposes.
    local stealthed = (stealthState == STEALTH_STATE_HIDDEN)
        or (stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED)
    SetPhysical(STATE_STEALTH, stealthed)
end

local function OnMountedState(_, mounted)
    SetPhysical(STATE_MOUNTED, mounted)
end

local function OnWerewolfState(_, werewolf)
    SetPhysical(STATE_WEREWOLF, werewolf)
end

-- Swimming has dedicated enter/exit events (no polling needed): the engine
-- fires EVENT_PLAYER_SWIMMING on entering water and EVENT_PLAYER_NOT_SWIMMING
-- on leaving, so each just flips the physical flag.
local function OnSwimmingState(_)
    SetPhysical(STATE_SWIMMING, true)
end

local function OnNotSwimmingState(_)
    SetPhysical(STATE_SWIMMING, false)
end

-- Interaction/dialogue is bracketed by EVENT_CHATTER_BEGIN (talking to an NPC,
-- quest giver, etc.) and EVENT_CHATTER_END (the conversation closed), so the
-- framing applies for the duration of the chatter window only.
--
-- ENTRY DEBOUNCE: unlike combat or a transformation, a "conversation" is often
-- just a flash -- clicking a merchant, spamming through a quest turn-in -- where
-- chatter begins and ends in a fraction of a second. The coalescer above damps
-- the EXIT of a state, but interaction needs the opposite: its ENTRY must be
-- delayed, or the camera "pecks" on every quick click. So OnChatterBegin does not
-- record the physical flag immediately; it arms a short timer and only commits
-- the interaction state if the conversation is still open when the timer elapses.
-- A chatter that ends inside the window cancels the pending entry, so a fast click
-- never moves the camera at all. This debounce is interaction-only by design:
-- combat/werewolf keep their instant, responsive entry.
local INTERACTION_ENTRY_NAME = "BAV_ContextPresets_InteractionEntry"
local INTERACTION_ENTRY_DEBOUNCE_MS = 250

-- pending gates the one-shot entry timer; nothing runs while idle.
local interactionEntry = {
    pending = false,
}

-- Tear down the entry-debounce timer. Idempotent, so it doubles as the cancel
-- path on chatter-end, disable, and emergency restore.
local function CancelInteractionEntry()
    if interactionEntry.pending then
        EVENT_MANAGER:UnregisterForUpdate(INTERACTION_ENTRY_NAME)
        interactionEntry.pending = false
    end
end

-- One-shot: unregister immediately, then commit the interaction flag now that the
-- conversation has outlasted the debounce window. SetPhysical re-evaluates, so
-- priority still decides whether interaction actually frames the camera.
local function OnInteractionEntryElapsed()
    CancelInteractionEntry()
    SetPhysical(STATE_INTERACTION, true)
end

-- Arm the entry debounce, unless one is already pending or interaction is already
-- physically active (a re-fired begin without an end). The timer fires once after
-- the window and commits the flag.
local function ArmInteractionEntry()
    if interactionEntry.pending or controller.physical[STATE_INTERACTION] then
        return
    end
    interactionEntry.pending = true
    EVENT_MANAGER:RegisterForUpdate(
        INTERACTION_ENTRY_NAME, INTERACTION_ENTRY_DEBOUNCE_MS, OnInteractionEntryElapsed)
end

local function OnChatterBegin(_)
    -- Defer entry: only frame the conversation if it lasts past the debounce, so a
    -- quick merchant click does not peck the camera.
    ArmInteractionEntry()
end

local function OnChatterEnd(_)
    -- Cancel a still-pending entry first: a conversation that ended inside the
    -- debounce window never committed the flag, so this makes the quick-click case
    -- a true no-op (the camera never moved). If the entry already committed (a
    -- real conversation), clear the flag so the camera leaves interaction framing.
    CancelInteractionEntry()
    SetPhysical(STATE_INTERACTION, false)
end

-- Sprint has no dedicated start/stop event, so we sample it via the shared
-- SprintWatch while the feature is enabled AND the sprint state is one the user
-- actually toggled on -- otherwise we never subscribe, keeping overhead at zero
-- for users who do not use it. SprintWatch owns BAV's event-driven action-slot
-- detector and dispatches its canonical state to every subscriber.
local function OnSprintChanged(sprinting)
    SetPhysical(STATE_SPRINT, sprinting)
end

-- Seed states that ESO exposes synchronously before the first evaluation. Event
-- subscriptions only report future changes, so without this a feature enabled
-- while already in combat, mounted, or stealthed would wait for an unrelated
-- state edge before applying. Interaction remains event-driven by design: its
-- entry debounce is part of the chatter workflow.
local function BootstrapPhysicalStates()
    local stealthState = GetUnitStealthState and GetUnitStealthState("player")
    controller.physical[STATE_COMBAT] = IsUnitInCombat and IsUnitInCombat("player") and true or false
    controller.physical[STATE_STEALTH] = (stealthState == STEALTH_STATE_HIDDEN)
        or (stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED)
    controller.physical[STATE_WEREWOLF] = IsPlayerInWerewolfForm
        and IsPlayerInWerewolfForm() and true or false
    controller.physical[STATE_MOUNTED] = IsMounted and IsMounted() and true or false
    controller.physical[STATE_SWIMMING] = IsUnitSwimming and IsUnitSwimming("player") and true or false
    controller.physical[STATE_SPRINT] = (SprintWatch ~= nil and SprintWatch.IsSprinting()) and true or false
end

local function StartSprintPolling()
    if not SprintWatch then
        return
    end
    SprintWatch.Subscribe(SPRINT_WATCH_NAME, OnSprintChanged)
end

local function StopSprintPolling()
    if not SprintWatch then
        SetPhysical(STATE_SPRINT, false)
        return
    end
    -- Unsubscribe first: if we were the last subscriber, SprintWatch stops the
    -- timer and dispatches false (which SetPhysical no-ops if already false).
    -- If other modules remain subscribed we still clear OUR physical flag so a
    -- disabled sprint style never keeps framing from a leftover true.
    SprintWatch.Unsubscribe(SPRINT_WATCH_NAME)
    SetPhysical(STATE_SPRINT, false)
end

-- Subscribe to all state events. Idempotent: EVENT_MANAGER replaces an existing
-- registration for the same (namespace, event) pair, so double-calling is safe.
local function RegisterStateEvents()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_STEALTH_STATE_CHANGED, OnStealthState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED, OnMountedState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_WEREWOLF_STATE_CHANGED, OnWerewolfState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_SWIMMING, OnSwimmingState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_NOT_SWIMMING, OnNotSwimmingState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_CHATTER_BEGIN, OnChatterBegin)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_CHATTER_END, OnChatterEnd)
end

local function UnregisterStateEvents()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_STEALTH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_WEREWOLF_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_CHATTER_END)
end

-- ---------------------------------------------------------------------------
-- Options-window coordination
-- ---------------------------------------------------------------------------
-- While the ESO settings window is open the player may edit the real camera
-- settings (FOV, etc.). But if a preset is active, the LIVE camera shows the
-- preset's values, not the player's -- so editing there would mean editing a
-- masked value, and re-snapshotting the live camera afterward would bake the
-- preset's offsets into the "base" snapshot (compounding every session, the very
-- thing RecoverPersistedSnapshot guards against).
--
-- So we bracket the options window:
--   * OPEN  -> if a preset is overriding the camera, hand the live camera back to
--              the captured snapshot (Apply(snapshot, true): direct write, drops
--              any FOV hold) so the player sees and edits their REAL settings.
--              The capture is kept; only the camera is reverted. Re-evaluation is
--              suspended (OptionsWatch.IsOpen()) so a state change while the menu
--              is up cannot re-apply a preset over what they are editing.
--   * CLOSE -> forget the now-stale snapshot, re-snapshot the (possibly edited)
--              live camera as the fresh base, then re-resolve and re-apply the
--              active state on top of it.
-- The fragment is the options window specifically (not the ESC menu), so this
-- never fires for the in-game system menu. The open/closed lifecycle is owned by
-- the shared OptionsWatch; these are just the payload. The controller only
-- subscribes while enabled (SetEnabled), so the old `not controller.enabled`
-- guards are now structural -- a disabled controller is not subscribed at all.
local OPTIONS_WATCH_NAME = "ContextPresets"
local optionsExternalFrozen = false

local function OnOptionsOpened()
    -- Stop any in-flight transition/coalesce so nothing re-applies a preset while
    -- the player is editing the real settings.
    StopTransition()
    CancelCoalesce()
    CancelInteractionEntry()

    optionsExternalFrozen = externalProfile.source ~= nil
        and type(externalProfile.bundle) == "table"
        and rawget(externalProfile.bundle, "freezeInMenus") == true
    if optionsExternalFrozen then
        LogDebug("ContextPresets: options opened, freezing external profile")
        return
    end

    -- Only revert the camera if a preset is actually overriding it (a snapshot
    -- exists). At default state there is nothing masking the real settings.
    if ContextPresets.HasCapture(RESTORE_SLOT) then
        LogDebug("ContextPresets: options opened, reverting to snapshot for editing")
        ContextPresets.Apply(slots[RESTORE_SLOT], true)
    end
end

local function OnOptionsClosed()
    if optionsExternalFrozen then
        optionsExternalFrozen = false
        LogDebug("ContextPresets: options closed, resolving frozen external profile")
        if controller.ready then
            local resolved = controller.enabled and ResolveActiveState() or STATE_DEFAULT
            ApplyState(resolved, true, true)
        else
            Reevaluate()
        end
        if not controller.enabled and externalProfile.source == nil then
            OptionsWatch.Unsubscribe(OPTIONS_WATCH_NAME)
        end
        return
    end

    -- The player may have changed the real camera settings. Drop the stale
    -- pre-edit snapshot WITHOUT restoring it (restoring would write the old values
    -- back over the player's fresh edits), then force the active state to be
    -- recomputed: the next ApplyState re-snapshots the edited live camera as the
    -- new base and layers the preset on top of it.
    LogDebug("ContextPresets: options closed, re-snapshotting base and re-applying")
    ContextPresets.ClearCapture(RESTORE_SLOT)
    PersistRestoreSnapshot(nil)
    controller.activeState = STATE_DEFAULT
    Reevaluate()
    if not controller.enabled and externalProfile.source == nil then
        OptionsWatch.Unsubscribe(OPTIONS_WATCH_NAME)
    end
end

-- ---------------------------------------------------------------------------
-- Public controller API (wired to SavedVariables by Settings.lua)
-- ---------------------------------------------------------------------------

-- Returns true while the controller is actively managing the camera.
function ContextPresets.IsEnabled()
    return controller.enabled
end

-- Returns the currently active state id (STATE_DEFAULT when idle/disabled).
function ContextPresets.GetActiveState()
    return controller.activeState
end

-- Stop an in-flight spatial glide without landing it. OffsetNudge uses this so
-- a hold-to-nudge bind is not fighting a 250 ms preset transition. When the
-- interrupted glide was a restore, the live horizontal/vertical offsets are
-- copied into the snapshot so the player's seen framing becomes the new base
-- for those axes. An interrupted apply leaves the original player snapshot
-- intact -- the live camera is mid-preset, and OffsetNudge then deltas both.
function ContextPresets.InterruptTransition()
    if not Ease.IsActive(TRANSITION_UPDATE_NAME) then
        return false
    end

    if transitionIsRestore then
        local snapshot = slots[RESTORE_SLOT]
        if type(snapshot) == "table" then
            local horizontal, hasHorizontal = CameraSettings.Get("horizontalOffset")
            if hasHorizontal then
                snapshot.horizontalOffset = horizontal
            end
            local vertical, hasVertical = CameraSettings.Get("verticalOffset")
            if hasVertical then
                snapshot.verticalOffset = vertical
            end
        end

        local clears = transitionClearsRestoreSnapshot
        local target = snapshot or transitionTarget
        StopTransition()
        if type(target) == "table" then
            local _, failed = ContextPresets.Apply(target, true)
            if clears and failed == 0 then
                ContextPresets.ClearCapture(RESTORE_SLOT)
                PersistRestoreSnapshot(nil)
            elseif clears then
                PersistRestoreSnapshot(snapshot)
            end
        end
        return true
    end

    StopTransition()
    return true
end

-- Shift one restore-snapshot axis by a live delta. Used while OffsetNudge is
-- writing the camera so leaving the preset does not rewind the nudge. Skipped
-- while the options window is open: that path already shows the real camera
-- and re-snapshots it on close. Does not persist; FlushRestoreSnapshot does.
function ContextPresets.AdjustRestoreOffset(key, delta)
    if OptionsWatch.IsOpen() then
        return false
    end
    local snapshot = slots[RESTORE_SLOT]
    if type(snapshot) ~= "table" then
        return false
    end
    delta = tonumber(delta)
    if delta == nil or snapshot[key] == nil then
        return false
    end
    snapshot[key] = snapshot[key] + delta
    return true
end

-- Write one restore-snapshot axis to an absolute value (recenter). Same
-- options-window and persistence rules as AdjustRestoreOffset.
function ContextPresets.SetRestoreOffset(key, value)
    if OptionsWatch.IsOpen() then
        return false
    end
    local snapshot = slots[RESTORE_SLOT]
    if type(snapshot) ~= "table" then
        return false
    end
    value = tonumber(value)
    if value == nil then
        return false
    end
    snapshot[key] = value
    return true
end

-- Persist the in-memory restore snapshot. OffsetNudge calls this when a hold
-- ends so a mid-nudge /reloadui still recovers the player's real framing.
function ContextPresets.FlushRestoreSnapshot()
    local snapshot = slots[RESTORE_SLOT]
    if type(snapshot) ~= "table" then
        return false
    end
    PersistRestoreSnapshot(snapshot)
    return true
end

-- Read one axis from the pre-preset snapshot, or nil when no snapshot is live.
-- OffsetNudge uses this so "remember home" stores the player's real framing
-- rather than a cinematic bundle currently sitting on the camera.
function ContextPresets.GetRestoreOffset(key)
    local snapshot = slots[RESTORE_SLOT]
    if type(snapshot) ~= "table" then
        return nil
    end
    return tonumber(snapshot[key])
end

-- Request a temporary profile from a detector module while keeping camera
-- ownership inside ContextPresets. `stateId` must be stable for one logical
-- profile (for example "detector:engaged"); changing it triggers a normal state
-- transition. The bundle uses the same offset/target fields as STATE_BUNDLES.
function ContextPresets.SetExternalProfile(source, stateId, bundle, force)
    if type(source) ~= "string" or source == ""
        or type(stateId) ~= "string" or stateId == ""
        or type(bundle) ~= "table" then
        return false
    end

    if externalProfile.source ~= nil and externalProfile.source ~= source then
        LogWarn("ContextPresets.SetExternalProfile: '%s' rejected; '%s' owns the external profile",
            source, externalProfile.source)
        return false
    end

    externalProfile.source = source
    externalProfile.stateId = stateId
    externalProfile.bundle = bundle
    externalProfile.failed = 0
    if not controller.enabled then
        OptionsWatch.Subscribe(OPTIONS_WATCH_NAME, {
            onOpen  = OnOptionsOpened,
            onClose = OnOptionsClosed,
        })
    end
    -- While the settings window is open the live camera intentionally shows the
    -- player's unmasked base values. Keep the new external bundle, but defer its
    -- actual write until OnOptionsClosed re-snapshots and re-evaluates; applying
    -- here would bake profile values into the next restore baseline.
    if OptionsWatch.IsOpen() then
        return true
    end
    if force and controller.ready and controller.activeState == stateId then
        local snapshot = slots[RESTORE_SLOT]
        local preset = ResolveBundle(stateId, snapshot)
        if preset ~= nil then
            StopTransition()
            if rawget(bundle, "instant") then
                local _, failed = ContextPresets.Apply(preset, false)
                externalProfile.failed = failed
            else
                StartTransition(preset, false)
            end
        end
    else
        Reevaluate()
    end
    return true
end

-- Release an external profile. Only its owner may clear it. The controller then
-- resolves the next normal state, or restores the player's base camera when no
-- other state applies.
function ContextPresets.ClearExternalProfile(source, instant)
    if externalProfile.source == nil then
        return false
    end
    if externalProfile.source ~= source then
        LogWarn("ContextPresets.ClearExternalProfile: '%s' cannot clear profile owned by '%s'",
            tostring(source), externalProfile.source)
        return false
    end

    externalProfile.source = nil
    externalProfile.stateId = nil
    externalProfile.bundle = nil
    externalProfile.failed = 0

    -- The live camera already shows the player's base while Options is open.
    -- Defer restore/ordinary-preset resolution until OnOptionsClosed, otherwise
    -- a disable/de-escalation from LAM could write over camera edits or leave a
    -- restore transition running after the panel closes.
    if OptionsWatch.IsOpen() then
        return true
    end

    if not controller.enabled then
        OptionsWatch.Unsubscribe(OPTIONS_WATCH_NAME)
    end

    if controller.ready then
        local resolved = controller.enabled and ResolveActiveState() or STATE_DEFAULT
        if resolved ~= controller.activeState then
            ApplyState(resolved, instant)
        end
    end
    return true
end

function ContextPresets.IsExternalProfileActive(source)
    return externalProfile.source ~= nil
        and (source == nil or externalProfile.source == source)
end

function ContextPresets.GetExternalProfileFailureCount(source)
    if externalProfile.source == nil
        or (source ~= nil and externalProfile.source ~= source) then
        return 0
    end
    return externalProfile.failed or 0
end

-- Adopt a manual distance as the player's new restore baseline while an
-- external profile is active. This lets a detector cede zoom to the player
-- without the eventual profile release restoring the older pre-PvP distance.
function ContextPresets.UpdateExternalBaseDistance(source, distance)
    if externalProfile.source == nil or externalProfile.source ~= source then
        return false
    end

    distance = tonumber(distance)
    local snapshot = slots[RESTORE_SLOT]
    if distance == nil or type(snapshot) ~= "table" then
        return false
    end

    snapshot[DISTANCE_KEY] = distance
    PersistRestoreSnapshot(snapshot)
    return true
end

-- Return the player's captured pre-preset distance while a preset override is
-- live. Core persistence uses this instead of the camera's current distance so
-- preset offsets cannot become the next session's normal currentZoom.
function ContextPresets.GetBaseZoomForPersistence()
    local snapshot = slots[RESTORE_SLOT]
    if type(snapshot) ~= "table" then
        return nil
    end
    return tonumber(snapshot[DISTANCE_KEY])
end

-- Returns the list of selectable style ids in display order, so the settings
-- panel can build its per-state dropdowns without hardcoding the same list
-- (keeping ContextPresets the single source of truth for what styles exist).
function ContextPresets.GetStyleIds()
    local copy = {}
    for i = 1, #STYLE_IDS do
        copy[i] = STYLE_IDS[i]
    end
    return copy
end

-- The style id meaning "disabled" -- exposed so Settings can treat it as the
-- neutral choice without hardcoding the string.
function ContextPresets.GetOffStyleId()
    return STYLE_OFF
end

-- Turn the whole feature on or off. Turning OFF unregisters every event, stops
-- sprint polling, restores the player's snapshot, and clears runtime state so
-- the module touches nothing further. Turning ON registers events and does an
-- immediate evaluation so the correct bundle applies without waiting for the
-- next state change.
local function SetEnabled(enabled)
    enabled = enabled and true or false
    if enabled == controller.enabled then
        return false
    end

    if enabled then
        controller.enabled = true
        RegisterStateEvents()
        OptionsWatch.Subscribe(OPTIONS_WATCH_NAME, {
            onOpen  = OnOptionsOpened,
            onClose = OnOptionsClosed,
        })
        -- Sprint polling only runs when sprint has a non-Off style selected.
        if StyleForState(STATE_SPRINT) ~= STYLE_OFF then
            StartSprintPolling()
        end
        -- Before the first EVENT_PLAYER_ACTIVATED Reevaluate is gated by
        -- controller.ready, so no snapshot or camera write can happen before
        -- persisted recovery and saved-zoom restoration complete.
        if controller.ready then
            BootstrapPhysicalStates()
            Reevaluate()
        end
    else
        -- Tear down in the reverse order, then put the camera back. Turning the
        -- feature off should hand the camera back IMMEDIATELY, not over a glide:
        -- cancel any in-flight transition and restore instantly. (ApplyState here
        -- would start a glide that runs after enabled=false -- wrong UX and a
        -- false "glide while disabled" signal.)
        UnregisterStateEvents()
        StopSprintPolling()
        StopTransition()
        CancelCoalesce()
        CancelInteractionEntry()
        controller.physical = {}
        controller.enabled = false

        local hasExternalProfile = externalProfile.stateId ~= nil
            and type(externalProfile.bundle) == "table"
        if not hasExternalProfile then
            OptionsWatch.Unsubscribe(OPTIONS_WATCH_NAME)
            RestoreAndForget()
            controller.activeState = STATE_DEFAULT
        end
    end

    return true
end

-- Apply a configuration table, typically mirrored from SavedVariables:
--   enabled       boolean
--   intensity     number 0..1
--   smooth        boolean -- ease state transitions (spatial + FOV glide) when
--                  true; snap instantly when false.
--   states        { combat=<style>, werewolf=<style>, ... } where each value is
--                  a style id ("off"/"subtle"/"cinematic"/"action").
--   stateIntensities { combat=<0..1>, werewolf=<0..1>, ... } per-state multiplier
--                  layered on top of the global intensity and the state's style
--                  strength. A missing entry is treated as 1.0 (no attenuation).
--   stateCoalesce { combat=<ms>, werewolf=<ms>, ... } per-state release delay in
--                  milliseconds: how long leaving that state is deferred so a fast
--                  out-and-back collapses to a no-op. A missing entry is treated as
--                  0 (release immediately, no coalescing).
-- Unspecified fields are left unchanged. Safe to call repeatedly; it diffs and
-- only re-evaluates when something that affects the active state changed.
function ContextPresets.Configure(options)
    options = options or {}

    if options.intensity ~= nil then
        controller.intensity = Clamp(tonumber(options.intensity) or controller.intensity, 0, 1)
    end

    if options.smooth ~= nil then
        controller.smooth = options.smooth and true or false
    end

    if type(options.states) == "table" then
        for _, stateId in ipairs(STATE_PRIORITY) do
            local choice = options.states[stateId]
            if choice ~= nil then
                controller.stateStyles[stateId] = NormalizeStyle(choice)
            end
        end
        -- Sprint polling must follow the sprint style while already enabled.
        if controller.enabled then
            if StyleForState(STATE_SPRINT) ~= STYLE_OFF then
                StartSprintPolling()
            else
                StopSprintPolling()
            end
        end
    end

    if type(options.stateIntensities) == "table" then
        for _, stateId in ipairs(STATE_PRIORITY) do
            local value = options.stateIntensities[stateId]
            if value ~= nil then
                controller.stateIntensities[stateId] = Clamp(tonumber(value) or 1.0, 0, 1)
            end
        end
    end

    if type(options.stateCoalesce) == "table" then
        for _, stateId in ipairs(STATE_PRIORITY) do
            local value = options.stateCoalesce[stateId]
            if value ~= nil then
                local ms = tonumber(value) or 0
                if ms < 0 then ms = 0 end
                controller.stateCoalesceMs[stateId] = ms
            end
        end
    end

    local enabledChanged = false
    if options.enabled ~= nil then
        enabledChanged = SetEnabled(options.enabled)
    end

    if not enabledChanged and controller.enabled and not OptionsWatch.IsOpen() then
        -- Re-apply with possibly-new intensity / styles. Resetting activeState to
        -- default makes any genuinely-active state an escalation, so Reevaluate
        -- applies it immediately rather than deferring it as a release.
        controller.activeState = STATE_DEFAULT  -- force ApplyState to recompute
        RestoreAndForget()
        Reevaluate()
    end

    LogDebug("ContextPresets.Configure: enabled=%s intensity=%.2f",
        tostring(controller.enabled), controller.intensity)
end

-- Emergency recovery: forcibly hand the camera back to the player, no matter
-- what state the module is in. This is the LAM "restore camera" panic button,
-- meant for the case where a preset or FOV hold got stuck (e.g. a failed apply,
-- an orphaned hold, or a state event the client never fired the "off" side of).
--
-- Steps, ordered so the camera ends up under the player's control:
--   1. Force-release any FOV hold, ignoring ownership, so dynamic/manual FOV is
--      free again even if the owning source never released it.
--   2. Restore the player's captured pre-preset snapshot if one exists, putting
--      their own framing back exactly; then forget the slot.
--   3. Reset runtime state to default so the next Reevaluate starts clean.
--
-- It deliberately does NOT change the user's saved toggles or disable the
-- feature: it recovers the camera, then lets normal evaluation resume. Returns
-- true if it had anything to undo (a hold or a stored snapshot), false if the
-- camera was already in the player's hands.
function ContextPresets.EmergencyRestore()
    local didSomething = false

    -- Cancel any in-flight transition glide FIRST. Its self-tearing updater would
    -- otherwise keep easing spatial keys frame-by-frame and fight the recovery
    -- we are about to do. StopTransition is idempotent, so this is a no-op when
    -- nothing is gliding.
    StopTransition()

    -- Drop any pending coalesce timer too, or it would fire after the panic
    -- restore and re-apply a state we just handed back.
    CancelCoalesce()
    -- Same for a pending interaction entry: it would otherwise commit the
    -- interaction flag after the panic restore and re-frame the camera.
    CancelInteractionEntry()

    local arbiter = addon.FovArbiter
    if arbiter and arbiter.ForceRelease() then
        didSomething = true
    end

    local presetRestored = true
    if ContextPresets.HasCapture(RESTORE_SLOT) then
        presetRestored = RestoreAndForget()
        didSomething = true
    end
    if not ContextPresets.HasCapture(RESTORE_SLOT) then
        PersistRestoreSnapshot(nil)
    end

    -- ForceRelease deliberately does not reassert an FOV owner because this
    -- emergency path restores the preset snapshot afterward. Once that restore
    -- has succeeded, let a disabled Dynamic FOV return its persisted manual FOV
    -- last. If preset recovery was incomplete, retain both snapshots for retry.
    local dynamicFov = addon.DynamicFov
    if presetRestored and dynamicFov and dynamicFov.OnHoldReleased then
        dynamicFov.OnHoldReleased()
    end

    -- Drop runtime state so a still-enabled controller re-applies from scratch
    -- rather than thinking it is mid-transition.
    controller.activeState = STATE_DEFAULT
    controller.physical = {}
    externalProfile.source = nil
    externalProfile.stateId = nil
    externalProfile.bundle = nil
    externalProfile.failed = 0
    if not controller.enabled then
        OptionsWatch.Unsubscribe(OPTIONS_WATCH_NAME)
    end

    LogInfo("ContextPresets.EmergencyRestore: camera handed back to player (changed=%s)",
        tostring(didSomething))

    -- If the feature is still on, let it re-evaluate so any genuinely-active
    -- state re-applies cleanly on the next engine event.
    if controller.enabled then
        Reevaluate()
    end

    return didSomething
end

-- ---------------------------------------------------------------------------
-- Load-time recovery
-- ---------------------------------------------------------------------------
-- Call ONCE after the player is in the world (EVENT_PLAYER_ACTIVATED), BEFORE
-- the controller is allowed to capture anything. If the previous session ended
-- while a preset was overriding the camera, the engine settings still hold the
-- preset's values and Settings has the player's real pre-preset snapshot. Write
-- that snapshot straight back (isRestore=true: direct write, no FOV re-pin),
-- then clear the persisted copy so a clean session starts from the player's own
-- framing. Without this, the controller would snapshot the dirty values and
-- treat them as the new baseline -- the offsets would compound every session.
--
-- No-op when nothing was persisted (the normal case). One-shot per session:
-- guarded by controller.recovered so a later zone change (which also fires
-- EVENT_PLAYER_ACTIVATED) cannot tear down a preset that legitimately became
-- active during THIS session and re-persisted its own snapshot.
function ContextPresets.RecoverPersistedSnapshot()
    if controller.recovered then
        return false
    end
    controller.recovered = true

    local settings = addon.Settings
    if not (settings and settings.GetPresetRestoreSnapshot) then
        return false
    end

    local snapshot = settings.GetPresetRestoreSnapshot()
    if type(snapshot) ~= "table" then
        return false
    end

    LogInfo("ContextPresets.RecoverPersistedSnapshot: restoring camera left overridden by a preset last session")
    local _, failed = ContextPresets.Apply(snapshot, true)
    if failed ~= 0 then
        LogWarn("ContextPresets.RecoverPersistedSnapshot: restore incomplete; retaining persisted snapshot")
        return false
    end

    -- Forget it everywhere: the in-memory slot must not start out thinking it
    -- holds a capture, and the persisted copy has served its purpose.
    ContextPresets.ClearCapture(RESTORE_SLOT)
    PersistRestoreSnapshot(nil)
    return true
end

-- Complete the one-time startup sequence after the core restored saved zoom.
-- Configure may enable this controller before EVENT_PLAYER_ACTIVATED, but it
-- must stay inert until any persisted pre-preset snapshot is restored and the
-- player's saved zoom is back in place; otherwise the base snapshot ApplyState
-- takes could preserve the previous session's preset framing as the new base.
function ContextPresets.ActivateAfterRecovery()
    if controller.ready then
        return false
    end

    controller.ready = true
    if controller.enabled then
        BootstrapPhysicalStates()
    end
    if controller.enabled or externalProfile.stateId ~= nil then
        Reevaluate()
    end
    return true
end

-- Re-pin the currently-active preset's framing onto the live camera, instantly.
-- ---------------------------------------------------------------------------
-- EVENT_PLAYER_ACTIVATED fires on every zone change, not just login, and the
-- engine resets the camera (zoom, FOV, offsets) across the load screen. The
-- core's OnPlayerActivated re-applies the player's saved ZOOM, but the physical
-- state flags survive a zone change WITHOUT re-firing their events -- so a
-- preset that was active before the load (e.g. combat) never re-runs ApplyState
-- and its framing is left stomped by the restored base zoom (and the wiped
-- FOV/offsets stay wiped). This hands distance/FOV/offsets back to the active
-- preset so its framing survives the zone change.
--
-- Instant (no glide): we are coming off a load screen, so the preset framing
-- should already be in place when the world fades in, not ease in afterward.
-- No-op when the controller is disabled, idle at the default state, or has no
-- snapshot to resolve the bundle against -- so it is free for users who never
-- enabled presets and never fights the normal (default-state) zoom restore.
function ContextPresets.ReassertActive()
    if not controller.enabled and externalProfile.stateId == nil then
        return false
    end

    local stateId = controller.activeState
    if stateId == STATE_DEFAULT then
        return false
    end

    local snapshot = slots[RESTORE_SLOT]
    local preset = ResolveBundle(stateId, snapshot)
    if not preset then
        return false
    end

    -- Cancel any in-flight glide and snap the resolved bundle back exactly.
    -- isRestore=false so FOV re-pins through the arbiter hold, matching what the
    -- original ApplyState established for this state.
    StopTransition()
    LogDebug("ContextPresets.ReassertActive: re-pinning state '%s' after activation", stateId)
    local _, failed = ContextPresets.Apply(preset, false)
    if stateId == externalProfile.stateId then
        externalProfile.failed = failed
    end
    return true
end

-- Shoulder ownership handoff (called by ShoulderControl on every mode change).
-- ---------------------------------------------------------------------------
-- Snapshot() and Apply() cede shoulder while ShoulderControl owns it, so the
-- captured base snapshot's shoulder entry is only valid for the ownership state
-- it was taken under. A mid-session mode change therefore has to fix the
-- snapshot up, or shoulder leaks:
--   * ownership TAKEN (off -> auto/manual) while a preset is active: our
--     snapshot carries the player's shoulder, but we will never restore it
--     (Apply skips shoulder from now on). Hand it back immediately -- while we
--     still own the property, and BEFORE ShoulderControl captures its own base,
--     so that base is the player's real shoulder and not a preset's OTS value --
--     then drop the key from the snapshot (memory + persisted).
--   * ownership RELEASED (auto/manual -> off) while a preset is active: our
--     snapshot has NO shoulder (it was skipped at capture time) yet the preset
--     bundle is about to start writing shoulder again -- so a later return to
--     default would leave the OTS-shaped value baked in. ShoulderControl has
--     already restored the player's own shoulder by this point, so adopt the
--     live value as the snapshot's shoulder base and re-assert the active state
--     so its bundle applies shoulder from a known baseline.
-- ownedExternally is passed explicitly because ShoulderControl calls this around
-- its own mode assignment, when OwnsShoulder() would still report the old value.
function ContextPresets.NotifyShoulderOwnershipChanged(ownedExternally)
    if not CameraSettings.IsSupported(SHOULDER_KEY) then
        return false
    end

    local snapshot = slots[RESTORE_SLOT]
    if snapshot == nil then
        -- No preset is overriding the camera, so there is no snapshot to fix up;
        -- the next capture is taken under the new ownership and is correct.
        return false
    end

    if ownedExternally then
        if snapshot[SHOULDER_KEY] == nil then
            return false
        end
        LogDebug("ContextPresets: shoulder ownership taken externally; returning %.2f and dropping it from the snapshot",
            snapshot[SHOULDER_KEY])
        CameraSettings.Set(SHOULDER_KEY, snapshot[SHOULDER_KEY])
        snapshot[SHOULDER_KEY] = nil
        PersistRestoreSnapshot(snapshot)
        return true
    end

    if snapshot[SHOULDER_KEY] == nil then
        local value, ok = CameraSettings.Get(SHOULDER_KEY)
        if ok and value ~= nil then
            LogDebug("ContextPresets: shoulder ownership released; adopting %.2f as the snapshot base", value)
            snapshot[SHOULDER_KEY] = value
            PersistRestoreSnapshot(snapshot)
        end
    end
    ContextPresets.ReassertActive()
    return true
end
