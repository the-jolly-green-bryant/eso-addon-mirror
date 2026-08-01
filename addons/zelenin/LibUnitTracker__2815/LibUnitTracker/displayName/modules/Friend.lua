local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverFriend = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverFriend", self.owner.name)

    self.scanHandler = LibHandler:Limiter(function()
        self:scan()
    end, 10 * 1000, true)

    self:eventHandlers()
    self:scan()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_FRIEND_ADDED, function(eventCode, displayName)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_FRIEND_CHARACTER_UPDATED, function(eventCode, displayName)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_FRIEND_CHARACTER_UPDATED, function(eventCode, oldDisplayName, newDisplayName)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(eventCode, displayName, characterName, oldStatus, newStatus)
        self.scanHandler:Trigger()
    end)
end

function class:scan()
    for index = 1, GetNumFriends() do
        local displayName, _, _, _ = GetFriendInfo(index)
        local hasCharacter, characterName, _, _, _, _, _, _, _ = GetFriendCharacterInfo(index)
        if hasCharacter then
            self.owner:AddDisplayName(characterName, displayName)
        end
    end
end
