--[[----------------------------------------------------------------------
    Dynamic Encounters : Encounter Tracker
    "Clone then own" — pressing T next to an encounter creates a fully
    independent custom timer pre-filled with encounter data (name, zone,
    predicted countdown, wayshrine). No sync, no linking, no guards.
    The timer is yours to edit, move, lock, and delete freely.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

-- Duplicate prevention: one pop-out timer per encounter zone.
-- Map of zoneId -> timerId so pressing T again finds the existing timer.
local clonedFromEncounter = {}

-- -------------------------------------------------------------------
-- TrackEncounter — clone encounter data into an independent custom timer
-- -------------------------------------------------------------------

function T.TrackEncounter(zoneId)
    if not zoneId then return end

    -- Duplicate prevention: one timer per encounter
    if clonedFromEncounter[zoneId] then
        local existing = T.GetTimer(clonedFromEncounter[zoneId])
        if existing then return clonedFromEncounter[zoneId] end
        -- Timer was deleted — clear stale entry
        clonedFromEncounter[zoneId] = nil
    end

    -- Build a descriptive label from encounter data
    local encName = HE.GetEncounterName(zoneId) or ("Encounter " .. zoneId)
    local zoneName = HE.GetZoneName(zoneId) or ""
    local label = encName
    if zoneName ~= "" then label = encName .. " \226\128\148 " .. zoneName end

    -- Calculate predicted remaining time as the initial duration
    local pred = HE.GetPrediction and HE.GetPrediction(zoneId)
    local duration = T.defaults.timerSettings.defaultDuration  -- fallback: 5 min
    if pred and pred.at then
        local remaining = math.max(0, pred.at - GetTimeStamp())
        if remaining > 0 then duration = math.ceil(remaining) end
    end

    -- Create a normal custom timer — no encounterZoneId, no sync, no guards
    local id = T.CreateTimer(label, duration, T.SIZE_MEDIUM)
    local timer = T.GetTimer(id)
    if not timer then return end

    -- Pre-set the wayshrine to the encounter's zone
    timer.wayshrineNodeId = nil
    timer.wayshrineZoneId = zoneId
    if T.UI_OnWayshrineChanged then T.UI_OnWayshrineChanged(timer) end

    -- Auto-start the countdown if there's a prediction
    if duration > 0 and pred and pred.at and pred.at > GetTimeStamp() then
        T.StartTimer(id)
    end

    clonedFromEncounter[zoneId] = id
    return id
end

-- -------------------------------------------------------------------
-- Cleanup: called by DeleteTimer to clear the clone tracking
-- -------------------------------------------------------------------

function T.OnEncounterCloneDeleted(timerId)
    for zoneId, tid in pairs(clonedFromEncounter) do
        if tid == timerId then
            clonedFromEncounter[zoneId] = nil
            return
        end
    end
end
