WritStylePrice.Item = ZO_Object:Subclass()
WritStylePrice.ItemType = {}

--[[
-- @const ITEM_TYPE_MW The itemType value for master writ
--]]
WritStylePrice.Item.ITEM_TYPE_MW = "masterWrit"

--[[
-- @const ITEM_TYPE_SP The itemType value for style page
--]]
WritStylePrice.Item.ITEM_TYPE_SP = "stylePage"

--[[
-- @const ITEM_TYPE_MW The itemType value for style books and chapters
--]]
WritStylePrice.Item.ITEM_TYPE_MO = "motives"

--[[
-- Instanciate a new Item object
--
-- @param table itemInfo Info about the item.
--  Value come from self.createBaseObj() or from savedVars (collect.list[][][]).
--  When it's from savedVars, properties matches because we save Item object table.
--
-- @return WritStylePrice.Item
--]]
function WritStylePrice.Item:New(itemInfo)
    -- Extract from ZO_Object:New()
    -- The 1st argument in setmetatable is replaced by itemInfo instead of {}

    if itemInfo == nil then
        --Error on savedVariable if it happens
        return nil
    end

    local newObject = setmetatable(itemInfo, self)
    local mt = getmetatable(newObject)
    mt.__index = self

    newObject:initData()
    
    return newObject
end

--[[
-- Initialise the data property with a instance of the dedicated object for the item type
--]]
function WritStylePrice.Item:initData()
    if self.itemType == self.ITEM_TYPE_MW then
        self.data = WritStylePrice.ItemType.MasterWrit:New(self.data, self)
    elseif self.itemType == self.ITEM_TYPE_MO or self.itemType == self.ITEM_TYPE_SP then
        self.data = WritStylePrice.ItemType.Style:New(self.data, self)
    end
end

--[[
-- Generate and return the base table used to create a new Item object
--
-- @param int bagId
-- @param int slotIdx
-- @param string itemLink
-- @param string itemType (see constants)
--
-- @return
--]]
function WritStylePrice.Item.createBaseObj(bagId, slotIdx, itemLink, itemType)
    local currentCharId = nil
    if bagId == BAG_BACKPACK then
        currentCharId = GetCurrentCharacterId()
    end

    return {
        bagId    = bagId,
        slotIdx  = slotIdx,
        charId   = currentCharId,
        itemLink = itemLink,
        itemName = LocalizeString("<<1>>", GetItemLinkName(itemLink)),
        itemType = itemType,
        data     = nil
    }
end

--[[
-- Check if an item is a type we follow and save (masterWrit or stylePage/motives)
--
-- @param string itemLink
--
-- @return string|nil If string, it's one of the Item constants; If nil, not an item we follow.
--]]
function WritStylePrice.Item.checkType(itemLink)
    local itemType, itemSubType = GetItemLinkItemType(itemLink)

    -- Is masterWrit
    if itemType == ITEMTYPE_MASTER_WRIT then
        if WritStylePrice.ItemType.MasterWrit.checkWritType(itemLink) then
            return WritStylePrice.Item.ITEM_TYPE_MW
        else
            return nil
        end
    end

    -- Is stylePage or motives
    if itemType == ITEMTYPE_CONTAINER then
        if itemSubType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
            local itemId = GetItemLinkItemId(itemLink)

            -- Extracted from addon UnknownInsight
            local itemLink      = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemId, 364)
            local collectibleId = GetItemLinkContainerCollectibleId(itemLink)

            if collectibleId > 0 then
                local categoryType = GetCollectibleCategoryType(collectibleId)

                if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
                    return WritStylePrice.Item.ITEM_TYPE_SP
                end
            end
        end
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        if itemSubType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or itemSubType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER then
            return WritStylePrice.Item.ITEM_TYPE_MO
        end
    end

    return nil
end
