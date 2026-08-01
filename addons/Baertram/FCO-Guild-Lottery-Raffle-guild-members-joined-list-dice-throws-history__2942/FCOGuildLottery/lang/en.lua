if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local preFix = "[FCOGL]"

FCOGuildLottery.lang["en"] = {
    --Entries in the search dropdown
    [FCOGL_SEARCHDROP_PREFIX .."1"]             = "Name / Rank",
    [FCOGL_SEARCHDROP_PREFIX .."2"]             = "Joined date",

    --Entries in the history search dropdown
    [FCOGL_HISTORY_SEARCHDROP_PREFIX .."1"]     = "Name / #",

    --The sort headers
    FCOGL_HEADER_RANK                           = "Rank",
    FCOGL_HEADER_NAME                           = "Seller",
    FCOGL_HEADER_DATE                           = "Date",
    FCOGL_HEADER_ITEM                           = "Item",
    FCOGL_HEADER_AMOUNT                         = "Amount",
    FCOGL_HEADER_PRICE                          = "Price",
    FCOGL_HEADER_TAX                            = "Tax",
    FCOGL_HEADER_INFO                           = "Info",
    FCOGL_HEADER_NO                             = "#",
    FCOGL_HEADER_ROLL                           = "|t28:28:/esoui/art/loot/dice_disabled.dds|t(Roll)",
    FCOGL_HEADER_MEMBER_NAME                    = "Member name",
    FCOGL_HEADER_INVITEDBY                      = "Invited by",
    FCOGL_HEADER_JOINEDINFO                     = "Joined date [Still in?/index]",
    FCOGL_NO_GUILD                              = "-> No guild <-",

    FCOGL_DICE_TYPE_STRING_RANDOM               = "Random",
    FCOGL_DICE_TYPE_STRING_GUILD                = "Guild's \'%s\' member index ",
    FCOGL_DICE_TYPE_STRING_GUILDSALESLOTTERY    = "Guild's \'%s\' sales lottery rank ",
    FCOGL_DICE_TYPE_STRING_GUILDMEMBERJOINED    = "Guild's \'%s\' member joined list ",

    FCOGL_DICE_HISTORY_NORMAL                   = "Normal rolls history",
    FCOGL_DICE_HISTORY_GUILD                    = "Guild rolls history",

    FCOGL_LASTROLLED_DICE_CHAT_OUTPUT           = "%s dice roll (D%s) =   %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_SOLD_CHAT_OUTPUT = ">>Found member \'%s\' at rank: %s, with sold sum: %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_JOINED_CHAT_OUTPUT = ">>Found joined member \'%s\' at list index: %s",
    FCOGL_LASTROLLED_DICE_FOUND_MEMBER_CHAT_OUTPUT = ">>Found member \'%s\'",

    FCOGL_DICE_SIDES                            = "# of sides of the dice",
    FCOGL_START_NEW_GUILD_SALES_LOTTERY         = "Start new guild sales lottery",
    FCOGL_ROLL_THE_DICE                         = "Roll the dice",
    FCOGL_REFRESH                               = "Refresh",
    FCOGL_STOP_GUILDSALESLOTTERY                = "Stop guild sales lottery",
    FCOGL_SETTINGS                              = "Open settings",
    FCOGL_CLOSE                                 = "Close",
    FCOGL_TOGGLE_DICE_ROLL_HISTORY              = "Toggle dice roll history",
    FCOGL_GUILD_SALES_LOTTERY                   = "Guild sales lottery",
    FCOGL_GUILD_SALES_LOTTERY_HISTORY           = "Guild sales lottery history",
    FCOGL_START_NEW_GUILD_MEMBER_JOINED_LIST    = "Start new guild members joined date list",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST         = "Stop guild members joined date list",

    FCOGL_DICE_PREFIX                           = "D",

    FCOGL_CURRENTGUILSALESLOTTERY_TEXT              = "Start: %s / End: %s (%s days)",
    FCOGL_CURRENTGUILSALESLOTTERY_DICEHISTORY_TEXT  = "From: %s / -%s days",
    FCOGL_GUILDSALESLOTTERY_HISTORY_DROP_TT         = "Select a saved guild sales lottery history.\nThis will re-open this sales lottery for new dice throws.\nA currently active guild sales lottery will be stopped!",
    FCOGL_GUILDSALESLOTTERY_DELETE_HISTORY_DROP_TT  = "Select saved guild sales lottery history entries that you would like to delete, then click on the delete button at the right side of the selection box",
    FCOGL_GUILDSALESLOTTERY_DELETE_SELECTED         = "Delete selected saved guild sales lottery history entries",

    FCOGL_GUILDMEMBERSJOINEDDATE_HISTORY_DROP_TT         = "Select a saved guild members joined list history.\nThis will re-open this members joined list for new dice throws.\nA currently active guild members joined list will be stopped!",
    FCOGL_GUILDMEMBERSJOINEDDATE_DELETE_HISTORY_DROP_TT  = "Select saved guild members joined list history entries that you would like to delete, then click on the delete button at the right side of the selection box",
    FCOGL_GUILDMEMBERSJOINEDDATE_DELETE_SELECTED         = "Delete selected saved guild members joined list history entries",

    FCOGL_DELETE_HISTORY_NONE_SELECTED              = "",
    FCOGL_DELETE_HISTORY_SOME_SELECTED              = "<<1>> selected, click button |t24:24:/esoui/art/tutorial/inventory_tabicon_junk_up.dds|t ->",

    FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_TITLE    = "Reset guild sales lottery",
    FCOGL_RESET_GUILD_SALES_LOTTERY_DIALOG_QUESTION = "Do you want to reset the currently active guild\n sales lottery?\nThis will start a new lottery!",
    FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE    = "Reset guild member joined list throws",
    FCOGL_RESET_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION = "Do you want to reset the currently active guild\n member joined list?\nThis will start a new guild member joined list!",

    FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_TITLE     = "Stop guild sales lottery",
    FCOGL_STOP_GUILD_SALES_LOTTERY_DIALOG_QUESTION  = "Do you want to stop the currently active guild\nsales lottery?\nThis will enable the guild dice throws for the\nselected guild again.",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_TITLE= "Stop guild member joined throws",
    FCOGL_STOP_GUILD_MEMBER_JOINED_LIST_DIALOG_QUESTION  = "Do you want to stop the currently active guild\nmember joined list throws?\nThis will enable the guild dice throws for the\nselected guild again.",

    FCOGL_CLEAR_HISTORY                             = "Clear the shown history list",
    FCOGL_CLEAR_HISTORY_DIALOG_TITLE                = "Clear history list?",
    FCOGL_CLEAR_HISTORY_DIALOG_QUESTION             = "Do you want to clear the shown \'%s\'\nhistory list? This will delete all entries!",
    FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_TITLE       = "Delete selected history entries?",
    FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_QUESTION    = "Do you want to delete the selected #\'%s\'\nhistory entries?",

    FCOGL_HISTORY                               = "Normal roll",
    FCOGL_GUILD_HISTORY                         = "Guild roll",
    FCOGL_GUILD_SALES_LOTTERY_HISTORY           = "Guild sales lottery roll",
    FCOGL_GUILD_MEMBER_JOIN_DATE_HISTORY        = "Guild member join date roll",

    FCOGL_CLEARED_HISTORY_COUNT                 = preFix .. "Deleted \'%s\' history entries",

    FCOGL_TOGGLE_WINDOW_DRAW_LAYER              = "Toggle draw layer",

    FCOGL_DELETE_HEADER                         = "Delete",
    FCOGL_DELETE_ENTRY                          = "Delete entry #%s",

    --LAM settings menu
    --Description
    FCOGL_LAM_DESCRIPTION                       = 'Helper addon for a guild lottery/member joined list/member & normal dice rolls.',
    FCOGL_LAM_HEADER_CHAT_COMMANDS              = 'Chat slash commands',
    FCOGL_LAM_CHAT_COMMANDS                     = 'Chat slash commands are:\n'..
            '/fcogl   Toggle the UI.\n/fcogls   Toggle the settings menu.\n'..
            '/dice <number>   Will roll a dice with <number> sides. If left empty the default value from the settings will be used!\n' ..
            '/diceG1 - /diceG5  Will roll a dice for the number of guild members of guild 1 - 5.\n\n'..
            '/gslnew <guildIndex 1 to 5> will reset the currently active sales lottery and start a new one.\n'..
            '/gsl will roll the next dice for the active guild sales lottery.\n'..
            '/gslstop will stop the currently active guild sales lottery.\n\n'..
            '/gmjnew <guildIndex 1 to 5> will reset the currently active guild members joined date list and start a new one.\n'..
            '/gmj will roll the next dice for the active guild members joined date list.\n'..
            '/gmjstop will stop the currently active guild members joined date list.\n\n'..
            '/gsllast or /gmjlast or /dicelast will show the last dice roll results in your local chat (or if you got it enabled: within the \'DebugLogViewer\' UI) again.',
    --Headlines
    FCOGL_LAM_FORMAT_OPTIONS                    = "Output format",
    FCOGL_LAM_DICE_OPTIONS                      = 'Dice settings',
    FCOGL_LAM_GUILD_ROLL_OPTIONS                = 'Guild role settings',
    FCOGL_LAM_GUILD_LOTTERY_OPTIONS             = 'Guild lottery settings',
    FCOGL_LAM_GUILD_MEMBERS_JOINED_OPTIONS      = 'Guild members joined settings',
    FCOGL_LAM_DEBUG_OPTIONS                     = 'Debug',

    FCOGL_LAM_SAVE_TYPE                         = 'Settings save type',
    FCOGL_LAM_SAVE_TYPE_TT                      = 'Use account wide settings for all your characters, or save them separatley for each character?',
    FCOGL_LAM_SAVE_TYPE_PER_CHARACTER           = 'Each character',
    FCOGL_LAM_SAVE_TYPE_PER_ACCOUNT             = 'Account wide',

    --Options
    FCOGL_LAM_DEFAULT_DICE_SIDES                            = "Default dice sides",
    FCOGL_LAM_DEFAULT_DICE_SIDES_TT                         = "The standard sides of a dice which you roll via the \'/dice\' slash command, or via the keybind \'Roll dice with def. sides\'",
    FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT           = "Chat edit box: Dice roll result",
    FCOGL_LAM_GUILD_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT        = "Define the text that should be shown in the chat after a normal guild dice roll was done, and a member index was determined\n\nYou can use the following placeholders:\n<<1>>   Dice roll #\n<<2>>   @AccountName of guild member.",
    FCOGL_LAM_GUILD_LOTTERY_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT= "Define the text that should be shown in the chat after a guild sales lottery dice roll was done, and a member rank was determined\n\nYou can use the following placeholders:\n<<1>>   Dice roll #\n<<2>>   @AccountName of seller.",
    FCOGL_LAM_GUILD_MEMBER_JOIN_DATE_DICE_ROLL_RESULT_TO_CHAT_EDIT_TT = "Define the text that should be shown in the chat after a guild member joined date list dice roll was done, and a member index was determined\n\nYou can use the following placeholders:\n<<1>>   Dice roll #\n<<2>>   @AccountName of joined guild member.",

    FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT     = "Cut-off at 00:00 current day",
    FCOGL_LAM_GUILD_LOTTERY_CUT_OFF_AT_MIDNIGHT_TT  = "Cut-off the data at the current day at 00:00.\nNo newer events coming in after 00:00 via LibHistoire will be used for the list entries!\nOnly for the guild lottery ranking: If this setting is disabled (default setting) the ranking (Guild sales lottery) will be using the same values as Master Merchant e.g. does for the 7 days ranking.",
    FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL    = "Show UI after dice roll",
    FCOGL_LAM_GUILD_LOTTERY_SHOW_UI_ON_DICE_ROLL_TT = "Automatically show the UI after a dice roll was done via a slash command.\n\nThe dice roll history will be expanded as well then.\nInfo: The dice roll history will not change to the dice throw type (e.g. /diceg1 should switch to the guild 1 dice history) if a guild sales lottery or guild member joined list is currently active!",
    FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE             = "Days backwards from today",
    FCOGL_LAM_GUILD_LOTTERY_DAYS_BEFORE_TT          = "The days the guild should read backwards from today and collect the sales data. Default value is 7 days.\n\nAttention: The more days you select here the more guild sales events need to be read! Make sure ALL the selected days are given in your guild  history, check the guild tabs and if \'LibHistoire\' did read all the needed data, is aligned and updated! Else you'll most probably not be able to start the dice rolls, or you'll get false results!",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_DAYS_BEFORE_TT = "The days the guild should read backwards from today and collect the member joined data. Default value is 31 days.\n\nAttention: The more days you select here the more guild member events need to be read! Make sure ALL the selected days are given in your guild  history, check the guild tabs and if \'LibHistoire\' did read all the needed data, is aligned and updated! Else you'll most probably not be able to start the dice rolls, or you'll get false results!",

    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_SHOW_UI_ON_DICE_ROLL_TT = "Automatically show the UI after a dice roll was done via a slash command.\n\nThe dice roll history will be expanded as well then.\nInfo: The dice roll history will not change to the dice throw type (e.g. /diceg1 should switch to the guild 1 dice history) if a guild sales lottery or guild member joined list is currently active!",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT = "Hide members who left",
    FCOGL_LAM_GUILD_MEMBERS_JOINED_DATE_LIST_FILTER_ALREADY_LEFT_TT = "Hide/filter the guild members who have left the guild again already",

    FCOGL_LAM_GUILD_LOTTERY_DATE_FROM               = "Date from",
    FCOGL_LAM_GUILD_LOTTERY_DATE_FROM_TT            = "The start date of the guild sales lottery. Default value is today - 7 days (at midnight).",

    FCOGL_LAM_USE_24h_FORMAT                    = "Use 24h time format",
    FCOGL_LAM_USE_24h_FORMAT_TT                 = "Use the 24 hours time format for date & time formats",
    FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT        = "Custom date & time format",
    FCOGL_LAM_USE_CUSTOM_DATETIME_FORMAT_TT     = "Specify your own date & time format.\nLeve the edit field empty to use the standard date & time format.\nThe usable placeholders are pre-defined within the lua language:\n\n%a	abbreviated weekday name (e.g., Wed)\n%A	full weekday name (e.g., Wednesday)\n%b	abbreviated month name (e.g., Sep)\n%B	full month name (e.g., September)\n%c	date and time (e.g., 09/16/98 23:48:10)\n%d	day of the month (16) [01-31]\n%H	hour, using a 24-hour clock (23) [00-23]\n%I	hour, using a 12-hour clock (11) [01-12]\n%M	minute (48) [00-59]\n%m	month (09) [01-12]\n%p	either \"am\" or \"pm\" (pm)\n%S	second (10) [00-61]\n%w	weekday (3) [0-6 = Sunday-Saturday]\n%x	date (e.g., 09/16/98)\n%X	time (e.g., 23:48:10)\n%Y	full year (1998)\n%y	two-digit year (98) [00-99]\n%%	the character `%´",

    FCOGL_LAM_CLEAR_SAVEDVARIABLES_OPTIONS      = "Clear SavedVariables",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE      = "Choose 'Days before'",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DAYS_BEFORE_TT   = "Choose the saved 'Days before', which you want to delete.\n\nYou can use this list as overview too, to see which day-range was selected before already. By changing the appropriate slider above to the same days-range and reladoing the UI afterwards, you can use the FCO GuildLottery history UI afterwards to see the saved data and delete single entries, or the whole saved day-range, via the history UIs buttons and context menus.",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE      = "Delete",
    FCOGL_LAM_CLEAR_SAVEDVARIABLES_DELETE_TT   = "Delete the chosen entries",
    FCOGL_LAM_NONE                             = "-None-",

    FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO             = "Chat output too (LibDebugLogger)",
    FCOGL_LAM_DEBUG_CHAT_OUTPUT_TOO_TT          = "If LibDebugLogger is enabled the logging will only be shown in the UI DebugLogViewer, or within the SavedVariables file LibDebugLogger.lua.\nIf you enable the setting there also will be a chat output shown for you, but only if:\n|c5F5F5F\'LibDebugLogger\' is loaded AND \'DebugLogViewer\' is currently not loaded|r.",

    FCOGL_CHAT_EDITBOX_TEXT_TEMPLATE_DEFAULT    = "#<<1>>, congratulations to \'<<C:2>>\'",
    FCOGL_GUILD_NAME_SHORT                      = "Guild name: %s",
    FCOGL_GUILD_NAME_LONG                       = "Guild name of guild no %s (server-wide unique ID: %s): %s",
    FCOGL_GUILD_INFO_ROW_1                      = "GuildInfo about your guild no. %s (server-wide unique ID: %s), name: %s",
    FCOGL_GUILD_INFO_ROW_2                      = ">Leader name: %s / Open invitations: %s",
    FCOGL_GUILD_INFO_ROW_3                      = ">Member count: %s / Currently online: %s",

    --Date & time formats
    FCOGL_DATTIME_FORMAT_24HOURS                = "%d.%m.%y, %H:%M:%S",
    FCOGL_DATTIME_FORMAT_12HOURS                = "%y-%m-%d, %I:%M:%S %p",

    --Errors
    FCOGL_ERROR_SELECTED_GUILD_INVALID          = "The selected guild does not seem be valid. Please select the guild from the guilds dropdown box.",
    FCOGL_ERROR_NO_GUILD_ONLY_GENERIC_DICE_THROW= "Please select a guild from the guilds dropdown box!\nElse you are only able to use the dice button/use the slash command /dice to throw a random dice throw with the sides you have defined at the editbox next to the button/at the normal dice settings.",
    FCOGL_ERROR_GUILD_SALES_LOTTERY_PARAMETERS_MISSING = "Please use the slash command /gslnew <guildIndex> <daysBeforeCurrent> to start a new guild sales lottery.\nReplace <guildIndex> with the index 1 to 5 of your guilds, and optionally replace <daysBeforeCurrent> with the count of days you want to build the ranking of the guild sales lottery for.\nIf this 2nd parameter is left empty \'%s days\' will be used as default value.\n\nAfter starting a new guild sales lottery via /gslnew you can use /gsl to throw the next dice.",
    FCOGL_ERROR_GUILD_MEMBERS_JOIN_DATE_LIST_PARAMETERS_MISSING = "Please use the slash command /gmjnew <guildIndex> <daysBeforeCurrent> to start a new guild members joined list.\nReplace <guildIndex> with the index 1 to 5 of your guilds, and optionally replace <daysBeforeCurrent> with the count of days you want to build the ranking of the guild members joined list for.\nIf this 2nd parameter is left empty \'%s days\' will be used as default value.\n\nAfter starting a new guild members joined list via /gmjnew you can use /gmj to throw the next dice.",

    FCOGL_ERROR_GUILD_GOT_NO_TRADER             = "Either you are not a member of the guild \'%s\' aymore, or this guild does not use a trader.",
    FCOGL_ERROR_GUILD_MEMBER_JOINED_COUNT       = "The count of members who joined the guild #%s \'%s\' (ID: %s) during the selected timeframe is 0.\nPlease try to manually update the guild history via the \'Get more\' keybind at the guild's history. Also check if LibHistoire is still fetching data or if it is fully linked and updated.",
    FCOGL_ERROR_GUILD_MEMBER_COUNT              = "The count of members having sold any items, for the guild #%s \'%s\' (ID: %s) is 0.\nEither no items were sold in the selected timeframe, or there occured an error!\nPlease try to manually update the guild history via the \'Get more\' keybind at the guild's history. Also check if LibHistoire is still fetching data or if it is fully linked and updated.",
    FCOGL_ERROR_GUILD_LISTENER_STILL_FETCHING_EVENTS = "The listener for the guild #%s \'%s\' (ID: %s) is still fetching events...\nPlease wait (could take minutes), or open the guild history of that guild and manually press the \'Get more\' keybind to fetch more events, until all missing ones were added!\nThis is only working if the mising data is a small timeframe like 2-10 days.\nAlso check if LibHistoire is still fetching data or if it is fully linked and updated.",

    --Keybindings
    SI_BINDING_NAME_FCOGL_TOGGLE                = "Toggle FCO GuildLottery UI",
    SI_BINDING_NAME_FCOGL_ROLL_THE_DICE         = "Roll dice with def. sides",
    SI_BINDING_NAME_FCOGL_ROLL_THE_DICE_FOR_GUILD_SALES = "Start lottery/Roll dice",
    SI_BINDING_NAME_FCOGL_RESET_GUILD_SALES     = "Reset guild sales lottery",
    SI_BINDING_NAME_FCOGL_STOP_GUILD_SALES      = "Stop guild sales lottery",


    FCOGL_RELOADUI_WARNING_WITH_TEXT            = "<<========== ERROR ==========>>\nYou did not do a /reloadui after changing \'%s\' in the settings/via slash command!\nPlease reload the UI now!",
    FCOGL_RELOADUI_DAYSBEFORE                   = " the days before value"
}
local langEn = FCOGuildLottery.lang["en"]

for stringId, stringValue in pairs(langEn) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end