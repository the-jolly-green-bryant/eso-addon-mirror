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
-- Keep in sync with ## Version in UnderPressure.addon and panelData.version
-- in Settings.lua. Through 0.2.7 these three disagreed four ways.
UP.version = "0.2.8"

local DEFAULT_SAVED = {
    hidden        = false,
    offset_x      = 0,
    offset_y      = -140,
    scale         = 1.0,
    debug         = false,
    -- "solo" (Not Tank) counts attackers on the local player.
    -- "tank" counts attackers on any groupmate (best-effort: limited to
    -- combat events the local client actually receives).
    attacker_mode = "solo",
    show_counter  = true,
    tunables      = {},
    abilityOverrides   = {},
    riskBonusOverrides = {},
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
local function loadSavedVars()
    -- Detect the pre-0.2.8 layout before ZO_SavedVars restructures the global.
    -- A ZO_SavedVars-managed table has a "Default" key at the top; a legacy
    -- one has our own setting keys there instead.
    local legacy = nil
    local existing = UnderPressureSavedVars
    if type(existing) == "table" and existing.Default == nil then
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
end

-- ---------------------------------------------------------------------------
-- UI refresh loop (see the TIMERS note at the top of this file)
-- ---------------------------------------------------------------------------
local UI_REFRESH_NAMESPACE = "UnderPressure_UIRefresh"
local UI_REFRESH_MS = 200   -- 5 Hz

local function refreshUI()
    if UP.UI and UP.UI.SetCounter and UP.Attackers and UP.Attackers.Counts then
        local count = UP.Attackers.Counts(GetGameTimeMilliseconds()) or 0
        UP.UI.SetCounter(count)
    end
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
    UP.Debug.Init()
    UP.Debug.SetVisible(UP.sv.debug or false)

    -- Settings panel
    UP.Settings.Init()

    -- Event ingestion
    UP.Ingest.Register()

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

    -- NOTE: "/up" is also declared as panelData.slashCommand in Settings.lua,
    -- so LibAddonMenu registers it itself when LAM is present. We only claim
    -- the command when LAM is ABSENT (console today), where it would
    -- otherwise do nothing at all. Overwriting LAM's working handler with our
    -- own -- which is what 0.2.7 did -- was strictly a downgrade: it gated on
    -- LibStub (removed in LAM r36+, so the branch was dead) and passed
    -- UP_IndicatorRoot, the indicator texture control, to OpenToPanel instead
    -- of the settings panel object.
    if not (UP.Settings and UP.Settings.panel) then
        SLASH_COMMANDS["/up"] = function()
            d("[Under Pressure] Settings UI unavailable (LibAddonMenu-2.0 not loaded).")
        end
    end

    UP.Note(("v%s loaded cleanly."):format(UP.version))
end

EVENT_MANAGER:RegisterForEvent(UP.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
