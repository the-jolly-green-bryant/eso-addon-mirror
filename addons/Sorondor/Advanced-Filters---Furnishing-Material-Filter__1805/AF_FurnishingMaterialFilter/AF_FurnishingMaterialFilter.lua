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
local function GetFilterCallback(filterTypes)
    if(not filterTypes) then return function(slot) return true end end

    return function(slot)
        local itemLink = AdvancedFilters.util.GetItemLink(slot)

        local itemType = GetItemLinkItemType(itemLink)

        for i = 1, #filterTypes do
            if filterTypes[i] == itemType then return true end
        end
    end
end

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters'  master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "FurnishingMaterial", filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL})},
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
    ["FurnishingMaterial"] = "Furnishing Material",
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
    callbackTable = dropdownCallbacks,
    filterType = ITEMFILTERTYPE_CRAFTING,
    subfilters = {"",}, --(Sorondor)this line is required only to register the filter
    enStrings = strings,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)
