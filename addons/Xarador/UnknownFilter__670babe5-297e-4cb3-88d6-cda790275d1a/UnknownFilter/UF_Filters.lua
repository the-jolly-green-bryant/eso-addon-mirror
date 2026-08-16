-- UF_Filters.lua
local UF = UnknownFilter

local function SafeGetItemType(link)
    if not (link and GetItemLinkItemType) then
        return nil, nil
    end

    local ok, itemType, specializedItemType = pcall(GetItemLinkItemType, link)
    if ok then
        return itemType, specializedItemType
    end
    return nil, nil
end

local function LearnableStatus(link)
    if not link or link == "" then
        return false, nil, "no-link"
    end

    local itemType = SafeGetItemType(link)
    if itemType == ITEMTYPE_RECIPE and IsItemLinkRecipeKnown then
        local ok, known = pcall(IsItemLinkRecipeKnown, link)
        if ok then
            return true, known == true, "recipe"
        end
    end

    return false, nil, "not-learnable"
end

local function MotifBookStatus(link)
    if not link or link == "" then
        return false, nil, "no-link"
    end

    local itemType = SafeGetItemType(link)
    if (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_BOOK)
        and IsItemLinkBookKnown
    then
        local ok, known = pcall(IsItemLinkBookKnown, link)
        if ok then
            return true, known == true, "motif-book"
        end
    end

    return false, nil, "not-motif"
end

local function CollectibleContainerStatus(link)
    if not link or link == "" then
        return false, nil, "no-link"
    end
    if not (GetItemLinkContainerCollectibleId and IsCollectibleUnlocked) then
        return false, nil, "unsupported"
    end

    local ok, collectibleId = pcall(GetItemLinkContainerCollectibleId, link)
    if ok and type(collectibleId) == "number" and collectibleId > 0 then
        local unlockedOk, unlocked = pcall(IsCollectibleUnlocked, collectibleId)
        if unlockedOk then
            return true, unlocked == true, "collectible"
        end
    end

    return false, nil, "not-collectible"
end

local function GetSetCollectionStatus(link)
    if not (GetItemLinkSetInfo
        and GetItemLinkItemSetCollectionSlot
        and IsItemSetCollectionSlotUnlocked)
    then
        return false, "unsupported"
    end

    local setInfo = { pcall(GetItemLinkSetInfo, link, false) }
    if not setInfo[1] or setInfo[2] ~= true then
        return false, "no-set"
    end

    -- pcall adds its success flag at index 1; GetItemLinkSetInfo returns setId sixth.
    local itemSetId = setInfo[7]
    local slotOk, collectionSlot = pcall(GetItemLinkItemSetCollectionSlot, link)
    if type(itemSetId) ~= "number" or itemSetId <= 0 or not slotOk or not collectionSlot then
        return false, "undetermined"
    end

    local unlockedOk, unlocked = pcall(IsItemSetCollectionSlotUnlocked, itemSetId, collectionSlot)
    if unlockedOk and type(unlocked) == "boolean" then
        return unlocked, "collection-slot"
    end

    return false, "undetermined"
end

local function GearStatus(link)
    if not link or link == "" then
        return false, nil, "no-link"
    end

    local itemType = SafeGetItemType(link)
    if itemType ~= ITEMTYPE_WEAPON and itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_JEWELRY then
        return false, nil, "not-gear"
    end

    if not IsItemLinkSetCollectionPiece then
        return false, nil, "unsupported"
    end

    local isPieceOk, isCollectionPiece = pcall(IsItemLinkSetCollectionPiece, link)
    if not isPieceOk or not isCollectionPiece then
        return false, nil, "not-set-piece"
    end

    local unlocked, method = GetSetCollectionStatus(link)
    return true, unlocked, method
end

function UF:Passes(link, mode)
    if not link or link == "" then
        return false, "no-link"
    end

    if mode == self.MODE_GEAR then
        local applies, known, method = GearStatus(link)
        return applies and known == false, method
    elseif mode == self.MODE_LEARN then
        local applies, known, method = LearnableStatus(link)
        return applies and known == false, method
    elseif mode == self.MODE_MOTIF then
        local applies, known, method = MotifBookStatus(link)
        return applies and known == false, method
    elseif mode == self.MODE_COLLECT then
        local applies, known, method = CollectibleContainerStatus(link)
        return applies and known == false, method
    end

    return true, "off"
end
