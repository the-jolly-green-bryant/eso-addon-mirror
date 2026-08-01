-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english, so the file en.lua shuld be kept empty!
rChat_localization_strings = rChat_localization_strings  or {}

rChat_localization_strings["en"] = {

	-- ************************************************
	-- Chat tab selector Bindings
	-- ************************************************
	RCHAT_Tab1 = "Select Chat Tab 1",
	RCHAT_Tab2 = "Select Chat Tab 2",
	RCHAT_Tab3 = "Select Chat Tab 3",
	RCHAT_Tab4 = "Select Chat Tab 4",
	RCHAT_Tab5 = "Select Chat Tab 5",
	RCHAT_Tab6 = "Select Chat Tab 6",
	RCHAT_Tab7 = "Select Chat Tab 7",
	RCHAT_Tab8 = "Select Chat Tab 8",
	RCHAT_Tab9 = "Select Chat Tab 9",
	RCHAT_Tab10 = "Select Chat Tab 10",
	RCHAT_Tab11 = "Select Chat Tab 11",
	RCHAT_Tab12 = "Select Chat Tab 12",

	-- 9.3.6.24 Additions
	RCHAT_CHATTABH = "Chat Tab Settings",
	RCHAT_enableChatTabChannel = "Enable Last Used Channel Per Tab",
	RCHAT_enableChatTabChannelT = "Enable chat tabs to remember the last used channel, it will become the default until you opt to use a different one in that tab.",
	RCHAT_enableWhisperTab = "Enable Whisper Redirect",
	RCHAT_enableWhisperTabT = "Enable redirect your whispers to a specific tab.",

	RCHAT_OPTIONSH = "Messages Settings",
	RCHAT_FRIENDSTATUS = "Enable display of Friend status messages.",
	
	RCHAT_GUILDNUMBERS = "Guild numbers",
	RCHAT_GUILDNUMBERSTT = "Shows the guild number next to the guild tag",

	RCHAT_ALLGUILDSSAMECOLOUR = "Use same color for all guilds",
	RCHAT_ALLGUILDSSAMECOLOURTT = "Makes all guild chats use the same color as /guild1",

	RCHAT_ALLZONESSAMECOLOUR = "Use same color for all zone chats",
	RCHAT_ALLZONESSAMECOLOURTT = "Makes all zone chats use the same color as /zone",

	RCHAT_ALLNPCSAMECOLOUR = "Use same color for all NPC lines",
	RCHAT_ALLNPCSAMECOLOURTT = "Makes all NPC lines use the same color as NPC say",

	RCHAT_DELZONETAGS = "Remove zone tags",
	RCHAT_DELZONETAGSTT = "Remove tags such as says, yells at the beginning of the message",

	RCHAT_ZONETAGSAY = "says",
	RCHAT_ZONETAGYELL = "yells",
	RCHAT_ZONETAGPARTY = "Group",
	RCHAT_ZONETAGZONE = "zone",

	RCHAT_CARRIAGERETURN = "Newline between name and message",
	RCHAT_CARRIAGERETURNTT = "Player names and chat texts are separated by a newline.",

	RCHAT_USEESOCOLORS = "Use ESO colors",
	RCHAT_USEESOCOLORSTT = "Use colors set in social settings instead rChat ones",

	RCHAT_DIFFFORESOCOLORS = "Difference between ESO colors",
	RCHAT_DIFFFORESOCOLORSTT = "If using ESO colors and Use two colors option, you can adjust brightness difference between player name and message displayed",

	RCHAT_REMOVECOLORSFROMMESSAGES = "Remove colors from messages",
	RCHAT_REMOVECOLORSFROMMESSAGESTT = "Stops people using things like rainbow colored text",

	RCHAT_PREVENTCHATTEXTFADING = "Prevent chat text fading",
	RCHAT_PREVENTCHATTEXTFADINGTT = "Prevents the chat text from fading (you can prevent the BG from fading in the Social options",

	RCHAT_AUGMENTHISTORYBUFFER = "Augment # of lines displayed in chat",
	RCHAT_AUGMENTHISTORYBUFFERTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines",

	RCHAT_USEONECOLORFORLINES = "Use one color for lines",
	RCHAT_USEONECOLORFORLINESTT = "Instead of having two colors per channel, only use 1st color",

	RCHAT_GUILDTAGSNEXTTOENTRYBOX = "Guild tags next to entry box",
	RCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Show the guild tag instead of the guild name next to where you type",

	RCHAT_DISABLEBRACKETS = "Remove brackets around names",
	RCHAT_DISABLEBRACKETSTT = "Remove the brackets [] around player names",

	RCHAT_DEFAULTCHANNEL = "Default channel",
	RCHAT_DEFAULTCHANNELTT = "Select which channel to use at login",

	RCHAT_DEFAULTCHANNELCHOICE99 = "Do not change",
	RCHAT_DEFAULTCHANNELCHOICE31 = "/zone",
	RCHAT_DEFAULTCHANNELCHOICE0 = "/say",
	RCHAT_DEFAULTCHANNELCHOICE12 = "/guild1",
	RCHAT_DEFAULTCHANNELCHOICE13 = "/guild2",
	RCHAT_DEFAULTCHANNELCHOICE14 = "/guild3",
	RCHAT_DEFAULTCHANNELCHOICE15 = "/guild4",
	RCHAT_DEFAULTCHANNELCHOICE16 = "/guild5",
	RCHAT_DEFAULTCHANNELCHOICE17 = "/officer1",
	RCHAT_DEFAULTCHANNELCHOICE18 = "/officer2",
	RCHAT_DEFAULTCHANNELCHOICE19 = "/officer3",
	RCHAT_DEFAULTCHANNELCHOICE20 = "/officer4",
	RCHAT_DEFAULTCHANNELCHOICE21 = "/officer5",

	RCHAT_GEOCHANNELSFORMAT = "Names format",
	RCHAT_GEOCHANNELSFORMATTT = "Names format for local channels (say, zone, tell)",

	RCHAT_DEFAULTTAB = "Default tab",
	RCHAT_DEFAULTTABTT = "Select which tab to display at startup",

	RCHAT_ADDCHANNELANDTARGETTOHISTORY = "Switch channel when using history",
	RCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Switch the channel when using arrow keys to match the channel previously used.",

	RCHAT_URLHANDLING = "Detect and make URLs linkable",
	RCHAT_URLHANDLINGTT = "If a URL starting with http(s):// is linked in chat rChat will detect it and you'll be able to click on it to directly go on the concerned link with your system browser",

	RCHAT_ENABLECOPY = "Enable copy",
	RCHAT_ENABLECOPYTT = "Enable copy with a right click on text - Also enable the channel switch with a left click. Disable this option if you got problems to display links in chat",


	-- Group Settings

	RCHAT_GROUPH = "Group channel tweaks",

	RCHAT_ENABLEPARTYSWITCH = "Enable Group Switch",
	RCHAT_ENABLEPARTYSWITCHTT = "Enabling Group switch will switch your current channel to group when joining a group and  switch back to your default channel when leaving a group",

	RCHAT_GROUPLEADER = "Special color for group leader",
	RCHAT_GROUPLEADERTT = "Enabling this feature will let you set a special color for group leader messages",

	RCHAT_GROUPLEADERCOLOR = "Group leader color",
	RCHAT_GROUPLEADERCOLORTT = "Color of group leader messages. 2nd color is only to set if \"Use ESO colors\" is set to Off",

	RCHAT_GROUPLEADERCOLOR1 = "Color of messages for Group leader",
	RCHAT_GROUPLEADERCOLOR1TT = "Color of message for group leader. If \"Use ESO colors\" is set to Off, this option will be disabled. The color of the group leader will be the one set above and the group leader messages will be this one",

	RCHAT_GROUPNAMES = "Names format for groups",
	RCHAT_GROUPNAMESTT = "Format of your groupmates names in group channel",

	RCHAT_GROUPNAMESCHOICE1 = "@UserID",
	RCHAT_GROUPNAMESCHOICE2 = "Character Name",
	RCHAT_GROUPNAMESCHOICE3 = "Character Name@UserID",
	RCHAT_GROUPNAMESCHOICE4 = "Character Name(@UserID)",
	RCHAT_GROUPNAMESCHOICE5 = "Character Name/@UserID",

	-- Sync settings

	RCHAT_SYNCH = "Syncing settings",

	RCHAT_CHATSYNCCONFIG = "Sync chat configuration",
	RCHAT_CHATSYNCCONFIGTT = "If the sync is enabled, all your chars will get the same chat configuration (colors, position, window dimensions, tabs)\nPS: Only enable this option after your chat is fully customized !",

	RCHAT_CHATSYNCCONFIGIMPORTFROM = "Import chat settings from",
	RCHAT_CHATSYNCCONFIGIMPORTFROMTT = "You can at any time import chat settings from another character (colors, position, window dimensions, tabs)",

	-- Apparence

	RCHAT_APPEARANCEMH = "Chat window settings",

	RCHAT_WINDOWDARKNESS = "Chat window transparency",
	RCHAT_WINDOWDARKNESSTT = "Increase the darkening of the chat window",

	RCHAT_CHATMINIMIZEDATLAUNCH = "Chat minimized at startup",
	RCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimize chat window on the left side of the screen when the game starts",

	RCHAT_CHATMINIMIZEDINMENUS = "Chat minimized in menus",
	RCHAT_CHATMINIMIZEDINMENUSTT = "Minimize chat window on the left of the screen when you enter in menus (Guild, Stats, Crafting, etc)",

	RCHAT_CHATMAXIMIZEDAFTERMENUS = "Restore chat after exiting menus",
	RCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Always restore the chat window after exiting menus",

	RCHAT_FONTCHANGE = "Chat Font",
	RCHAT_FONTCHANGETT = "Set the Chat font",

	RCHAT_TABWARNING = "New message warning",
	RCHAT_TABWARNINGTT = "Set the warning color for tab name",

	-- Whisper settings

	RCHAT_IMH = "Whispers",

	RCHAT_WHISPSOUND_ENABLED = "Enable sound for whispers",
	RCHAT_SOUNDFORINCWHISPS = "Sound for incoming whisps",
	RCHAT_SOUNDFORINCWHISPSTT = "Choose sound wich will be played when you receive a whisp",

	RCHAT_NOTIFYIM = "Visual notification",
	RCHAT_NOTIFYIMTT = "If you miss a whisp, a notification will appear in the top right corner of the chat allowing you to quickly access to it. Plus, if your chat was minimized at that time, a notification will be displayed in the minibar",

	-- Restore chat settings

	RCHAT_RESTORECHATH = "Restore chat",

	RCHAT_RESTOREONRELOADUI = "After a ReloadUI",
	RCHAT_RESTOREONRELOADUITT = "After reloading game with a ReloadUI(), rChat will restore your chat and its history",

	RCHAT_RESTOREONLOGOUT = "After a LogOut",
	RCHAT_RESTOREONLOGOUTTT = "After a logoff, rChat will restore your chat and its history if you login in the allotted time set under",

	RCHAT_RESTOREONAFK = "After being kicked",
	RCHAT_RESTOREONAFKTT = "After being kicked from game after inactivity, flood or a network disconnect, rChat will restore your chat and its history if you login in the allotted time set under",

	RCHAT_RESTOREONQUIT = "After leaving game",
	RCHAT_RESTOREONQUITTT = "After leaving game, rChat will restore your chat and its history if you login in the allotted time set under",

	RCHAT_TIMEBEFORERESTORE = "Maximum time for restoring chat",
	RCHAT_TIMEBEFORERESTORETT = "After this time (in hours), rChat will not attempt to restore the chat",

	RCHAT_RESTORESYSTEM = "Restore System Messages",
	RCHAT_RESTORESYSTEMTT = "Restore System Messages (Such as login notifications or add ons messages) when chat is restored",

	RCHAT_RESTORESYSTEMONLY = "Restore Only System messages",
	RCHAT_RESTORESYSTEMONLYTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored",

	RCHAT_RESTOREWHISPS = "Restore Whispers",
	RCHAT_RESTOREWHISPSTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()",

	RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT  = "Restore Text entry history",
	RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()",

	-- Anti Spam settings

	RCHAT_ANTISPAMH = "Anti-Spam",

	RCHAT_FLOODPROTECT = "Enable anti-flood",
	RCHAT_FLOODPROTECTTT = "Prevents the players close to you from sending identical and repeated messages",

	RCHAT_FLOODGRACEPERIOD = "Duration of anti-flood banishment",
	RCHAT_FLOODGRACEPERIODTT = "Number of seconds while the previous identical message will be ignored",

	RCHAT_LOOKINGFORPROTECT = "Ignore grouping messages",
	RCHAT_LOOKINGFORPROTECTTT = "Ignore the messages players seeking to establish / join group",

	RCHAT_WANTTOPROTECT = "Ignore Commercial messages",
	RCHAT_WANTTOPROTECTTT = "Ignore messages from players looking to buy, sell or trade",
	
	RCHAT_PRICEPROTECT = "Ignore Price Check messages",
	RCHAT_PRICEPROTECTTT = "Ignore messages from players looking for or responding to price checks",

	RCHAT_GUILDPROTECT = "Ignore Guild Recruiting messages",
	RCHAT_GUILDPROTECTTT = "Ignore messages from players promoting Guild memberships",

	RCHAT_SPAMGRACEPERIOD = "Temporarily stopping the spam",
	RCHAT_SPAMGRACEPERIODTT = "When you make yourself a research group message or trade, spam temporarily disables the function you have overridden the time to have an answer. It reactivates automatically after a period that can be set (in minutes)",

	-- Nicknames settings

	RCHAT_NICKNAMESH = "Nicknames",
	RCHAT_NICKNAMESD = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",
	RCHAT_NICKNAMES = "List of Nicknames",
	RCHAT_NICKNAMESTT = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",

	-- Timestamp settings

	RCHAT_TIMESTAMPH = "Timestamp",

	RCHAT_ENABLETIMESTAMP = "Enable timestamp",
	RCHAT_ENABLETIMESTAMPTT = "Adds a timestamp to chat messages",

	RCHAT_TIMESTAMPCOLORISLCOL = "Timestamp color same as player one",
	RCHAT_TIMESTAMPCOLORISLCOLTT = "Ignore timestamp color and colorize timestamp same as player / NPC name",

	RCHAT_TIMESTAMPFORMAT = "Timestamp format",
	RCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: hours (24)\nhh: hours (12)\nH: hour (24, no leading 0)\nh: hour (12, no leading 0)\nA: AM/PM\na: am/pm\nm: minutes\ns: seconds",

	RCHAT_TIMESTAMP = "Timestamp",
	RCHAT_TIMESTAMPTT = "Set color for the timestamp",

	-- Guild settings
    RCHAT_GUILDOPT = "Guild Settings",

	RCHAT_NICKNAMEFOR = "Nickname",
	RCHAT_NICKNAMEFORTT = "Nickname for ",

	RCHAT_OFFICERTAG = "Officer chat tag",
	RCHAT_OFFICERTAGTT = "Prefix for Officers chats",

	RCHAT_SWITCHFOR = "Switch for channel",
	RCHAT_SWITCHFORTT = "New switch for channel. Ex: /myguild",

	RCHAT_OFFICERSWITCHFOR = "Switch for officer channel",
	RCHAT_OFFICERSWITCHFORTT = "New switch for officer channel. Ex: /offs",

	RCHAT_NAMEFORMAT = "Name format",
	RCHAT_NAMEFORMATTT = "Select how guild member names are formatted",

	RCHAT_FORMATCHOICE1 = "@UserID",
	RCHAT_FORMATCHOICE2 = "Character Name",
	RCHAT_FORMATCHOICE3 = "Character Name@UserID",
	RCHAT_FORMATCHOICE4 = "Character Name(@UserID)",
	RCHAT_FORMATCHOICE5 = "Character Name/@UserID",

	RCHAT_SETCOLORSFORTT = "Set colors for members of <<1>>",
	RCHAT_SETCOLORSFORCHATTT = "Set colors for messages of <<1>>",

	RCHAT_SETCOLORSFOROFFICIERSTT = "Set colors for members of Officer chat of <<1>>",
	RCHAT_SETCOLORSFOROFFICIERSCHATTT = "Set colors for messages of Officer chat of <<1>>",

	RCHAT_MEMBERS = "<<1>> - Players",
	RCHAT_CHAT = "<<1>> - Messages",

	RCHAT_OFFICERSTT = " Officers",

	-- Channel colors settings

	RCHAT_COLORSH = "Colors Settings",
	RCHAT_CHATCOLORSH = "Chat Colors",
	RCHAT_CHATCOLORTT = "",

	RCHAT_SAY = "Say - Player",
	RCHAT_SAYTT = "Set player color for say channel",

	RCHAT_SAYCHAT = "Say - Chat",
	RCHAT_SAYCHATTT = "Set chat color for say channel",

	RCHAT_ZONE = "Zone - Player",
	RCHAT_ZONETT = "Set player color for zone channel",

	RCHAT_ZONECHAT = "Zone - Chat",
	RCHAT_ZONECHATTT = "Set chat color for zone channel",

	RCHAT_YELL = "Yell - Player",
	RCHAT_YELLTT = "Set player color for yell channel",

	RCHAT_YELLCHAT = "Yell - Chat",
	RCHAT_YELLCHATTT = "Set chat color for yell channel",

	RCHAT_INCOMINGWHISPERS = "Incoming whispers - Player",
	RCHAT_INCOMINGWHISPERSTT = "Set player color for incoming whispers",

	RCHAT_INCOMINGWHISPERSCHAT = "Incoming whispers - Chat",
	RCHAT_INCOMINGWHISPERSCHATTT = "Set chat color for incoming whispers",

	RCHAT_OUTGOINGWHISPERS = "Outgoing whispers - Player",
	RCHAT_OUTGOINGWHISPERSTT = "Set player color for outgoing whispers",

	RCHAT_OUTGOINGWHISPERSCHAT = "Outgoing whispers - Chat",
	RCHAT_OUTGOINGWHISPERSCHATTT = "Set chat color for outgoing whispers",

	RCHAT_GROUP = "Group - Player",
	RCHAT_GROUPTT = "Set player color for group chat",

	RCHAT_GROURCHAT = "Group - Chat",
	RCHAT_GROURCHATTT = "Set chat color for group chat",

	-- Other colors

	RCHAT_OTHERCOLORSH = "Other Colors",
	RCHAT_OTHERCOLORTT = "",

	RCHAT_EMOTES = "Emotes - Player",
	RCHAT_EMOTESTT = "Set player color for emotes",

	RCHAT_EMOTESCHAT = "Emotes - Chat",
	RCHAT_EMOTESCHATTT = "Set chat color for emotes",

	RCHAT_LANGZONEH = "Language Zones",
	RCHAT_ENZONE = "EN Zone - Player",
	RCHAT_ENZONETT = "Set player color for English zone channel",

	RCHAT_ENZONECHAT = "EN Zone - Chat",
	RCHAT_ENZONECHATTT = "Set chat color for English zone channel",

	RCHAT_FRZONE = "FR Zone - Player",
	RCHAT_FRZONETT = "Set player color for French zone channel",

	RCHAT_FRZONECHAT = "FR Zone - Chat",
	RCHAT_FRZONECHATTT = "Set chat color for French zone channel",

	RCHAT_DEZONE = "DE Zone - Player",
	RCHAT_DEZONETT = "Set player color for German zone channel",

	RCHAT_DEZONECHAT = "DE Zone - Chat",
	RCHAT_DEZONECHATTT = "Set chat color for German zone channel",

	RCHAT_JPZONE = "JP Zone - Player",
	RCHAT_JPZONETT = "Set player color for Japanese zone channel",

	RCHAT_JPZONECHAT = "JP Zone - Chat",
	RCHAT_JPZONECHATTT = "Set chat color for Japanese zone channel",

	RCHAT_RUZONE = "RU Zone - Player",
	RCHAT_RUZONETT = "Set player color for Russian zone channel",

	RCHAT_RUZONECHAT = "RU Zone - Chat",
	RCHAT_RUZONECHATTT = "Set chat color for Russian zone channel",

	RCHAT_ESZONE = "ES Zone - Player",
	RCHAT_ESZONETT = "Set player color for Spanish zone channel",

	RCHAT_ESZONECHAT = "ES Zone - Chat",
	RCHAT_ESZONECHATTT = "Set chat color for Spanish zone channel",

	RCHAT_ZHZONE = "ZH-Han Zone - Player",
	RCHAT_ZHZONETT = "Set player color for Simplified Chinese zone channel",

	RCHAT_ZHZONECHAT = "ZH-Han Zone - Chat",
	RCHAT_ZHZONECHATTT = "Set chat color for Simplified Chinese zone channel",

	RCHAT_NPC = "NPC",
	RCHAT_NPCSAY = "NPC Say - NPC name",
	RCHAT_NPCSAYTT = "Set NPC name color for NPC say",

	RCHAT_NPCSAYCHAT = "NPC Say - Chat",
	RCHAT_NPCSAYCHATTT = "Set NPC chat color for NPC say",

	RCHAT_NPCYELL = "NPC Yell - NPC name",
	RCHAT_NPCYELLTT = "Set NPC name color for NPC yell",

	RCHAT_NPCYELLCHAT = "NPC Yell - Chat",
	RCHAT_NPCYELLCHATTT = "Set NPC chat color for NPC yell",

	RCHAT_NPCWHISPER = "NPC Whisper - NPC name",
	RCHAT_NPCWHISPERTT = "Set NPC name color for NPC whisper",

	RCHAT_NPCWHISPERCHAT = "NPC Whisper - Chat",
	RCHAT_NPCWHISPERCHATTT = "Set NPC chat color for NPC whisper",

	RCHAT_NPCEMOTES = "NPC Emotes - NPC name",
	RCHAT_NPCEMOTESTT = "Set NPC name color for NPC emotes",

	RCHAT_NPCEMOTESCHAT = "NPC Emotes - Chat",
	RCHAT_NPCEMOTESCHATTT = "Set NPC chat color for NPC emotes",

	-- Various strings not in panel settings

	RCHAT_COPYXMLTITLE = "Copy text with Ctrl+C",
	RCHAT_COPYXMLLABEL = "Copy text with Ctrl+C",
	RCHAT_COPYXMLTOOLONG = "Text is too long and is splitted",
	RCHAT_COPYXMLNEXT = "Next",

	RCHAT_COPYMESSAGECT = "Copy message",
	RCHAT_COPYLINECT = "Copy line",
	RCHAT_COPYDISCUSSIONCT = "Copy channel talk",
	RCHAT_ALLCT = "Copy whole chat",

	RCHAT_SWITCHTONEXTTABBINDING = "Switch to next tab",
	RCHAT_TOGGLECHATBINDING = "Toggle Chat Window",
	RCHAT_WHISPMYTARGETBINDING = "Whisper my target",

	RCHAT_SAVMSGERRALREADYEXISTS = "Cannot save your message, this one already exists",
	RCHAT_RCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the beginning of the message (ex: |cFFFFFF/g1|r)",
	RCHAT_RCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message",
	RCHAT_RCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message",
	RCHAT_RCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message",
	RCHAT_RCHAT_AUTOMSG_ADD_AUTO_MSG = "Add",
	RCHAT_RCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit",
	RCHAT_SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG = "Automated messages",
	RCHAT_RCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove",

	RCHAT_CLEARBUFFER = "Clear chat",
	RCHAT_CLEARCACHE = "Clear history",
	RCHAT_CLEARCACHE_TT = "Empty out the chat history so that it cannot be restored to before this point.",

    RCHAT_MENTION_NM = "Mention Notification",
    RCHAT_MENTION_ENABLED = "Enable mention detection in chat",
	RCHAT_MENTION_EMOTE_ENABLED = "Add mention detection for emotes",
	RCHAT_MENTION_EMOTE_ENABLED_TT = "Can be slow!",
    RCHAT_MENTIONSTR = "String to look for in chat",
    RCHAT_SOUND_ENABLED = "Enable sound notification",
    RCHAT_SOUND_INDEX = "Which sound to play",
    RCHAT_COLOR_ENABLED = "Enable color highlighting",
    RCHAT_MENTIONCOLOR = "Highlight color to use",
    RCHAT_SOUND_NAME = "Name of current Sound",

	RCHAT_DISABLELOGGER = "Disable LibDebugLogger chat blocking",
	RCHAT_DISABLELOGGERTT = "Disable LibDebugLogger's blocking of SYSTEM messages in chat",
	
	RCHAT_ANNOUNCE_ZONE = "Announce zone in chat",
	RCHAT_ANNOUNCE_ZONETT = "Announce arrival to a zone in chat",
	
}
