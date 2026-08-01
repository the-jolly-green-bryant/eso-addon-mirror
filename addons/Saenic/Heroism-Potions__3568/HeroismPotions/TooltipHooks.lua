local HeroismPotions = _G["HeroismPotions"]

function HeroismPotions:InitializeTooltipHooks()

    local function HookTooltipFunction(tooltipControl, functionName, linkFunction)
        local originalFunction = tooltipControl[functionName]

        tooltipControl[functionName] = function(self, ...)
            local itemLink = linkFunction(...)

            originalFunction(self, ...)

            if HeroismPotions:ShouldReplacePotion(itemLink) then
                local icon = HeroismPotions:GetPotionIcon(itemLink)
                ZO_ItemIconTooltip_OnAddGameData(tooltipControl, TOOLTIP_GAME_DATA_ITEM_ICON, icon)
            end
        end
    end

    local function ReturnItemLink(itemLink)
        return itemLink
    end

    HookTooltipFunction(PopupTooltip, "SetLink", ReturnItemLink)
    HookTooltipFunction(ItemTooltip, "SetLink", ReturnItemLink)

    HookTooltipFunction(ItemTooltip, "SetBagItem", GetItemLink)
    HookTooltipFunction(ItemTooltip, "SetBagItem", GetItemLink)
    HookTooltipFunction(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    HookTooltipFunction(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    HookTooltipFunction(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    HookTooltipFunction(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    HookTooltipFunction(ItemTooltip, "SetLootItem", GetLootItemLink)
    HookTooltipFunction(ItemTooltip, "SetReward", GetItemRewardItemLink)
    HookTooltipFunction(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
    HookTooltipFunction(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    HookTooltipFunction(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
end
