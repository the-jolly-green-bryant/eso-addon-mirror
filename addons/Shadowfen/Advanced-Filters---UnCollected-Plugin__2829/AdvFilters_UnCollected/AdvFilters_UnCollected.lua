local util = AdvancedFilters.util
local bankBags = {
    [BAG_SUBSCRIBER_BANK]   = true,
    [BAG_BANK]              = true,
    [BAG_HOUSE_BANK_ONE]    = true,
    [BAG_HOUSE_BANK_TWO]    = true,
    [BAG_HOUSE_BANK_THREE]  = true,
    [BAG_HOUSE_BANK_FOUR]   = true,
    [BAG_HOUSE_BANK_FIVE]   = true,
    [BAG_HOUSE_BANK_SIX]    = true,
    [BAG_HOUSE_BANK_SEVEN]  = true,
    [BAG_HOUSE_BANK_EIGHT]  = true,
    [BAG_HOUSE_BANK_NINE]   = true,
    [BAG_HOUSE_BANK_TEN]    = true,
}
 
local function GetFilterCallback()
    return function(slot, slotIndex)
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        local bagId, slotIndex = slot.bagId, slot.slotIndex
        if not bagId or not slotIndex then return false end
        
        --Only select non-collected collectable set items
		local itemLink = GetItemLink(bagId, slotIndex)
		
		local hasSet, setName = GetItemLinkSetInfo(itemLink)
		if hasSet == false then return false end
		
		local itemType = GetItemLinkItemType(itemLink)
		if IsItemLinkCrafted(itemLink) == true then return false end
		
		local itemId = GetItemLinkItemId(itemLink)
		local isCollected = IsItemSetCollectionPieceUnlocked(itemId)
		if isCollected == false then return true end
		return false
    end
end

local UnCollectedDropdownCallbacks = {
	[1] = {name = "UnCollected", filterCallback = GetFilterCallback()},
}

local en = {
	["UnCollected"] = "UnCollected",
}

local filterInformation = {
	callbackTable = UnCollectedDropdownCallbacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {
		[1] = "All",
	},
	enStrings = en,
}

AdvancedFilters_RegisterFilter(filterInformation)