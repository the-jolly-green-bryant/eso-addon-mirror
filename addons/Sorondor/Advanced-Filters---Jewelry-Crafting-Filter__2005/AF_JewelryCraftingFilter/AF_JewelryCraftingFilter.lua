--[[----------------------------------------------------------------------------
1.0 Initial release
1.1 Added "Ochre" to Items >> Materials >> All >> Jewelry Crafting (All) filter
         so that ALL Jewelry Crafting specific items can be viewed in one place
    Added Jewelry Crafting submenu to Items >> Materials >> All subfilter
    Added French and German localizations
--]]----------------------------------------------------------------------------

local util = AdvancedFilters.util

--[[----------------------------------------------------------------------------
    The anonymous function returned by this function handles the actual
        filtering.
    Use whatever parameters for "GetFilterCallback..." and whatever logic you
        need to in "function(slot)".
    "slot" is a table of item data. A typical slot can be found in
        PLAYER_INVENTORY.inventories[bagId].slots[slotIndex].
    "slotIndex" crafting stations will provide it in their filter functions
    A return value of true means the item in question will be shown while the
        filter is active. False means the item will be hidden while the filter
        is active.
--]]----------------------------------------------------------------------------
local function GetFilterCallback(filterTypes)
    if(not filterTypes) then return function(slot) return true end end

    return function(slot, slotIndex)

        --[[the following lines support the crafting stations, as they do not
            send the "slot" alone as parameter but the slot (=bagIndex of the
            inventory row in the crafting table) and the slotIndex. The function
            util.prepareSlot is just moving the slot (bagId) and the slotIndex
            to the "slot" variable itself:
                slot.bagId = slot
                slot.slotIndex = slotIndex
            So you are able to get the bagId and slotIndex from the slot
            variable afterwards in your code like this:
                local bagId, slotIndex = slot.bagId, slot.slotIndex
            (Baertam) ]]    
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end

        local itemLink = util.GetItemLink(slot)
        local _, itemType = GetItemLinkItemType(itemLink)
        for i = 1, #filterTypes do
            if filterTypes[i] == itemType then return true end
        end
    end
end


-- Items >> Materials >> All >> Jewelry Crafting (All) dropdown filter

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters' master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "JewelryCraftingAll", filterCallback = GetFilterCallback({
            SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
            SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
            SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
            SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
            SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT,
            SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT,
            SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING,
        })},
}

--[[----------------------------------------------------------------------------
    There are many potential tables for this section, each covering a different
        language supported by Advanced Filters. Only English is required. See
        AdvancedFilters/strings/ for a list of implemented languages.
    If other language tables are not included, the English table will
        automatically be used for those languages.
    All languages must share common keys.
--]]----------------------------------------------------------------------------
local stringsEN = {
    ["JewelryCraftingAll"] = GetString(SI_ITEMFILTERTYPE24) .. " (" .. GetString(SI_ITEMFILTERTYPE0) .. ")",  -- "Jewelry Crafting (All)"
}
local stringsDE = {
    ["JewelryCraftingAll"] = GetString(SI_ITEMFILTERTYPE24) .. " (" .. GetString(SI_ITEMFILTERTYPE0) .. ")",
}
local stringsFR = {
    ["JewelryCraftingAll"] = GetString(SI_ITEMFILTERTYPE24) .. " (" .. GetString(SI_ITEMFILTERTYPE0) .. ")",
}

--[[----------------------------------------------------------------------------
    This section packages the data for Advanced Filters to use.
    All keys are required except for xxStrings, where xx is any implemented
        language shortcode that is not "en".
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
    subfilters = {"",},  -- filter active in root (All) subfilter only
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)


-- Items >> Materials >> All >> Jewelry Crafting dropdown submenu filters

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters' master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "JewelryCraftingMaterialRaw",         filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL})},
    [2] = {name = "JewelryCraftingMaterial",            filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_MATERIAL})},
    [3] = {name = "JewelryCraftingPlatingRaw",          filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER})},
    [4] = {name = "JewelryCraftingPlating",             filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_BOOSTER})},
    [5] = {name = "JewelryCraftingTraitRaw",            filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT})},
    [6] = {name = "JewelryCraftingTrait",               filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT})},
    [7] = {name = "JewelryCraftingFurnishingMaterial",  filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING})},
}

--[[----------------------------------------------------------------------------
    There are many potential tables for this section, each covering a different
        language supported by Advanced Filters. Only English is required. See
        AdvancedFilters/strings/ for a list of implemented languages.
    If other language tables are not included, the English table will
        automatically be used for those languages.
    All languages must share common keys.
--]]----------------------------------------------------------------------------
local stringsEN = {
    ["JewelryCraftingFiltersSubmenu"]       = GetString(SI_ITEMFILTERTYPE24),           -- "Jewelry Crafting"
    ["JewelryCraftingMaterialRaw"]          = GetString(SI_SPECIALIZEDITEMTYPE2800),    -- "Raw Material"
    ["JewelryCraftingMaterial"]             = GetString(SI_SPECIALIZEDITEMTYPE2850),    -- "Material"
    ["JewelryCraftingPlatingRaw"]           = GetString(SI_SPECIALIZEDITEMTYPE3000),    -- "Raw Plating"
    ["JewelryCraftingPlating"]              = GetString(SI_SPECIALIZEDITEMTYPE2900),    -- "Plating"
    ["JewelryCraftingTraitRaw"]             = GetString(SI_SPECIALIZEDITEMTYPE3050),    -- "Raw Trait"
    ["JewelryCraftingTrait"]                = GetString(SI_SPECIALIZEDITEMTYPE2950),    -- "Jewelry Trait"
    ["JewelryCraftingFurnishingMaterial"]   = GetString(SI_SPECIALIZEDITEMTYPE2860),    -- "Furnishing Material"
}
local stringsDE = {
    ["JewelryCraftingFiltersSubmenu"]       = GetString(SI_ITEMFILTERTYPE24),
    ["JewelryCraftingMaterialRaw"]          = GetString(SI_SPECIALIZEDITEMTYPE2800),
    ["JewelryCraftingMaterial"]             = GetString(SI_SPECIALIZEDITEMTYPE2850),
    ["JewelryCraftingPlatingRaw"]           = GetString(SI_SPECIALIZEDITEMTYPE3000),
    ["JewelryCraftingPlating"]              = GetString(SI_SPECIALIZEDITEMTYPE2900),
    ["JewelryCraftingTraitRaw"]             = GetString(SI_SPECIALIZEDITEMTYPE3050),
    ["JewelryCraftingTrait"]                = GetString(SI_SPECIALIZEDITEMTYPE2950),
    ["JewelryCraftingFurnishingMaterial"]   = GetString(SI_SPECIALIZEDITEMTYPE2860),
}
local stringsFR = {
    ["JewelryCraftingFiltersSubmenu"]       = GetString(SI_ITEMFILTERTYPE24),
    ["JewelryCraftingMaterialRaw"]          = GetString(SI_SPECIALIZEDITEMTYPE2800),
    ["JewelryCraftingMaterial"]             = GetString(SI_SPECIALIZEDITEMTYPE2850),
    ["JewelryCraftingPlatingRaw"]           = GetString(SI_SPECIALIZEDITEMTYPE3000),
    ["JewelryCraftingPlating"]              = GetString(SI_SPECIALIZEDITEMTYPE2900),
    ["JewelryCraftingTraitRaw"]             = GetString(SI_SPECIALIZEDITEMTYPE3050),
    ["JewelryCraftingTrait"]                = GetString(SI_SPECIALIZEDITEMTYPE2950),
    ["JewelryCraftingFurnishingMaterial"]   = GetString(SI_SPECIALIZEDITEMTYPE2860),
}

--[[----------------------------------------------------------------------------
    This section packages the data for Advanced Filters to use.
    All keys are required except for xxStrings, where xx is any implemented
        language shortcode that is not "en".
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
    submenuName = "JewelryCraftingFiltersSubmenu",
    callbackTable = dropdownCallbacks,
    filterType = ITEMFILTERTYPE_CRAFTING,
    subfilters = {"",},  -- submenu/filters active in root (All) subfilter only
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)
