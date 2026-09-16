-- Common Works -- light attack tracker
--
-- One-line weave tally: grade each skill's preceding light attack and GCD delay.
-- Reset on combat start; freeze on combat end.
-- Grading ported from Solinur's SimpleCastbar. Gaps beyond the
-- break cutoff count as pauses and are excluded from both totals.
-- LibCombat supplies cast start/end timings.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local UI = CW.UI
local EM = EVENT_MANAGER

-- Radiant Destruction and its morphs are cast 100ms after the press.
local ABILITY_DELAY = { [63044] = 100, [63029] = 100, [63046] = 100 }

-- The global cooldown floor. A cast shorter than this still holds the bar for it.
local GCD_MS = 1000

local COMBAT_STATE_EVENT = CW.name .. "LightAttackCombat"
local HIT_EVENT = CW.name .. "LightAttackHit"

-- Check LibCombat entry points; incompatible versions count as absent (as LT() does).
local function LC()
    local lc = LibCombat
    if type(lc) ~= "table" then return nil end
    if type(lc.RegisterForCombatEvent) ~= "function"
        or type(lc.UnregisterForCombatEvent) ~= "function" then return nil end
    return lc
end

function CW.LightAttackAvailable()
    return LC() ~= nil
end

local stats = { attempts = 0, missed = 0, late = 0, wastedMs = 0, activeMs = 0 }

local frozen = true
local hasPrevCast = false
local lastSkillEnd = 0
local lastAttackWasLight = false

local function FormatDuration(ms)
    local seconds = math.floor(ms / 1000)
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

-- Also the panel's placement stand-in, so what is dragged is the real line.
function CW.LaStatsText()
    local sv = CW.SavedVars
    local attempts = stats.attempts
    local parts = {}

    -- Purely "did a light attack land in front of the cast"; lateness is counted apart.
    local weaved = attempts - stats.missed

    if sv.laStatsAccuracy then
        parts[#parts + 1] = attempts > 0
            and string.format("%d%%", zo_round(weaved / attempts * 100)) or "-"
    end
    if sv.laStatsCount then
        parts[#parts + 1] = string.format("%s: %d/%d", CW.L.LA_WEAVES, weaved, attempts)
    end
    if sv.laStatsMissed then
        parts[#parts + 1] = string.format("%s: %d", CW.L.LA_MISSED, stats.missed)
    end
    if sv.laStatsLate then
        parts[#parts + 1] = string.format("%s: %d", CW.L.LA_LATE, stats.late)
    end
    if sv.laStatsAvgGap then
        local avg = attempts > 0
            and string.format("%dms", zo_round(stats.wastedMs / attempts)) or "-"
        parts[#parts + 1] = string.format("%s: %s", CW.L.LA_AVG_GAP, avg)
    end
    if sv.laStatsWasted then
        parts[#parts + 1] = string.format("%s: %.1fs", CW.L.LA_WASTED, stats.wastedMs / 1000)
    end
    if sv.laStatsActive then
        parts[#parts + 1] = string.format("%s: %s", CW.L.LA_ACTIVE, FormatDuration(stats.activeMs))
    end

    return table.concat(parts, sv.laStatsSeparator)
end

-- The panel is up through the fight, and after it only when asked to linger.
local function Repaint()
    UI.SetLaStatsText(CW.LaStatsText())
    UI.ApplyLaStatsVisibility(not frozen or CW.SavedVars.laStatsOutOfCombat == true)
end

function CW.ResetLaStats()
    stats.attempts, stats.missed, stats.late = 0, 0, 0
    stats.wastedMs, stats.activeMs = 0, 0
    -- The first cast of a fight would otherwise be timed against the last of the previous.
    hasPrevCast = false
    Repaint()
end

-- reducedslot 1 is the light attack; the rest are skill slots. REGISTERED and QUEUE
-- report a press and SUCCESS a cast ending, so grade on the three that start one.
local function OnSkillEvent(_, timems, reducedslot, abilityId, status, _, castTime)
    if status == LIBCOMBAT_SKILLSTATUS_REGISTERED
        or status == LIBCOMBAT_SKILLSTATUS_QUEUE
        or status == LIBCOMBAT_SKILLSTATUS_SUCCESS then return end

    if reducedslot % 10 == 1 then
        lastAttackWasLight = true
        return
    end

    local duration = GCD_MS
    if status == LIBCOMBAT_SKILLSTATUS_BEGIN_DURATION
        or status == LIBCOMBAT_SKILLSTATUS_BEGIN_CHANNEL then
        local _, castLength = GetAbilityCastInfo(abilityId)
        if castTime and castTime > 0 then castLength = castTime end
        duration = math.max(castLength, GCD_MS)
            + (ABILITY_DELAY[abilityId] or 0) + GetLatency() / 2
    end

    if not frozen then
        local gap = timems - lastSkillEnd
        -- Gaps beyond the cutoff count as neither attempts nor wasted time.
        -- Negative gaps beat the prior cast's projected end; they are not time gained.
        if hasPrevCast and gap <= CW.SavedVars.laBreakCutoff then
            local wasted = math.max(gap, 0)
            stats.attempts = stats.attempts + 1
            stats.wastedMs = stats.wastedMs + wasted
            stats.activeMs = stats.activeMs + wasted

            if not lastAttackWasLight then
                stats.missed = stats.missed + 1
            elseif gap >= CW.SavedVars.laLateCutoff then
                stats.late = stats.late + 1
            else
                UI.FlashLaStats()   -- weaved, and inside the clean window
            end
        end

        -- Light attacks are left out: they weave inside the cooldown this covers.
        stats.activeMs = stats.activeMs + duration
        hasPrevCast = true
        Repaint()
    end

    lastAttackWasLight = false
    lastSkillEnd = timems + duration
end

local function OnCombatStateChanged(_, inCombat)
    frozen = not inCombat
    if inCombat then CW.ResetLaStats() else Repaint() end
end

-- The cast timings report the slot used, not whether the swing connected.
local HIT_DEBOUNCE_MS = 200
local lastHitMs = 0

-- Engine-filter to the player's damage, one registration per result.
-- No slot-type filter exists, so the handler checks it.
local HIT_RESULTS = {
    ACTION_RESULT_DAMAGE,
    ACTION_RESULT_CRITICAL_DAMAGE,
    ACTION_RESULT_BLOCKED_DAMAGE,
    ACTION_RESULT_DAMAGE_SHIELDED,
}

-- Also the settings panel's audition path, so picking a sound plays what a real hit plays.
function CW.PlayLaHitSound()
    CW.PlaySoundRepeated(CW.SavedVars.laHitSoundKey, CW.SavedVars.laHitSoundVolume)
end

local function OnLightAttackHit(_, _, _, _, _, slotType)
    if slotType ~= ACTION_SLOT_TYPE_LIGHT_ATTACK then return end

    -- Cleave and shield portions can produce several damage events; sound once per swing.
    local now = GetGameTimeMilliseconds()
    if now - lastHitMs < HIT_DEBOUNCE_MS then return end
    lastHitMs = now

    CW.PlayLaHitSound()
end

local skillTracking, hitTracking = false, false

function CW.UpdateLaStatsTracking()
    local lc = LC()
    local wanted = lc ~= nil and CW.SavedVars.laStats

    if wanted and not skillTracking then
        lc:RegisterForCombatEvent(CW.name, LIBCOMBAT_EVENT_SKILL_TIMINGS, OnSkillEvent)
        EM:RegisterForEvent(COMBAT_STATE_EVENT, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
        skillTracking = true
        frozen = not CW.inCombat
        CW.ResetLaStats()
    elseif not wanted and skillTracking then
        lc:UnregisterForCombatEvent(CW.name, LIBCOMBAT_EVENT_SKILL_TIMINGS)
        EM:UnregisterForEvent(COMBAT_STATE_EVENT, EVENT_PLAYER_COMBAT_STATE)
        skillTracking = false
        frozen = true
    end

    UI.ApplyLaStatsVisibility(skillTracking and (not frozen or CW.SavedVars.laStatsOutOfCombat == true))
end

function CW.UpdateLaHitSoundTracking()
    local wanted = CW.SavedVars.laHitSound

    if wanted and not hitTracking then
        for i = 1, #HIT_RESULTS do
            local key = HIT_EVENT .. i
            EM:RegisterForEvent(key, EVENT_COMBAT_EVENT, OnLightAttackHit)
            EM:AddFilterForEvent(key, EVENT_COMBAT_EVENT,
                REGISTER_FILTER_COMBAT_RESULT, HIT_RESULTS[i],
                REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
                REGISTER_FILTER_IS_ERROR, false)
        end
        hitTracking = true
    elseif not wanted and hitTracking then
        for i = 1, #HIT_RESULTS do
            EM:UnregisterForEvent(HIT_EVENT .. i, EVENT_COMBAT_EVENT)
        end
        hitTracking = false
    end
end
