LootTrackerSolution.Tracking = {}

function LootTrackerSolution.Tracking.TrackLoot(itemLink)

end

function LootTrackerSolution.Tracking.Initialize()

    EVENT_MANAGER:RegisterForEvent(LootTrackerSolution.Name, EVENT_LOOT_RECEIVED, LootTrackerSolution.Tracking.OnLootReceived)
end

function LootTrackerSolution.Tracking.OnLootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, lootedBy, isPickpocketLoot, questItemIcon, itemId)

    local currentPlayerName = GetUnitName("player")

    if receivedBy ~= (currentPlayerName .. "^Fx") then
        return
    end

    local pattern = "%|H0:.+%|h"
    local match = string.match(itemLink, pattern)

    if not match then return end

    local itemQuality = GetItemLinkQuality(itemLink)
    local notifyOnLegendary = LootTrackerSolution.LootStorageModule:GetGeneralSetting("NotifyOnLegendary")
    local notifyOnNirncrux = LootTrackerSolution.LootStorageModule:GetGeneralSetting("NotifyOnNirncrux")
    local notificationSound = LootTrackerSolution.LootStorageModule:GetGeneralSetting("NotificationSound")
    local textNotify = LootTrackerSolution.LootStorageModule:GetGeneralSetting("TextNotify")
    local localization = LootTrackerSolution.Localization.translation
    local sounds = { "Console_Game_Enter", "Endeavor_Complete", "New_Notification", "Defer_Notification", "CodeRedemption_Success", "Fence_Item_Laundered", "Market_CrownsSpent", "None" }

    local function createAnnouncementParams()
        return CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sounds[notificationSound])
    end

    local announcementParams = createAnnouncementParams()

    if itemQuality == ITEM_QUALITY_LEGENDARY or (itemId == 56863) or (itemId == 56862) or (itemId == 203810) then 
        if textNotify then
            local itemIcon = GetItemLinkIcon(itemLink)

            announcementParams:SetText(string.format("%s |t30:30:%s|t %s", localization["Looted"], itemIcon, LootTrackerSolution.LogicModule.ReworkLinkUTF8Item(itemLink)))
            announcementParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
            announcementParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ABOVE_HOTBAR)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(announcementParams)
        else
            if (itemQuality == ITEM_QUALITY_LEGENDARY and notifyOnLegendary) or ((itemId == 56863 or itemId == 56862 or itemId == 203810) and notifyOnNirncrux) then
                PlaySound(sounds[notificationSound])
            end
        end
    end

    local category, subcategory = GetItemLinkFilterTypeInfo(itemLink)
    local categoriesTable = {
        [4] = {
            [13] = "Blacksmithing",
            [14] = "Clothing",
            [15] = "Woodworking",
            [24] = "Jewelry Crafting",
            [16] = "Alchemy",
            [17] = "Enchanting",
            [18] = "Provisioning",
        },
    }

    local categoryName = categoriesTable[category] and categoriesTable[category][subcategory] or "Other"

    local lastPrice = nil

    local scrollData = LootTrackerSolution.LootJournalWindow.control.ScrollList.scrollData
    if(scrollData ~= nil) then
        for _, itemData in ipairs(scrollData) do
            if(itemData.itemLink == itemLink) then
                lastPrice = itemData.lastPrice
                break
            end
        end
    end

    if lastPrice == nil then
        lastPrice = LootTrackerSolution.TradeCenter.GetPriceInfo(itemLink)
    end

    LootTrackerSolution.LootStorageModule:AddLoot(categoryName, itemLink, quantity, lastPrice)
    LootTrackerSolution.LootStorageModule:AddGold(categoryName, lastPrice, quantity)

    if not LootTrackerSolution.LootJournalWindow.control or LootTrackerSolution.LootJournalWindow.control:IsHidden() then
        return
    end

    LootTrackerSolution.LootJournalWindow.InsertNewItem({
        itemLink = itemLink,
        itemQuantity = quantity,
        itemLastPrice = lastPrice,
    })
end