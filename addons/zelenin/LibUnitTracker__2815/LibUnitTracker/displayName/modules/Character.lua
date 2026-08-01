local class = ZO_InitializingObject:Subclass()
libUnitTrackerDisplayNameResolverCharacter = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sDisplayNameResolverCharacter", self.owner.name)
    self.displayName = GetDisplayName()

    self:eventHandlers()
    self:scan()
end

function class:eventHandlers()

end

function class:scan()
    for index = 1, GetNumCharacters() do
        local name, _, _, _, _, _, _, _ = GetCharacterInfo(index)
        self.owner:AddDisplayName(name, self.displayName)
    end
end
