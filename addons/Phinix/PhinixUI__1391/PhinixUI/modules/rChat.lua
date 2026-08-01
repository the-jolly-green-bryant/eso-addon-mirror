
function PUIAddon.rChat()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = RCHAT_OPTS.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.colours = {
		groupleader1 = "|c76BCC3",
		groupleader = "|cC35582",
		tabwarning = "|c76BCC3",
		timestamp = "|c8F8F8F",
	}
	db.tabs = {
		defaultTab = 1,
		defaultchannel = 31,
		defaultTabName = "",
		enableChatTabChannel = true,
	}
	db.spam = {
		priceCheckProtect = false,
		lookingForProtect = false,
		spamGracePeriod = 5,
		guildProtect = false,
		floodGracePeriod = 10,
		wantToProtect = false,
		floodProtect = true,
	}
	db.whisper = {
		incomingsound = "ABILITY_CASTER_BUSY",
		notifyIM = false,
		soundEnabled = false,
	}
	db.mention = {
		color = "|cFFFFFF",
		sound = "New_Notification",
		emoteEnabled = false,
		mentionEnabled = false,
		colorEnabled = false,
		soundEnabled = false,
	}
	db.newcolors = {
		[32] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
		[1] = {
			[2] = "|cFFB5F4",
			[1] = "|cE974D8",
		},
		[2] = {
			[2] = "|cB27BFF",
			[1] = "|cB27BFF",
		},
		[3] = {
			[2] = "|cA1DAF7",
			[1] = "|c6EABCA",
		},
		[4] = {
			[2] = "|c7E57B5",
			[1] = "|c7E57B5",
		},
		[6] = {
			[2] = "|cA5A5A5",
			[1] = "|cA5A5A5",
		},
		[7] = {
			[2] = "|c879B7D",
			[1] = "|c879B7D",
		},
		[8] = {
			[2] = "|c879B7D",
			[1] = "|c879B7D",
		},
		[9] = {
			[2] = "|c879B7D",
			[1] = "|c879B7D",
		},
		[10] = {
			[2] = "|c879B7D",
			[1] = "|c879B7D",
		},
		[12] = {
			[2] = "|cC3F0C2",
			[1] = "|c94E193",
		},
		[13] = {
			[2] = "|cC3F0C2",
			[1] = "|c94E193",
		},
		[14] = {
			[2] = "|cC3F0C2",
			[1] = "|c94E193",
		},
		[15] = {
			[2] = "|cC3F0C2",
			[1] = "|c94E193",
		},
		[16] = {
			[2] = "|cC3F0C2",
			[1] = "|c94E193",
		},
		[17] = {
			[2] = "|cC3F0C2",
			[1] = "|cC3F0C2",
		},
		[18] = {
			[2] = "|cC3F0C2",
			[1] = "|cC3F0C2",
		},
		[19] = {
			[2] = "|cC3F0C2",
			[1] = "|cC3F0C2",
		},
		[20] = {
			[2] = "|cC3F0C2",
			[1] = "|cC3F0C2",
		},
		[21] = {
			[2] = "|cC3F0C2",
			[1] = "|cC3F0C2",
		},
		[36] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
		[35] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
		[34] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
		[33] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
		[0] = {
			[2] = "|cFFFFFF",
			[1] = "|cFFFFFF",
		},
		[31] = {
			[2] = "|cB0A074",
			[1] = "|cCEB36F",
		},
	}
	db.carriageReturn = false
	db.restoreOnLogOut = false
	db.showGuildNumbers = false
	db.disableBrackets = true
	db.restoreOnAFK = false
	db.nozonetags = true
	db.addChannelAndTargetToHistory = true
	db.enablepartyswitch = true
	db.fonts = "ESO Standard Font"
	db.lastWasQuit = false
	db.chatMaximizedAfterMenus = false
	db.timestampcolorislcol = false
	db.diffforESOcolors = 40
	db.showTimestamp = false
	db.chatMinimizedAtLaunch = false
	db.allZonesSameColour = true
	db.chatMinimizedInMenus = false
	db.allNPCSameColour = true
	db.oneColour = false
	db.geoChannelsFormat = 2
	db.restoreWhisps = true
	db.augmentHistoryBuffer = true
	db.disableDebugLoggerBlocking = true
	db.timeBeforeRestore = 2
	db.lastWasReloadUI = false
	db.restoreSystemOnly = false
	db.allGuildsSameColour = false
	db.showTagInEntry = true
	db.restoreSystem = false
	db.restoreTextEntryHistoryAtLogOutQuit = false
	db.restoreOnQuit = false
	db.timestampFormat = "HH:m"
	db.chatSyncConfig = true
	db.windowDarkness = 6
	db.enablecopy = true
	db.announce_zone = false
	db.alwaysShowChat = true
	db.groupNames = 3
	db.urlHandling = true
	db.lastWasLogOut = false
	db.restoreOnReloadUI = false
	db.lastWasAFK = true
	db.useESOcolors = true
	db.groupLeader = false

end
