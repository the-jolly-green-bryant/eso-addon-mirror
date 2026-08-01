-- Create namespace
DsRGuildPersonalAvA = {}
local DsRGuildPersonalAvA = DsRGuildPersonalAvA or {}

DsRGuildPersonalAvA.name = "DsRGuildPersonalAvA"

-------------------------------------------------------------------------------------------------------------------------------------------------
local function FilterWantedItems(itemData)
    local isSiegeOrRepair = itemData.itemType
    if isSiegeOrRepair == ITEMTYPE_AVA_REPAIR or isSiegeOrRepair == ITEMTYPE_SIEGE then
        return true
    else
        return false
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function getItemIdComparator(itemIdList, excludeJunk, skipFcoisLocked)
    return function(itemData)
        local itemId = GetItemId(itemData.bagId, itemData.slotIndex)
        for expectedItemId, _ in pairs(itemIdList) do
            if expectedItemId == itemId then return true end
        end
        return false
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function _countInventoryItem(itemId)
    local itemIdComparator = getItemIdComparator({[itemId] = true}, true)
    local itemBagCache     = SHARED_INVENTORY:GenerateFullSlotData(itemIdComparator, BAG_BACKPACK)

    local totalItemsCount = 0
    for _, data in pairs(itemBagCache) do
        totalItemsCount = totalItemsCount + data.stackCount
    end

    return totalItemsCount
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalAvA.BySiegeItems()
    if not DsRGuildPersonal.ACCconfig.AvAShoppingOnOff then
        return
    end

    local siegeItems   = DsRGuildPersonalGlobals.SiegeWeapons[GetUnitAlliance("player")]

    for key, value in ipairs(siegeItems) do
        local amountInInventory = _countInventoryItem(value.itemId)
        if value.gold and DsRGuildPersonal.GetSettings()["SiegeMaster"]["buy"..value.settingName.."Gold"] > 0 then
            toBuy             = DsRGuildPersonal.GetSettings()["SiegeMaster"]["buy"..value.settingName.."Gold"] - amountInInventory
            currency          = CURT_MONEY
        else
            toBuy             = DsRGuildPersonal.GetSettings()["SiegeMaster"]["buy"..value.settingName] - amountInInventory
            currency          = CURT_ALLIANCE_POINTS
        end

        if toBuy > 0 then  
            for i = 1, GetNumStoreItems() do
                local itemLink = GetStoreItemLink(i,LINK_STYLE_BRACKETS)
                if itemLink and itemLink ~= "" then
                    local storeItemId = GetItemLinkItemId(itemLink)
                    local _,_,_, price,_,meetsRequirementsToBuy,meetsRequirementsToUse,_,_,itemCurrency, itemCurrencyAmount = GetStoreEntryInfo(i)
                    local recalculatedAmount = 0
                
                    if storeItemId == value.itemId and (itemCurrency == currency or (currency == CURT_MONEY and price > 0)) and meetsRequirementsToBuy and meetsRequirementsToUse then
                        local max = GetStoreEntryMaxBuyable(i)

                        recalculatedAmount = toBuy
                        if max < recalculatedAmount then
                            recalculatedAmount = max
                        end
                        local currentCurrency = GetCurrencyAmount(currency, CURRENCY_LOCATION_CHARACTER)

                        if price > 0 and itemCurrencyAmount == 0 then
                            itemCurrencyAmount = price
                        end				  
    
                        if currentCurrency < itemCurrencyAmount then
                            d(zo_strformat(" |c9fb6cd[DsR-Shop]|r " .. GetString(DsRGuildPersonal_AvAShopMissing), toBuy, itemLink, DsRGuildPersonal.getFormattedCurrency(itemCurrencyAmount * toBuy, currency, true), DsRGuildPersonal.getFormattedCurrency((itemCurrencyAmount * toBuy ) - currentCurrency, currency, true)))
                            break
                        elseif currentCurrency < itemCurrencyAmount * recalculatedAmount then
                            while currentCurrency < itemCurrencyAmount * recalculatedAmount do
                                recalculatedAmount = recalculatedAmount - 1 
                            end
                        end
                        BuyStoreItem(i, recalculatedAmount)
                        d(zo_strformat(" |c9fb6cd[DsR-Shop]|r " .. GetString(DsRGuildPersonal_AvAShopBought), recalculatedAmount, itemLink, DsRGuildPersonal.getFormattedCurrency(itemCurrencyAmount * recalculatedAmount, currency, true)))
                    end
                end
            end
        end
    end
end