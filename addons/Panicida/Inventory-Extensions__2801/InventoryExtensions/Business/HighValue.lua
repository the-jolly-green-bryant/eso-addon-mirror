-- local ATTS = ArkadiusTradeTools.Modules.Sales

-- local function ATT_ZO_ScrollList_Commit_Hook(list)
--     if (ArkadiusTradeToolsSales.InventoryExtensions.inventoryLists[list]) then
--         local scrollData = ZO_ScrollList_GetDataList(list)
--         for i = 1, #scrollData do
--             local data = scrollData[i].data
--             local bagId = data.bagId
--             local slotIndex = data.slotIndex
--             local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
--             if not (data.marketValue and data.marketValueStackCount == data.stackCount and data.marketValueItemLink == itemLink) then
--                 if itemLink then
--                     local avgPrice = ArkadiusTradeToolsSales.InventoryExtensions:GetPrice(itemLink)
--                     if avgPrice > 0 then
--                         data.marketValue = math.floor(avgPrice * data.stackCount)
--                         data.marketValueStackCount = data.stackCount
--                         data.marketValueItemLink = itemLink
--                         data.ATT_PRICE = true
--                     else
--                         data.marketValue = (data.stackCount or 0) * (data.sellPrice or 0)
--                     end
--                 end
--             end
--         end
--     end

--     return false
-- end

-- function ArkadiusTradeToolsSales.InventoryExtensions:Enable(enable)
--     if (enable) then
--         ZO_PreHook("ZO_ScrollList_Commit", ATT_ZO_ScrollList_Commit_Hook)
--         self:EnableMarketValue()
--     end

--     Settings.enabled = enable
-- end