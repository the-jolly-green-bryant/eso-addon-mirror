local DP = _G["DynamicPotions"]

function DP:ShouldReplacePotion(itemLink)
    if not itemLink then
        return false
    end
    
    local itemId = GetItemLinkItemId(itemLink)
    
    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_POTION and itemType ~= ITEMTYPE_POISON then
        return false
    end
    
    local mask = self:GetEffectMaskFromLink(itemLink)
    local classification = self:Classify(mask)
    
    return classification ~= nil
end

function DP:GetCustomName(itemLink)
    local mask = self:GetEffectMaskFromLink(itemLink)
    local classification = self:Classify(mask)
    
    if not classification then
        return nil
    end
    
    local requiredLevel = GetItemLinkRequiredLevel(itemLink)
    local requiredCP = GetItemLinkRequiredChampionPoints(itemLink)
    local combinedLevel = requiredLevel + requiredCP
    
    return self:FormatPotionName(classification, combinedLevel)
end

function DP:GetCustomIcon(itemLink)
    local mask = self:GetEffectMaskFromLink(itemLink)
    local classification = self:Classify(mask)
    
    if not classification then
        return nil
    end
    
    local combinedLevel = (GetItemLinkRequiredLevel(itemLink) + GetItemLinkRequiredChampionPoints(itemLink))
    
    return self:GetIconFor(classification, combinedLevel)
end

function DP:InitializeHooks()
    local orig_GetItemName = GetItemName
    local orig_GetItemInfo = GetItemInfo
    local orig_GetItemLinkName = GetItemLinkName
    local orig_GetItemLinkInfo = GetItemLinkInfo
    local orig_GetSlotTexture = GetSlotTexture
    local orig_GetSlotName = GetSlotName
    local orig_THListing = GetTradingHouseListingItemInfo
    local orig_THSearch = GetTradingHouseSearchResultItemInfo

    GetItemName = function(bagId, slotIndex)
        local link = GetItemLink(bagId, slotIndex)
        if DP:ShouldReplacePotion(link) then
            return DP:GetCustomName(link) or orig_GetItemName(bagId, slotIndex)
        end
        return orig_GetItemName(bagId, slotIndex)
    end

    GetItemInfo = function(bagId, slotIndex)
        local icon, stack, sellPrice, meetsUsageRequirement, locked,
            equipType, itemStyleId, functionalQuality, displayQuality =
            orig_GetItemInfo(bagId, slotIndex)
            
        local link = GetItemLink(bagId, slotIndex)
        if DP:ShouldReplacePotion(link) then
            icon = DP:GetCustomIcon(link) or icon
        end
        
        return icon, stack, sellPrice, meetsUsageRequirement, locked,
               equipType, itemStyleId, functionalQuality, displayQuality
    end

    GetItemLinkName = function(itemLink)
        if DP:ShouldReplacePotion(itemLink) then
            return DP:GetCustomName(itemLink) or orig_GetItemLinkName(itemLink)
        end
        return orig_GetItemLinkName(itemLink)
    end

    GetItemLinkInfo = function(itemLink)
        local icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId = 
            orig_GetItemLinkInfo(itemLink)
            
        if DP:ShouldReplacePotion(itemLink) then
            icon = DP:GetCustomIcon(itemLink) or icon
        end
        
        return icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId
    end

    GetSlotTexture = function(slotIndex, hotbarCategory)
        local link = GetSlotItemLink(slotIndex, hotbarCategory)
        if DP:ShouldReplacePotion(link) then
            return DP:GetCustomIcon(link) or orig_GetSlotTexture(slotIndex, hotbarCategory)
        end
        return orig_GetSlotTexture(slotIndex, hotbarCategory)
    end

    GetSlotName = function(slotIndex, hotbarCategory)
        local link = GetSlotItemLink(slotIndex, hotbarCategory)
        if DP:ShouldReplacePotion(link) then
            return DP:GetCustomName(link) or orig_GetSlotName(slotIndex, hotbarCategory)
        end
        return orig_GetSlotName(slotIndex, hotbarCategory)
    end

    GetTradingHouseListingItemInfo = function(index)
        local icon, itemName, displayQuality, stackCount, sellerName,
            timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit =
            orig_THListing(index)
            
        local link = GetTradingHouseListingItemLink(index)
        if DP:ShouldReplacePotion(link) then
            itemName = DP:GetCustomName(link) or itemName
            icon = DP:GetCustomIcon(link) or icon
        end
        
        return icon, itemName, displayQuality, stackCount, sellerName,
               timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
    end

    GetTradingHouseSearchResultItemInfo = function(index)
        local icon, name, displayQuality, stackCount, sellerName,
            timeRemaining, purchasePrice, currencyType, itemUniqueId,
            purchasePricePerUnit = orig_THSearch(index)
            
        local link = GetTradingHouseSearchResultItemLink(index)
        if DP:ShouldReplacePotion(link) then
            name = DP:GetCustomName(link) or name
            icon = DP:GetCustomIcon(link) or icon
        end
        
        return icon, name, displayQuality, stackCount, sellerName,
               timeRemaining, purchasePrice, currencyType, itemUniqueId,
               purchasePricePerUnit
    end
end