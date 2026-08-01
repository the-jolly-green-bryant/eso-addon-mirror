SafeChat = {
	lamPanel = nil,
}

local NAME = "SafeChat"
local VERSION = "0.1"

-- Addon events
-- Use SafeChat.RegisterCallback(event, callback) to register a callback
SC_EVENT_CHANNEL_CHANGED	= "ChannelChanged" 	-- player changed chat channel
SC_EVENT_CHAT_SEND			= "ChatSend"	 	-- player presses Enter to send chat message

local A  = SafeChat
local EM = EVENT_MANAGER
local CM -- callback manager

local SV = nil -- saved variables
local SV_DEFAULTS = {
	enabled = false,
	enabledEverywhere = false,
	enabledChannels = {
		[CHAT_CHANNEL_SAY]		= true,
		[CHAT_CHANNEL_YELL]		= true,
		[CHAT_CHANNEL_EMOTE]	= true,
		[CHAT_CHANNEL_WHISPER]	= true,
		[CHAT_CHANNEL_PARTY]	= true,
	},
	useCustomKeyword = false,
	customKeyword = "Saf3Ch4t",
	customKeywordChannels = {
		[CHAT_CHANNEL_SAY]		= true,
		[CHAT_CHANNEL_YELL]		= true,
		[CHAT_CHANNEL_EMOTE]	= true,
		[CHAT_CHANNEL_PARTY]	= false,
	},
}

-- Shortcuts
local time 			= GetGameTimeMilliseconds
local strformat 	= string.format
local strsub 		= string.sub
local strlen		= utf8.len
local charcode 		= utf8.codepoint
local utf8offset 	= utf8.offset

-- Alphabets
-- lowercase, UPPERCASE and numbers are separated to make encoded messages look more "human" instead of a random sequence like "1Ab9 0CdX"
-- it also helps to bypass CAPSLOCK spam filters
local ABC = {
	['num']		= {}, -- 0-9
	['en']		= {}, -- english lowercase
	['EN']		= {}, -- english UPPERCASE
}

-- character => alphabet
-- contains characters from all alphabets to quickly know which character belongs to which alphabet
local CHAR = {}

-- Supported chat channels and their shifts (by how much we "shift" a character in the alphabet when encoding)
local CHANNELS = {
	[CHAT_CHANNEL_SAY]				= 1,
	[CHAT_CHANNEL_YELL]				= 2,
	[CHAT_CHANNEL_EMOTE]			= 3,
	[CHAT_CHANNEL_ZONE]				= 4,
	[CHAT_CHANNEL_WHISPER]			= 5,
	[CHAT_CHANNEL_WHISPER_SENT]		= 5,
	[CHAT_CHANNEL_PARTY]			= 6,
	[CHAT_CHANNEL_GUILD_1]			= 7, -- must be the same number for all guilds
	[CHAT_CHANNEL_GUILD_2]			= 7, -- guild2 for one player can be guild5 for another
	[CHAT_CHANNEL_GUILD_3]			= 7,
	[CHAT_CHANNEL_GUILD_4]			= 7,
	[CHAT_CHANNEL_GUILD_5]			= 7,
	[CHAT_CHANNEL_OFFICER_1]		= 8, -- must be the same number for all guilds
	[CHAT_CHANNEL_OFFICER_2]		= 8,
	[CHAT_CHANNEL_OFFICER_3]		= 8,
	[CHAT_CHANNEL_OFFICER_4]		= 8,
	[CHAT_CHANNEL_OFFICER_5]		= 8,
	[CHAT_CHANNEL_ZONE_LANGUAGE_1]	= 20,
	[CHAT_CHANNEL_ZONE_LANGUAGE_2]	= 21,
	[CHAT_CHANNEL_ZONE_LANGUAGE_3]	= 22,
	[CHAT_CHANNEL_ZONE_LANGUAGE_4]	= 23,
	[CHAT_CHANNEL_ZONE_LANGUAGE_5]	= 24,
	[CHAT_CHANNEL_ZONE_LANGUAGE_6]	= 25,
	[CHAT_CHANNEL_ZONE_LANGUAGE_7]	= 26,
}

-- Get i-th character from utf8 string
local function utf8c(s, i)
	return strsub(s, utf8offset(s, i), utf8offset(s, i + 1) - 1)
end

-- Count alphabet characters in string + spaces
function A.abcLen(s)
	local n = 0
	for i = 1, utf8.len(s) do
		local c = utf8c(s, i)
		if c == " " or CHAR[c] then
			n = n + 1
		end
	end
	return n
end

local function IsEmptyString(s)
	return type(s) ~= 'string' or #s == 0
end

function A.GetName()
	return NAME
end

function A.GetVersion()
	return VERSION
end

function A.SetEnabled(enabled)
	if enabled == true then
		SV.enabled = true
	else
		SV.enabled = false
	end
	A.UpdateHUD()
end

function A.IsEnabled()
	return SV.enabled
end

function A.GetCurrentChannel()
	return CHAT_ROUTER:GetCurrentChannelData().id
end

-- Is current channel encoded
function A.IsSafeChannel(channel)
	channel = channel or A.GetCurrentChannel()
	return A.IsEnabled() and CHANNELS[channel] and (SV.enabledEverywhere or SV.enabledChannels[channel])
end

function A.IsCustomKeywordChannel(channel)
	return SV.useCustomKeyword and SV.customKeywordChannels[channel]
end

local lastRawKeyword, lastKeyword -- cache keyword
function A.GetCustomKeyword()
	if lastRawKeyword == SV.customKeyword and lastKeyword then
		return lastKeyword
	end

	local keyword = {}
	for i = 1, utf8.len(SV.customKeyword) do
		local c = utf8c(SV.customKeyword, i)
		if CHAR[c] then
			table.insert(keyword, c)
		end
	end
	lastRawKeyword = SV.customKeyword
	lastKeyword = table.concat(keyword)
	return lastKeyword
end

-- table, string
local function CreateCipherAlphabet(baseAlphabet, keyword)
	local cipherAlphabet = {} -- hash
	local cipherAlphabetIndex = {} -- ordered table
	-- Remove duplicates from the keyword
	for i = 1, #keyword do
		local c = keyword:sub(i, i)
		if baseAlphabet[c] and not cipherAlphabet[c] then
			table.insert(cipherAlphabetIndex, c)
			cipherAlphabet[c] = #cipherAlphabetIndex
		end
	end
	-- Generate cipher alphabet: keyword + the rest of the alphabet excluding keyword letters
	for _, c in ipairs(baseAlphabet['index']) do
		if not cipherAlphabet[c] then
			table.insert(cipherAlphabetIndex, c)
			cipherAlphabet[c] = #cipherAlphabetIndex
		end
	end
	-- Keep the indexed alphabet too
	cipherAlphabet['index'] = cipherAlphabetIndex
	return cipherAlphabet
end

-- string, number
local function ApplyCaesarCipher(text, shift)
	local caesarEncodedText = {}
	local prev = '' -- previous character
	local hCount = -1 -- count |h to avoid links
	for i = 1, utf8.len(text) do
		local c = utf8c(text, i)
		-- after meeting |H we need double |h to "close" it
		if prev == '|' and (c == 'H' or c == 'h') then
			hCount = hCount > 0 and hCount - 1 or 2
		end
		prev = c
		-- encode character if it belongs to known alphabet
		if hCount < 0 and CHAR[c] then
			local abc = CHAR[c]
			local encodedIndex = (abc[c] + shift) % #abc['index']
			-- first index in tables is 1, so we need to handle 0 manually (use the last alphabet's character)
			table.insert(caesarEncodedText, encodedIndex > 0 and abc['index'][encodedIndex] or abc['index'][#abc['index']])
		-- keep original character
		else
			table.insert(caesarEncodedText, c)
		end
		if hCount == 0 then hCount = -1 end -- when hCount turns 0, we are still inside a link
	end
	return table.concat(caesarEncodedText)
end

-- string, string
local function EncodeKeywordCipher(text, keyword)
	local ciphers = {}
	local encodedText = {}
	local prev = '' -- previous character
	local hCount = -1 -- count |h to avoid links
	for i = 1, utf8.len(text) do
		local c = utf8c(text, i)
		-- after meeting |H we need double |h to "close" it
		if prev == '|' and (c == 'H' or c == 'h') then
			hCount = hCount > 0 and hCount - 1 or 2
		end
		prev = c
		-- encode character if it belongs to known alphabet
		if hCount < 0 and CHAR[c] then
			local abc = CHAR[c] -- the alphabet this character belongs to
			if not ciphers[abc] then -- create cipher if needed (if text contains digits only, then we don't need ciphers for letters)
				ciphers[abc] = CreateCipherAlphabet(abc, keyword)
			end
			-- encoded character = abc's character with the same index in cipher
			table.insert(encodedText, ciphers[abc]['index'][abc[c]])
		-- keep the original character
		else
			table.insert(encodedText, c)
		end
		if hCount == 0 then hCount = -1 end -- when hCount turns 0, we are still inside a link
	end
	return table.concat(encodedText)
end

-- string, string
local function DecodeKeywordCipher(text, keyword)
	local ciphers = {}
	local decodedText = {}
	local prev = '' -- previous character
	local hCount = -1 -- count |h to avoid links
	for i = 1, utf8.len(text) do
		local c = utf8c(text, i)
		-- after meeting |H we need double |h to "close" it
		if prev == '|' and (c == 'H' or c == 'h') then
			hCount = hCount > 0 and hCount - 1 or 2
		end
		prev = c
		-- decode character if it belongs to known alphabet
		if hCount < 0 and CHAR[c] then
			local abc = CHAR[c] -- the alphabet this character belongs to
			if not ciphers[abc] then -- create cipher if needed (if text contains digits only, then we don't need ciphers for letters)
				ciphers[abc] = CreateCipherAlphabet(abc, keyword)
			end
			-- decoded character = cipher's character with the same index in abc
			table.insert(decodedText, abc['index'][ciphers[abc][c]])
		-- keep the original character
		else
			table.insert(decodedText, c)
		end
		if hCount == 0 then hCount = -1 end -- when hCount turns 0, we are still inside a link
	end
	return table.concat(decodedText)
end	

-- Message prefix is needed to distinguish between normal and encoded chat messages from other players.
-- Message prefix consists of 2 letters:
-- 1) text length converted to UPPERCASE english letter
-- 2) first letter of @UserID shifted by channelShift (lowercase)
-- "salt" is a number used to offset alphabet index
function A.GetMessagePrefix(channel, userId, salt)
	if A.IsCustomKeywordChannel(channel) then
		userId = A.GetCustomKeyword()
	end
	local id = UndecorateDisplayName(IsEmptyString(userId) and GetDisplayName() or userId)
	local shift = CHANNELS[channel] or 0
	salt = type(salt) == 'number' and zo_ceil(salt) or shift
	return strformat('%s%s', ABC['EN']['index'][(salt + shift) % #ABC['EN']['index'] + 1], ABC['en']['index'][(charcode(id) + shift) % #ABC['en']['index'] + 1])
end

-- Use different keywords for different channels and messages, so there are less repeating words
function A.GetKeyword(channel, userId, salt)
	if A.IsCustomKeywordChannel(channel) then
		return A.GetCustomKeyword()
	end

	local id = UndecorateDisplayName(IsEmptyString(userId) and GetDisplayName() or userId)
	local shift = CHANNELS[channel] or 0
	local len = salt % 5 + 1 -- keyword length
	local keyword = {}
	shift = shift + salt + charcode(id) -- make shift more dynamic
	for _, abc in pairs(ABC) do
		local index = abc['index']
		local indexLength = #index
		table.insert(keyword, index[shift % indexLength + 1])
		if len > 1 then table.insert(keyword, index[indexLength - shift % indexLength]) end
		if len > 2 then table.insert(keyword, index[salt % indexLength + 1]) end
		if len > 3 then table.insert(keyword, index[indexLength - salt % indexLength]) end
		if len > 4 then table.insert(keyword, index[salt * shift % indexLength]) end
	end
	return table.concat(keyword)

	-- if I ever want to use guild name for keyword generation...
	--local guildId = GetGuildId((channel - CHAT_CHANNEL_GUILD_1) % MAX_GUILDS + 1)
	--local guildName = GetGuildName(guildId)
end

function A.GetMessagePrefixAndKeyword(channel, userId, salt)
	return A.GetMessagePrefix(channel, userId, salt), A.GetKeyword(channel, userId, salt)
end

function A.EncodeMessage(text, keyword)
	keyword = IsEmptyString(keyword) and '' or keyword
	return ApplyCaesarCipher(EncodeKeywordCipher(text, keyword), strlen(keyword))
end

function A.DecodeMessage(text, keyword)
	keyword = IsEmptyString(keyword) and '' or keyword
	return DecodeKeywordCipher(ApplyCaesarCipher(text, -strlen(keyword)), keyword)
end


-------------------------------------------------
---- HUD
-------------------------------------------------

function A.UpdateHUD()
	local channel = A.GetCurrentChannel()
	local texture
	if A.IsSafeChannel(channel) then
		texture = A.IsCustomKeywordChannel(channel) and '/esoui/art/inventory/inventory_tradable_icon.dds' or '/esoui/art/inventory/inventory_icon_hiddenby.dds'
	end
	SafeChatControlButton:SetNormalTexture(texture or '/esoui/art/inventory/inventory_icon_visible.dds')
end

-- Chatbox icon
function SafeChat_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPRIGHT)
	local channel = A.GetCurrentChannel()
	local text
	if A.IsSafeChannel(channel) then
		text = A.IsCustomKeywordChannel(channel) and "|c00FF00This channel uses custom SafeChat keyword|r" or "|c00FF00This channel is encoded by SafeChat|r"
	end
    SetTooltipText(InformationTooltip, text or "|cFF0000This channel is NOT encoded|r")
end

function SafeChat_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
end

function SafeChat_ShowOptions(control)
    ClearMenu()

	AddMenuItem('Settings', function() LibAddonMenu2:OpenToPanel(A.lamPanel) end)
	if A.IsEnabled() and not SV.enabledEverywhere then
		local channel = A.GetCurrentChannel()
		if SV.enabledChannels[channel] then
			AddMenuItem('Disable Channel Encoding', function() SV.enabledChannels[channel] = false; A.UpdateHUD(); end)
		else
			AddMenuItem('Enable Channel Encoding', function() SV.enabledChannels[channel] = true; A.UpdateHUD(); end)
		end
	end

    ShowMenu(SafeChatControlButton)
end


-------------------------------------------------
---- Load & Initialize
-------------------------------------------------

function A.GetCallbackManager()
	return CM
end

function A.RegisterCallback(eventName, callback)
    CM:RegisterCallback(eventName, callback)
end

function A.UnregisterCallback(eventName, callback)
    CM:UnregisterCallback(eventName, callback)
end

local function PlayerActivated()
	-- Unregister old events
	A.UnregisterCallback(SC_EVENT_CHANNEL_CHANGED, A.UpdateHUD)

	-- Register new events
	A.RegisterCallback(SC_EVENT_CHANNEL_CHANGED, A.UpdateHUD)

	A.UpdateHUD()
end

local function Initialize()

	CM = ZO_CallbackObject:New()

	-- Create hash tables that are easier to work with than strings
	local function CreateAlphabet(s, a)
		a['index'] = {}
		for i = 1, #s do
			local c = s:sub(i, i)
			a[c] = i
			table.insert(a['index'], c)
			CHAR[c] = a
		end
	end
	CreateAlphabet('0123456789', ABC['num'])
	CreateAlphabet('abcdefghijklmnopqrstuvwxyz', ABC['en'])
	CreateAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ', ABC['EN'])

	-- Retrieve saved variables
	SV = ZO_SavedVars:NewAccountWide('SafeChatSV', 10, nil, SV_DEFAULTS, 'Default', GetWorldName())

	-- Build LibAddonMenu2
	A.BuildMenu(SV, SV_DEFAULTS)

	-- Register events
	EM:RegisterForEvent(NAME .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, PlayerActivated)

	---------------------------
	-- Hooks and overrides
	---------------------------
	local lastChannelId -- last send channel

	-- Decode history
	local orgAddCommandHistory
	local function AddCommandHistory(self, text)
		if orgAddCommandHistory then
			if A.IsEnabled() and A.IsSafeChannel(lastChannelId) and strlen(text) > 2 then
				local textBody = text:sub(3)
				local prefix, keyword = A.GetMessagePrefixAndKeyword(lastChannelId, GetDisplayName(), A.abcLen(textBody))
				if text:sub(1, 2) == prefix then
					text = A.DecodeMessage(textBody, keyword)
				end
			end
			orgAddCommandHistory(self, text)
		end
	end

	-- This function is called when user presses Enter to send chat message, but we still can modify it
	ZO_PreHook("ZO_ChatTextEntry_Execute", function(...)
		-- CHAT_SYSTEM:ValidateChatChannel() -- switch to valid channel and send message there
		lastChannelId = A.GetCurrentChannel()
		local textEntry = ZO_GetChatSystem().textEntry
		local text = textEntry:GetText()
		local encodedText
		if A.IsEnabled() and A.IsSafeChannel(lastChannelId) and #text > 0 and text:sub(1, 1) ~= '/' then -- ignore /commands
			local prefix, keyword = A.GetMessagePrefixAndKeyword(lastChannelId, GetDisplayName(), A.abcLen(text))
			encodedText = A.EncodeMessage(text, keyword)
			textEntry:SetText(strformat('%s%s', prefix, encodedText))
			-- We can't modify SharedChatSystem:SubmitTextEntry() to store correct history, so use this workaround
			if textEntry.AddCommandHistory ~= AddCommandHistory then
				orgAddCommandHistory = textEntry.AddCommandHistory
				textEntry.AddCommandHistory = AddCommandHistory
			end
		end
		-- Player presses Enter
		CM:FireCallbacks(SC_EVENT_CHAT_SEND, lastChannelId, text, encodedText)
	end)

	-- Chat channel changed
	ZO_PostHook(CHAT_ROUTER, "SetCurrentChannelData", function()
		CM:FireCallbacks(SC_EVENT_CHANNEL_CHANGED, A.GetCurrentChannel())
	end)

	-- Decode chat messages before they are passed to message formatters of chat addons and libs
	local orgFormatAndAddChatMessage = CHAT_ROUTER.FormatAndAddChatMessage
	CHAT_ROUTER.FormatAndAddChatMessage = function(...)
		-- Only decode EVENT_CHAT_MESSAGE_CHANNEL messages
		if A.IsEnabled() and select(2, ...) == EVENT_CHAT_MESSAGE_CHANNEL then
			local args = {...} -- [1] = eventKey, [2] = eventId, [3] = channelId, [4] = from, [5] = text, [6] = isCustomerService, [7] = fromDisplayName
			local text = args[5]
			if CHANNELS[args[3]] and strlen(text) > 2 then
				local textBody = text:sub(3) -- if it's an encoded text, then first two letters are english, so we don't need utf8 functions there
				-- For sent whispers both "from" and "fromDisplayName" are actually target names, but we need player's name for prefix
				local prefix, keyword = A.GetMessagePrefixAndKeyword(args[3], args[3] == CHAT_CHANNEL_WHISPER_SENT and GetDisplayName() or args[7], A.abcLen(textBody))
				if text:sub(1, 2) == prefix then
					args[5] = A.DecodeMessage(textBody, keyword)
				end
			end
			return orgFormatAndAddChatMessage(unpack(args))
		else
			return orgFormatAndAddChatMessage(...)
		end
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
