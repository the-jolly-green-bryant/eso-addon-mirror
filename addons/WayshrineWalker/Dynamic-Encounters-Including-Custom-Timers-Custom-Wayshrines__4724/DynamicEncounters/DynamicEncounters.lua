--[[----------------------------------------------------------------------
    Dynamic Encounters
    Tracks ESO Dynamic Encounters (Update 50+) via the World Event API.

    Design notes (verified via in-game /denc debug, API 101052):
      * Dynamic Encounters are World Events found via GetNextWorldEventInstanceId().
      * Dolmens (Dark Anchors) DO appear in the World Event Instance API.
        They are filtered by name (POI name contains "Dolmen") in IsDynamicEncounter.
      * GetWorldEventInstanceInfo does NOT exist in ESO's API. Identification
        is zone-based: any world event instance in a tracked starter zone IS
        a Dynamic Encounter.
      * While in the zone we receive EVENT_WORLD_EVENT_ACTIVATED / _DEACTIVATED
        plus step and progress events, and GetWorldEventCurrentStepExpireTimeS()
        gives a server-precise expiry timestamp for the current stage.
      * The respawn clock is NOT exposed by the API. It is learned here:
        we record real (end -> next start) gaps per zone per server and
        predict with the median. Shards may differ; we say so honestly.

----------------------------------------------------------------------]]--

DynamicEncounters = DynamicEncounters or {}
local HE = DynamicEncounters

HE.name        = "DynamicEncounters"
HE.displayName = "Dynamic Encounters"
HE.version     = "1.0.0"

local EVENT_NS = "DynamicEncounters_"

-- Sanity bounds for a believable respawn gap (seconds)
local GAP_MIN, GAP_MAX     = 5 * 60, 90 * 60
local DEFAULT_COOLDOWN     = 30 * 60      -- seed hypothesis: ~30 minutes
local MIN_ENCOUNTER_DURATION = 60          -- below this = phase transition, not real end
local MAX_GAP_SAMPLES      = 12
local MAX_LOG_ENTRIES      = 60

-- The three launch Dynamic Encounters, keyed by zoneId.
-- Names are fallbacks; when an encounter is live with a POI context we
-- read the real (localized) POI name from the game instead.
HE.ENCOUNTERS = {
    [381] = { order = 1, key = "flowervine", fallbackName = "Flowervine Farm" }, -- Auridon
    [41]  = { order = 2, key = "bilsa",      fallbackName = "Bilsa's Delivery" }, -- Stonefalls
    [3]   = { order = 3, key = "vampire",    fallbackName = "Vampire Hunt" },     -- Glenumbra
}

HE.ICON_ACTIVE = "EsoUI/Art/MapPins/worldEvent_poi_active_incomplete.dds"
HE.ICON_IDLE   = "EsoUI/Art/ZoneStories/completionTypeIcon_worldEvents.dds"

HE.SOUND_CHOICES = {
    { name = nil --[[filled at load: NONE]], id = "NONE" },
    { id = "OBJECTIVE_DISCOVERED" },
    { id = "DUEL_START" },
    { id = "NEW_NOTIFICATION" },
    { id = "QUEST_COMPLETED" },
    { id = "GROUP_ELECTION_REQUESTED" },
}

HE.defaults = {
    shown          = true,
    locked         = false,
    scale          = 1.0,
    opacity        = 0.55,
    theme          = "dark",       -- "dark" | "light"
    compact        = false,
    collapsed      = false,
    minimized     = false,
    onlyCurrent    = false,
    showTravel     = true,
    showDisclaimer = true,
    collapseMode   = "status",  -- "name" | "status" | "full"
    deluxeMode     = false,    -- show confidence breakdown + shard info
    panelWidth     = 300,
    hideInCombat   = false,
    showSeconds    = true,
    showMapPins    = true,
    showHoverTooltips = true,   -- show hover tooltips on HUD buttons
    left           = nil,
    top            = nil,
    track          = {},           -- [zoneId] = true/false
    alertCSA       = true,
    alertChat      = true,
    alertSound     = "OBJECTIVE_DISCOVERED",
    preAlertSecs   = 0,   -- off by default; set >0 in settings to get alerts before predicted start
    zones            = {},           -- learned data: [zoneId] = {...}
    log              = {},           -- raw observation log (debug/calibration)
    activeSnapshots  = {},           -- [zoneId][coordKey] = { instanceId, poiX, poiY, startTime, lastSeen }
    probeData       = nil,          -- /denc probe output (for easy copy-paste)
    debugMode       = false,        -- toggle diagnostic chat output for Timers
    headerWayshrine = {             -- custom header wayshrine button
        nodeIndex = nil,
        name      = nil,
        zoneId    = nil,
        zoneName  = nil,
        enabled   = true,
    },
    timerSettings   = {             -- custom timer system (Timers/)
        version      = 1,
        nextId       = 1,
        globalLock   = false,
        defaultSize  = 2,           -- 1=small, 2=medium, 3=large
        list         = {},
    },
}

-- ---------------------------------------------------------------------
-- runtime state
-- ---------------------------------------------------------------------

HE.runtime = {}      -- [zoneId] = { active, instanceId, startTime, startObserved, liveName }
HE.predictors = {}    -- [zoneId] = Predictor instance (wraps SV subtable)
HE.currentZoneId = 0
-- Track instance IDs seen during passive scans (not event-driven).
-- Persistent IDs = dolmens; transient IDs = dynamic encounters.
HE.scanInstanceHistory = {}  -- [zoneId][instanceId] = seenCount
HE.participation = { instanceId = 0, stepDefId = 0 }

local function Now()
    return GetTimeStamp()
end

local function GetZoneData(zoneId)
    local sv = HE.sv
    if not sv.zones[zoneId] then
        sv.zones[zoneId] = {
            samples = {}, scores = {}, quarantine = {},
            durEma = nil, anchor = {},
            lastSeen = nil,
        }
    else
        local zd = sv.zones[zoneId]
        -- MIGRATION: convert old-format data (gaps/ema/lastEnd) to Predictor format
        if zd.gaps and #zd.gaps > 0 then
            local now = Now()
            if type(zd.samples) ~= "table" then zd.samples = {} end
            for i, g in ipairs(zd.gaps) do
                if g <= 60 * 60 then
                    zd.samples[#zd.samples + 1] = { t = zd.lastEnd or now, cd = g, w = 1 }
                end
            end
            zd.gaps = nil
        end
        zd.anchor = zd.anchor or {}
        if zd.lastEnd and not zd.anchor.lastEnd then
            zd.anchor.lastEnd = zd.lastEnd
            zd.lastEnd = nil
        end
        if zd.lastStart and not zd.anchor.lastStart then
            zd.anchor.lastStart = zd.lastStart
            zd.lastStart = nil
        end
        zd.samples = zd.samples or {}
        zd.scores = zd.scores or {}
        zd.quarantine = zd.quarantine or {}
    end
    return sv.zones[zoneId]
end

-- Get or create a Predictor instance for a zone.
local function GetPredictor(zoneId)
    if not HE.predictors[zoneId] then
        local zd = GetZoneData(zoneId)
        HE.predictors[zoneId] = HE.Predictor.New(zd)
    end
    return HE.predictors[zoneId]
end

local function GetRuntime(zoneId)
    HE.runtime[zoneId] = HE.runtime[zoneId] or { active = false }
    return HE.runtime[zoneId]
end

function HE.IsTracked(zoneId)
    local t = HE.sv.track[zoneId]
    if t == nil then return true end
    return t
end

-- ---------------------------------------------------------------------
-- learned respawn model (median of observed end->start gaps)
-- ---------------------------------------------------------------------

-- Delegate to the Predictor engine for all cooldown/prediction math.
local function MedianGapForSnapshot(zoneId)
    local p = GetPredictor(zoneId)
    local T, _, neff = p:GetCooldown(Now())
    return T
end

function HE.GetCooldownEstimate(zoneId)
    local p = GetPredictor(zoneId)
    local T, _, neff = p:GetCooldown(Now())
    return T, math.floor(neff or 0)
end

function HE.GetPrediction(zoneId)
    local p = GetPredictor(zoneId)
    local pred = p:GetPrediction(Now())
    if not pred then return nil, 0 end
    return pred, math.floor(pred.samples or 0)
end

local function LogObservation(kind, zoneId, extra)
    local log = HE.sv.log
    log[#log + 1] = { t = Now(), k = kind, z = zoneId, x = extra }
    while #log > MAX_LOG_ENTRIES do
        table.remove(log, 1)
    end
end

-- ---------------------------------------------------------------------
-- naming
-- ---------------------------------------------------------------------

function HE.GetEncounterName(zoneId)
    local rt = GetRuntime(zoneId)
    if rt.liveName and rt.liveName ~= "" then
        return rt.liveName
    end
    local def = HE.ENCOUNTERS[zoneId]
    return def and def.fallbackName or GetString(SI_WORLD_MAP_FILTERS_OBJECTIVES) or "World Event"
end

function HE.GetZoneName(zoneId)
    local name = GetZoneNameById(zoneId)
    if not name or name == "" then return "" end
    return zo_strformat("<<1>>", name)
end

local function ResolveLiveName(zoneId, instanceId)
    local rt = GetRuntime(zoneId)
    -- GetWorldEventLocationContext returns a numeric constant:
    --   WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST = 2 (confirmed via debug)
    local ok, context = pcall(GetWorldEventLocationContext, instanceId)
    if ok and context == 2 then
        local okPoi, zoneIndex, poiIndex = pcall(GetWorldEventPOIInfo, instanceId)
        if okPoi and zoneIndex and poiIndex then
            local objectiveName = GetPOIInfo(zoneIndex, poiIndex)
            if objectiveName and objectiveName ~= "" then
                rt.liveName = zo_strformat("<<1>>", objectiveName)
            end
            -- Store normalized map coordinates for map pins
            rt.poiZoneIndex, rt.poiIndex = zoneIndex, poiIndex
            local okMap, normX, normY = pcall(GetPOIMapInfo, zoneIndex, poiIndex)
            if okMap and normX then
                rt.poiX, rt.poiY = normX, normY
            end
        end
    end
end

-- ---------------------------------------------------------------------
-- real-time position updates (for moving encounters like patrols)
-- Uses GetWorldEventPOIPinInfo -- the same API dragon addons use.
-- Polled at 500ms only when the world map is visible.
-- ---------------------------------------------------------------------
local MAP_PIN_POLL_MS = 500
local mapPinNextPoll = 0

function HE.UpdateEncounterPositions()
    local now_ms = GetGameTimeMilliseconds()
    if now_ms < mapPinNextPoll then return end
    mapPinNextPoll = now_ms + MAP_PIN_POLL_MS
    -- Only poll when map is open (saves CPU)
    if ZO_WorldMap_IsWorldMapHidden and ZO_WorldMap_IsWorldMapHidden() then return end
    -- Guard: GetWorldEventPOIPinInfo does NOT exist in ESO's API (confirmed via debug).
    -- Position polling is a no-op until ZOS exposes this or we find the correct function.
    if type(GetWorldEventPOIPinInfo) ~= "function" then return end
    local changed = false
    for zoneId in pairs(HE.ENCOUNTERS) do
        local rt = GetRuntime(zoneId)
        if rt.active and rt.poiZoneIndex and rt.poiIndex then
            local activeState, x, y = GetWorldEventPOIPinInfo(rt.poiZoneIndex, rt.poiIndex)
            local ACTIVE_STATE = WORLD_EVENT_ACTIVE_STATE_ACTIVE or 2
            if activeState == ACTIVE_STATE and x and (x ~= rt.poiX or y ~= rt.poiY) then
                rt.poiX, rt.poiY = x, y
                changed = true
            end
        end
    end
    if changed then
        HE.RefreshAllMapPins()
    end
end

-- ---------------------------------------------------------------------
-- saved snapshots: minimal SV persistence to survive zone transitions
-- Keyed by zoneId + coordinate hash; preserves startTime across reloads.
-- TTL 15 min prevents ghost entries from encounters that ended during load.
-- ---------------------------------------------------------------------
local MIN_SNAPSHOT_TTL = 15 * 60  -- 15 minutes floor

local function GetSnapshotTTL(zoneId)
    local cooldown = MedianGapForSnapshot(zoneId) or DEFAULT_COOLDOWN
    return math.max(MIN_SNAPSHOT_TTL, cooldown * 1.5)
end

local function CoordKey(x, y)
    if not x or not y then return nil end
    return string.format("%.4f_%.4f", x, y)
end

local function SaveSnapshot(zoneId, rt)
    local ck = CoordKey(rt.poiX, rt.poiY)
    if not ck then return end
    HE.sv.activeSnapshots[zoneId] = HE.sv.activeSnapshots[zoneId] or {}
    HE.sv.activeSnapshots[zoneId][ck] = {
        instanceId = rt.instanceId,
        poiX = rt.poiX, poiY = rt.poiY,
        startTime = rt.startTime,
        lastSeen = Now(),
    }
end

local function PruneSnapshots(zoneId)
    local snap = HE.sv.activeSnapshots[zoneId]
    if not snap then return end
    local cutoff = Now() - GetSnapshotTTL(zoneId)
    for ck, data in pairs(snap) do
        if not data.lastSeen or data.lastSeen < cutoff then
            snap[ck] = nil
        end
    end
end

local function MatchSnapshot(zoneId, rt)
    PruneSnapshots(zoneId)
    local ck = CoordKey(rt.poiX, rt.poiY)
    if not ck then return false end
    local snap = HE.sv.activeSnapshots[zoneId]
    if snap and snap[ck] and snap[ck].startTime then
        rt.startTime = snap[ck].startTime
        rt.startObserved = true
        return true
    end
    return false
end

-- ---------------------------------------------------------------------
-- chat + alerts
-- ---------------------------------------------------------------------

local function Chat(msg)
    CHAT_ROUTER:AddSystemMessage(HE.GetString("CHAT_PREFIX") .. msg)
end

local function PlayAlertSound()
    local key = HE.sv.alertSound
    if key and key ~= "NONE" and SOUNDS[key] then
        PlaySound(SOUNDS[key])
    end
end

local function AnnounceCSA(mainText, subText)
    if not CENTER_SCREEN_ANNOUNCE then return end
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
    params:SetText(mainText, subText)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

local function FormatDuration(seconds, forceSeconds, forceMinimal)
    seconds = math.max(0, math.floor(seconds or 0))
    if forceMinimal then
        return ZO_FormatTimeLargestTwo(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL)
    end
    if HE.sv.showSeconds or forceSeconds or seconds < 60 then
        return ZO_FormatTime(seconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
    end
    return ZO_FormatTimeLargestTwo(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL)
end
HE.FormatDuration = FormatDuration

-- ---------------------------------------------------------------------
-- world event handling
-- ---------------------------------------------------------------------

-- Dynamic Encounter identification
-- KEY INSIGHTS (all confirmed via in-game /denc debug, API 101052):
--   1. GetWorldEventInstanceInfo does NOT exist in ESO's API.
--   2. GetNextWorldEventInstanceId() returns ALL world events in the current zone,
--      INCLUDING dolmens (Dark Anchors). Instance 98 = "Iluvamir Dolmen" in Auridon.
--   3. To distinguish Dynamic Encounters from dolmens, we resolve the POI name
--      via GetWorldEventPOIInfo(instanceId) -> GetPOIInfo(zoneIndex, poiIndex).
--      If the name contains "Dolmen", it's a Dark Anchor, not a Dynamic Encounter.
--   4. Each tracked starter zone has exactly ONE Dynamic Encounter plus 3 dolmens.
--      Only the Dynamic Encounter should trigger panel/alert/timer behavior.
--
-- Returns: isDynamicEncounter (bool), resolvedZoneId (number or nil)

-- Check if a world event instance is in the ACTIVE state.
-- Tries GetWorldEventActiveState first, then falls back to alternate API.
-- Returns: isActive (bool), stateValue (number or nil)
local function GetInstanceActiveState(instanceId)
    -- Strategy 1: GetWorldEventActiveState (most likely to exist)
    if type(GetWorldEventActiveState) == "function" then
        local ok, state = pcall(GetWorldEventActiveState, instanceId)
        if ok and state ~= nil then
            -- WORLD_EVENT_ACTIVE_STATE_ACTIVE = 2 (numeric fallback)
            return state == 2, state
        end
    end
    -- Strategy 2: GetWorldEventInstanceState (alternate naming)
    if type(GetWorldEventInstanceState) == "function" then
        local ok, state = pcall(GetWorldEventInstanceState, instanceId)
        if ok and state ~= nil then
            return state == 2, state
        end
    end
    -- Cannot determine -- return unknown
    return nil, nil
end

-- Try to resolve a human-readable name for a world event instance.
-- Tests multiple possible API functions.
-- Returns: name (string or nil)
local function TryGetWorldEventName(instanceId)
    -- Try every plausible function name
    local funcsToTry = {
        "GetWorldEventName",
        "GetWorldEventDisplayName",
        "GetWorldEventInfo",
        "GetWorldEventInstanceInfo",
    }
    for _, fnName in ipairs(funcsToTry) do
        local fn = _G[fnName]
        if type(fn) == "function" then
            local ok, result = pcall(fn, instanceId)
            if ok and type(result) == "string" and result ~= "" then
                return result
            end
            -- Some might return multiple values
            if ok and result ~= nil then
                return tostring(result)
            end
        end
    end
    -- Try POI-based resolution
    if type(GetWorldEventPOIInfo) == "function" then
        local okPoi, zi, pi = pcall(GetWorldEventPOIInfo, instanceId)
        if okPoi and zi and pi then
            local okName, poiName = pcall(GetPOIInfo, zi, pi)
            if okName and poiName and poiName ~= "" then
                return tostring(poiName)
            end
        end
    end
    return nil
end

local function IsDynamicEncounter(instanceId)
    if not instanceId or instanceId == 0 then return false, nil end

    local zoneId = HE.currentZoneId
    if not HE.ENCOUNTERS[zoneId] then
        return false, nil
    end

    -- NAME-BASED FILTER: Try to get the name and reject dolmens.
    local name = TryGetWorldEventName(instanceId)
    if name then
        local nameStr = tostring(name):lower()
        if nameStr:find("dolmen") or nameStr:find("dark anchor") then
            return false, nil
        end
        -- Positive identification: if name contains "dynamic" or known encounter keywords
        HE._debugResolvedName = name
    end

    -- If we can't resolve the name, we CANNOT reliably identify this instance.
    -- Fall through to zone-based acceptance but mark as uncertain.
    return true, zoneId
end

-- ---------------------------------------------------------------------
-- world map pins
-- Uses ESO's native custom pin API:
--   ZO_WorldMap_AddCustomPinType   -- register pin type (called once)
--   ZO_WorldMap_GetPinManager():CreatePin  -- create pins in callback
--   ZO_WorldMap_RefreshCustomPinsOfType    -- redraw after state change
-- PIN_TYPE string must be unique to avoid collisions with other addons.
-- ---------------------------------------------------------------------
local MAP_PIN_TYPE = "DynamicEncounters_WorldEventPin"

-- Encounter state change -> tell the map to repaint our pins
function HE.RefreshAllMapPins()
    if ZO_WorldMap_RefreshCustomPinsOfType then
        ZO_WorldMap_RefreshCustomPinsOfType(MAP_PIN_TYPE)
    end
end

local function OnEncounterLive(zoneId, instanceId, startObserved)
    local rt = GetRuntime(zoneId)
    if rt.active and rt.instanceId == instanceId then return end

    rt.active        = true
    rt.instanceId    = instanceId
    rt.startObserved = startObserved
    rt.startTime     = Now()
    rt.alertedSoon   = nil
    ResolveLiveName(zoneId, instanceId)
    if rt.poiX then
        SaveSnapshot(zoneId, rt)
    end
    HE.RefreshAllMapPins()

    local zd = GetZoneData(zoneId)
    zd.lastSeen = Now()
    GetPredictor(zoneId):RecordLastSeen(Now(), startObserved and "start" or "active")

    if startObserved then
        -- Guard: if encounter just ended briefly (phase transition),
        -- skip gap learning and alerts.
        if rt.lastPhaseEnd and (Now() - rt.lastPhaseEnd) < MIN_ENCOUNTER_DURATION then
            rt.lastPhaseEnd = nil
            LogObservation("phase_start", zoneId)
            HE.UI_RequestRefresh()
            return
        end
        rt.lastPhaseEnd = nil

        -- Feed the observation to the Predictor engine.
        -- It handles missed-cycle math, quarantine, drift detection, and confidence.
        local p = GetPredictor(zoneId)
        local report = p:OnEventStart(Now())
        if report.accepted then
            -- Note: report.weight may be nil during a regime shift (the
            -- predictor resets samples and does not compute a per-cycle
            -- weight for the shift event itself). Guard with 'or 0' so
            -- string.format never receives nil for the %f specifier.
            LogObservation("start", zoneId,
                report.cycles > 1 and string.format("cycles=%d impliedT=%ds w=%.2f", report.cycles, math.floor(report.impliedT or 0), report.weight or 0)
                or nil)
        elseif report.quarantined then
            LogObservation("quarantine", zoneId, string.format("impliedT=%ds", math.floor(report.rejectedT or 0)))
        elseif report.regimeShift then
            LogObservation("regime_shift", zoneId)
        else
            LogObservation("start", zoneId)
        end
        zd.lastStart = Now()

        if HE.IsTracked(zoneId) then
            -- Debounce: suppress alert output if we already alerted for this
            -- zone within the last 5 seconds. State still updates above;
            -- only chat/CSA/sound are suppressed to prevent double-fire.
            local now = Now()
            if not rt.lastAlertTime or (now - rt.lastAlertTime) >= 5 then
                rt.lastAlertTime = now
                local encName  = HE.GetEncounterName(zoneId)
                local zoneName = HE.GetZoneName(zoneId)
                if HE.sv.alertChat then
                    Chat(HE.GetString("CHAT_LIVE", encName, zoneName))
                end
                if HE.sv.alertCSA then
                    AnnounceCSA(HE.GetString("ALERT_LIVE"), HE.GetString("ALERT_LIVE_SUB", encName, zoneName))
                end
                PlayAlertSound()
            end
        end
    else
        LogObservation("seen_active", zoneId)
    end

    HE.UI_RequestRefresh()
end

local function OnEncounterEnded(zoneId, instanceId)
    local rt = GetRuntime(zoneId)
    if not rt.active then return end
    if rt.instanceId and instanceId and rt.instanceId ~= instanceId then return end

    rt.active        = false
    rt.instanceId    = nil
    rt.liveName      = nil
    rt.poiX          = nil
    rt.poiY          = nil
    rt.poiZoneIndex  = nil
    rt.poiIndex      = nil
    rt.alertedSoon   = nil
    HE.RefreshAllMapPins()

    local zd = GetZoneData(zoneId)
    -- Guard: if encounter was active < MIN_ENCOUNTER_DURATION,
    -- this was likely a phase transition, not a real end.
    local wasPhaseTransition = false
    if rt.startObserved and rt.startTime then
        local duration = Now() - rt.startTime
        if duration < MIN_ENCOUNTER_DURATION then
            wasPhaseTransition = true
        end
    end
    -- Always update the Predictor anchor when an encounter ends,
    -- even during phase transitions. A fresh lastEnd timestamp is
    -- essential for correct prediction; stale anchors cause "due any
    -- moment" instead of proper cooldown countdowns.
    GetPredictor(zoneId):OnEventEnd(Now())
    if wasPhaseTransition then
        rt.lastPhaseEnd = Now()
    end
    zd.lastSeen = Now()
    GetPredictor(zoneId):RecordLastSeen(Now(), wasPhaseTransition and "active" or "end")
    LogObservation(wasPhaseTransition and "phase_end" or "end", zoneId)

    if not wasPhaseTransition and HE.IsTracked(zoneId) and HE.sv.alertChat then
        local cooldown = MedianGapForSnapshot(zoneId)
        Chat(HE.GetString("CHAT_ENDED", HE.GetEncounterName(zoneId), HE.GetZoneName(zoneId), FormatDuration(cooldown)))
    end

    HE.UI_RequestRefresh()
end

-- Legacy EVENT_WORLD_EVENT_ACTIVATED/DEACTIVATED handlers.
-- These work alongside EVENT_WORLD_EVENT_ACTIVE_STATE_CHANGED and
-- provide redundant coverage for real-time encounter detection.
-- Both fire on activation/deactivation; the OnEncounterLive guard
-- (if rt.active and rt.instanceId == instanceId then return end)
-- and the 5-second alert debounce prevent duplicate user-visible output.
local function OnWorldEventActivated(_, worldEventInstanceId)
    if not HE.sv then return end  -- guard against events firing before SV init
    local isDE, zoneId = IsDynamicEncounter(worldEventInstanceId)
    if not isDE then return end
    zoneId = zoneId or HE.currentZoneId
    if zoneId == 0 or not HE.ENCOUNTERS[zoneId] then return end
    OnEncounterLive(zoneId, worldEventInstanceId, true)
end

local function OnWorldEventDeactivated(_, worldEventInstanceId)
    if not HE.sv then return end  -- guard against events firing before SV init
    local isDE, zoneId = IsDynamicEncounter(worldEventInstanceId)
    if not isDE then return end
    zoneId = zoneId or HE.currentZoneId
    if zoneId == 0 or not HE.ENCOUNTERS[zoneId] then return end
    OnEncounterEnded(zoneId, worldEventInstanceId)
end

-- EVENT_WORLD_EVENT_ACTIVE_STATE_CHANGED provides state constants
-- because it fires with explicit state constants (INACTIVE/INTRO/ACTIVE/OUTRO).
--
-- TIMING PRECISION (verified 2026-07-15):
--   INACTIVE(0) -> INTRO(1) -> ACTIVE(2) -> OUTRO(3) -> INACTIVE(0)
--
--   The server's cooldown clock starts when the encounter ENDS (enters INACTIVE).
--   The next encounter APPEARS at INTRO -- that's when the new cycle begins visually.
--   Previously we triggered "live" on ACTIVE(2), which includes the INTRO duration
--   (spawn + announce time, typically 15-60s) in our gap measurement, inflating T.
--
--   FIX: Trigger "live" at INTRO(1) instead of ACTIVE(2). The measured gap becomes
--   INACTIVE->INTRO = true server cooldown. ACTIVE(2) is now a fallback: if we
--   somehow miss INTRO, ACTIVE still catches it.
--
-- State names for diagnostic logging:
local STATE_NAMES = { [0] = "INACTIVE", [1] = "INTRO", [2] = "ACTIVE", [3] = "OUTRO" }

local function OnWorldEventStateChanged(_, worldEventInstanceId, oldState, newState)
    local isDE, zoneId = IsDynamicEncounter(worldEventInstanceId)
    if not isDE then return end
    zoneId = zoneId or HE.currentZoneId
    if zoneId == 0 or not HE.ENCOUNTERS[zoneId] then return end

    -- Diagnostic: log every state transition with timestamp
    local oldName = STATE_NAMES[oldState] or tostring(oldState)
    local newName = STATE_NAMES[newState] or tostring(newState)
    LogObservation("state_change", zoneId,
        string.format("%s->%s inst=%d", oldName, newName, worldEventInstanceId))

    -- Numeric state constants (per ESO Update 50, confirmed via debug):
    -- INACTIVE=0, INTRO=1, ACTIVE=2, OUTRO=3
    local introState    = 1
    local activeState   = 2
    local inactiveState = 0

    local rt = GetRuntime(zoneId)

    -- PRIMARY: trigger "live" at INTRO -- this is the true cycle boundary
    if newState == introState then
        OnEncounterLive(zoneId, worldEventInstanceId, true)

    -- FALLBACK: if we missed INTRO, catch at ACTIVE (better than missing it entirely)
    elseif newState == activeState and not rt.active then
        LogObservation("active_fallback", zoneId,
            "INTRO was missed; starting from ACTIVE")
        OnEncounterLive(zoneId, worldEventInstanceId, true)

    elseif newState == inactiveState then
        OnEncounterEnded(zoneId, worldEventInstanceId)
    end
end

-- iterate active world events in the current zone (e.g. after loading in)
-- generic-for passes (state, control); the C function wants (lastId)
local function WorldEventIdIterator(state, lastId)
    return GetNextWorldEventInstanceId(lastId)
end
local function IterWorldEventInstanceIds()
    return WorldEventIdIterator, nil, nil
end

function HE.RescanCurrentZone()
    local zoneId = HE.currentZoneId
    if zoneId == 0 then return end

    PruneSnapshots(zoneId)

    -- Collect all instances and check active state
    local foundInstances = {}
    local foundActive = false
    for instanceId in IterWorldEventInstanceIds() do
        local isDE, resolvedZone = IsDynamicEncounter(instanceId)
        if isDE then
            foundInstances[#foundInstances + 1] = instanceId
            -- Check if this instance is actually in ACTIVE state
            local isActive, stateVal = GetInstanceActiveState(instanceId)
            if isActive then
                foundActive = true
                local targetZone = resolvedZone or zoneId
                local rt = GetRuntime(targetZone)
                ResolveLiveName(targetZone, instanceId)
                local matched = MatchSnapshot(targetZone, rt)
                OnEncounterLive(targetZone, instanceId, matched)
            end
        end
    end

    -- Reconciliation: if we had an active encounter but it's no longer found
    local rt = GetRuntime(zoneId)
    if rt.active and #foundInstances == 0 then
        local zd = GetZoneData(zoneId)
        local p = GetPredictor(zoneId)
        -- The encounter ended sometime while we were loading.
        -- Pass an uncertainty equal to the time since we last saw it active.
        local uncertainty = rt.startTime and (Now() - rt.startTime) or 0
        p:OnEventEnd(Now(), math.min(uncertainty, 30 * 60))
        zd.lastSeen = Now()
        if rt.startObserved and rt.startTime then
            zd.lastDuration = Now() - rt.startTime
        end
        rt.active, rt.instanceId = false, nil
        rt.liveName = nil
        rt.poiX, rt.poiY = nil, nil
        LogObservation("gone", zoneId)
        HE.RefreshAllMapPins()
    end

    if #foundInstances == 0 and HE.ENCOUNTERS[zoneId] then
        GetZoneData(zoneId).lastSeen = Now()
    end

    HE.UI_RequestRefresh()
end

local function OnPlayerActivated()
    -- Rebuild wayshrine cache now that player is fully loaded.
    -- GetNumFastTravelNodes() returns very few nodes before this event.
    if HE.Timers and HE.Timers.BuildWayshrineCache then
        HE.Timers.BuildWayshrineCache()
        -- Zone resolution (tagging each node with its zoneId) runs when
        -- the wayshrine picker opens. It's NOT called here because the map
        -- system may not be ready for SetMapToMapListIndex during
        -- EVENT_PLAYER_ACTIVATED. The picker's ResolveNodeZones() call
        -- self-guards and exits early on subsequent opens.
    end

    local zoneIndex = GetUnitZoneIndex("player")
    -- Notify all predictors that we're leaving the zone.
    -- This marks the current gap as unreliable for learning.
    if HE.currentZoneId and HE.currentZoneId ~= 0 then
        local oldP = GetPredictor(HE.currentZoneId)
        if oldP and oldP.OnZoneExit then oldP:OnZoneExit() end
    end
    HE.currentZoneId = GetZoneId(zoneIndex)
    -- Tell every predictor about the loading screen (shards may change)
    for zoneId in pairs(HE.ENCOUNTERS) do
        GetPredictor(zoneId):OnLoadingScreen()
    end
    HE.RescanCurrentZone()
    -- Ghost pin reconciliation: encounters that ended during a loading screen
    -- leave rt.active = true but the instance is no longer in the world event list.
    -- Query the live API to detect and clean up these stale entries.
    local liveInstances = {}
    for instanceId in IterWorldEventInstanceIds() do
        local isDE = IsDynamicEncounter(instanceId)
        if isDE then
            liveInstances[instanceId] = true
        end
    end
    for zoneId in pairs(HE.ENCOUNTERS) do
        if zoneId == HE.currentZoneId then
            local rt = GetRuntime(zoneId)
            if rt.active and rt.instanceId and not liveInstances[rt.instanceId] then
                OnEncounterEnded(zoneId, rt.instanceId)
            end
        end
    end
    HE.RefreshAllMapPins()
end

-- participation (precise per-stage server timers while inside an encounter)
local function OnParticipationChanged()
    local instanceId, stepDefId = GetParticipatingWorldEventStep()
    HE.participation.instanceId = instanceId or 0
    HE.participation.stepDefId  = stepDefId or 0
    HE.UI_RequestRefresh()
end

function HE.GetParticipationInfo()
    local p = HE.participation
    if not p or p.instanceId == 0 then return nil end
    local ok1, stepName         = pcall(GetWorldEventStepName, p.instanceId, p.stepDefId)
    local ok2, expireTime       = pcall(GetWorldEventCurrentStepExpireTimeS, p.instanceId)
    local ok3, current, maximum = pcall(GetWorldEventCurrentStepProgress, p.instanceId)
    return {
        stepName = (ok1 and stepName) and zo_strformat("<<1>>", stepName) or "",
        expireTime = (ok2 and expireTime) or 0,
        progress = (ok3 and maximum and maximum > 1) and ((current or 0) / maximum) or nil,
    }
end

-- ---------------------------------------------------------------------
-- pre-alert (estimated) engine, driven from the UI update tick
-- ---------------------------------------------------------------------

function HE.CheckPreAlerts()
    local pre = HE.sv.preAlertSecs or 0
    if pre <= 0 then return end
    local now = Now()
    for zoneId in pairs(HE.ENCOUNTERS) do
        if HE.IsTracked(zoneId) then
            local rt = GetRuntime(zoneId)
            if not rt.active then
                local predicted, samples = HE.GetPrediction(zoneId)
                if predicted and samples > 0 then
                    local remaining = (predicted.at or 0) - now
                    if remaining <= pre and remaining > 0 and rt.alertedSoon ~= predicted.at then
                        rt.alertedSoon = predicted.at
                        local encName  = HE.GetEncounterName(zoneId)
                        local zoneName = HE.GetZoneName(zoneId)
                        if HE.sv.alertChat then
                            Chat(HE.GetString("CHAT_SOON", encName, zoneName, FormatDuration(remaining, true)))
                        end
                        if HE.sv.alertCSA then
                            AnnounceCSA(HE.GetString("ALERT_SOON"), HE.GetString("ALERT_SOON_SUB", encName, zoneName))
                        end
                        PlayAlertSound()
                    end
                end
            end
        end
    end
end

-- ---------------------------------------------------------------------
-- row model consumed by the UI
-- ---------------------------------------------------------------------

function HE.OpenMapToZone(zoneId, zoneName)
    if (not zoneId or zoneId == 0) and not zoneName then return end
    -- Open the world map navigated to a specific zone, from anywhere (HUD-safe).
    -- Ordering matters: ZO_WorldMap_ShowWorldMap() fires the on-show handler
    -- synchronously, which resets to player location. Setting the map on the
    -- very next line overrides that reset -- no delay needed.
    -- Uses SetMapToMapListIndex (the real API) via GetMapIndexByZoneId.
    -- SetMapToZoneId does NOT exist in ESO's API; we believed folklore.
    ZO_WorldMap_ShowWorldMap()
    local result = SET_MAP_RESULT_FAILED

    -- Method 1: Try by zone NAME first (hardcoded table, more reliable than zoneId)
    if zoneName and zoneName ~= "" then
        local numMaps = GetNumMaps()
        for mapIndex = 1, numMaps do
            local mapName = GetMapInfo(mapIndex)
            if mapName and mapName:lower() == zoneName:lower() then
                result = SetMapToMapListIndex(mapIndex)
                if result == SET_MAP_RESULT_MAP_CHANGED then
                    break
                end
            end
        end
    end

    -- Method 2: If zoneName failed, fall back to zoneId
    if (not result or result == SET_MAP_RESULT_FAILED) and zoneId and zoneId > 0 then
        local mapIndex = GetMapIndexByZoneId(zoneId)
        if mapIndex then
            result = SetMapToMapListIndex(mapIndex)
        else
            local mapId = GetMapIdByZoneId(zoneId)
            if mapId and mapId > 0 then
                result = SetMapToMapId(mapId)
            end
        end
    end

    if result == SET_MAP_RESULT_MAP_CHANGED then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
end

function HE.GetSortedZoneIds()
    local ids = {}
    for zoneId in pairs(HE.ENCOUNTERS) do ids[#ids + 1] = zoneId end
    table.sort(ids, function(a, b) return HE.ENCOUNTERS[a].order < HE.ENCOUNTERS[b].order end)
    return ids
end

function HE.GetRowState(zoneId)
    local rt  = GetRuntime(zoneId)
    local zd  = GetZoneData(zoneId)
    local now = Now()
    local here = (zoneId == HE.currentZoneId)

    -- LIVE: encounter is currently active
    if rt.active then
        local elapsed = rt.startObserved and (now - (rt.startTime or now)) or nil
        return {
            state = "live", here = here,
            statusText = HE.GetString("STATUS_LIVE"),
            timerText  = elapsed and HE.GetString("STATUS_LIVE_FOR", FormatDuration(elapsed)) or "",
        }
    end

    -- Ask the Predictor for a rich prediction
    local p = GetPredictor(zoneId)
    local pred = p:GetPrediction(now)

    -- DEBUG: trace Glenumbra (zoneId=3) prediction state to diagnose timer freeze
    if zoneId == 3 then
        local a = p.s.anchor
        local hasLastEnd = a.lastEnd and true or false
        local lastEndAge = a.lastEnd and (now - a.lastEnd) or -1
        local hasPred = pred and true or false
        local predAt = pred and pred.at or -1
        local remaining = pred and (pred.at - now) or -1
        local missed = pred and pred.missedCycles or -1
        local st = a.lastSeenType or "nil"
        local lst = a.lastSeenTime or -1
        local lstAge = a.lastSeenTime and (now - a.lastSeenTime) or -1
        local loads = a.loads or 0
        local samples = math.floor(pred and pred.samples or 0)
        LogObservation("dbg_row", zoneId,
            string.format("lastEnd=%s age=%d pred=%s at=%d rem=%d missed=%d seentype=%s seenage=%d loads=%d samples=%d",
                tostring(hasLastEnd), math.floor(lastEndAge),
                tostring(hasPred), math.floor(predAt),
                math.floor(remaining), missed, st,
                math.floor(lstAge), loads, samples))
    end

    if pred then
        local remaining = pred.at - now
        local samples = math.floor(pred.samples)
        local confLabel = HE.Predictor.ConfidenceLabel(pred.confidence)
        if remaining > 0 then
            -- "next ~15m"  +  "good · 3 samples"
            local timerStr
            if samples > 0 then
                timerStr = HE.GetString("CONFIDENCE", tostring(samples))
                if pred.missedCycles > 0 then
                    timerStr = timerStr .. " (" .. tostring(pred.missedCycles) .. " missed)"
                end
            else
                timerStr = HE.GetString("CONFIDENCE_LEARNING")
            end
            return {
                state = "soon", here = here,
                statusText = HE.GetString("STATUS_EXPECTED", FormatDuration(remaining, false, true)),
                timerText  = timerStr,
                confidence = pred.confidence,
                confLabel  = confLabel,
            }
        else
            -- "due any moment"  +  "ended 5m ago"
            local ago = now - (pred.at - pred.cooldown)
            return {
                state = "overdue", here = here,
                statusText = HE.GetString("STATUS_OVERDUE"),
                timerText  = HE.GetString("STATUS_COOLDOWN", FormatDuration(now - (pred.at - pred.cooldown), false, true)),
                confidence = pred.confidence,
                confLabel  = confLabel,
            }
        end
    end

    -- Smart prediction not available — try Estimated tier
    local estPred = p:GetEstimatedPrediction(now)
    -- Fallback: if the predictor engine has no lastSeenTime yet (no events
    -- witnessed since the update), but the zone data has a historical lastSeen
    -- timestamp, construct a simple estimated prediction from that.
    if not estPred and zd.lastSeen then
        local T, _, neff = p:GetCooldown(now)
        local D = p:GetDuration()
        local C = T + D
        local predicted = zd.lastSeen + T + D * 0.5
        while predicted < now do
            predicted = predicted + C
        end
        local remaining = predicted - now
        if remaining > 0 then
            estPred = { remaining = remaining, samples = neff, confidence = 10 }
        end
    end
    if estPred then
        local remaining = estPred.remaining
        local samples = math.floor(estPred.samples or 0)
        if remaining > 0 then
            local timerStr
            if samples > 0 then
                timerStr = HE.GetString("CONFIDENCE", tostring(samples))
            else
                timerStr = HE.GetString("CONFIDENCE_LEARNING")
            end
            return {
                state = "estimated", here = here,
                statusText = HE.GetString("STATUS_EXPECTED", FormatDuration(remaining, false, true)),
                timerText  = timerStr,
                confidence = estPred.confidence or 10,
                confLabel  = "fair",
            }
        end
    end
    -- We've seen this zone's encounter before, but don't have enough data
    if zd.lastSeen then
        return {
            state = "unknown", here = here,
            statusText = HE.GetString("STATUS_STALE", FormatDuration(now - zd.lastSeen, false, true)),
            timerText  = "",
        }
    end

    -- Never seen anything for this zone.
    return { state = "unknown", here = here, statusText = HE.GetString("STATUS_UNKNOWN"), timerText = "" }
end

-- ---------------------------------------------------------------------
-- slash commands
-- ---------------------------------------------------------------------

local function CmdStatus()
    Chat(HE.GetString("CMD_STATUS_HEADER"))
    for _, zoneId in ipairs(HE.GetSortedZoneIds()) do
        local row = HE.GetRowState(zoneId)
        Chat(string.format("%s (%s): %s %s",
            HE.GetEncounterName(zoneId), HE.GetZoneName(zoneId),
            row.statusText, row.timerText or ""))
    end
    Chat(HE.GetString("NOTE_INSTANCE"))
end

local function CmdLog()
    local log = HE.sv.log
    local from = math.max(1, #log - 19)
    local now = Now()
    Chat(string.format("Observation log (last %d of %d):", #log - from + 1, #log))
    for i = from, #log do
        local e = log[i]
        local zoneName = HE.GetZoneName(e.z) or ("zone " .. e.z)
        local extra = e.x and ("  " .. tostring(e.x)) or ""
        Chat(string.format("[-%s] %s | %s%s", FormatDuration(now - e.t, true), zoneName, e.k, extra))
    end
    if #log == 0 then Chat("(observation log is empty)") end
end

-- =====================================================================
-- API PROBE: Tests every possible World Event function for existence.
-- Saves results to SavedVariables so you can copy from the .sav file
-- instead of line-by-line from chat.
-- Usage: /denc probe  ? then log out and check SavedVariables file
-- =====================================================================
local function CmdProbe()
    local probe = {}
    probe.timestamp = tostring(GetTimeStamp())
    probe.apiVersion = GetAPIVersion and GetAPIVersion() or "unknown"
    probe.currentZoneId = HE.currentZoneId
    probe.zoneName = HE.GetZoneName(HE.currentZoneId)

    -- Build list of ALL GetWorldEvent* and Get*WorldEvent* functions
    local worldEventFuncs = {}
    local allFuncs = {}
    -- Scan _G for all functions containing "WorldEvent" or "worldEvent"
    for k, v in pairs(_G) do
        if type(v) == "function" then
            local kl = tostring(k):lower()
            if kl:find("worldevent") or kl:find("world_event") then
                worldEventFuncs[#worldEventFuncs + 1] = tostring(k)
            end
        end
    end
    table.sort(worldEventFuncs)
    probe.allWorldEventFunctions = worldEventFuncs

    -- Also check for EVENT_WORLD_EVENT* constants
    local worldEventConstants = {}
    for k, v in pairs(_G) do
        local ks = tostring(k)
        if ks:find("WORLD_EVENT") and type(v) == "number" then
            worldEventConstants[#worldEventConstants + 1] = ks .. " = " .. tostring(v)
        end
    end
    table.sort(worldEventConstants)
    probe.allWorldEventConstants = worldEventConstants

    -- For each world event instance, call every function and record results
    probe.instances = {}
    for instanceId in IterWorldEventInstanceIds() do
        local inst = {}
        inst.instanceId = instanceId

        -- Try every plausible function
        local funcsToTest = {
            "GetWorldEventActiveState",
            "GetWorldEventInstanceState",
            "GetWorldEventInstanceInfo",
            "GetWorldEventInfo",
            "GetWorldEventName",
            "GetWorldEventDisplayName",
            "GetWorldEventId",
            "GetWorldEventIcon",
            "GetWorldEventLocationContext",
            "GetWorldEventPOIInfo",
            "GetWorldEventPOILocation",
            "GetWorldEventZoneId",
            "GetWorldEventZoneIndex",
            "GetWorldEventTypeName",
            "GetWorldEventTypeId",
            "GetWorldEventCategory",
            "GetNumWorldEventSteps",
            "GetWorldEventStepInfo",
        }

        inst.functionResults = {}
        for _, fnName in ipairs(funcsToTest) do
            local fn = _G[fnName]
            if type(fn) == "function" then
                local ok, r1, r2, r3, r4, r5 = pcall(fn, instanceId)
                local entry = fnName .. " -> "
                if ok then
                    local parts = {}
                    if r1 ~= nil then parts[#parts + 1] = tostring(r1) end
                    if r2 ~= nil then parts[#parts + 1] = tostring(r2) end
                    if r3 ~= nil then parts[#parts + 1] = tostring(r3) end
                    if r4 ~= nil then parts[#parts + 1] = tostring(r4) end
                    if r5 ~= nil then parts[#parts + 1] = tostring(r5) end
                    entry = entry .. table.concat(parts, ", ")
                else
                    entry = entry .. "ERROR: " .. tostring(r1)
                end
                inst.functionResults[#inst.functionResults + 1] = entry
            else
                inst.functionResults[#inst.functionResults + 1] = fnName .. " -> NIL (does not exist)"
            end
        end

        -- Also try GetPOIInfo with various indices
        inst.poiTests = {}
        for zi = 0, 50 do
            for pi = 0, 200 do
                local ok, name = pcall(GetPOIInfo, zi, pi)
                if ok and name and tostring(name):lower():find("dolmen") then
                    inst.poiTests[#inst.poiTests + 1] = string.format(
                        "GetPOIInfo(%d,%d) = %s (DOLMEN)", zi, pi, tostring(name))
                end
                -- Also look for encounter-related POIs
                if ok and name and tostring(name):lower():find("dynamic") then
                    inst.poiTests[#inst.poiTests + 1] = string.format(
                        "GetPOIInfo(%d,%d) = %s (DYNAMIC)", zi, pi, tostring(name))
                end
            end
        end

        -- IsDynamicEncounter result
        local isDE, zoneId = IsDynamicEncounter(instanceId)
        inst.isDynamicEncounter = tostring(isDE)
        inst.resolvedZoneId = tostring(zoneId)
        inst.activeState = tostring(GetInstanceActiveState(instanceId))

        probe.instances[#probe.instances + 1] = inst
    end

    -- Save to SavedVariables
    HE.sv.probeData = probe

    -- Print summary to chat
    Chat("=== Dynamic Encounters API Probe ===")
    Chat(string.format("Found %d world event functions in _G:", #worldEventFuncs))
    for _, fn in ipairs(worldEventFuncs) do
        Chat("  " .. fn)
    end
    Chat(string.format("Found %d instances:", #probe.instances))
    for _, inst in ipairs(probe.instances) do
        Chat(string.format("  Instance %d: isDE=%s activeState=%s",
            inst.instanceId, inst.isDynamicEncounter, inst.activeState))
    end
    Chat(string.format("Found %d world event constants:", #worldEventConstants))
    for _, c in ipairs(worldEventConstants) do
        Chat("  " .. c)
    end
    Chat("=== Full probe data saved to SavedVariables! ===")
    Chat("Log out and open DynamicEncountersSV.sav in Notepad to copy everything at once.")
    Chat("=== End Probe ===")
end

local function CmdDebug()
    Chat("=== Dynamic Encounters Debug ===")
    Chat(string.format("currentZoneId: %d (tracked: %s)",
        HE.currentZoneId, HE.ENCOUNTERS[HE.currentZoneId] and "YES" or "no"))

    -- Dump ALL world event instances the API exposes
    -- Note: GetWorldEventInstanceInfo does NOT exist in ESO's API.
    -- We use the functions that actually work instead.
    local count = 0
    for instanceId in IterWorldEventInstanceIds() do
        count = count + 1
        Chat(string.format("[%d] instanceId=%d", count, instanceId))

        -- Location context (confirmed working — returns 2=POI for dynamic encounters)
        local okCtx, ctx = pcall(GetWorldEventLocationContext, instanceId)
        Chat(string.format("     locationContext=%s (ok=%s)", tostring(ctx), tostring(okCtx)))

        -- POI info (zoneIndex, poiIndex)
        local okPoi, zi, pi = pcall(GetWorldEventPOIInfo, instanceId)
        Chat(string.format("     POI zoneIndex=%s poiIndex=%s (ok=%s)",
            tostring(zi), tostring(pi), tostring(okPoi)))
        if okPoi and zi and pi then
            local poiName = GetPOIInfo(zi, pi)
            Chat(string.format("     POI name=%s", tostring(poiName)))
            local okMap, nx, ny = pcall(GetPOIMapInfo, zi, pi)
            if okMap and nx then
                Chat(string.format("     mapPos=%s,%s", tostring(nx), tostring(ny)))
            end
        end

        -- Step info (if participating)
        local inst, stepDef = GetParticipatingWorldEventStep()
        if inst == instanceId and stepDef and stepDef ~= 0 then
            local okStep, stepName = pcall(GetWorldEventStepName, inst, stepDef)
            Chat(string.format("     step=%s name=%s", tostring(stepDef), tostring(okStep and stepName or "?")))
            local okExp, expTime = pcall(GetWorldEventCurrentStepExpireTimeS, inst)
            Chat(string.format("     stepExpire=%ss (ok=%s)", tostring(expTime), tostring(okExp)))
        end

        -- Show resolved detection
        local isDE, zoneId = IsDynamicEncounter(instanceId)
        Chat(string.format("     -> IsDynamicEncounter=%s zoneId=%s",
            tostring(isDE), tostring(zoneId)))
    end
    Chat(string.format("Total world event instances: %d", count))

    -- Show runtime + learned state for each tracked zone
    for _, zoneId in ipairs(HE.GetSortedZoneIds()) do
        local rt = GetRuntime(zoneId)
        local zd = GetZoneData(zoneId)
        local pred, samples = HE.GetPrediction(zoneId)
        Chat(string.format("Zone %d (%s): active=%s inst=%s liveName=%s",
            zoneId, HE.GetZoneName(zoneId),
            tostring(rt.active), tostring(rt.instanceId), tostring(rt.liveName)))
        local p = GetPredictor(zoneId)
        local T, mad, neff = p:GetCooldown(Now())
        local D = p:GetDuration()
        local predInfo = pred and string.format("at=%d conf=%d%% missed=%d",
            pred.at or 0, pred.confidence or 0, pred.missedCycles or 0) or "nil"
        Chat(string.format("  samples=%d durEma=%ds T=%ds D=%ds mad=%ds neff=%.1f pred=%s",
            #(zd.samples or {}), math.floor(D), math.floor(T),
            math.floor(D), math.floor(mad), neff, predInfo))
    end

    -- Show participation state
    local part = HE.participation
    Chat(string.format("Participation: instance=%d step=%d", part.instanceId or 0, part.stepDefId or 0))
    if part.instanceId and part.instanceId ~= 0 then
        local info = HE.GetParticipationInfo()
        if info then
            Chat(string.format("  stepName='%s' expire=%ss progress=%s",
                info.stepName, tostring(info.expireTime), tostring(info.progress)))
        end
    end
    Chat("=== End Debug ===")
end

local function OnSlashCommand(args)
    args = (args or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if args == "" or args == "toggle" then
        HE.TogglePanel()
    elseif args == "lock" then
        HE.sv.locked = true;  HE.UI_ApplyLock()
    elseif args == "unlock" then
        HE.sv.locked = false; HE.UI_ApplyLock()
    elseif args == "scan" then
        HE.RescanCurrentZone(); Chat(HE.GetString("CMD_SCAN_DONE"))
    elseif args == "status" then
        CmdStatus()
    elseif args == "log" then
        CmdLog()
    elseif args == "debug" then
        CmdDebug()
    elseif args == "probe" then
        CmdProbe()
    elseif args == "reset" then
        HE.sv.left, HE.sv.top = nil, nil
        HE.sv.zones, HE.sv.log, HE.sv.activeSnapshots = {}, {}, {}
        HE.predictors = {}  -- clear cached predictor instances
        HE.UI_ResetPosition()
        Chat(HE.GetString("CMD_RESET_DONE"))
    elseif args == "resetpos" then
        HE.sv.left, HE.sv.top = nil, nil
        HE.UI_ResetPosition()
        Chat(HE.GetString("CMD_RESET_POS"))
    else
        Chat(HE.GetString("CMD_HELP"))
    end
end

-- keybind label + toggle entry point
ZO_CreateStringId("SI_BINDING_NAME_DynamicEncounters_TOGGLE", "Toggle Dynamic Encounters panel")

function HE.TogglePanel()
    if not HE.sv then return end
    HE.sv.shown = not HE.sv.shown
    HE.UI_ApplyVisibility()
end

-- ---------------------------------------------------------------------
-- initialization
-- ---------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= HE.name then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NS .. "Loaded", EVENT_ADD_ON_LOADED)

    -- per-server profile: NA / EU / PTS have independent clocks and data
    HE.sv = ZO_SavedVars:NewAccountWide("DynamicEncountersSV", 1, nil, HE.defaults, GetWorldName())
    -- SV upgrade safety: ensure nested tables exist for users upgrading from older versions
    HE.sv.track = HE.sv.track or {}
    HE.sv.zones = HE.sv.zones or {}
    HE.sv.log = HE.sv.log or {}
    HE.sv.activeSnapshots = HE.sv.activeSnapshots or {}
    HE.sv.timerSettings = HE.sv.timerSettings or {}
    HE.sv.timerSettings.list = HE.sv.timerSettings.list or {}

    -- Register custom map pin type (called once, before any pins are created)
    -- The add callback fires every time the map opens/refreshes this pin type.
    local function OnMapPinAddCallback(pinManager)
        if not HE.sv.showMapPins then return end
        -- Only show pins for the map the player is currently viewing
        -- (allows scrolling the map to other zones and seeing their pins)
        local viewedZoneId = GetZoneId(GetCurrentMapZoneIndex())
        for zoneId in pairs(HE.ENCOUNTERS) do
            if zoneId == viewedZoneId then
                local rt = GetRuntime(zoneId)
                if rt.active and rt.poiX then
                    local tag = "DynamicEncounters_" .. tostring(zoneId) .. "_" .. tostring(rt.instanceId or 0)
                    pinManager:CreatePin(MAP_PIN_TYPE, tag, rt.poiX, rt.poiY)
                end
            end
        end
    end

    -- Pin layout: same icon as the HUD panel's active indicator
    local pinLayout = {
        level = 50,
        texture = HE.ICON_ACTIVE,
        size = 32,
        insetX = 0,
        insetY = 0,
    }

    -- Tooltip: encounter name + status
    local function PinTooltipCreator(pin)
        -- pin.data contains the tag, we extract zoneId
        local _, pinTag = pin:GetPinTypeAndTag()
        local tag = pinTag or ""
        local zoneId = tonumber(tag:match("DynamicEncounters_(%d+)"))
        if zoneId then
            local name = HE.GetEncounterName(zoneId)
            local row = HE.GetRowState(zoneId)
            local tooltipText = zo_strformat("<<1>>: <<2>>", name, row.statusText or "")
            if row.timerText and row.timerText ~= "" then
                tooltipText = tooltipText .. " |cAAAAAA (" .. row.timerText .. ")|r"
            end
            return tooltipText
        end
        return HE.displayName
    end

    if ZO_WorldMap_AddCustomPinType then
        ZO_WorldMap_AddCustomPinType(MAP_PIN_TYPE, OnMapPinAddCallback, nil, pinLayout, PinTooltipCreator)
    end

    HE.UI_Initialize()
    if HE.Settings_Initialize then HE.Settings_Initialize() end

    -- custom timer system
    if HE.Timers and HE.Timers.Initialize then
        HE.Timers.Initialize()
        -- Initial cache build (may be incomplete before player loads)
        HE.Timers.BuildWayshrineCache()
        if HE.Timers.UI_Initialize then HE.Timers.UI_Initialize() end
        if HE.Timers.Settings_Initialize then HE.Timers.Settings_Initialize() end
    end

    SLASH_COMMANDS["/denc"] = OnSlashCommand
    SLASH_COMMANDS["/DynamicEncounters"] = OnSlashCommand

    local EM = EVENT_MANAGER
    EM:RegisterForEvent(EVENT_NS .. "Activated",    EVENT_PLAYER_ACTIVATED,            OnPlayerActivated)
    EM:RegisterForEvent(EVENT_NS .. "WEInit",       EVENT_WORLD_EVENTS_INITIALIZED,    function() HE.RescanCurrentZone() end)
    EM:RegisterForEvent(EVENT_NS .. "WEActivated",  EVENT_WORLD_EVENT_ACTIVATED,       OnWorldEventActivated)
    EM:RegisterForEvent(EVENT_NS .. "WEDeactivated",EVENT_WORLD_EVENT_DEACTIVATED,     OnWorldEventDeactivated)
    EM:RegisterForEvent(EVENT_NS .. "WEStateChanged",EVENT_WORLD_EVENT_ACTIVE_STATE_CHANGED, OnWorldEventStateChanged)
    EM:RegisterForEvent(EVENT_NS .. "PartBegin",    EVENT_WORLD_EVENT_PARTICIPATION_BEGIN, OnParticipationChanged)
    EM:RegisterForEvent(EVENT_NS .. "PartEnd",      EVENT_WORLD_EVENT_PARTICIPATION_END,   OnParticipationChanged)
    EM:RegisterForEvent(EVENT_NS .. "StepChanged",  EVENT_WORLD_EVENT_STEP_CHANGED,        OnParticipationChanged)
    EM:RegisterForEvent(EVENT_NS .. "StepProgress", EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED, function() HE.UI_RequestRefresh() end)

    if HE.sv.hideInCombat then
        HE.RegisterCombatVisibility()
    end

    -- background tick: pre-alerts must work even while the panel is hidden
    EVENT_MANAGER:RegisterForUpdate(EVENT_NS .. "PreAlertTick", 1000, function()
        HE.CheckPreAlerts()
    end)
    -- real-time map pin position updates (500ms, only active when map is visible)
    EVENT_MANAGER:RegisterForUpdate(EVENT_NS .. "MapPinPoll", MAP_PIN_POLL_MS, function()
        HE.UpdateEncounterPositions()
    end)
end

function HE.RegisterCombatVisibility()
    local EM = EVENT_MANAGER
    EM:RegisterForEvent(EVENT_NS .. "Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        HE.UI_SetCombatHidden(inCombat and HE.sv.hideInCombat)
    end)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NS .. "Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
