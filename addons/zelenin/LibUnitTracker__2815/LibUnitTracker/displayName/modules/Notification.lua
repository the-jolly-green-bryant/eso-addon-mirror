local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverNotification = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverNotification", self.owner.name)

    self:eventHandlers()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RAID_SCORE_NOTIFICATION_ADDED, function(eventCode, notificationId)
        self:scan(notificationId)
    end)
end

function class:scan(notificationId)
    for memberIndex = 1, GetNumRaidScoreNotificationMembers(notificationId) do
        local displayName, characterName, _, _, _ = GetRaidScoreNotificationMemberInfo(notificationId, memberIndex)
        self.owner:AddDisplayName(characterName, displayName)
    end
end

function class:scanNotification(notificationId)
    for memberIndex = 1, GetNumRaidScoreNotificationMembers(notificationId) do
        local displayName, characterName, _, _, _ = GetRaidScoreNotificationMemberInfo(notificationId, memberIndex)
        self.owner:AddDisplayName(characterName, displayName)
    end
end
