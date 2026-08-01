local util = AdvancedFilters.util
local function GetFilterCallback(name)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end

		local itemType, sItemType = GetItemType(slot.bagId, slot.slotIndex)
		
		return itemType == ITEMTYPE_TROPHY and (sItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)
	end
end

local AFTreasureMapFilterCallBacks = {
	[1] = {name = "All Treasure Maps", filterCallback = GetFilterCallback("All Treasure Maps")},
}

local en = {
	["Treasure Map Filter"] = "Treasure Map Filter",
	["All Treasure Maps"] = "All Treasure Maps",
}


local filterInformation = {
	submenuName = "Treasure Map Filter",
	callbackTable = AFTreasureMapFilterCallBacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {"All Treasure Maps",},
	enStrings = en
}

AdvancedFilters_RegisterFilter(filterInformation)
