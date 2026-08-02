-- =============================================================================
-- Under Pressure -- main entry
-- =============================================================================
-- Lifecycle:
--   1. EVENT_ADD_ON_LOADED for this addon
--   2. Load saved variables (migrating the pre-0.2.8 raw-global layout)
--   3. Run feature detection
--   4. Init classifier, UI, debug, settings
--   5. Register event listeners
--   6. Start the engine tick loop and the (slower) UI refresh loop
--
-- TIMERS: there are two, deliberately at different rates.
--   * UnderPressure_Tick    -- 10 Hz, the pressure model. State changes push
--                              to the UI immediately from inside the engine.
--   * UnderPressure_UIRefresh -- 5 Hz, the attacker counter and debug overlay.
--                              Neither needs 10 Hz: the counter moves on a
--                              1-5 second window, and the overlay is a
--                              read-out. Halving that work matters on console,
--                              where the frame budget is shared across every
--                              installed addon.
--
-- Through 0.2.8 development this was one timer: the main file replaced
-- UP.Engine.Tick with a closure that called the original and then refreshed
-- the UI. That was removed. It welded both jobs to one rate, split the
-- per-frame path across two files, and created a silent ordering trap --
-- RegisterForUpdate captures whatever UP.Engine.Tick points at when Start()
-- is called, so moving Start() earlier would have left the engine ticking
-- correctly while the counter and overlay quietly froze, with no error.
-- =============================================================================

UP = UP or {}
UP.name    = "UnderPressure"
-- Keep in sync with ## Version in UnderPressure.addon. Through 0.2.7 the
-- version string lived in three places and disagreed four ways; as of 0.3.3
-- there are two, because Settings.lua now READS UP.version for the settings
-- panel header rather than carrying its own copy.
UP.version = "0.3.3"
-- Read by Settings.lua for the console settings header (LibHarvensAddonSettings
-- displays panel.author but never sets it). Matches ## Author in the manifest.
UP.author  = "Th3rtythr33"

local DEFAULT_SAVED = {
    hidden        = false,
    offset_x      = 0,
    offset_y      = -140,
    scale         = 1.0,
    debug         = false,
    show_counter  = true,
    -- Silence ring (0.3.0). Independent of `hidden`, which is the Threat
    -- Indicator's master toggle -- see UI/SilenceRing.lua for why.
    silence_ring  = true,
    tunables      = {},
    abilityOverrides   = {},
    riskBonusOverrides = {},
    -- attacker_mode ("solo" / "tank") was removed in 0.2.9 with Tank mode
    -- itself. Any stored value is cleared once on upgrade -- see
    -- pruneRemovedSettings below.
}

-- Settings whose UI control was removed in 0.2.9. A stored override for one of
-- these is worse than useless: the engine still reads it every tick, but the
-- user has no control left to see it, change it, or reset it -- so a slider
-- someone nudged in 0.2.8 would silently govern their indicator forever. The
-- point of removing the controls was that the defaults are tuned, so clear the
-- overrides once and let everyone land on them.
--
-- A settings library's reset-to-defaults would normally have covered this, but
-- it only resets controls that still exist in the options table. True of LAM's
-- registerForDefaults through 0.3.2 and equally true of LibHarvensAddonSettings'
-- allowDefaults since 0.3.3, which iterates its own settings list.
local REMOVED_TUNABLES = {
    "weight_1s", "weight_2s", "weight_3s", "weight_6s",
    "burst_multiplier", "effect_weight", "pressure_floor",
    "state_persistence_ms",
}

-- Saved-variable SCHEMA version. Deliberately unrelated to the addon version
-- above -- it identifies the shape of stored data, nothing else. Bump it when
-- the SHAPE or MEANING of a stored value changes, and add a migration step
-- below; not for adding new keys, which the defaults table already handles.
--
-- Do NOT renumber it to "tidy it up". ZO_SavedVars resets to defaults when it
-- finds a different version than the one stored, so any change here wipes
-- user settings. It reads 3 because the release was briefly planned as 3.0;
-- leaving it alone is free, changing it is not.
local SAVED_VARS_VERSION = 3

-- ---------------------------------------------------------------------------
-- Saved variables
-- ---------------------------------------------------------------------------
-- Pre-3.0 wrote settings as bare keys on the global UnderPressureSavedVars
-- table, with a hand-rolled recursive default merge. That persisted fine but
-- had no version field and so no migration path. 0.2.8 moves to ZO_SavedVars,
-- which supplies versioning, default merging, and a migration hook.
--
-- ZO_SavedVars must be constructed inside EVENT_ADD_ON_LOADED or the file
-- does not actually persist (documented in ZOS's own zo_savedvars.lua).
--
-- Account-wide rather than per-character: these are HUD preferences, and
-- users with several tanks would otherwise have to retune each one.

-- Drop stored values for settings whose control no longer exists. Guarded by
-- its own flag rather than SAVED_VARS_VERSION: bumping the version resets the
-- WHOLE file to defaults, which would throw away the user's position, scale and
-- TTD thresholds to clean up a handful of orphaned keys.
local function pruneRemovedSettings()
    if UP.sv.pruned_0_2_9 then return end

    local tunables = UP.sv.tunables
    if type(tunables) == "table" then
        for _, key in ipairs(REMOVED_TUNABLES) do
            tunables[key] = nil
        end
    end
    UP.sv.attacker_mode = nil

    UP.sv.pruned_0_2_9 = true
    -- Cached in the engine, and this runs before the first tick, but clearing
    -- it costs nothing and does not depend on that ordering staying true.
    if UP.Engine and UP.Engine.MarkTunablesDirty then
        UP.Engine.MarkTunablesDirty()
    end
end

local function loadSavedVars()
    -- Detect the pre-0.2.8 layout before ZO_SavedVars restructures the global.
    -- A ZO_SavedVars-managed table has a "Default" key at the top; a legacy
    -- one has our own setting keys there instead.
    local legacy = nil
    local existing = UnderPressureSavedVars
    if type(existing) == "table" and existing.Default == nil then
        -- attacker_mode is listed as a RECOGNISER for the old layout, not as a
        -- live setting -- it was removed in 0.2.9, but a pre-0.2.8 file still
        -- has it, and its presence is evidence about the file's shape.
        if existing.attacker_mode ~= nil or existing.tunables ~= nil
           or existing.offset_y ~= nil or existing.scale ~= nil then
            legacy = existing
        end
        -- Clear it either way: a non-empty table in an unrecognised shape
        -- would otherwise be reinterpreted as ZO_SavedVars' own structure.
        UnderPressureSavedVars = nil
    end

    UP.sv = ZO_SavedVars:NewAccountWide("UnderPressureSavedVars",
                                        SAVED_VARS_VERSION, nil, DEFAULT_SAVED)

    -- Carry pre-0.2.8 settings across exactly once. Only keys we recognise are
    -- copied, so anything stale in an old file is dropped rather than
    -- resurrected.
    if legacy and not UP.sv.migrated_from_legacy then
        for k, v in pairs(DEFAULT_SAVED) do
            local old = legacy[k]
            if old ~= nil then
                if type(v) == "table" and type(old) == "table" then
                    for subK, subV in pairs(old) do UP.sv[k][subK] = subV end
                elseif type(old) == type(v) then
                    UP.sv[k] = old
                end
            end
        end
        UP.sv.migrated_from_legacy = true
        UP.Note("Settings migrated from the pre-0.2.8 format.")
    end

    pruneRemovedSettings()
end

-- ---------------------------------------------------------------------------
-- UI refresh loop (see the TIMERS note at the top of this file)
-- ---------------------------------------------------------------------------
local UI_REFRESH_NAMESPACE = "UnderPressure_UIRefresh"
local UI_REFRESH_MS = 200   -- 5 Hz

local function refreshUI()
    -- One clock read for the whole pass. Attackers.Counts memoises on this
    -- timestamp and Debug.Refresh reads that memo via Snapshot, so Counts must
    -- stay ahead of Refresh here.
    local nowMs = GetGameTimeMilliseconds()

    if UP.UI and UP.UI.SetCounter and UP.Attackers and UP.Attackers.Counts then
        UP.UI.SetCounter(UP.Attackers.Counts(nowMs) or 0)
    end

    -- Failsafe sweep only. The silence ring normally appears and disappears on
    -- events; this catches a FADED that never arrived. See SilenceTracker.
    if UP.Silence and UP.Silence.Expire then UP.Silence.Expire(nowMs) end

    if UP.Debug and UP.Debug.Refresh then UP.Debug.Refresh() end
end

local function onAddOnLoaded(eventCode, addonName)
    if addonName ~= UP.name then return end
    EVENT_MANAGER:UnregisterForEvent(UP.name, EVENT_ADD_ON_LOADED)

    -- Saved variables
    loadSavedVars()

    -- Feature detection runs first; EventIngest and the classifier consult
    -- its results. No longer a pass/fail gate -- the only fatal capability
    -- (gameTime) is now an assumption rather than a probe. See APIAUDITS.md.
    UP.RunFeatureDetect()

    -- Classifier needs access to override tables in saved vars
    UP.Classifier.init(UP.sv)

    -- UI
    if not UP.UI.Init() then return end
    -- Not fatal if it fails: the silence ring disables itself and the rest of
    -- the addon carries on. Its initial state is seeded by the Resync below.
    UP.SilenceRing.Init()
    UP.Debug.Init()
    UP.Debug.SetVisible(UP.sv.debug or false)

    -- Settings panel
    UP.Settings.Init()

    -- Event ingestion
    UP.Ingest.Register()

    -- Seed silence state by reading the player's current buffs.
    -- EVENT_EFFECT_CHANGED does not replay for effects that are already active,
    -- so without this a /reloadui mid-silence would leave the ring off for the
    -- rest of the duration -- the same failure shape as the combat-state seeding
    -- below. Must run AFTER SilenceRing.Init so there is a UI to publish to.
    UP.Silence.Resync()

    -- Seed combat state. EVENT_PLAYER_COMBAT_STATE only fires on a CHANGE, so
    -- without this the addon believes it is out of combat until the next
    -- transition -- meaning a /reloadui mid-fight left the indicator hidden
    -- under default settings. Alive state is seeded separately in UP.UI.Init.
    if type(IsUnitInCombat) == "function" then
        local ok, inCombat = pcall(IsUnitInCombat, "player")
        if ok then
            UP.Engine.SetCombatState(inCombat == true)
            UP.UI.SetInCombat(inCombat == true)
        end
    end

    -- Engine loop (10 Hz) and UI refresh loop (5 Hz). Independent namespaces,
    -- independent rates -- neither wraps the other.
    UP.Engine.Start()
    EVENT_MANAGER:RegisterForUpdate(UI_REFRESH_NAMESPACE, UI_REFRESH_MS, refreshUI)

    -- Slash commands
    SLASH_COMMANDS["/updebug"] = function()
        if UP.Debug and UP.Debug.Toggle then
            UP.Debug.Toggle()
            UP.sv.debug = not UP.sv.debug
        end
    end

    -- Shows the silence ring for 10s without needing something to actually
    -- silence you. Registered here rather than at file scope (as /up-api-audit
    -- is) because it needs UP.SilenceRing.Init to have run -- and unlike the
    -- audit, there is no value in it working after a failed startup.
    --
    -- This prints one line to chat. The standing rule is no chat output unless
    -- the user asks for it; typing the command IS asking, same as
    -- /up-api-audit. A test command that gave no acknowledgement would be
    -- indistinguishable from one that failed to register.
    local function runVisualTest()
        if UP.SilenceRing and UP.SilenceRing.RunVisualTest and UP.SilenceRing.RunVisualTest() then
            d(("|cFFD700[Under Pressure]|r silence ring shown for %ds (visual test)."):format(
                (UP.SilenceRing.TestDurationMs() or 10000) / 1000))
        else
            d("|cFF4040[Under Pressure]|r silence ring unavailable; nothing to show.")
        end
    end
    SLASH_COMMANDS["/up-visual-test"] = runVisualTest

    -- "/up" was removed in 0.3.3 along with LibAddonMenu. LAM registered it
    -- itself from panelData.slashCommand; LibHarvensAddonSettings has no
    -- slash-command concept at all, and its console entry point is the gamepad
    -- Main Menu > Add-Ons. Re-adding a command that only printed directions
    -- would be worse than nothing on console, where typing one means opening
    -- the on-screen keyboard through chat. See Docs/UnderPressure.md.

    UP.Note(("v%s loaded cleanly."):format(UP.version))
end

EVENT_MANAGER:RegisterForEvent(UP.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
