-- Messages settings
local strings = {
-- New May Need Translations
	-- ************************************************
	-- Chat tab selector Bindings
	-- ************************************************
	PCHAT_Tab1 = "Select Chat Tab 1",
	PCHAT_Tab2 = "Select Chat Tab 2",
	PCHAT_Tab3 = "Select Chat Tab 3",
	PCHAT_Tab4 = "Select Chat Tab 4",
	PCHAT_Tab5 = "Select Chat Tab 5",
	PCHAT_Tab6 = "Select Chat Tab 6",
	PCHAT_Tab7 = "Select Chat Tab 7",
	PCHAT_Tab8 = "Select Chat Tab 8",
	PCHAT_Tab9 = "Select Chat Tab 9",
	PCHAT_Tab10 = "Select Chat Tab 10",
	PCHAT_Tab11 = "Select Chat Tab 11",
	PCHAT_Tab12 = "Select Chat Tab 12",
	-- 9.3.6.24 Additions
	PCHAT_CHATTABH = "チャットタブ設定",
	PCHAT_enableChatTabChannel = "タブ毎の最後に使ったチャンネルを有効にする",
	PCHAT_enableChatTabChannelT = "Enable chat tabs to remember the last used channel, it will become the default until you opt to use a different one in that tab.",
	PCHAT_enableWhisperTab = "Enable Whisper Redirect",
	PCHAT_enableWhisperTabT = "Enable redirect your whispers to a specific tab.",
	
-- New Need Translations


	PCHAT_OPTIONSH = "チャット設定",
	PCHAT_MESSAGEOPTIONSH = "メッセージ設定",
	PCHAT_MESSAGEOPTIONSNAMEH = "メッセージ中の名前",
	PCHAT_MESSAGEOPTIONSNAME_ALLOTHERH = "その他",
	PCHAT_MESSAGEOPTIONSCOLORH = "メッセージの色",

	PCHAT_GUILDNUMBERS = "ギルド番号",
	PCHAT_GUILDNUMBERSTT = "ギルドタグ内にギルド番号を表示する",

	PCHAT_ALLGUILDSSAMECOLOUR = "全ギルドチャットに同じ色を使う",
	PCHAT_ALLGUILDSSAMECOLOURTT = "すべてのギルドチャットに \'%s\' と同じ色を使う",

	PCHAT_ALLZONESSAMECOLOUR = "全ゾーンチャットに同じ色を使う",
	PCHAT_ALLZONESSAMECOLOURTT = "すべてのゾーンチャットに /zoneと 同じ色を使う",

	PCHAT_ALLNPCSAMECOLOUR = "全NPC発言に同じ色を使う",
	PCHAT_ALLNPCSAMECOLOURTT = "すべてのNPC発言が NPC say と同じ色を使う",

	PCHAT_DELZONETAGS = "ゾーンタグを表示しない",
	PCHAT_DELZONETAGSTT = "メッセージの冒頭の say のようなタグを削除する。",

	PCHAT_ZONETAGSAY = "says",
	PCHAT_ZONETAGYELL = "yells",
	PCHAT_ZONETAGPARTY = "Group",
	PCHAT_ZONETAGZONE = "zone",

	PCHAT_CARRIAGERETURN = "名前とメッセージの行を分ける",
	PCHAT_CARRIAGERETURNTT = "Player names and chat texts are separated by a newline.",

	PCHAT_USEESOCOLORS = "ESOカラーを使う",
	PCHAT_USEESOCOLORSTT = "[設定 > ソーシャル] のカラーを使う",

	PCHAT_DIFFFORESOCOLORS = "Enable brightness difference",
	PCHAT_DIFFFORESOCOLORSTT = "Adjust brightness difference between player name/zone and message text displayed by this value (name will get darker / message text will get brighter).\nThis option is not working if you enable the option \'Use one color for lines\'!\nSet the slider to 0 to deactivate the brightness difference.",
	PCHAT_DIFFFORESOCOLORSDARKEN = "Brightness diff.: Darken by",
	PCHAT_DIFFFORESOCOLORSDARKENTT = "Darken the chat name by this value.",
	PCHAT_DIFFFORESOCOLORSLIGHTEN = "Brightness diff.: Brighten by",
	PCHAT_DIFFFORESOCOLORSLIGHTENTT = "Brighten the chat text by this value.",

	PCHAT_REMOVECOLORSFROMMESSAGES = "Remove colors from messages",
	PCHAT_REMOVECOLORSFROMMESSAGESTT = "Stops people using things like rainbow colored text",

	PCHAT_PREVENTCHATTEXTFADING = "チャットテキストのフェーディングをしない",
	PCHAT_PREVENTCHATTEXTFADINGTT = "Prevents the chat text from fading (you can prevent the BG from fading in the Social options",

	PCHAT_AUGMENTHISTORYBUFFER = "Augment # of lines displayed in chat",
	PCHAT_AUGMENTHISTORYBUFFERTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines",

	PCHAT_USEONECOLORFORLINES = "単色を使う",
	PCHAT_USEONECOLORFORLINESTT = "Instead of having two colors per channel, only use 1st color (the player color)",

	PCHAT_GUILDTAGSNEXTTOENTRYBOX = "Guild tags next to text box",
	PCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Show the guild tag instead of the guild name left of the chat's text entry box",

	PCHAT_DISABLEBRACKETS = "名前のカギ括弧を表示しない",
	PCHAT_DISABLEBRACKETSTT = "名前のカギ括弧 [] を表示しない",

	PCHAT_DEFAULTCHANNEL = "デフォルトチャンネル",
	PCHAT_DEFAULTCHANNELTT = "ログイン時のチャンネルを選択する",

	PCHAT_DEFAULTCHANNELCHOICE99 = "チャンネルを選択しない",
	PCHAT_DEFAULTCHANNELCHOICE31 = "/ゾーン",
	PCHAT_DEFAULTCHANNELCHOICE0 = "/話す",
	PCHAT_DEFAULTCHANNELCHOICE12 = "/ギルド1",
	PCHAT_DEFAULTCHANNELCHOICE13 = "/ギルド2",
	PCHAT_DEFAULTCHANNELCHOICE14 = "/ギルド3",
	PCHAT_DEFAULTCHANNELCHOICE15 = "/ギルド4",
	PCHAT_DEFAULTCHANNELCHOICE16 = "/ギルド5",
	PCHAT_DEFAULTCHANNELCHOICE17 = "/オフィサー",
	PCHAT_DEFAULTCHANNELCHOICE18 = "/オフィサー2",
	PCHAT_DEFAULTCHANNELCHOICE19 = "/オフィサー3",
	PCHAT_DEFAULTCHANNELCHOICE20 = "/オフィサー4",
	PCHAT_DEFAULTCHANNELCHOICE21 = "/オフィサー5",

	PCHAT_GEOCHANNELSFORMAT = "名前のフォーマット",
	PCHAT_GEOCHANNELSFORMATTT = "ローカルチャンネル(話す, ゾーン, ささやき)の名前のフォーマット",

	PCHAT_DEFAULTTAB = "デフォルト表示タブ",
	PCHAT_DEFAULTTABTT = "起動時に表示するタブを選択する",

	PCHAT_ADDCHANNELANDTARGETTOHISTORY = "Switch channel using arrow keys",
	PCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Switch the channel when using arrow keys to match the channel previously used.",

	PCHAT_URLHANDLING = "URLを検出してリンク可能にする",
	PCHAT_URLHANDLINGTT = "http(s):// で始まるURLを検出すると、そのURLをクリックしてWebブラウザを開く事が可能になります",

	PCHAT_ENABLECOPY = "コピー可能にする",
	PCHAT_ENABLECOPYTT = "テキストを右クリックしてコピーを有効に、左クリックでチャンネルスイッチを有効にします。 チャットでリンクを表示する際に問題が発生した場合は、このオプションを無効にしてください",

	-- Group Settings

	PCHAT_GROUPH = "グループチャンネル",

	PCHAT_ENABLEPARTYSWITCH = "グループ切り替えを有効にする",
	PCHAT_ENABLEPARTYSWITCHTT = "有効な場合、グループ参加時にチャンネルがグループに切り替わり、グループから出た時にデフォルトのチャンネルに切り替わります",

	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEON 	= "自動切替:ダンジョン/リロード",
	PCHAT_ENABLEPARTYSWITCHPORTTODUNGEONTT 	= "グループ参加中に、ダンジョンに移動/リロード/ログイン するとチャンネルがグループに切り替わります。\nこの設定は、グループ切り替えが有効になっている場合のみ有効になります!",

	PCHAT_GROUPLEADER = "リーダーを特殊カラーにする",
	PCHAT_GROUPLEADERTT = "有効な場合、グループリーダーのメッセージに特別な色を設定できます",

	PCHAT_GROUPLEADERCOLOR = "リーダーカラー",
	PCHAT_GROUPLEADERCOLORTT = "Color of party leader name.",

	PCHAT_GROUPLEADERCOLOR1 = "Leader message color",
	PCHAT_GROUPLEADERCOLOR1TT = "Color of message for party leader. If \"Use ESO colors\" is enabled this option will be disabled.",

	PCHAT_GROUPNAMES = "グループの名前フォーマット",
	PCHAT_GROUPNAMESTT = "Format of your groupmates names in party channel",

	-- Sync settings

	PCHAT_SYNCH = "同期設定",

	PCHAT_CHATSYNCCONFIG = "チャット設定を同期",
	PCHAT_CHATSYNCCONFIGTT = "同期が有効な場合、全キャラクターが同じ設定(色、位置、ウィンドウの大きさ、タブ)になります。\nPS:完全にカスタマイズした後に、このオプションを有効にしてください !",

	PCHAT_CHATSYNCCONFIGIMPORTFROM = "チャット設定をインポート",
	PCHAT_CHATSYNCCONFIGIMPORTFROMTT = "他のキャラクターからいつでもチャット設定をインポートできます(色、位置、ウィンドウの大きさ、タブ)。",

	-- Apparence

	PCHAT_APPARENCEMH = "チャットウィンドウ設定",

	PCHAT_WINDOWDARKNESS = "チャットウィンドウの透明度",
	PCHAT_WINDOWDARKNESSTT = "Increase the darkening of the chat window",

	PCHAT_CHATMINIMIZEDATLAUNCH = "開始時にチャットウィンドウを最小化する",
	PCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimize chat window on the left side of the screen when the game starts",

	PCHAT_CHATMINIMIZEDINMENUS = "メニュー時にチャットウィンドウを最小化する",
	PCHAT_CHATMINIMIZEDINMENUSTT = "Minimize chat window on the left of the screen when you enter in menus (Guild, Stats, Crafting, etc)",

	PCHAT_CHATMAXIMIZEDAFTERMENUS = "メニュー終了時にチャットウィンドウを戻す",
	PCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Always restore the chat window after exiting menus",

	PCHAT_FONTCHANGE = "フォント",
	PCHAT_FONTCHANGETT = "Set the Chat font",

	PCHAT_TABWARNING = "New message warning",
	PCHAT_TABWARNINGTT = "Set the warning color for tab name",

	-- Whisper settings

	PCHAT_IMH = "ささやき",

	PCHAT_SOUNDFORINCWHISPS = "ささやきの通知音",
	PCHAT_SOUNDFORINCWHISPSTT = "ささやきを受信したときに再生される音を選択します。",

	PCHAT_NOTIFYIM = "ビジュアルな通知",
	PCHAT_NOTIFYIMTT = "ささやきを見逃した場合は、チャットの右上に通知が表示され、すぐにアクセスできるようになります。さらに、その時にチャットが最小化されていた場合は、ミニバーに通知が表示されます。",

	PCHAT_SOUNDFORINCWHISPSCHOICE1 = "None",
	PCHAT_SOUNDFORINCWHISPSCHOICE2 = "Notification",
	PCHAT_SOUNDFORINCWHISPSCHOICE3 = "Click",
	PCHAT_SOUNDFORINCWHISPSCHOICE4 = "Write",

	-- Restore chat settings

	PCHAT_RESTORECHATH = "チャット履歴",

	PCHAT_RESTOREONRELOADUI = "リロード後に復元",
	PCHAT_RESTOREONRELOADUITT = "ReloadUI()でゲームをリロードした後、pChatはチャットとその履歴を復元します。",

	PCHAT_RESTOREONLOGOUT = "ログイン後に復元",
	PCHAT_RESTOREONLOGOUTTT = "ログオフした後、pChat は、設定された時間内にログインすると、チャットとその履歴を復元します。",

	PCHAT_RESTOREONAFK = "After being kicked",
	PCHAT_RESTOREONAFKTT = "After being kicked from game after inactivity, flood or a network disconnect, pChat will restore your chat and its history if you login in the allotted time set under",

	PCHAT_RESTOREONQUIT = "After leaving game",
	PCHAT_RESTOREONQUITTT = "After leaving game, pChat will restore your chat and its history if you login in the allotted time set under",

	PCHAT_TIMEBEFORERESTORE = "Maximum time for restoring chat",
	PCHAT_TIMEBEFORERESTORETT = "After this time (in hours), pChat will not attempt to restore the chat",

	PCHAT_RESTORESYSTEM = "Restore System Messages",
	PCHAT_RESTORESYSTEMTT = "Restore System Messages (Such as login notifications or add ons messages) when chat is restored",

	PCHAT_RESTORESYSTEMONLY = "Restore Only System messages",
	PCHAT_RESTORESYSTEMONLYTT = "Restore Only System Messages (Such as login notifications or add ons messages) when chat is restored",

	PCHAT_RESTOREWHISPS = "ささやきを復元",
	PCHAT_RESTOREWHISPSTT = "Restore whispers sent and received after logoff, disconnect or quit. Whispers are always restored after a ReloadUI()",

	PCHAT_RESTOREWHISPS_NO_NOTIFY = "No whisper notification on restore",
	PCHAT_RESTOREWHISPS_NO_NOTIFY_TT = "Do not show the whisper notifications, and do not color the chat tab for restored whisper messages.\nCan only be enabled if the whisper notifications are enabled.",

	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT  = "Restore Text entry history",
	PCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT  = "Restore Text entry history available with arrow keys after logoff, disconnect or quit. History of text entry is always restored after a ReloadUI()",

	-- Anti Spam settings

	PCHAT_ANTISPAMH = "スパム対策",

	PCHAT_FLOODPROTECT = "繰り返しメッセージ対応を有効にする",
	PCHAT_FLOODPROTECTTT = "自分の近くにいるプレイヤーが同じメッセージを繰り返すのを防ぎます",

	PCHAT_FLOODGRACEPERIOD = "繰り返しメッセージの期間",
	PCHAT_FLOODGRACEPERIODTT = "前の同一のメッセージが無視されるまでの秒数",

	PCHAT_LOOKINGFORPROTECT = "グループ発言を無視する",
	PCHAT_LOOKINGFORPROTECTTT = "グループを設立/参加しようとしているプレイヤーのメッセージを無視します。",

	PCHAT_WANTTOPROTECT = "売買メッセージを無視する",
	PCHAT_WANTTOPROTECTTT = "購入、売却、取引を希望するプレイヤーからのメッセージを無視します。",

	PCHAT_SPAMGRACEPERIOD = "Temporarily stopping the spam",
	PCHAT_SPAMGRACEPERIODTT = "When you make yourself a research group message or trade, spam temporarily disables the function you have overridden the time to have an answer. It reactivates automatically after a period that can be set (in minutes)",

	-- Nicknames settings

	PCHAT_NICKNAMESH = "Nicknames",
	PCHAT_NICKNAMESD = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",
	PCHAT_NICKNAMES = "ニックネーム一覧",
	PCHAT_NICKNAMESTT = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",

	-- Timestamp settings

	PCHAT_TIMESTAMPH = "時刻",

	PCHAT_ENABLETIMESTAMP = "時刻を有効にする",
	PCHAT_ENABLETIMESTAMPTT = "Adds a timestamp to chat messages",

	PCHAT_TIMESTAMPCOLORISLCOL = "時刻の色をプレイヤーの色と同じにする",
	PCHAT_TIMESTAMPCOLORISLCOLTT = "Ignore timestamp color and colorize timestamp same as player / NPC name",

	PCHAT_TIMESTAMPFORMAT = "時刻のフォーマット",
	PCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: hours (24)\nhh: hours (12)\nH: hour (24, no leading 0)\nh: hour (12, no leading 0)\nA: AM/PM\na: am/pm\nm: minutes\ns: seconds",

	PCHAT_TIMESTAMP = "時刻の色",
	PCHAT_TIMESTAMPTT = "Set color for the timestamp",

	-- Guild settings
	PCHAT_GUILDH = "ギルド",

	PCHAT_CHATCHANNELSH = "チャットチャンネル",

	PCHAT_NICKNAMEFOR = "ニックネーム",
	PCHAT_NICKNAMEFORTT = "Nickname for ",

	PCHAT_OFFICERTAG = "オフィサーチャットのタグ",
	PCHAT_OFFICERTAGTT = "Prefix for Officers chats",

	PCHAT_SWITCHFOR = "Switch for channel",
	PCHAT_SWITCHFORTT = "New switch for channel. Ex: /myguild",

	PCHAT_OFFICERSWITCHFOR = "Switch for officer channel",
	PCHAT_OFFICERSWITCHFORTT = "New switch for officer channel. Ex: /offs",

	PCHAT_NAMEFORMAT = "名前のフォーマット",
	PCHAT_NAMEFORMATTT = "Select how guild member names are formatted",

	PCHAT_FORMATCHOICE1 = "@ESO-ID",
	PCHAT_FORMATCHOICE2 = "キャラクター名",
	PCHAT_FORMATCHOICE3 = "キャラクター名@ESO-ID",
	PCHAT_FORMATCHOICE4 = "@ESO-ID/キャラクター名",

	PCHAT_SETCOLORSFORTT = "Set colors for members of <<1>>",
	PCHAT_SETCOLORSFORCHATTT = "Set colors for messages of <<1>>",

	PCHAT_SETCOLORSFOROFFICIERSTT = "Set colors for members of Officer chat of <<1>>",
	PCHAT_SETCOLORSFOROFFICIERSCHATTT = "Set colors for messages of Officer chat of <<1>>",

	PCHAT_MEMBERS = "Player name",
	PCHAT_CHAT = "Message",

	PCHAT_OFFICERSTT = " Officer",

	-- Channel colors settings

	PCHAT_CHATCOLORSH = "チャットチャンネルの色",

	PCHAT_SAY = "Say - name",
	PCHAT_SAYTT = "Set player name color for say channel",

	PCHAT_SAYCHAT = "Say - message",
	PCHAT_SAYCHATTT = "Set chat message color for say channel",

	PCHAT_ZONE = "Zone - name",
	PCHAT_ZONETT = "Set player name color for zone channel",

	PCHAT_ZONECHAT = "Zone - message",
	PCHAT_ZONECHATTT = "Set chat message color for zone channel",

	PCHAT_YELL = "Yell - name",
	PCHAT_YELLTT = "Set player name color for yell channel",

	PCHAT_YELLCHAT = "Yell - message",
	PCHAT_YELLCHATTT = "Set chat message color for yell channel",

	PCHAT_INCOMINGWHISPERS = "Incoming whispers - name",
	PCHAT_INCOMINGWHISPERSTT = "Set player name color for incoming whispers",

	PCHAT_INCOMINGWHISPERSCHAT = "Incoming whispers - message",
	PCHAT_INCOMINGWHISPERSCHATTT = "Set chat message color for incoming whispers",

	PCHAT_OUTGOINGWHISPERS = "Outgoing whispers - name",
	PCHAT_OUTGOINGWHISPERSTT = "Set player name color for outgoing whispers",

	PCHAT_OUTGOINGWHISPERSCHAT = "Outgoing whispers - message",
	PCHAT_OUTGOINGWHISPERSCHATTT = "Set chat message color for outgoing whispers",

	PCHAT_GROUP = "Group - name",
	PCHAT_GROUPTT = "Set player name color for group chat",

	PCHAT_GROUPCHAT = "Group - message",
	PCHAT_GROUPCHATTT = "Set chat message color for group chat",

	-- Other colors

	PCHAT_OTHERCOLORSH = "その他の色",

	PCHAT_EMOTES = "Emotes - name",
	PCHAT_EMOTESTT = "Set player name color for emotes",

	PCHAT_EMOTESCHAT = "Emotes - message",
	PCHAT_EMOTESCHATTT = "Set chat message color for emotes",

	PCHAT_ENZONE = "EN Zone - name",
	PCHAT_ENZONETT = "Set player name color for English zone channel",

	PCHAT_ENZONECHAT = "EN Zone - message",
	PCHAT_ENZONECHATTT = "Set chat message color for English zone channel",

	PCHAT_FRZONE = "FR Zone - name",
	PCHAT_FRZONETT = "Set player name color for French zone channel",

	PCHAT_FRZONECHAT = "FR Zone - message",
	PCHAT_FRZONECHATTT = "Set chat message color for French zone channel",

	PCHAT_DEZONE = "DE Zone - name",
	PCHAT_DEZONETT = "Set player name color for German zone channel",

	PCHAT_DEZONECHAT = "DE Zone - message",
	PCHAT_DEZONECHATTT = "Set chat message color for German zone channel",

	PCHAT_JPZONE = "JP Zone - name",
	PCHAT_JPZONETT = "Set player name color for Japanese zone channel",

	PCHAT_JPZONECHAT = "JP Zone - message",
	PCHAT_JPZONECHATTT = "Set chat message color for Japanese zone channel",

	PCHAT_RUZONE = "RU Zone - name",
	PCHAT_RUZONETT = "Set player name color for Russian zone channel",

	PCHAT_RUZONECHAT = "RU Zone - message",
	PCHAT_RUZONECHATTT = "Set chat message color for Russian zone channel",

	PCHAT_NPCSAY = "NPC Say - name",
	PCHAT_NPCSAYTT = "Set NPC name color for NPC say",

	PCHAT_NPCSAYCHAT = "NPC Say - message",
	PCHAT_NPCSAYCHATTT = "Set NPC chat message color for NPC say",

	PCHAT_NPCYELL = "NPC Yell - name",
	PCHAT_NPCYELLTT = "Set NPC name color for NPC yell",

	PCHAT_NPCYELLCHAT = "NPC Yell - message",
	PCHAT_NPCYELLCHATTT = "Set NPC chat message color for NPC yell",

	PCHAT_NPCWHISPER = "NPC Whisper - name",
	PCHAT_NPCWHISPERTT = "Set NPC name color for NPC whisper",

	PCHAT_NPCWHISPERCHAT = "NPC Whisper - message",
	PCHAT_NPCWHISPERCHATTT = "Set NPC chat message color for NPC whisper",

	PCHAT_NPCEMOTES = "NPC Emotes - name",
	PCHAT_NPCEMOTESTT = "Set NPC name color for NPC emotes",

	PCHAT_NPCEMOTESCHAT = "NPC Emotes - message",
	PCHAT_NPCEMOTESCHATTT = "Set NPC chat message color for NPC emotes",

	-- Debug settings

	PCHAT_DEBUGH = "Debug",

	PCHAT_DEBUG = "Debug",
	PCHAT_DEBUGTT = "Debug",

	-- Various strings not in panel settings

	PCHAT_UNDOCKTEXTENTRY = "Undock Text Entry",
	PCHAT_REDOCKTEXTENTRY = "Redock Text Entry",

	PCHAT_COPYXMLTITLE = "Copy text with Ctrl+C",
	PCHAT_COPYXMLLABEL = "Copy text with Ctrl+C",
	PCHAT_COPYXMLTOOLONG = "Splitted text",
	PCHAT_COPYXMLPREV = "Prev",
	PCHAT_COPYXMLNEXT = "Next",
	PCHAT_COPYXMLAPPLY = "Apply filter",

	PCHAT_COPYMESSAGECT = "メッセージ部分のみコピー",
	PCHAT_COPYLINECT = "行をコピー",
	PCHAT_COPYDISCUSSIONCT = "このチャンネルをコピー",
	PCHAT_ALLCT = "すべてをコピー",

	PCHAT_SWITCHTONEXTTABBINDING = "Switch to next tab",
	PCHAT_TOGGLECHATBINDING = "Toggle Chat Window",
	PCHAT_WHISPMYTARGETBINDING = "Whisper my target",

	PCHAT_SAVMSGERRALREADYEXISTS = "Cannot save your message, this one already exists",
	PCHAT_PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Write here the text which will be sent when you'll be using the auto message function",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Newlines will be automatically deleted",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "This message will be sent when you'll validate the message \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "To send a message in a specified channel, add its switch at the begenning of the message (ex: |cFFFFFF/g1|r)",
	PCHAT_PCHAT_AUTOMSG_NAME_HEADER = "Abbreviation of your message",
	PCHAT_PCHAT_AUTOMSG_MESSAGE_HEADER = "Substitution message",
	PCHAT_PCHAT_AUTOMSG_ADD_TITLE_HEADER = "New automated message",
	PCHAT_PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modify automated message",
	PCHAT_PCHAT_AUTOMSG_ADD_AUTO_MSG = "Add",
	PCHAT_PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Edit",
	PCHAT_SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Automated messages",
	PCHAT_PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Remove",

	PCHAT_CLEARBUFFER = "Clear chat",


	--Added by Baertram
	PCHAT_RESTORED_PREFIX = "[H]",
	PCHAT_RESTOREPREFIX = "Add prefix to restored messages",
	PCHAT_RESTOREPREFIXTT = "Add a prefix \'[H]\' to restored messages in order to easily see they were restored.\nThis will affect the current chat only after a reloadUI!\nThe color of the prefix will be shown with the standard ESO chat channel colors.",

	PCHAT_BUILT_IN_CHANNEL_SWITCH_WARNING = "Cannot use existing built-in switch '%s'",
	PCHAT_DUPLICATE_CHANNEL_SWITCH_WARNING = "Tried to replace already existing switch '%s'",

	PCHAT_CHATHANDLERS = "フォーマット対象",
	PCHAT_CHATHANDLER_TEMPLATETT = "Format the chat messages of the event \'%s\'.\n\nIf this setting is disabled the chat messages won't be changed with the different pChat formatting options (e.g. colors, timestamps, names, etc.)",
	PCHAT_CHATHANDLER_SYSTEMMESSAGES = "システムメッセージ",
	PCHAT_CHATHANDLER_PLAYERSTATUS = "プレイヤーのステータス変更",
	PCHAT_CHATHANDLER_IGNORE_ADDED = "ブロックリスト追加",
	PCHAT_CHATHANDLER_IGNORE_REMOVED = "ブロックリスト削除",
	PCHAT_CHATHANDLER_GROUP_MEMBER_LEFT = "グループメンバーが抜けた時",
	PCHAT_CHATHANDLER_GROUP_TYPE_CHANGED = "グループの種類変更",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end