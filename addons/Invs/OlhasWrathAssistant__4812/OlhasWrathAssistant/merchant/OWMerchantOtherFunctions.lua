local owa = OWAssistant
local merchant = owa.Merchant

merchant.RegisterCategory(
    "other",
    function(profile, bagId, slotIndex, itemLink)
        local itemType, specializedItemType =
            GetItemLinkItemType(itemLink)

        if profile.emptySoulGemsEnabled
            and itemType == ITEMTYPE_SOUL_GEM
            and IsItemSoulGem(
                SOUL_GEM_TYPE_EMPTY,
                bagId,
                slotIndex
            )
        then
            return true
        end

        if profile.fishingBaitEnabled
            and itemType == ITEMTYPE_LURE
        then
            return true
        end

        return profile.trophyFishEnabled
            and itemType == ITEMTYPE_COLLECTIBLE
            and specializedItemType
                == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH
    end
)
