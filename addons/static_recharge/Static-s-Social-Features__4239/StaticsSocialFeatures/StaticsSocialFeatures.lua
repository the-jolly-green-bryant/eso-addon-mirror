--[[------------------------------------------------------------------------------------------------
Title:					Static's Social Features
Author:					Static_Recharge
Version:				2.0.1
Description:		Adds specific social featues.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER
local CR = CHAT_ROUTER


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures Class Initialization
StaticsSocialFeatures    													- Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :LogoutQuitHook()															- Hooks into the logout and quit function to set character status if needed before actually logging out.
├─ :FriendMessageHook()                						- Hooks into the friends message to allow only showing for fav friends.
├─ :GetCharacterIndex()                						- Returns the index of the curent character from the saved vars table.
├─ :OnPlayerActivated(initial) 										- Fires once after load or reload. Performs various on load functions.
├─ :UpdateGuildList() 														- Updates the internal guild list data.
└─ :Test(...)                                     - For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--
StaticsSocialFeatures = {}


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:Initialize()
Inputs:				None
Outputs:			None
Description:	Initializes all of the variables, modules, slash commands, keybinds and main events.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:Initialize()
	-- Static definitions
	self.addonName = "StaticsSocialFeatures"
	self.addonVersion = "2.0.1"
	self.varsVersion = 2 -- SHOULD BE 2
	self.charVarsVersion = 1
	self.author = "|CFF0000Static_Recharge|r"

	-- Paired Lists
	self.PlayerStatus = LibStatic:PairedListNew(
		{"Disabled", "Online", "Away", "Do Not Disturb", "Offline"},
		{5, PLAYER_STATUS_ONLINE, PLAYER_STATUS_AWAY, PLAYER_STATUS_DO_NOT_DISTURB, PLAYER_STATUS_OFFLINE}
	)

	self.AllFavNone = LibStatic:PairedListNew(
		{"All", "Fav", "None"},
		{1, 2, 3}
	)

	self.NotificationTypes = LibStatic:PairedListNew(
		{"Chat", "Center Screen", "Alert"},
		{1, 2, 3}
	)

  self.NotificationSizes = LibStatic:PairedListNew(
		{"Small", "Medium", "Large"},
		{CSA_CATEGORY_SMALL_TEXT, CSA_CATEGORY_MAJOR_TEXT, CSA_CATEGORY_LARGE_TEXT}
	)

	self.NotificationSounds = LibStatic:PairedListNew(
		{"None", "Book", "Default", "Map Open", "Error", "New Notification"},
		{SOUNDS.NONE, SOUNDS.BOOK_ACQUIRED, SOUNDS.DEFAULT_CLICK, SOUNDS.MAP_WINDOW_OPEN, SOUNDS.GENERAL_ALERT_ERROR, SOUNDS.NEW_NOTIFICATION}
	)

	self:UpdateGuildList()

	self.IconTextures = {
		"/esoui/art/compass/target_gold_star.dds",					-- Gold Star
		"/esoui/art/compass/target_blue_square.dds",				-- Blue Square
		"/esoui/art/compass/target_green_circle.dds",				-- Green Circle
		"/esoui/art/compass/target_orange_triangle.dds",		-- Orange Triangle
		"/esoui/art/compass/target_pink_moons.dds",					-- Pink Moons
		"/esoui/art/compass/target_purple_oblivion.dds",		-- Purple Oblivion
		"/esoui/art/compass/target_red_weapons.dds",				-- Red Weapons
		"/esoui/art/compass/target_white_skull.dds",				-- White Skull
		"/esoui/art/armory/buildicons/buildicon_5.dds",			-- CP Star
		"/esoui/art/armory/buildicons/buildicon_32.dds",		-- Dolmen Swirl
		"/esoui/art/armory/buildicons/buildicon_34.dds",		-- Veteran
		"/esoui/art/armory/buildicons/buildicon_46.dds",		-- DB Hand
		"/esoui/art/armory/buildicons/buildicon_49.dds",		-- Buddies
		"/esoui/art/tutorial/journal_tabicon_quest_up.dds",	-- Quest Icon
		"/esoui/art/buttons/featuredot_active.dds",					-- Feature Dot
	}

	self.Defaults = {
		-- Friends List
		favFriendsTop = true,
		sharedGuilds = self.AllFavNone.All,
		sharedGuildsGroup = true,
		favIconSize = 90, -- %
		favIconInheritColor = false,
		favIconTexture = self.IconTextures[1],

		-- Status
		charOverride = self.PlayerStatus.Disabled,
		charOverrideLogin = false,
		charOverrideLogout = false,
		accountOverride = self.PlayerStatus.Disabled,
		accountOverrideLogin = false,
		accountOverrideLogout = false,
		accountOverrideEnabled = true,
		afkTimerEnabled = true,
		afkTimeout = 600, -- seconds

		-- Notifications
		offlineNotice = true,
		groupInvite = self.AllFavNone.All,
		whisperNotice = true,
		notificationType = self.NotificationTypes["Center Screen"],
		notificationSize = self.NotificationSizes.Medium,
		notificationSound = self.NotificationSounds["Book Acquired"],
		afkNotice = true,
		offlineTimerEnabled = false,
		offlineTimeout = 10, -- minutes
		offlineTimerNotice = true,
		offlineTimerEnd = nil,
		multiMountNotify = true,
		friendMsg = self.AllFavNone.All,
		friendMsgChat = true,

		-- Repped Guild
		reppedGuildAccountSelection = 0,

		-- Lists and Tables
		Characters = {},
		Favs = {},
		Friends = {},
		Ignored = {},

		-- Misc.
		chatEnabled = true,
		debugEnabled = false,
		settingsChanged = true,
	}

	self.CharDefaults = {
		-- Multi Mount
		multiMountEnable = false,
		multiMount = nil,
		soloMount = nil,

		-- Repped Guild
		reppedGuildAccountEnabled = false,
		reppedGuildMarqueeEnabled = false,
		reppedGuildMarqueeInterval = 5, -- minutes
		reppedGuildMarqueeSelections = {},
	}

	-- Session variables
	self.chatRouterEventRedirected = false
	self.marqueeIndex = 1
	self.marqueeRunning = false
	

	-- Saved variables initialization
	self.SV = ZO_SavedVars:NewAccountWide("StaticsSocialFeaturesAccountWideVars", self.varsVersion, nil, self.Defaults, GetWorldName())
	self.CH = ZO_SavedVars:NewCharacterIdSettings("StaticsSocialFeaturesCharVars", self.charVarsVersion, nil, self.CharDefaults, GetWorldName())
	--RequestAddOnSavedVariablesPrioritySave(self.addonName)

	-- Update Character list (preserve any settings)
	local NewData = {}

	for i=1, GetNumCharacters() do
		local name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
		local found = false
		name = zo_strformat("<<1>>", name)

		for index, value in ipairs(self.SV.Characters) do
			if value.id == id then
				NewData[i] = {name = name, id = id, charOverride = value.charOverride, charOverrideLogin = value.charOverrideLogin, charOverrideLogout = value.charOverrideLogout}
				found = true
				break
			end
		end

		if not found then
			NewData[i] = {name = name, id = id, charOverride = self.Defaults.charOverride, charOverrideLogin = self.Defaults.charOverrideLogin, charOverrideLogout = self.Defaults.charOverrideLogout}
		end
	end

	table.sort(NewData, function(a, b) return a.name < b.name end)
	self.SV.Characters = NewData

	-- Library Initializations
	local Options = {
		addonIdentifier = "SSF",
		prefixColor = "FF6600",
		textColor = "FFFFFF",
		chatEnabled = self.SV.chatEnabled,
		debugEnabled = self.SV.debugEnabled,
	}
	self.Chat = LibStatic:ChatNew(Options)

	-- Module Initializations
	self.Status:Initialize(self)
	self.Notifications:Initialize(self)
	self.Lists:Initialize(self)
	self.Mounts:Initialize(self)
	self.Settings:Initialize(self)

	-- Hooks and Events
	self:LogoutQuitHook()
	self:FriendMessageHook()
	EM:RegisterForEvent(self.addonName, EVENT_PLAYER_ACTIVATED, function(_, ...) self:OnPlayerActivated(...) end)

	-- Slash Commands
	--SLASH_COMMANDS["/ssftest"] = function(...) self:Test(...) end

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:LogoutQuitHook()
Inputs:			  None
Outputs:			None
Description:	Hooks into the logout and quit function to set character status if needed before actually logging out.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:LogoutQuitHook()
	function self:OnLogout()
		self.Chat:Debug("Logout/Quit prehook started.")
		if self.SV.accountOverrideEnabled and self.SV.accountOverrideLogout then
			SelectPlayerStatus(self.SV.accountOverride)
			self.Chat:Debug(zo_strformat("Player status set to <<1>>", self.SV.accountOverride))
		else
			local i = self:GetCharacterIndex()
			if self.SV.Characters[i].charOverride ~= self.PlayerStatus.Disabled and self.SV.Characters[i].charOverrideLogout then
				SelectPlayerStatus(self.SV.Characters[i].charOverride)
				self.Chat:Debug(zo_strformat("Player status set to <<1>>", self.SV.Characters[i].charOverride))
			end
		end
	end
	ZO_PreHook('Logout', function() self:OnLogout() end)
	ZO_PreHook('Quit', function() self:OnLogout() end)
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:FriendMessageHook()
Inputs:			  None
Outputs:			None
Description:	Hooks into the friends message to allow only showing for fav friends.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:FriendMessageHook()
	function self:OnFriendStatusChanged(eventCode, displayName, characterName, oldStatus, newStatus)
		self.Chat:Debug("Friend Message prehook started.")
		if self.SV.friendMsg == self.AllFavNone.None then return end
		if self.SV.friendMsg == self.AllFavNone.Fav and self.SV.Favs[displayName] then
			if not self.SV.friendMsgChat and self.SV.notificationType ~= self.NotificationTypes.Chat then
				local wasOnline = oldStatus ~= self.PlayerStatus.Offline
				local isOnline = newStatus ~= self.PlayerStatus.Offline
				if wasOnline ~= isOnline then
					local text
					if isOnline then
						self.Notifications:Notify(zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayName, characterName))
					else
						self.Notifications:Notify(zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayName, characterName))
					end
				end
			else
				CR:FormatAndAddChatMessage(eventCode, displayName, characterName, oldStatus, newStatus)
			end
		end
	end
	if self.SV.friendMsg ~= self.AllFavNone.All and self.chatRouterEventRedirected == false then
		EM:UnregisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED)
		EM:RegisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(...) self:OnFriendStatusChanged(...) end)
		self.chatRouterEventRedirected = true
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:GetCharacterIndex()
Inputs:			  None
Outputs:			index 					- The index of the character
Description:	Returns the index of the curent character from the saved vars table.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:GetCharacterIndex()
	local index
	local id = GetCurrentCharacterId()
	for i, v in ipairs(self.SV.Characters) do
		if v.id == id then
			index = i
			break
		end
	end
	return index
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:OnPlayerActiviated()
Inputs:			  initial 														- (bool) true if first load after login
Outputs:			None
Description:	Fires once after load or reload. Performs various on load functions.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:OnPlayerActivated(initial)
	-- Repped Guild Update
	self:ReppedGuildAccountWideUpdate()
	self:MarqueeUpdate()

	EM:UnregisterForEvent(self.addonName, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:ReppedGuildAccountWideUpdate()
Inputs:			  None
Outputs:			None
Description:	Updates the repped guild based on account wide setting.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:ReppedGuildAccountWideUpdate()
	local enabled, marquee = self.CH.reppedGuildAccountEnabled, self.CH.reppedGuildMarqueeEnabled
	local selection = self.SV.reppedGuildAccountSelection
	if enabled and not marquee then
		SetRepresentedGuildId(selection)
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:UpdateGuildList()
Inputs:			  None
Outputs:			None
Description:	Updates the internal guild paired list.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:UpdateGuildList()
	local guildIds = {0}
	local guildNames = {"None"}
	for i=1, GetNumGuilds() do
		local id = GetGuildId(i)
		table.insert(guildNames, GetGuildName(id))
		table.insert(guildIds, id)
	end

	if not self.Guilds then
		self.Guilds = LibStatic:PairedListNew(guildNames, guildIds)
	else
		self.Guilds:UpdateData(guildNames, guildIds)
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:MarqueeUpdate()
Inputs:			  None
Outputs:			None
Description:	Updates the repped guild marquee system. Turns off if not needed.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:MarqueeUpdate()
	local function SetNextMarqueeGuild()
		local min, max = 1, #self.CH.reppedGuildMarqueeSelections
		self.marqueeIndex = self.marqueeIndex + 1
		if self.marqueeIndex > max then self.marqueeIndex = min end
		SetRepresentedGuildId(self.CH.reppedGuildMarqueeSelections[self.marqueeIndex])
	end

	if self.CH.reppedGuildMarqueeEnabled and #self.CH.reppedGuildMarqueeSelections >= 2 then
		if self.marqueeRunning then
			EM:UnregisterForUpdate(self.addonName)
		end
		self.marqueeIndex = 1
		EM:RegisterForUpdate(self.addonName, self.CH.reppedGuildMarqueeInterval * 60 * 1000, SetNextMarqueeGuild)
		self.marqueeRunning = true
	else
		EM:UnregisterForUpdate(self.addonName)
		self.marqueeRunning = false
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsSocialFeatures:Test(...)
Inputs:				...							- Various test inputs.
Outputs:			None
Description:	For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--
function StaticsSocialFeatures:Test(...)
	--self.Notifications:Notify(...)
	--self:Chat(...)
end


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, StaticsSocialFeatures, of the StaticsSocialFeatures class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("StaticsSocialFeatures", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "StaticsSocialFeatures" then return end
	EM:UnregisterForEvent("StaticsSocialFeatures", EVENT_ADD_ON_LOADED)
	StaticsSocialFeatures:Initialize()
end)