-- RealisticNeedsAndDiseases_Calculator.lua
-- Decay-rate formulas for hunger/thirst/fatigue.
--
-- DESIGN INTENT (confirmed): meters decay NATURALLY at a flat baseline rate
-- regardless of temperature — that baseline never goes away. Environmental
-- temperature only ever ACCELERATES decay on top of that baseline; it never
-- slows decay below the natural rate. Concretely: the multiplier returned by
-- ExtremityRamp() is always >= 1 — it's exactly 1 inside the comfort band
-- (pure baseline decay, as if temperature didn't exist) and increases only
-- outside it.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Calc = {}
RN.Calculator = Calc

-- ─────────────────────────────────────────────────────────────────────────────
-- Temperature source resolution — Frostfall preferred, LibZoneTemp fallback,
-- nil (no coupling, pure baseline) if neither is present.
--
-- When Frostfall is active, RND reads the player's EFFECTIVE temperature via
-- Frostfall:GetEffectiveTemp() rather than the raw zone ambient temperature.
-- GetEffectiveTemp() returns FV.State.playerTemp (which already incorporates
-- armor insulation, weather/precipitation drag, swimming exposure, and drift
-- toward ambient) PLUS the live spell-resist reagent offset, if the player
-- has consumed a qualifying alchemy reagent (Bugloss, Mudcrab Chitin, Clam
-- Gall, or White Cap). This means hunger/thirst/fatigue decay acceleration
-- and frostbite/heatstroke exposure checks all reflect the player's FELT
-- temperature — not the raw zone temperature — when Frostfall is loaded.
--
-- NOTE: Frostfall is an OptionalDependsOn. ESO's version gate requires the
-- installed Frostfall version to be >= the floor declared in the manifest
-- (currently Frostfall>=3). If the gate fails, the Frostfall global is never
-- populated and this function falls through to the LibZoneTemp branch, which
-- returns ambient zone temperature only (no insulation/weather/reagent
-- effects). Check the ## OptionalDependsOn line in the .txt manifest if
-- Frostfall is installed but this branch isn't being reached.
--
--   Frostfall:GetEffectiveTemp() -> number (Celsius) — effective player temp
--   Frostfall.State.isSwimming -> boolean
--   LibZoneTemp.GetCurrentTemperature() -> number (Celsius) — ambient only
-- ─────────────────────────────────────────────────────────────────────────────
function Calc.GetCurrentTemperature()
    if Frostfall and Frostfall.GetEffectiveTemp then
        local ok, temp = pcall(function() return Frostfall:GetEffectiveTemp() end)
        if ok and type(temp) == "number" then
            return temp, "frostfall"
        end
    end
    if LibZoneTemp and LibZoneTemp.GetCurrentTemperature then
        local ok, temp = pcall(LibZoneTemp.GetCurrentTemperature)
        if ok and type(temp) == "number" then
            return temp, "libzonetemp"
        end
    end
    return nil, "none"
end

function Calc.GetIsSwimming()
    if Frostfall and Frostfall.State and Frostfall.State.isSwimming ~= nil then
        return Frostfall.State.isSwimming
    end
    return IsUnitSwimming("player")  -- own state only; allowed
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Base (natural) decay rate, derived from the player-adjustable "minutes to
-- empty" setting rather than a hardcoded constant. needName is "hunger",
-- "thirst", or "fatigue". Range supports as fast as 5 minutes full-to-empty
-- up to as slow as 2 hours (120 minutes).
-- ─────────────────────────────────────────────────────────────────────────────
function Calc.GetBaseRatePerSecond(sv, needName)
    local minutes = sv.settings.decayMinutes[needName] or 240
    if minutes <= 0 then minutes = 1 end  -- guard against div-by-zero from a bad slider value
    return 100 / (minutes * 60)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Comfort-band constants (Celsius).
-- ─────────────────────────────────────────────────────────────────────────────
Calc.COMFORT_MIN = 10
Calc.COMFORT_MAX = 25
Calc.HOT_THIRST_MULTIPLIER_MAX  = 2.5
Calc.COLD_HUNGER_MULTIPLIER_MAX = 2.0
Calc.EXTREME_FATIGUE_MULTIPLIER_MAX = 2.0
Calc.EXTREME_REFERENCE_RANGE = 20

-- Returns a 0..1 ramp for how far outside the comfort band, in the given
-- direction, the temperature is. ALWAYS >= 0 — never produces a value that
-- would push the resulting multiplier below 1.
local function ExtremityRamp(temp, direction)
    if direction == "hot" then
        if temp <= Calc.COMFORT_MAX then return 0 end
        return math.min(1, (temp - Calc.COMFORT_MAX) / Calc.EXTREME_REFERENCE_RANGE)
    else
        if temp >= Calc.COMFORT_MIN then return 0 end
        return math.min(1, (Calc.COMFORT_MIN - temp) / Calc.EXTREME_REFERENCE_RANGE)
    end
end

-- baseRatePerTick is the natural decay rate. Returned value is always
-- >= baseRatePerTick — temperature can only accelerate, never reduce, decay.
function Calc.GetThirstDecayRate(baseRatePerTick)
    local temp = Calc.GetCurrentTemperature()
    if not temp then return baseRatePerTick end
    local ramp = ExtremityRamp(temp, "hot")
    local multiplier = 1 + ramp * (Calc.HOT_THIRST_MULTIPLIER_MAX - 1)  -- always >= 1
    return baseRatePerTick * multiplier
end

function Calc.GetHungerDecayRate(baseRatePerTick)
    local temp = Calc.GetCurrentTemperature()
    if not temp then return baseRatePerTick end
    local ramp = ExtremityRamp(temp, "cold")
    local multiplier = 1 + ramp * (Calc.COLD_HUNGER_MULTIPLIER_MAX - 1)
    return baseRatePerTick * multiplier
end

function Calc.GetFatigueDecayRate(baseRatePerTick)
    local temp = Calc.GetCurrentTemperature()
    local tempMultiplier = 1
    if temp then
        local hotRamp  = ExtremityRamp(temp, "hot")
        local coldRamp = ExtremityRamp(temp, "cold")
        local ramp = math.max(hotRamp, coldRamp)
        tempMultiplier = 1 + ramp * (Calc.EXTREME_FATIGUE_MULTIPLIER_MAX - 1)
    end
    local exertionMultiplier = Calc.GetExertionMultiplier()
    return baseRatePerTick * tempMultiplier * exertionMultiplier
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Stamina exertion (#6) — fatigue should drain faster the more stamina the
-- player has actually SPENT recently, regardless of whether they're moving
-- (sprinting, light/heavy attacks, blocking, dodging, bashing all cost
-- stamina without necessarily covering ground). Tracked independently of
-- the position-based Rest mechanics in Rest.lua.
--
-- PARAMETER ORDER UNVERIFIED IN A LIVE CLIENT: this matches the commonly
-- documented EVENT_POWER_UPDATE signature, but confirm against
-- https://wiki.esoui.com/EVENT_POWER_UPDATE before trusting it blindly —
-- same caveat as the combat/loot events elsewhere in this project.
-- COMBAT_MECHANIC_FLAGS_STAMINA is reused here
-- from the already-working GetUnitPower() call in Disease.lua's low-health
-- trigger, but EVENT_POWER_UPDATE's powerType parameter might use a
-- differently-named enum family — also worth confirming.
-- ─────────────────────────────────────────────────────────────────────────────
local EXERTION_REFERENCE_STAMINA   = 300  -- stamina spent in one ~5s tick window that reaches max exertion
local EXERTION_MAX_MULTIPLIER      = 2.5

local _staminaSpentSinceLastTick = 0
local _lastStaminaValue = nil

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then return end
    if powerType ~= COMBAT_MECHANIC_FLAGS_STAMINA then return end

    if _lastStaminaValue and powerValue < _lastStaminaValue then
        _staminaSpentSinceLastTick = _staminaSpentSinceLastTick + (_lastStaminaValue - powerValue)
    end
    _lastStaminaValue = powerValue
end

-- Registered from Calc.Initialize(), called by OnAddOnLoaded in the main
-- file — not here at file scope, so RN.SavedVars is guaranteed to exist
-- before this can fire.
function Calc.Initialize()
    EVENT_MANAGER:RegisterForEvent("RealisticNeeds_PowerUpdate", EVENT_POWER_UPDATE, OnPowerUpdate)
end

-- Returns the current exertion multiplier and resets the tracking window —
-- call once per main tick (from GetFatigueDecayRate, which is itself called
-- once per main 5s tick).
function Calc.GetExertionMultiplier()
    local spent = _staminaSpentSinceLastTick
    _staminaSpentSinceLastTick = 0
    local fraction = math.min(1, spent / EXERTION_REFERENCE_STAMINA)
    return 1 + fraction * (EXERTION_MAX_MULTIPLIER - 1)
end
