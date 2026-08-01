LootTrackerSolution.LogicModule = {}

local SLM = LootTrackerSolution.LogicModule

function SLM.SortTable(scrollData)
    local parametr = LootTrackerSolution.LootStorageModule:GetGeneralSetting("SortListParametr")   
    local direction = LootTrackerSolution.LootStorageModule:GetGeneralSetting("SortListDirection") 

    if parametr == 1 then
        if direction == 1 then
            table.sort(scrollData, function(a, b) return a.itemTime < b.itemTime end)
        else
            table.sort(scrollData, function(a, b) return a.itemTime > b.itemTime end)
        end
    elseif parametr == 2 then
        if direction == 1 then
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice) * a.itemQuantity) <
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice) * b.itemQuantity) end)
        else
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice) * a.itemQuantity) >
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice) * b.itemQuantity) end)
        end
    elseif parametr == 3 then
        if direction == 1 then
            table.sort(scrollData, function(a, b) return a.itemQuantity < b.itemQuantity end)
        else
            table.sort(scrollData, function(a, b) return a.itemQuantity > b.itemQuantity end)
        end
    end

    return scrollData
end

function SLM.SortTableByParams(scrollData, sortDirection, sortType, sortCategory, searchText, showOnlyMaterials)
    local parametr = sortType       
    local direction = sortDirection 
    local category = sortCategory   
    local search = searchText
    local onlyMaterials = showOnlyMaterials

    if parametr == 1 then
        if direction then
            table.sort(scrollData, function(a, b) return GetItemLinkName(a.itemLink) < GetItemLinkName(b.itemLink) end)
        else
            table.sort(scrollData, function(a, b) return GetItemLinkName(a.itemLink) > GetItemLinkName(b.itemLink) end)
        end
    elseif parametr == 2 then
        if direction then
            table.sort(scrollData, function(a, b) return a.itemCategory < b.itemCategory end)
        else
            table.sort(scrollData, function(a, b) return a.itemCategory > b.itemCategory end)
        end
    elseif parametr == 3 then
        if direction then
            table.sort(scrollData, function(a, b) return a.itemQuantity < b.itemQuantity end)
        else
            table.sort(scrollData, function(a, b) return a.itemQuantity > b.itemQuantity end)
        end
    elseif parametr == 4 then
        if direction then
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice) * a.itemQuantity) <
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice) * b.itemQuantity) end)
        else
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice) * a.itemQuantity) >
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice) * b.itemQuantity) end)
        end
    elseif parametr == 5 then
        if direction then
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice)) <
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice)) end)
        else
            table.sort(scrollData,
                function(a, b) return (LootTrackerSolution.TradeCenter.SelectPriceInfo(a.lastPrice)) >
                    (LootTrackerSolution.TradeCenter.SelectPriceInfo(b.lastPrice)) end)
        end
    end

    if onlyMaterials and category ~= "Other" then 
        local tempTable = {}
        for _, itemData in ipairs(scrollData) do
            if itemData.itemCategory == "Blacksmithing" or itemData.itemCategory == "Clothing" or itemData.itemCategory == "Woodworking" or itemData.itemCategory == "Jewelry Crafting" or itemData.itemCategory == "Alchemy" or itemData.itemCategory == "Enchanting" or itemData.itemCategory == "Provisioning" then
                table.insert(tempTable, itemData)
            end
        end
        scrollData = tempTable
    end

    local filteredDataByText = {}

    if search ~= "" or search ~= nil then
        for _, itemData in ipairs(scrollData) do
            if string.find(string.lower(GetItemLinkName(itemData.itemLink)), string.lower(search)) then
                table.insert(filteredDataByText, itemData)
            end
        end
    else
        filteredDataByText = scrollData
    end

    local filteredData = {}
    if category ~= "All" then
        for _, itemData in ipairs(filteredDataByText) do
            if itemData.itemCategory == category then
                table.insert(filteredData, itemData)
            end
        end
        return filteredData
    else
        return filteredDataByText
    end
end

function SLM.RestructTableToItemStacking(scrollData)
    local stackedData = {}

    for _, itemData in ipairs(scrollData) do
        local foundItem = false

        for _, stackedItem in ipairs(stackedData) do
            if stackedItem.itemLink == itemData.itemLink then
                stackedItem.itemQuantity = stackedItem.itemQuantity + itemData.itemQuantity
                foundItem = true
                break
            end
        end

        if not foundItem then
            table.insert(stackedData, {
                itemLink = itemData.itemLink,
                itemQuantity = itemData.itemQuantity,
                lastPrice = itemData.lastPrice,
                itemTime = itemData.itemTime
            })
        end
    end

    return stackedData
end

function SLM.FormatTimeMilliseconds(milliseconds)

    local seconds = math.floor(milliseconds / 1000)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60

    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function SLM.GetCharacterCount(str)

    local count = 0
    local byteIndex = 1

    while byteIndex <= #str do
        count = count + 1
        byteIndex = byteIndex + (string.byte(str, byteIndex) >= 192 and 2 or 1)
    end

    return count
end

function SLM.ReworkLinkUTF8Item(itemLink)
    if type(itemLink) == "string" then
        local itemName = GetItemLinkName(itemLink)
        local formattedLink = string.gsub(itemLink, "|h.*|h", "|h" .. itemName .. "|h")
        return zo_strformat(SI_TOOLTIP_ITEM_NAME, formattedLink)
    else
        return nil
    end
end

function SLM.TrimItemLinkName(itemLink, maxLength)

    if type(itemLink) == "string" and type(maxLength) == "number" then
        local itemName = GetItemLinkName(itemLink)

        if LootTrackerSolution.LogicModule.GetCharacterCount(itemName) > maxLength then
            local trimmedName = itemName
            local byteIndex = 1
            local numBytes = 0

            while numBytes < maxLength - 3 and byteIndex <= #itemName do
                local charByte = string.byte(itemName, byteIndex)

                if charByte < 128 or charByte >= 192 then
                    numBytes = numBytes + 1
                end

                byteIndex = byteIndex + 1
            end

            while byteIndex <= #itemName and string.byte(itemName, byteIndex) >= 128 and string.byte(itemName, byteIndex) < 192 do
                byteIndex = byteIndex + 1
            end

            trimmedName = string.sub(itemName, 1, byteIndex - 1) .. "..."
            local formattedLink = string.gsub(itemLink, "|h.*|h", "|h" .. trimmedName .. "|h")
            return zo_strformat(SI_TOOLTIP_ITEM_NAME, formattedLink)
        else
            return itemLink
        end
    else
        return nil
    end
end