--- @class (partial) AbilityIconsFramework
local AbilityIconsFramework = AbilityIconsFramework

-- Heroism Potions Configuration
AbilityIconsFramework.HEROISM_POTIONS = {
    potionItemIds = {
        [54340] = true, -- All Magicka Pots
        [54341] = true -- All Stamina Pots
    },
    potionEffects = {
        [197919] = true, -- Restore Magicka + Restore Stamina + Heroism
        [335616] = true -- Restore Stamina + Heroism
    },
    potions = {
        [3] = { name = GetString(HP_POTION_NAME_3), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_001.dds' },
        [10] = { name = GetString(HP_POTION_NAME_10), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_001.dds' },
        [20] = { name = GetString(HP_POTION_NAME_20), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_002.dds' },
        [30] = { name = GetString(HP_POTION_NAME_30), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_003.dds' },
        [40] = { name = GetString(HP_POTION_NAME_40), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_004.dds' },
        [60] = { name = GetString(HP_POTION_NAME_CP10), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [100] = { name = GetString(HP_POTION_NAME_CP50), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [150] = { name = GetString(HP_POTION_NAME_CP100), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [200] = { name = GetString(HP_POTION_NAME_CP150), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' }
    },
    isStationInteract = false,
    tooltipColor = "B066FF" -- Purple color for heroism potions
}

-- Function to initialize potion names after strings are loaded
function AbilityIconsFramework:InitializePotionNames()
    self.HEROISM_POTIONS.potions = {
        [3] = { name = GetString(HP_POTION_NAME_3), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_001.dds' },
        [10] = { name = GetString(HP_POTION_NAME_10), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_001.dds' },
        [20] = { name = GetString(HP_POTION_NAME_20), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_002.dds' },
        [30] = { name = GetString(HP_POTION_NAME_30), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_003.dds' },
        [40] = { name = GetString(HP_POTION_NAME_40), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_004.dds' },
        [60] = { name = GetString(HP_POTION_NAME_CP10), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [100] = { name = GetString(HP_POTION_NAME_CP50), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [150] = { name = GetString(HP_POTION_NAME_CP100), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' },
        [200] = { name = GetString(HP_POTION_NAME_CP150), icon = '/AbilityIconsFramework/HeroismPotions/potion_type_005.dds' }
    }
end

-- Heroism Potions Functions
function AbilityIconsFramework:GetPotionEffectFromItemLink(itemLink)
    local data = itemLink:match("|H.:item:(.-)|h.-|h")
    local result = select(21, zo_strsplit(':', data))
    return tonumber(result) or 0
end

function AbilityIconsFramework:FindPotion(itemLink)
    local combinedLevel = (GetItemLinkRequiredLevel(itemLink) + GetItemLinkRequiredChampionPoints(itemLink))
    return self.HEROISM_POTIONS.potions[combinedLevel] or nil
end

function AbilityIconsFramework:GetPotionName(itemLink)
    local potion = self:FindPotion(itemLink)
    return potion and potion.name
end

function AbilityIconsFramework:GetPotionIcon(itemLink)
    local potion = self:FindPotion(itemLink)
    return potion and potion.icon
end

function AbilityIconsFramework:ShouldReplacePotion(itemLink)
    -- Check if heroism potion icons are enabled
    if not self:GetSettings().enableHeroismPotionIcons then return false end
    
    if self.HEROISM_POTIONS.isStationInteract then return false end

    local itemId = GetItemLinkItemId(itemLink)
    if not self.HEROISM_POTIONS.potionItemIds[itemId] then return false end

    local effect = self:GetPotionEffectFromItemLink(itemLink)
    return self.HEROISM_POTIONS.potionEffects[effect] and true or false
end

-- Cache frequently used globals for better performance
local GetString = GetString
local SafeAddString = SafeAddString
local SI_TOOLTIP_ITEM_NAME = SI_TOOLTIP_ITEM_NAME

-- Create a lookup table for tooltip functions to reduce repetition
local tooltipFunctions = {
    ["SetBagItem"] = GetItemLink,
    ["SetTradeItem"] = GetTradeItemLink,
    ["SetBuybackItem"] = GetBuybackItemLink,
    ["SetStoreItem"] = GetStoreItemLink,
    ["SetAttachedMailItem"] = GetAttachedItemLink,
    ["SetLootItem"] = GetLootItemLink,
    ["SetTradingHouseItem"] = GetTradingHouseSearchResultItemLink,
    ["SetTradingHouseListing"] = GetTradingHouseListingItemLink,
}

local function ReturnItemLink(itemLink)
    return itemLink
end

local function TooltipHook(tooltipControl, method, linkFunc)
    local origMethod = tooltipControl[method]
    
    tooltipControl[method] = function(self, ...)
        local link = linkFunc(...)
        
        -- Store original tooltip name string
        local orgText = GetString(SI_TOOLTIP_ITEM_NAME)
        
        -- Only modify if it's a heroism potion (avoid unnecessary string operations)
        if AbilityIconsFramework:ShouldReplacePotion(link) then
            SafeAddString(SI_TOOLTIP_ITEM_NAME, "|cB066FF" .. orgText .. "|r", 1)
        end
        
        -- Call original method
        origMethod(self, ...)
        
        -- Only restore if we modified it (avoid unnecessary string operations)
        if AbilityIconsFramework:ShouldReplacePotion(link) then
            SafeAddString(SI_TOOLTIP_ITEM_NAME, orgText, 1)
            
            -- Replace the tooltip icon using the proper API after the original method
            local icon = AbilityIconsFramework:GetPotionIcon(link)
            if icon then
                ZO_ItemIconTooltip_OnAddGameData(self, TOOLTIP_GAME_DATA_ITEM_ICON, icon)
            end
        end
    end
end

local function InitializeTooltipHooks()
    -- Hook all tooltip functions using the lookup table
    for method, linkFunc in pairs(tooltipFunctions) do
        TooltipHook(ItemTooltip, method, linkFunc)
    end
    
    -- Hook SetLink separately since it uses a different function
    TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
    TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)
end

-- Initialize Heroism Potions Hooks
function AbilityIconsFramework:InitializeHeroismPotions()
    -- Initialize potion names first
    self:InitializePotionNames()
    
    -- Store original functions
    local ZO_GetItemName = GetItemName
    local ZO_GetItemInfo = GetItemInfo
    local ZO_GetItemLinkName = GetItemLinkName
    local ZO_GetItemLinkInfo = GetItemLinkInfo
    local ZO_GetSlotTexture = GetSlotTexture
    local ZO_GetSlotName = GetSlotName
    local ZO_GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo
    local ZO_GetTradingHouseSearchResultItemInfo = GetTradingHouseSearchResultItemInfo

    -- Hook GetItemName
    GetItemName = function(bagId, slotIndex)
        local itemLink = GetItemLink(bagId, slotIndex)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            local potionName = AbilityIconsFramework:GetPotionName(itemLink)
            if potionName then
                return "|cB066FF" .. potionName .. "|r"  -- Add purple color to heroism potions
            end
        end
        return ZO_GetItemName(bagId, slotIndex)
    end

    -- Hook GetItemInfo
    GetItemInfo = function(bagId, slotIndex)
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionNamealQuality, displayQuality = ZO_GetItemInfo(bagId, slotIndex)
        local itemLink = GetItemLink(bagId, slotIndex)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            icon = AbilityIconsFramework:GetPotionIcon(itemLink) or icon
        end
        return icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionNamealQuality, displayQuality
    end

    -- Hook GetItemLinkName
    GetItemLinkName = function(itemLink)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            return AbilityIconsFramework:GetPotionName(itemLink) or ZO_GetItemLinkName(itemLink)
        end
        return ZO_GetItemLinkName(itemLink)
    end

    -- Hook GetItemLinkInfo
    GetItemLinkInfo = function(itemLink)
        local icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId = ZO_GetItemLinkInfo(itemLink)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            icon = AbilityIconsFramework:GetPotionIcon(itemLink) or icon
        end
        return icon, sellPrice, meetsUsageRequirement, equipType, itemStyleId
    end

    -- Hook GetSlotTexture
    GetSlotTexture = function(slotIndex, hotbarCategory)
        local itemLink = GetSlotItemLink(slotIndex, hotbarCategory)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            return AbilityIconsFramework:GetPotionIcon(itemLink) or ZO_GetSlotTexture(slotIndex, hotbarCategory)
        end
        return ZO_GetSlotTexture(slotIndex, hotbarCategory)
    end

    -- Hook GetSlotName
    GetSlotName = function(slotIndex, hotbarCategory)
        local itemLink = GetSlotItemLink(slotIndex, hotbarCategory)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            local potionName = AbilityIconsFramework:GetPotionName(itemLink)
            if potionName then
                return "|cB066FF" .. potionName .. "|r"  -- Add purple color to heroism potions
            end
        end
        return ZO_GetSlotName(slotIndex, hotbarCategory)
    end

    -- Hook GetTradingHouseListingItemInfo
    GetTradingHouseListingItemInfo = function(index)
        local icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit = ZO_GetTradingHouseListingItemInfo(index)
        local itemLink = GetTradingHouseListingItemLink(index)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            local potion = AbilityIconsFramework:FindPotion(itemLink)
            if potion then
                if potion.icon then icon = potion.icon end
                if potion.name then itemName = "|cB066FF" .. potion.name .. "|r" end
            end
        end
        return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
    end

    -- Hook GetTradingHouseSearchResultItemInfo
    GetTradingHouseSearchResultItemInfo = function(index)
        local icon, name, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit = ZO_GetTradingHouseSearchResultItemInfo(index)
        local itemLink = GetTradingHouseSearchResultItemLink(index)
        if AbilityIconsFramework:ShouldReplacePotion(itemLink) then
            local potion = AbilityIconsFramework:FindPotion(itemLink)
            if potion then
                if potion.icon then icon = potion.icon end
                if potion.name then name = "|cB066FF" .. potion.name .. "|r" end
            end
        end
        return icon, name, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
    end

    -- Initialize Tooltip Hooks
    InitializeTooltipHooks()

    -- Register for crafting station events
    EVENT_MANAGER:RegisterForEvent(AbilityIconsFramework.name, EVENT_CRAFTING_STATION_INTERACT, function()
        AbilityIconsFramework.HEROISM_POTIONS.isStationInteract = true
    end)
    EVENT_MANAGER:RegisterForEvent(AbilityIconsFramework.name, EVENT_END_CRAFTING_STATION_INTERACT, function()
        AbilityIconsFramework.HEROISM_POTIONS.isStationInteract = false
    end)
end

-- Make sure this is called in your initialization
local function Initialize()
    -- ... existing initialization code ...
    InitializeTooltipHooks()
end 