AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

local util = AF.util
local ugil = util.GetItemLink

local debugSpam = AF.debugSpam

local itemIds = AF.itemIds

--Local speedup
local isInTab   = ZO_IsElementInNumericallyIndexedTable
local isij      = IsItemJunk
local gileqt    = GetItemLinkEquipType
local gilat     = GetItemLinkArmorType
local gilwt     = GetItemLinkWeaponType
local gilit     = GetItemLinkItemType
local gilii     = GetItemLinkInfo
local gilfti    = GetItemLinkFilterTypeInfo
local gilti     = GetItemLinkTraitInfo
local giliid    = GetItemLinkItemId
local iils      = IsItemLinkStolen
--local IFUgsitbitdc = ITEM_FILTER_UTILS.GetSpecializedItemTypesByItemTypeDisplayCategory
local IFUgsitbitdc = ZO_ItemFilterUtils.GetSpecializedItemTypesByItemTypeDisplayCategory
local IFUisfdiitdc = ZO_ItemFilterUtils.IsSlotFilterDataInItemTypeDisplayCategory

local checkForResearchPanelAndRunFilterFunction = util.CheckForResearchPanelAndRunFilterFunction

------------------------------------------------------------------------------------------------------------------------
-- Lookup tables
------------------------------------------------------------------------------------------------------------------------
--Trophy itemTypes (all trophies)
local allItemTypesTrophies = {
    [ITEMTYPE_TROPHY] = true,                                   [ITEMTYPE_COLLECTIBLE] = true,                          [ITEMTYPE_FISH] = true,
    [ITEMTYPE_TREASURE] = true,                                 [ITEMTYPE_RECALL_STONE] = true,                         [ITEMTYPE_CONSUMABLE_ABILITY] = true,
    [ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = true,                   [ITEMTYPE_CRAFTED_ABILITY] = true,
}
--Non fencable itemTypes
local nonFencableItemTypes = {
    [ITEMTYPE_GLYPH_ARMOR] = true,                              [ITEMTYPE_GLYPH_JEWELRY] = true,                        [ITEMTYPE_GLYPH_WEAPON] = true,
    [ITEMTYPE_SOUL_GEM] = true,                                 [ITEMTYPE_SIEGE] = true,                                [ITEMTYPE_LURE] = true,
    [ITEMTYPE_TOOL] = true,                                     [ITEMTYPE_TRASH] = true,
}



------------------------------------------------------------------------------------------------------------------------
-- Other addons helper
---------------------------------------------------------------------------------------------------------------------------
--FCOCompanion
local FCOCompanionJunkEnabled = false
local junkFunctionsUpdateDone = false
local checkForOtherAddonFlags = AF.util.CheckForOtherAddonFlags


------------------------------------------------------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------------------------------------------------------
--NO filter types are given, and we need to check for junkable items
local function checkNoFilterTypesOrIsJunk(slot, junkCheck)
    --Shall we check only junk items?
    if junkCheck and slot.bagId and slot.slotIndex then
        --Check if the junk API functions need a new reassign, if maybe other addons ave hooked into them later
        if not junkFunctionsUpdateDone then
            FCOCompanionJunkEnabled = checkForOtherAddonFlags()
            if FCOCompanionJunkEnabled == true then
                isij = IsItemJunk
                junkFunctionsUpdateDone = true
            end
            junkFunctionsUpdateDone = true
        end
        return isij(slot.bagId, slot.slotIndex)
    end
    --No junk but must be junk, and no slot data to check: Disallow/Filter out
    if junkCheck then return false end
    --No filtertypes, no junk or no slot data: Allow/Show
    return true
end


local function increaseCounterIfFoundInNummericallyIndexedTable(tableName, searchValues, counter)
    for _, searchValue in ipairs(searchValues) do
        if isInTab(tableName, searchValue) == true then
            counter = counter + 1
        end
    end
    return counter
end

local function checkExcludedTypes(itemLink, excludeThisTypes)
    if not excludeThisTypes then return true end
    local itemType, spezializedItemType, armorType, weaponType, equipType
    for excludeTypeToCheck, excludedTypesTab in pairs(excludeThisTypes) do
        if excludedTypesTab and (#excludedTypesTab > 0 or NonContiguousCount(excludedTypesTab) > 0) then
            if excludeTypeToCheck == "equipType" then
                equipType = equipType or gileqt(itemLink)
                if excludedTypesTab[equipType] or isInTab(excludedTypesTab, equipType) then return false end

            elseif excludeTypeToCheck == "armorType" then
                armorType = armorType or gilat(itemLink)
                if excludedTypesTab[armorType] or isInTab(excludedTypesTab, armorType) then return false end

            elseif excludeTypeToCheck == "weaponType" then
                weaponType = weaponType or gilwt(itemLink)
                if excludedTypesTab[weaponType] or isInTab(excludedTypesTab, weaponType) then return false end

            elseif excludeTypeToCheck == "itemType" then
                if itemType == nil or spezializedItemType == nil then
                    itemType, spezializedItemType = gilit(itemLink)
                end
--d(string.format(">[%s] checkExcludedTypes - itemType: %s", itemLink, tostring(itemType)))
                if excludedTypesTab[itemType] or isInTab(excludedTypesTab, itemType) then
--d("<<excluded by itemType!")
                    return false
                end

            elseif excludeTypeToCheck == "specializedItemType" then
                if itemType == nil or spezializedItemType == nil then
                    itemType, spezializedItemType = gilit(itemLink)
                end
--d(string.format(">[%s] checkExcludedTypes - specializedItemType: %s", itemLink, tostring(spezializedItemType)))
                if excludedTypesTab[spezializedItemType] or isInTab(excludedTypesTab, spezializedItemType) then
--d("<<excluded by spezializedItemType!")
                    return false
                end
            end
        end
    end
    return true
end


local function checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory, isCompanionItem)
    isCompanionItem = isCompanionItem or false
    if slot ~= nil and itemLink ~= nil and itemTypeDisplayCategory ~= nil then
        local slotCopy = ZO_ShallowTableCopy(slot)
        --Prevent only comparison against junk itemTypeDisplayCategory within ZO_ItemFilterUtils.IsSlotFilterDataInItemTypeDisplayCategory
        -->by removing the isJunk identifier and adding it, if neccessary, after the comparison
        if slotCopy.isJunk ~= nil and slotCopy.isJunk == true then
            slotCopy.isJunk = nil
        end
        if slotCopy.filterData == nil then
            local filterData =  { gilfti(itemLink) }
            slotCopy.filterData = filterData
            --Update the filterData to the slot too
            slot.filterData = filterData
        end
        --local isSlotFilterDataInItemTypeDisplayCategory = ITEM_FILTER_UTILS.IsSlotFilterDataInItemTypeDisplayCategory(slot, itemTypeDisplayCategory)
        --Info: 3rd param isCompanionItem is a compatibility fix for FCOCompanion's feature "Companion junk" where the ZOs function get#s changed and the new 3rd param gets added
        local isSlotFilterDataInItemTypeDisplayCategory = IFUisfdiitdc(slotCopy, itemTypeDisplayCategory, isCompanionItem)

        if not isSlotFilterDataInItemTypeDisplayCategory then return false end
    end
    return true
end

------------------------------------------------------------------------------------------------------------------------
-- Subfilter callback functions
---------------------------------------------------------------------------------------------------------------------------
--Check if the first parameter "slot" is the bagId of a crafting station item row, or the dataEntry.data table of another
--inventory row and prepare the slot variable then properly for the filter functions
local prepareSlot = util.prepareSlot
local function checkCraftingStationSlot(slot, slotIndex)
    if prepareSlot and slotIndex ~= nil and type(slot) ~= "table" then
        --Slot is the bagId!
        slot = prepareSlot(slot, slotIndex)
    end
    return slot
end
AF.checkCraftingStationSlot = checkCraftingStationSlot

--QuickSlot
--[[
local function AF_QS_FilterFunctionForQS_ShouldAddItemToSlot(itemData)
    local itemTypeFilter = QUICKSLOT_WINDOW.currentFilter.extraInfo and QUICKSLOT_WINDOW.currentFilter.extraInfo.AF_QSFilter_ItemTypes
    if itemTypeFilter then
        local itemType = GetItemType(itemData.bagId, itemData.slotIndex)
        if not itemTypeFilter[itemType] then
            return false
        end
    end
    return true
end
]]

local function filterCallbackChecks(slot, slotIndex, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    slot = checkCraftingStationSlot(slot, slotIndex)
    if not filterTypes and not itemTypeDisplayCategory then
        return checkNoFilterTypesOrIsJunk(slot, checkOnlyJunk)
    end
    if checkOnlyJunk == true then
        if not checkNoFilterTypesOrIsJunk(slot, true) then
            return false
        end
    end
    local itemLink = ugil(slot)
    if not itemLink then return false end

    if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory, nil) then
        return false
    else
        if not filterTypes then
            return true
        end
    end

    local itemId = giliid(itemLink)
    local itemType = gilit(itemLink)

    if addFilterTypesToMatch ~= nil then
        local itemFilterTypes = {gilfti(itemLink)}
        local matchesFound = 0
        matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
        if matchesFound ~= #addFilterTypesToMatch then
            return false
        end
    end

    local numFilterTypes = #filterTypes
    for i=1, numFilterTypes do
        if filterTypes[i] == itemType then
            if excludeTheseItemIds then
                if type(excludeTheseItemIds) == "table" then
                    for _, itemIdToExclude in ipairs(excludeTheseItemIds) do
                        if itemId == itemIdToExclude then
                            return false
                        end
                    end
                else
                    if itemId == excludeTheseItemIds then
                        return false
                    end
                end
            end
            return checkExcludedTypes(itemLink, excludeThisTypes)
        end
    end
    return false
end

local function GetFilterCallbackForWeaponType(filterTypes, checkOnlyJunk, addFilterTypesToMatch, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then
            return false
        end

        local weaponType = gilwt(itemLink)
        if addFilterTypesToMatch ~= nil then
            local itemFilterTypes = {gilfti(itemLink)}
            local matchesFound = 0
            matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
            if matchesFound ~= #addFilterTypesToMatch then
                return false
            end
        end

        for i=1, #filterTypes do
            if(filterTypes[i] == weaponType) then
                return true
            end
        end
        return false
    end
end

local function GetFilterCallbackForArmorType(filterTypes, checkOnlyJunk, addFilterTypesToMatch, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local armorType = gilat(itemLink)
        if addFilterTypesToMatch ~= nil then
            local itemFilterTypes =  {gilfti(itemLink)}
            local matchesFound = 0
            matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
            if matchesFound ~= #addFilterTypesToMatch then
                return false
            end
        end

        for i=1, #filterTypes do
            if(filterTypes[i] == armorType) then
                return true
            end
        end
        return false
    end
end

local function GetFilterCallbackForGear(filterTypes, armorTypes, checkOnlyJunk, addFilterTypesToMatch, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local goOn = false
        if addFilterTypesToMatch ~= nil then
            local itemFilterTypes = {gilfti(itemLink)}
            local matchesFound = 0
            matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
            if matchesFound ~= #addFilterTypesToMatch then
                return false
            end
        end

        if armorTypes ~= nil then
            local armorType = gilat(itemLink)
            for i=1, #armorTypes do
                if armorTypes[i] == armorType then
                    goOn = true
                    break
                end
            end
        else
            goOn = true
        end
        if goOn then
            local _, _, _, equipType = gilii(itemLink)

            for i=1, #filterTypes do
                if filterTypes[i] == equipType then
                    return true
                end
            end
        end
        return false
    end
end

local function GetFilterCallbackForJewelry(filterTypes, itemTraitType, checkOnlyJunk, addFilterTypesToMatch, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local _, _, _, equipType = gilii(itemLink)
        if addFilterTypesToMatch ~= nil then
            local itemFilterTypes = {gilfti(itemLink)}
            local matchesFound = 0
            matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
            if matchesFound ~= #addFilterTypesToMatch then
                return false
            end
        end

        for i=1, #filterTypes do
            if filterTypes[i] == equipType then
                local checkItemTraitType = gilti(itemLink)
                if itemTraitType == checkItemTraitType then
                    return true
                end
            end
        end
        return false
    end
end

local function GetFilterCallbackForClothing(checkOnlyJunk, addFilterTypesToMatch, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local armorType = gilat(itemLink)
        local _, _, _, equipType = gilii(itemLink)

        if addFilterTypesToMatch ~= nil then
            local itemFilterTypes = {gilfti(itemLink)}
            local matchesFound = 0
            matchesFound = increaseCounterIfFoundInNummericallyIndexedTable(addFilterTypesToMatch, itemFilterTypes, matchesFound)
            if matchesFound ~= #addFilterTypesToMatch then
                return false
            end
        end

        if((armorType == ARMORTYPE_NONE) and
          (equipType ~= EQUIP_TYPE_NECK) and (equipType ~= EQUIP_TYPE_MAIN_HAND) and
          (equipType ~= EQUIP_TYPE_OFF_HAND) and (equipType ~= EQUIP_TYPE_ONE_HAND) and
          (equipType ~= EQUIP_TYPE_TWO_HAND) and (equipType ~= EQUIP_TYPE_RING)
            --and (equipType ~= EQUIP_TYPE_COSTUME) !!!Disabled as Clothing was disabled in Armor, and Vanity was moved to Miscelaneous
           and (equipType ~= EQUIP_TYPE_INVALID)) then
            return true
        end
        return false
    end
end

local function GetFilterCallbackForTrophy(checkOnlyJunk, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local itemType = gilit(itemLink)
        --if not iils(itemLink) and (itemType == ITEMTYPE_TROPHY
        if allItemTypesTrophies[itemType] == true then
            return true
        end
        return false
    end
end

local function GetFilterCallbackForFence(checkOnlyJunk, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        local itemType = gilit(itemLink)
        if iils(itemLink) and (not nonFencableItemTypes[itemType]) then
            if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end
            return true
        end
        return false
    end
end

local function GetFilterCallbackForStolen(checkOnlyJunk, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end
        if iils(itemLink) then
            if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end
--d("[AF]GetFilterCallbackForStolen: " ..itemLink)
            return true
        end
        return false
    end
end

--[[
local function GetFilterCallbackForProvisioningIngredient(ingredientType)
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local lookup = {
            --meats (health)
            ["28609"] = "Food", --Game
            ["33752"] = "Food", --Red Meat
            ["33753"] = "Food", --Fish
            ["33754"] = "Food", --White Meat
            ["33756"] = "Food", --Small Game
            ["34321"] = "Food", --Poultry
            --fruits (magicka)
            ["28603"] = "Food", --Tomato
            ["28610"] = "Food", --Jazbay Grapes
            ["33755"] = "Food", --Bananas
            ["34308"] = "Food", --Melon
            ["34311"] = "Food", --Apples
            ["34305"] = "Food", --Pumpkin
            --vegetables (stamina)
            ["28604"] = "Food", --Greens
            ["33758"] = "Food", --Potato
            ["34307"] = "Food", --Radish
            ["34309"] = "Food", --Beets
            ["34323"] = "Food", --Corn
            ["34324"] = "Food", --Carrots
            --dish additives
            ["26954"] = "Food", --Garlic
            ["27057"] = "Food", --Cheese
            ["27058"] = "Food", --Seasoning
            ["27063"] = "Food", --Saltrice
            ["27064"] = "Food", --Millet
            ["27100"] = "Food", --Flour
            --rare dish additive
            ["26802"] = "Food", --Frost Mirriam
            --alcoholic (health)
            ["28639"] = "Drink", --Rye
            ["29030"] = "Drink", --Rice
            ["33774"] = "Drink", --Yeast
            ["34329"] = "Drink", --Barley
            ["34345"] = "Drink", --Surilie Grapes
            ["34348"] = "Drink", --Wheat
            --tea (magicka)
            ["28636"] = "Drink", --Rose
            ["33768"] = "Drink", --Comberry
            ["33771"] = "Drink", --Jasmine
            ["33773"] = "Drink", --Mint
            ["34330"] = "Drink", --Lotus
            ["34334"] = "Drink", --Bittergreen
            --tonic (stamina)
            ["33772"] = "Drink", --Coffee
            ["34333"] = "Drink", --Guarana
            ["34335"] = "Drink", --Yerba Mate
            ["34346"] = "Drink", --Gingko
            ["34347"] = "Drink", --Ginseng
            ["34349"] = "Drink", --Acai Berry
            --drink additives
            ["27035"] = "Drink", --Isinglass
            ["27043"] = "Drink", --Honey
            ["27048"] = "Drink", --Metheglin
            ["27049"] = "Drink", --Lemon
            ["27052"] = "Drink", --Ginger
            ["28666"] = "Drink", --Seaweed
            --rare drink additive
            ["27059"] = "Drink", --Bervez Juice
            --old ingredients
            ["26962"] = "Old", --Old Pepper
            ["26966"] = "Old", --Old Drippings
            ["26974"] = "Old", --Old Cooking Fat
            ["26975"] = "Old", --Old Suet
            ["26976"] = "Old", --Old Lard
            ["26977"] = "Old", --Old Fatback
            ["26978"] = "Old", --Old Pinguis
            ["26986"] = "Old", --Old Thin Broth
            ["26987"] = "Old", --Old Broth
            ["26988"] = "Old", --Old Stock
            ["26989"] = "Old", --Old Jus
            ["26990"] = "Old", --Old Glace Viande
            ["26998"] = "Old", --Old Imperial Stock
            ["26999"] = "Old", --Old Meal
            ["27000"] = "Old", --Old Milled Flour
            ["27001"] = "Old", --Old Sifted Flour
            ["27002"] = "Old", --Old Cake Flour
            ["27003"] = "Old", --Old Baker's Flour
            ["27004"] = "Old", --Old Imperial Flour
            ["27044"] = "Old", --Old Saaz Hops
            ["27051"] = "Old", --Old Jazbay Grapes
            ["27053"] = "Old", --Old Canis Root
            ["28605"] = "Old", --Old Scuttle Meat
            ["28606"] = "Old", --Old Plump Worms^p
            ["28607"] = "Old", --Old Plump Rodent Toes^p
            ["28608"] = "Old", --Old Plump Maggots^p
            ["28632"] = "Old", --Old Snake Slime
            ["28634"] = "Old", --Old Snake Venom
            ["28635"] = "Old", --Old Wild Honey
            ["28637"] = "Old", --Old Sujamma Berries^P
            ["28638"] = "Old", --Old River Grapes^p
            ["33757"] = "Old", --Old Venison
            ["33767"] = "Old", --Old Shornhelm Grains^p
            ["33769"] = "Old", --Old Tangerine
            ["33770"] = "Old", --Old Wasp Squeezings
            ["34304"] = "Old", --Old Pork
            ["34306"] = "Old", --Old Sweetmeats^p
            ["34312"] = "Old", --Old Saltrice
            ["34322"] = "Old", --Old Shank
            ["34331"] = "Old", --Old Ripe Apple
            ["34332"] = "Old", --Old Wisp Floss
            ["34336"] = "Old", --Old Spring Essence
            ["40260"] = "Old", --Old Brown Malt
            ["40261"] = "Old", --Old Amber Malt
            ["40262"] = "Old", --Old Caramalt
            ["40263"] = "Old", --Old Wheat Malt
            ["40264"] = "Old", --Old White Malt
            ["40265"] = "Old", --Old Wine Grapes^p
            ["40266"] = "Old", --Old Grasa Grapes^p
            ["40267"] = "Old", --Old Lado Grapes^p
            ["40268"] = "Old", --Old Camaralet Grapes^p
            ["40269"] = "Old", --Old Ribier Grapes^p
            ["40270"] = "Old", --Old Corn Mash
            ["40271"] = "Old", --Old Wheat Mash
            ["40272"] = "Old", --Old Oat Mash
            ["40273"] = "Old", --Old Barley Mash
            ["40274"] = "Old", --Old Rice Mash
            ["40276"] = "Old", --Old Mutton Flank
            ["45522"] = "Old", --Old Golden Malt
            ["45523"] = "Old", --Old Emperor Grapes^p
            ["45524"] = "Old", --Old Imperial Mash
        }
        local itemLink = ugil(slot)
        if not itemLink then return false end
        if gilit(itemLink) ~= ITEMTYPE_INGREDIENT then return false end
        local itemId = giliid(itemLink)
        if lookup[itemId] == ingredientType then return true end
        return false
    end
end
]]

local function GetFilterCallbackForStyleMaterial(categoryConst, checkOnlyJunk)
    checkOnlyJunk = checkOnlyJunk or false
    return function(slot, slotIndex)
        if not util.LibMotifCategories then return true end
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end
        if categoryConst == util.LibMotifCategories:GetMotifCategory(itemLink) then
            return true
        end
        return false
    end
end

local function GetFilterCallbackForItemTypeAndSpecializedItemtype(sItemTypes, sSpecializedItemTypes, checkOnlyJunk, needsItemTypeAndSpecializedItemType, itemTypeDisplayCategory)
    checkOnlyJunk = checkOnlyJunk or false
    needsItemTypeAndSpecializedItemType = needsItemTypeAndSpecializedItemType or false

    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        if not sItemTypes and not sSpecializedItemTypes then return checkNoFilterTypesOrIsJunk(slot, checkOnlyJunk) end
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if sSpecializedItemTypes == nil and itemTypeDisplayCategory ~= nil then
            sSpecializedItemTypes = IFUgsitbitdc(itemTypeDisplayCategory)
        end
        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local itemType, specializedItemType = gilit(itemLink)
        for i = 1, #sItemTypes do
            if sItemTypes[i] == itemType then
                if needsItemTypeAndSpecializedItemType == true then
                    for j = 1, #sSpecializedItemTypes do
                        if sSpecializedItemTypes[j] == specializedItemType then
                            return true
                        end
                    end
                else
                    return true
                end
            end
        end
        return false
    end
end

local function GetFilterCallbackForSpecializedItemtype(sSpecializedItemTypes, checkOnlyJunk, checkItemTypeToo, itemTypeDisplayCategory)
    return function(slot, slotIndex)
        checkOnlyJunk = checkOnlyJunk or false
        checkItemTypeToo = checkItemTypeToo or false
        slot = checkCraftingStationSlot(slot, slotIndex)
        if not sSpecializedItemTypes and not itemTypeDisplayCategory then return checkNoFilterTypesOrIsJunk(slot, checkOnlyJunk) end
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if sSpecializedItemTypes == nil then
            sSpecializedItemTypes = IFUgsitbitdc(itemTypeDisplayCategory)
        end
        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local itemType, specializedItemType = gilit(itemLink)
        for i = 1, #sSpecializedItemTypes do
            if sSpecializedItemTypes[i] == specializedItemType then
                return true
            else
                if checkItemTypeToo and sSpecializedItemTypes[i] == itemType then
                    return true
                end
            end
        end
        return false
    end
end

local function GetFilterCallbackForDefinedSpecializedOrItemType(specializedItemTypeTab, itemTypeTab, checkOnlyJunk, itemTypeDisplayCategory)
    return function(slot, slotIndex)
        checkOnlyJunk = checkOnlyJunk or false
        slot = checkCraftingStationSlot(slot, slotIndex)
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        local itemLink = ugil(slot)
        if not itemLink then return false end

        if not checkZOsVanillaItemTypeDisplayCategory(slot, itemLink, itemTypeDisplayCategory) then return false end

        local itemType, specializedItemType = gilit(itemLink)

        if not specializedItemTypeTab[specializedItemType] then
            if not itemTypeTab or not itemTypeTab[itemType] then
                return false
            else
                return true
            end
        else
            return true
        end
        return false
    end

end

local function GetFilterCallbackForQuestItems()
    return function(slot, slotIndex)
        slot = checkCraftingStationSlot(slot, slotIndex)
        local itemLink = ugil(slot)
        if not itemLink then return false end
        return true
    end
end

local function GetFilterCallbackForCollectibles(categoryTypes)
    return function(slot, slotIndex)
        if categoryTypes == nil then return true end
        slot = checkCraftingStationSlot(slot, slotIndex)
        --categoryType = COLLECTIBLE_CATEGORY_TYPE_COSTUME .e.g
        local categoryType = slot and slot.categoryType
        if not categoryType then return end
        for _, categoryTypeToCompare in ipairs(categoryTypes) do
            if categoryTypeToCompare == categoryType then return true end
        end
        return false
    end
end
AF.GetFilterCallbackForCollectibles = GetFilterCallbackForCollectibles


-- GetFilterCallback({ITEMTYPE_WEAPON}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS),
local function GetFilterCallback(filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
    return function(slot, slotIndex)
        return filterCallbackChecks(slot, slotIndex, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
    end
end

local function checkItemLinkFilterCallback(slot, slotIndex, filterFunc, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
   slot = checkCraftingStationSlot(slot, slotIndex)
   local itemLink = ugil(slot)
   if not itemLink then return false end

   local filterFuncResult = filterFunc(itemLink)
   filterFuncResult = filterFuncResult or false
--d("[AF]GetFilterCallbackWithItemLinkFunction-["..tostring(itemLinkFilterFunctionName) .."]" .. itemLink .. ": " ..tostring(filterFuncResult))
   if filterFuncResult == false then return false end

   if filterTypes ~= nil or checkOnlyJunk ~= nil or excludeTheseItemIds ~= nil or addFilterTypesToMatch ~= nil or excludeThisTypes ~= nil or itemTypeDisplayCategory ~= nil then
--d(">calling filterCallbackChecks")
       local retVar = filterCallbackChecks(slot, slotIndex, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
       return retVar
   end
   return true
end

local function GetFilterCallbackWithItemLinkFunction(itemLinkFilterFunctionName, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
   return function(slot, slotIndex)
       if itemLinkFilterFunctionName == nil or itemLinkFilterFunctionName == "" then return false end
       if type(itemLinkFilterFunctionName) == "table" then
           for _, filterFuncStr in ipairs(itemLinkFilterFunctionName) do
               local filterFunc = _G[filterFuncStr]
               if filterFunc == nil then return false end
               local resultLoop = checkItemLinkFilterCallback(slot, slotIndex, filterFunc, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
                --Onyl 1 of the functions must be true
               if resultLoop == true then return true end
           end
       else
           local filterFunc = _G[itemLinkFilterFunctionName]
           if filterFunc == nil then return false end
           return checkItemLinkFilterCallback(slot, slotIndex, filterFunc, filterTypes, checkOnlyJunk, excludeTheseItemIds, addFilterTypesToMatch, excludeThisTypes, itemTypeDisplayCategory)
       end
       return false
   end
end

--OTHER ADDONS CALLBACK functions
--[[
local function GetFilterCallbackForOtherAddon(itemFilterTypeOfTheOtherAddon, checkOnlyJunk)
    return function(slot, slotIndex)
        return true
        if AF.settings.debugSpam then d("Other addons filter callback func") end
        if not itemFilterTypeOfTheOtherAddon then return end
        local invType = util.GetCurrentFilterTypeForInventory(AF.currentInventoryType)
        if not invType then return end
        local activeInventoryFilterBarButton = util.GetActiveInventoryFilterBarButtonData(invType)
        if not activeInventoryFilterBarButton then return end
        --Get the original callback of the button
        local buttonData = activeInventoryFilterBarButton.m_buttonData
        if not buttonData then return false end
        local origButtonCallback = buttonData.filterType
        if not origButtonCallback or type(origButtonCallback) ~= "function" then return false end
        --Check for junk and prepare the crafting station slot
        checkOnlyJunk = checkOnlyJunk or false
        slot = checkCraftingStationSlot(slot, slotIndex)
        --Call the original filter function
        local origCallbackResult = origButtonCallback(slot, slotIndex)
        if(not origCallbackResult) then return checkNoFilterTypesOrIsJunk(slot, checkOnlyJunk) end
        if checkOnlyJunk == true then if not checkNoFilterTypesOrIsJunk(slot, true) then return false end end
        --Return the original callback function result
        return origCallbackResult
    end
end
]]



------------------------------------------------------------------------------------------------------------------------
-- Constant re-usable dropdown callback tables
---------------------------------------------------------------------------------------------------------------------------
local armorTypeDropdownCallbacks = {
    {name = "Head",         showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD})},
    {name = "Chest",        showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST})},
    {name = "Shoulders",    showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS})},
    {name = "Hand",         showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND})},
    {name = "Waist",        showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST})},
    {name = "Legs",         showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS})},
    {name = "Feet",         showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET})},
    {name = "Crafted",      showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
}

local glyphTypesDropdownCallbacks = {
    {name = "ArmorGlyph",   showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR})},
    {name = "JewelryGlyph", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_JEWELRY})},
    {name = "WeaponGlyph",  showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_WEAPON})},
    {name = "Crafted",      showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
}


------------------------------------------------------------------------------------------------------------------------
-- Subfilter callback setup table for each entry in constants.lua, table "subfilterButtonNames"
---------------------------------------------------------------------------------------------------------------------------
local subfilterCallbacks = {
--=============================================================================================================================================================================================
--=============================================================================================================================================================================================
--=============================================================================================================================================================================================
-- -v- Inventory main filters subfilter bars                                                                         -v-
--=============================================================================================================================================================================================
    --All
    [AF_CONST_ALL] = {
        addonDropdownCallbacks = {},
        dropdownCallbacks = {
            {name = AF_CONST_ALL,
             filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
             filterCallback = GetFilterCallback(nil),
            },
        },
        dropdownSubmenuCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
            dropdownSubmenuCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Weapons
    Weapons = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        OneHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}),
            dropdownCallbacks = {
                {name = "Axe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
            dropdownCallbacksHeaders = true,
        },
        TwoHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
            dropdownCallbacksHeaders = true,
        },
        Bow = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW})},
            },
            dropdownCallbacksHeaders = true,
        },
        DestructionStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
        HealStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Armor
    Armor = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Heavy = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        Medium = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        LightArmor = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        --Moved to Miscelaneous
        Clothier = {
            filterCallback = GetFilterCallbackForClothing(),
        },
        ]]
        Body = {
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Shield = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND})},
            },
        },
        --[[
        --Moved to Miscelaneous
        Vanity = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_DISGUISE, EQUIP_TYPE_COSTUME}),
            dropdownCallbacks = {},
        },
        ]]
    },
--=============================================================================================================================================================================================
    --Jewelry
    Jewelry = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Neck = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_NECK},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}),
            --Not shown in the normal dropdown filter boxes as the name must be "dropdownCallbacks" for that! But kept to be used in the subMenu, see "AF_SpecialDropdownCallbacks"!
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Neck",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Neck",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK})},
                        {name = "Arcane", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Neck",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Neck",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Neck",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Neck",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_ALL},
                    subfilters = {"All",},
                    onlyGroups = {"Jewelry", "JewelryCraftingStation", "JewelryRetrait", "Junk"},
                    excludeFilterPanels = {
                        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
                        LF_SMITHING_REFINE,
                        LF_ALCHEMY_CREATION,
                        LF_CRAFTBAG,
                        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
                        LF_QUICKSLOT
                    },
                },
            }
        },
        Ring = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_RING},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}),
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Ring",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Ring",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING})},
                        {name = "Arcane", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Ring",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Ring",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Ring",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Ring",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_ALL},
                    subfilters = {"All",},
                    onlyGroups = {"Jewelry", "JewelryCraftingStation", "JewelryRetrait", "Junk"},
                    excludeFilterPanels = {
                        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
                        LF_SMITHING_REFINE,
                        LF_ALCHEMY_CREATION,
                        LF_CRAFTBAG,
                        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
                        LF_QUICKSLOT
                    },
                },
            },
        },
    },
--=============================================================================================================================================================================================
    --Consumables
    Consumables = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
                {name = "Crown", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction({"IsItemLinkFromCrownStore", "IsItemLinkFromCrownCrate"})},
                {name = "StackableContainer", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_CONTAINER_STACKABLE})},
            },
        },
        Crown = {
            filterCallback = GetFilterCallback({ITEMTYPE_CROWN_ITEM, ITEMTYPE_DYE_STAMP}),
            dropdownCallbacks = {},
        },
        Food = {
            filterCallback = GetFilterCallback({ITEMTYPE_FOOD}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        Drink = {
            filterCallback = GetFilterCallback({ITEMTYPE_DRINK}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        Recipe = {
            filterCallback = GetFilterCallback({ITEMTYPE_RECIPE}),
            dropdownCallbacks = {},
        },
        Potion = {
            filterCallback = GetFilterCallback({ITEMTYPE_POTION}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        Poison = {
            filterCallback = GetFilterCallback({ITEMTYPE_POISON}),
            dropdownCallbacks = {
            },
            dropdownCallbacksHeaders = true,
        },
        Motif = {
            filterCallback = GetFilterCallback({ITEMTYPE_RACIAL_STYLE_MOTIF}),
            dropdownCallbacks = {
            },
        },
        Writ = {
            filterCallback = GetFilterCallback({ITEMTYPE_MASTER_WRIT}),
            dropdownCallbacks = {},
        },
        Container = {
            filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype(
                    {ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER_CURRENCY, ITEMTYPE_CONTAINER_STACKABLE},
                    {SPECIALIZED_ITEMTYPE_CONTAINER, SPECIALIZED_ITEMTYPE_CONTAINER_CURRENCY, SPECIALIZED_ITEMTYPE_CONTAINER_EVENT, SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE}, false, false)
                    or GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMFILTERTYPE_PROVISIONING}, {SPECIALIZED_ITEMTYPE_CONTAINER}, false, true),
            dropdownCallbacks = {
            },
        },
        Repair = {
            filterCallback = GetFilterCallback({ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_GROUP_REPAIR}),
            dropdownCallbacks = {
            },
        },
        Trophy = {
            filterCallback = GetFilterCallbackForTrophy(), --will include Miscellaneous trophies, but ZOs vanilla codes filters them here already before AF filters are applied
            dropdownCallbacks = {
                {name = "KeyFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT})},
                {name = "RecipeFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT})},
                {name = "Scroll", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SCROLL})},
                {name = "CollectibleFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT})},
                {name = "Key", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_KEY})},
                {name = "MaterialUpgrader", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER})},
                {name = "RuneboxFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT})},
                {name = "Toy", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_TOY})},
                {name = "UpgradeFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT})},
                {name = "Fish", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_FISH}, {}, false, false)},
                {name = "RecallStone", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP})},
                {name = "ScribingScript", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_CRAFTED_ABILITY_SCRIPT})},
                {name = "ScribingGrimoire", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_CRAFTED_ABILITY})},
                {name = "ConsumableAbility", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_CONSUMABLE_ABILITY})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Materials
    Crafting = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Blacksmithing = {
            filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER}),
            dropdownCallbacks = {},
        },
        Clothier = {
            filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER}),
            dropdownCallbacks = {},
        },
        Woodworking = {
            filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER}),
            dropdownCallbacks = {},
        },
        Alchemy = {
            filterCallback = GetFilterCallback({ITEMTYPE_REAGENT, ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE}),
            dropdownCallbacks = {
                {name = "Reagent", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_REAGENT})},
                {name = "Water", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POTION_BASE})},
                {name = "Oil", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POISON_BASE})},
            },
            dropdownCallbacksHeaders = true,
        },
        Enchanting = {
            filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY}),
            dropdownCallbacks = {
                {name = "Aspect", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ASPECT})},
                {name = "Essence", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ESSENCE})},
                {name = "Potency", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_POTENCY})},
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        Provisioning = {
            filterCallback = GetFilterCallback({ITEMTYPE_INGREDIENT}),
            dropdownCallbacks = {
                {name = "FoodIngredient", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_FOOD_INGREDIENT),
                },
                {name = "DrinkIngredient", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_DRINK_INGREDIENT)
                },
                {name = "RareIngredient", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_RARE_INGREDIENT)},
            },
        },
        ]]
        Provisioning = {
            filterCallback = GetFilterCallback({ITEMTYPE_INGREDIENT}),
            dropdownCallbacks = {
                {name = "FoodIngredient", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ ITEMTYPE_INGREDIENT }, { SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE, SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT, SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT, SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE }, false, true, nil)},
                {name = "DrinkIngredient", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ ITEMTYPE_INGREDIENT }, { SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE, SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL, SPECIALIZED_ITEMTYPE_INGREDIENT_TEA, SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC }, false, true, nil)},
                {name = "RareIngredient", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ ITEMTYPE_INGREDIENT }, { SPECIALIZED_ITEMTYPE_INGREDIENT_RARE }, false, true, nil),},
            },
            dropdownCallbacksHeaders = true,
        },
        JewelryCrafting = {
            filterCallback = GetFilterCallback({
                ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
                ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
                ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
                ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
            }),
            dropdownCallbacks = {
                {name = "Plating", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_BOOSTER})},
                {name = "RefinedMaterialJewelry", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_MATERIAL})},
                {name = "RawPlating", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER})},
                {name = "RawMaterialJewelry", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL})},
            },
            dropdownCallbacksHeaders = true,
        },
        Style = {
            filterCallback = GetFilterCallback({ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {
                {name = "RawMaterialStyle", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_RAW_MATERIAL})},
                {name = "NormalStyle", showIcon=true, filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_NORMAL)},
                {name = "RareStyle", showIcon=true, filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_RARE)},
                {name = "AllianceStyle", showIcon=true, filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_ALLIANCE)},
                {name = "ExoticStyle", showIcon=true, filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_EXOTIC)},
                {name = "CrownStyle", showIcon=true, filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_CROWN)},
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        WeaponTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_WEAPON_TRAIT}),
            dropdownCallbacks = {},
        },
        ArmorTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_ARMOR_TRAIT}),
            dropdownCallbacks = {},
        },
        JewelryAllTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT}),
            dropdownCallbacks = {
                {name = "RawMaterialJewelryTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_RAW_TRAIT})},
                {name = "RefinedMaterialJewelry", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT})},
            },
        },
        ]]
        AllTraits = {
            filterCallback = GetFilterCallback({ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT}),
            dropdownCallbacks = {
                {name = "WeaponTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_WEAPON_TRAIT})},
                {name = "ArmorTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ARMOR_TRAIT})},
                {name = "JewelryAllTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT})},
                {name = "JewelryRawTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_RAW_TRAIT})},
                {name = "JewelryRefinedTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT})},
            },
            dropdownCallbacksHeaders = true,
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
        Scribing = {
            filterCallback = GetFilterCallback({ITEMTYPE_SCRIBING_INK}),
            dropdownCallbacks = {
                {name = "ScribingInk", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_SCRIBING_INK})},
            },
        }
    },
--=============================================================================================================================================================================================
    --Furnishing
    Furnishings = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        CraftingStation = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION}),
            dropdownCallbacks = {},
        },
        Light = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT}),
            dropdownCallbacks = {},
        },
        Ornamental = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL}),
            dropdownCallbacks = {},
        },
        Seating = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_SEATING}),
            dropdownCallbacks = {},
        },
        TargetDummy = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Miscellaneous
    Miscellaneous = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Glyphs = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON}),
            dropdownCallbacks = glyphTypesDropdownCallbacks,
        },
        SoulGem = {
            filterCallback = GetFilterCallback({ITEMTYPE_SOUL_GEM}),
            dropdownCallbacks = {},
        },
        Siege = {
            filterCallback = GetFilterCallback({ITEMTYPE_SIEGE}),
            dropdownCallbacks = {},
        },
        Bait = {
            filterCallback = GetFilterCallback({ITEMTYPE_LURE}),
            dropdownCallbacks = {},
        },
        Tool = {
            filterCallback = GetFilterCallback({ITEMTYPE_TOOL}),
            dropdownCallbacks = {},
        },
        Trophy = {
            filterCallback = GetFilterCallbackForTrophy(),  --will include Consumables trophies, but ZOs vanilla codes filters them here already before AF filters are applied
            dropdownCallbacks = {
                {name = "TreasureMaps", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP})},
                {name = "SurveyReport", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT})},
                {name = "MuseumPiece", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE})},
                {name = "Scroll", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SCROLL})},
                {name = "RareFish", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH})},
                {name = "Treasure", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TREASURE})},
            },
            dropdownCallbacksHeaders = true,
        },
        Fence = {
            filterCallback = GetFilterCallbackForFence(),
            dropdownCallbacks = {},
        },
        Trash = {
            filterCallback = GetFilterCallback({ITEMTYPE_TRASH}),
            dropdownCallbacks = {},
        },
        Vanity = {
            filterCallback = GetFilterCallbackForClothing(),
            dropdownCallbacks = {
                {name = "Costume", showIcon=true,  filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_COSTUME})},
                {name = "Disguise", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_DISGUISE})},
                {name = "Tabard", showIcon=true,   filterCallback = GetFilterCallback({ITEMTYPE_TABARD})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
    --Quest
    Quest = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallbackForQuestItems(nil),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Junk -> See at the bottom of the table!
--=============================================================================================================================================================================================
-- -^- Inventory main filters subfilter bars                                                                         -^-
--=============================================================================================================================================================================================
--=============================================================================================================================================================================================
--=============================================================================================================================================================================================


--=============================================================================================================================================================================================
--=============================================================================================================================================================================================
--=============================================================================================================================================================================================
-- -v- Subfilters of the subfilterbars                                                                               -v-
--=============================================================================================================================================================================================

    --Collectibles
    Collectibles = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL]         = {
            filterCallback    = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
    },

--=============================================================================================================================================================================================
-- -v- Weapons & Crafting                                                                                            -v-
--=============================================================================================================================================================================================
    WeaponsSmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        OneHand = {
            filterForAll = {
                filterTypes = {WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, {WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}) end,
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}), {WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER},
            dropdownCallbacks = {
                {name = "Axe", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_AXE) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_HAMMER) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_SWORD) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_DAGGER) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
            dropdownCallbacksHeaders = true,
        },
        TwoHand = {
            filterForAll = {
                filterTypes = {WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, {WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}) end,
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_TWO_HANDED_AXE) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_TWO_HANDED_HAMMER) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_TWO_HANDED_SWORD) end, filterCallback=GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    WeaponsWoodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Bow = {
            filterForAll = {
                itemTypes = {WEAPONTYPE_BOW},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_BOW) end,
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {
                {name = "Bow", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_BOW) end, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW})},
            },
            dropdownCallbacksHeaders = true,
        },
        DestructionStaff = {
            filterForAll = {
                itemTypes = {WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, {WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}) end,
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_FIRE_STAFF) end, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_FROST_STAFF) end, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_LIGHTNING_STAFF) end, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
        HealStaff = {
            filterForAll = {
                itemTypes = {WEAPONTYPE_HEALING_STAFF},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_HEALING_STAFF) end,
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {
                {name = "HealStaff", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, WEAPONTYPE_HEALING_STAFF) end, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
-- -^- Weapons & Crafting                                                                                            -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
-- -v- Armor & Crafting & Refine                                                                                     -v-
--=============================================================================================================================================================================================
    ArmorSmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Heavy = {
            filterForAll = {
                armorTypes = {ARMORTYPE_HEAVY},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_HEAVY) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD})},
                {name = "Chest", showIcon=true,     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST})},
                {name = "Shoulders", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS})},
                {name = "Hand", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND})},
                {name = "Waist", showIcon=true,     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST})},
                {name = "Legs", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS})},
                {name = "Feet", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Smithing refine
    RefineSmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialSmithing = {
            filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    ArmorClothier = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        LightArmor = {
            filterForAll = {
                armorTypes = {ARMORTYPE_LIGHT},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_LIGHT) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD}, {ARMORTYPE_LIGHT})},
                {name = "Chest", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST}, {ARMORTYPE_LIGHT})},
                {name = "Shoulders", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS}, {ARMORTYPE_LIGHT})},
                {name = "Hand", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND}, {ARMORTYPE_LIGHT})},
                {name = "Waist", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST}, {ARMORTYPE_LIGHT})},
                {name = "Legs", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS}, {ARMORTYPE_LIGHT})},
                {name = "Feet", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET}, {ARMORTYPE_LIGHT})},
            },
            dropdownCallbacksHeaders = true,
        },
        Medium = {
            filterForAll = {
                armorTypes = {ARMORTYPE_MEDIUM},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_MEDIUM) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD}, {ARMORTYPE_MEDIUM})},
                {name = "Chest", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST}, {ARMORTYPE_MEDIUM})},
                {name = "Shoulders", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS}, {ARMORTYPE_MEDIUM})},
                {name = "Hand", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND}, {ARMORTYPE_MEDIUM})},
                {name = "Waist", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST}, {ARMORTYPE_MEDIUM})},
                {name = "Legs", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS}, {ARMORTYPE_MEDIUM})},
                {name = "Feet", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET}, {ARMORTYPE_MEDIUM})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Clothier refine
    RefineClothier = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialClothier = {
            filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    ArmorWoodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Shield = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_OFF_HAND},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_OFF_HAND) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {
                {name = "Shield", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_OFF_HAND) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Woodworking refine
    RefineWoodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialWoodworking = {
            filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
-- -^- Armor & Crafting & Refine                                                                                     -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
-- -v- Jewelry & Crafting & Refine                                                                                   -v-
--=============================================================================================================================================================================================
    --JewelryCrafting
    JewelryCrafting = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Plating = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_BOOSTER}),
            dropdownCallbacks = {},
        },
        RefinedMaterialJewelry = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_MATERIAL}),
            dropdownCallbacks = {},
        },
        RawPlating = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER}),
            dropdownCallbacks = {},
        },
        RawMaterialJewelry = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },

    --Jewelry crafting refine
    RefineJewelryCraftingStation = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawPlating = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER}),
            dropdownCallbacks = {},
        },
        RawMaterialJewelry = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
        JewelryRawTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_RAW_TRAIT}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
-- -^- Jewelry & Crafting & Refine                                                                                   -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
-- -v- CraftBag & Materials                                                                                          -v-
--=============================================================================================================================================================================================
    --Blacksmithing
    Blacksmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialSmithing = {
            filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
        RefinedMaterialSmithing = {
            filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_MATERIAL}),
            dropdownCallbacks = {},
        },
        Temper = {
            filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_BOOSTER}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Clothing
    Clothing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialClothier = {
            filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
        RefinedMaterialClothier = {
            filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_MATERIAL}),
            dropdownCallbacks = {},
        },
        Tannin = {
            filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_BOOSTER}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Woodworking
    Woodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        RawMaterialWoodworking = {
            filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_RAW_MATERIAL}),
            dropdownCallbacks = {},
        },
        RefinedMaterialWoodworking = {
            filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_MATERIAL}),
            dropdownCallbacks = {},
        },
        Resin = {
            filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_BOOSTER}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Alchemy
    Alchemy = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Reagent = {
            filterCallback = GetFilterCallback({ITEMTYPE_REAGENT}),
            dropdownCallbacks = {},
        },
        Water = {
            filterCallback = GetFilterCallback({ITEMTYPE_POTION_BASE}),
            dropdownCallbacks = {},
        },
        Oil = {
            filterCallback = GetFilterCallback({ITEMTYPE_POISON_BASE}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Enchanting
    Enchanting = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Aspect = {
            filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ASPECT}),
            dropdownCallbacks = {},
        },
        Essence = {
            filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ESSENCE}),
            dropdownCallbacks = {},
        },
        Potency = {
            filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_POTENCY}),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Runes
    Runes = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Glyphs
    Glyphs = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        WeaponGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_WEAPON}),
            dropdownCallbacks = {
            },
        },
        ArmorGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR}),
            dropdownCallbacks = {
            },
        },
        JewelryGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_JEWELRY}),
            dropdownCallbacks = {
            },
        },
    },
--=============================================================================================================================================================================================
    --Provisioning
    Provisioning = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        --[[
        FoodIngredient = {
            filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_FOOD_INGREDIENT),
            dropdownCallbacks = {},
        },
        DrinkIngredient = {
            filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_DRINK_INGREDIENT),
            dropdownCallbacks = {},
        },
        RareIngredient = {
            filterCallback = GetFilterCallbackForSpecializedItemtype(nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_RARE_INGREDIENT),
            dropdownCallbacks = {},
        },
        ]]
        --GetFilterCallbackForItemTypeAndSpecializedItemtype(sItemTypes, sSpecializedItemTypes, checkOnlyJunk, needsItemTypeAndSpecializedItemType, itemTypeDisplayCategory)
        FoodIngredient = {
            filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_INGREDIENT}, {SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE, SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT, SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT, SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE}, false, true, nil),
            dropdownCallbacks = {},
        },
        DrinkIngredient = {
            filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_INGREDIENT}, {SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE, SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL, SPECIALIZED_ITEMTYPE_INGREDIENT_TEA, SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC}, false, true, nil),
            dropdownCallbacks = {},
        },
        RareIngredient = {
            filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_INGREDIENT}, {SPECIALIZED_ITEMTYPE_INGREDIENT_RARE}, false, true, nil),
            dropdownCallbacks = {},
        },
        FurnishingMat = {
            filterCallback = GetFilterCallback({ITEMTYPE_FURNISHING_MATERIAL}),
            dropdownCallbacks = {},
        },
        Bait = {
            filterCallback = GetFilterCallback({ITEMTYPE_LURE}),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Style
    Style = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        NormalStyle = {
            filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_NORMAL),
            dropdownCallbacks = {},
        },
        RareStyle = {
            filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_RARE),
            dropdownCallbacks = {},
        },
        AllianceStyle = {
            filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_ALLIANCE),
            dropdownCallbacks = {},
        },
        ExoticStyle = {
            filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_EXOTIC),
            dropdownCallbacks = {},
        },
        CrownStyle = {
            filterCallback = GetFilterCallbackForStyleMaterial(LMC_MOTIF_CATEGORY_CROWN),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
    --Traits
    Traits = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        WeaponTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_WEAPON_TRAIT}),
            dropdownCallbacks = {},
        },
        ArmorTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_ARMOR_TRAIT}),
            dropdownCallbacks = {},
        },
        JewelryAllTrait = {
            filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT, ITEMTYPE_JEWELRY_RAW_TRAIT}),
            dropdownCallbacks = {
                {name = "RawMaterialJewelry", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_RAW_TRAIT})},
                {name = "RefinedMaterialJewelry", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_TRAIT})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
    --CraftBag's Miscellaneous tab
    CraftBagMiscellaneous = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "ScribingInk", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_SCRIBING_INK})},
            },
        },
        Scribing = {
            filterCallback = GetFilterCallback({ITEMTYPE_SCRIBING_INK}),
            dropdownCallbacks = {},
        }
    },
--=============================================================================================================================================================================================
-- -^- CraftBag & Materials                                                                                          -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
-- -v- Retrait                                                                                                       -v-
--=============================================================================================================================================================================================
    --Weapons retrait
    WeaponsRetrait = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        OneHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}),
            dropdownCallbacks = {
                {name = "Axe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
            dropdownCallbacksHeaders = true,
        },
        TwoHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
            dropdownCallbacksHeaders = true,
        },
        Bow = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW})},
            },
            dropdownCallbacksHeaders = true,
        },
        DestructionStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
        HealStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Armor retrait
    ArmorRetrait = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Heavy = {
            filterForAll = {
                armorTypes = {ARMORTYPE_HEAVY},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_HEAVY) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD})},
                {name = "Chest", showIcon=true,     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST})},
                {name = "Shoulders", showIcon=true, filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS})},
                {name = "Hand", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND})},
                {name = "Waist", showIcon=true,     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST})},
                {name = "Legs", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS})},
                {name = "Feet", showIcon=true,      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_HEAVY) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET})},
            },
            dropdownCallbacksHeaders = true,
        },
        LightArmor = {
            filterForAll = {
                armorTypes = {ARMORTYPE_LIGHT},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_LIGHT) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD}, {ARMORTYPE_LIGHT})},
                {name = "Chest", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST}, {ARMORTYPE_LIGHT})},
                {name = "Shoulders", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS}, {ARMORTYPE_LIGHT})},
                {name = "Hand", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND}, {ARMORTYPE_LIGHT})},
                {name = "Waist", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST}, {ARMORTYPE_LIGHT})},
                {name = "Legs", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS}, {ARMORTYPE_LIGHT})},
                {name = "Feet", showIcon=true, addString="Light", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_LIGHT) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET}, {ARMORTYPE_LIGHT})},
            },
            dropdownCallbacksHeaders = true,
        },
        Medium = {
            filterForAll = {
                armorTypes = {ARMORTYPE_MEDIUM},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, nil, ARMORTYPE_MEDIUM) end,
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
            dropdownCallbacks = {
                {name = "Head", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HEAD, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD}, {ARMORTYPE_MEDIUM})},
                {name = "Chest", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_CHEST, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_CHEST}, {ARMORTYPE_MEDIUM})},
                {name = "Shoulders", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_SHOULDERS, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_SHOULDERS}, {ARMORTYPE_MEDIUM})},
                {name = "Hand", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_HAND, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HAND}, {ARMORTYPE_MEDIUM})},
                {name = "Waist", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_WAIST, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_WAIST}, {ARMORTYPE_MEDIUM})},
                {name = "Legs", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_LEGS, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_LEGS}, {ARMORTYPE_MEDIUM})},
                {name = "Feet", showIcon=true, addString="Medium", filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_FEET, ARMORTYPE_MEDIUM) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_FEET}, {ARMORTYPE_MEDIUM})},
            },
            dropdownCallbacksHeaders = true,
        },
        Shield = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND})},
            },
            dropdownCallbacksHeaders = true,
        },
    },
--=============================================================================================================================================================================================
    --Jewelry retrait
    --[[
    --> See Jewelry
    JewelryRetrait = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Neck = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}),
            dropdownCallbacks = {
                {name = "Arcane", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                {name = "Bloodthirsty", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                {name = "Harmony", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                {name = "Healthy", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                {name = "Infused", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                {name = "Intricate", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                {name = "Ornate", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                {name = "Protective", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                {name = "Robust", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                {name = "Swift", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                {name = "Triune", showIcon=true, addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
            },
        },
        Ring = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}),
            dropdownCallbacks = {
                {name = "Arcane", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                {name = "Bloodthirsty", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                {name = "Harmony", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                {name = "Healthy", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                {name = "Infused", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                {name = "Intricate", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                {name = "Ornate", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                {name = "Protective", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                {name = "Robust", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                {name = "Swift", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                {name = "Triune", showIcon=true, addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
            },
        },
    },
    ]]

--=============================================================================================================================================================================================
-- -^- Retrait                                                                                                       -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
-- -v- QuickSlot                                                                                                     -v-
--=============================================================================================================================================================================================
    --QuickSlot - Misc.
    QuickSlot = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Drink = {
            filterCallback = GetFilterCallback({ITEMTYPE_DRINK}),
            dropdownCallbacks = {},
        },
        Food = {
            filterCallback = GetFilterCallback({ITEMTYPE_FOOD}),
            dropdownCallbacks = {},
        },
        Potion = {
            filterCallback = GetFilterCallback({ITEMTYPE_POTION}),
            dropdownCallbacks = {
            },
        },
        Siege = {
            filterCallback = GetFilterCallback({ITEMTYPE_SIEGE}),
            dropdownCallbacks = {},
        },
        Scroll = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SCROLL}),
            dropdownCallbacks = {},
        },
        Repair = {
            filterCallback = GetFilterCallback({ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_GROUP_REPAIR}),
            dropdownCallbacks = {},
        },
        Trophy = {
            filterCallback = GetFilterCallbackForTrophy(),
            dropdownCallbacks = {
                {name = "KeyFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT})},
                {name = "RecipeFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT})},
                {name = "Scroll", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SCROLL})},
                {name = "TreasureMaps", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP})},
                {name = "SurveyReport", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT})},
                {name = "CollectibleFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT})},
                {name = "Key", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_KEY})},
                {name = "MaterialUpgrader", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER})},
                {name = "RuneboxFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT})},
                {name = "Toy", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_TOY})},
                {name = "UpgradeFragment", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT})},
                {name = "Fish", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({ITEMTYPE_FISH}, {}, false, false)},
                {name = "RecallStone", showIcon=true, filterCallback = GetFilterCallbackForItemTypeAndSpecializedItemtype({SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP})},
                {name = "Treasure", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_TREASURE})}
            },
            dropdownCallbacksHeaders = true,
        },
        Crown = {
            filterCallback = GetFilterCallback({ITEMTYPE_CROWN_ITEM, ITEMTYPE_DYE_STAMP}),
            dropdownCallbacks = {},
        },

    },
    QuickSlotQuest = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
    },
--=============================================================================================================================================================================================
-- -^- QuickSlot                                                                                                     -^-
--=============================================================================================================================================================================================


--=============================================================================================================================================================================================
-- -v- Companion (the companion items tab at the player inventory! Not the companion's inventory itsself)
--=============================================================================================================================================================================================
    Companion = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil, false, nil, {ITEMFILTERTYPE_COMPANION}),
            dropdownCallbacks = {},
        },
        Weapon = {
            filterCallback = GetFilterCallback({ITEMTYPE_WEAPON}, false, nil, {ITEMFILTERTYPE_COMPANION}, {equipType={EQUIP_TYPE_OFF_HAND}}),
            dropdownCallbacks = {
                {name = "OneHand", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "TwoHand", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "DestructionStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}, false, {ITEMFILTERTYPE_COMPANION})},
            },
            dropdownCallbacksHeaders = true,
        },
        Armor = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_HAND, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_OFF_HAND}, nil, false, {ITEMFILTERTYPE_COMPANION}),
            dropdownCallbacks = {
                {name = "Heavy", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "Medium", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "LightArmor", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}, false, {ITEMFILTERTYPE_COMPANION})},
                --{name = "Clothier", filterCallback = GetFilterCallbackForClothing(, {ITEMFILTERTYPE_COMPANION})},
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}, nil, false, {ITEMFILTERTYPE_COMPANION})},
                --{name = "Vanity", filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_DISGUISE, EQUIP_TYPE_COSTUME}, nil, false, , {ITEMFILTERTYPE_COMPANION})},
                --{name = "Vanity", filterCallback = GetFilterCallbackForClothing(true, {ITEMFILTERTYPE_COMPANION})},
            },
            dropdownCallbacksHeaders = true,
        },
        Jewelry = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING, EQUIP_TYPE_NECK}, nil, false, {ITEMFILTERTYPE_COMPANION}),
            dropdownCallbacks = {
                {name = "Ring", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}, nil, false, {ITEMFILTERTYPE_COMPANION})},
                {name = "Neck", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}, nil, false, {ITEMFILTERTYPE_COMPANION})},
            },
            dropdownCallbacksHeaders = true,
        },
    },

--=============================================================================================================================================================================================
-- -^- Companion (in Player Inventory)                                                                                            -^-
--=============================================================================================================================================================================================

--=============================================================================================================================================================================================
--Not added yet
    --[[
    CreateArmorSmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Armor = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
        },
    },
    CreateWeaponsSmithing = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        OneHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}),
            dropdownCallbacks = {
                {name = "Axe", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
        },
        TwoHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
        },
    },
    CreateArmorClothier = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Medium = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
        },
        LightArmor = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
        },
    },
    CreateWeaponsWoodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Bow = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {},
        },
        DestructionStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
        },
        HealStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {},
        },
    },
    CreateArmorWoodworking = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Shield = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {},
        },
    },
    CreateJewelryCraftingStation = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Neck = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}),
            dropdownCallbacks = {
                {name = "Arcane", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                {name = "Bloodthirsty", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                {name = "Harmony", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                {name = "Healthy", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                {name = "Infused", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                {name = "Intricate", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                {name = "Ornate", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                {name = "Protective", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                {name = "Robust", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                {name = "Swift", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                {name = "Triune", addString = "Neck", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
            },
        },
        Ring = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}),
            dropdownCallbacks = {
                {name = "Arcane", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                {name = "Bloodthirsty", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                {name = "Harmony", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                {name = "Healthy", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                {name = "Infused", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                {name = "Intricate", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                {name = "Ornate", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                {name = "Protective", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                {name = "Robust", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                {name = "Swift", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                {name = "Triune", addString = "Ring", filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
            },
        },
    },
    ]]
--=============================================================================================================================================================================================
    Junk = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil, true),
            dropdownCallbacks = {
                {name = "Crafted", showIcon=true, filterCallback = GetFilterCallbackWithItemLinkFunction("IsItemLinkCrafted")},
            },
        },
        Weapon = {
            filterCallback = GetFilterCallback({ITEMTYPE_WEAPON}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS),
            dropdownCallbacks = {
                {name = "OneHand", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS)},
                {name = "TwoHand", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS)},
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS)},
                {name = "DestructionStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS)},
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS)},
            },
            dropdownCallbacksHeaders = true,
        },
        Armor = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_HAND, EQUIP_TYPE_WAIST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_OFF_HAND},
                                                    nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_ARMOR),
            dropdownCallbacks = {
                {name = "Heavy", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_ARMOR)},
                {name = "Medium", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_ARMOR)},
                {name = "LightArmor", showIcon=true, filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_ARMOR)},
                --{name = "Clothier", filterCallback = GetFilterCallbackForClothing()},
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}, nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_ARMOR)},
                --{name = "Vanity", filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_DISGUISE, EQUIP_TYPE_COSTUME})},
                --{name = "Vanity", filterCallback = GetFilterCallbackForClothing(true)},
            },
            dropdownCallbacksHeaders = true,
        },
        Jewelry = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING, EQUIP_TYPE_NECK}, nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY),
            dropdownCallbacks = {
                {name = "Ring", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}, nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY)},
                {name = "Neck", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}, nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY)},
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        Consumable = {
            filterCallback = GetFilterCallback({ITEMTYPE_CROWN_ITEM, ITEMTYPE_DYE_STAMP, ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_POISON, ITEMTYPE_RACIAL_STYLE_MOTIF,
                                                ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER_CURRENCY, ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_TROPHY,
                                                ITEMTYPE_COLLECTIBLE, ITEMTYPE_FISH, ITEMTYPE_GROUP_REPAIR}, true, itemIds.lockpick),
            dropdownCallbacks = {
                {name = "Crown", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_CROWN_ITEM}, true)},
                {name = "Food", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_FOOD}, true)},
                {name = "Drink", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_DRINK}, true)},
                {name = "Recipe", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_RECIPE}, true)},
                {name = "Potion", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POTION}, true)},
                {name = "Poison", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POISON}, true)},
                {name = "Motif", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_RACIAL_STYLE_MOTIF}, true)},
                {name = "Writ", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_MASTER_WRIT}, true)},
                {name = "Container", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER_CURRENCY}, true, true)},
                {name = "Repair", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_GROUP_REPAIR}, true, itemIds.lockpick)},
                {name = "Trophy", showIcon=true, filterCallback = GetFilterCallbackForTrophy(true)},
            },
        },
        ]]
        Consumable = {
            filterCallback = GetFilterCallback(nil, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE),
            dropdownCallbacks = {
                {name = "Crown", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_CROWN_ITEM, ITEMTYPE_DYE_STAMP}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Food", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_FOOD}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Drink", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_DRINK}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Recipe", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_RECIPE}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Potion", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POTION}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Poison", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_POISON}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Motif", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_RACIAL_STYLE_MOTIF}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Writ", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_MASTER_WRIT}, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Container", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER, ITEMTYPE_CONTAINER_CURRENCY, ITEMTYPE_CONTAINER_STACKABLE}, true, true, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Repair", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_GROUP_REPAIR}, true, itemIds.lockpick, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
                {name = "Trophy", showIcon=true, filterCallback = GetFilterCallbackForTrophy(true, ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE)},
            },
            dropdownCallbacksHeaders = true,
        },
        Materials = {
            filterCallback = GetFilterCallbackForSpecializedItemtype({ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER,
                                                ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER,
                                                ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER,
                                                ITEMTYPE_JEWELRYCRAFTING_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
                                                ITEMTYPE_REAGENT, ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE,
                                                ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY,
                                                ITEMTYPE_INGREDIENT, ITEMTYPE_STYLE_MATERIAL,
                                                ITEMTYPE_RAW_MATERIAL, ITEMTYPE_JEWELRY_RAW_TRAIT, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
                                                ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_JEWELRY_TRAIT,
                                                ITEMTYPE_FURNISHING_MATERIAL, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
                                                SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING,
                                                SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING,
                                                SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING,
            }, true, true, nil),
            dropdownCallbacks = {
                {name = "Blacksmithing", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER}, true)},
                {name = "Clothier", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER}, true)},
                {name = "Woodworking", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER}, true)},
                {name = "JewelryCrafting", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRYCRAFTING_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL}, true)},
                {name = "Alchemy", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_REAGENT, ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE}, true)},
                {name = "Enchanting", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY}, true)},
                {name = "Provisioning", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_INGREDIENT}, true)},
                {name = "Style", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL}, true)},
                {name = "ArmorTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_ARMOR_TRAIT}, true)},
                {name = "WeaponTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_WEAPON_TRAIT}, true)},
                {name = "JewelryAllTrait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_JEWELRY_RAW_TRAIT, ITEMTYPE_JEWELRY_TRAIT}, true)},
                {name = "Furnishings", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({ITEMTYPE_FURNISHING_MATERIAL, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
                                                SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING,
                                                SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING, SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING})},
            },
            dropdownCallbacksHeaders = true,
        },
        Furnishings = {
            filterCallback = GetFilterCallbackForSpecializedItemtype(nil, true, nil, ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING),
            dropdownCallbacks = {
                {name = "CraftingStation", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION})},
                {name = "Light", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT})},
                {name = "Ornamental", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL})},
                {name = "Seating", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_SEATING})},
                {name = "TargetDummy", showIcon=true, filterCallback = GetFilterCallbackForSpecializedItemtype({SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY})},
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        Miscellaneous = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL, ITEMTYPE_TROPHY, ITEMTYPE_COLLECTIBLE, ITEMTYPE_FISH, ITEMTYPE_TREASURE, ITEMTYPE_TRASH, ITEMTYPE_DISGUISE, ITEMTYPE_TABARD}, true, itemIds.repairtools),
            dropdownCallbacks = {
                {name = "Glyphs", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON}, true)},
                {name = "SoulGem", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_SOUL_GEM}, true)},
                {name = "Siege", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_SIEGE}, true)},
                {name = "Bait", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_LURE}, true)},
                {name = "Tool", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_TOOL}, true, itemIds.repairtools)},
                {name = "Trophy", showIcon=true, filterCallback = GetFilterCallbackForTrophy(true)},
                {name = "Fence", showIcon=true, filterCallback = GetFilterCallbackForFence(true)},
                {name = "Trash", showIcon=true, filterCallback = GetFilterCallback({ITEMTYPE_TRASH}, true)},
                {name = "Vanity", showIcon=true, filterCallback = GetFilterCallbackForClothing(true)},
                --{name = "Costume",  filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_COSTUME})},
            },
        },
        ]]
        Miscellaneous = {
            filterCallback    = GetFilterCallback(nil, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS),
            dropdownCallbacks = {
                { name = "Glyphs", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON }, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "SoulGem", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_SOUL_GEM }, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Siege", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_SIEGE }, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Bait", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_LURE }, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Tool", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_TOOL }, true, itemIds.repairtools, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Trophy", showIcon = true, filterCallback = GetFilterCallbackForTrophy(true, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Fence", showIcon = true, filterCallback = GetFilterCallbackForFence(true, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Trash", showIcon = true, filterCallback = GetFilterCallback({ ITEMTYPE_TRASH }, true, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                { name = "Vanity", showIcon = true, filterCallback = GetFilterCallbackForClothing(true, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) },
                --{name = "Costume",  filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_COSTUME}, nil, nil, nil, ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS)},
            },
            dropdownCallbacksHeaders = true,
        },
    },


--=============================================================================================================================================================================================
    --Universal Deconstruction
    --[[
        "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand",
        "Shield", "LightArmor", "Medium", "Heavy",
        "Ring", "Neck",
        "WeaponGlyph", "ArmorGlyph", "JewelryGlyph",
    ]]

    AllUniversalDecon = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },

        --Weapons
        OneHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}),
            dropdownCallbacks = {
                {name = "Axe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
            dropdownCallbacksHeaders = true,
        },
        TwoHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
            dropdownCallbacksHeaders = true,
        },
        Bow = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW})},
            },
            dropdownCallbacksHeaders = true,
        },
        DestructionStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
        HealStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },

        --Armor
        Heavy = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Medium = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        LightArmor = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Body = {
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Shield = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND})},
            },
            dropdownCallbacksHeaders = true,
        },

        --Jewelry
        Neck = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_NECK},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}),
            --Not shown in the normal dropdown filter boxes as the name must be "dropdownCallbacks" for that! But kept to be used in the subMenu, see "AF_SpecialDropdownCallbacks"!
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Neck",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Neck",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK})},
                        {name = "Arcane", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Neck",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Neck",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Neck",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Neck",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL},
                    subfilters = {"All", "Neck"},
                },
            }
        },
        Ring = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_RING},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}),
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Ring",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Ring",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING})},
                        {name = "Arcane", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Ring",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Ring",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Ring",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Ring",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL},
                    subfilters = {"All", "Ring"},
                },
            },
        },

        --Glyphs
        Glyphs = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON}),
            dropdownCallbacks = glyphTypesDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },

    }, --ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL

    WeaponsUniversalDecon = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        OneHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER}),
            dropdownCallbacks = {
                {name = "Axe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_AXE})},
                {name = "Hammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HAMMER})},
                {name = "Sword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_SWORD})},
                {name = "Dagger", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_DAGGER})},
            },
            dropdownCallbacksHeaders = true,
        },
        TwoHand = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}),
            dropdownCallbacks = {
                {name = "TwoHandAxe", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_AXE})},
                {name = "TwoHandHammer", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_HAMMER})},
                {name = "TwoHandSword", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_TWO_HANDED_SWORD})},
            },
            dropdownCallbacksHeaders = true,
        },
        Bow = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW}),
            dropdownCallbacks = {
                {name = "Bow", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_BOW})},
            },
            dropdownCallbacksHeaders = true,
        },
        DestructionStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}),
            dropdownCallbacks = {
                {name = "Fire", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FIRE_STAFF})},
                {name = "Frost", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_FROST_STAFF})},
                {name = "Lightning", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_LIGHTNING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
        HealStaff = {
            filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF}),
            dropdownCallbacks = {
                {name = "HealStaff", showIcon=true, filterCallback = GetFilterCallbackForWeaponType({WEAPONTYPE_HEALING_STAFF})},
            },
            dropdownCallbacksHeaders = true,
        },
    }, --ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS

    ArmorUniversalDecon = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {}, --uses "Body" replacement dropdownCallbacks
        },
        Heavy = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_HEAVY}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Medium = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_MEDIUM}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        LightArmor = {
            filterCallback = GetFilterCallbackForArmorType({ARMORTYPE_LIGHT}),
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        --[[
        --Moved to Miscelaneous
        Clothier = {
            filterCallback = GetFilterCallbackForClothing(),
        },
        ]]
        Body = {
            dropdownCallbacks = armorTypeDropdownCallbacks,
            dropdownCallbacksHeaders = true,
        },
        Shield = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND}),
            dropdownCallbacks = {
                {name = "Shield", showIcon=true, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_OFF_HAND})},
            },
            dropdownCallbacksHeaders = true,
        },
        --[[
        --Moved to Miscelaneous
        Vanity = {
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_DISGUISE, EQUIP_TYPE_COSTUME}),
            dropdownCallbacks = {},
        },
        ]]
    },--ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR

    JewelryUniversalDecon = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(true, nil) end,
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        Neck = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_NECK},
            },
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK}),
            --Not shown in the normal dropdown filter boxes as the name must be "dropdownCallbacks" for that! But kept to be used in the subMenu, see "AF_SpecialDropdownCallbacks"!
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Neck",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Neck",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_NECK})},
                        {name = "Arcane", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Neck",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Neck",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Neck",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Neck",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Neck",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Neck",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Neck",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Neck",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_NECK, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_NECK}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY},
                    subfilters = {"All", "Neck"},
                },
            }
        },
        Ring = {
            filterForAll = {
                equipTypes = {EQUIP_TYPE_RING},
            },
            filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end,
            filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING}),
            dropdownCallbacks = {
            },
            dropdownSubmenuCallbacks = {
                [1] = {
                    submenuName = "Ring",
                    callbackTable = {
                        {name = "All", showIcon=true, addString = "Ring",           filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForGear({EQUIP_TYPE_RING})},
                        {name = "Arcane", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ARCANE)},
                        {name = "Bloodthirsty", showIcon=true, addString = "Ring",  filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)},
                        {name = "Harmony", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HARMONY)},
                        {name = "Healthy", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY)},
                        {name = "Infused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INFUSED)},
                        {name = "Intricate", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)},
                        {name = "Ornate", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ORNATE)},
                        {name = "Protective", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE)},
                        {name = "Robust", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_ROBUST)},
                        {name = "Swift", showIcon=true, addString = "Ring",         filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_SWIFT)},
                        {name = "Triune", showIcon=true, addString = "Ring",        filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)},
                        --Companion
                        {name = "Aggressive", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE)},
                        {name = "Augmented", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_AUGMENTED)},
                        {name = "Bolstered", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_BOLSTERED)},
                        {name = "Focused", showIcon=true, addString = "Ring",       filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_FOCUSED)},
                        {name = "Quickened", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_QUICKENED)},
                        {name = "Shattering", showIcon=true, addString = "Ring",    filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SHATTERING)},
                        {name = "Soothing", showIcon=true, addString = "Ring",      filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_SOOTHING)},
                        {name = "Vigorous", showIcon=true, addString = "Ring",     filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_WEAPON_VIGOROUS)},

                        {name = "None", showIcon=true, addString = "Ring",          filterStartCallback = function() checkForResearchPanelAndRunFilterFunction(false, EQUIP_TYPE_RING, nil) end, filterCallback = GetFilterCallbackForJewelry({EQUIP_TYPE_RING}, ITEM_TRAIT_TYPE_NONE)},
                    },
                    filterType = {ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY},
                    subfilters = {"All", "Ring"},
                },
            },
        },
    },--ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY
    GlyphsUniversalDecon = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback = GetFilterCallback(nil),
            dropdownCallbacks = {},
        },
        WeaponGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_WEAPON}),
            dropdownCallbacks = {},
        },
        ArmorGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_ARMOR}),
            dropdownCallbacks = {},
        },
        JewelryGlyph = {
            filterCallback = GetFilterCallback({ITEMTYPE_GLYPH_JEWELRY}),
            dropdownCallbacks = {},
        },
    },--ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS


--=============================================================================================================================================================================================
    --CUSTOM ADDON TABs
    --[[
    HarvensStolenFilter = {
        addonDropdownCallbacks = {},
        [AF_CONST_ALL] = {
            filterCallback     = GetFilterCallbackForOtherAddon(ITEMFILTERTYPE_AF_HARVENSSTOLENFILTER, false),
            dropdownCallbacks   = {},
        },
    },
    ]]
--=============================================================================================================================================================================================
} --subfilterCallbacks

--Clones of subfilterCallbacks
subfilterCallbacks.JewelryCraftingStation   = subfilterCallbacks.Jewelry
subfilterCallbacks.JewelryRetrait           = subfilterCallbacks.Jewelry

--Global variable
AF.subfilterCallbacks = subfilterCallbacks

--Callback functions for external addons, used on AF.util.SubfilterRefresh() filter function to grey out subfilter buttons
AF.SubfilterRefreshCallbacks = {}

--Build the ALL dropdown callback submenus based on all available groups and their existing callbacks in table subfilterCallbacks
--TODO: Loop over subfilterCallbacks, get all subtables (= groups) and read their callbacks -> For each new one create a subMenu
--TODO: for the ALL group. But skip some groups like "Junk"


