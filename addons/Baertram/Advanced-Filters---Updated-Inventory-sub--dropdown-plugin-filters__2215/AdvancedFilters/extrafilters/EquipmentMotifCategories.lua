local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot
local lib = util.LibMotifCategories
if lib == nil then return end

local function GetFilterCallbackForMotifCategory(motifCategory)
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemLink = util.GetItemLink(slot)

        return lib:GetMotifCategory(itemLink) == motifCategory
    end
end

local dropdownCallbacks = {
    [1] = {name = "NormalStyle", filterCallback = GetFilterCallbackForMotifCategory(LMC_MOTIF_CATEGORY_NORMAL)},
    [2] = {name = "RareStyle", filterCallback = GetFilterCallbackForMotifCategory(LMC_MOTIF_CATEGORY_RARE)},
    [3] = {name = "AllianceStyle", filterCallback = GetFilterCallbackForMotifCategory(LMC_MOTIF_CATEGORY_ALLIANCE)},
    [4] = {name = "ExoticStyle", filterCallback = GetFilterCallbackForMotifCategory(LMC_MOTIF_CATEGORY_EXOTIC)},
    [5] = {name = "DroppedStyle", filterCallback = GetFilterCallbackForMotifCategory(LMC_MOTIF_CATEGORY_DROPPED)},
}

local strings = {
    ["MotifCategories"] = "Motif categories",
    ["NormalStyle"] = lib:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_NORMAL),
    ["RareStyle"] = lib:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_RARE),
    ["AllianceStyle"] = lib:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_ALLIANCE),
    ["ExoticStyle"] = lib:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_EXOTIC),
    ["DroppedStyle"] = lib:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_DROPPED),
}

local stringsDE = {
    ["MotifCategories"] = "Motiv Kategorien",
}
stringsDE = setmetatable(stringsDE, {__index = strings})
local stringsES = {
    ["MotifCategories"] = "Diseños por categoría",
}
stringsES = setmetatable(stringsES, {__index = strings})
local stringsFR = {
    ["MotifCategories"] = "Catégories de motifs",
}
stringsFR = setmetatable(stringsFR, {__index = strings})

local filterInformation = {
    pluginName = "AF_MotifCategoriesFilters",
    submenuName = "MotifCategories",
    callbackTable = dropdownCallbacks,
    filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
    deStrings = stringsDE,
	esStrings = stringsES,
    enStrings = strings,
    frStrings = stringsFR,
}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_ARMOR
filterInformation.subfilters = {"Body", "Shield", "Jewelry",}

AdvancedFilters_RegisterFilter(filterInformation)