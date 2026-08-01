--AFDup = {}

local AF = AdvancedFilters
local util = AF.util

local checkCraftingStationSlot = AF.checkCraftingStationSlot
local isCraftingStationInventoryType = util.IsCraftingStationInventoryType
local getCurrentFilterTypeForInventory = util.GetCurrentFilterTypeForInventory
local getInventoryFromCraftingPanel = util.GetInventoryFromCraftingPanel

local invDataCopy = nil
local invType = nil
local isCraftingInventoryType = nil
local filterPanelId
local currentFilterIndex

AF.externalDropdownFilterPlugins = AF.externalDropdownFilterPlugins or {}
AF.externalDropdownFilterPlugins.AF_FCODuplicateItemsFilters = {
    isFiltering = false
}

--Constants for the different searches
local search_name = 1
local search_namequality = 2
local search_namelevel = 3
local search_nametrait = 4
local search_namequalitylevel = 5
local search_namequalitytrait = 6
local search_nameleveltrait = 7
local search_all = 999

--Delay before the filters are actually called (to provide time to read and copy the inventory slots for duplicate comparison)
local delay = 25

local wasManuallyFiltered = false

----------------------------------------------------------------------------------------------------------------
--This function is called at the start of the dropdown filter execution, before any filters are applied.
-->Takes only "the visible" from the current's listView and saves them in a copy "invDataCopy"
local function FilterStartCallback()
--d("[FilterStartCallback]")
    local inventoryControl
    if not invDataCopy or (invDataCopy and #invDataCopy <= 0) then
        --AFDup.slots = {}

        invType = AF.currentInventoryType
        isCraftingInventoryType = isCraftingStationInventoryType(invType)
        filterPanelId = getCurrentFilterTypeForInventory(invType)

        if isCraftingInventoryType then
            inventoryControl = getInventoryFromCraftingPanel(filterPanelId)
        else
            if PLAYER_INVENTORY.inventories[invType] ~= nil then
                inventoryControl = PLAYER_INVENTORY.inventories[invType]
            end
        end
        --Inventory control was found? So get it's listView data now
        if inventoryControl then
            local invDataPointer = (inventoryControl.listView and inventoryControl.listView.data) or (inventoryControl.list and inventoryControl.list.data)
            if invDataPointer and #invDataPointer > 0 then
                invDataCopy = {}
                for index, slotData in ipairs(invDataPointer) do
                    local data = slotData.data
                    if data then
                        invDataCopy[index] = {}
                        invDataCopy[index].data = data
                    end
                end
            end
        end
    end
    --Set variable in externalFilterPlugin table to true, so other addons can know that the plugin is currently used
    --Will be reset within AdvancedFilters util function AF.util.ResetExternalDropdownFilterPluginsIsFiltering()
    --as another filter is selected from the dropdown box
    --AF.externalDropdownFilterPlugins.AF_FCODuplicateItemsFilters.isFiltering = true

    --AFDup.invData = invData
    --AFDup.inventoryControl = inventoryControl
    --AFDup.invDataCopy = invDataCopy

    --AFDup.invType = invType
    --AFDup.isCraftingInventoryType = isCraftingInventoryType
    --AFDup.filterPanelId = filterPanelId
end

--This function is called at the end of the dropdown filter execution, as all items have been scanned
local function FilterEndCallback()
--d("[FilterEndCallback]")
    --Clear the copied "prefiltered item list of the inventory's listView"
    --> Will lead to an empty inventory list as the comparison data is missing! So it needs to be rebuild each time
    --> it is missing, via function FilterStartCallback -> See function FilterCallbackFunctionForFCODuplicateItems
    invDataCopy = nil

    --Clear the values which need to be set once
    invType = nil
    isCraftingInventoryType = nil

    wasManuallyFiltered = false
end

----------------------------------------------------------------------------------------------------------------
--Function to compare the items data of the current slot and the prefiltered inventory slot items (taken from the shown inventory list)
local function checkItems(p_duplicateFilterType, p_slot, p_isCrafting)
    --invDataCopy will be nil here e.g. if this function is called as the inventory updates after an item was withdrawn/deposit from/to banks
    --and the current inventory list refreshes the filtered items. The variable "wasManuallyFiltered" is false then (as it was reset due to function
    --"FilterEndCallback" already).
    if invDataCopy == nil then
        if not wasManuallyFiltered then
--d(">not filtering manually -> invDataCopy is nil: ReApplying dropdown filter!")
            --ReApply the current filter of the dropdown box as this will refresh the inventory slots and data properly
            util.ReApplyDropdownFilter()
        end
        return false
    end

    local itemLinkCompare
    local itemLink
    --For crafting tables: The parameter p_slot is not filled with all relevant data but only bagId and slotIndex.
    --Rebuild the needed data for comparison
    local bagId, slotIndex = p_slot.bagId, p_slot.slotIndex
    itemLink               = p_slot.itemlink or GetItemLink(bagId, slotIndex)

--d(">Checking: " .. itemLink)

    p_slot.itemInstanceId = p_slot.itemInstanceId or GetItemInstanceId(bagId, slotIndex)
    p_slot.rawName = p_slot.rawName or GetItemLinkName(itemLink)
    p_slot.name = p_slot.name or ZO_CachedStrFormat("<<C:1>>", p_slot.rawName)
    p_slot.equipType = p_slot.equipType or GetItemLinkEquipType(itemLink)
    if p_slot.itemType == nil or p_slot.specializedItemType == nil then
        p_slot.itemType, p_slot.specializedItemType = GetItemLinkItemType(itemLink)
    end
    p_slot.quality = p_slot.quality or GetItemLinkQuality(itemLink)
    p_slot.traitInformation = (p_slot.traitInformation ~= nil and p_slot.traitInformation ~= 0 and p_slot.traitInformation) or GetItemLinkTraitInfo(itemLink)
    p_slot.requiredLevel = p_slot.requiredLevel or GetItemLinkRequiredLevel(itemLink)
    p_slot.requiredChampionPoints = p_slot.requiredChampionPoints or GetItemLinkRequiredChampionPoints(itemLink)
    for _, sharedInvSlot in pairs(invDataCopy) do
        local equalQuality, equalLevel, equalTrait, equalQualityLevel, equalQualityTrait, equalLevelTrait, equalAll, sharedInvSlotData = false, false, false, false, false, false, false, nil
        if sharedInvSlot.data then
            sharedInvSlotData = sharedInvSlot.data
            if sharedInvSlotData.slotIndex and slotIndex ~= sharedInvSlotData.slotIndex then
                itemLinkCompare = GetItemLink(sharedInvSlotData.bagId, sharedInvSlotData.slotIndex)
                if (
                    ((p_slot.itemInstanceId and sharedInvSlotData.itemInstanceId and p_slot.itemInstanceId == sharedInvSlotData.itemInstanceId) or (not p_slot.itemInstanceId and not sharedInvSlotData.itemInstanceId))
                    or
                    (
                    ((p_slot.equipType and sharedInvSlotData.equipType and p_slot.equipType == sharedInvSlotData.equipType) or (not p_slot.equipType and not sharedInvSlotData.equipType)) and
                    ((p_slot.itemType and sharedInvSlotData.itemType and p_slot.itemType == sharedInvSlotData.itemType) or (not p_slot.itemType and not sharedInvSlotData.itemType)) and
                    ((p_slot.specializedItemType and sharedInvSlotData.specializedItemType and p_slot.specializedItemType == sharedInvSlotData.specializedItemType) or (not p_slot.specializedItemType and not sharedInvSlotData.specializedItemType))
                    )
                    ) and ((p_slot.rawName and sharedInvSlotData.rawName and p_slot.rawName == sharedInvSlotData.rawName) or (p_slot.name and sharedInvSlotData.name and p_slot.name == sharedInvSlotData.name))
                then
--d(">>>duplicate name: " .. itemLinkCompare)
                    if p_duplicateFilterType == search_name then
                        return true
                    else
                        if p_duplicateFilterType == search_all or p_duplicateFilterType == search_namequality or p_duplicateFilterType == search_namequalitylevel or p_duplicateFilterType == search_namequalitytrait then
                            equalQuality = ( p_slot.quality and sharedInvSlotData.quality and p_slot.quality == sharedInvSlotData.quality ) or false
                        end
                        if p_duplicateFilterType == search_all or  p_duplicateFilterType == search_namelevel or p_duplicateFilterType == search_namequalitylevel or p_duplicateFilterType == search_nameleveltrait then
                            equalLevel = ( (p_slot.requiredLevel and sharedInvSlotData.requiredLevel and p_slot.requiredLevel == sharedInvSlotData.requiredLevel)
                                    and (
                                    ((not p_slot.requiredChampionPoints and not sharedInvSlotData.requiredChampionPoints) or (p_slot.requiredChampionPoints and p_slot.requiredChampionPoints == 0 and sharedInvSlotData.requiredChampionPoints and sharedInvSlotData.requiredChampionPoints == 0))
                                            or (p_slot.requiredChampionPoints and sharedInvSlotData.requiredChampionPoints and p_slot.requiredChampionPoints > 0 and p_slot.requiredChampionPoints == sharedInvSlotData.requiredChampionPoints)
                            )
                            ) or false
                        end
                        if p_duplicateFilterType == search_all or  p_duplicateFilterType == search_nametrait or p_duplicateFilterType == search_namequalitytrait or p_duplicateFilterType == search_nameleveltrait then
                            --Trait info on invSlot is somehow = 0 sometimes so reRead it here
                            local traitOfsharedInvSlotData = GetItemLinkTraitInfo(itemLinkCompare)
                            equalTrait = ( p_slot.traitInformation and p_slot.traitInformation == traitOfsharedInvSlotData ) or false
                        end
                        equalQualityLevel    = (equalQuality and equalLevel) or false
                        equalQualityTrait    = (equalQuality and equalTrait) or false
                        equalLevelTrait      = (equalLevel and equalTrait) or false
                        equalAll             = (equalQualityLevel and equalTrait) or false
                        --Special item types, like MasterWrits
                        local isMasterWrit = p_slot.itemType == ITEMTYPE_MASTER_WRIT or false

--d(">>>>>quality: " ..tostring(equalQuality) .. ", level: " ..tostring(equalLevel) .. ", trait: " ..tostring(equalTrait).. ", qualityLevel: " ..tostring(equalQualityLevel).. ", qualityTrait: " ..tostring(equalQualityTrait).. ", levelTrait: " ..tostring(equalLevelTrait) .. ", all: " .. tostring(equalAll))
                        if p_duplicateFilterType == search_all then
                            if isMasterWrit then
                                local function GetItemLinkWritVoucherCount(p_itemLink)
                                    local data = select(24, ZO_LinkHandler_ParseLink(p_itemLink))
                                    if data then
                                        local vouchers = tonumber(data) / 10000
                                        return tonumber(string.format("%.0f", vouchers))
                                    else
                                        return -1
                                    end
                                end
                                --Get the data about item to craft + voucher account reward and let them flow into the "all" decision
                                local isEqualMasterWrit = false
                                local mwVouchers = GetItemLinkWritVoucherCount(itemLink)
                                local mwVouchersCompare = GetItemLinkWritVoucherCount(itemLinkCompare)
                                if mwVouchers == mwVouchersCompare then
                                    local mwBaseText = GenerateMasterWritBaseText(itemLink)
                                    local mwBaseTextCompare = GenerateMasterWritBaseText(itemLinkCompare)
                                    if mwBaseText == mwBaseTextCompare then
                                        local mwRewardText = GenerateMasterWritRewardText(itemLink)
                                        local mwRewardTextCompare = GenerateMasterWritRewardText(itemLinkCompare)
                                        if mwRewardText == mwRewardTextCompare then
                                            isEqualMasterWrit = true
                                        end
                                    end
                                end
                                equalAll = equalAll and isEqualMasterWrit
                            end
                            return equalAll
                        else
                            if p_duplicateFilterType == search_namequality then
                                return equalQuality
                            elseif p_duplicateFilterType == search_namelevel then
                                return equalLevel
                            elseif p_duplicateFilterType == search_nametrait then
                                return equalTrait
                            elseif p_duplicateFilterType == search_namequalitylevel then
                                return equalQualityLevel
                            elseif p_duplicateFilterType == search_namequalitytrait then
                                return equalQualityTrait
                            elseif p_duplicateFilterType == search_nameleveltrait then
                                return equalLevelTrait
                            end
                        end --if p_duplicateFilterType == "all" then
                    end --if p_duplicateFilterType == "name" then
                end
            end
        end
    end
    --d(">>checkItems - END")
    return false
end
----------------------------------------------------------------------------------------------------------------

--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local function FilterCallbackFunctionForFCODuplicateItems(duplicateFilterType, indexOfChosenDuplicateFilter)
--d("[AF]DuplicateItemFilter: " ..tostring(duplicateFilterType))
    currentFilterIndex = indexOfChosenDuplicateFilter

    --The slot check function for comparison of each item
    return function(slot, slotIndex)
        --At crafting stations the slot is ONLY the bagId. At inventories it's the slotData of the inventorySlot
        slot = checkCraftingStationSlot(slot, slotIndex)
--AFDup.slots = AFDup.slots or {}
        local foundADuplicateItem = false
        --Get the item bag and slotIndex of the item to compare all other items to
        foundADuplicateItem = checkItems(duplicateFilterType, slot, isCraftingInventoryType)
--slot._foundDuplicate = foundADuplicateItem
--table.insert(AFDup.slots, slot)
        --Different duplicate checks
        return foundADuplicateItem
    end
end


--filterResetAtStart:
--Check if the parameter to reset the current dropdown filter to "All" was registered
-->This is needed if the dropdown filters rely on the currently "shown" (and thus already filtered) inventory items
-->to only use these for their filter functions/comparisons, and not ALL items of the inventories involved
--filterResetAtStartDelay: Set delay so the next dropdown filter will be called AFTER evertyhing got updated via filterResetAtStart
local FCODuplicateItemsDropdownCallback = {
    { name = "DuplicateAll",                filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_all, 1),                 filterEndCallback = FilterEndCallback},
    { name = "DuplicateName",               filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_name, 2),                filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameQuality",        filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_namequality, 3),         filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameLevel",          filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_namelevel, 4),           filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameTrait",          filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_nametrait, 5),           filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameQualityLevel",   filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_namequalitylevel, 6),    filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameQualityTrait",   filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_namequalitytrait, 7),    filterEndCallback = FilterEndCallback},
    { name = "DuplicateNameLevelTrait",     filterResetAtStart = true, filterResetAtStartDelay = delay, filterStartCallback = function() wasManuallyFiltered = true FilterStartCallback() end,   filterCallback = FilterCallbackFunctionForFCODuplicateItems(search_nameleveltrait, 8),      filterEndCallback = FilterEndCallback},
}


--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCODuplicateItems = {
    ["FCODuplicateItemSubMenu"] 			= "Duplicate",
    ["DuplicateAll"]                        = "Dupl.: All",
    ["DuplicateName"]                       = "Dupl.: Only name",
    ["DuplicateNameQuality"]                = "Dupl.: Name & quality",
    ["DuplicateNameLevel"]                  = "Dupl.: Name & level",
    ["DuplicateNameTrait"]                  = "Dupl.: Name & trait",
    ["DuplicateNameQualityLevel"]           = "Dupl.: Name, quality & level",
    ["DuplicateNameQualityTrait"]           = "Dupl.: Name, quality & trait",
    ["DuplicateNameLevelTrait"]             = "Dupl.: Name, level & trait",
}
local deFCODuplicateItems = {
    ["FCODuplicateItemSubMenu"] 			= "Doppelte",
    ["DuplicateAll"]                        = "Dopp.: Alles",
    ["DuplicateName"]                       = "Dopp.: Nur Name",
    ["DuplicateNameQuality"]                = "Dopp.: Name & Qualität",
    ["DuplicateNameLevel"]                  = "Dopp.: Name & Level",
    ["DuplicateNameTrait"]                  = "Dopp.: Name & Eigenschaft",
    ["DuplicateNameQualityLevel"]           = "Dopp.: Name, Qualität & Level",
    ["DuplicateNameQualityTrait"]           = "Dopp.: Name, Qualität & Eigenschaft",
    ["DuplicateNameLevelTrait"]             = "Dopp.: Name, Level & Eigenschaft",
}
deFCODuplicateItems = setmetatable(deFCODuplicateItems, {__index = enFCODuplicateItems})

--ARMOR
--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	submenuName = "FCODuplicateItemSubMenu",
	callbackTable = FCODuplicateItemsDropdownCallback,
	filterType = {ITEMFILTERTYPE_ALL},
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_SMITHING_REFINE,
        LF_JEWELRY_REFINE,
        LF_ALCHEMY_CREATION,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_ENCHANTING_CREATION,
        LF_ENCHANTING_EXTRACTION,
    },
	enStrings = enFCODuplicateItems,
	deStrings = deFCODuplicateItems,
	frStrings = enFCODuplicateItems,
	esStrings = enFCODuplicateItems,
	ruStrings = enFCODuplicateItems,
	jpStrings = enFCODuplicateItems,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)