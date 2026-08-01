--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following people for helping me, either with testing or giving me ideas:
- @Draconise
- @Ray.1
- @QxQ
- @Rhone2112
- @Karm1cOne
- @Sanenomore
- @Morelian
- @ivutar

I'd like to thank the following addons:
- pChat by Puddy
- Thurisaz Guild Info by calia1120
- RaidLead Essentials by LaynaKaru
- GMen by Ayantir
- Mute List by Randactyl
- AutoInvite by Sasky
]]

-- Initialized the addon names
AdvancedGroupRoster = {}
AdvancedGroupRoster.name = "AdvancedGroupRoster"
AdvancedGroupRoster.version = 13.0

-- Initializes various things; variables aptly named
AdvancedGroupRoster.playerInPvP = false
AdvancedGroupRoster.playerName = ''
AdvancedGroupRoster.playerZone = ''

AdvancedGroupRoster.characterWidth = 140
AdvancedGroupRoster.columnHeight = 30
AdvancedGroupRoster.normalCharacterWidth = 205
AdvancedGroupRoster.normalZoneWidth = 125

AdvancedGroupRoster.defaultRoleColor = {1,1,1,1}
AdvancedGroupRoster.defaultRowColor = {0.46274510025978, 0.73725491762161, 0.76470589637756, 1}

AdvancedGroupRoster.rosterStatus = {}

AdvancedGroupRoster.sortedGroupRoster = {}
AdvancedGroupRoster.sortedRosterKeys = {}

AdvancedGroupRoster.players_table = nil
AdvancedGroupRoster.currentSession = {
	players = {}
}

AdvancedGroupRoster.kickTable = {}
AdvancedGroupRoster.allGuilds = {}
AdvancedGroupRoster.guildNames = {}

AdvancedGroupRoster.currentGroupPlayerSelected = ''
AdvancedGroupRoster.currentCharacterNameWritten = ''
AdvancedGroupRoster.currentGuildFriendSelected = ''
AdvancedGroupRoster.currentFriendSelected = ''
AdvancedGroupRoster.currentPlayerRank = 1
AdvancedGroupRoster.playerName = ''
AdvancedGroupRoster.inGroup = false

-- For the addon settings menu
AdvancedGroupRoster.LAM2 = LibAddonMenu2

if not AdvancedGroupRoster.LAM2 and LibStub then
	AdvancedGroupRoster.LAM2 = LibStub("LibAddonMenu-2.0", true)
end

-- Saved beyond session variables
AdvancedGroupRoster.accountWideDefaults={
	accountWide=false
}

AdvancedGroupRoster.defaults={
	useUserId=1,
	pvpRankLevel=1,
	healColors={1,1,1,1},
	tankColors={1,1,1,1},
	dpsColors={1,1,1,1},
	nicknames="",
	listNicknames = {},
	markSelf=false,
	sameLocColors={0.46274510025978, 0.73725491762161, 0.76470589637756, 1},
	groupRoster={},
	showRoles=false,
	utilizeGroupNotes=false,
	trackGroupStatus=false,
	awayMessages='',
	listAwayMessages={},
	secLeaders="",
	listSecLeaders={},
	popupLeft=0,
	popupTop=0,
	unlocked=true,
	dump={},
	raidAttendance=true,
	allianceIcon=false,
	groupInviteEnabled=false,
	groupInviteString='',
	groupInviteSize=24,
	groupInvitePVPCheck=false,
	groupInviteAutoKick=5,
	groupInviteNonZone=false,
	guildOption={},
	groupInviteCaseSensitive=true,
	groupInviteFinder=false,
	roleNames={
		[1] = 'Tanks',
		[2] = 'Healers',
		[3] = 'DPS',
		[4] = '',
		[5] = '',
		[6] = '',
		[7] = ''
	},
	roleAmount={
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0
	},
	rolePlayers={
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {}
	},
	groupInviteNonRoled=true,
	groupInviteKickNonRoled=false,
	raidManagementEnable=false,
	nonRoledDPS=false,
	combatControlsKickNonRoled=true,
	groupSizeRaidManage=0,
	useRankingAutoKick=false,
	groupInviteString2='',
	autoTransferUponDeath=false,
	roleDeathAnnouncement={
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false
	},
	guildRank={},
	rosterSortUserID=false,
}

function AdvancedGroupRoster:Initialize()
	AdvancedGroupRoster.playerInPvP = IsPlayerInAvAWorld()
	AdvancedGroupRoster.playerZone = zo_strformat(SI_SOCIAL_LIST_LOCATION_FORMAT, GetUnitZone('player'))

	AdvancedGroupRoster.postHook("RefreshData", AdvancedGroupRoster.UpdateGroupList, "GROUP_LIST")
	AdvancedGroupRoster.postHook("GetRowColors", AdvancedGroupRoster.UpdateRowColors, "GROUP_LIST")
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_PLAYER_ACTIVATED, AdvancedGroupRoster.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_CHAT_MESSAGE_CHANNEL, AdvancedGroupRoster.onChatMessage)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_GROUP_MEMBER_JOINED, AdvancedGroupRoster.OnGroupPlayerEnter)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_GROUP_MEMBER_LEFT, AdvancedGroupRoster.OnGroupPlayerLeave)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, AdvancedGroupRoster.OnGroupPlayerOffline)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_PLAYER_DEAD, AdvancedGroupRoster.onPlayerDead)
	EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_UNIT_DEATH_STATE_CHANGED, AdvancedGroupRoster.onGroupMemberDead)
	ZO_PreHook("ZO_ScrollList_UpdateScroll", AdvancedGroupRoster.OnGroupScroll)
	--EVENT_MANAGER:RegisterForUpdate(AdvancedGroupRoster.name, 1000 * 60 * 5, AdvancedGroupRoster.UpdateAttendance)
	EVENT_MANAGER:RegisterForUpdate(AdvancedGroupRoster.name, 1000, AdvancedGroupRoster.onUpdate)

	-- un-enable if logging in / reloading
	AdvancedGroupRoster.SV.groupInviteEnabled = false

	AdvancedGroupRoster.playerName = GetUnitName('player')
end

function AdvancedGroupRoster.OnAddOnLoaded(event, addonName)
	if addonName ~= AdvancedGroupRoster.name then
		return
	end

	AdvancedGroupRoster:SetupGuilds()

	AdvancedGroupRoster.DS = ZO_SavedVars:NewAccountWide("AdvancedGroupRosterTrackerSettings", 1.0, "AccountWide", AdvancedGroupRoster.accountWideDefaults)

	if AdvancedGroupRoster.DS.accountWide then
		AdvancedGroupRoster.SV = ZO_SavedVars:NewAccountWide("AdvancedGroupRosterTrackerSettings", 1.0, "Settings", AdvancedGroupRoster.defaults)
	else
		AdvancedGroupRoster.SV = ZO_SavedVars:New("AdvancedGroupRosterTrackerSettings", 1.0, "Settings", AdvancedGroupRoster.defaults)
	end
	
	AdvancedGroupRoster:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(AdvancedGroupRoster.name, EVENT_ADD_ON_LOADED)

	AdvancedGroupRoster:Initialize()
	AdvancedGroupRoster:InitControls()
	AdvancedGroupRoster.EditRosterHeader()
	AdvancedGroupRoster:SetUpCommands()
	AdvancedGroupRoster:SetupPlayerTable()

	if AdvancedGroupRoster.SV.groupInviteFinder == true then
		AdvancedGroupRoster:SetupAutoInviteSystem()
	end
end

-- Thanks to Thurisaz Guild Info for this awesome post-hook function!
function AdvancedGroupRoster.postHook(funcName, callback, subtable)
	local tmp = _G[subtable][funcName]

	_G[subtable][funcName] = function(...)
		tmp(...)
		callback()
	end
end

function AdvancedGroupRoster.SetupAutoInviteSystem()
	local ui = {}

	ui.main = WINDOW_MANAGER:CreateControl("GroupInviteOptions", AGR_GI_Options, CT_CONTROL)
    ui.scroll = ui.main 
    ui.main:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, 45)
    ui.main:SetWidth(340)
    ui.panel = ui.main
    ui.panel.data = {}

	ui.restart = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = 'Enabled:',
        tooltip = "ON - listens in chat for 'Invite String', OFF - does not listen in chat",
        default = AdvancedGroupRoster.defaults.groupInviteEnabled,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteEnabled end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteEnabled = newValue end,
    })
    ui.restart.checkbox:SetAnchor(LEFT, ui.restart.container, RIGHT, -25, 0)
    ui.restart:SetAnchor(TOPLEFT, ui.main, BOTTOMLEFT, 0, 15)

	ui.string1 = LAMCreateControl.editbox(ui, {
        type = "editbox",
		name = "Invite String1:",
		tooltip = "Choose which messages to listen for to determine whether a person is away",
		isMultiline = false,
		isExtraWide = false,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteString end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteString = newValue end,
		width = "full",
    })
    ui.string1:SetAnchor(TOPRIGHT, ui.restart, TOPRIGHT, 0, 35)

	ui.string2 = LAMCreateControl.editbox(ui, {
        type = "editbox",
		name = "Invite String2:",
		tooltip = "Choose which messages to listen for to determine whether a person is away",
		isMultiline = false,
		isExtraWide = false,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteString2 end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteString2 = newValue end,
		width = "full",
    })
    ui.string2:SetAnchor(TOPRIGHT, ui.string1, TOPRIGHT, 0, 35)

	ui.sensitive = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
		name = "Case Sensitive:",
		tooltip = "ON - players must type exactly the invite string, OFF - players can type upper or lower case versions of invite string",
		default = AdvancedGroupRoster.defaults.groupInviteCaseSensitive,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteCaseSensitive end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteCaseSensitive = newValue end,
    })
    ui.sensitive.checkbox:SetAnchor(LEFT, ui.sensitive.container, RIGHT, -25, 0)
    ui.sensitive:SetAnchor(TOPLEFT, ui.string2, BOTTOMLEFT, 0, 15)

    ui.max = LAMCreateControl.slider(ui, {
        type = "slider",
		name = "Max Group Size:",
		tooltip = "How large your group should get",
		default = 24,
		min     = 4,
        max     = 24,
        step    = 1,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteSize end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteSize = newValue end,
    })
    ui.max:SetAnchor(TOPRIGHT, ui.sensitive, TOPRIGHT, 0, 35)

	ui.kick = LAMCreateControl.slider(ui, {
        type = "slider",
		name = "Auto-Kick:",
		tooltip = "Number of Seconds before auto-kicking a player from group that has gone offline. Set to 0 to never auto-kick.",
		default = 0,
		min     = 0,
        max     = 600,
        step    = 1,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteAutoKick end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteAutoKick = newValue end,
    })
    ui.kick:SetAnchor(TOPRIGHT, ui.max, TOPRIGHT, 0, 45)

	ui.zone = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
		name = "Non-Zone Only:",
		tooltip = "ON - only invite people who type the invite string in any chat but zone, OFF - invite people who type invite string in any chat",
		default = AdvancedGroupRoster.defaults.groupInviteNonZone,
		getFunc = function() return AdvancedGroupRoster.SV.groupInviteNonZone end,
		setFunc = function(newValue) AdvancedGroupRoster.SV.groupInviteNonZone = newValue end,
    })
    ui.zone.checkbox:SetAnchor(LEFT, ui.zone.container, RIGHT, -25, 0)
    ui.zone:SetAnchor(TOPLEFT, ui.kick, BOTTOMLEFT, 0, 15)
	
	local data =
    {
        name = 'Group Invite',
        categoryFragment = ZO_FadeSceneFragment:New(AGR_GI_Options),
        normalIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
        pressedIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_down.dds",
        mouseoverIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_over.dds",
    }

    GROUP_MENU_KEYBOARD:AddCategory(data)
end

function AdvancedGroupRoster:SetupGuilds()
	AdvancedGroupRoster.allGuilds = {}
	AdvancedGroupRoster.guildNames = {}

	for guild = 1, GetNumGuilds() do
		local guildId = GetGuildId(guild)
		local guildName = GetGuildName(guildId)

		if (not guildName or (guildName):len() < 1) then
			guildName = "Guild " .. guildId
		end

		AdvancedGroupRoster.allGuilds[guildId] = guildName
		table.insert(AdvancedGroupRoster.guildNames, guildName)
	end
end

function AdvancedGroupRoster.string_split(string, pattern)
	pattern = pattern or "%S+"
	local array = {}

	for i in string.gmatch(string, pattern) do
		table.insert(array, i)
	end

	return array
end

function AdvancedGroupRoster:InitControls()
	AdvancedGroupRosterReport:ClearAnchors();
	AdvancedGroupRosterReport:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AdvancedGroupRoster.SV.popupLeft, AdvancedGroupRoster.SV.popupTop);

	AdvancedGroupRosterReport:SetMouseEnabled(AdvancedGroupRoster.SV.unlocked) 
	AdvancedGroupRosterReport:SetMovable(AdvancedGroupRoster.SV.unlocked)
end

function AdvancedGroupRoster:SetUpCommands()
	SLASH_COMMANDS["/agrclearafk"] = function (extra)
		local pieces = AdvancedGroupRoster.string_split(extra)

		if #pieces == 1 then
			AdvancedGroupRoster.clearAwayMessage(extra)

			d("Cleared away status for: "..extra)
		else
			for playerName, awayInfo in pairs(AdvancedGroupRoster.rosterStatus) do
				AdvancedGroupRoster.rosterStatus[playerName].isAway = false
				AdvancedGroupRoster.rosterStatus[playerName].message = ''
				AdvancedGroupRoster.rosterStatus[playerName].timer = ''
			end

			AdvancedGroupRoster.UpdateGroupList()

			d("Cleared away status for everyone in the group.")
		end
	end

	local count = 1

	for guildId, guildName in pairs(self.allGuilds) do
		SLASH_COMMANDS["/ga"..count] = function (extra)
			local message = ''

			if self.SV.guildOption[guildId] ~= nil then
				message = self.SV.guildOption[guildId]
			end

			ZO_ChatWindowTextEntryEditBox:SetText(message)
		end
		
		SLASH_COMMANDS["/mg"..count] = function (extra)
			self.SV.guildOption[guildId] = extra
		end

		count = count + 1
	end

	SLASH_COMMANDS["/rreq"] = function (extra)
		if GetGroupSize() <= 0 then
			d("You're not in group. You can't use this function.")
			return
		end

		local characterName = ''
		local numPlayersEachType = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0
		}

		local playerType = 0
		local groupSize = GetGroupSize()
		local searchCharacterName = ''
		local searchName = ''

		for i=1, groupSize do
			characterName = GetUnitName(GetGroupUnitTagByIndex(i))
			searchCharacterName = string.gsub(characterName, "-", "")
			playerType = 0

			for j=1, 7 do
				for index, name in pairs(self.SV.rolePlayers[j]) do
					searchName = string.gsub(name, "-", "")

					if string.find(searchName, searchCharacterName) then
						numPlayersEachType[j] = numPlayersEachType[j] + 1
						playerType = 7
						break
					end
				end

				if playerType ~= 0 then
					break
				end
			end

			if playerType == 0 and AdvancedGroupRoster.SV.nonRoledDPS == true then
				numPlayersEachType[3] = numPlayersEachType[3] + 1
			end
		end
		
		local message = "You have the following of each type in group: "

		for index, amount in pairs(numPlayersEachType) do
			local name = self.SV.roleNames[index]
			local number = self.SV.roleAmount[index]

			if name ~= ''--[[ and number ~= nil and number > 0]] then
				message = message .. name .. ": "..amount.." / "..number.." "
			end
		end

		message = message .. 'Total: '..groupSize
		
		d(message)
	end
end

function AdvancedGroupRoster.tableContains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end

	return false
end

function AdvancedGroupRoster.getGroupMembers()
	local groupMembers = {}
	table.insert(groupMembers, 'Choose...')
	local groupSize = GetGroupSize()

	for i=1, groupSize do
		local playerName = GetUnitName(GetGroupUnitTagByIndex(i))

		if playerName ~= AdvancedGroupRoster.playerName then
			table.insert(groupMembers, playerName)
		end
	end

	return groupMembers
end

-- Creates the addon settings menu
function AdvancedGroupRoster:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Advanced Group Roster",
		displayName = "|c66ccffAdvanced Group Roster",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.2f", AdvancedGroupRoster.version),
		slashCommand = "/agr",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Advanced_Group_Roster", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Advanced Group Roster allows one to modify the group roster to one's needs, whether it's seeing everyone's account names or color-coding each person's role.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Advanced Group Roster Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Same settings for all characters",
		tooltip = "ON - Each character has the same set of settings, OFF - Separate settings for each character",
		requiresReload = true,
		default = self.accountWideDefaults.accountWide,
		getFunc = function() return self.DS.accountWide end,
		setFunc = function(newValue) self.DS.accountWide = newValue end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "UserID Display:",
		tooltip = 'Choose how to display the user account name',
		choices = {"Never", "Switch with Character Name", "Display next to Character Name"},
		getFunc = function() 
			if self.SV.useUserId==1 then 
				return "Never"
			elseif self.SV.useUserId==2 then
				return "Switch with Character Name"				
			elseif self.SV.useUserId==3 then
				return "Display next to Character Name"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Never" then 
				self.SV.useUserId=1
			elseif newValue=="Switch with Character Name" then
				self.SV.useUserId=2
			elseif newValue=="Display next to Character Name" then
				self.SV.useUserId=3
			end
			self:EditRosterHeader()
		end,
		default = 1,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Sort By UserID:",
		tooltip = "ON - sort roster by UserID, OFF - sort roster by Character Name (NOTE - this will stop sorting when group is greater then 20 people)",
		disabled = function()
			if self.SV.useUserId == 1 then
				self.SV.rosterSortUserID = false
				return true
			end
		end,
		default = self.defaults.rosterSortUserID,
		getFunc = function() return self.SV.rosterSortUserID end,
		setFunc = function(newValue) self.SV.rosterSortUserID = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Mark yourself with a STAR:",
		tooltip = "ON - shows a STAR next to your name, where the leader crown would usually be, OFF - no star is shown",
		default = self.defaults.markSelf,
		getFunc = function() return self.SV.markSelf end,
		setFunc = function(newValue) self.SV.markSelf = newValue end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Switch LVL with PVP Rank:",
		tooltip = 'Switch out the LVL column to show PVP rank instead',
		choices = {"Never", "PVP Only", "Always"},
		getFunc = function() 
			if self.SV.pvpRankLevel==1 then 
				return "Never"
			elseif self.SV.pvpRankLevel==2 then
				return "PVP Only"				
			elseif self.SV.pvpRankLevel==3 then
				return "Always"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Never" then 
				self.SV.pvpRankLevel=1
			elseif newValue=="PVP Only" then
				self.SV.pvpRankLevel=2
			elseif newValue=="Always" then
				self.SV.pvpRankLevel=3
			end
			self:EditRosterHeader()
		end,
		default = 1,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Switch LVL with Alliance Icon:",
		tooltip = "ON - switch LVL column with alliance icon, OFF - no switch is made",
		disabled = function()
			if self.SV.pvpRankLevel ~= 1 then
				return true
			end
		end,
		default = self.defaults.allianceIcon,
		getFunc = function() return self.SV.allianceIcon end,
		setFunc = function(newValue) self.SV.allianceIcon = newValue self:EditRosterHeader() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Hide Character Roles Not Used:",
		tooltip = "ON - hide those character roles that that person isn't using, OFF - shows all roles",
		default = self.defaults.showRoles,
		getFunc = function() return self.SV.showRoles end,
		setFunc = function(newValue) self.SV.showRoles = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Utilize Group Roster Notes:",
		tooltip = "ON - allows you to take notes on players in your group, OFF - hides the Group Roster Note Icon",
		default = self.defaults.utilizeGroupNotes,
		getFunc = function() return self.SV.utilizeGroupNotes end,
		setFunc = function(newValue) self.SV.utilizeGroupNotes = newValue self:EditRosterHeader() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Track Group Members' Status:",
		tooltip = "ON - tracks which of your group members are away, OFF - does not track status of group members",
		default = self.defaults.trackGroupStatus,
		getFunc = function() return self.SV.trackGroupStatus end,
		setFunc = function(newValue) self.SV.trackGroupStatus = newValue self.UpdateGroupMemberStatus() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto Transfer Leadership Upon Death:",
		tooltip = "ON - transfers leadership in order of secondary leaders when you die, OFF - you keep your group leadership upon death",
		default = self.defaults.autoTransferUponDeath,
		getFunc = function() return self.SV.autoTransferUponDeath end,
		setFunc = function(newValue) self.SV.autoTransferUponDeath = newValue end,
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Away Messages:",
		tooltip = "Choose which messages to listen for to determine whether a person is away",
		disabled = function()
			if self.SV.trackGroupStatus == false then
				return true
			end
		end,
		isMultiline = true,
		isExtraWide = true,
		getFunc = function() return self.SV.awayMessages end,
		setFunc = function(newValue)
			self.SV.awayMessages = newValue
			self.BuildAwayMessages()
		end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Nicknames:",
		tooltip = "Place a list of nicknames on each new line; eg. @aldericon = alder OR Aewenil = Healer #1",
		isMultiline = true,
		isExtraWide = true,
		getFunc = function() return self.SV.nicknames end,
		setFunc = function(newValue)
			self.SV.nicknames = newValue
			self.BuildNicknames()
		end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Secondary Leaders:",
		tooltip = "When you are leader, these people in group can utilize your leader abilities as well; eg. @aldericon",
		isMultiline = true,
		isExtraWide = true,
		getFunc = function() return self.SV.secLeaders end,
		setFunc = function(newValue)
			self.SV.secLeaders = newValue
			self.BuildSecondaryLeaders()
		end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Color Options",
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for Healers:",
		tooltip = "Pick the color of the Healer Role",
        default = ZO_ColorDef:New(unpack(self.SV.healColors)),
        getFunc = function() return unpack(self.SV.healColors) end,
		setFunc = function(r,g,b,a)
            self.SV.healColors = {r,g,b,a}
        end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for DPS:",
		tooltip = "Pick the color of the DPS Role",
        default = ZO_ColorDef:New(unpack(self.SV.dpsColors)),
        getFunc = function() return unpack(self.SV.dpsColors) end,
		setFunc = function(r,g,b,a)
            self.SV.dpsColors = {r,g,b,a}
        end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for Tanks:",
		tooltip = "Pick the color of the Tank Role",
        default = ZO_ColorDef:New(unpack(self.SV.tankColors)),
        getFunc = function() return unpack(self.SV.tankColors) end,
		setFunc = function(r,g,b,a)
            self.SV.tankColors = {r,g,b,a}
        end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for same Location:",
		tooltip = "Pick a color for those in the same location as you",
        default = ZO_ColorDef:New(unpack(self.SV.sameLocColors)),
        getFunc = function() return unpack(self.SV.sameLocColors) end,
		setFunc = function(r,g,b,a)
            self.SV.sameLocColors = {r,g,b,a}
        end,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Reset Color Options",
		tooltip = 'Reset your color options back to default',
		func = function ()
			self.OnResetColorOptions()
		end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Raid Attendance Options",
	})
	table.insert(optionsData, {
		type = "description",
		text = "Raid Attendance is a way to track which players are participating in group activities. During the raid, the attendance is available via keybindings. When the group activity is complete, all the group leader has to do is click the Export button below. Then, after performing a reload, the data will appear in the SavedVariables file for this addon. For most, this is found in C:\\Users\\NAME\\Documents\\Elder Scrolls Online\\live\\SavedVariables\\AdvancedGroupRoster.lua. Open Notepad++ and perform a Find & Replace (CTRL+H, second tab 'Replace') using this in the 'Find': (^\\s*\\[\\d*\\]\\s\\=\\s\\\")(.*)(\\\",$)   AND this in the 'Replace': \\2   . Select the option 'Regular Expression' and click 'Replace All'. Look for the word 'dump' in your file and you'll see a clear set of characters, then user ids, then times. You can copy each 'column' into whatever kind of file you need. Make sure not to save the SavedVariables file.",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Raid Attendance",
		tooltip = "ON - track raid attendance, OFF - does not track raid attendance",
		default = self.defaults.raidAttendance,
		getFunc = function() return self.SV.raidAttendance end,
		setFunc = function(newValue) self.SV.raidAttendance = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with frame positions",
		tooltip = "ON - various displays can moved on the screen by left clicking and dragging, OFF - all locked in place and cannot be moved",
		disabled = function()
			if self.SV.raidAttendance == false then
				return true
			end
		end,
		default = self.defaults.unlocked,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Export",
		tooltip = 'Exports to saved variables file; follow instructions (found in addon description) to get file contents',
		func = function ()
			self.ExportRaidAttendance(false)
		end,
	})
	--[[table.insert(optionsData, {
		type = "button",
		name = "Import",
		tooltip = 'Raid Attendance saves itself every 5 minutes; if you crash during a raid, use this to bring back attendance records. This will override your current attendance sheet.',
		func = function ()
			self.ImportRaidAttendance()
		end,
	})]]
	table.insert(optionsData, {
		type = "button",
		name = "Clear Attendance",
		tooltip = 'Clear the current session attendance AND the saved variables attendance.',
		func = function ()
			self.ClearRaidAttendance()
		end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Group Invite Options",
	})
	table.insert(optionsData, {
		type = "description",
		text = "Provides a variety of options for automatically having group members enter group.",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Settings in Group Finder:",
		tooltip = "ON - have most group invite settings listed in 'Group & Activity Finder' under 'Group Invite' instead of listed in addon settings, OFF - list settings in addon settings only",
		default = self.defaults.groupInviteFinder,
		requiresReload = true,
		getFunc = function() return self.SV.groupInviteFinder end,
		setFunc = function(newValue) self.SV.groupInviteFinder = newValue end,
	})
	if AdvancedGroupRoster.SV.groupInviteFinder == false then
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enabled:",
		tooltip = "ON - listens in chat for 'Invite String', OFF - does not listen in chat",
		default = self.defaults.groupInviteEnabled,
		getFunc = function() return self.SV.groupInviteEnabled end,
		setFunc = function(newValue) self.SV.groupInviteEnabled = newValue end,
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Invite String1:",
		tooltip = "Write the string that people should put in chat to be automatically invited to group",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		isMultiline = false,
		isExtraWide = false,
		getFunc = function() return self.SV.groupInviteString end,
		setFunc = function(newValue) self.SV.groupInviteString = newValue end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Invite String2:",
		tooltip = "Write the string that people should put in chat to be automatically invited to group",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		isMultiline = false,
		isExtraWide = false,
		getFunc = function() return self.SV.groupInviteString2 end,
		setFunc = function(newValue) self.SV.groupInviteString2 = newValue end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Case Sensitive:",
		tooltip = "ON - players must type exactly the invite string, OFF - players can type upper or lower case versions of invite string",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		default = self.defaults.groupInviteCaseSensitive,
		getFunc = function() return self.SV.groupInviteCaseSensitive end,
		setFunc = function(newValue) self.SV.groupInviteCaseSensitive = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Max Group Size:",
		tooltip = "How large your group should get",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		default = 24,
		min     = 4,
        max     = 24,
        step    = 1,
		getFunc = function() return self.SV.groupInviteSize end,
		setFunc = function(newValue) self.SV.groupInviteSize = newValue end,
	})
	--[[table.insert(optionsData, {
		type = "checkbox",
		name = "Cyrodiil Check:",
		tooltip = "ON - only invite people who are currently in Cyrodiil, OFF - does not check if member is in Cyrodiil",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		default = self.defaults.groupInvitePVPCheck,
		getFunc = function() return self.SV.groupInvitePVPCheck end,
		setFunc = function(newValue) self.SV.groupInvitePVPCheck = newValue end,
	})]]
	table.insert(optionsData, {
		type = "slider",
		name = "Auto-Kick:",
		tooltip = "Number of Seconds before auto-kicking a player from group that has gone offline. Set to 0 to never auto-kick.",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		default = 0,
		min     = 0,
        max     = 600,
        step    = 1,
		getFunc = function() return self.SV.groupInviteAutoKick end,
		setFunc = function(newValue) self.SV.groupInviteAutoKick = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Non-Zone Only:",
		tooltip = "ON - only invite people who type the invite string in any chat but zone, OFF - invite people who type invite string in any chat",
		disabled = function()
			if self.SV.groupInviteEnabled == false then
				return true
			end
		end,
		default = self.defaults.groupInviteNonZone,
		getFunc = function() return self.SV.groupInviteNonZone end,
		setFunc = function(newValue) self.SV.groupInviteNonZone = newValue end,
	})
	end
	
	for guildId, guildName in pairs(self.allGuilds) do
		table.insert(optionsData, {
			type = "dropdown",
			name = guildName.." Rank Restriction:",
			tooltip = "All guild members with this rank or higher can be invited to the raid. This won't apply to players that aren't in any of your guilds. Note that this won't work turned on for more then one guild at a time if members are in multiple guilds that you are also in and their guild rank is lower then that guild's rank restriction but their rank is higher in this guild rank's restriction.",
			choices = AdvancedGroupRoster.getGuildRanks(guildId),
			getFunc = function()
				if self.SV.guildRank[guildId] ~= nil then
					return self.SV.guildRank[guildId]
				else
					return ''
				end
			end,
			setFunc = function(newValue)
				self.SV.guildRank[guildId] = newValue
			end,
		})
	end
	
	table.insert(optionsData, {
		type = "header",
		name = "Raid Management",
	})
	table.insert(optionsData, {
		type = "description",
		text = "These options work with the Group Invite options above to further control your group. It gives you the option to rank group members into new categories - perhaps you have players that always run a certain ability - and to only invite up-to the amount of players you need for that role, which includes setting amounts for Tanks, Healers and DPS. You also have the option to rank them, allowing players that perform better but join later to auto-kick those that aren't performing as well.",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enabled:",
		tooltip = "ON - raid management settings are in affect, OFF - raid management settings are not running",
		default = self.defaults.raidManagementEnable,
		getFunc = function() return self.SV.raidManagementEnable end,
		setFunc = function(newValue) self.SV.raidManagementEnable = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Treat non-roled players as DPS:",
		tooltip = "ON - any players that aren't included in a role listing is considered DPS, OFF - non-roled players are not defaulted to being DPS",
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		default = self.defaults.nonRoledDPS,
		getFunc = function() return self.SV.nonRoledDPS end,
		setFunc = function(newValue) self.SV.nonRoledDPS = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Invite non-roled players:",
		tooltip = "ON - auto-invite any players that are not currently listed in a role, OFF - only auto-invite players that are listed in a role",
		disabled = function()
			if self.SV.raidManagementEnable == false or self.SV.nonRoledDPS == true then
				return true
			end
		end,
		default = self.defaults.groupInviteNonRoled,
		getFunc = function() return self.SV.groupInviteNonRoled end,
		setFunc = function(newValue) self.SV.groupInviteNonRoled = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Kick non-roled players:",
		tooltip = "ON - auto-kick any players that are not currently listed in a role once group is full, OFF - do not auto-kick non-roled players. Note that this setting uses the 'Max Group Size' Group Invite setting.",
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		default = self.defaults.groupInviteKickNonRoled,
		getFunc = function() return self.SV.groupInviteKickNonRoled end,
		setFunc = function(newValue) self.SV.groupInviteKickNonRoled = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "No Auto-Kick while in Combat:",
		tooltip = "ON - auto-kick does not kick while in combat, OFF - auto-kick regardless of combat status.",
		disabled = function()
			if self.SV.raidManagementEnable == false or self.SV.groupInviteKickNonRoled == false then
				return true
			end
		end,
		default = self.defaults.combatControlsKickNonRoled,
		getFunc = function() return self.SV.combatControlsKickNonRoled end,
		setFunc = function(newValue) self.SV.combatControlsKickNonRoled = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Group Size to apply Raid Management:",
		tooltip = "If you wish to only start restricting what roles people joining the group can play once you've reached a certain size, set that size here. To always apply it, set to 0.",
		default = 0,
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		min     = 0,
        max     = 24,
        step    = 1,
		getFunc = function() return self.SV.groupSizeRaidManage end,
		setFunc = function(newValue) self.SV.groupSizeRaidManage = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Use Ranking:",
		tooltip = "ON - kick higher ranking characters as lower ranking characters get invited to maintain the amount of that role you want in group, OFF - do not kick",
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		default = self.defaults.useRankingAutoKick,
		getFunc = function() return self.SV.useRankingAutoKick end,
		setFunc = function(newValue) self.SV.useRankingAutoKick = newValue end,
	})
	table.insert(optionsData, {
		type = "divider",
		height = 15,
		alpha = 0.5
	})

	table.insert(optionsData, {
		type = "dropdown",
		name = "List of Current Group Players:",
		tooltip = 'List of players in your current group, to be used for selecting and adding to / removing from roles. Need to reloadui to populate list.',
		disabled = function()
			if GetGroupSize() <= 0 or self.SV.raidManagementEnable == false then
				return true
			end
		end,
		choices = AdvancedGroupRoster.getGroupMembers(),
		getFunc = function() return AdvancedGroupRoster.currentGroupPlayerSelected end,
		setFunc = function(newValue) AdvancedGroupRoster.currentGroupPlayerSelected = newValue end,
		--reference = "AGRGroupList"
	})

	--[[local guildFriends = {}

	for guild = 1, GetNumGuilds() do
		guildFriends = {}
		table.insert(guildFriends, 'Choose...')

		local guildId = GetGuildId(guild)

		for i = 1, GetNumGuildMembers(guildId) do
			local _, rawCharacterName = GetGuildMemberCharacterInfo(guildId, i)

			--if AdvancedGroupRoster.tableContains(guildFriends, rawCharacterName) == false then
				table.insert(guildFriends, zo_strformat("<<1>>", rawCharacterName))
			--end
		end

		table.insert(optionsData, {
			type = "dropdown",
			name = "List of Guild #"..guild.." Members:",
			tooltip = 'List of guild members, to be used for selecting and adding to / removing from roles. List contains characters from when they last longs on. Need to reloadui to populate.',
			choices = guildFriends,
			getFunc = function() return AdvancedGroupRoster.currentGuildFriendSelected end,
			setFunc = function(newValue) AdvancedGroupRoster.currentGuildFriendSelected = newValue end
		})
	end]]

	local friendPlayers = {}
	table.insert(friendPlayers, 'Choose...')
	
	for i = 1, GetNumFriends() do
		local _, rawCharacterName = GetFriendCharacterInfo(i)

		--if AdvancedGroupRoster.tableContains(friendPlayers, rawCharacterName) == false then
			table.insert(friendPlayers, zo_strformat("<<1>>", rawCharacterName))
		--end
    end

	table.insert(optionsData, {
		type = "dropdown",
		name = "List of Friends:",
		tooltip = 'List of current friends, to be used for selecting and adding to / removing from roles. List contains characters from when they last longs on. Need to reloadui to populate.',
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		choices = friendPlayers,
		getFunc = function() return AdvancedGroupRoster.currentFriendSelected end,
		setFunc = function(newValue) AdvancedGroupRoster.currentFriendSelected = newValue end
	})

	table.insert(optionsData, {
		type = "editbox",
		name = "Player to Add / Remove:",
		tooltip = "A character name, to be used for adding to / removing from roles",
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		isMultiline = false,
		isExtraWide = false,
		getFunc = function() return AdvancedGroupRoster.currentCharacterNameWritten end,
		setFunc = function(newValue) AdvancedGroupRoster.currentCharacterNameWritten = newValue end
	})

	table.insert(optionsData, {
		type = "dropdown",
		name = "Player Rank:",
		tooltip = 'What rank the player will have, to be used for adding to / removing from roles',
		disabled = function()
			if self.SV.raidManagementEnable == false then
				return true
			end
		end,
		choices = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24},
		getFunc = function() return AdvancedGroupRoster.currentPlayerRank end,
		setFunc = function(newValue) AdvancedGroupRoster.currentPlayerRank = newValue end,
		default = 1
	})

	table.insert(optionsData, {
		type = "divider",
		height = 15,
		alpha = 0.5
	})

	for j=1, 7 do
		if j == 1 or j == 2 or j == 3 then
			local name = ""

			if j == 1 then
				name = "Tanks"
			elseif j == 2 then
				name = "Healers"
			elseif j == 3 then
				name = "DPS"
			end
			
			table.insert(optionsData, {
				type = "editbox",
				name = "Role Name #"..j..":",
				tooltip = "The name of the role you're making",
				disabled = function() return true end,
				isMultiline = false,
				isExtraWide = false,
				getFunc = function() return name end
			})
		elseif j > 3 then
			table.insert(optionsData, {
				type = "editbox",
				name = "Role Name #"..j..":",
				tooltip = "The name of the role you're making",
				disabled = function()
					if self.SV.raidManagementEnable == false then
						return true
					end
				end,
				isMultiline = false,
				isExtraWide = false,
				getFunc = function() 
					if self.SV.roleNames[j] ~= nil then
						return self.SV.roleNames[j]
					else
						return ''
					end
				end,
				setFunc = function(newValue) self.SV.roleNames[j] = newValue end
			})
		end

		table.insert(optionsData, {
			type = "dropdown",
			name = "Player Type in Group Amount #"..j..":",
			tooltip = 'How many of this player type are allowed in group',
			disabled = function()
				if self.SV.raidManagementEnable == false or (self.SV.nonRoledDPS == true and j == 3) then
					return true
				end
			end,
			choices = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24},
			getFunc = function() 
				if self.SV.roleAmount[j] ~= nil then
					return self.SV.roleAmount[j]
				else
					return ''
				end
			end,
			setFunc = function(newValue) self.SV.roleAmount[j] = newValue end
		})
		table.insert(optionsData, {
			type = "dropdown",
			name = "Players for Role #"..j..":",
			tooltip = 'List of players currently in this role',
			disabled = function()
				if self.SV.raidManagementEnable == false or (self.SV.nonRoledDPS == true and j == 3) then
					return true
				end
			end,
			choices = self.SV.rolePlayers[j],
			getFunc = function() 
				if self.SV.rolePlayers[j] ~= nil then
					return self.SV.rolePlayers[j]
				else
					return ''
				end
			end,
			setFunc = function(newValue) end,
			reference = "AGRTypeList"..j
		})
		table.insert(optionsData, {
			type = "checkbox",
			name = "On-Screen Announcement upon death of #"..j..":",
			tooltip = "ON - receive an on-screen announcement whenever one of this type dies, OFF - no on-screen announcement upon death",
			disabled = function()
				if self.SV.raidManagementEnable == false then
					return true
				end
			end,
			default = self.defaults.roleDeathAnnouncement[j],
			getFunc = function() return self.SV.roleDeathAnnouncement[j] end,
			setFunc = function(newValue) self.SV.roleDeathAnnouncement[j] = newValue end,
		})
		table.insert(optionsData, {
			type = "button",
			name = "Add to #"..j,
			tooltip = 'Add the selected player from group AND/OR from the typed player character name.',
			disabled = function()
				if self.SV.raidManagementEnable == false or (self.SV.nonRoledDPS == true and j == 3) then
					return true
				end
			end,
			func = function ()
				if AdvancedGroupRoster.currentGroupPlayerSelected ~= '' and AdvancedGroupRoster.currentGroupPlayerSelected ~= 'Choose...' then
					table.insert(self.SV.rolePlayers[j], AdvancedGroupRoster.currentGroupPlayerSelected..' '..AdvancedGroupRoster.currentPlayerRank)
				end

				if AdvancedGroupRoster.currentCharacterNameWritten ~= '' and AdvancedGroupRoster.currentCharacterNameWritten ~= 'Choose...' then
					table.insert(self.SV.rolePlayers[j], AdvancedGroupRoster.currentCharacterNameWritten..' '..AdvancedGroupRoster.currentPlayerRank)
				end

				--[[if AdvancedGroupRoster.currentGuildFriendSelected ~= '' and AdvancedGroupRoster.currentGuildFriendSelected ~= 'Choose...' then
					table.insert(self.SV.rolePlayers[j], AdvancedGroupRoster.currentGuildFriendSelected..' '..AdvancedGroupRoster.currentPlayerRank)
				end]]

				if AdvancedGroupRoster.currentFriendSelected ~= '' and AdvancedGroupRoster.currentFriendSelected ~= 'Choose...' then
					table.insert(self.SV.rolePlayers[j], AdvancedGroupRoster.currentFriendSelected..' '..AdvancedGroupRoster.currentPlayerRank)
				end

				local players_dropdown = WINDOW_MANAGER:GetControlByName("AGRTypeList"..j)
				players_dropdown:UpdateChoices(self.SV.rolePlayers[j])
			end
		})
		table.insert(optionsData, {
			type = "button",
			name = "Remove from #"..j,
			tooltip = "Remove the selected player from the 'Players for Role #"..j.."' option from this type. You must write / select the name where you would add the name to remove it from the list. Selecting it from the list and clicking this button will not remove it.",
			disabled = function()
				if self.SV.raidManagementEnable == false or (self.SV.nonRoledDPS == true and j == 3) then
					return true
				end
			end,
			func = function ()
				if AdvancedGroupRoster.currentGroupPlayerSelected ~= '' and AdvancedGroupRoster.currentGroupPlayerSelected ~= 'Choose...' then
					for index, name in pairs(self.SV.rolePlayers[j]) do
						if name == AdvancedGroupRoster.currentGroupPlayerSelected..' '..AdvancedGroupRoster.currentPlayerRank then
							table.remove(self.SV.rolePlayers[j], index)
							break
						end
					end
				end

				if AdvancedGroupRoster.currentCharacterNameWritten ~= '' and AdvancedGroupRoster.currentCharacterNameWritten ~= 'Choose...' then
					for index, name in pairs(self.SV.rolePlayers[j]) do
						if name == AdvancedGroupRoster.currentCharacterNameWritten..' '..AdvancedGroupRoster.currentPlayerRank then
							table.remove(self.SV.rolePlayers[j], index)
							break
						end
					end
				end

				--[[if AdvancedGroupRoster.currentGuildFriendSelected ~= '' and AdvancedGroupRoster.currentGuildFriendSelected ~= 'Choose...' then
					for index, name in pairs(self.SV.rolePlayers[j]) do
						if name == AdvancedGroupRoster.currentGuildFriendSelected..' '..AdvancedGroupRoster.currentPlayerRank then
							table.remove(self.SV.rolePlayers[j], index)
							break
						end
					end
				end]]

				if AdvancedGroupRoster.currentFriendSelected ~= '' and AdvancedGroupRoster.currentFriendSelected ~= 'Choose...' then
					for index, name in pairs(self.SV.rolePlayers[j]) do
						if name == AdvancedGroupRoster.currentFriendSelected..' '..AdvancedGroupRoster.currentPlayerRank then
							table.remove(self.SV.rolePlayers[j], index)
							break
						end
					end
				end

				local players_dropdown = WINDOW_MANAGER:GetControlByName("AGRTypeList"..j)
				players_dropdown:UpdateChoices(self.SV.rolePlayers[j])
			end
		})

		if j ~= 7 then
			table.insert(optionsData, {
				type = "divider",
				height = 15,
				alpha = 0.5
			})
		end
	end

	table.insert(optionsData, {
		type = "header",
		name = "Guild Advertisement(s)",
	})
	table.insert(optionsData, {
		type = "description",
		text = "List your guild advertisements here, and you can use chat commands to automatically post them in your current chat instead of typing them out manually.",
	})

	local count = 1

	for guildId, guildName in pairs(self.allGuilds) do
		table.insert(optionsData, {
			type = "editbox",
			name = guildName.." Advertisement:",
			tooltip = "Write the advertisement here, then use '/ga"..count.."' in chat to write it",
			isMultiline = true,
			isExtraWide = true,
			getFunc = function()
				if self.SV.guildOption[guildId] ~= nil then
					return self.SV.guildOption[guildId]
				else
					return ''
				end
			end,
			setFunc = function(newValue)
				self.SV.guildOption[guildId] = newValue
			end,
			width = "full",
		})

		count = count + 1
	end
	
	self.LAM2:RegisterOptionControls("Advanced_Group_Roster", optionsData)

	ZO_CreateStringId("SI_BINDING_NAME_RAIDATTENDANCE_SHOW_REPORT", "Toggle Raid Attendance Report")
end

function AdvancedGroupRoster.ClockToSeconds(clockTime)
	local hours = tonumber(string.sub(clockTime, 1,2))
	local minutes = tonumber(string.sub(clockTime, 4,5))
	local seconds = tonumber(string.sub(clockTime, 7,8))

	return (hours * 60 * 60) + (minutes * 60) + seconds
end

function AdvancedGroupRoster.Explode(div, str)
	if (div=='') then return false end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end

function AdvancedGroupRoster.spairs(t, order)
    local keys = {}

    for k in pairs(t) do
		keys[#keys+1] = k
	end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0

    return function()
        i = i + 1

        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function AdvancedGroupRoster.tablelength(T)
	local count = 0

	for _ in pairs(T) do
		count = count + 1
	end

	return count
end

function AdvancedGroupRoster.findGroupUnitTag(name)
	for i = 1, GetGroupSize() do
		local tag = GetGroupUnitTagByIndex(i)

		if GetUnitDisplayName(tag) == name or GetUnitName(tag) == name then
			return tag
		end
	end

	return nil
end

function AdvancedGroupRoster.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function AdvancedGroupRoster.startsWith(str, start)
	return str:sub(1, #start) == start
end

function AdvancedGroupRoster.findCharacterName(displayName)
	for guild = 1, GetNumGuilds() do
		local guildId = GetGuildId(guild)
		local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName) 

		if memberIndex ~= nil then
			local _, rawCharacterName = GetGuildMemberCharacterInfo(guildId, memberIndex)
			return zo_strformat("<<1>>", rawCharacterName)
		end
	end

	for i = 1, GetNumFriends() do
		local friendDisplayName = GetFriendInfo(i)

		if friendDisplayName == displayName then
			local _, rawCharacterName = GetFriendCharacterInfo(i)
			return zo_strformat("<<1>>", rawCharacterName)
		end
    end

	return displayName
end

function AdvancedGroupRoster.onPlayerDead(eventCode) 
	if AdvancedGroupRoster.SV.autoTransferUponDeath == false or IsUnitGroupLeader('player') == false then
		return
	end

	for secLeader, _ in pairs(AdvancedGroupRoster.SV.listSecLeaders) do
		if IsPlayerInGroup(secLeader) == true then
			GroupPromote(AdvancedGroupRoster.findGroupUnitTag(secLeader))
			d("Upon your death, ".. secLeader .. " was promoted to group leader")
			return
		end
	end
end

-- only activates in group
function AdvancedGroupRoster.onGroupMemberDead(eventCode, unitTag, isDead)
	local characterName = GetUnitName(unitTag)

	if isDead == false or AdvancedGroupRoster.playerName == characterName or characterName == nil or characterName == '' then
		return
	end

	local searchCharacterName = string.gsub(characterName, "-", "")
	local timing = 2000

	if AdvancedGroupRoster.SV.nonRoledDPS == true and AdvancedGroupRoster.SV.roleDeathAnnouncement[3] == true then
		AdvancedGroupRoster.ScreenNotification(characterName .. " ("..GetUnitDisplayName(unitTag)..") just died", timing)
		return
	end

	for j=1, 7 do
		if AdvancedGroupRoster.SV.roleDeathAnnouncement[j] == true then
			for index, name in pairs(AdvancedGroupRoster.SV.rolePlayers[j]) do
				searchName = string.gsub(name, "-", "")

				if string.find(searchName, searchCharacterName) then
					AdvancedGroupRoster.ScreenNotification(characterName .. " ("..GetUnitDisplayName(unitTag)..") just died", timing)
					return
				end
			end
		end
	end
end

function AdvancedGroupRoster.ScreenNotification(message, timeOnScreen)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(message)
	messageParams:SetLifespanMS(timeOnScreen)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function AdvancedGroupRoster.getGuildRanks(guildId)
	local guildRanks = {}
	table.insert(guildRanks, 'Do Not Use')

	for rankIndex=1, GetNumGuildRanks(guildId) do
		table.insert(guildRanks, GetGuildRankCustomName(guildId, rankIndex))
	end

	return guildRanks
end

EVENT_MANAGER:RegisterForEvent(AdvancedGroupRoster.name, EVENT_ADD_ON_LOADED, AdvancedGroupRoster.OnAddOnLoaded)