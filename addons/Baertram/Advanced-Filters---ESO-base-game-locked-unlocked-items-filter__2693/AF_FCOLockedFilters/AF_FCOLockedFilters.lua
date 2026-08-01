local util = AdvancedFilters.util
--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..." 
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForLockedItems(checkIfLocked)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		if checkIfLocked == true then
			return slot.isPlayerLocked == true
		else
			return not slot.isPlayerLocked
		end
		return false
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOLockedDropdownCallback = {
	{ name = "FCOLocked", filterCallback = GetFilterCallbackForLockedItems(true)},
	{ name = "FCOUnlocked", filterCallback = GetFilterCallbackForLockedItems(false)},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCOLockedStrings = {
	["FCOLockedSubmenu"] = GetString(SI_ITEM_ACTION_MARK_AS_LOCKED),
	["FCOLocked"] 	 = GetString(SI_ITEM_FORMAT_STR_LOCKED),
	["FCOUnlocked"]	 = GetString(SI_MARKET_PRODUCT_TOOLTIP_UNLOCK),
}

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	submenuName = "FCOLockedSubmenu",
	callbackTable = FCOLockedDropdownCallback,
	filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
	enStrings = enFCOLockedStrings,
	deStrings = enFCOLockedStrings,
	frStrings = enFCOLockedStrings,
	jpStrings = enFCOLockedStrings,
	ruStrings = enFCOLockedStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)
