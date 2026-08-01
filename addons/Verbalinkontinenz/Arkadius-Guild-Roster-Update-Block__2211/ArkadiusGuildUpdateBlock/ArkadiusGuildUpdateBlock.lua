
local OnGuildMemberCharacterUpdated = GUILD_ROSTER_MANAGER.OnGuildMemberCharacterUpdated
GUILD_ROSTER_MANAGER.OnGuildMemberCharacterUpdated = function(self, displayName)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberCharacterUpdated(self, displayName) end
end

local OnGuildMemberCharacterZoneChanged = GUILD_ROSTER_MANAGER.OnGuildMemberCharacterZoneChanged
GUILD_ROSTER_MANAGER.OnGuildMemberCharacterZoneChanged = function(self, displayName, characterName, zone)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberCharacterZoneChanged(self, displayName, characterName, zone) end
end

local OnGuildMemberCharacterLevelChanged = GUILD_ROSTER_MANAGER.OnGuildMemberCharacterLevelChanged
GUILD_ROSTER_MANAGER.OnGuildMemberCharacterLevelChanged = function(self, displayName, characterName, level)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberCharacterLevelChanged(self, displayName, characterName, level) end
end

local OnGuildMemberCharacterChampionPointsChanged = GUILD_ROSTER_MANAGER.OnGuildMemberCharacterChampionPointsChanged
GUILD_ROSTER_MANAGER.OnGuildMemberCharacterChampionPointsChanged = function(self, displayName, characterName, championPoints)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberCharacterChampionPointsChanged(self, displayName, characterName, championPoints) end
end

local OnGuildMemberRankChanged = GUILD_ROSTER_MANAGER.OnGuildMemberRankChanged
GUILD_ROSTER_MANAGER.OnGuildMemberRankChanged = function(self, displayName, rankIndex)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberRankChanged(self, displayName, rankIndex) end
end

local OnGuildMemberPlayerStatusChanged = GUILD_ROSTER_MANAGER.OnGuildMemberPlayerStatusChanged
GUILD_ROSTER_MANAGER.OnGuildMemberPlayerStatusChanged = function(self, displayName, oldStatus, newStatus)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberPlayerStatusChanged(self, displayName, oldStatus, newStatus) end
end

local OnGuildMemberNoteChanged = GUILD_ROSTER_MANAGER.OnGuildMemberNoteChanged
GUILD_ROSTER_MANAGER.OnGuildMemberNoteChanged = function(self, displayName, note)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildMemberNoteChanged(self, displayName, note) end
end

local OnGuildRanksChanged = GUILD_ROSTER_MANAGER.OnGuildRanksChanged
GUILD_ROSTER_MANAGER.OnGuildRanksChanged = function(self)
    if (not ZO_GuildRoster:IsHidden()) then OnGuildRanksChanged(self) end
end

local OnUpdate = GUILD_ROSTER_MANAGER.OnUpdate
GUILD_ROSTER_MANAGER.OnUpdate = function(self, control, currentTime)
    if (not ZO_GuildRoster:IsHidden()) then OnUpdate(self, control, currentTime) end
end

