(function()
    return function(Addon)
        Addon.ReticleDebouncer = Addon.ReticleDebouncer or {}
    
        local ReticleDebouncer = Addon.ReticleDebouncer
        local updateName = string.format("%s_ReticleDebounce", Addon.EventNamespace)
        local callback = nil
        local isFishingInteractionActive
    
        local function debugValue(value)
            if value == nil or value == "" then
                return "<nil>"
            end
    
            return tostring(value)
        end
    
        local function updateDebugSection(rawActionText, rawInteractableName, additionalInfo, resolvedTarget)
            if not Addon.DebugOverlay or not Addon.DebugOverlay.SetSection then
                return
            end
    
            Addon.DebugOverlay.SetSection("reticle", "Reticle Resolver", {
                string.format(
                    "raw=%s | %s",
                    debugValue(rawActionText),
                    debugValue(rawInteractableName)
                ),
                string.format(
                    "info=%s active=%s",
                    debugValue(additionalInfo),
                    tostring(isFishingInteractionActive())
                ),
                string.format(
                    "resolved=%s %s | %s",
                    tostring(resolvedTarget ~= nil),
                    debugValue(resolvedTarget and resolvedTarget.interactableName),
                    debugValue(resolvedTarget and resolvedTarget.actionText)
                ),
            })
        end
    
        local function containsFishingText(value)
            if type(value) ~= "string" or value == "" then
                return false
            end
    
            local lowered = string.lower(value)
            return string.find(lowered, "fish", 1, true) ~= nil
                or string.find(lowered, "bait", 1, true) ~= nil
        end
    
        isFishingInteractionActive = function()
            return type(GetInteractionType) == "function"
                and INTERACTION_FISH ~= nil
                and GetInteractionType() == INTERACTION_FISH
        end
    
        local function isReelReadyAction(value)
            if type(value) ~= "string" or value == "" then
                return false
            end
    
            if type(GetString) == "function" and SI_GAMECAMERAACTIONTYPE17 then
                local localizedReelAction = GetString(SI_GAMECAMERAACTIONTYPE17)
                if type(localizedReelAction) == "string" and localizedReelAction ~= "" then
                    return value == localizedReelAction
                end
            end
    
            return string.find(string.lower(value), "reel", 1, true) ~= nil
        end
    
        local function resolveCurrentTarget(previousTarget)
            if type(GetGameCameraInteractableActionInfo) ~= "function" then
                return nil
            end
    
            local actionText, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
            local fishingNodeInfo = ADDITIONAL_INTERACT_INFO_FISHING_NODE
            local isFishingHole = fishingNodeInfo ~= nil and additionalInfo == fishingNodeInfo
    
            if not isFishingHole then
                isFishingHole = containsFishingText(actionText) or containsFishingText(interactableName)
            end
    
            if not isFishingHole and isReelReadyAction(actionText) then
                isFishingHole = true
            end
    
            if not isFishingHole and previousTarget and previousTarget.isFishingHole and isFishingInteractionActive() then
                isFishingHole = true
                actionText = actionText or previousTarget.actionText
                interactableName = interactableName or previousTarget.interactableName
            end
    
            if not isFishingHole then
                updateDebugSection(actionText, interactableName, additionalInfo, nil)
                return nil
            end
    
            local resolvedTarget = {
                actionText = actionText,
                interactableName = interactableName,
                additionalInfo = additionalInfo,
                isFishingHole = true,
            }
    
            updateDebugSection(actionText, interactableName, additionalInfo, resolvedTarget)
    
            return resolvedTarget
        end
    
        ReticleDebouncer.ResolveCurrentTarget = resolveCurrentTarget
    
        function ReticleDebouncer.Initialize(onTargetResolved)
            callback = onTargetResolved
    
            EVENT_MANAGER:UnregisterForEvent(updateName, EVENT_RETICLE_TARGET_CHANGED)
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            EVENT_MANAGER:RegisterForEvent(updateName, EVENT_RETICLE_TARGET_CHANGED, function()
                EVENT_MANAGER:UnregisterForUpdate(updateName)
                EVENT_MANAGER:RegisterForUpdate(updateName, 500, function()
                    EVENT_MANAGER:UnregisterForUpdate(updateName)
    
                    if callback then
                        callback(resolveCurrentTarget())
                    end
                end)
            end)
        end
    end
    
end)()(_G["TheArtaeumAngler"])
