WritStylePrice.Collect = {}

--[[
-- @const TYPE_HOUSE_BANK The key in self.list for the table which contain
-- the house bank item's list.
--]]
WritStylePrice.Collect.TYPE_HOUSE_BANK = "houseBank"

--[[
-- @const TYPE_BANK The key in self.list for the table which contain the bank item's list.
--]]
WritStylePrice.Collect.TYPE_BANK = "bank"

--[[
-- @const TYPE_CHAR The key in self.list for the table which contain the characters item's list.
--]]
WritStylePrice.Collect.TYPE_CHAR = "char"

--[[
-- @var table|nil The list of all collected items.
-- When it's not nil, it's a ref to WritStylePrice.savedVariables.collect.list
--]]
WritStylePrice.Collect.list = nil

--[[
-- @var table The read/collected status for each part which can be read/collected
--]]
WritStylePrice.Collect.status = {
    savedListReaded = false,
    houseCollected  = false,
    bankCollected   = false,
    bagCollected    = false
}

--[[
-- @var table All saved variables dedicated to the collect system.
--]]
WritStylePrice.Collect.savedVars = nil

--[[
-- Initialise the collect system
--]]
function WritStylePrice.Collect:init()
    self.savedVars = WritStylePrice.savedVariables.collect
    self:initSavedVarsValues()

    self.list = self.savedVars.list
    self:initSavedList()
end

--[[
-- Initialise with a default value all saved variables dedicated to the collect system
--]]
function WritStylePrice.Collect:initSavedVarsValues()
    if self.savedVars.list == nil then
        self.savedVars.list = {}
    end

    if self.savedVars.scan == nil then
        self.savedVars.scan = {}
    end
    if self.savedVars.scan.charBag == nil then
        self.savedVars.scan.charBag = true
    end
    if self.savedVars.scan.bank == nil then
        self.savedVars.scan.bank = true
    end
    if self.savedVars.scan.houseBank == nil then
        self.savedVars.scan.houseBank = true
    end
end

--[[
-- Initialise the self.list table contents
--]]
function WritStylePrice.Collect:initSavedList()
    if self.list[self.TYPE_HOUSE_BANK] == nil then
        self.list[self.TYPE_HOUSE_BANK] = {}

        -- Define the table with the content directly not resolve constant value :(
        -- So we define it one by one
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_ONE]   = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_TWO]   = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_THREE] = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_FOUR]  = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_FIVE]  = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_SIX]   = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_SEVEN] = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_EIGHT] = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_NINE]  = {}
        self.list[self.TYPE_HOUSE_BANK][BAG_HOUSE_BANK_TEN]   = {}
    end

    if self.list[self.TYPE_BANK] == nil then
        self.list[self.TYPE_BANK] = {}
        self.list[self.TYPE_BANK][BAG_BANK]            = {}
        self.list[self.TYPE_BANK][BAG_SUBSCRIBER_BANK] = {}
    end

    if self.list[self.TYPE_CHAR] == nil then
        self.list[self.TYPE_CHAR] = {}

        for charId, charName in pairs(WritStylePrice.charactersMap) do
            self.list[self.TYPE_CHAR][charId] = {}
        end
    end

    -- Check deleted char
    for charId in pairs(self.list[self.TYPE_CHAR]) do
        if WritStylePrice.charactersMap[charId] == nil then
            self.list[self.TYPE_CHAR][charId] = nil
        end
    end

    -- Check new perso
    local currentCharId = GetCurrentCharacterId()
    if self.list[self.TYPE_CHAR][currentCharId] == nil then
        self.list[self.TYPE_CHAR][currentCharId] = {}
    end
end

--[[
-- To know if the character bag should be scanned or not
--
-- @return bool
--]]
function WritStylePrice.Collect:obtainScanCharBag()
    return self.savedVars.scan.charBag
end

--[[
-- Define the value for the var used to know if the character bag should be scanned
--
-- @param bool newValue
--]]
function WritStylePrice.Collect:defineScanCharBag(newValue)
    self.savedVars.scan.charBag = newValue

    if newValue == true then
        WritStylePrice.async:Call(function()
            WritStylePrice.Collect:readCharBag()
            WritStylePrice.GUI:refreshList()
        end)
    else
        self:removeAllInBagType(self.TYPE_CHAR)
        WritStylePrice.Collect.status.bagCollected = false
        WritStylePrice.GUI:refreshList()
    end
end

--[[
-- To know if the bank should be scanned or not
--
-- @return bool
--]]
function WritStylePrice.Collect:obtainScanBank()
    return self.savedVars.scan.bank
end

--[[
-- Define the value for the var used to know if the bank should be scanned
--
-- @param bool newValue
--]]
function WritStylePrice.Collect:defineScanBank(newValue)
    self.savedVars.scan.bank = newValue

    if newValue == true then
        WritStylePrice.async:Call(function()
            WritStylePrice.Collect:readBank()
            WritStylePrice.GUI:refreshList()
        end)
    else
        self:removeAllInBagType(self.TYPE_BANK)
        WritStylePrice.Collect.status.bankCollected = false
        WritStylePrice.GUI:refreshList()
    end
end

--[[
-- To know if the house bank (storrage coffers) should be scanned or not
--
-- @return bool
--]]
function WritStylePrice.Collect:obtainScanHouseBank()
    return self.savedVars.scan.houseBank
end

--[[
-- Define the value for the var used to know if the house bank should be scanned
--
-- @param bool newValue
--]]
function WritStylePrice.Collect:defineScanHouseBank(newValue)
    self.savedVars.scan.houseBank = newValue

    if newValue == true then
        WritStylePrice.async:Call(function()
            WritStylePrice.Collect:readHouseBanks()
            WritStylePrice.GUI:refreshList()
        end)
    else
        self:removeAllInBagType(self.TYPE_HOUSE_BANK)
        WritStylePrice.Collect.status.houseCollected = false
        WritStylePrice.GUI:refreshList()
    end
end

--[[
-- Read all list of items collected and call the callback for each item
--
-- The callback will receive 4 args (5 with the self)
-- > table self The self table used in the callback
-- > string listType The type of the list (see constants)
-- > int bagId The bag id where is the item
-- > string itemKey The item key in self.list[][]
-- > WritStylePrice.Item itemObj The Item object for the current item readed
--
-- @param function The callback to call for each item read
-- @param table The self passed to the callback.
--  If not defined, the self will be WritStylePrice.Collect
--]]
function WritStylePrice.Collect:readAllList(callback, callbackSelf)
    if callbackSelf == nil then
        callbackSelf = self
    end

    for listType, bagTypeList in pairs(self.list) do
        for bagId, bagItemList in pairs(bagTypeList) do
            for itemKey, itemObj in pairs(bagItemList) do
                callback(callbackSelf, listType, bagId, itemKey, itemObj)
            end
        end
    end
end

--[[
-- Remove all items in a specific bagType (not bagId !)
--
-- @param string bagType See WritStylePrice.Collect constants
--]]
function WritStylePrice.Collect:removeAllInBagType(bagType)
    if self.list[bagType] == nil then
        return
    end

    for bagId, _ in pairs(self.list[bagType]) do
        self.list[bagType][bagId] = {}
    end
end

--[[
-- Read all item saved in savedVar and instanciate a new Item object for each item.
--]]
function WritStylePrice.Collect:readSavedList()
    local instanciateItemObj = function(self, listType, bagId, itemKey, savedData)
        savedData = WritStylePrice.Item:New(savedData)
    end

    self:readAllList(instanciateItemObj)

    self.status.savedListReaded = true
end

--[[
-- Read all item in the character bag
--]]
function WritStylePrice.Collect:readCharBag()
    if self:obtainScanCharBag() == false then
        return nil
    end

    local bagId       = BAG_BACKPACK
    local bagItemList = self:obtainBagItemList(BAG_BACKPACK)
    local bagSize     = GetBagSize(bagId)

    for slotIdx=0, bagSize, 1 do
        self:readItemSlot(bagId, slotIdx, bagItemList)
    end

    self.status.bagCollected = true
end

--[[
-- Read all item in the bank
--]]
function WritStylePrice.Collect:readBank()
    if self:obtainScanBank() == false then
        return nil
    end

    for bagId, bagItemList in pairs(self.list[self.TYPE_BANK]) do
        local bagSize = GetBagSize(bagId)

        for slotIdx=0, bagSize, 1 do
            self:readItemSlot(bagId, slotIdx, bagItemList)
        end
    end

    self.status.bankCollected = true
end

--[[
-- Read all item in the house bank (storrage coffers)
--]]
function WritStylePrice.Collect:readHouseBanks()
    if not IsOwnerOfCurrentHouse() then
        return nil
    end

    if self:obtainScanHouseBank() == false then
        return nil
    end

    for bagId, bagItemList in pairs(self.list[self.TYPE_HOUSE_BANK]) do
        local bagSize = GetBagSize(bagId)

        for slotIdx=0, bagSize, 1 do
            self:readItemSlot(bagId, slotIdx, bagItemList)
        end
    end

    self.status.houseCollected = true
end

--[[
-- Generate the key used to save an item in self.list[][]
--
-- @param int bagId The bagId where is the item
-- @param int slotIdx The slot index of the item
--
-- @return string
--]]
function WritStylePrice.Collect:generateSavedKey(bagId, slotIdx)
    return zo_strformat("<<1>>_<<2>>", bagId, slotIdx)
end

--[[
-- Obtain the table which contain the list item for a specific bagId
--
-- @param int bagId
--
-- @return table|nil Return nil if the bag is not managed
--]]
function WritStylePrice.Collect:obtainBagItemList(bagId)
    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        return self.list[self.TYPE_BANK][bagId]
    end

    if bagId == BAG_BACKPACK then
        local currentCharId = GetCurrentCharacterId()
        return self.list[self.TYPE_CHAR][currentCharId]
    end

    if bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN then
        return self.list[self.TYPE_HOUSE_BANK][bagId]
    end

    return nil
end

--[[
-- Read a slot index in a bag id
--
-- @param int bagId
-- @param int slotIdx
-- @param table bagItemList The table in self.list[][] where the item can be saved
--]]
function WritStylePrice.Collect:readItemSlot(bagId, slotIdx, bagItemList)
    local itemLink  = GetItemLink(bagId, slotIdx)
    local savedKey  = self:generateSavedKey(bagId, slotIdx)
    local savedData = bagItemList[savedKey]

    if itemLink == "" and savedData ~= nil then
        self:removeItem(bagId, slotIdx, bagItemList, savedKey)
    elseif itemLink ~= "" and savedData == nil then
        self:newItem(bagId, slotIdx, itemLink, bagItemList, savedKey)
    elseif itemLink ~= "" and savedData ~= nil then
        self:updateItem(bagId, slotIdx, itemLink, bagItemList, savedKey)
    end
end

--[[
-- To add an unknown item (for the list) to the list if it's an item that interests us
--
-- @param int bagId
-- @param int slotIdx
-- @param string itemLink
-- @param table bagItemList (opt) The table in self.list[][] where the item can be saved
--  Info is known when it's called since self:readItemSlot, else define to nil
-- @param string savedKey (opt) The key to use to save the item in self.list[][]
--  Info is known when it's called since self:readItemSlot, else define to nil
--]]
function WritStylePrice.Collect:newItem(bagId, slotIdx, itemLink, bagItemList, savedKey)
    if bagItemList == nil then
        bagItemList = self:obtainBagItemList(bagId)

        -- Bag not found :o
        if bagItemList == nil then
            return
        end
    end

    if savedKey == nil then
        savedKey = self:generateSavedKey(bagId, slotIdx)
    end

    local itemType = WritStylePrice.Item.checkType(itemLink)
    if itemType == nil then
        return
    end

    local obj = WritStylePrice.Item.createBaseObj(bagId, slotIdx, itemLink, itemType)
    bagItemList[savedKey] = WritStylePrice.Item:New(obj)
end

--[[
-- To update a known item in self.list[][]
--
-- @param int bagId
-- @param int slotIdx
-- @param string itemLink
-- @param table bagItemList (opt) The table in self.list[][] where the item can be saved
--  Info is known when it's called since self:readItemSlot, else define to nil
-- @param string savedKey (opt) The key to use to save the item in self.list[][]
--  Info is known when it's called since self:readItemSlot, else define to nil
--]]
function WritStylePrice.Collect:updateItem(bagId, slotIdx, itemLink, bagItemList, savedKey)
    if bagItemList == nil then
        bagItemList = self:obtainBagItemList(bagId)

        -- Bag not found :o
        if bagItemList == nil then
            return
        end
    end

    if savedKey == nil then
        savedKey = self:generateSavedKey(bagId, slotIdx)
    end

    local savedData     = bagItemList[savedKey]
    local savedItemLink = savedData.itemLink

    -- Not the same object for the same bag and slot
    if savedItemLink ~= itemLink then
        self:removeItem(bagId, slotIdx, bagItemList, savedKey)
        self:newItem(bagId, slotIdx, itemLink, bagItemList, savedKey)
        return
    end

    -- Need to instanciate Item object ?
    if savedData.initData == nil then
        savedData = WritStylePrice.Item:New(savedData)
    end
end

--[[
-- To remove a known item from self.list[][]
-- Also check if it's a motif and if it has been learned.
--
-- @param int bagId
-- @param int slotIdx
-- @param table bagItemList (opt) The table in self.list[][] where the item can be saved
--  Info is known when it's called since self:readItemSlot, else define to nil
-- @param string savedKey (opt) The key to use to save the item in self.list[][]
--  Info is known when it's called since self:readItemSlot, else define to nil
--]]
function WritStylePrice.Collect:removeItem(bagId, slotIdx, bagItemList, savedKey)
    if bagItemList == nil then
        bagItemList = self:obtainBagItemList(bagId)

        -- Bag not found :o
        if bagItemList == nil then
            return
        end
    end

    if savedKey == nil then
        savedKey = self:generateSavedKey(bagId, slotIdx)
    end

    -- Check if it's a motif and if it has been learned just now
    local savedData = bagItemList[savedKey]
    if savedData ~= nil then
        if savedData.itemType ~= WritStylePrice.Item.ITEM_TYPE_MW then
            if savedData.data.isKnown == false then
                savedData.data:checkStyleIsKnown()

                if savedData.data.isKnown == true then
                    self:readAllList(WritStylePrice.Collect.newStyleLearn)

                    if WritStylePrice.GUI:getIsHidden() == false then
                        WritStylePrice.GUI:refreshList()
                    end
                end
            end
        end
    end

    bagItemList[savedKey] = nil
end

--[[
-- Callback for self:readAllList called when a new style has been learned.
-- Used to check if the style is now known or not on each masterWrit in the list.
--
-- @param string listType The type of the list (see constants)
-- @param int bagId The bag id where is the item
-- @param string itemKey The item key in self.list[][]
-- @param WritStylePrice.Item itemObj The Item object for the current item readed
--]]
function WritStylePrice.Collect:newStyleLearn(listType, bagId, itemKey, itemObj)
    if itemObj.itemType == WritStylePrice.Item.ITEM_TYPE_MW then
        itemObj.data:checkStyleIsKnown()
    end
end
