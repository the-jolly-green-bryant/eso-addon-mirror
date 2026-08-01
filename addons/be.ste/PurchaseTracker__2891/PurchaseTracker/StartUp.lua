
local ADDON_NAME = "PurchaseTracker"

PurchaseTracker = {
    internal = {
        --chat = LibChatMessage(ADDON_NAME, "PuTr"),
        --gettext = LibGetText(ADDON_NAME).gettext
    },
}
--local chat = PurchaseTracker.internal.chat
--local gettext = PurchaseTracker.internal.gettext

_G[ADDON_NAME] = PurchaseTracker

function PurchaseTracker.Initialize()
    local acctDefaults = {
        ['purchases'] = {},
    }

    PurchaseTracker.savedVariables = ZO_SavedVars:NewAccountWide("PurchaseTrackerVars", 1, nil, acctDefaults, nil, 'PurchaseTracker')
    PurchaseTracker.loggedInWorldName = GetWorldName()
    PurchaseTracker.upgradeSavedVariablesVersion()
    PurchaseTracker.cleanUpHighPurchaseAmounts()
    PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetAttachedMailItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetBagItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetBuybackItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetLootItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetTradeItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetStoreItem")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseListing")
	PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetWornItem")
    PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetQuestReward")
    PurchaseTracker.OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseItem")

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_PURCHASED, function(itemData)
        local count = itemData.stackCount
        local name = itemData.name
        local itemLink = itemData.itemLink
        local seller = ZO_LinkHandler_CreateDisplayNameLink(itemData.sellerName)
        local price = ZO_Currency_FormatPlatform(CURT_MONEY, itemData.purchasePrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)    
        local guildName = itemData.guildName
        local itemQuality = GetItemLinkQuality(itemLink) 
        --local message = gettext("You have bought <<1>>x <<t:2>> ( <<6>> ) from <<3>> for <<4>> in <<5>>", count, name, seller, price, guildName, theIID)   
        --chat:Print(message)

        local itemId = GetItemLinkItemId(itemLink)
        local savedPurchase = {
            itemName = name,
            itemCount = count,
            itemPrice = itemData.purchasePrice,
            singlePrice = itemData.purchasePrice / count,
        }
        
        if PurchaseTracker.savedVariables['purchases'] == nil then
            PurchaseTracker.savedVariables['purchases'] = {}
        end
    
        if PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName] == nil then
            PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName] = {}
        end
        
    
        if PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId] == nil then
            PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId] = {}
        end
    
        if PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality] == nil then
            PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality] = {}
        end
    
        table.insert(PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality], savedPurchase)
    end)
end

function PurchaseTracker.upgradeSavedVariablesVersion()
    local upgradedTable = {}
    upgradedTable['purchases'] = {}
    local loggedInWorldName = GetWorldName()
    
    if (not (PurchaseTracker.savedVariables['purchases'] == nil)) then
        for key,value in pairs(PurchaseTracker.savedVariables['purchases']) do
            if( (not (key == "NA Megaserver")) and
                (not (key == "EU Megaserver")) ) then
                -- migrating already available data to the first logged in server
                if upgradedTable['purchases'][loggedInWorldName] == nil then
                    upgradedTable['purchases'][loggedInWorldName] = {}
                end

                -- migrating itemId (key)
                if upgradedTable['purchases'][loggedInWorldName][key] == nil then
                    upgradedTable['purchases'][loggedInWorldName][key] = {}
                end
                
                -- migrating into "unknown=0" itemLevel
                if upgradedTable['purchases'][loggedInWorldName][key][0] == nil then
                    upgradedTable['purchases'][loggedInWorldName][key][0] = {}
                end

                upgradedTable['purchases'][loggedInWorldName][key][0] = value
            else
                upgradedTable['purchases'][key] = value
            end
        end
    end
    PurchaseTracker.savedVariables['purchases'] = upgradedTable['purchases']
end

function PurchaseTracker.mergeUnregisteredQualityItemsForBetaVersionCompatibility(itemId, itemQuality)
    local itemPurchasesTable = {}
    -- compatibiliy to beta version of quality untracked items, merge them:
    if (not (PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][0] == nil)) then

        local itemsOfQualityPurchasesTableLen = 0
        if (not (PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality] == nil)) then
            itemsOfQualityPurchasesTableLen = #PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality]
        end

        -- if less than 100 registered items with registered quality purchased, 
        --  also add the from the beta version registered items without quality registered
        -- else just use the by quality registered items
        if (itemsOfQualityPurchasesTableLen < 100)  then
            for key,value in ipairs(PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][0]) do
                table.insert(itemPurchasesTable, value)
            end
            if (itemsOfQualityPurchasesTableLen > 0) then
                for key,value in ipairs(PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality]) do
                    table.insert(itemPurchasesTable, value)
                end
            end
        else
            itemPurchasesTable = PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality]
        end
    else
        itemPurchasesTable = PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality]    
    end

    return itemPurchasesTable
end

function PurchaseTracker.cleanUpHighPurchaseAmounts()
    local loggedInWorldName = GetWorldName()
    
    if ((not (PurchaseTracker.savedVariables['purchases'] == nil)) and
        (not (PurchaseTracker.savedVariables['purchases'][loggedInWorldName] == nil))) then

        for itemIdKey, itemTable in pairs(PurchaseTracker.savedVariables['purchases'][loggedInWorldName]) do
            for itemQualityKey, itemPurchasesTable in pairs(itemTable) do
                local currentItemsPurchasesTableLen = #itemPurchasesTable
                if (currentItemsPurchasesTableLen > 100) then
                    local cleanedTable = {}
                    local tableToBeCleaned = itemPurchasesTable
                    for i = currentItemsPurchasesTableLen - 99, currentItemsPurchasesTableLen, 1 
                    do
                        table.insert(cleanedTable, itemPurchasesTable[i])
                    end
                    
                    PurchaseTracker.savedVariables['purchases'][loggedInWorldName][itemIdKey][itemQualityKey] = cleanedTable               
                end
            end
        end
    end
end

function PurchaseTracker.OverWriteToolTipFunction(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		PurchaseTracker.addToolTipText(control)
	end
end

function PurchaseTracker.addToolTipText(tooltip)

    local itemLink = PurchaseTracker.getItemLinkFromToolTip(toolTip)
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink)
    if (itemName == nil or itemName == "") then
        return
    end

    tooltip:AddVerticalPadding(5)
    ZO_Tooltip_AddDivider(tooltip)
    local itemId = GetItemLinkItemId(itemLink)
    local itemQuality = GetItemLinkQuality(itemLink)

    if (PurchaseTracker.savedVariables['purchases'] == nil or
        PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName] == nil or
        PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId] == nil or 
        (PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality] == nil and
         PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][0] == nil) ) then

        tooltip:AddLine("*** No Purchases (" .. itemId .. ") ***")
        return
    end

    local itemPurchasesTable = {}
    -- compatibiliy to beta version of quality untracked items, merge them:
    if (not (PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][0] == nil)) then
        itemPurchasesTable = PurchaseTracker.mergeUnregisteredQualityItemsForBetaVersionCompatibility(itemId, itemQuality)
    else
        itemPurchasesTable = PurchaseTracker.savedVariables['purchases'][PurchaseTracker.loggedInWorldName][itemId][itemQuality]    
    end

    local currentItemsPurchasesTableLen = #itemPurchasesTable
    if (currentItemsPurchasesTableLen >= 100) then
        tooltip:AddLine("*** more than " .. currentItemsPurchasesTableLen .. " Purchases (" .. itemId .. ") ***")
    elseif (currentItemsPurchasesTableLen == 1) then
        tooltip:AddLine("*** " .. currentItemsPurchasesTableLen .. " Purchase (" .. itemId .. ") ***")
    else
        tooltip:AddLine("*** " .. currentItemsPurchasesTableLen .. " Purchases (" .. itemId .. ") ***")
    end

    if (currentItemsPurchasesTableLen > 0) then
        local lastPurchasesText = PurchaseTracker.createTextForLastPurchasesOfItem(
            itemPurchasesTable, 
            currentItemsPurchasesTableLen)
        local avgText = PurchaseTracker.createTextForAverageForLastPurchasesOfItem(
            itemPurchasesTable, 
            currentItemsPurchasesTableLen)
        tooltip:AddLine(lastPurchasesText)
        tooltip:AddLine(avgText)
    end
end

function PurchaseTracker.formatPriceForToolTip(numericPrice)
    local toOneAfterCommaRoundedPrice = tonumber(string.format("%.1f", numericPrice))
    local prettyFormatedPrice = ZO_Currency_FormatPlatform(CURT_MONEY, toOneAfterCommaRoundedPrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    return prettyFormatedPrice
end

function PurchaseTracker.calculateAverageForLastPurchasesOfItem(purchaseCountToAverage, 
    purchasesForItemTable, 
    currentItemsPurchasesTableLen, 
    lastShowAverageOffset)

    local avgText = ""
    if(currentItemsPurchasesTableLen > lastShowAverageOffset) then
        local purchasesCount = 0
        local totalPrice = 0
        local totalItemCount = 0
        local processingPurchase = {}
        for i = currentItemsPurchasesTableLen, currentItemsPurchasesTableLen - (purchaseCountToAverage-1), -1 
        do 
            if i == 0 then break end
            processingPurchase = purchasesForItemTable[i]
            purchasesCount = purchasesCount + 1
            totalPrice = totalPrice + processingPurchase['itemPrice']
            totalItemCount = totalItemCount + processingPurchase['itemCount']
        end
        local average = totalPrice / totalItemCount
        avgText = PurchaseTracker.formatPriceForToolTip(average) .. " (" .. purchasesCount .. "/" .. totalItemCount .. ")"
    end

    return avgText
end

function PurchaseTracker.createTextForLastPurchasesOfItem(purchasesForItemTable, 
    currentItemsPurchasesTableLen)

    local lastPurchasesText = "Last: "
    local processingPurchase = {}
    if (currentItemsPurchasesTableLen > 0) then
        processingPurchase = purchasesForItemTable[currentItemsPurchasesTableLen]
        lastPurchasesText = lastPurchasesText .. PurchaseTracker.formatPriceForToolTip(processingPurchase.singlePrice) .. " (" .. processingPurchase.itemCount .. ")"
    end

    if (currentItemsPurchasesTableLen > 1) then
        processingPurchase = purchasesForItemTable[currentItemsPurchasesTableLen-1]
        lastPurchasesText = lastPurchasesText .. " - " .. PurchaseTracker.formatPriceForToolTip(processingPurchase.singlePrice) .. " (" .. processingPurchase.itemCount .. ")"
    end
    
    if (currentItemsPurchasesTableLen > 2) then
        processingPurchase = purchasesForItemTable[currentItemsPurchasesTableLen-2]
        lastPurchasesText = lastPurchasesText .. " - " .. PurchaseTracker.formatPriceForToolTip(processingPurchase.singlePrice) .. " (" .. processingPurchase.itemCount .. ")"
    end

    return lastPurchasesText
end

function PurchaseTracker.createTextForAverageForLastPurchasesOfItem(purchasesForItemTable, 
    currentItemsPurchasesTableLen)

    local lastShowAverageOffset = 0
    local avgText = "Avg: "
    local lastFiveAverageText = PurchaseTracker.calculateAverageForLastPurchasesOfItem(5, 
        purchasesForItemTable, 
        currentItemsPurchasesTableLen, 
        lastShowAverageOffset)
    lastShowAverageOffset = 5
    if (not (lastFiveAverageText == "")) then
        avgText = avgText .. lastFiveAverageText
    end
    
    local lastTwentyAverageText = PurchaseTracker.calculateAverageForLastPurchasesOfItem(20, 
        purchasesForItemTable, 
        currentItemsPurchasesTableLen, 
        lastShowAverageOffset)
    lastShowAverageOffset = 20
    if (not (lastTwentyAverageText == "")) then
        avgText = avgText .. " - " .. lastTwentyAverageText
    end
    
    local lastHundredAverageText = PurchaseTracker.calculateAverageForLastPurchasesOfItem(100, 
        purchasesForItemTable, 
        currentItemsPurchasesTableLen, 
        lastShowAverageOffset)
    if (not (lastHundredAverageText == "")) then
        avgText = avgText .. " - " .. lastHundredAverageText
    end     

    return avgText
end

-- This function is copied over from the Addon MasterMerchant
function PurchaseTracker.getItemLinkFromToolTip(toolTip)
    local skMoc = moc()
    -- Make sure we don't double-add stats or try to add them to nothing
    -- Since we call this on Update rather than Show it gets called a lot
    -- even after the tip appears
    if (not skMoc or not skMoc:GetParent()) then
      return
    end
  
    local itemLink = nil
    local mocParent = skMoc:GetParent():GetName()
  
    -- Store screen
    if mocParent == 'ZO_StoreWindowListContents' then itemLink = GetStoreItemLink(skMoc.index)
    -- Store buyback screen
    elseif mocParent == 'ZO_BuyBackListContents' then itemLink = GetBuybackItemLink(skMoc.index)
    -- Guild store posted items
    elseif mocParent == 'ZO_TradingHousePostedItemsListContents' then
      local mocData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      if not mocData then return end
      itemLink = GetTradingHouseListingItemLink(mocData.slotIndex)
    -- Guild store search
    elseif mocParent == 'ZO_TradingHouseItemPaneSearchResultsContents' then
      local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      -- The only thing with 0 time remaining should be guild tabards, no
      -- stats on those!
      if not rData or rData.timeRemaining == 0 then return end
      itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
    -- Guild store item posting
    elseif mocParent == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
      if skMoc.slotIndex and skMoc.bagId then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex) end
    -- Player bags (and bank) (and crafting tables)
    elseif mocParent == 'ZO_PlayerInventoryBackpackContents' or
           mocParent == 'ZO_PlayerInventoryListContents' or
           mocParent == 'ZO_CraftBagListContents' or
           mocParent == 'ZO_QuickSlotListContents' or
           mocParent == 'ZO_PlayerBankBackpackContents' or
           mocParent == 'ZO_HouseBankBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
           mocParent == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
           mocParent == 'ZO_GuildBankBackpackContents' then
           if skMoc and skMoc.dataEntry then
              local rData = skMoc.dataEntry.data
              itemLink = GetItemLink(rData.bagId, rData.slotIndex)
           end
    -- Worn equipment
    elseif mocParent == 'ZO_Character' then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex)
    -- Loot window if autoloot is disabled
    elseif mocParent == 'ZO_LootAlphaContainerListContents' then itemLink = GetLootItemLink(skMoc.dataEntry.data.lootId)
    elseif mocParent == 'ZO_MailInboxMessageAttachments' then itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), skMoc.id, LINK_STYLE_DEFAULT)
    elseif mocParent == 'ZO_MailSendAttachments' then itemLink = GetMailQueuedAttachmentLink(skMoc.id, LINK_STYLE_DEFAULT)
    elseif mocParent == 'IIFA_GUI_ListHolder' then itemLink = moc().itemLink
    elseif mocParent == 'ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents' then
      local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      -- The only thing with 0 time remaining should be guild tabards, no
      -- stats on those!
      if not rData or rData.timeRemaining == 0 then return end
      itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
    end

    return itemLink
end

local function OnAddonLoaded()
    PurchaseTracker.Initialize()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)





