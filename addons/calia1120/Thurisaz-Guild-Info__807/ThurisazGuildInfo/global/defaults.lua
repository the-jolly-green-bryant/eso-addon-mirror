-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use parts of my AddOns for your own work, please contact me first!

--Dropdown Options
TI.vars = {}
TI.SETTINGS_SHOW_ACC_AND_CHAR_NAME = "CharName@AccountName"
TI.SETTINGS_SHOW_CHAR_NAME = "CharName"
TI.SETTINGS_SHOW_ACC_NAME = "@AccountName"

TI.SETTINGS_DISPLAY_TYPE_CHAT = "Chat"
TI.SETTINGS_DISPLAY_TYPE_LABEL = "Scrolling Text (HUD)"
TI.SETTINGS_DISPLAY_TYPE_BOTH = "Chat + Scrolling Text"

TI.SETTINGS_DISPLAY_ALIGN_LEFT = "#--"
TI.SETTINGS_DISPLAY_ALIGN_CENTER = "-#-"
TI.SETTINGS_DISPLAY_ALIGN_RIGHT = "--#"
TI.SETTINGS_DISPLAY_DEFAULT_TIME = 10

TI.colors = {
	headerDefault = {0.77, 0.76, 0.62, 1},
	rosterOnline = {0.46, 0.73, 0.76, 1},
	rosterOffline = {0.4, 0.4, 0.4, 1}

}

TI.defaults = {
	ShowAnnouncements = true,
	ShowCharNames = true,
	NameFormat = TI.SETTINGS_SHOW_ACC_AND_CHAR_NAME,
	DisplayType = TI.SETTINGS_DISPLAY_TYPE_CHAT,
	DisplayTypeChat = true,
	DisplayTypeHUD = false,
	AnnounceDisplayX = 200,
	AnnounceDisplayY = 300,
	AnnounceDisplayWidth = 500,
	AnnounceDisplayAlignment = TI.SETTINGS_DISPLAY_ALIGN_CENTER,
	AnnounceDisplayFont = "ZoFontAnnounceMessage",
	AnnounceDisplayColorMode = true,
	AnnounceDisplayTime = TI.SETTINGS_DISPLAY_DEFAULT_TIME,

	AnnounceShowTimestamp = false,

	PlayerNameColor = {0,1,1,1},

	-- Individual guild settings
	guildSettings = {
		[1] = {
			ShowAnnouncements = true,
			Abbreviation = "",
			ShowStatusChange = false,
			ShowLevelChange = true,
			ShowMemberChange = true,
			--ShowRaidScoreNotifications = true,
			GuildNameColor = {0,0.5,0,1}
		},
		[2] = {
			ShowAnnouncements = true,
			Abbreviation = "",
			ShowStatusChange = false,
			ShowLevelChange = true,
			ShowMemberChange = true,
			--ShowRaidScoreNotifications = true,
			GuildNameColor = {0,0.5,0,1}
		},
		[3] = {
			ShowAnnouncements = true,
			Abbreviation = "",
			ShowStatusChange = false,
			ShowLevelChange = true,
			ShowMemberChange = true,
			--ShowRaidScoreNotifications = true,
			GuildNameColor = {0,0.5,0,1}
		},
		[4] = {
			ShowAnnouncements = true,
			Abbreviation = "",
			ShowStatusChange = false,
			ShowLevelChange = true,
			ShowMemberChange = true,
			--ShowRaidScoreNotifications = true,
			GuildNameColor = {0,0.5,0,1}
		},
		[5] = {
			ShowAnnouncements = true,
			Abbreviation = "",
			ShowStatusChange = false,
			ShowLevelChange = true,
			ShowMemberChange = true,
			--ShowRaidScoreNotifications = true,
			GuildNameColor = {0,0.5,0,1}
		},

	},
	guildMembers = {

	}, -- Informations about guild members
	--Overall Setting
	ShowAnnouncementsGuild1 = true,
	ShowAnnouncementsGuild2 = true,
	ShowAnnouncementsGuild3 = true,
	ShowAnnouncementsGuild4 = true,
	ShowAnnouncementsGuild5 = true,

	--Abbreviation Changes Setting
	AbbreviationAnnouncementsGuild1 = "",
	AbbreviationAnnouncementsGuild2 = "",
	AbbreviationAnnouncementsGuild3 = "",
	AbbreviationAnnouncementsGuild4 = "",
	AbbreviationAnnouncementsGuild5 = "",

	--Status Changes Setting
	ShowStatusAnnouncementsGuild1 = false,
	ShowStatusAnnouncementsGuild2 = false,
	ShowStatusAnnouncementsGuild3 = false,
	ShowStatusAnnouncementsGuild4 = false,
	ShowStatusAnnouncementsGuild5 = false,

	--Level Changes Setting
	ShowLevelAnnouncementsGuild1 = true,
	ShowLevelAnnouncementsGuild2 = true,
	ShowLevelAnnouncementsGuild3 = true,
	ShowLevelAnnouncementsGuild4 = true,
	ShowLevelAnnouncementsGuild5 = true,

	--Member Changes Setting
	ShowMemberAnnouncementsGuild1 = true,
	ShowMemberAnnouncementsGuild2 = true,
	ShowMemberAnnouncementsGuild3 = true,
	ShowMemberAnnouncementsGuild4 = true,
	ShowMemberAnnouncementsGuild5 = true,

	--Guild Name Color Setting
	GuildNameColorAnnouncementsGuild1 = {1,0,0,1},
	GuildNameColorAnnouncementsGuild2 = {1,0,0,1},
	GuildNameColorAnnouncementsGuild3 = {1,0,0,1},
	GuildNameColorAnnouncementsGuild4 = {1,0,0,1},
	GuildNameColorAnnouncementsGuild5 = {1,0,0,1},
}