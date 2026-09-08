local owa = OWAssistant
local merchant = owa.Merchant

merchant.RegisterCategory(
    "resources",
    function(profile, bagId, slotIndex, itemLink)
        return merchant.IsSelectedResourceIngredient(
                profile,
                itemLink
            )
            or merchant.IsSelectedAlchemySolvent(
                profile,
                itemLink
            )
    end
)
