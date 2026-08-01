function AD_BLOCK_PLUS.IntializeHistory()
	--local function getTableSize(T) local count = 0 for _ in pairs(T) do count = count + 1 end return count end

	local recordCount = #AD_BLOCK_PLUS.history + 1 -- getTableSize(AD_BLOCK_PLUS.history)
	if recordCount > AD_BLOCK_PLUS.maxHistory then
		local x = 0
		for i = 0, recordCount - 1, 1 do
			if i >= recordCount - AD_BLOCK_PLUS.maxHistory then
				if AD_BLOCK_PLUS.history[i] ~= nil then
					AD_BLOCK_PLUS.history[x] = AD_BLOCK_PLUS.history[i]
					AD_BLOCK_PLUS.savedVariables.history[x] = AD_BLOCK_PLUS.history[i]
					x = x + 1
				end
			end
			AD_BLOCK_PLUS.history[i] = nil
			AD_BLOCK_PLUS.savedVariables.history[i] = nil			
		end
	end

	for i = 0, AD_BLOCK_PLUS.maxHistory - 1, 1 do
		if AD_BLOCK_PLUS.history[i] ~= nil then
			AD_BLOCK_PLUS_LIST:NewEntry(AD_BLOCK_PLUS.history[i], AD_BLOCK_PLUS.historyIndex)
			AD_BLOCK_PLUS.historyIndex = AD_BLOCK_PLUS.historyIndex + 1			
		end
	end	
end

--[[ --dep unless frontier supported
function AD_BLOCK_PLUS.isKeyword(t, key, text)
	if t[key] then
		if t[key].primary and #t[key].primary > 0 then
			for _, keywordPrimary in ipairs(t[key].primary) do
				if keywordPrimary ~= "" then
					if not AD_BLOCK_PLUS.block.agressive and t[key].secondary and #t[key].secondary > 0 then
						if string.find(string.lower(text), keywordPrimary) then
							for _, keywordSecondary in ipairs(t[key].secondary) do
								if keywordSecondary ~= "" then
									if string.find(string.lower(text), keywordSecondary) then return true end
								end
							end
						end
					else
						if string.find(string.lower(text), keywordPrimary) then return true end
					end
				end
			end
		end
	end

	return false
end
]]

function AD_BLOCK_PLUS.isKeyword(t, key, text)
	function w(s, m)
		p = "w#"
		if string.find(m, p) ~= nil then
			m = m:gsub(p, "")
			return string.find(" "..string.lower(s).." ", " "..m.." ") ~= nil
		else
			return string.find(string.lower(s), m) ~= nil
		end
	end
	if t[key] then
		if t[key].primary and #t[key].primary > 0 then
			for _, keywordPrimary in ipairs(t[key].primary) do
				if keywordPrimary ~= "" then
					if key == "automated" then
						if #text == 1 and w(text, keywordPrimary) then return true end
					else
						if not AD_BLOCK_PLUS.block.agressive and t[key].secondary and #t[key].secondary > 0 then
							if w(text, keywordPrimary) then
								for _, keywordSecondary in ipairs(t[key].secondary) do
									if keywordSecondary ~= "" then
										if w(text, keywordSecondary) then return true end
									end
								end
							end
						else
							if w(text, keywordPrimary) then return true end
						end						
					end
				end
			end
		end
	end

	return false
end


function AD_BLOCK_PLUS.OnFriendPlayerStatusChanged(displayName, characterName, oldStatus, newStatus)

	local statusMessage
	local displayNameLink 			= ZO_LinkHandler_CreateDisplayNameLink(displayName)
	local characterNameLink 		= ZO_LinkHandler_CreateCharacterLink(characterName)
	local wasOnline 				= oldStatus	~= PLAYER_STATUS_OFFLINE
	local isOnline 					= newStatus ~= PLAYER_STATUS_OFFLINE

	if AD_BLOCK_PLUS.friend then

		if not wasOnline and isOnline then
			statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
		elseif wasOnline and not isOnline then
			statusMessage = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
		end		
		if statusMessage then return statusMessage end

	else

		local fromNameFull = string.format("[%s %s]", ZO_CachedStrFormat(SI_UNIT_NAME, characterName), displayName)

		if not wasOnline and isOnline then
			statusMessage = GetString(SI_AD_BLOCK_PLUS_FRIEND_ONLINE)
		elseif wasOnline and not isOnline then
			statusMessage = GetString(SI_AD_BLOCK_PLUS_FRIEND_OFFLINE)
		end

		if statusMessage then
			local newNotify = string.format("|cffffff[%s]|r |c%s[%s]|r |c%s[%s]|r", string.lower(GetString(SI_AD_BLOCK_PLUS_BLOCK)), AD_BLOCK_PLUS.chatColor[CHAT_CHANNEL_SYSTEM], AD_BLOCK_PLUS.getChatType(CHAT_CHANNEL_SYSTEM), AD_BLOCK_PLUS.chatColor.filter, GetString(SI_AD_BLOCK_PLUS_FRIEND_TYPE))
			local newHistory = string.format("|cffffff%s|r |c%s[%s]|r |c%s[%s]|r |cb7ff00%s|r |c%s%s|r", os.date("%m/%d/%Y %I:%M:%S%p"), AD_BLOCK_PLUS.chatColor[CHAT_CHANNEL_SYSTEM], AD_BLOCK_PLUS.getChatType(CHAT_CHANNEL_SYSTEM), AD_BLOCK_PLUS.chatColor.filter, GetString(SI_AD_BLOCK_PLUS_FRIEND_TYPE), fromNameFull, AD_BLOCK_PLUS.chatColor[CHAT_CHANNEL_SYSTEM], statusMessage)		
			
			AD_BLOCK_PLUS.addHistory(newHistory)
			if AD_BLOCK_PLUS.notify then AD_BLOCK_PLUS.Print(newNotify) end	
		end

	end

end

function AD_BLOCK_PLUS.ChatRouter(_, eventCategory, targetChannel, fromDisplayName, rawMessageText, _, fromAccountName)

	--if eventCategory == EVENT_FRIEND_PLAYER_STATUS_CHANGED and not AD_BLOCK_PLUS.friend then return true end
	if eventCategory ~= EVENT_CHAT_MESSAGE_CHANNEL then return end

	local function CHAT_CHANNEL_GUILD(c)
		for _, v in pairs(CHAT_CHANNEL_GUILD_ALL) do
			if v == c then return c end
		end
	end
	local function isGuildChannel(c)
		for _, v in pairs(CHAT_CHANNEL_GUILD_ALL) do
			if v == c then return true end
		end
		return false
	end	
	local function getGuildInfo(c)
		for k, v in pairs(CHAT_CHANNEL_GUILD_ALL) do
			if v == c then return GetGuildName(GetGuildId(k)) end
		end		
	end
	
	if not (
		targetChannel == CHAT_CHANNEL_SAY 		or
		targetChannel == CHAT_CHANNEL_WHISPER 	or
		targetChannel == CHAT_CHANNEL_EMOTE 	or
		targetChannel == CHAT_CHANNEL_YELL 		or
		targetChannel == CHAT_CHANNEL_PARTY 	or
		targetChannel == CHAT_CHANNEL_ZONE		or
		--targetChannel == CHAT_CHANNEL_SYSTEM	or
		targetChannel == CHAT_CHANNEL_GUILD(targetChannel)
	)
	then return end

	if not AD_BLOCK_PLUS.enable then return end
	if AD_BLOCK_PLUS.isSelfMessage(fromAccountName) then return end
	if AD_BLOCK_PLUS.isNotMonitoredChannel(targetChannel) then return end
	
	local function filterChat(filterType)
		local fromNameFull

		if not isGuildChannel(targetChannel) then
			fromNameFull = string.format("[%s %s]", ZO_CachedStrFormat(SI_UNIT_NAME, fromDisplayName), fromAccountName)
		else
			fromNameFull = string.format("[%s %s]", getGuildInfo(targetChannel), fromAccountName)
		end

		local newNotify = string.format("|cffffff[%s]|r |c%s[%s]|r |c%s[%s]|r", string.lower(GetString(SI_AD_BLOCK_PLUS_BLOCK)), AD_BLOCK_PLUS.chatColor[targetChannel], AD_BLOCK_PLUS.getChatType(targetChannel), AD_BLOCK_PLUS.chatColor.filter, AD_BLOCK_PLUS.getBlockedType(filterType))
		local newHistory = string.format("|cffffff%s|r |c%s[%s]|r |c%s[%s]|r |cb7ff00%s|r |c%s%s|r", os.date("%m/%d/%Y %I:%M:%S%p"), AD_BLOCK_PLUS.chatColor[targetChannel], AD_BLOCK_PLUS.getChatType(targetChannel), AD_BLOCK_PLUS.chatColor.filter, AD_BLOCK_PLUS.getBlockedType(filterType), fromNameFull, AD_BLOCK_PLUS.chatColor[targetChannel], rawMessageText)

		AD_BLOCK_PLUS.addHistory(newHistory)
		if AD_BLOCK_PLUS.notify then AD_BLOCK_PLUS.Print(newNotify) end	
	end

	--for filterType in pairs(AD_BLOCK_PLUS.chatStrings) do
	for filterType in AD_BLOCK_PLUS.sorted_table(AD_BLOCK_PLUS.chatStrings, false) do
		if AD_BLOCK_PLUS.block[filterType] and AD_BLOCK_PLUS.isKeyword(AD_BLOCK_PLUS.chatStrings, filterType, rawMessageText) then -- and filterType.enabled
			filterChat(filterType)
			return true
		end
	end

	if AD_BLOCK_PLUS.block.custom then
		for filterType in pairs(AD_BLOCK_PLUS.chatStringsCustom) do
			if AD_BLOCK_PLUS.isKeyword(AD_BLOCK_PLUS.chatStringsCustom, filterType, rawMessageText) then -- and filterType.enabled
				filterChat(filterType)
				return true
			end
		end
	end
end

function AD_BLOCK_PLUS.addHistory(newHistory)
	if AD_BLOCK_PLUS.historyIndex ~= AD_BLOCK_PLUS.maxHistory then
		AD_BLOCK_PLUS.history[AD_BLOCK_PLUS.historyIndex] = newHistory
		AD_BLOCK_PLUS.savedVariables.history[AD_BLOCK_PLUS.historyIndex] = newHistory

		AD_BLOCK_PLUS_LIST:NewEntry(newHistory, AD_BLOCK_PLUS.historyIndex)			
		
		AD_BLOCK_PLUS.historyIndex = AD_BLOCK_PLUS.historyIndex + 1
	else
		for i = 0, AD_BLOCK_PLUS.maxHistory-2, 1 do
			AD_BLOCK_PLUS.history[i] = AD_BLOCK_PLUS.history[i + 1]
		end
		AD_BLOCK_PLUS.history[AD_BLOCK_PLUS.maxHistory-1]	= newHistory
		AD_BLOCK_PLUS.savedVariables.history[AD_BLOCK_PLUS.maxHistory-1] = newHistory
		AD_BLOCK_PLUS_LIST:UpdateHistory()
	end

	AD_BLOCK_PLUS.blocked = AD_BLOCK_PLUS.blocked + 1
	AD_BLOCK_PLUS.savedVariables.blocked = AD_BLOCK_PLUS.blocked
	AD_BLOCK_PLUS_LIST:UpdateTotalBlocked(AD_BLOCK_PLUS.numberFormat(AD_BLOCK_PLUS.blocked))	
end
function AD_BLOCK_PLUS.isNotMonitoredChannel(targetChannel)
	for k in pairs(AD_BLOCK_PLUS.chatType) do
		if type(AD_BLOCK_PLUS.chatType[k].channel) ~= "table" then
			if AD_BLOCK_PLUS.chatType[k].channel == targetChannel then
				if AD_BLOCK_PLUS.block[k] then return false end
			end
		else
			for k2, v2 in pairs(AD_BLOCK_PLUS.chatType[k].channel) do
				if v2 == targetChannel and AD_BLOCK_PLUS.block[k] then return false end
			end			
		end
	end
	return true
end
function AD_BLOCK_PLUS.getChatType(targetChannel)
	for k, v in pairs(AD_BLOCK_PLUS.chatType) do
		if type(AD_BLOCK_PLUS.chatType[k].channel) ~= "table" then
			if AD_BLOCK_PLUS.chatType[k].channel == targetChannel then return AD_BLOCK_PLUS.chatType[k].name[AD_BLOCK_PLUS.language] end --return k
		else
			for k2, v2 in pairs(AD_BLOCK_PLUS.chatType[k].channel) do
				if v2 == targetChannel then return AD_BLOCK_PLUS.chatType[k].name[AD_BLOCK_PLUS.language] end
			end
		end
	end
	if targetChannel == CHAT_CHANNEL_SYSTEM then return "system" end

	return "unknown"
end
function AD_BLOCK_PLUS.getBlockedType(filterType)
	for k in pairs(AD_BLOCK_PLUS.chatStrings) do
		if k == filterType then return AD_BLOCK_PLUS.chatStrings[filterType].name[AD_BLOCK_PLUS.language] end --return k
	end
	return "custom"
end
function AD_BLOCK_PLUS.SetCustomWords(s, delimiter)
	s = s:gsub("%s+", "")
	if s == "" then return s end
	result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		if match ~= "" then table.insert(result, match) end
	end
	return result;
end
function AD_BLOCK_PLUS.GetCustomWords(t)
	s = ""
	if not t or #t == 0 then return s end
	for _, v in pairs(t) do
		s = s..v..";"
	end	
	return s
end
function AD_BLOCK_PLUS.sorted_table(t, o)
	local i = {}
	for k in next, t do	table.insert(i, k) end
	if not o then table.sort(i, function(a, b) return a:lower() > b:lower() end)
	else table.sort(i, function(a, b) return a:lower() < b:lower() end)
	end
	
	return function()
		local k = table.remove(i)
		if k ~= nil then return k, t[k] end
	end
end
function AD_BLOCK_PLUS.numberFormat(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then break end
	end
	return formatted
end
function AD_BLOCK_PLUS.isSelfMessage(fromAccountName) return AD_BLOCK_PLUS.playerName == fromAccountName end
function AD_BLOCK_PLUS.Print(message, ...)	df("|cb7ff00[%s]|r %s", AD_BLOCK_PLUS.name, message:format(...)) end
function AD_BLOCK_PLUS.ShowHistoryWindow() AD_BLOCK_PLUS_LIST:UpdateTotalBlocked(AD_BLOCK_PLUS.numberFormat(AD_BLOCK_PLUS.blocked)) AdBlockPlusHistory:SetHidden(false) end
function AD_BLOCK_PLUS.HideHistoryWindow() AdBlockPlusHistory:SetHidden(true) end

--function AD_BLOCK_PLUS.slashCommand() AD_BLOCK_PLUS.Print("%i %s!", AD_BLOCK_PLUS.blocked, GetString(SI_AD_BLOCK_PLUSED_TOTAL)) end
--for i = 0, 1000, 1 do AD_BLOCK_PLUS.history[i] = nil AD_BLOCK_PLUS.savedVariables.history[i] = nil end