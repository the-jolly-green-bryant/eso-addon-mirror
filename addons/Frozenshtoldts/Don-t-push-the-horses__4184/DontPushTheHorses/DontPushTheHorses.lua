DontPushTheHorses = {}

local addonName = "DontPushTheHorses"

local CHANNELS = {
	[CHAT_CHANNEL_SAY] = "Say",
	[CHAT_CHANNEL_YELL] = "Yell",
	[CHAT_CHANNEL_PARTY] = "Group",
	[CHAT_CHANNEL_GUILD_1] = "Guild 1",
	[CHAT_CHANNEL_GUILD_2] = "Guild 2",
	[CHAT_CHANNEL_GUILD_3] = "Guild 3",
	[CHAT_CHANNEL_GUILD_4] = "Guild 4",
	[CHAT_CHANNEL_GUILD_5] = "Guild 5",
	[CHAT_CHANNEL_ZONE] = "Zone",
	[CHAT_CHANNEL_ZONE_LANGUAGE_1] = "Zone (Language 1)",
	[CHAT_CHANNEL_ZONE_LANGUAGE_2] = "Zone (Language 2)",
	[CHAT_CHANNEL_ZONE_LANGUAGE_3] = "Zone (Language 3)",
	[CHAT_CHANNEL_ZONE_LANGUAGE_4] = "Zone (Language 4)",
	[CHAT_CHANNEL_ZONE_LANGUAGE_5] = "Zone (Language 5)",
	[CHAT_CHANNEL_ZONE_LANGUAGE_6] = "Zone (Language 6)",
	[CHAT_CHANNEL_WHISPER] = "Whisper (Incoming)",
	[CHAT_CHANNEL_WHISPER_SENT] = "Whisper (Sent)",
	[CHAT_CHANNEL_EMOTE] = "Emote",
}


DontPushTheHorses.CHANNELS = CHANNELS

local blockedCharacters = {"ё", "Ё", "ъ", "Ъ", "ы", "Ы", "э", "Э"}

local function StripSuffix(name)
	if not name then return "" end
	return string.match(name, "([^%^@]+)")
end

local function ContainsBlockedCharacters(text)
	for _, ch in ipairs(blockedCharacters) do
		if string.find(text, ch, 1, true) then
			return true
		end
	end
	return false
end

local function ContainsCJKCharacters(text)
	for i = 1, #text do
		local byte = string.byte(text, i)
		if byte and byte >= 0xE3 then
			return true
		end
	end
	return false
end

local function IsBlockedText(text)
	return ContainsBlockedCharacters(text) or ContainsCJKCharacters(text)
end

local defaultSettings = {
	chatFilters = {},
	notifyChannels = {},
	messageFormat = "name+channel+text",
	blockOwnMessages = false,
}

for channelId in pairs(CHANNELS) do
	defaultSettings.chatFilters[channelId] = true
	defaultSettings.notifyChannels[channelId] = true
end

DontPushTheHorses.savedVars = {}

function DontPushTheHorses.spamFilter(chatRoom, fromName, rawMessageText)
	local playerCharName = GetUnitName("player")
	local playerAccountName = GetDisplayName()

	if not DontPushTheHorses.savedVars.blockOwnMessages then
		if StripSuffix(fromName) == playerCharName then return false end
		if fromName == playerAccountName then return false end
	end

	if not DontPushTheHorses.savedVars.chatFilters[chatRoom] then return false end

	if IsBlockedText(rawMessageText) then
		DontPushTheHorses.filteredCount = (DontPushTheHorses.filteredCount or 0) + 1

		if DontPushTheHorses.savedVars.notifyChannels[chatRoom] then
			local msg
			local format = DontPushTheHorses.savedVars.messageFormat
			local chatName = DontPushTheHorses.CHANNELS[chatRoom] or tostring(chatRoom)
			if format == "name" then
				msg = zo_strformat("|cFF0000[Dont Push The Horses]|r |c00FFFF<<1>>|r has been knocked out!", fromName)
			elseif format == "name+channel" then
				msg = zo_strformat("|cFF0000[Dont Push The Horses]|r |c00FFFF<<1>>|r from the |c00FF00<<2>>|r chat has been knocked out!", fromName, chatName)
			elseif format == "name+channel+text" then
				msg = zo_strformat("|cFF0000[Dont Push The Horses]|r |c00FFFF<<1>>|r from the |c00FF00<<2>>|r chat has been knocked out because of: |cFFFFFF<<3>>|r!", fromName, chatName, rawMessageText)
			else
				msg = zo_strformat("|cFF0000[Dont Push The Horses]|r <<1>>", fromName)
			end
			CHAT_SYSTEM:AddMessage(msg)
		end
		return true
	end

	return false
end

DontPushTheHorses.formatter = nil

function DontPushTheHorses:Initialize()
	DontPushTheHorses.savedVars = ZO_SavedVars:New("DontPushTheHorsesSavedVariables", 1, GetWorldName(), defaultSettings, GetWorldName())
	DontPushTheHorses.filteredCount = 0

	SLASH_COMMANDS["/dpth"] = function()
		CHAT_SYSTEM:AddMessage(zo_strformat("Wins by Knockout: <<1>>", DontPushTheHorses.filteredCount))
	end

	DontPushTheHorses:CreateSettingsMenu()

	EVENT_MANAGER:RegisterForEvent("DontPushTheHorsesInit", EVENT_PLAYER_ACTIVATED, function()
		CHAT_SYSTEM:AddMessage("|c00ff00[Dont Push The Horses] entered the ring!|r")
		EVENT_MANAGER:UnregisterForEvent("DontPushTheHorsesInit", EVENT_PLAYER_ACTIVATED)

		if pChat == nil then
			if not DontPushTheHorses.formatter then
				DontPushTheHorses.formatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
			end
			--pChat is not loaded: Add your own handler to the CHAT_ROUTER
			--I'd always check if any other chat addon is active though and maybe thus always add the code below, even if pChat is not loaded
			--as it will keep exisitng callback functions of other addons or event add to the original vanilla chat formatter callback function
			CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(channelID, from, text, isCustomerService, fromDisplayName)
				local senderName = fromDisplayName

				if channelID == CHAT_CHANNEL_WHISPER_SENT then
					senderName = GetDisplayName()
				end

				if DontPushTheHorses.spamFilter(channelID, senderName, text) then
					return nil
				end

				return DontPushTheHorses.formatter(channelID, from, text, isCustomerService, fromDisplayName)
			end)
		else
			--pChat is loaded
			--!!!ATTENTION!!!
			--Do the following at EVENT_PLAYER_ACTIVATED after pChat has set CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, pChatChatHandlersMessageChannelReceiver)
			--Get all chat formatters. Table formatters will contain the different chat event entries, like EVENT_CHAT_MESSAGE_CHANNEL now
			local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
			--Get the chat callback function for EVENT_CHAT_MESSAGE_CHANNEL of pChat
			local originalpChatFormatter = formatters[EVENT_CHAT_MESSAGE_CHANNEL]
			if originalpChatFormatter then
				--Either:
				--Post Hook pChat's EVENT_CHAT_MESSAGE_CHANNEL callbackFunction by re-applying the own handler function
				--which first calls pChat's function, and then your own code
				CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(channelID, from, text, isCustomerService, fromDisplayName)
					local senderName = fromDisplayName

					if channelID == CHAT_CHANNEL_WHISPER_SENT then
						senderName = GetDisplayName()
					end

					if DontPushTheHorses.spamFilter(channelID, senderName, text) then
						return nil
					end

					return originalpChatFormatter(channelID, from, text, isCustomerService, fromDisplayName)
				end)
			end
		end

	end)
end

local function OnAddonLoaded(event, name)
    CHAT_SYSTEM:AddMessage("test")
	if name == addonName then
		DontPushTheHorses:Initialize()
		EVENT_MANAGER:UnregisterForEvent(addonName .. "Loaded", EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(addonName .. "Loaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
