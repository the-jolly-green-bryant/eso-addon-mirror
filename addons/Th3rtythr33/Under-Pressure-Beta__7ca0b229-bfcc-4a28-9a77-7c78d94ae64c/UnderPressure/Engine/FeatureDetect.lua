-- =============================================================================
-- Under Pressure -- FeatureDetect.lua
-- =============================================================================
-- Runtime detection of API capabilities that could not be verified on console
-- without hardware. Each probe is non-destructive.
--
-- TWO SEPARATE JOBS, DELIBERATELY SPLIT
-- -------------------------------------
-- 1. DETECTION -- UP.RunFeatureDetect(), at startup, exactly once. This is
--    NOT diagnostics: both surviving flags are consumed as configuration.
--
--      * combatFilter     -- decides whether EventIngest registers
--                            server-side target filters. Without it, Tank
--                            mode falls back to an UNFILTERED subscription
--                            and every combat event in the zone crosses
--                            into Lua.
--      * statusEffectType -- decides whether the classifier can categorise
--                            debuffs by type or must fall back to the static
--                            ability-ID table.
--
--    Both fail silently if unset, and console does not surface Lua errors.
--    So do not move this off startup or make it lazy: it must run before
--    UP.Ingest.Register(), which reads combatFilter to decide how to
--    register, and before the first debuff is classified.
--
--    Six further probes were retired on 2026-07-29 -- four abandoned, two
--    hardcoded into ASSUMED below. All are archived with their consuming
--    guards in APIAUDITS.md at the workspace root.
--
-- 2. REPORTING -- UP.RunApiAudit(), on demand via /up-api-audit, printed to
--    chat. Nothing depends on it. This used to be a block in the debug
--    overlay plus a startup dump into the debug log buffer; both are gone.
--
--    It reports the STARTUP SNAPSHOT, so what you read is what the addon is
--    actually running on. It does not re-probe -- see the comment above
--    UP.RunApiAudit for why that was tried and dropped. The single exception
--    is when detection never ran at all, where there is no snapshot to report.
-- =============================================================================

UP = UP or {}
UP.features = {}

-- ---------------------------------------------------------------------------
-- Startup diary
-- ---------------------------------------------------------------------------
-- The addon prints NOTHING to chat unless the user asks for it. Anything that
-- would previously have been a d() during load -- the version banner, the
-- saved-vars migration notice, and the three failure messages -- is recorded
-- here instead and printed by /up-api-audit.
--
-- Diagnosability is the point: on console Lua errors are invisible, so a
-- failed load that also says nothing anywhere is undebuggable. This keeps the
-- information without putting it in the player's face.
--
-- Lives in this file only because it is first in the manifest load order, so
-- every other module can call UP.Note() at any point during startup.
UP.startupNotes = {}

function UP.Note(msg)
    UP.startupNotes[#UP.startupNotes + 1] = tostring(msg)
end

-- ---------------------------------------------------------------------------
-- Capabilities we no longer probe
-- ---------------------------------------------------------------------------
-- These are settled: field use of the shipped addon proves them true, and
-- they are properties of the client build, so they cannot vary between
-- sessions. Probing them every load was re-asking an answered question.
--
--   gameTime         -- if false, PressureEngine.Tick returns immediately and
--                       the addon does nothing at all. It works, so: true.
--   combatStateEvent -- 0.2.6's hide-when-out-of-combat depends on
--                       EVENT_PLAYER_COMBAT_STATE being registered, and that
--                       behaviour works. So: true.
--
-- They still appear in /up-api-audit, labelled (assumed), so the readout
-- never implies a measurement that did not happen. The probes and the guards
-- they gated are preserved in APIAUDITS.md at the workspace root -- restore
-- from there if ZOS ever changes this.
local ASSUMED = {
    gameTime         = true,
    combatStateEvent = true,
}

-- ---------------------------------------------------------------------------
-- 1. Combat event filter availability
-- ---------------------------------------------------------------------------
-- Still genuinely unknown. The addon works either way -- with server-side
-- filters, or registering unfiltered and filtering inside the callback -- so
-- "it works in the field" is no evidence at all about this one.
local function probeCombatFilter()
    local hasConstant = (type(REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE) == "number")
                    and (type(COMBAT_UNIT_TYPE_PLAYER) == "number")
    local hasMethod = (EVENT_MANAGER and type(EVENT_MANAGER.AddFilterForEvent) == "function")
    return hasConstant and hasMethod
end

-- ---------------------------------------------------------------------------
-- 2. Status-effect-type field on EVENT_EFFECT_CHANGED
-- ---------------------------------------------------------------------------
-- Still genuinely unknown. It only selects a classification strategy, and the
-- whole risk layer was inert from the seconds/milliseconds bug until 0.2.8,
-- so no field evidence exists either way.
local function probeStatusEffectType()
    return type(STATUS_EFFECT_TYPE_MAGIC) == "number"
        or type(STATUS_EFFECT_TYPE_STUN) == "number"
        or type(STATUS_EFFECT_TYPE_SNARE) == "number"
end

-- ---------------------------------------------------------------------------
-- Probe table -- drives both detection and the audit report
-- ---------------------------------------------------------------------------
-- "impact" is what a FALSE result costs, which is the only useful thing to
-- read in a report like this. Four further probes (shieldPower,
-- attributeVisual, groupTags, sourceType) were retired on 2026-07-29 -- they
-- existed to scope features that were then abandoned or never built. See
-- APIAUDITS.md for the code and the reasoning.
local PROBES = {
    { key = "combatFilter",     fn = probeCombatFilter,
      impact = "no server-side filtering; all combat events reach Lua" },
    { key = "statusEffectType", fn = probeStatusEffectType,
      impact = "classifier falls back to the static ability-ID table" },
}

local function runProbes()
    local results = {}
    for key, value in pairs(ASSUMED) do results[key] = value end
    for _, p in ipairs(PROBES) do
        local ok, value = pcall(p.fn)
        results[p.key] = ok and (value and true or false) or false
    end
    return results
end

-- ---------------------------------------------------------------------------
-- DETECTION (startup)
-- ---------------------------------------------------------------------------
-- No longer returns a pass/fail gate. The only fatal capability was gameTime,
-- which is now an assumption rather than a probe, so there is nothing left
-- that can refuse to start. The caller in UnderPressure.lua calls this
-- plainly. See APIAUDITS.md to restore the fatal path.
function UP.RunFeatureDetect()
    UP.features = runProbes()
end

-- ---------------------------------------------------------------------------
-- REPORTING (/up-api-audit)
-- ---------------------------------------------------------------------------
-- Reports the flags the addon is ACTUALLY RUNNING ON -- the startup snapshot,
-- not a fresh probe.
--
-- An earlier draft re-probed live, justified as catching a game patch that
-- changed availability mid-session. That cannot happen: patching ESO requires
-- the client to restart, so the snapshot cannot go stale that way. Nor is any
-- probe state-dependent -- they are constant/function existence checks.
--
-- Re-probing was also strictly worse: it could display values differing from
-- the ones event registration was built on, and it needed drift-detection
-- machinery to manage a discrepancy it introduced itself. Reading the snapshot
-- has neither problem.
--
-- Assumed values are labelled as such. An audit that presented an assumption
-- as a measurement would be worse than useless -- it is exactly the readout
-- someone would consult to find out why something stopped working.
local function report(flags, label)
    d("|cFFD700[Under Pressure] API audit|r")
    d(("addon v%s  |  API %s%s"):format(
        tostring(UP.version or "?"),
        tostring((type(GetAPIVersion) == "function") and GetAPIVersion() or "?"),
        label or ""))

    for _, p in ipairs(PROBES) do
        local ok = flags[p.key]
        d(("  %s  %-16s %s"):format(
            ok and "|c00FF00YES|r" or "|cFF4040NO |r",
            p.key,
            ok and "" or ("-- " .. p.impact)))
    end
    for key in pairs(ASSUMED) do
        d(("  %s  %-16s |cAAAAAA(assumed, not probed -- see APIAUDITS.md)|r"):format(
            flags[key] and "|c00FF00YES|r" or "|cFF4040NO |r", key))
    end
end

function UP.RunApiAudit()
    -- next() == nil means RunFeatureDetect never ran, i.e. startup aborted
    -- before reaching it. Reporting an empty table would show every capability
    -- as missing, which is a lie. Probe fresh and say so -- this is the one
    -- case where probing on demand is the right answer, because there is no
    -- snapshot to report and diagnosing the failed startup is the whole point.
    if next(UP.features) == nil then
        d("|cFFA500[Under Pressure] Feature detection never ran -- startup did")
        d("|cFFA500not complete. Probing now for diagnosis only; these values are")
        d("|cFFA500NOT in use by the addon.|r")
        report(runProbes(), "  (live probe)")
        return
    end

    report(UP.features, "  (in use since load)")

    -- Anything the addon wanted to say during load. Empty on a clean start.
    if #UP.startupNotes > 0 then
        d("  --- startup notes ---")
        for _, note in ipairs(UP.startupNotes) do
            d("  " .. note)
        end
    end

    -- Tank mode's extra registration depends on two flags at once, which the
    -- per-flag list above does not make obvious. The mode itself is live --
    -- it can be changed from the settings panel, which re-registers.
    -- The sourceType PROBE was retired, but the capability it tested is still
    -- load-bearing here: Tank mode's group-filtered registration needs
    -- COMBAT_UNIT_TYPE_OTHER_PLAYER. EventIngest guards it inline, so check
    -- the constant directly rather than a flag that no longer exists.
    local mode = (UP.sv and UP.sv.attacker_mode) or "solo"
    if mode == "tank" then
        local hasOtherPlayer = type(COMBAT_UNIT_TYPE_OTHER_PLAYER) == "number"
        if UP.features.combatFilter and hasOtherPlayer then
            d("  Tank mode: group-filtered registration ACTIVE")
        elseif not hasOtherPlayer then
            d("  |cFF4040Tank mode: COMBAT_UNIT_TYPE_OTHER_PLAYER missing --|r")
            d("  |cFF4040groupmate attackers are NOT being counted|r")
        else
            d("  |cFFA500Tank mode: falling back to unfiltered events|r")
        end
    end
end

-- Registered at file scope, not from onAddOnLoaded, so the audit still works
-- if startup bailed -- which is exactly when you most want to run it.
SLASH_COMMANDS["/up-api-audit"] = function() UP.RunApiAudit() end
-- Hyphen-free alias, in case the chat parser tokenizes on non-word characters.
SLASH_COMMANDS["/upapi"] = SLASH_COMMANDS["/up-api-audit"]
