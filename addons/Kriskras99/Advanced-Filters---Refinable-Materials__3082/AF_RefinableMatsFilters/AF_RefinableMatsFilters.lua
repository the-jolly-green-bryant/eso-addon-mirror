local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot

local refinementStackSize = GetRequiredSmithingRefinementStackSize()

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
local function GetFilterCallbackForRefinableMaterials(minLevel, maxLevel)
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemType = GetItemType(slot.bagId, slot.slotIndex)
        if itemType == ITEMTYPE_RAW_MATERIAL or 
           itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or 
           itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or
           itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
           itemType == ITEMTYPE_JEWELRY_RAW_TRAIT or
           itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or
           itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL then
            return GetSlotStackSize(slot.bagId, slot.slotIndex) >= refinementStackSize
        end
        return false 
    end
end

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters'  master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local refinableMaterialsCallback = {
    [1] = {name = "RefinableMaterials", filterCallback = GetFilterCallbackForRefinableMaterials()},
}

--[[----------------------------------------------------------------------------
    There are many potential tables for this section, each covering a different
        language supported by Advanced Filters. Only English is required. See
        AdvancedFilters/strings/ for a list of implemented languages.
    If other language tables are not included, the English table will
        automatically be used for those languages.
    All languages must share common keys.
--]]----------------------------------------------------------------------------
local strings = {
    --Remember to provide a string for your submenu if using one (see below).
    ["RefinableMaterials"] = "Refinable Materials",
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
    callbackTable = refinableMaterialsCallback,
    filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
    excludeGroups = {"Quest"},
	enStrings = strings,
}
--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)
