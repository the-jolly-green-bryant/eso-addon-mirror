local util = AdvancedFilters.util
--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForFCOUniqueItems(check)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--get the item link
		local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
		--Check if unique items should be shown, or not
		if itemLink ~= nil then
			return check == IsItemLinkUnique(itemLink)
		end
        return false
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOUniqueItemsDropdownCallback = {
	[1] = { name = "FCOUnique", filterCallback = GetFilterCallbackForFCOUniqueItems(true)},
	[2] = { name = "FCONonUnique", filterCallback = GetFilterCallbackForFCOUniqueItems(false)},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCOUniqueStrings = {
	["FCOUnique"] 	 = "Unique",
	["FCONonUnique"] = "Not unique",
}
local deFCOUniqueStrings = {
	["FCOUnique"] 	 = "Einzigartig",
	["FCONonUnique"] = "Nicht einzigartig",
}
local frFCOUniqueStrings = {
	["FCOUnique"] 	 = "Unique",
	["FCONonUnique"] = "Non unique",
}
local esFCOUniqueStrings = {
	["FCOUnique"] 	 = "�nico",
	["FCONonUnique"] = "No �nico",
}
local ruFCOUniqueStrings = {
	["FCOUnique"] 	 = "Unique",
	["FCONonUnique"] = "Not unique",
}

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	callbackTable = FCOUniqueItemsDropdownCallback,
	filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
	enStrings = enFCOUniqueStrings,
	deStrings = deFCOUniqueStrings,
	frStrings = frFCOUniqueStrings,
	esStrings = esFCOUniqueStrings,
	ruStrings = ruFCOUniqueStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)
