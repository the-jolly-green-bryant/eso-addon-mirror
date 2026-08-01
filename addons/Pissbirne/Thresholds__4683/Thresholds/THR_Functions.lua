---------------------------------------------------------------------------
-- Thresholds - boss acquisition, config lookup and event handling
---------------------------------------------------------------------------

local THR = Thresholds
local Engine = THR.Engine -- THR_Engine.lua loads first (see manifest)

---------------------------------------------------------------------------
-- CONFIG LOOKUP
---------------------------------------------------------------------------
function THR.GetCleanName(rawName)
    -- SI_UNIT_NAME is ZOS's own unit-name format string; it formats correctly
    -- per client language, unlike a hardcoded "<<C:1>>".
    return zo_strformat(SI_UNIT_NAME, rawName)
end

-- Shipped names are English client unit names; on other client languages
-- the exact-name comparisons in the shipped-data helpers simply never match.
-- THR.clientLang is cached once in THR.Initialize (it cannot change without
-- a reloadui/logout, which reloads the whole environment anyway).
function THR.UsesEnglishNames()
    return THR.clientLang == "en"
end

-- Shipped per-boss default thresholds from THR_BossData.lua, or nil.
-- Entries without shipped thresholds hold `true` instead of a table.
function THR.GetShippedThresholds(zoneId, bossName)
    if not bossName then return nil end
    local data = THR.BossData and THR.BossData[zoneId]
    local entry = data and data.bosses and data.bosses[bossName]
    if type(entry) == "table" then return entry end
    return nil
end

-- Optional per-alert fields carried from stored entries into normalized
-- ones; missing fields inherit the global alert settings at fire time.
local ENTRY_FIELDS = {
    "text", "color", "sound", "soundRepeat",
    "fontSize", "duration", "noText", "noSound", "x", "y",
}

-- Accepts a number array (simple), an array of { pct =, ... } alert tables,
-- or a mix, and returns fresh entries { value = number, <ENTRY_FIELDS> }
-- sorted descending, deduped by value (first occurrence wins).
local function NormalizeThresholds(source)
    local out, known = {}, {}
    for i = 1, #source do
        local stored = source[i]
        local entry
        if type(stored) == "table" then
            if type(stored.pct) == "number" then
                entry = { value = stored.pct }
                for f = 1, #ENTRY_FIELDS do
                    entry[ENTRY_FIELDS[f]] = stored[ENTRY_FIELDS[f]]
                end
            end
        elseif type(stored) == "number" then
            entry = { value = stored }
        end
        if entry and not known[entry.value] then
            known[entry.value] = true
            out[#out + 1] = entry
        end
    end
    table.sort(out, function(a, b) return a.value > b.value end)
    return out
end

-- All config levels merge: per-boss override, zone thresholds, shipped
-- per-boss defaults and global defaults each contribute their alerts.
-- NormalizeThresholds keeps the FIRST occurrence of each percent, so
-- appending in precedence order (boss > zone > shipped > global) makes the
-- most specific level win same-percent conflicts. Always returns fresh,
-- descending-sorted entries. Shipped data is read live (never copied into
-- saved variables), so addon updates with corrected data propagate.
function THR.GetThresholdsFor(zoneId, bossName)
    local SV = THR.SV
    local zone = SV.zones[zoneId]
    local merged = {}
    local function append(source)
        if not source then return end
        for i = 1, #source do
            merged[#merged + 1] = source[i]
        end
    end
    if zone then
        if bossName and zone.bosses then
            append(zone.bosses[bossName])
        end
        append(zone.thresholds)
    end
    append(THR.GetShippedThresholds(zoneId, bossName))
    append(SV.globalThresholds)
    return NormalizeThresholds(merged)
end

-- Push updated config into live subjects (called after menu changes).
function THR.ReapplyThresholds()
    for _, subject in pairs(THR.subjects) do
        subject.thresholds = THR.GetThresholdsFor(THR.currentZoneId, subject.name)
        Engine.Reseed(subject, subject.lastPct)
    end
    THR.RefreshDisplay()
end

---------------------------------------------------------------------------
-- BOSS ACQUISITION
---------------------------------------------------------------------------
-- Enumerate boss1..boss6 and sync the subject list. Same-named bosses
-- (shared-health twins) collapse into one subject; an existing subject is
-- rebound to its new tag with fired state intact, so boss-bar flicker never
-- replays alerts.
function THR.ScanBosses()
    if not THR.isEnabled then return end

    local seen = {}
    THR.subjectKeyByTag = {}

    for i = 1, #THR.BOSS_TAGS do
        local tag = THR.BOSS_TAGS[i]
        if DoesUnitExist(tag) then
            local current, maximum = GetUnitPower(tag, COMBAT_MECHANIC_FLAGS_HEALTH)
            if maximum and maximum > 0 then
                local name = THR.GetCleanName(GetUnitName(tag))
                if name ~= "" then
                    local key = "boss:" .. name
                    THR.subjectKeyByTag[tag] = key

                    local subject = THR.subjects[key]
                    if not subject then
                        subject = Engine.CreateSubject(key, name,
                            THR.GetThresholdsFor(THR.currentZoneId, name),
                            current / maximum * 100)
                    end
                    if not seen[key] then
                        subject.tag = tag
                    end
                    seen[key] = true
                end
            end
        end
    end

    for key in pairs(THR.subjects) do
        if not seen[key] then
            Engine.RemoveSubject(key)
        end
    end

    THR.RefreshDisplay()
end

---------------------------------------------------------------------------
-- ENGINE CALLBACKS
---------------------------------------------------------------------------
-- Only the lowest threshold crossed in one hit is announced; the skipped
-- ones are still marked in the dedupe table so a boss-bar flicker or a
-- shared-health twin cannot re-announce them later in the same combat.
-- crossedValues holds { value, text } entries (see THR.GetThresholdsFor).
-- Alerts only fire while the player is in combat; crossings observed out
-- of combat (released after a wipe, someone else fighting the boss) are
-- still deduped so entering the fight late never replays them.
function THR.OnThresholdCrossed(subject, crossedValues)
    local lowest = crossedValues[#crossedValues]
    local shouldAlert = not THR.dedupe[subject.name .. ":" .. lowest.value]
    for i = 1, #crossedValues do
        THR.dedupe[subject.name .. ":" .. crossedValues[i].value] = true
    end
    if shouldAlert and THR.isCombat then
        THR.FireAlert(subject.name, lowest)
    end
end

function THR.OnSubjectUpdated(subject)
    THR.UpdateSubjectRow(subject)
end

---------------------------------------------------------------------------
-- EVENT HANDLERS
---------------------------------------------------------------------------
function THR.OnPowerUpdate(_, unitTag, _, _, powerValue, powerMax)
    local key = THR.subjectKeyByTag[unitTag]
    if key then
        Engine.OnHealthSample(key, powerValue, powerMax)
    end
end

function THR.OnBossesChanged()
    THR.ScanBosses()
end

function THR.OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= THR.currentZoneId then
        THR.currentZoneId = zoneId
        THR.subjects = {}
        THR.subjectKeyByTag = {}
        THR.dedupe = {}
    end
    THR.isCombat = IsUnitInCombat("player")
    THR.ScanBosses()
end

function THR.OnCombatStateChanged(_, inCombat)
    THR.isCombat = inCombat
    if not inCombat then
        THR.dedupe = {}
        Engine.ResetAll()
    end
    THR.ScanBosses()
end

---------------------------------------------------------------------------
-- ENABLE / DISABLE
---------------------------------------------------------------------------
function THR.Enable()
    if THR.isEnabled then return end
    THR.isEnabled = true

    local ns = THR.name
    EVENT_MANAGER:RegisterForEvent(ns .. "_Activated", EVENT_PLAYER_ACTIVATED, THR.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ns .. "_Bosses", EVENT_BOSSES_CHANGED, THR.OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent(ns .. "_Combat", EVENT_PLAYER_COMBAT_STATE, THR.OnCombatStateChanged)

    -- One filtered registration per boss tag; the server then only sends us
    -- health updates for actual boss units.
    for i = 1, #THR.BOSS_TAGS do
        local tag = THR.BOSS_TAGS[i]
        local puNs = ns .. "_PU_" .. tag
        EVENT_MANAGER:RegisterForEvent(puNs, EVENT_POWER_UPDATE, THR.OnPowerUpdate)
        EVENT_MANAGER:AddFilterForEvent(puNs, EVENT_POWER_UPDATE,
            REGISTER_FILTER_UNIT_TAG, tag,
            REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
    end

    THR.OnPlayerActivated()
end

function THR.Disable()
    if not THR.isEnabled then return end
    THR.isEnabled = false

    local ns = THR.name
    EVENT_MANAGER:UnregisterForEvent(ns .. "_Activated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(ns .. "_Bosses", EVENT_BOSSES_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ns .. "_Combat", EVENT_PLAYER_COMBAT_STATE)
    for i = 1, #THR.BOSS_TAGS do
        EVENT_MANAGER:UnregisterForEvent(ns .. "_PU_" .. THR.BOSS_TAGS[i], EVENT_POWER_UPDATE)
    end

    THR.subjects = {}
    THR.subjectKeyByTag = {}
    THR.dedupe = {}
    THR.RefreshDisplay()
end
