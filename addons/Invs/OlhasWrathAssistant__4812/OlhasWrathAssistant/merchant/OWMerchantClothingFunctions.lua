local owa = OWAssistant
local merchant = owa.Merchant

local function IsClothing(itemLink)
    if GetItemLinkItemType(itemLink) ~= ITEMTYPE_ARMOR then
        return false
    end

    local armorType = GetItemLinkArmorType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)

    return equipType ~= EQUIP_TYPE_OFF_HAND
        and (
            armorType == ARMORTYPE_LIGHT
            or armorType == ARMORTYPE_MEDIUM
            or armorType == ARMORTYPE_HEAVY
        )
end

merchant.RegisterCategory(
    "clothing",
    function(profile, bagId, slotIndex, itemLink)
        if merchant.IsSelectedTraitMaterial(
            profile,
            "clothing",
            itemLink
        ) then
            return true
        end

        return profile.enabled
            and IsClothing(itemLink)
            and merchant.PassesEquipmentFilters(
                profile,
                bagId,
                slotIndex,
                itemLink
            )
    end
)
