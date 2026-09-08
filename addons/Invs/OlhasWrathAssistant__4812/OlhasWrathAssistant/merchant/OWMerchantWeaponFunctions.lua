local owa = OWAssistant
local merchant = owa.Merchant

local function IsShield(itemLink)
    return GetItemLinkItemType(itemLink) == ITEMTYPE_ARMOR
        and GetItemLinkEquipType(itemLink) == EQUIP_TYPE_OFF_HAND
end

local function IsWeaponOrShield(itemLink)
    return GetItemLinkItemType(itemLink) == ITEMTYPE_WEAPON
        or IsShield(itemLink)
end

merchant.RegisterCategory(
    "weapon",
    function(profile, bagId, slotIndex, itemLink)
        if merchant.IsSelectedTraitMaterial(
            profile,
            "weapon",
            itemLink
        ) then
            return true
        end

        return profile.enabled
            and IsWeaponOrShield(itemLink)
            and merchant.PassesEquipmentFilters(
                profile,
                bagId,
                slotIndex,
                itemLink
            )
    end
)
