local owa = OWAssistant
local merchant = owa.Merchant

local function IsGlyph(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    return itemType == ITEMTYPE_GLYPH_ARMOR
        or itemType == ITEMTYPE_GLYPH_JEWELRY
        or itemType == ITEMTYPE_GLYPH_WEAPON
end

merchant.RegisterCategory(
    "enchanting",
    function(profile, bagId, slotIndex, itemLink)
        if merchant.IsSelectedEnchantingRune(
            profile,
            itemLink
        ) then
            return true
        end

        if not profile.enabled or not IsGlyph(itemLink) then
            return false
        end

        local quality = merchant.GetItemQuality(
            bagId,
            slotIndex
        )

        if not quality or quality > profile.maxQuality then
            return false
        end

        return true
    end
)
