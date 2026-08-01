local Addon = TheArtaeumAngler

Addon.FishingLogic = Addon.FishingLogic or {}

local FishingLogic = Addon.FishingLogic
local stateUpdateName = string.format("%s_FishingState", Addon.EventNamespace)
local INTERACTION_POLL_MS = 250
local MAX_CAST_LATCH_MS = 45000
local PROMPT_RESHOW_DELAY_MS = 750
local isFishingInteractionActive

local function debugValue(value)
    if value == nil or value == "" then
        return "<nil>"
    end

    return tostring(value)
end

local function pushDebugEvent(message)
    if Addon.DebugOverlay and Addon.DebugOverlay.PushEvent then
        Addon.DebugOverlay.PushEvent(message)
    end
end

local function isTargetSuppressed(targetData)
    if not targetData or not targetData.isFishingHole then
        return false
    end

    if type(FishingLogic.suppressUntilMs) ~= "number" then
        return false
    end

    if type(GetFrameTimeMilliseconds) ~= "function" then
        FishingLogic.suppressUntilMs = nil
        return false
    end

    if GetFrameTimeMilliseconds() < FishingLogic.suppressUntilMs then
        return true
    end

    FishingLogic.suppressUntilMs = nil
    return false
end

local function suppressPromptBriefly()
    if type(GetFrameTimeMilliseconds) ~= "function" then
        FishingLogic.suppressUntilMs = nil
        return
    end

    FishingLogic.suppressUntilMs = GetFrameTimeMilliseconds() + PROMPT_RESHOW_DELAY_MS
end

local function clearSuppressedPromptState()
    FishingLogic.suppressUntilMs = nil
end

local function inferWaterTypeFromTarget(targetData)
    if not targetData or not Addon.BaitManager or not Addon.BaitManager.NormalizeWaterType then
        return nil
    end

    local normalizedWaterType = Addon.BaitManager.NormalizeWaterType(targetData.interactableName)

    if normalizedWaterType ~= "unknown" then
        return normalizedWaterType
    end

    normalizedWaterType = Addon.BaitManager.NormalizeWaterType(targetData.actionText)

    if normalizedWaterType ~= "unknown" then
        return normalizedWaterType
    end

    return nil
end

local function getWaterType(targetData)
    local inferredWaterType = inferWaterTypeFromTarget(targetData or FishingLogic.activeTarget)

    if inferredWaterType then
        return inferredWaterType
    end

    if FishingLogic.confirmedWaterType then
        return FishingLogic.confirmedWaterType
    end

    if type(GetFishingWaterType) == "function"
        and (FishingLogic.fishingCastActive or isFishingInteractionActive())
    then
        local rawWaterType = GetFishingWaterType()
        local normalizedWaterType = Addon.BaitManager
            and Addon.BaitManager.NormalizeWaterType
            and Addon.BaitManager.NormalizeWaterType(rawWaterType)
            or "unknown"

        if normalizedWaterType ~= "unknown" then
            FishingLogic.confirmedWaterType = normalizedWaterType
            return normalizedWaterType
        end
    end

    return "Unknown"
end

local function contains(value, needle)
    return string.find(value, needle, 1, true) ~= nil
end

local function isReelReadyAction(actionText)
    if type(actionText) ~= "string" or actionText == "" then
        return false
    end

    if type(GetString) == "function" and SI_GAMECAMERAACTIONTYPE17 then
        local localizedReelAction = GetString(SI_GAMECAMERAACTIONTYPE17)
        if type(localizedReelAction) == "string" and localizedReelAction ~= "" then
            return actionText == localizedReelAction
        end
    end

    return contains(string.lower(actionText), "reel")
end

isFishingInteractionActive = function()
    return type(GetInteractionType) == "function"
        and INTERACTION_FISH ~= nil
        and GetInteractionType() == INTERACTION_FISH
end

local function resetTransientFishingState()
    FishingLogic.biteDetected = false
    FishingLogic.confirmedWaterType = nil
    FishingLogic.lastBaitCount = nil
    FishingLogic.lastBaitLureIndex = nil
    FishingLogic.castStartedAtMs = nil
    FishingLogic.fishingCastActive = false
    FishingLogic.reelActionObserved = false
end

local function getCurrentLureSnapshot()
    if type(GetFishingLure) ~= "function" or type(GetFishingLureInfo) ~= "function" then
        return nil
    end

    local lureIndex = GetFishingLure()

    if type(lureIndex) ~= "number" or lureIndex <= 0 then
        return nil
    end

    local name, icon, stackCount = GetFishingLureInfo(lureIndex)

    return {
        count = stackCount or 0,
        icon = icon,
        lureIndex = lureIndex,
        name = name,
    }
end

local function buildDisplayModel(targetData)
    local model = Addon.BaitManager.BuildModel(getWaterType(targetData))
    local reelReady = FishingLogic.biteDetected == true

    model.isReelReady = reelReady
    model.promptHintText = reelReady and Addon.Strings.reelHint or ""
    model.promptStateColor = reelReady and Addon.StateColors.reel or model.stateColor
    model.promptStateText = reelReady and Addon.Strings.reelReady
        or model.waterTypeLabel
        or Addon.WaterTypeLabels.unknown
    model.allowSelector = not FishingLogic.fishingCastActive
        and not reelReady
        and model.state ~= "empty"
        and #model.rows > 0

    return model
end

local function updateDebugSection(reason, interactionSnapshot, targetData)
    if not Addon.DebugOverlay or not Addon.DebugOverlay.SetSection then
        return
    end

    local activeTarget = targetData or FishingLogic.activeTarget
    local rawWaterType = type(GetFishingWaterType) == "function" and GetFishingWaterType() or nil
    local model = FishingLogic.model

    Addon.DebugOverlay.SetSection("logic", "Fishing Logic", {
        string.format(
            "reason=%s cast=%s interaction=%s reel=%s",
            debugValue(reason),
            tostring(FishingLogic.fishingCastActive == true),
            tostring(isFishingInteractionActive()),
            tostring(model and model.isReelReady == true)
        ),
        string.format(
            "biteDetected=%s actionReel=%s",
            tostring(FishingLogic.biteDetected == true),
            tostring(activeTarget and isReelReadyAction(activeTarget.actionText) or false)
        ),
        string.format(
            "reelActionObserved=%s",
            tostring(FishingLogic.reelActionObserved == true)
        ),
        string.format(
            "target=%s | action=%s",
            debugValue(activeTarget and activeTarget.interactableName),
            debugValue(activeTarget and activeTarget.actionText)
        ),
        string.format(
            "snapshot=%s | info=%s",
            debugValue(interactionSnapshot and interactionSnapshot.actionText),
            debugValue(interactionSnapshot and interactionSnapshot.additionalInfo)
        ),
        string.format(
            "water raw=%s inferred=%s confirmed=%s model=%s",
            debugValue(rawWaterType),
            debugValue(inferWaterTypeFromTarget(activeTarget)),
            debugValue(FishingLogic.confirmedWaterType),
            debugValue(model and model.waterType)
        ),
        string.format(
            "bait=%s x%s state=%s",
            debugValue(model and model.recommendedName),
            tostring(model and model.recommendedCount or 0),
            debugValue(model and model.state)
        ),
        string.format(
            "lureIndex=%s lastCount=%s castStarted=%s",
            debugValue(FishingLogic.lastBaitLureIndex),
            debugValue(FishingLogic.lastBaitCount),
            debugValue(FishingLogic.castStartedAtMs)
        ),
        string.format(
            "interact=%s -> %s | ended=%s/%s",
            debugValue(FishingLogic.lastInteractResult),
            debugValue(FishingLogic.lastInteractTargetName),
            debugValue(FishingLogic.lastInteractionEndType),
            debugValue(FishingLogic.lastInteractionEndCancelContext)
        ),
    })
end

local function getCurrentFishingTarget()
    if Addon.ReticleDebouncer and Addon.ReticleDebouncer.ResolveCurrentTarget then
        return Addon.ReticleDebouncer.ResolveCurrentTarget(FishingLogic.activeTarget)
    end

    return nil
end

local function clearActiveTarget()
    if FishingLogic.activeTarget then
        pushDebugEvent("Target cleared")
    end

    FishingLogic.activeTarget = nil
    FishingLogic.model = nil
    resetTransientFishingState()

    if Addon.UI and Addon.UI.HideReticlePrompt then
        Addon.UI.HideReticlePrompt()
    end

    updateDebugSection("clear_target")
end

local function getInteractionSnapshot()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return nil
    end

    local actionText, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()

    return {
        actionText = actionText,
        additionalInfo = additionalInfo,
        interactableName = interactableName,
        isFishingInteractionActive = isFishingInteractionActive(),
    }
end

local function syncFishingCastState(interactionSnapshot, targetData)
    local interactionActive = interactionSnapshot and interactionSnapshot.isFishingInteractionActive or false

    if interactionActive then
        FishingLogic.fishingCastActive = true
        return
    end

    if not FishingLogic.fishingCastActive then
        return
    end

    if FishingLogic.biteDetected then
        return
    end

    if type(GetFrameTimeMilliseconds) == "function"
        and FishingLogic.castStartedAtMs
        and (GetFrameTimeMilliseconds() - FishingLogic.castStartedAtMs) >= MAX_CAST_LATCH_MS
    then
        pushDebugEvent("Cast latch expired")
        FishingLogic.fishingCastActive = false

        if Addon.UI and Addon.UI.CloseBaitSelector then
            Addon.UI.CloseBaitSelector()
        end

        if targetData then
            FishingLogic.confirmedWaterType = nil
        end
    end
end

local function updateBiteState()
    if not FishingLogic.fishingCastActive or FishingLogic.biteDetected then
        return false
    end

    local currentLure = getCurrentLureSnapshot()

    if not currentLure then
        return false
    end

    if currentLure.lureIndex ~= FishingLogic.lastBaitLureIndex then
        FishingLogic.lastBaitLureIndex = currentLure.lureIndex
        FishingLogic.lastBaitCount = currentLure.count
        pushDebugEvent(string.format("Tracking lure %s x%s", debugValue(currentLure.name), tostring(currentLure.count)))
        return false
    end

    if FishingLogic.lastBaitCount ~= nil and currentLure.count < FishingLogic.lastBaitCount then
        FishingLogic.biteDetected = true
        pushDebugEvent(string.format(
            "Bite detected from bait drop %s -> %s",
            tostring(FishingLogic.lastBaitCount),
            tostring(currentLure.count)
        ))
        FishingLogic.lastBaitCount = currentLure.count
        return true
    end

    FishingLogic.lastBaitCount = currentLure.count
    return false
end

local function hasVisibleReelAction(interactionSnapshot, targetData)
    if interactionSnapshot and isReelReadyAction(interactionSnapshot.actionText) then
        return true
    end

    if targetData and isReelReadyAction(targetData.actionText) then
        return true
    end

    if FishingLogic.activeTarget and isReelReadyAction(FishingLogic.activeTarget.actionText) then
        return true
    end

    return false
end

local function shouldFinalizeCompletedFishing(interactionSnapshot, targetData)
    if not FishingLogic.biteDetected then
        return false
    end

    if hasVisibleReelAction(interactionSnapshot, targetData) then
        FishingLogic.reelActionObserved = true
        return false
    end

    if FishingLogic.reelActionObserved ~= true then
        return false
    end

    return not (interactionSnapshot and interactionSnapshot.isFishingInteractionActive)
end

local function refreshPrompt(targetData)
    if targetData then
        FishingLogic.activeTarget = targetData
    end

    if not FishingLogic.activeTarget then
        clearActiveTarget()
        return
    end

    local previousModel = FishingLogic.model
    FishingLogic.model = buildDisplayModel(FishingLogic.activeTarget)

    if FishingLogic.model.isReelReady
        and not (previousModel and previousModel.isReelReady)
        and type(PlaySound) == "function"
    then
        if SOUNDS and SOUNDS.ABILITY_READY then
            PlaySound(SOUNDS.ABILITY_READY)
        end

        if SOUNDS and SOUNDS.JUSTICE_PICKPOCKET_BONUS then
            PlaySound(SOUNDS.JUSTICE_PICKPOCKET_BONUS)
        end
    end

    if Addon.UI and Addon.UI.CloseBaitSelector and FishingLogic.model.isReelReady then
        Addon.UI.CloseBaitSelector()
    end

    if Addon.UI and Addon.UI.UpdateReticlePrompt then
        Addon.UI.UpdateReticlePrompt(FishingLogic.model)
    end

    updateDebugSection("refresh_prompt", nil, FishingLogic.activeTarget)
end

local function onInteractionEnded(_, oldInteractionType, cancelContext)
    FishingLogic.lastInteractionEndType = oldInteractionType
    FishingLogic.lastInteractionEndCancelContext = cancelContext

    if oldInteractionType ~= INTERACTION_FISH then
        pushDebugEvent(string.format(
            "Interaction ended (non-fish %s/%s)",
            debugValue(oldInteractionType),
            debugValue(cancelContext)
        ))
        updateDebugSection("interaction_ended_non_fish")
        return
    end

    FishingLogic.confirmedWaterType = nil
    FishingLogic.fishingCastActive = false
    FishingLogic.lastInteractResult = nil
    FishingLogic.lastInteractTargetName = nil
    suppressPromptBriefly()
    pushDebugEvent("Fishing interaction ended")

    clearActiveTarget()
end

function FishingLogic.OnReticleTargetChanged(targetData)
    if not targetData or not targetData.isFishingHole then
        clearSuppressedPromptState()

        if FishingLogic.fishingCastActive or isFishingInteractionActive() then
            refreshPrompt()
            updateDebugSection("reticle_cast_latched")
            return
        end

        clearActiveTarget()
        return
    end

    if isTargetSuppressed(targetData) then
        if Addon.UI and Addon.UI.HideReticlePrompt then
            Addon.UI.HideReticlePrompt()
        end

        updateDebugSection("reticle_target_suppressed", nil, targetData)
        return
    end

    pushDebugEvent("Fishing hole targeted")
    refreshPrompt(targetData)
    updateDebugSection("reticle_target_changed", nil, targetData)
end

function FishingLogic.OpenSelector()
    if not FishingLogic.activeTarget or not FishingLogic.model then
        return
    end

    if Addon.UI and Addon.UI.OpenBaitSelector then
        Addon.UI.OpenBaitSelector(FishingLogic.model)
    end
end

function FishingLogic.ConfirmSelection(rowData)
    if not rowData then
        return
    end

    Addon.BaitManager.ApplyChoice(rowData)
    refreshPrompt()
end

local function onFishingLureSet()
    local currentLure = getCurrentLureSnapshot()

    FishingLogic.confirmedWaterType = nil
    FishingLogic.lastBaitLureIndex = currentLure and currentLure.lureIndex or nil
    FishingLogic.lastBaitCount = currentLure and currentLure.count or nil
    pushDebugEvent("Lure changed")

    if not FishingLogic.activeTarget then
        updateDebugSection("fishing_lure_set")
        return
    end

    refreshPrompt()
end

local function onClientInteractResult(_, result, interactTargetName)
    FishingLogic.lastInteractResult = result
    FishingLogic.lastInteractTargetName = interactTargetName

    if result == CLIENT_INTERACT_RESULT_SUCCESS and FishingLogic.activeTarget then
        local currentLure = getCurrentLureSnapshot()

        if FishingLogic.biteDetected then
            pushDebugEvent("Reel interaction succeeded")
            suppressPromptBriefly()
            resetTransientFishingState()
            clearActiveTarget()

            updateDebugSection("reel_success")
            return
        end

        FishingLogic.fishingCastActive = true
        if type(GetFrameTimeMilliseconds) == "function" then
            FishingLogic.castStartedAtMs = GetFrameTimeMilliseconds()
        else
            FishingLogic.castStartedAtMs = nil
        end
        FishingLogic.lastBaitLureIndex = currentLure and currentLure.lureIndex or nil
        FishingLogic.lastBaitCount = currentLure and currentLure.count or nil
        pushDebugEvent(string.format(
            "Cast started with %s x%s",
            debugValue(currentLure and currentLure.name),
            tostring(currentLure and currentLure.count or 0)
        ))
    end

    pushDebugEvent(string.format("Interact %s -> %s", debugValue(result), debugValue(interactTargetName)))
    updateDebugSection("client_interact_result")
end

local function pollCurrentFishingState()
    local interactionSnapshot = getInteractionSnapshot()
    local targetData = getCurrentFishingTarget()

    if isTargetSuppressed(targetData) then
        targetData = nil
    end

    syncFishingCastState(interactionSnapshot, targetData)
    if updateBiteState() then
        refreshPrompt(targetData or FishingLogic.activeTarget)
        updateDebugSection("poll_bite", interactionSnapshot, targetData or FishingLogic.activeTarget)
        return
    end

    if shouldFinalizeCompletedFishing(interactionSnapshot, targetData) then
        pushDebugEvent("Fishing cycle completed")
        suppressPromptBriefly()
        clearActiveTarget()
        updateDebugSection("poll_cycle_complete", interactionSnapshot, targetData)
        return
    end

    if interactionSnapshot
        and FishingLogic.activeTarget
        and (interactionSnapshot.isFishingInteractionActive or isReelReadyAction(interactionSnapshot.actionText))
    then
        targetData = targetData or {
            actionText = interactionSnapshot.actionText or FishingLogic.activeTarget.actionText,
            interactableName = interactionSnapshot.interactableName or FishingLogic.activeTarget.interactableName,
            additionalInfo = interactionSnapshot.additionalInfo or FishingLogic.activeTarget.additionalInfo,
            isFishingHole = true,
        }
    end

    if not targetData then
        if FishingLogic.fishingCastActive and FishingLogic.activeTarget then
            refreshPrompt()
            updateDebugSection("poll_latched", interactionSnapshot)
            return
        end

        if FishingLogic.activeTarget then
            clearActiveTarget()
        end
        return
    end

    if not FishingLogic.activeTarget
        or FishingLogic.activeTarget.actionText ~= targetData.actionText
        or FishingLogic.activeTarget.interactableName ~= targetData.interactableName
        or FishingLogic.activeTarget.additionalInfo ~= targetData.additionalInfo
        or (FishingLogic.model and FishingLogic.model.state == "unknown")
        or not FishingLogic.model
        or (
            interactionSnapshot
            and interactionSnapshot.isFishingInteractionActive
            and not FishingLogic.confirmedWaterType
        )
    then
        refreshPrompt(targetData)
        updateDebugSection("poll_refresh", interactionSnapshot, targetData)
        return
    end

    updateDebugSection("poll_idle", interactionSnapshot, targetData)
end

local function onAddOnLoaded(_, addonName)
    if addonName ~= Addon.Name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(Addon.EventNamespace, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(Addon.EventNamespace, EVENT_CLIENT_INTERACT_RESULT, onClientInteractResult)
    EVENT_MANAGER:RegisterForEvent(Addon.EventNamespace, EVENT_FISHING_LURE_SET, onFishingLureSet)
    EVENT_MANAGER:RegisterForEvent(Addon.EventNamespace, EVENT_INTERACTION_ENDED, onInteractionEnded)
    EVENT_MANAGER:UnregisterForUpdate(stateUpdateName)
    EVENT_MANAGER:RegisterForUpdate(stateUpdateName, INTERACTION_POLL_MS, pollCurrentFishingState)

    if Addon.UI then
        if Addon.DebugOverlay and Addon.DebugOverlay.Initialize then
            Addon.DebugOverlay.Initialize()
        end

        Addon.UI.SetOpenSelectorHandler(FishingLogic.OpenSelector)
        Addon.UI.SetConfirmSelectionHandler(FishingLogic.ConfirmSelection)
        Addon.UI.HideReticlePrompt()
    end

    Addon.ReticleDebouncer.Initialize(FishingLogic.OnReticleTargetChanged)
    updateDebugSection("addon_loaded")
end

EVENT_MANAGER:RegisterForEvent(Addon.EventNamespace, EVENT_ADD_ON_LOADED, onAddOnLoaded)
