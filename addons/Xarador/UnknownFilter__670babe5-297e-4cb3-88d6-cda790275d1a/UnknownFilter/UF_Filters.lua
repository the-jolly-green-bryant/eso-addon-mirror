-- UF_Filters.lua (robust, rückwärtskompatibel)
local UF = UnknownFilter

-- Safe wrapper
local function SafeGetItemLinkItemType(link)
    if not (link and GetItemLinkItemType) then return nil,nil end
    local ok, t, st = pcall(GetItemLinkItemType, link)
    if ok then return t, st end
    return nil, nil
end

-- Learnables (Rezepte / Pläne)
local function LearnableStatus(link)
    if not link or link=="" then return false,nil,"-" end
    local itemType = select(1, SafeGetItemLinkItemType(link))
    if itemType == ITEMTYPE_RECIPE and IsItemLinkRecipeKnown then
        local ok, known = pcall(IsItemLinkRecipeKnown, link)
        if ok then return true, (known==true), "Recipe/Plan" end
    end
    return false,nil,"-"
end

-- Motif / Buch
local function MotifBookStatus(link)
    if not link or link=="" then return false,nil,"-" end
    local itemType = select(1, SafeGetItemLinkItemType(link))
    if (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_BOOK) and IsItemLinkBookKnown then
        local ok, known = pcall(IsItemLinkBookKnown, link)
        if ok then return true, (known==true), "Motif/Book" end
    end
    return false,nil,"-"
end

-- Collectible Container (Runebox, Style Page)
local function CollectibleContainerStatus(link)
    if not link or link=="" then return false,nil,"-" end
    if not (GetItemLinkContainerCollectibleId and IsCollectibleUnlocked) then return false,nil,"-" end
    local ok, cid = pcall(GetItemLinkContainerCollectibleId, link)
    if ok and type(cid)=="number" and cid>0 then
        local ok2, known = pcall(IsCollectibleUnlocked, cid)
        if ok2 then return true, (known==true), "CollectibleId" end
    end
    return false,nil,"-"
end

-- Gear (Set Sammlung)
local function IsSetPieceUnlocked_Strict(link)
    if not link or link=="" then return false, "no-link" end

    -- 1) direkter Link
    if IsItemSetCollectionPieceUnlockedByItemLink then
        local ok, res = pcall(IsItemSetCollectionPieceUnlockedByItemLink, link)
        if ok and type(res)=="boolean" then return res, "piece-by-link" end
    end

    -- 2) PieceInfo APIs
    local setId, slotId, pieceId
    if GetItemLinkSetCollectionPieceInfo then
        local ok,a,b,c = pcall(GetItemLinkSetCollectionPieceInfo, link)
        if ok then setId,slotId,pieceId = a,b,c end
    elseif GetItemLinkSetCollectionInfo then
        local ok,a,b,c = pcall(GetItemLinkSetCollectionInfo, link)
        if ok then setId,slotId,pieceId = a,b,c end
    end

    if pieceId and IsItemSetCollectionPieceUnlocked then
        local ok, unlocked = pcall(IsItemSetCollectionPieceUnlocked, pieceId)
        if ok and type(unlocked)=="boolean" then return unlocked, "pieceId" end
    end

    if setId and slotId and IsItemSetCollectionSlotUnlocked then
        local ok, unlocked = pcall(IsItemSetCollectionSlotUnlocked, setId, slotId)
        if ok and type(unlocked)=="boolean" then return unlocked, "slot" end
    end

    -- 3) Fallback: ItemId
    if GetItemLinkItemId and IsItemSetCollectionPieceUnlocked then
        local okId, id = pcall(GetItemLinkItemId, link)
        if okId and type(id)=="number" and id>0 then
            local okU, un = pcall(IsItemSetCollectionPieceUnlocked, id)
            if okU and type(un)=="boolean" then return un, "fallback-itemId" end
        end
    end

    return false, "undetermined"
end

local function GearStatus(link)
    if not link or link=="" then return false,nil,"-" end
    local t = select(1, SafeGetItemLinkItemType(link))
    if not (t==ITEMTYPE_WEAPON or t==ITEMTYPE_ARMOR or t==ITEMTYPE_JEWELRY) then
        return false,nil,"not-gear"
    end
    if not (IsItemLinkSetCollectionPiece and IsItemLinkSetCollectionPiece(link)) then
        return false,nil,"not-set"
    end
    local unlocked, how = IsSetPieceUnlocked_Strict(link)
    return true, unlocked, how
end

-- Public API
function UF:Passes(link, mode)
    if not link or link=="" then return false,"no-link" end
    if     mode==self.MODE_GEAR    then local isSet, unlocked, how = GearStatus(link);              return (isSet and unlocked==false), how
    elseif mode==self.MODE_LEARN   then local isL, known,   how = LearnableStatus(link);            return (isL and known==false),      how
    elseif mode==self.MODE_MOTIF   then local isM, known,   how = MotifBookStatus(link);            return (isM and known==false),      how
    elseif mode==self.MODE_COLLECT then local isC, known,   how = CollectibleContainerStatus(link); return (isC and known==false),      how
    else return true, "off" end
end
