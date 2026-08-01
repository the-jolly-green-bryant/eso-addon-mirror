local _isEmoteSyncActive = false
local _emoteSyncKey = "[LovelyEmotes]"
local _emoteSyncChats

function LovelyEmotes.IsEmoteSynchronizationActive()
	return _isEmoteSyncActive
end

function LovelyEmotes.CreateSyncMessage(emote)
	CHAT_SYSTEM:StartTextEntry(zo_strformat("<<1>> <<2>> <<3>>", _emoteSyncKey, emote.ID, emote.SlashName))
end

local function OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	if _emoteSyncChats[channelType] ~= true then return end

	local strings = {}
	for w in string.gmatch(text, "%S+") do
		table.insert(strings, w)
		if #strings > 1 then break end
	end

	if strings[1] ~= _emoteSyncKey or strings[2] == nil then return end

	local emote = LovelyEmotes.GetEmoteByID(tonumber(strings[2]:match("%d+")))
	if emote ~= nil then
		emote.Play()
	end
end

local function UpdateChatMessageChannelEventActive()
	local isActive = false

	for _, isEnabled in pairs(_emoteSyncChats) do
		if isEnabled == true then
			isActive = true
			break
		end
	end

	if isActive == _isEmoteSyncActive then return end
	_isEmoteSyncActive = isActive

	if isActive == true then
		EVENT_MANAGER:RegisterForEvent(LovelyEmotes.Name, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
	else
		EVENT_MANAGER:UnregisterForEvent(LovelyEmotes.Name, EVENT_CHAT_MESSAGE_CHANNEL)
	end
end

function LovelyEmotes.InitializeEmoteSync()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	_emoteSyncChats = {
		[CHAT_CHANNEL_SAY] = savedAccountVariables.EnableSayChatSync,
		[CHAT_CHANNEL_PARTY] = savedAccountVariables.EnablePartyChatSync,
		[CHAT_CHANNEL_WHISPER] = savedAccountVariables.EnableWhisperChatSync,
		[CHAT_CHANNEL_ZONE] = savedAccountVariables.EnableZoneChatSync,
	}

	UpdateChatMessageChannelEventActive()

	LovelyEmotes_EventSystem.AddListener(LE_EVENT_EmoteSyncChatChannelChanged, function(chatChannel, isEnabled)
		_emoteSyncChats[chatChannel] = isEnabled
		UpdateChatMessageChannelEventActive()
	end)
end
