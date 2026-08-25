GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy
local ADDON_NAME = GB.ADDON_NAME or "GatherBuddy"

------------------------------------------------------------
-- ALLOWED GATHERING ITEM TYPES
------------------------------------------------------------

local ALLOWED_ITEM_TYPES = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
    [ITEMTYPE_REAGENT] = true,
    [ITEMTYPE_POTION_BASE] = true,
    [ITEMTYPE_POISON_BASE] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
    [ITEMTYPE_FISH] = true,
    [ITEMTYPE_INGREDIENT] = true,
    [ITEMTYPE_FLAVORING] = true,
    [ITEMTYPE_SPICE] = true,
    [ITEMTYPE_FURNISHING_MATERIAL] = true,
}

------------------------------------------------------------
-- FISHING FURNISHINGS
------------------------------------------------------------

local FISHING_FURNISHING_ITEM_IDS = {
    [118337] = true, -- Fish, Trout
    [118338] = true, -- Fish, Bass
    [118339] = true, -- Fish, Salmon
    [118357] = true, -- Fish, Small
    [118358] = true, -- Fish, Medium
    [118359] = true, -- Fish, Large
}

------------------------------------------------------------
-- GATHERING FILTER
------------------------------------------------------------

local function IsGatheringItem(
    itemType,
    specializedItemType,
    itemId
)
    if ALLOWED_ITEM_TYPES[itemType] then
        return true
    end

    if itemType == ITEMTYPE_COLLECTIBLE
        and specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH then
        return true
    end

    if FISHING_FURNISHING_ITEM_IDS[itemId] then
        return true
    end

    return false
end

------------------------------------------------------------
-- LOOT
------------------------------------------------------------

local function OnLootReceived(
    eventCode,
    receivedBy,
    itemName,
    quantity,
    soundCategory,
    lootType,
    isSelf,
    isPickpocketLoot,
    questItemIcon,
    itemId,
    isStolen
)
    if not isSelf then
        return
    end

    local itemLink =
        string.format(
            "|H0:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            itemId
        )

    local itemType, specializedItemType =
        GetItemLinkItemType(
            itemLink
        )

    if not IsGatheringItem(
        itemType,
        specializedItemType,
        itemId
    ) then
        return
    end

    local cleanItemName =
        zo_strformat(
            SI_TOOLTIP_ITEM_NAME,
            GetItemLinkName(itemLink)
        )

    if cleanItemName == nil
        or cleanItemName == "" then
        cleanItemName = itemName
    end

    local itemQuality =
        GetItemLinkQuality(
            itemLink
        )

    if GB.sessionItems[itemId] == nil then
        GB.sessionItems[itemId] = {
            name = cleanItemName,
            quantity = 0,
            quality = itemQuality
        }
    end

    GB.sessionItems[itemId].quantity =
        GB.sessionItems[itemId].quantity
        + quantity

    if GB.UpdateMaterialList then
        GB.UpdateMaterialList()
    end

    CHAT_SYSTEM:AddMessage(
        "|c66FF66[Gather Buddy]|r "
            .. itemName
            .. " x"
            .. tostring(quantity)
    )
end

------------------------------------------------------------
-- TRACKING REGISTRATION
------------------------------------------------------------

function GB.RegisterTracking()
    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Loot",
        EVENT_LOOT_RECEIVED,
        OnLootReceived
    )
end