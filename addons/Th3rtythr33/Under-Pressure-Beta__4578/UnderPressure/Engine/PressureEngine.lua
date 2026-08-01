-- =============================================================================
-- Under Pressure -- PressureEngine.lua
-- =============================================================================
-- Core model. Maintains rolling damage and effect windows, computes the
-- estimated time-to-die under "no healing, no mitigation from now" hypothesis,
-- and decides the current visual state.
--
-- HISTORY: prior versions distinguished damage by sourceType (player vs NPC
-- vs unknown) and tracked a separate damage shield pool via shieldPower. The
-- ESO console runtime does NOT expose either of those APIs at this time, so
-- those paths were removed in 0.2.6. The model now treats every damage event
-- uniformly and uses raw health for time-to-die.
-- =============================================================================

UP = UP or {}
UP.Engine = {}

-- ---------------------------------------------------------------------------
-- State enumeration
-- ---------------------------------------------------------------------------
UP.STATE = {
    GREEN_SQUARE   = "green_square",        -- safe / low current pressure
    YELLOW_EMPTY   = "yellow_empty",        -- recent damage but not lethal
    YELLOW_FILLED  = "yellow_filled",       -- moderate pressure, ttd 3-6s
    RED_ONE        = "red_one",             -- ttd 2-3s
    RED_TWO        = "red_two",             -- ttd 1-2s
    RED_THREE      = "red_three",           -- ttd < 1s
}

-- ---------------------------------------------------------------------------
-- Tunables (overridden by saved variables)
-- ---------------------------------------------------------------------------
UP.Defaults = {
    -- Window weight multipliers
    weight_1s        = 1.25,
    weight_2s        = 1.15,
    weight_3s        = 1.00,
    weight_6s        = 0.75,

    -- Single risk-bonus weight applied to all active debuffs. (Previously
    -- split into effect_player_weight / effect_npc_weight / effect_unknown
    -- but sourceType is not available so the split was a no-op.)
    effect_weight    = 1.00,

    -- Burst multiplier: if >50% of the 2s damage arrived in the last 0.5s,
    -- multiply pressure by this. Tunable 1.0 (off) to ~2.0.
    burst_share_threshold = 0.50,
    burst_multiplier      = 1.20,

    -- Execute threshold: at or below this health %, execute risk bonus
    -- magnifies. Default mirrors common ESO execute thresholds (25%).
    execute_health_pct    = 0.25,
    execute_amplifier     = 2.0,

    -- Floor used in division to avoid TTD blowup with no recent damage.
    pressure_floor        = 100,    -- DPS minimum when computing TTD

    -- State decision thresholds (seconds)
    red_three_ttd         = 1.0,
    red_two_ttd           = 2.0,
    red_one_ttd           = 3.0,
    yellow_filled_ttd     = 6.0,

    -- "Recent damage" window for yellow_empty / green_square decision
    recent_pressure_window_s = 10.0,

    -- Persistence interval: a new state must hold this long before being shown
    state_persistence_ms     = 200,

    -- Effect (debuff) lingering window in ms after FADED
    effect_lingering_ms      = 500,

    -- Attacker counter window
    attacker_window_s        = 3,
}

-- ---------------------------------------------------------------------------
-- Runtime state
-- ---------------------------------------------------------------------------
local state = {
    damageEvents = {},   -- list of {t, amount} sorted by t ascending; trimmed periodically
    activeEffects = {},  -- abilityId -> {category, gainedT, endT, fadedAt}
    lastPowerUpdate = 0,
    currentHealth   = 0,
    maxHealth       = 1,
    inCombat        = false,

    candidateState  = nil,
    candidateSince  = 0,
    publishedState  = "green_square",
    publishedSince  = 0,

    lastPressureDps    = 0,
    lastTtd            = math.huge,
    lastBurstMul       = 1.0,
    lastRiskBonus      = 0,
}

UP.Engine.state = state  -- exposed for debug overlay

-- ---------------------------------------------------------------------------
-- Public ingest entry points (called from EventIngest)
-- ---------------------------------------------------------------------------
function UP.Engine.IngestEvent(event)
    if event.kind == "damage" or event.kind == "shieldHit" then
        table.insert(state.damageEvents, {
            t = event.t,
            amount = event.amount,
        })
        state.lastPressureDamageT = event.t
    elseif event.kind == "effect" then
        local FADED = (type(EFFECT_RESULT_FADED) == "number") and EFFECT_RESULT_FADED or 2
        if event.changeType == FADED then
            local rec = state.activeEffects[event.abilityId]
            if rec then rec.fadedAt = event.t end
        else
            state.activeEffects[event.abilityId] = {
                category   = event.category,
                gainedT    = event.t,
                endT       = event.endTime,
                fadedAt    = nil,
            }
        end
    end
end

function UP.Engine.UpdatePower(powerType, value, max)
    if type(COMBAT_MECHANIC_FLAGS_HEALTH) == "number" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        state.currentHealth = value
        state.maxHealth     = max > 0 and max or 1
    end
    -- Damage-shield power updates are intentionally ignored: the console
    -- runtime does not expose COMBAT_MECHANIC_FLAGS_DAMAGE_SHIELD reliably.
    state.lastPowerUpdate = GetGameTimeMilliseconds()
end

function UP.Engine.SetCombatState(inCombat)
    state.inCombat = inCombat
end

function UP.Engine.InCombat()
    return state.inCombat == true
end

-- ---------------------------------------------------------------------------
-- Math helpers
-- ---------------------------------------------------------------------------
local function sumDamageSince(now_ms, window_s)
    local cutoff = now_ms - (window_s * 1000)
    local total = 0
    for i = #state.damageEvents, 1, -1 do
        local e = state.damageEvents[i]
        if e.t < cutoff then break end
        total = total + e.amount
    end
    return total
end

local function trimDamageBuffer(now_ms)
    -- Drop events older than the largest window (6s) plus a safety margin.
    local horizon = now_ms - 8000
    while state.damageEvents[1] and state.damageEvents[1].t < horizon do
        table.remove(state.damageEvents, 1)
    end
end

local function expireEffects(now_ms, tunables)
    for id, rec in pairs(state.activeEffects) do
        local linger = tunables.effect_lingering_ms or UP.Defaults.effect_lingering_ms
        local expired = false
        if rec.fadedAt and (now_ms - rec.fadedAt) > linger then expired = true end
        if rec.endT and rec.endT > 0 and now_ms > (rec.endT + linger) then expired = true end
        if expired then state.activeEffects[id] = nil end
    end
end

local function aggregateRiskBonus(tunables)
    -- Sum risk bonuses across all currently active debuffs. Each category
    -- contributes its highest-base instance at most once to avoid stacking
    -- the same threat from multiple casters.
    local seen = {}        -- category -> best weighted bonus
    local categories = {}  -- category -> true (presence flag for execute amp)
    local w = tunables.effect_weight or UP.Defaults.effect_weight
    for _, rec in pairs(state.activeEffects) do
        local base = UP.Classifier.bonusFor(rec.category)
        local weighted = base * w
        if (not seen[rec.category]) or (weighted > seen[rec.category]) then
            seen[rec.category] = weighted
        end
        categories[rec.category] = true
    end
    local total = 0
    for _, v in pairs(seen) do total = total + v end
    return total, categories
end

-- ---------------------------------------------------------------------------
-- The core calculation
-- ---------------------------------------------------------------------------
local function computePressure(now_ms, tunables)
    local d1 = sumDamageSince(now_ms, 1.0)
    local d2 = sumDamageSince(now_ms, 2.0)
    local d3 = sumDamageSince(now_ms, 3.0)
    local d6 = sumDamageSince(now_ms, 6.0)

    local dps1 = d1 / 1.0
    local dps2 = d2 / 2.0
    local dps3 = d3 / 3.0
    local dps6 = d6 / 6.0

    local pressureDps = math.max(
        dps1 * tunables.weight_1s,
        dps2 * tunables.weight_2s,
        dps3 * tunables.weight_3s,
        dps6 * tunables.weight_6s
    )

    -- Burst multiplier: detect spike in the last 0.5s
    local d_half = sumDamageSince(now_ms, 0.5)
    local burstMul = 1.0
    if d2 > 0 and (d_half / d2) > tunables.burst_share_threshold then
        burstMul = tunables.burst_multiplier
    end

    local riskBonus, categoriesSeen = aggregateRiskBonus(tunables)

    -- Execute amplification at low health
    local healthPct = (state.maxHealth > 0) and (state.currentHealth / state.maxHealth) or 1.0
    if categoriesSeen[UP.RISK.EXECUTE] and healthPct <= tunables.execute_health_pct then
        riskBonus = riskBonus * tunables.execute_amplifier
    end

    local adjustedDps = (pressureDps * burstMul) + riskBonus
    if adjustedDps < tunables.pressure_floor then adjustedDps = tunables.pressure_floor end

    local ehp = state.currentHealth or 0
    local ttd = ehp / adjustedDps  -- seconds

    state.lastPressureDps = adjustedDps
    state.lastTtd         = ttd
    state.lastBurstMul    = burstMul
    state.lastRiskBonus   = riskBonus

    return ttd, d6
end

local function decideState(ttd, d6, now_ms, tunables)
    local recentDmgWindow = sumDamageSince(now_ms, tunables.recent_pressure_window_s)
    local hasActiveDebuff = next(state.activeEffects) ~= nil

    if ttd < tunables.red_three_ttd then
        return UP.STATE.RED_THREE
    elseif ttd < tunables.red_two_ttd then
        return UP.STATE.RED_TWO
    elseif ttd < tunables.red_one_ttd then
        return UP.STATE.RED_ONE
    elseif ttd < tunables.yellow_filled_ttd then
        return UP.STATE.YELLOW_FILLED
    elseif recentDmgWindow > 0 or hasActiveDebuff then
        return UP.STATE.YELLOW_EMPTY
    else
        return UP.STATE.GREEN_SQUARE
    end
end

-- ---------------------------------------------------------------------------
-- Tick loop
-- ---------------------------------------------------------------------------
local function getTunables()
    local sv = UnderPressureSavedVars and UnderPressureSavedVars.tunables
    if not sv then return UP.Defaults end
    local merged = {}
    for k, v in pairs(UP.Defaults) do merged[k] = (sv[k] ~= nil) and sv[k] or v end
    return merged
end

function UP.Engine.Tick()
    if not UP.features or not UP.features.gameTime then return end
    local now_ms = GetGameTimeMilliseconds()
    local tunables = getTunables()

    trimDamageBuffer(now_ms)
    expireEffects(now_ms, tunables)

    -- If health is unknown (addon just loaded), pull a snapshot.
    if state.maxHealth <= 1 then
        local h, hmax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
        if h and hmax then
            state.currentHealth = h
            state.maxHealth = hmax > 0 and hmax or 1
        end
    end

    local ttd, d6 = computePressure(now_ms, tunables)
    local newState = decideState(ttd, d6, now_ms, tunables)

    -- Persistence: only publish a state change after the new candidate has
    -- been stable for state_persistence_ms milliseconds.
    if newState ~= state.publishedState then
        if state.candidateState ~= newState then
            state.candidateState = newState
            state.candidateSince = now_ms
        elseif (now_ms - state.candidateSince) >= tunables.state_persistence_ms then
            state.publishedState = newState
            state.publishedSince = now_ms
            if UP.UI and UP.UI.SetState then UP.UI.SetState(newState) end
        end
    else
        state.candidateState = newState
        state.candidateSince = now_ms
    end
end

-- ---------------------------------------------------------------------------
-- Start / stop
-- ---------------------------------------------------------------------------
local TICK_NAMESPACE = "UnderPressure_Tick"
local TICK_INTERVAL_MS = 100  -- 10 Hz

function UP.Engine.Start()
    EVENT_MANAGER:RegisterForUpdate(TICK_NAMESPACE, TICK_INTERVAL_MS, UP.Engine.Tick)
end

function UP.Engine.Stop()
    EVENT_MANAGER:UnregisterForUpdate(TICK_NAMESPACE)
end

function UP.Engine.Snapshot()
    local attackerCount = 0
    local attackerMode = "solo"
    if UP.Attackers then
        attackerCount = UP.Attackers.Counts(GetGameTimeMilliseconds()) or 0
        attackerMode = UP.Attackers.Mode()
    end
    return {
        ttd              = state.lastTtd,
        pressureDps      = state.lastPressureDps,
        burstMul         = state.lastBurstMul,
        riskBonus        = state.lastRiskBonus,
        publishedState   = state.publishedState,
        candidateState   = state.candidateState,
        health           = state.currentHealth,
        maxHealth        = state.maxHealth,
        activeEffects    = state.activeEffects,
        damageEventCount = #state.damageEvents,
        attackerCount    = attackerCount,
        attackerMode     = attackerMode,
        inCombat         = state.inCombat,
    }
end
