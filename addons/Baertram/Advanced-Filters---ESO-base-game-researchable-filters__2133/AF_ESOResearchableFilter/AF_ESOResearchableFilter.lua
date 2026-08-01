local util = AdvancedFilters.util

local function GetFilterCallbackForESOResearchable(slot, slotIndex)
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        local bagId, slotIndex = slot.bagId, slot.slotIndex
        if not bagId or not slotIndex then return false end
        if (GetItemTraitInformation(bagId, slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED) then return true end
        return false
end

local dropdownCallback = {
    {name = "ESOResearchableFilter", filterCallback = GetFilterCallbackForESOResearchable},
}

local strings = {
    ["ESOResearchableFilter"] = "ESO - Researchable",
}
local stringsDE = {
    ["ESOResearchableFilter"] = "ESO - Analysierbar",
}
local stringsFR = {
    ["ESOResearchableFilter"] = "ESO - Recherche possible",
}
local stringsRU = {
    ["ESOResearchableFilter"] = "ESO - исследуемые",
}
local stringsJP = {
    ["ESOResearchableFilter"] = "ESO - 研究可能な",
}

--Add to weapons filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

--Add to armor filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_ARMOR,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

--Add to jewelry filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_JEWELRY,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

--Add to clothing crafting filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

--Add to smithing crafting filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

--Add to woodworking crafting filters
local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
    callbackTable = dropdownCallback,
    filterType = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    subfilters = {"All",},
    ruStrings = stringsRU,
    jpStrings = stringsJP,
    deStrings = stringsDE,
    frStrings = stringsFR,
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)


--Add to all filters, but only for the body and weapons and jewelry
filterInformation.filterType = ITEMFILTERTYPE_ALL
filterInformation.onlyGroups = {"Body"}
--Register the same filter again at the ALL inventory tab
AdvancedFilters_RegisterFilter(filterInformation)
