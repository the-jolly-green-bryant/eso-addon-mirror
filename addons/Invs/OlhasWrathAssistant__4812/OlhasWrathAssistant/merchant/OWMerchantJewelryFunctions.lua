local owa = OWAssistant
local merchant = owa.Merchant

local function IsJewelry(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)

    return equipType == EQUIP_TYPE_RING
        or equipType == EQUIP_TYPE_NECK
end

merchant.RegisterCategory(
    "jewelry",
    function(profile, bagId, slotIndex, itemLink)
        if merchant.IsSelectedTraitMaterial(
            profile,
            "jewelry",
            itemLink
        ) then
            return true
        end

        return profile.enabled
            and IsJewelry(itemLink)
            and merchant.PassesEquipmentFilters(
                profile,
                bagId,
                slotIndex,
                itemLink
            )
    end
)
