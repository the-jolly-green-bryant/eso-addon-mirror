--[[----------------------------------------------------------------------
    Dynamic Encounters : Predictor
    Standalone, drop-in respawn prediction engine. No UI, no events â€”
    feed it observations, ask it for predictions. Pure Lua 5.1, ESO-safe
    (no os.*, no io.*, plain-table state suitable for SavedVariables).

    THE MODEL
    ---------
    Dynamic Encounters appear to respawn a cooldown T after the previous
    encounter ENDS (not on a wall-clock schedule). Each full cycle is
    C = T + D, where D is the encounter's running duration.

    We estimate:
      T  : recency-weighted median of implied-cooldown samples
      D  : EMA of observed durations
      spread : recency-weighted MAD (median absolute deviation) of samples

    MISSED CYCLES (the login/logout problem)
    ----------------------------------------
    If the player is absent for m full cycles, the observed end->start
    gap is  G = m*T + (m-1)*D.  Solving:  m = (G + D) / (T + D).
    We round to get m-hat, then recover ONE implied-T sample:
        implied_T = (G - (m-hat - 1) * D) / m-hat
    and down-weight it by 1/m-hat (multi-cycle inference is fuzzier).
    Example: T=30m, D=5m, absent 95m -> m-hat = round(100/35) = 3,
    implied_T = (95 - 10)/3 = 28m20s. Accepted, weight 1/3.

    PERIOD vs ANCHOR (the shard problem)
    ------------------------------------
    The period T is a server-wide property and travels well. The PHASE
    ANCHOR (lastEnd) is shard-local and perishable: every loading screen
    risks landing you on a different clock. So: prediction misses first
    re-anchor; they only reshape T if implied-T samples themselves drift
    consistently (drift purge). Never flush T samples because the anchor
    was stale.

    CONFIDENCE
    ----------
    Product of four honest factors in [0,1]:
      evidence   n_eff / (n_eff + 2)           -- decayed sample mass
      consistency exp(-3 * MAD / T)            -- relative spread
      anchor     decays with missed cycles, loading screens,
                 and end-time uncertainty
      track      exp(-2 * mean recent |error|/C) -- were we right lately?

----------------------------------------------------------------------]]--

DynamicEncounters = DynamicEncounters or {}
local HE = DynamicEncounters

local Predictor = {}
Predictor.__index = Predictor
HE.Predictor = Predictor

-- tunables ------------------------------------------------------------
local GAP_MIN            = 5 * 60
local GAP_MAX            = 90 * 60
local DEFAULT_COOLDOWN   = 30 * 60
local DEFAULT_DURATION   = 6 * 60
local MAX_SAMPLES        = 16
local MAX_SCORES         = 6
local HALF_LIFE_S        = 4 * 3600     -- recency half-life for samples
local DUR_EMA_ALPHA      = 0.3
local ANCHOR_LOAD_DECAY  = 0.90         -- per loading screen after end
local ANCHOR_MISS_DECAY  = 0.85         -- per unobserved cycle
local DRIFT_REL          = 0.25         -- drift purge threshold
local MIN_WINDOW_S       = 180   -- 3 min minimum grace before rolling prediction forward

-- construction --------------------------------------------------------

-- state: a plain table you own (e.g. a SavedVariables subtable).
function Predictor.New(state)
    state.samples = state.samples or {}   -- { {t=obsTime, cd=impliedT, w=baseWeight}, ... }
    state.scores  = state.scores  or {}   -- recent |prediction error| / C, newest last
    state.quarantine = state.quarantine or {}  -- believable-but-disagreeing gaps
    state.durEma  = state.durEma  or nil
    state.anchor  = state.anchor  or {}   -- lastEnd, endUncertainty, loads, lastStart, startObserved
    -- Track whether the player was in-zone for the entire cooldown gap.
    -- If the player left and came back, the gap is unreliable for learning.
    state.anchor.zoneExitDuringGap = state.anchor.zoneExitDuringGap or false
    return setmetatable({ s = state }, Predictor)
end

-- internals -----------------------------------------------------------

local function decayedWeight(sample, now)
    local age = math.max(0, now - (sample.t or now))
    return (sample.w or 1) * (0.5 ^ (age / HALF_LIFE_S))
end

-- weighted median and weighted MAD of implied-cooldown samples
local function robustStats(samples, now)
    local items, total = {}, 0
    for i = 1, #samples do
        local w = decayedWeight(samples[i], now)
        if w > 0.001 then
            items[#items + 1] = { v = samples[i].cd, w = w }
            total = total + w
        end
    end
    if total == 0 then return nil, nil, 0 end

    table.sort(items, function(a, b) return a.v < b.v end)
    local function weightedMedian(list, tot)
        local acc = 0
        for i = 1, #list do
            acc = acc + list[i].w
            if acc >= tot / 2 then return list[i].v end
        end
        return list[#list].v
    end

    local median = weightedMedian(items, total)
    local devs = {}
    for i = 1, #items do
        devs[#devs + 1] = { v = math.abs(items[i].v - median), w = items[i].w }
    end
    table.sort(devs, function(a, b) return a.v < b.v end)
    local mad = weightedMedian(devs, total)
    return median, mad, total
end

function Predictor:GetCooldown(now)
    local median, mad, neff = robustStats(self.s.samples, now)
    return median or DEFAULT_COOLDOWN, mad or 0, neff or 0
end

function Predictor:GetDuration()
    return self.s.durEma or DEFAULT_DURATION
end

function Predictor:GetCycle(now)
    local T = self:GetCooldown(now)
    return T + self:GetDuration(), T
end

-- purge stale majority if the three newest samples agree the world moved
local function driftPurge(samples)
    local n = #samples
    if n < 6 then return end
    local old = {}
    for i = 1, n - 3 do old[#old + 1] = samples[i].cd end
    table.sort(old)
    local oldMed = old[math.ceil(#old / 2)]
    local dir
    for i = n - 2, n do
        local dev = samples[i].cd - oldMed
        if math.abs(dev) <= DRIFT_REL * oldMed then return end
        local d = dev > 0 and 1 or -1
        if dir and d ~= dir then return end
        dir = d
    end
    -- consistent regime change: keep only the three fresh witnesses
    local fresh = { samples[n - 2], samples[n - 1], samples[n] }
    for i = n, 1, -1 do samples[i] = nil end
    for i = 1, 3 do samples[i] = fresh[i] end
end

-- observations ----------------------------------------------------------

-- Call when an encounter visibly begins.
-- Returns a small report table (useful for debug logging).
function Predictor:OnEventStart(now)
    local a = self.s.anchor
    local report = { accepted = false }

    -- score the standing prediction, if we had one
    local pred = self._lastPrediction
    if pred and pred.at then
        local C = select(1, self:GetCycle(now))
        local err = math.abs(now - pred.at) / C
        local scores = self.s.scores
        scores[#scores + 1] = math.min(err, 1)
        while #scores > MAX_SCORES do table.remove(scores, 1) end
        report.predictionError = err
    end

    if a.lastEnd then
        local G = now - a.lastEnd
        -- DEFENSE B: Gap sanity cap -- reject absurdly long gaps as unreliable.
        -- A gap > 2x GAP_MAX means the player was almost certainly away.
        -- The gap is still valid for prediction (it sets the cycle count),
        -- but it shouldn't contribute a sample to learning.
        local gapTooLong = G > (GAP_MAX * 2)
        -- DEFENSE A: Zone-presence check -- if the player left the zone
        -- during this cooldown, we can't trust the gap measurement.
        local zoneContaminated = a.zoneExitDuringGap or gapTooLong
        local D = self:GetDuration()

        local T, mad, neff = self:GetCooldown(now)
        T = math.max(DEFAULT_COOLDOWN, math.min(T, 2400))  -- clamp 30-40 min for acceptance gate
        local C = T + D  -- use learned cycle for accurate inference

        local m = math.max(1, math.floor((G + D) / C + 0.5))
        local impliedT = (G - (m - 1) * D) / m

        -- if the rounded m gives an implausible T, search m+-3
        if (impliedT < GAP_MIN or impliedT > GAP_MAX) then
            for offset = -3, 3 do
                local mAlt = m + offset
                if mAlt >= 1 then
                    local tAlt = (G - (mAlt - 1) * D) / mAlt
                    if tAlt >= GAP_MIN and tAlt <= GAP_MAX then
                        m, impliedT = mAlt, tAlt
                        break
                    end
                end
            end
        end

        local plausible = impliedT >= GAP_MIN and impliedT <= GAP_MAX
        -- Skip learning if the gap was contaminated by zone exit / absurd length
        if zoneContaminated then plausible = false end
        if plausible and neff >= 3 then
            -- with real evidence, also require agreement with the estimate
            local tol = math.max(0.35 * T, 3 * math.max(mad, 15))
            plausible = math.abs(impliedT - T) <= tol
        end

        if plausible then
            local loads = a.loads or 0
            local weight = (1 / m)
                         * (ANCHOR_LOAD_DECAY ^ loads)
                         * (a.endUncertainty and math.max(0.25, 1 - a.endUncertainty / C) or 1)
            local samples = self.s.samples
            samples[#samples + 1] = { t = now, cd = impliedT, w = weight }
            while #samples > MAX_SAMPLES do table.remove(samples, 1) end
            driftPurge(samples)
            self.s.quarantine = {}   -- quarantined sample indicates no regime shift
            report.accepted, report.impliedT, report.cycles, report.weight = true, impliedT, m, weight
        elseif impliedT >= GAP_MIN and impliedT <= GAP_MAX then
            -- disagreed with the current estimate but is a believable gap:
            -- quarantine it. Three consecutive quarantined samples that agree
            -- with EACH OTHER mean the world changed (patch / new shard clock)
            -- and they become the new regime.
            local q = self.s.quarantine or {}
            self.s.quarantine = q
            q[#q + 1] = { t = now, cd = impliedT }
            while #q > 4 do table.remove(q, 1) end
            if #q == 4 then
                local lo, hi = math.huge, -math.huge
                local sum = 0
                for i = 1, 3 do
                    lo, hi = math.min(lo, q[i].cd), math.max(hi, q[i].cd)
                    sum = sum + q[i].cd
                end
                local qMed = sum / 3
                if (hi - lo) <= 0.2 * qMed then
                    local samples = self.s.samples
                    for i = #samples, 1, -1 do samples[i] = nil end
                    for i = 1, 3 do
                        samples[i] = { t = q[i].t, cd = q[i].cd, w = 1 }
                    end
                    self.s.scores = {}       -- old track record judged the old world
                    self.s.quarantine = {}
                    report.regimeShift = true
                    -- Weight is 1.0 for regime-shifted samples because they
                    -- replace the entire sample set with fresh observations.
                    report.accepted, report.impliedT, report.cycles, report.weight = true, impliedT, m, 1.0
                end
            end
            if not report.accepted then
                report.rejectedT, report.cycles, report.quarantined = impliedT, m, true
            end
        else
            report.rejectedT, report.cycles = impliedT, m
        end
    end

    a.lastStart, a.startObserved = now, true
    -- Preserve lastEnd from the previous cycle: it remains a valid anchor
    -- even if the player leaves mid-cycle. Confidence decays naturally
    -- with loads (shard changes) and missed cycles in GetPrediction.
    a.loads = 0
    -- Reset zone exit flag for the new cycle (we're here NOW)
    a.zoneExitDuringGap = false
    self._lastPrediction = nil
    return report
end

-- Call when an encounter ends.
-- endUncertainty: seconds of slack if the exact end was not witnessed
-- (e.g. detected missing on rescan: pass the observation gap). 0/nil = exact.
function Predictor:OnEventEnd(now, endUncertainty)
    local a = self.s.anchor
    if a.startObserved and a.lastStart and not endUncertainty then
        local d = now - a.lastStart
        if d > 30 and d < 45 * 60 then
            self.s.durEma = self.s.durEma and (self.s.durEma + DUR_EMA_ALPHA * (d - self.s.durEma)) or d
        end
    end
    a.lastEnd = now - (endUncertainty and endUncertainty / 2 or 0)
    a.endUncertainty = endUncertainty or 0
    a.loads = 0
    a.zoneExitDuringGap = false  -- we just witnessed the end; cooldown starts NOW
    a.lastStart, a.startObserved = nil, nil
end

-- Call on every loading screen / zone transition (shards may change).
function Predictor:OnLoadingScreen()
    local a = self.s.anchor
    if a.lastEnd then
        a.loads = (a.loads or 0) + 1
        -- Player left the zone (or changed shard). The current gap is now
        -- unreliable because we don't know what happened while we were gone.
        a.zoneExitDuringGap = true
    end
end

-- Call when the player leaves the zone entirely (not just shard change).
function Predictor:OnZoneExit()
    local a = self.s.anchor
    if a.lastEnd then
        a.zoneExitDuringGap = true
    end
end

-- The anchor is shard-local; call this if evidence says our clock is wrong
-- (e.g. an encounter is visibly active when we predicted deep cooldown).
function Predictor:InvalidateAnchor()
    local a = self.s.anchor
    a.lastEnd, a.endUncertainty, a.loads = nil, nil, 0
    self._lastPrediction = nil
end

-- Record a sighting of the encounter in any state (start/active/end).
-- This feeds the Estimated prediction tier, which always works because
-- it only needs lastSeen + cooldown â€” no cycle completion required.
function Predictor:RecordLastSeen(now, seenType)
    local a = self.s.anchor
    -- For "active" observations: only record the FIRST time we see it active
    -- in a given cycle. Repeat observations of the same active encounter
    -- should not update lastSeenTime, so we can estimate remaining duration
    -- as: D - (time_since_first_observation).
    if seenType == "active" and a.lastSeenType == "active" then
        return  -- already tracking this active period; keep the original timestamp
    end
    a.lastSeenTime = now
    a.lastSeenType = seenType  -- "start", "active", or "end"
end

-- Simple prediction using lastSeen + cooldown with phase correction.
-- Always available (unlike GetPrediction which requires a cycle anchor).
-- Confidence is lower but improves as we learn the cooldown.
function Predictor:GetEstimatedPrediction(now)
    local a = self.s.anchor
    if not a.lastSeenTime then return nil end

    local T, _, neff = self:GetCooldown(now)
    local D = self:GetDuration()
    local C = T + D

    -- Phase correction based on observation type
    local predicted
    if a.lastSeenType == "end" then
        predicted = a.lastSeenTime + T           -- next start = end + cooldown
    elseif a.lastSeenType == "start" then
        predicted = a.lastSeenTime + D + T       -- next = active duration + cooldown
    else  -- "active" or unknown: we saw it already running
        -- Anchor from lastSeenTime (when we first observed it active).
        -- Use D/2 as the expected elapsed time (uniform arrival within
        -- the encounter window). This avoids consistently overestimating
        -- the remaining time by the full duration.
        -- IMPORTANT: Do NOT use "now + remainingActive + T" -- when
        -- remainingActive reaches 0, the now terms cancel out and
        -- the timer freezes at T (30:00 with default cooldown).
        -- Bug confirmed 2026-07-17: Glenumbra timer frozen at 30:00.
        predicted = a.lastSeenTime + T + D * 0.5
    end

    -- Roll forward past missed cycles
    while predicted < now do
        predicted = predicted + C
    end

    local remaining = math.max(0, predicted - now)
    return {
        at = predicted,
        remaining = remaining,
        confidence = math.floor(30 * math.min(1, neff / 4) + 0.5),
        cooldown = T,
        duration = D,
        samples = neff,
    }
end

-- prediction ------------------------------------------------------------

-- Returns nil if there is nothing to anchor on, otherwise:
-- { at, low, high, missedCycles, confidence (0-100), cooldown, duration,
--   spread, samples (effective) }
function Predictor:GetPrediction(now)
    local a = self.s.anchor
    if not a.lastEnd then return nil end

    local T, mad, neff = self:GetCooldown(now)
    -- Use the learned cooldown BUT clamp to a sane range:
    --   min: DEFAULT_COOLDOWN (30 min) -- never show less than baseline
    --   max: 2400 (40 min) -- if the learned value is wild, rein it in
    -- The learned value converges to the true shard timing over time.
    T = math.max(DEFAULT_COOLDOWN, math.min(T, 2400))
    local D = self:GetDuration()
    local C = T + D

    -- STALE ANCHOR DETECTION: If the player left the zone since the last
    -- encounter ended, the anchor (a.lastEnd) may be hours old and belong
    -- to a different shard.  Blindly rolling forward from a stale anchor
    -- produces nonsensical multi-cycle countdowns (70+ min).  Instead,
    -- snap to the nearest past cycle boundary -- this preserves the shard's
    -- phase while anchoring the countdown to a stable point so the display
    -- actually counts down rather than freezing.
    -- The zoneExitDuringGap flag is reset by OnEventStart when the next
    -- encounter actually begins, restoring the real anchor.
    local anchorEnd = a.lastEnd
    if a.zoneExitDuringGap and (now - a.lastEnd) > C then
        local cyclesSince = math.floor((now - a.lastEnd) / C)
        anchorEnd = a.lastEnd + cyclesSince * C
    end

    -- roll the anchor forward past cycles we evidently missed
    local predicted = anchorEnd + T
    local missed = 0
    local halfWidth = math.max(MIN_WINDOW_S, 2 * math.max(mad, 20))
    while now > predicted + halfWidth * math.sqrt(1 + missed) + (a.endUncertainty or 0) do
        missed = missed + 1
        predicted = predicted + C
        if missed > 48 then return nil end -- anchor is ancient; give up honestly
    end
    halfWidth = halfWidth * math.min(5, math.sqrt(1 + missed)) + (a.endUncertainty or 0)

    -- confidence ---------------------------------------------------------
    local fEvidence = neff / (neff + 2)
    local fSpread   = math.exp(-3 * (neff > 0 and (mad / T) or 0.5))
    local fAnchor   = (ANCHOR_MISS_DECAY ^ missed)
                    * (ANCHOR_LOAD_DECAY ^ (a.loads or 0))
                    * math.exp(-((a.endUncertainty or 0) / C))
    local fTrack = 1
    local scores = self.s.scores
    if #scores > 0 then
        local sum = 0
        for i = 1, #scores do sum = sum + scores[i] end
        fTrack = math.exp(-2 * (sum / #scores))
    end
    local confidence = math.floor(100 * fEvidence * fSpread * fAnchor * fTrack + 0.5)

    local result = {
        at = predicted,
        low = predicted - halfWidth,
        high = predicted + halfWidth,
        missedCycles = missed,
        confidence = confidence,
        cooldown = T,
        duration = D,
        spread = mad,
        samples = neff,
    }
    self._lastPrediction = result
    return result
end

-- Optional word buckets for UI use.
function Predictor.ConfidenceLabel(confidence)
    if confidence >= 75 then return "locked-in" end
    if confidence >= 50 then return "good" end
    if confidence >= 25 then return "fair" end
    return "calibrating"
end
