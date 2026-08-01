local orgIsItemUsable = IsItemUsable

function IsItemUsable(bagId, slotIndex)
	if
		bagId == BAG_BACKPACK
		and not IsShiftKeyDown()
	then
		local itemType = GetItemType(bagId, slotIndex)

		if
			itemType == ITEMTYPE_CRAFTED_ABILITY
			or itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT
			or itemType == ITEMTYPE_RACIAL_STYLE_MOTIF
			or itemType == ITEMTYPE_RECIPE
		then
			return false
		end
	end

	return orgIsItemUsable(bagId, slotIndex)
end