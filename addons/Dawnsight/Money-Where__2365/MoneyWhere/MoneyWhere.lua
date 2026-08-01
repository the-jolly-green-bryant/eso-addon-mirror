--[[
	Addon: MoneyWhere
	Author: Dawnsight
	Created by dawnsight@yahoo.com
  
  This addon is designed to track all of the currency the player spends and receives and put it in categories.
  These categories are used to show where the player is spending their currency with an idea of how fast
  The money comes in or goes out.
]]--

---- This is the main file where management occurs
-- A Top level table for storing data
if not MWG then MWG = {} end
 
-- Common items needed.
MWG.name = "MoneyWhere"
MWG.long = "Money, Where Is It?"
MWG.version = "1.91"
MWG.author = "Dawnsight"

local MoneyWhere = {}
MWG.MoneyWhere = MoneyWhere


-- ***************************************
-- Groups for categories; these are global constants
MW_TOTALS = 1
MW_BANK = 2
MW_LOOT = 3
MW_REWARD = 4
MW_ACTIVITY = 5
MW_PVP_REWARD = 6
MW_VENDOR = 7
MW_TRADE_HOUSE = 8
MW_COSTS = 9
MW_JUSTICE = 10
MW_MAIL = 11
MW_OTHER = 12

MW_EXTOTALS = 1
MW_EXDISCOVERY = 2
MW_EXKILL = 3
MW_EXREWARD = 4
MW_EXACTIVITY = 5
MW_EXPVP = 6
MW_EXSKILLBOOK = 7
MW_EXTRADESKILL = 8
MW_EXACHIEVEMENT = 9
MW_EXJUSTICE = 10
MW_EXBOOK = 11
MW_EXOTHER = 12

MW_CURRENCY_GOLD = 1
MW_CURRENCY_ALLIANCEPOINTS = 2
MW_CURRENCY_TELVAR = 3
MW_EXPERIENCE = 4

MW_TRANSACTION_INCOME = 1
MW_TRANSACTION_EXPENSE = 2
MW_TRANSACTION_NET = 3

MW_DEFAULT_X_POS = 250
MW_DEFAULT_Y_POS = 250
MW_DEFAULT_WIDTH = 1350
MW_DEFAULT_HEIGHT = 410

MW_OFFSET_EXPERIENCE = 90

MW_ONE_MINUTE = 60000 -- 60 thousand milliseconds
MW_RATE_RUNNING_QUEUE_POSITION = 11

-- ***************************************
MoneyWhere.AmountChange = 0 -- This calculation is used often and everywhere
MoneyWhere.ChangeFlag = true
MoneyWhere.DebugFlag = false -- setting to true will print debug messages during processing
MoneyWhere.RateDebugFlag = false -- setting to true will print debug messages during processing



--[[
	GUI layout settings
--]]
MoneyWhere.GROUP_INDENT = 8
MoneyWhere.CURRENCY_INDENT = 29
MoneyWhere.ADDED_INDENT = 4
MoneyWhere.COLUMN_HEIGHT_ADD = 1 --26

-- how wide is each column with status box and group name
MoneyWhere.COLUMN_WIDTH = 96

-- how far indented from left side is first column of group name
MoneyWhere.COLUMN_INDENT = 114
MoneyWhere.WindowProperties = { 
  x = MW_DEFAULT_X_POS,
  y = MW_DEFAULT_Y_POS,
  width = MW_DEFAULT_WIDTH,
  height = MW_DEFAULT_HEIGHT,
}
-- ***************************************
-- String bank
MoneyWhere.GroupStrings = {
  [MW_TOTALS] = GetString(SI_TRADINGHOUSESORTFIELD2),
  [MW_BANK] = GetString(SI_CURRENCYLOCATION1),
  [MW_LOOT] = GetString(SI_WINDOW_TITLE_LOOT),
  [MW_REWARD] = GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_PLURAL),
  [MW_ACTIVITY] = GetString(SI_GUILDMETADATAATTRIBUTE4),
  [MW_PVP_REWARD] = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE2),
  [MW_VENDOR] = GetString(SI_GAMEPAD_VENDOR_CATEGORY_HEADER),
  [MW_TRADE_HOUSE] = GetString(SI_GAMEPAD_GUILD_KIOSK_TRADER_HEADER),
  [MW_COSTS] = GetString(SI_MONEYWHERE_COSTS),
  [MW_JUSTICE] = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE10),
  [MW_MAIL] = GetString(SI_BINDING_NAME_TOGGLE_MAIL),
  [MW_OTHER] = GetString(SI_GAMEPAD_HOUSING_PERMISSIONS_GUILD_OTHER),
} 

MoneyWhere.TypeStrings = {
  [MW_CURRENCY_GOLD] = GetString(SI_GAMEPAD_MAIL_SEND_GOLD_HEADER),
  [MW_CURRENCY_ALLIANCEPOINTS] = GetString(SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS),
  [MW_CURRENCY_TELVAR] = GetString(SI_QUEST_REWARD_TELVAR_STONES_NAME),
  [MW_EXPERIENCE] = GetString(SI_LOOT_HISTORY_EXPERIENCE_GAIN),
}

MoneyWhere.AmountStrings = {
  [MW_TRANSACTION_INCOME] = GetString(SI_MONEYWHERE_TRANSACTION_INCOME),
  [MW_TRANSACTION_EXPENSE] = GetString(SI_MONEYWHERE_TRANSACTION_EXPENSE),
  [MW_TRANSACTION_NET] = GetString(SI_MONEYWHERE_TRANSACTION_NET),
}

MoneyWhere.ExGroupStrings = {
  [MW_EXTOTALS] = GetString(SI_TRADINGHOUSESORTFIELD2),
  [MW_EXDISCOVERY] = GetString(SI_MONEYWHERE_EXDISCOVERY),
  [MW_EXKILL] = GetString(SI_MONEYWHERE_EXKILL),
  [MW_EXREWARD] = GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_PLURAL),
  [MW_EXACTIVITY] = GetString(SI_GUILDMETADATAATTRIBUTE4),
  [MW_EXPVP] = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE2),
  [MW_EXSKILLBOOK] = GetString(SI_MONEYWHERE_EXSKILLBOOK),
  [MW_EXTRADESKILL] = GetString(SI_MONEYWHERE_EXTRADESKILL),
  [MW_EXACHIEVEMENT] = GetString(SI_MONEYWHERE_EXACHIEVEMENT),
  [MW_EXJUSTICE] = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE10),
  [MW_EXBOOK] = GetString(SI_ITEM_SUB_TYPE_BOOK),
  [MW_EXOTHER] = GetString(SI_GAMEPAD_HOUSING_PERMISSIONS_GUILD_OTHER),
} 

-- These tables are faster than nested ifs
-- This table translates the ZOS category into a banking category
MoneyWhere.CurrencyReasonToCategory = {
  [CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_ACHIEVEMENT] = MW_REWARD,
  [CURRENCY_CHANGE_REASON_ACTION] = MW_ACTIVITY,
  [CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD] = MW_REWARD,
  [CURRENCY_CHANGE_REASON_BAGSPACE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_BANK_DEPOSIT] = MW_BANK,
  [CURRENCY_CHANGE_REASON_BANK_FEE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL] = MW_BANK,
  [CURRENCY_CHANGE_REASON_BANKSPACE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_BATTLEGROUND] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_BUYBACK] = MW_VENDOR,
  [CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY] = MW_MAIL,
  [CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_COMMAND] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_CONSUME_POTION] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_CONVERSATION] = MW_REWARD,
  [CURRENCY_CHANGE_REASON_CRAFT] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_CROWN_CRATE_DUPLICATE] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_CROWNS_PURCHASED] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_DEATH] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_DECONSTRUCT] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_DEPRECATED_0] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_DEPRECATED_1] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_DEPRECATED_2] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_FEED_MOUNT] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT] = MW_BANK,
  [CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL] = MW_BANK,
  [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP] = MW_ACTIVITY,
--  [CURRENCY_CHANGE_REASON_GUILD_STANDARD] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_GUILD_TABARD] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_HARVEST_REAGENT] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_ITEM_CONVERTED_TO_GEMS] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_KEEP_REPAIR] = MW_ACTIVITY,
  [CURRENCY_CHANGE_REASON_KEEP_UPGRADE] = MW_ACTIVITY,
  [CURRENCY_CHANGE_REASON_KILL] = MW_LOOT,
  [CURRENCY_CHANGE_REASON_LOOT] = MW_LOOT,
  [CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_LOOT_STOLEN] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_MAIL] = MW_MAIL,
  [CURRENCY_CHANGE_REASON_MEDAL] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_PICKPOCKET] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_PLAYER_INIT] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_PURCHASED_WITH_CROWNS] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_PURCHASED_WITH_ENDEAVOR_SEALS]=MW_OTHER,
  [CURRENCY_CHANGE_REASON_PURCHASED_WITH_GEMS] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER] = MW_PVP_REWARD,
  [CURRENCY_CHANGE_REASON_PVP_RESURRECT] = MW_ACTIVITY,
  [CURRENCY_CHANGE_REASON_QUESTREWARD] = MW_REWARD,
  [CURRENCY_CHANGE_REASON_RECIPE] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_RECONSTRUCTION] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_REFORGE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_RESEARCH_TRAIT] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_RESPEC_CHAMPION] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_RESPEC_MORPHS] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_RESPEC_SKILLS] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_REWARD] = MW_REWARD,
  [CURRENCY_CHANGE_REASON_SELL_STOLEN] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_SOULWEARY]=MW_OTHER,
  [CURRENCY_CHANGE_REASON_SOUL_HEAL] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_SOULWEARY] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_STABLESPACE] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_STUCK] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_TRADE] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING] = MW_TRADE_HOUSE,
  [CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE] = MW_TRADE_HOUSE,
  [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND] = MW_TRADE_HOUSE,
  [CURRENCY_CHANGE_REASON_TRAIT_REVEAL] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD] = MW_COSTS,
  [CURRENCY_CHANGE_REASON_UNKNOWN] = MW_OTHER,
  [CURRENCY_CHANGE_REASON_VENDOR] = MW_VENDOR,
  [CURRENCY_CHANGE_REASON_VENDOR_LAUNDER] = MW_JUSTICE,
  [CURRENCY_CHANGE_REASON_VENDOR_REPAIR] = MW_COSTS,
}

-- This table translates the ZOS category into a experience category
MoneyWhere.ExperienceReasonToCategory = {
  --[[ The first three have a -1 constant value and must be handled specifically
  [PROGRESS_REASON_ITERATION_BEGIN] = MW_EUNKNOWN,
  [PROGRESS_REASON_MIN_VALUE] = MW_EUNKNOWN,
  [PROGRESS_REASON_NONE] = MW_EUNKNOWN,
  --]]
  [PROGRESS_REASON_ACHIEVEMENT] = MW_EXACHIEVEMENT,
  [PROGRESS_REASON_ACTION] = MW_EXACTIVITY,
  [PROGRESS_REASON_ALLIANCE_POINTS] = MW_EXPVP,
  [PROGRESS_REASON_ANTIQUITY_COMPLETED_DIGGING]=MW_EXACTIVITY,
  [PROGRESS_REASON_ANTIQUITY_COMPLETED_SCRYING]=MW_EXACTIVITY,
  [PROGRESS_REASON_AVA] = MW_EXPVP,
  [PROGRESS_REASON_BATTLEGROUND] = MW_EXPVP,
  [PROGRESS_REASON_BOOK_COLLECTION_COMPLETE] = MW_EXBOOK,
  [PROGRESS_REASON_BOSS_KILL] = MW_EXKILL,
  [PROGRESS_REASON_COLLECT_BOOK] = MW_EXBOOK,
  [PROGRESS_REASON_COMMAND] = MW_EOXTHER,
  [PROGRESS_REASON_COMPLETE_POI] = MW_EXACTIVITY,
  [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = MW_EXACTIVITY,
  [PROGRESS_REASON_DARK_FISSURE_CLOSED] = MW_EXACTIVITY,
  [PROGRESS_REASON_DISCOVER_POI] = MW_EXDISCOVERY,
  [PROGRESS_REASON_DRAGON_KILL] = MW_EXKILL,  -- 39
  [PROGRESS_REASON_DUNGEON_CHALLENGE] = MW_EXACHIEVEMENT,
  [PROGRESS_REASON_EVENT] = MW_EXACTIVITY,
  [PROGRESS_REASON_FINESSE] = MW_EXOTHER,
  [PROGRESS_REASON_FISSURE_COMPLETED]=MW_EXACTIVITY,
  [PROGRESS_REASON_GEYSER_COMPLETED]=MW_EXACTIVITY,
  [PROGRESS_REASON_GRANT_REPUTATION] = MW_EXOTHER,
  [PROGRESS_REASON_GUILD_REP] = MW_EXOTHER,
  [PROGRESS_REASON_HARROWSTORM_COMPLETED]=MW_EXACTIVITY,
  [PROGRESS_REASON_JUSTICE_SKILL_EVENT] = MW_EXJUSTICE,
  [PROGRESS_REASON_KEEP_REWARD] = MW_EXPVP,
  [PROGRESS_REASON_KILL] = MW_EXKILL,
  [PROGRESS_REASON_LFG_REWARD] = MW_EXOTHER, 
  [PROGRESS_REASON_LOCK_PICK] = MW_EXJUSTICE,
  [PROGRESS_REASON_MEDAL] = MW_EXPVP,
  [PROGRESS_REASON_NONE]=MW_EXOTHER,
  [PROGRESS_REASON_OBLIVION_PORTAL_COMPLETED]=MW_EXACTIVITY,
  [PROGRESS_REASON_OTHER] = MW_EXOTHER,
  [PROGRESS_REASON_OVERLAND_BOSS_KILL] = MW_EXKILL,
  [PROGRESS_REASON_PVP_EMPEROR] = MW_EXPVP,
  [PROGRESS_REASON_QUEST] = MW_EXREWARD,
  [PROGRESS_REASON_REWARD] = MW_EXREWARD,
  [PROGRESS_REASON_SCRIPTED_EVENT] = MW_EXACTIVITY,
  [PROGRESS_REASON_SKILL_BOOK] = MW_EXSKILLBOOK,
  [PROGRESS_REASON_TRADESKILL] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_ACHIEVEMENT] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_CONSUME] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_HARVEST] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_QUEST] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_RECIPE] = MW_EXTRADESKILL,
  [PROGRESS_REASON_TRADESKILL_TRAIT] = MW_EXTRADESKILL,
  [PROGRESS_REASON_WORLD_EVENT_COMPLETED] = MW_EXKILL, --  This is a kill since world events require killing a dragon or such
  [PROGRESS_REASON_ITERATION_END] = MW_EXOTHER, 
  [PROGRESS_REASON_MAX_VALUE] = MW_EXOTHER, 
}

-- ***************************************
-- Currency Class Group
MoneyWhere.MaxNumberOfGroups = MW_OTHER
MoneyWhere.CurrencyGroup = { }

MoneyWhere.CurrencyGroup.__index = MoneyWhere.CurrencyGroup
function MoneyWhere.CurrencyGroup:new()
  newGroup = {
    [MW_TOTALS] = 0,
    [MW_BANK] = 0,
    [MW_LOOT] = 0,
    [MW_REWARD] = 0,
    [MW_ACTIVITY] = 0,
    [MW_PVP_REWARD] = 0,
    [MW_VENDOR] = 0,
    [MW_TRADE_HOUSE] = 0,
    [MW_COSTS] = 0,
    [MW_JUSTICE] = 0,
    [MW_MAIL] = 0,
    [MW_OTHER] = 0,
  }
    
  setmetatable(newGroup, self)
  self.__index = self
  return newGroup
end

-- Experience Class Group
MoneyWhere.MaxNumberOfGroups = MW_EXOTHER
MoneyWhere.ExperienceGroup = { }

MoneyWhere.ExperienceGroup.__index = MoneyWhere.ExperienceGroup
function MoneyWhere.ExperienceGroup:new()
  newGroup = {
    [MW_EXTOTALS] = 0,
    [MW_EXDISCOVERY] = 0,
    [MW_EXKILL] = 0,
    [MW_EXREWARD] = 0,
    [MW_EXACTIVITY] = 0,
    [MW_EXPVP] = 0,
    [MW_EXSKILLBOOK] = 0,
    [MW_EXTRADESKILL] = 0,
    [MW_EXACHIEVEMENT] = 0,
    [MW_EXJUSTICE] = 0,
    [MW_EXBOOK] = 0,
    [MW_EXOTHER] = 0,
  }
    
setmetatable(newGroup, self)
  self.__index = self
  return newGroup
end

-- ***************************************
-- Table structures for tracking changes. There is an in and out and difference for each currency type
-- Gold
MoneyWhere.GoldGroups = {
  Income = MoneyWhere.CurrencyGroup:new(),
  Expense = MoneyWhere.CurrencyGroup:new(),
  NetCurr = MoneyWhere.CurrencyGroup:new(),
}

-- Alliance Points
MoneyWhere.APointsGroups = {
  Income = MoneyWhere.CurrencyGroup:new(),
  Expense = MoneyWhere.CurrencyGroup:new(),
  NetCurr = MoneyWhere.CurrencyGroup:new(),
}

-- Telvar
MoneyWhere.TelvarGroups = {
  Income = MoneyWhere.CurrencyGroup:new(),
  Expense = MoneyWhere.CurrencyGroup:new(),
  NetCurr = MoneyWhere.CurrencyGroup:new(),
}

-- Experience
MoneyWhere.ExperienceGroup = MoneyWhere.ExperienceGroup:new()

-- ***************************************
-- Timer and rate values
MoneyWhere.MinuteTrackRateFlag = true
MoneyWhere.MinuteCount = 1 -- current queue number
MoneyWhere.MinuteNumber = 1 -- number of minutes that have been collected
MoneyWhere.MinuteQueue = { -- Space 11 is for storing current values
  Gold = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  APoints = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  Telvar = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  Experience = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

MoneyWhere.GoldRate = 0
MoneyWhere.APointsRate = 0
MoneyWhere.TelvarRate = 0
MoneyWhere.ExperienceRate = 0
MoneyWhere.TimerFlag = false
MoneyWhere.RateExControl = nil
MoneyWhere.RateGoldControl = nil
MoneyWhere.RateAPointsControl = nil
MoneyWhere.RateTelvarControl = nil


local panelData = {
    type = "panel",
    name = MWG.name,
    displayName = MWG.name,
    author = "|cFFA500"..MWG.author.."|r",
    version = MWG.version,
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
}

local optionsTable = {
    [1] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_LOAD_LEDGER_ON_INIT),
      tooltip = GetString(SI_MONEYWHERE_LOAD_LEDGER_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.LoadLedgerOnInit end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.LoadLedgerOnInit = value end,
      width = "full",	--or "half" (optional)
      --warning = "Will need to reload the UI.",	--(optional)
    },
    [2] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_TRACK_GOLD),
      tooltip = GetString(SI_MONEYWHERE_TRACK_GOLD_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.TrackGold end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.TrackGold = value end,
      width = "full",	--or "half" (optional)
			requiresReload = true,
      --warning = GetString(SI_MONEYWHERE_NEED_TO_RELOAD_UI),	--(optional)
    },
    [3] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_TRACK_APOINTS),
      tooltip = GetString(SI_MONEYWHERE_TRACK_APOINTS_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.TrackAPoints end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.TrackAPoints = value end,
      width = "full",	--or "half" (optional)
			requiresReload = true,
      --warning = GetString(SI_MONEYWHERE_NEED_TO_RELOAD_UI),	--(optional)
    },
    [4] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_TRACK_TELVAR),
      tooltip = GetString(SI_MONEYWHERE_TRACK_TELVAR_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.TrackTelvar end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.TrackTelvar = value end,
      width = "full",	--or "half" (optional)
			requiresReload = true,
      --warning = GetString(SI_MONEYWHERE_NEED_TO_RELOAD_UI),	--(optional)
    },
    [5] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_TRACK_EXP),
      tooltip = GetString(SI_MONEYWHERE_TRACK_EXP_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.TrackExperience end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.TrackExperience = value end,
      width = "full",	--or "half" (optional)
			requiresReload = true,
      --warning = GetString(SI_MONEYWHERE_NEED_TO_RELOAD_UI),	--(optional)
    },
    [6] = {
      type = "checkbox",
      name = GetString(SI_MONEYWHERE_TRACK_RATE),
      tooltip = GetString(SI_MONEYWHERE_TRACK_RATE_DESCRIP),
      getFunc = function() return MWG.MWSaved.SavedVariables.TrackRate end,
      setFunc = function(value) MWG.MWSaved.SavedVariables.TrackRate = value end,
      width = "full",	--or "half" (optional)
			requiresReload = true,
      --warning = GetString(SI_MONEYWHERE_NEED_TO_RELOAD_UI),	--(optional)
    },
    [7] = {
        type = "slider",
        name = GetString(SI_MONEYWHERE_MINUTES_TRACKED),
        tooltip = GetString(SI_MONEYWHERE_MINUTES_TRACKED_DESCRIP),
        min = 1,
        max = 10,
        step = 1,	--(optional)
        getFunc = function() return MWG.MWSaved.SavedVariables.RateMinutes end,
        setFunc = function(value) MWG.MWSaved.SavedVariables.RateMinutes = value end,
        width = "full",	--or "half" (optional)
        default = 5,	--(optional)
    },
}

-- ***************************************
-- Functions Start here
-- ***************************************
-- Functions for handling currency
-- ***************************************
function MoneyWhere.UpdateBanked()
  -- Get money from bank
  local BGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
  local BAPoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_BANK)
  local BTelvar = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
  
  -- format currency strings
  local BGoldString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_MONEY, BGold, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  local BAPointsString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_ALLIANCE_POINTS, BAPoints, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  local BTelvarString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_TELVAR_STONES, BTelvar, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  
  -- Set window value
  MWWindowMoneyBanked:SetText(zo_strformat("<<1>> <<2>> / <<3>> / <<4>>", ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_BANK_CURRENCY_AMOUNT_BANKED_HEADER)), BGoldString, BAPointsString, BTelvarString))
end

function MoneyWhere.UpdatePockets()
  local PGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
  local PAPoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
  local PTelvar = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
  
  -- format currency strings
  local PGoldString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_MONEY, PGold, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  local PAPointsString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_ALLIANCE_POINTS, PAPoints, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  local PTelvarString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_TELVAR_STONES, PTelvar, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
  
  -- Set window value
  MWWindowMoneyPockets:SetText(zo_strformat("<<1>> <<2>> / <<3>> / <<4>>", ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_BANK_CURRENCY_AMOUNT_CARRIED_HEADER)), PGoldString, PAPointsString, PTelvarString))
end

function MoneyWhere.UpdateExperience()
  local level, xp, xpgoal, needed
  
  if IsUnitChampion("player") then -- CP
    level = GetPlayerChampionPointsEarned()
    xp = GetPlayerChampionXP()
    xpgoal = GetNumChampionXPInChampionPoint(level)
    if MoneyWhere.DebugFlag == true then d(string.format("MW:CP Experience: %d / %d", xp, xpgoal)) end
  else -- Level 1-49
    xp = GetUnitXP("player")
    xpgoal = GetUnitXPMax("player")
    if MoneyWhere.DebugFlag == true then d(string.format("MW:Lvl. Experience: %d / %d", xp, xpgoal)) end
  end
  
  needed = xpgoal - xp
  
  -- Set window value
  MWWindowExperience:SetText(zo_strformat("<<1>>: <<2>> / <<3>>: <<4>> / <<5>>: <<6>>", ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_LOOT_HISTORY_EXPERIENCE_GAIN)), ZO_LocalizeDecimalNumber(xp), ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_GAMEPAD_GUILD_HISTORY_PAGE_NEXT)), ZO_LocalizeDecimalNumber(xpgoal), ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_MONEYWHERE_XP_NEED)), ZO_LocalizeDecimalNumber(needed)))
end

function MoneyWhere.UpdateRates()
  if MWG.MWSaved.SavedVariables.TrackRate == false then return end
  
  MoneyWhere.GoldRate = 0
  MoneyWhere.APointsRate = 0
  MoneyWhere.TelvarRate = 0
  MoneyWhere.ExperienceRate = 0

  -- calculate rate by adding all of the values
  for icnt=1, MoneyWhere.MinuteNumber do -- only go up to MinuteNumber since we might not have a full set of data
    MoneyWhere.GoldRate = MoneyWhere.GoldRate + MoneyWhere.MinuteQueue.Gold[icnt]
    MoneyWhere.APointsRate = MoneyWhere.APointsRate + MoneyWhere.MinuteQueue.APoints[icnt]
    MoneyWhere.TelvarRate = MoneyWhere.TelvarRate + MoneyWhere.MinuteQueue.Telvar[icnt]
    MoneyWhere.ExperienceRate = MoneyWhere.ExperienceRate + MoneyWhere.MinuteQueue.Experience[icnt]
  end
  
  if MWG.MWSaved.SavedVariables.TrackGold == true then
    MoneyWhere.RateGoldControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_MONEY, MoneyWhere.GoldRate, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
  end
  if MWG.MWSaved.SavedVariables.TrackAPoints == true then
    MoneyWhere.RateAPointsControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_ALLIANCE_POINTS, MoneyWhere.APointsRate, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
  end
  if MWG.MWSaved.SavedVariables.TrackTelvar == true then
    MoneyWhere.RateTelvarControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_TELVAR_STONES, MoneyWhere.TelvarRate, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
  end
  if MWG.MWSaved.SavedVariables.TrackExperience == true then
    MoneyWhere.RateExControl:SetText(zo_strformat("<<1>>xp", ZO_LocalizeDecimalNumber(MoneyWhere.ExperienceRate)))
  end
  
  -- Set window value
  MWWindowRateHeader:SetText(ZO_HIGHLIGHT_TEXT:Colorize(string.format(GetString(SI_MONEYWHERE_RATE_FOR_X_MIN), MoneyWhere.MinuteNumber)))
end

-- Function to handle gold both in and out
function MoneyWhere.MWHandleGold(MoneyReason)
  -- First determine the reason and set the index based upon the reason, declare a variable for it
  local indexReason = MoneyWhere.CurrencyReasonToCategory[MoneyReason]
  if MoneyWhere.DebugFlag == true then d(string.format("MW:Gold Rsn(%d) Cat(%d): %d", MoneyReason, indexReason, MoneyWhere.AmountChange)) end

  -- Adjust specific value and total
  if MoneyWhere.AmountChange > 0 then
  -- Received
    MoneyWhere.GoldGroups.Income[indexReason] = MoneyWhere.GoldGroups.Income[indexReason] + MoneyWhere.AmountChange 
  else
    MoneyWhere.GoldGroups.Expense[indexReason] = MoneyWhere.GoldGroups.Expense[indexReason] + MoneyWhere.AmountChange
  end
  
  MoneyWhere.CurrencyChangeFlag = true -- change flag since values are updated
  
  -- add gold to current rate
  MoneyWhere.MinuteQueue.Gold[MW_RATE_RUNNING_QUEUE_POSITION] = MoneyWhere.MinuteQueue.Gold[MW_RATE_RUNNING_QUEUE_POSITION] + MoneyWhere.AmountChange
end
 
 
 -- Function to handle Alliance Points in and out
function MoneyWhere.MWHandleAPoints(MoneyReason)
  -- First determine the reason and set the index based upon the reason, declare a variable for it
  local indexReason = MoneyWhere.CurrencyReasonToCategory[MoneyReason]
  --if indexReason == MW_REWARD then indexReason = MW_PVP_REWARD end -- if Telvar, automatically change to PVP reward
  if MoneyWhere.DebugFlag == true then d(string.format("MW:APoints Rsn(%d) Cat(%d): %d", MoneyReason, indexReason, MoneyWhere.AmountChange)) end
   
 if MoneyWhere.AmountChange > 0 then
  -- Received
    MoneyWhere.APointsGroups.Income[indexReason] = MoneyWhere.APointsGroups.Income[indexReason] + MoneyWhere.AmountChange 
  else
    MoneyWhere.APointsGroups.Expense[indexReason] = MoneyWhere.APointsGroups.Expense[indexReason] + MoneyWhere.AmountChange
  end
  
  MoneyWhere.CurrencyChangeFlag = true -- change flag since values are updated

  -- add gold to current rate
  MoneyWhere.MinuteQueue.APoints[MW_RATE_RUNNING_QUEUE_POSITION] = MoneyWhere.MinuteQueue.APoints[MW_RATE_RUNNING_QUEUE_POSITION] + MoneyWhere.AmountChange

end
 
 
 
 -- Function to handle Telvar stones in and out
function MoneyWhere.MWHandleTelvar(MoneyReason)
    -- First determine the reason and set the index based upon the reason, declare a variable for it
  local indexReason = MoneyWhere.CurrencyReasonToCategory[MoneyReason]
  --if indexReason == MW_REWARD then indexReason = MW_PVP_REWARD end -- if AP, automatically change to PVP reward
  if MoneyWhere.DebugFlag == true then d(string.format("MW:Telvar Rsn(%d) Cat(%d): %d", MoneyReason, indexReason, MoneyWhere.AmountChange)) end
   
   -- Change the in or out depending upon amount and modify total
  if MoneyWhere.AmountChange > 0 then
    -- Received
    MoneyWhere.TelvarGroups.Income[indexReason] = MoneyWhere.TelvarGroups.Income[indexReason] + MoneyWhere.AmountChange 
  else
    MoneyWhere.TelvarGroups.Expense[indexReason] = MoneyWhere.TelvarGroups.Expense[indexReason] + MoneyWhere.AmountChange
  end
  
  MoneyWhere.CurrencyChangeFlag = true -- change flag since values are updated

  -- add gold to current rate
  MoneyWhere.MinuteQueue.Telvar[MW_RATE_RUNNING_QUEUE_POSITION] = MoneyWhere.MinuteQueue.Telvar[MW_RATE_RUNNING_QUEUE_POSITION] + MoneyWhere.AmountChange

end
 
 -- Function to handle Telvar stones in and out
function MoneyWhere.MWHandleExperience(ExperienceReason)
  -- Handle exceptions
  if(ExperienceReason == PROGRESS_REASON_ITERATION_BEGIN) or (ExperienceReason == PROGRESS_REASON_MIN_VALUE) or (ExperienceReason == PROGRESS_REASON_NONE) then
      if MoneyWhere.DebugFlag == true then d(string.format("MW:Experience Reason Bad: %d", ExperienceReason)) end
      return
    end
  
  local indexReason
  
  indexReason = MoneyWhere.ExperienceReasonToCategory[ExperienceReason]
  if MoneyWhere.DebugFlag == true then d(string.format("MW:Exp Rsn(%d) Cat(%d): %d", ExperienceReason, indexReason, MoneyWhere.AmountChange)) end
   
   -- Amount Change should always be positive
  MoneyWhere.ExperienceGroup[indexReason] = MoneyWhere.ExperienceGroup[indexReason] + MoneyWhere.AmountChange 
  
  MoneyWhere.CurrencyChangeFlag = true -- change flag since values are updated

  -- add gold to current rate
  MoneyWhere.MinuteQueue.Experience[MW_RATE_RUNNING_QUEUE_POSITION] = MoneyWhere.MinuteQueue.Experience[MW_RATE_RUNNING_QUEUE_POSITION] + MoneyWhere.AmountChange

end
 
 
function MoneyWhere.MWCalculateTotals()
  
  if MoneyWhere.CurrencyChangeFlag == false then return end -- Don't waste time calculating if nothing has changed
  
  -- running total values
  local InTotal = 0
  local OutTotal = 0
  
  -- Initialze totals to zero
  MoneyWhere.GoldGroups.Income[MW_TOTALS] = 0
  MoneyWhere.GoldGroups.Expense[MW_TOTALS] = 0
  
  MoneyWhere.APointsGroups.Income[MW_TOTALS] = 0
  MoneyWhere.APointsGroups.Expense[MW_TOTALS] = 0
  
  MoneyWhere.TelvarGroups.Income[MW_TOTALS] = 0
  MoneyWhere.TelvarGroups.Expense[MW_TOTALS] = 0
  
  MoneyWhere.ExperienceGroup[MW_EXTOTALS] = 0
  
  -- Loop all table values from end forward
  for icnt = #MoneyWhere.GoldGroups.Income, 2, -1 do
    MoneyWhere.GoldGroups.Income[MW_TOTALS] = MoneyWhere.GoldGroups.Income[MW_TOTALS] + MoneyWhere.GoldGroups.Income[icnt]
    MoneyWhere.GoldGroups.Expense[MW_TOTALS] = MoneyWhere.GoldGroups.Expense[MW_TOTALS] + MoneyWhere.GoldGroups.Expense[icnt]
    MoneyWhere.GoldGroups.NetCurr[icnt] = MoneyWhere.GoldGroups.Income[icnt] + MoneyWhere.GoldGroups.Expense[icnt]
  
    MoneyWhere.APointsGroups.Income[MW_TOTALS] = MoneyWhere.APointsGroups.Income[MW_TOTALS] + MoneyWhere.APointsGroups.Income[icnt]
    MoneyWhere.APointsGroups.Expense[MW_TOTALS] = MoneyWhere.APointsGroups.Expense[MW_TOTALS] + MoneyWhere.APointsGroups.Expense[icnt]
    MoneyWhere.APointsGroups.NetCurr[icnt] = MoneyWhere.APointsGroups.Income[icnt] + MoneyWhere.APointsGroups.Expense[icnt]
  
    MoneyWhere.TelvarGroups.Income[MW_TOTALS] = MoneyWhere.TelvarGroups.Income[MW_TOTALS] + MoneyWhere.TelvarGroups.Income[icnt]
    MoneyWhere.TelvarGroups.Expense[MW_TOTALS] = MoneyWhere.TelvarGroups.Expense[MW_TOTALS] + MoneyWhere.TelvarGroups.Expense[icnt]
    MoneyWhere.TelvarGroups.NetCurr[icnt] = MoneyWhere.TelvarGroups.Income[icnt] + MoneyWhere.TelvarGroups.Expense[icnt]
    
    MoneyWhere.ExperienceGroup[MW_EXTOTALS] = MoneyWhere.ExperienceGroup[MW_EXTOTALS] + MoneyWhere.ExperienceGroup[icnt] -- since experience is same size
  end
  
    -- Get Net Totals
    MoneyWhere.GoldGroups.NetCurr[MW_TOTALS] = MoneyWhere.GoldGroups.Income[MW_TOTALS] + MoneyWhere.GoldGroups.Expense[MW_TOTALS]
    MoneyWhere.APointsGroups.NetCurr[MW_TOTALS] = MoneyWhere.APointsGroups.Income[MW_TOTALS] + MoneyWhere.APointsGroups.Expense[MW_TOTALS]
    MoneyWhere.TelvarGroups.NetCurr[MW_TOTALS] = MoneyWhere.TelvarGroups.Income[MW_TOTALS] + MoneyWhere.TelvarGroups.Expense[MW_TOTALS]
 
  MoneyWhere.UpdateBanked()
  MoneyWhere.UpdatePockets()
  MoneyWhere.UpdateExperience()
  MoneyWhere.UpdateRates()
  MoneyWhere.CurrencyChangeFlag = false -- reset flag since all values are updated
  if MoneyWhere.DebugFlag == true then d("MW:Calculate Totals") end
end

 
function MoneyWhere.TransferCurrency(CurrType, FromGroup, ToGroup, TransferAmount)
  --This will transfer the money and adjust the net totals
  if MoneyWhere.DebugFlag == true then d(string.format("MW:Transfer %s from %s to %s: %d", MoneyWhere.TypeStrings[CurrType], MoneyWhere.GroupStrings[FromGroup], MoneyWhere.GroupStrings[ToGroup], TransferAmount)) end

  if(CurrType == MW_CURRENCY_GOLD) then
    -- transfer
    MoneyWhere.GoldGroups.Income[FromGroup] = MoneyWhere.GoldGroups.Income[FromGroup] - TransferAmount 
    MoneyWhere.GoldGroups.Income[ToGroup] = MoneyWhere.GoldGroups.Income[ToGroup] + TransferAmount 
  elseif(CurrType == MW_CURRENCY_ALLIANCEPOINTS) then
    -- transfer
    MoneyWhere.APointsGroups.Income[FromGroup] = MoneyWhere.APointsGroups.Income[FromGroup] - TransferAmount 
    MoneyWhere.APointsGroups.Income[ToGroup] = MoneyWhere.APointsGroups.Income[ToGroup] + TransferAmount 
  else --if(CurrType == MW_CURRENCY_TELVAR) then
    -- transfer
    MoneyWhere.TelvarGroups.Income[FromGroup] = MoneyWhere.TelvarGroups.Income[FromGroup] - TransferAmount 
    MoneyWhere.TelvarGroups.Income[ToGroup] = MoneyWhere.TelvarGroups.Income[ToGroup] + TransferAmount 
  end
  
  MoneyWhere.CurrencyChangeFlag = true -- change flag since all values are updated
end


function MoneyWhere.ResetRate()
  
  -- loop over table and zero everything
  for icnt in ipairs(MoneyWhere.MinuteQueue.Gold) do
    MoneyWhere.MinuteQueue.Gold[icnt] = 0
    MoneyWhere.MinuteQueue.APoints[icnt] = 0
    MoneyWhere.MinuteQueue.Telvar[icnt] = 0
    MoneyWhere.MinuteQueue.Experience[icnt] = 0
  end
  
  MoneyWhere.MinuteCount = 1 -- current queue number
  MoneyWhere.MinuteNumber = 1 -- number of minutes that have been collected
end

function MoneyWhere.ZeroCurrentValues()
  CHAT_SYSTEM:AddMessage("MoneyWhere Zero Session")
  -- loop over each type and set all values to 0
  for icnt in ipairs(MoneyWhere.GoldGroups.Income) do
    MoneyWhere.GoldGroups.Income[icnt] = 0
    MoneyWhere.GoldGroups.Expense[icnt] = 0
    MoneyWhere.GoldGroups.NetCurr[icnt] = 0
    MoneyWhere.APointsGroups.Income[icnt] = 0 -- Do Alliance Points and Telvar here since same size
    MoneyWhere.APointsGroups.Expense[icnt] = 0 -- Do Alliance Points and Telvar here since same size
    MoneyWhere.APointsGroups.NetCurr[icnt] = 0 -- Do Alliance Points and Telvar here since same size
    MoneyWhere.TelvarGroups.Income[icnt] = 0
    MoneyWhere.TelvarGroups.Expense[icnt] = 0
    MoneyWhere.TelvarGroups.NetCurr[icnt] = 0
    
    MoneyWhere.ExperienceGroup[icnt] = 0 -- since experience is the same size, we'll put it here. separate if changes
  end
 
  MoneyWhere.ResetRate()
  MoneyWhere.CurrencyChangeFlag = true -- change flag since all values are updated
 
end

function MoneyWhere.ZeroAllValues()
  MoneyWhere.ZeroCurrentValues()
  MWG.MWSaved:SaveAccountVariables()
end

function MoneyWhere.SaveAddSessionAndZeroCurrent()
  MWG.MWSaved:SaveAccountVariables() 
  MoneyWhere.ZeroCurrentValues()
end

function MoneyWhere.LoadLedger()
  -- Loads saved values and will overwrite current session
  CHAT_SYSTEM:AddMessage("MoneyWhere Load Ledger, overwrite")
  -- loop over each type and set all values to 0
  for icnt in ipairs(MoneyWhere.GoldGroups.Income) do
    MoneyWhere.GoldGroups.Income[icnt] = MWG.MWSaved.SavedVariables.Gold.Income[icnt]
    MoneyWhere.GoldGroups.Expense[icnt] = MWG.MWSaved.SavedVariables.Gold.Expense[icnt]
  -- Do Alliance Points and Telvar here since same size
    MoneyWhere.APointsGroups.Income[icnt] = MWG.MWSaved.SavedVariables.APoints.Income[icnt]
    MoneyWhere.APointsGroups.Expense[icnt] = MWG.MWSaved.SavedVariables.APoints.Expense[icnt] -- Do Alliance Points and Telvar here since same size
    MoneyWhere.TelvarGroups.Income[icnt] = MWG.MWSaved.SavedVariables.Telvar.Income[icnt]
    MoneyWhere.TelvarGroups.Expense[icnt] = MWG.MWSaved.SavedVariables.Telvar.Expense[icnt]
  end
 
  MoneyWhere.CurrencyChangeFlag = true -- change flag since all values are updated
end
function MoneyWhere.LoadAddLedger()
  -- Loads saved values and adds them to current session
  -- Loads saved values and will overwrite current session
  CHAT_SYSTEM:AddMessage("MoneyWhere Load Ledger, add")
  -- loop over each type and set all values to 0
  for icnt in ipairs(MoneyWhere.GoldGroups.Income) do
    MoneyWhere.GoldGroups.Income[icnt] = MoneyWhere.GoldGroups.Income[icnt] + MWG.MWSaved.SavedVariables.Gold.Income[icnt]
    MoneyWhere.GoldGroups.Expense[icnt] = MoneyWhere.GoldGroups.Expense[icnt] + MWG.MWSaved.SavedVariables.Gold.Expense[icnt]
    -- Do Alliance Points and Telvar here since same size
    MoneyWhere.APointsGroups.Income[icnt] = MoneyWhere.APointsGroups.Income[icnt] + MWG.MWSaved.SavedVariables.APoints.Income[icnt] 
    MoneyWhere.APointsGroups.Expense[icnt] = MoneyWhere.APointsGroups.Expense[icnt] + MWG.MWSaved.SavedVariables.APoints.Expense[icnt]
    MoneyWhere.TelvarGroups.Income[icnt] = MoneyWhere.TelvarGroups.Income[icnt] + MWG.MWSaved.SavedVariables.Telvar.Income[icnt]
    MoneyWhere.TelvarGroups.Expense[icnt] = MoneyWhere.TelvarGroups.Expense[icnt] + MWG.MWSaved.SavedVariables.Telvar.Expense[icnt]
  end
 
  --MoneyWhere.MWCalculateTotals() -- calculate net and totals
  MoneyWhere.CurrencyChangeFlag = true -- change flag since all values are updated
end

-- ***************************************
-- Key event handling functions
-- ***************************************
function MoneyWhere:OnCloseWindow()
	MWWindow:SetHidden(true)
end

function MoneyWhere:OnRefresh()
	if not MWWindow:IsHidden() then
    -- Calculate totals is a lot of calculations, but it is only called when the window is visible
    -- Players will not be doing anything intensive while the window is up, so Net and Totals can wait until visible
    MoneyWhere.MWCalculateTotals()
		MoneyWhere.CTree:RefreshVisible()
		MoneyWhere.ETree:RefreshVisible()
    MoneyWhere.UpdatePockets()
    MoneyWhere.UpdateBanked()
	end
end

function MoneyWhere:OnShow()
	MoneyWhere:OnRefresh()
end


function MoneyWhere:OnMoveStop()
	local x, y = MWWindow:GetScreenRect()
	self.WindowProperties.x = x
	self.WindowProperties.y = y
  if MoneyWhere.DebugFlag == true then d("MW:Window: " .. x .. ": " .. y .. ": " .. self.WindowProperties.width .. ": " .. self.WindowProperties.height) end
end

-- save window size when resizing it
function MoneyWhere:OnResizeStop()
	local width, height = MWWindow:GetDimensions()
	self.WindowProperties.width = width
	self.WindowProperties.height = height
  if MoneyWhere.DebugFlag == true then d("MW:Window: " .. self.WindowProperties.x .. ": " .. self.WindowProperties.y .. ": " .. width .. ": " .. height) end
end

function MoneyWhere:OnUpdate()
  MoneyWhere:OnRefresh()    
end
 
-- Show or hide the window
function MoneyWhere.ToggleDisplay()
	MWWindow:ToggleHidden()
end

function MoneyWhere:OnToggleCurrencyType(buttonControl, button)
	-- toggle only if left click
	if button == MOUSE_BUTTON_INDEX_LEFT then
		ZO_ToggleButton_Toggle(buttonControl)
		local parentNode = buttonControl:GetParent().node
		parentNode:SetOpen(not parentNode:IsOpen(), USER_REQUESTED_OPEN)
	end
end

function MoneyWhere.PrintCommands()
	CHAT_SYSTEM:AddMessage("Money Where slash commands:")
	CHAT_SYSTEM:AddMessage("/moneywhere or /mw -- Shows/Hides Screen")
  CHAT_SYSTEM:AddMessage("/mw zero -- zeros session values")
	CHAT_SYSTEM:AddMessage("/mw zall -- zeros session and ledger")
  CHAT_SYSTEM:AddMessage("/mw save -- saves session to ledger")
  CHAT_SYSTEM:AddMessage("/mw sadd -- adds session to ledger")
  CHAT_SYSTEM:AddMessage("/mw sadz -- adds session to ledger, zeros session")
	CHAT_SYSTEM:AddMessage("/mw load -- load from ledger, overwrite session")
	CHAT_SYSTEM:AddMessage("/mw ladd -- add ledger to session")
  CHAT_SYSTEM:AddMessage("/mw help -- shows slash options")
end

function MoneyWhere.ProcessSlash(extra)
-- can use /mw or /moneywhere
-- /moneywhere toggle display
-- /moneywhere zero will zero current values
-- /moneywhere zall will zero current values and saved values
-- /moneywhere save will store the values in the saved area called the ledger
-- /moneywhere sadd will store the values in the saved area called the ledger by adding to the ledger
-- /moneywhere sadz will store the values in the saved area called the ledger by adding to the ledger then zero the session
-- /moneywhere load will load values into session from ledger, will overwrite current values
-- /moneywhere ladd will load values into session from ledger, will add values to current values
-- /moneywhere help will list commands

  if extra == nil then MoneyWhere.ToggleDisplay()
  elseif extra == "zero" then MoneyWhere.ZeroCurrentValues()
  elseif extra == "zall" then MoneyWhere.ZeroAllValues() 
  elseif extra == "save" then MWG.MWSaved:SaveAccountVariables()
  elseif extra == "sadd" then MWG.MWSaved:SaveAddAccountVariables()
  elseif extra == "sadz" then MWG.MWSaved:SaveAddSessionAndZeroCurrent()
  elseif extra == "load" then MoneyWhere.LoadLedger()
  elseif extra == "ladd" then MoneyWhere.LoadAddLedger()
  elseif extra == "help" then MoneyWhere.PrintCommands()
  else MoneyWhere.ToggleDisplay()
  end
  
end


-- ***************************************
-- Functions for Initialization and Drawing
-- ***************************************
function MoneyWhere:InitAddonMenu()
 	-- Get the Menu Display Library
  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel("MoneyWhere", panelData)
  LAM:RegisterOptionControls("MoneyWhere", optionsTable)
end


function MoneyWhere.TreeExperienceTypeSetup(node, CurrencyTypeControl, data, open, userRequested, enabled)
	local CurrencyControl = CurrencyTypeControl:GetNamedChild("ExTypeName")
	CurrencyControl:SetText(ZO_HIGHLIGHT_TEXT:Colorize(MoneyWhere.TypeStrings[data.section])) -- 4
  
	local PreviousControl = nil
	
  -- loop over columns
	for index, value in ipairs(data.NetCurr) do 
		local AmountControl = CurrencyTypeControl:GetNamedChild(string.format("Amount%s", index))
		AmountControl:SetHidden(false)
    -- need to find which group is being called, determined by data.section
    AmountControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_LocalizeDecimalNumber(value)))
		AmountControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
		-- center status control in column
		if PreviousControl then
			AmountControl:SetAnchor(CENTER, PreviousControl, CENTER, MoneyWhere.COLUMN_WIDTH)
		else
			AmountControl:SetAnchor(CENTER, CurrencyControl, LEFT, MoneyWhere.COLUMN_INDENT - MoneyWhere.ADDED_INDENT + MoneyWhere.COLUMN_WIDTH / 2, 4)
		end
		
		PreviousControl = AmountControl
	end
end

function MoneyWhere.TreeCurrencyTypeSetup(node, CurrencyTypeControl, data, open, userRequested, enabled)
	local CurrencyControl = CurrencyTypeControl:GetNamedChild("TypeName")
	CurrencyControl:SetText(ZO_HIGHLIGHT_TEXT:Colorize(MoneyWhere.TypeStrings[data.section]))
  
	local PreviousControl = nil
  
-- loop over columns
	for index, value in ipairs(data.NetCurr) do 
		local AmountControl = CurrencyTypeControl:GetNamedChild(string.format("Amount%s", index))
		AmountControl:SetHidden(false)
    -- need to find which group is being called, determined by data.section
    AmountControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(data.type, value, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
		AmountControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
		-- center status control in column
		if PreviousControl then
			AmountControl:SetAnchor(CENTER, PreviousControl, CENTER, MoneyWhere.COLUMN_WIDTH)
		else
			AmountControl:SetAnchor(CENTER, CurrencyControl, LEFT, MoneyWhere.COLUMN_INDENT - MoneyWhere.ADDED_INDENT + MoneyWhere.COLUMN_WIDTH / 2 )
		end
		
		PreviousControl = AmountControl
	end
end


function MoneyWhere.TreeAmountSetup(node, nodeControl, data, open, userRequested, enabled)
	local AmountControl = nodeControl:GetNamedChild("AmountName")
	AmountControl:SetText(MoneyWhere.AmountStrings[data.section]) -- Income, Expense, or Total
	
	local PreviousControl = nil
	
  -- loop over groups organized into columns
	for ColumnIndex, value in ipairs(data.CurrencyNet) do
		local AmountValueControl = nodeControl:GetNamedChild(string.format("Amount%s", ColumnIndex))
		AmountValueControl:SetHidden(false)
    AmountValueControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(data.type, value, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
		AmountValueControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		if PreviousControl then
			AmountValueControl:SetAnchor(CENTER, PreviousControl, CENTER, MoneyWhere.COLUMN_WIDTH)
		else
			AmountValueControl:SetAnchor(CENTER, AmountControl, LEFT, MoneyWhere.COLUMN_INDENT - MoneyWhere.ADDED_INDENT + MoneyWhere.COLUMN_WIDTH / 2)
		end
		
		PreviousControl = AmountValueControl
	end
end

-- This creates a header with the categories at the top
function MoneyWhere:CreateGroupsColumnHeader()
  -- Set up experience header
	local HeaderControl = MWWindow:GetNamedChild("ExpColumnHeader")
	local PreviousControl = nil
	local HeaderHeight = 0
  local OffsetY = 1
  local OffsetRateVX = 5
	
  if(MWG.MWSaved.SavedVariables.TrackExperience == true) then
    -- loop over strings so it gets all of the categories
    for index, group in ipairs(MoneyWhere.ExGroupStrings) do
      ColumnHeaderControl = CreateControlFromVirtual("ExpGroupsColumnHeader", HeaderControl, "MWGroupsColumnHeader", index)
      
      ColumnHeaderControl:SetText("|cf53838"..MoneyWhere.ExGroupStrings[index].."|r")
      ColumnHeaderControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
      
      -- set column width but leave a little padding
      ColumnHeaderControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
      
      if PreviousControl then
        ColumnHeaderControl:SetAnchor(CENTER, PreviousControl, CENTER, MoneyWhere.COLUMN_WIDTH)
      else
        ColumnHeaderControl:SetAnchor(CENTER, HeaderControl, LEFT, MoneyWhere.COLUMN_INDENT - MoneyWhere.ADDED_INDENT + MoneyWhere.COLUMN_WIDTH / 2 )
      end
      
      ColumnHeaderHeight = ColumnHeaderControl:GetHeight()
      
      if ColumnHeaderHeight > HeaderHeight then
        HeaderHeight = ColumnHeaderHeight
      end
      
      PreviousControl = ColumnHeaderControl
    end
    
    HeaderControl:SetHeight(ColumnHeaderHeight + MoneyWhere.COLUMN_HEIGHT_ADD)
    OffsetY = 61
    
    -- reset up for money columns
    PreviousControl = nil
    HeaderHeight = 0
  end
  
  HeaderControl = MWWindow:GetNamedChild("ColumnHeader")
	
  if(MWG.MWSaved.SavedVariables.TrackGold == true or MWG.MWSaved.SavedVariables.TrackAPoints == true or MWG.MWSaved.SavedVariables.TrackTelvar == true) then
  -- loop over strings so it gets all of the categories
    for index, group in ipairs(MoneyWhere.GroupStrings) do
      ColumnHeaderControl = CreateControlFromVirtual("GroupsColumnHeader", HeaderControl, "MWGroupsColumnHeader", index)
      
      ColumnHeaderControl:SetText("|cFCBA03"..MoneyWhere.GroupStrings[index].."|r")
      ColumnHeaderControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
      
      -- set column width but leave a little padding
      ColumnHeaderControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
      
      if PreviousControl then
        ColumnHeaderControl:SetAnchor(CENTER, PreviousControl, CENTER, MoneyWhere.COLUMN_WIDTH)
      else
        ColumnHeaderControl:SetAnchor(CENTER, HeaderControl, LEFT, MoneyWhere.COLUMN_INDENT - MoneyWhere.ADDED_INDENT + MoneyWhere.COLUMN_WIDTH / 2, OffsetY)
      end
      
      ColumnHeaderHeight = ColumnHeaderControl:GetHeight()
      
      if ColumnHeaderHeight > HeaderHeight then
        HeaderHeight = ColumnHeaderHeight
      end
      
      PreviousControl = ColumnHeaderControl
    end
    
	  HeaderControl:SetHeight(ColumnHeaderHeight + MoneyWhere.COLUMN_HEIGHT_ADD)
  end
    
  -- Set rate location
  HeaderControl = MWWindow:GetNamedChild("RateHeader")
  
  if(MWG.MWSaved.SavedVariables.TrackExperience == true) then
    OffsetY = 30
    MoneyWhere.RateExControl = CreateControlFromVirtual("ExpRateValue", HeaderControl, "MWRatesValue", 4)
    MoneyWhere.RateExControl:SetAnchor(LEFT, HeaderControl, LEFT, OffsetRateVX, OffsetY )
    MoneyWhere.RateExControl:SetText("--/--")
    MoneyWhere.RateExControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    MoneyWhere.RateExControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
  end
  
  if(MWG.MWSaved.SavedVariables.TrackGold == true) then
    OffsetY = OffsetY + 80
    MoneyWhere.RateGoldControl = CreateControlFromVirtual("GoldRateValue", HeaderControl, "MWRatesValue", 1)
    MoneyWhere.RateGoldControl:SetAnchor(LEFT, HeaderControl, LEFT, OffsetRateVX, OffsetY )
    MoneyWhere.RateGoldControl:SetText("--/--")
    MoneyWhere.RateGoldControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    MoneyWhere.RateGoldControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
  end 
  if MWG.MWSaved.SavedVariables.TrackAPoints == true then
    OffsetY = OffsetY + 80
    MoneyWhere.RateAPointsControl = CreateControlFromVirtual("APointsRateValue", HeaderControl, "MWRatesValue", 2)
    MoneyWhere.RateAPointsControl:SetAnchor(LEFT, HeaderControl, LEFT, OffsetRateVX, OffsetY )
    MoneyWhere.RateAPointsControl:SetText("--/--")
    MoneyWhere.RateAPointsControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    MoneyWhere.RateAPointsControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
  end
  if MWG.MWSaved.SavedVariables.TrackTelvar == true then
    OffsetY = OffsetY + 80
    MoneyWhere.RateTelvarControl = CreateControlFromVirtual("TelvarRateValue", HeaderControl, "MWRatesValue", 3)
    MoneyWhere.RateTelvarControl:SetAnchor(LEFT, HeaderControl, LEFT, OffsetRateVX, OffsetY )
    MoneyWhere.RateTelvarControl:SetText("--/--")
    MoneyWhere.RateTelvarControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    MoneyWhere.RateTelvarControl:SetWidth(MoneyWhere.COLUMN_WIDTH - 10)
  end
  
	-- ensure the window is exactly wide enough to contain the header, plus a little extra
	local width = MoneyWhere.COLUMN_INDENT + MoneyWhere.COLUMN_WIDTH * MoneyWhere.MaxNumberOfGroups + 120
	local _, minHeight, maxWidth, maxHeight = MWWindow:GetDimensionConstraints()
	MWWindow:SetDimensionConstraints(width, minHeight, maxWidth, maxHeight)
	MWWindow:SetDimensions(width, MWWindow:GetHeight())
	MoneyWhere:OnResizeStop()
  
end


function MoneyWhere:InitializeRows()
	-- Create a section for each category of quests
  local CurrencyNode
  
  -- Experience
  if(MWG.MWSaved.SavedVariables.TrackExperience == true) then
    CurrencyNode = MoneyWhere.ETree:AddNode("MWExperienceType", { section = 4, NetCurr = MoneyWhere.ExperienceGroup, } )
    CurrencyNode:SetOpen(true)
    -- move scroll frame down to accomodate experience.
  end
  -- Gold and currencies
  if(MWG.MWSaved.SavedVariables.TrackGold == true) then
    CurrencyNode = MoneyWhere.CTree:AddNode("MWCurrencyType", { type = CURT_MONEY, section = 1, NetCurr = MoneyWhere.GoldGroups.NetCurr, } )
    -- Create a row for each type
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_MONEY, section = 1, CurrencyNet = MoneyWhere.GoldGroups.Income, }, CurrencyNode ) -- Income
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_MONEY, section = 2, CurrencyNet = MoneyWhere.GoldGroups.Expense, }, CurrencyNode ) -- Expense
    CurrencyNode:SetOpen(true)
  end
  
  -- Alliance Points
  if(MWG.MWSaved.SavedVariables.TrackAPoints == true) then
    CurrencyNode = MoneyWhere.CTree:AddNode("MWCurrencyType", { type = CURT_ALLIANCE_POINTS, section = 2, NetCurr = MoneyWhere.APointsGroups.NetCurr, } )
    -- Create a row for each type
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_ALLIANCE_POINTS, section = 1, CurrencyNet = MoneyWhere.APointsGroups.Income, }, CurrencyNode ) -- Income
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_ALLIANCE_POINTS, section = 2, CurrencyNet = MoneyWhere.APointsGroups.Expense, }, CurrencyNode ) -- Expense
    CurrencyNode:SetOpen(true)
  end
   
  -- Telvar
  if(MWG.MWSaved.SavedVariables.TrackTelvar == true) then
    CurrencyNode = MoneyWhere.CTree:AddNode("MWCurrencyType", { type = CURT_TELVAR_STONES, section = 3, NetCurr = MoneyWhere.TelvarGroups.NetCurr, } )
    -- Create a row for each type
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_TELVAR_STONES, section = 1, CurrencyNet = MoneyWhere.TelvarGroups.Income, }, CurrencyNode ) -- Income
    MoneyWhere.CTree:AddNode("MWCurrencyAmount", { type = CURT_TELVAR_STONES, section = 2, CurrencyNet = MoneyWhere.TelvarGroups.Expense, }, CurrencyNode ) -- Expense
    CurrencyNode:SetOpen(true)
  end
   
   
end

function MoneyWhere.OnPlayerCurrencyUpdate(event, currencyType, newAmount, oldAmount, reason)
  -- skip if it's just initialization
  if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then
    MoneyWhere.AmountChange = 0;
    return
  end
  
  MoneyWhere.AmountChange = newAmount - oldAmount
 
  MoneyWhere.CurrencyChangeFlag = true;
  if MoneyWhere.DebugFlag == true then d(string.format("MW:OnPlayerCurrencyUpdate: %s - %s = %d", newAmount, oldAmount, MoneyWhere.AmountChange)) end
    
  -- Check if it's money
  if (currencyType == CURT_MONEY) and (MWG.MWSaved.SavedVariables.TrackGold == true) then
    MoneyWhere.MWHandleGold(reason)
  elseif (currencyType == CURT_ALLIANCE_POINTS) and (MWG.MWSaved.SavedVariables.TrackAPoints == true) then
    MoneyWhere.MWHandleAPoints(reason)
  elseif (currencyType == CURT_TELVAR_STONES) and (MWG.MWSaved.SavedVariables.TrackTelvar == true) then
    MoneyWhere.MWHandleTelvar(reason)
  else  -- Don't care about type
    if MoneyWhere.DebugFlag == true then d("MW:Not Tracked: ") end
  end
  
  MoneyWhere:OnRefresh()
end

function MoneyWhere.OnCurrencyUpdate(event, currencyType, location, newAmount, oldAmount, reason)
  -- skip if it's just initialization
  if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then
    MoneyWhere.AmountChange = 0;
    return
  end
  
  MoneyWhere.AmountChange = newAmount - oldAmount
 
  MoneyWhere.CurrencyChangeFlag = true;
  if MoneyWhere.DebugFlag == true then d(string.format("MW:OnCurrencyUpdate: %d - %d = %d", newAmount, oldAmount, MoneyWhere.AmountChange)) end
    
  -- Check if it's money
  if (currencyType == CURT_MONEY) and (MWG.MWSaved.SavedVariables.TrackGold == true) then
    if MoneyWhere.DebugFlag == true then d(string.format("MW:Gold Change at (%d)", location)) end
    --MoneyWhere.MWHandleGold(reason)
  elseif (currencyType == CURT_ALLIANCE_POINTS) and (MWG.MWSaved.SavedVariables.TrackAPoints == true) then
    if MoneyWhere.DebugFlag == true then d(string.format("MW:AP Change at (%d)", location)) end
    --MoneyWhere.MWHandleAPoints(reason)
  elseif (currencyType == CURT_TELVAR_STONES) and (MWG.MWSaved.SavedVariables.TrackTelvar == true) then
    if MoneyWhere.DebugFlag == true then d(string.format("MW:Telvar Change at (%d)", location)) end
    --MoneyWhere.MWHandleTelvar(reason)
  else  -- Don't care about type
    if MoneyWhere.DebugFlag == true then d("MW:Not Tracked: ") end
  end
  
  MoneyWhere:OnRefresh()
end

function MoneyWhere.OnPlayerTakeMailMoney(event, mailID)
  local sender, _, subject, _, _, _, _, returnedflag, _, attachedMoney, codAmount, _, _ = GetMailItemInfo(mailID)
  
  -- At this stage, money has been taken so money will be zero, use Amount Change instead
  if attachedMoney == 0 then attachedMoney = MoneyWhere.AmountChange end 
  
  -- Transfer money based upon subject of email
  if(string.find(subject, "Item Sold") ~= nil) then 
    -- Money from selling item in guild store
    if MoneyWhere.DebugFlag == true then d("MW:Item Sold") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_TRADE_HOUSE, attachedMoney)
  elseif(string.find(subject, "Our Thanks") ~= nil) then
    -- Reward for PvP Campaign
    if MoneyWhere.DebugFlag == true then d("MW:Thanx Warrior") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "Rewards for the Worthy") ~= nil) then
    -- Reward for PvP activities
    if MoneyWhere.DebugFlag == true then d("MW:Rewards for the Worthy!") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "Campaign Loyalty") ~= nil) then
    -- Reward for campaign loyalty
    if MoneyWhere.DebugFlag == true then d("MW:Campaign Loyalty") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "For the Pact") ~= nil) then
    -- Reward for campaign loyalty
    if MoneyWhere.DebugFlag == true then d("MW:For The ___") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "For the Covenant") ~= nil) then
    -- Reward for campaign loyalty
    if MoneyWhere.DebugFlag == true then d("MW:For The ___") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "For the Dominion") ~= nil) then
    -- Reward for campaign loyalty
    if MoneyWhere.DebugFlag == true then d("MW:For The ___") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_PVP_REWARD, attachedMoney)
  elseif(string.find(subject, "Daily Quest") ~= nil) then
    -- Reward for daily quest
    if MoneyWhere.DebugFlag == true then d("MW:Daily Quest") end
    MoneyWhere.TransferCurrency(MW_CURRENCY_GOLD, MW_MAIL, MW_REWARD, attachedMoney)
  end
  
  MoneyWhere:OnRefresh()
end

function MoneyWhere.OnPlayerExperienceGain(event, reason, level, oldExperience, newExperience, championPoints)
  MoneyWhere.AmountChange = newExperience - oldExperience
  MoneyWhere.CurrencyChangeFlag = true;
  
  if MoneyWhere.DebugFlag == true then d(string.format("MW:OnPlayerExperienceGain: %s - %s = %s", newExperience, oldExperience, MoneyWhere.AmountChange)) end
  
  -- Make sure 
  if(MWG.MWSaved.SavedVariables.TrackExperience == true) then
    MoneyWhere.MWHandleExperience(reason)
  end
  
end

function MoneyWhere.OnPlayerExperienceUpdate(event, unitTag, oldExperience, newExperience, reason)
  MoneyWhere.AmountChange = newExperience - oldExperience
  MoneyWhere.CurrencyChangeFlag = true;
  
  if MoneyWhere.DebugFlag == true then d(string.format("MW:OnPlayerExperienceUpdate: %s - %s = %s", newExperience, oldExperience, MoneyWhere.AmountChange)) end
  
  -- Make sure 
  if(MWG.MWSaved.SavedVariables.TrackExperience == true) then
    MoneyWhere.MWHandleExperience(reason)
  end
  
end


function MoneyWhere.OnRateTimerAction()
  -- Rate timer activated so advance queue and other items
  if MWG.MWSaved.SavedVariables.TrackRate == false then return end
  
  -- transfer running amount to queue
  MoneyWhere.MinuteQueue.Gold[MoneyWhere.MinuteCount] = MoneyWhere.MinuteQueue.Gold[MW_RATE_RUNNING_QUEUE_POSITION]
  MoneyWhere.MinuteQueue.APoints[MoneyWhere.MinuteCount] = MoneyWhere.MinuteQueue.APoints[MW_RATE_RUNNING_QUEUE_POSITION]
  MoneyWhere.MinuteQueue.Telvar[MoneyWhere.MinuteCount] = MoneyWhere.MinuteQueue.Telvar[MW_RATE_RUNNING_QUEUE_POSITION]
  MoneyWhere.MinuteQueue.Experience[MoneyWhere.MinuteCount] = MoneyWhere.MinuteQueue.Experience[MW_RATE_RUNNING_QUEUE_POSITION]
  
  MoneyWhere.UpdateRates()
  if MoneyWhere.RateDebugFlag == true then 
    d(string.format("MW:Rate Count, Num, EPR, GPR: %d, %d, %d, %d", MoneyWhere.MinuteCount, MoneyWhere.MinuteNumber, MoneyWhere.GoldRate, MoneyWhere.ExperienceRate)) 
    d(string.format("MW:V:%d-%d-%d-%d-%d:%d", MoneyWhere.MinuteQueue.Experience[1], MoneyWhere.MinuteQueue.Experience[2], MoneyWhere.MinuteQueue.Experience[3], MoneyWhere.MinuteQueue.Experience[4], MoneyWhere.MinuteQueue.Experience[5], MoneyWhere.MinuteQueue.Experience[MW_RATE_RUNNING_QUEUE_POSITION]))
  end
  
  -- advance count
  if MoneyWhere.MinuteCount < MWG.MWSaved.SavedVariables.RateMinutes then 
    MoneyWhere.MinuteCount = MoneyWhere.MinuteCount + 1 
  else
    MoneyWhere.MinuteCount = 1 
  end
  -- Advance number of minutes collected
  if MoneyWhere.MinuteNumber < MWG.MWSaved.SavedVariables.RateMinutes then MoneyWhere.MinuteNumber = MoneyWhere.MinuteNumber + 1 end
  
  -- Zero running amount
  MoneyWhere.MinuteQueue.Gold[MW_RATE_RUNNING_QUEUE_POSITION] = 0
  MoneyWhere.MinuteQueue.APoints[MW_RATE_RUNNING_QUEUE_POSITION] = 0
  MoneyWhere.MinuteQueue.Telvar[MW_RATE_RUNNING_QUEUE_POSITION] = 0
  MoneyWhere.MinuteQueue.Experience[MW_RATE_RUNNING_QUEUE_POSITION] = 0

  -- start rate timer, do flag check again in case some wierd situation occured with timing
  if MWG.MWSaved.SavedVariables.TrackRate == true  then zo_callLater(MoneyWhere.OnRateTimerAction, MW_ONE_MINUTE) end

end


-- Initializes window size and position to default
function MoneyWhere:InitializeWindowProperties()
		-- get default window properties
	local x = MWG.MWSaved.SavedVariables.WindowProperties.x
  local y = MWG.MWSaved.SavedVariables.WindowProperties.y
	local width = MWG.MWSaved.SavedVariables.WindowProperties.width
  local height = MWG.MWSaved.SavedVariables.WindowProperties.height
	
  MWWindow:ClearAnchors()
	MWWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	MWWindow:SetDimensions(width, height)
end

-- A function that will initialize our addon
function MoneyWhere.Initialize()
  -- Set the initial gold amount to 0.
  MoneyWhere.AmountChange = 0
  MoneyWhere.CurrencyChangeFlag = true
  
  -- Register keybindings
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_TOGGLE_DISPLAY", "Display MoneyWhere Window")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_ZERO_VALUES", "Zero Current Session")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_ZERO_ALL_VALUES", "Zero Session and Ledger")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_SAVE_SESSION", "Save Session to Ledger")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_SAVE_ADD_SESSION", "Add Session to Ledger")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_SAVE_ADD_ZERO_CURRENT", "Add Session Then Zero")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_LOAD_LEDGER", "Load Ledger")
	ZO_CreateStringId("SI_BINDING_NAME_MONEYWHERE_LOAD_ADD_LEDGER", "Add Ledger To Session")

  -- Load saved variables
  MWG.MWSaved:Initialize()

  MoneyWhere:InitializeWindowProperties()

  -- setup menu
  MoneyWhere:InitAddonMenu()
  
  -- Initialization of display window
  MoneyWhere:CreateGroupsColumnHeader()
  -- Get a window from XML, create templates for each type, then the template function is called for each type created
  -- https://wiki.esoui.com/ZO_Tree
  local scrollContainer = MWWindow:GetNamedChild("ExScrollFrame")
	MoneyWhere.ETree = ZO_Tree:New(scrollContainer:GetNamedChild("ScrollChild"), 0, 0, MW_DEFAULT_WIDTH)
	MoneyWhere.ETree:AddTemplate("MWExperienceType", MoneyWhere.TreeExperienceTypeSetup, nil, nil, MoneyWhere.CURRENCY_INDENT, 0)
  scrollContainer = MWWindow:GetNamedChild("ScrollFrame")
	MoneyWhere.CTree = ZO_Tree:New(scrollContainer:GetNamedChild("ScrollChild"), 0, 0, MW_DEFAULT_WIDTH)
	MoneyWhere.CTree:AddTemplate("MWCurrencyType", MoneyWhere.TreeCurrencyTypeSetup, nil, nil, MoneyWhere.CURRENCY_INDENT, 0)
	MoneyWhere.CTree:AddTemplate("MWCurrencyAmount", MoneyWhere.TreeAmountSetup, nil, nil, MoneyWhere.GROUP_INDENT, 0)
  
	MoneyWhere:InitializeRows()
  
  -- Check to load ledger or not
  if(MWG.MWSaved.SavedVariables.LoadLedgerOnInit == true) then
    MoneyWhere.LoadLedger()
  end
  
  -- Register events for tracking currency
  MoneyWhere.MWCalculateTotals()
  EVENT_MANAGER:RegisterForEvent("MoneyWhere", EVENT_CARRIED_CURRENCY_UPDATE, MoneyWhere.OnPlayerCurrencyUpdate)  
  EVENT_MANAGER:RegisterForEvent("MoneyWhere", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, MoneyWhere.OnPlayerTakeMailMoney)  
  EVENT_MANAGER:RegisterForEvent("MoneyWhere", EVENT_EXPERIENCE_GAIN, MoneyWhere.OnPlayerExperienceGain)  
  --EVENT_MANAGER:RegisterForEvent("MoneyWhere", EVENT_CURRENCY_UPDATE, MoneyWhere.OnCurrencyUpdate)  

  -- For slash command
  SLASH_COMMANDS["/moneywhere"] = MoneyWhere.ProcessSlash
  SLASH_COMMANDS["/mw"] = MoneyWhere.ProcessSlash
  
  -- start rate timer
  if MWG.MWSaved.SavedVariables.TrackRate == true  then zo_callLater(MoneyWhere.OnRateTimerAction, MW_ONE_MINUTE) end
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
MoneyWhere.OnAddOnLoaded = function(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == MWG.name then
    EVENT_MANAGER:UnregisterForEvent(MWG.name, EVENT_ADD_ON_LOADED)
    MoneyWhere.Initialize()
  end
  
end

-- this is where it all starts
-- Register event handler function to be called when this is loaded.
EVENT_MANAGER:RegisterForEvent(MWG.name, EVENT_ADD_ON_LOADED, MoneyWhere.OnAddOnLoaded)