if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
-- Different Functions
------------------------------------------------------------------------------------------------------------
function FCOSS.GetTextureId(texturePath)
    if texturePath == nil or texturePath == "" then return 0 end
    for textureId, texturePathString in pairs(FCOSS.iconTextures) do
        if	texturePathString == texturePath then
            return textureId
        end
    end
    return 0
end




------------------------------------------------------------------------------------------------------------
-- Chat output
------------------------------------------------------------------------------------------------------------
function FCOSS.outputActiveBuffFood(foundType, foundName)
    local settings = FCOSS.settingsVars.settings
--d("[FCOSS]outputActiveBuffFood-foundType: " .. tostring(foundType) .. ", foundName: " .. tostring(foundName) ..", onlyWithoutActiveFoodBuff: " ..tostring(settings.alertRepeatChatOutputOnlyWithoutFoodBuff) .. ", chatOutputConsumedNamed: " ..tostring(settings.chatOutputConsumedNamed))
    local doOutput = false
    if foundType ~= nil and foundName ~= nil and foundName ~= "" then
        if settings.chatOutputConsumedNamed or (settings.alertRepeatChatOutput and not settings.alertRepeatChatOutputOnlyWithoutFoodBuff) then
            doOutput = true
        end
    end
    if doOutput then
        d(FCOSS.locVars.preChatTextGreen .. foundType .. " |c0081F0" .. foundName .. "|r" .. FCOSS.localizationVars.fco_ss_loc["chat_output_is_active"])
    end
end


------------------------------------------------------------------------------------------------------------
-- Zone & Group
------------------------------------------------------------------------------------------------------------
function FCOSS.getCurrentZoneAndGroupStatus()
    local isInPublicDungeon = false
    local isInGroupDungeon = false
    local isInAnyDungeon = false
    local isInRaid = false
    local isInDelve = false
    local isInGroup = false
    local groupSize = 0
    local isInPVP = false
    local playerVar = "player"

    isInPVP = IsPlayerInAvAWorld()
    isInAnyDungeon = IsAnyGroupMemberInDungeon()  -- returned true if not in group and in solo dungeon/delve until patch API???? Now it returns false
    isInRaid = IsPlayerInRaid()
    isInGroup = IsUnitGrouped(playerVar)
    if not isInAnyDungeon then
        isInAnyDungeon = (IsUnitInDungeon(playerVar) or GetMapContentType() == MAP_CONTENT_DUNGEON) or false
    end

    --Check if user is in any dungeon
    --As there is no API to check for delves: We assume ungrouped + in dungeon = in delve
    if not isInGroup then
        isInDelve = isInAnyDungeon
    else
        groupSize = GetGroupSize() --SMALL_GROUP_SIZE_THRESHOLD (4) / RAID_GROUP_SIZE_THRESHOLD (12) / GROUP_SIZE_MAX (24)
        isInDelve = (isInAnyDungeon and not isInRaid and groupSize <= SMALL_GROUP_SIZE_THRESHOLD) or false
    end
    --Get POI info for group and public dungeons
    local zoneIndex, poiIndex = GetCurrentSubZonePOIIndices()
--d(string.format(">zoneIndex: %s, poiIndex: %s", tostring(zoneIndex), tostring(poiIndex)))
    local abort = false
    if zoneIndex == nil then
        abort = true
    end
    if poiIndex == nil then
        abort = true
    end
    if not abort then
        local _, _, _, iconPath = GetPOIMapInfo(zoneIndex, poiIndex)
        local iconPathLower = iconPath:lower()
--d(">iconPathLower: "..tostring(iconPathLower))
        if iconPathLower:find("poi_delve") then
            -- in a delve
            isInDelve = true
        end
        isInPublicDungeon = IsPOIPublicDungeon(zoneIndex, poiIndex)
        isInGroupDungeon = IsPOIGroupDungeon(zoneIndex, poiIndex)
        if isInPublicDungeon then
            isInDelve = false
            isInGroupDungeon = false
        elseif isInGroupDungeon then
            isInDelve = false
            isInPublicDungeon = false
        end
        --[[
            else
                --Workaround as long as some public dungeons are not determined correctly (e.g. in Reapers March)
                --Workaround disabled: Delves are not determined correctly this way (you are normally grouped in public dungeons?!)!
                isInPublicDungeon = (isInAnyDungeon and not isInGroup)
        ]]
    end
    --d("[FCOSS.getCurrentZoneAndGroupStatus] PvP: " .. tostring(isInPVP) .. ", Delve: " .. tostring(isInDelve) .. ", PubDun: " .. tostring(isInPublicDungeon) .. ", GroupDun: " .. tostring(isInGroupDungeon) .. ", inGroup: " .. tostring(isInGroup) .. ", groupSize: " .. groupSize)
    return isInPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize
end

function FCOSS.checkIfRepeatedCheck()
    --Check every region and every type of dungeon/no dungeon is activated?
    if FCOSS.settingsVars.settings.alertCheckEvent == 9 and FCOSS.settingsVars.settings.alertCheckDungeons == 6 then
        return true
    end

    local retValEvent 	= false
    local retValDungeon	= false
    local settings = FCOSS.settingsVars.settings

    --Check the current zone where the user is and the group status
    local isInPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize = FCOSS.getCurrentZoneAndGroupStatus()

--d(string.format("[FCOSS.checkIfRepeatedCheck]alertCheckEvent: %s, alertCheckDungeons: %s, isInPVP: %s, isInDelve: %s, isInPublicDungeon: %s, isInGroupDungeon: %s, isInRaid: %s, isInGroup: %s, groupSize: %s", tostring(settings.alertCheckEvent), tostring(settings.alertCheckDungeons), tostring(isInPVP), tostring(isInDelve), tostring(isInPublicDungeon), tostring(isInGroupDungeon), tostring(isInRaid), tostring(isInGroup), tostring(groupSize)))

    --Check for the events
    --[[
            [1] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pvp"],
            [2] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pvp_group"],
            [3] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pvp_raid"],
            [4] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pve"],
            [5] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pve_group"],
            [6] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_pve_raid"],
            [7] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_group"],
            [8] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_raid"],
            [9] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_everywhere"],
    ]]
    if settings.alertCheckEvent ~= 9 then
        --In AvA/PvP?
        if     settings.alertCheckEvent == 1 then
            if isInPVP then
                retValEvent = true
            end

            --In AvA/PvP + in group?
        elseif settings.alertCheckEvent == 2 then
            if isInPVP and isInGroup and groupSize <= SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end

            --In AvA/PvP + in raid group?
        elseif settings.alertCheckEvent == 3 then
            if isInPVP and isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end

            --NOT in AvA/PvP?
        elseif settings.alertCheckEvent == 4 then
            if not isInPVP then
                retValEvent = true
            end

            --NOT in AvA/PvP + in group?
        elseif settings.alertCheckEvent == 5 then
            if not isInPVP and isInGroup and groupSize <= SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end

            --NOT in AvA/PvP + in raid group?
        elseif settings.alertCheckEvent == 6 then
            if not isInPVP and isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end

            --In group?
        elseif settings.alertCheckEvent == 7 then
            if isInGroup and groupSize <= SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end

            --In raid group?
        elseif settings.alertCheckEvent == 8 then
            if isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD then
                retValEvent = true
            end
        end
    else
        retValEvent = true
    end

    --Check for the dungeons
    --[[
            [1] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_delve"],
            [2] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_public"],
            [3] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_group"],
            [4] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_raid"],
            [5] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_all"],
            [6] = FCOSS.localizationVars.fco_ss_loc["options_alert_check_event_dungeon_everywhere"]
    ]]
    if settings.alertCheckDungeons ~= 6 then
        --In delve
        if     settings.alertCheckDungeons == 1 then
            if isInDelve and not isInPublicDungeon then
                retValDungeon = true
            end

            --In public dungeon
        elseif settings.alertCheckDungeons == 2 then
            if isInPublicDungeon then
                retValDungeon = true
            end

            --In group dungeon
        elseif settings.alertCheckDungeons == 3 then
            if isInGroupDungeon then
                retValDungeon = true
            end

            --In raid group dungeon
        elseif settings.alertCheckDungeons == 4 then
            if isInRaid then
                retValDungeon = true
            end

            --In all dungeon types
        elseif settings.alertCheckDungeons == 5 then
            if isInDelve or isInPublicDungeon or isInGroupDungeon or isInRaid then
                retValDungeon = true
            end
        end

    else
        retValDungeon = true
    end

    --Return the return value: true if crepeated food buff check should be done!
    return (retValEvent and retValDungeon)
end


------------------------------------------------------------------------------------------------------------
-- Alert on screen (incl. blinking) / alert to chat
------------------------------------------------------------------------------------------------------------
function FCOSS.createAlertIcons()
    --Food buff icon
    local icon = WINDOW_MANAGER:CreateControl(FCOSS.addonVars.addonName .. "_AlertIcon", FCOStarveStopContainer, CT_TEXTURE)
    FCOSS.alertIcon = icon

    icon:SetHidden(true)
    icon:SetMouseEnabled(true)
    icon:SetMovable(true)
    icon:SetTexture(FCOSS.iconTextures[FCOSS.settingsVars.settings.iconAlertTexture])
    icon:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidth, FCOSS.settingsVars.settings.iconAlertHeight)
    icon:ClearAnchors()
    icon:SetParent(FCOStarveStopContainer)
    icon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FCOSS.settingsVars.settings.iconAlertX, FCOSS.settingsVars.settings.iconAlertY)
    icon:SetDrawLayer(1)
    icon.hideNow = false

    icon:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if not FCOStarveStop_SettingsMenu:IsHidden() then return false end
        if mouseButton == 2 and upInside then
            FCOSS.preventerVars.iconManuallyHidden = true
            FCOSS.preventerVars.iconShownBeforeMenuOpened = false
            FCOSS.alertIconIsBlinking = false
            self:SetHidden(true)
        end
    end)
    icon:SetHandler("OnMouseEnter", function()
        --Build the tooltip text
        local tooltipText = ""
        if FCOSS.alertTextFood ~= "" then
            tooltipText = FCOSS.alertTextFood
        elseif FCOSS.alertTextDrink ~= "" then
            tooltipText = FCOSS.alertTextDrink
        else
            tooltipText = FCOSS.alertTextGeneral
        end
        if tooltipText ~= nil and tooltipText ~= '' then
            ZO_Tooltips_ShowTextTooltip(icon, BOTTOM, tooltipText)
        end
    end)
    icon:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    icon:SetHandler("OnMoveStop", function()
        FCOSS.settingsVars.settings.iconAlertX = icon:GetLeft()
        FCOSS.settingsVars.settings.iconAlertY = icon:GetTop()
    end)

    --Potion icon
    local iconPotion = WINDOW_MANAGER:CreateControl(FCOSS.addonVars.addonName .. "_AlertIconPotion", FCOStarveStopContainerPotion, CT_TEXTURE)
    FCOSS.alertIconPotion = iconPotion

    iconPotion:SetHidden(true)
    iconPotion:SetMouseEnabled(true)
    iconPotion:SetMovable(true)
    iconPotion:SetTexture(FCOSS.iconTextures[FCOSS.settingsVars.settings.iconAlertTexturePotion])
    iconPotion:SetDimensions(FCOSS.settingsVars.settings.iconAlertWidthPotion, FCOSS.settingsVars.settings.iconAlertHeightPotion)
    iconPotion:ClearAnchors()
    iconPotion:SetParent(FCOStarveStopContainerPotion)
    iconPotion:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FCOSS.settingsVars.settings.iconAlertXPotion, FCOSS.settingsVars.settings.iconAlertYPotion)
    iconPotion:SetDrawLayer(1)
    iconPotion.hideNow = false

    iconPotion:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if not FCOStarveStop_SettingsMenu:IsHidden() then return false end
        if mouseButton == 2 and upInside then
            FCOSS.preventerVars.iconManuallyHiddenPotion = true
            FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion = false
            self:SetHidden(true)
        end
    end)
    iconPotion:SetHandler("OnMouseEnter", function()
        --Build the tooltip text
        local tooltipText = FCOSS.alertTextGeneralPotion
        if tooltipText ~= nil and tooltipText ~= '' then
            ZO_Tooltips_ShowTextTooltip(icon, BOTTOM, tooltipText)
        end
    end)
    iconPotion:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    iconPotion:SetHandler("OnMoveStop", function()
        FCOSS.settingsVars.settings.iconAlertXPotion = iconPotion:GetLeft()
        FCOSS.settingsVars.settings.iconAlertYPotion = iconPotion:GetTop()
    end)
end

function FCOSS.showWarningBeforeExpiration(buffName, startTime, endTime, iconFile, foodType, chatOutput)
    if not startTime or not endTime then return false end
    if FCOSS.settingsVars.settings.showWarningBeforeExpiration <= 0 then
        --Disable the warning
        FCOSS.setupWarningBeforeExpirationRepeat(true, nil, nil, nil, nil, nil, nil)
        return false
    end
    --Get the time until the food buff is activated and will expire
    local currentTimeS = tonumber((GetGameTimeMilliseconds() / 1000))
    if not currentTimeS or currentTimeS <= 0 then return false end
    local timeLeft = endTime - currentTimeS
    local timeLeftMinutes = math.floor(timeLeft / 60)
    local warningTextCSA = ""
--d("[FCOSS.showWarningBeforeExpiration] buffName: " .. buffName .. ", startTime: " .. startTime .. ", endTime: " .. endTime .. ", time left: " .. timeLeftMinutes .. " minutes, foodType: " .. foodType)

    --Minutes left are smaller or equal then the warning value?
    if timeLeftMinutes > 0 and timeLeftMinutes <= FCOSS.settingsVars.settings.showWarningBeforeExpiration then
        --With update Thieves guild this text was too long
        --local warningText = zo_strformat("|cDD2222" .. foodType .. "'|cFFFFFF" .. buffName .. "|cDD2222' " .. FCOSS.localizationVars.fco_ss_loc["warning_expire_text"] .. "|r", "|cFFFFFF" .. timeLeftMinutes .. "|cDD2222")
        local warningText = zo_strformat("|cDD2222" .. foodType .. "|cDD2222 " .. FCOSS.localizationVars.fco_ss_loc["warning_expire_text"] .. "|r", "|cFFFFFF" .. timeLeftMinutes .. "|cDD2222")
        warningTextCSA = zo_iconTextFormat(iconFile, 64, 64, warningText)
        --CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_BROADCAST, CSA_EVENT_SMALL_TEXT, nil, warningTextCSA)
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        params:SetText(warningTextCSA)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        if chatOutput then
            local warningTextChat = zo_iconTextFormat(iconFile, 24, 24, warningText)
            d(warningTextChat)
        end
    end
end

function FCOSS.setupWarningBeforeExpirationRepeat(disable, foundName, startTime, endTime, iconFile, foundType, doChatOutput, playerActivatedCalled)
--d("FCOSS.setupWarningBeforeExpirationRepeat("..tostring(disable)..", "..tostring(foundName)..", "..tostring(startTime)..", "..tostring(endTime)..", "..tostring(iconFile)..", "..tostring(foundType)..", "..tostring(doChatOutput) .. ", playerActivatedCalled: " .. tostring(playerActivatedCalled))
    doChatOutput = doChatOutput or false
    disable = disable or false
    playerActivatedCalled = playerActivatedCalled or false
    startTime = tonumber(startTime)
    endTime = tonumber(endTime)
    EVENT_MANAGER:UnregisterForUpdate(FCOSS.updateEventName)
    if disable then return false end
    if FCOSS.settingsVars.settings.showWarningBeforeExpiration > 0 then
        --If lockpicking was done, or the player activated event was calling this function after reloadui/login:
        --Show the reminder message now once in advance, before the regularly repeat check is done
        if FCOSS.preventerVars.lockpickWasDone or playerActivatedCalled then
            FCOSS.showWarningBeforeExpiration(foundName, startTime, endTime, iconFile, foundType, doChatOutput)
        end
        --Check every n seconds if the buff food expiration warning should be shown
        EVENT_MANAGER:RegisterForUpdate(FCOSS.updateEventName, FCOSS.settingsVars.settings.showWarningBeforeExpirationRepeat*1000, function()
            FCOSS.showWarningBeforeExpiration(foundName, startTime, endTime, iconFile, foundType, doChatOutput)
        end)
    end
end

function FCOSS.checkAndHideAlertIconInHouse()
    --Are we in a house and the setting to hide alerts in a house is enabled?
    local settings = FCOSS.settingsVars.settings
    if settings.alertNotInHouse and FCOSS.checkIfInHouse() then
        --If the food buff alert icon is currently shown: Hide it
        if settings.iconAlert then
            if not FCOSS.alertIcon:IsHidden() or FCOSS.alertIconIsBlinking then
                FCOSS.preventerVars.iconManuallyHidden = false
                FCOStarveStopContainer:SetHidden(true)
                FCOSS.alertIcon:SetHidden(true)
                FCOSS.alertIconIsBlinking = false
            end
        end
        return true
    end
    return false
end

function FCOSS.alertNow(buffType, chatOutput, test)
    test = test or false
    chatOutput = chatOutput or false
    local settings = FCOSS.settingsVars.settings

--d("[FCOSS.alertNow] buffType: ".. buffType .. ", chatOutput: " .. tostring(chatOutput) .. ", test: " .. tostring(test) .. ", chatoutputOnlyWithoutFoodBuff: " ..tostring(settings.alertRepeatChatOutputOnlyWithoutFoodBuff))

    --If we are in a lockpicking progress do not show the alert message now!
    --Show it after the lockpicking ends instead
    if FCOSS.preventerVars.lockpickInProgress then
        return
    end

    --Are we in a house and the setting to hide alerts in a house is enabled?
    if FCOSS.checkAndHideAlertIconInHouse() then
--d("[FCOSS] In a house, no alert will be shown!")
        return
    end

    local textAlert = ""
    if buffType ~= "n/a" then
        textAlert = settings["textAlert" .. buffType]
    else
        textAlert = settings.textAlertGeneral
    end
    if textAlert ~= "" then
        if test then
            textAlert = "---TEST--- " .. textAlert
        end
        local textAlertWithPreText =  FCOSS.locVars.preChatTextRed .. textAlert
        if settings.textAlert then
            --CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_BROADCAST, CSA_EVENT_SMALL_TEXT, nil, textAlert)
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
            params:SetText(textAlert)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)

            FCOSS.AlertSoundRepeat()
        end
        if not test then
            if buffType == "Drink" then
                FCOSS.alertTextDrink = textAlertWithPreText
                FCOSS.alertTextFood = ""
            elseif buffType == "Food" then
                FCOSS.alertTextFood = textAlertWithPreText
                FCOSS.alertTextDrink = ""
                FCOSS.alertTextGeneral = ""
            elseif buffType == "n/a" then
                FCOSS.alertTextFood = ""
                FCOSS.alertTextDrink = ""
                FCOSS.alertTextGeneral = textAlertWithPreText
            end
        end
        --Show text message in chat?
        local showChatText = false
        if chatOutput then
            d(textAlertWithPreText)
        end
    end
    if settings.iconAlert then
        --Blink the icon
        FCOSS.ToggleAlertIcon(nil, true, test)
    end
    if not test then
        --Change the quickslots?
        FCOSS.changeQuickslots(FCOSS.inCombat, true)
    end
end

function FCOSS.setupAlertRepeat(seconds, doChatOutput, disable)
    doChatOutput = doChatOutput or false
    disable = disable or false
    EVENT_MANAGER:UnregisterForUpdate("FCOStarveStopBuffFoodCheck")
    if disable then return false end
    if seconds > 0 then
        EVENT_MANAGER:RegisterForUpdate("FCOStarveStopBuffFoodCheck", seconds*1000, function() FCOSS.checkActiveBuffFood(doChatOutput, false, false) end)
    end
end


-- =====================================================================================================================
--  House functions
-- =====================================================================================================================
--Check if the player is in a house
function FCOSS.checkIfInHouse()
    local inHouse = (GetCurrentZoneHouseId() ~= 0) or false
    if not inHouse then
        local x,y,z,rotRad = GetPlayerWorldPositionInHouse()
        if x == 0 and y == 0 and z == 0 and rotRad == 0 then
            return false -- not in a house
        end
    end
    return true -- in a house
end