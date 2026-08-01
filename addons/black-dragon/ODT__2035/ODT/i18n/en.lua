--[[
Author: @blackdragon06
Filename: en.lua
Version: 2.66
]]--

local strings = {
	
	-- General
	submenu_globals	= "Globals",
	submenu_ODT_LOCKWINDOWS = "lock windows position",

	-- Background
	submenu_background = "background",
	submenu_ODT_BG_Show = "Display background [ODT]",
	submenu_ODT_BGX = "Width",
	submenu_ODT_BGY = "Height",

	-- Hide in combat
	submenu_HideCombat = "Hide while combat",
	submenu_HideCombat_GLOBAL = "Hide all windows",
	submenu_HideCombat_BG = "background",
	submenu_HideCombat_CLOCK = "Clock",
	submenu_HideCombat_CHRONO = "Stopwatch",
	submenu_HideCombat_TIMER = "timer",
	submenu_HideCombat_PERF = "Performances",
	submenu_HideCombat_INVENTORY = "Inventory",
	submenu_HideCombat_STATS = "Weapons & Armor statistics",
	submenu_HideCombat_HORSE = "Mount",
	submenu_HideCombat_STOLEN = "theft",
	
	
	-- Clock
	submenu_clock = "Clock",
	submenu_ODT_ShowClock = "Display clock",
	submenu_ODT_ShowClockFontSize = "Font Size",
	submenu_ODT_ShowClockFontColor = "Font Color",
	submenu_ODT_ShowClockBG = "Transparent background",

	-- Chronometer
	submenu_chrono = "Stopwatch",
	submenu_ODT_ShowChrono = "Display Stopwatch",
	submenu_ODT_ShowChronoFontSize = "Font Size",
	submenu_ODT_ShowChronoFontColor = "Font Color",
	submenu_ODT_ShowChronoBG = "Transparent background",

	-- Timer
	submenu_timer = "Timer",
	submenu_ODT_ShowTimer = "Display timer",
	submenu_ODT_ShowTimerFontSize = "Font Size",
	submenu_ODT_ShowTimerFontColor = "Font Color",
	submenu_ODT_ShowTimerBG = "Transparent background",
	submenu_ODT_Timer_Seconds = "Duration in seconds",
	submenu_ODT_Timer_SOUND = "Sound",
	submenu_ODT_Timer_SOUND_TOOLTIP ="Play a sound when the countdown is over",

	-- Performances
	submenu_perf = "performances",
	submenu_ODT_ShowPERF = "Display performances (FPS/PING)",
	submenu_ODT_ShowPERFBG = "Transparent background",
	
	-- Inventory
	submenu_inventory = "inventory",
	submenu_ODT_ShowBag = "View inventory fill rate", 
	submenu_ODT_ShowBagBG = "Transparent background", 
	
	-- Weapons & Armor
	submenu_WA_STATS = "Weapons & Armor statistics",
	submenu_WA_STATS_TOOLTIP = "|cFFFFFFDisplays Weapon charge %, Armor status %  and Repair cost",
	submenu_ODT_WA_ONOFF = "Display Weapons & Armor statistics",
	submenu_ODT_WABG = "Transparent background",
	submenu_ODT_WA_ATX = "Message when armor < 10%",
	submenu_ODT_WA_ATX_TOOLTIP = "Show a message if a piece of armor is at less than 10%",
	submenu_ODT_WA_SOUND_ARMOR = "Sound",
	submenu_ODT_WA_WTX = "Message when enchantement < 3%",
	submenu_ODT_WA_WTX_TOOLTIP = "Show a message if the a weapon is less than 3% charged",
	submenu_ODT_WA_SOUND_WEAPON = "Sound",
	submenu_ODT_WA_Recharge = "Automatic weapon charging",
	submenu_ODT_WA_Recharge_TOOLTIP = "Reload the weapon automatically when the charge is at 0%",
	weaponcharged = "\nhas been charged",
	nosoulgem = "\no charged soul gem",
	weaponwarning1 = "\nWeapon # 1 is less than 3% charged",
	weaponwarning2 = "\nWeapon # 2 is less than 3% charged",
	weaponwarning3 = "\nWeapon # 3 is less than 3% charged",
	weaponwarning4 = "\nWeapon # 4 is less than 3% charged",
	armorwarning = "An armor piece is at less than 10%",
	
	-- Food / Drink
	submenu_food = "Food & Drink",
	submenu_ODT_ShowFOOD = "Warn when the food / drink is going to end",
	submenu_ODT_ShowFOOD_TIME = "Time left in minutes",
	submenu_ODT_ShowFOOD_TIME_TOOLTIP = "Warn when the food / drink will end in ...",
	submenu_ODT_ShowFOOD_POPDURATION = "Display delay",
	submenu_ODT_ShowFOOD_POPDURATION_TOOLTIP = "Message display delay (0 = the window will disappear only by clicking on it)",
	submenu_ODT_ShowFOOD_SOUND = "Sound",
	submenu_ODT_ShowFOOD_CHECKONLOAD = "Warn when loading",
	submenu_ODT_ShowFOOD_CHECKONLOAD_TOOLTIP = "Warn if there is no food when loading the character / reloadUI",

	-- Mount
	submenu_horse = "Mount",
	submenu_ODT_HORSE = "Warn when the training is finished",
	submenu_ODT_HORSE_SHOWPERMA = "Permanent display",
	submenu_ODT_HORSE_SHOWPERMA_TOOLTIP = "Permanently display the remaining training time",
	submenu_ODT_HORSE_SHOWBG = "Transparent background",
	submenu_ODT_HORSE_SHOWTIME = "Display delay",
	submenu_ODT_HORSE_SHOWTIME_TOOLTIP = "Message display delay (0 = the window will disappear only by clicking on it)",
	submenu_ODT_HORSE_SOUND = "Sound",
	submenu_ODT_HORSE_CHECKONLOAD = "Warn when loading",
	submenu_ODT_HORSE_CHECKONLOAD_TOOLTIP = "Warn at startup / ReloadUI if the mount can be trained",
	
	-- MAILBOX
	submenu_mail = "mail",
	submenu_ODT_MailRTS_ONOFF = "RTS (Return to Sender)",
	submenu_ODT_MailRTS_ONOFF_TOOLTIP =  "|cFFFFFFThe received mails whose subject is |cF2AE04RTS |cFFFFFFou |cF2AE04rts|cFFFFFF in subject will be returned automatically to the sender.",
	submenu_ODT_MailRTS_SOUND1 = "Sound if a mail is returned (success)",
	submenu_ODT_MailRTS_SOUND2 = "Sound if a mail is not returned (failure)",
	btnraz = "|cFFFFFFDelete",
	btnerase = "|cFFFFFFErase",
	btninserthouseicon = "|cFFFFFFInsert house icon",
	btninsertraidicon = "|cFFFFFFIInsert raid icon",
	btninsertpvpicon = "|cFFFFFFInsert PvP icon",
	btninsertbdgicon = "|cFFFFFFInsert guild bank icon",
	btninsertsign = "|cFFFFFFInsert signature",
	btnloadsave = "left click to load / right click to save",
	btnsend = "Send",
	mailsenderror = "|cFF6909Mail ODT : |cC80F14mail not sent (",
	mailsendsuccess = " sendsed",
	mailrtssender = "|cFF6909ODT RTS : mail return to |cEDFF00",
	mailrtsobjects = "|cFF6909  --  Objects number : |cEDFF00",
	mailrtsnil = "|cFF6909ODT RTS : Mail to delete manually |cEDFF00",
	mailsenderrorself = "|cFF6909Mail ODT : |cC80F14Impossible to send a mail to oneself",
	mailsenderrorfull = "|cFF6909Mail ODT : |cC80F14The mailbox is full (",
	mailsenderrorclosed = "|cFF6909Mail ODT : |cC80F14MailBox closed",

	-- guilds : Notifications status membres"
	submenu_guildsnotifications = "guilds : Notification on members status change",
	submenu_ODT_GMHeure = "Message : display hour",
	submenu_ODT_GuildName = "Message : display guild name",
	submenu_ODT_GMCharacterName = "Message : display character name",
	submenu_ODT_GMAlliance = "Message : display character alliance",
	submenu_ODT_GMSound = "Sound",
	status_online = " |c04D631online",
	status_with = "|cE6F702 with ",
	status_afk = " |cE6F702- AFK -",
	status_npd = " |cf81e1e- Don't disturb -",
	status_offline = " |c848484offline",
	
	-- CHAT Notifications
	submenu_chat_notifications	= "chat notifications",
	submenu_ODT_Notif_Say = "Say",
	submenu_ODT_Notif_Yell = "Yell",
	submenu_ODT_Notif_Tell = "Tell",
	submenu_ODT_Notif_Party = "Party",
	submenu_ODT_Notif_Z = "Zone",
	submenu_ODT_Notif_ZEN = "Zone : English",
	submenu_ODT_Notif_ZFR = "Zone : French",
	submenu_ODT_Notif_ZDE = "Zone : German",
	
	-- CHAT Personnalisé
	submenu_customchat	= "Custom chat",
	submenu_ODT_CustomChatPerma = "Permanent chat display",
	submenu_ODT_CustomChatPerma_TOOLTIP = "|cFFFFFFChanging this value requires a ReloadUI",
	submenu_ODT_CustomChatDate = "Date",
	submenu_ODT_CustomChatTime = "Hour",
	submenu_ODT_CustomChatChan = "Chan",
	submenu_ODT_CustomChatAccount = "@account name",
	submenu_ODT_CustomChatPersoInfos = "Character informations",
	submenu_ODT_CustomChatPersoInfos_TOOLTIP = "(only on guild channel)", 	
	submenu_ODT_CustomChatName = "Character name",
	submenu_ODT_CustomChatLvl = "Character level",
	submenu_ODT_CustomChatAlliance = "Character alliance",
	submenu_ODT_CustomChatClasse = "Character class",
	CustomChatChan0 = " say ",
	CustomChatChan1 = " yell ",
	CustomChatChan2 = " whisp ",
	CustomChatChan3 = " party ",
	CustomChatChan4 = " whisp to ",
	CustomChatChan7 = " NPC ",
	CustomChatChan8 = " NPC ",
	CustomChatChan9 = " NPC ",
	CustomChatChan31 = " zone ",
	CustomChatChan32 = " zone EN ",
	CustomChatChan33 = " zone FR ",
	CustomChatChan34 = " zone DE ",
	CustomChatChan35 = " zone JP ",
	
	-- Save Settings
    submenu_ODT_Apply = "Apply",
	submenu_ODT_Apply_TOOLTIP = "Applies parameter changes without reload UI (changes are not saved)",
	submenu_ODT_Save = "Save",
	submenu_ODT_Save_TOOLTIP = "Saves the settings and performs a UI reload",

	-- Chronometer
	chrono_title = "Stopwatch [ODT]",
	chrono_start = "Start stopwatch",
	chrono_stop = "Stop stopwatch",

	-- Timer
	timer_title = "Timer [ODT]",
	timer_start = "Start timer",
	timer_stop = "Stop timer",
	timer_ended = "The countdown is over",
	
	-- Mount
	horse_msg_ended = "The mount training is finished.",
	horse_timer_ended = "ended ",

	-- Food
	food_timer_msg = " ends in ",
	food_timer_print = " |cE6F702ends in ",
	food_ended_msg = "no food/drink",

	-- XP Scroll
	submenu_XPScroll = "Increased Experience Scroll",
	submenu_ODT_XPScroll = "Warn when Experience Scroll is over",
	submenu_ODT_XPScroll_POPDURATION_TOOLTIP = "Message display delay (0 = the window will disappear only by clicking on it)",
	submenu_ODT_XPScroll_SOUND = "Sound",
	XPScroll_timer_print = " |cE6F702Increased Experience Scroll ended ",
	XPScroll_timer_msg = "Increased Experience ended",

	-- Fish
	submenu_FISH_Title = "Fishing",
	submenu_ODT_Fish = "Display Water type and baits",
	fish_ocean = "|c6699ff[Ocean]  |cCCFFFF(Worms/Chub)",
	fish_river = "|c6699ff[River]  |cCCFFFF(Insect Parts/Shad)",
	fish_lake = "|c6699ff[Lake]  |cCCFFFF(Guts/Minnow)",
	fish_foul = "|c6699ff[Foul Water]  |cCCFFFF(Crawlers/Fish Roe)",

	-- Vol
	submenu_Stolen_Title = "theft",
	submenu_ODT_Stolen = "Display theft informations",
	submenu_ODT_StolenTOOLTIP = "Daily sells amount \nBag stolen items amount \nSells items number \nLaundred items number \nRemaining time",
	submenu_ODT_ShowStolenBG = "Fond transparent", 
	
	-- Annonce des morts
	submenu_ShowDeath_Title = "Deaths announcement",
	submenu_ShowDeath = "Dead announcement",
	submenu_ShowDeath_Msg = "Alert message when a player dies",
	submenu_ShowDeath_Chat = "Message in chat",
	submenu_ShowDeath_List = "Display the list of the dead", 
	submenu_ShowDeath_rez = "Resurrection message", 
	submenu_ShowDeath_Snd = "Sound", 
	
	-- Bindings
	lng_SI_BINDING_NAME_ODT_Clock = "Show/Hide clock",
	lng_SI_BINDING_NAME_ODT_Chrono = "Show/Hide stopwatch",
	lng_SI_BINDING_NAME_ODT_ChronoONOFF = "Start/Stop stopwatch",
	lng_SI_BINDING_NAME_ODT_Timer = "Show/Hide timer",
	lng_SI_BINDING_NAME_ODT_TimerONOFF = "Start/Stop timer",
	lng_SI_BINDING_NAME_ODT_PERF = "Show/Hide performances",
	lng_SI_BINDING_NAME_ODT_STATS = "Show/Hide armor & weapons statistics",
	lng_SI_BINDING_NAME_ODT_RLUI = "|cffff0dReload UI",
	lng_SI_BINDING_NAME_ODT_FREN = "Switch language EN/FR",
	lng_SI_BINDING_NAME_ODT_SACK = "|cCCFFFFSend message [Heavy sack]",
	lng_SI_BINDING_NAME_ODT_CHEST = "|cCCFFFFSend message [Chest]",
	
	-- Divers	
	ODT_notif_officers = " : Officers",
	closewindow = "|cFFFFFFClose window",
	addonloaded = ") loaded. \n|cEDFF00/odt |cFF6909to show commands \n|cEDFF00Settings→Addons |cFF6909to custom parameters \nControls |cFF6909for keybindings",
	dailiesupdated = "|cFF6909addon ODT : |cEDFF00dailies updated (guild message).",
	btnchan_officers = "|c94DE23[Orbe du Temps] \n|c00D7FFleft click : |cEDFF00Pledges \n|c00D7FF[Shift]+left click : |cFFB04DCommands list \n|c00D7FF[CTRL]+left click : |cf81e1eReload UI \n\n|c00D7FFmiddle click : |cEDFF00recruitment message \n|c00D7FF[Shift]+middle click : |cEDFF00welcome message \n\n|c00D7FFright click : |cEDFF00Go to guild house\n|c00D7FF[Shift]+right click : |cEDFF00Guild mailing",
	btnchan = "|c94DE23[Orbe du Temps] \n|c00D7FFleft click : |cEDFF00pledges \n|c00D7FF[Shift]+left click : |cFFB04DCommands list \n|c00D7FF[CTRL]+left click : |cf81e1eReload UI \n\n|c00D7FFright click : |cEDFF00Go to guild house",
	btnexecute = "|cFFFFFFExecute commande",
	btnexecuteoptions = "|cFFFFFFAdd the | c00D7FF-c | cFFFFFF option by executing a command below",
	savecolors = "Save the chat colors configured on this character",
	loadcolors = "Load saved chat colors",
	
	cmd_pledges_today = "|cFFB04D• Today pledges ",
	cmd_pledges_before_yesterday = "|cFFB04D• Before yesterday pledges",
	cmd_pledges_yesterday = "|cFFB04D• Yesterday pledges",
	cmd_pledges_tomorrow = "|cFFB04D• Tomorrow pledges",
	cmd_pledges_after_tomorrow = "|cFFB04D• After tomorrow pledges",
	pledges_today = "Today pledges -> ",
	pledges_before_yesterday = "Before yesterday pledges -> ",
	pledges_yesterday = "Yesterday pledges -> ",
	pledges_tomorrow = "Tomorrow pledges -> ",
	pledges_after_tomorrow = "After tomorrow pledges -> ",
	
}
	
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end