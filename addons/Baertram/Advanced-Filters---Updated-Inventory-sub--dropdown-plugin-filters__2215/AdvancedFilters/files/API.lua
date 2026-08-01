AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

local util = AF.util

local debugSpam = AF.debugSpam
local pluginNameUnknown = "_pluginNameUnknown"
AF.pluginNameUnknown = pluginNameUnknown

local mapItemFilterTypeToItemFilterCategory = util.mapItemFilterTypeToItemFilterCategory

------------------------------------------------------------------------------------------------------------------------
--Local variables from global addon namespace
------------------------------------------------------------------------------------------------------------------------
local addStrings = AF.util.AddStrings

local filterTypeToGroupName = AF.filterTypeNames
local normalFilterNames = AF.normalFilterNames
local normalFilter2CraftingFilter = AF.normalFilter2CraftingFilter

local subfilterCallbacks = AF.subfilterCallbacks

--Preventer table to check if any plugin strings have been changed to add the unique prefix already
-->Will contain the table as key and a boolean true if already processed!
local alreadyStringProcessedPluginFilterInformation = {}


------------------------------------------------------------------------------------------------------------------------
--Local helper functions for the API
------------------------------------------------------------------------------------------------------------------------
local function BuildAddonInformation(filterInformation, pluginName)
    if filterInformation == nil then return nil end
    --pluginName = pluginName or filterInformation.submenuName or "n/a"
    pluginName = pluginName or (filterInformation.pluginName or filterInformation.submenuName or (filterInformation.callbackTable and filterInformation.callbackTable[1] and filterInformation.callbackTable[1].name))

    --#75 if passed in filterInformation.callbackTable.nestedSubmenuEntries or any entry in nestedSubmenuEntries got nestedSubmenuEntries again (nestedNested...)
    -->LibScrollableMenu must show those as nested submenu entries then, via data.entries = nestedSubmenuEntries later on in AF_FilterBar:ActivateButton -> local function PopulateDropdown(p_newButton)

    local addonInformation = {
        pluginName          = pluginName,
        submenuName         = filterInformation.submenuName,
        callbackTable       = filterInformation.callbackTable, --callbackTable.nestedSubmenuEntries could contain nested submenu menus
        subfilters          = filterInformation.subfilters,
        excludeSubfilters   = filterInformation.excludeSubfilters,
        generator           = filterInformation.generator,
        excludeFilterPanels = filterInformation.excludeFilterPanels,
        onlyGroups          = filterInformation.onlyGroups,
        excludeGroups       = filterInformation.excludeGroups,
    }
    --Error if both group parameters are given: "exclude" and "only"
    local onlyGroups = filterInformation.onlyGroups
    local excludeGroups = filterInformation.excludeGroups
    if onlyGroups ~= nil and excludeGroups ~= nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-Parameters \'onlyGroups\' and \'excludeGroups\' cannot be used together. Please specify only 1 of them!")
        return
    end
    --Check the onlyGroups table for entries like Armor or Weapons and split them up into the normal armor + crafting armor filters (same for weapons)
    if onlyGroups ~= nil and #onlyGroups > 0 then
        local n2c = normalFilter2CraftingFilter
        local nfNames = normalFilterNames
        local aiOnlyGroups = addonInformation.onlyGroups
        if n2c ~= nil and nfNames ~= nil then
            for idx, filterPanelName in pairs(onlyGroups) do
                if nfNames[filterPanelName] then
                    local n2cByName = n2c[filterPanelName]
                    if n2cByName ~= nil then
                        for craftingFilterName, value in pairs(n2cByName) do
                            if value == true and craftingFilterName ~= nil and craftingFilterName ~= "" then
                                table.insert(aiOnlyGroups, craftingFilterName)
                            end
                        end
                    end
                end
            end
        end
    --Check the excludeGroups table for entries like Armor or Weapons and split them up into the normal armor + crafting armor filters (same for weapons)
    elseif excludeGroups ~= nil and #excludeGroups > 0 then
        local n2c = normalFilter2CraftingFilter
        local nfNames = normalFilterNames
        local aiExcludeGroups = addonInformation.excludeGroups
        if n2c ~= nil and nfNames ~= nil then
            for idx, filterPanelName in pairs(excludeGroups) do
                if nfNames[filterPanelName] then
                    local n2cByName = n2c[filterPanelName]
                    if n2cByName ~= nil then
                        for craftingFilterName, value in pairs(n2cByName) do
                            if value == true and craftingFilterName ~= nil and craftingFilterName ~= "" then
                                table.insert(aiExcludeGroups, craftingFilterName)
                            end
                        end
                    end
                end
            end
        end
    end
    --For debugging
    AF.addonInformation = AF.addonInformation or {}
    if pluginName ~= nil then
        AF.addonInformation[pluginName] = addonInformation
    else
        AF.addonInformation[pluginNameUnknown] = AF.addonInformation[pluginNameUnknown] or {}
        table.insert(AF.addonInformation[pluginNameUnknown], addonInformation)
    end
    return addonInformation
end



------------------------------------------------------------------------------------------------------------------------
-- Global addon/plugin API functions
---------------------------------------------------------------------------------------------------------------------------

--Check if the same addon filterInformation is already in the callback tables for the filterType and remove the old one, before
--adding the same/newer one again
function AdvancedFilters_RemoveDuplicateAddonPlugin(filterInformation, groupName, filterTypeWasMappedToNewFilterTypeCategory)
    if filterInformation == nil then return false end
    filterTypeWasMappedToNewFilterTypeCategory = filterTypeWasMappedToNewFilterTypeCategory or false
    if not filterTypeWasMappedToNewFilterTypeCategory then
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        --Added with ESO PTS API100033 Markarth
        --Use util.mapItemFilterTypeToItemFilterCategory(itemFilterType) to map the itemFilterTypes specified in the
        -->filterInformationTable to the new ZOs ItemFilterDisplayCategory! Else the subfilterBars won't be recognized
        -->properly and the dropdown filters won't be registered to the correct bars!
        local itemFilterCategory = mapItemFilterTypeToItemFilterCategory(filterInformation.filterType)
        filterInformation.filterType = itemFilterCategory
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    end
    groupName = groupName or filterTypeToGroupName[filterInformation.filterType] or nil
    if groupName == nil then
        return
    end
    local addonInformation = BuildAddonInformation(filterInformation)
    if addonInformation == nil then return false end

    --Check if the same addon information is already in the callback tables for the filterType
    --and remove the old one, before adding the same/newer one again
    local removedDuplicate = false
    local subfilterCallBacksOfGroup = subfilterCallbacks[groupName]
    if subfilterCallBacksOfGroup ~= nil and subfilterCallBacksOfGroup.addonDropdownCallbacks ~= nil then
        local existingAFSubfilterCallbacksInfo = subfilterCallbacks[groupName].addonDropdownCallbacks
        for index, subfilterCallbacksInfo in pairs(existingAFSubfilterCallbacksInfo) do
            --FilterInformation got a submenu? Compare the submenu names and remove exisitng before re-adding this
            if addonInformation.submenuName ~= nil then
                if subfilterCallbacksInfo ~= nil and type(subfilterCallbacksInfo) == "table"
                    and subfilterCallbacksInfo.submenuName ~= nil and subfilterCallbacksInfo.submenuName == addonInformation.submenuName then
                    --Remove this entry from the subfilterCallbacks as the same submenu will be added again
--d("[AF]RemoveDuplicatePluginEntries at group: ".. tostring(groupName) .." - SUBMENU: " ..tostring(addonInformation.submenuName))
                    table.remove(existingAFSubfilterCallbacksInfo, index)
                    removedDuplicate = true
--[[
                else
                    if subfilterCallbacksInfo ~= nil and type(subfilterCallbacksInfo) == "table" then
--d(">submenuName: " ..tostring(subfilterCallbacksInfo.submenuName))
                    else
d("[AdvancedFilters_RemoveDuplicateAddonPlugin]Plugin SUBMENU callback name: \'"..tostring(addonInformation.submenuName).."\', group: " ..tostring(groupName) .." - Compared existingSubfilterCallbacksTableAtGroup entry is nil or not a table!- index: " ..tostring(index) .. ", subfilterCallbacksInfo: " ..tostring(subfilterCallbacksInfo))
d(">type subfilterCallbacksInfo: " .. tostring(type(subfilterCallbacksInfo)))
                    end
]]
                end
            else
                --No submenu name is given: Compare the callbackTable contents
                local newPluginCallbackTable = addonInformation.callbackTable
                local existingSubfilterCallbacksTableAtGroup = subfilterCallbacksInfo.callbackTable
                if newPluginCallbackTable.name ~= nil and existingSubfilterCallbacksTableAtGroup ~= nil then
                    --Check each entry of the exisitng addon dropdown plugin callbackTable
                    for cbTabIndex, cbTabEntry in pairs(existingSubfilterCallbacksTableAtGroup) do
                        if cbTabEntry ~= nil and type(cbTabEntry) == "table"
                                and cbTabEntry.name ~= nil and cbTabEntry.name == newPluginCallbackTable.name then
--d("[AF]RemoveDuplicatePluginEntries at group: ".. tostring(groupName) .." - " ..tostring(newPluginCallbackTable.name))
                            --Same name of the callback plugin table was found: Remove the old plugin callbackTable completely
                            --Remove this entry from the subfiltercallbacks as the same submenu will be added again
                            table.remove(existingAFSubfilterCallbacksInfo, index)
                            removedDuplicate = true
--[[
                        else
                            if cbTabEntry ~= nil and type(cbTabEntry) == "table" then
                                --d(">cbTabEntry.name: " ..tostring(cbTabEntry.name))
                            else
d("[AdvancedFilters_RemoveDuplicateAddonPlugin]ERROR - Plugin callback name: \'"..tostring(newPluginCallbackTable.name).."\', group: " ..tostring(groupName) .." - cbTabIndex: " ..tostring(cbTabIndex) .. ", cbTabEntry: " ..tostring(cbTabEntry))
d(">type cbTabEntry: " .. tostring(type(cbTabEntry)))
                            end
]]
                        end
                    end
                end
            end
        end
    end
    return removedDuplicate
end
local removeDuplicateAddonPlugin = AdvancedFilters_RemoveDuplicateAddonPlugin



--Register a filterInformation table to AdvancedFilters -> Register a plugin for the filter dropdown boxes
function AdvancedFilters_RegisterFilter(filterInformationTable)
    local pluginName = filterInformationTable.pluginName or filterInformationTable.submenuName or (filterInformationTable.callbackTable and filterInformationTable.callbackTable[1] and filterInformationTable.callbackTable[1].name)

--d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'")

    --make sure all necessary information is present
    if filterInformationTable == nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-No filter information provided. Filter not registered.")
        return
    end
    if filterInformationTable.callbackTable == nil and filterInformationTable.generator == nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-No callback information provided. Filter not registered.")
        return
    end
    if filterInformationTable.subfilters == nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-No subfilter type information provided. Filter not registered.")
        return
    end
    if filterInformationTable.filterType == nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-No base filter type information provided. Filter not registered.")
        return
    end
    if filterInformationTable.enStrings == nil and filterInformationTable.generator == nil then
        d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-No English strings provided. Filter not registered.")
        return
    end

    --------------------------------------------------------------------------------------------------------------------
    --Parse the filterInformation now and add the plugin data to the dropdown filters
    local function parseFilterInformation(filterInformation, originalFilterInformationTable)
        originalFilterInformationTable = originalFilterInformationTable or filterInformation

--        local filterTypeToGroupName = AF.filterTypeNames
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        --Added with ESO PTS API100033 Markarth
        --Use util.mapItemFilterTypeToItemFilterCategory(itemFilterType) to map the itemFilterTypes specified in the
        -->filterInformationTable to the new ZOs ItemFilterDisplayCategory! Else the subfilterBars won't be recognized
        -->properly and the dropdown filters won't be registered to the correct bars!
        local itemFilterCategory = mapItemFilterTypeToItemFilterCategory(filterInformation.filterType)
        filterInformation.filterType = itemFilterCategory
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        local groupName = filterTypeToGroupName[filterInformation.filterType] or nil
        if groupName == nil then
            d("[AdvancedFilters_RegisterFilter]Plugin: \'"..tostring(pluginName).."\'-Given \"filterType\" " .. tostring(filterInformation.filterType) .. " in the plugin's filterInformation is not known within the addon.\nPlease see file \"constants.lua\", table \"filterTypeNames\" for valid filterTypes!\nFilter not registered.")
            return
        else
            if subfilterCallbacks[groupName] == nil or subfilterCallbacks[groupName].addonDropdownCallbacks == nil then return end
        end

        --Check if the same addon information is already in the callback tables for the filterType
        --and remove the old one, before adding the same/newer one again
        removeDuplicateAddonPlugin(filterInformation, groupName, true)


        --get filter information from the calling addon and insert it into our callback table
        local addonInformation = BuildAddonInformation(filterInformation, pluginName)
        --insert addon/plugin's callbacks to subFilter callbacks of group
        table.insert(subfilterCallbacks[groupName].addonDropdownCallbacks, addonInformation)


        --if strings are going to be generated from a function at the plugin (as dropdown menu opens), end registration now
        if filterInformation.generator ~= nil then return end


        --Add the texts to the AF.strings table
        addStrings(filterInformation.enStrings, filterInformation, pluginName)
    end
    --------------------------------------------------------------------------------------------------------------------




    --Support for filterType = table, but not if it's a "generator" run!
    local filterTypes = filterInformationTable.filterType
    if not filterInformationTable.generator and type(filterTypes) == "table" then
        local filterInformationForEachFilterType
        --Call the parse function once for each filterType
        for _, filterInformationFilterType in pairs(filterTypes) do
            if filterInformationFilterType ~= nil and filterInformationFilterType ~= "" then
                --Everything else will be taken 1:1 from "filterInformationTable" table data!
                if filterInformationForEachFilterType == nil then
                    filterInformationForEachFilterType = ZO_DeepTableCopy(filterInformationTable)
                end
                --But just exchange the filterType on each call
                filterInformationForEachFilterType.filterType = filterInformationFilterType
                if filterInformationForEachFilterType ~= nil then
                    parseFilterInformation(filterInformationForEachFilterType, filterInformationTable)
                end
            end
        end
    else
        parseFilterInformation(filterInformationTable, nil)
    end
end

--Register a filter function for the Subfilterbars buttons so they properly grey out if your addon
--changes filters as well (e.g. FCOCraftFilter will filter by the bagId to hide/only show bank items at crafting tables)
--> See function AF.util.RefreshSubfilterBar -> calling function AF.util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters
function AdvancedFilters_RegisterSubfilterbarRefreshFilter(filterInformationTable)
    local pluginName = filterInformationTable.filterName
--d("[AF]AdvancedFilters_RegisterSubfilterbarRefreshFilter " .. tostring(filterInformationTable.filterName))
    --make sure all necessary information is present
    if filterInformationTable == nil then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No filter information provided. Filter not registered.")
        return
    end
    if filterInformationTable.inventoryType == nil then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No inventory type information provided. Filter not registered.")
        return
    end
    if filterInformationTable.craftingType == nil then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No crafting type information provided. Filter not registered.")
        return
    end
    if filterInformationTable.filterPanelId == nil then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No libFilters-3.0 panel Id (LF_ ...) provided. Filter not registered.")
        return
    end
    if filterInformationTable.filterName == nil then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No unique filter name provided. Filter not registered.")
        return
    end
    if filterInformationTable.callbackFunction == nil or type(filterInformationTable.callbackFunction) ~= "function" then
        d("[AdvancedFilters_RegisterSubfilterbarRefreshFilter]Plugin: \'"..tostring(pluginName).."\'-No callback function provided. Filter not registered.")
        return
    end
    --Register the filter callback function for each inventory type + each crafting type at the inventory type:
    local inventoryTypes = filterInformationTable.inventoryType
    local craftingTypes = filterInformationTable.craftingType
    local subfilterRefreshCallbacks = AF.SubfilterRefreshCallbacks
    for _, inventoryType in pairs(inventoryTypes) do
        for _, craftingType in pairs(craftingTypes) do
            --insert subfilterbar refresh filter information from external addon
            if subfilterRefreshCallbacks[inventoryType] == nil then subfilterRefreshCallbacks[inventoryType] = {} end
            if subfilterRefreshCallbacks[inventoryType][craftingType] == nil then subfilterRefreshCallbacks[inventoryType][craftingType] = {} end
            if subfilterRefreshCallbacks[inventoryType][craftingType][filterInformationTable.filterPanelId] == nil then subfilterRefreshCallbacks[inventoryType][craftingType][filterInformationTable.filterPanelId] = {} end
            subfilterRefreshCallbacks[inventoryType][craftingType][filterInformationTable.filterPanelId][tostring(filterInformationTable.filterName)] = filterInformationTable.callbackFunction
        end
    end
end
