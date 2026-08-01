local RegisterForEvent = SocialIndicators.RegisterForEvent
local LogDebug = SocialIndicators.LogDebug
local GetGuildMemberIndexFromCharacterOrDisplayName = SocialIndicators.GetGuildMemberIndexFromCharacterOrDisplayName

local GuildRosterCollector = ZO_Object:Subclass()
SocialIndicators.GuildRosterCollector = GuildRosterCollector

function GuildRosterCollector:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function GuildRosterCollector:Initialize(database)
	self.database = database

	local function FindGuildMemberIndexAndCall(guildId, displayName, func, ...)
		local memberIndex = GetGuildMemberIndexFromCharacterOrDisplayName(guildId, displayName)
		if(memberIndex) then
			func(self, guildId, memberIndex, ...)
		end
	end

	self:DoFullUpdate()
	RegisterForEvent(EVENT_GUILD_DATA_LOADED, function() self:DoFullUpdate() end)
	RegisterForEvent(EVENT_GUILD_RANK_CHANGED, function(_, guildId) self:DoFullGuildUpdate(guildId) end)
	RegisterForEvent(EVENT_GUILD_RANKS_CHANGED, function(_, guildId) self:DoFullGuildUpdate(guildId) end)
	RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, function(_, globalGuildId, guildName) self:DoFullGuildUpdate(GetGuildId(GetNumGuilds())) end) -- assuming that the new guild always has the highest index
	-- RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, function(_, globalGuildId, guildName)  end) -- handle old ranks lazily and remove them only when they are accessed
	RegisterForEvent(EVENT_GUILD_MEMBER_ADDED, function(_, guildId, displayName) FindGuildMemberIndexAndCall(guildId, displayName, self.UpdateAllPlayerData) end)
	--RegisterForEvent(EVENT_GUILD_MEMBER_REMOVED, function(_, guildId, displayName) end) -- nothing to do here, same behaviour as EVENT_GUILD_SELF_LEFT_GUILD
	RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_UPDATED, function(_, guildId, displayName) FindGuildMemberIndexAndCall(guildId, displayName, self.UpdateAllPlayerData) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, function(_, guildId, displayName, characterName, zone) self:UpdateZone(characterName, zone) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED, function(_, guildId, displayName, characterName, level) self:UpdateLevel(characterName, level) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED, function(_, guildId, displayName, characterName, championPoints) self:UpdateChampionPoints(characterName, championPoints) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED, function(_, guildId, displayName, rankIndex) self:UpdateRankIndex(displayName, guildId, rankIndex) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_NOTE_CHANGED, function(_, guildId, displayName, note) self:UpdateNote(displayName, guildId, note) end)
	RegisterForEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_, guildId, displayName, oldStatus, newStatus) FindGuildMemberIndexAndCall(guildId, displayName, self.UpdateStatus) end)
end

function GuildRosterCollector:DoFullUpdate()
	for i = 1, GetNumGuilds() do
		self:DoFullGuildUpdate(GetGuildId(i))
	end
end

function GuildRosterCollector:DoFullGuildUpdate(guildId)
	for i = 1, GetNumGuildMembers(guildId) do
		self:UpdateAllPlayerData(guildId, i)
	end
end

function GuildRosterCollector:UpdateAllPlayerData(guildId, memberIndex)
	local db = self.database

	local displayName, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
	local player = db:GetPlayer(displayName)
	player:UpdateGuildNote(guildId, note)
	player:UpdateGuildRank(guildId, rankIndex)
	player:UpdateStatus(playerStatus, secsSinceLogoff)
	player:Save()

	local hasCharacter, characterName, zoneName, classType, alliance, level, championPoints = GetGuildMemberCharacterInfo(guildId, memberIndex)
	if(hasCharacter) then
		local character = db:GetCharacter(characterName)
		character:SetGender(GetGenderFromNameDescriptor(characterName))
		character:SetClass(classType)
		character:SetAlliance(alliance)
		character:UpdateLevel(level)
		character:UpdateZone(zoneName)
		if(not character:GetPlayer()) then
			character:SetPlayer(displayName)
		end
		character:UpdateChampionPoints(championPoints)
		character:UpdateLastSeen()
		character:Save()
	end
end

function GuildRosterCollector:UpdateZone(characterName, zoneName)
	local character = self.database:GetCharacter(characterName)
	character:UpdateZone(zoneName)
	character:UpdateLastSeen()
	character:Save()
end

function GuildRosterCollector:UpdateLevel(characterName, level)
	local character = self.database:GetCharacter(characterName)
	character:UpdateLevel(level)
	character:UpdateLastSeen()
	character:Save()
end

function GuildRosterCollector:UpdateChampionPoints(characterName, championPoints)
	local character = self.database:GetCharacter(characterName)
	character:UpdateChampionPoints(championPoints)
	character:UpdateLastSeen()
	character:Save()
end

function GuildRosterCollector:UpdateRankIndex(displayName, guildId, rankIndex)
	local player = self.database:GetPlayer(displayName)
	player:UpdateGuildRank(guildId, rankIndex)
end

function GuildRosterCollector:UpdateNote(displayName, guildId, note)
	local player = self.database:GetPlayer(displayName)
	player:UpdateGuildNote(guildId, note)
end

function GuildRosterCollector:UpdateStatus(guildId, memberIndex)
	local displayName, _, _, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
	local player = self.database:GetPlayer(displayName)
	player:UpdateStatus(playerStatus, secsSinceLogoff)
	player:Save()
end
