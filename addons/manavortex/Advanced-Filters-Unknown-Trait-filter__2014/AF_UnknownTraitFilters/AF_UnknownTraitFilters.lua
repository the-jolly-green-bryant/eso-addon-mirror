local util = AdvancedFilters.util

--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForFCOUnknownItems(check)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--get the item link
		local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
        
        return itemLink ~= nil and CanItemLinkBeTraitResearched(itemLink) 

	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOUnknownItemsDropdownCallback = {
	[1] = { name = "FCOUnknown", filterCallback = GetFilterCallbackForFCOUnknownItems(true)},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCOUnknownStrings = {
	["FCOUnknown"] 	 = "Unknown",
}
local deFCOUnknownStrings = {
	["FCOUnknown"] 	 = "Unbekannt",
}
local frFCOUnknownStrings = {
	["FCOUnknown"] 	 = "Unknown",
}
local esFCOUnknownStrings = {
	["FCOUnknown"] 	 = "desconocido",
}
local ruFCOUnknownStrings = {
	["FCOUnknown"] 	 = "Unknown",
}

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	callbackTable = FCOUnknownItemsDropdownCallback,
	filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
	enStrings = enFCOUnknownStrings,
	deStrings = deFCOUnknownStrings,
	frStrings = frFCOUnknownStrings,
	esStrings = esFCOUnknownStrings,
	ruStrings = ruFCOUnknownStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)
