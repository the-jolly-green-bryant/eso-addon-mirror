local util = AdvancedFilters.util
local function GetFilterCallback(name)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end

		local itemType, sItemType = GetItemType(slot.bagId, slot.slotIndex)
		
		return ((itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT) or (itemType == ITEMTYPE_CRAFTED_ABILITY)) and (
			(sItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY) or
			(sItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY) or
			(sItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY) or
			(sItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY)
		)
	end
end

local AFScribingScriptsFilterCallBacks = {
	[1] = {name = "All Scribing Scripts", filterCallback = GetFilterCallback("All Scribing Scripts")},
}

local en = {
	["Scribing Scripts Filter"] = "Scribing Scripts Filter",
	["All Scribing Scripts"] = "All Scribing Scripts",
}


local filterInformation = {
	submenuName = "Scribing Scripts Filter",
	callbackTable = AFScribingScriptsFilterCallBacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {"All Scribing Scripts",},
	enStrings = en
}

AdvancedFilters_RegisterFilter(filterInformation)
