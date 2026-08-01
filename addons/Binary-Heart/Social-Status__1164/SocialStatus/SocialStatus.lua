-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- SocialStatus v1.20.3 (API version 100026)
--		by Alyka & BinaryHeart 
--
--	Allows you to log into Elder Scrolls Online with a defined Social Status:
--
--		Online;
--		Away From Keyboard;
--		Do Not Disturb;
--		Offline.
--
-- ----------------------------------------------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Settings
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local	AccountDefaults 		=									-- default account wide settings
		{
			SocialStatus		= 4,								-- Social Status = offline
			version				= 1.20,
			AttemptRosterFix	= false
		}
local	CharacterDefaults 		=									-- default character settings
		{
			SocialStatus		= 5,								-- Social Status = AccountSettings' value
			version				= 1.20
		}
local	AccountSettings												-- AccountWide settings
local	CharacterSettings											-- character specific settings
local	SocialStatus												-- current SocialStatus
local	PreAFKStatus			= 1									-- Social Status prior to an AFK toggle. When AFK is toggled off, SocialStatus is reset to this


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- DisplayStatus()
--		Displays current SocialStatus in chat window
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function DisplayStatus()
	if SocialStatus == PLAYER_STATUS_ONLINE then
		d("You're flagged as online")
	elseif SocialStatus == PLAYER_STATUS_AWAY then	
		d("You're flagged as afk")
	elseif SocialStatus == PLAYER_STATUS_DO_NOT_DISTURB then
		d("You're flagged as do not disturb")
	elseif SocialStatus == PLAYER_STATUS_OFFLINE then
		d("You're flagged as offline")
	else
		d("Social Status unknown. Why don't you admire Soras' gorgeous eyes while we try to resolve this?") -- Soras is really quite sexy
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- StatusChanged(event, unsigned, unsigned)
--		Hooks into EVENT_PLAYER_STATUS_CHANGED event
--		When 
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function StatusChanged(event, old, new)
	SocialStatus = new
	
	if SocialStatus ~= PLAYER_STATUS_AWAY then		
		PreAFKStatus = PLAYER_STATUS_AWAY
	end

	DisplayStatus()	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- SetStatus(unsigned)
--		Selects player status if passed status is new
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function SetStatus(flag)
	if SocialStatus ~= flag then
		SelectPlayerStatus(flag)
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- ToggleAFK()
--		Toggles afk on/off
--		When toggling off, the SocialStatus set before afk was toggled on is reset
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function ToggleAFK()
	if SocialStatus == PLAYER_STATUS_AWAY then
		SelectPlayerStatus(PreAFKStatus)
	else
		SelectPlayerStatus(PLAYER_STATUS_AWAY);
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Slash commands - these can be used to set and display SocialStatus
-- ----------------------------------------------------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/online"]		= function() SetStatus(PLAYER_STATUS_ONLINE) end			-- set SocialStatus to online
SLASH_COMMANDS["/on"]			= function() SetStatus(PLAYER_STATUS_ONLINE) end			-- set SocialStatus to online
SLASH_COMMANDS["/afk"]			= ToggleAFK													-- toggle afk/previous SocialStatus
SLASH_COMMANDS["/dnd"]			= function() SetStatus(PLAYER_STATUS_DO_NOT_DISTURB) end	-- set SocialStatus to dnd
SLASH_COMMANDS["/offline"]		= function() SetStatus(PLAYER_STATUS_OFFLINE) end			-- set SocialStatus to offline
SLASH_COMMANDS["/off"]			= function() SetStatus(PLAYER_STATUS_OFFLINE) end			-- set SocialStatus to offline
SLASH_COMMANDS["/socialstatus"]	= DisplayStatus												-- displays current SocialStatus in chat window
SLASH_COMMANDS["/ss"]			= DisplayStatus												-- displays current SocialStatus in chat window


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- PersonalSubjectThird(bool, string)
--		returns the third-person personal subjective pronoun for the passed character as a string
--
--		params
--			bool	- whether we wish to capitalise the returned string
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function PersonalSubjectThird(capitalised)	
	local Gender = GetGenderFromNameDescriptor(GetRawUnitName("player"))

	if Gender == GENDER_FEMALE then
		if capitalised then
			return "She"
		else
			return "she"
		end
	elseif Gender == GENDER_MALE then
		if capitalised then
			return "He"
		else
			return "he"
		end
	elseif capitalised then
		return "It"
	else
		return "it"
	end	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- PersonalObjectThird(bool, string)
--		returns the third-person personal objective pronoun for the passed character as a string
--
--		params
--			bool	- whether we wish to capitalise the returned string
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function PersonalObjectThird(capitalised)
	local Gender = GetGenderFromNameDescriptor(GetRawUnitName("player"))
	
	if Gender == GENDER_FEMALE then
		if capitalised then
			return "Her"
		else
			return "her"
		end
	elseif Gender == GENDER_MALE then
		if capitalised then
			return "His"
		else
			return "his"
		end
	elseif capitalised then
		return "Its"
	else
		return "its"
	end	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- CreateSettingsWindow()
--		LAM2 settings panel
--		This is displayed ingame under
--			Main Menu (esc)
--			-	Settings
--				-	Addon settings
--					- Social Status
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsPanel()
	local LAM2 				= LibStub("LibAddonMenu-2.0")					-- Get LAM library
	local CharacterName		= GetUnitName("player")							-- the player character's name - displayed in several places
	local PronounSubjective	= PersonalSubjectThird(false)					-- these are both used in Instructions description
	local PronounObjective	= PersonalObjectThird(false)
	
	local LogonTypeAccount	=												-- options for AccountWide Social Status dropdown menu
	{
		"Online",
		"Away From Keyboard",
		"Do Not Disturb",
		"Offline"		
	}
	
	local LogonTypeCharacter	=											-- options for Character Social Status dropdown menu
	{
		"Online",
		"Away From Keyboard",
		"Do Not Disturb",
		"Offline",
		"Account"
	}
	
	local LogonTypeMap	=													-- each possible Social Status mapped to a value
	{
		["Online"]				= PLAYER_STATUS_ONLINE,
		["Away From Keyboard"]	= PLAYER_STATUS_AWAY,
		["Do Not Disturb"]		= PLAYER_STATUS_DO_NOT_DISTURB,
		["Offline"]				= PLAYER_STATUS_OFFLINE,
		["Account"]				= 5
	}
	
--	Define LAMPanel
	local LAMPanel	=
	{
		type 				= "panel",
		name				= "Social Status",
		displayName 		= ZO_HIGHLIGHT_TEXT:Colorize("Social Status"),
		author 				= "Alyka & BinaryHeart",
		version				= AccountSettings.version,
		slashCommand		= "/sso",
		registerForRefresh	= true,
		registerForDefaults	= true
	}
	
	--	Register LAMPanel	
	LAM2:RegisterAddonPanel("LAMSocialStatusSettings", LAMPanel)
		
--	Define LAMSettings
	local LAMSettings =
	{
		{
			type		= "header",
			name		= ZO_HIGHLIGHT_TEXT:Colorize("Account Social Status on login")
		},
		{
			type 		= "dropdown",
			tooltip 	= "All characters will logon with this Social Status unless overridden below",
			choices 	=  LogonTypeAccount,
			getFunc 	= function() return LogonTypeAccount[AccountSettings.SocialStatus] end,
			setFunc 	= function(val) AccountSettings.SocialStatus = LogonTypeMap[val] end,
			default		= LogonTypeAccount[AccountDefaults.SocialStatus]
		},
		{
			type		= "header",
			name		= ZO_HIGHLIGHT_TEXT:Colorize(CharacterName.."'s Social Status on login")
		},
		{
			type 		= "dropdown",
			tooltip 	= "Social Status to logon "..CharacterName.." with",
			choices 	= LogonTypeCharacter,
			getFunc 	= function() return LogonTypeCharacter[CharacterSettings.SocialStatus] end,
			setFunc 	= function(val) CharacterSettings.SocialStatus = LogonTypeMap[val] end,
			default		= LogonTypeCharacter[CharacterDefaults.SocialStatus]
		},
		{
			type = "checkbox",
			name = "Fix inactivity bug",
			getFunc = function() return AccountSettings.FixRoster end,
			setFunc = function(value) AccountSettings.FixRoster = value end,
			default = AccountSettings.FixRoster,
			reference = "FixInactivityBug"
		},
		{
			type		= "submenu",		
			name		= ZO_HIGHLIGHT_TEXT:Colorize("Instructions"),
			tooltip		= "View Instructions",			
			controls 	=
			{
				{
					type	= "description",
					text	= "When "..CharacterName.."'s Social Status is set to [Account], "..PronounSubjective.." will be logged on with your Account Social Status. Choosing a value other than [Account] for "..CharacterName.." will log "..PronounObjective.." on with this Social Status instead.\n\nIf you change the Account Social Status setting while on any character, this change will take effect on all characters who use it:\n\n\t\tAccount Social Status is set to [Online];\n\t\t"..CharacterName.."'s Social Status is set to [Account];\n\t\tWe log onto Cheeky Corrick and change Account Social Status to [Offline];\n\t\tThe next time we log onto "..CharacterName..", "..PronounSubjective.." will be [Offline].\n\nThe first time a character is loaded, their Social Status setting defaults to [Account]. Thus, if your Account Social Status is set to [Offline], you can even create new characters 'offline'.\n\nN.B. Sexy Soras is always online, even when he's not. Once you've gazed into those eyes, they never leave you.\n\nSometimes when you are kicked from the server for inactivity, when you log back on in offline mode you will appear at the top of guild rosters and friend lists without any associated character. If this annoys you, you can check the \"Fix inactivity bug\". When this is checked, SocialStatus will sort to fix your guild roster and friend list entries, but BE WARNED - sometimes this may make you appear briefly online. This is an account-wide option.",
					width	= "full"
				}
			}			
		}
	}

--	Register LAMSettings
	LAM2:RegisterOptionControls("LAMSocialStatusSettings", LAMSettings)	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- PostInit()
--		Displays player's SocialStatus
--		Registers a callback for when player's status changes after 2.5 seconds
--		|---this is to stop situation whereby hook fires before EVENT_PLAYER_STATUS_CHANGED fires for original SelectPlayerStatus call
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function PostInit()
	DisplayStatus()
	zo_callLater(function() EVENT_MANAGER:RegisterForEvent("SocialStatus", EVENT_PLAYER_STATUS_CHANGED, StatusChanged) end, 2500)
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- AttemptInactivityFix()
--		Attempts to puts player online and them immediately offline. This doesn't always work - sometimes the order of calls is reversed, other
--		only one or the other fire
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function AttemptInactivityFix()
	SelectPlayerStatus(PLAYER_STATUS_ONLINE) -- go online
	SelectPlayerStatus(PLAYER_STATUS_OFFLINE) -- go offline
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- ValidateInactivityFixed(integer)
--		Validates whether the attempt at fixing the inactivity bug was successful. If it wasn't, further attempts will be made at 1.5 second
--		intervals until it is
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function ValidateInactivityFixed(lastOnline)

	local GuildMemberIndex = GetGuildMemberIndexFromDisplayName(1, GetDisplayName()) 

	if GuildMemberIndex ~= nil then -- if we're in a guild	
		name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(1, GuildMemberIndex)
	
		test = GetGuildMemberCharacterInfo(1, GuildMemberIndex)
	
		local State  = GetPlayerStatus()
	
		if State ~= PLAYER_STATUS_OFFLINE or playerStatus ~= PLAYER_STATUS_OFFLINE then
			if State == playerStatus then
				SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
			else
				AttemptInactivityFix()			
				zo_callLater(function() ValidateInactivityFixed(lastOnline) end, 1500)		
			end
		else
			PostInit()
		end
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- PlayerActivated(event, boolean)
--		Called when player is activated
--		Unregisters for event, we need only call this once
--		Sets player status (if applicable)
--		Attempts to fix inactivity bug if it is detected and option turned on
--		Otherwise calls PostInit function
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function SelectSocialStatus(event, bool)
	EVENT_MANAGER:UnregisterForEvent("SocialStatus", EVENT_PLAYER_ACTIVATED)
		
	if GetPlayerStatus() ~= SocialStatus then
		SelectPlayerStatus(SocialStatus)
	end	

	if GetGuildMemberCharacterInfo(1, GetGuildMemberIndexFromDisplayName(1, GetDisplayName())) == false then
		d("You're displaying offline without any character at the top of guild rosters and friend lists. This is due to the server disconnecting you for inactivity.")
		if AccountSettings.AttemptRosterFix == true then
			d("You have chosen to fix this in SocialStatus settings")
			
			name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(1, GetGuildMemberIndexFromDisplayName(1, GetDisplayName()))
			
			zo_callLater(AttemptInactivityFix, 1000)
			zo_callLater(function() ValidateInactivityFixed(secsSinceLogoff) end, 2500)
		end
	else
		PostInit()
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Initialise(event, name)
--		Called when addon loads
--		Unregisters for event, we need only call this once
--		If player isn't offline, immediately makes them so (this should now block player from ever appearing online if desired - thanks Zeni =*)
--		Loads Account and Character Settings
--		Creates LAM2 settings panel
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function Initialise(event, name)
	EVENT_MANAGER:UnregisterForEvent("SocialStatus", EVENT_ADD_ON_LOADED)

	if GetPlayerStatus() ~= PLAYER_STATUS_OFFLINE then
		SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
	end
	
	AccountSettings		=	ZO_SavedVars:NewAccountWide("SocialStatusSavedVariables", 1.20, nil, AccountDefaults)	
	CharacterSettings	=	ZO_SavedVars:New("SocialStatusSavedVariables", 1.20, nil, CharacterDefaults)	
	
	if CharacterSettings.SocialStatus == 5 then											-- if Character Settings flags Global Social Status
		SocialStatus = AccountSettings.SocialStatus										-- set Social Status to Account Setting's value
	else
		SocialStatus = CharacterSettings.SocialStatus									-- otherwise set Social Status to Character Setting's value
	end
	
	CreateSettingsPanel()
	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Event registering
--		Initialise when addon is loaded
--		SelectSocialStatus when player is activated
-- ----------------------------------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("SocialStatus", EVENT_ADD_ON_LOADED, Initialise)
EVENT_MANAGER:RegisterForEvent("SocialStatus", EVENT_PLAYER_ACTIVATED, SelectSocialStatus)
