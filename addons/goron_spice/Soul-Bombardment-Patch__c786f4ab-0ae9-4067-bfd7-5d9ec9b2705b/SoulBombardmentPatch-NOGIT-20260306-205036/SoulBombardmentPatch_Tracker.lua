function SoulBombardmentPatch.IsInBlackGemFoundry()
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex == nil then
        return false
    end

    local zoneName = GetZoneNameByIndex(zoneIndex)
    return zoneName == SoulBombardmentPatch.blackGemFoundryZoneName
end

function SoulBombardmentPatch.NormalizeCombatUnitName(unitName)
    if unitName == nil or unitName == "" then
        return nil
    end
    if type(zo_strformat) == "function" then
        return zo_strformat(SI_UNIT_NAME, unitName)
    end
    return tostring(unitName)
end

function SoulBombardmentPatch.IsBombardmentStartResult(result)
    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL then
        return true
    end
    if result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        return true
    end

    if type(GetActionResultName) == "function" then
        local resultName = tostring(GetActionResultName(result) or tostring(result))
        if string.find(resultName, "BEGIN", 1, true) ~= nil then
            return true
        end
        if string.find(resultName, "EFFECT_GAINED", 1, true) ~= nil then
            return true
        end
    end

    return false
end

function SoulBombardmentPatch.IsBombardmentEndResult(result)
    if result == ACTION_RESULT_EFFECT_FADED or result == ACTION_RESULT_EFFECT_FADED_DURATION then
        return true
    end
    if result == ACTION_RESULT_INTERRUPT then
        return true
    end

    if type(GetActionResultName) == "function" then
        local resultName = tostring(GetActionResultName(result) or tostring(result))
        if string.find(resultName, "FADED", 1, true) ~= nil then
            return true
        end
        if string.find(resultName, "INTERRUPT", 1, true) ~= nil then
            return true
        end
    end

    return false
end

function SoulBombardmentPatch.IsSignalAbilityId(abilityId)
    local numericId = tonumber(abilityId)
    if numericId == nil then
        return false
    end
    return SoulBombardmentPatch.soulEssenceBombardmentSignalAbilityIds[numericId] == true
end

function SoulBombardmentPatch.LogSignalAbilityEvent(abilityId, abilityName, sourceName, targetName)
    local idText = tostring(tonumber(abilityId) or abilityId or "none")
    local nameText = tostring(abilityName or "none")
    local sourceText = SoulBombardmentPatch.NormalizeCombatUnitName(sourceName) or "none"
    local targetText = SoulBombardmentPatch.NormalizeCombatUnitName(targetName) or "none"

    d(string.format(
        "Soul Bombardment Patch signal: name=%s id=%s source=%s target=%s",
        nameText,
        idText,
        sourceText,
        targetText
    ))
end

function SoulBombardmentPatch.HandleBombardmentCombatEvent(result, abilityId)
    local numericId = tonumber(abilityId)
    if numericId ~= SoulBombardmentPatch.soulEssenceBombardmentAbilityId then
        return
    end

    if SoulBombardmentPatch.IsBombardmentStartResult(result) then
        SoulBombardmentPatch.StartCastWindow()
        return
    end

    if SoulBombardmentPatch.activeCast ~= nil and SoulBombardmentPatch.IsBombardmentEndResult(result) then
        SoulBombardmentPatch.ResolveCastWindow()
    end
end

function SoulBombardmentPatch.HandleSignalCombatEvent(result, abilityId, abilityName, sourceName, targetName)
    if not SoulBombardmentPatch.IsSignalAbilityId(abilityId) then
        return
    end

    SoulBombardmentPatch.LogSignalAbilityEvent(abilityId, abilityName, sourceName, targetName)
    if SoulBombardmentPatch.IsBombardmentStartResult(result) then
        if SoulBombardmentPatch.activeCast == nil then
            SoulBombardmentPatch.StartIncomingWarningWindow()
        end
        return
    end
    if SoulBombardmentPatch.IsBombardmentEndResult(result) then
        if SoulBombardmentPatch.activeIncomingWarning then
            SoulBombardmentPatch.ResolveIncomingWarningWindow()
        end
    end
end

function SoulBombardmentPatch.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not SoulBombardmentPatch.trackerEnabled then
        return
    end
    if not SoulBombardmentPatch.IsInBlackGemFoundry() then
        return
    end

    SoulBombardmentPatch.HandleBombardmentCombatEvent(result, abilityId)
    SoulBombardmentPatch.HandleSignalCombatEvent(result, abilityId, abilityName, sourceName, targetName)
end

function SoulBombardmentPatch.OnPlayerCombatState(eventCode, inCombat)
    if inCombat then
        SoulBombardmentPatch.wasPlayerInCombat = true
        return
    end

    if not SoulBombardmentPatch.wasPlayerInCombat then
        return
    end

    SoulBombardmentPatch.wasPlayerInCombat = false
    SoulBombardmentPatch.ResolveIncomingWarningWindow()
    if SoulBombardmentPatch.activeCast ~= nil then
        SoulBombardmentPatch.HideCastWindow()
    end
end

function SoulBombardmentPatch.RegisterCombatEventHandlers()
    local coreNamespace = SoulBombardmentPatch.name .. "CombatBombardmentCore"
    local signalNamespaceBase = SoulBombardmentPatch.name .. "CombatBombardmentSignal"
    local sourceDiscoveryNamespace = SoulBombardmentPatch.name .. "CombatSourceDiscovery"
    local oldBaseCombatNamespace = SoulBombardmentPatch.name .. "CombatBombardment"
    local corrosionNamespace = SoulBombardmentPatch.name .. "CombatCorrosion"
    local combatStateNamespace = SoulBombardmentPatch.name .. "CombatState"

    EVENT_MANAGER:UnregisterForEvent(coreNamespace, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(sourceDiscoveryNamespace, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(oldBaseCombatNamespace, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(corrosionNamespace, EVENT_COMBAT_EVENT)

    EVENT_MANAGER:RegisterForEvent(coreNamespace, EVENT_COMBAT_EVENT, SoulBombardmentPatch.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(
        coreNamespace,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,
        SoulBombardmentPatch.soulEssenceBombardmentAbilityId
    )

    local signalIds = SoulBombardmentPatch.soulEssenceBombardmentSignalAbilityIdList or {}
    for _, abilityId in ipairs(signalIds) do
        local namespace = string.format("%s%d", signalNamespaceBase, abilityId)
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, SoulBombardmentPatch.OnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    EVENT_MANAGER:UnregisterForEvent(combatStateNamespace, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:RegisterForEvent(combatStateNamespace, EVENT_PLAYER_COMBAT_STATE, SoulBombardmentPatch.OnPlayerCombatState)

    local signalText = "none"
    if #signalIds > 0 then
        local parts = {}
        for _, abilityId in ipairs(signalIds) do
            table.insert(parts, tostring(abilityId))
        end
        signalText = table.concat(parts, ",")
    end

    d(string.format(
        "Soul Bombardment Patch: tracking core=%d and signals=%s.",
        SoulBombardmentPatch.soulEssenceBombardmentAbilityId,
        signalText
    ))
end
