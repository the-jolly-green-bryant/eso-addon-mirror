-- ESO Adventurer Suite
-- v0.29.624 - scalar-only dense-trial combat recorder.
-- Trial combat is gameplay-first: while an 8+ player group is in combat, keep
-- only exact headline totals needed by the HUD/report and stop building detailed
-- combat analytics on the live event path. Detailed ability/target/group/actor
-- tables are intentionally omitted for dense trial fights to protect frame time.

local EPC = ESOProgressionCoach
if not EPC or not EPC.Combat then return end

local C = EPC.Combat
local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_TrialRecorderPerf029624"
local state = { groupSize = 0, inCombat = false }

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function safeNumber(value, fallback)
    local n = tonumber(value)
    if n == nil then return tonumber(fallback) or 0 end
    return n
end

local function refreshGroupSize()
    if type(GetGroupSize) == "function" then
        local ok, value = pcall(GetGroupSize)
        state.groupSize = ok and math.max(0, tonumber(value) or 0) or 0
    else
        state.groupSize = 0
    end
end

local function refreshCombatState()
    if type(IsUnitInCombat) == "function" then
        local ok, value = pcall(IsUnitInCombat, "player")
        state.inCombat = ok and value == true
    else
        state.inCombat = C.inCombat == true
    end
end

local function denseCombat(self)
    return state.groupSize >= 8
        and state.inCombat == true
        and self ~= nil
        and self.inCombat == true
        and type(self.current) == "table"
end

local function cleanUnitName(value)
    value = tostring(value or "")
    if value == "" then return "You" end
    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", value)
        if ok and formatted and formatted ~= "" then value = formatted end
    end
    value = value:gsub("%^%a+", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return value ~= "" and value or "You"
end

local function playerName()
    if type(GetUnitName) == "function" then
        local ok, value = pcall(GetUnitName, "player")
        if ok and value and value ~= "" then return cleanUnitName(value) end
    end
    return "You"
end

local function criticalDamage(result)
    return (ACTION_RESULT_CRITICAL_DAMAGE ~= nil and result == ACTION_RESULT_CRITICAL_DAMAGE)
        or (ACTION_RESULT_DOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_DOT_TICK_CRITICAL)
end

local function criticalHeal(result)
    return (ACTION_RESULT_CRITICAL_HEAL ~= nil and result == ACTION_RESULT_CRITICAL_HEAL)
        or (ACTION_RESULT_HOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_HOT_TICK_CRITICAL)
end

local function blockedDamage(result)
    return (ACTION_RESULT_BLOCKED_DAMAGE ~= nil and result == ACTION_RESULT_BLOCKED_DAMAGE)
        or (ACTION_RESULT_BLOCKED ~= nil and result == ACTION_RESULT_BLOCKED)
end

local function dotDamage(result)
    return (ACTION_RESULT_DOT_TICK ~= nil and result == ACTION_RESULT_DOT_TICK)
        or (ACTION_RESULT_DOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_DOT_TICK_CRITICAL)
end

refreshGroupSize()
refreshCombatState()

if EM then
    if EVENT_GROUP_UPDATE then EM:RegisterForEvent(NAME .. "_Group", EVENT_GROUP_UPDATE, refreshGroupSize) end
    if EVENT_GROUP_MEMBER_JOINED then EM:RegisterForEvent(NAME .. "_Join", EVENT_GROUP_MEMBER_JOINED, refreshGroupSize) end
    if EVENT_GROUP_MEMBER_LEFT then EM:RegisterForEvent(NAME .. "_Left", EVENT_GROUP_MEMBER_LEFT, refreshGroupSize) end
    if EVENT_PLAYER_ACTIVATED then
        EM:RegisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            refreshGroupSize()
            refreshCombatState()
        end)
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EM:RegisterForEvent(NAME .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            state.inCombat = inCombat == true
            if not state.inCombat then refreshGroupSize() end
        end)
    end
end

-- Do not build/scan a 12-player actor roster on the combat-start frame in a
-- trial. Dense mode only needs the local identity for headline player totals.
if type(C.BuildActorRoster) == "function" and not C._easTrialRosterPerf029624 then
    C._easTrialRosterPerf029624 = true
    local baseBuildActorRoster = C.BuildActorRoster
    function C:BuildActorRoster(...)
        if state.groupSize >= 8 then
            local name = playerName()
            return { players = { [string.lower(name)] = name }, companions = {}, selfName = name }
        end
        return baseBuildActorRoster(self, ...)
    end
end

-- Mark dense fights and keep only one cached player name. The base BeginFight
-- still creates the normal fight object so every downstream report API remains
-- compatible after combat ends.
if type(C.BeginFight) == "function" and not C._easTrialBeginPerf029624 then
    C._easTrialBeginPerf029624 = true
    local baseBeginFight = C.BeginFight
    function C:BeginFight(...)
        local result = baseBeginFight(self, ...)
        if type(self.current) == "table" and state.groupSize >= 8 then
            self.current._easTrialPerformance029624 = true
            self.current._easTrialSelfName029624 = playerName()
            -- Dense trial reports intentionally do not collect live detail tables.
            self.current.abilities = {}
            self.current.targets = {}
            self.current.group = {}
            self.current.actors = {}
            self.current.incomingSources = {}
        end
        return result
    end
end

-- A start-of-fight stat snapshot already exists in Combat:BeginFight(). During
-- dense combat do not query character stats again on every hit/heal/incoming hit.
if type(C.AccumulateCombatStats) == "function" and not C._easTrialStatsPerf029624 then
    C._easTrialStatsPerf029624 = true
    local baseAccumulateCombatStats = C.AccumulateCombatStats
    function C:AccumulateCombatStats(eventKind, value, result, ...)
        if denseCombat(self) then return end
        return baseAccumulateCombatStats(self, eventKind, value, result, ...)
    end
end

-- Dense trial hot path: scalar math only. Core's late performance guard also
-- removes GROUP source subscriptions, so this normally receives only the local
-- player, local pet/companion, and incoming-to-player streams.
if type(C.OnCombatEvent) == "function" and not C._easTrialEventPerf029624 then
    C._easTrialEventPerf029624 = true
    local baseOnCombatEvent = C.OnCombatEvent

    function C:OnCombatEvent(eventKind, result, abilityName, sourceName, sourceType, targetName, targetType, hitValue, abilityId, sourceUnitId, ...)
        if not denseCombat(self) then
            return baseOnCombatEvent(self, eventKind, result, abilityName, sourceName, sourceType, targetName, targetType, hitValue, abilityId, sourceUnitId, ...)
        end

        local fight = self.current
        local value = tonumber(hitValue) or 0
        if value <= 0 then return end

        if eventKind == "INCOMING_DAMAGE" then
            fight.incomingDamage = (tonumber(fight.incomingDamage) or 0) + value
            fight.incomingHits = (tonumber(fight.incomingHits) or 0) + 1
            if blockedDamage(result) then fight.blockedHits = (tonumber(fight.blockedHits) or 0) + 1 end
            return
        end

        local isDamage = eventKind == "DAMAGE"
        local isHeal = eventKind == "HEAL"
        if not isDamage and not isHeal then return end

        local playerType = rawget(_G, "COMBAT_UNIT_TYPE_PLAYER")
        local petType = rawget(_G, "COMBAT_UNIT_TYPE_PLAYER_PET")
        local companionType = rawget(_G, "COMBAT_UNIT_TYPE_PLAYER_COMPANION")

        if companionType ~= nil and sourceType == companionType then
            if isDamage then fight.companionDamage = (tonumber(fight.companionDamage) or 0) + value
            else fight.companionHealing = (tonumber(fight.companionHealing) or 0) + value end
            return
        end

        if petType ~= nil and sourceType == petType then
            if isDamage then fight.petDamage = (tonumber(fight.petDamage) or 0) + value
            else fight.petHealing = (tonumber(fight.petHealing) or 0) + value end
            return
        end

        -- Core registers the local player's own stream as COMBAT_UNIT_TYPE_PLAYER.
        -- Never do name normalization/ownership lookup on the dense hot path.
        if playerType == nil or sourceType ~= playerType then return end

        if isDamage then
            fight.totalDamage = (tonumber(fight.totalDamage) or 0) + value
            fight.hits = (tonumber(fight.hits) or 0) + 1
            if criticalDamage(result) then fight.criticalHits = (tonumber(fight.criticalHits) or 0) + 1 end
            if dotDamage(result) then
                fight.dotDamage = (tonumber(fight.dotDamage) or 0) + value
            else
                fight.directDamage = (tonumber(fight.directDamage) or 0) + value
            end
        else
            fight.totalHealing = (tonumber(fight.totalHealing) or 0) + value
            fight.healEvents = (tonumber(fight.healEvents) or 0) + 1
            if criticalHeal(result) then fight.criticalHeals = (tonumber(fight.criticalHeals) or 0) + 1 end
        end
    end
end

-- While dense combat is active, never build/sort the detailed live report. The
-- compact scalar snapshot is enough for any HUD consumer that explicitly asks.
if type(C.GetDisplayFight) == "function" and not C._easTrialDisplayPerf029624 then
    C._easTrialDisplayPerf029624 = true
    local baseGetDisplayFight = C.GetDisplayFight
    function C:GetDisplayFight(...)
        if not denseCombat(self) then return baseGetDisplayFight(self, ...) end
        local fight = self.current
        local summary = self:GetLiveSummary() or {}
        local duration = math.max(0.1, safeNumber(summary.duration, 0.1))
        return {
            live = true,
            trialPerformanceMode = true,
            duration = duration,
            totalDamage = safeNumber(fight.totalDamage, 0), dps = safeNumber(summary.dps, 0),
            directDamage = safeNumber(fight.directDamage, 0), dotDamage = safeNumber(fight.dotDamage, 0),
            dotPercent = safeNumber(fight.totalDamage, 0) > 0 and (safeNumber(fight.dotDamage, 0) / safeNumber(fight.totalDamage, 1) * 100) or 0,
            petDamage = safeNumber(fight.petDamage, 0), petDps = safeNumber(summary.petDps, 0),
            companionDamage = safeNumber(fight.companionDamage, 0), companionDps = safeNumber(summary.companionDps, 0),
            combinedDamage = safeNumber(summary.combinedDamage, 0), combinedDps = safeNumber(summary.combinedDps, 0),
            hits = safeNumber(fight.hits, 0), criticalHits = safeNumber(fight.criticalHits, 0),
            criticalEventPercent = safeNumber(summary.criticalEventPercent, 0),
            totalHealing = safeNumber(fight.totalHealing, 0), hps = safeNumber(summary.hps, 0),
            petHealing = safeNumber(fight.petHealing, 0), companionHealing = safeNumber(fight.companionHealing, 0),
            combinedHealing = safeNumber(summary.combinedHealing, 0),
            healEvents = safeNumber(fight.healEvents, 0), criticalHeals = safeNumber(fight.criticalHeals, 0),
            criticalHealPercent = safeNumber(summary.criticalHealPercent, 0),
            incomingDamage = safeNumber(fight.incomingDamage, 0), dtps = safeNumber(summary.dtps, 0),
            incomingHits = safeNumber(fight.incomingHits, 0), blockedHits = safeNumber(fight.blockedHits, 0),
            blockPercent = safeNumber(summary.blockPercent, 0),
            targetCount = 0,
            targets = {}, abilities = {}, contributors = {}, actors = {}, effects = {}, incomingSources = {},
            combatStats = type(fight.statTracking) == "table" and (fight.statTracking.last or {}) or {},
            resources = type(self.BuildResourceStats) == "function" and self:BuildResourceStats(fight, duration) or {},
        }
    end
end

-- Game Combat is a post-fight analysis window. During an active dense trial,
-- freeze it completely even if it was left open. The normal combat-end refresh
-- repopulates it once gameplay pressure is gone.
local R = EPC.GameModeReport
if type(R) == "table" and type(R.Refresh) == "function" and not R._easTrialRefreshPerf029624 then
    R._easTrialRefreshPerf029624 = true
    local baseReportRefresh = R.Refresh
    function R:Refresh(...)
        if state.groupSize >= 8 and state.inCombat then return end
        return baseReportRefresh(self, ...)
    end
end
