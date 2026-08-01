local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolver = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolver", self.owner.name)
    self.displayNames = {}

    _ = libUnitTrackerDisplayNameResolverBattleground:New(self)
    _ = libUnitTrackerDisplayNameResolverCharacter:New(self)
    _ = libUnitTrackerDisplayNameResolverEvent:New(self)
    _ = libUnitTrackerDisplayNameResolverFriend:New(self)
    _ = libUnitTrackerDisplayNameResolverGroup:New(self)
    _ = libUnitTrackerDisplayNameResolverGuild:New(self)
    _ = libUnitTrackerDisplayNameResolverNotification:New(self)
end

function class:AddDisplayName(characterName, displayName)
    if type(characterName) ~= "string" or type(displayName) ~= "string" then
        return
    end
    if characterName == "" or characterName == "Offline" or displayName == "" then
        return
    end

    characterName = ZO_CachedStrFormat(SI_UNIT_NAME, characterName)

    self.displayNames[characterName] = displayName
end

function class:GetDisplayName(characterName)
    if type(characterName) ~= "string" then
        return nil
    end
    if characterName == "" or characterName == "Offline" then
        return nil
    end

    characterName = ZO_CachedStrFormat(SI_UNIT_NAME, characterName)

    return self.displayNames[characterName]
end

function class:GetDisplayNames()
    return self.displayNames
end
