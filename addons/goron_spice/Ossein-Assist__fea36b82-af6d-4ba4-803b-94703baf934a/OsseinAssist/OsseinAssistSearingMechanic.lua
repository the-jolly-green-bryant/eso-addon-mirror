function OsseinAssist.SetSearingCastLoggingEnabled(enabled)
    if enabled and not OsseinAssist.IsDevUser() then
        OsseinAssist.searingCastLoggingEnabled = false
        if OsseinAssist.savedVariables ~= nil then
            OsseinAssist.savedVariables.searingCastLoggingEnabled = false
        end
        OsseinAssist.RefreshSearingCastTrackingRegistration()
        d("Ossein Assist: searing cast logger is developer-only.")
        return
    end

    OsseinAssist.searingCastLoggingEnabled = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.searingCastLoggingEnabled = enabled
    end
    OsseinAssist.RefreshSearingCastTrackingRegistration()
    d(string.format("Ossein Assist: searing cast logger %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.FormatMsToMinuteSecondFromSession(ms)
    local totalSeconds = math.floor((tonumber(ms) or 0) / 1000)
    if totalSeconds < 0 then
        totalSeconds = 0
    end
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function OsseinAssist.TryLogSearingCastMechanic(result, abilityName, sourceName, abilityId)
    local shouldLog = OsseinAssist.searingCastLoggingEnabled and OsseinAssist.IsDevUser()
    local shouldTrackAssignment = OsseinAssist.IsSearingAssignmentActive()
    if not shouldLog and not shouldTrackAssignment then
        return
    end
    if not OsseinAssist.IsInOsseinCage() then
        return
    end
    if abilityName ~= OsseinAssist.searingSparksName and abilityName ~= OsseinAssist.searingBlazeName then
        return
    end

    local numericAbilityId = tonumber(abilityId)
    local bossKey = nil
    if numericAbilityId == OsseinAssist.searingSparksAbilityId then
        bossKey = OsseinAssist.jynorahName
    elseif numericAbilityId == OsseinAssist.searingBlazeAbilityId then
        bossKey = OsseinAssist.skorkifName
    end
    if bossKey == nil then
        if OsseinAssist.verboseDebugLoggingEnabled then
            OsseinAssist.DebugLog(string.format(
                "searing ignored: ability=%s result=%s id=%s",
                tostring(abilityName),
                tostring(result),
                tostring(abilityId)
            ))
        end
        return
    end

    -- Debounce per boss: searing hits multiple players, producing many events per cast.
    -- Only record the first event; ignore subsequent ones within the debounce window.
    local nowMs = GetFrameTimeMilliseconds()
    local lastCastMs = OsseinAssist.lastSearingCastByBoss[bossKey]
    if lastCastMs ~= nil and (nowMs - lastCastMs) < OsseinAssist.searingCastDebounceMs then
        return
    end

    OsseinAssist.MarkFightTwoDetected()
    if OsseinAssist.verboseDebugLoggingEnabled then
        OsseinAssist.DebugLog(string.format(
            "searing matched: boss=%s source=%s ability=%s id=%s result=%s",
            tostring(bossKey),
            tostring(sourceName),
            tostring(abilityName),
            tostring(abilityId),
            tostring(result)
        ))
    end

    if shouldLog then
        local clockText = OsseinAssist.FormatMsToMinuteSecondFromSession(nowMs)
        OsseinAssist.LogSearingMechanicMessage(string.format(
            "Ossein Assist: [Searing] %s %s cast %s (id=%s).",
            clockText,
            bossKey,
            abilityName,
            tostring(abilityId)
        ))
    end

    OsseinAssist.lastSearingCastByBoss[bossKey] = nowMs
    local otherBoss = bossKey == OsseinAssist.jynorahName and OsseinAssist.skorkifName or OsseinAssist.jynorahName
    local otherTimestamp = OsseinAssist.lastSearingCastByBoss[otherBoss]
    if otherTimestamp ~= nil then
        local deltaMs = math.abs(nowMs - otherTimestamp)
        if deltaMs <= OsseinAssist.searingPairWindowMs and math.abs(nowMs - OsseinAssist.lastSearingPairProcessMs) > 250 then
            OsseinAssist.lastSearingPairProcessMs = nowMs
            if shouldTrackAssignment then
                OsseinAssist.AdvanceSearingMechanicState()
            end
            if shouldLog and math.abs(nowMs - OsseinAssist.lastSearingPairAnnounceMs) > 250 then
                OsseinAssist.lastSearingPairAnnounceMs = nowMs
                OsseinAssist.LogSearingMechanicMessage(string.format("Ossein Assist: [Searing] paired cast detected (%d ms apart).", deltaMs))
            end
        end
    end
end

function OsseinAssist.RunSearingMechanicTest()
    if not OsseinAssist.IsDevUser() then
        OsseinAssist.LogSearingMechanicMessage("Ossein Assist: searing mechanic test is developer-only.")
        return
    end
    if not OsseinAssist.IsSearingAssignmentActive() then
        OsseinAssist.LogSearingMechanicMessage("Ossein Assist: assign Blue/Red 1/2 first (Not Assigned disables this feature).")
        return
    end

    OsseinAssist.AdvanceSearingMechanicState()
    OsseinAssist.LogSearingMechanicMessage(string.format(
        "Ossein Assist: [Searing Test] fire #%d -> %s %d",
        OsseinAssist.searingMechanicCount or 0,
        tostring(OsseinAssist.searingCurrentColor),
        tonumber(OsseinAssist.searingCurrentNumber) or 0
    ))
end

function OsseinAssist.ShouldTrackSearingCombatEvents()
    local shouldLog = OsseinAssist.searingCastLoggingEnabled and OsseinAssist.IsDevUser()
    local shouldTrackAssignment = OsseinAssist.IsSearingAssignmentActive()
    return shouldLog or shouldTrackAssignment
end

function OsseinAssist.OnSearingCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    OsseinAssist.TryLogSearingCastMechanic(result, abilityName, sourceName, abilityId)
end

function OsseinAssist.RefreshSearingCastTrackingRegistration()
    local namespaceBase = OsseinAssist.name .. "SearingTracking"
    local searingIds = { OsseinAssist.searingSparksAbilityId, OsseinAssist.searingBlazeAbilityId }
    local shouldTrack = OsseinAssist.ShouldTrackSearingCombatEvents()
    for _, abilityId in ipairs(searingIds) do
        local namespace = string.format("%s_%d", namespaceBase, abilityId)
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
        if shouldTrack then
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OsseinAssist.OnSearingCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        end
    end
end

function OsseinAssist.StartSearingCastTracking()
    OsseinAssist.RefreshSearingCastTrackingRegistration()
end
