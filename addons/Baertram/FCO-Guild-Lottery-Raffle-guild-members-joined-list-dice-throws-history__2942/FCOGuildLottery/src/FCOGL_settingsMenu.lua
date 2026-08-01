if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonVars = FCOGuildLottery.addonVars
local addonName = addonVars.addonName
local addonNamePre = "["..addonName.."]"

local tos = tostring
local strgma =  string.gmatch
local strfor = string.format
local tins = table.insert

--Debug messages
local df    = FCOGuildLottery.df
local dfa   = FCOGuildLottery.dfa
local dfe   = FCOGuildLottery.dfe
local dfv   = FCOGuildLottery.dfv
local dfw   = FCOGuildLottery.dfw

local savedVarsCleanDelimiter = "-|-"

local buildUniqueId = FCOGuildLottery.BuildUniqueId
local formatDate = FCOGuildLottery.FormatDate

------------------------------------------------------------------------------------------------------------------------
--LibAddonMenu-2.0 SETTINGS MENU
local guildSalesLotterySavedDaysBeforeChoices
local guildSalesLotterySavedDaysBeforeChoicesValues
local guildSalesLotteryChosenSavedDaysBefore
local guildMemberJoinedDateListSavedDaysBeforeChoices
local guildMemberJoinedDateListSavedDaysBeforeChoicesValues
local guildMemberJoinedDateListChosenSavedDaysBefore


local function splitStr(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in strgma(inputstr, "([^"..sep.."]+)") do
      tins(t, str)
   end
   return t
end

local function splitDropdownChoiceValueAtDelimiter(dropdownChoiceValue)
    if dropdownChoiceValue == nil or dropdownChoiceValue == "" then return nil, nil, nil end
    local t = splitStr(dropdownChoiceValue, savedVarsCleanDelimiter)
    return t[1], t[2], t[3]
end

local function getDataOfSelectedDropdownEntry(dropdownChoiceValue)
    --tos(guildId) .. savedVarsCleanDelimiter .. tos(uniqueIdentifier) .. savedVarsCleanDelimiter .. tos(timeStampOfRoll)
    local guildId, uniqueIdentifier, timeStamp = splitDropdownChoiceValueAtDelimiter(dropdownChoiceValue)
--d("guildId: " ..tos(guildId) .. ", uniqueId: " ..tos(uniqueIdentifier) .. ", timeStamp: " ..tos(timeStamp))
    return tonumber(guildId), uniqueIdentifier, tonumber(timeStamp)
end

local function buildDropdownEntries(diceRollType)
    if diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY then
        guildSalesLotterySavedDaysBeforeChoices = {}
        guildSalesLotterySavedDaysBeforeChoicesValues = {}
        guildSalesLotteryChosenSavedDaysBefore = "0"

        tins(guildSalesLotterySavedDaysBeforeChoices, 1, GetString(FCOGL_LAM_NONE))
        tins(guildSalesLotterySavedDaysBeforeChoicesValues, 1, "0")

        --Read the current SavedVariables for the guild sales lottery
        for guildId, daysBeforeTab in pairs(FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory) do
            if guildId ~= nil and type(guildId) == "number" then
                local guildName = GetGuildName(guildId)

                for uniqueIdEntry, daysBeforeData in pairs(daysBeforeTab) do
                    for timeStampsOfDaysBefore, timeStampsTable in pairs(daysBeforeData) do
                        local daysBeforeDetected = timeStampsTable["daysBefore"]
                        if daysBeforeDetected ~= nil then
                            local uniqueIdentifier = buildUniqueId(guildId, daysBeforeDetected, nil, FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
                            if uniqueIdentifier ~= nil and uniqueIdentifier == uniqueIdEntry then
                                local numEntries = NonContiguousCount(timeStampsTable) - 1 -- subtract 1 because of the "daysBefore" entry
                                --for timeStampOfRoll, rollDataOfTimeStamp in pairs(timeStampsTable) do
                                    --if timeStampOfRoll ~= "daysBefore" then
                                        local timeStr = formatDate(timeStampsOfDaysBefore)
                                        --local guildSalesLotterySavedDaysBeforeChoiceEntry = strfor("[%s(%s)]%s (%s)", tos(guildName), tos(guildId), tos(timeStr), tos(timeStampOfRoll))
                                        local guildSalesLotterySavedDaysBeforeChoiceEntry = strfor("[%s]%s: %s (#%s)", tos(guildName), tos(daysBeforeDetected), tos(timeStr), tos(numEntries))
                                        tins(guildSalesLotterySavedDaysBeforeChoices, guildSalesLotterySavedDaysBeforeChoiceEntry)
                                        tins(guildSalesLotterySavedDaysBeforeChoicesValues, tos(guildId) .. savedVarsCleanDelimiter .. tos(uniqueIdentifier) .. savedVarsCleanDelimiter .. tos(timeStampsOfDaysBefore))
                                    --end
                                --end
                            end
                        end
                    end
                end
            end
        end

    elseif diceRollType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE then
        guildMemberJoinedDateListSavedDaysBeforeChoices = {}
        guildMemberJoinedDateListSavedDaysBeforeChoicesValues = {}
        guildMemberJoinedDateListChosenSavedDaysBefore = "0"

        tins(guildMemberJoinedDateListSavedDaysBeforeChoices, 1, GetString(FCOGL_LAM_NONE))
        tins(guildMemberJoinedDateListSavedDaysBeforeChoicesValues, 1, "0")

        --Read the current SavedVariables for the guild members joined date list
        for guildId, daysBeforeTab in pairs(FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory) do
            if guildId ~= nil and type(guildId) == "number" and daysBeforeTab ~= nil then
                local guildName = GetGuildName(guildId)

                for uniqueIdEntry, daysBeforeData in pairs(daysBeforeTab) do
                    for timeStampsOfDaysBefore, timeStampsTable in pairs(daysBeforeData) do
                        local daysBeforeDetected = timeStampsTable["daysBefore"]
                        if daysBeforeDetected ~= nil then
                            local uniqueIdentifier = buildUniqueId(guildId, daysBeforeDetected, nil, FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)
                            if uniqueIdentifier ~= nil and uniqueIdentifier == uniqueIdEntry then
                                local numEntries = NonContiguousCount(timeStampsTable) - 1 -- subtract 1 because of the "daysBefore" entry
                                --for timeStampOfRoll, rollDataOfTimeStamp in pairs(timeStampsTable) do
                                    --if timeStampOfRoll ~= "daysBefore" then
                                        local timeStr = formatDate(timeStampsOfDaysBefore)
                                        --local guildMemberJoinedDateListSavedDaysBeforeChoiceEntry = strfor("[%s(%s)]%s (%s)", tos(guildName), tos(guildId), tos(timeStr), tos(timeStampOfRoll))
                                        local guildMemberJoinedDateListSavedDaysBeforeChoiceEntry = strfor("[%s]%s: %s (#%s)", tos(guildName), tos(daysBeforeDetected), tos(timeStr), tos(numEntries))
                                        tins(guildMemberJoinedDateListSavedDaysBeforeChoices, guildMemberJoinedDateListSavedDaysBeforeChoiceEntry)
                                        tins(guildMemberJoinedDateListSavedDaysBeforeChoicesValues, tos(guildId) .. savedVarsCleanDelimiter .. tos(uniqueIdentifier) .. savedVarsCleanDelimiter .. tos(timeStampsOfDaysBefore))
                                    --end
                                --end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function deleteChosenSavedGuildSalesLottery()
    if guildSalesLotterySavedDaysBeforeChoices == nil or guildSalesLotterySavedDaysBeforeChoicesValues == nil
            or guildSalesLotteryChosenSavedDaysBefore == nil or guildSalesLotteryChosenSavedDaysBefore == "0" then return end
    d("Delete Guild Sales Lottery - days before: " ..tos(guildSalesLotteryChosenSavedDaysBefore))
    local guildId, uniqueIdentifier, timeStamp = getDataOfSelectedDropdownEntry(guildSalesLotteryChosenSavedDaysBefore)
    if guildId == nil or uniqueIdentifier == nil or timeStamp == nil then
d("<Exit: GuildId or other data missing!")
        guildSalesLotteryChosenSavedDaysBefore = "0"
        return
    end

    if FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId] ~= nil
            and FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][uniqueIdentifier] ~= nil
            and FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][uniqueIdentifier][timeStamp] ~= nil then
--d(">>found SV - set = nil")
        FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][uniqueIdentifier][timeStamp] = nil
        if FCOGuildLottery.diceRollGuildLotteryHistory[guildId] ~= nil and
                FCOGuildLottery.diceRollGuildLotteryHistory[guildId][uniqueIdentifier] ~= nil and
                FCOGuildLottery.diceRollGuildLotteryHistory[guildId][uniqueIdentifier][timeStamp] ~= nil then
--d(">>found internal SV table - set = nil")
            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][uniqueIdentifier][timeStamp] = nil
        end

        buildDropdownEntries(FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
        if FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_SALES_LOTERY ~= nil then
            FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_SALES_LOTERY:UpdateChoices(guildSalesLotterySavedDaysBeforeChoices, guildSalesLotterySavedDaysBeforeChoicesValues)
        end
    end
    guildSalesLotteryChosenSavedDaysBefore = "0"
end

local function deleteChosenSavedGuildMemberJoinedDateList()
    if guildMemberJoinedDateListSavedDaysBeforeChoices == nil or guildMemberJoinedDateListSavedDaysBeforeChoicesValues == nil
        or guildMemberJoinedDateListChosenSavedDaysBefore == nil or guildMemberJoinedDateListChosenSavedDaysBefore == "0" then return end
d("Delete Guild Members Joined Date List - days before: " ..tos(guildMemberJoinedDateListChosenSavedDaysBefore))
    local guildId, uniqueIdentifier, timeStamp = getDataOfSelectedDropdownEntry(guildMemberJoinedDateListChosenSavedDaysBefore)
    if guildId == nil or uniqueIdentifier == nil or timeStamp == nil then
d("<Exit: GuildId or other data missing!")
        guildMemberJoinedDateListChosenSavedDaysBefore = "0"
        return
    end
    if FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId] ~= nil
        and FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier] ~= nil
        and FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier][timeStamp] ~= nil then
        FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier][timeStamp] = nil
        if FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId] ~= nil and
                FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier] ~= nil and
                FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier][timeStamp] ~= nil then
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][uniqueIdentifier][timeStamp] = nil
        end

        buildDropdownEntries(FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)
        if FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_MEMBER_JOINED_DATE_LIST ~= nil then
            FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_MEMBER_JOINED_DATE_LIST:UpdateChoices(guildMemberJoinedDateListSavedDaysBeforeChoices, guildMemberJoinedDateListSavedDaysBeforeChoicesValues)
        end

    end
    guildMemberJoinedDateListChosenSavedDaysBefore = "0"
end

function FCOGuildLottery.ShowLAMSettings()
    if FCOGuildLottery.FCOSettingsPanel == nil then return end
    FCOGuildLottery.LAM:OpenToPanel(FCOGuildLottery.FCOSettingsPanel)
end

local lastGuildLotteryDaysBeforeSliderWasChanged, lastGuildMembersJoinedDateDaysBeforeSliderWasChanged

function FCOGuildLottery.buildAddonMenu()
    local settings = FCOGuildLottery.settingsVars.settings
    if not settings or not FCOGuildLottery.LAM then return false end
    local defaults = FCOGuildLottery.settingsVars.defaults

    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= tos(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/fcogls",
        website             = addonVars.addonWebsite,
        feedback            = addonVars.addonFeedback,
        donation            = addonVars.addonDonation,
    }
    FCOGuildLottery.FCOSettingsPanel = FCOGuildLottery.LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)

    buildDropdownEntries(FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY)
    buildDropdownEntries(FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE)

    local savedVariablesOptions = {
        [1] = GetString(FCOGL_LAM_SAVE_TYPE_PER_CHARACTER),
        [2] = GetString(FCOGL_LAM_SAVE_TYPE_PER_ACCOUNT),
    }
    local savedVariablesOptionsValues = {
        [1] = 1,
        [2] = 2,
    }

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            text = GetString(FCOGL_LAM_DESCRIPTION),
        },
        --==============================================================================
        {
            type = "submenu",
            name = GetString(FCOGL_LAM_HEADER_CHAT_COMMANDS),
            controls = {
                {
                    type = 'description',
                    text = GetString(FCOGL_LAM_CHAT_COMMANDS),
                }
            },
        },
        --==============================================================================
        {
            type = 'dropdown',
            name = GetString(FCOGL_LAM_SAVE_TYPE),
            tooltip = GetString(FCOGL_LAM_SAVE_TYPE_TT),
            choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOGuildLottery.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                FCOGuildLottery.settingsVars.defaultSettings.saveMode = value
            end,
            requiresReload = true,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_FORMAT_OPTIONS),
        },
        {
            type = "checkbox",
            name = GetString(FCOGL_LAM_USE_24h_FORMAT),
            tooltip = GetString(FCOGL_LAM_USE_24h_FORMAT_TT),
            getFunc = function() return settings.use24hFormat end,
            setFunc = function(value)
                settings.use24hFormat = value
            end,
            default = defaults.use24hFormat,
            disabled = function() return settings.useCustomDateFormat ~= "" end
        },
        {
            type = "editbox",
            name = GetString(FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT),
            tooltip = GetString(FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT_TT),
            getFunc = function() return settings.useCustomDateFormat end,
            setFunc = function(value)
                settings.useCustomDateFormat = value
            end,
            default = defaults.useCustomDateFormat,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_DICE_OPTIONS),
        },
        {
            type    = "slider",
            name    = GetString(FCOGL_LAM_DEFAULT_DICE_SIDES),
            tooltip = GetString(FCOGL_LAM_DEFAULT_DICE_SIDES_TT),
            min     = 1,
            max     = FCOGL_MAX_DICE_SIDES,
            step    = 1,
            decimals = 0,
            autoSelect = true,
            getFunc = function() return settings.defaultDiceSides end,
            setFunc = function(value) settings.defaultDiceSides = value   end,
            default = function() return defaults.defaultDiceSides end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL_TT),
            getFunc = function() return settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GENERIC] end,
            setFunc = function(value) settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GENERIC] = value end,
            default = function() return defaults.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GENERIC] end,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_GUILD_ROLL_OPTIONS),
        },
        {
            type    = "editbox",
            name    = GetString(FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT),
            tooltip = GetString(FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function() return settings.preFillChatEditBoxAfterDiceRollTextTemplates.normal[1] end,
            setFunc = function(value) settings.preFillChatEditBoxAfterDiceRollTextTemplates.normal[1] = value end,
            default = function() return defaults.preFillChatEditBoxAfterDiceRollTextTemplates.normal[1] end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL_TT),
            getFunc = function() return settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] end,
            setFunc = function(value) settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] = value end,
            default = function() return defaults.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] end,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_GUILD_LOTTERY_OPTIONS)
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT_TT),
            getFunc = function() return settings.cutOffGuildSalesHistoryCurrentDateMidnight end,
            setFunc = function(value) settings.cutOffGuildSalesHistoryCurrentDateMidnight = value end,
            default = function() return defaults.cutOffGuildSalesHistoryCurrentDateMidnight end,
        },

        {
            type    = "slider",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE_TT),
            min = 1,
            max = FCOGL_MAX_DAYS_BEFORE,
            step = 1,
            getFunc = function()
                if lastGuildLotteryDaysBeforeSliderWasChanged == nil then
                    lastGuildLotteryDaysBeforeSliderWasChanged = settings.guildLotteryDaysBefore
                end
                return settings.guildLotteryDaysBefore
            end,
            setFunc = function(value)
                settings.guildLotteryDaysBefore = value
                if value ~= lastGuildLotteryDaysBeforeSliderWasChanged then
                    lastGuildLotteryDaysBeforeSliderWasChanged = value
                    FCOGuildLottery.guildLotteryDaysBeforeSliderWasChanged = true
                end
            end,
            default = function() return defaults.guildLotteryDaysBefore end,
            requiresReload = true,
        },
--[[
        {
            type = 'datepicker',
            name = GetString(FCOGL_LAM_GUILD_LOTTERY_DATE_FROM),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_DATE_FROM_TT),
            getFunc = function() return settings.guildLotteryDateStart end,
            setFunc = function(dateTimeStampPicked)
                settings.guildLotteryDateStart = dateTimeStampPicked
                settings.guildLotteryDateStartSet = true
            end,
            default = function() return defaults.guildLotteryDateStart end,
            width = "full",
            reference = "FCOGL_DatePickerFrom",
            disabled = function() return false  end
        },
]]
        {
            type    = "editbox",
            name    = GetString(FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function() return settings.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] end,
            setFunc = function(value) settings.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] = value end,
            default = function() return defaults.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL_TT),
            getFunc = function() return settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY] end,
            setFunc = function(value) settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY] = value end,
            default = function() return defaults.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY] end,
        },


        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_OPTIONS)
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT_TT),
            getFunc = function() return settings.cutOffGuildMembersJoinedCurrentDateMidnight end,
            setFunc = function(value) settings.cutOffGuildMembersJoinedCurrentDateMidnight = value end,
            default = function() return defaults.cutOffGuildMembersJoinedCurrentDateMidnight end,
        },

        {
            type    = "slider",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE),
            tooltip = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_DAYS_BEFORE_TT),
            min = 1,
            max = FCOGL_MAX_DAYS_GUILD_MEMBERS_BEFORE,
            step = 1,
            getFunc = function()
                if lastGuildMembersJoinedDateDaysBeforeSliderWasChanged == nil then
                    lastGuildMembersJoinedDateDaysBeforeSliderWasChanged = settings.guildMembersDaysBefore
                end
                return settings.guildMembersDaysBefore
            end,
            setFunc = function(value)
                settings.guildMembersDaysBefore = value
                if value ~= lastGuildMembersJoinedDateDaysBeforeSliderWasChanged then
                    lastGuildMembersJoinedDateDaysBeforeSliderWasChanged = value
                    FCOGuildLottery.guildMembersDaysBeforeSliderWasChanged = true
                end
            end,
            default = function() return defaults.guildMembersDaysBefore end,
            requiresReload = true,
        },
--[[
        {
            type = 'datepicker',
            name = GetString(FCOGL_LAM_GUILD_LOTTERY_DATE_FROM),
            tooltip = GetString(FCOGL_LAM_GUILD_LOTTERY_DATE_FROM_TT),
            getFunc = function() return settings.guildLotteryDateStart end,
            setFunc = function(dateTimeStampPicked)
                settings.guildLotteryDateStart = dateTimeStampPicked
                settings.guildLotteryDateStartSet = true
            end,
            default = function() return defaults.guildLotteryDateStart end,
            width = "full",
            reference = "FCOGL_DatePickerFrom",
            disabled = function() return false  end
        },
]]
        {
            type    = "editbox",
            name    = GetString(FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT),
            tooltip = GetString(FCOGL_LAM_GUILD_MEMBER_JOIN_DATE_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function() return settings.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] end,
            setFunc = function(value) settings.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] = value end,
            default = function() return defaults.preFillChatEditBoxAfterDiceRollTextTemplates.guilds[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL),
            tooltip = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_SHOW_UI_ON_DICE_ROLL_TT),
            getFunc = function() return settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] end,
            setFunc = function(value) settings.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] = value end,
            default = function() return defaults.showUIForDiceRollTypes[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT),
            tooltip = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT_TT),
            getFunc = function() return settings.hideGuildMembersJoinedDateListWhoLeftAlready end,
            setFunc = function(value) settings.hideGuildMembersJoinedDateListWhoLeftAlready = value end,
            default = function() return defaults.hideGuildMembersJoinedDateListWhoLeftAlready end,
        },

        --==============================================================================
        {
            type = 'submenu',
            name = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_OPTIONS),
            controls = {
                {
                    type = 'header',
                    name = GetString(FCOGL_LAM_GUILD_LOTTERY_OPTIONS)
                },
                {
                    type = 'dropdown',
                    name = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE),
                    tooltip = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE_TT),
                    choices = guildSalesLotterySavedDaysBeforeChoices,
                    choicesValues = guildSalesLotterySavedDaysBeforeChoicesValues,
                    getFunc = function()
                        return guildSalesLotteryChosenSavedDaysBefore end,
                    setFunc = function(value)
                        guildSalesLotteryChosenSavedDaysBefore = value
                    end,
                    scrollable = true,
                    sort = "value-up",
                    reference = "FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_SALES_LOTERY"
                },
                {
                    type = 'button',
                    name = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE),
                    tooltip = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE_TT),
                    func = function() deleteChosenSavedGuildSalesLottery() end,
                    disabled = function() return guildSalesLotteryChosenSavedDaysBefore == nil or guildSalesLotteryChosenSavedDaysBefore == "0" end,
                },


                {
                    type = 'header',
                    name = GetString(FCOGL_LAM_GUILD_MEMBERS_JOINED_OPTIONS)
                },
                {
                    type = 'dropdown',
                    name = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE),
                    tooltip = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE_TT),
                    choices = guildMemberJoinedDateListSavedDaysBeforeChoices,
                    choicesValues = guildMemberJoinedDateListSavedDaysBeforeChoicesValues,
                    getFunc = function()
                        return guildMemberJoinedDateListChosenSavedDaysBefore end,
                    setFunc = function(value)
                        guildMemberJoinedDateListChosenSavedDaysBefore = value
                    end,
                    scrollable = true,
                    sort = "value-up",
                    reference = "FCOGL_LAM_DROPDOWN_CLEAR_SAVEDVARIABLES_GUILD_MEMBER_JOINED_DATE_LIST"
                },
                {
                    type = 'button',
                    name = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE),
                    tooltip = GetString(FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE_TT),
                    func = function() deleteChosenSavedGuildMemberJoinedDateList() end,
                    disabled = function() return guildMemberJoinedDateListChosenSavedDaysBefore == nil or guildMemberJoinedDateListChosenSavedDaysBefore == "0" end,
                },


            }
        },


        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOGL_LAM_DEBUG_OPTIONS),
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_DEBUG_OPTIONS),
            tooltip = "Debugging",
            getFunc = function() return settings.debug  end,
            setFunc = function(value) settings.debug = value   end,
            default = function() return defaults.debug  end,
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO),
            tooltip = GetString(FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO_TT),
            getFunc = function() return settings.debugToChatToo  end,
            setFunc = function(value) settings.debugToChatToo = value   end,
            default = function() return defaults.debugToChatToo  end,
            disabled = function() return not settings.debug or not LibDebugLogger or DebugLogViewer end
        }

    } -- optionsTable
    -- END OF OPTIONS TABLE
    --[[
    local lamPanelCreationInitDone = false
    local function LAMControlsCreatedCallbackFunc(pPanel)
        if pPanel ~= FCOGuildLottery.FCOSettingsPanel then return end
        if lamPanelCreationInitDone == true then return end
        --Do stiff here
        lamPanelCreationInitDone = true
    end
    ]]
    --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc)

    FCOGuildLottery.LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end
