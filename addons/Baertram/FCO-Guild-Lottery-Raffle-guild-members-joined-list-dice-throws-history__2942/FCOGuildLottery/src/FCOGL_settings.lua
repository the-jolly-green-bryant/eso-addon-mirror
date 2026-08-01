if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonVars = FCOGuildLottery.addonVars
local addonName = addonVars.addonName
local addonNamePre = "["..addonName.."]"

--Debug messages
local df    = FCOGuildLottery.df
local dfa   = FCOGuildLottery.dfa
local dfe   = FCOGuildLottery.dfe
local dfv   = FCOGuildLottery.dfv
local dfw   = FCOGuildLottery.dfw

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- SETTINGS

--Read the SavedVariables
function FCOGuildLottery.getSettings()
    local svName, svVersion         = addonVars.addonSavedVariablesName, addonVars.addonSavedVarsVersion
    local svSettingsStr             = "Settings"
    local svSettingsAcrossAllStr    = "SettingsForAll"
    local worldName                 = GetWorldName()

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
        --Debug
        debug = false,
        debugToChatToo = false,

        --Server + account wide base setting
        alwaysUseClientLanguage			    = true,
        --Server + account wide settings
        defaultDiceSides = FCOGL_DICE_SIDES_DEFAULT,

        diceRollHistory = {},
        diceRollGuildsHistory = {},
        diceRollGuildLotteryHistory = {},
        diceRollGuildMemberJoinedDateListHistory = {},

        --false: Like MasterMerchant determines the sales from the history -> Until current time.
        --true: cut-off at midnght of the current day
        cutOffGuildSalesHistoryCurrentDateMidnight = false,
        cutOffGuildMembersJoinedCurrentDateMidnight = false,

        autoPreFillChatEditBoxAfterDiceRollOnlyNumber = false,
        autoPreFillChatEditBoxAfterDiceRoll = false,
        preFillChatEditBoxAfterDiceRollTextTemplates = {
            normal = {
                [1] =                                               GetString(FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT)
            },
            guilds = {
                [FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC] =              GetString(FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT),
                [FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY] =        GetString(FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT),
                [FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] =    GetString(FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT)
            },
        },

        --Date & time
        use24hFormat        = false,
        useCustomDateFormat = "",
        guildLotteryDaysBefore = 7,
        guildLotteryDateStart = 0,
        guildLotteryDateStartSet = false,

        guildMembersDaysBefore = 31,
        guildMembersDateStart = 0,
        guildMembersDateStartSet = false,
        hideGuildMembersJoinedDateListWhoLeftAlready = false,

        --UI
        -->Window
        UIwindow = {
            width   = 730,
            height  = 690,
            left    = 300,
            top     = 150,
            sortKeys = {
              [FCOGL_TAB_GUILDSALESLOTTERY] = {
                  [FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] = "name",
                  [FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] = "datetime",
              },
            },
            sortOrder = {
              [FCOGL_TAB_GUILDSALESLOTTERY] = {
                  [FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] = ZO_SORT_ORDER_DOWN,
                  [FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] = ZO_SORT_ORDER_UP,
              },
            },
        },
        UIDiceHistoryWindow = {
            isHidden = true,
        },
        showUIForDiceRollTypes = {
          [FCOGL_DICE_ROLL_TYPE_GENERIC]                = false,
          [FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC]          = false,
          [FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY]    = false,
          [FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] = false,
        },

    }
    FCOGuildLottery.settingsVars.defaults = defaults

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOGuildLottery.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svName, 999, svSettingsAcrossAllStr, defaultsSettings, worldName, nil)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCOGuildLottery.settingsVars.defaultSettings.saveMode == 1) then
        FCOGuildLottery.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svName, svVersion , svSettingsStr, defaults, worldName, nil )
    else
        FCOGuildLottery.settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, svSettingsStr, defaults, worldName, nil )
    end
    --=============================================================================================================

    --Connect local variables with the SV
    FCOGuildLottery.diceRollHistory             = FCOGuildLottery.settingsVars.settings.diceRollHistory
    FCOGuildLottery.diceRollGuildsHistory       = FCOGuildLottery.settingsVars.settings.diceRollGuildsHistory
    FCOGuildLottery.diceRollGuildLotteryHistory = FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory
    FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory = FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory

    --For the moment do not check if any date was manually chosen! Just use -7 days
    --if FCOGuildLottery.settingsVars.settings.guildLotteryDateStartSet == false then
        local currentDateTable = os.date("*t", os.time())
        local day = currentDateTable.day - 7
        local currentDateMinusSevenDayTimeStamp = os.time({year=currentDateTable.year, month=currentDateTable.month, day=day, hour=0, minute=0, seconds=0})
        FCOGuildLottery.settingsVars.settings.guildLotteryDateStart = currentDateMinusSevenDayTimeStamp
    --end

    --[[
    if GetDisplayName() == "@Baertram" then
        FCOGuildLottery.settingsVars.settings.debug = true
    end
    ]]
end