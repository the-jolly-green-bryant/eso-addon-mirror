---------------------------------------------------------------------------
-- Thresholds - threshold engine
--
-- Pure bookkeeping over health samples; no unit tags or ESO unit calls in
-- here. Subjects are keyed by an arbitrary string, so a future module can
-- feed samples for adds (keyed by unitId or name) through the same engine.
--
-- thresholds are { value = number, text = string|nil } entries as returned
-- by THR.GetThresholdsFor (sorted descending by value).
--
-- Emits through two optional callbacks on the addon table:
--   THR.OnThresholdCrossed(subject, crossedEntries)  -- sorted desc by value
--   THR.OnSubjectUpdated(subject)
---------------------------------------------------------------------------

local THR = Thresholds

THR.Engine = {}
local Engine = THR.Engine

-- Point nextIdx at the highest threshold strictly below pct, so joining a
-- fight in progress never replays thresholds that have already passed.
function Engine.Reseed(subject, pct)
    subject.nextIdx = 1
    while subject.nextIdx <= #subject.thresholds
            and subject.thresholds[subject.nextIdx].value >= pct do
        subject.nextIdx = subject.nextIdx + 1
    end
    subject.lastPct = pct
end

-- thresholds must be sorted descending (THR.GetThresholdsFor guarantees it)
function Engine.CreateSubject(key, name, thresholds, initialPct)
    local subject = {
        key = key,
        name = name,
        thresholds = thresholds,
        nextIdx = 1,
        lastPct = initialPct,
        isDead = false,
    }
    Engine.Reseed(subject, initialPct)
    THR.subjects[key] = subject
    return subject
end

function Engine.RemoveSubject(key)
    THR.subjects[key] = nil
end

-- Re-arm every subject against its current health. Called on combat end so
-- the next pull starts fresh; already-passed thresholds stay skipped.
function Engine.ResetAll()
    for _, subject in pairs(THR.subjects) do
        Engine.Reseed(subject, subject.lastPct)
    end
end

function Engine.OnHealthSample(key, current, maximum)
    local subject = THR.subjects[key]
    if not subject or not maximum or maximum <= 0 then return end

    -- The game repeats power updates with unchanged values; when nothing
    -- moved there is nothing to cross and nothing to repaint.
    if current == subject.lastCurrent and maximum == subject.lastMax then
        return
    end
    subject.lastCurrent = current
    subject.lastMax = maximum

    local pct = current / maximum * 100

    if current <= 0 then
        -- Dead: show 0% but never cascade the remaining thresholds.
        subject.isDead = true
        subject.lastPct = 0
        if THR.OnSubjectUpdated then THR.OnSubjectUpdated(subject) end
        return
    end
    subject.isDead = false

    if pct >= subject.lastPct then
        if THR.isCombat then
            -- Heals and shields never re-arm mid-fight; a threshold fires
            -- once per combat no matter how the health oscillates.
            subject.lastPct = pct
        else
            -- Out of combat the boss is resetting - re-arm accordingly.
            Engine.Reseed(subject, pct)
        end
        if THR.OnSubjectUpdated then THR.OnSubjectUpdated(subject) end
        return
    end

    local crossed = nil
    while subject.nextIdx <= #subject.thresholds
            and pct <= subject.thresholds[subject.nextIdx].value do
        crossed = crossed or {}
        crossed[#crossed + 1] = subject.thresholds[subject.nextIdx]
        subject.nextIdx = subject.nextIdx + 1
    end
    subject.lastPct = pct

    if crossed and THR.OnThresholdCrossed then
        THR.OnThresholdCrossed(subject, crossed)
    end
    if THR.OnSubjectUpdated then THR.OnSubjectUpdated(subject) end
end
