WritStylePrice.ItemType.Style = {}
WritStylePrice.ItemType.Style.__index = WritStylePrice.ItemType.Style

--[[
-- Instanciate a new Style object
--
-- @param table|nil itemData Data about the item.
--  If not null, data come from savedVars (collect.list[][][].data).
--  When it's from savedVars, properties matches because we save the object table.
-- @param WritStylePrice.Item itemObj The Item object which call us
--
-- return WritStylePrice.ItemType.Style
--]]
function WritStylePrice.ItemType.Style:New(info, itemObj)
    if info == nil then
        info = {
            itemId  = nil,
            isKnown = false
        }
    end

    -- To have access to info properties, and itemObj properties with self
    local newObject = setmetatable(
        info,
        {
            __index = function(table, key)
                local selfValue = self[key]
                local itemValue = itemObj[key]
        
                if selfValue ~= nil then
                    return selfValue
                elseif itemValue ~= nil then
                    return itemValue
                else
                    return nil
                end
            end
        }
    )
    
    if newObject.itemId == nil then
        newObject:readItem()
    end

    if newObject.isKnown == false then
        newObject:checkStyleIsKnown()
    end
    
    return newObject
end

--[[
-- Read the item and populate properties
--]]
function WritStylePrice.ItemType.Style:readItem()
    self.itemId = GetItemLinkItemId(self.itemLink)
end

--[[
-- Check if the style is known or not for the current character.
-- Called only if not already known on another character.
--]]
function WritStylePrice.ItemType.Style:checkStyleIsKnown()
    -- Extracted from UnknownInsight
    if self.itemType == WritStylePrice.Item.ITEM_TYPE_MO then
        self.isKnown = IsItemLinkBookKnown(self.itemLink)
    elseif self.itemType == WritStylePrice.Item.ITEM_TYPE_SP then
        local collectibleId = GetItemLinkContainerCollectibleId(self.itemLink)
        self.isKnown = IsCollectibleUnlocked(collectibleId)
    end
end
