if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

FCOGuildLottery.clientLang = GetCVar("language.2")

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.addonVars = {}
local addonVars = FCOGuildLottery.addonVars
addonVars.addonVersion		        = 0.4
addonVars.addonSavedVarsVersion	    = "0.02"                --Attention: Changing this ressts the SV!!!
addonVars.addonName				    = "FCOGuildLottery"
addonVars.addonNameShort		    = "FCOGL"
addonVars.addonNameMenu  		    = "FCO GuildLottery"
addonVars.addonNameMenuDisplay	    = "|c00FF00FCO |cFFFF00 GuildLottery|r"
addonVars.addonSavedVariablesName   = "FCOGuildLottery_Settings"
addonVars.settingsName   		    = "FCO GuildLottery"
addonVars.addonAuthor			    = "Baertram"
addonVars.addonWebsite              = "https://www.esoui.com/downloads/info1542-FCOGuildLottery.html"
addonVars.addonFeedback             = "https://www.esoui.com/portal.php?uid=2028"
addonVars.addonDonation             = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"

local addonName = FCOGuildLottery.addonVars.addonName
local addonNamePre = "["..addonName.."]"
FCOGuildLottery.addonNamePre = addonNamePre

------------------------------------------------------------------------------------------------------------------------
--Dice roll types for guilds, and generic without guilds
FCOGL_DICE_ROLL_TYPE_GENERIC                       = -100
FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC                 = 1
FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY           = 2
FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE       = 3
FCOGuildLottery.currentlyUsedDiceRollType          = FCOGL_DICE_ROLL_TYPE_GENERIC

FCOGL_DICE_SIDES_NO_CHECK                          = -99999 --Do not do any checks against diceSide
FCOGL_DICE_SIDES_DEFAULT                           = 6  --Standard D6/W6 (dice with 6 sides)
FCOGL_MAX_DICE_SIDES                               = 999 --999 as of 2021-01-26
FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS              = 7 -- 1 week
FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS = 31 -- 1 month
FCOGL_MAX_DAYS_BEFORE                              = 100
FCOGL_MAX_DAYS_GUILD_MEMBERS_BEFORE                = 1510


------------------------------------------------------------------------------------------------------------------------
--String constants
FCOGuildLottery.lang                               = {}

FCOGuildLottery.constStr                           = {}
--Changed at 20210214, removed GuildName as the uniqueId will be used inside tables where the unique guildId is already given as a top level filter
--FCOGuildLottery.constStr.guildLotteryLastNDays = "GuildSellsLast%sDays_%s" --1st: days, 2nd: guildName
FCOGuildLottery.constStr[FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY] = "GuildSells_Last%sDays" --1st: days  / old identifier: guildLotteryLastNDays
FCOGuildLottery.constStr[FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE] = "GuildMembers_Last%sDays" --1st: days  / old identifier: guildMembersLastNDays

FCOGuildLottery.noGuildIndex = MAX_GUILDS + 1 -- The index of the first non-guild entry in the guilds dropdown box
------------------------------------------------------------------------------------------------------------------------
--Library variables
--LibHistoire
FCOGuildLottery.libHistoireIsReady = false

--LibHistoire
local lh
local function checkForLibHistoireReady()
    lh = LibHistoire
    FCOGuildLottery.LH = lh
    return lh ~= nil and lh:IsReady()
end
FCOGuildLottery.CheckForLibHistoireReady = checkForLibHistoireReady

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.settingsVars = {}
FCOGuildLottery.settingsVars.defaultSettings = {}
FCOGuildLottery.settingsVars.settings = {}
FCOGuildLottery.settingsVars.defaults = {}

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.playerActivatedDone = false

------------------------------------------------------------------------------------------------------------------------
--FCOGuildLottery.otherAddons = {}

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.guildsData = {}

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.lastRolledChatOutput = nil
FCOGuildLottery.lastRolledGuildChatOutput = nil

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.guildSellListeners          = {} --LibHistoire processors saved, for guild history "trader" category
FCOGuildLottery.guildSellListenerCompleted  = {}
FCOGuildLottery.guildSellStats              = {}

FCOGuildLottery.guildMembersListeners          = {} --LibHistoire processors saved, for guild history "members" category
FCOGuildLottery.guildMembersListenerCompleted  = {}
FCOGuildLottery.guildMembersJoinedStats        = {}

FCOGuildLottery.diceRollHistory             = {}
FCOGuildLottery.diceRollGuildsHistory       = {}
FCOGuildLottery.diceRollGuildLotteryHistory = {}
FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory = {}
------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.defaultGuildSalesLotteryUniqueIdentifiers = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
}
FCOGuildLottery.defaultMembersUniqueIdentifiers = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
}

------------------------------------------------------------------------------------------------------------------------
FCOGuildLottery.dialogs = {}
FCOGuildLottery.dialogs.names = {
    ["resetGuildSalesLottery"] = "Dialog_ResetGuildSalesLottery",
}

------------------------------------------------------------------------------------------------------------------------
--UI
FCOGL_TAB_GUILDSALESLOTTERY = 1

FCOGL_TAB_STATE_LOADING = 1
FCOGL_TAB_STATE_LOADED  = 2

--left list at main TLC
FCOGL_LISTTYPE_NORMAL_THROWS = 1
FCOGL_LISTTYPE_GUILD_MEMBER_THROWS = 2
FCOGL_LISTTYPE_GUILD_SALES_LOTTERY = 3
FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE = 4
--right list with own hidable TLC
FCOGL_LISTTYPE_ROLLED_DICE_HISTORY = 50


FCOGL_SEARCHDROP_PREFIX = "FCOGL_SEARCHDROP"
FCOGL_GUILDSDROP_PREFIX = "FCOGL_GUILDSDROP"
FCOGL_HISTORY_SEARCHDROP_PREFIX = "FCOGL_HISTORY_SEARCHDROP"
FCOGL_GUILDSALESHISTORYDROP_PREFIX = "FCOGL_GUILDSALESHISTORYDROP"
FCOGL_GUILDMEMBERSJOINEDDATEHISTORYDROP_PREFIX = "FCOGL_GUILDMEMBERSJOINEDDATEHISTORYDROP"

FCOGL_SEARCH_TYPE_NAME = 1
FCOGL_SEARCH_TYPE_JOIN_DATE = 2
FCOGL_SEARCH_TYPE_HISTORY_NAME = 1

--FCOGL_SEARCH_TYPE_ITERATION_END = FCOGL_SEARCH_TYPE_JOIN_DATE
FCOGL_SEARCH_TYPE_ITERATION_END = FCOGL_SEARCH_TYPE_NAME
FCOGL_HISTORY_SEARCH_TYPE_ITERATION_END = FCOGL_SEARCH_TYPE_HISTORY_NAME

FCOGuildLottery.UI = {}
FCOGuildLottery.UI.firstCallOfShowUIWindow = true
FCOGuildLottery.UI.window = nil
FCOGuildLottery.UI.diceHistoryWindow = nil
FCOGuildLottery.UI.SCENE_NAME = "FCOGuildLottery_UI_Scene"
FCOGuildLottery.UI.SCROLLLIST_DATATYPE_GUILDSALESRANKING    = 1
FCOGuildLottery.UI.SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY  = 2
FCOGuildLottery.UI.SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST = 3

FCOGuildLottery.Localization = {}
FCOGuildLottery.Localization.Yes = GetString(SI_YES)
FCOGuildLottery.Localization.No = GetString(SI_NO)

--Preventer variables
FCOGuildLottery.prevVars = {
    doNotRunOnTextChanged = false
}

FCOGuildLottery.guildLotteryDaysBeforeSliderWasChanged = false
FCOGuildLottery.guildMembersJoinedDateListDaysBeforeSliderWasChanged = false