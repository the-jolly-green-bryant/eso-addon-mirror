--[[------------------------------------------------------------------------------------------------
Title:					Static's Recruiter
Author:					Static_Recharge
Version:				3.0.2
Description:		Creates a list of zones to teleport to for the purposes of recruiting.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local LAM2 = LibAddonMenu2
local CDM = ZO_COLLECTIBLE_DATA_MANAGER
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
SR Class Initialization
SR    - Parent object containing all functions, tables, variables, constants and other data managers.
  |-  Defaults    - Default values for saved vars and settings menu items.
  |-  FM    - Friend Data Manager (See FriendDataManager.lua)
  |-  GM    - Guild Data Manager (See GuildDataManager.lua)
  |-  HM    - House Data Manager (See HouseDataManager.lua)
  |-  ZM    - Zone Data Manager (See ZoneDataManager.lua)
------------------------------------------------------------------------------------------------]]--
local SR = ZO_InitializingObject:Subclass()

--[[------------------------------------------------------------------------------------------------
SR:Initialize()
Inputs:				None
Outputs:			None
Description:	Initializes all of the variables, data managers, slash commands and event callbacks.
------------------------------------------------------------------------------------------------]]--
function SR:Initialize()
	-- Static definitions
	self.addonName = "StaticsRecruiter"
	self.addonVersion = "3.0.2"
	self.author = "|CFF0000Static_Recharge|r"
	self.chatPrefix = "|c66CCFF[Static's Recruiter]:|r "
	self.chatTextColor = "|cFFFFFF"
	self.chatSuffix = "|r"
	self.msgMaxChars = MAX_TEXT_CHAT_INPUT_CHARACTERS
	self.varsVersion = 2
	self.autoStarted = false
	self.waitingForFocus = false
	self.zoneIndex = 1
	self.destination = nil
	self.completed = 0
	self.total = 0
	self.Zones = {}
	self.Defaults = {
		Guilds = {},
		payWayshrineFee = false,
		autoFill = false,
		autoFillGuildSelection = nil,
		autoNext = false,
		chatMsgEnabled = true,
		zoneCheckbox = false,
		debugMode = false,
		selectedProfile = 1,
		autoRetry = true,
		Profiles = {
			[1] = {
				name = "Default",
				Zones = {
					[382] = true,		-- Reaper's March
					[383] = true,		-- Grahtwood
					[92] = true,		-- Bangkorai
					[19] = true,		-- Stormhaven
					[103] = true,		-- The Rift
					[57] = true,		-- Deshaan
					[888] = true,		-- Craglorn
					[849] = true,		-- Vvardenfell
					[1011] = true,	-- Summerset
					[1086] = true,	-- Northern Elseweyr
					[1160] = true,	-- Western Skyrim
					[1261] = true,	-- Blackwood
					[1381] = true,	-- High Isle
					[1414] = true,	-- Telvanni Peninsula
					[1443] = true,	-- West Weald
					[1502] = true, 	-- Solstice
				},
			},
		}
	}

	-- Saved variables initialization
	self.SavedVars = ZO_SavedVars:NewAccountWide("StaticsRecruiterAccountWideVars", self.varsVersion, nil, self.Defaults, GetWorldName())

	-- Data Manager Initializations
	self.HM = StaticsRecruiterInitHouseDataManager(self)
	self.GM = StaticsRecruiterInitGuildDataManager(self)
	self.FM = StaticsRecruiterInitFriendDataManager(self)
	self.ZM = StaticsRecruiterInitZoneDataManager(self)
	self.SM = StaticsRecruiterInitSettingsDataManager(self)
	
	-- Event fired functions
	--[[------------------------------------------------------------------------------------------------
	local function OnPlayerActivated(eventCode, initial)
	Inputs:				eventCode				- Internal ZOS event code, not used here.
								initial					- Indicates if this is the first activation from log-in. From 
																experience this is actually opposite what it means.
	Outputs:			None
	Description:	Fired when the player character is available after loading screens such as changing 
								zones, reloadui and logging in. If the system is in auto mode (autoStarted) and the 
								new zone after activation matches the destination then load the recruitment message 
								into the chat box. If the game is not focused then wait until focus.
	------------------------------------------------------------------------------------------------]]--
	local function OnPlayerActivated(eventCode, initial)
		self:DebugMsg("OnPlayerActivated event fired.")
		local id
  	if self.SavedVars.autoFill and initial and self.autoStarted then -- The input "initial" is actually "not initial"
			if self.SavedVars.autoFillGuildSelection then
  			id = self.SavedVars.autoFillGuildSelection
				self:DebugMsg("autofillGuildSelection = " .. GetGuildName(id))
			else
				self:SendToChat("No Guild selected to recruit for. Please select a guild in the add-on settings.")
				return
			end
  		if DoesGameHaveFocus() then
				self:DebugMsg("Game has focus.")
  			if self.ZM:DoesPlayerLocationMatch(self.destination) then
					self:AutoTravelProgress()
					self:DebugMsg("Player location matched destination.")
  				StartChatInput(self.SavedVars.Guilds[id].recruitMsg, CHAT_CHANNEL_ZONE)
				elseif self.SavedVars.autoRetry then
					self:DebugMsg("Player location doesn't match destination. Trying again.")
					self:SendToChat("Zone mismatch, trying again...")
					self.zoneIndex = self.zoneIndex - 1
					self:Travel()
  			else
  				self:SendToChat("Current zone doesn't match selection. Auto recruit stopping.")
  				self:ResetAutoTravelProgress()
  			end
  		else
				self:DebugMsg("Game does not have focus.")
  			self.waitingForFocus = true
  		end
  	end
  end

	--[[------------------------------------------------------------------------------------------------
	local function OnChatMessageChannel(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	Inputs:				eventCode				- Internal ZOS event code, not used here.
								channelType			- Party/Zone/Say/etc.
								fromName				- Character name of person that sent the message.
								text						- Text content of the message sent.
								isCustomerService	- True if the message was sent by a member of customer service.
								fromDisplayName	- The @account name of the person that sent the message.
	Outputs:			None
	Description:	Fired when a chat message is recieved by the game client. Will initiate traveling to 
								the next zone in the list if the chat message text matches the selected guild 
								recruitment message (autoFillGuildSelection), is from the user, autoNext is true and
								autoStarted is true. If the current zone doesn't match the intended destination then 
								exit automode.
	------------------------------------------------------------------------------------------------]]--
  local function OnChatMessageChannel(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
  	local id = self.SavedVars.autoFillGuildSelection
  	if self.autoStarted and fromDisplayName == GetDisplayName() and text == self.SavedVars.Guilds[id].recruitMsg and self.SavedVars.autoNext then
			self:DebugMsg("OnChatMessageChannel event fired with matching display name, text and autoNext enabled.")
  		if self.ZM:DoesPlayerLocationMatch(self.destination) then
  			zo_callLater(function() self:Travel() end, 100) -- 100ms delay is used to ensure the chat message appears in the chat box before traveling to the next zone.
  		else
  			self:SendToChat("Current zone doesn't match selection. Auto recruit stopping.")
  			self:ResetAutoTravelProgress()
  		end
  	end
  end
  
	--[[------------------------------------------------------------------------------------------------
	local function OnGameFocusChanged(eventCode, hasFocus)
	Inputs:				eventCode				- Internal ZOS event code, not used here.
								hasFocus				- True if the game currently has window focus.
	Outputs:			None
	Description:	Fired when the window focus of the game changes. This is used in the case of the user
								tabbing out of the game while loading between zones. Once the game has focus and 
								automations have started then the selected recruitment message is loaded into the chat
								input box.
	------------------------------------------------------------------------------------------------]]--
  local function OnGameFocusChanged(eventCode, hasFocus)
		self:DebugMsg("OnGameFocusChanged event fired.")
		local id
  	if self.SavedVars.autoFillGuildSelection  then
			id = self.SavedVars.autoFillGuildSelection
		elseif self.waitingForFocus and self.autoStarted then
			self:SendToChat("No Guild selected to recruit for. Please select a guild in the add-on settings.")
			return
		end
  	if self.waitingForFocus and hasFocus then
  		if self.ZM:DoesPlayerLocationMatch(self.destination) then
				self:DebugMsg("Player location matched destination.")
				self:AutoTravelProgress()
  			zo_callLater(function() StartChatInput(self.SavedVars.Guilds[id].recruitMsg, CHAT_CHANNEL_ZONE) self.waitingForFocus = false end, 100)
			elseif self.SavedVars.autoRetry then
				self:DebugMsg("Player location doesn't match destination. Trying again.")
				self:SendToChat("Zone mismatch, trying again...")
				self.zoneIndex = self.zoneIndex - 1
				self:Travel()
			else
  			self:SendToChat("Current zone doesn't match selection. Auto recruit stopping.")
  			self:ResetAutoTravelProgress()
  		end
  	end
  end
  
	--[[------------------------------------------------------------------------------------------------
	local function OnGuildJoined(eventCode, guildServerId, characterName, guildIndex)
	Inputs:				eventCode				- Internal ZOS event code, not used here.
								guildServerId		- The server unique guild ID of the guild that was joined.
								characterName		- The character name of the user that joined the guild (Player)
								guildIndex			- The client index the joined guild was assigned.
	Outputs:			None
	Description:	Fired when the player joins a guild. Updates the internal guild information and 
								related settings controls in the menu.
	** Ditto for the OnGuildLeft function **
	------------------------------------------------------------------------------------------------]]--
	local function OnGuildJoined(eventCode, guildServerId, characterName, guildIndex)
		self:DebugMsg("OnGuildJoined event fired.")
    self.GM:Update()
    self.SM:Update()
  end

  local function OnGuildLeft(eventCode, guildServerId, characterName, guildIndex)
		self:DebugMsg("OnGuildLeft event fired.")
    self.GM:Update()
    self.SM:Update()
	end

	-- Event Registrations
	EM:RegisterForEvent(self.addonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EM:RegisterForEvent(self.addonName, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessageChannel)
	EM:RegisterForEvent(self.addonName, EVENT_GAME_FOCUS_CHANGED, OnGameFocusChanged)
	EM:RegisterForEvent(self.addonName, EVENT_GUILD_SELF_JOINED_GUILD, OnGuildJoined)
	EM:RegisterForEvent(self.addonName, EVENT_GUILD_SELF_LEFT_GUILD, OnGuildLeft)

	-- Slash commands declarations
	SLASH_COMMANDS["/srnext"] = function(...) self:Travel() end
	SLASH_COMMANDS["/srmsg"] = function(...) self:CommandParse(...) end
	SLASH_COMMANDS["/srreset"] = function(...) self:ResetAutoTravelProgress() end
	SLASH_COMMANDS["/srdebug"] = function(...) self:DebugMsg() end

	-- Keybindings associations
	ZO_CreateStringId("SI_BINDING_NAME_SR_TRAVEL", "Travel to Next Zone")
	ZO_CreateStringId("SI_BINDING_NAME_SR_MESSAGE_1", "Load Guild 1 Message")
	ZO_CreateStringId("SI_BINDING_NAME_SR_MESSAGE_2", "Load Guild 2 Message")
	ZO_CreateStringId("SI_BINDING_NAME_SR_MESSAGE_3", "Load Guild 3 Message")
	ZO_CreateStringId("SI_BINDING_NAME_SR_MESSAGE_4", "Load Guild 4 Message")
	ZO_CreateStringId("SI_BINDING_NAME_SR_MESSAGE_5", "Load Guild 5 Message")
	
	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
function SR:SendToChat(inputString, ...)
Inputs:				inputString			- The input string to be formatted and sent to chat. Can be bools.
							...							- More inputs to be placed on new lines within the same message.
Outputs:			None
Description:	Formats text to be sent to the chat box for the user. Bools will be converted to 
							"true" or "false" text formats. All inputs after the first will be placed on a new 
							line within the message. Only the first line gets the add-on prefix.
------------------------------------------------------------------------------------------------]]--
function SR:SendToChat(inputString, ...)
	if not self.SavedVars.chatMsgEnabled then return end
	if inputString == false then return end
	local Args = {...}
	local Output = {}
	table.insert(Output, self.chatPrefix)
	table.insert(Output, self.chatTextColor)
	table.insert(Output, inputString) 
	table.insert(Output, self.chatSuffix)
	if #Args > 0 then
		for i,v in ipairs(Args) do
			if type(v) == boolean then
				if v then v = "true" else v = "false" end
			end
		  table.insert(Output, "\n")
			table.insert(Output, self.chatTextColor)
	    table.insert(Output, v) 
	    table.insert(Output, self.chatSuffix)
		end
	end
	CS:AddMessage(table.concat(Output))
end


--[[------------------------------------------------------------------------------------------------
function SR:DebugMsg(inputString)
Inputs:				inputString			- The debug string to print to chat
							...							- More inputs to be placed on new lines within the same message.
Outputs:			None
Description:	Checks if debugging mode is on and if so, sends the input message to chat.
------------------------------------------------------------------------------------------------]]--
function SR:DebugMsg(inputString)
	if not self.SavedVars.debugMode then return end
	if inputString == false then return end
	self:SendToChat("[DEBUG] " .. inputString)
end


--[[------------------------------------------------------------------------------------------------
function SR:AbleToFastTravel()
Inputs:				None
Outputs:			canTravel				- True if the player can fast travel right now.
Description:	Checks if the player is in a PvP (AvA) zone or in combat and returns true if the 
							player is able to fast travel at this moment.
------------------------------------------------------------------------------------------------]]--
function SR:AbleToFastTravel()
	local canTravel = false
	if not (IsInAvAZone() or IsUnitInCombat("player")) then
		canTravel = true
	end
	return canTravel
end


--[[------------------------------------------------------------------------------------------------
function SR:AutoTravelProgress()
Inputs:				None
Outputs:			None
Description:	Sends info to chat about the auto travel progress in the form of:
							"Auto travel progress: Completed/Total (%done)"
							Everytime the function is called it will update the numbers automatically.
------------------------------------------------------------------------------------------------]]--
function SR:AutoTravelProgress()
	self.completed = self.completed + 1
	if self.total == 0 then
		for index, value in pairs(self.Zones) do
			if value then self.total = self.total + 1 end
		end
	end
	local c = self.completed
	local t = self.total
	local d = math.floor((c/t) * 100)
	self:SendToChat(zo_strformat("Auto travel progress: <<1>>/<<2>> (<<3>>%)", c, t, d))
end


--[[------------------------------------------------------------------------------------------------
function SR:ResetAutoTravelProgress()
Inputs:				None
Outputs:			None
Description:	Resets the internal parameters for automatic traveling to recruitment zones.
------------------------------------------------------------------------------------------------]]--
function SR:ResetAutoTravelProgress()
	self.autoStarted = false
	self.waitingForFocus = false
	self.zoneIndex = 1
	self.completed = 0
	self.total = 0
	self:SendToChat("Auto travel progress has been reset to the beginning.")
end


--[[------------------------------------------------------------------------------------------------
function SR:Travel()
Inputs:				None
Outputs:			None
Description:	Checks for houses, friends, guild mates and wayshrines using other methods available 
							to travel to the desired zone for recruiting.
------------------------------------------------------------------------------------------------]]--
function SR:Travel()
	self:DebugMsg("Travel function start.")
	local target
	self.ZM:Update()
	self.HM:Update()
	if self.SavedVars.autoNext then
		if not self.autoStarted then self:SendToChat("Auto recruiting started. Don't forget to press Enter to send the recruit messages! (Please don't use custom recall animations during auto recruiting.)") end
		self.autoStarted = true
	end
	if self.SavedVars.autoFill then self.autoStarted = true end
	self:DebugMsg("Finding next zone to travel to.")
	for i=self.zoneIndex, #self.ZM.Data do
		local v = self.ZM.Data[i]
		if self.Zones[v.zoneID] then 
			self.destination = self.ZM.Data[i].zoneID
			-- Check for house in target zone.
			target = self.HM:GetHouseIDFromZoneID(self.destination)
			if target and CanJumpToHouseFromCurrentLocation() and self:AbleToFastTravel() then
				self:SendToChat("Fast traveling to " .. self.HM:GetHouseName(target) .. " in " .. self.ZM:GetZoneName(self.destination) .. ".")
				RequestJumpToHouse(target, true)
				self.zoneIndex = i + 1
				return
			else
				-- Check for friend in target zone.
				target = self.FM:GetFriendInZone(self.destination)
				if target and CanJumpToPlayerInZone(self.destination) and self:AbleToFastTravel() then
					self:SendToChat("Fast traveling to " .. target .. " in " .. self.ZM:GetZoneName(self.destination) .. ".")
					JumpToFriend(target)
					self.zoneIndex = i + 1
					return
				else
					-- Check for guild member in target zone.
					target = self.GM:GetGuildMemberInZone(self.destination)
					if target and CanJumpToPlayerInZone(self.destination) and self:AbleToFastTravel() then
						self:SendToChat("Fast traveling to " .. target .. " in " .. self.ZM:GetZoneName(self.destination) .. ".")
						JumpToGuildMember(target)
						self.zoneIndex = i + 1
						return
					else
						-- Check for wayshrine in target zone.
						target = self.ZM:GetWayshrineInZone(self.destination)
						if target and self.SavedVars.payWayshrineFee and self:AbleToFastTravel() then
							self:SendToChat("Fast traveling to " .. self.ZM:GetZoneName(self.destination) .. ". (Wayshrine: " .. zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_MONEY, GetRecallCost(), ZO_CURRENCY_FORMAT_AMOUNT_ICON)) .. self.chatTextColor .. ")")
							FastTravelToNode(self.ZM:GetWayshrineInZone(self.destination))
							self.zoneIndex = i + 1
							return
						elseif not self.SavedVars.payWayshrineFee then
							self:SendToChat("Fast traveling to wayshrines is disabled. Turn on \"Pay Wayshrine Fee\" in settings. Unable to travel to " .. self.ZM:GetZoneName(self.destination) .. ", skipping.")
							self.zoneIndex = i + 1
							return
						else
							-- No targets found.
							self:SendToChat("No suitable travel location found. Please ensure you have unlocked at least one wayshrine in " .. self.ZM:GetZoneName(self.destination) .. ", skipping.")
							self.zoneIndex = i + 1
							return
						end
					end
				end
			end
		end
	end
	-- reset data
	self.autoStarted = false
	self.waitingForFocus = false
	self.zoneIndex = 1
	self.completed = 0
	self.total = 0
	self:SendToChat("End of travel list reached. Press the hotkey or run the /srnext command again to start over.")
end


--[[------------------------------------------------------------------------------------------------
function SR:LoadMessage(index)
Inputs:			  index           - Index of guild recruitment message to load.
Outputs:			None
Description:	Loads the indexed recruitment message into the chat input box. The user still has to
							press enter.
------------------------------------------------------------------------------------------------]]--
function SR:LoadMessage(index)
	local id = GetGuildId(index)
	StartChatInput(self.SavedVars.Guilds[id].recruitMsg, CHAT_CHANNEL_ZONE)
	self:DebugMsg("Recruitment message loaded into chat box.")
end


--[[------------------------------------------------------------------------------------------------
function SR:CommandParse(args)
Inputs:			  args            - arguments from the slash command input.
Outputs:			None
Description:	Parses the command arguments into a table to execute certain functions.
------------------------------------------------------------------------------------------------]]--
function SR:CommandParse(args)
	local Options = {}
	local searchResult = {string.match(args, "^(%S*)%s*(.-)$")}
	for i,v in pairs(searchResult) do
		if (v ~= nil and v~= "") then
			Options[i] = string.lower(v)
		end
	end
	if #Options == 0 then
		self:SendToChat("No message number entered.")
	else
		self:LoadMessage(tonumber(Options[1]))
	end
end	


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, StaticsRecruiter, of the SR class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("StaticsRecruiter", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "StaticsRecruiter" then return end
	EM:UnregisterForEvent("StaticsRecruiter", EVENT_ADD_ON_LOADED)
	StaticsRecruiter = SR:New()
end)