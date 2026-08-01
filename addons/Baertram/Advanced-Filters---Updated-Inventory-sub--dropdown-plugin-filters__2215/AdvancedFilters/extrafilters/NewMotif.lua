local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot
local lib = util.LibMotifCategories
if lib == nil then return end

local function GetFilterCallbackForNewMotif()
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemLink = util.GetItemLink(slot)

        return lib:IsNewMotif(itemLink)
    end
end

local dropdownCallback = {
    [1] = {name = "NewMotif", filterCallback = GetFilterCallbackForNewMotif()},
}

local strings = {
    ["NewMotif"] = "New motifs",
}
local stringsDE = {
    ["NewMotif"] = "Neue Motive",
}
local stringsFR = {
    ["NewMotif"] = "Nouveau motifs",
}
local stringsES = {
    ["NewMotif"] = "Diseños nuevos",
}

local filterInformation = {
    pluginName = "AF_NewMotifFilters",
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
    deStrings = stringsDE,
    enStrings = strings,
    frStrings = stringsFR,
	esStrings = stringsES,
}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_ARMOR
filterInformation.subfilters = {"Body", "Shield",}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_CONSUMABLE
filterInformation.subfilters = {"Motif",}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_CRAFTING
filterInformation.subfilters = {"Style",}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_STYLE_MATERIALS
filterInformation.subfilters = {"All",}

AdvancedFilters_RegisterFilter(filterInformation)