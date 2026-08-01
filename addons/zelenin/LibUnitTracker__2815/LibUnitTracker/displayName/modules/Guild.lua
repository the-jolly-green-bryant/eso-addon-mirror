local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverGuild = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverGuild", self.owner.name)

    self.scanHandler = LibHandler:Limiter(function()
        self:scan()
    end, 60 * 1000, true)

    self:eventHandlers()
    self:scan()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_INVITE_PLAYER_SUCCESSFUL, function(eventCode, playerName, guildId)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_ADDED, function(eventCode, guildId, displayName)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_CHARACTER_UPDATED, function(eventCode, guildId, displayName)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_SELF_JOINED_GUILD, function(eventCode, guildId, displayName)
        self.scanHandler:Trigger()
    end)
end

function class:scan()
    for index = 1, GetNumGuilds() do
        local guildId = GetGuildId(index)
        local numMembers, _, _, _ = GetGuildInfo(guildId)
        for memberIndex = 1, numMembers do
            local displayName, _, _, _, _ = GetGuildMemberInfo(guildId, memberIndex)
            local hasCharacter, characterName, _, _, _, _, _, _, _ = GetGuildMemberCharacterInfo(guildId, memberIndex)
            if hasCharacter then
                self.owner:AddDisplayName(characterName, displayName)
            end
        end
    end
end
