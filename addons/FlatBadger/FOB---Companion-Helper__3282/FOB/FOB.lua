FOB.Name = "FOB"

local enabledForScene = true
local enabledScenes = {
    ["hud"] = true,
    ["provisioner"] = true
}

local PENDING_COMPANION_STATES = {
    [COMPANION_STATE_PENDING] = true,
    [COMPANION_STATE_INITIALIZED_PENDING] = true
}

local ACTIVE_COMPANION_STATES = {
    [COMPANION_STATE_ACTIVE] = true
}

local INTERACTION_TYPES = {
    INTERACTION_NONE,
    INTERACTION_FISH,
    INTERACTION_HARVEST,
    INTERACTION_LOOT,
    INTERACTION_BOOK
}

FOB.Enabled = true

local function endInteraction()
    if (INTERACTIVE_WHEEL_MANAGER) then
        INTERACTIVE_WHEEL_MANAGER:StopInteraction(ZO_INTERACTIVE_WHEEL_TYPE_UTILITY)
    end

    EndPendingInteraction()

    for _, interactionType in ipairs(INTERACTION_TYPES) do
        EndInteraction(interactionType)
    end

    return true
end

local function FOBHandler(interactionPossible, _)
    if (interactionPossible and FOB.Enabled and enabledForScene and HasActiveCompanion()) then
        if (not FOB.ActiveCompanionDefId) then
            FOB.ActiveCompanionDefId = GetActiveCompanionDefId()
        end

        if (not FOB.Functions[FOB.ActiveCompanionDefId]) then
            return false
        end

        local action, interactableName, _, _, additionalInfo, _, _, isCriminalInteract =
            GetGameCameraInteractableActionInfo()

        if
            (FOB.Functions[FOB.ActiveCompanionDefId].Dislikes(
                action,
                interactableName,
                isCriminalInteract,
                additionalInfo
            ))
        then
            FOB.ReplaceReticle()
            EndPendingInteraction()
            return endInteraction
        end

        -- are we trying to talk to someone?
        if (action == FOB.Actions.Talk and FOB.Vars.DisableCompanionInteraction) then
            -- is it a companion?
            local isCompanionAction = FOB.LC.PartialMatch(interactableName, FOB.CompanionNames)

            if (isCompanionAction) then
                if (not FOB.Exceptions[interactableName]) then
                    -- companion detected - we don't want to talk to you, cancel the interaction
                    EndPendingInteraction()
                    return endInteraction()
                end
            end
        end

        FOB.RestoreReticle()

        return false
    end
end

-- disable FOB in irrelevant scenes
local function sceneHandler(_, newState)
    local scene = SCENE_MANAGER:GetCurrentScene():GetName()

    if (newState == "showing") then
        enabledForScene = enabledScenes[scene] or false
        --FOB.Log(enabledForScene, "warn")
    end
end

function FOB.RunCompanionFunctions()
    -- Zerith
    PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
end

function FOB.OnCompanionStateChanged(_, newState, _)
    if (FOB.Vars.UseCompanionSummoningFrame) then
        if (CF ~= nil) then
            return
        end

        if (ACTIVE_COMPANION_STATES[newState]) then
            FOB.SummoningFrame:SetHidden(true)
        end

        if (PENDING_COMPANION_STATES[newState]) then
            FOB.HideDefaultCompanionFrame()

            if (HasPendingCompanion()) and not IsCollectibleBlocked(GetCompanionCollectibleId(FOB.ActiveCompanion), GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
                local pendingCompanionDefId = GetPendingCompanionDefId()
                local pendingCompanionName = GetCompanionName(pendingCompanionDefId)
                local companionName = zo_strformat(SI_COMPANION_NAME_FORMATTER, pendingCompanionName)
                local summoning = GetString(SI_UNIT_FRAME_STATUS_SUMMONING)
                local summoningText = companionName .. ". " .. summoning

                FOB.SummoningFrame.Message:SetText(summoningText)
                FOB.SummoningFrame:SetHidden(false)
            end
        end
    end
end

function FOB.OnAddonLoaded(_, addonName)
    if (addonName ~= FOB.Name) then
        return
    end

    if (LibDebugLogger ~= nil) then
        FOB.Logger = LibDebugLogger(FOB.Name)
    end

    if (LibChatMessage ~= nil) then
        FOB.Chat = LibChatMessage(FOB.Name, "FOB")
    end

    if (RuEsoVariables ~= nil) then
        FOB.UsingRuEso = true
    end

    --FOB.Log("Loaded", "info")
    EVENT_MANAGER:UnregisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED)

    -- monitor scene changes
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneHandler)

    -- saved variables
    FOB.Vars =
        LibSavedVars:NewAccountWide("FOBSavedVars", "Account", FOB.Defaults):AddCharacterSettingsToggle(
            "FOBSavedVars",
            "Characters"
        )

    -- settings
    FOB.RegisterSettings()

    -- hook into the reticle interaction handler
    ZO_PreHook(RETICLE, "TryHandlingInteraction", FOBHandler)
    ZO_PreHook(ZO_Provisioner, "Create", FOB.ProvisionerHandler)

    if (DailyProvisioning) then
        ZO_PreHook(DailyProvisioning, "Crafting", FOB.DailyProvisioningOverride)
    end

    FOB.SetupCheeseAlert()
    FOB.SetupCoffeeAlert()

    -- if Companion Frame is installed, let it handle the summoning frame
    if (not CF) then
        FOB.CreateCompanionSummoningFrame()
    end

    EVENT_MANAGER:RegisterForEvent(
        FOB.Name,
        EVENT_ACTIVE_COMPANION_STATE_CHANGED,
        function(...)
            zo_callLater(
                function()
                    FOB.ActiveCompanionDefId = GetActiveCompanionDefId()
                    FOB.RestoreReticle()
                    FOB.RunCompanionFunctions()
                end,
                2000
            )

            FOB.OnCompanionStateChanged(...)
        end
    )

    FOB.ActiveCompanionDefId = GetActiveCompanionDefId()
end

EVENT_MANAGER:RegisterForEvent(FOB.Name, EVENT_ADD_ON_LOADED, FOB.OnAddonLoaded)
