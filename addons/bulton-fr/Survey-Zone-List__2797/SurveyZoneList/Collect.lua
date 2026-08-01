SurveyZoneList.Collect = {}

-- @var table Keys are the zone name (from survey item name), value is a table
-- which contain all info about the zone like number of survey, etc
SurveyZoneList.Collect.zoneList = {}

-- @var table Keys are the slot index, value a table with info about the survey
-- at the specific slot index; the table contain the zone name and the itemlink
SurveyZoneList.Collect.slotList = {}

-- @var table Same as zoneList but with numerical keys (like an array), so we
-- don't care about keys on this table. Values are reference to values in zoneList.
SurveyZoneList.Collect.orderedList = {}

--[[
-- Read all items in the character bag to find all surveys
--]]
function SurveyZoneList.Collect:search()
    self.zoneList    = {}
    self.slotList    = {}
    self.orderedList = {}

    local bagItems = GetBagSize(BAG_BACKPACK)
    local itemZoneName = ""

    for slotIdx=0, bagItems, 1 do
        itemZoneName = self:readItem(slotIdx)
        self:updateItemToList(itemZoneName, slotIdx)
    end
end

--[[
-- Read a specific item in the character bag to know if it's a survey, and
-- parse the item name to know the zone name of the survey
--
-- @param int slotIdx The slot index of the item to read
--
-- @return string|nil The zone name of the survey, or nil
--]]
function SurveyZoneList.Collect:readItem(slotIdx)
    local itemLink      = GetItemLink(BAG_BACKPACK, slotIdx)
    local type, subType = GetItemLinkItemType(itemLink)

    if type ~= ITEMTYPE_TROPHY then
        return nil
    end

    if subType ~= SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT and subType ~= SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
        return nil
    end

    local itemName     = zo_strformat("<<1>>", GetItemName(BAG_BACKPACK, slotIdx)):lower()
    local itemZoneName = nil

    for matchIdx, matchStr in ipairs(SurveyZoneList.lang.collectFindName) do
        if itemZoneName == nil then
            itemZoneName = itemName:match(matchStr)
        end
    end

    -- Some survey map name not corresponding to the pattern, so a security to
    -- avoid error.
    if itemZoneName == nil then
        return nil
    end

    if itemZoneName:find("i$") ~= nil or itemZoneName:find("v$") ~= nil or itemZoneName:find("x$") ~= nil then
        local matchItemZoneName = nil
        local patternList = {
            -- Normal space
            "^(.*) i+$", -- "i" or "ii" or "iii" ...
            "^(.*) iv$", -- only "iv"
            "^(.*) vi*$", -- "v" or "vi" or "vii" ...
            "^(.*) xi*$", -- "x" or "xi" or "xii" ...
            -- Strange space (seem to be used in DE and RU surveys)
            "^(.*) i+$",
            "^(.*) iv$",
            "^(.*) vi*$",
            "^(.*) xi*$",
        }

        for patternIdx, pattern in ipairs(patternList) do
            matchItemZoneName = string.match(itemZoneName, pattern)

            --d(zo_strformat("<<1>> / <<2>> / <<3>>", itemZoneName, pattern, matchItemZoneName))
            
            if matchItemZoneName ~= nil then
                itemZoneName = matchItemZoneName
                break
            end
        end
    end

    return itemZoneName
end

--[[
-- Obtain the table skeleton used to save data about a zone
--
-- @param string itemZoneName A zone name
--
-- @return table
--]]
function SurveyZoneList.Collect:obtainNewZoneInfo(itemZoneName)
    return {
        name        = itemZoneName,
        nameEscaped = SurveyZoneList.ItemSort:espaceLuaStr(itemZoneName:lower()),
        survey      = {
            nbUnique = 0,
            nbTotal  = 0
        },
        treasure    = {
            nbUnique = 0,
            nbTotal  = 0
        },
        list        = {}
    }
end

--[[
-- Update all lists for the item at slot slotIdx in the character bag
--
-- @param string itemZoneName The zone name where the survey is
-- @param int slotIdx The item slot index in the character bag
--]]
function SurveyZoneList.Collect:updateItemToList(itemZoneName, slotIdx)
    if itemZoneName == nil then
        return
    end

    local itemLink = GetItemLink(BAG_BACKPACK, slotIdx)
    local quantity = GetItemTotalCount(BAG_BACKPACK, slotIdx)
    local subType  = select(2, GetItemLinkItemType(itemLink))

    if self.zoneList[itemZoneName] == nil then
        self.zoneList[itemZoneName] = self:obtainNewZoneInfo(itemZoneName)
        table.insert(self.orderedList, self.zoneList[itemZoneName])
    end

    local itemTypeCounter = nil
    if subType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
        itemTypeCounter = self.zoneList[itemZoneName].survey
    elseif subType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
        itemTypeCounter = self.zoneList[itemZoneName].treasure
    end

    local oldQuantity = 0
    if self.zoneList[itemZoneName].list[itemLink] == nil then
        itemTypeCounter.nbUnique = itemTypeCounter.nbUnique + 1
    else
        oldQuantity = self.zoneList[itemZoneName].list[itemLink]
    end

    self.zoneList[itemZoneName].list[itemLink] = quantity

    itemTypeCounter.nbTotal = itemTypeCounter.nbTotal + (quantity - oldQuantity)

    self.slotList[slotIdx] = {
        zoneName = itemZoneName,
        itemLink = itemLink
    }

    if quantity < oldQuantity and subType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
        SurveyZoneList.Recolt:reset()
        SurveyZoneList.Alerts:updateQuantity(quantity, itemTypeCounter.nbTotal)
    end
end

--[[
-- Remove an item from all list
--
-- @param table itemInfo All info about the item; it's a value in table slotList
-- @param int slotIdx The slot index where the item was
--]]
function SurveyZoneList.Collect:removeItemFromList(itemInfo, slotIdx)
    if itemInfo == nil then
        return
    end

    local itemZoneName = itemInfo.zoneName
    local itemLink     = itemInfo.itemLink
    local subType      = select(2, GetItemLinkItemType(itemLink))

    if self.zoneList[itemZoneName] == nil then
        self.zoneList[itemZoneName] = self:obtainNewZoneInfo(itemZoneName)
        table.insert(self.orderedList, self.zoneList[itemZoneName])
    end

    local itemTypeCounter = nil
    if subType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
        itemTypeCounter = self.zoneList[itemZoneName].survey
    elseif subType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
        itemTypeCounter = self.zoneList[itemZoneName].treasure
    end

    itemTypeCounter.nbUnique = itemTypeCounter.nbUnique - 1
    if itemTypeCounter.nbUnique < 0 then
        itemTypeCounter.nbUnique = 0
    end

    if self.zoneList[itemZoneName].list[itemLink] ~= nil then
        local oldQuantity = self.zoneList[itemZoneName].list[itemLink]

        itemTypeCounter.nbTotal = itemTypeCounter.nbTotal - oldQuantity
        if itemTypeCounter.nbTotal < 0 then
            itemTypeCounter.nbTotal = 0
        end

        self.zoneList[itemZoneName].list[itemLink] = nil
    end

    self.slotList[slotIdx] = nil

	if subType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
		SurveyZoneList.Recolt:reset()
		SurveyZoneList.Alerts:updateQuantity(0, itemTypeCounter.nbTotal)
	end
end

--[[
-- Return saved info about the item at a specific slot index in character bag
--
-- @return table|nil
--]]
function SurveyZoneList.Collect:findForSlotIdx(slotIdx)
    return self.slotList[slotIdx]
end
