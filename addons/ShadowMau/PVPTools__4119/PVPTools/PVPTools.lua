-- ***** Pawprints' PVP Tools *****



--[[
Recent Changes:
	1.18
	[list]
		[*] Autoinvite strings are no longer case sensitive
		[*] Autoinvite now has the ability to listen to three independent strings with each string having the capacity to be limited as to which channels it is listening for the string.
		[*] Autoinvite will no longer accidentally send invites in certain situations.
		[*] Added in a warning if you try to use a Keep Recall Stone or Sigil of Imperial Retreat and you have none remaning.
		[*] Improvements to the settings and built in manual.
		[*] NOTE: Manual for the AutoInvite will be added in a future update once I am sure all elements are working properly.
		[*] Added in some more matches for the QuestShare module
	[/list]
	
--]]
--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
local PT = PVPTools


--------------------------------------------------------
-- Initialize global data and settings
-------------------------------------------------------

-- General
-- PT.debug = false  DEBUG STATE is now saved in the saved variables.  To turn it on/off manually in-game type /script PT.debug = true/false
PT.debugLog = {}
PT.siegeFeeQueue = {}
PT.guilds = {}	-- Autoinvite will be continually checking chat messages against the various guild channels.  Instead of repeatedly calling for a list of guilds, make a list of guilds and hold it.  Have a format of {[1] is the guild id and [2] is the guild name}  The function that populates the guild list should also set up a listener for if the person is added or removed from a guild and repopulate the list accordingly.
PT.menuControls = {}

PT.name 			= "PVPTools"
PT.displayName 		= "|c00E600PVP Tools|r"
PT.version 			= "1.18 (20260730)"
PT.author 			= "|c787878ShadowMau / Pawprints.Shadow|r"
PT.website			= "https://www.esoui.com/downloads/info2915-PT.html"
PT.donation			= "https://www.paypal.com/donate/?hosted_button_id=3MACYMHKL9Q4J"
PT.requiredLAMVersion = 41

-- Sounds
PT.soundDefault 		= SOUNDS.ACTIVE_SKILL_MORPH_CHOSEN
PT.soundError			= SOUNDS.GENERAL_ALERT_ERROR
PT.soundQuestShare 		= SOUNDS.BATTLEGROUND_CAPTURE_AREA_SPAWNED
PT.soundMount			= SOUNDS.ARMORY_OPEN
PT.soundJohnny			= SOUNDS.DAEDRIC_ARTIFACT_SPAWNED
PT.soundWarning			= SOUNDS.ABILITY_SYNERGY_READY
PT.soundEmergencyQueue 	= SOUNDS.QUEST_STEP_FAILED

-- Keybinds
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_SHARE_QUEST_HERE", "|c00ffffQuick Share Quest|r")
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_QUEST_TIMERS", "|c00ffffDisplay Daily PVP Quest Timers|r")
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_USE_MULTIMOUNTS", "|c62d27fUse Only Multimounts|r")
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_RIDE_MULTIMOUNT", "|c62d27fRide Friend\'s Multimount|r")
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_USE_RECALL", "|c62d27fUse Recall Stone|r")
ZO_CreateStringId("SI_BINDING_NAME_PVPTOOLS_JOKE_SIEGE_RENTAL", "|c62d27fSend Siege Rental Fee|r")

-- Controls and Such for Auto Invite
PT.dataGroupMenuKeyboardPVPToolsData = ""
PT.controlGroupMenuKeyboardPVPToolsIcon = 0
PT.groupMenuKeyboardFragment = {}
PT.autoInviteListening = false




--------------------------------------------------
-- Default saved variable settings
--------------------------------------------------
PT.accountDefaults = {
	
	-- General
	settingsPTDebug = false,
	settingsDailyReset = 0,
		
	-- QuestShare
	settingsQSModuleOn 			= false,
	settingsQSAutoShare		 	= false,
	settingsQSAutoAccept 		= false,
	settingsQSTrackDaily 		= false,
	settingsQSCenterAnnounce 	= false,
	settingsQSAlert 			= false,
	
	-- AutoInvite
	settingsAIModuleOn	= false,
	settingsAIAutoKick	= false,
	settingsAIKickDelay	= 300,
	settingsAIWatchStrings	= {
		[1] = {
			["text"] 		= "lfg",
			["channels"] 	= {CHAT_CHANNEL_SAY, CHAT_CHANNEL_ZONE},
			["enabled"]		= false,
		},
		[2] = {
			["text"]	 	= "x",
			["channels"] 	= {CHAT_CHANNEL_SAY, CHAT_CHANNEL_ZONE},
			["enabled"]		= false,
		},
		[3] = {
			["text"]		= "guild",
			["channels"]	= {CHAT_CHANNEL_GUILD_1},
			["enabled"]		= false,
		},
	},
	settingsAIIgnoreList = {},


	-- Quality of Life
	settingsQOLMultimountOn 			= false,
	settingsQOLEmergencyExit			= false,
	--settingsQOLPreferredCyrodiil		= 103,	-- depreciated
	--settingsQOLPreferredImperialCity	= 96,	-- depreciated
	settingsQOLQueueGroup				= false,
	settingsQOLAutoAcceptQueue			= false,
	settingsQOLCenterAnnounce 			= false,
	settingsQOLAlert					= false,
	settingsQOLDailySiegeTable			= {},

	-- Merchant and Banking
	settingsMBUseAutoBanking		= false,
	settingsMBUseFragmentMerchant	= false,
	settingsMBUseAutoMerchant		= false,
	settingsMBReserveBagSpace		= 5,

	settingsMBAutoBanking = {
		-- ["currencyType"] = 	{[1]active,	[2]minAmount,	[3]maxAmount},
		["Gold"]			=	{false, 	50000, 			100000},
		["Telvar"]			=	{false, 	100, 			100},
		["Alliance Points"]	= 	{false, 	50000, 			500000},
	},
	
	
	settingsMBAutoMerchant = {
		-- itemName = {[1]quantity, [2]useGold, [3]stackSize}
		-- stackSize is depreciated and can be removed in the future if there is a major version bump
		["Cyrodiil Repair Kit"]				=	{0, false, 200},
		["Alliance Battle Draught"]			=	{0, false, 200},
		["Alliance Health Draught"]			=	{0, false, 200},
		["Alliance Spell Draught"]			=	{0, false, 200},
		["Bound Tri-Restoration Potion"]	=	{0, false, 200},
		["Cyrodilic Field Bar"]				=	{0, false, 200},
		["Cyrodilic Field Brew"]			=	{0, false, 200},
		["Cyrodilic Field Tack"]			=	{0, false, 200},
		["Cyrodilic Field Tea"]				=	{0, false, 200},
		["Cyrodilic Field Tonic"]			=	{0, false, 200},
		["Cyrodilic Field Treat"]			=	{0, false, 200},
		["Flaming Oil"]						=	{0, false, 20},
		["Keep Recall Stone"]				=	{0, false, 100},
		["Soul Gem"]						=	{0, false, 200},
		["Soul Gem (Empty)"]				=	{0, true, 200},
		["Ballista"]						=	{0, false, 20},
		["Battering Ram"]					=	{0, false, 20},
		["Firebolt Ballista"]				=	{0, false, 20},
		["Firepot Trebuchet"]				=	{0, false, 20},
		["Forward Camp"]					=	{0, false, 100},
		["Iceball Trebuchet"]				=	{0, false, 20},
		["Lightning Ballista"]				=	{0, false, 20},
		["Meatbag Catapult"]				=	{0, false, 20},
		["Oil Catapult"]					=	{0, false, 20},
		["Scattershot Catapult"]			=	{0, false, 20},
		["Stone Trebuchet"]					=	{0, false, 20},
	}
}

PT.characterDefaults = {
	
	-- QuestShare daily PVP quest tracking
	savedResetTime = 0,
	
	completedConquestQuests = {
		["resources"] 		= false,
		["keeps"]			= false,
		["towns"]			= false,
		["150"]				= false,
	},
	
	completedBountyQuests = {
		["players"] 		= false,
		["templars"]		= false,
		["nightblades"]		= false,
		["sorcerers"]		= false,
		["dragonknights"]	= false,
		["wardens"]			= false,
		["necromancers"]	= false,
		["arcanists"]		= false,
	},

	completedImperialCityQuests = {
		["elven"] 		= false,
		["arboretum"] 	= false,
		["temple"] 		= false,
		["memorial"] 	= false,
		["arena"] 		= false,
		["nobles"] 		= false,
	},
	
	-- Quality of Life (random mount)
	randomMountType = RANDOM_MOUNT_TYPE_NONE,
	savedMount = 2,
	-- the collectible id of the base-game mount everyone gets at level 10 is 2
	
}


--------------------------------------------------
-- OnAddOnLoaded - check to see if this addon is the one loaded
--------------------------------------------------
function PT.OnAddOnLoaded(event, addonName) -- Verified
	
	if addonName == PT.name then
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ADD_ON_LOADED)
		if PT.debug then PT.DebugEntry("PAWPRINT'S PVP TOOLS LOADED") end
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_PLAYER_ACTIVATED, PT.OnPlayerActivated)

		--------------------------------------------------
		-- Use ASV for account wide saved variables
		-- Use CSV for character specific saved variables
		--------------------------------------------------
		PT.ASV = ZO_SavedVars:NewAccountWide("PVPToolsSavedVariables", 2, nil, PT.accountDefaults, GetWorldName())
		PT.CSV = ZO_SavedVars:NewCharacterIdSettings("PVPToolsSavedVariables", 2, nil, PT.characterDefaults, GetWorldName())
		--[[ Other Module Ideas
			-- Addon Notification Window (libfontfunctions)  maybe multiple tabs??
				-- Important Wispers / zone posts (">>>") (list of people who will have their message displayed on the notification window)
				-- Debug entries
				-- AP / Telvar increase / decrease
				-- Telvar Warning
				-- Potion and food low warnings
				-- Respawn timer
			-- Autoinvite
			-- COOP communication encrypter
			-- Door / Postern locations
			-- Vamp Snacks
			-- Well Locations
			-- Hammer Locator - eyecatching where is the hammer
			-- Quick Port
			-- Telvar / AP deposit
			-- Merchant autobuy
			-- CyroMap
			-- Hoveing Icons above keeps / resources / etc like Miats
			-- Leader Beam
			-- Dead people Beam
			-- Leader Arrow
			-- Camp Locations
			-- Siege Locations
			-- Bridge / Tunnel Locations
			-- Primary paths on the map??
			-- Siege low warning
			-- Compass around retical
			-- AP Meter
			-- Simplified Kill Counter
			-- Grubmaster
			-- PVPRanks
			-- something that when targeting a dead person lock out the report / friend options on the wheel
			-- EMP Celebrate (everyone have emp costume)
			-- Other Addons
				-- LibKeepTooltip
				-- Alliance Rank Progress
				-- Auto Recharge
				-- Auto Repair
				-- Forward Camp Preview
				-- Lights of Meridia
				-- TelVar Counter Telvar Logger
		--]]

		-- FavoriteMount always overrides if loaded
		if FavoriteMount then
			PT.ASV.settingsQOLMultimountOn = false
		end
		
		-- because settings are account wide, but mount info is character based check if we need to save this specific character's mount info
		if PT.ASV.settingsQOLMultimountOn then
			PVPTools.QOL.SaveCharacterMountInfo()
		else
			PVPTools.QOL.ResetCharacterMountInfo()
		end
		
		if IsPlayerInGuild(344653) then EVENT_MANAGER:RegisterForEvent(PT.name,  EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, PT.OnGuildMemberPlayerStatusChanged) end
		
		PT.debug = PT.ASV.settingsPTDebug
		
		PT.PopulateGuildList()
		PVPTools.AutoInvite.Initialize()
		PT.CreateSettingsMenu()
	end
end


EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ADD_ON_LOADED, PT.OnAddOnLoaded)




--------------------------------------------------
-- DEBUGGING FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- DebugEntry - add a debug entry into the debug log and output the entry to the chat window
--------------------------------------------------
function PT.ToggleDebug()
	PT.ASV.settingsPTDebug = not PT.ASV.settingsPTDebug
	PT.debug = PT.ASV.settingsPTDebug -- kept around because it is used so often.  Eventually may be phased out
end

--------------------------------------------------
-- DebugEntry - add a debug entry into the debug log and output the entry to the chat window
--------------------------------------------------
function PT.DebugEntry(message) -- Verified
	table.insert(PT.debugLog, message)
	d(message)
end


--------------------------------------------------
-- ConvertBool - convert a boolean value to a string
--------------------------------------------------
function PT.ConvertBool(boolValue) -- Verified
	if boolValue then return "true" else return "false" end
end


--------------------------------------------------
-- Spacer - add blanks spaces to text
--------------------------------------------------
function PT.Spacer(width) -- Verified
	if width == nil then width = 10 end
	return "|u"..width..":0:: |u "
	-- PT.Spacer()..
end




--------------------------------------------------
-- EVENT REGISTRATIONS 
--------------------------------------------------

--------------------------------------------------
-- CheckEventRegistrations - turn on or off appropriate event listeners
--------------------------------------------------
function PT.CheckEventRegistrations()
	if PT.debug then PT.DebugEntry("PVPTools.CheckEventRegistrations") end
	
	--[[
	only one registration will be saved in the event manager and multiple calls to register for event will only acknowledge the initial registration
	
	registering for event multiple times will not cause any errors but only the first call is actually registered  Have not found a way to test if already registered.
	https://www.esoui.com/forums/showthread.php?t=8635&highlight=check+registered+event
	You are mistaken. Event handlers can only be registered once for the same eventNamespace/eventId pair. EVENT_MANAGER:RegisterForEvent returns true if it actually registered the function and false otherwise. In order to assign a different function you have to first call UnregisterForEvent for the same namespace and id, which will also return true in case it did unregister something.
	--]]
	
	local SV = PT.ASV	-- make a shortcut to the account wide saved variables

--	EVENT_GROUP_MEMBER_JOINED and EVENT_GROUP_MEMBER_LEFT
	if SV.settingsAIModuleOn then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_GROUP_MEMBER_JOINED and EVENT_GROUP_MEMBER_LEFT") end
		
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_GROUP_MEMBER_JOINED, PT.OnGroupMemberJoined)
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_GROUP_MEMBER_LEFT, PT.OnGroupMemberLeft)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting  EVENT_GROUP_MEMBER_JOINED and EVENT_GROUP_MEMBER_LEFT")end
		
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_GROUP_MEMBER_LEFT)
	end

--	EVENT_CHAT_MESSAGE_CHANNEL
	if 	(SV.settingsQSModuleOn and SV.settingsQSAutoShare) or (SV.settingsAIModuleOn and PVPTools.AutoInvite.AutoInviteShouldBeListening())
	then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_CHAT_MESSAGE_CHANNEL") end
	
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_CHAT_MESSAGE_CHANNEL, PT.OnChatMessage)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting  EVENT_CHAT_MESSAGE_CHANNEL") end
		
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_CHAT_MESSAGE_CHANNEL)
	end

--	EVENT_ZONE_CHANGED and EVENT_ARTIFACT_SCROLL_STATE_CHANGED
	if (SV.settingsQSModuleOn and SV.settingsQSAutoShare) then
		if PT.debug then 
			PT.DebugEntry(PT.Spacer().."Listening to EVENT_ZONE_CHANGED")
			PT.DebugEntry(PT.Spacer().."Listening to EVENT_ARTIFACT_SCROLL_STATE_CHANGED")
		end
		
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ZONE_CHANGED, PT.OnZoneChange)
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ARTIFACT_SCROLL_STATE_CHANGED, PT.OnScrollChange)
	elseif (not SV.settingsQSModuleOn or not SV.settingsQSAutoShare) then
		if PT.debug then 
			PT.DebugEntry(PT.Spacer().."Muting  EVENT_ZONE_CHANGED")
			PT.DebugEntry(PT.Spacer().."Muting  EVENT_ARTIFACT_SCROLL_STATE_CHANGED")
		end
		
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ZONE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ARTIFACT_SCROLL_STATE_CHANGED)
	end

-- 	EVENT_QUEST_SHARED
	if (SV.settingsQSModuleOn and SV.settingsQSAutoAccept) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_QUEST_SHARED")end
		
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_QUEST_SHARED, PT.OnQuestShared)
	elseif (not SV.settingsQSModuleOn or not SV.settingsQSAutoAccept) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting  EVENT_QUEST_SHARED")end
		
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_QUEST_SHARED)
	end

--	EVENT_QUEST_COMPLETE
	if (SV.settingsQSModuleOn and SV.settingsQSTrackDaily) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to  EVENT_QUEST_COMPLETE") end
		
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_QUEST_COMPLETE, PT.OnQuestComplete)
	elseif (not SV.settingsQSModuleOn or not SV.settingsQSTrackDaily) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_QUEST_COMPLETE") end
		
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_QUEST_COMPLETE)
	end

-- 	EVENT_MOUNTED_STATE_CHANGED
	if (not FavoriteMount) and (SV.settingsQOLMultimountOn) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_MOUNTED_STATE_CHANGED") end
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_MOUNTED_STATE_CHANGED, PT.OnMountStateChanged)
	elseif (FavoriteMount) or (not SV.settingsQOLMultimountOn) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_MOUNTED_STATE_CHANGED") end
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_MOUNTED_STATE_CHANGED)
	end

-- EVENT_CAMPAIGN_QUEUE_STATE_CHANGED
	if (SV.settingsQOLAutoAcceptQueue) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_CAMPAIGN_QUEUE_STATE_CHANGED") end
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, PT.OnCampaignQueueStateChange)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_CAMPAIGN_QUEUE_STATE_CHANGED") end
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
	end	

-- EVENT_OPEN_BANK
	if (SV.settingsMBUseAutoBanking) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_OPEN_BANK") end
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_OPEN_BANK, PT.OnOpenBank)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_OPEN_BANK") end
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_OPEN_BANK)
	end

-- EVENT_OPEN_STORE	
	if (SV.settingsMBUseAutoMerchant or SV.settingsMBUseFragmentMerchant) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_OPEN_STORE") end
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_OPEN_STORE, PT.OnOpenStore)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_OPEN_STORE") end
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_OPEN_STORE)
	end

-- EVENT_GROUP_MEMBER_CONNECTED_STATUS
	if (SV.settingsAIModuleOn and PVPTools.ASV.settingsAIAutoKick) then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Listening to EVENT_GROUP_MEMBER_CONNECTED_STATUS") end 
		
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, PT.OnGroupMemberConnectedStatusChanged)
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Muting EVENT_GROUP_MEMBER_CONNECTED_STATUS") end
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS)
	end
end




--------------------------------------------------
-- EVENT HANDLERS
-- Because in each addon an event can only have one function call per event and we have multiple modules listening for the same event, we will have to use a handler to triger the appropriate functions.
--------------------------------------------------




--------------------------------------------------
-- OnPlayerActivated - handler for EVENT_PLAYER_ACTIVATED
--------------------------------------------------
function PT.OnPlayerActivated(eventCode, initial) 
	if PT.debug then PT.DebugEntry("PVPTools.OnPlayerActivated") end
	
	PT.CheckEventRegistrations()
	
	if PT.ASV.settingsQSTrackDaily and PT.QuestShare.DailyResetHappened() then PT.QuestShare.ResetDailyTimers() end
	
	if PT.ASV.settingsDailyReset and PT.DailyResetHappen() then PT.ResetASVDailyTimer() end
end


--------------------------------------------------
-- OnChatMessage - handler for when EVENT_CHAT_MESSAGE_CHANNEL
--------------------------------------------------
function PT.OnChatMessage(eventCode, msgChannel, fromName, message, isCustomerService, fromDisplayName)
	if PT.debug then PT.DebugEntry("PVPTools.OnChatMessage") end
	
	-- This is a special case that is valid to call when not in a group or in pvp to check quest status
	if (message == "qs timers" or message == "qs timer") and PT.IsMe(fromDisplayName) then
		PT.QuestShare.DisplayQuestTimers()
		return
	end
		
	if 	PT.ASV.settingsQSModuleOn and 
		PT.ASV.settingsQSAutoShare and
		PT.IsGrouped() and
		PT.IsPVPZone()
	then
		PT.QuestShare.ProcessMessage(msgChannel, message, fromDisplayName)
	end
	
	if 	PT.ASV.settingsAIModuleOn and
		PVPTools.AutoInvite.AutoInviteShouldBeListening()
	then
		PVPTools.AutoInvite.ProcessMessage(msgChannel, message, fromDisplayName)
	end
end


--------------------------------------------------
-- OnGroupMemberJoined - handler for when EVENT_GROUP_MEMBER_JOINED
--------------------------------------------------
function PT.OnGroupMemberJoined(eventCode, characterName, memberDisplayName, isLocalPlayer)
	if PT.debug then PT.DebugEntry("PVPTools.OnGroupMemberJoined") end
	
	--TODO
end


--------------------------------------------------
-- OnGroupMemberLeft - handler for when EVENT_GROUP_MEMBER_LEFT
--------------------------------------------------
function PT.OnGroupMemberLeft(eventCode, characterName, leaveReason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	if PT.debug then PT.DebugEntry("PVPTools.OnGroupMemberLeft") end
	
	--TODO
end


--------------------------------------------------
-- OnZoneChange - handler for when EVENT_ZONE_CHANGED
--------------------------------------------------
function PT.OnZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneID, subZoneID) -- Verified
	if PT.debug then PT.DebugEntry("PVPTools.OnZoneChange") end
	
	if 	PT.ASV.settingsQSModuleOn and 
		PT.ASV.settingsQSAutoShare and
		PT.IsGrouped() and
		IsInCyrodiil()  -- ZOS function
	then
		PT.QuestShare.ProcessZoneChange(subZoneName)
	end
end


--------------------------------------------------
-- OnScrollChange - handler for EVENT_ARTIFACT_SCROLL_STATE_CHANGED
--------------------------------------------------
function PT.OnScrollChange(eventCode, objectiveKeepID, objectiveObjectiveID, battlegroundContext, objectiveName, objectiveControlEvent, objectiveControlState, originalOwnerAlliance, holderAlliance, lastHolderAlliance, capturedAtKeepID, mapDisplayPinType)
	if PT.debug then PT.DebugEntry("PVPTools.OnScrollChange") end
	
	if PT.ASV.settingsQSModuleOn and PT.ASV.settingsQSAutoShare then
		PT.QuestShare.ProcessScrollChange(objectiveName, holderAlliance)
	end
end


--------------------------------------------------
-- OnQuestShared - handler for EVENT_QUEST_SHARED
--------------------------------------------------
function PT.OnQuestShared(eventCode, questID)
	if PT.debug then PT.DebugEntry("PVPTools.OnQuestShared") end
	
	if PT.ASV.settingsQSModuleOn and PT.ASV.settingsQSAutoAccept then
		PT.QuestShare.ProcessQuestShared(questID)
	end
	
end


--------------------------------------------------
-- OnQuestComplete - handler for EVENT_QUEST_COMPLETE
--------------------------------------------------
function PT.OnQuestComplete(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
	if PT.debug then PT.DebugEntry("PVPTools.OnQuestComplete") end
	
	if 	(PT.ASV.settingsQSModuleOn and PT.ASV.settingsQSTrackDaily) and
		PT.IsPVPZone()
	then
		PT.QuestShare.ProcessQuestComplete(questName)
	end
end


--------------------------------------------------
-- OnMountStateChanged - handler for EVENT_MOUNTED_STATE_CHANGED
--------------------------------------------------
function PT.OnMountStateChanged(eventid, mounted)
	if PT.debug then PT.DebugEntry("PVPTools.OnMountStateChanged") end
	
	if PT.ASV.settingsQOLMultimountOn then
		PT.QOL.SwitchMount(mounted)
	end
end


--------------------------------------------------
-- OnCampaignQueueStateChange - handler for EVENT_CAMPAIGN_QUEUE_STATE_CHANGED
--------------------------------------------------
function PT.OnCampaignQueueStateChange(eventCode, campaignId, isGroup, campaignQueueRequestStateType)
	if PT.debug then PT.DebugEntry("PVPTools.OnCampaignQueueStateChange") end
	
	if PT.ASV.settingsQOLAutoAcceptQueue then
		PVPTools.QOL.AutoAcceptQueue(campaignId, isGroup, campaignQueueRequestStateType)
	end
	
end


--------------------------------------------------
-- OnGuildMemberPlayerStatusChanged - handler for EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
--------------------------------------------------
function PT.OnGuildMemberPlayerStatusChanged(eventCode, guildId, playerName, oldStatus, newStatus)
	-- if PT.debug then PT.DebugEntry("PVPTools.OnGuildMemberPlayerStatusChanged") end
	-- GetGuildId(luaindex guildIndex) Returns: integer guildId
	-- GetGuildName(integer guildId) Returns: string name
	-- Heroes of the Pact is guild number 344653
	if 	guildId == 344653 and 
		playerName == "@pawprints.shadow" and
		newStatus == PLAYER_STATUS_ONLINE
	then
		PVPTools.AMS.DisplayCenterAnnounce("|c00E600IT'S PAWS|r", PT.soundJohnny)
	end
	
	if 	guildId == 344653 and 
		playerName == "@Johnny_Guns86" and
		newStatus == PLAYER_STATUS_ONLINE
	then
		PVPTools.AMS.DisplayCenterAnnounce("|c662323Heeeeerrrreeesss JOHNNY!|r", PT.soundJohnny)
	end
end


--------------------------------------------------
-- OnOpenBank - handler for EVENT_OPEN_BANK
--------------------------------------------------
function PT.OnOpenBank(eventid, bankBag)
	if PT.debug then PT.DebugEntry("PVPTools.OnOpenBank") end
	
	if bankBag == BAG_BANK then PVPTools.MB.DoBanking(bankBag) end
end


--------------------------------------------------
-- OnOpenStore - handler for EVENT_OPEN_STORE
--------------------------------------------------
function PT.OnOpenStore(eventid)
	if PT.debug then PT.DebugEntry("PVPTools.OnOpenStore") end
	
	if (IsInCyrodiil() and PT.ASV.settingsMBAutoMerchant) then
		
		local itemName = ""
		local isSiegeMerchant = false
		
		itemName = PVPTools.MB.GetStoreItemInfo(1)
		
		for key, value in pairs(PVPTools.ASV.settingsMBAutoMerchant) do
			if string.find (itemName, key) then isSiegeMerchant = true break end
		end
		
		if isSiegeMerchant then PVPTools.MB.DoShopping() end
	end

	if (IsInImperialCity() and PT.ASV.settingsMBUseFragmentMerchant) then
		local c = {}
		c[1],c[2],c[3],c[4],c[5] = GetStoreUsedCurrencyTypes()
		for key, data in ipairs(c) do
			if  data == CURT_IMPERIAL_FRAGMENTS then
				PVPTools.MB.DoICShopping()
			end
		end	
	end
end



function PT.OnGroupMemberConnectedStatusChanged(eventCode, unitTag, isOnline)
	if PT.debug then PT.DebugEntry("PVPTools.OnGroupMemberConnectedStatusChanged") end
	
	d("Group Member Connection Status Change Event Triggered")
	d("unitTag: "..unitTag)
	d("Unit Name: "..GetUnitDisplayName(unitTag))
	if isOnline then d("Online") else d("Offline") end
	
	if not isOnline and PT.ASV.settingsAIAutoKick then
		-- I found that unitTag can change as people enter / leave group so we will use something safer
		local displayName = GetUnitDisplayName(unitTag)
		zo_callLater(function() PVPTools.AutoInvite.PlayerDisconnected(displayName) end, PT.ASV.settingsAIKickDelay * 1000)
	end
end
--------------------------------------------------
-- CHAT WINDOW FUNCTIONS
--------------------------------------------------




--------------------------------------------------
-- PreparedMessageToChat - Place a prepared message into the chat window so the user can press enter to send
--------------------------------------------------
function PT.PreparedMessageToChat(message)
	CHAT_SYSTEM:StartTextEntry(message)
	ZO_ChatWindowTextEntry:SetAlpha(1)
	ZO_ChatWindowTextEntryEditBox:SelectAll()
	ZO_ChatWindowTextEntryEditBox:TakeFocus()
end




--------------------------------------------------
-- GROUP FUNCTIONS
--------------------------------------------------




--------------------------------------------------
-- IsGrouped - quick test to see if the user is in a group
--------------------------------------------------
function PT.IsGrouped() -- Verified
	return IsUnitGrouped("player")
end


--------------------------------------------------
-- IsLeader - quick test to see if the user is the group leader
--------------------------------------------------
function PT.IsLeader() -- Verified
	return IsUnitGroupLeader("player")
end




--------------------------------------------------
-- PVP FUNCTIONS
--------------------------------------------------




--------------------------------------------------
-- IsInPVPZone - quick test to see if the user is in cyrodiil or imperial city
--------------------------------------------------
function PT.IsPVPZone()	-- Verified
	return IsPlayerInAvAWorld()
end


--------------------------------------------------
-- MyAlliance - returns the player's alliance
--------------------------------------------------
function PT.MyAlliance()
	return GetUnitAlliance('player')
end


--------------------------------------------------
-- IsInVengeance - returns true if the player is in Vengance
--------------------------------------------------
function PT.IsInVengeance()
	local campaignId = GetCurrentCampaignId()
	local campaignName = GetCampaignName(campaignId)
	
	if campaignName == "Vengeance" then
		return true
	else
		return false
	end
end


--------------------------------------------------
-- GetKeepId - take a supplied location name and return the cyrodiil keep id
--------------------------------------------------
function PT.GetKeepId(location)
	if PT.debug then PT.DebugEntry("PT.GetKeepId") end
	
	--[[
		Because each loaction in Cyrodiil is considered a keep, we can sequence through the keep numbers until we find a locatioin that matches the supplied location.
		Keeps, outposts, towns, resources, gates and bridges are all considered keeps.
		Even though we sequence through 200 potential keep ids not every keep id has been assigned, and the last used keep id number appears to be #165 which is for Harlun's outpost.
		/script
			for keepID = 1,200 do
				d("Keep ID: "..keepID)
				d("Keep Name: "..GetKeepName(keepID))
				d("Keep Alliance: "..GetKeepAlliance(keepID, BGQUERY_ASSIGNED_CAMPAIGN))
				d("Keep Alliance Name: "..GetAllianceName(GetKeepAlliance(keepID, BGQUERY_ASSIGNED_CAMPAIGN)))
				d("----------")
			end
	--]]
	if not location then return 0 end
	
	for keepId = 1, 200 do
		if location == string.lower(GetKeepName(keepId)) then
			if PT.debug then PT.DebugEntry(PT.Spacer().."Match found for "..location..".  Keep ID is "..keepId) end
			return keepId
		end
	end
	
	return 0
	
end




--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------




--------------------------------------------------
-- IsMe - check if the name matches the player's name
--------------------------------------------------
function PT.IsMe(name)
	if GetUnitDisplayName('player') == name then 
		return true 
	else 
		return false 
	end
end


--------------------------------------------------
-- CountPairs - returns the number of elements in an nonsequential table
--------------------------------------------------
function PT.CountPairs(tableToCount)
	local count = 0
	if tableToCount == nil then return nil end
	
	for element1, element2 in pairs(tableToCount) do
		count = count +1
	end
	
	return count
end


--------------------------------------------------
-- Capitalize - returns the string with the first letter capitalized
--------------------------------------------------
function PT.Capitalize(word)
	return (string.upper(string.sub(word, 1, 1))..string.sub(word, 2, -1))
end


--------------------------------------------------
-- DidDailyResetHappen - Check if the daily reset has happened since the last time the user logged in
--------------------------------------------------
function PT.DailyResetHappen()
	if PT.debug then PT.DebugEntry("PVPTools.DidDailyResetHappen") end
	
	if GetTimeStamp() > PT.ASV.settingsDailyReset then
		return true
	else	
		return false
	end
end


--------------------------------------------------
-- ResetASVDailyTimer - Reset the Account Wide Variables daily timer
--------------------------------------------------
function PT.ResetASVDailyTimer()
	if PT.debug then PT.DebugEntry("PVPTools.ResetASVDailyTimer") end
	
	local currentTime = GetTimeStamp()
	local timeUntilNextReset = GetTimeUntilNextDailyLoginRewardClaimS()
	
	PT.ASV.settingsDailyReset = currentTime + timeUntilNextReset
	PT.ASV.settingsQOLDailySiegeTable = {}
end


--------------------------------------------------
-- InCombat - check if the player is in combat
--------------------------------------------------
function PT.InCombat()
	if PT.debug then PT.DebugEntry("PVPTools.IAmInCombat") end
	
	return IsUnitInCombat("player")
end


--------------------------------------------------
-- PopulateGuildList - Populate the user's list of guilds
--------------------------------------------------
function PT.PopulateGuildList()
	if PT.debug then PT.DebugEntry("PVPTools.PopulateGuildList") end
	
	for i=1, 5 do
		local guildId = GetGuildId(i)
		if guildId then 
			PT.guilds[i] = {
				guildId, 
				GetGuildName(guildId)
			}
		else
			PT.guilds[i] = {
				0,
				"",
			}
		end
	end
	
	-- Repopulate the list if the user joins or leaves a guild
	EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_GUILD_SELF_JOINED_GUILD, PT.PopulateGuildList)
	EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_GUILD_SELF_LEFT_GUILD, PT.PopulateGuildList)
	
	-- Rebuild the Group Finder categories - primariliy used if a person joins or leaves a guild so that the autoinvite will list the proper guild names in the proper order.  TODO: NEEDS TO BE TESTED
	GROUP_MENU_KEYBOARD:RebuildCategories()
end




--------------------------------------------------
-- INVENTORY FUNCTIONS
--------------------------------------------------




--------------------------------------------------
-- FindSlotInBackpackByItemName - returns the slot number of the first instance of itemName or returns nil
--------------------------------------------------
function PT.FindSlotInBackpackByItemName(itemName)
	if PT.debug then PT.DebugEntry("PVPTools.FindSlotInBackpackByItemName") end
	
	local bag = BAG_BACKPACK
	local slot = ZO_GetNextBagSlotIndex(bag)
	
	while slot do
		local bagItemName = GetItemName(bag, slot)
		if string.find(bagItemName, itemName) then break end
		slot = ZO_GetNextBagSlotIndex(bag, slot) 
	end
	
	return slot
end
