local localization =
{	
	-- Translation by @peniku8
  -- Settings menu
    
  -- PresetManager submenu
    AR_STR_NEW_PRESET               = "Make new preset",                                                                                                                                                                                                                                                                                                                                               
    AR_STR_NEW_PRESET_TT            = "Create a new settings preset",
    AR_STR_NEW_PRESET_ERROR         = "|cFFFFFFGive your new preset a name first.",
    AR_STR_RELOADUI_WARNING         = "Will reload the UI",
    AR_STR_PRESET_NAME              = "Preset name:",
    AR_STR_PRESET_NAME_TT           = "Give your new preset a name",
    AR_STR_DELETE_PRESET            = "Delete current preset",
    
  -- Rank submenu
    AR_STR_ENABLED                  = "Enabled",
    AR_STR_ENABLED_TT               = "Move members to or from this rank",
    AR_STR_NEW_MEMBER               = "New member rank",
    AR_STR_NEW_MEMBER_TT            = "Don't demote any players back to this rank",
    AR_STR_RANK_PERIOD              = "Rank period",
    AR_STR_RANK_PERIOD_TT           = "Promote members from this rank to the next rank after a set amount of days\nOnly works when 'New member rank' and the next rank are enabled",
    AR_STR_PERMANENT_RANK           = "Permanent rank",
    AR_STR_PERMANENT_RANK_TT        = "Don't demote any players from this rank",
    AR_STR_SALES_REQUIREMENT        = "Sales requirement",
    AR_STR_SALES_REQUIREMENT_TT     = "Set the sales threshold to assign members to this rank\nNo input=drain only\n0=lowest rank for a demotion",
    AR_STR_DONATION_REQUIREMENT     = "Donation requirement",
    AR_STR_DONATION_REQUIREMENT_TT  = "Set the donation threshold to assign members to this rank\nNo input=drain only\n0=lowest rank for a demotion",
    AR_STR_MEET_BOTH						    = "Meet both",
    AR_STR_MEET_BOTH_TT 						= "Requires a player to meet both the sales and the donations requirement to be moved to this rank.\nIf this is disabled, a player will be moved to this rank once they meet either of the two.",
    
  -- Message submenu
    AR_STR_DESC_1                   = "You can add dynamic values to the message:\n#SALES - inserts the sales stats based on the time frame specified above\n#DONATIONS - inserts the donation stats based on the time frame above",
    AR_STR_DESC_2                   = "The message settings are unaffected by presets.\nNote: The message previews require you to reload the UI to update.",
    AR_STR_MAIL                     = " mail",
    AR_STR_MAIL_TT_1                = "Send a mail to members, who have been promoted from ",
    AR_STR_MAIL_TT_2                = "|r to ",
    AR_STR_MAIL_TT_3                = "",
    AR_STR_SUBJECT                  = "Subject",
    AR_STR_MESSAGE_TEXT             = "Message text",
    AR_STR_SEND_DEMOTE_MAIL_TT      = "Send a mail to members, after they've been demoted to ",
    AR_STR_SEND_DEMOTE_MAIL_TT_2    = "",
    
  -- Advanced submenu
    AR_STR_ADVANCED_SETTINGS        = "Advanced settings",
    AR_STR_NOTE_IMMUNITY            = "Note immunity",
    AR_STR_NOTE_IMMUNITY_TT         = "Ignore members, if a keyword is found in their note.\nIf no keyword is specified below, all players with a note will be ignored.",
    AR_STR_NOTE_KEY                 = "Note keyword",
    AR_STR_DEMOTE_CAP               = "Maximum demotions",
    AR_STR_DEMOTE_CAP_TT            = "Specifies the maximum number of ranks a player can be demoted at once",
    AR_STR_RESTORE_RANK             = "Restore rank",
    AR_STR_RESTORE_RANK_TT          = "Restores the rank of a player found in Auto Kick's list of saved players to their original rank (e.g. a previously inactive lifetime member rejoining)",
    
  -- Main menu
    AR_STR_PROCESS                  = "Process Guilds",
    AR_STR_PROCESS_TT               = "Start the promotion/demotion process for all enabled guilds",
    AR_STR_CHAT_NOTIF               = "Display Chat Notifications",
    AR_STR_LOAD_PRESET              = "Load preset",
    AR_STR_LOAD_PRESET_TT           = "Load a settings preset from the dropdown menu",
    AR_STR_LOAD_PRESET_HINT         = "|cFFFFFFSelect a preset you want to load first.",
    AR_STR_PRESET_MANAGER           = "Preset Manager",
    
  -- Guild menu
    AR_STR_MM_INFO                  = "You can configure the custom sales time frame in MM settings",
    AR_STR_SALES_TIME               = "Sales time frame",
    AR_STR_CUSTOM_SALES             = "Custom sales time frame",
    AR_STR_CUSTOM_SALES_TT          = "Only for ATT. Set MM's custom time frame in MM's settings.",
    AR_STR_CUSTOM_DONATIONS         = "Donations time frame",
    AR_STR_TRACK_LAST               = "Track last donation",
    AR_STR_TRACK_LAST_TT            = "Calculates a 'current week donation' from the last donation to allow members to pay multiple weeks of fees in advance",
    AR_STR_TRACK_LAST_TIME          = "Last donation time frame",
    AR_STR_TRACK_LAST_TIME_TT       = "Time frame for the 'Track last donation' option",
    AR_STR_RANK_SETTINGS            = "Rank Settings",
    AR_STR_MESSAGE_SETTINGS         = "Message Settings",
    AR_STR_PROCESS_RANKS            = "Process ranks",
    AR_STR_GUILD_ACTIVATE           = "Activate Auto Ranks for ",
    AR_STR_PROMOTIONS_ONLY          = "Promotions only",
    AR_STR_NOGUILDS                 = "|cff4848No suitable guilds found. Check your permissions.",
    
    
  -- Chat notifications and other strings:
    
  -- Time frames
    AR_STR_THIS_WEEK                = "This week",
    AR_STR_LAST_WEEK                = "Last week",
    AR_STR_CUSTOM                   = "Custom",
    AR_STR_TWO_WEEKS                = "This+Last week",
    AR_STR_ALL                      = "All",
    
  -- Chat notifications
    AR_STR_CHAT_PRESET_ACTION       = "|c6C00FFAuto Ranks - |cFFFFFFPreset '",
    AR_STR_CHAT_PRESET_SAVED        = "'|cFFFFFF saved.",
    AR_STR_CHAT_PRESET_OVERWR       = "'|cFFFFFF overwritten.",
    AR_STR_CHAT_PRESET_ACTIVE       = "'|cFFFFFF is already active.",
    AR_STR_CHAT_PRESET_LOADED       = "'|cFFFFFF loaded.",
    AR_STR_CHAT_PRESET_DELETED      = "'|cFFFFFF deleted.",
    AR_STR_CHAT_RELOADUI            = "|cFFFFFFReloading UI...",
    AR_STR_CHAT_RELOADUI2           = "|cFFFFFFAn update was detected and this preset has to be reinitialized. Reloading UI...",
    AR_STR_AR                       = "|c6C00FFAuto Ranks - |cFFFFFF",
    AR_STR_CHAT_DELETE_WARNING      = "|cFFFFFFYou must load a preset first before you can delete it.",
    AR_STR_CHAT_PROCESSING          = "Processing ",
    AR_STR_CHAT_AMOUNT_PRESET       = " rank changes on preset '",
    AR_STR_CHAT_SINGLE_PRESET       = " rank change on preset '",
    AR_STR_CHAT_ZERO_PRESET         = "Nothing to do on preset '",
    AR_STR_CHAT_RANK_MANY           = " rank changes...",
    AR_STR_CHAT_RANK_ONE            = " rank change...",
    AR_STR_CHAT_NOTHING             = "Nothing to do...",
    AR_STR_CHAT_PROMOTED            = " promoted from ",
    AR_STR_CHAT_DEMOTED             = " demoted from ",
    AR_STR_CHAT_TO                  = "|cFFFFFF to ",
    AR_STR_CHAT_IN                  = "|cFFFFFF in ",
    AR_STR_CHAT_PM_SENT             = "|c82fa58 - Message sent",
    AR_STR_CHAT_DONE                = "DONE!",
    AR_STR_CHAT_PM_ALTERT           = "|cFFFFFFCan't send empty messages, check your settings.",
    AR_STR_CHAT_MM_ATT_MISSING      = "|c6C00FFAuto Ranks |cFFFFFFneeds MM or ATT to scan sales!",
    AR_STR_CHAT_AMT_ITT_MISSING     = "|c6C00FFAuto Ranks |cFFFFFFneeds AMT or ITT to operate properly!",
    AR_STR_CHAT_IGNORE              = " ignores you.",
    AR_STR_CHAT_FULLINBOX           = "'s inbox is full.",
    AR_STR_CHAT_MAILFAIL            = "Failed to send mails to ",
    AR_STR_CHAT_PLAYER              = " player.",
    AR_STR_CHAT_PLAYERS             = " players.",
    AR_STR_CHAT_IGNORELIST          = "|cFFFFFFThe following players ignore you:",
    AR_STR_CHAT_FULLINBOXLIST       = "|cFFFFFFThe following players had a full inbox:",
    AR_STR_CHAT_IDK                 = "|cFFFFFFThe following players couldn't be messaged due to an unexpected issue:",
    AR_STR_CHAT_WAITMM              = "Please wait for MM to finish initializing...",
    
  -- Other
    AR_STR_KEYBIND                  = "Start processing ranks",
    
}

ZO_ShallowTableCopy(localization, AutoRanks.Localization)