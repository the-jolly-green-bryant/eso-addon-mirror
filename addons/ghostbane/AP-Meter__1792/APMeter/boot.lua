local addonName = 'APMeter'

APMeter = {
	name = addonName,
	version = '2.0.4',
	build = 204,
    db = {}
}

AP_METER_QUART_PI = -ZO_HALF_PI

local APM = APMeter
local LCM = LibChatMessage
local chat = LCM("APM", "APM")

local logger = ZO_Object:Subclass()
function logger:Info(...)end

if GetDisplayName() == '@Ghostbane' then
    logger = LibDebugLogger('APM')
    logger:SetEnabled(true)
end

-- buffList
----------------------
-- Torte food and applicable AP buffs for our checklist
----------------------
local buffList = {
    cake = {
        [147687] = {    -- Alliance Skill Gain 50% Boost
            itemLink = '|H0:item:171323:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h',
            boost = '50',
            category = 'cake'
        }, 
        [147733] = {    -- Alliance Skill Gain 100% Boost
            itemLink = '|H0:item:171329:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h',
            boost = '100',
            category = 'cake'
        },
        [147734] = {    -- Alliance Skill Gain 150% Boost
            itemLink = '|H0:item:171432:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h',
            boost = '150',
            category = 'cake'
        }
    },
    event = {
        [92232] = {     -- Pelinal's Ferocity
            itemLink = '|H0:item:121550:124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h',
            icon = '/esoui/art/icons/event_midyear_starterscroll.dds',
            description = [[Increase AP + XP gain by 100% for 2 hours. XP from player deaths.
            ]],
            boost = '100',
            category = 'event'
        }
    },
    delve = {
        [66282] = {    -- Blessing of War
            description = 'Increase AP gain by 20% for 1 hour. Only active in Cyrodiil.',
            icon = '/esoui/art/icons/ability_healer_030.dds',
            boost = '20',
            category = 'delve'
        }
    }
}

-- session
----------------------
-- Keep a collection of all ap gathered through non-transactional means. Categorised. 
----------------------
local session = {
    combat = 0,
    repairs = 0,
    defence = 0,
    capture = 0,
    quests = 0,
    resurrections = 0,
    total = 0,
    startTime = 0,
    deaths = 0,
    timeElapsed = 0,
    APStreak = 0
}

APM.session = session

local currentRank = GetUnitAvARank('player')
local currentZone = ''
local hasSessionBegan = false
local keeps = {}

for i = 1, 165 do
    local name = GetKeepName(i)
    if name ~= "" then keeps[name] = i end
end

-- ------------------------
-- Methods
-- ------------------------

-- FormatCurrencyString()
----------------------
-- Return fromatted string for alliance points currency display
----------------------
local function FormatCurrencyString(value)
    local currencyType = CURT_ALLIANCE_POINTS
    local currencyAmount = value
    local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
    
    return zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType))
end

-- ActiveBuffCount()
----------------------
-- Return a total of active buffs (int)
----------------------
local function ActiveBuffCount()

    local count = 0

    for category, v in pairs(buffList) do
        for id, buff in pairs(buffList[category]) do
            if buff.active then
                count = count + 1
            end
        end
    end
    
    return count
end

--ScreenReminder(buff)
----------------------
-- Takes APMeter buff object, visual center screen alert
----------------------
local function ScreenReminder(buff)
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.TELVAR_GAINED)
    local remaining = zo_max(zo_roundToNearest(buff.endTime - GetGameTimeMilliseconds() / 1000, 1), 0)
    local name = buff.itemLink
    if not name then name = '|cedc600Blessing of War' end
    local msg = string.format('|t64:64:%s|t %s expires in |cf49b42%s', buff.icon, name, ZO_FormatTime(remaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
    
    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
    params:SetText(msg)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

--  OnUpdateBuffs()
----------------------
----------------------
local function OnUpdateBuffs()

    logger:Info('OnUpdateBuffs()')
    logger:Info('ActiveBuffCount() = %d', ActiveBuffCount())

    for category, v in pairs(buffList) do
        for id, buff in pairs(buffList[category]) do
        
            if buff.active then
                
                local timeRemaining = zo_max(zo_roundToNearest(buff.endTime - GetGameTimeMilliseconds() / 1000, 1), 0)

                logger:Info('Check %s', category)
                logger:Info('Time remaining %d', timeRemaining)
                logger:Info('settings.cake_screen: %s', tostring(APM.db.settings.notifications.cake_screen))
                logger:Info('settings.cake_chat: %s', tostring(APM.db.settings.notifications.cake_chat))
                logger:Info('-----------------')
                
                if timeRemaining <= 310 then
                    local settings = APM.db.settings.notifications
                    logger:Info('%s is less than 310',category)
                    if category == 'cake' and settings.cake_screen then ScreenReminder(buff) end
                    if category == 'delve' and settings.delve_screen then ScreenReminder(buff) end
                    if category == 'event' and settings.scroll_screen then ScreenReminder(buff) end

                    local remaining = zo_max(zo_roundToNearest(buff.endTime - GetGameTimeMilliseconds() / 1000, 1), 0)

                    if category == 'cake' and settings.cake_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- '..buff.itemLink..' expires in '..ZO_FormatTime(remaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
                    end

                    if category == 'delve' and settings.delve_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- |cedc600Blessing of War|ce0d7d7 expires in '..ZO_FormatTime(remaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))               
                    end

                    if category == 'event' and settings.scroll_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- '..buff.itemLink..' expires in '..ZO_FormatTime(remaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
                    end
                end
            end
        end
    end

end

function APMeter.test()
    Zgoo.CommandHandler(buffList)
end

-- Set flag to manage if buff timer is running
local buffTimerRunning = false

-- EnableBuffTimer()
----------------------
local function EnableBuffTimer()

    logger:Info('EnableBuffTimer()')

    if ActiveBuffCount() > 0 and not buffTimerRunning then
        EVENT_MANAGER:RegisterForUpdate('APMeterBuffCheck', 180000, OnUpdateBuffs)
        OnUpdateBuffs()
        buffTimerRunning = true
        logger:Info('buffTimerRunning: %s', tostring(buffTimerRunning))
    end

end

-- DisableBuffTimer()
----------------------
local function DisableBuffTimer()
    logger:Info('DisableBuffTimer()')
    if ActiveBuffCount() == 0 and  buffTimerRunning then
        EVENT_MANAGER:UnregisterForUpdate('APMeterBuffCheck')
        buffTimerRunning = false
        logger:Info('buffTimerRunning: %s', tostring(buffTimerRunning))
    end
end

-- SetupAndCheckForBuffs()
----------------------
-- 1) Build up the buff manifest with correct locale information
-- 2) Setup filtered events for said buffs ( added + ended )
-- 3) Check existing active buffs and set them as active in the manifest
----------------------
local function SetupAndCheckForBuffs()
    local nextEventHandleNr = 0
    local function RegisterAbilityIdEvent(id, callback)
        local eventHandleName = 'APMeter_AbilityId_NS_' .. tostring(nextEventHandleNr) -- This is needed in order to generate a new unique eventNameSpace for each filterType added!
        nextEventHandleNr = nextEventHandleNr + 1
        EVENT_MANAGER:RegisterForEvent(eventHandleName, EVENT_EFFECT_CHANGED, callback)
        EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
        EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
        return eventHandleName
    end

    for category, v in pairs(buffList) do
        for id, buff in pairs(buffList[category]) do
            buff.id = id
            buff.name = GetAbilityName(id)
            buff.active = false

            if not buff.description then
                buff.description = GetAbilityDescription(id)
            end

            if buff.itemLink then
                buff.icon = GetItemLinkIcon(buff.itemLink)
            end
            
            RegisterAbilityIdEvent(id, function(eventCode, changeType, _, name, unitTag, beginTime, endTime, _, _, _, _, _, _, _, _, abilityId)
                buff.active = false

                logger:Info('CHANGE-TYPE: ', changeType)

                if changeType == EFFECT_RESULT_ITERATION_END or changeType == EFFECT_RESULT_FADED then
                    logger:Info('EFFECT_RESULT_ITERATION_END: ', (changeType == EFFECT_RESULT_ITERATION_END))
                    logger:Info('EFFECT_RESULT_FADED: ', (changeType == EFFECT_RESULT_FADED))

                    if buff.timeRemaining and changeType == EFFECT_RESULT_ITERATION_END then
                        buff.timeRemaining = nil
                        buff.duration = nil
                    end
                    DisableBuffTimer()
                    APM.Panel.UpdateBufflist(buff)

                    local settings = APM.db.settings.notifications

                    if buff.category == 'cake' and settings.cake_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- '..buff.itemLink..' has expired')
                    end
    
                    if buff.category == 'delve' and settings.delve_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- |cedc600Blessing of War|ce0d7d7 has expired')               
                    end
    
                    if buff.category == 'event' and settings.scroll_chat then
                        chat:SetTagColor('58c5ed'):Print('|ccf1717Warning! |ce0d7d7- '..buff.itemLink..' has expired')
                    end

                elseif changeType == EFFECT_RESULT_UPDATED or changeType == EFFECT_RESULT_GAINED then
                    logger:Info('EFFECT_RESULT_GAINED: ', (changeType == EFFECT_RESULT_GAINED))
                    buff.active = true
                    buff.endTime = endTime
                    buff.timeRemaining = zo_max(zo_roundToNearest(endTime - GetGameTimeMilliseconds() / 1000, 1), 0)
                    buff.duration = zo_max(zo_roundToNearest((endTime - beginTime) / 1000, 1), 0)
                    EnableBuffTimer()
                    APM.Panel.UpdateBufflist(buff)
                end

            end)
        end
    end

    local numBuffs = GetNumBuffs("player")

    if numBuffs > 0 then
        for i = 1, numBuffs do

            local _, beginTime, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)

            for category, v in pairs(buffList) do
                if buffList[category][abilityId] then
                    buffList[category][abilityId].active = true
                    buffList[category][abilityId].endTime = endTime
                    buffList[category][abilityId].timeRemaining = zo_max(zo_roundToNearest(endTime - GetGameTimeMilliseconds() / 1000, 1), 0)
                    buffList[category][abilityId].duration = (endTime - beginTime)
                    APM.Panel.UpdateBufflist(buffList[category][abilityId])
                    EnableBuffTimer()
                end
            end       
        end
    end
end

function APM.test()
    Zgoo.CommandHandler(buffList)
end


-- GetPlayerProgress()
----------------------
-- return (int)PercentageOfProgress, (int)AmountToNextRank
----------------------
local function GetPlayerProgress()

    local currentAlliancePoints = GetUnitAvARankPoints('player')

    local subRankStartsAt, nextSubRankAt = GetAvARankProgress(currentAlliancePoints)
    local rankTotalLeft = nextSubRankAt - currentAlliancePoints

    local rankTotal = (nextSubRankAt - subRankStartsAt)
    local percentage = zo_floor((100 / rankTotal) * (rankTotal - rankTotalLeft))

    return percentage, rankTotalLeft

end

-- ZoneUpdate()
----------------------
-- Inform Theme that we have swapped subZone's and pass the correct label string
----------------------
local function ZoneUpdate(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)

    if not IsInCampaign() then return end

    if subZoneName == nil or subZoneName == '' then
        -- Sometimes when transiting keeps, the EVENT_ZONE_CHANGED fires with no information.
        -- If the subZoneName comes back blank, we will try to get the location again in
        -- a second 
        zo_callLater(function() ZoneUpdate(0, 0, GetPlayerLocationName()) end, 1000)
        return
    else

        currentZone = subZoneName

        if currentZone == 'Bruma Anchor' then
            currentZone = 'Bruma'
        end

        local keepNames = {'Keep', 'Castle', 'Fort'}
        local resourceNames = {'Lumbermill', 'Mine', 'Farm', 'Temple'}
        local townNames = {'Vlastarus', 'Cropsford', 'Bruma Anchor', 'Bruma'}
        local locationString = ' '

        for i = 1, 3 do
            if string.find(subZoneName, keepNames[i]) then
                locationString = 'Keep  Range'
            end
        end

        for i = 1, 3 do
            if string.find(subZoneName, townNames[i]) then
                locationString = 'Town  Range'
            end
        end

        for i = 1, 4 do
            if string.find(subZoneName, resourceNames[i]) then
                locationString = resourceNames[i] .. ' Range'
            end
        end

        if string.find(subZoneName, 'Outpost') then
            locationString = 'Outpost  Range'
        end

        APM.Theme.Selected():SetTickRange(locationString)
    end
end

-- SendNotification()
----------------------
local function SendNotification(sourceType, difference, area)

    local db = APM.db
            
    APM.Panel.UpdateSessionBreakdown()

    if db.settings.apType[sourceType] then
        local displayNotifcation = true
        local when = "[" .. GetTimeString() .. "] "
        local icon = '|t16:16:/esoui/art/currency/alliancepoints.dds|t'
        local superStructure = ''

        if string.sub(sourceType, -1) == 's' then
            sourceType = sourceType:sub(1, -2)
        end

        if not db.settings.showTimestamp then
            when = ''
        end

        if area then
            superStructure = '  |c006d0c[' .. area .. ']'
        end

        displayNotifcation = difference >= tonumber(db.settings.minimalLimit)

        if displayNotifcation then
            chat:SetTagColor('58c5ed'):Print('|c31c441'..when..zo_strformat('<<C:1>>', sourceType..'^N')..': '..FormatCurrencyString(difference)..superStructure)
        end
    end
end

-- SetRankProgress()
----------------------
local function SetRankProgress(value)

    if not value then
        value = GetPlayerProgress()
    end

    local rank = GetUnitAvARank('player')

    if currentRank ~= rank then
        APM.Theme.Selected():RankChange()
        currentRank = rank
    end

    APM.Theme.Selected():SetProgress(value)

    if APM.db.goal.active then
        local goalValue = (100/APM.db.goal.target * APM.db.goal.total)
        APM.Theme.Selected():SetGoalProgress(goalValue)
        APM.Panel.UpdateGoal()
    end

end

-- SetAPValue()
----------------------
local function SetAPValue()
    APM.Theme.Selected():SetValue(session.total)
end

-- UpdateTickList()
----------------------
local function UpdateTickList(tickReward)
    if keeps[currentZone] then
        APM.Panel.UpdateTicklist(keeps[currentZone],tickReward)
    end
end

-- OnAPGain()
----------------------
local function OnAPGain(eventCode, alliancePoints, playSound, difference, reason, locationId)

    if reason ~= CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL and reason ~= CURRENCY_CHANGE_REASON_VENDOR then

        local db = APM.db

        if not hasSessionBegan and session.timeElapsed == 0 then
            hasSessionBegan = true
            session.startTime = GetGameTimeMilliseconds()
            session.timeElapsed = 1
        end

        if difference > 0 then
            session.total = difference + session.total
            session.APStreak = difference + session.APStreak

            if db.goal.active then
                db.goal.total = difference + db.goal.total

                if db.goal.target <= db.goal.total then
                    chat:SetTagColor('58c5ed'):Print('|c03a1fcAP Goal Complete! - '..FormatCurrencyString(db.goal.target))
                    APM.Panel.RemoveGoal()
                end

            end

            SetAPValue()
            SetRankProgress()
            APM.Panel.UpdateSession()

            if reason == CURRENCY_CHANGE_REASON_KILL then
                session.combat = difference + session.combat
                SendNotification('combat', difference)
                UpdateTickList()
                return
            elseif reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR then
                session.repairs = difference + session.repairs
                SendNotification('repairs', difference)
                UpdateTickList()
                return
            elseif reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD then
                session.capture = difference + session.capture
                SendNotification('capture', difference, GetKeepName(locationId))
                return
            elseif reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then
                session.defence = difference + session.defence
                SendNotification('defence', difference, GetKeepName(locationId))
                UpdateTickList(locationId, true)
                return
            elseif reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT then
                session.resurrections = difference + session.resurrections
                SendNotification('resurrections', difference)
                UpdateTickList()
                return
            elseif reason == CURRENCY_CHANGE_REASON_MEDAL then
                SendNotification('medal', difference)
                return
            elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND then
                SendNotification('match', difference)
                return
            elseif reason == CURRENCY_CHANGE_REASON_TRADE or reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
                session.quests = difference + session.quests
                SendNotification('quests', difference)
                return
            end

        end

    end

end

-- OnCombatKill()
----------------------
function OnCombatKill(eventCode, result, isError, abilityName, _, _, sourceName, sourceType, targetName)

    if (IsInCampaign() or IsActiveWorldBattleground()) then
        if (isError) then return end
        if result == ACTION_RESULT_KILLING_BLOW and sourceType == COMBAT_UNIT_TYPE_PLAYER and GetUnitName("player") == zo_strformat("<<1>>", sourceName) and abilityName ~= "" then
            if (sourceName == targetName) then return end
            
            if APM.db.settings.enableFrame then APM_KillingBlowScreenFrame.animation:PlayFromStart() end
        end
    end

end

-- OnBackgroundKill()
----------------------
function OnBackgroundKill(_, _, _, _, _, _, _, killType)
    if (killType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW) and APM.db.settings.enableFrame then
        APM_KillingBlowScreenFrame.animation:PlayFromStart()
    end
end

-- OnDeath()
----------------------
local function OnDeath()
    if (IsInCampaign() or IsActiveWorldBattleground()) and APM.db.settings.apstreak then
        if not IsActiveWorldBattleground() then
            chat:SetTagColor('58c5ed'):Print('|cababab AP Streak Ended: '..FormatCurrencyString(session.APStreak))
            session.APStreak = 0
        end
    end
end

-- OnPlayerActivated()
----------------------
-- Informal initialize function, from EVENT_PLAYER_ACTIVATED
----------------------
local function OnPlayerActivated(eventCode)

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

    APM.Theme.Initialize()
    APM.Panel.Initialize()

    zo_callLater(function()
        SetRankProgress()
    end, 700)
    
    SetAPValue()

    APMeterContainer:SetHandler('OnMoveStop', function(control)
        local location = APM.db.settings.locations[APM.Theme.Selected().name]
        location.x = control:GetLeft()
        location.y = control:GetTop()
    end)

    local fragment = ZO_HUDFadeSceneFragment:New(APMeterContainer, nil, 0)
    
    fragment:SetConditional(function()
        return IsInCampaign() or IsActiveWorldBattleground()
    end)

	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
    LOOT_SCENE:AddFragment(fragment)

    ZoneUpdate(0, 0, GetPlayerLocationName())

    SetupAndCheckForBuffs()

    APM_KillingBlowScreenFrameOverlay:SetEdgeColor(ZO_ColorDef:New(unpack(APM.db.settings.frameColor)):UnpackRGBA())
    APM_KillingBlowScreenFrame.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual('APM_KillingBlowScreenFrameAnimation', APM_KillingBlowScreenFrame)

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ZONE_CHANGED, ZoneUpdate)
end

-- APMeter.GetLocalAP()
----------------------
-- External hortcut for GetPlayerProgress()
----------------------
function APM.GetLocalAP()
    return GetPlayerProgress()
end

-- --------------------
-- Settings
-- --------------------
local db_defaults = {
    settings = {
        global = true,
        selectedTheme = 'Modern',
        previewTheme = 'Modern',
        locations = {},
        showTimestamp = false,
        apType = {
            combat = true,
            repairs = true,
            defence = true,
            capture = true,
            quests = true,
            medal = true,
            match = true,
            resurrections = true,
            apstreak = true,
        },
        minimalLimit = 10,
        notifications = {
            delve_screen = true,
            delve_chat = true,
            cake_screen = true,
            cake_chat = true,
            scroll_screen = true,
            scroll_chat = true
        },
        enableFrame = true,
        frameColor = {0.51764708757041, 1, 0.24705882370472, 1},
        themes = {
            Classic = {
                aph = false
            },
            Modern = {
                size = 'large'
            }
        }
    },
    goal = {
        active = false,
        target = 0,
        total = 0
    },
    panel = {
        location ={
            x = 0,
            y = 0
        }
    }
}
local defaultSetting = db_defaults.settings

local panelData = {
    type = 'panel',
    name = 'AP Meter',
    version = APMeter.version,
    author = 'ghostbane',
    website = 'http://www.esoui.com/downloads/info1792-APMeter.html'
}


-- --------------------
-- OnAddOnLoaded
-- --------------------
local function OnAddOnLoaded(eventCode, _addOnName)

	if _addOnName == addonName then

		APM.db = ZO_SavedVars:NewCharacterIdSettings('APMeterSettings', 2, GetWorldName(), db_defaults, nil)

        if APM.db.settings.global then
            APM.db = ZO_SavedVars:NewAccountWide('APMeterSettings', 2, nil, db_defaults)
            APM.db.settings.global = true
        end

		EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
		EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

        -- Build settings
        local LAM2 = LibAddonMenu2

        local settingsObject = APM.BuildSettingsObject(APM.db, defaultSetting)
        
        APM.LAMSettings = LAM2:RegisterAddonPanel('APMeterOptions', panelData)
        LAM2:RegisterOptionControls('APMeterOptions', settingsObject)

        APMeterPanelAppName:SetText('AP Meter v'..tostring(APM.version))
	end

end

-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ALLIANCE_POINT_UPDATE, OnAPGain)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_DEAD, OnDeath)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_BATTLEGROUND_KILL, OnBackgroundKill)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_COMBAT_EVENT, OnCombatKill)

-- --------------------
-- Keybind string
-- --------------------
ZO_CreateStringId("SI_BINDING_NAME_APM_TOGGLE_PANEL","Toggle AP Meter Panel")