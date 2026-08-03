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
local function CombatActorKey(name)
    if not name or name == "" then
        return ""
    end
    return NormalizeUnitName(name)
end

local function CombatAbilityIdentity(abilityId, abilityName)
    abilityId = tonumber(abilityId) or 0
    local displayName = abilityName and abilityName ~= "" and abilityName or nil
    if not displayName and abilityId > 0 and type(GetAbilityName) == "function" then
        displayName = GetAbilityName(abilityId)
    end
    displayName = displayName and displayName ~= "" and displayName or "Unknown effect"
    -- Prefer the stable ability ID. Name is only a fallback for effects whose
    -- combat event does not identify an ability.
    local identity = abilityId > 0 and ("id:" .. abilityId) or ("name:" .. zo_strlower(displayName))
    return identity, displayName, abilityId
end

local function IsCriticalDamageResult(result)
    return result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
end

local function AccumulateCombatSource(groupedActors, actorName, abilityId, abilityName, value, isCritical, actorKeyCache)
    value = math.max(0, tonumber(value) or 0)
    local actorKey
    if actorKeyCache and actorName then
        actorKey = actorKeyCache[actorName]
        if actorKey == nil then
            actorKey = CombatActorKey(actorName)
            actorKeyCache[actorName] = actorKey
        end
    else
        actorKey = CombatActorKey(actorName)
    end
    if value <= 0 or actorKey == "" then
        return
    end
    local actorSources = groupedActors[actorKey]
    if not actorSources then
        actorSources = {}
        groupedActors[actorKey] = actorSources
    end
    local identity, displayName, resolvedAbilityId = CombatAbilityIdentity(abilityId, abilityName)
    local source = actorSources[identity]
    if not source then
        source = {
            name = displayName,
            abilityId = resolvedAbilityId > 0 and resolvedAbilityId or nil,
            total = 0,
            hitCount = 0,
            critCount = 0,
            minHit = nil,
            maxHit = 0,
        }
        actorSources[identity] = source
    end
    source.total = source.total + value
    source.hitCount = (source.hitCount or 0) + 1
    if isCritical then
        source.critCount = (source.critCount or 0) + 1
    end
    source.minHit = source.minHit and math.min(source.minHit, value) or value
    source.maxHit = math.max(source.maxHit or 0, value)
end

local function SourceGroupsForNames(groupedActors, names)
    local groups = {}
    local seen = {}
    -- `ipairs` stops at the first nil. Combat names are normally available,
    -- but `pairs` keeps a missing character/display name from preventing the
    -- other valid identity from being considered at duel finish.
    for _, name in pairs(names) do
        local actorKey = CombatActorKey(name)
        local group = actorKey ~= "" and groupedActors[actorKey] or nil
        if group and not seen[group] then
            seen[group] = true
            table.insert(groups, group)
        end
    end
    return groups
end

local function BuildTopCombatSources(groupedActors, names)
    local combined = {}
    local total = 0
    for _, group in ipairs(SourceGroupsForNames(groupedActors, names)) do
        for identity, source in pairs(group) do
            local entry = combined[identity]
            if not entry then
                entry = {
                    name = source.name,
                    abilityId = source.abilityId,
                    total = 0,
                    hitCount = 0,
                    critCount = 0,
                    minHit = nil,
                    maxHit = 0,
                }
                combined[identity] = entry
            end
            entry.total = entry.total + (tonumber(source.total) or 0)
            entry.hitCount = entry.hitCount + (tonumber(source.hitCount) or 0)
            entry.critCount = entry.critCount + (tonumber(source.critCount) or 0)
            local sourceMin = tonumber(source.minHit)
            if sourceMin and sourceMin > 0 then
                entry.minHit = entry.minHit and math.min(entry.minHit, sourceMin) or sourceMin
            end
            entry.maxHit = math.max(entry.maxHit or 0, tonumber(source.maxHit) or 0)
        end
    end

    local entries = {}
    for _, entry in pairs(combined) do
        total = total + entry.total
        table.insert(entries, entry)
    end
    table.sort(entries, function(left, right)
        if left.total ~= right.total then
            return left.total > right.total
        end
        return zo_strlower(left.name) < zo_strlower(right.name)
    end)

    local top = {}
    for index = 1, math.min(COMBAT_SUMMARY_TOP_SOURCES, #entries) do
        local entry = entries[index]
        table.insert(top, {
            name = entry.name,
            abilityId = entry.abilityId,
            total = math.floor(entry.total + 0.5),
            hitCount = math.max(0, math.floor((entry.hitCount or 0) + 0.5)),
            critCount = math.max(0, math.floor((entry.critCount or 0) + 0.5)),
            minHit = entry.minHit and math.floor(entry.minHit + 0.5) or nil,
            maxHit = math.max(0, math.floor((entry.maxHit or 0) + 0.5)),
        })
    end
    return total > 0 and math.floor(total + 0.5) or nil, top
end

local function CountCombatSources(groupedActors)
    local count = 0
    for _, sources in pairs(groupedActors or {}) do
        for _ in pairs(sources) do
            count = count + 1
        end
    end
    return count
end

function Dueling:BuildDuelCombatSummary(tracking, opponentCharacterName, opponentDisplayName, durationSeconds)
    if not tracking then
        return nil
    end
    local opponentNames = { opponentCharacterName, opponentDisplayName }
    local damageDone, topDamageDone = BuildTopCombatSources(
        tracking.damageDoneByTarget or {},
        opponentNames
    )
    local damageTaken, topDamageTaken = BuildTopCombatSources(
        tracking.damageTakenBySource or {},
        opponentNames
    )
    -- Healing is accumulated only after the callback verifies that the local
    -- player is both source and target. Use that direct total as the canonical
    -- API-reported healing value so a display-name variation cannot suppress a
    -- valid healing card.
    local healingDone = tonumber(tracking.reportedHealing) or 0
    if healingDone <= 0 then
        healingDone = nil
    else
        healingDone = math.floor(healingDone + 0.5)
    end

    if not damageDone and not damageTaken and not healingDone then
        return nil
    end

    return {
        damageDone = damageDone,
        damageTaken = damageTaken,
        healingDone = healingDone,
        -- ESO's public combat events cannot reliably provide a non-overlapping
        -- shield-absorption number for every damage shield. Leave it absent.
        shieldAbsorbed = nil,
        topDamageDone = topDamageDone,
        topDamageTaken = topDamageTaken,
    }
end

function Dueling:CaptureCombatDebugSnapshot(tracking, opponentCharacterName, opponentDisplayName, combatSummary, eventsRegisteredAtFinish)
    local opponentName = opponentCharacterName
    if not opponentName or opponentName == "" then
        opponentName = opponentDisplayName
    end
    self.lastCombatDebug = {
        eventsRegisteredAtFinish = eventsRegisteredAtFinish == true,
        activeOpponentKey = CombatActorKey(opponentName),
        outgoingSourceEntries = CountCombatSources(tracking and tracking.damageDoneByTarget),
        incomingSourceEntries = CountCombatSources(tracking and tracking.damageTakenBySource),
        temporaryDamageDone = tonumber(tracking and tracking.damageDone) or 0,
        temporaryDamageTaken = tonumber(tracking and tracking.damageTaken) or 0,
        temporaryHealing = tonumber(tracking and tracking.reportedHealing) or 0,
        finalDamageDone = combatSummary and combatSummary.damageDone,
        finalDamageTaken = combatSummary and combatSummary.damageTaken,
        finalHealingDone = combatSummary and combatSummary.healingDone,
        finalShieldAbsorbed = combatSummary and combatSummary.shieldAbsorbed,
        topDamageDoneCount = combatSummary and #(combatSummary.topDamageDone or {}) or 0,
        topDamageTakenCount = combatSummary and #(combatSummary.topDamageTaken or {}) or 0,
    }
end

function Dueling:OnHealingCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceUnitType, targetName, _, hitValue, _, _, _, _, _, abilityId)
    local tracking = self.currentDuelTracking
    if not tracking or sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    local now = GetGameTimeMilliseconds()
    if self.currentDuelStartMS and now < self.currentDuelStartMS then
        return
    end
    local amount = math.max(0, tonumber(hitValue) or 0)
    if amount <= 0 then
        return
    end
    -- Analytics retains all API-reported healing cast by the local player,
    -- including heals placed on another target. The existing Duel Summary
    -- remains self-healing-only and therefore keeps its established meaning.
    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.RecordHealing then
        Analytics:SafeCall("RecordHealing", tracking, "healingDone", result, abilityName, sourceName, targetName, amount, abilityId)
    end

    -- Only self-targeted healing is part of this player's personal duel
    -- totals. We intentionally do not infer unreported overheal or shields.
    local targetKey = tracking.actorKeyCache and tracking.actorKeyCache[targetName]
    if targetKey == nil then
        targetKey = CombatActorKey(targetName)
        if tracking.actorKeyCache and targetName then
            tracking.actorKeyCache[targetName] = targetKey
        end
    end
    if targetKey ~= (tracking.playerCombatKey or CombatActorKey(tracking.playerCharacterName)) then
        return
    end
    if Analytics and Analytics.RecordHealing then
        Analytics:SafeCall("RecordHealing", tracking, "healingReceived", result, abilityName, sourceName, targetName, amount, abilityId)
    end
    tracking.reportedHealing = (tracking.reportedHealing or 0) + amount
    tracking.healingEventCount = (tracking.healingEventCount or 0) + 1
    AccumulateCombatSource(
        tracking.healingByTarget,
        targetName,
        abilityId,
        abilityName,
        amount,
        false,
        tracking.actorKeyCache
    )
end

function Dueling:OnCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceUnitType, targetName, targetUnitType, hitValue, _, _, _, _, _, abilityId, overflow)
    local tracking = self.currentDuelTracking
    if not tracking then
        return
    end

    -- Shield-absorption results name the ward/passive that absorbed the hit
    -- (for example Calculated Defense), not the damaging attack. They are not
    -- attributable damage sources and must never enter the damage tables.
    -- Native registration applies this boundary first; retain the explicit
    -- check here so a direct or future shared callback remains fail-safe.
    if not IsDamageCombatResult(result) then
        return
    end

    local now = GetGameTimeMilliseconds()
    if self.currentDuelStartMS and now < self.currentDuelStartMS then
        return
    end

    -- Native event filters already limit this callback to player-originated
    -- or player-targeted damage. The unit types replace repeated and slower
    -- player-name string comparisons in the hot combat path.
    local isFromPlayer = sourceUnitType == COMBAT_UNIT_TYPE_PLAYER
    local isToPlayer = targetUnitType == COMBAT_UNIT_TYPE_PLAYER
    local damage = math.max(0, tonumber(hitValue) or 0)
    local absorbed = math.max(0, tonumber(overflow) or 0)
    local Analytics = PvPerformance.Modules.Analytics
    if damage > 0 then
        if isFromPlayer and not isToPlayer then
            tracking.damageDone = (tracking.damageDone or 0) + damage
            tracking.damageEventCount = (tracking.damageEventCount or 0) + 1
            tracking.lastOutgoingTargetKey = CombatActorKey(targetName)
            self:TrackOutgoingDamage(tracking, damage)
            AccumulateCombatSource(
                tracking.damageDoneByTarget,
                targetName,
                abilityId,
                abilityName,
                damage,
                IsCriticalDamageResult(result),
                tracking.actorKeyCache
            )
        elseif isToPlayer and not isFromPlayer then
            tracking.damageTaken = (tracking.damageTaken or 0) + damage
            tracking.damageEventCount = (tracking.damageEventCount or 0) + 1
            tracking.lastIncomingSourceKey = CombatActorKey(sourceName)
            AccumulateCombatSource(
                tracking.damageTakenBySource,
                sourceName,
                abilityId,
                abilityName,
                damage,
                IsCriticalDamageResult(result),
                tracking.actorKeyCache
            )
        end
    end

    -- Analytics records attack occurrences independently from authoritative
    -- health-damage totals. This keeps a fully blocked zero-damage attack in
    -- the hit count and combat log without adding it to DPS, rating inputs, or
    -- the compact Dueling damage summary. If ESO reports an overflow value,
    -- retain it as absorbed damage rather than mixing it into health damage.
    if Analytics and Analytics.RecordDamage then
        if isFromPlayer and not isToPlayer then
            Analytics:SafeCall(
                "RecordDamage",
                tracking,
                "damageDone",
                result,
                abilityName,
                sourceName,
                targetName,
                damage,
                abilityId,
                absorbed
            )
        elseif isToPlayer and not isFromPlayer then
            Analytics:SafeCall(
                "RecordDamage",
                tracking,
                "damageTaken",
                result,
                abilityName,
                sourceName,
                targetName,
                damage,
                abilityId,
                absorbed
            )
        end
    end

    if isFromPlayer and (PlayerIsWerewolf() or self:IsWerewolfSignatureAbility(abilityId)) then
        tracking.playerWasWerewolf = true
        return
    end

    -- An incoming event identifies the duel opponent without depending on
    -- reticle state. A source that cannot later be matched to the finish
    -- event is deliberately ignored rather than guessed to be Werewolf.
    if not isToPlayer or isFromPlayer then
        return
    end

    if self.werewolfDebug then
        Print(string.format(
            "WW debug: %s used %s (ability %s).",
            CleanCharacterName(sourceName),
            abilityName or "an unnamed ability",
            tostring(abilityId)
        ))
    end

    if self:IsWerewolfSignatureAbility(abilityId) then
        self:RememberWerewolfSource(sourceName, abilityId)
    end
end

function Dueling:WasOpponentConfirmedWerewolf(opponentCharacterName, opponentDisplayName)
    local tracking = self.currentDuelTracking
    if not tracking then
        return false, nil
    end

    local sources = tracking.opponentWerewolfSources or {}
    local abilityId = sources[NormalizeUnitName(opponentCharacterName)]
        or sources[NormalizeUnitName(opponentDisplayName)]
    return abilityId ~= nil, abilityId
end

function Dueling:OnWerewolfCommand(argument)
    local action, value = string.match(zo_strlower(argument or ""), "^%s*(%S*)%s*(.-)%s*$")
    if action == "add" then
        local abilityId = tonumber(value)
        if not abilityId or abilityId <= 0 then
            Print("Usage: /metrics ww add <abilityId>")
            return
        end
        self.savedVars.werewolfAbilityIds[abilityId] = true
        Print(string.format("Added ability %d as a Werewolf signature for future duels.", abilityId))
    elseif action == "debug" then
        self.werewolfDebug = value == "on" or value == "1" or value == "true"
        Print(self.werewolfDebug and "WW ability debug enabled for the current duel." or "WW ability debug disabled.")
    elseif action == "scan" then
        self:ScanReticleForWerewolf()
        Print("Scanned your reticle target for a visible Werewolf form effect.")
    else
        Print("Werewolf tools: /metrics ww scan | debug on|off | add <abilityId>")
    end
end

function Dueling:PrintCombatDebug()
    local tracking = self.currentDuelTracking
    if tracking then
        Print(string.format(
            "Combat debug (active): listeners %s | opponent key %s | outgoing sources %d | incoming sources %d",
            self.duelTrackingEventsRegistered and "ON" or "OFF",
            tracking.lastIncomingSourceKey or tracking.lastOutgoingTargetKey or "pending",
            CountCombatSources(tracking.damageDoneByTarget),
            CountCombatSources(tracking.damageTakenBySource)
        ))
        Print(string.format(
            "Combat debug (active totals): done %s | taken %s | healing %s",
            FormatDamage(tonumber(tracking.damageDone) or 0),
            FormatDamage(tonumber(tracking.damageTaken) or 0),
            FormatDamage(tonumber(tracking.reportedHealing) or 0)
        ))
    else
        Print(string.format(
            "Combat debug (active): listeners %s | no active duel.",
            self.duelTrackingEventsRegistered and "ON" or "OFF"
        ))
    end

    local snapshot = self.lastCombatDebug
    if not snapshot then
        Print("Combat debug: no completed-duel snapshot is available this session.")
        return
    end

    Print(string.format(
        "Combat debug (last finish): listeners %s | opponent key %s | outgoing sources %d | incoming sources %d",
        snapshot.eventsRegisteredAtFinish and "ON" or "OFF",
        snapshot.activeOpponentKey ~= "" and snapshot.activeOpponentKey or "unknown",
        snapshot.outgoingSourceEntries,
        snapshot.incomingSourceEntries
    ))
    Print(string.format(
        "Combat debug (temporary totals): done %s | taken %s | healing %s",
        FormatDamage(snapshot.temporaryDamageDone),
        FormatDamage(snapshot.temporaryDamageTaken),
        FormatDamage(snapshot.temporaryHealing)
    ))
    Print(string.format(
        "Combat debug (final summary): done %s | taken %s | healing %s | shield %s | top done %d | top taken %d",
        snapshot.finalDamageDone ~= nil and FormatDamage(snapshot.finalDamageDone) or "N/A",
        snapshot.finalDamageTaken ~= nil and FormatDamage(snapshot.finalDamageTaken) or "N/A",
        snapshot.finalHealingDone ~= nil and FormatDamage(snapshot.finalHealingDone) or "N/A",
        snapshot.finalShieldAbsorbed ~= nil and FormatDamage(snapshot.finalShieldAbsorbed) or "N/A",
        snapshot.topDamageDoneCount,
        snapshot.topDamageTakenCount
    ))
end

function Dueling:NextDuelId()
    -- Timestamp alone can collide when a test or rapid event sequence ends in
    -- the same second. A tiny SavedVariables sequence is compact and gives
    -- every new record a stable selection key without storing combat events.
    self.savedVars.nextDuelSequence = (tonumber(self.savedVars.nextDuelSequence) or 0) + 1
    return string.format("%d-%d", GetTimeStamp(), self.savedVars.nextDuelSequence)
end

local function IsEstablishedDifficultOpponent(history, opponentDisplayName, opponentCharacterName)
    local displayKey = zo_strlower(opponentDisplayName or "")
    local characterKey = NormalizeUnitName(opponentCharacterName)
    local decisiveDuels = 0
    local playerWins = 0

    for _, previousDuel in ipairs(history or {}) do
        local previousOpponent = previousDuel.opponent or {}
        local sameOpponent = displayKey ~= ""
            and displayKey ~= "unknown @name"
            and zo_strlower(previousOpponent.displayName or "") == displayKey
        if not sameOpponent and displayKey == "" and characterKey ~= "" then
            sameOpponent = NormalizeUnitName(previousOpponent.characterName) == characterKey
        end

        if sameOpponent and not previousDuel.drawn then
            decisiveDuels = decisiveDuels + 1
            if previousDuel.won then
                playerWins = playerWins + 1
            end
        end
    end

    return decisiveDuels >= 5 and (playerWins / decisiveDuels) <= (1 / 3)
end

function Dueling:OnDuelFinished(_, duelResult, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    -- A forfeit deliberately counts as a draw, not a win for either player.
    -- For a regular finish, EVENT_DUEL_FINISHED emits WON and identifies the
    -- winner through wasLocalPlayersResult.
    local forfeited = duelResult == DUEL_RESULT_FORFEIT
    local drawn = forfeited or duelResult ~= DUEL_RESULT_WON
    local won = not drawn and wasLocalPlayersResult

    if not self:IsDuelTrackingEnabled() then
        self:UnregisterDuelTrackingEvents()
        self:StopLatencySampling()
        local Analytics = PvPerformance.Modules.Analytics
        if Analytics and Analytics.CancelDuel then
            Analytics:SafeCall("CancelDuel")
        end
        self.currentDuelStartMS = nil
        self.currentDuelTracking = nil
        return
    end

    local currentTimeMS = GetGameTimeMilliseconds()
    local durationSeconds
    if self.currentDuelStartMS and currentTimeMS >= self.currentDuelStartMS then
        durationSeconds = math.floor((currentTimeMS - self.currentDuelStartMS) / 1000)
    end
    self.currentDuelStartMS = nil

    local eventsRegisteredAtFinish = self.duelTrackingEventsRegistered == true
    self:UnregisterDuelTrackingEvents()
    self:SampleDuelLatency(currentTimeMS)
    self:StopLatencySampling()
    local duelTracking = self.currentDuelTracking
    local suspectedCcLock, ccLockConfidence, ccLockLossMultiplier = self:WasLossDuringSuspectedCcLock(
        duelTracking,
        currentTimeMS,
        won,
        drawn
    )
    local suspectedLatencySpike, latencySpikeConfidence = self:WasLossDuringSuspectedLatencySpike(
        duelTracking,
        currentTimeMS,
        won,
        drawn
    )
    local playerWasWerewolf = (duelTracking and duelTracking.playerWasWerewolf)
        or PlayerIsWerewolf()
    local opponentWasWerewolf, werewolfEvidenceAbilityId = self:WasOpponentConfirmedWerewolf(
        opponentCharacterName,
        opponentDisplayName
    )

    local playerGender = GetUnitGender("player")
    local playerClassId = GetUnitClassId("player")
    local playerRaceId = GetUnitRaceId("player")
    local combatSummary = self:BuildDuelCombatSummary(
        duelTracking,
        opponentCharacterName,
        opponentDisplayName,
        durationSeconds
    )
    local Analytics = PvPerformance.Modules.Analytics
    local analyticsSummary = Analytics and Analytics.FinishDuel
        and Analytics:SafeCall("FinishDuel", duelTracking, opponentCharacterName, opponentDisplayName)
        or nil
    self:CaptureCombatDebugSnapshot(
        duelTracking,
        opponentCharacterName,
        opponentDisplayName,
        combatSummary,
        eventsRegisteredAtFinish
    )
    local damageDone
    local damageTaken
    local damageRatingMultiplier = 1
    local damageRatingReason
    local latencyBaselineMS
    local latencyPeakMS
    if duelTracking and (duelTracking.latencySampleCount or 0) >= LATENCY_MIN_BASELINE_SAMPLES then
        latencyBaselineMS = math.floor((duelTracking.latencyBaselineMS or 0) + 0.5)
        latencyPeakMS = math.floor((duelTracking.latencyPeakMS or 0) + 0.5)
    end
    -- Rating and detail totals use only source groups that match the opponent
    -- supplied by EVENT_DUEL_FINISHED. This deliberately rejects nearby or
    -- unidentifiable combat rather than saving it as part of the duel.
    if combatSummary and (combatSummary.damageDone or combatSummary.damageTaken) then
        damageDone = combatSummary.damageDone
        damageTaken = combatSummary.damageTaken
        if self:GetSettings().damageRatingEnabled then
            local difficultOpponent = IsEstablishedDifficultOpponent(
                self.savedVars.history,
                opponentDisplayName,
                opponentCharacterName
            )
            damageRatingMultiplier, damageRatingReason = CalculateDamageRatingMultiplier(
                won,
                drawn,
                damageDone,
                damageTaken,
                durationSeconds,
                duelTracking and duelTracking.peakOutgoingBurst,
                difficultOpponent
            )
        end
    end

    local duel = {
        id = self:NextDuelId(),
        timestamp = GetTimeStamp(),
        timeString = GetTimeString(),
        durationSeconds = durationSeconds,
        won = won,
        drawn = drawn,
        damageDone = damageDone,
        damageTaken = damageTaken,
        combatSummary = combatSummary,
        damageRatingMultiplier = damageRatingMultiplier,
        damageRatingReason = damageRatingReason,
        damageRatingRuleVersion = DAMAGE_RATING_RULE_VERSION,
        latencyBaselineMS = latencyBaselineMS,
        latencyPeakMS = latencyPeakMS,
        -- A conservative indicator for review: this remains a loss in the
        -- journal, but the reduction follows a saved confidence level.
        suspectedCcLock = suspectedCcLock,
        ccLockConfidence = ccLockConfidence,
        ccLockLossMultiplier = ccLockLossMultiplier,
        -- Latency is only a review flag. It never changes rating, placement,
        -- or recorded W-L-D without reliable packet-loss/desync evidence.
        suspectedLatencySpike = suspectedLatencySpike,
        latencySpikeConfidence = latencySpikeConfidence,
        -- Retain the final duel result for history and presentation.
        result = duelResult,
        player = {
            characterName = CleanCharacterName(GetUnitName("player")),
            displayName = GetDisplayName(),
            classId = playerClassId,
            className = NameForClass(playerClassId, playerGender),
            wasWerewolf = playerWasWerewolf,
            raceId = playerRaceId,
            raceName = NameForRace(playerRaceId, playerGender),
        },
        opponent = {
            characterName = CleanCharacterName(opponentCharacterName),
            displayName = opponentDisplayName and opponentDisplayName ~= "" and opponentDisplayName or "Unknown @name",
            alliance = opponentAlliance,
            classId = opponentClassId,
            className = NameForClass(opponentClassId, opponentGender),
            wasWerewolf = opponentWasWerewolf,
            werewolfEvidenceAbilityId = werewolfEvidenceAbilityId,
            raceId = opponentRaceId,
            raceName = NameForRace(opponentRaceId, opponentGender),
        },
    }

    -- The compact record is complete before it is persisted. Insert exactly
    -- one final record, then release every live-duel map before rating/UI work
    -- so no transient combat data can leak into a later duel.
    table.insert(self.savedVars.history, duel)
    -- Detailed Analytics remains session-only by default. It is deliberately
    -- kept outside SavedVariables until the player presses SAVE DUEL.
    if Analytics and Analytics.RegisterCompletedDuel then
        Analytics:SafeCall("RegisterCompletedDuel", duel, analyticsSummary)
    end
    self.currentDuelTracking = nil
    if #self.savedVars.history > MAX_HISTORY then
        table.remove(self.savedVars.history, 1)
    end
    local overallChange, overallPlacement, _, _, overallCalibration, overallDebug = self:ApplyRatingForDuel(duel)
    local classChange, classPlacement, _, _, classCalibration, classDebug = self:ApplyClassRatingForDuel(duel)
    duel.overallRatingChange = SignedRatingChange(duel, overallChange)
    duel.classRatingChange = SignedRatingChange(duel, classChange)
    duel.overallPlacement = overallPlacement
    duel.classPlacement = classPlacement
    duel.overallCalibration = overallCalibration
    duel.classCalibration = classCalibration
    duel.overallRatingDebug = overallDebug
    duel.classRatingDebug = classDebug
    local resultText = drawn and "Draw" or (won and "Win" or "Loss")
    Print(string.format(
        "%s vs %s - %s %s vs %s %s - %s",
        resultText,
        duel.opponent.displayName,
        duel.player.raceName,
        ClassDisplayForDuel(duel.player),
        duel.opponent.raceName,
        ClassDisplayForDuel(duel.opponent),
        FormatDuration(duel.durationSeconds)
    ))
    if suspectedCcLock then
        Print(string.format(
            "%s CC lock: this loss is marked in the journal and costs %.0f%% less rating.",
            ccLockConfidence or "POSSIBLE",
            (1 - (ccLockLossMultiplier or 1)) * 100
        ))
    end
    if suspectedLatencySpike then
        Print(string.format(
            "Suspected %s latency: baseline %d ms, peak %d ms. The loss is flagged for review; rating is unchanged.",
            zo_strlower(latencySpikeConfidence or "moderate"),
            latencyBaselineMS or 0,
            latencyPeakMS or 0
        ))
    end
    local overallExplanation = FormatProgressExplanation(duel, overallDebug)
    Print(string.format(
        "%s: Overall %s%s",
        won and "Victory" or (drawn and "Draw" or "Defeat"),
        FormatSignedRating(duel.overallRatingChange),
        overallExplanation and (" | " .. overallExplanation) or ""
    ))
    local classExplanation = FormatProgressExplanation(duel, classDebug)
    if classExplanation ~= overallExplanation then
        Print(string.format(
            "Class Tier: %s%s",
            FormatSignedRating(duel.classRatingChange),
            classExplanation and (" | " .. classExplanation) or ""
        ))
    end
    self:PrintSummary()
    if self.ui and not self.ui.window:IsHidden() then
        self:RefreshUI()
    end
end

