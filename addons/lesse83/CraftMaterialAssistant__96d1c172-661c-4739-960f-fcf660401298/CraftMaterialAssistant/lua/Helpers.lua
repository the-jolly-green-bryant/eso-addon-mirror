local CMA = CraftMaterialAssistant

-- output formatted chat messages with an add-on tag
function CMA:SendChatMessage(message)
    d("|cFFD700[CraftMaterialAssistant]|r " .. message)
end

-- send formatted message concatenating items in a table. limit item count per message.
function CMA:SendChatMessageLimitedItemCount(message, items)
    local chunks = {}
    local totalItemCount = #items

    -- create sized junks with items
    for i = 1, totalItemCount, self.maxChatMessageItems do
        local startIndex = i
        local endIndex = math.min(i + self.maxChatMessageItems - 1, totalItemCount)
        table.insert(chunks, table.concat(items, ", ", startIndex, endIndex))
    end
    -- iterate over the junks and print them
    for i = 1, #chunks do
        self:SendChatMessage(message .. chunks[i])
    end
end

-- Helper function to convert id64 to string safely
function CMA:GetUniqueIdString(bagId, slotIndex)
    local uniqueId = GetItemUniqueId(bagId, slotIndex)
    if uniqueId then
        return Id64ToString(uniqueId)
    end
    return nil
end

-- find an item by its uniqueId in a bag
function CMA:findItemByUniqueId(bagId, searchedUniqueId)
    local maxSlots = GetBagSize(bagId)
    for slotIndex = 0, maxSlots do
        if HasItemInSlot(bagId, slotIndex) then
            local uniqueId = self:GetUniqueIdString(bagId, slotIndex)
            if uniqueId == searchedUniqueId then
                return bagId, slotIndex
            end
        end
    end
    return nil, nil
end

-- string explode function splitting a string into substrings (delimited by the separator)
function CMA:StringExplode(text, separator)
  local result = {}
  for substring in string.gmatch(text, "([^"..separator.."]+)") do
    table.insert(result, substring)
  end
  return result
end

-- scan the bank and fill the cachedBankSlots
function CMA:ScanAndMapBankSlots(bag)
    -- iterate through the bag and get the items
    local slot = ZO_GetNextBagSlotIndex(bag)
    while slot do
        if HasItemInSlot(bag, slot) then
            local itemId = GetItemId(bag, slot)
            if self.cachedBankSlots[itemId] then
                -- another slot already features that itemId - attach as comma separated values
                self.cachedBankSlots[itemId][1] = self.cachedBankSlots[itemId][1] + 1
                self.cachedBankSlots[itemId][2] = self.cachedBankSlots[itemId][2] .. self.cachedBankSlotSeparator .. slot
            else
                -- item id not in the map so far - initialize it with the item
                self.cachedBankSlots[itemId] = {1, slot}
            end
        end
        -- go on with the next slot, if available
        slot = ZO_GetNextBagSlotIndex(bag, slot)
    end
end

-- check if there is a slot that item is already present and get the best fitting slotIndex if there are multiple
function CMA:GetBestFitMapSlot(bag, itemId, stackSizeToDeposit)
    -- check if there are items with that id in the bank
    if self.cachedBankSlots[itemId] then
        -- found at least one stack
        if(self.cachedBankSlots[itemId][1] == 1) then
            -- only one option, check if the stack size would fit
            local currentStackSize, maxStackSize = GetSlotStackSize(bag, self.cachedBankSlots[itemId][2])
            if (maxStackSize - currentStackSize - stackSizeToDeposit) > 0 then
                -- there is space, return the slotIndex
                return self.cachedBankSlots[itemId][2]
            else
                -- no space for it
                return nil
            end
        else
            -- multiple options - iterate them and look where it fits and the left space is smallest
            local possibleSlots = self:StringExplode(self.cachedBankSlots[itemId][2], self.cachedBankSlotSeparator)
            local smallestDifferenceValue = math.huge
            local smallestDifferenceIndex = 0
            -- iterate over slots
            for i = 1, #possibleSlots do
                local currentStackSize, maxStackSize = GetSlotStackSize(bag, possibleSlots[i])
                local computedNewStackSize = maxStackSize - currentStackSize - stackSizeToDeposit
                -- only remember slot if it fits and is the best fitting
                if (computedNewStackSize > 0) and (computedNewStackSize < smallestDifferenceValue) then
                    smallestDifferenceValue = computedNewStackSize
                    smallestDifferenceIndex = possibleSlots[i]
                end
            end
            -- now check if there was something found to be merged with
            if smallestDifferenceIndex ~= 0 then
                -- one optimal was found, return the slotIndex
                return smallestDifferenceIndex
            else
                -- no fitting space amongst them
                return nil
            end
        end
    else
        -- no stack with that item so far -> return nil
        return nil
    end
end