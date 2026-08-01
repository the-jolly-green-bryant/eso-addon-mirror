local HeroismPotions = _G["HeroismPotions"]

function HeroismPotions:InitializeHooks()
    local ZO_GetItemName = GetItemName
    local ZO_GetItemInfo = GetItemInfo

    local ZO_GetItemLinkName = GetItemLinkName
    local ZO_GetItemLinkInfo = GetItemLinkInfo

    local ZO_GetSlotTexture = GetSlotTexture
    local ZO_GetSlotName = GetSlotName

    local ZO_GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo
    local ZO_GetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo

    GetItemName = function(bagId, slotIndex)
        local itemLink = GetItemLink(bagId, slotIndex)

        if self:ShouldReplacePotion(itemLink) then
            return self:GetPotionName(itemLink) or ZO_GetItemName(bagId, slotIndex)
        end
        return ZO_GetItemName(bagId, slotIndex)
    end

    GetItemInfo = function(bagId, slotIndex)
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionNamealQuality, displayQuality = ZO_GetItemInfo(bagId, slotIndex)
        local itemLink = GetItemLink(bagId, slotIndex)

        if self:ShouldReplacePotion(itemLink) then
            icon = self:GetPotionIcon(itemLink) or icon
        end
        return icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionNamealQuality, displayQuality
    end

    GetItemLinkName = function(itemLink)
        if self:ShouldReplacePotion(itemLink) then
            return self:GetPotionName(itemLink) or ZO_GetItemLinkName(itemLink)
        end
        return ZO_GetItemLinkName(itemLink)
    end

    GetItemLinkInfo = function(itemLink)
        local icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId = ZO_GetItemLinkInfo(itemLink)

        if self:ShouldReplacePotion(itemLink) then
            icon = self:GetPotionIcon(itemLink) or icon
        end
        return icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId
    end

    GetSlotTexture = function(slotIndex, hotbarCategory)
        local itemLink = GetSlotItemLink(slotIndex, hotbarCategory)

        if self:ShouldReplacePotion(itemLink) then
            return self:GetPotionIcon(itemLink) or ZO_GetSlotTexture(slotIndex, hotbarCategory)
        end
        return ZO_GetSlotTexture(slotIndex, hotbarCategory)
    end

    GetSlotName = function(slotIndex, hotbarCategory)
        local itemLink = GetSlotItemLink(slotIndex, hotbarCategory)

        if self:ShouldReplacePotion(itemLink) then
            return self:GetPotionName(itemLink) or ZO_GetSlotName(slotIndex, hotbarCategory)
        end
        return ZO_GetSlotName(slotIndex, hotbarCategory)
    end

    GetTradingHouseListingItemInfo = function(index)
        local icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit = ZO_GetTradingHouseListingItemInfo(index)
        local itemLink = GetTradingHouseListingItemLink(index)

        if self:ShouldReplacePotion(itemLink) then
            local potion = self:FindPotion(itemLink)
            if potion and potion.icon then icon = potion.icon end
            if potion and potion.name then itemName = potion.name end
        end

        return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
    end

    GetTradingHouseSearchResultItemInfo = function(index)
        local icon, name, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit = ZO_GetTradingHouseSearchResultItemInfo(index)
        local itemLink = GetTradingHouseSearchResultItemLink(index)

        if self:ShouldReplacePotion(itemLink) then
            local potion = self:FindPotion(itemLink)
            if potion and potion.icon then icon = potion.icon end
            if potion and potion.name then name = potion.name end
        end
        return icon, name, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
    end
end
