local function SimpleFish()
	local fishCounter = 0
	local totalFish = 0
	local bag = BAG_BACKPACK
	local slot = 0
	local bagSlots = GetBagSize(bag) - 1
	while(slot<=bagSlots) do
		local itemType = GetItemType(bag, slot)
		if ITEMTYPE_FISH == itemType then
			fishCounter = GetItemTotalCount(bag, slot)
			totalFish = totalFish + fishCounter
		end
		slot = slot + 1
	end
	d("Total Fish:")
	d(totalFish)
end
	
SLASH_COMMANDS["/myfish"] = SimpleFish