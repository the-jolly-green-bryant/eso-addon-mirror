local AF = AdvancedFilters
local util = AF.util
local checkCraftingStationSlot = AF.checkCraftingStationSlot
local lib = util.LibMotifCategories
if lib == nil then return end

local function GetFilterCallbackForCraftableMotif()
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemLink = util.GetItemLink(slot)

        return lib:IsMotifCraftable(itemLink)
    end
end

local function GetFilterCallbackForKnownMotif()
    return function(slot, slotIndex)
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        local itemLink = util.GetItemLink(slot)

        return lib:IsMotifKnown(itemLink)
    end
end

local dropdownCallbacks = {
    [1] = {name = "CraftableMotif", filterCallback = GetFilterCallbackForCraftableMotif()},
    [2] = {name = "KnownMotif", filterCallback = GetFilterCallbackForKnownMotif()},
}

local styleDropdownCallbacks = {
    [1] = {name = "KnownMotif", filterCallback = GetFilterCallbackForKnownMotif()},
}

local strings = {
    ["MotifKnowledge"]  = "Motif knowledge",
    ["CraftableMotif"]  = "Craftable motif",
    ["KnownMotif"]      = "Known motif",
}
local stringsDE = {
    ["MotifKnowledge"]  = "Motiv Wissen",
    ["CraftableMotif"]  = "Herstellbare Motive",
    ["KnownMotif"]      = "Bekannte Motive",
}
local stringsFR = {
    ["MotifKnowledge"]  = "Motif connaissance",
    ["CraftableMotif"]  = "Motif artisanal",
    ["KnownMotif"]      = "Motif connu",
}
local stringsES = {
    ["MotifKnowledge"]  = "Conocimiento en diseños",
    ["CraftableMotif"]  = "Diseños fabricables",
    ["KnownMotif"]      = "Diseños conocidos",
}

local filterInformation = {
    pluginName = "AF_MotifKnowledgeFilters",
    submenuName = "MotifKnowledge",
    callbackTable = dropdownCallbacks,
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

filterInformation.submenuName = nil
filterInformation.callbackTable = styleDropdownCallbacks
filterInformation.filterType = ITEMFILTERTYPE_CRAFTING
filterInformation.subfilters = {"Style",}

AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.filterType = ITEMFILTERTYPE_STYLE_MATERIALS
filterInformation.subfilters = {"All",}

AdvancedFilters_RegisterFilter(filterInformation)