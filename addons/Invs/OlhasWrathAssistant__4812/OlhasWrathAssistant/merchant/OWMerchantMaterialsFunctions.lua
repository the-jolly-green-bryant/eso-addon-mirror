local owa = OWAssistant
local merchant = owa.Merchant

local RUBEDITE_INGOT_ITEM_ID = 64489
local RUBEDITE_ORE_ITEM_ID = 71198
local ANCESTOR_SILK_ITEM_ID = 64504
local RUBEDO_LEATHER_ITEM_ID = 64506
local SANDED_RUBY_ASH_ITEM_ID = 64502
local ROUGH_RUBY_ASH_ITEM_ID = 71199
local PLATINUM_OUNCE_ITEM_ID = 135146
local PLATINUM_DUST_ITEM_ID = 135145

local FABRIC_MATERIAL_IDS = {
    [811] = true,
    [4463] = true,
    [23125] = true,
    [23126] = true,
    [23127] = true,
    [46131] = true,
    [46132] = true,
    [46133] = true,
    [46134] = true,
    [ANCESTOR_SILK_ITEM_ID] = true,
}

local LEATHER_MATERIAL_IDS = {
    [794] = true,
    [4447] = true,
    [23099] = true,
    [23100] = true,
    [23101] = true,
    [46135] = true,
    [46136] = true,
    [46137] = true,
    [46138] = true,
    [RUBEDO_LEATHER_ITEM_ID] = true,
}

local function GetRefinedMaterialItemId(itemLink)
    if type(GetItemLinkRefinedMaterialItemLink) ~= "function" then
        return nil
    end

    local refinedItemLink =
        GetItemLinkRefinedMaterialItemLink(
            itemLink,
            LINK_STYLE_DEFAULT
        )

    if not refinedItemLink or refinedItemLink == "" then
        return nil
    end

    return GetItemLinkItemId(refinedItemLink)
end

merchant.RegisterCategory(
    "materials",
    function(profile, bagId, slotIndex, itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = GetItemLinkItemId(itemLink)

        if profile.blacksmithingEnabled
            and itemType == ITEMTYPE_BLACKSMITHING_MATERIAL
            and itemId ~= RUBEDITE_INGOT_ITEM_ID
        then
            return true
        end

        if profile.blacksmithingRawEnabled
            and itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
            and itemId ~= RUBEDITE_ORE_ITEM_ID
        then
            return true
        end

        if profile.clothingMaterialsEnabled
            and itemType == ITEMTYPE_CLOTHIER_MATERIAL
            and FABRIC_MATERIAL_IDS[itemId]
            and itemId ~= ANCESTOR_SILK_ITEM_ID
        then
            return true
        end

        if profile.leatherMaterialsEnabled
            and itemType == ITEMTYPE_CLOTHIER_MATERIAL
            and LEATHER_MATERIAL_IDS[itemId]
            and itemId ~= RUBEDO_LEATHER_ITEM_ID
        then
            return true
        end

        if itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL then
            local refinedItemId =
                GetRefinedMaterialItemId(itemLink)

            if profile.clothingRawMaterialsEnabled
                and FABRIC_MATERIAL_IDS[refinedItemId]
                and refinedItemId ~= ANCESTOR_SILK_ITEM_ID
            then
                return true
            end

            if profile.leatherRawMaterialsEnabled
                and LEATHER_MATERIAL_IDS[refinedItemId]
                and refinedItemId ~= RUBEDO_LEATHER_ITEM_ID
            then
                return true
            end
        end

        if profile.jewelryMaterialsEnabled
            and itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
            and itemId ~= PLATINUM_OUNCE_ITEM_ID
        then
            return true
        end

        if profile.woodworkingEnabled
            and itemType == ITEMTYPE_WOODWORKING_MATERIAL
            and itemId ~= SANDED_RUBY_ASH_ITEM_ID
        then
            return true
        end

        if profile.woodworkingRawEnabled
            and itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL
            and itemId ~= ROUGH_RUBY_ASH_ITEM_ID
        then
            return true
        end

        if profile.jewelryRawMaterialsEnabled
            and itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL
            and itemId ~= PLATINUM_DUST_ITEM_ID
        then
            return true
        end

        if merchant.IsSelectedFurnishingMaterial(
            profile,
            itemLink
        ) then
            return true
        end

        return itemType == ITEMTYPE_STYLE_MATERIAL
            and merchant.IsSelectedStyleMaterial(
                profile,
                itemLink
            )
    end
)
