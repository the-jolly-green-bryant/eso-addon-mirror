if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Warnings Text, Icon, Sound
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- Buff food/drink alerts
------------------------------------------------------------------------------------------------------------
function FCOSS.UpdateAlertIconValues()
    if FCOSS.alertIcon == nil then return false end
    FCOSS.alertIcon:SetTexture(FCOSS.iconTextures[FCOSS.settingsVars.settings.iconAlertTexture])
    --FCOStarveStopContainer:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidth, FCOSS.settingsVars.settings.iconAlertHeight)
    FCOSS.alertIcon:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidth, FCOSS.settingsVars.settings.iconAlertHeight)
    FCOSS.alertIcon:ClearAnchors()
    FCOSS.alertIcon:SetParent(FCOStarveStopContainer)
    FCOStarveStopContainer:SetHidden(false)
    FCOSS.alertIcon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FCOSS.settingsVars.settings.iconAlertX, FCOSS.settingsVars.settings.iconAlertY)
    FCOSS.alertIcon:SetDrawLayer(1)
end

function FCOSS.ToggleAlertIcon(override, blink, test)
    if FCOSS.alertIcon == nil then return false end
    blink = blink or false
    test = test or false
    local settings = FCOSS.settingsVars.settings
    local prevVars = FCOSS.preventerVars

--d("[FCOSS.ToggleAlertIcon] override: " .. tostring(override) .. ", blink: " .. tostring(blink) .. ", test: " .. tostring(test))
    --Do not use the alert icon
    if not settings.iconAlert or override == false then
--d(">1")
        if override == nil and prevVars.changedBySettingsMenu then
            prevVars.iconShownBeforeMenuOpened = false
        end

        --If coming from the LAM settings panel and buff food is currently not active the icon should not be hidden automatically,
        --but only if the icon was shown already before the settings menu was opened!
        if prevVars.iconShownBeforeMenuOpened and not prevVars.alreadyBuffFoodChecked and override == false then
            local activeBuffFood = FCOSS.checkForExistingBuffFood(nil, false)
            if activeBuffFood == "" then
--d("<<<ABORT 1 -> No active buff food")
                return
            end
        end

        if not FCOSS.alertIcon:IsHidden() or FCOSS.alertIconIsBlinking then
--d(">2")
            prevVars.iconManuallyHidden = false
            --Only hide the icon if not in the settings menu, or if settings menu changed the value on purpose
            if not FCOStarveStop_SettingsMenu:IsHidden() and not prevVars.changedBySettingsMenu then
--d("<<<ABORT 2 -> MENU")
                return false
            end
            FCOStarveStopContainer:SetHidden(true)
            FCOSS.alertIcon:SetHidden(true)
            FCOSS.alertIconIsBlinking = false
        end
    --Use the alert icon
    elseif settings.iconAlert or override == true then
        if FCOSS.alertIcon:IsHidden() or blink or test then
            FCOSS.UpdateAlertIconValues()

            --Was the icon shown before the menu was open?
            if FCOStarveStop_SettingsMenu:IsHidden() then
                prevVars.iconShownBeforeMenuOpened = true
            end

            --Play a sound?
            if not settings.textAlert and (FCOStarveStop_SettingsMenu:IsHidden() or (not FCOStarveStop_SettingsMenu:IsHidden() and test)) then
                FCOSS.AlertSoundRepeat()
            end
            --Should the icon blink 3 times?
            --During each blink check if the food buff wasn't renewed in between and stop the blinking!
            if blink then
                if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                FCOSS.alertIconIsBlinking = true
                if FCOSS.alertIconIsBlinking then
                    if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                    FCOSS.alertIcon:SetHidden(false)
                    zo_callLater(function()
                        FCOSS.alertIcon:SetHidden(true)
                        --Check if blink should be aborted
                        if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                        zo_callLater(function()
                            if FCOSS.alertIconIsBlinking then
                                FCOSS.alertIcon:SetHidden(false)
                                zo_callLater(function()
                                    FCOSS.alertIcon:SetHidden(true)
                                    --Check if blink should be aborted
                                    if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                                    if FCOSS.alertIconIsBlinking then
                                        zo_callLater(function()
                                            --Check if blink should be aborted
                                            if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                                            FCOSS.alertIcon:SetHidden(false)
                                            FCOSS.alertIconIsBlinking = false
                                            if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end
                                            zo_callLater(function() if FCOSS.checkIfAlertIconBlinkShouldBeAborted() then return false end end, 1000)
                                        end, 650)
                                    end
                                end, 650)
                            end
                        end, 650)
                    end, 650)
                end
            else
                FCOSS.alertIcon:SetHidden(false)
                FCOSS.alertIconIsBlinking = false
                prevVars.iconManuallyHidden = false
            end
        end
    end
end

function FCOSS.AlertSoundRepeat()
    local settings = FCOSS.settingsVars.settings
    if settings.alertSound > 1 then
        PlaySound(SOUNDS[FCOSS.sounds[settings.alertSound]])
        if settings.alertSoundRepeat == 1 then return false end
        local delay = settings.alertSoundDelay or 1000
        for run = 1, settings.alertSoundRepeat-1, 1 do
            zo_callLater(function()
                PlaySound(SOUNDS[FCOSS.sounds[settings.alertSound]])
            end, delay)
            delay = ((run+1)*settings.alertSoundDelay) or ((run+1)*1000)
        end
    end
end

function FCOSS.checkIfAlertIconBlinkShouldBeAborted()
    --d("[FCOSS.checkIfAlertIconBlinkShouldBeAborted]")
    if FCOSS.preventerVars.iconManuallyHidden then
        --d(">manually hidden!")
        FCOSS.preventerVars.iconManuallyHidden = false
        FCOSS.alertIconIsBlinking = false
        return true
    end
    if not FCOSS.buffFoodNotActive then
        --d(">Food buff is active again: Stop blinking!")
        FCOSS.alertIconIsBlinking = false
        return true
    end
    --d("<<< return false")
    return false
end




------------------------------------------------------------------------------------------------------------
-- Potion alerts
------------------------------------------------------------------------------------------------------------
function FCOSS.UpdateAlertIconValuesPotion()
    if FCOSS.alertIconPotion == nil then return false end
    FCOSS.alertIconPotion:SetTexture(FCOSS.iconTextures[FCOSS.settingsVars.settings.iconAlertTexturePotion])
    --FCOStarveStopContainerPotion:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidthPotion, FCOSS.settingsVars.settings.iconAlertHeightPotion)
    FCOSS.alertIconPotion:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidthPotion, FCOSS.settingsVars.settings.iconAlertHeightPotion)
    FCOSS.alertIconPotion:ClearAnchors()
    FCOSS.alertIconPotion:SetParent(FCOStarveStopContainerPotion)
    FCOStarveStopContainerPotion:SetHidden(false)
    FCOSS.alertIconPotion:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FCOSS.settingsVars.settings.iconAlertXPotion, FCOSS.settingsVars.settings.iconAlertYPotion)
    FCOSS.alertIconPotion:SetDrawLayer(1)
end

--Toggle the potion alert icon
function FCOSS.toggleAlertIconPotion(override, test)
    if FCOSS.alertIconPotion == nil then return false end
    test = test or false

--d("[FCOSS.toggleAlertIconPotion] override: " .. tostring(override) ..", test: " .. tostring(test) .. ", lamShown: " .. tostring(FCOSS.addonMenu.isShown) .. ", preventPotionAlertIcon: " ..tostring(FCOSS.preventerVars.hidePotionAlertIcon))
    --if FCOSS.addonMenu.currentAddonPanel ~= nil then d("currentPanel: " .. tostring(FCOSS.addonMenu.currentAddonPanel:GetName())) end
    --Coming from the LAM settings panel -> Changed the active panel/or closed the lam panel
    --If potion alert icon should not already be hidden
    --If the potion alert should be hidden (override = false)
    --If the active panel is not FCOStarveStop
    --> Set variable to hide the icon then
    if (override == false and not FCOSS.preventerVars.hidePotionAlertIcon and FCOSS.addonMenu.isShown and FCOSS.addonMenu.currentAddonPanel:GetName() ~= FCOSS.addonMenuPanel:GetName()) then
        --Hide the potion alert icon now
        FCOSS.preventerVars.hidePotionAlertIcon = true
    end

    if not FCOSS.settingsVars.settings.iconAlertPotion or (override ~= nil and override == false) then
        if not FCOSS.preventerVars.hidePotionAlertIcon and override == nil and FCOSS.preventerVars.changedBySettingsMenuPotion then
            FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion = false
        end

        --[[
                --If coming from the LAM settings panel and potion is currently not active the icon should not be hidden automatically,
                --but only if the icon was shown already before the settings menu was opened!
                if not FCOSS.preventerVars.hidePotionAlertIcon and FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion and override ~= nil and override == false then
                    if not FCOSS.preventerVars.activePotionBuff then
                        return
                    end
                end
        ]]
        FCOSS.preventerVars.hidePotionAlertIcon = false

        if not FCOSS.alertIconPotion:IsHidden() then
            FCOSS.preventerVars.iconManuallyHiddenPotion = false
            --Only hide the icon if not in the settings menu, or if settings menu changed the value on purpose
            if not FCOStarveStop_SettingsMenu:IsHidden() and not FCOSS.preventerVars.changedBySettingsMenuPotion then
                return false
            end
            FCOStarveStopContainerPotion:SetHidden(true)
            FCOSS.alertIconPotion:SetHidden(true)
            FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion = false
        end

    elseif FCOSS.settingsVars.settings.iconAlertPotion or (override ~= nil and override) then
        if FCOSS.alertIconPotion:IsHidden() or test then
            FCOSS.UpdateAlertIconValuesPotion()

            --Was the icon shown before the menu was open?
            if FCOStarveStop_SettingsMenu:IsHidden() then
                FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion = true
            end
            FCOSS.alertIconPotion:SetHidden(false)
            FCOSS.preventerVars.iconManuallyHiddenPotion = false
            --Unregister any registered update function (for the automatic showing of the potion alert after the potion's cooldown ended)
            FCOSS.setupPotionAlert(0, nil, true)
        end
    end
end

function FCOSS.checkAndHidePotionAlertIconInHouse()
    --Are we in a house and the setting to hide alerts in a house is enabled?
    local settings = FCOSS.settingsVars.settings
    if settings.alertNotInHouse and FCOSS.checkIfInHouse() then
        if settings.iconAlertPotion then
            --If the potion alert icon is currently shown: Hide it
            if not FCOSS.alertIconPotion:IsHidden() then
                FCOSS.preventerVars.iconManuallyHiddenPotion = false
                FCOStarveStopContainerPotion:SetHidden(true)
                FCOSS.alertIconPotion:SetHidden(true)
                FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion = false
            end
        end
        return true
    end
    return false
end

--Show/Hide the potion alert now
function FCOSS.showPotionAlert(showPotionAlert, test)
    test = test or false
    showPotionAlert = showPotionAlert or false
--d("[FCOSS.showPotionAlert] showPotionAlert: " .. tostring(showPotionAlert) .. ", test: " .. tostring(test))

    --Show the potion alert now?
    if showPotionAlert then
        local settings = FCOSS.settingsVars.settings
        if not test then
            --Unregister any registered update function (for the automatic showing of the potion alert after the potion's cooldown ended)
            FCOSS.setupPotionAlert(0, nil, true)
        end

        --Is the potion alert active?
        if settings.potionAlert or test then
            --Are we in a house and the setting to hide alerts in a house is enabled?
            if FCOSS.checkAndHidePotionAlertIconInHouse() then
--d("[FCOSS] Potion: In a house, no alert will be shown!")
                return false
            end
            --Only check in combat?
            --Abort here if we are not inside combat
            if not test and settings.potionAlertOnlyInCombat and not FCOSS.inCombat then return false end
            --Change the active quickslot to the wanted one from the settings as the alert message is shown
            local potionName = FCOSS.checkActiveQuickSlotIsPotionAndChangeToPotionIfNeeded()
            --Is the text alert message set
            if settings.textAlertGeneralPotion ~= nil and settings.textAlertGeneralPotion ~= "" then
                --Build the tooltip text
                local textAlertWithPreText =  FCOSS.locVars.preChatTextRed .. settings.textAlertGeneralPotion
                FCOSS.alertTextGeneralPotion = textAlertWithPreText
                local alertTextPotion = settings.textAlertGeneralPotion
                if potionName ~= "" then
                    alertTextPotion = alertTextPotion .. " [" .. potionName .. "]"
                end
                --Text alert?
                if settings.textAlertPotion then
                    --CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_BROADCAST, CSA_EVENT_SMALL_TEXT, nil, alertTextPotion)
                    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
                    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
                    params:SetText(alertTextPotion)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
                end
            end
            --Icon alert?
            if settings.iconAlertPotion then
                --Show the potion alert icon
                FCOSS.toggleAlertIconPotion(true, test)
            end
            --Sound alert?
            FCOSS.AlertSoundRepeatPotion()
        end
        --Reset a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
        FCOSS.preventerVars.activePotionBuff = false
    else
        --Hide the potion alert icon
        FCOSS.toggleAlertIconPotion(false, false)
    end
end

--Function to setup a timer and show/hide the potion alert afterwards.
--Used to show the potion alert text/icon right after the cooldown of the potion is gone, and not directly as the buff fades
function FCOSS.setupPotionAlert(timerMS, showPotionAlert, disable)
    --Set the timer in milliseconds to a default of 45 seconds if no value was given -> 45 seconds = standard ESO potion cooldown
    if timerMS == nil or timerMS < 0 then timerMS = 45000 end
    disable = disable or false

--d("[FCOSS] setupPotionAlert - timerMS: "..tostring(timerMS) ..", showPotionAlert: " .. tostring(showPotionAlert) .. ", disable: " .. tostring(disable))

    EVENT_MANAGER:UnregisterForUpdate("FCOStarveStopPotionCheck")
    if disable then return false end
    if timerMS > 0 then
        EVENT_MANAGER:RegisterForUpdate("FCOStarveStopPotionCheck", timerMS, function() FCOSS.showPotionAlert(showPotionAlert) end)
    end
end

--Check for active potion buffs and alert if enabled in the settings
function FCOSS.checkPotionAlert(abilityId, isBuffGained)
    if abilityId == nil then return false end
    isBuffGained = isBuffGained or false
    local showPotionAlert = false

--d("[FCOSS] checkPotionAlert - abilityId: ".. tostring(abilityId) .. ", isBuffGained: " .. tostring(isBuffGained) ..", activePotionBuff: " .. tostring(FCOSS.preventerVars.activePotionBuff))
    if FCOSS.preventerVars.activePotionBuff then return false end
    local settings = FCOSS.settingsVars.settings
    
    --Is the potion alert enabled?
    if settings.potionAlert then
        --Only check in combat? Abort here if we are not inside combat
        if settings.potionAlertOnlyInCombat and not FCOSS.inCombat then return false end
        --Check the player buffs for the active potion's abilityId now
        --Is the given ability ID in the list of the potion ability IDs?
        local isPotionBuffActive = FCOSS.libPB:IsAbilityAPotionBuff(abilityId)
        if isPotionBuffActive then
            --Show the potion alert if the ability has currently faded, or hide it if it was gained
            showPotionAlert = not isBuffGained

            --If the potion buff was currently gained -> Save the cooldown left for this potion
            if isBuffGained then
                --Set a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
                FCOSS.preventerVars.activePotionBuff = true
                --Get the remaining cooldown time and the total CD duration in milliseconds
                local remainingMS, _ = FCOSS.getPotionCD(false)
--d(">gained new potion buff, remaining: " ..tostring(remainingMS))
                if not remainingMS or remainingMS <= 0 then
                    FCOSS.preventerVars.activePotionBuff = false
                    return false
                elseif remainingMS < 250 then
--d("<remainingMS < 250")
                    remainingMS = 250
                end
                --Setup the potion reminder with the countdown time of the potion left, so the reminder will not popup if the buff fades, but as the
                --potion's cooldown is gone. Subtract a quarter second so the reminder will be shown right in time!
                FCOSS.setupPotionAlert((remainingMS - 250), true)
                --Hide the potion alert now
                FCOSS.showPotionAlert(false)
                --If a potion was used from the menu the icon was hidden and will be shown again, if we close the menu.
                --So we need to prevent the "shown again"!
                FCOSS.alertIconPotion.hideNow = true
            else
                --Reset a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
                FCOSS.preventerVars.activePotionBuff = false
            end
        end
    else
        return false
    end
end

function FCOSS.checkIfPotionAlertNeedsToBeShown()
--d("[FCOSS]checkIfPotionAlertNeedsToBeShown")
    --Is the potion alert enabled?
    if FCOSS.settingsVars.settings.potionAlert then
        --Only check in combat?
        if FCOSS.settingsVars.settings.potionAlertOnlyInCombat and not FCOSS.inCombat then
--d("<not in combat - hide all. !ABORT!")
            --Unregister any registered update function (for the automatic showing of the potion alert after the potion's cooldown ended)
            FCOSS.setupPotionAlert(0, nil, true)
            FCOSS.preventerVars.hidePotionAlertIcon = true
            --Hide the potion alert now
            FCOSS.showPotionAlert(false)
            FCOSS.preventerVars.hidePotionAlertIcon = false
            --Reset a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
            FCOSS.preventerVars.activePotionBuff = false
            --Abort here if not in combat, but should be in combat to check for the potion alert
            return false
        end
        --Check if any potion buff is still active
        --or if a potion's cooldown is still active (without an active buff of that potion)
        --and if the potion alert should be setup to show later again
        local activePotionBuff = FCOSS.checkActiveBuffsForPotion()
        --Get the remaining cooldown time and the total CD duration in milliseconds
        local remainingMS, _ = FCOSS.getPotionCD(false)
        if activePotionBuff and remainingMS > 0 then
            --Set a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
            FCOSS.preventerVars.activePotionBuff = true
--d("Active potion effect: " .. tostring(activePotionBuff) .. ", CD remaining: " .. tostring(remainingMS) .. " ms")
            --Setup the potion reminder with the countdown time of the potion left, so the reminder will not popup if the buff fades, but as the
            --potion's cooldown is gone. Subtract a quarter second so the reminder will be shown right in time!
            if not remainingMS or remainingMS <= 0 then
--d("<remainingMS = 0. !ABORT!")
                --Reset a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
                FCOSS.preventerVars.activePotionBuff = false
                return false
            --Remaining cooldown below 250ms? Increase it to be 250ms
            elseif remainingMS < 250 then
--d("<remainingMS < 250")
                remainingMS = 250
            end
            FCOSS.setupPotionAlert((remainingMS - 250), true)
            --Hide the potion alert now
            FCOSS.showPotionAlert(false)
        else
--d("No active potion, show reminder now!")
            --No potion buff is active so show the potion alert now
            FCOSS.showPotionAlert(true)
            --Reset a preventer var for "active potion" as one potion can have several buffs and they expire at different times. But only one cooldown of the potion is relevant
            FCOSS.preventerVars.activePotionBuff = false
        end
    end
end

function FCOSS.AlertSoundRepeatPotion()
    if FCOSS.settingsVars.settings.alertSoundPotion > 1 then
        PlaySound(SOUNDS[FCOSS.sounds[FCOSS.settingsVars.settings.alertSoundPotion]])
        if FCOSS.settingsVars.settings.alertSoundRepeatPotion == 1 then return false end
        local delay = FCOSS.settingsVars.settings.alertSoundDelayPotion or 1000
        for run = 1, FCOSS.settingsVars.settings.alertSoundRepeatPotion-1, 1 do
            zo_callLater(function()
                PlaySound(SOUNDS[FCOSS.sounds[FCOSS.settingsVars.settings.alertSoundPotion]])
            end, delay)
            delay = ((run+1)*FCOSS.settingsVars.settings.alertSoundDelayPotion) or ((run+1)*1000)
        end
    end
end