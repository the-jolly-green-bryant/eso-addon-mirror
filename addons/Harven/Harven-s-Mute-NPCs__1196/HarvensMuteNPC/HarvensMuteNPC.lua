local sv
local currentVolume = 0
local inConversation = false
local npcChatting = false

local function printDebug(message)
	if sv.debug then
		d("HarvensMuteNPC: "..message)
	end
end

local function MuteVO()
	npcChatting = false
	EVENT_MANAGER:UnregisterForUpdate("HarvenMuteNPC_MuteVO")
	if inConversation then
		return
	end
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
	currentVolume = 0
	printDebug( "VO Muted" )
end

local function OnChatMessageChannel(eventId, msgType, fromName, text, isCustomerService)
	if IsUnitInCombat( "player" ) and sv.disableInCombat then return end

	if not sv.unmuteChats then
		return
	end

	if msgType ~= CHAT_CHANNEL_MONSTER_EMOTE and 
		msgType ~= CHAT_CHANNEL_MONSTER_SAY and
		msgType ~= CHAT_CHANNEL_MONSTER_WHISPER and
		msgType ~= CHAT_CHANNEL_MONSTER_YELL then return end

	EVENT_MANAGER:UnregisterForUpdate("HarvenMuteNPC_MuteVO")
		
	local from = zo_strformat("<<C:1>>", fromName)
	local message = zo_strformat("<<1>>", text)
	
	if not sv.heard[from] then
		sv.heard[from] = { [message] = true }
	elseif not sv.heard[from][message] then
		sv.heard[from][message] = true
	else
		if sv.muteHeardChats then
			printDebug("Dialogue alread heard - doing nothing.")
			return
		end
	end
	
	npcChatting = true
	
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sv.volume)
	currentVolume = sv.volume
	
	local timeout = 1000 * ( 2 + ( #message * 0.1 ) )
	
	EVENT_MANAGER:RegisterForUpdate("HarvenMuteNPC_MuteVO", timeout, MuteVO)
	printDebug( "Never heard dialogue: VO unmuted for "..(timeout/1000).." seconds." )
end

local function InitOptionsPanel()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's Mute NPCs")
	if not settings then return end
	
	local dialogue = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Unmuted Voice Volume",
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return sv.volume end,
		setFunction = function(value) sv.volume = value end,
	}
	
	local bankers = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Bankers Voice Volume",
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		getFunction = function() return sv.bankersVolume end,
		setFunction = function(value) sv.bankersVolume = value end,
	}
	
	local unmuteDialogs = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Mute NPCs in Dialogs",
		getFunction = function() return not sv.unmuteDialogs end,
		setFunction = function(value) sv.unmuteDialogs = not value end,
	}
	
	local unmuteChats = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Mute Says/Yells",
		getFunction = function() return not sv.unmuteChats end,
		setFunction = function(value) sv.unmuteChats = not value end,
	}
	
	local muteHeardChats = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Mute Once Heard Says/Yells",
		getFunction = function() return sv.muteHeardChats end,
		setFunction = function(value) sv.muteHeardChats = value end,
	}

	local disableInCombat = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Disable addon while in combat",
		getFunction = function() return sv.disableInCombat end,
		setFunction = function(value) sv.disableInCombat = value end,
	}
	
	local debugging = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Show Debug Messages",
		getFunction = function() return sv.debug end,
		setFunction = function(value) sv.debug = value end,
	}
	
	settings:AddSettings({dialogue, bankers, unmuteDialogs, unmuteChats, muteHeardChats, disableInCombat, debugging})
end
	
local function OnInitialized(eventID, addonName)
	if addonName ~= "HarvensMuteNPC" then
		return
	end
	
	local defaults = {
		volume = -1,
		bankersVolume = 100,
		heard = {
		},
		debug = false,
		unmuteDialogs = true,
		unmuteChats = true,
		muteHeardChats = true,
		disableInCombat = true
	}
	
	sv = ZO_SavedVars:NewAccountWide("HarvensMuteNPC_SavedVariables", 1, nil, defaults)
	
	if sv.volume == -1 then
		sv.volume = math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	end
	
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
	
	local VOOnReleasedHandler = Options_Audio_VOVolume.onReleasedHandler
	Options_Audio_VOVolume.onReleasedHandler = function(...)
		VOOnReleasedHandler(...)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, currentVolume)
	end

	EVENT_MANAGER:RegisterForEvent("HarvensMuteNPC", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessageChannel)
	EVENT_MANAGER:RegisterForEvent("HarvensMuteNPC", EVENT_CHATTER_BEGIN, function(eventID, optionsCount)
		if IsUnitInCombat( "player" ) and sv.disableInCombat then return end
		
		local isBanker = false
		if optionsCount and optionsCount > 0 then
			for i=1,optionsCount do
				local text, otype = GetChatterOption(i)
				if otype == CHATTER_START_BANK then
					isBanker = true
				end
			end
		end
	
		if not sv.unmuteDialogs then return end
		if isBanker then
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sv.bankersVolume)
			printDebug("Chatter begin (banker)- VO unmuted - "..sv.bankersVolume)
			currentVolume = sv.bankersVolume
		else
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sv.volume)
			printDebug("Chatter begin - VO unmuted - "..sv.volume)
			currentVolume = sv.volume
		end
		inConversation = true
	end)
	EVENT_MANAGER:RegisterForEvent("HarvensMuteNPC", EVENT_CHATTER_END, function()
		if IsUnitInCombat( "player" ) and sv.disableInCombat then return end
		if not inConversation then return end
		inConversation = false
		if npcChatting then return end
		MuteVO()
	end)
	EVENT_MANAGER:RegisterForEvent("HarvensMuteNPC", EVENT_PLAYER_COMBAT_STATE, function(eventId, inCombat)
		if sv.disableInCombat then
			if inCombat then
				printDebug( "In combat - VO unmuted - "..sv.volume )
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, sv.volume)
			else
				printDebug( "Out of combat - muting VO" )
				MuteVO()
			end
		end
	end)
	
	InitOptionsPanel()
end

EVENT_MANAGER:RegisterForEvent("HarvensMuteNPC", EVENT_ADD_ON_LOADED, OnInitialized)