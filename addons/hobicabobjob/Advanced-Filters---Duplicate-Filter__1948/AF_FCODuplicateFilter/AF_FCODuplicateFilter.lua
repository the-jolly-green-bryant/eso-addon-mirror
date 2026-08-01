local util = AdvancedFilters.util

--[[----------------------------------------------------------------------------
    The anonymous function returned by this function handles the actual
        filtering.
    Use whatever parameters for "GetFilterCallback..." and whatever logic you
        need to in "function(slot)".
    "slot" is a table of item data. A typical slot can be found in
        PLAYER_INVENTORY.inventories[bagId].slots[slotIndex].
    A return value of true means the item in question will be shown while the
        filter is active. False means the item will be hidden while the filter
        is active.
--]]----------------------------------------------------------------------------
local function GetFilterCallbackForDuplicate()
    return function(slot, slotIndex)
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        local bagId, slotIndex = slot.bagId, slot.slotIndex
        if not bagId or not slotIndex then return false end
        local i = 0
        for k, s in pairs(SHARED_INVENTORY.bagCache[bagId]) do
	        if slot.name == s.name then
		        i = i + 1
            end
        end
        return false or i > 1
    end
end

local dropdownCallbacks = {
    {name = "DuplicateFilter", filterCallback = GetFilterCallbackForDuplicate()},
}

local strings = {
    ["DuplicateFilter"] = "Duplicates",
}
local stringsDE = {
    ["DuplicateFilter"] = "Doppelte",
}

--[[----------------------------------------------------------------------------
    This section packages the data for Advanced Filters to use.
    All keys are required except for xxStrings, where xx is any implemented
        language shortcode that is not "en". A few language keys are assigned
        the same table here only for demonstrative purposes. You do not need to
        do this.
    The filterType key expects an ITEMFILTERTYPE constant provided by the game.
    The values for key/value pairs in the "subfilters" table can be any of the
        string keys from the "masterSubfilterData" table in data.lua such as
        "All", "OneHanded", "Body", or "Blacksmithing".
    If your filterType is ITEMFILTERTYPE_ALL then the "subfilters" table must
        only contain the value "All".
    If the field "submenuName" is defined, your filters will be placed into a
        submenu in the dropdown list rather then in the root dropdown list
        itself. "submenuName" takes a string which matches a key in your strings
        table(s).
--]]----------------------------------------------------------------------------
local filterInformation = {
    filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
    callbackTable = dropdownCallbacks,
    enStrings = strings,
    deStrings = stringsDE,
}
AdvancedFilters_RegisterFilter(filterInformation)