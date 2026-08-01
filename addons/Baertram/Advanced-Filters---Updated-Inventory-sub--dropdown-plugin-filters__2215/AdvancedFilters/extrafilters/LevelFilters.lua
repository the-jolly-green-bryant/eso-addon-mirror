local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot
local cpIcon = zo_iconFormat("/esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds", 18, 18)

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
local function GetFilterCallbackForLevel(minLevel, maxLevel)
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemLink = util.GetItemLink(slot)
        local level = GetItemLinkRequiredLevel(itemLink)
        local cp = GetItemLinkRequiredChampionPoints(itemLink)
        if cp > 0 then
            level = level + cp
        end
        if maxLevel ~= nil then
            return ((level >= minLevel) and (level <= maxLevel)) or false
        else
            return (level == minLevel) or false
        end
    end
end

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters'  master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local fullLevelDropdownCallbacks = {
    {name = "1-10", filterCallback = GetFilterCallbackForLevel(1, 10)},
    {name = "11-20", filterCallback = GetFilterCallbackForLevel(11, 20)},
    {name = "21-30", filterCallback = GetFilterCallbackForLevel(21, 30)},
    {name = "31-40", filterCallback = GetFilterCallbackForLevel(31, 40)},
    {name = "41-50", filterCallback = GetFilterCallbackForLevel(41, 50)},
    {name = "1-49",  filterCallback = GetFilterCallbackForLevel(1, 49)},
    {name = "cp10-160", filterCallback = GetFilterCallbackForLevel(60, 210)},
    {name = "cp10-20", filterCallback = GetFilterCallbackForLevel(60, 70)},
    {name = "cp30-40", filterCallback = GetFilterCallbackForLevel(80, 90)},
    {name = "cp50-60", filterCallback = GetFilterCallbackForLevel(100, 110)},
    {name = "cp70-80", filterCallback = GetFilterCallbackForLevel(120, 130)},
    {name = "cp90-100", filterCallback = GetFilterCallbackForLevel(140, 150)},
    {name = "cp110-120", filterCallback = GetFilterCallbackForLevel(160, 170)},
    {name = "cp130-140", filterCallback = GetFilterCallbackForLevel(180, 190)},
    {name = "cp150", filterCallback = GetFilterCallbackForLevel(200, nil)},
    {name = "cp150-160", filterCallback = GetFilterCallbackForLevel(200, 210)},
    {name = "cp160", filterCallback = GetFilterCallbackForLevel(210, nil)},
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
    ["LevelFilters"] = "Level Filters",
    ["1-10"] = "1-10",
    ["11-20"] = "11-20",
    ["21-30"] = "21-30",
    ["31-40"] = "31-40",
    ["41-50"] = "41-50",
    ["1-49"]  = "1-49",
    ["cp10-160"] = cpIcon .. "10-160",
    ["cp10-20"] = cpIcon .. "10-20",
    ["cp30-40"] = cpIcon .. "30-40",
    ["cp50-60"] = cpIcon .. "50-60",
    ["cp70-80"] = cpIcon .. "70-80",
    ["cp90-100"] = cpIcon .. "90-100",
    ["cp110-120"] = cpIcon .. "110-120",
    ["cp130-140"] = cpIcon .. "130-140",
    ["cp150"] = cpIcon .. "150",
    ["cp150-160"] = cpIcon .. "150-160",
    ["cp160"] = cpIcon .. "160",
}
local stringsDE = {
    --Remember to provide a string for your submenu if using one (see below).
    ["LevelFilters"] = "Level Filter",
}
stringsDE = setmetatable(stringsDE, {__index = strings})
local stringsES = {
    --Remember to provide a string for your submenu if using one (see below).
    ["LevelFilters"] = "Filtrar por nivel",
}
stringsES = setmetatable(stringsES, {__index = strings})

--[[----------------------------------------------------------------------------
    This section packages the data for Advanced Filters to use.
    All keys are required except for xxStrings, where xx is any implemented
        language shortcode that is not "en". A few language keys are assigned
        the same table here only for demonstrative purposes. You do not need to
        do this.
    The filterType key expects an ITEMFILTERTYPE constant provided by the game.
    The values for key/value pairs in the "subfilters" table can be any of the
        string keys from the "masterSubfilterData" table in files/filterCallbacks.lua such as
        "All", "OneHanded", "Body", or "Blacksmithing".
    If your filterType is ITEMFILTERTYPE_ALL then the "subfilters" table must
        only contain the value "All".
    If the field "submenuName" is defined, your filters will be placed into a
        submenu in the dropdown list rather then in the root dropdown list
        itself. "submenuName" takes a string which matches a key in your strings
        table(s).
--]]----------------------------------------------------------------------------
local filterInformation = {
    pluginName = "AF_LevelFilters",
    submenuName = "LevelFilters",
    callbackTable = fullLevelDropdownCallbacks,
    filterType = {
        ITEMFILTERTYPE_ALL,
        ITEMFILTERTYPE_WEAPONS, ITEMFILTERTYPE_ARMOR,
        ITEMFILTERTYPE_JEWELRY,
    },
    subfilters = {"All",},
    excludeGroups = {"Quest"},
    enStrings = strings,
    deStrings = stringsDE,
    frStrings = strings,
    ruStrings = strings,
    esStrings = stringsES,
}
--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)

--[[----------------------------------------------------------------------------
    If you only need to redefine some fields for the next registration, you can
        do that as well.
--]]----------------------------------------------------------------------------
filterInformation.filterType = ITEMFILTERTYPE_CONSUMABLE
filterInformation.subfilters = {"Food", "Drink", "Potion", "Poison",}
--[[----------------------------------------------------------------------------
    Again, register your filters by passing your new filter information to this
        function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)