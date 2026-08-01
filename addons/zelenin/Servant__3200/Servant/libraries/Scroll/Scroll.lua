local class = ZO_InitializingObject:Subclass()
servantScrollLibrary = class

-- scrollItemId = abilityId
servantScrollLibrary.expItems = {
    [64537] = 66776, -- Crown Experience Scroll
    [94439] = 85501, -- Gold Coast Experience Scroll
    [94440] = 85502, -- Major Crown Experience Scroll
    [94441] = 85503, -- Grand Crown Experience Scroll
    [135110] = nil, -- Crown Experience Scroll
    [138811] = nil, -- Crown Experience Scroll (2)
}

-- scrollItemId = abilityId
servantScrollLibrary.apItems = {
    [170148] = 137733, -- Alliance War Skill Line, Major
    [171262] = 147466, -- Alliance War Skill Line
    [171263] = 147467, -- Alliance War Skill Line, Grand
}

servantScrollLibrary.pelinalScroll = {
    itemId = 121550,
    itemLink = "|H1:item:121550:124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
    abilityId = 92232,
}

function class:Initialize()
    self.expAbilities = {}
    self.apAbilities = {}
    self.pelinalAbilities = {}

    self:loadAbilities()
end

function class:loadAbilities()
    self.expAbilities = {}
    self.apAbilities = {}
    self.pelinalAbilities = {}

    for itemId, _ in pairs(self.expItems) do
        local abilityId = self.expItems[itemId]
        if abilityId ~= nil then
            self.expAbilities[abilityId] = true
        end
    end

    for itemId, _ in pairs(self.apItems) do
        local abilityId = self.apItems[itemId]
        if abilityId ~= nil then
            self.apAbilities[abilityId] = true
        end
    end

    local abilityId = self.pelinalScroll.abilityId
    if abilityId ~= nil then
        self.pelinalAbilities[abilityId] = true
    end
end

function class:IsExpAbility(abilityId)
    return self.expAbilities[abilityId] == true
end

function class:IsApAbility(abilityId)
    return self.apAbilities[abilityId] == true
end

function class:IsPelinalAbility(abilityId)
    return self.pelinalAbilities[abilityId] == true
end

function class:IsExpScroll(itemId)
    return self.expItems[itemId] ~= nil
end

function class:IsApScroll(itemId)
    return self.apItems[itemId] ~= nil
end

function class:IsPelinalScroll(itemId)
    return self.pelinalScroll.itemId == itemId
end
