--[[----------------------------------------------------------------------------
Version history
1.0     Initial release
1.1     Added Jewel Crafting Sketch support (Summerset)
1.2     This version brought to you by Baertram
        (all I did was fine tune the English localization)
        Localization support changes
        German localization added
        Added support for AdvancedFilters beta version by Baertram
1.3     French localization added (please PM me if you find mistakes)
        Overall housekeeping (I'm still learning)
1.4     Added Known/Unknown Recipe filters; filters only for current character
1.5     Fixed Consumable>>All>>Unknown recipe filter displays more than recipes
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

local function GetFilterCallback_KnownRecipe()
    
    return function(slot, slotIndex)
        
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        
        local itemLink = util.GetItemLink(slot)
        return IsItemLinkRecipeKnown(itemLink)
        
    end
end

local function GetFilterCallback_UnknownRecipe()

    return function(slot, slotIndex)

        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        
        local itemLink = util.GetItemLink(slot)
        local itemType = GetItemLinkItemType(itemLink)
        if itemType == ITEMTYPE_RECIPE then
            return not IsItemLinkRecipeKnown(itemLink)
        end
        
        return false
        
    end
end


-- Items >> Consumable >> Recipe >> Known/Unknown Recipe filters

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters' master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "KnownRecipe",    filterCallback = GetFilterCallback_KnownRecipe()},
    [2] = {name = "UnknownRecipe",  filterCallback = GetFilterCallback_UnknownRecipe()},
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
    ["KnownRecipe"]     = zo_strformat(SI_ITEM_FORMAT_STR_KNOWN_ITEM_TYPE, GetString(SI_ITEMTYPE29)), -- "Known Recipe"
    ["UnknownRecipe"]   = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),                               -- "Unknown Recipe"
}
local stringsDE = {
    ["KnownRecipe"]     = zo_strformat(SI_ITEM_FORMAT_STR_KNOWN_ITEM_TYPE, GetString(SI_ITEMTYPE29)),
    ["UnknownRecipe"]   = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
}
local stringsFR = {
    ["KnownRecipe"]     = zo_strformat(SI_ITEM_FORMAT_STR_KNOWN_ITEM_TYPE, GetString(SI_ITEMTYPE29)),
    ["UnknownRecipe"]   = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE),
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
    filterType = ITEMFILTERTYPE_CONSUMABLE,
    subfilters = {"Recipe",},
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)


-- Items >> Consumable >> Recipe >> Food/Drink/Furnishing Recipe dropdown filters

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters' master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "FoodRecipe",         filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD})},
    [2] = {name = "DrinkRecipe",        filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK})},
    [3] = {name = "FurnishingRecipe",   filterCallback = GetFilterCallback({
            SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING, 
            SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING, 
            SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING, 
            SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
            SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING, 
            SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING, 
            SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING})
    },
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
    ["FoodRecipe"]          = GetString(SI_ITEMTYPE4) .. " " .. GetString(SI_ITEMTYPE29),   -- "Food Recipe"
    ["DrinkRecipe"]         = GetString(SI_ITEMTYPE12) .. " " .. GetString(SI_ITEMTYPE29),  -- "Drink Recipe"
    ["FurnishingRecipe"]    = GetString(SI_ITEMTYPE61) .. " " .. GetString(SI_ITEMTYPE29),  -- "Furnishing Recipe"
}
local stringsDE = {
    ["FoodRecipe"]          = GetString(SI_ITEMTYPE4) .. " " .. GetString(SI_ITEMTYPE29),
    ["DrinkRecipe"]         = GetString(SI_ITEMTYPE12) .. " " .. GetString(SI_ITEMTYPE29),
    ["FurnishingRecipe"]    = GetString(SI_HOUSINGFURNISHINGLIMITTYPE0) .. " " .. GetString(SI_ITEMTYPE29),
}
local stringsFR = {
    ["FoodRecipe"]          = "Recette de " .. GetString(SI_ITEMTYPE4),
    ["DrinkRecipe"]         = "Recette de " .. GetString(SI_ITEMTYPE12),
    ["FurnishingRecipe"]    = "Recette de " .. GetString(SI_ITEMTYPE61),
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
    filterType = ITEMFILTERTYPE_CONSUMABLE,
    subfilters = {"Recipe",},
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)


-- Items >> Consumable >> Recipe >> Furnishing Recipe by Craft submenu filters

--[[----------------------------------------------------------------------------
    This table is processed within Advanced Filters and its contents are added
        to Advanced Filters'  master callback table.
    The string value for name is the relevant key for the language table.
--]]----------------------------------------------------------------------------
local dropdownCallbacks = {
    [1] = {name = "BlacksmithingDiagram",   filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING})},
    [2] = {name = "ClothierPattern",        filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING})},
    [3] = {name = "WoodworkingBlueprint",   filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING})},
    [4] = {name = "JewelryCraftingSketch",  filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING})},
    [5] = {name = "AlchemyFormula",         filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING})},
    [6] = {name = "EnchantingSchematic",    filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING})},
    [7] = {name = "ProvisioningDesign",     filterCallback = GetFilterCallback({SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING})},
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
    ["FurnishingRecipeByCraftSubmenu"]  = GetString(SI_SPECIALIZEDITEMTYPE210) .. " " .. GetString(SI_ITEMTYPE29) .. " by Craft",   -- "Furnishing Recipe by Craft"
    ["BlacksmithingDiagram"]            = GetString(SI_RECIPECRAFTINGSYSTEM1) .. " (" .. GetString(SI_ITEMFILTERTYPE13) .. ")",     -- "Diagrams (Blacksmithing)"
    ["ClothierPattern"]                 = GetString(SI_RECIPECRAFTINGSYSTEM2) .. " (" .. GetString(SI_ITEMFILTERTYPE14) .. ")",     -- "Patterns (Clothier)"
    ["WoodworkingBlueprint"]            = GetString(SI_RECIPECRAFTINGSYSTEM6) .. " (" .. GetString(SI_ITEMFILTERTYPE15) .. ")",     -- "Blueprints (Woodworking)"
    ["JewelryCraftingSketch"]           = GetString(SI_RECIPECRAFTINGSYSTEM7) .. " (" .. GetString(SI_ITEMFILTERTYPE24) .. ")",     -- "Sketches (Jewelry Crafting)"
    ["AlchemyFormula"]                  = GetString(SI_RECIPECRAFTINGSYSTEM4) .. " (" .. GetString(SI_ITEMFILTERTYPE16) .. ")",     -- "Formulae (Alchemy)"
    ["EnchantingSchematic"]             = GetString(SI_RECIPECRAFTINGSYSTEM3) .. " (" .. GetString(SI_ITEMFILTERTYPE17) .. ")",     -- "Praxis (Enchanting)"
    ["ProvisioningDesign"]              = GetString(SI_RECIPECRAFTINGSYSTEM5) .. " (" .. GetString(SI_ITEMFILTERTYPE18) .. ")",     -- "Designs (Provisioning)"
}
local stringsDE = {
    ["FurnishingRecipeByCraftSubmenu"]  = GetString(SI_HOUSINGFURNISHINGLIMITTYPE0) .. " " .. GetString(SI_ITEMTYPE29) .. " je " .. GetString(SI_QUESTTYPE4),
    ["BlacksmithingDiagram"]            = GetString(SI_RECIPECRAFTINGSYSTEM1) .. " (" .. GetString(SI_ITEMFILTERTYPE13) .. ")",
    ["ClothierPattern"]                 = GetString(SI_RECIPECRAFTINGSYSTEM2) .. " (" .. GetString(SI_ITEMFILTERTYPE14) .. ")",
    ["WoodworkingBlueprint"]            = GetString(SI_RECIPECRAFTINGSYSTEM6) .. " (" .. GetString(SI_ITEMFILTERTYPE15) .. ")",
    ["JewelryCraftingSketch"]           = GetString(SI_RECIPECRAFTINGSYSTEM7) .. " (" .. GetString(SI_ITEMFILTERTYPE24) .. ")",
    ["AlchemyFormula"]                  = GetString(SI_RECIPECRAFTINGSYSTEM4) .. " (" .. GetString(SI_ITEMFILTERTYPE16) .. ")",
    ["EnchantingSchematic"]             = GetString(SI_RECIPECRAFTINGSYSTEM3) .. " (" .. GetString(SI_ITEMFILTERTYPE17) .. ")",
    ["ProvisioningDesign"]              = GetString(SI_RECIPECRAFTINGSYSTEM5) .. " (" .. GetString(SI_ITEMFILTERTYPE18) .. ")",
}
local stringsFR = {
    ["FurnishingRecipeByCraftSubmenu"]  = "Recette de " .. GetString(SI_SPECIALIZEDITEMTYPE210) .. " par " .. GetString(SI_QUESTTYPE4),
    ["BlacksmithingDiagram"]            = GetString(SI_RECIPECRAFTINGSYSTEM1) .. " (" .. GetString(SI_ITEMFILTERTYPE13) .. ")",
    ["ClothierPattern"]                 = GetString(SI_RECIPECRAFTINGSYSTEM2) .. " (" .. GetString(SI_ITEMFILTERTYPE14) .. ")",
    ["WoodworkingBlueprint"]            = GetString(SI_RECIPECRAFTINGSYSTEM6) .. " (" .. GetString(SI_ITEMFILTERTYPE15) .. ")",
    ["JewelryCraftingSketch"]           = GetString(SI_RECIPECRAFTINGSYSTEM7) .. " (" .. GetString(SI_ITEMFILTERTYPE24) .. ")",
    ["AlchemyFormula"]                  = GetString(SI_RECIPECRAFTINGSYSTEM4) .. " (" .. GetString(SI_ITEMFILTERTYPE16) .. ")",
    ["EnchantingSchematic"]             = GetString(SI_RECIPECRAFTINGSYSTEM3) .. " (" .. GetString(SI_ITEMFILTERTYPE17) .. ")",
    ["ProvisioningDesign"]              = GetString(SI_RECIPECRAFTINGSYSTEM5) .. " (" .. GetString(SI_ITEMFILTERTYPE18) .. ")",
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
    submenuName = "FurnishingRecipeByCraftSubmenu",
    callbackTable = dropdownCallbacks,
    filterType = ITEMFILTERTYPE_CONSUMABLE,
    subfilters = {"Recipe",},
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
}

--[[----------------------------------------------------------------------------
    Register your filters by passing your filter information to this function.
--]]----------------------------------------------------------------------------
AdvancedFilters_RegisterFilter(filterInformation)
