local util = AdvancedFilters.util
local function GetFilterCallback()
	return function(slot, slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--get the item link
		local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
		if itemLink == nil then
			return false
		end
		--get the items bankcount
		local bagCount, bankCount = GetItemLinkStacks(itemLink)
		if bankCount == nil then
			return false
		end
		if bankCount == 0 then
			return false
		end
		return true
	end
end

local InBankDropdownCallbacks = {
	[1] = {name = "InBank", filterCallback = GetFilterCallback()},
}

local en = {
	["InBank"] = "In bank",
}
local de = {
	["InBank"] = "In der Bank",
}
local fr = {
	["InBank"] = "In bank",
}

local filterInformation = {
	callbackTable = InBankDropdownCallbacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {
		[1] = "All",
	},
	enStrings = en,
	deStrings = de,
	frStrings = fr,
}

AdvancedFilters_RegisterFilter(filterInformation)