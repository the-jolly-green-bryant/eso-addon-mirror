local util = AdvancedFilters.util
--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..." 
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForFCOStolenItems()
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		return slot.stolen
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOStolenDropdownCallback = {
	[1] = { name = "FCOStolen", filterCallback = GetFilterCallbackForFCOStolenItems()},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCOStolenStrings = {
	["FCOStolen"] 	 = "Stolen",
}
local deFCOStolenStrings = {
	["FCOStolen"] 	 = "Gestohlen",
}
local frFCOStolenStrings = {
	["FCOStolen"] 	 = "Volé",
}

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	callbackTable = FCOStolenDropdownCallback,
	filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
	enStrings = enFCOStolenStrings,
	deStrings = deFCOStolenStrings,
	frStrings = frFCOStolenStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)
