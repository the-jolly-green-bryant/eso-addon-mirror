-- =============================================================================
-- GroupGCDTracker.lua  v1.1
-- =============================================================================
-- Tracks per-skill GCDs + proximity detonation for every member of a 12-person
-- group.  Combat data is sourced from whichever library is available first:
--   LibCombat → LibCombat2 → native EVENT_COMBAT_EVENT
-- Settings are exposed via a LibAddonMenu-2.0 panel and backed by SavedVars.
--
-- Exposed callbacks (via GCDTracker:RegisterCallback):
--   "GCD_START"          (unitTag, abilityId, abilityName, durationMs)
--   "GCD_END"            (unitTag, abilityId, abilityName)
--   "ABILITY_USED"       (unitTag, abilityId, abilityName)
--   "PROX_DET_ARMED"     (unitTag, abilityId, abilityName)
--   "PROX_DET_TRIGGERED" (unitTag, abilityId, abilityName)
--
-- Public API:
--   GCDTracker:IsOnGCD(unitTag)              → bool, msRemaining
--   GCDTracker:GetLastAbility(unitTag)       → abilityId, abilityName
--   GCDTracker:GetAllGCDStates()             → table
--   GCDTracker:IsProxDetArmed(unitTag, id)   → bool, armedAtMs
--   GCDTracker:GetLibrarySource()            → string
--   GCDTracker:RegisterCallback(event, fn)
-- =============================================================================

local ADDON_NAME  = "GroupGCDTracker"
local ADDON_TITLE = "Group GCD Tracker"
local MAX_GROUP   = 12   -- ESO trial / dungeon cap (increase to 24 for Cyrodiil)

-- Trans-pride colour palette — usable in ESO |cRRGGBB...| escape sequences
local COL = {
    BLUE  = "5BCEFA",   -- light blue
    PINK  = "F5A9B8",   -- pink
    WHITE = "FFFFFF",
    NAVY  = "0D1B2A",   -- dark navy (backdrop)
}

-- Namespace
GroupGCDTracker       = GroupGCDTracker or {}
local GCDTracker      = GroupGCDTracker

-- Internal state
GCDTracker._gcdState  = {}   -- [unitTag] = { onGCD, startTime, endTime, abilityId, abilityName }
GCDTracker._proxState = {}   -- [unitTag] = { armed, armedAt, startMs, endMs, durationMs, abilityId, abilityName }
GCDTracker._callbacks = {}   -- [eventName] = { fn, ... }
GCDTracker._libSource = nil  -- "LibCombat" | "LibCombat2" | "Native"
GCDTracker.settings   = {}   -- populated by LoadSettings()

-- =============================================================================
-- Default SavedVar schema
-- =============================================================================

local DEFAULTS = {
    enabled           = true,
    gcdDurationMs     = 1000,    -- standard ESO GCD in milliseconds
    trackSelf         = true,    -- include "player" unit tag
    trackProximityDet = true,    -- fire PROX_DET_* events
    showChatAlerts    = false,   -- verbose per-cast chat messages
    debugMode         = false,
    -- Ability names to treat as proximity detonations (exact in-game name as the key).
    -- All morphs of Proximity Detonation share the same displayed name in ESO.
    proxDetAbilityNames = { ["Proximity Detonation"] = true},
    proxDetDefaultDurationMs = 8000,  -- fallback (ms) when GetUnitBuffInfo returns no data
    -- HUD
    showUI    = true,
    hideGCD   = false,  -- collapse the GCD column; DET bar expands to fill the space
    uiX       = nil,   -- nil = center on first load
    uiY       = nil,
    uiOpacity = 0.9,
    uiScale       = 1.0,
    fontSizeName  = 20,   -- member name label font size (pt)
    fontSizeTimer = 16,   -- countdown / timer label font size (pt)
    fontSizeHeader = 22,  -- title and column header font size (pt)
    -- HUD Colours (RGBA tables)
    colorBarText  = {1.000, 1.000, 1.000, 1.00},  -- timer label text   (pure white)
    colorNameLive = {1.000, 1.000, 1.000, 1.00},  -- member name (active)
    colorGcdFull  = {0.180, 0.850, 0.180, 1.00},  -- GCD bar  > 30%  (green)
    colorGcdLow   = {1.000, 0.200, 0.200, 1.00},  -- GCD bar  < 30%  (red)
    colorDetFull  = {0.180, 0.850, 0.180, 1.00},  -- DET bar  plenty (green)
    colorDetHigh  = {1.000, 0.200, 0.200, 1.00},  -- DET bar  imminent (red)
}

-- =============================================================================
-- Callback System
-- =============================================================================

--- Register a listener for a named event.
-- @param event  string  "GCD_START"|"GCD_END"|"ABILITY_USED"|"PROX_DET_ARMED"|"PROX_DET_TRIGGERED"
-- @param fn     function
function GCDTracker:RegisterCallback(event, fn)
    if not self._callbacks[event] then
        self._callbacks[event] = {}
    end
    table.insert(self._callbacks[event], fn)
end

local function Fire(event, ...)
    local list = GCDTracker._callbacks[event]
    if not list then return end
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then
            d(string.format("|c%s[%s]|r %s error: %s",
                COL.PINK, ADDON_NAME, event, tostring(err)))
        end
    end
end

-- =============================================================================
-- GCD State Management
-- =============================================================================

local function StartGCD(unitTag, abilityId, abilityName)
    if not GCDTracker.settings.enabled then return end
    local durMs = GCDTracker.settings.gcdDurationMs
    local now   = GetGameTimeMilliseconds()

    GCDTracker._gcdState[unitTag] = {
        onGCD       = true,
        startTime   = now,
        endTime     = now + durMs,
        abilityId   = abilityId,
        abilityName = abilityName or "",
    }

    Fire("GCD_START",    unitTag, abilityId, abilityName, durMs)
    Fire("ABILITY_USED", unitTag, abilityId, abilityName)

    if GCDTracker.settings.showChatAlerts then
        d(string.format("|c%s[GCDTracker]|r %s → |c%s%s|r (id:%d)",
            COL.BLUE, unitTag, COL.PINK, abilityName or "?", abilityId))
    end

    -- Schedule GCD expiry; guard against superseded casts via startTime stamp
    zo_callLater(function()
        local s = GCDTracker._gcdState[unitTag]
        if s and s.onGCD and s.startTime == now then
            s.onGCD = false
            Fire("GCD_END", unitTag, abilityId, abilityName)
        end
    end, durMs)
end

-- =============================================================================
-- Proximity Detonation Tracking
-- =============================================================================

-- Forward declaration: ArmProxDet's zo_callLater closure calls TriggerProxDet,
-- which is defined later.  Lua compiles local references at parse time, so we
-- must declare the local slot here before ArmProxDet is defined.
local TriggerProxDet

--- Query GetUnitBuffInfo for accurate effect timing when a prox-det buff is applied.
-- ESO buff times are in seconds comparable to GetGameTimeMilliseconds()/1000.
-- Falls back to proxDetDefaultDurationMs when the buff is not queryable
-- (e.g. unit is not "player" or active target).
local function LookupProxDetDuration(unitTag, abilityId)
    local defaultMs = GCDTracker.settings.proxDetDefaultDurationMs or 10000
    local now       = GetGameTimeMilliseconds()
    local nowSec    = now / 1000
    for i = 1, GetNumBuffs(unitTag) do
        local _, tStart, tEnd, _, _, _, _, _, _, _, buffId = GetUnitBuffInfo(unitTag, i)
        if buffId == abilityId and tEnd and tEnd > nowSec then
            local durSec = tEnd - tStart
            local remSec = tEnd - nowSec
            if durSec > 0 and remSec > 0 and remSec < 120 then
                local durMs = math.floor(durSec * 1000)
                local remMs = math.floor(remSec * 1000)
                return now - (durMs - remMs), now + remMs, durMs
            end
        end
    end
    return now, now + defaultMs, defaultMs
end

local function ArmProxDet(unitTag, abilityId, abilityName)
    if not GCDTracker.settings.trackProximityDet then return end
    local startMs, endMs, durationMs = LookupProxDetDuration(unitTag, abilityId)
    GCDTracker._proxState[unitTag] = {
        armed       = true,
        armedAt     = startMs,
        startMs     = startMs,
        endMs       = endMs,
        durationMs  = durationMs,
        abilityId   = abilityId,
        abilityName = abilityName or "",
    }
    if GCDTracker.settings.debugMode then
        d(string.format("|c%s[GCDTracker]|r DET armed: %s → |c%s%s|r (id:%d dur:%dms)",
            COL.PINK, unitTag, COL.BLUE, abilityName or "?", abilityId, durationMs))
    end
    Fire("PROX_DET_ARMED", unitTag, abilityId, abilityName)

    -- Auto-clear after duration + grace period.
    -- startMs stamp guards against this timer firing after a newer arm.
    zo_callLater(function()
        local pd = GCDTracker._proxState[unitTag]
        if pd and pd.armed and pd.startMs == startMs then
            TriggerProxDet(unitTag, abilityId, abilityName)
        end
    end, durationMs + 1000)
end

-- Assigned (not re-declared) so the forward-declared local slot is populated.
TriggerProxDet = function(unitTag, abilityId, abilityName)
    if not GCDTracker.settings.trackProximityDet then return end
    GCDTracker._proxState[unitTag] = nil
    Fire("PROX_DET_TRIGGERED", unitTag, abilityId, abilityName)
end

-- =============================================================================
-- Unit Tag Helpers
-- =============================================================================

local function IsGroupTag(unitTag)
    if unitTag == "player" then
        return GCDTracker.settings.trackSelf
    end
    if unitTag:sub(1, 5) == "group" then
        local idx = tonumber(unitTag:sub(6))
        return idx ~= nil and idx >= 1 and idx <= MAX_GROUP
    end
    return false
end

--- Strip ESO gender prefix (^M / ^F / ^N) and @account suffix from a name.
local function NormalizeName(name)
    if not name or name == "" then return "" end
    local stripped = name:match("^%^[MFNmfn](.+)$") or name
    return stripped:match("^([^@]+)") or stripped
end

-- Persistent name→tag lookup cache, rebuilt on zone/group changes.
local _nameToTag = {}

--- Rebuild the name→tag cache using every name variant ESO exposes per unit.
-- GetGroupMemberInfo provides the canonical character name used in combat logs.
local function RebuildNameCache()
    _nameToTag = {}
    local function store(tag, name)
        if name and name ~= "" then
            local norm = NormalizeName(name)
            -- "player" always takes priority: once the normalised name is mapped to
            -- "player", group-slot entries must not overwrite it.  This ensures all
            -- combat events for the local player resolve to "player", matching the
            -- key used by EVENT_EFFECT_CHANGED for prox-det state.
            if _nameToTag[norm] == nil or tag == "player" then
                _nameToTag[norm] = tag
            end
            if _nameToTag[name] == nil then _nameToTag[name] = tag end
        end
    end
    -- Self
    store("player", GetRawUnitName("player"))
    store("player", GetUnitName("player"))
    -- All group slots: raw name (character name, may have ^M/^F prefix) + display name (@Account)
    -- NormalizeName strips the prefix so it matches the zo_strformat-cleaned sourceName
    -- from EVENT_COMBAT_EVENT.
    for i = 1, MAX_GROUP do
        local tag = "group" .. i
        if DoesUnitExist(tag) then
            store(tag, GetRawUnitName(tag))
            store(tag, GetUnitName(tag))
        end
    end
end

--- Resolve combat-event sourceName to a tracked unit tag, or nil.
local function NameToUnitTag(sourceName)
    if not sourceName or sourceName == "" then return nil end
    if next(_nameToTag) == nil then RebuildNameCache() end  -- lazy init
    local tag = _nameToTag[NormalizeName(sourceName)] or _nameToTag[sourceName]
    if tag == "player" and not GCDTracker.settings.trackSelf then return nil end
    return tag
end

-- =============================================================================
-- Central combat-event dispatcher
-- Called by all three library paths with a normalised signature.
-- =============================================================================

-- Results that mean "an ability was just activated" → triggers GCD + det timer
local GCD_RESULTS = {
    [ACTION_RESULT_BEGIN]                  = true,
    [ACTION_RESULT_EFFECT_GAINED]          = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
}

--- Returns true if the ability matches a name in the proxDetAbilityNames list.
-- Falls back to DEFAULTS when the settings table is nil or empty (e.g. if the
-- LAM2 editbox was saved blank, LoadSettings will not restore the default because
-- the key exists — the empty table must be detected here).
local function IsProxDetAbility(abilityId, abilityName)
    local names = GCDTracker.settings.proxDetAbilityNames
    if not names or next(names) == nil then
        names = DEFAULTS.proxDetAbilityNames  -- safe fallback
    end
    if not names then return false end
    local name = abilityName ~= "" and abilityName or GetAbilityName(abilityId) or ""
    return names[name] == true
end

--- Handles EVENT_EFFECT_CHANGED.
-- PRIMARY path for prox-det detection: effectName (param 4) is the exact
-- displayed buff name, so it matches proxDetAbilityNames reliably without
-- depending on EVENT_COMBAT_EVENT abilityName formatting.
-- Fires for the local player and any visible group member.
-- ESO param order: eventCode, changeType, effectSlot, effectName, unitTag,
--   unitName, unitId, beginTime, endTime, stackCount, iconName, buffType,
--   effectType, abilityType, statusEffectType, abilityId, castByPlayer
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, _, _, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, abilityId, castByPlayer)
    if not IsGroupTag(unitTag) then return end

    -- UPDATED fires when an already-active buff has its duration refreshed
    -- (reapplication); treat it identically to GAINED so the timer resets.
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if not GCDTracker.settings.trackProximityDet then return end
        if not IsProxDetAbility(abilityId, effectName) then return end

        local now    = GetGameTimeMilliseconds()
        local bT     = tonumber(beginTime)
        local eT     = tonumber(endTime)
        local durSec = (bT and eT) and (eT - bT) or -1
        local startMs, endMsVal, durMs
        if durSec > 0 and durSec < 120 then
            local remMs = math.max(0, math.floor((eT - now / 1000) * 1000))
            durMs    = math.floor(durSec * 1000)
            startMs  = now - (durMs - remMs)
            endMsVal = now + remMs
        else
            durMs    = GCDTracker.settings.proxDetDefaultDurationMs or 8000
            startMs  = now
            endMsVal = now + durMs
        end
        GCDTracker._proxState[unitTag] = {
            armed       = true,
            armedAt     = startMs,
            startMs     = startMs,
            endMs       = endMsVal,
            durationMs  = durMs,
            abilityId   = abilityId,
            abilityName = effectName ~= "" and effectName or "",
        }
        if GCDTracker.settings.debugMode then
            d(string.format("|c%s[GCDTracker]|r DET armed (effect): %s -> |c%s%s|r (id:%d dur:%dms)",
                COL.PINK, unitTag, COL.BLUE, effectName or "?", abilityId, durMs))
        end
        Fire("PROX_DET_ARMED", unitTag, abilityId, effectName)

    elseif changeType == EFFECT_RESULT_FADED then
        local pd = GCDTracker._proxState[unitTag]
        if pd and pd.armed and pd.abilityId == abilityId then
            TriggerProxDet(unitTag, abilityId, pd.abilityName or "")
        end
    end
end

local function OnAbilityEvent(unitTag, abilityId, abilityName, result, isError)
    if isError or not unitTag then return end
    if not IsGroupTag(unitTag) then return end

    -- GCD: restricted to cast-begin / effect-gained results.
    if GCD_RESULTS[result] then
        StartGCD(unitTag, abilityId, abilityName)
    end

    -- Prox det: restricted to GCD-class results (BEGIN / EFFECT_GAINED /
    -- EFFECT_GAINED_DURATION) so that explosion damage / AoE events fired by a
    -- detonation that has already faded cannot re-arm the timer (the "FX DUMMY"
    -- double-proc).  OnEffectChanged is the primary arm path via EFFECT_RESULT_GAINED
    -- / EFFECT_RESULT_UPDATED; OnAbilityEvent is the fallback for group members
    -- whose effect events are not visible to the local client.
    if GCDTracker.settings.trackProximityDet and GCD_RESULTS[result]
       and IsProxDetAbility(abilityId, abilityName) then
        local pd  = GCDTracker._proxState[unitTag]
        local now = GetGameTimeMilliseconds()
        if not pd or not pd.armed or now > (pd.endMs or 0) then
            if GCDTracker.settings.debugMode then
                d(string.format("|c%s[GCDTracker]|r DET armed (combat): %s -> |c%s%s|r (id:%d result:%d)",
                    COL.PINK, unitTag, COL.BLUE, abilityName ~= "" and abilityName or "?", abilityId, result))
            end
            ArmProxDet(unitTag, abilityId, abilityName)
        end
    end
end

-- =============================================================================
-- LibCombat (original) Integration
-- TODO: Verify callback / event names against the installed LibCombat version.
--       The original Wykkyd LibCombat used a different parameter order to LC2.
-- =============================================================================

local function TryInitLibCombat()
    local LC = LibCombat
    if type(LC) ~= "table" then return false end

    -- Pattern A: object with RegisterCallback(eventName, fn)
    if LC.RegisterCallback then
        LC:RegisterCallback("OnCombatEvent", function(
                unitTag, result, isError,
                abilityName, _graphic, _slotType,
                _srcName, _tgtName,
                _hitValue, _powerType, _dmgType,
                _log, _srcUnitId, _tgtUnitId, abilityId)
            OnAbilityEvent(unitTag, abilityId, abilityName, result, isError)
        end)
        return false
    end

    -- Pattern B: older global-registration style
    if LC.RegisterForCombat then
        -- TODO: adapt the parameter order to what this LibCombat version passes.
        LC:RegisterForCombat(ADDON_NAME, function(unitTag, abilityId, abilityName, result, isError)
            OnAbilityEvent(unitTag, abilityId, abilityName, result or ACTION_RESULT_BEGIN, isError or false)
        end)
        return false
    end

    return false
end

-- =============================================================================
-- LibCombat2 Integration
-- TODO: Verify callback names against the installed LibCombat2 variant.
-- =============================================================================

local function TryInitLibCombat2()
    local LC2 = LibCombat2
    if type(LC2) ~= "table" then return false end

    -- Pattern A: RegisterCallback(eventName, fn)
    if LC2.RegisterCallback then
        LC2:RegisterCallback("AbilityActivated", function(unitTag, abilityId, abilityName, result)
            OnAbilityEvent(unitTag, abilityId, abilityName,
                result or ACTION_RESULT_BEGIN, false)
        end)
        return true
    end

    -- Pattern B: event-constant table (LC2.EVENT.ABILITY_ACTIVATED)
    if LC2.EVENT and LC2.EVENT.ABILITY_ACTIVATED and LC2.On then
        LC2:On(LC2.EVENT.ABILITY_ACTIVATED, function(unitTag, abilityId, abilityName)
            OnAbilityEvent(unitTag, abilityId, abilityName, ACTION_RESULT_BEGIN, false)
        end)
        return true
    end

    return false
end

-- =============================================================================
-- Native EVENT_COMBAT_EVENT Fallback
-- =============================================================================

local function OnCombatEventNative(
        _eventCode,
        result, isError, abilityName, _abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, _targetName, _targetType,
        _hitValue, _powerType, _damageType, _log, _sourceUnitId, _targetUnitId,
        abilityId, _overflow)
    -- Only trigger the GCD for abilities activated from the skill bar.
    -- ACTION_SLOT_TYPE_ACTIVE_ABILITY = regular bar skills;
    -- ACTION_SLOT_TYPE_ULTIMATE       = ultimate slot.
    -- Procs, passives, and world abilities have a different slot type and are ignored.
    if abilityActionSlotType ~= ACTION_SLOT_TYPE_ACTIVE_ABILITY
    and abilityActionSlotType ~= ACTION_SLOT_TYPE_ULTIMATE then
        return
    end
    local cleanSource  = zo_strformat("<<1>>", sourceName)
    local cleanAbility = zo_strformat("<<1>>", abilityName)
    local unitTag = NameToUnitTag(cleanSource)
    -- Console/xb1cert fallback: if name-cache lookup fails but sourceType identifies
    -- the local player, resolve directly.  COMBAT_UNIT_TYPE_PLAYER = 1 in all builds.
    if not unitTag and sourceType == (COMBAT_UNIT_TYPE_PLAYER or 1)
       and GCDTracker.settings.trackSelf then
        unitTag = "player"
    end
    OnAbilityEvent(unitTag, abilityId, cleanAbility, result, isError)
end

-- =============================================================================
-- Saved Variables
-- =============================================================================

local function LoadSettings()
    GroupGCDTracker_SavedVars = GroupGCDTracker_SavedVars or {}
    local sv = GroupGCDTracker_SavedVars
    -- Fill any keys that don't exist yet (handles new fields added by updates).
    -- Table-typed defaults are shallow-copied so each install gets its own copy.
    for k, v in pairs(DEFAULTS) do
        if sv[k] == nil then
            if type(v) == "table" then
                local copy = {}
                for dk, dv in pairs(v) do copy[dk] = dv end
                sv[k] = copy
            else
                sv[k] = v
            end
        end
    end
    GCDTracker.settings = sv
    -- Merge any names added to DEFAULTS.proxDetAbilityNames into existing saved vars
    -- (the loop above only copies when the key is nil, so new morphs like "Bombard"
    -- are never added to players who already have a saved proxDetAbilityNames table).
    if type(sv.proxDetAbilityNames) == "table" then
        for name, val in pairs(DEFAULTS.proxDetAbilityNames) do
            if sv.proxDetAbilityNames[name] == nil then
                sv.proxDetAbilityNames[name] = val
            end
        end
    end
end

-- =============================================================================
-- LibAddonMenu-2.0 Settings Panel
-- =============================================================================

local function BuildLAM2Panel()
    local LAM2 = LibAddonMenu2
              or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not LAM2 then
        if GCDTracker.settings.debugMode then
            d("|c" .. COL.PINK .. "[" .. ADDON_NAME .. "]|r LibAddonMenu-2.0 not found — settings UI unavailable.")
        end
        return
    end

    local panelData = {
        type               = "panel",
        name               = ADDON_NAME,
        displayName        = "|c" .. COL.BLUE .. ADDON_TITLE .. "|r",
        author             = "",
        version            = "1.2",
        slashCommand       = "/ggcdt",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local S = GCDTracker.settings  -- live reference; getFunc/setFunc read/write it directly

    local optionsData = {
        -- ── General ──────────────────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.BLUE .. "General|r",
        },
        {
            type    = "checkbox",
            name    = "Enable Addon",
            tooltip = "Master enable / disable for Group GCD Tracker.",
            getFunc = function() return S.enabled end,
            setFunc = function(v) S.enabled = v end,
            default = DEFAULTS.enabled,
        },
        {
            type    = "checkbox",
            name    = "Track Self",
            tooltip = "Include the local player (\"player\" unit tag) in GCD tracking.",
            getFunc = function() return S.trackSelf end,
            setFunc = function(v) S.trackSelf = v end,
            default = DEFAULTS.trackSelf,
        },
        -- ── GCD ──────────────────────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.BLUE .. "Global Cooldown|r",
        },
        {
            type    = "slider",
            name    = "GCD Duration (ms)",
            tooltip = "GCD window length in milliseconds.\nStandard ESO GCD is 1000 ms.",
            min     = 500,
            max     = 2000,
            step    = 50,
            getFunc = function() return S.gcdDurationMs end,
            setFunc = function(v) S.gcdDurationMs = v end,
            default = DEFAULTS.gcdDurationMs,
        },
        -- ── Proximity Detonation ─────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.PINK .. "Proximity Detonation|r",
        },
        {
            type    = "checkbox",
            name    = "Track Proximity Detonations",
            tooltip = "Fire PROX_DET_ARMED / PROX_DET_TRIGGERED callbacks for watched ability IDs.",
            getFunc = function() return S.trackProximityDet end,
            setFunc = function(v) S.trackProximityDet = v end,
            default = DEFAULTS.trackProximityDet,
        },
        {
            type        = "editbox",
            name        = "Proximity Det Ability Names",
            tooltip     = "Comma-separated ability names to treat as proximity detonations.\n"
                       .. "Use the exact in-game name (e.g. \"Proximity Detonation\").\n"
                       .. "All morphs of an ability share the same displayed name.",
            getFunc     = function()
                local names = {}
                for name in pairs(S.proxDetAbilityNames) do
                    table.insert(names, name)
                end
                table.sort(names)
                return table.concat(names, ", ")
            end,
            setFunc     = function(v)
                S.proxDetAbilityNames = {}
                for chunk in v:gmatch("[^,]+") do
                    local name = chunk:match("^%s*(.-)%s*$")  -- trim whitespace
                    if name ~= "" then
                        S.proxDetAbilityNames[name] = true
                    end
                end
            end,
            isMultiline = true,
            default     = "Proximity Detonation",
        },
        {
            type    = "slider",
            name    = "Prox Det Default Duration (ms)",
            tooltip = "Estimated detonation window used when GetUnitBuffInfo cannot query\nthe buff (e.g. unit is not player or active target).\nDefault: 10000 ms (10 s).",
            min     = 1000,
            max     = 30000,
            step    = 500,
            getFunc = function() return S.proxDetDefaultDurationMs end,
            setFunc = function(v) S.proxDetDefaultDurationMs = v end,
            default = DEFAULTS.proxDetDefaultDurationMs,
        },
        -- ── HUD ──────────────────────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.BLUE .. "HUD|r",
        },
        {
            type    = "checkbox",
            name    = "Show HUD",
            tooltip = "Show / hide the group GCD HUD panel.  Also toggled with /ggcdui.",
            getFunc = function() return S.showUI end,
            setFunc = function(v)
                S.showUI = v
                if GCDTracker.SetUIVisible then GCDTracker:SetUIVisible(v) end
            end,
            default = DEFAULTS.showUI,
        },
        {
            type    = "checkbox",
            name    = "Hide GCD Column",
            tooltip = "Collapse the GCD bar and timer.\nThe detonation bar expands to fill the freed space.",
            getFunc = function() return S.hideGCD end,
            setFunc = function(v) S.hideGCD = v end,
            default = DEFAULTS.hideGCD,
        },
        {
            type    = "slider",
            name    = "HUD Opacity",
            tooltip = "Overall opacity of the HUD panel.",
            min     = 0.1,
            max     = 1.0,
            step    = 0.05,
            getFunc = function() return S.uiOpacity end,
            setFunc = function(v)
                S.uiOpacity = v
                if GCDTracker.SetUIOpacity then GCDTracker:SetUIOpacity(v) end
            end,
            default = DEFAULTS.uiOpacity,
        },
        {
            type    = "slider",
            name    = "HUD Scale",
            tooltip = "Scale multiplier for the HUD panel.\n1.0 = normal size · 0.5 = half · 2.0 = double.",
            min     = 0.5,
            max     = 10.0,
            step    = 0.05,
            getFunc = function() return S.uiScale end,
            setFunc = function(v)
                S.uiScale = v
                if GCDTracker.SetUIScale then GCDTracker:SetUIScale(v) end
            end,
            default = DEFAULTS.uiScale,
        },
        {
            type    = "slider",
            name    = "Name Label Font Size",
            tooltip = "Font size (pt) for the member name column.\nTakes effect immediately.",
            min     = 10,
            max     = 28,
            step    = 1,
            getFunc = function() return S.fontSizeName end,
            setFunc = function(v)
                S.fontSizeName = v
                if GCDTracker.RefreshFonts then GCDTracker:RefreshFonts() end
            end,
            default = DEFAULTS.fontSizeName,
        },
        {
            type    = "slider",
            name    = "Timer Label Font Size",
            tooltip = "Font size (pt) for GCD and DET countdown labels.\nTakes effect immediately.",
            min     = 10,
            max     = 24,
            step    = 1,
            getFunc = function() return S.fontSizeTimer end,
            setFunc = function(v)
                S.fontSizeTimer = v
                if GCDTracker.RefreshFonts then GCDTracker:RefreshFonts() end
            end,
            default = DEFAULTS.fontSizeTimer,
        },
        {
            type    = "slider",
            name    = "Header / Title Font Size",
            tooltip = "Font size (pt) for the panel title and column headers (Member, GCD, DET IN).\nTakes effect immediately.",
            min     = 10,
            max     = 40,
            step    = 1,
            getFunc = function() return S.fontSizeHeader end,
            setFunc = function(v)
                S.fontSizeHeader = v
                if GCDTracker.RefreshFonts then GCDTracker:RefreshFonts() end
            end,
            default = DEFAULTS.fontSizeHeader,
        },
        {
            type    = "slider",
            name    = "HUD Position X",
            tooltip = "Horizontal position of the HUD panel (pixels from the left edge of the screen).\nDrag the panel in-game to update this automatically, or set it here directly.",
            min     = 0,
            max     = 3840,
            step    = 1,
            getFunc = function() return S.uiX or 0 end,
            setFunc = function(v)
                if GCDTracker.MoveUITo then
                    GCDTracker:MoveUITo(v, S.uiY or 0)
                end
            end,
            default = 0,
        },
        {
            type    = "slider",
            name    = "HUD Position Y",
            tooltip = "Vertical position of the HUD panel (pixels from the top edge of the screen).\nDrag the panel in-game to update this automatically, or set it here directly.",
            min     = 0,
            max     = 2160,
            step    = 1,
            getFunc = function() return S.uiY or 0 end,
            setFunc = function(v)
                if GCDTracker.MoveUITo then
                    GCDTracker:MoveUITo(S.uiX or 0, v)
                end
            end,
            default = 0,
        },
        {
            type    = "button",
            name    = "Reset HUD Position",
            tooltip = "Move the HUD back to the center of the screen and clear the saved X / Y values.",
            func    = function()
                if GCDTracker.ResetUIPosition then GCDTracker:ResetUIPosition() end
            end,
        },
        -- ── HUD Colours ───────────────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.PINK .. "HUD Colours|r",
        },
        {
            type    = "colorpicker",
            name    = "Timer Text",
            tooltip = "Colour of GCD and detonation timer labels.",
            getFunc = function() return unpack(S.colorBarText) end,
            setFunc = function(r,g,b,a) S.colorBarText = {r, g, b, a or 0.9} end,
            default = function() return unpack(DEFAULTS.colorBarText) end,
        },
        {
            type    = "colorpicker",
            name    = "Member Name",
            tooltip = "Colour of active group member names.",
            getFunc = function() return unpack(S.colorNameLive) end,
            setFunc = function(r,g,b,a) S.colorNameLive = {r, g, b, a or 1} end,
            default = function() return unpack(DEFAULTS.colorNameLive) end,
        },
        {
            type    = "colorpicker",
            name    = "GCD Bar (active)",
            tooltip = "Colour of the GCD bar when more than 30% remains.",
            getFunc = function() return unpack(S.colorGcdFull) end,
            setFunc = function(r,g,b,a) S.colorGcdFull = {r, g, b, a or 1} end,
            default = function() return unpack(DEFAULTS.colorGcdFull) end,
        },
        {
            type    = "colorpicker",
            name    = "GCD Bar (expiring)",
            tooltip = "Colour of the GCD bar when less than 30% remains.",
            getFunc = function() return unpack(S.colorGcdLow) end,
            setFunc = function(r,g,b,a) S.colorGcdLow = {r, g, b, a or 1} end,
            default = function() return unpack(DEFAULTS.colorGcdLow) end,
        },
        {
            type    = "colorpicker",
            name    = "DET Bar (plenty of time)",
            tooltip = "Colour of the detonation countdown bar when more than 40% remains.",
            getFunc = function() return unpack(S.colorDetFull) end,
            setFunc = function(r,g,b,a) S.colorDetFull = {r, g, b, a or 1} end,
            default = function() return unpack(DEFAULTS.colorDetFull) end,
        },
        {
            type    = "colorpicker",
            name    = "DET Bar (imminent)",
            tooltip = "Colour of the detonation countdown bar when less than 40% remains.",
            getFunc = function() return unpack(S.colorDetHigh) end,
            setFunc = function(r,g,b,a) S.colorDetHigh = {r, g, b, a or 1} end,
            default = function() return unpack(DEFAULTS.colorDetHigh) end,
        },
        -- ── Debug ─────────────────────────────────────────────────────────────
        {
            type = "header",
            name = "|c" .. COL.WHITE .. "Debug|r",
        },
        {
            type    = "checkbox",
            name    = "Chat Alerts",
            tooltip = "Print ability name and unit tag to chat whenever a skill fires.",
            getFunc = function() return S.showChatAlerts end,
            setFunc = function(v) S.showChatAlerts = v end,
            default = DEFAULTS.showChatAlerts,
        },
        {
            type    = "checkbox",
            name    = "Debug Mode",
            tooltip = "Print library-init status and other verbose info on load.",
            getFunc = function() return S.debugMode end,
            setFunc = function(v) S.debugMode = v end,
            default = DEFAULTS.debugMode,
        },
    }

    LAM2:RegisterAddonPanel(ADDON_NAME .. "_Panel", panelData)
    LAM2:RegisterOptionControls(ADDON_NAME .. "_Panel", optionsData)
end

-- =============================================================================
-- Initialization
-- =============================================================================

local function OnAddonLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    LoadSettings()
    BuildLAM2Panel()

    -- Always use native ESO events — no third-party library dependency
    GCDTracker._libSource = "Native"
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEventNative)
    -- NO AddFilterForEvent: we need all group member events, not just the local player.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    -- Redundant local-player path: EVENT_ACTION_SLOT_ABILITY_USED fires on all
    -- platforms without needing source-name resolution from combat event data.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_ABILITY_USED,
        function(_, slotIndex)
            if not GCDTracker.settings.enabled
            or not GCDTracker.settings.trackSelf then return end
            local abilityId   = GetSlotBoundId(slotIndex) or 0
            local abilityName = (abilityId > 0 and GetAbilityName(abilityId)) or ""
            StartGCD("player", abilityId, abilityName)
        end)

    -- Build name→tag cache after a short delay (ESO group data loads asynchronously)
    zo_callLater(RebuildNameCache, 2000)
    -- Rebuild on zone change and group membership changes
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(RebuildNameCache, 2000)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, function()
        zo_callLater(RebuildNameCache, 1000)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, function()
        zo_callLater(RebuildNameCache, 1000)
    end)

    -- Build HUD (defined in GroupGCDTracker_UI.lua)
    if GCDTracker.InitUI then
        GCDTracker:InitUI()
    end

    if GCDTracker.settings.debugMode then
        d(string.format("|c%s[%s]|r loaded — source: |c%s%s|r  maxGroup:%d",
            COL.BLUE, ADDON_NAME, COL.PINK, GCDTracker._libSource, MAX_GROUP))
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- =============================================================================
-- Public API
-- =============================================================================

--- Is unitTag currently within its GCD window?
-- @param unitTag string  e.g. "player", "group1" … "group12"
-- @return bool onGCD, number msRemaining
function GCDTracker:IsOnGCD(unitTag)
    local s = self._gcdState[unitTag]
    if not s or not s.onGCD then return false, 0 end
    local rem = s.endTime - GetGameTimeMilliseconds()
    if rem <= 0 then s.onGCD = false; return false, 0 end
    return true, rem
end

--- Last ability cast by unitTag (regardless of current GCD state).
-- @return number|nil abilityId, string|nil abilityName
function GCDTracker:GetLastAbility(unitTag)
    local s = self._gcdState[unitTag]
    if not s then return nil, nil end
    return s.abilityId, s.abilityName
end

--- Snapshot of all tracked GCD states, keyed by unit tag.
-- @return table { [unitTag] = { onGCD, msRemaining, abilityId, abilityName } }
function GCDTracker:GetAllGCDStates()
    local now, out = GetGameTimeMilliseconds(), {}
    for tag, s in pairs(self._gcdState) do
        local rem = s.onGCD and math.max(0, s.endTime - now) or 0
        out[tag] = {
            onGCD       = s.onGCD and rem > 0,
            msRemaining = rem,
            abilityId   = s.abilityId,
            abilityName = s.abilityName,
        }
    end
    return out
end

--- Is a detonation timer currently armed on unitTag?
-- Pass abilityId to check for a specific ability, or omit to check any.
-- @return bool armed, number|nil armedAtMs
function GCDTracker:IsProxDetArmed(unitTag, abilityId)
    local pd = self._proxState[unitTag]
    if not pd or not pd.armed then return false, nil end
    if abilityId and pd.abilityId ~= abilityId then return false, nil end
    return true, pd.armedAt
end

--- Which combat library is supplying events?
-- @return string  "LibCombat" | "LibCombat2" | "Native"
function GCDTracker:GetLibrarySource()
    return self._libSource
end

--[[
-- =============================================================================
-- USAGE EXAMPLES  (remove / comment out in production)
-- =============================================================================

-- Listen for any group GCD start:
GroupGCDTracker:RegisterCallback("GCD_START", function(unitTag, abilityId, abilityName, durMs)
    d(string.format("%s cast %s — GCD %.1fs", unitTag, abilityName, durMs / 1000))
end)

-- Listen for proximity detonation events:
GroupGCDTracker:RegisterCallback("PROX_DET_ARMED", function(unitTag, abilityId, abilityName)
    d(unitTag .. " armed " .. abilityName)
end)
GroupGCDTracker:RegisterCallback("PROX_DET_TRIGGERED", function(unitTag, abilityId, abilityName)
    d(unitTag .. " DETONATED " .. abilityName)
end)

-- Poll from a UI ticker:
local onGCD, ms = GroupGCDTracker:IsOnGCD("group5")
if onGCD then label:SetText(string.format("%.2fs", ms / 1000)) end

-- Check which library is active:
d("Source: " .. GroupGCDTracker:GetLibrarySource())
--]]


