local util = AdvancedFilters.util
local function GetFilterCallback(name)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end

		local itemType, sItemType = GetItemType(slot.bagId, slot.slotIndex)
		
		return itemType == ITEMTYPE_COLLECTIBLE and (sItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE)
	end
end

local AFStylePageFilterCallBacks = {
	[1] = {name = "All Style Pages", filterCallback = GetFilterCallback("All Style Pages")},
}

local en = {
	["Style Page Filter"] = "Style Page Filter",
	["All Style Pages"] = "All Style Pages",
}


local filterInformation = {
	submenuName = "Style Page Filter",
	callbackTable = AFStylePageFilterCallBacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {"All Style Pages",},
	enStrings = en
}

AdvancedFilters_RegisterFilter(filterInformation)
