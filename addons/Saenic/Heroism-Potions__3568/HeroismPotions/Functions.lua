local HeroismPotions = _G["HeroismPotions"]

function HeroismPotions:GetPotionEffectFromItemLink(itemLink)
    local data = itemLink:match("|H.:item:(.-)|h.-|h")
    local result = select(21, zo_strsplit(':', data))
    return tonumber(result) or 0
end

function HeroismPotions:FindPotion(itemLink)
    local combinedLevel = (GetItemLinkRequiredLevel(itemLink) + GetItemLinkRequiredChampionPoints(itemLink))
    return self.potions[combinedLevel] or nil
end

function HeroismPotions:GetPotionName(itemLink)
    local potion = self:FindPotion(itemLink)
    return potion and potion.name
end

function HeroismPotions:GetPotionIcon(itemLink)
    local potion = self:FindPotion(itemLink)
    return potion and potion.icon
end

function HeroismPotions:ShouldReplacePotion(itemLink)
    if self.isStationInteract then return false end

    local itemId = GetItemLinkItemId(itemLink)
    if not self.potionItemIds[itemId] then return false end

    local effect = self:GetPotionEffectFromItemLink(itemLink)
    return self.potionEffects[effect] and true or false
end

--|H1:item:54340:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:196608|h|h -- Magicka, Stamina, Heroism
--|H1:item:54340:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:197919|h|h -- Magicka
