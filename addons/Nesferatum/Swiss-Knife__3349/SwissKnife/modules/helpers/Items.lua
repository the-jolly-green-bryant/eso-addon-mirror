local SK = SwissKnife
local SKDC = SK.Data.common
local SKDI = SK.Data.itemsData
local SKH = SK.HelperFunctions

local function returnItemLink(itemLink)return itemLink end

local function getWornItemLink(equipSlot, bagId)
    if bagId ~= BAG_WORN then bagId = BAG_COMPANION_WORN end
    return GetItemLink(bagId, equipSlot)
end

local function getNonStolenItemLink(itemLink)
    if not IsItemLinkStolen(itemLink) then return itemLink end
    local itemLinkMod = string.gsub(itemLink, "1(:%d+:%d+|h|h)$", "0%1")
    itemLinkMod = string.gsub(itemLinkMod, "%d+(:%d+:%d+:%d+:%d+:%d+:%d+|h|h)$", "0%1")
    return itemLinkMod
end

local function isItemProtected(bagId, slotIndex)
    local isProtected = IsItemPlayerLocked(bagId, slotIndex) or (
        FCOIS and (FCOIS.IsLocked(bagId, slotIndex) or FCOIS.IsDestroyLocked(bagId, slotIndex) or
        FCOIS.IsDeconstructionLocked(bagId, slotIndex)) and not
        FCOIS.IsMarked(bagId, slotIndex, FCOIS_CON_ICON_SELL))
    return isProtected
end

local function isItemDestroyProtected(bagId, slotId)
    return IsItemPlayerLocked(bagId, slotId) or (FCOIS and FCOIS.IsDestroyLocked(bagId, slotId))
end

local function isItemDeconstructionProtected(bagId, slotId)
    return IsItemPlayerLocked(bagId, slotId) or (FCOIS and FCOIS.IsDeconstructionLocked(bagId, slotId))
end

local function isItemForLaunder(bagId, slotIndex, itemLink)
    if not SK.savedVars.isAutoLaunderEnabled then return end
    local itemType, specializedItemType, itemId
    if bagId and slotIndex then
        itemType, specializedItemType = GetItemType(bagId, slotIndex)
        itemId = GetItemId(bagId, slotIndex)
    elseif itemLink then
        itemType, specializedItemType = GetItemLinkItemType(itemLink)
        itemId = GetItemLinkItemId(itemLink)
    else
        return false
    end
    return SKH.isValueInList(SKDI.LAUNDER_ITEM_TYPES, itemType) or SKH.isValueInList(SKDI.LAUNDER_ITEMS, itemId) or
            (itemType == ITEMTYPE_TROPHY and SKH.isValueInList(SKDI.LAUNDER_ITEMTYPE_TROPHY, specializedItemType)) or
        SKH.isValueInList(SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.RESOURCES], itemType) or
            SKH.isKeyInTable(SK.globalSV.launderItems, itemId)
end

local function isStolenItemForDestroy(bagId, slotIndex, itemLink, sellCost)
    if not SK.savedVars.isPickyThiefEnabled then return end
    if bagId and slotIndex and not itemLink then itemLink = GetItemLink(BAG_BACKPACK, slotIndex) end
    local itemType = GetItemLinkItemType(itemLink)
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    if bagId and slotIndex then
        sellCost = GetItemSellValueWithBonuses(bagId, slotIndex) * GetSlotStackSize(bagId, slotIndex)
    elseif not sellCost then
        local bagCount = GetItemLinkStacks(itemLink)
        sellCost = GetItemLinkValue(itemLink)
        if bagCount and sellCost then sellCost = sellCost * bagCount end
    end
    if sellCost == nil or sellCost < tonumber(SK.savedVars.lowCostStealing) then
        local isWorthless = SKH.isValueInList(SKDI.WORTHLESS_STEALING_ITEMS, itemType)
        local isLowQuality = SKH.isValueInList(SKDI.STEALING_BY_QUALITY_ITEMS, itemType) and
            itemQuality <= SK.savedVars.lowQualityStealing
        return isWorthless or isLowQuality
    end
end

local function getItemTypeData(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_NONE and equipType ~= EQUIP_TYPE_INVALID then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then
            return SK.SET_PARTS_DATA[itemType][equipType]
        elseif weaponType ~= WEAPONTYPE_NONE then
            return SK.SET_PARTS_DATA[itemType][weaponType]
        end
    end
end

local function getItemTypeName(itemLink)
    local itemData = getItemTypeData(itemLink)
    if itemData then return itemData.name, itemData.preset end
end

local function getItemTypeIcon(itemLink)
    local itemData = getItemTypeData(itemLink)
    if itemData then return itemData.icon end
end

local function getSetName(itemLink, isEnOnly, newLine)
    if itemLink == nil then return "[Wrong link]" end
    local _, setId, setName = SKH.getItemLinkSetInfo(itemLink)
    local isSetEnNameExists = SKH.isKeyInTable(SK.Data.setsData, setId)
    local name = setName
    if isSetEnNameExists then
        local enSetName = SK.Data.setsData[setId]
        if enSetName ~= setName then
            if isEnOnly then
                name = enSetName
            else
                local d = " - "
                if newLine then d = "\n" end
                name = setName..d..enSetName
            end
        end
    end
    return name
end

local function getTraitName(itemLink)
    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
    local traitName
    if traitType ~= ITEM_TRAIT_TYPE_NONE and traitDescription ~= "" then
        if SKH.isKeyInTable(SK.Data.traitsData, traitType) then traitName = SK.Data.traitsData[traitType] end
    end
    return traitName
end

local function getPotentialRefineMaterialsByType(rawMaterialsList, craftingInteractionType)
    for _, bagId in ipairs(SKDC.BAG_MATERIALS) do
        if SK.savedVars.debugMode then d("bagId "..bagId) end
        for slotIndex in ZO_IterateBagSlots(bagId) do
            local itemType = GetItemType(bagId, slotIndex)
            if itemType ~= ITEMTYPE_NONE then
                local materialByInteractionType = SKDI.RAW_MATERIALS_BY_TYPE[craftingInteractionType]
                if materialByInteractionType ~= nil and SKH.isValueInList(materialByInteractionType, itemType) then
                    local itemId = GetItemInstanceId(bagId, slotIndex)
                    local quantity = GetSlotStackSize(bagId, slotIndex)
                    if rawMaterialsList[itemId] == nil then
                        rawMaterialsList[itemId] = {
                            bagId = bagId,
                            slotIndex = slotIndex,
                            quantity = quantity
                        }
                    else
                        rawMaterialsList[itemId].quantity = rawMaterialsList[itemId].quantity + quantity
                    end
                end
            end
        end
    end
    --if SK.savedVars.debugMode then d(rawMaterialsList) end
    return rawMaterialsList
end

local function getPotentialRefineMaterials()
    local rawMaterialsList = {}
    for craftingInteractionType, _ in pairs(SKDI.RAW_MATERIALS_BY_TYPE) do
        rawMaterialsList = getPotentialRefineMaterialsByType(rawMaterialsList, craftingInteractionType)
    end
    for itemId, data in pairs(rawMaterialsList) do
        local itemType = GetItemType(data.bagId, data.slotIndex)
        if itemType == ITEMTYPE_RAW_MATERIAL then
            rawMaterialsList[itemId].quantity = rawMaterialsList[itemId].quantity / 3
        end
    end
    return rawMaterialsList
end

-- Export helper functions
SK.HelperFunctions.getWornItemLink = getWornItemLink
SK.HelperFunctions.returnItemLink = returnItemLink
SK.HelperFunctions.getNonStolenItemLink = getNonStolenItemLink
SK.HelperFunctions.isItemProtected = isItemProtected
SK.HelperFunctions.isItemDestroyProtected = isItemDestroyProtected
SK.HelperFunctions.isItemDeconstructionProtected = isItemDeconstructionProtected
SK.HelperFunctions.getItemTypeData = getItemTypeData
SK.HelperFunctions.getItemTypeName = getItemTypeName
SK.HelperFunctions.getItemTypeIcon = getItemTypeIcon
SK.HelperFunctions.getSetName = getSetName
SK.HelperFunctions.getTraitName = getTraitName
SK.HelperFunctions.getPotentialRefineMaterialsByType = getPotentialRefineMaterialsByType
SK.HelperFunctions.getPotentialRefineMaterials = getPotentialRefineMaterials
SK.HelperFunctions.isItemForLaunder = isItemForLaunder
SK.HelperFunctions.isStolenItemForDestroy = isStolenItemForDestroy
