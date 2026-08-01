local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverGroup = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverGroup", self.owner.name)

    self.scanHandler = LibHandler:Limiter(function()
        self:scan()
    end, 50, true)

    self:eventHandlers()
    self:scan()
end

function class:eventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function(eventCode)
        self.scanHandler:Trigger()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_CHARACTER_NAME_CHANGED, function(eventCode, unitTag)
        if self:isGroupUnitTag(unitTag) then
            self.scanHandler:Trigger()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_CREATED, function(eventCode, unitTag)
        if self:isGroupUnitTag(unitTag) then
            self.scanHandler:Trigger()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_INVITE_RECEIVED, function(eventCode, inviterCharacterName, inviterDisplayName)
        self.owner:AddDisplayName(inviterCharacterName, inviterDisplayName)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_INVITE_RESPONSE, function(eventCode, inviterName, response, inviterDisplayName)
        self.owner:AddDisplayName(inviterName, inviterDisplayName)
    end)
end

function class:scan()
    for index = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(index)
        if DoesUnitExist(unitTag) then
            local characterName = GetRawUnitName(unitTag)
            local displayName = GetUnitDisplayName(unitTag)
            self.owner:AddDisplayName(characterName, displayName)
        end
    end
end

function class:isGroupUnitTag(unitTag)
    local start, _ = unitTag:find("^group%d+$")

    return start == 1
end
