local ADDON_NAME = "CraftedPotions"
_G[ADDON_NAME] = {}

local function OnAddonLoaded(_, addon)
    if addon ~= ADDON_NAME then return end

    -- Utility functions
    local function IsCraftedPotion(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        return (itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) and (select(24, ZO_LinkHandler_ParseLink(itemLink)) ~= "0")
    end

    local function ChangeQuality(itemLink)
        local quality = ITEM_DISPLAY_QUALITY_NORMAL
        for i = 1, GetMaxTraits() do
            local hasTraitAbility = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)

            if hasTraitAbility then
                quality = quality + 1
            end
        end

        if quality == ITEM_DISPLAY_QUALITY_NORMAL then
            quality = ITEM_DISPLAY_QUALITY_MAGIC
        end

        return quality
    end

    local function ModifyAPIMethod(functionName, itemLinkFunction, qualityIndex)
        local original = _G[functionName]
        _G[ADDON_NAME][functionName] = original
        _G[functionName] = function(...)
            local itemLink = itemLinkFunction(...)
            if IsCraftedPotion(itemLink) then
                if(qualityIndex) then
                    local data = {original(...)}
                    data[qualityIndex] = ChangeQuality(itemLink)
                    return unpack(data)
                else
                    return ChangeQuality(itemLink)
                end
            end
            return original(...)
        end
    end

    local function ReturnItemLink(itemLink)
        return itemLink
    end

    -- Rewriting core functions

    -- Shared (Gamepad UI, Addons)
    ModifyAPIMethod("GetItemDisplayQuality", GetItemLink)

    -- Shared (Gamepad UI, Addons)
    ModifyAPIMethod("GetItemLinkDisplayQuality", ReturnItemLink)

    -- QuickSlots
    ModifyAPIMethod("GetSlotItemDisplayQuality", GetSlotItemLink)

    -- Bags
    local GET_ITEM_INFO_DISPLAY_QUALITY_INDEX = 9
    ModifyAPIMethod("GetItemInfo", GetItemLink, GET_ITEM_INFO_DISPLAY_QUALITY_INDEX)

    -- Trading House listings
    local GET_TRADING_HOUSE_LISTING_ITEM_INFO_DISPLAY_QUALITY_INDEX = 3
    ModifyAPIMethod("GetTradingHouseListingItemInfo", GetTradingHouseListingItemLink, GET_TRADING_HOUSE_LISTING_ITEM_INFO_DISPLAY_QUALITY_INDEX)

    -- Trading House searches
    local GET_TRADING_HOUSE_SEARCH_RESULT_ITEM_INFO_DISPLAY_QUALITY_INDEX = 3
    ModifyAPIMethod("GetTradingHouseSearchResultItemInfo", GetTradingHouseSearchResultItemLink, GET_TRADING_HOUSE_SEARCH_RESULT_ITEM_INFO_DISPLAY_QUALITY_INDEX)

    -- Stores
    local GET_STORE_ENTRY_INFO_QUALITY_INDEX = 8
    ModifyAPIMethod("GetStoreEntryInfo", GetStoreItemLink, GET_STORE_ENTRY_INFO_QUALITY_INDEX)

    -- Guild Log
    local GET_GUILD_SPECIFIC_ITEM_INFO_QUALITY_INDEX = 3
    ModifyAPIMethod("GetGuildSpecificItemInfo", GetGuildSpecificItemLink, GET_GUILD_SPECIFIC_ITEM_INFO_QUALITY_INDEX)

    -- Trade between players
    local GET_TRADE_ITEM_INFO_DISPLAY_QUALITY_INDEX = 4
    ModifyAPIMethod("GetTradeItemInfo", GetTradeItemLink, GET_TRADE_ITEM_INFO_DISPLAY_QUALITY_INDEX)

    -- Store Buyback
    local GET_BUY_BACK_ITEM_INFO_FUNCTIONAL_QUALITY_INDEX = 5 -- Game actually uses functional quality here instead of display quality
    ModifyAPIMethod("GetBuybackItemInfo", GetBuybackItemLink, GET_BUY_BACK_ITEM_INFO_FUNCTIONAL_QUALITY_INDEX)

    -- Mails
    local GET_ATTACHED_ITEM_INFO_DISPLAY_QUALITY_INDEX = 8
    ModifyAPIMethod("GetAttachedItemInfo", GetAttachedItemLink, GET_ATTACHED_ITEM_INFO_DISPLAY_QUALITY_INDEX)

    -- Loots
    local GET_LOOT_ITEM_INFO_QUALITY_INDEX = 5
    ModifyAPIMethod("GetLootItemInfo", GetLootItemLink, GET_LOOT_ITEM_INFO_QUALITY_INDEX)

    -- Gamepad Alchemy UI
    local GET_ALCHEMY_RESULTING_ITEM_INFO_QUALITY_INDEX = 8
    ModifyAPIMethod("GetAlchemyResultingItemInfo", GetAlchemyResultingItemLink, GET_ALCHEMY_RESULTING_ITEM_INFO_QUALITY_INDEX)

    -- When you learn a new trait ?
    local GET_LAST_CRAFTING_RESULT_LEARNED_TRAIT_INFO_QUALITY_INDEX = 8
    ModifyAPIMethod("GetLastCraftingResultLearnedTraitInfo", GetAlchemyResultingItemLink, GET_LAST_CRAFTING_RESULT_LEARNED_TRAIT_INFO_QUALITY_INDEX)

    -- Shared function for tooltips
    local function ModifyTooltip(itemLink)
        if IsCraftedPotion(itemLink) then
            local quality = ChangeQuality(itemLink)
            local color = GetItemQualityColor(quality)
            SafeAddString(SI_TOOLTIP_ITEM_NAME, color:Colorize(GetString(SI_TOOLTIP_ITEM_NAME)), 1)
        end
    end

    local function TooltipHook(tooltipControl, method, linkFunc)
        local origMethod = tooltipControl[method]
        tooltipControl[method] = function(self, ...)
            local orgText = GetString(SI_TOOLTIP_ITEM_NAME)
            local itemLink = linkFunc(...)
            ModifyTooltip(itemLink)
            origMethod(self, ...)
            SafeAddString(SI_TOOLTIP_ITEM_NAME, orgText, 1)
        end
    end

    -- ItemTooltip are tooltips displayed when you hover an item
    TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    TooltipHook(ItemTooltip, "SetAction", GetSlotItemLink)
    TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)

    -- Is the Tooltip at the Craft Station
    TooltipHook(ZO_AlchemyTopLevelTooltip, "SetPendingAlchemyItem", GetAlchemyResultingItemLink)

    -- Is the Tooltip when you click on a link
    TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)

    -- PotionMaker Addon Tooltip
    if PotionMakerTooltip then
        TooltipHook(PotionMakerTooltip, "SetLink", ReturnItemLink)
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
