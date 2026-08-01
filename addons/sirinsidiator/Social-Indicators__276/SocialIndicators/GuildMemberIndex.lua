local RegisterForEvent = SocialIndicators.RegisterForEvent

local initialized = false
local guildMemberIndex = {}
local guildMemberIndexDirty = true

local function SetGuildMemberIndexDirty()
	guildMemberIndexDirty = true
end

local function AddEntry(name, guildId, memberIndex)
	if(not guildMemberIndex[name]) then guildMemberIndex[name] = {} end
	guildMemberIndex[name][guildId] = memberIndex
end

local function RebuildGuildMemberIndex()
	guildMemberIndex = {}
	for guildIndex = 1, MAX_GUILDS do
		local guildId = GetGuildId(guildIndex)
		for memberIndex = 1, GetNumGuildMembers(guildId) do
			local displayName = GetGuildMemberInfo(guildIndex, memberIndex)
			AddEntry(displayName, guildId, memberIndex)

			local hasCharacter, characterName = GetGuildMemberCharacterInfo(guildIndex, memberIndex)
			if(hasCharacter) then
				AddEntry(characterName:gsub("%^.*x$",""), guildId, memberIndex)
			end
		end
	end
	guildMemberIndexDirty = false
end

local function GetGuildMemberIndexFromCharacterOrDisplayName(guildId, name)
	if(not name or name == "") then return nil end
	if(guildMemberIndexDirty) then RebuildGuildMemberIndex() end
	name = name:gsub("%^.*x$","")
	if(guildMemberIndex[name]) then
		return guildMemberIndex[name][guildId]
	end
	return nil
end

local preferredGuildOrder = {} -- TODO: make this a setting
for guildIndex = 1, MAX_GUILDS do
	preferredGuildOrder[#preferredGuildOrder + 1] = GetGuildId(guildIndex)
end

local function GetPreferredGuildMemberIndexFromCharacterOrDisplayName(name)
	for i = 1, #preferredGuildOrder do
		local guildId = preferredGuildOrder[i]
		local memberIndex = GetGuildMemberIndexFromCharacterOrDisplayName(guildId, name)
		if(memberIndex) then return guildId, memberIndex end
	end
	return nil, nil
end

local function InitGuildMemberIndex()
	if(initialized) then return end

	local eventList = {
		EVENT_GUILD_DATA_LOADED,
		EVENT_GUILD_MEMBER_CHARACTER_UPDATED,
		EVENT_GUILD_MEMBER_ADDED,
		EVENT_GUILD_MEMBER_REMOVED,
		EVENT_GUILD_SELF_JOINED_GUILD,
		EVENT_GUILD_SELF_LEFT_GUILD
	}
	for _, event in ipairs(eventList) do RegisterForEvent(event, SetGuildMemberIndexDirty) end

	initialized = true
end

SocialIndicators.SetGuildMemberIndexDirty = SetGuildMemberIndexDirty
SocialIndicators.GetGuildMemberIndexFromCharacterOrDisplayName = GetGuildMemberIndexFromCharacterOrDisplayName
SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName = GetPreferredGuildMemberIndexFromCharacterOrDisplayName
SocialIndicators.InitGuildMemberIndex = InitGuildMemberIndex
