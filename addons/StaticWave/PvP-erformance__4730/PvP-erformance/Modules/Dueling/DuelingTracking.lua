local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
setfenv(1, setmetatable({
    PvPerformance = PvPerformance,
    Dueling = Dueling,
    Private = Private,
}, {
    __index = function(_, key)
        local value = Private[key]
        if value ~= nil then
            return value
        end
        return _G[key]
    end,
}))
function Dueling:RegisterDuelTrackingEvents()
    if self.duelTrackingEventsRegistered then
        return
    end

    -- Two native filters cover the required OR condition: player as source
    -- (damage done) or target (damage taken). Keeping each result separate
    -- lets the event manager reject irrelevant combat before Lua is called.
    for _, result in ipairs(DAMAGE_COMBAT_RESULTS) do
        local outgoingEventName = string.format("%sCombatOutgoing%d", ADDON_NAME, result)
        EVENT_MANAGER:RegisterForEvent(outgoingEventName, EVENT_COMBAT_EVENT, function(...)
            Dueling:OnCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            outgoingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )

        local incomingEventName = string.format("%sCombatIncoming%d", ADDON_NAME, result)
        EVENT_MANAGER:RegisterForEvent(incomingEventName, EVENT_COMBAT_EVENT, function(...)
            Dueling:OnCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            incomingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end

    -- A source-player filter keeps the healing callback out of other players'
    -- events. Further target validation occurs in Lua because only healing to
    -- the local player belongs in this personal duel summary.
    for _, result in ipairs(HEAL_COMBAT_RESULTS) do
        local eventName = string.format("%sHealing%d", ADDON_NAME, result)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...)
            Dueling:OnHealingCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Stun", EVENT_PLAYER_STUNNED_STATE_CHANGED, function(...)
        Dueling:OnPlayerStunnedStateChanged(...)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Reticle", EVENT_RETICLE_TARGET_CHANGED, function(...)
        Dueling:OnReticleTargetChanged(...)
    end)
    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.RegisterDuelEvents then
        Analytics:SafeCall("RegisterDuelEvents")
    end
    self.duelTrackingEventsRegistered = true
end

function Dueling:UnregisterDuelTrackingEvents()
    if not self.duelTrackingEventsRegistered then
        local Analytics = PvPerformance.Modules.Analytics
        if Analytics and Analytics.UnregisterDuelEvents then
            Analytics:SafeCall("UnregisterDuelEvents")
        end
        return
    end

    for _, result in ipairs(DAMAGE_COMBAT_RESULTS) do
        EVENT_MANAGER:UnregisterForEvent(string.format("%sCombatOutgoing%d", ADDON_NAME, result), EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(string.format("%sCombatIncoming%d", ADDON_NAME, result), EVENT_COMBAT_EVENT)
    end
    for _, result in ipairs(HEAL_COMBAT_RESULTS) do
        EVENT_MANAGER:UnregisterForEvent(string.format("%sHealing%d", ADDON_NAME, result), EVENT_COMBAT_EVENT)
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Stun", EVENT_PLAYER_STUNNED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Reticle", EVENT_RETICLE_TARGET_CHANGED)
    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.UnregisterDuelEvents then
        Analytics:SafeCall("UnregisterDuelEvents")
    end
    self.duelTrackingEventsRegistered = false
end

function Dueling:OnPlayerDeactivated()
    -- A load screen, logout, or disconnect cannot safely complete a duel.
    -- Discard only temporary combat state; never create a partial record.
    if self.ui and (self:IsSceneShowing() or not self.ui.window:IsHidden()) then
        self:HideUI()
    end
    self:UnregisterDuelTrackingEvents()
    self:StopLatencySampling()
    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.CancelDuel then
        Analytics:SafeCall("CancelDuel")
    end
    self.currentDuelStartMS = nil
    self.currentDuelTracking = nil
end

function Dueling:OnPlayerStunnedStateChanged(_, isStunned)
    local tracking = self.currentDuelTracking
    if not tracking then
        return
    end

    local now = GetGameTimeMilliseconds()
    -- Ignore a crowd-control event during the pre-duel countdown. Only a stun
    -- that occurred after the scheduled duel start can affect its record.
    if self.currentDuelStartMS and now < self.currentDuelStartMS then
        return
    end

    if isStunned then
        local currentStamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
        local currentHealth, maxHealth = GetUnitPower("player", POWERTYPE_HEALTH)
        currentStamina = tonumber(currentStamina) or 0
        maxStamina = tonumber(maxStamina) or 0
        currentHealth = tonumber(currentHealth) or 0
        maxHealth = tonumber(maxHealth) or 0

        -- Replacing an existing start avoids counting duplicate true events
        -- as a fresh stun. ESO does not expose a confirmed Break Free result,
        -- so the health sample only supports a conservative confidence level.
        if not tracking.ccStunned and maxStamina >= CC_LOCK_MIN_STAMINA
            and currentStamina >= CC_LOCK_MIN_STAMINA
            and maxHealth > 0 then
            tracking.ccStunned = true
            tracking.ccStunStartMS = now
            tracking.ccStunStartHealthPercent = math.max(0, math.min(1, currentHealth / maxHealth))
        end
        return
    end

    if tracking.ccStunned then
        local duration = now - (tracking.ccStunStartMS or now)
        if duration >= CC_LOCK_MIN_STUN_DURATION_MS then
            tracking.ccLastQualifyingStunEndMS = now
            tracking.ccLastQualifyingStunHealthPercent = tracking.ccStunStartHealthPercent
        end
    end
    tracking.ccStunned = false
    tracking.ccStunStartMS = nil
    tracking.ccStunStartHealthPercent = nil
end

function Dueling:WasLossDuringSuspectedCcLock(tracking, finishedAtMS, won, drawn)
    if not tracking or won or drawn then
        return false, nil, nil
    end

    local stunEndedAtMS
    local healthPercent
    if tracking.ccStunned and tracking.ccStunStartMS
        and finishedAtMS - tracking.ccStunStartMS >= CC_LOCK_MIN_STUN_DURATION_MS then
        stunEndedAtMS = nil -- Death occurred during the qualifying lock.
        healthPercent = tracking.ccStunStartHealthPercent
    else
        local lastEndMS = tracking.ccLastQualifyingStunEndMS
        if lastEndMS == nil or finishedAtMS < lastEndMS
            or finishedAtMS - lastEndMS > CC_LOCK_RECOVERY_FINISH_WINDOW_MS then
            return false, nil, nil
        end
        stunEndedAtMS = lastEndMS
        healthPercent = tracking.ccLastQualifyingStunHealthPercent
    end

    healthPercent = tonumber(healthPercent) or 0
    -- A fatal stun that started below 15% health is too likely to be an
    -- ordinary kill window to be protected at all.
    if healthPercent < 0.15 then
        return false, nil, nil
    end

    local afterEndMS = stunEndedAtMS and (finishedAtMS - stunEndedAtMS) or 0
    if healthPercent >= 0.70 and (stunEndedAtMS == nil or afterEndMS <= CC_LOCK_IMMEDIATE_FINISH_WINDOW_MS) then
        return true, "STRONG", CC_LOCK_STRONG_LOSS_MULTIPLIER
    end
    if healthPercent >= 0.35 and (stunEndedAtMS == nil or afterEndMS <= CC_LOCK_LIKELY_FINISH_WINDOW_MS) then
        return true, "LIKELY", CC_LOCK_LIKELY_LOSS_MULTIPLIER
    end
    -- A recovered player who dies within five seconds, or a low-but-viable
    -- player dying in the lock, is only a possible indicator.
    if (stunEndedAtMS == nil and healthPercent >= 0.15)
        or (stunEndedAtMS ~= nil and afterEndMS <= CC_LOCK_RECOVERY_FINISH_WINDOW_MS) then
        return true, "POSSIBLE", CC_LOCK_POSSIBLE_LOSS_MULTIPLIER
    end

    return false, nil, nil
end

function Dueling:SampleDuelLatency(now)
    local tracking = self.currentDuelTracking
    if not tracking or type(GetLatency) ~= "function" then
        return
    end

    now = now or GetGameTimeMilliseconds()
    if self.currentDuelStartMS and now < self.currentDuelStartMS then
        return
    end

    local latency = tonumber(GetLatency()) or 0
    if latency <= 0 then
        return
    end

    tracking.latencySampleCount = (tracking.latencySampleCount or 0) + 1
    tracking.latencyPeakMS = math.max(tracking.latencyPeakMS or 0, latency)

    local baseline = tracking.latencyBaselineMS
    local baselineSamples = tracking.latencyBaselineSamples or 0
    local hasBaseline = baseline ~= nil and baselineSamples >= LATENCY_MIN_BASELINE_SAMPLES
    local difference = hasBaseline and (latency - baseline) or 0
    local isSevereSpike = hasBaseline and (difference >= LATENCY_SEVERE_MIN_DELTA_MS
        or latency >= baseline * LATENCY_SEVERE_MULTIPLIER)
    local isModerateSpike = hasBaseline and difference >= LATENCY_MODERATE_MIN_DELTA_MS
        and latency >= baseline * LATENCY_MODERATE_MULTIPLIER
    local spikeLevel = isSevereSpike and "SEVERE" or (isModerateSpike and "MODERATE" or nil)

    if spikeLevel then
        tracking.latencySpikeStartMS = tracking.latencySpikeStartMS or now
        if spikeLevel == "SEVERE" then
            tracking.latencyCurrentSpikeLevel = "SEVERE"
        else
            tracking.latencyCurrentSpikeLevel = tracking.latencyCurrentSpikeLevel or "MODERATE"
        end
        if now - tracking.latencySpikeStartMS >= LATENCY_MIN_SPIKE_DURATION_MS then
            tracking.latencyLastQualifyingSpikeMS = now
            tracking.latencyQualifyingSpike = true
            tracking.latencySpikeConfidence = tracking.latencyCurrentSpikeLevel
        end
        return
    end

    tracking.latencySpikeStartMS = nil
    tracking.latencyCurrentSpikeLevel = nil
    if baseline == nil then
        tracking.latencyBaselineMS = latency
        tracking.latencyBaselineSamples = 1
    elseif baselineSamples < LATENCY_BASELINE_WINDOW_SAMPLES then
        local nextCount = baselineSamples + 1
        tracking.latencyBaselineMS = ((baseline * baselineSamples) + latency) / nextCount
        tracking.latencyBaselineSamples = nextCount
    else
        -- A gradual rolling update follows normal connection changes without
        -- letting a detected spike contaminate the comparison baseline.
        tracking.latencyBaselineMS = baseline * 0.90 + latency * 0.10
    end
end

function Dueling:StartLatencySampling()
    if not EVENT_MANAGER or not EVENT_MANAGER.RegisterForUpdate then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(LATENCY_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(LATENCY_UPDATE_NAME, LATENCY_SAMPLE_INTERVAL_MS, function()
        if not self.currentDuelTracking then
            EVENT_MANAGER:UnregisterForUpdate(LATENCY_UPDATE_NAME)
            return
        end
        self:SampleDuelLatency()
    end)
end

function Dueling:StopLatencySampling()
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(LATENCY_UPDATE_NAME)
    end
end

function Dueling:WasLossDuringSuspectedLatencySpike(tracking, finishedAtMS, won, drawn)
    if not tracking or won or drawn or not tracking.latencyQualifyingSpike then
        return false, nil
    end

    local lastSpikeMS = tracking.latencyLastQualifyingSpikeMS
    local isRecent = lastSpikeMS ~= nil and finishedAtMS >= lastSpikeMS
        and finishedAtMS - lastSpikeMS <= LATENCY_FINISH_WINDOW_MS
    return isRecent, isRecent and (tracking.latencySpikeConfidence or "MODERATE") or nil
end

function Dueling:OnDuelCountdown(_, startTimeMS)
    -- EVENT_DUEL_COUNTDOWN supplies the scheduled start time in the game's clock.
    self:UnregisterDuelTrackingEvents()
    if not self:IsDuelTrackingEnabled() then
        self:StopLatencySampling()
        local Analytics = PvPerformance.Modules.Analytics
        if Analytics and Analytics.CancelDuel then
            Analytics:SafeCall("CancelDuel")
        end
        self.currentDuelStartMS = nil
        self.currentDuelTracking = nil
        return
    end
    self.currentDuelStartMS = startTimeMS
    self.currentDuelTracking = {
        -- These maps exist only for the active duel. They aggregate by
        -- opponent and stable ability identifier; no individual combat event
        -- is retained once the compact final duel record is made.
        playerCharacterName = CleanCharacterName(GetUnitName("player")),
        playerDisplayName = GetDisplayName(),
        playerCombatKey = NormalizeUnitName(GetUnitName("player")),
        actorKeyCache = {},
        damageDoneByTarget = {},
        damageTakenBySource = {},
        healingByTarget = {},
        playerWasWerewolf = PlayerIsWerewolf(),
        opponentWerewolfSources = {},
        damageDone = 0,
        damageTaken = 0,
        damageEventCount = 0,
        outgoingDamageSamples = {},
        outgoingBurstTotal = 0,
        peakOutgoingBurst = 0,
        latencySampleCount = 0,
        latencyBaselineSamples = 0,
        latencyPeakMS = 0,
    }

    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.BeginDuel then
        Analytics:SafeCall("BeginDuel", self.currentDuelTracking, startTimeMS)
    end

    -- A player who transformed before requesting the duel may not cast a
    -- Werewolf ability once the duel starts. Scan the active reticle now and
    -- again shortly after the countdown begins to catch its visible form buff.
    local tracking = self.currentDuelTracking
    self:ScanReticleForWerewolf()
    zo_callLater(function()
        if self.currentDuelTracking == tracking then
            self:ScanReticleForWerewolf()
        end
    end, 500)
    self:StartLatencySampling()
    self:RegisterDuelTrackingEvents()
end

function Dueling:IsWerewolfSignatureAbility(abilityId)
    abilityId = tonumber(abilityId)
    return abilityId and (WEREWOLF_SIGNATURE_ABILITY_IDS[abilityId]
        or (self.savedVars.werewolfAbilityIds and self.savedVars.werewolfAbilityIds[abilityId]))
end

function Dueling:RememberWerewolfSource(sourceName, abilityId)
    if not self.currentDuelTracking or not sourceName or sourceName == "" then
        return
    end

    local sourceKey = NormalizeUnitName(sourceName)
    if sourceKey == "" then
        return
    end

    self.currentDuelTracking.opponentWerewolfSources[sourceKey] = abilityId
end

function Dueling:ScanReticleForWerewolf()
    if not self.currentDuelTracking or not DoesUnitExist("reticleover") then
        return
    end

    local reticleName = GetUnitName("reticleover")
    if not reticleName or reticleName == "" or NamesMatch(reticleName, GetUnitName("player")) then
        return
    end

    local buffCount = GetNumBuffs("reticleover") or 0
    for buffIndex = 1, buffCount do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", buffIndex)
        if self:IsWerewolfSignatureAbility(abilityId) then
            self:RememberWerewolfSource(reticleName, abilityId)
            return
        end
    end
end

function Dueling:OnReticleTargetChanged()
    self:ScanReticleForWerewolf()
end

function Dueling:TrackOutgoingDamage(tracking, value)
    local now = GetGameTimeMilliseconds()
    local samples = tracking.outgoingDamageSamples
    local sample = { timestamp = now, value = value }
    table.insert(samples, sample)
    tracking.outgoingBurstTotal = (tracking.outgoingBurstTotal or 0) + value

    while #samples > 0 and now - samples[1].timestamp > DAMAGE_BURST_WINDOW_MS do
        tracking.outgoingBurstTotal = tracking.outgoingBurstTotal - samples[1].value
        table.remove(samples, 1)
    end

    tracking.peakOutgoingBurst = math.max(tracking.peakOutgoingBurst or 0, tracking.outgoingBurstTotal)
end

