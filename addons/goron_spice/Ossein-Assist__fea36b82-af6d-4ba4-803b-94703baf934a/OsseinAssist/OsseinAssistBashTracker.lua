function OsseinAssist.ConfigureBarZones()
    local dangerWidth = math.floor(OsseinAssist.bashBarMaxWidth * (1 - OsseinAssist.rollWarningStartProgress) + 0.5)
    local safeWidth = OsseinAssist.bashBarMaxWidth - dangerWidth
    OsseinAssistIndicatorBarSafe:SetWidth(safeWidth)
    OsseinAssistIndicatorBarDanger:SetWidth(dangerWidth)
end

function OsseinAssist.ApplyIndicatorAnchor()
    OsseinAssistIndicator:ClearAnchors()
    OsseinAssistIndicator:SetAnchor(TOP, GuiRoot, TOP, OsseinAssist.heavyIndicatorOffsetX, OsseinAssist.heavyIndicatorOffsetY)
end

function OsseinAssist.SetHeavyIndicatorOffsetX(value)
    local offsetX = math.floor(tonumber(value) or 0)
    OsseinAssist.heavyIndicatorOffsetX = offsetX
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.heavyIndicatorOffsetX = offsetX
    end
    OsseinAssist.ApplyIndicatorAnchor()
end

function OsseinAssist.SetHeavyIndicatorOffsetY(value)
    local offsetY = math.floor(tonumber(value) or 0)
    OsseinAssist.heavyIndicatorOffsetY = offsetY
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.heavyIndicatorOffsetY = offsetY
    end
    OsseinAssist.ApplyIndicatorAnchor()
end

function OsseinAssist.StartHeavySettingsPreview()
    if OsseinAssist.activeBashCast ~= nil then
        return
    end

    OsseinAssist.heavySettingsPreviewActive = true

    OsseinAssistIndicator:SetAlpha(1)
    OsseinAssistIndicator:SetHidden(false)
    OsseinAssist.SetBashBarProgress(0.62)
    OsseinAssistIndicatorLabel:SetText("Preview: Aspect Heavy")

    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HeavySettingsPreviewMonitor")
    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "HeavySettingsPreviewMonitor", 100, function()
        if not OsseinAssist.heavySettingsPreviewActive then
            EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HeavySettingsPreviewMonitor")
            return
        end
        if not IsConsoleUI() then
            return
        end
        if type(OsseinAssist.IsLibHarvensSettingsSceneShowing) == "function"
            and not OsseinAssist.IsLibHarvensSettingsSceneShowing() then
            OsseinAssist.StopHeavySettingsPreview()
            return
        end
        if LibHarvensAddonSettings == nil or LibHarvensAddonSettings.list == nil then
            OsseinAssist.StopHeavySettingsPreview()
            return
        end
        local selectedData = LibHarvensAddonSettings.list:GetSelectedData()
        local tooltipFn = selectedData and selectedData.tooltipText or nil
        local isHeavyTooltip = type(tooltipFn) == "function"
            and OsseinAssist.heavyTooltipFunctionLookup ~= nil
            and OsseinAssist.heavyTooltipFunctionLookup[tooltipFn] == true
        if not isHeavyTooltip then
            OsseinAssist.StopHeavySettingsPreview()
        end
    end)
end

function OsseinAssist.StopHeavySettingsPreview()
    OsseinAssist.heavySettingsPreviewActive = false
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HeavySettingsPreviewUpdate")
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HeavySettingsPreviewMonitor")
    if OsseinAssist.activeBashCast == nil then
        OsseinAssist.HideBashBar()
    end
end

function OsseinAssist.PokeHeavySettingsPreview()
    if not OsseinAssist.heavySettingsPreviewActive then
        OsseinAssist.StartHeavySettingsPreview()
    end
end

function OsseinAssist.SetBashVisualsEnabled(enabled)
    OsseinAssist.enableBashVisuals = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.enableBashVisuals = enabled
    end
    if not enabled then
        OsseinAssist.HideBashBar()
        OsseinAssist.pendingTrackedCastBegins = {}
    end
    d(string.format("Ossein Assist: bash visuals %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.SetHeavyStartSoundEnabled(enabled)
    OsseinAssist.playHeavyStartSound = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.playHeavyStartSound = enabled
    end
    d(string.format("Ossein Assist: heavy-start sound %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.SetStartupBarTestEnabled(enabled)
    if enabled and not OsseinAssist.IsDevUser() then
        OsseinAssist.runStartupBarTest = false
        if OsseinAssist.savedVariables ~= nil then
            OsseinAssist.savedVariables.runStartupBarTest = false
        end
        d("Ossein Assist: startup bar test is developer-only.")
        return
    end
    OsseinAssist.runStartupBarTest = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.runStartupBarTest = enabled
    end
    d(string.format("Ossein Assist: startup bar test %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.PlayHeavyStartSound()
    if not OsseinAssist.playHeavyStartSound then
        return
    end

    local preferredSound = (SOUNDS ~= nil and SOUNDS.DUEL_START) or nil
    local fallbackSound = (SOUNDS ~= nil and SOUNDS.DEFAULT_CLICK) or nil
    local soundId = preferredSound or fallbackSound
    if soundId ~= nil then
        PlaySound(soundId)
    end
end


function OsseinAssist.PrepareIndicatorForConsole()
    OsseinAssist.ApplyIndicatorAnchor()
    OsseinAssistIndicator:SetDrawLayer(DL_OVERLAY)
    OsseinAssistIndicator:SetDrawTier(DT_HIGH)
    OsseinAssistIndicator:SetDrawLevel(50)
    OsseinAssistIndicator:SetMouseEnabled(false)
    OsseinAssistIndicator:SetAlpha(1)
    OsseinAssistIndicator:SetHidden(true)
end

function OsseinAssist.GetTrackedCastProfile(abilityName, sourceName, isInTestZone, isTrialFight)
    for _, profile in ipairs(OsseinAssist.trackedCastProfiles) do
        local zoneMatch = (profile.zone == "test" and isInTestZone) or (profile.zone == "trial" and isTrialFight)
        if profile.zone == "test" and not OsseinAssist.CanMonitorTestAdd() then
            zoneMatch = false
        end
        if zoneMatch and abilityName == profile.abilityName then
            if profile.zone == "trial" then
                local resolvedAspectName = OsseinAssist.ResolveAspectEncounterName(sourceName)
                if resolvedAspectName ~= nil and resolvedAspectName == profile.sourceName then
                    return profile
                end
            end
            if OsseinAssist.IsSourceNameMatch(sourceName, profile.sourceName) then
                return profile
            end
        end
    end

    return nil
end

function OsseinAssist.GetTrackedCastProfileByAbilityId(abilityId)
    for _, profile in ipairs(OsseinAssist.trackedCastProfiles) do
        if profile.abilityId ~= nil and profile.abilityId == abilityId then
            return profile
        end
        if profile.knownAbilityIds ~= nil then
            for _, knownId in ipairs(profile.knownAbilityIds) do
                if knownId == abilityId then
                    return profile
                end
            end
        end
    end

    return nil
end

function OsseinAssist.HasAnyTrackedCastAbilityIds()
    for _, profile in ipairs(OsseinAssist.trackedCastProfiles) do
        if profile.abilityId ~= nil then
            return true
        end
        if profile.knownAbilityIds ~= nil and #profile.knownAbilityIds > 0 then
            return true
        end
    end

    return false
end

function OsseinAssist.RegisterFilteredCombatEvents()
    for _, profile in ipairs(OsseinAssist.trackedCastProfiles) do
        local legacyNamespace = string.format("%s_%s", OsseinAssist.name, profile.key)
        EVENT_MANAGER:UnregisterForEvent(legacyNamespace, EVENT_COMBAT_EVENT)

        local idsToRegister = {}
        if profile.knownAbilityIds ~= nil then
            for _, id in ipairs(profile.knownAbilityIds) do
                idsToRegister[id] = true
            end
        elseif profile.abilityId ~= nil then
            idsToRegister[profile.abilityId] = true
        end

        for abilityId in pairs(idsToRegister) do
            local namespace = string.format("%s_%s_%d", OsseinAssist.name, profile.key, abilityId)
            EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OsseinAssist.OnCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        end
    end
end

function OsseinAssist.LogDiscoveredAbilityId(profile, abilityId, abilityName, resultName)
    if abilityId == nil then
        return
    end

    local profileLog = OsseinAssist.loggedAbilityIdsByProfileKey[profile.key]
    if profileLog == nil then
        profileLog = {}
        OsseinAssist.loggedAbilityIdsByProfileKey[profile.key] = profileLog
    end

    if profileLog[abilityId] then
        return
    end

    profileLog[abilityId] = true
    OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: discovered abilityId for %s => %d (ability=%s, result=%s).", profile.label, abilityId, tostring(abilityName), tostring(resultName)))
end

function OsseinAssist.GetDurationConfigForProfile(profile)
    local minDurationMs = profile.minDurationMs or OsseinAssist.defaultCastMinDurationMs
    local maxDurationMs = profile.maxDurationMs or OsseinAssist.defaultCastMaxDurationMs
    local defaultDurationMs = profile.defaultDurationMs or OsseinAssist.defaultCastDurationMs
    return minDurationMs, maxDurationMs, defaultDurationMs
end

function OsseinAssist.GetActionResultDebugName(result)
    if type(GetActionResultName) == "function" then
        local resultName = GetActionResultName(result)
        if resultName ~= nil and resultName ~= "" then
            return resultName
        end
    end

    return tostring(result)
end

function OsseinAssist.GetBashCastDurationMs(profile, abilityId)
    local durationMs = 0
    local castInfoAbilityId = abilityId
    if profile ~= nil and profile.durationAbilityId ~= nil then
        castInfoAbilityId = profile.durationAbilityId
    end
    if type(GetAbilityCastInfo) == "function" and castInfoAbilityId ~= nil then
        local _, castTimeMs, channelTimeMs = GetAbilityCastInfo(castInfoAbilityId)
        durationMs = math.max(castTimeMs or 0, channelTimeMs or 0)
    end

    local minDurationMs, maxDurationMs, defaultDurationMs = OsseinAssist.GetDurationConfigForProfile(profile)
    local learnedDurationMs = OsseinAssist.learnedDurationMsByProfileKey[profile.key]
    if durationMs <= 0 then
        durationMs = learnedDurationMs or defaultDurationMs
    end

    return zo_clamp(durationMs, minDurationMs, maxDurationMs)
end

function OsseinAssist.SetBashBarProgress(progress)
    local clamped = zo_clamp(progress, 0, 1)
    local width = math.floor(OsseinAssist.bashBarMaxWidth * clamped + 0.5)
    OsseinAssistIndicatorBarFill:SetWidth(width)

    local lineX = zo_clamp(width - 1, 0, OsseinAssist.bashBarMaxWidth - 1)
    OsseinAssistIndicatorProgressLine:ClearAnchors()
    OsseinAssistIndicatorProgressLine:SetAnchor(LEFT, OsseinAssistIndicatorBarBackground, LEFT, lineX, -2)
end

function OsseinAssist.HideBashBar()
    OsseinAssist.activeBashCast = nil
    OsseinAssistIndicator:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "BashBarUpdate")
end

function OsseinAssist.StartStartupBarTest()
    if not OsseinAssist.runStartupBarTest then
        return
    end

    local testDurationMs = 3000
    local testStartMs = GetFrameTimeMilliseconds()

    OsseinAssistIndicator:SetHidden(false)
    OsseinAssistIndicatorLabel:SetText("Ossein Assist: Visual Test")
    OsseinAssist.SetBashBarProgress(0)

    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "StartupBarTestUpdate", 16, function()
        local elapsedMs = GetFrameTimeMilliseconds() - testStartMs
        local progress = zo_clamp(elapsedMs / testDurationMs, 0, 1)
        OsseinAssist.SetBashBarProgress(progress)

        if progress >= 1 then
            EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "StartupBarTestUpdate")
            OsseinAssistIndicatorLabel:SetText("Ossein Assist: Visual Test Complete")
            zo_callLater(OsseinAssist.HideBashBar, 750)
        end
    end)
end

function OsseinAssist.OnBashBarUpdate()
    local castData = OsseinAssist.activeBashCast
    if castData == nil then
        OsseinAssist.HideBashBar()
        return
    end

    local elapsedMs = GetFrameTimeMilliseconds() - castData.startTimeMs
    local progress = elapsedMs / castData.durationMs
    -- Keep the bar visible until the actual "fire" event arrives.
    local displayProgress = math.min(progress, 0.99)
    OsseinAssist.SetBashBarProgress(displayProgress)
    OsseinAssistIndicatorLabel:SetText(string.format("%s (%.0f ms)", castData.label, math.max(castData.durationMs - elapsedMs, 0)))

    -- Failsafe: hide if no completion event arrives soon after predicted impact.
    if elapsedMs >= (castData.durationMs + 450) then
        OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: %s bar timed out waiting for resolve event.", castData.label))
        OsseinAssist.HideBashBar()
    end
end

function OsseinAssist.StartBashBar(profile, abilityId)
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "StartupBarTestUpdate")
    OsseinAssist.StopHeavySettingsPreview()

    local durationMs = OsseinAssist.GetBashCastDurationMs(profile, abilityId)
    OsseinAssist.activeBashCast = {
        profileKey = profile.key,
        profile = profile,
        abilityId = abilityId,
        startTimeMs = GetFrameTimeMilliseconds(),
        durationMs = durationMs,
        label = profile.label,
    }

    OsseinAssistIndicator:SetAlpha(1)
    OsseinAssistIndicator:SetHidden(false)
    OsseinAssist.SetBashBarProgress(0)
    OsseinAssistIndicatorLabel:SetText(profile.label)
    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "BashBarUpdate", 16, OsseinAssist.OnBashBarUpdate)
end

function OsseinAssist.CompleteBashBar(profile, abilityId)
    local castData = OsseinAssist.activeBashCast
    if castData == nil then
        return
    end
    if abilityId ~= nil and castData.abilityId ~= abilityId then
        OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: cast id mismatch (start=%d fire=%d). Completing anyway.", castData.abilityId, abilityId))
    end

    local elapsedMs = GetFrameTimeMilliseconds() - castData.startTimeMs
    local minDurationMs, maxDurationMs = OsseinAssist.GetDurationConfigForProfile(profile)
    local clampedElapsedMs = zo_clamp(elapsedMs, minDurationMs, maxDurationMs)
    local priorLearnedDurationMs = OsseinAssist.learnedDurationMsByProfileKey[profile.key]
    if priorLearnedDurationMs == nil then
        OsseinAssist.learnedDurationMsByProfileKey[profile.key] = clampedElapsedMs
    else
        -- Smooth prediction toward real observed timings.
        OsseinAssist.learnedDurationMsByProfileKey[profile.key] = math.floor((priorLearnedDurationMs * 0.7) + (clampedElapsedMs * 0.3) + 0.5)
    end

    local learnedDurationMs = OsseinAssist.learnedDurationMsByProfileKey[profile.key]
    OsseinAssist.SetBashBarProgress(1)
    OsseinAssistIndicatorLabel:SetText(string.format("%s resolved (%d ms)", profile.label, elapsedMs))
    OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: %s resolved after %d ms (prediction now %d ms).", profile.label, elapsedMs, learnedDurationMs))
    zo_callLater(OsseinAssist.HideBashBar, 250)
end

function OsseinAssist.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, _, _, abilityId)
    if not OsseinAssist.enableBashVisuals then
        return
    end

    local isInOsseinCage = OsseinAssist.IsInOsseinCage()
    local isInTestZone = OsseinAssist.IsInTestZone()
    if not isInOsseinCage and not isInTestZone then
        return
    end

    local hasKnownFightTwoSource = isInOsseinCage and OsseinAssist.IsFightTwoSourceName(sourceName)
    if hasKnownFightTwoSource then
        OsseinAssist.MarkFightTwoDetected()
        OsseinAssist.DebugLog(string.format("combat event source confirms fight2: source=%s ability=%s id=%s result=%s", tostring(sourceName), tostring(abilityName), tostring(abilityId), tostring(result)))
    end
    local isTrialFight = isInOsseinCage and (OsseinAssist.IsJynorahAndSkorkhifFight() or hasKnownFightTwoSource)
    local castProfile = OsseinAssist.GetTrackedCastProfileByAbilityId(abilityId)
    if castProfile == nil then
        castProfile = OsseinAssist.GetTrackedCastProfile(abilityName, sourceName, isInTestZone, isTrialFight)
    end
    if castProfile == nil then
        if isTrialFight or isInTestZone or hasKnownFightTwoSource then
            OsseinAssist.DebugLog(string.format(
                "combat event not tracked: ability=%s source=%s id=%s result=%s trialFight=%s testZone=%s",
                tostring(abilityName),
                tostring(sourceName),
                tostring(abilityId),
                tostring(result),
                tostring(isTrialFight),
                tostring(isInTestZone)
            ))
        end
        return
    end

    OsseinAssist.DebugLog(string.format(
        "combat event matched profile=%s ability=%s source=%s id=%s result=%s trialFight=%s",
        tostring(castProfile.key),
        tostring(abilityName),
        tostring(sourceName),
        tostring(abilityId),
        tostring(result),
        tostring(isTrialFight)
    ))

    local hasAnyKnownIds = castProfile.abilityId ~= nil
        or (castProfile.knownAbilityIds ~= nil and #castProfile.knownAbilityIds > 0)
    if not hasAnyKnownIds then
        local resultName = OsseinAssist.GetActionResultDebugName(result)
        OsseinAssist.LogDiscoveredAbilityId(castProfile, abilityId, abilityName, resultName)
    end

    local resultName = OsseinAssist.GetActionResultDebugName(result)
    local isBegin = result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL

    if isBegin then
        OsseinAssist.pendingTrackedCastBegins[abilityId] = {
            profileKey = castProfile.key,
            startTimeMs = GetFrameTimeMilliseconds(),
        }
        OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: %s started (id=%d, result=%s).", castProfile.label, abilityId, resultName))
        if castProfile.zone == "trial" then
            OsseinAssist.PlayHeavyStartSound()
        end
        if OsseinAssist.enableBashVisuals then
            OsseinAssist.StartBashBar(castProfile, abilityId)
        end
        return
    end

    -- Resolve on first non-begin event for the tracked cast.
    local pendingCastData = OsseinAssist.pendingTrackedCastBegins[abilityId]
    local hasMatchingPendingCast = pendingCastData ~= nil and pendingCastData.profileKey == castProfile.key
    local hasMatchingActiveCast = OsseinAssist.activeBashCast ~= nil and OsseinAssist.activeBashCast.profileKey == castProfile.key
    if not hasMatchingPendingCast and not hasMatchingActiveCast then
        return
    end

    if hasMatchingPendingCast then
        local elapsedMs = GetFrameTimeMilliseconds() - pendingCastData.startTimeMs
        OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: %s resolved after %d ms (id=%d, result=%s).", castProfile.label, elapsedMs, abilityId, resultName))
        OsseinAssist.pendingTrackedCastBegins[abilityId] = nil
    else
        OsseinAssist.LogAspectHeavyMessage(string.format("Ossein Assist: %s resolved (id=%d, result=%s).", castProfile.label, abilityId, resultName))
    end

    if OsseinAssist.enableBashVisuals then
        OsseinAssist.CompleteBashBar(castProfile, abilityId)
    end
end
