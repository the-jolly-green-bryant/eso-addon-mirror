local SRC = SupportRotationCallouts
SRC.ColossusEventAdapter = SRC.ColossusEventAdapter or {}
local Adapter = SRC.ColossusEventAdapter
local C = SRC.Colossus

function Adapter:Initialize()
    self.lastCastBySource = {}

    for abilityId in pairs(C.ABILITY_IDS) do
        local eventName = SRC.name .. "ColossusCast" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    local enemyEffectEvent = SRC.name .. "MajorVulnerabilityEnemy"
    EVENT_MANAGER:RegisterForEvent(enemyEffectEvent, EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(false, ...) end)
    EVENT_MANAGER:AddFilterForEvent(enemyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, C.MAJOR_VULNERABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(enemyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_COMBAT_RESULT, EFFECT_RESULT_UPDATED)
    EVENT_MANAGER:AddFilterForEvent(enemyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_OTHER)

    local dummyEffectEvent = SRC.name .. "MajorVulnerabilityDummy"
    EVENT_MANAGER:RegisterForEvent(dummyEffectEvent, EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(true, ...) end)
    EVENT_MANAGER:AddFilterForEvent(dummyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, C.MAJOR_VULNERABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(dummyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_COMBAT_RESULT, EFFECT_RESULT_UPDATED)
    EVENT_MANAGER:AddFilterForEvent(dummyEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_TARGET_DUMMY)

    local deathResults = {
        ACTION_RESULT_DIED,
        ACTION_RESULT_DIED_XP,
    }
    for index, result in ipairs(deathResults) do
        if result then
            local eventName = SRC.name .. "BossDeath" .. tostring(index)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) self:OnDeathEvent(...) end)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
        end
    end

    SRC.Diagnostics:Add("EVENT", "Colossus and Major Vulnerability listeners registered")
end

function Adapter:GetSourceIdentity(sourceUnitId, accountName, sourceName)
    if sourceUnitId and sourceUnitId ~= 0 then
        return tostring(sourceUnitId), "unitId"
    end

    local normalizedAccount = SRC:NormalizeAccountName(accountName)
    if normalizedAccount ~= "" then
        return normalizedAccount, "account"
    end

    local normalizedCharacter = zo_strlower(zo_strtrim(zo_strformat("<<1>>", sourceName or "unknown")))
    if normalizedCharacter == "" then normalizedCharacter = "unknown" end
    return normalizedCharacter, "character"
end

function Adapter:IsDuplicateOrUpgrade(sourceIdentity, abilityId, isPriorityTarget)
    local nowMs = GetGameTimeMilliseconds()
    local key = tostring(sourceIdentity) .. ":" .. tostring(abilityId)
    local previous = self.lastCastBySource[key]

    if previous and nowMs - previous.timeMs < C.CAST_DEDUPE_MS then
        if isPriorityTarget and not previous.priorityTarget then
            previous.priorityTarget = true
            previous.timeMs = nowMs
            return false, "priority-upgrade", nowMs - previous.firstSeenMs
        end
        return true, "duplicate", nowMs - previous.firstSeenMs
    end

    self.lastCastBySource[key] = {
        timeMs = nowMs,
        firstSeenMs = nowMs,
        priorityTarget = isPriorityTarget,
    }
    return false, "new", 0
end

function Adapter:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if not SRC.saved.enabled or SRC.saved.colossusEnabled == false then return end
    if not C.ABILITY_IDS[abilityId] then return end

    local isDummy = targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY
    local isBoss = SRC:IsBossTarget(targetName, nil)
    local priorityTarget = isDummy or isBoss
    local account = SRC.Roster:GetAccountFromCharacter(sourceName)
    local sourceIdentity, identityType = self:GetSourceIdentity(sourceUnitId, account, sourceName)

    SRC.Diagnostics:AddFields("RAW_CAST", "EVENT_COMBAT_EVENT", {
        abilityId = abilityId,
        abilityName = abilityName,
        result = result,
        isError = isError,
        sourceName = sourceName,
        sourceType = sourceType,
        sourceUnitId = sourceUnitId,
        identity = sourceIdentity,
        identityType = identityType,
        account = account,
        targetName = targetName,
        targetType = targetType,
        targetUnitId = targetUnitId,
        isBoss = isBoss,
        isDummy = isDummy,
        hitValue = hitValue,
        log = log,
    })

    if isDummy and not SRC.saved.dummyMode then
        SRC.Diagnostics:Add("CAST", "Rejected target dummy because dummy mode is disabled")
        return
    end

    local duplicate, decision, elapsedMs = self:IsDuplicateOrUpgrade(sourceIdentity, abilityId, priorityTarget)
    SRC.Diagnostics:AddFields("DEDUPE", "Colossus cast decision", {
        decision = decision,
        duplicate = duplicate,
        elapsedMs = elapsedMs,
        identity = sourceIdentity,
        abilityId = abilityId,
        priorityTarget = priorityTarget,
    })
    if duplicate then return end

    SRC.ColossusRotation:OnColossusCast({
        abilityId = abilityId,
        result = result,
        sourceName = sourceName,
        accountName = account,
        sourceUnitId = sourceUnitId,
        sourceIdentity = sourceIdentity,
        sourceIdentityType = identityType,
        targetName = targetName,
        targetUnitId = targetUnitId,
        targetType = targetType,
        isBoss = isBoss,
        isDummy = isDummy,
        castTimeMs = GetGameTimeMilliseconds(),
        fromCombatEvent = true,
    })
end

function Adapter:OnDeathEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if not SRC.saved.enabled or SRC.saved.colossusEnabled == false then return end

    local isKnownBoss = SRC:IsBossTarget(targetName, nil)
    SRC.Diagnostics:AddFields("RAW_DEATH", "EVENT_COMBAT_EVENT", {
        result = result,
        targetName = targetName,
        targetType = targetType,
        targetUnitId = targetUnitId,
        isKnownBoss = isKnownBoss,
        sourceName = sourceName,
        sourceUnitId = sourceUnitId,
        abilityId = abilityId,
    })

    if not isKnownBoss then return end
    SRC:OnBossDeath(targetName)
end

function Adapter:OnEffectChanged(isDummy, _, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
        stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName,
        unitId, abilityId, sourceType)
    if not SRC.saved.enabled or SRC.saved.colossusEnabled == false then return end
    if abilityId ~= C.MAJOR_VULNERABILITY_ID then return end

    local nowSeconds = GetGameTimeSeconds()
    local remaining = endTime - nowSeconds
    local isBoss = not isDummy and SRC:IsBossTarget(unitName, unitTag)

    SRC.Diagnostics:AddFields("RAW_EFFECT", "EVENT_EFFECT_CHANGED", {
        changeType = changeType,
        effectSlot = effectSlot,
        effectName = effectName,
        unitTag = unitTag,
        unitName = unitName,
        unitId = unitId,
        abilityId = abilityId,
        beginTime = string.format("%.3f", beginTime),
        endTime = string.format("%.3f", endTime),
        remaining = string.format("%.3f", remaining),
        sourceType = sourceType,
        effectType = effectType,
        statusEffectType = statusEffectType,
        isBoss = isBoss,
        isDummy = isDummy,
    })

    if remaining <= 0 then
        SRC.Diagnostics:Add("EFFECT", "Ignored expired Major Vulnerability update")
        return
    end

    if isDummy and not SRC.saved.dummyMode then
        SRC.Diagnostics:Add("EFFECT", "Ignored dummy Major Vulnerability because dummy mode is disabled")
        return
    end

    if not isDummy then
        local allowed = false
        local reason = "NON_BOSS_TARGET"
        if SRC.CombatContextEngine then
            allowed, reason = SRC.CombatContextEngine:CanTrackHostileEffect(unitTag, unitId, unitName)
        else
            allowed = isBoss
        end
        if not allowed then
            SRC.Diagnostics:AddFields("EFFECT_CONTEXT", "Ignored Major Vulnerability outside active target context", {
                unitName = unitName,
                unitId = unitId,
                reason = reason,
            })
            return
        end
    end

    SRC.ColossusRotation:OnMajorVulnerabilityUpdate({
        unitTag = unitTag,
        unitName = unitName,
        unitId = unitId,
        beginTime = beginTime,
        endTime = endTime,
        receivedMs = GetGameTimeMilliseconds(),
        isBoss = isBoss,
        isDummy = isDummy,
    })
end
