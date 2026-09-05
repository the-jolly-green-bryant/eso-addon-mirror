local CMA = CraftMaterialAssistant

-- Core Vendor Liquidation Routine
function CMA:OnStoreOpen()
    if not self.db.autoSellJunk then return end

    if self.db.showVendorAlerts then
        local vendoredItems = {}
        local totalGoldEarned = 0
        for i = 1, #self.junkedSlots do

            local _, stackCount = GetItemInfo(targetBag, self.junkedSlots[i])
            if stackCount > 0 then
                local itemLink = GetItemLink(targetBag, self.junkedSlots[i])
                local sellPrice = GetItemSellValueWithBonuses(targetBag, self.junkedSlots[i])
                local itemTotalGold = sellPrice * stackCount

                totalGoldEarned = totalGoldEarned + itemTotalGold
                table.insert(vendoredItems, itemLink .. " (" .. itemTotalGold .. ")")
            end
        end
        if totalGoldEarned > 0 then
            self:SendChatMessage("|cFF0000Vendored materials for" .. tostring(totalGoldEarned) "g|r")
            self:SendChatMessageLimitedItemCount("|cFFEE00Sold items:|r ", vendoredItems)
        end
    end
    SellAllJunk()
    self.junkedSlots = {}
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ITEM_GOLD_CHANGED, "Sold filtered materials.")
end