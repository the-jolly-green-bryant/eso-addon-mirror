local class = ZO_InitializingObject:Subclass()
servantScrollCollectible = class

-- collectibleId = abilityId
servantScrollCollectible.items = {
    --[479] = 96118, -- Witchmother's Whistle
    --[1167] = 91369, -- The Pie of Misrule
    [1168] = 91449, -- Breda's Bottomless Mead Mug
    [11089] = 181478, -- Jubilee Cake 2023
}

function class:Initialize()
    self.abilities = {}

    self:loadAbilities()
end

function class:loadAbilities()
    self.abilities = {}

    for collectibleId, _ in pairs(self.items) do
        local abilityId = self.items[collectibleId]
        if abilityId ~= nil then
            self.abilities[abilityId] = true
        end
    end
end

function class:IsCollectibleAbility(abilityId)
    return self.abilities[abilityId] == true
end

function class:IsCollectible(collectibleId)
    return self.items[collectibleId] ~= nil
end
