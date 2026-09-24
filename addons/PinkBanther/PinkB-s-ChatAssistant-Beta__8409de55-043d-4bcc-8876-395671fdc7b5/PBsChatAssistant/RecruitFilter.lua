-- Guild recruitment chat filter, following PB's ChatFilter's proven formatter-wrapper pattern.
-- A Guild Finder advert contains a real guild link. Matching that markup is language-independent
-- and leaves ordinary conversation (and every non-guild link) alone.
if not PBS_CHAT_ASSISTANT then
	return
end

local addon = PBS_CHAT_ASSISTANT

local GUILD_LINK_PATTERN = "|H%d+:"
	.. ((type(GUILD_LINK_TYPE) == "string" and GUILD_LINK_TYPE) or "guild") .. ":"

local GUILD_CHANNELS = {}
local WHISPER_CHANNELS = {}

local function AddChannel(target, channel)
	if type(channel) == "number" then
		target[channel] = true
	end
end

AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_GUILD_1)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_GUILD_2)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_GUILD_3)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_GUILD_4)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_GUILD_5)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_OFFICER_1)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_OFFICER_2)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_OFFICER_3)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_OFFICER_4)
AddChannel(GUILD_CHANNELS, CHAT_CHANNEL_OFFICER_5)
AddChannel(WHISPER_CHANNELS, CHAT_CHANNEL_WHISPER)
AddChannel(WHISPER_CHANNELS, CHAT_CHANNEL_WHISPER_SENT)

local function ContainsGuildLink(text)
	return type(text) == "string" and text:find(GUILD_LINK_PATTERN) ~= nil
end

local function SamePlayerName(a, b)
	if type(a) ~= "string" or type(b) ~= "string" or a == "" or b == "" then
		return false
	end
	return a == b or a:gsub("^@", "") == b:gsub("^@", "")
end

local function IsFromPlayer(fromName, fromDisplayName)
	local displayName = type(GetDisplayName) == "function" and GetDisplayName() or nil
	if SamePlayerName(fromDisplayName, displayName) or SamePlayerName(fromName, displayName) then
		return true
	end
	local characterName = type(GetUnitName) == "function" and GetUnitName("player") or nil
	return SamePlayerName(fromName, characterName)
end

addon.ContainsGuildRecruitmentLink = ContainsGuildLink

function addon:ShouldShowRecruitment(channel, fromName, text, fromDisplayName)
	if not self.sv or not self.sv.enabled or not self.sv.recruitFilterEnabled then
		return true
	end
	-- A guild link inside a guild's own channel is conversation, not an advert to filter.
	if GUILD_CHANNELS[channel] or not ContainsGuildLink(text) then
		return true
	end
	-- Direct messages are kept unless the player explicitly opts into filtering them.
	if WHISPER_CHANNELS[channel] and not self.sv.recruitFilterWhispers then
		return true
	end
	-- Never make a message the player just sent appear to have failed.
	if IsFromPlayer(fromName, fromDisplayName) then
		return true
	end

	self.hiddenRecruitment = (self.hiddenRecruitment or 0) + 1
	return false
end

function addon:InstallRecruitmentFilter()
	if self.recruitmentFilterInstalled then
		return true
	end
	if type(CHAT_ROUTER) ~= "table"
		or type(CHAT_ROUTER.RegisterMessageFormatter) ~= "function"
		or type(CHAT_ROUTER.GetRegisteredMessageFormatters) ~= "function" then
		return false
	end

	local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
	local original = type(formatters) == "table" and formatters[EVENT_CHAT_MESSAGE_CHANNEL]
	if type(original) ~= "function" then
		return false
	end

	CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL,
		function(channel, fromName, text, isCustomerService, fromDisplayName, ...)
			if not self:ShouldShowRecruitment(channel, fromName, text, fromDisplayName) then
				return nil
			end
			return original(channel, fromName, text, isCustomerService, fromDisplayName, ...)
		end)

	self.recruitmentFilterInstalled = true
	return true
end
