if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Buff food/drink functions and checks
------------------------------------------------------------------------------------------------------------

function FCOSS.checkBuffFoodFadedDelayed(buffType)
    --Delay the alert message 1 second, so refreshing/overwriting an existing buff food will get noticed
    zo_callLater(function()
        --d("-> onEventBuffFoodFadedDelayed")
        if not FCOSS.preventerVars.buffFoodRenewed then
            --d("--> drin")
            --Disable the warning before expiration check now
            FCOSS.setupWarningBeforeExpirationRepeat(true, nil, nil, nil, nil, nil, nil)
            --Buff food faded out and was not renewed
            --d("[FCOSS.checkBuffFoodFadedDelayed]buffFoodNotActive - true")
            FCOSS.buffFoodNotActive = true
            --Start the timer for the buff food refresh check again?
            local settings = FCOSS.settingsVars.settings
            FCOSS.setupAlertRepeat(settings.alertRepeatSeconds, settings.alertRepeatChatOutput, false)
            FCOSS.alertNow(buffType, settings.alertRepeatChatOutput, false)
        end
        FCOSS.preventerVars.buffFoodFaded = false
    end, 1000)
end

function FCOSS.checkForExistingBuffFood(foodOrDrinkName, chatOutput, debug, playerActivatedCalled)
    chatOutput = chatOutput or false
    debug = debug or false
    playerActivatedCalled = playerActivatedCalled or false
    --local numBuffsOnPlayer = GetNumBuffs("player")
    local name = ""
    --local foundName = ""
    local foundType = "none"
    local buffName, isDrink, startTime, endTime, iconFile, buffType, abilityId
    --Buff food is active
    local FOOD_BUFF_NONE = 0
    local timeLeftInSeconds = -1
    --New method to determine the active food/drin buffs via the library libFoodDrinkBuff
    local libFDB = FCOSS.libFDB
    --Returns 8: number buffTypeFoodDrink, bool isDrink, number abilityId, string buffName, number timeStarted, number timeEnds, string iconTexture, number timeLeftInSeconds
    buffType, isDrink, abilityId, buffName, startTime, endTime, iconFile, timeLeftInSeconds = libFDB:GetFoodBuffInfos('player')
    --Is the active food/drink buff a drink?
--d("[FCOSS]checkForExistingBuffFood - Buff '"..tostring(buffName).."', AbilityId: " .. tostring(abilityId) .. ", Bufftype: " .. tostring(buffType) .. ", startTime: " .. tostring(startTime) .. ", endTime: " .. tostring(endTime) .. ", timeLeftInSeconds: " .. tostring(timeLeftInSeconds) .. ", setupWarningBeforeExpirationRepeat: " .. tostring(FCOSS.preventerVars.setupWarningBeforeExpirationRepeat))
    if buffType ~= FOOD_BUFF_NONE then
        name = buffName or foodOrDrinkName
        --Remove trailing ^f endings etc...
        name = string.gsub(name, "%^.*", "")
        local locVars = FCOSS.localizationVars.fco_ss_loc
        if isDrink then
            foundType = locVars["found_type_drink"]
        else
            foundType = locVars["found_type_food"]
        end
        --Food buff was found?
        if foundType ~= "none" then
            --Setup the warning if food buff will expire in n minutes and you've setup a warning to show before expiration
            if not debug then
                local disable = (FCOSS.settingsVars.settings.showWarningBeforeExpiration <= 0) or false
                FCOSS.setupWarningBeforeExpirationRepeat(disable, name, startTime, endTime, iconFile, foundType, chatOutput, playerActivatedCalled)
            end
            --Show the chat output?
            if chatOutput and not FCOSS.preventerVars.setupWarningBeforeExpirationRepeat then
                FCOSS.outputActiveBuffFood(foundType, name)
            end
        end
    end
    return name, startTime, endTime, iconFile, foundType, timeLeftInSeconds
end

function FCOSS.checkActiveBuffFood(postToChat, noAlerts, override, playerActivatedCalled)
    --If we are in a lockpicking progress do not show the alert message now!
    --Show it after the lockpicking ends instead
    local prevVars = FCOSS.preventerVars
    if prevVars.lockpickInProgress then
        return
    end

    postToChat = postToChat or false
    noAlerts = noAlerts or false
    override = override or false
    playerActivatedCalled = playerActivatedCalled or false

    --Should the check be done now?
    local checkShouldBeDone = FCOSS.checkIfRepeatedCheck()
--d("[FCOSS.checkActiveBuffFood]checkShouldBeDone: " ..tostring(checkShouldBeDone))

    if not checkShouldBeDone and not override then return end

    --Check if buff food is still active?
    --return name, startTime, endTime, iconFile, foundType, timeLeftInSeconds
    local activeBuffFoodName = FCOSS.checkForExistingBuffFood(nil, postToChat, nil, playerActivatedCalled)
    --No food buff found as active one?
    if activeBuffFoodName == "" then
--d("[FCOSS.checkActiveBuffFood]buffFoodNotActive - true")
        FCOSS.buffFoodNotActive = true
        if not noAlerts then
            FCOSS.alertNow("n/a", postToChat, false)
        end
    --Active food buff was found
    else
--d("[FCOSS.checkActiveBuffFood]buffFoodNotActive - false")
        FCOSS.buffFoodNotActive = false
        prevVars.alreadyBuffFoodChecked = true
        FCOSS.ToggleAlertIcon(false, false, false)
        prevVars.alreadyBuffFoodChecked = false
    end
end

