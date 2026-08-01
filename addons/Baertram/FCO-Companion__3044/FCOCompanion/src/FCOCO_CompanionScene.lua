FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------
--[[
local sm = SCENE_MANAGER

local origIsInteractingWithMyCompanion = IsInteractingWithMyCompanion
local wasIsInteractingWithMyCompanionOverwritten = false

local companionSceneGroupKeyboard   = "companionSceneGroup"
local companionSceneGamepad         = "companionRootGamepad"
]]
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--[[
local function isCompanionSceneShown()
    local currentScene = sm.currentScene
    --Keyboard mode
    if not IsInGamepadPreferredMode() then
        return currentScene.sceneGroup == sm:GetSceneGroup(companionSceneGroupKeyboard)
    else
        --Gamepad mode
        return currentScene.name == companionSceneGamepad
    end
end

--Attention: IsInteractingWithMyCompanion() will return false if only the scene is shown!
--So as a workaround we will overwrite it here to return true if the scene is shown
if wasIsInteractingWithMyCompanionOverwritten == false then
    function IsInteractingWithMyCompanion()
        return origIsInteractingWithMyCompanion() or isCompanionSceneShown()
    end
    wasIsInteractingWithMyCompanionOverwritten = true
end


--Open the companion menu without interaction with the companion
-->Not working! Will only show the controls but the chatter which starts the interaction with the companion was missing
-->before and thus we cannot equip/unquip items etc.
local specificScene
local function OnOpenCompanionMenu()
    --Keyboard mode
    if not IsInGamepadPreferredMode() then
        local sceneGroup = sm:GetSceneGroup(companionSceneGroupKeyboard)
        specificScene = sceneGroup:GetActiveScene()
        sm:Show(specificScene)
    else
        --Gamepad mode
        sm:Show(companionSceneGamepad)
    end
end
FCOCompanion.OpenCompanionMenu = OnOpenCompanionMenu
]]


------------------------------------------------------------------------------------------------------------------------
local function checkCollectibleId(collectibleId)
    --Check if the collectibleId is given and unlocked
    local isCollectibleBlocked = IsCollectibleBlacklisted(collectibleId) or IsCollectibleBlocked(collectibleId) or not IsCollectibleUsable(collectibleId)
    local isCollectibleActive = IsCollectibleActive(collectibleId)
--d(string.format("[checkCollectibleId]collectibleId: %s, isCollectibleBlocked: %s, isCollectibleActive: %s", tostring(collectibleId), tostring(isCollectibleBlocked), tostring(isCollectibleActive)))
    return not isCollectibleBlocked and isCollectibleActive
end

local function toggleCompanion(companionIdToShow, doShow, onlyIfLastCompanionWasKnown)
    local companionId
    local companionCollectibleId
    local doSummonOtherCompanion = false
    local doUseNow = false
    local companionInfo = FCOCompanion.companionInfo
    onlyIfLastCompanionWasKnown = onlyIfLastCompanionWasKnown or false

    local lastCompanionDefId = FCOCompanion.settingsVars.settings.lastCompanionId
    if lastCompanionDefId == nil then
        if onlyIfLastCompanionWasKnown == true then return end
        lastCompanionDefId = 1 --Bastian Helix, companionDefId 1,
    end

    --Current active assistant:
    --local activeAssistantId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    --if activeAssistantId ~= 0 then
        --local assistantData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id)
    --end

    --A companion was called: Abort here and wait until it is there.
    local companionIsOnTheWay = HasPendingCompanion()
    local companionIsActive = HasActiveCompanion()

    --Companion was called and is on the way
    if companionIsOnTheWay == true then
        companionId = GetPendingCompanionDefId()
    --Companion is actively shown
    elseif companionIsActive == true then
        companionId = GetActiveCompanionDefId()
    --Companion is not on the way, and not active
    else
        companionId = companionIdToShow
        --Which companion should be shown if non explicictly asked for?
        --Use the last known from the settings. If this is nil the default value 1 will be used
        if companionId == nil then companionId = lastCompanionDefId end
    end

    --Was the "toggle" keybind used and no show/hide was passed in?
    --Then change the show or hide depending on the currently active companionId (if any is active),
    --or else if non is shown > show. If any is shown -> hide
    if doShow == nil then
        --A companion is currently active?
        if companionIsActive then
            --Is the active companionId the same as the one to show? Then hide it.
            if companionIdToShow ~= nil then
                if companionId == companionIdToShow then
                    doShow = false
                --if it's another hide the active one and show the other
                else
                    doShow = true
                    doSummonOtherCompanion = true
                end
            else
                doShow = false
            end
        else
            --No companion active: Show it
            doShow = true
        end
    --Show/hide was given as parameter
    else
        --Show a companion
        if doShow == true then
            --Is the shown one already the one to show? Abort then
            if companionIdToShow ~= nil and companionId == companionIdToShow then
                if not companionIsActive and onlyIfLastCompanionWasKnown == true then
                    --Coming from crafting table interaction END event
                    companionId = companionIdToShow
                else
                    return
                end
            else
                doSummonOtherCompanion = true
            end
            --Hide a companion
            --elseif doShow == false then
        end
    end

--d(string.format("FCOCO]toggleCompanion - companionIsActive: %s, companionIsOnTheWay: %s, companionId: %s, companionIdToShow: %s, doShow: %s, doSummonOtherCompanionAfterwards: %s", tostring(companionIsActive), tostring(companionIsOnTheWay), tostring(companionId), tostring(companionIdToShow), tostring(doShow), tostring(doSummonOtherCompanion)))

    --Companion was called: Abort here and let it arrive first!
    if not companionId then return end
    if companionIsOnTheWay then return end
    --Hide a companion but nothing to hide is active? Abort
    if not doShow and not companionIsActive then return end

    --Get the collectibleId of the companion by the help of the "to use" companion's id
    if doSummonOtherCompanion == true then
        companionCollectibleId = companionInfo[companionIdToShow]
    else
        companionCollectibleId = GetCompanionCollectibleId(companionId)
    end
    if not companionCollectibleId then return end
    --Does this collectibleId exist already (live server: no, PTS: yes)


    local isActive = checkCollectibleId(companionCollectibleId)

    if doShow == true and not isActive then
        --Show the collectible
        doUseNow = true
    elseif not doShow and isActive == true then
        --Hide the collectible
        doUseNow = true
    end
--d(">collectibleIde: " .. tostring(companionCollectibleId) .. ", doUseNow: " ..tostring(doUseNow))

    if doUseNow == true then

        local isCollectibleUsable = IsCollectibleUsable(companionCollectibleId)
        local isCollectibleBlocked = IsCollectibleBlocked(companionCollectibleId)
        local collectibleBlockReason = GetCollectibleBlockReason(companionCollectibleId)
        local collectableCooldownLeft = GetCollectibleCooldownAndDuration(companionCollectibleId)

--d(">Collectible usable: " ..tostring(isCollectibleUsable) .. ", blocked: " ..tostring(isCollectibleBlocked) .. ", blockReason: " ..tostring(collectibleBlockReason) .. ", cdLeft: " ..tostring(collectableCooldownLeft))
        local delay = 0
        if isCollectibleUsable == true then
            if not isCollectibleBlocked or (isCollectibleBlocked and collectibleBlockReason == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
                if collectableCooldownLeft ~= nil and collectableCooldownLeft > 0 then --and doShow == true then
                --Collectible is on cooldown. Delay the call to the summon/dismiss process by the cooldown left
                delay = collectableCooldownLeft
            end
            else
                --Collectible blocked
                return
            end
        else
            --Collectible not usable
            return
        end

        --Use the companion collectibleId, delayed if any cooldown left
        zo_callLater(function()
--d("!!! Using collectible: companionCollectibleId !!! - Delayed: " ..tostring(delay))
            UseCollectible(companionCollectibleId)
        end, delay)
    end
end
FCOCompanion.ToggleCompanion = toggleCompanion