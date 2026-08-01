function NWT.ScanBag(bagId, itemList)
    local totalValue = 0
    local slots = GetBagSize(bagId)
    for slotIndex = 0, slots - 1 do
        local itemLink = GetItemLink(bagId, slotIndex)
        if itemLink and itemLink ~= "" then
            local stackCount = GetSlotStackSize(bagId, slotIndex)
            if stackCount and stackCount > 0 then
                local price = NWT.GetPrice(itemLink)
                if price and price > 0 then
                    local itemValue = price * stackCount
                    totalValue = totalValue + itemValue
                    if itemList then
                        local name = GetItemLinkName(itemLink)
                        if name then
                            table.insert(itemList, {name = name, count = stackCount, value = itemValue})
                        end
                    end
                end
            end
        end
    end
    return totalValue
end

function NWT.ScanCraftBag(itemList)
    local totalValue = 0
    local slotIndex = GetNextVirtualBagSlotId(nil)
    while slotIndex do
        local itemLink = GetItemLink(BAG_VIRTUAL, slotIndex)
        if itemLink and itemLink ~= "" then
            local stackCount = GetSlotStackSize(BAG_VIRTUAL, slotIndex)
            if stackCount and stackCount > 0 then
                local price = NWT.GetPrice(itemLink)
                if price and price > 0 then
                    local itemValue = price * stackCount
                    totalValue = totalValue + itemValue
                    if itemList then
                        local name = GetItemLinkName(itemLink)
                        if name then
                            table.insert(itemList, {name = name, count = stackCount, value = itemValue})
                        end
                    end
                end
            end
        end
        slotIndex = GetNextVirtualBagSlotId(slotIndex)
    end
    return totalValue
end

-- Crown/WV price lookup helpers (global so Housing.lua can use them)
function NWT.GetCrownPriceForItem(itemId, itemName)
    if ATCrownPriceData then
        if ATCrownPriceData.byId and itemId then
            local data = ATCrownPriceData.byId[itemId]
            if data then return data.price end
        end
        if ATCrownPriceData.byName and itemName then
            local price = ATCrownPriceData.byName[itemName]
            if price then return price end
        end
    end
    return nil
end

function NWT.GetWritVoucherCostForItem(itemId)
    if ATWritVoucherData and ATWritVoucherData.byId and itemId then
        local data = ATWritVoucherData.byId[itemId]
        if data then return data.cost end
    end
    return nil
end

-- Local aliases for use within this file
local GetCrownPriceForItem = NWT.GetCrownPriceForItem
local GetWritVoucherCostForItem = NWT.GetWritVoucherCostForItem

function NWT.ScanFurnitureVault(itemList)
    local totalValue = 0
    local crownStoreCount = 0
    local crownCrateCount = 0
    local totalCrownValue = 0
    local totalWritVouchers = 0
    local slotId = GetNextFurnitureVaultSlotId(nil)
    while slotId do
        local icon, stackCount = GetItemInfo(BAG_FURNITURE_VAULT, slotId)
        if icon then
            local itemLink = GetItemLink(BAG_FURNITURE_VAULT, slotId, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" then
                local count = stackCount or 1
                local isCrownStore = IsItemFromCrownStore(BAG_FURNITURE_VAULT, slotId)
                local isCrownCrate = IsItemFromCrownCrate(BAG_FURNITURE_VAULT, slotId)
                if isCrownStore then
                    crownStoreCount = crownStoreCount + count
                elseif isCrownCrate then
                    crownCrateCount = crownCrateCount + count
                end
                
                -- Calculate crown value
                local itemId = GetItemLinkItemId(itemLink)
                local itemName = GetItemLinkName(itemLink)
                local crownPrice = GetCrownPriceForItem(itemId, itemName)
                if crownPrice then
                    totalCrownValue = totalCrownValue + (crownPrice * count)
                end
                
                -- Calculate writ voucher cost
                local wvCost = GetWritVoucherCostForItem(itemId)
                if wvCost then
                    totalWritVouchers = totalWritVouchers + (wvCost * count)
                end
                
                local price = NWT.GetPrice(itemLink)
                if price and price > 0 then
                    local itemValue = price * count
                    totalValue = totalValue + itemValue
                    if itemList then
                        local name = GetItemLinkName(itemLink)
                        if name then
                            table.insert(itemList, {name = name, count = count, value = itemValue})
                        end
                    end
                end
            end
        end
        slotId = GetNextFurnitureVaultSlotId(slotId)
    end
    
    -- Cache for search if scanning from furniture vault
    if not itemList then
        local searchItems = {}
        local searchCount = 0
        local sId = GetNextFurnitureVaultSlotId(nil)
        while sId do
            local itemName = GetItemName(BAG_FURNITURE_VAULT, sId)
            if itemName and itemName ~= "" then
                searchCount = searchCount + 1
                searchItems[searchCount] = itemName
            end
            sId = GetNextFurnitureVaultSlotId(sId)
        end
        NWT.savedVars.furnitureVaultCache = {
            items = searchItems,
            lastScanned = GetTimeStamp()
        }
    end
    
    return totalValue, crownStoreCount, crownCrateCount, totalCrownValue, totalWritVouchers
end

function NWT.ScanCurrentHouse(itemList)
    local totalValue = 0
    local houseName = ""
    local totalCrownValue = 0
    local totalWritVouchers = 0
    local itemCount = 0
    local houseId = GetCurrentZoneHouseId()
    if not houseId or houseId == 0 then return 0, "", 0, 0, 0 end
    
    local collectibleId = GetCollectibleIdForHouse(houseId)
    if collectibleId then
        houseName = GetCollectibleName(collectibleId) or ""
    end
    
    local furnitureId = GetNextPlacedHousingFurnitureId(nil)
    while furnitureId do
        itemCount = itemCount + 1
        local itemLink, collectibleLink = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_DEFAULT)
        
        -- Handle item-based furniture
        if itemLink and itemLink ~= "" then
            local itemId = GetItemLinkItemId(itemLink)
            local itemName = GetItemLinkName(itemLink)
            
            -- Calculate crown value
            local crownPrice = GetCrownPriceForItem(itemId, itemName)
            if crownPrice then
                totalCrownValue = totalCrownValue + crownPrice
            end
            
            -- Calculate writ voucher cost
            local wvCost = GetWritVoucherCostForItem(itemId)
            if wvCost then
                totalWritVouchers = totalWritVouchers + wvCost
            end
            
            local price = NWT.GetPrice(itemLink)
            if price and price > 0 then
                totalValue = totalValue + price
                if itemList then
                    if itemName then
                        table.insert(itemList, {name = itemName, count = 1, value = price})
                    end
                end
            end
        end
        
        -- Handle collectible-based furniture (crown store statues, etc.)
        if collectibleLink and collectibleLink ~= "" then
            local collectibleId = GetCollectibleIdFromLink(collectibleLink)
            if collectibleId then
                local collectibleName = GetCollectibleName(collectibleId)
                local furnitureDataId = GetCollectibleFurnitureDataId(collectibleId)
                
                -- Try to get crown price by collectible name or furniture data ID
                local crownPrice = GetCrownPriceForItem(furnitureDataId, collectibleName)
                if crownPrice then
                    totalCrownValue = totalCrownValue + crownPrice
                end
                
                -- Check for writ voucher cost
                local wvCost = GetWritVoucherCostForItem(furnitureDataId)
                if wvCost then
                    totalWritVouchers = totalWritVouchers + wvCost
                end
            end
        end
        
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
    end
    return totalValue, houseName, totalCrownValue, totalWritVouchers, itemCount
end

-- Scan housing storage boxes (BAG_HOUSE_BANK_ONE through TEN)
function NWT.ScanHousingStorage()
    local totalValue = 0
    local totalCrownValue = 0
    local totalWritVouchers = 0
    
    local houseBags = {
        BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TWO, BAG_HOUSE_BANK_THREE, BAG_HOUSE_BANK_FOUR,
        BAG_HOUSE_BANK_FIVE, BAG_HOUSE_BANK_SIX, BAG_HOUSE_BANK_SEVEN, BAG_HOUSE_BANK_EIGHT,
        BAG_HOUSE_BANK_NINE, BAG_HOUSE_BANK_TEN
    }
    
    for _, bagId in ipairs(houseBags) do
        local slots = GetBagSize(bagId)
        if slots and slots > 0 then
            for slotIndex = 0, slots - 1 do
                local itemLink = GetItemLink(bagId, slotIndex)
                if itemLink and itemLink ~= "" then
                    local stackCount = GetSlotStackSize(bagId, slotIndex) or 1
                    local itemId = GetItemLinkItemId(itemLink)
                    local itemName = GetItemLinkName(itemLink)
                    
                    -- Calculate crown value
                    local crownPrice = GetCrownPriceForItem(itemId, itemName)
                    if crownPrice then
                        totalCrownValue = totalCrownValue + (crownPrice * stackCount)
                    end
                    
                    -- Calculate writ voucher cost
                    local wvCost = GetWritVoucherCostForItem(itemId)
                    if wvCost then
                        totalWritVouchers = totalWritVouchers + (wvCost * stackCount)
                    end
                    
                    -- Calculate gold value (include bound items in value)
                    local price = NWT.GetPrice(itemLink)
                    if price and price > 0 then
                        totalValue = totalValue + (price * stackCount)
                    end
                end
            end
        end
    end
    return totalValue, totalCrownValue, totalWritVouchers
end

function NWT.ScanGuildBank(itemList)
    local totalValue = 0
    if not IsGuildBankOpen() then return 0 end
    
    local slotId = GetNextGuildBankSlotId(nil)
    while slotId do
        local itemLink = GetItemLink(BAG_GUILDBANK, slotId, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local stackCount = GetSlotStackSize(BAG_GUILDBANK, slotId)
            if stackCount and stackCount > 0 then
                local price = NWT.GetPrice(itemLink)
                if price and price > 0 then
                    local itemValue = price * stackCount
                    totalValue = totalValue + itemValue
                    if itemList then
                        local name = GetItemLinkName(itemLink)
                        if name then
                            table.insert(itemList, {name = name, count = stackCount, value = itemValue})
                        end
                    end
                end
            end
        end
        slotId = GetNextGuildBankSlotId(slotId)
    end
    return totalValue
end

function NWT.CalculateNetWorth()
    NWT.topItems = {}
    local allItems = {}
    local nw = NWT.netWorth
    
    nw.inventory = NWT.ScanBag(BAG_BACKPACK, allItems)
    nw.bank = 0
    nw.craftBag = 0
    nw.furnitureVault = 0
    
    if NWT.savedVars and NWT.savedVars.includeBank then
        nw.bank = NWT.ScanBag(BAG_BANK, allItems) + NWT.ScanBag(BAG_SUBSCRIBER_BANK, allItems)
    end
    
    if NWT.savedVars and NWT.savedVars.includeCraftBag then
        nw.craftBag = NWT.ScanCraftBag(allItems)
    end
    
    nw.furnitureCrownValue = 0
    nw.furnitureWritVouchers = 0
    nw.writVouchersAsGold = 0
    
    if NWT.savedVars and NWT.savedVars.includeFurnitureVault then
        local scannedValue, crownStore, crownCrate, crownValue, wvValue = NWT.ScanFurnitureVault(allItems)
        if scannedValue > 0 or crownValue > 0 or wvValue > 0 then
            nw.furnitureVault = scannedValue
            nw.crownStoreItems = crownStore
            nw.crownCrateItems = crownCrate
            nw.furnitureCrownValue = crownValue or 0
            nw.furnitureWritVouchers = wvValue or 0
            NWT.savedVars.lastFurnitureVaultValue = scannedValue
            NWT.savedVars.lastFurnitureCrownValue = crownValue or 0
            NWT.savedVars.lastFurnitureWritVouchers = wvValue or 0
        else
            nw.furnitureVault = NWT.savedVars.lastFurnitureVaultValue or 0
            nw.furnitureCrownValue = NWT.savedVars.lastFurnitureCrownValue or 0
            nw.furnitureWritVouchers = NWT.savedVars.lastFurnitureWritVouchers or 0
        end
        
    end
    
    nw.myHousing = 0
    nw.visitingHouse = 0
    nw.housingCrownValue = 0
    nw.housingWritVouchers = 0
    local houseId = GetCurrentZoneHouseId()
    local inHouse = houseId and houseId > 0
    local isOwner = inHouse and IsOwnerOfCurrentHouse()
    
    if not NWT.savedVars.myHousingValues then NWT.savedVars.myHousingValues = {} end
    if not NWT.savedVars.myHousingCrownValues then NWT.savedVars.myHousingCrownValues = {} end
    if not NWT.savedVars.myHousingWVValues then NWT.savedVars.myHousingWVValues = {} end
    
    if inHouse then
        -- Only add items to allItems (for top 10 list) if we own the house
        local itemListForTop10 = isOwner and allItems or nil
        local scannedValue, houseName, houseCrowns, houseWV, houseItemCount = NWT.ScanCurrentHouse(itemListForTop10)
        nw.visitingHouse = scannedValue
        nw.visitingHouseCrowns = houseCrowns or 0
        nw.visitingHouseWV = houseWV or 0
        nw.visitingHouseName = houseName or ""
        nw.visitingHouseItemCount = houseItemCount or 0
        -- Calculate combined value with crown/writ converted to gold
        local wvToGold = NWT.savedVars.writVoucherToGoldRate or 1000
        local crownToGold = NWT.savedVars.crownToGoldRate or 100
        nw.visitingHouseWithCrowns = scannedValue + ((houseCrowns or 0) * crownToGold) + ((houseWV or 0) * wvToGold)
        if isOwner then
            if scannedValue > 0 then NWT.savedVars.myHousingValues[houseId] = scannedValue end
            if houseCrowns > 0 then NWT.savedVars.myHousingCrownValues[houseId] = houseCrowns end
            if houseWV > 0 then NWT.savedVars.myHousingWVValues[houseId] = houseWV end
        end
    end
    
    if NWT.savedVars.includeMyHousing then
        if NWT.savedVars.myHousingValues then
            for _, value in pairs(NWT.savedVars.myHousingValues) do
                nw.myHousing = nw.myHousing + (value or 0)
            end
        end
        if NWT.savedVars.myHousingCrownValues then
            for _, value in pairs(NWT.savedVars.myHousingCrownValues) do
                nw.housingCrownValue = nw.housingCrownValue + (value or 0)
            end
        end
        if NWT.savedVars.myHousingWVValues then
            for _, value in pairs(NWT.savedVars.myHousingWVValues) do
                nw.housingWritVouchers = nw.housingWritVouchers + (value or 0)
            end
        end
    end
    
    -- Scan housing storage boxes
    nw.housingStorage = 0
    nw.housingStorageCrowns = 0
    nw.housingStorageWV = 0
    if inHouse and isOwner then
        local storageValue, storageCrowns, storageWV = NWT.ScanHousingStorage()
        nw.housingStorage = storageValue
        nw.housingStorageCrowns = storageCrowns
        nw.housingStorageWV = storageWV
        NWT.savedVars.lastHousingStorageValue = storageValue
        NWT.savedVars.lastHousingStorageCrowns = storageCrowns
        NWT.savedVars.lastHousingStorageWV = storageWV
    else
        nw.housingStorage = NWT.savedVars.lastHousingStorageValue or 0
        nw.housingStorageCrowns = NWT.savedVars.lastHousingStorageCrowns or 0
        nw.housingStorageWV = NWT.savedVars.lastHousingStorageWV or 0
    end
    
    nw.guildBanks = 0
    if NWT.savedVars.guildBankValues and NWT.savedVars.enabledGuildBanks then
        for gId, value in pairs(NWT.savedVars.guildBankValues) do
            if NWT.savedVars.enabledGuildBanks[gId] then
                nw.guildBanks = nw.guildBanks + (value or 0)
            end
        end
    end
    
    nw.gold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    nw.crowns = GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)
    nw.crownGems = GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)
    if NWT.savedVars.includeBank then
        nw.gold = nw.gold + GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    end
    
    nw.crownsAsGold = 0
    if NWT.savedVars.includeCrownsAsGold and NWT.savedVars.crownToGoldRate > 0 then
        nw.crownsAsGold = nw.crowns * NWT.savedVars.crownToGoldRate
    end
    
    -- Calculate total writ vouchers and crown values from all sources (for display only)
    nw.totalWritVouchers = (nw.furnitureWritVouchers or 0) + (nw.housingWritVouchers or 0) + (nw.housingStorageWV or 0)
    nw.totalCrownValue = (nw.furnitureCrownValue or 0) + (nw.housingCrownValue or 0) + (nw.housingStorageCrowns or 0)
    
    -- Convert rates for adding crown/writ values to their respective locations
    local wvToGold = NWT.savedVars.writVoucherToGoldRate or 1000
    local crownToGold = NWT.savedVars.crownToGoldRate or 100
    
    -- Add crown/writ gold values to their respective location breakdowns
    -- Vault: add crown and writ value from vault items
    local vaultCrownGold = (nw.furnitureCrownValue or 0) * crownToGold
    local vaultWVGold = (nw.furnitureWritVouchers or 0) * wvToGold
    nw.furnitureVaultWithCrowns = nw.furnitureVault + vaultCrownGold + vaultWVGold
    
    -- Housing: add crown and writ value from placed items
    local housingCrownGold = (nw.housingCrownValue or 0) * crownToGold
    local housingWVGold = (nw.housingWritVouchers or 0) * wvToGold
    nw.myHousingWithCrowns = nw.myHousing + housingCrownGold + housingWVGold
    
    -- Housing Storage: add crown and writ value from storage items
    local storageCrownGold = (nw.housingStorageCrowns or 0) * crownToGold
    local storageWVGold = (nw.housingStorageWV or 0) * wvToGold
    nw.housingStorageWithCrowns = nw.housingStorage + storageCrownGold + storageWVGold
    
    -- Store totals for informational display (NOT added to total - already in breakdowns)
    nw.writVouchersAsGold = nw.totalWritVouchers * wvToGold
    nw.crownFurnitureAsGold = nw.totalCrownValue * crownToGold
    
    -- Total uses the "WithCrowns" values to include crown/writ in their locations
    -- crownsAsGold is crown CURRENCY, not crown items
    nw.total = nw.gold + nw.inventory + nw.bank + nw.craftBag + nw.furnitureVaultWithCrowns + nw.myHousingWithCrowns + nw.housingStorageWithCrowns + nw.guildBanks + nw.crownsAsGold
    
    if NWT.savedVars.savedTopItems then
        for _, savedItem in ipairs(NWT.savedVars.savedTopItems) do
            local found = false
            for _, item in ipairs(allItems) do
                if item.name == savedItem.name then found = true break end
            end
            if not found and savedItem.name and savedItem.value then
                table.insert(allItems, savedItem)
            end
        end
    end
    
    table.sort(allItems, function(a, b) return a.value > b.value end)
    NWT.savedVars.savedTopItems = {}
    for i = 1, 10 do
        if allItems[i] then
            NWT.topItems[i] = allItems[i]
            if i <= 5 then
                NWT.savedVars.savedTopItems[i] = {
                    name = allItems[i].name,
                    count = allItems[i].count,
                    value = allItems[i].value
                }
            end
        end
    end
end

function NWT.ShowNetWorthInChat()
    NWT.CalculateNetWorth()
    local nw = NWT.netWorth
    local format = NWT.FormatGold
    
NWT.Debug("|c00FF00========== NET WORTH ==========|r")
NWT.Debug("|cFFD700TOTAL:|r " .. format(nw.total) .. "g")
NWT.Debug("|c888888------------------------------|r")
NWT.Debug("|cFFFFAAGold:|r " .. format(nw.gold) .. "g")
NWT.Debug("|cFFFFAAInventory:|r " .. format(nw.inventory) .. "g")
    
    if NWT.savedVars.includeBank then NWT.Debug("|cFFFFAABank:|r " .. format(nw.bank) .. "g") end
    if NWT.savedVars.includeCraftBag then NWT.Debug("|cFFFFAACraft Bag:|r " .. format(nw.craftBag) .. "g") end
    if NWT.savedVars.includeFurnitureVault then
        local vaultSlot = GetNextFurnitureVaultSlotId(nil)
        local suffix = (nw.furnitureVault > 0 and not vaultSlot) and " (saved)" or ""
NWT.Debug("|cFFFFAAFurniture Vault:|r " .. format(nw.furnitureVault) .. "g" .. suffix)
    end
    if NWT.savedVars.includeMyHousing and nw.myHousing > 0 then
        local hId = GetCurrentZoneHouseId()
        local isOwner = hId > 0 and IsOwnerOfCurrentHouse()
        local suffix = (hId == 0 or not isOwner) and " (saved)" or ""
NWT.Debug("|cFFFFAAMy Housing:|r " .. format(nw.myHousing) .. "g" .. suffix)
    end
    if nw.visitingHouse > 0 then NWT.Debug("|cFFFFAACurrent House:|r " .. format(nw.visitingHouse) .. "g") end
    if nw.housingStorage > 0 then
        local hId = GetCurrentZoneHouseId()
        local suffix = (hId == 0 or not IsOwnerOfCurrentHouse()) and " (saved)" or ""
NWT.Debug("|cFFFFAAHousing Storage:|r " .. format(nw.housingStorage) .. "g" .. suffix)
    end
    if nw.guildBanks > 0 then NWT.Debug("|cFFFFAAGuild Banks:|r " .. format(nw.guildBanks) .. "g (saved)") end
    
NWT.Debug("|c888888------------------------------|r")
    local crownsText = "|c33CCFFCrowns:|r " .. format(nw.crowns)
    if nw.crownsAsGold > 0 then crownsText = crownsText .. " (=" .. format(nw.crownsAsGold) .. "g)" end
NWT.Debug(crownsText)
NWT.Debug("|cFF66CCCrown Gems:|r " .. format(nw.crownGems))
NWT.Debug("|c99CCFFCrown Items:|r " .. (nw.crownStoreItems or 0) .. " store, " .. (nw.crownCrateItems or 0) .. " crate")
    if nw.totalCrownValue and nw.totalCrownValue > 0 then
        local crownText = "|cFFAA00Crown Furniture:|r " .. format(nw.totalCrownValue) .. " crowns"
        if nw.crownFurnitureAsGold and nw.crownFurnitureAsGold > 0 then
            crownText = crownText .. " (=" .. format(nw.crownFurnitureAsGold) .. "g)"
        end
NWT.Debug(crownText)
    end
    if nw.totalWritVouchers and nw.totalWritVouchers > 0 then
        local wvText = "|c88FF88Writ Vouchers:|r " .. format(nw.totalWritVouchers) .. " WV"
        if nw.writVouchersAsGold > 0 then wvText = wvText .. " (=" .. format(nw.writVouchersAsGold) .. "g)" end
NWT.Debug(wvText)
    end
    
    if #NWT.topItems > 0 then
NWT.Debug("|c888888------------------------------|r")
NWT.Debug("|cFFD700TOP 5 ITEMS:|r")
        for i = 1, 5 do
            if NWT.topItems[i] then
                local item = NWT.topItems[i]
NWT.Debug(i .. ". " .. (item.name or "Unknown"))
NWT.Debug("   x" .. item.count .. " = " .. format(item.value) .. "g")
            end
        end
    end
NWT.Debug("|c00FF00==============================|r")
end
