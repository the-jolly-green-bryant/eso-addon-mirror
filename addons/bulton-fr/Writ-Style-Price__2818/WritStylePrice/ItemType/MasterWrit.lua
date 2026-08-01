WritStylePrice.ItemType.MasterWrit = {}
WritStylePrice.ItemType.MasterWrit.__index = WritStylePrice.ItemType.MasterWrit

--[[
-- Instanciate a new MasterWrit object
--
-- @param table|nil itemData Data about the item.
--  If not null, data come from savedVars (collect.list[][][].data).
--  When it's from savedVars, properties matches because we save the object table.
-- @param WritStylePrice.Item itemObj The Item object which call us
--
-- return WritStylePrice.ItemType.MasterWrit
--]]
function WritStylePrice.ItemType.MasterWrit:New(itemData, itemObj)
    if itemData == nil then
        itemData = {
            writItemType = nil,
            styleIdx     = nil,
            chapterIdx   = nil,
            styleIsKnown = false,
            nbVouchers   = 0,
            styleItem    = {
                motifLink = nil,
                motifId   = nil,
                motifName = nil
            }
        }
    end

    -- To have access to itemData properties, and itemObj properties with self
    local newObject = setmetatable(
        itemData,
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
    
    if newObject.writItemType == nil then
        newObject:readItem()
    end

    if newObject.styleIsKnown == false then
        newObject:checkStyleIsKnown()
    end

    -- The value may have changed
    if newObject.styleIsKnown == false then
        newObject:updatePrices()
    end
    
    return newObject
end

--[[
-- Read the item and populate properties
--]]
function WritStylePrice.ItemType.MasterWrit:readItem()
    local itemInfo = { ZO_LinkHandler_ParseLink(self.itemLink) } --cf WritWorthy : Util.ToWritFields

    if itemInfo[15] == nil or itemInfo[15] == "0" then --no style defined
        return
    end

    self.writItemType = tonumber(itemInfo[10])
    self.styleIdx     = tonumber(itemInfo[15])
    self.chapterIdx   = self:convertWritItemTypeToCSChapterIdx()
    self.nbVouchers   = math.floor(tonumber(itemInfo[24]) + 0.5) / 10000

    -- To avoid errors
    if self.chapterIdx == nil then
        return
    end

    local styleIcon, styleLink = CS.Style.GetIconAndLink(self.styleIdx, self.chapterIdx)
    local styleItemInfo        = { ZO_LinkHandler_ParseLink(link) }
    
    self.styleItem = {
        motifLink = styleLink,
        motifId   = tonumber(styleItemInfo[4]),
        motifName = LocalizeString("<<1>>", GetItemLinkName(styleLink))
    }
end

--[[
-- Check the type writType to know if it's a masterWrit we need to follow or not
--
-- @param itemLink
--
-- @return bool
--]]
function WritStylePrice.ItemType.MasterWrit.checkWritType(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    local allowedItemIds = {
        119563, 119680, 121527, 121529, -- Blacksmith
        119694, 119695, 121532, 121533, -- Clothier
        119681, 119682, 121530, 121531, -- Woodworking
    }

    for idx, readItemId in ipairs(allowedItemIds) do
        if readItemId == itemId then
            return true
        end
    end

    return false
end

--[[
-- Convert a writ itemType (from info in masterWrit) to CraftStore chapter index
--
-- @return int|nil
--]]
function WritStylePrice.ItemType.MasterWrit:convertWritItemTypeToCSChapterIdx()
    -- List extracted from CraftStore
    -- Axe    Belt    Boot    Bow     Chest   Dager   Glove   Head    Legs    Mace    Shield  Shoul   Staves  Swords
    -- 1      2       3       4       5       6       7       8       9       10      11      12      13      14  

    -- List of writItemType : http://en.uesp.net/wiki/Online:Item_Link#Master_Writ_Data
    local writItemType = self.writItemType

    if writItemType == 53 or writItemType == 68 then -- Axe
        return 1
    elseif writItemType == 21 or writItemType == 30 or writItemType == 39 or writItemType == 48 then -- Belt
        return 2
    elseif writItemType == 23 or writItemType == 32 or writItemType == 41 or writItemType == 50 then -- Boot / Feet
        return 3
    elseif writItemType == 70 then -- Bow
        return 4
    elseif writItemType == 19 or writItemType == 28 or writItemType == 37 or writItemType == 46 then -- Chest
        return 5
    elseif writItemType == 62 then -- Dagger
        return 6
    elseif writItemType == 25 or writItemType == 34 or writItemType == 43 or writItemType == 52 then -- Glove
        return 7
    elseif writItemType == 17 or writItemType == 26 or writItemType == 35 or writItemType == 44 then -- Helmet / Head
        return 8
    elseif writItemType == 22 or writItemType == 31 or writItemType == 40 or writItemType == 49 then -- Legs / Greaves
        return 9
    elseif writItemType == 56 or writItemType == 69 then -- Mace / Maul
        return 10
    elseif writItemType == 65 then -- Shield
        return 11
    elseif writItemType == 20 or writItemType == 29 or writItemType == 38 or writItemType == 47 then -- Shoul / Shoulder
        return 12
    elseif writItemType == 71 or writItemType == 72 or writItemType == 73 or writItemType == 74 then -- Staves
        return 13
    elseif writItemType == 59 or writItemType == 67 then -- Swords
        return 14
    end

    return nil
end

--[[
-- Check if the style of the masterWrit is known or not
--]]
function WritStylePrice.ItemType.MasterWrit:checkStyleIsKnown()
    local currentCharId   = GetCurrentCharacterId()
    local currentCharName = WritStylePrice.charactersMap[currentCharId]
    local styleId         = GetValidItemStyleId(self.styleIdx)
    local chapterId       = CS.Style.GetChapterId(self.styleIdx, self.chapterIdx)

    self.styleIsKnown = CS.Data.style.knowledge[currentCharName][chapterId]
end

--[[
-- Update the motif's price
--]]
function WritStylePrice.ItemType.MasterWrit:updatePrices()
    WritStylePrice.Price:generatePrices(self.styleItem.motifLink)
end
