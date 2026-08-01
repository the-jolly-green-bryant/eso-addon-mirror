if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonName = FCOGuildLottery.addonVars.addonName
local addonNamePre = "["..addonName.."]"

local tos = tostring

--LibHistoire
local lh = LibHistoire
local checkForLibHistoireReady = FCOGuildLottery.CheckForLibHistoireReady


--LibDateTime
--local ldt = FCOGuildLottery.LDT

--Debug messages
local df    = FCOGuildLottery.df
local dfa   = FCOGuildLottery.dfa
local dfe   = FCOGuildLottery.dfe
local dfv   = FCOGuildLottery.dfv
local dfw   = FCOGuildLottery.dfw


local fcoglUIwindow
local fcoglUIwindowFrame

--Last used variables
local daysBeforeLastUsedGuildSalesLottery
local daysBeforeLastUsedGuildMemberJoinedDateList


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--FUNCTIONS
--Helper functions
local function showReloadUIMessage(messageType)
    if messageType == "daysbefore" then
        dfw(GetString(FCOGL_RELOADUI_WARNING_WITH_TEXT), GetString(FCOGL_RELOADUI_DAYSBEFORE))
    end
end


local function diffInDays(startTimestamp, endTimestamp)
    endTimestamp = endTimestamp or GetTimeStamp()
    local daysDiff = os.difftime(endTimestamp, startTimestamp) / (60 * 60 * 24)
    return math.floor(daysDiff)
end

local function minusNDays(endTimestamp, daysBefore, defaultDaysBefore)
    endTimestamp = endTimestamp or GetTimeStamp()
    daysBefore = daysBefore or defaultDaysBefore

    local endTimeStampTable = os.date("*t", endTimestamp)
    endTimeStampTable.hour = 0
    endTimeStampTable.min = 0
    endTimeStampTable.sec = 0
    local endDayMidnight = os.time(endTimeStampTable)

    local timeStart = endDayMidnight - (daysBefore * (24 * 60 * 60)) --86400 seconds a day * <daysToGetBefore> days

    --LibHistoire API 2.0: SetBeforeEventTime has been changed to exclude the specified time. Keep that in mind when updating code that uses this function directly.
    -->So we need to at least calculate +1 second on the endDate timestamp so we get all events "before" that endDate
    local timeEnd = endTimestamp + 1 --add 1 second because of new LibHistoire API 2.0

    local settings = FCOGuildLottery.settingsVars.settings
    if settings.cutOffGuildSalesHistoryCurrentDateMidnight == true then
        timeEnd = endDayMidnight
    end
    return timeStart, timeEnd
end
FCOGuildLottery.minusNDays = minusNDays

local function getDateMinusXDays(daysToGetBefore, defaultDaysBefore)
    --[[
    -MasterMerchant_Guild.lua -> Get guild trader change time (Start of the day)
    -- Calc Day Cutoff in Local Time
      local dayCutoff = GetTimeStamp() - GetSecondsSinceMidnight()
      (...)
      o.eightStart    = dayCutoff - 7 * 86400 -- last 7 days

    o.eightStart is the cutoff for sales to that filter, i.e. older sales are rejected. So it's start of current day minus 7 days, which matches my experience. It doesn't reset on Tuesday 15h00.
    ]]
    daysToGetBefore = daysToGetBefore or defaultDaysBefore
    if daysToGetBefore <= 0 then daysToGetBefore = 1 end
    local currentDayCurrentTime = GetTimeStamp()

    local timeStampStart, timeStampEnd = minusNDays(currentDayCurrentTime, daysToGetBefore, defaultDaysBefore)

--[[
    local currentDayMidnight = currentDayCurrentTime - GetSecondsSinceMidnight()
    local timeStart = currentDayMidnight - (daysToGetBefore * (24 * 60 * 60)) --86400 seconds a day * <daysToGetBefore> days
    local timeEnd = currentDayCurrentTime

    local settings = FCOGuildLottery.settingsVars.settings
    if settings.cutOffGuildSalesHistoryCurrentDateMidnight == true then
        timeEnd = currentDayMidnight
    end
--d(">getDateMinusXDays - startDate: " .. tos(timeStart) .. ", endDate: " ..tos(timeEnd))

    return timeStart, timeEnd
    ]]
    return timeStampStart, timeStampEnd
end


local function getSettingsForCurrentlyUsedDiceRollType(diceRollTypeOverride)
    if diceRollTypeOverride ~= nil then
        return FCOGuildLottery.settingsVars.settings.showUIForDiceRollTypes[diceRollTypeOverride]
    else
        return FCOGuildLottery.settingsVars.settings.showUIForDiceRollTypes[FCOGuildLottery.currentlyUsedDiceRollType]
    end
end

--Guild functions
local function resetCurrentGuildSalesLotteryData(startingNewLottery, guildIndex, daysBefore)
    startingNewLottery = startingNewLottery or false
    if startingNewLottery == false and FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier == nil then
        return
    end
    df( "ResetCurrentGuildSalesLotteryData - startingNewLottery: " ..tos(startingNewLottery))
    FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp     = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryRolls         = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryLastRolledChatOutput = nil

    local lastUsedGuildSalesLotteryDaysBefore = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
    FCOGuildLottery.lastUsedGuildSalesLotteryDaysBefore = lastUsedGuildSalesLotteryDaysBefore
    FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime  = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime       = nil

    FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId       = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex    = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildName     = nil

    FCOGuildLottery.currentlyUsedGuildSalesLotteryData          = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount   = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank= nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums = nil
    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellCounts = nil

    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GENERIC
    if startingNewLottery == false then
        df("<END: guild sales lottery data was deleted <<<<<<<<<<<<<<<<<<<<<")
        FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenTimestamp = nil
    else
        df("<OLD guild sales lottery data was deleted - STARTING a new lottery now >>>>>>>>>>>>>>>>>>>>")
        if guildIndex ~= nil and daysBefore ~= nil then
            FCOGuildLottery.NewGuildSalesLottery(guildIndex, daysBefore)
        end
    end
end

local function resetCurrentGuildMembersJoinDateData(startingNewMembersJoinDate, guildIndex, daysBefore)
    startingNewMembersJoinDate = startingNewMembersJoinDate or false
    if startingNewMembersJoinDate == false and FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier == nil then
        return
    end
    df( "resetCurrentGuildMembersJoinDate - startingNewMembersJoinDate: " ..tos(startingNewMembersJoinDate))
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp     = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateRolls         = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateLastRolledChatOutput = nil

    local lastUsedGuildMembersJoinDateDaysBefore = FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore
    FCOGuildLottery.lastUsedGuildMembersJoinDateDaysBefore = lastUsedGuildMembersJoinDateDaysBefore
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime  = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime       = nil

    FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId       = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex    = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildName     = nil

    FCOGuildLottery.currentlyUsedGuildMembersJoinDateData          = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount   = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData= nil

    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GENERIC
    if startingNewMembersJoinDate == false then
        df("<END: guild members join date was deleted <<<<<<<<<<<<<<<<<<<<<")
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenTimestamp = nil
    else
        df("<OLD guild members join date was deleted - STARTING to collect new join dates now >>>>>>>>>>>>>>>>>>>>")
        if guildIndex ~= nil and daysBefore ~= nil then
            FCOGuildLottery.NewGuildMembersJoinDate(guildIndex, daysBefore)
        end
    end
end

function FCOGuildLottery.IsGuildSalesLotteryActive()
    local retVar = (FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier ~= nil and
           FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex ~= nil and
           FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId ~= nil) or false
    df("IsGuildSalesLotteryActive: " ..tos(retVar))
    return retVar
end
local isGuildSalesLotteryActive = FCOGuildLottery.IsGuildSalesLotteryActive

function FCOGuildLottery.IsGuildMembersJoinDateListActive()
    return (FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier ~= nil and
           FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex ~= nil and
           FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId ~= nil) or false
end
local isGuildMembersJoinDateListActive = FCOGuildLottery.IsGuildMembersJoinDateListActive


local function IsGuildIndexValid(guildIndex)
    return (guildIndex ~= nil and guildIndex >= 1 and guildIndex <= MAX_GUILDS) or false
end
FCOGuildLottery.IsGuildIndexValid = IsGuildIndexValid

local function getGuildIdAndName(guildIndex)
    local guildId = GetGuildId(guildIndex)
    local guildName = ZO_CachedStrFormat(SI_UNIT_NAME, GetGuildName(guildId))
    return guildId, guildName
end
FCOGuildLottery.getGuildIdAndName = getGuildIdAndName


local function chatOutputRolledDice(rolledDiceSide, rolledName, guildIndex)
    --Put info into the chat so one just needs to press the return key
    local settings = FCOGuildLottery.settingsVars.settings
    if settings.autoPreFillChatEditBoxAfterDiceRoll == true then
        local chatText
        if settings.autoPreFillChatEditBoxAfterDiceRollOnlyNumber == true then
            chatText = "#<<1>> <<C:2>>"
        else
            if guildIndex ~= nil then
                --Todo: Random chatText template
                local chatTemplates = settings.preFillChatEditBoxAfterDiceRollTextTemplates.guilds
                chatText = chatTemplates[1]
            else
                local chatTemplates = settings.preFillChatEditBoxAfterDiceRollTextTemplates.normal
                chatText = chatTemplates[1]
            end
        end
        local chatChannel = CHAT_CHANNEL_SAY
        if IsGuildIndexValid(guildIndex) == true then
            chatChannel = _G["CHAT_CHANNEL_GUILD_" .. tos(guildIndex)]
        end
        --"#<<1>>, congratulations to \'<<C:2>>\'"
        StartChatInput(zo_strformat(chatText, tos(rolledDiceSide), tos(rolledName)), chatChannel, nil)
    end
end

local function checkIfPendingSellEventAndResetGuildSalesLottery(guildId)
    --[[
    if FCOGuildLottery.IsSellEventPendingForGuildId(guildId) == true then
        FCOGuildLottery.ResetCurrentGuildSalesLotteryData(true, false, nil, nil, nil, nil)
        return
    end
    ]]
    return false
end

local function checkIfPendingMemberJoinedEventAndResetGuildMemberJoinedData(guildId)
    if FCOGuildLottery.IsMemberJoinedEventPendingForGuildId(guildId) == true then
        FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(true, false, nil, nil, nil, nil)
        return
    end
end


function FCOGuildLottery.FormatDate(timeStamp)
    if not timeStamp then return end
    return os.date("%c", timeStamp)
end

local function updateUIGuildsDropNow(diceRollType, guildIndex, updateIfGuildSalesLottery, updateIfGuildMemberJoinedDateList, noCallBack)
    updateIfGuildSalesLottery = updateIfGuildSalesLottery or false
    noCallBack = noCallBack or false
    df(">updateUIGuildsDropNow - diceRollType %s, guildIndex %s, updateIfGuildSalesLottery %s, updateIfGuildMemberJoinedDateList: %s, noCallBack %s",
            tos(diceRollType), tos(guildIndex), tos(updateIfGuildSalesLottery), tos(updateIfGuildMemberJoinedDateList), tos(noCallBack))
    --Set the guilds dropdownbox at the UI, if no active guild sales lottery
    local fcoglUI = FCOGuildLottery.UI
    if updateIfGuildSalesLottery == true and isGuildSalesLotteryActive() then
        if diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY and guildIndex ~= nil then
            fcoglUI.ChangeGuildsDropSelectedByGuildIndex(guildIndex, noCallBack)
        end
    elseif updateIfGuildMemberJoinedDateList == true and isGuildMembersJoinDateListActive() then
        if diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE and guildIndex ~= nil then
            fcoglUI.ChangeGuildsDropSelectedByGuildIndex(guildIndex, noCallBack)
        end
    else
        if diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC and guildIndex ~= nil then
            fcoglUI.ChangeGuildsDropSelectedByGuildIndex(guildIndex, noCallBack)
        elseif diceRollType == FCOGL_DICE_ROLL_TYPE_GENERIC and guildIndex == nil then
            fcoglUI.ChangeGuildsDropSelectedByIndex(MAX_GUILDS + 1, noCallBack)
        end
    end
end
FCOGuildLottery.UI.updateUIGuildsDropNow = updateUIGuildsDropNow

local function isUICreatedAndShown()
    df("isUICreatedAndShown")
    local fcoglUI = FCOGuildLottery.UI
    fcoglUIwindow = fcoglUI and fcoglUI.window

    local showUINow = false
    local isWindowAlreadyShown = false

    if fcoglUIwindow ~= nil then
        if fcoglUIwindow.frame == nil then
            showUINow = true
        else
            isWindowAlreadyShown = not fcoglUIwindow.frame:IsControlHidden()
            if isWindowAlreadyShown == false then
                showUINow = true
            end
        end
    else
        showUINow = true
    end
    return isWindowAlreadyShown, showUINow
end
FCOGuildLottery.UI.isUICreatedAndShown = isUICreatedAndShown

local function updateLoadingIconHiddenState(doHide)
    local fcoglUI = FCOGuildLottery.UI
    fcoglUIwindow = fcoglUIwindow or (fcoglUI and fcoglUI.window)
    fcoglUIwindowFrame = fcoglUIwindowFrame or (fcoglUIwindow and fcoglUIwindow.frame)
    if fcoglUIwindowFrame == nil then return end

    if doHide then
        fcoglUIwindowFrame.loading:Hide()
    else
        fcoglUIwindowFrame.loading:Show()
    end
end

local function checkIfUIShouldBeShownOrUpdated(diceRollType, hideHistory, guildIndex)
    df("checkIfUIShouldBeShownOrUpdated - diceRollType %s, hideHistory %s, guildIndex %s", tos(diceRollType), tos(hideHistory), tos(guildIndex))
    if not diceRollType then return end
    hideHistory = hideHistory or false
    --Is the UI already shown?
    local fcoglUI = FCOGuildLottery.UI
    local isWindowAlreadyShown, showUINow = isUICreatedAndShown()

    if isWindowAlreadyShown == false and showUINow then
        --Show the UI if enabled in the settings
        local settings = FCOGuildLottery.settingsVars.settings
        local showUIForDiceRollTypes = settings.showUIForDiceRollTypes
        local showUIForDiceRollType = showUIForDiceRollTypes[diceRollType] or false
df(">isWindowAlreadyShown: false, showUINow: true, showUIForDiceRollType: %s", tos(showUIForDiceRollType))
        if not showUIForDiceRollType then return end

        --Create (if not existing yet) and show the UI window, and the dice history according to setting
        fcoglUI.Show(true, hideHistory, nil)

        updateUIGuildsDropNow(diceRollType, guildIndex, false, false, nil)
    elseif isWindowAlreadyShown == true then
df(">isWindowAlreadyShown: true")
        --Should the dice history be shown?
        local diceHistoryWindow = fcoglUI.diceHistoryWindow
        if diceHistoryWindow ~= nil and diceHistoryWindow.frame ~= nil then
            local isDiceHistoryHidden = diceHistoryWindow.frame:IsControlHidden()
            if isDiceHistoryHidden then
                diceHistoryWindow.frame:SetHidden(false)
                fcoglUI.setDiceRollHistoryButtonState(false)
                FCOGuildLottery.settingsVars.settings.UIDiceHistoryWindow.isHidden = false
            end
        end
        updateUIGuildsDropNow(diceRollType, guildIndex, false, false, nil)
    end
end


function FCOGuildLottery.getCurrentDiceRollTypeAndGuildIndex()
    local diceRollType = FCOGuildLottery.currentlyUsedDiceRollType
    local guildIndex
    if isGuildSalesLotteryActive() then
        guildIndex = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex
    elseif isGuildMembersJoinDateListActive() then
        guildIndex = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex
    else
        local guildId = FCOGuildLottery.currentlyUsedDiceRollGuildId
        if guildId == nil then
            guildIndex = nil
        else
            guildIndex = FCOGuildLottery.GetGuildIndexById(guildId)
        end
    end
    return diceRollType, guildIndex
end

function FCOGuildLottery.buildGuildsDropEntries()
--df("[FCOGuildLottery]buildGuildsDropEntries")
    local guildsComboBoxEntryBase = {}
    local cnt = 0
    local guildsOfAccount = {}
    for guildIndex=1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if guildId ~= nil and guildId > 0 then
            FCOGuildLottery.diceRollGuildsHistory[guildId] = FCOGuildLottery.diceRollGuildsHistory[guildId] or {}
            local gotTrader = (IsPlayerInGuild(guildId) and DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE)) or false
            local guildName = ZO_CachedStrFormat(SI_UNIT_NAME, GetGuildName(guildId))
            if not gotTrader then
                guildName = "|cFF0000" .. guildName .. "|r"
            end
            guildsOfAccount[guildIndex] = {
                index       = guildIndex,
                id          = guildId,
                name        = string.format("(%s) %s", tos(guildIndex), guildName),
                nameClean   = guildName,
                gotTrader   = gotTrader
            }
        end
    end
    for guildIndex, guildData in ipairs(guildsOfAccount) do
        cnt = cnt + 1
        local stringId = FCOGL_GUILDSDROP_PREFIX .. tos(guildIndex)
        ZO_CreateStringId(stringId, guildData.name)
        SafeAddVersion(stringId, 1)
        table.insert(guildsComboBoxEntryBase, {
            index               =   guildIndex,
            id                  =   guildData.id,
            name                =   guildData.name,
            nameClean           =   guildData.nameClean,
            gotTrader           =   guildData.gotTrader,
        })
    end
    --[[
    --Sort the chars table by their name
    if guildsComboBoxEntryBase ~= nil and #guildsComboBoxEntryBase > 0 then
        table.sort(guildsComboBoxEntryBase,
            --Sort function, returns true if item a will be before b
            function(a,b)
                --Move the current char to the top of the list (current char name starts with " -")
                --if string.sub(tos(a.name), 1, 2) == " -" or string.sub(tos(b.name), 1, 2) == " -" then
                --    return true
                --else
                    return a.name < b.name
                --end
            end
        )
    end
    ]]
    return guildsComboBoxEntryBase
end

function FCOGuildLottery.UpdateCurrentDiceRollType(uiWindow)
    df("UpdateCurrentDiceRollType")
    local fcoglUI = FCOGuildLottery.UI
    uiWindow = uiWindow or fcoglUI.window
    if uiWindow == nil then return end
    if uiWindow.frame ~= nil then
        --The UI is shown?
        if not uiWindow.frame:IsControlHidden() then
            --Get the guilds dropdown selected data
            local selectedGuildsDropdownData = fcoglUI.getSelectedGuildsDropEntry()
            local selectedIndex = selectedGuildsDropdownData.selectedIndex
            --local isGuild = selectedGuildsDropdownData.isGuild
            local guildIndex = selectedGuildsDropdownData.index
            local guildId                            = selectedGuildsDropdownData.id
            local isGuildSalesLotteryCurrentlyActive     = isGuildSalesLotteryActive()
            local isGuildMemberJoinedListCurrentlyActive = isGuildMembersJoinDateListActive()

            local currentDiceRollType = FCOGuildLottery.currentlyUsedDiceRollType
            df(">frame not hidden - currentDiceRollType: %s, guildsDropSelectedIndex: %s", tos(currentDiceRollType), tos(selectedIndex))
            local newDiceRolltype
            if currentDiceRollType == FCOGL_DICE_ROLL_TYPE_GENERIC then
                if IsGuildIndexValid(guildIndex) then
                    if isGuildSalesLotteryCurrentlyActive then
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY
                    elseif isGuildMemberJoinedListCurrentlyActive then
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE
                    else
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC
                    end
                end

            elseif currentDiceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC or
                    currentDiceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY or
                    currentDiceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE then
                if guildId ~= nil and IsGuildIndexValid(guildIndex) then
                    if isGuildSalesLotteryCurrentlyActive then
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY
                    elseif isGuildMemberJoinedListCurrentlyActive then
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE
                    else
                        newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC
                    end
                else
                    newDiceRolltype = FCOGL_DICE_ROLL_TYPE_GENERIC
                end
            end

            df(">>newDiceRolltype: %s", tos(newDiceRolltype))
            FCOGuildLottery.currentlyUsedDiceRollType = newDiceRolltype
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--LibDateTime
--[[
local function getTraderWeekFromDate(dateStr)
    --TODO Change dateStr to a valid dateStr. datetime could be 2021013 or 2021-01-13 or 13.01.2021 etc.
    --local timeStampOfDateStr = ldt:CalculateTimeStamp(year, month, day, hour, minute, second)
    local timeStampOfDateStr = GetTimeStamp()
    --local isInTraderWeek = ldt:IsInTraderWeek(timeStampOfDateStr)
    local weekOffset = ldt:CalculateWeekOffset(timeStampOfDateStr)
    local isoWeekAndYear, tradingWeekStart, tradingWeekEnd = ldt:GetTraderWeek(weekOffset)
    if not tradingWeekStart or not tradingWeekEnd then return nil, nil, nil end
    return isoWeekAndYear, tradingWeekStart, tradingWeekEnd
end
]]

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Slash command functions
local function showNewGSLSlashCommandHelp(noGuildSelected, guildSalesLotteryWanted, guildMemberJoinedListWanted)
    noGuildSelected = noGuildSelected or false
    local newGSLChatErrorMessage
    --local uiWindow = FCOGuildLottery.UI and FCOGuildLottery.UI.window and FCOGuildLottery.UI.window.control
    --if uiWindow ~= nil and uiWindow:IsControlHidden() == false then
--        fcoglUIwindow = fcoglUIwindow or FCOGuildLottery.UI.window
--        fcoglUIwindowFrame = fcoglUIwindowFrame or FCOGuildLottery.UI.window.frame

        if noGuildSelected == true then
            newGSLChatErrorMessage = GetString(FCOGL_ERROR_NO_GUILD_ONLY_GENERIC_DICE_THROW)
        else
            if guildSalesLotteryWanted and guildMemberJoinedListWanted == nil  then
                newGSLChatErrorMessage = string.format(GetString(FCOGL_ERROR_GUILD_SALES_LOTTERY_PARAMETERS_MISSING), tos(FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS))
            elseif guildMemberJoinedListWanted and guildSalesLotteryWanted == nil then
                newGSLChatErrorMessage = string.format(GetString(FCOGL_ERROR_GUILD_MEMBERS_JOIN_DATE_LIST_PARAMETERS_MISSING), tos(FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS))
            else
                newGSLChatErrorMessage = GetString(FCOGL_ERROR_SELECTED_GUILD_INVALID)
            end
        end
--    else
--        newGSLChatErrorMessage = string.format(GetString(FCOGL_ERROR_GUILD_SALES_LOTTERY_PARAMETERS_MISSING), tos(FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS))
--    end
    dfa(newGSLChatErrorMessage)
end


local function checkAndShowNoTraderMessage(guildIndex)
    local guildId, guildName = getGuildIdAndName(guildIndex)
    local gotTrader = (IsPlayerInGuild(guildId) and DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE)) or false
    if not gotTrader then
        local noTraderChatErrorMessage = GetString(FCOGL_ERROR_GUILD_GOT_NO_TRADER)
        dfa(noTraderChatErrorMessage, guildName)
        return true
    end
    return false
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- LibHistoire
local function showGuildEventsStillFetchingMessage(guildId, guildIndex)
    guildIndex = guildIndex or FCOGuildLottery.GetGuildIndexById(guildId)
    local _, guildName = getGuildIdAndName(guildIndex)
    dfe( GetString(FCOGL_ERROR_GUILD_LISTENER_STILL_FETCHING_EVENTS), tos(guildIndex), guildName, tos(guildId) )
end

local function showGuildEventsNoTraderWeekDeterminedMessage(dateStr)
    dfe( "The trading week for the given date \'" ..tos(dateStr) .." \' could not be determined." )
end

local function showGuildEventsNoMemberCountMessage(guildId, guildIndex)
    guildIndex = guildIndex or FCOGuildLottery.GetGuildIndexById(guildId)
    local _, guildName = getGuildIdAndName(guildIndex)
    dfe(GetString(FCOGL_ERROR_GUILD_MEMBER_COUNT), tos(guildIndex), guildName, tos(guildId))
end

local function showGuildEventsNoMemberJoinedMessage(guildId, guildIndex)
    guildIndex = guildIndex or FCOGuildLottery.GetGuildIndexById(guildId)
    local _, guildName = getGuildIdAndName(guildIndex)
    dfe(GetString(FCOGL_ERROR_GUILD_MEMBER_JOINED_COUNT), tos(guildIndex), guildName, tos(guildId))
end

function FCOGuildLottery.FetchHistyLibrary()
    df( "FetchHistyLibrary")
    if lh == nil or FCOGuildLottery.LH == nil then
        FCOGuildLottery.LH = LibHistoire
        lh = FCOGuildLottery.LH
        if lh == nil then
            dfe( "!!!!! Mandatory library \'LibHistoire\' could not be loaded !!!!!")
        end
    end
end

function FCOGuildLottery.GetSellEventProcessorForGuildId(guildId)
df( "GetSellEventProcessorForGuildId - guildId: " ..tos(guildId) .. " -> " ..tos(FCOGuildLottery.guildSellListeners[guildId]))
    if not checkForLibHistoireReady() or guildId == nil then return end
    return FCOGuildLottery.guildSellListeners[guildId]
end
local getSellEventProcessorForGuildId = FCOGuildLottery.GetSellEventProcessorForGuildId

function FCOGuildLottery.SetSellEventProcessorForGuildId(guildId, processor)
df( "SetSellEventListenerForGuildId - guildId: " ..tos(guildId) .. " -> " ..tos(FCOGuildLottery.guildSellListeners[guildId]))
    if not checkForLibHistoireReady() or guildId == nil then return end
    FCOGuildLottery.guildSellListeners[guildId] = processor
end
local setSellEventProcessorForGuildId = FCOGuildLottery.SetSellEventProcessorForGuildId


function FCOGuildLottery.GetMemberEventProcessorForGuildId(guildId)
df( "GetMemberEventListenerForGuildId - guildId: " ..tos(guildId) .. " -> " ..tos(FCOGuildLottery.guildMembersListeners[guildId]))
    if not checkForLibHistoireReady() or guildId == nil then return end
    return FCOGuildLottery.guildMembersListeners[guildId]
end
local getMemberEventProcessorForGuildId = FCOGuildLottery.GetMemberEventProcessorForGuildId


function FCOGuildLottery.SetMemberEventProcessorForGuildId(guildId, processor)
df( "SetMemberEventProcessorForGuildId - guildId: " ..tos(guildId) .. " -> " ..tos(FCOGuildLottery.guildMembersListeners[guildId]))
    if not checkForLibHistoireReady() or guildId == nil then return end
    FCOGuildLottery.guildMembersListeners[guildId] = processor
end
local setMemberEventProcessorForGuildId = FCOGuildLottery.SetMemberEventProcessorForGuildId


function FCOGuildLottery.IsSellEventPendingForAnyGuildId()
    if not checkForLibHistoireReady() then return end

    local sellEventsForGuildsActive = FCOGuildLottery.guildSellListenerCompleted
    if not sellEventsForGuildsActive then return false end
    for guildId, _ in pairs(sellEventsForGuildsActive) do
        local isPending, timeLeft = FCOGuildLottery.IsSellEventPendingForGuildId(guildId) == true
        if isPending == true then
            return true, timeLeft
        end
    end
    return false, 0
end

function FCOGuildLottery.IsSellEventPendingForGuildId(guildId)
    --API 2.0 -> Still valid?

    if not checkForLibHistoireReady() then return nil, nil end
    df( "IsSellEventPendingForGuildId - guildId: %s", tos(guildId))
--d( string.format("IsSellEventPendingForGuildId - guildId: %s", tos(guildId)))

    --[[
        1. weißt du, dass du alle Daten hast wenn der SetIterationCompletedCallback aufgerufen wird
        2. kannst du mittels der GetPendingEventMetrics Funktion abfragen wie weit die iteration ist
        3. wenn eventCount 0 ist und SetIterationCompleted nicht aufgerufen wurde, kannst du annehmen, dass noch Daten ausstehen
    ]]
    local guildEventSellProcessor = getSellEventProcessorForGuildId(guildId)
    if not guildEventSellProcessor then return nil, nil end
    --All data was received already for the guildId?
    if FCOGuildLottery.guildSellListenerCompleted[guildId] == true then
        df("<guild sell listener was completed!")
--d("<guild sell listener was completed!")
        return false, 0
    end

    --is the listener still running or did it end?
    local isRunning = guildEventSellProcessor:IsRunning()
    if not isRunning then
        df("<guild sell listener not actively running!")
--d("<guild sell listener not actively running!")
        return false, 0
    end


    --eventCount - the amount of stored or unlinked events that are currently waiting to be processed by the listener
    --processingSpeed - the average processing speed in events per second or -1 if not enough data is yet available
    --timeLeft - the estimated time in seconds it takes to process the remaining events or -1 if no estimate is possible
    local numEventsRemaining, processingSpeed, timeLeft = guildEventSellProcessor:GetPendingEventMetrics()
    df(">eventsRemaining: %s, processingSpeed: %s, timeLeft: %s", tos(numEventsRemaining), tos(processingSpeed), tos(timeLeft))
--d(string.format(">eventCount: %s, processingSpeed: %s, timeLeft: %s", tos(eventCount), tos(processingSpeed), tos(timeLeft)))
    local errorMsg = false
    if numEventsRemaining > 0 then
        --Workaround as there often happens to be the eventCount = 1, but the listener itsself at the guildHistory says: All data fetched?!
        if numEventsRemaining == 1 and processingSpeed == -1 and timeLeft == -1 then
            --TODO: How to check that LibHistoire's data for the sell event at guildId is all done?
            if isRunning == true then
                -->Assume all is okay....
                return false, 0
            end
            errorMsg = true
        end
    elseif numEventsRemaining == 0 then
        errorMsg = true
        timeLeft = 0 --unknown timeleft, as currently there are no events
    end
    if errorMsg == true then
        showGuildEventsStillFetchingMessage(guildId)
        return true, timeLeft
    end
    return false, 0
end

function FCOGuildLottery.IsMemberJoinedEventPendingForGuildId(guildId)
    if not checkForLibHistoireReady() then return nil, nil end
    df( "IsMemberJoinedEventPendingForGuildId - guildId: %s", tos(guildId))
--d( string.format("IsMemberJoinedEventPendingForGuildId - guildId: %s", tos(guildId)))

    --[[
        1. weißt du, dass du alle Daten hast wenn der SetIterationCompletedCallback aufgerufen wird
        2. kannst du mittels der GetPendingEventMetrics Funktion abfragen wie weit die iteration ist
        3. wenn eventCount 0 ist und SetIterationCompleted nicht aufgerufen wurde, kannst du annehmen, dass noch Daten ausstehen
    ]]
    local guildEventMemberJoinedListener = getMemberEventProcessorForGuildId(guildId)
    if not guildEventMemberJoinedListener then return nil, nil end
    --All data was received already for the guildId?
    if FCOGuildLottery.guildMembersListenerCompleted[guildId] == true then
        df("<guild member joined listener was completed!")
--d("<guild sell listener was completed!")
        return false, 0
    end

    --is the listener still running or did it end?
    local isRunning = guildEventMemberJoinedListener:IsRunning()
    if not isRunning then
        df("<guild member joined listener not actively running!")
--d("<guild sell listener not actively running!")
        return false, 0
    end
    --eventCount - the amount of stored or unlinked events that are currently waiting to be processed by the listener
    --processingSpeed - the average processing speed in events per second or -1 if not enough data is yet available
    --timeLeft - the estimated time in seconds it takes to process the remaining events or -1 if no estimate is possible
    local eventCount, processingSpeed, timeLeft = guildEventMemberJoinedListener:GetPendingEventMetrics()
    df(">eventCount: %s, processingSpeed: %s, timeLeft: %s", tos(eventCount), tos(processingSpeed), tos(timeLeft))
--d(string.format(">eventCount: %s, processingSpeed: %s, timeLeft: %s", tos(eventCount), tos(processingSpeed), tos(timeLeft)))
    local errorMsg = false
    if eventCount > 0 then
        --Workaround as there often happens to be the eventCount = 1, but the listener itsself at the guildHistory says: All data fetched?!
        if eventCount == 1 and processingSpeed == -1 and timeLeft == -1 then
            --TODO: How to check that LibHistoire's data for the guild roster member joined at guildId is all done?
            if isRunning == true then
                -->Assume all is okay....
                return false, 0
            end
            errorMsg = true
        end
    elseif eventCount == 0 then
        errorMsg = true
        timeLeft = 0 --unknown timeleft, as currently there are no events
    end
    if errorMsg == true then
        showGuildEventsStillFetchingMessage(guildId)
        return true, timeLeft
    end
    return false, 0
end

function FCOGuildLottery.AddTradeSellEvent(guildId, uniqueIdentifier, eventType, eventId, eventTime, seller, buyer, quantity, itemLink, price, tax)
    if not checkForLibHistoireReady() or
        not guildId or not uniqueIdentifier or not eventId then return end
--dfv( "AddTradeSellEvent - guildId: %s, uniqueIdentifier: %s, seller: %s, buyer: %s, quantity: %s, itemlink: %s, price: %s, tax: %s ", tos(guildId), tos(uniqueIdentifier), tos(seller), tos(buyer), tos(quantity), tos(itemLink), tos(price), tos(tax))
    FCOGuildLottery.guildSellStats[guildId][uniqueIdentifier] = FCOGuildLottery.guildSellStats[guildId][uniqueIdentifier] or {}
    local eventTimeFormated = os.date("%c", eventTime)
    local eventKey = seller .. "_" .. Id64ToString(eventId) .. "_" .. eventTime .. "_"  .. "_" .. eventTimeFormated
    --local processor = getSellEventProcessorForGuildId(guildId)
    --local eventKey = processor:GetKey()
    FCOGuildLottery.guildSellStats[guildId][uniqueIdentifier][eventKey] = {
        eventId     = Id64ToString(eventId),
        eventTime   = eventTime, --today: format the date and time from timestamp!
        eventTimeFormated = eventTimeFormated, --today: format the date and time from timestamp!
        --params of GUILD_EVENT_ITEM_SOLD
        seller      = seller, --seller
        buyer       = buyer, --buyer
        quantity    = quantity, --quantity
        itemLink    = itemLink, --itemLink
        price       = price, --price
        tax         = tax  --tax
    }

    --[[
    --TODO: For debugging and comparison with MM data!
    local guildName = GetGuildName(guildId)
    FCOGuildLottery._FCOGL7DaysData = FCOGuildLottery._FCOGL7DaysData or {}
    FCOGuildLottery._FCOGL7DaysData[guildName] = FCOGuildLottery._FCOGL7DaysData[guildName] or {}
    FCOGuildLottery._FCOGL7DaysData[guildName][eventTime .. "(" ..eventTimeFormated .. ")_" .. Id64ToString(eventId)] = {
      seller = param1,
      amount = param5,
      stack = param3,
      wasKiosk = (param2 ~= nil and true) or false,
    }
    ]]

end
local addTradeSellEvent = FCOGuildLottery.AddTradeSellEvent

function FCOGuildLottery.AddMemberJoinedEvent(guildId, uniqueIdentifier, eventType, eventId, eventTime, joinerDisplayName, optionalInviterDisplayName)
    if not checkForLibHistoireReady() or not guildId or not uniqueIdentifier or not eventId then return end
--dfv( "AddMemberJoinedEvent - guildId: %s, uniqueIdentifier: %s, joinerDisplayName: %s, optionalInviterDisplayName: %s, tos(guildId), tos(uniqueIdentifier), tos(joinerDisplayName), tos(optionalInviterDisplayName))
    FCOGuildLottery.guildMembersJoinedStats[guildId][uniqueIdentifier] = FCOGuildLottery.guildMembersJoinedStats[guildId][uniqueIdentifier] or {}
    local eventTimeFormated = os.date("%c", eventTime)
    local eventKey = joinerDisplayName .. "_" .. Id64ToString(eventId) .. "_" .. eventTime .. "_"  .. "_" .. eventTimeFormated
    --local processor = getMemberEventProcessorForGuildId(guildId)
    --local eventKey = processor:GetKey()
    FCOGuildLottery.guildMembersJoinedStats[guildId][uniqueIdentifier][eventKey] = {
        eventId     = Id64ToString(eventId),
        eventTime   = eventTime, --today: format the date and time from timestamp!
        eventTimeFormated = eventTimeFormated, --today: format the date and time from timestamp!
        --Params of GUILD_EVENT_GUILD_JOIN
        --[[
            function GuildJoinedEventFormat(eventType, joinerDisplayName, optionalInviterDisplayName)
                if IsInvalidParam(optionalInviterDisplayName) then
                    local contrastColor = GetContrastTextColor()
                    local userFacingJoinerDisplayName = ZO_FormatUserFacingDisplayName(joinerDisplayName)
                    return zo_strformat(SI_GUILDEVENTTYPEDEPRECATED7, contrastColor:Colorize(userFacingJoinerDisplayName))
                else
                    return DefaultEventFormatWithTwoDisplayNames(eventType, joinerDisplayName, optionalInviterDisplayName)
                end
            end
        ]]
        joinerDisplayName           = joinerDisplayName, --joinerDisplayName
        optionalInviterDisplayName  = optionalInviterDisplayName, --optionalInviterDisplayName
    }
end
local addMemberJoinedEvent = FCOGuildLottery.AddMemberJoinedEvent


local function libHistoireGuildHistoryTraderEventErrorProcessor(reason, guildId, processor)
    local guildIdOfListener = guildId or processor:GetGuildId()
    local stopReasons = lh.StopReason

    if (reason == stopReasons.ITERATION_COMPLETED) then
        -- all events in the time range have been processed
        df( "<<<~~~~~~~~~~ CollectGuildSellStats - end for guildId: %s ~~~~~~~~~~<<<", tos(guildIdOfListener) )
        FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = true

        --Start the first dice throw for the guild sales history now
        FCOGuildLottery.RollTheDiceForGuildSalesLotteryNow(FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId or guildId, FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex, false)

    elseif reason == stopReasons.LAST_CACHED_EVENT_REACHED then
        -- all events in the time range have been processed but there could be more as you selected until "today"
        -->Counts as finished too in our case
        df( "<<<LAST CACHED EVENT REACHED !!!!! CollectGuildSellStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = true

        --Start the first dice throw for the guild sales history now
        FCOGuildLottery.RollTheDiceForGuildSalesLotteryNow(FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId or guildId, FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex, false)


    elseif reason == stopReasons.MANAGED_RANGE_LOST then
        FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = false
        dfe( "<<<MANAGED RANGED LOST !!!!! CollectGuildSellStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfe( "Guild sales history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    elseif reason == stopReasons.MANUAL_STOP then
        FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = false
        dfw( "<<<MANUAL STOP !!!!! CollectGuildSellStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfw( "Guild sales history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    else
        FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = false
        dfe( "<<<ERROR !!!!! CollectGuildSellStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfe( "Guild sales history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    end
end

local guildMemberJoinedEventsReceivedCounter = 0
local function libHistoireGuildHistoryMemberJoinedEventProcessor(event, guildId, processor, uniqueIdentifier, wasMissed)
    wasMissed = wasMissed or false
    local info = event:GetEventInfo()
    local eventType = info.eventType
    --Member joined events
    if eventType == GUILD_HISTORY_ROSTER_EVENT_JOIN then
        --Params as of "ConvertEvent":
        --GUILD_EVENT_GUILD_JOIN, oldEventId, eventTime, DecorateDisplayName(info.actingDisplayName), DecorateDisplayName(info.targetDisplayName)
        local eventId = event:GetEventId()
        local eventTime = event:GetEventTimestampS()
        local guildIdOfListener = guildId or processor:GetGuildId()
        if not wasMissed then
            guildMemberJoinedEventsReceivedCounter = guildMemberJoinedEventsReceivedCounter + 1
            if guildMemberJoinedEventsReceivedCounter == 1 then
                df(">!!!!! [FIRST EVENT!]Members joined listener:NextEvent - guildId: %s, eventType: %s, eventTime: %s", tos(guildIdOfListener), tos(eventType), tos(eventTime))
            end
            --dfv(">Sold items listener:NextEvent - guildId: %s, eventType: %s, eventTime: %s", tos(guildIdOfListener), tos(eventType), tos(eventTime))

            FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = false
            --addMemberJoinedEvent(guildId, uniqueIdentifier, eventType, eventId, eventTime, joinerDisplayName, optionalInviterDisplayName)
            addMemberJoinedEvent(guildIdOfListener, uniqueIdentifier, eventType, eventId, eventTime, DecorateDisplayName(info.actingDisplayName), DecorateDisplayName(info.targetDisplayName))
        else
            --Missed event
            --dfw( "Missed member joined event detected-eventId: %s, guildId: %s, eventTime: %s, seller: %s, buyer: %s, quantity: %s, itemLink: %s, price: %s, tax: %s", tos(eventId), tos(guildIdOfListener), tos(eventTime), tos(DecorateDisplayName(info.sellerDisplayName)), tos(DecorateDisplayName(info.buyerDisplayName)), tos(info.quantity), tos(info.itemLink), tos(info.price), tos(info.tax))
        end
    end
end

local function libHistoireGuildHistoryMemberJoinedEventErrorProcessor(reason, guildId, processor)
    local guildIdOfListener = guildId or processor:GetGuildId()
    local stopReasons = lh.StopReason

    if (reason == stopReasons.ITERATION_COMPLETED) then
        -- all events in the time range have been processed
        df( "<<<~~~~~~~~~~ CollectGuildMemberStats - end for guildId: %s ~~~~~~~~~~<<<", tos(guildIdOfListener) )
        FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = true

        --Start the first dice throw for the guild sales history now
        FCOGuildLottery.RollTheDiceForMemberJoinedNow(FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId or guildId, FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex, false)

    elseif reason == stopReasons.LAST_CACHED_EVENT_REACHED then
        -- all events in the time range have been processed but there could be more as you selected until "today"
        -->Counts as finished too in our case
        df( "<<<LAST CACHED EVENT REACHED !!!!! CollectGuildMemberStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = true

        --Start the first dice throw for the guild sales history now
        FCOGuildLottery.RollTheDiceForMemberJoinedNow(FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId or guildId, FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex, false)


    elseif reason == stopReasons.MANAGED_RANGE_LOST then
        FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = false
        dfe( "<<<MANAGED RANGED LOST !!!!! CollectGuildMemberStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfe( "Guild member joined history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    elseif reason == stopReasons.MANUAL_STOP then
        FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = false
        dfw( "<<<MANUAL STOP !!!!! CollectGuildMemberStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfw( "Guild member joined history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    else
        FCOGuildLottery.guildMembersListenerCompleted[guildIdOfListener] = false
        dfe( "<<<ERROR !!!!! CollectGuildMemberStats - end for guildId: %s !!!!! <<<", tos(guildIdOfListener) )
        dfe( "Guild member joined history listener stopped early! guildId: %s, name: %q, reason: %s", tos(guildId), tos(GetGuildName(guildId)), tos(reason) )
    end
end

local guildSalesEventsReceivedCounter = 0
local function libHistoireGuildHistoryTraderEventProcessor(event, guildId, processor, uniqueIdentifier, wasMissed)
    wasMissed = wasMissed or false
    local info = event:GetEventInfo()
    local eventType = info.eventType
    --Sold item events
    if eventType == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
        --Params as of "ConvertEvent":
        --GUILD_EVENT_ITEM_SOLD, oldEventId, eventTime, DecorateDisplayName(info.sellerDisplayName), DecorateDisplayName(info.buyerDisplayName), info.quantity, info.itemLink, info.price, info.tax
        local eventId = event:GetEventId()
        local eventTime = event:GetEventTimestampS()
        local guildIdOfListener = guildId or processor:GetGuildId()
        if not wasMissed then
            guildSalesEventsReceivedCounter = guildSalesEventsReceivedCounter + 1
            if guildSalesEventsReceivedCounter == 1 then
                df(">!!!!! [FIRST EVENT!]Sold items listener:NextEvent - guildId: %s, eventType: %s, eventTime: %s", tos(guildIdOfListener), tos(eventType), tos(eventTime))
            end
            --dfv(">Sold items listener:NextEvent - guildId: %s, eventType: %s, eventTime: %s", tos(guildIdOfListener), tos(eventType), tos(eventTime))

            FCOGuildLottery.guildSellListenerCompleted[guildIdOfListener] = false
            --addTradeSellEvent(guildId, uniqueIdentifier, eventType, eventId, eventTime, seller, buyer, quantity, itemLink, price, tax)
            addTradeSellEvent(guildIdOfListener, uniqueIdentifier, eventType, eventId, eventTime, DecorateDisplayName(info.sellerDisplayName), DecorateDisplayName(info.buyerDisplayName), info.quantity, info.itemLink, info.price, info.tax)
        else
            --Missed event
            --dfw( "Missed guild sales event detected-eventId: %s, guildId: %s, eventTime: %s, seller: %s, buyer: %s, quantity: %s, itemLink: %s, price: %s, tax: %s", tos(eventId), tos(guildIdOfListener), tos(eventTime), tos(DecorateDisplayName(info.sellerDisplayName)), tos(DecorateDisplayName(info.buyerDisplayName)), tos(info.quantity), tos(info.itemLink), tos(info.price), tos(info.tax))
        end
    end
end

--Get guild store sell statistics from LibHistoire stored events
function FCOGuildLottery.CollectGuildSellStats(guildId, startDate, endDate, uniqueIdentifier)
    df( "CollectGuildSellStats - guildId: %s, name: %s, startDate: %s, endDate: %s, uniqueIdentifier: %s", tos(guildId),tos(GetGuildName(guildId)),tos(startDate),tos(endDate),tos(uniqueIdentifier) )
    if not checkForLibHistoireReady() then
        dfe( "CollectGuildSellStats - Mandatory library \LibHistoire\' not found, or not ready yet!")
        return
    elseif guildId == nil or uniqueIdentifier == nil or uniqueIdentifier == "" or startDate == nil or endDate == nil or
           startDate == nil or endDate == nil then
        dfe( "CollectGuildSellStats - Either guildId: %s, startTradingDay: %s, endTradingDay: %s or uniqueIdentifier: %s are not given!", tos(guildId),tos(startDate),tos(endDate),tos(uniqueIdentifier))
        return
    elseif startDate and endDate and startDate > endDate then
        dfe( "CollectGuildSellStats - startTradingDay: " ..tos(startDate) .. " is newer than endTradingDay: " ..tos(endDate))
    end
--d(">>listener 0")

    --Did the timeframe change?
    if FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime == nil or startDate ~= FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime or
            FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime == nil or endDate ~= FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime or
            FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier == nil or uniqueIdentifier ~= FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier then
        df(">Sold items listener's timeFrame changed: %s to %s", os.date("%c", startDate), os.date("%c", endDate))
        --d(string.format(">listener's timeFrame changed: %s to %s", os.date("%c", startDate), os.date("%c", endDate)))
        --Create / reset the guildSalesStats for the current guildId, and the flag "callback completed"
        FCOGuildLottery.guildSellStats[guildId] = FCOGuildLottery.guildSellStats[guildId] or {}
    end


    --Create the listener for the guild history sold items - NEW API
    local existingProcessor = getSellEventProcessorForGuildId(guildId)
    if existingProcessor ~= nil then
        if existingProcessor:IsRunning() then
            if existingProcessor:Stop() then
                df(">>!!!Existing and active sold items processor stopped!!!")
            else
                df(">>!!!Existing and active sold items processor could NOT be stopped!!!")
                return
            end
        end
    end

    --Reset the link to the current processor
    setSellEventProcessorForGuildId(guildId, nil)
    FCOGuildLottery.guildSellListenerCompleted[guildId] = false
    guildSalesEventsReceivedCounter                     = 0

    --Get guild history category "trader"
    local category = GUILD_HISTORY_EVENT_CATEGORY_TRADER
    local processor = lh:CreateGuildHistoryProcessor(guildId, category, addonName)
    if not processor then
        -- the processor could not be created
        df(">New sold items processor could NOT be created for guildId: %s", tos(guildId))
        return
    end
    df(">New sold items processor created for guildId: %s", tos(guildId))

    --Create a new listener and directly start it
    local listenerStarted = processor:StartIteratingTimeRange(startDate, endDate,
            function(event) libHistoireGuildHistoryTraderEventProcessor(event, guildId, processor, uniqueIdentifier, nil) end ,
            function(reason) libHistoireGuildHistoryTraderEventErrorProcessor(reason, guildId, processor) end
    )
    if not listenerStarted then
        dfe( "CollectGuildSellStats - Listener sold items coud not be found/created! GuildId: " ..tos(guildId) .. ", startTradingDay: " ..tos(startDate).. ", endTradingDay: " ..tos(endDate).. ", uniqueIdentifier: " ..tos(uniqueIdentifier))
        return
    else
        df( ">>>~~~~~~~~~~ CollectGuildSellStats - listener started for guildId: %s, name: %q ~~~~~~~~~~>>>", tos(guildId),tos(GetGuildName(guildId)) )

        --Set event missed callback
        processor:SetMissedEventCallback(function(event) libHistoireGuildHistoryTraderEventProcessor(event, guildId, processor, uniqueIdentifier, true) end)

        df(">Sold items listener running for guildId: %s", tos(guildId))

        --Update the link to the current processor
        setSellEventProcessorForGuildId(guildId, processor)
        FCOGuildLottery.guildSellListenerCompleted[guildId] = false
    end
end


--Get guild members statistics from LibHistoire stored events
function FCOGuildLottery.CollectGuildMemberStats(guildId, startDate, endDate, uniqueIdentifier)
    df( "CollectGuildMemberStats - guildId: %s, startDate: %s, endDate: %s, uniqueIdentifier: %s", tos(guildId),tos(startDate),tos(endDate),tos(uniqueIdentifier) )
    if not checkForLibHistoireReady() then
        dfe( "CollectGuildMemberStats - Mandatory library \LibHistoire\' not found, or not ready yet!")
        return
    elseif guildId == nil or uniqueIdentifier == nil or uniqueIdentifier == "" or startDate == nil or endDate == nil or
            startDate == nil or endDate == nil then
        dfe( "CollectGuildMemberStats - Either guildId: %s, startTradingDay: %s, endTradingDay: %s or uniqueIdentifier: %s are not given!", tos(guildId),tos(startDate),tos(endDate),tos(uniqueIdentifier))
        return
    elseif startDate and endDate and startDate > endDate then
        dfe( "CollectGuildMemberStats - startTradingDay: " ..tos(startDate) .. " is newer than endTradingDay: " ..tos(endDate))
    end
    --d(">>listener 0")

    --Did the timeframe change?
    if FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime == nil or startDate ~= FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime or
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime == nil or endDate ~= FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime or
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier == nil or uniqueIdentifier ~= FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier then
        df(">Guild roster listener's timeFrame changed: %s to %s", os.date("%c", startDate), os.date("%c", endDate))
        FCOGuildLottery.guildMembersJoinedStats[guildId] = FCOGuildLottery.guildMembersJoinedStats[guildId] or {}
    end

    --Create the listener for the guild history member joined - NEW API
    local existingProcessor = getMemberEventProcessorForGuildId(guildId)
    if existingProcessor ~= nil then
        if existingProcessor:IsRunning() then
            if existingProcessor:Stop() then
                df(">>!!!Existing and active member joined processor stopped!!!")
            else
                df(">>!!!Existing and active member joined processor could NOT be stopped!!!")
                return
            end
        end
    end

    --Reset the link to the current processor
    setMemberEventProcessorForGuildId(guildId, nil)
    FCOGuildLottery.guildMembersListenerCompleted[guildId] = false
    guildMemberJoinedEventsReceivedCounter = 0


    --Get guild history category "roster"
    local category = GUILD_HISTORY_EVENT_CATEGORY_ROSTER
    local processor = lh:CreateGuildHistoryProcessor(guildId, category, addonName)
    if not processor then
        -- the processor could not be created
        df(">New member joined processor could NOT be created for guildId: %s", tos(guildId))
        return
    end
    df(">New member joined processor created for guildId: %s", tos(guildId))

    --Create a new listener and directly start it
    local listenerStarted = processor:StartIteratingTimeRange(startDate, endDate,
            function(event) libHistoireGuildHistoryMemberJoinedEventProcessor(event, guildId, processor, uniqueIdentifier, nil) end ,
            function(reason) libHistoireGuildHistoryMemberJoinedEventErrorProcessor(reason, guildId, processor) end
    )
    if not listenerStarted then
        dfe( "CollectGuildMemberStats - Listener member joined coud not be found/created! GuildId: " ..tos(guildId) .. ", startTradingDay: " ..tos(startDate).. ", endTradingDay: " ..tos(endDate).. ", uniqueIdentifier: " ..tos(uniqueIdentifier))
        return
    else
        df( ">>>~~~~~~~~~~ CollectGuildMemberStats - listener started for guildId: %s, name: %q ~~~~~~~~~~>>>", tos(guildId),tos(GetGuildName(guildId)) )

        --Set event missed callback
        processor:SetMissedEventCallback(function(event) libHistoireGuildHistoryMemberJoinedEventProcessor(event, guildId, processor, uniqueIdentifier, true) end)

        df(">Member joined listener running for guildId: %s", tos(guildId))

        --Update the link to the current processor
        setSellEventProcessorForGuildId(guildId, processor)
        FCOGuildLottery.guildMembersListenerCompleted[guildId] = false
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function buildUniqueId(guildId, daysToGetBefore, defaultDaysBefore, diceRolltype)
    if not diceRolltype then return end
    daysToGetBefore = daysToGetBefore or defaultDaysBefore
    if daysToGetBefore == nil or daysToGetBefore <= 0 then return end
    local guildName = GetGuildName(guildId)
    --Changed at 20210214, removed GuildName as the uniqueId will be used inside tables where the unique guildId is already given as a top level filter
    local uniqueId = string.format(FCOGuildLottery.constStr[diceRolltype], tos(daysToGetBefore))
    df( "buildUniqueId - guildId: %s, daysToGetBefore: %s, guildName: %s -> uniqueId: %s - diceRollType: %s", tos(guildId), tos(daysToGetBefore), guildName, uniqueId, tos(diceRolltype))
    return uniqueId
end
FCOGuildLottery.BuildUniqueId = buildUniqueId


--Guild store sell statistics from now to - daysToGetBefore days
function FCOGuildLottery.PrepareSellStatsOfGuild(guildId, daysToGetBefore)
    if not guildId or not daysToGetBefore then return end
    --Get the actual trading week via LibDateTime
    --Not needed!
    --local isoWeekAndYear, tradingWeekStart, tradingWeekEnd = getTraderWeekFromDate(daysToGetBefore)
    --Manually calculate the last n days
    local startDate, endDate = getDateMinusXDays(daysToGetBefore, FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS)
    --d( string.format("PrepareSellStatsOfGuild - guildId: %s, daysToGetBefore: %s, dateStart: %s, dateEnd: %s", tos(guildId), tos(daysToGetBefore), os.date("%c", startDate) , os.date("%c", endDate)))
    df( "PrepareSellStatsOfGuild - guildId: %s, name: %q, daysToGetBefore: %s, dateStart: %s, dateEnd: %s", tos(guildId), tos(GetGuildName(guildId)), tos(daysToGetBefore), os.date("%c", startDate) , os.date("%c", endDate))

    --77951 - Fair Trade Society
    --guildId = guildId or 77951
    --UniqueId: "GuildSellsLast%sDays_%s"
    local uniqueIdentifier = buildUniqueId(guildId, daysToGetBefore, FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS, FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
    FCOGuildLottery.CollectGuildSellStats(guildId, startDate, endDate, uniqueIdentifier)
    return uniqueIdentifier, startDate, endDate--, isoWeekAndYear
end

--Guild store member statistics from now to - daysToGetBefore days
function FCOGuildLottery.PrepareMembersStatsOfGuild(guildId, daysToGetBefore)
    if not guildId or not daysToGetBefore then return end
    --Manually calculate the last n days
    local startDate, endDate = getDateMinusXDays(daysToGetBefore, FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS)
    --d( string.format("PrepareMembersStatsOfGuild - guildId: %s, daysToGetBefore: %s, dateStart: %s, dateEnd: %s", tos(guildId), tos(daysToGetBefore), os.date("%c", startDate) , os.date("%c", endDate)))
    df( "PrepareMembersStatsOfGuild - guildId: %s, daysToGetBefore: %s, dateStart: %s, dateEnd: %s", tos(guildId), tos(daysToGetBefore), os.date("%c", startDate) , os.date("%c", endDate))

    --77951 - Fair Trade Society
    --guildId = guildId or 77951
    --UniqueId: "GuildSellsLast%sDays_%s"
    local uniqueIdentifier = buildUniqueId(guildId, daysToGetBefore, FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS, FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)
    FCOGuildLottery.CollectGuildMemberStats(guildId, startDate, endDate, uniqueIdentifier)
    return uniqueIdentifier, startDate, endDate--, isoWeekAndYear
end


--Get the default (chosen in settings, or 7 days) sales history data of each guild which got a store enabled
function FCOGuildLottery.GetDefaultSalesHistoryData()
    local daysBefore = FCOGuildLottery.settingsVars.settings.guildLotteryDaysBefore
    daysBefore = daysBefore or FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS
    df( "GetDefaultSalesHistoryData - Getting sales history of the last %s days, for all guilds...", tos(daysBefore))
    if lh == nil then FCOGuildLottery.FetchHistyLibrary() end
    FCOGuildLottery.defaultGuildSalesLotteryUniqueIdentifiers = {}
    --Prepare the sold history data for the 5 guilds, of the last 7 days
    for guildIndex=1, GetNumGuilds(), 1 do
        --Are you in that guild?
        local guildId = GetGuildId(guildIndex)
        if guildId and guildId > 0 then
            --Am I member of this guild?
            if IsPlayerInGuild(guildId) and DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE) then
                --Does this guild use a shop?
                df( ">Guild got a shop: guildId: %s, name: %q", tos(guildId), tos(GetGuildName(guildId)) )
                local unqiueId, _, _ = FCOGuildLottery.PrepareSellStatsOfGuild(guildId, daysBefore)
                FCOGuildLottery.defaultGuildSalesLotteryUniqueIdentifiers[guildId] = unqiueId
            end
        end
    end
end

--Get the default (chosen in settings, or 31 days) guild member history data of each guild
function FCOGuildLottery.GetDefaultMemberHistoryData()
    local daysBefore = FCOGuildLottery.settingsVars.settings.guildMembersDaysBefore
    daysBefore = daysBefore or FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS
    df( "GetDefaultMemberHistoryData - Getting members history of the last %s days, for all guilds...", tos(daysBefore))
    if lh == nil then FCOGuildLottery.FetchHistyLibrary() end
    FCOGuildLottery.defaultMembersUniqueIdentifiers = {}
    --Prepare the sold history data for the 5 guilds, of the last 7 days
    for guildIndex=1, GetNumGuilds(), 1 do
        --Are you in that guild?
        local guildId = GetGuildId(guildIndex)
        if guildId and guildId > 0 then
            --Am I member of this guild?
            if IsPlayerInGuild(guildId) then
                local unqiueId, _, _ = FCOGuildLottery.PrepareMembersStatsOfGuild(guildId, daysBefore)
                FCOGuildLottery.defaultMembersUniqueIdentifiers[guildId] = unqiueId
            end
        end
    end
end


--Get the count of members who sold something via the guild store, in a timeframe from a given endTime - daysToGetBefore days
function FCOGuildLottery.GetGuildSalesMemberCount(guildId, daysToGetBefore, startTime, endTime, uniqueIdentifier)
    if not guildId or not daysToGetBefore then return end
    if daysToGetBefore <= 0 then daysToGetBefore = 1 end
    if not endTime or not startTime then return end

    df( "GetGuildSalesMemberCount-guildId: %s, daysToGetBefore: %s, startTime: %s, endTime: %s, uniqueIdentifier: %s", tos(guildId), tos(daysToGetBefore), tos(startTime), tos(endTime), tos(uniqueIdentifier))

    local countMembersHavingSold = 0
    local currentlyUsedGuildSalesLotteryMemberCount = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
    if FCOGuildLottery.currentlyUsedGuildSalesLotteryData ~= nil and currentlyUsedGuildSalesLotteryMemberCount ~= nil and currentlyUsedGuildSalesLotteryMemberCount > 0 then
        df(">currentlyUsedGuildSalesLotteryMemberCount: " ..tos(currentlyUsedGuildSalesLotteryMemberCount))
        --d(">currentlyUsedGuildSalesLotteryMemberCount: " ..tos(currentlyUsedGuildSalesLotteryMemberCount))
        return currentlyUsedGuildSalesLotteryMemberCount
    else
        --Check the sales data for the guildId
        --[[
            --Each entry looks like this
            --Will only work if the listerner "end" callback has fired, so that the requested data was "all" found!
            FCOGuildLottery.guildSellStats[guildId][uniqueIdentifier][eventTime] = {
                eventId     = Id64ToString(eventId),
                eventTime   = eventTime, --today: format the date and time from timestamp!
                eventTimeFormated = eventTimeFormated, --today: format the date and time from timestamp!
                seller      = param1, --seller
                buyer       = param2, --buyer
                quantity    = param3, --quantity
                itemLink    = param4, --itemLink
                price       = param5, --price
                tax         = param6  --tax
            }
        ]]

        --Is the listener of this guild still working?
        if checkIfPendingSellEventAndResetGuildSalesLottery(guildId) then return end

        df(">got here 1: Listener okay, data should be there")
        if FCOGuildLottery.guildSellStats ~= nil then
            local sellStatsOfGuildId = FCOGuildLottery.guildSellStats[guildId]
            if sellStatsOfGuildId ~= nil then
                uniqueIdentifier = uniqueIdentifier or buildUniqueId(guildId, daysToGetBefore, FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS, FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
                df(">>uniqueIdentifier: " ..tos(uniqueIdentifier) .. ", daysToGetBefore: " ..tos(daysToGetBefore))
                local sellStatsDetailsOfGuildId = sellStatsOfGuildId[tos(uniqueIdentifier)]
                if sellStatsDetailsOfGuildId ~= nil then
                    df(">>>got here 2 - uniqueId data found")
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryData = sellStatsDetailsOfGuildId
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellCounts = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellCounts or {}
                    local currentlyUsedGuildSalesLotteryMemberSellCounts = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellCounts

                    local settings = FCOGuildLottery.settingsVars.settings
                    local cutOffGuildSalesHistoryCurrentDateMidnight = settings.cutOffGuildSalesHistoryCurrentDateMidnight

                    --Count the sells of each different seller name
                    --    local eventTimeFormated = os.date("%c", eventTime)
                    --local eventKey = param1 .. "_" .. eventId .. "_" .. eventTime .. "_"  .. "_" .. eventTimeFormated
                    for eventKey, guildSellData in pairs(sellStatsDetailsOfGuildId) do
                        local eventTime = guildSellData.eventTime
                        --Difference to MM data: MM always includes events after 00:00 of the current day (for the 7,10,30 days ranking)
                        local addEvent = false
                        if cutOffGuildSalesHistoryCurrentDateMidnight == true then
                            if eventTime >= startTime and eventTime <= endTime then
                                addEvent = true
                            end
                        else
                            if eventTime >= startTime then
                                addEvent = true
                            end
                        end
                        if addEvent == true then
                            local memberName = guildSellData.seller
                            if memberName ~= nil and memberName ~= "" then
                                local currentCount = currentlyUsedGuildSalesLotteryMemberSellCounts ~= nil and currentlyUsedGuildSalesLotteryMemberSellCounts[memberName] or nil
                                currentCount = currentCount or 0
                                --New member detected?
                                if currentCount == 0 then
                                    local currentlyUsedGuildSalesLotteryMemberCountLoc = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
                                    FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount = currentlyUsedGuildSalesLotteryMemberCountLoc + 1
                    df(">>>>Adding new member to ranking: " ..tos(memberName))
                                end
                                --Increase the counter for the sells of this member by 1
                                currentlyUsedGuildSalesLotteryMemberSellCounts[memberName] = currentCount + 1

                                --Increase the counter for the sells value (price) of this member by the price of the actual item
                                FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName] = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName] or {
                                    sumPrice = 0,
                                    sumTax   = 0,
                                    sumQuantity = 0,
                                }
                                local actualSellSumDataOfMember = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName]
                                FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName].sumPrice       = actualSellSumDataOfMember.sumPrice    + guildSellData.price
                                FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName].sumTax         = actualSellSumDataOfMember.sumTax      + guildSellData.tax
                                FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums[memberName].sumQuantity    = actualSellSumDataOfMember.sumQuantity + guildSellData.quantity
                            end
                        end
                    end
                    for memberName, sumData in pairs(FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums) do
                        table.insert(FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank, {
                            --rank
                            --memberName
                            --soldSum
                            --taxSum
                            --amountSum
                            rank        = -1,
                            memberName  = memberName,
                            soldSum     = sumData.sumPrice,
                            taxSum      = sumData.sumTax,
                            amountSum   = tos(currentlyUsedGuildSalesLotteryMemberSellCounts[memberName]) .. "/" .. tos(sumData.sumQuantity),
                        })
                    end
                    table.sort(FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank, function(a,b) return a.soldSum > b.soldSum end)
                    --Update the rank in the table data now
                    for rank, tabData in ipairs(FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank) do
                        tabData.rank = rank
                    end
                    countMembersHavingSold = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
                end
            end
        end
    end
    return countMembersHavingSold
end

--Get the count of members who joined the guild in the selected time frame from a given endTime - daysToGetBefore days
function FCOGuildLottery.GetGuildMembersJoinedListMemberCount(guildId, daysToGetBefore, startTime, endTime, uniqueIdentifier)
    if not guildId or not daysToGetBefore then return end
    if daysToGetBefore <= 0 then daysToGetBefore = 1 end
    if not endTime or not startTime then return end

    df( "GetGuildMembersJoinedListMemberCount-guildId: %s, daysToGetBefore: %s, startTime: %s, endTime: %s, uniqueIdentifier: %s", tos(guildId), tos(daysToGetBefore), tos(startTime), tos(endTime), tos(uniqueIdentifier))

    local countMembersHavingJoined                  = 0
    local currentlyUsedGuildSalesLotteryMemberCount = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
    if FCOGuildLottery.currentlyUsedGuildSalesLotteryData ~= nil and currentlyUsedGuildSalesLotteryMemberCount ~= nil and currentlyUsedGuildSalesLotteryMemberCount > 0 then
        df(">currentlyUsedGuildSalesLotteryMemberCount: " ..tos(currentlyUsedGuildSalesLotteryMemberCount))
        --d(">currentlyUsedGuildSalesLotteryMemberCount: " ..tos(currentlyUsedGuildSalesLotteryMemberCount))
        return currentlyUsedGuildSalesLotteryMemberCount
    else
        --Check the sales data for the guildId
        --[[
            --Each entry looks like this
            --Will only work if the listerner "end" callback has fired, so that the requested data was "all" found!
            FCOGuildLottery.guildSellStats[guildId][uniqueIdentifier][eventTime] = {
                eventId     = Id64ToString(eventId),
                eventTime   = eventTime, --today: format the date and time from timestamp!
                eventTimeFormated = eventTimeFormated, --today: format the date and time from timestamp!
                joinerDisplayName               = param1, --joinerDisplayName
                optionalInviterDisplayName      = param2, --optionalInviterDisplayName
            }
        ]]

        --Is the listener of this guild still working?
        if checkIfPendingMemberJoinedEventAndResetGuildMemberJoinedData(guildId) then return end

        --df(">got here 1: Listener okay, data should be there")
        if FCOGuildLottery.guildMembersJoinedStats ~= nil then
            local memberJoinedStatsOfGuildId = FCOGuildLottery.guildMembersJoinedStats[guildId]
            if memberJoinedStatsOfGuildId ~= nil then
                uniqueIdentifier = uniqueIdentifier or buildUniqueId(guildId, daysToGetBefore, FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS, FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)
                --d(">uniqueIdentifier: " ..tos(uniqueIdentifier) .. ", daysToGetBefore: " ..tos(daysToGetBefore))
                local memberJoinedStatsDetailsOfGuildId = memberJoinedStatsOfGuildId[uniqueIdentifier]
                if memberJoinedStatsDetailsOfGuildId ~= nil then
                    --df(">got here 2 - uniqueId data found")
                    FCOGuildLottery.currentlyUsedGuildMembersJoinDateData = memberJoinedStatsDetailsOfGuildId
                    --local currentlyUsedGuildMembersJoinDateMemberSellCounts = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberSellCounts

                    local settings = FCOGuildLottery.settingsVars.settings
                    local cutOffGuildMembersJoinedCurrentDateMidnight = settings.cutOffGuildMembersJoinedCurrentDateMidnight
                    local hideGuildMembersJoinedDateListWhoLeftAlready = settings.hideGuildMembersJoinedDateListWhoLeftAlready

                    --Count the sells of each different seller name
                    --    local eventTimeFormated = os.date("%c", eventTime)
                    --local eventKey = param1 .. "_" .. eventId .. "_" .. eventTime .. "_"  .. "_" .. eventTimeFormated
                    local currentCount = 0
                    for eventKey, guildMemberJoinedData in pairs(memberJoinedStatsDetailsOfGuildId) do
                        local eventTime = guildMemberJoinedData.eventTime
                        --Difference to MM data: MM always includes events after 00:00 of the current day (for the 7,10,30 days ranking)
                        local addEvent = false
                        if cutOffGuildMembersJoinedCurrentDateMidnight == true then
                            if eventTime >= startTime and eventTime <= endTime then
                                addEvent = true
                            end
                        else
                            if eventTime >= startTime then
                                addEvent = true
                            end
                        end
                        if addEvent == true then
                            local memberName = guildMemberJoinedData.joinerDisplayName
                            if memberName ~= nil and memberName ~= "" then
                                local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, memberName)
                                local isStillInGuild = false
                                if guildMemberIndex ~= nil and guildMemberIndex > 0 then
                                    local memberNameStillInGuild = GetGuildMemberInfo(guildId, guildMemberIndex)
                                    if memberNameStillInGuild ~= nil and memberNameStillInGuild ~= "" then
                                        isStillInGuild = true
                                    end
                                end
                                if not hideGuildMembersJoinedDateListWhoLeftAlready or (hideGuildMembersJoinedDateListWhoLeftAlready == true and isStillInGuild == true) then
                                    if currentCount == 0 then
                                        local currentlyUsedGuildMembersJoinDateMemberCountLoc     = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount
                                        FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount = currentlyUsedGuildMembersJoinDateMemberCountLoc + 1
                                    end

                                    table.insert(FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData, {
                                        --rank
                                        --memberName
                                        --optionalInviterDisplayName
                                        _eventTime  = eventTime,
                                        _eventTimeFormated = guildMemberJoinedData.eventTimeFormated,
                                        rank        = -1,
                                        memberIndex = guildMemberIndex,
                                        isStillInGuild = isStillInGuild,
                                        memberName  = memberName,
                                        invitedBy   = guildMemberJoinedData.optionalInviterDisplayName,
                                    })
                                end
                            end
                        end
                    end
                    table.sort(FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData, function(a,b) return a._eventTime < b._eventTime end)
                    --Update the rank in the table data now
                    for rank, tabData in ipairs(FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData) do
                        tabData.rank = rank
                    end
                    countMembersHavingJoined = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount
                end
            end
        end
    end
    return countMembersHavingJoined
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function FCOGuildLottery.GetGuildIndexById(guildId)
    if not guildId then return end
    for guildIndex = 1, GetNumGuilds(), 1 do
        local guildIdToCompare = GetGuildId(guildIndex)
        if guildId == guildIdToCompare then return guildIndex end
    end
    return
end
local GetGuildIndexById = FCOGuildLottery.GetGuildIndexById

function FCOGuildLottery.GetGuildId(guildIndex)
    if not IsGuildIndexValid(guildIndex) then return end
    return getGuildIdAndName(guildIndex)
end

function FCOGuildLottery.GetGuildMemberCount(guildIndex)
    if not IsGuildIndexValid(guildIndex) then return end
    local numMembers = GetGuildInfo(GetGuildId(guildIndex))
    return numMembers
end

function FCOGuildLottery.GetGuildName(guildIndex, noChatOutput, shortChatOutput)
    noChatOutput = noChatOutput or false
    shortChatOutput = shortChatOutput or false
    if not IsGuildIndexValid(guildIndex) then return end
    local guildId, guildName = getGuildIdAndName(guildIndex)
    if not noChatOutput then
        if shortChatOutput == true then
            dfa( GetString(FCOGL_GUILD_NAME_SHORT), tos(guildName))
        else
            dfa( GetString(FCOGL_GUILD_NAME_LONG), tos(guildIndex), tos(guildId), tos(guildName))
        end
    end
    return guildName, guildId
end

function FCOGuildLottery.GetGuildInfo(guildIndex, noChatOutput)
    noChatOutput = noChatOutput or false
    if not IsGuildIndexValid(guildIndex) then return end
    local guildId, guildName = getGuildIdAndName(guildIndex)
    local numMembers, numOnline, leaderName, numInvitees = GetGuildInfo(guildId)
    if not noChatOutput then
        dfa(">>==============================>>")
        dfa(GetString(FCOGL_GUILD_INFO_ROW_1), tos(guildIndex), tos(guildId), tos(guildName))
        dfa(GetString(FCOGL_GUILD_INFO_ROW_2), tos(leaderName), tos(numInvitees))
        dfa(GetString(FCOGL_GUILD_INFO_ROW_3), tos(numMembers), tos(numOnline))
        dfa("<<==============================<<")
    end
    return numMembers, numOnline, leaderName, numInvitees
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Dice functions
--Roll a dice until a new value was rolled, which wasn't rolled before (isn't in table rolledBefore)
local function rollADiceUntilNewValue(diceSides, rolledBefore)
    if not diceSides or diceSides == 0 then return end
    df("rollADiceUntilNewValue - diceSides: %s, rolledBefore: %s", tos(diceSides), tos(rolledBefore ~= nil))
    local validRollFound = false
    local abortCounter = 0
    local diceSide
    while validRollFound == false or abortCounter <= diceSides do
        abortCounter = abortCounter + 1
        --Pop some random numbers to make it really random
        math.random(); math.random(); math.random()
        diceSide = zo_roundToZero(math.random(1, diceSides))
        if rolledBefore == nil or ( rolledBefore ~= nil and not rolledBefore[diceSide]) then
            rolledBefore = rolledBefore or {}
            rolledBefore[diceSide] = true
            --Force end of while loop
            validRollFound = true
            abortCounter = diceSides + 1
        else
            df(">Rolled a duplicate number \'%s\'. Re-rolling directly ...", tos(diceSide))
        end
    end
    return diceSide
end

function FCOGuildLottery.RollTheDiceAndUpdateUIIfShown(sidesOfDice, noChatOutput, diceRollTypeOverride)
    local diceRollData = FCOGuildLottery.RollTheDice(sidesOfDice, noChatOutput, diceRollTypeOverride)
    if diceRollData ~= nil then
        local showUiIfHidden = getSettingsForCurrentlyUsedDiceRollType(diceRollTypeOverride)
        FCOGuildLottery.UI.RefreshWindowLists(showUiIfHidden, nil)
    end
end
local rollTheDiceAndUpdateUIIfShown = FCOGuildLottery.RollTheDiceAndUpdateUIIfShown

--Roll the dice with pre-defined sides of the dice. Do further checks for a guild sales lottery, or other guild related
--rolls.
--Do not check any further if it's only a dice roll.
--Returns a table:
--[[
    diceRollData = {
        --Info about the dice roller
        displayName = @AccountNameOfTheDiceRoller,
        characterId = CharacterIdOfTheDiceRoller,
        --Info about the throw/roll
        timestamp   = timeStampAsTheRollWasDone,
        diceSides   = sidesOfDiceUsed,
        roll        = theRolledRandomDiceValue,
        --Optional (only if guildId was given):
        guildId                            = guildId
        guildIndex                         = guildIndex
        --GuildMemeber who was met with the roll (dice side = memberIndex)
        rolledGuildMemberName              = rolledGuildMemberDisplayName
        rolledGuildMemberStatus            = playerStatus
        rolledGuildMemberSecsSinceLogoff   = secondsSinceLogoff
        soldSum                            = valueOfSoldItemsAsSum
    }
]]
function FCOGuildLottery.RollTheDice(sidesOfDice, noChatOutput, diceRollTypeOverwrite)
    noChatOutput = noChatOutput or false
    sidesOfDice = sidesOfDice or FCOGL_MAX_DICE_SIDES --Number of max guild members, currently 500
    if sidesOfDice <= 0 then sidesOfDice = 1 end

    local now = GetTimeStamp()
    math.randomseed(os.time()) -- random initialize

    local isNormalDiceRoll
    local diceRollType
    local isNormalGuildRoll
    local isGuildSalesLottery
    local isMembersJoinedList
    if diceRollTypeOverwrite ~= nil then
        if diceRollTypeOverwrite == FCOGL_DICE_ROLL_TYPE_GENERIC then
            isNormalDiceRoll = true
            isGuildSalesLottery = false
            isNormalGuildRoll = false
            isMembersJoinedList = false
            diceRollType      = FCOGL_DICE_ROLL_TYPE_GENERIC

        elseif diceRollTypeOverwrite == FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC then
            isNormalDiceRoll = false
            isGuildSalesLottery = false
            isNormalGuildRoll = true
            isMembersJoinedList = false
            diceRollType      = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC

        elseif diceRollTypeOverwrite == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY then
            isNormalDiceRoll = false
            isGuildSalesLottery = true
            isNormalGuildRoll = false
            isMembersJoinedList = false
            diceRollType      = FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY

        elseif diceRollTypeOverwrite == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE then
            isNormalDiceRoll = false
            isGuildSalesLottery = false
            isNormalGuildRoll = false
            isMembersJoinedList = true
            diceRollType      = FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE
        end
    else
        diceRollType        = FCOGuildLottery.currentlyUsedDiceRollType
        --isNormalGuildRoll = (diceRollTypeGuild == FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC) or false
        isGuildSalesLottery = (diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY) or false
        isMembersJoinedList = (diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE) or false
    end

df( "RollTheDice - sidesOfDice: %s, noChatOutput: %s, normalDiceRoll: %s", tos(sidesOfDice), tos(noChatOutput), tos(isNormalDiceRoll))

    --Create random dice value
    local diceSide

    if isGuildSalesLottery == true then
        if FCOGuildLottery.currentlyUsedGuildSalesLotteryRolls ~= nil then
            diceSide = rollADiceUntilNewValue(sidesOfDice, FCOGuildLottery.currentlyUsedGuildSalesLotteryRolls)
            if sidesOfDice == 1 then
                --Reset the table
                FCOGuildLottery.currentlyUsedGuildSalesLotteryRolls = {}
            end
        else
            dfe("> Guild sales lottery previously rolled dice throws were not found! Aborting now...")
            resetCurrentGuildSalesLotteryData()
        end
    elseif isMembersJoinedList == true then
        if FCOGuildLottery.currentlyUsedGuildMembersJoinDateRolls ~= nil then
            diceSide = rollADiceUntilNewValue(sidesOfDice, FCOGuildLottery.currentlyUsedGuildMembersJoinDateRolls)
            if sidesOfDice == 1 then
                --Reset the table
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateRolls = {}
            end
        else
            dfe("> Guild members joined list previously rolled dice throws were not found! Aborting now...")
            resetCurrentGuildMembersJoinDateData()
        end
    else
        --Pop some random numbers to make it really random
        math.random(); math.random(); math.random()
        diceSide = zo_roundToZero(math.random(1, sidesOfDice))
    end

    local guildId = FCOGuildLottery.currentlyUsedDiceRollGuildId
    local rolledGuildMemberDisplayName, memberNote, rankIndex, playerStatus, secsSinceLogoff, guildIndex, soldSum
    if not isNormalDiceRoll and guildId ~= nil then
        --Get the guildMember with the rolled dice value (or if guild sales lottery: from the sales history data -> via LibHistoire / or if guild member joined list: from teh guild roster history joined date data -> via LibHistoire)
        rolledGuildMemberDisplayName, memberNote, rankIndex, playerStatus, secsSinceLogoff, guildIndex, soldSum = FCOGuildLottery.GetRolledGuildMemberInfo(guildId, diceSide, isGuildSalesLottery, isMembersJoinedList)
        if rolledGuildMemberDisplayName == nil then
            dfe( "<ABORT: rolledGuildMemberDisplayName is nil - sidesOfDice: %s, guildId: %s", tos(sidesOfDice), tos(guildId))
            return
        end
        if not isGuildSalesLottery then
            soldSum = nil
        end
    end
    local diceRollData = {
        --Info about the dice roller
        displayName = GetDisplayName(),
        characterId = GetCurrentCharacterId(),
        --Info about the throw/roll
        timestamp   = now,
        diceSides   = sidesOfDice,
        roll        = diceSide,
    }
    if not isNormalDiceRoll and guildId ~= nil then
        --Optional: Info about the guild it was rolled for (if provided)
        diceRollData.guildId                            = guildId
        diceRollData.guildIndex                         = guildIndex
        --GuildMemeber who was met with the roll (dice side = memberIndex)
        diceRollData.rolledGuildMemberName              = rolledGuildMemberDisplayName
        diceRollData.rolledGuildMemberStatus            = playerStatus
        diceRollData.rolledGuildMemberSecsSinceLogoff   = secsSinceLogoff
        soldSum                                         = soldSum
    end
    if not isGuildSalesLottery and not isMembersJoinedList then
        if not isNormalDiceRoll and guildId ~= nil then
            FCOGuildLottery.diceRollGuildsHistory[guildId] = FCOGuildLottery.diceRollGuildsHistory[guildId] or {}
            FCOGuildLottery.diceRollGuildsHistory[guildId][now] = diceRollData
        else
            FCOGuildLottery.diceRollHistory[now] = diceRollData
        end
    end
    if not noChatOutput then
        local diceTypeStr
        --local settings = FCOGuildLottery.settingsVars.settings
        if not isNormalDiceRoll and guildId ~= nil then
            local guildName = GetGuildName(guildId)
            if isGuildSalesLottery == true then
                diceTypeStr = string.format(GetString(FCOGL_DICE_TYPE_STRING_GUILDSALESLOTTERY), guildName)
            elseif isMembersJoinedList == true then
                diceTypeStr = string.format(GetString(FCOGL_DICE_TYPE_STRING_GUILDMEMBERJOINED), guildName)
            else
                diceTypeStr = string.format(GetString(FCOGL_DICE_TYPE_STRING_GUILD), guildName)
            end
        else
            diceTypeStr = GetString(FCOGL_DICE_TYPE_STRING_RANDOM)
        end
        local lastDiceRollChatOutput = string.format(GetString(FCOGL_LASTROLLED_DICE_CHAT_OUTPUT), diceTypeStr, tos(sidesOfDice), tos(diceSide))
        dfa( lastDiceRollChatOutput )

        --Remember the last chat output of the dice rolle for the slash commands /gsllast and /dicelast
        if not isNormalDiceRoll and guildId ~= nil then
            local memberFoundText
            if isGuildSalesLottery == true then
                memberFoundText = string.format(GetString(FCOGL_LASTROLLED_DICE_FOUND_MEMBER_SOLD_CHAT_OUTPUT), tos(rolledGuildMemberDisplayName), tos(diceSide), tos(soldSum))
                lastDiceRollChatOutput = lastDiceRollChatOutput .. "\n" .. memberFoundText
                FCOGuildLottery.currentlyUsedGuildSalesLotteryLastRolledChatOutput = lastDiceRollChatOutput
            elseif isMembersJoinedList == true then
                memberFoundText = string.format(GetString(FCOGL_LASTROLLED_DICE_FOUND_MEMBER_JOINED_CHAT_OUTPUT), tos(rolledGuildMemberDisplayName), tos(diceSide))
                lastDiceRollChatOutput = lastDiceRollChatOutput .. "\n" .. memberFoundText
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateLastRolledChatOutput = lastDiceRollChatOutput
            else
                memberFoundText = string.format(GetString(FCOGL_LASTROLLED_DICE_FOUND_MEMBER_CHAT_OUTPUT), tos(rolledGuildMemberDisplayName))
                lastDiceRollChatOutput = lastDiceRollChatOutput .. "\n" .. memberFoundText
                FCOGuildLottery.lastRolledGuildChatOutput = lastDiceRollChatOutput
            end
            dfa( memberFoundText )
        else
            FCOGuildLottery.lastRolledChatOutput = lastDiceRollChatOutput
        end
    end
    local rolledName = diceRollData.rolledGuildMemberName
    if not isNormalDiceRoll and guildId ~= nil then
        rolledName = diceRollData.rolledGuildMemberName
    else
        rolledName = ""
        guildIndex = nil
    end
    chatOutputRolledDice(diceSide, rolledName, guildIndex)

    --Show the UI now, and expand the dice roll history
    checkIfUIShouldBeShownOrUpdated(diceRollType, false, guildIndex)

    return diceRollData
end

function FCOGuildLottery.RollTheDiceWithDefaultSides(noChatOutput)
    --Is a guildId selected?
    local sidesOfDice = 0
    if FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
        --Get the count of guild members
        sidesOfDice = FCOGuildLottery.GetGuildMemberCount(GetGuildIndexById(FCOGuildLottery.currentlyUsedDiceRollGuildId))
    else
        sidesOfDice = FCOGuildLottery.settingsVars.settings.defaultDiceSides
    end
    df("RollTheDiceWithDefaultSides - sidesOfDice: %s, noChatOutput: %s", tos(sidesOfDice), tos(noChatOutput))
    if sidesOfDice <= 0 then sidesOfDice = FCOGL_DICE_SIDES_DEFAULT end

    rollTheDiceAndUpdateUIIfShown(sidesOfDice, noChatOutput, nil)
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Lottery functions


function FCOGuildLottery.UpdateMaxDiceSides(numDiceSides)
    df("UpdateMaxDiceSides - numDiceSides: %s", tos(numDiceSides))
    if FCOGuildLottery.UI == nil or FCOGuildLottery.UI.window == nil then
        FCOGuildLottery.tempEditBoxNumDiceSides = numDiceSides
        return
    end
    fcoglUIwindow = fcoglUIwindow or FCOGuildLottery.UI.window
    fcoglUIwindowFrame = fcoglUIwindowFrame or FCOGuildLottery.UI.window.frame

    FCOGuildLottery.tempEditBoxNumDiceSides = nil
    if numDiceSides == nil then return end
    FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
    fcoglUIwindowFrame.editBoxDiceSides:SetText(tos(numDiceSides))
end


function FCOGuildLottery.ReloadGuildSalesLotteryRanks()
    df("ReloadGuildSalesLotteryRanks")
    --if not isGuildSalesLotteryActive() then return end
end

local function showAskDialogNow(guildIndex, daysBefore, startingNewList, callbackYes, callbackNo, dialogTextsTable, noStandardYesCallback, diceRollType)
    noStandardYesCallback = noStandardYesCallback or false
    local resetGuildSalesLotteryDialogName = FCOGuildLottery.getDialogName("resetGuildSalesLottery")
    df("dialogName: %s", tos(resetGuildSalesLotteryDialogName) .. ", diceRollType: " ..tos(diceRollType))
    local isGuildSalesLottery = (diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY and true) or false
    local isGuildMemberJoined = (diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE and true) or false

    if resetGuildSalesLotteryDialogName ~= nil and not ZO_Dialogs_IsShowingDialog(resetGuildSalesLotteryDialogName) then
        local defTitleText = ((isGuildSalesLottery and GetString(FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_TITLE)) or (isGuildMemberJoined and GetString(FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE))) or ""
        local defQuestionText = ((isGuildSalesLottery and GetString(FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_QUESTION)) or (isGuildMemberJoined and GetString(FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION))) or ""
        local titleText = (dialogTextsTable ~= nil and dialogTextsTable.title ~= nil and dialogTextsTable.title) or defTitleText
        local questionText = (dialogTextsTable ~= nil and dialogTextsTable.question ~= nil and dialogTextsTable.question) or defQuestionText
        local data = {
            title       = titleText,
            question    = questionText,
            callbackData = {
                yes = function()
                    if not noStandardYesCallback then
                        if isGuildSalesLottery then
                            resetCurrentGuildSalesLotteryData(startingNewList, guildIndex, daysBefore)
                        elseif isGuildMemberJoined then
                            resetCurrentGuildMembersJoinDateData(startingNewList, guildIndex, daysBefore)
                        end
                    end
                    if callbackYes ~= nil and type(callbackYes) == "function" then
                        callbackYes(guildIndex, daysBefore)
                    end
                end,
                no  = function()
                    if callbackNo ~= nil and type(callbackNo) == "function" then
                        callbackNo(guildIndex, daysBefore)
                    end
                end
            },
        }
        ZO_Dialogs_ShowDialog(resetGuildSalesLotteryDialogName, data, nil, nil)
    end
end
FCOGuildLottery.showAskDialogNow = showAskDialogNow

--Reset the stored / last used data and enable a new lottery dice throw, where the popups of guild and timeFrame selection
--are showing up again
function FCOGuildLottery.ResetCurrentGuildSalesLotteryData(noSecurityQuestion, startingNewLottery, guildIndex, daysBefore, callbackYes, callbackNo, dialogTextsTable, forceCallbackYes)
    df("FCOGuildLottery.ResetCurrentGuildSalesLotteryData - noSecurityQuestion: %s, startingNewLottery: %s, guildIndex: %s, daysBefore: %s, guildSalesLotteryIdActive: %s, forceCallbackYes: %s", tos(noSecurityQuestion), tos(startingNewLottery), tos(guildIndex), tos(daysBefore), tos(FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier), tos(forceCallbackYes))
    noSecurityQuestion = noSecurityQuestion or false
    forceCallbackYes = forceCallbackYes or false
    local resetDataNow = false
    local dialogWasShown = false
    --ONLY resetting the data?
    if noSecurityQuestion == true and startingNewLottery == false and guildIndex == nil and daysBefore == nil then
        resetDataNow = true
    else
        if isGuildSalesLotteryActive() then
            if not noSecurityQuestion then
                --Show security question dialog
                --Do you really want to reset... ?
                dialogWasShown = true
                showAskDialogNow(guildIndex, daysBefore, startingNewLottery, callbackYes, callbackNo, dialogTextsTable, false, FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
            else
                resetDataNow = true
            end
        else
            if resetDataNow == false and startingNewLottery == true then
                resetDataNow = true
            end
        end
    end
    if resetDataNow == true then
        df(">resetting data now - startingNewLottery: %s, index: %s, daysBefore: %s", tos(startingNewLottery), tos(guildIndex), tos(daysBefore))
        resetCurrentGuildSalesLotteryData(startingNewLottery, guildIndex, daysBefore)
        if forceCallbackYes == true and not dialogWasShown and callbackYes ~= nil then
            if type(callbackYes) == "function" then
                df(">>callbackYes call!")
                callbackYes(guildIndex, daysBefore)
            end
        end
    end
end

--Reset the stored / last used data and enable a new member dice throw, where the popups of guild and timeFrame selection
--are showing up again
function FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(noSecurityQuestion, startingNewMembersJoinDate, guildIndex, daysBefore, callbackYes, callbackNo, dialogTextsTable, forceCallbackYes)
    df("FCOGuildLottery.ResetCurrentGuildMembersJoinDate - noSecurityQuestion: %s, startingNewMembersJoinDate: %s, guildIndex: %s, daysBefore: %s, guildMemberJoinDateListIdActive: %s, forceCallbackYes: %s", tos(noSecurityQuestion), tos(startingNewMembersJoinDate), tos(guildIndex), tos(daysBefore), tos(FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier), tos(forceCallbackYes))
    noSecurityQuestion = noSecurityQuestion or false
    forceCallbackYes = forceCallbackYes or false
    local resetDataNow = false
    local dialogWasShown = false
    --ONLY resetting the data?
    if noSecurityQuestion == true and startingNewMembersJoinDate == false and guildIndex == nil and daysBefore == nil then
        resetDataNow = true
    else
        if isGuildMembersJoinDateListActive() then
            if not noSecurityQuestion then
                --Show security question dialog
                --Do you really want to reset... ?
                dialogWasShown = true
                showAskDialogNow(guildIndex, daysBefore, startingNewMembersJoinDate, callbackYes, callbackNo, dialogTextsTable, false, FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)
            else
                resetDataNow = true
            end
        else
            if resetDataNow == false and startingNewMembersJoinDate == true then
                resetDataNow = true
            end
        end
    end
    if resetDataNow == true then
        df(">resetting data now - startingNewMembersJoinDate: %s, index: %s, daysBefore: %s", tos(startingNewMembersJoinDate), tos(guildIndex), tos(daysBefore))
        resetCurrentGuildMembersJoinDateData(startingNewMembersJoinDate, guildIndex, daysBefore)
        if forceCallbackYes == true and not dialogWasShown and callbackYes ~= nil then
            if type(callbackYes) == "function" then
                df(">>callbackYes call!")
                callbackYes(guildIndex, daysBefore)
            end
        end
    end
end

--Build the ranks list and get number of members having sold something in the timeframe
function FCOGuildLottery.BuildGuildSalesMemberRank(guildId, daysBefore, startTime, endTime, uniqueIdentifier)
    df( "BuildGuildSalesMemberRank - guildId: %s, endTime: %s, daysBefore: %s, startTime: %s, uniqueId: %s", tos(guildId), os.date("%c", endTime), tos(daysBefore), os.date("%c", startTime) , tos(uniqueIdentifier))
    if guildId == nil or guildId == 0 then return end

    if checkIfPendingSellEventAndResetGuildSalesLottery(guildId) then return end

    local guildSalesMemberCount = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
    if guildSalesMemberCount == nil or guildSalesMemberCount == 0 then
        guildSalesMemberCount = FCOGuildLottery.GetGuildSalesMemberCount(
                guildId,
                daysBefore,
                startTime,
                endTime,
                uniqueIdentifier
        )
    end
    df(">guildSalesMemberCount: " ..tos(guildSalesMemberCount))
    return guildSalesMemberCount
end

--Build the members joined list for the selected timeframe
function FCOGuildLottery.BuildGuildMembersJoinedList(guildId, daysBefore, startTime, endTime, uniqueIdentifier)
    df( "BuildGuildMembersJoinedList - guildId: %s, endTime: %s, daysBefore: %s, startTime: %s, uniqueId: %s", tos(guildId), os.date("%c", endTime), tos(daysBefore), os.date("%c", startTime) , tos(uniqueIdentifier))
    if guildId == nil or guildId == 0 then return end

    if checkIfPendingMemberJoinedEventAndResetGuildMemberJoinedData(guildId) then return end

    local guildMembersJoinedListMemberCount = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount
    if guildMembersJoinedListMemberCount == nil or guildMembersJoinedListMemberCount == 0 then
        guildMembersJoinedListMemberCount = FCOGuildLottery.GetGuildMembersJoinedListMemberCount(
                guildId,
                daysBefore,
                startTime,
                endTime,
                uniqueIdentifier
        )
    end
    df(">guildMembersJoinedListMemberCount: " ..tos(guildMembersJoinedListMemberCount))
    return guildMembersJoinedListMemberCount
end

function FCOGuildLottery.RollTheDiceForMemberJoinedNow(guildId, guildIndex, noChatOutput)
    updateLoadingIconHiddenState(true)

    --Set the dice roll type
    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE
    local rolledData, countJoinedMembers
    if guildId ~= nil and guildId ~= 0 then
        countJoinedMembers = FCOGuildLottery.BuildGuildMembersJoinedList(
                guildId,
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore,
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime,
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime,
                FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
        )
    end
    if countJoinedMembers ~= nil and countJoinedMembers > 0 then
        --Roll the dice with the number of guild sales members rank of that guildId
        rolledData = FCOGuildLottery.RollTheDice(countJoinedMembers, noChatOutput)
        if rolledData ~= nil and rolledData.timestamp ~= nil then
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId] = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId] or {}
            local currentlyUsedGuildMembersJoinDateUniqueIdentifier = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
            local currentlyUsedGuildMembersJoinDateTimestamp = FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier] = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier] or {}
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier][currentlyUsedGuildMembersJoinDateTimestamp] = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier][currentlyUsedGuildMembersJoinDateTimestamp] or {}
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier][currentlyUsedGuildMembersJoinDateTimestamp]["daysBefore"] = FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentlyUsedGuildMembersJoinDateUniqueIdentifier][currentlyUsedGuildMembersJoinDateTimestamp][rolledData.timestamp] = rolledData

            local showUiIfHidden = getSettingsForCurrentlyUsedDiceRollType()
            FCOGuildLottery.UI.RefreshWindowLists(showUiIfHidden, FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE)
            FCOGuildLottery.UpdateMaxDiceSides(countJoinedMembers)
        end
    else
        resetCurrentGuildMembersJoinDateData()
        showGuildEventsNoMemberJoinedMessage(guildId, guildIndex)
    end

end

function FCOGuildLottery.RollTheDiceForGuildSalesLotteryNow(guildId, guildIndex, noChatOutput)
    updateLoadingIconHiddenState(true)

    --Set the dice roll type
    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY

    local rolledData, countMembersAtRank
    if guildId ~= nil and guildId ~= 0 then
        countMembersAtRank = FCOGuildLottery.BuildGuildSalesMemberRank(
                guildId,
                FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore,
                FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime,
                FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime,
                FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
        )
    end
    if countMembersAtRank ~= nil and countMembersAtRank > 0 then
        --Roll the dice with the number of guild sales members rank of that guildId
        rolledData = FCOGuildLottery.RollTheDice(countMembersAtRank, noChatOutput)
        if rolledData ~= nil and rolledData.timestamp ~= nil then
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId] = FCOGuildLottery.diceRollGuildLotteryHistory[guildId] or {}
            local currentlyUsedGuildSalesLotteryUniqueIdentifier = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
            local currentlyUsedGuildSalesLotteryTimestamp = FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier] = FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier] or {}
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier][currentlyUsedGuildSalesLotteryTimestamp] = FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier][currentlyUsedGuildSalesLotteryTimestamp] or {}
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier][currentlyUsedGuildSalesLotteryTimestamp]["daysBefore"] = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentlyUsedGuildSalesLotteryUniqueIdentifier][currentlyUsedGuildSalesLotteryTimestamp][rolledData.timestamp] = rolledData

            local showUiIfHidden = getSettingsForCurrentlyUsedDiceRollType()
            FCOGuildLottery.UI.RefreshWindowLists(showUiIfHidden, FCOGL_LISTTYPE_GUILD_SALES_LOTTERY)
            FCOGuildLottery.UpdateMaxDiceSides(countMembersAtRank)
        end
    else
        resetCurrentGuildSalesLotteryData()
        showGuildEventsNoMemberCountMessage(guildId, guildIndex)
    end
end

--Roll the dice for the Guild Sales Lottery. At first roll show a dialog to ask for the guildId and the timeframe to get
--the sales data for. Following throws of the dice won't ask again until you reset it via the slash command
--/
function FCOGuildLottery.RollTheDiceForGuildSalesLottery(noChatOutput)
    noChatOutput = noChatOutput or false
    df( "RollTheDiceForGuildSalesLottery - noChatOutput: %s", tos(noChatOutput) )
    local guildId
    local guildIndex

    --Was the setting of the daysBefore slider changed /was the slash command used to change the daysBefore?
    --But no reloadui was done after that?
    if FCOGuildLottery.guildLotteryDaysBeforeSliderWasChanged == true then
        FCOGuildLottery.StopGuildSalesLottery(true, true)
        showReloadUIMessage("daysbefore")
        return
    end

    --Build the unique identifier and set the other needed variables
    local isAGuildSalesLotteryActive = isGuildSalesLotteryActive()
    if not isAGuildSalesLotteryActive then
        --Which guildIndex and Id should be used? And how many days backwards?
        -->All chosen via the slash command /gsl /guildsaleshistory or /dicegsl
        guildIndex = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex
        guildId    = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
        if (guildIndex == nil and guildId == nil) or FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore == nil then
            resetCurrentGuildSalesLotteryData(nil, nil, nil)
            return
        end
        if guildId == nil and guildIndex ~= nil then
            guildId = FCOGuildLottery.GetGuildId(guildIndex)
        elseif guildId ~= nil and guildIndex == nil then
            guildIndex = FCOGuildLottery.GetGuildIndexById(guildId)
        end
        if guildIndex == nil or guildId == nil  then
            resetCurrentGuildSalesLotteryData(nil, nil, nil)
            return
        end

        if FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData ~= nil then
            local chosenTimeStampFromDropdownHistoryUI = FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData.timestamp
            FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp = chosenTimeStampFromDropdownHistoryUI
            local chosenDaysBeforeFromDropdownHistoryUI = FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData.daysBefore or FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS
            FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore = chosenDaysBeforeFromDropdownHistoryUI

            FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil
        else
            FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp = GetTimeStamp()
        end
        df(">START: New guild sales lottery initiated at \'%s\' >>>>>>>>>>>>>>>>>>>>", os.date("%c", FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp))

        FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex    = guildIndex
        FCOGuildLottery.currentlyUsedDiceRollGuildId                = guildId
        FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId       = guildId
        FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildName     = GetGuildName(guildId)

        --Show the "Loading..." icon now
        updateLoadingIconHiddenState(false)

        --Update the LibHistoire data of the guild's sell history
        local uniqueIdentifier, timeStart, timeEnd = FCOGuildLottery.PrepareSellStatsOfGuild(guildId, FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore)
        FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime       = timeEnd
        FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime     = timeStart
        if not timeStart or not timeEnd then
            resetCurrentGuildSalesLotteryData()
            --showGuildEventsNoTraderWeekDeterminedMessage(dateStr)
            return
        end

        FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier = uniqueIdentifier

        FCOGuildLottery.currentlyUsedGuildSalesLotteryData             = {}
        FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank   = {}
        FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellCounts = {}
        FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellSums   = {}
        FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount   = 0

        FCOGuildLottery.currentlyUsedGuildSalesLotteryRolls             = {}


        --Get the membersRanking, or build it, and throw a dice then
        --FCOGuildLottery.RollTheDiceForGuildSalesLotteryNow(noChatOutput)
        -->This must be done at the LibHistoire callback as the cached events have been all received!
        ---> See FCOGuildLottery.CollectGuildSellStats() -> event listener for good events -> libHistoireGuildHistoryTraderEventErrorProcessor
    else
        guildId     = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
        guildIndex  = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex
        df(">Use existing guild sales lottery id %s, \'%s\' >>>>>>>>>>>>>>>>>>>>", tos(guildId), os.date("%c", FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp))

        --Get the membersRanking, or build it, and throw a dice then
        FCOGuildLottery.RollTheDiceForGuildSalesLotteryNow(guildId, guildIndex, noChatOutput)
    end
end

--Roll the dice for the Guild members data. At first roll show a dialog to ask for the guildId and the timeframe to get
--the sales data for. Following throws of the dice won't ask again until you reset it via the slash command
--/
function FCOGuildLottery.RollTheDiceForGuildMembersJoinDate(noChatOutput)
    noChatOutput = noChatOutput or false
    df( "RollTheDiceForGuildMembersJoinDate - noChatOutput: %s", tos(noChatOutput) )
    local guildId
    local guildIndex

    --Was the setting of the daysBefore slider changed /was the slash command used to change the daysBefore?
    --But no reloadui was done after that?
    if FCOGuildLottery.guildMembersJoinedDateListDaysBeforeSliderWasChanged == true then
        FCOGuildLottery.StopGuildMembersJoinDateList(true, true, nil, nil, nil, nil)
        showReloadUIMessage("daysbefore")
        return
    end

    --Build the unique identifier and set the other needed variables
    local isAGuildMemberJoinedDateListActive = isGuildMembersJoinDateListActive()
    if not isAGuildMemberJoinedDateListActive then
        --Which guildIndex and Id should be used? And how many days backwards?
        -->All chosen via the slash command /gsl /guildsaleshistory or /dicegsl
        guildIndex = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex
        guildId    = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
        if (guildIndex == nil and guildId == nil) or FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore == nil then
            resetCurrentGuildMembersJoinDateData(nil, nil, nil)
            return
        end
        if guildId == nil and guildIndex ~= nil then
            guildId = FCOGuildLottery.GetGuildId(guildIndex)
        elseif guildId ~= nil and guildIndex == nil then
            guildIndex = FCOGuildLottery.GetGuildIndexById(guildId)
        end
        if guildIndex == nil or guildId == nil  then
            resetCurrentGuildMembersJoinDateData(nil, nil, nil)
            return
        end

        if FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData ~= nil then
            local chosenTimeStampFromDropdownHistoryUI = FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData.timestamp
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp = chosenTimeStampFromDropdownHistoryUI
            local chosenDaysBeforeFromDropdownHistoryUI = FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData.daysBefore or FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore = chosenDaysBeforeFromDropdownHistoryUI

            FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil
        else
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp = GetTimeStamp()
        end
        df(">START: New guild members data initiated at \'%s\' >>>>>>>>>>>>>>>>>>>>", os.date("%c", FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp))

        FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex     = guildIndex
        FCOGuildLottery.currentlyUsedDiceRollGuildId                    = guildId
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId        = guildId
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildName      = GetGuildName(guildId)

        --Show the "Loading..." icon now
        updateLoadingIconHiddenState(false)

        --Update the LibHistoire data of the guild's member history
        local uniqueIdentifier, timeStart, timeEnd = FCOGuildLottery.PrepareMembersStatsOfGuild(guildId, FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore)
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime       = timeEnd
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime     = timeStart
        if not timeStart or not timeEnd then
            resetCurrentGuildMembersJoinDateData()
            return
        end

        FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier = uniqueIdentifier

        FCOGuildLottery.currentlyUsedGuildMembersJoinDateData             = {}
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData = {}
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount   = 0

        FCOGuildLottery.currentlyUsedGuildMembersJoinDateRolls             = {}

        --Get the membersRanking, or build it, and throw a dice then
        --FCOGuildLottery.RollTheDiceForMemberJoinedNow(guildId, guildIndex, noChatOutput)
        -->This must be done at the LibHistoire callback as the cached events have been all received!
        ---> See FCOGuildLottery.CollectGuildMemberStats() -> event listener for good events -> libHistoireGuildHistoryMemberJoinedEventErrorProcessor
    else
        guildId     = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
        guildIndex  = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex
        df(">Use existing guild members data id %s, \'%s\' >>>>>>>>>>>>>>>>>>>>", tos(guildId), os.date("%c", FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp))

        --Get the membersRanking, or build it, and throw a dice then
        FCOGuildLottery.RollTheDiceForMemberJoinedNow(guildId, guildIndex, noChatOutput)
    end
end

function FCOGuildLottery.GetRolledGuildMemberInfo(guildId, diceSide, useGuildSalesHistory, useMembersJoinedListHistory)
df( "GetRolledGuildMemberInfo-guildId: " ..tos(guildId) .. ", diceSide: " .. tos(diceSide) .. ", useGuildSalesHistory: " ..tos(useGuildSalesHistory) .. ", useMembersJoinedListHistory: " ..tos(useMembersJoinedListHistory))
    if not guildId then return end
    local guildIndex = FCOGuildLottery.GetGuildIndexById(guildId)
    if not IsGuildIndexValid(guildIndex) then return end
    useGuildSalesHistory = useGuildSalesHistory or false
    useMembersJoinedListHistory = useMembersJoinedListHistory or false

    local memberName, memberNote, rankIndex, playerStatus, secsSinceLogoff, soldSum
    if not useGuildSalesHistory and not useMembersJoinedListHistory then
        local maxGuildMembers = FCOGuildLottery.GetGuildMemberCount(guildIndex)
        if diceSide > maxGuildMembers then return end
        memberName, memberNote, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, diceSide)
    elseif useGuildSalesHistory == true then
        local guildSalesMemberCount = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberCount
        if guildSalesMemberCount == nil or guildSalesMemberCount == 0 then
            guildSalesMemberCount = FCOGuildLottery.BuildGuildSalesMemberRank(
                    guildId,
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore,
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryStartTime,
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryEndTime,
                    FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
            )
        end
        --Nothing found?
        if guildSalesMemberCount == nil or guildSalesMemberCount == 0 then
            showGuildEventsNoMemberCountMessage(guildId, guildIndex)
            return
        end
        if diceSide ~= FCOGL_DICE_SIDES_NO_CHECK and diceSide > guildSalesMemberCount then return end
        if FCOGuildLottery.currentlyUsedGuildSalesLotteryData ~= nil and FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank ~= nil then
            local rankGuilSellData = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank[diceSide]
            if rankGuilSellData ~= nil then
                local memberRankName  = rankGuilSellData.memberName
                soldSum = rankGuilSellData.soldSum
                local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, memberRankName)
                if guildMemberIndex ~= nil and guildMemberIndex > 0 then
                   memberName, memberNote , rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
                end
            else
                df("<<nothing found :-(")
            end
        else
df("<guild sell rank data missing!")
        end
    elseif useMembersJoinedListHistory == true then
        local guildMembersJoinedDateMemberCount = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberCount
        if guildMembersJoinedDateMemberCount == nil or guildMembersJoinedDateMemberCount == 0 then
            guildMembersJoinedDateMemberCount = FCOGuildLottery.BuildGuildMembersJoinedList(
                    guildId,
                    FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore,
                    FCOGuildLottery.currentlyUsedGuildMembersJoinDateStartTime,
                    FCOGuildLottery.currentlyUsedGuildMembersJoinDateEndTime,
                    FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
            )
        end
        --Nothing found?
        if guildMembersJoinedDateMemberCount == nil or guildMembersJoinedDateMemberCount == 0 then
            showGuildEventsNoMemberJoinedMessage(guildId, guildIndex)
            return
        end
        if diceSide ~= FCOGL_DICE_SIDES_NO_CHECK and diceSide > guildMembersJoinedDateMemberCount then return end
        if FCOGuildLottery.currentlyUsedGuildMembersJoinDateData ~= nil and FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData ~= nil then
            local listGuildMemberJoinedData = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData[diceSide]
            if listGuildMemberJoinedData ~= nil then
                local memberRankName  = listGuildMemberJoinedData.memberName
                local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, memberRankName)
                if guildMemberIndex ~= nil and guildMemberIndex > 0 then
                   memberName, memberNote , rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
                end
               --Did the user leave the guild already again?
                if guildMemberIndex == nil or memberName == nil or memberName == "" then
                    memberName = memberRankName
                end
            else
                df("<<nothing found :-(")
            end
        else
df("<guild members joined data missing!")
        end
    end
df("<<memberName: %s", tos(memberName))
    return memberName, memberNote, rankIndex, playerStatus, secsSinceLogoff, guildIndex, soldSum
end

function FCOGuildLottery.NewGuildSalesLottery(guildIndex, daysBefore)
df("[FCOGuildLottery.NewGuildSalesLottery] - index: %s, daysBefore: %s", tos(guildIndex), tos(daysBefore))
    if FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier ~= nil then return end
    --Set the guildIndex and daysBefore to start a new guild sales lottery with function
    FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex = guildIndex
    FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore = daysBefore
    FCOGuildLottery.RollTheDiceForGuildSalesLottery()
end

function FCOGuildLottery.NewGuildMembersJoinDate(guildIndex, daysBefore)
df("[FCOGuildLottery.NewGuildMembersJoinDate] - index: %s, daysBefore: %s", tos(guildIndex), tos(daysBefore))
    if FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier ~= nil then return end
    --Set the guildIndex and daysBefore to start a new guild members joined list with function
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex = guildIndex
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore = daysBefore
    FCOGuildLottery.RollTheDiceForGuildMembersJoinDate()
end


function FCOGuildLottery.GetGuildSalesLotteryStartDate()
    local daysBefore
    --Check the settings for the startdate timestamp:
    --[[
    local guildLotteryStartDate = FCOGuildLottery.settingsVars.settings.guildLotteryDateStart
    if guildLotteryStartDate ~= nil then
        --Count the days difference between now and this date, and return the days difference value.
        --If below 1, then use 1
        daysBefore = diffInDays(guildLotteryStartDate, GetTimeStamp())
    else
        daysBefore = FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS
    end
    ]]
    daysBefore = FCOGuildLottery.settingsVars.settings.guildLotteryDaysBefore
    daysBefore = daysBefore or  FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS
    return daysBefore
end

function FCOGuildLottery.GetGuildMemberJoinedDateStartDate()
    local daysBefore
    --Check the settings for the startdate timestamp:
    --[[
    local guildLotteryStartDate = FCOGuildLottery.settingsVars.settings.guildLotteryDateStart
    if guildLotteryStartDate ~= nil then
        --Count the days difference between now and this date, and return the days difference value.
        --If below 1, then use 1
        daysBefore = diffInDays(guildLotteryStartDate, GetTimeStamp())
    else
        daysBefore = FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS
    end
    ]]
    daysBefore = FCOGuildLottery.settingsVars.settings.guildMembersDaysBefore
    daysBefore = daysBefore or  FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS
    return daysBefore
end


function FCOGuildLottery.CheckBeforeStartNew(guildIndex, daysBefore, dataWasResetAlready, checkType)
df("[FCOGuildLottery.CheckBeforeStartNew] - index: %s, daysBefore: %s, dataWasResetAlready: %s", tos(guildIndex), tos(daysBefore), tos(dataWasResetAlready))
    if checkType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY then
        --Stop any active guild members joined date list?
        FCOGuildLottery.StopGuildMembersJoinDateList(nil, nil, "StartNewGuildSalesLottery", guildIndex, daysBefore, dataWasResetAlready)

    elseif checkType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE then
        --Stop any active guild lottery?
        FCOGuildLottery.StopGuildSalesLottery(nil, nil, "StartNewGuildMembersJoinDateList", guildIndex, daysBefore, dataWasResetAlready)
    end
end

function FCOGuildLottery.StartNewGuildSalesLottery(guildIndex, daysBefore, dataWasResetAlready)
df("[FCOGuildLottery.StartNewGuildSalesLottery] - index: %s, daysBefore: %s, dataWasResetAlready: %s", tos(guildIndex), tos(daysBefore), tos(dataWasResetAlready))
    if not IsGuildIndexValid(guildIndex) or daysBefore == nil then
        showNewGSLSlashCommandHelp((FCOGuildLottery.noGuildIndex ~= nil and guildIndex == FCOGuildLottery.noGuildIndex) or false, true, nil)
        return
    end
    if checkAndShowNoTraderMessage(guildIndex) == true then
        return
    end

    dataWasResetAlready = dataWasResetAlready or false
    if not dataWasResetAlready then
        --Reset and show dialog asking before, if any guild sales lottery is already active
        FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, true, guildIndex, daysBefore, nil, nil)
    else
        FCOGuildLottery.NewGuildSalesLottery(guildIndex, daysBefore)
    end
end

function FCOGuildLottery.StartNewGuildMembersJoinDateList(guildIndex, daysBefore, dataWasResetAlready)
df("[FCOGuildLottery.StartNewGuildMembersJoinDateList] - index: %s, daysBefore: %s, dataWasResetAlready: %s", tos(guildIndex), tos(daysBefore), tos(dataWasResetAlready))
    if not IsGuildIndexValid(guildIndex) or daysBefore == nil then
        showNewGSLSlashCommandHelp((FCOGuildLottery.noGuildIndex ~= nil and guildIndex == FCOGuildLottery.noGuildIndex) or false, nil, true)
        return
    end

    dataWasResetAlready = dataWasResetAlready or false
    if not dataWasResetAlready then
        --Reset and show dialog asking before, if any guild members join date list is already active
        FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(false, true, guildIndex, daysBefore, nil, nil)
    else
        FCOGuildLottery.NewGuildMembersJoinDate(guildIndex, daysBefore)
    end
end

function FCOGuildLottery.StopGuildSalesLottery(override, forceCallbackYes, callbackFuncToUseForYes, guildIndex, daysBefore, dataWasResetAlready)
    local callbackYes
    guildIndex = guildIndex or FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex
    if callbackFuncToUseForYes ~= nil and FCOGuildLottery[callbackFuncToUseForYes] ~= nil then
        callbackYes = function() return FCOGuildLottery[callbackFuncToUseForYes](guildIndex, daysBefore, dataWasResetAlready) end
    end

    if not isGuildSalesLotteryActive() then
        if callbackYes ~= nil then
            callbackYes()
        end
        return
    end

    if IsGuildIndexValid(guildIndex) then
        if callbackYes == nil then
            callbackYes = function() FCOGuildLottery.UI.resetGuildDropDownToGuild(guildIndex) end
        end
    else
        if callbackYes == nil then
            callbackYes = function() FCOGuildLottery.UI.resetGuildDropDownToNone() end
        end
    end
    local skipAskDialog = false
    if override ~= nil and override == true then
        skipAskDialog = true
    end
    FCOGuildLottery.ResetCurrentGuildSalesLotteryData(skipAskDialog, false, nil, nil,
        callbackYes, nil,
        {title=GetString(FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_TITLE), question=GetString(FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_QUESTION)},
        forceCallbackYes
    )
end

function FCOGuildLottery.StopGuildMembersJoinDateList(override, forceCallbackYes, callbackFuncToUseForYes, guildIndex, daysBefore, dataWasResetAlready)
    local callbackYes
    guildIndex = guildIndex or FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex
    if callbackFuncToUseForYes ~= nil and FCOGuildLottery[callbackFuncToUseForYes] ~= nil then
        callbackYes = function() return FCOGuildLottery[callbackFuncToUseForYes](guildIndex, daysBefore, dataWasResetAlready) end
    end

    if not isGuildMembersJoinDateListActive() then
        if callbackYes ~= nil then
            callbackYes()
        end
        return
    end

    if IsGuildIndexValid(guildIndex) then
        if callbackYes == nil then
            callbackYes = function() FCOGuildLottery.UI.resetGuildDropDownToGuild(guildIndex) end
        end
    else
        if callbackYes == nil then
            callbackYes = function() FCOGuildLottery.UI.resetGuildDropDownToNone() end
        end
    end
    local skipAskDialog = false
    if override ~= nil and override == true then
        skipAskDialog = true
    end
    FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(skipAskDialog, false, nil, nil,
        callbackYes, nil,
        {title=GetString(FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE), question=GetString(FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION)},
        forceCallbackYes
    )
end


function FCOGuildLottery.ResetCurrentGenericGuildDiceThrowData()
    local rememberedDiceRollGuildName = FCOGuildLottery.rememberedCurrentUsedDiceRollGuildName
    FCOGuildLottery.currentlyUsedDiceRollGuildName  = rememberedDiceRollGuildName
    FCOGuildLottery.rememberedCurrentUsedDiceRollGuildName = nil

    local rememberedDiceRollGuildId = FCOGuildLottery.rememberedCurrentUsedDiceRollGuildId
    FCOGuildLottery.currentlyUsedDiceRollGuildId  = rememberedDiceRollGuildId
    FCOGuildLottery.rememberedCurrentUsedDiceRollGuildId = nil

    local rememberedDiceRollType = FCOGuildLottery.rememberedCurrentUsedDiceRollType
    FCOGuildLottery.currentlyUsedDiceRollType       = rememberedDiceRollType
    FCOGuildLottery.rememberedCurrentUsedDiceRollType = nil
df("ResetCurrentGenericGuildDiceThrowData - diceRollType %s, guildId %s", tos(rememberedDiceRollType), tos(rememberedDiceRollGuildId))

    --Update the currently used dice roll type as it could have been reset to "generic" via a slash command
    FCOGuildLottery.UpdateCurrentDiceRollType()
end

function FCOGuildLottery.RememberCurrentGenericGuildDiceThrowData()
    FCOGuildLottery.rememberedCurrentUsedDiceRollGuildName  = FCOGuildLottery.currentlyUsedDiceRollGuildName
    FCOGuildLottery.rememberedCurrentUsedDiceRollGuildId    = FCOGuildLottery.currentlyUsedDiceRollGuildId
    FCOGuildLottery.rememberedCurrentUsedDiceRollType       = FCOGuildLottery.currentlyUsedDiceRollType
df("RememberCurrentGenericGuildDiceThrowData - diceRollType %s, guildId %s", tos(FCOGuildLottery.rememberedCurrentUsedDiceRollType), tos(FCOGuildLottery.rememberedCurrentUsedDiceRollGuildId))
end


function FCOGuildLottery.RollTheDiceNormalForGuildMemberCheck(guildIndex, noChatOutput)
    noChatOutput = noChatOutput or false
df("[FCOGuildLottery.RollTheDiceNormalForGuildMemberCheck] - index: %s, noChatOutput: %s", tos(guildIndex), tos(noChatOutput))
    local function abortFunc()
        FCOGuildLottery.currentlyUsedDiceRollGuildName = nil
        FCOGuildLottery.currentlyUsedDiceRollGuildId = nil
        FCOGuildLottery.currentlyUsedDiceRollType =  FCOGL_DICE_ROLL_TYPE_GENERIC
        return
    end
    --Is currently any guild lottery active? As a normal guild dice roll would interrupt it we need to ask if we want to
    if isGuildSalesLotteryActive() then
        --Show dialog and ask if we really want to! If yes is chosen: Try the dice throw again now, after resetting the current guild lottery
        FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, false, nil, nil, FCOGuildLottery.normalGuildMemeberDiceRollSlashCommand, nil)
        --Abort here now and let the dialog Yes callback function try again, or no do nothing
        return
    end
    --Is any Guildmember jined date list active? As a normal guild dice roll would interrupt it we need to ask if we want to
    if isGuildMembersJoinDateListActive() then
        --Show dialog and ask if we really want to! If yes is chosen: Try the dice throw again now, after resetting the current guild member joined list
        FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(false, false, nil, nil, FCOGuildLottery.normalGuildMemeberDiceRollSlashCommand, nil)
        --Abort here now and let the dialog Yes callback function try again, or no do nothing
        return
    end
    if not IsGuildIndexValid(guildIndex) then
        return abortFunc()
    end
    local diceSidesGuild = FCOGuildLottery.GetGuildMemberCount(guildIndex)
    if not diceSidesGuild or diceSidesGuild == 0 then
        return abortFunc()
    end

    FCOGuildLottery.currentlyUsedDiceRollGuildName, FCOGuildLottery.currentlyUsedDiceRollGuildId = FCOGuildLottery.GetGuildName(guildIndex, noChatOutput, true)
    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC
    return diceSidesGuild
end

function FCOGuildLottery.RollTheDiceCheck(noChatOutput)
    noChatOutput = noChatOutput or false
    df( "------------[ RollTheDiceCheck - noChatOutput: %s ]------------ ", tos(noChatOutput))
    if isGuildSalesLotteryActive() then
        FCOGuildLottery.RollTheDiceForGuildSalesLottery(noChatOutput)
    elseif isGuildMembersJoinDateListActive() then
        FCOGuildLottery.RollTheDiceForGuildMembersJoinDate(noChatOutput)
    else
        FCOGuildLottery.RollTheDiceWithDefaultSides(noChatOutput)
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Slash Command functions
function FCOGuildLottery.parseSlashCommandArguments(args, firstArg)
    --Parse the arguments string
    local options = {}
    --local searchResult = {} --old: searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for param in string.gmatch(args, "([^%s]+)%s*") do
        if (param ~= nil and param ~= "") then
            options[#options+1] = string.lower(param)
        end
    end
    --Should a dice be thrown= Chekc for the 2nd argument ONLY and validate as number
    if firstArg == "/dice" then
        if options[1] ~= nil then
            local intVal = tonumber(options[1])
            if type(intVal) == "number" then
                return intVal
            end
        else
            --Default dice sides = dice sides set in settings
            return FCOGuildLottery.settingsVars.settings.defaultDiceSides
        end

    --------------------------------------------------------------------------------------------------------------------
    --New guild sales lottery
    elseif firstArg == "/newgsl" then
        --guildId
        local guildIndex, daysBefore
        guildIndex = options[1]
        if guildIndex ~= nil then
            local intVal = tonumber(guildIndex)
            if type(intVal) == "number" then
                guildIndex = intVal
                if not IsGuildIndexValid(guildIndex) then
                    guildIndex = nil
                end
            else
                guildIndex = nil
            end
        end
        daysBefore = options[2]
        if guildIndex ~= nil and daysBefore ~= nil then
            local intVal = tonumber(daysBefore)
            if type(intVal) == "number" then
                if intVal > FCOGL_MAX_DAYS_BEFORE then
                    intVal = FCOGL_MAX_DAYS_BEFORE
                elseif intVal <= 0 then
                    intVal = 1
                end
                daysBefore = intVal
            end
        elseif guildIndex ~= nil and daysBefore == nil then
            daysBefore = FCOGuildLottery.GetGuildSalesLotteryStartDate()
        end
        if guildIndex ~= nil and daysBefore ~= nil then
            if daysBeforeLastUsedGuildSalesLottery == nil then
                daysBeforeLastUsedGuildSalesLottery = daysBefore
            else
                if FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore ~= nil then
                    daysBeforeLastUsedGuildSalesLottery = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
                elseif FCOGuildLottery.lastUsedGuildSalesLotteryDaysBefore ~= nil then
                    daysBeforeLastUsedGuildSalesLottery = FCOGuildLottery.lastUsedGuildSalesLotteryDaysBefore
                end
            end
            --todo: 20240424 Still needed with LibHistoire 2.x API?
            --[[
            if daysBeforeLastUsedGuildSalesLottery ~= daysBefore then
                FCOGuildLottery.guildLotteryDaysBeforeSliderWasChanged = true
            end
            ]]
            FCOGuildLottery.settingsVars.settings.guildLotteryDaysBefore = daysBefore
            return guildIndex, daysBefore
        end
        return nil, nil
    --------------------------------------------------------------------------------------------------------------------
    --New guild members joined list
    elseif firstArg == "/newgmj" then
        --guildId
        local guildIndex, daysBefore
        guildIndex = options[1]
        if guildIndex ~= nil then
            local intVal = tonumber(guildIndex)
            if type(intVal) == "number" then
                guildIndex = intVal
                if not IsGuildIndexValid(guildIndex) then
                    guildIndex = nil
                end
            else
                guildIndex = nil
            end
        end
        daysBefore = options[2]
        if guildIndex ~= nil and daysBefore ~= nil then
            local intVal = tonumber(daysBefore)
            if type(intVal) == "number" then
                if intVal > FCOGL_MAX_DAYS_GUILD_MEMBERS_BEFORE then
                    intVal = FCOGL_MAX_DAYS_GUILD_MEMBERS_BEFORE
                elseif intVal <= 0 then
                    intVal = 1
                end
                daysBefore = intVal
            end
        elseif guildIndex ~= nil and daysBefore == nil then
            daysBefore = FCOGuildLottery.GetGuildMemberJoinedDateStartDate()
        end
        if guildIndex ~= nil and daysBefore ~= nil then
            if daysBeforeLastUsedGuildMemberJoinedDateList == nil then
                daysBeforeLastUsedGuildMemberJoinedDateList = daysBefore
            else
                if FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore ~= nil then
                    daysBeforeLastUsedGuildSalesLottery = FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore
                elseif FCOGuildLottery.lastUsedGuildMembersJoinDateDaysBefore ~= nil then
                    daysBeforeLastUsedGuildSalesLottery = FCOGuildLottery.lastUsedGuildMembersJoinDateDaysBefore
                end
            end
            --todo: 20240424 Still needed with LibHistoire 2.x API?
            --[[
            if daysBeforeLastUsedGuildSalesLottery ~= daysBefore then
                FCOGuildLottery.guildMembersJoinedDateListDaysBeforeSliderWasChanged = true
            end
            ]]
            FCOGuildLottery.settingsVars.settings.guildMembersDaysBefore = daysBefore
            return guildIndex, daysBefore
        end
        return nil, nil
    end
end

--Start (if not started yet) or roll a dice for the current guild sales lottery, via slash command
function FCOGuildLottery.GuildSalesLotterySlashCommand(args)
    df( "GuildSalesLotterySlashCommand - args: " ..tos(args))
    if isGuildMembersJoinDateListActive() then return end

    --Is a guild sales lottery active so we can go on with this "dice roll"?
    if not isGuildSalesLotteryActive() then
    df( ">no guild sales lottery active")
        showNewGSLSlashCommandHelp(nil, true, nil)
    else
        --Just roll next guild sales lottery dice
        FCOGuildLottery.RollTheDiceForGuildSalesLottery()
    end
end

--Start (if not started yet) or roll a dice for the current guild member joined list, via slash command
function FCOGuildLottery.GuildMembersJoinedListSlashCommand(args)
    df( "GuildMembersJoinedListSlashCommand - args: " ..tos(args))
    if isGuildSalesLotteryActive() then return end

    --Is a guild sales lottery active so we can go on with this "dice roll"?
    if not isGuildMembersJoinDateListActive() then
    df( ">no members joined list active")
        showNewGSLSlashCommandHelp(nil, nil, true)
    else
        --Just roll next guild sales lottery dice
        FCOGuildLottery.RollTheDiceForGuildMembersJoinDate()
    end
end


--Start a new guild sales lottery, via slash command
function FCOGuildLottery.NewGuildSalesLotterySlashCommand(args)
    --FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, true)
    local guildIndex, daysBefore = FCOGuildLottery.parseSlashCommandArguments(args, "/newgsl")
--d("GuildIndex: " .. guildIndex .. ", daysBefore: " .. daysBefore)
    df( "------------[ NewGuildSalesLotterySlashCommand - guildIndex: %s, daysBefore: %s ]------------ ", tos(guildIndex), tos(daysBefore))
    FCOGuildLottery.StartNewGuildSalesLottery(guildIndex, daysBefore, false)
end

function FCOGuildLottery.NewGuildMembersJoinedListSlashCommand(args)
    --FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(false, true)
    local guildIndex, daysBefore = FCOGuildLottery.parseSlashCommandArguments(args, "/newgmj")
--d("GuildIndex: " .. guildIndex .. ", daysBefore: " .. daysBefore)
    df( "------------[ NewGuildMembersJoinedListSlashCommand - guildIndex: %s, daysBefore: %s ]------------ ", tos(guildIndex), tos(daysBefore))
    FCOGuildLottery.StartNewGuildMembersJoinDateList(guildIndex, daysBefore, false)
end

--Stop the currently active guild sales lottery, via slash command
function FCOGuildLottery.StopGuildSalesLotterySlashCommand()
    FCOGuildLottery.StopGuildSalesLottery(nil, nil, nil, nil, nil, nil)
end

function FCOGuildLottery.StopGuildMembersJoinedListSlashCommand()
    FCOGuildLottery.StopGuildMembersJoinDateList(nil, nil, nil, nil, nil, nil)
end

--Show the last rolled chat output for a guild sales lottery again
function FCOGuildLottery.GuildSalesLotteryLastRolledSlashCommand()
    if FCOGuildLottery.currentlyUsedGuildSalesLotteryLastRolledChatOutput == nil then return end
    dfa( FCOGuildLottery.currentlyUsedGuildSalesLotteryLastRolledChatOutput )
end

--Show the last rolled chat output for a guild members joined list again
function FCOGuildLottery.GuildMembersJoinedListLastRolledSlashCommand()
    if FCOGuildLottery.currentlyUsedGuildMembersJoinDateLastRolledChatOutput == nil then return end
    dfa( FCOGuildLottery.currentlyUsedGuildMembersJoinDateLastRolledChatOutput )
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--History

function FCOGuildLottery.ShowClearCurrentHistoryDialog(questionHistoryName)
    --Show security question dialog
    --Do you really want to reset... ?
    local clearHistoryDialogName = FCOGuildLottery.getDialogName("resetGuildSalesLottery")
    local dialogOKFunc = FCOGuildLottery.UI.ClearCurrentHistory

    if clearHistoryDialogName ~= nil and not ZO_Dialogs_IsShowingDialog(clearHistoryDialogName) then
        local titleText = GetString(FCOGL_CLEAR_HISTORY_DIALOG_TITLE)
        local questionText = string.format(GetString(FCOGL_CLEAR_HISTORY_DIALOG_QUESTION), questionHistoryName)
        local data = {
            title       = titleText,
            question    = questionText,
            callbackData = {
                yes = function()
                    dialogOKFunc()
                end,
                no  = function()
                end
            },
        }
        ZO_Dialogs_ShowDialog(clearHistoryDialogName, data, nil, nil)
    end
end

function FCOGuildLottery.ClearCurrentHistoryCheck()
    local questionHistoryName
    local isEnabled = FCOGuildLottery.UI.UpdateClearCurrentHistoryButton()
df("ClearCurrentHistoryCheck - isEnabled: %s", tos(isEnabled))
    if not isEnabled then return end

    if isGuildSalesLotteryActive() then
        questionHistoryName = GetString(FCOGL_GUILD_SALES_LOTTERY_HISTORY)
    elseif isGuildMembersJoinDateListActive() then
        questionHistoryName = GetString(FCOGL_GUILD_MEMBER_JOINED_LIST_HISTORY)
    else
        if FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
            questionHistoryName = GetString(FCOGL_GUILD_HISTORY)
        else
            questionHistoryName = GetString(FCOGL_HISTORY)
        end
    end
    FCOGuildLottery.ShowClearCurrentHistoryDialog(questionHistoryName)
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Date & time functions
function FCOGuildLottery.getDateTimeFormatted(dateTimeStamp)
    local dateTimeStr = ""
    if dateTimeStamp ~= nil then
        --Format the timestamp to the output version again
        if os and os.date then
            local settings = FCOGuildLottery.settingsVars.settings
            if settings.useCustomDateFormat ~= nil and settings.useCustomDateFormat ~= "" then
                dateTimeStr = os.date(settings.useCustomDateFormat, dateTimeStamp)
            else
                if settings.use24hFormat then
                    dateTimeStr = os.date(GetString(FCOGL_DATTIME_FORMAT_24HOURS), dateTimeStamp)
                else
                    dateTimeStr = os.date(GetString(FCOGL_DATTIME_FORMAT_12HOURS), dateTimeStamp)
                end

            end
        end
    end
    return dateTimeStr
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Character & account functions
local function buildCharacterData(keyIsCharName)
    keyIsCharName = keyIsCharName or false
    local charactersOfAccount
    --Check all the characters of the account
    for i = 1, GetNumCharacters() do
        local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
        local charName = ZO_CachedStrFormat(SI_UNIT_NAME, name)
        if characterId ~= nil and charName ~= "" then
            if charactersOfAccount == nil then charactersOfAccount = {} end
            if keyIsCharName == true then
                charactersOfAccount[charName]   = characterId
            else
                charactersOfAccount[characterId] = charName
            end
        end
    end
    return charactersOfAccount
end

function FCOGuildLottery.GetCharacterName(characterId)
    if FCOGuildLottery.characterData == nil then
        FCOGuildLottery.characterData = buildCharacterData(false)
    end
    if characterId == nil then return end
    local characterName = FCOGuildLottery.characterData[characterId]
    return characterName
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Guild member functions
--[[
function FCOGuildLottery.GetGuildMemberInfo(guildId, memberIndex)
    return GetGuildMemberInfo(guildId, memberIndex)
end
]]



------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Tooltip functions
function FCOGuildLottery.buildTooltip(tooltipText, zoStrFormatReplaceText1, zoStrFormatReplaceText2, zoStrFormatReplaceText3)
    local ttText = ""
    if zoStrFormatReplaceText1 ~= nil then
        if zoStrFormatReplaceText3 ~= nil then
            ttText = zo_strformat(tooltipText, zoStrFormatReplaceText1, zoStrFormatReplaceText2, zoStrFormatReplaceText3)
        elseif zoStrFormatReplaceText2 ~= nil then
            ttText = zo_strformat(tooltipText, zoStrFormatReplaceText1, zoStrFormatReplaceText2)
        else
            ttText = zo_strformat(tooltipText, zoStrFormatReplaceText1)
        end
    else
        ttText = tooltipText
    end
    return ttText
end

function FCOGuildLottery.ShowTooltip(ctrl, tooltipPosition, tooltipText, zoStrFormatReplaceText1, zoStrFormatReplaceTex2, zoStrFormatReplaceText3)
--d("[WL]ShowTooltip - ctrl: " ..tos(ctrl:GetName()) .. ", text: " .. tos(tooltipText))
    if ctrl == nil or (ctrl.IsMouseEnabled and not ctrl:IsMouseEnabled()) or tooltipText == nil or tooltipText == "" then return false end
	local tooltipPositions = {
        [TOP]       = true,
        [RIGHT]     = true,
        [BOTTOM]    = true,
        [LEFT]      = true,
    }
    if not tooltipPositions[tooltipPosition] then
        tooltipPosition = LEFT
	end
	local ttText = FCOGuildLottery.buildTooltip(tooltipText, zoStrFormatReplaceText1, zoStrFormatReplaceTex2, zoStrFormatReplaceText3)
    ZO_Tooltips_ShowTextTooltip(ctrl, tooltipPosition, ttText)
end

function FCOGuildLottery.HideTooltip()
    ZO_Tooltips_HideTextTooltip()
end