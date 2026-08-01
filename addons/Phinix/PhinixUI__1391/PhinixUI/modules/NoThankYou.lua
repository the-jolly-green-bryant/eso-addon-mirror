
function PUIAddon.NoThankYou()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = NO_THANK_YOU_VARS.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.guildAlertsGuilds = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
	}
	db.motdGuilds = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
	}
	db.raidGuilds = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
	}
	db.nonstopHarvest = true
	db.hideTamriel = false
	db.hideTamrielDungeons = 0
	db.emptyInteractions = false
	db.autoLootItems = false
	db.crownCrate = false
	db.guildInvites = 0
	db.unownedHouses = 2
	db.noPortOnLeader = 2
	db.ava = 2
	db.emptyMail = true
	db.noBindAlert = false
	db.noGuildLeave = 1
	db.dontShowSkillProgression = 0
	db.fenceDialog = false
	db.guildAlerts = 2
	db.craftBag = false
	db.ultimateSound = 0
	db.craftingResults = false
	db.repair = true
	db.luaMemory = 1
	db.alertTextExpiryDelay = 3
	db.raid = 3
	db.enlightened = false
	db.disableChatAutoComplete = true
	db.noUniversalStones = false
	db.boss = false
	db.improveDialog = false
	db.disbandDialog = false
	db.friends = true
	db.dontShowLoreDiscoveries = 2
	db.dontAcceptWritQuest = true
	db.noCameraSpinStats = false
	db.motd = 2
	db.noReportOnItems = true
	db.noCameraSpinInv = true
	db.screenshot = false
	db.marketAnnouncement = false
	db.dontReadBooks = false
	db.noCameraSpin = true
	db.chatForTradingHouse = false
	db.luaError = 1
	db.groupZone = 1
	db.ownedHouses = 2
	db.hideTamrielWayhsrines = 0
	db.largeGroupDialog = false
	db.raidToChat = true

end
