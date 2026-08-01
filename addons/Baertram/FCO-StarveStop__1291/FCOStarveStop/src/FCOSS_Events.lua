if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

local EM = EVENT_MANAGER

local addonVars = FCOSS.addonVars
local addonName = addonVars.addonName

--local quickslotsNew = FCOSS.quickslotsNew
local quickSlotsActionButtonIndex = FCOSS.quickSlotsActionButtonIndex

------------------------------------------------------------------------------------------------------------
-- Event callback functions
------------------------------------------------------------------------------------------------------------

function FCOSS.OnEventPlayer_Activated(...)
    --Build the addon menu once
    if not FCOSS.preventerVars.addonMenuBuild then
        FCOSS.buildAddonMenu()
    end

    local settings = FCOSS.settingsVars.settings
    --If food buff alert should be done on zoning/reloadui/entering a dungeon
    if settings.alertOnLogin then
        FCOSS.checkActiveBuffFood(settings.alertRepeatChatOutput, false, false, true)
    else
        FCOSS.checkActiveBuffFood(false, true, false, true)
    end
--d("[FCOSS]Event_Player_Activated - AlertOnLogin: " .. tostring(settings.alertOnLogin) .. ", buffFoodNotActive: " ..tostring(FCOSS.buffFoodNotActive))

    FCOSS.setupAlertRepeat(settings.alertRepeatSeconds, settings.alertRepeatChatOutput, false)
    --Are we in a house and the setting to hide alerts in a house is enabled?
    FCOSS.checkAndHideAlertIconInHouse()

    --Check if other addons are active
    FCOSS.checkIfOtherAddonsAreActive()

    --Check if potion alert needs to be shown
    FCOSS.checkIfPotionAlertNeedsToBeShown()
    --Are we in a house and the setting to hide alerts in a house is enabled?
    FCOSS.checkAndHidePotionAlertIconInHouse()
end

--EVENT_EFFECT_CHANGED (integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType, string unitName, integer unitId, integer abilityId, integer sourceUnitType)
function FCOSS.OnEventEffectChanged(changeType, _, effectName, unitTag, beginTime, endTime, _, iconName, _, _, _, _, _, _, abilityId, _)
--d("[FCOStarveStop] - EVENT_EFFECT_CHANGED for unitTag: " .. tostring(unitTag) ..", abilityId: " .. tostring(abilityId) .. ", abilityName: " .. GetAbilityName(abilityId))
    if unitTag == "player"  then

        --Buff food faded out?
        if changeType == EFFECT_RESULT_FADED then
            local prevVars = FCOSS.preventerVars
            --d(">EFFECT_RESULT_FADED")
            --If ultimate skill was executed: Check if this is the ultimate skill now (should be last in new gained effects) and abort all
            --effect gained messages until this skill effect was gained -> To prevent a chat output for the "new food buff"
            if prevVars.ultimateAbility["NoChatOutput"] then
                if     abilityId  == prevVars.ultimateAbility["AbilityId"] then
                    prevVars.ultimateAbility["NoChatOutput"] = false
                end
                return false
            end

            --Check for faded & renewed food buff
            prevVars.buffFoodFaded = false
            local buffType = "none"
         --OLD comparison via effectName of the buff
         --[[
            local lowerEffectName = zo_strlower(effectName)
            --Remove trailing ^f endings etc...
            lowerEffectName = string.gsub(lowerEffectName, "%^.*", "")
            if lowerEffectName and lowerEffectName ~= "" then
                --d("[FCOSS.OnEventEffectChanged - FADED] effectName: " .. lowerEffectName)
                if FCOSS.buffNames.food[lowerEffectName] then
                    --d("food")
                    buffType = "Food"
                elseif FCOSS.buffNames.drink[lowerEffectName] then
                    --d("drink")
                    buffType = "Drink"
                end
                if buffType == "none" then return false end
            ]]
                local libFDB = FCOSS.libFDB
                local isDrinkBuff = libFDB:IsAbilityADrinkBuff(abilityId)
                if isDrinkBuff == nil then return false end
                if isDrinkBuff == true then
                    buffType = "Drink"
                elseif isDrinkBuff == false then
                    buffType = "Food"
                end
--d(">FADED: " .. tostring(abilityId))
                --d("got here FADED")
                --Delay the alert as new buff food could be taken and the effect_result_faded event gets fired before
                prevVars.buffFoodFaded = true
                prevVars.buffFoodRenewed = false
                FCOSS.checkBuffFoodFadedDelayed(buffType)
                --Cancel weapon switch preventer variable as the food buff faded and needs to be checked for renewal!
                prevVars.weaponSwitched = false
            --end

--===================================================================================================================================
        --Buff food was eaten/drunken?
        elseif changeType == EFFECT_RESULT_GAINED then
            local prevVars = FCOSS.preventerVars
--d(">EFFECT_RESULT_GAINED, effectName: " .. tostring(effectName))
            --Check for gained potion buff
            FCOSS.checkPotionAlert(abilityId, true)
            --d(">>1")
            --Check for gained food buff
            --Do not show effect info if weapon pair was switched
            --			if prevVars.weaponSwitched then
            --d(">>2 weaponSwitched ABORT")
            --                prevVars.weaponSwitched = false
            --                return false
            --            end
            --If ultimate skill was executed: Check if this is the ultimate skill now (should be last in new gained effects) and abort all
            --effect gained messages until this skill effect was gained -> To prevent a chat output for the "new food buff"
            if prevVars.ultimateAbility["NoChatOutput"] then
                --d(">>3 ulti abort")
                if     abilityId  == prevVars.ultimateAbility["AbilityId"] then
                    prevVars.ultimateAbility["NoChatOutput"] = false
                end
                return false
            end
            local buffType = "none"
            --OLD method by comparison of buffname
            --[[
            local lowerEffectName = zo_strlower(effectName)
            --Remove trailing ^f endings etc...
            lowerEffectName = string.gsub(lowerEffectName, "%^.*", "")
            local effectNameStripped = string.gsub(effectName, "%^.*", "")
            --d(">>lowerEffectName: " .. tostring(lowerEffectName) .. ", effectNameStripped: " .. tostring(effectNameStripped))
            if lowerEffectName and lowerEffectName ~= "" then
                --d("[FCOSS.OnEventEffectChanged - GAINED] effectName: " .. lowerEffectName)
                local foundType
                if FCOSS.buffNames.food[lowerEffectName] then
                    --d("food")
                    buffType = "Food"
                    foundType = FCOSS.localizationVars.fco_ss_loc["found_type_food"]
                elseif FCOSS.buffNames.drink[lowerEffectName] then
                    --d("drink")
                    buffType = "Drink"
                    foundType = FCOSS.localizationVars.fco_ss_loc["found_type_drink"]
                end
                if buffType == "none" then return false end
            ]]
                local libFDB = FCOSS.libFDB
                local isDrinkBuff = libFDB:IsAbilityADrinkBuff(abilityId)
                if isDrinkBuff == nil then return false end
                local foundType = ""
                if isDrinkBuff == true then
                    buffType = "Drink"
                    foundType = FCOSS.localizationVars.fco_ss_loc["found_type_drink"]
                elseif isDrinkBuff == false then
                    buffType = "Food"
                    foundType = FCOSS.localizationVars.fco_ss_loc["found_type_food"]
                end
                local lowerEffectName = zo_strlower(effectName)
                --Remove trailing ^f endings etc...
                lowerEffectName = string.gsub(lowerEffectName, "%^.*", "")
                local effectNameStripped = string.gsub(effectName, "%^.*", "")

--d(">GAINED: " .. tostring(abilityId) .. ", name: " .. tostring(effectNameStripped) .. ", isDrinkBuff: " ..tostring(isDrinkBuff))

                --d("got here GAINED")
                --Setup the warning if food buff will expire in n minutes and you've setup a warning to show before expiration
                local settings = FCOSS.settingsVars.settings
                FCOSS.setupWarningBeforeExpirationRepeat(settings.showWarningBeforeExpiration <= 0, effectNameStripped, beginTime, endTime, iconName, foundType, settings.alertRepeatChatOutput)
                --Buff food is active (again)
--d("[FCOSS.OnEventEffectChanged]buffFoodNotActive - false")
                FCOSS.buffFoodNotActive = false
                --Stop the buff food check timer as buff food is active
                FCOSS.setupAlertRepeat(0, false, true)
                --Was the active buff food "overwritten" with new one?
                if prevVars.buffFoodFaded then
                    --d("Buff food was overwritten")
                    prevVars.buffFoodRenewed = true
                end
                --Hide the alert icon now if a buff food was eaten/drunken
                prevVars.alreadyBuffFoodChecked = true
                FCOSS.ToggleAlertIcon(false, false, false)
                prevVars.alreadyBuffFoodChecked = false
                FCOSS.outputActiveBuffFood(foundType, effectNameStripped)
                --If buff food was used from the menu the icon was hidden and will be shown again, if we close the menu.
                --So we need to prevent the "shown again"!
                FCOSS.alertIcon.hideNow = true
                --After renewing the food buff: Change back to another quickslot?
                if prevVars.changeBackToQuickslotAfterFoodBuffUsage then
                    FCOSS.changeQuickslots(FCOSS.inCombat, false)
                end
            --end
        end
    end
end

function FCOSS.OnEventActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
    --d("[FCOStarveStop] OnEventActiveWeaponPairChangedd - activeWeaponPair: " ..tostring(activeWeaponPair) .. ", locked: " .. tostring(locked))
    --Suppress the active buff food check in EVENT_EFFECT_CHANGED as all player buffs get rescanned on weapon change -> when locked 1st bar!
    if locked then
        FCOSS.preventerVars.weaponSwitched = true
    end
end

function FCOSS.OnEventPlayerCombatState(event, insideCombat)
    --d("[FCOSS] OnEventPlayerCombatState - insideCombat: " ..tostring(insideCombat))
    --Save the inCombat state
    FCOSS.inCombat = insideCombat
    --Check if quickslots should be changed
    FCOSS.changeQuickslots(insideCombat, false)
    --Check if potion alert needs to be shown
    FCOSS.checkIfPotionAlertNeedsToBeShown()
end

function FCOSS.OnEventActionSlotUsed(eventCode, slotNum)
    --Get Ultimate skill ability ID ( e.g. Sorcerer's overload IDs which shouldn't post the current player's buff to chat again!)
    local prevVars = FCOSS.preventerVars
    prevVars.ultimateAbility["NoChatOutput"] = false
    prevVars.ultimateAbility["AbilityId"] = nil
    --Is the slot number the last one = Ultimate skill?
    if slotNum == quickSlotsActionButtonIndex then   --ACTION_BAR_UTILITY_BAR_SIZE then
        --get the ability ID
        local abiltyId = GetSlotBoundId(slotNum, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        --Check if ability ID is on the blacklist
        local excludedUltimates = FCOSS.buffAbilityIds.ultimatesExcluded
        local isNotWantedUltimate = excludedUltimates[abiltyId] or false
        --Show ability ID and name, if debug mode is activated
        if FCOSS.debug then
            local abilityName = GetAbilityName(abiltyId)
            d("Ability name: " .. abilityName .. ", ID: " .. abiltyId .. ", onBlacklist: " .. tostring(isNotWantedUltimate))
        end
        --Set the preventer avriables for the event EFFECT_GAINED
        prevVars.ultimateAbility["NoChatOutput"] = isNotWantedUltimate
        prevVars.ultimateAbility["AbilityId"] = abiltyId
    end
end

--Lockpicking ends
function FCOSS.OnEventLockpickEnded(eventName)
    FCOSS.preventerVars.lockpickInProgress = false
    local settings = FCOSS.settingsVars.settings
    --Lockpicking ends or was aborted: Check if an reminder/alert message needs to be shown and show it then
    FCOSS.checkActiveBuffFood(settings.alertRepeatChatOutput, false, false)

    --Enable the food buff check timer again
    FCOSS.setupAlertRepeat(settings.alertRepeatSeconds, settings.alertRepeatChatOutput, false)

    FCOSS.preventerVars.lockpickWasDone = false

    --UnRegister for the lockpicking end events again
    EM:UnregisterForEvent(eventName)
end

--Lockpicking begins
function FCOSS.OnEventBeginLockpick(...)
    FCOSS.preventerVars.lockpickInProgress = true
    FCOSS.preventerVars.lockpickWasDone = true

    --Stop the buff food check timer now. Will be enabled after lockpicking ends again
    --and will directly show an alert message then if necessary
    FCOSS.setupAlertRepeat(0, false, true)
    --Disable the warning before expiration check now
    --Will be re-enabled automatically as Lockpicking ends within function FCOSS.checkActiveBuffFood()->FCOSS.checkForExistingBuffFood()
    FCOSS.setupWarningBeforeExpirationRepeat(true, nil, nil, nil, nil, nil, nil)

    --Register for the lockpicking end events
    EM:RegisterForEvent(addonName, EVENT_LOCKPICK_FAILED, FCOSS.OnEventLockpickEnded)
    EM:RegisterForEvent(addonName, EVENT_LOCKPICK_SUCCESS, FCOSS.OnEventLockpickEnded)
end


------------------------------------------------------------------------------------------------------------
-- Event loading
------------------------------------------------------------------------------------------------------------
function FCOSS.loadEvents()
    --Register for the effect changed event for food and drink buffs!
    local libFDB = FCOSS.libFDB
    --lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
    local wasEffectChangedEventLoaded = libFDB:RegisterAbilityIdsFilterOnEventEffectChanged(addonName .. "_FoodDrink", FCOSS.OnEventEffectChanged, REGISTER_FILTER_UNIT_TAG, "player")
    if not wasEffectChangedEventLoaded then d("[FCOStarveStop] Addon EVENT_EFFECT_CHANGED for food/drink not loaded. Addon will not work properly!") return end
    --Register for the effect changed event for potion buff!
    local libPB = FCOSS.libPB
    --lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
    local wasPotionEffectChangedEventLoaded = libPB:RegisterAbilityIdsFilterOnEventEffectChanged(addonName .. "_Potion", FCOSS.OnEventEffectChanged, REGISTER_FILTER_UNIT_TAG, "player")
    if not wasPotionEffectChangedEventLoaded then d("[FCOStarveStop] Addon EVENT_EFFECT_CHANGED for potions not loaded. Addon will not work properly!") return end
    --EM:RegisterForEvent(addonName .. "_EventEffectChangedPotion", EVENT_EFFECT_CHANGED, FCOSS.OnEventEffectChanged)
    --EM:AddFilterForEvent(addonName .. "_EventEffectChangedPotion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    --Register for the zone change/player ready event
    EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED,             FCOSS.OnEventPlayer_Activated)
    --Register callback function if the weapon bars change
    EM:RegisterForEvent(addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,   FCOSS.OnEventActiveWeaponPairChanged)
    --Register callback function if you get into combat
    EM:RegisterForEvent(addonName, EVENT_PLAYER_COMBAT_STATE,          FCOSS.OnEventPlayerCombatState)
    --Register callback function if you change the action slots
    EM:RegisterForEvent(addonName, EVENT_ACTION_SLOT_ABILITY_USED,     FCOSS.OnEventActionSlotUsed)
    --Register the events for lockpicking
    EM:RegisterForEvent(addonName, EVENT_BEGIN_LOCKPICK,               FCOSS.OnEventBeginLockpick)
end