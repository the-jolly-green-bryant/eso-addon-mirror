local orgGetItemName = GetItemName

function GetItemName(bagId, slotIndex)
	local name = orgGetItemName(bagId, slotIndex)

	-- check for treasure maps outside of craft bag
	if bagId ~= BAG_VIRTUAL then
		local specializedItemType = select(2, GetItemType(bagId, slotIndex))
	
		if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT or specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
			name = name:gsub("Alik'r", "Alik'r Desert")
	
			if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
				name = "Treasure Map: " .. name:gsub(" Treasure Map", ""):gsub("Bleakrock", "Bleakrock Isle"):gsub("Orsinium", "Wrothgar")
			end
		end
	end

	return name
end