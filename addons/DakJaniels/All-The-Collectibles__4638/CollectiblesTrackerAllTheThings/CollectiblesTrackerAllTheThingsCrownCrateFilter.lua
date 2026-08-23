--- @class (partial) CollectiblesTrackerAllTheThings
---
--- Nested FilterDrop menus via LibScrollableMenu.
--- Unsorted tab: Collections parent -> subcategory (CollectionsBook.lua tree).
--- Crown Crates: crate -> quality. Crown Store: category -> subcategory.
--- Collectibles Tracker has no extra-column API; Source stays the leaf name.
---
local CollectiblesTrackerAllTheThings = CollectiblesTrackerAllTheThings

local UNSORTED_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY
local CROWN_CRATE_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY_CROWN_CRATES
local CROWN_STORE_TAB_KEY = CollectiblesTrackerAllTheThings.THIRD_PARTY_TAB_KEY_CROWN_STORE
local SCROLL_LIST_DATA_TYPE = 1
local FILTER_ID_ALL = 1
local FILTER_ID_GROUP_PARENT = 0

local function GetCrownCrateGroupKey(sourceRow)
    if (sourceRow.crateKey ~= "") then
        return sourceRow.crateKey
    end
    if (sourceRow.crateTitle ~= "") then
        return sourceRow.crateTitle
    end
    return tostring(sourceRow[1] or "")
end

local function FindMenuEntryByFilterId(menuEntries, filterId)
    if (filterId == FILTER_ID_ALL or filterId == FILTER_ID_GROUP_PARENT) then
        return menuEntries[1]
    end

    for menuIndex = 2, #menuEntries do
        local crateEntry = menuEntries[menuIndex]
        if (crateEntry.id == filterId) then
            return crateEntry
        end
        local qualityEntries = crateEntry.entries
        if (qualityEntries) then
            for _, qualityEntry in ipairs(qualityEntries) do
                if (qualityEntry.id == filterId) then
                    return qualityEntry
                end
            end
        end
    end

    return menuEntries[1]
end

local function BuildCrownCrateFilterMenuEntries(list)
    local function OnFilterEntrySelected()
        list:UpdateState()
    end

    local menuEntries = {
        {
            name = GetString(SI_COLLECTIBLES_TRACKER_ALL_THE_THINGS_ALL_CRATES),
            id = FILTER_ID_ALL,
            callback = OnFilterEntrySelected,
        },
    }

    local tabData = list.data
    local crateGroups = {}
    local crateGroupByKey = {}
    for sourceIndex = 2, #tabData do
        local sourceRow = tabData[sourceIndex]
        local crateGroupKey = GetCrownCrateGroupKey(sourceRow)
        local crateGroup = crateGroupByKey[crateGroupKey]
        if (crateGroup == nil) then
            crateGroup = {
                crateKey = sourceRow.crateKey,
                crateId = sourceRow.crateId,
                crateTitle = sourceRow.crateTitle,
                qualityRows = {},
            }
            crateGroupByKey[crateGroupKey] = crateGroup
            crateGroups[#crateGroups + 1] = crateGroup
        end
        crateGroup.qualityRows[#crateGroup.qualityRows + 1] = {
            sourceIndex = sourceIndex,
            quality = sourceRow.quality,
        }
    end

    for _, crateGroup in ipairs(crateGroups) do
        local crateSourceIds = {}
        local qualityEntries = {}
        for _, qualityRow in ipairs(crateGroup.qualityRows) do
            crateSourceIds[qualityRow.sourceIndex] = true
            qualityEntries[#qualityEntries + 1] = {
                name = CollectiblesTrackerAllTheThings.GetCrownCrateQualityName(qualityRow.quality),
                id = qualityRow.sourceIndex,
                callback = OnFilterEntrySelected,
            }
        end

        menuEntries[#menuEntries + 1] = {
            name = CollectiblesTrackerAllTheThings.GetCrownCrateShortDisplayName(crateGroup),
            icon = CollectiblesTrackerAllTheThings.GetCrownCrateDisplayIcon(crateGroup),
            id = FILTER_ID_GROUP_PARENT,
            crateSourceIds = crateSourceIds,
            groupSourceIds = crateSourceIds,
            callback = OnFilterEntrySelected,
            entries = qualityEntries,
        }
    end

    return menuEntries
end

local function AttachNestedFilterMenu(list, attachedFlagName, buildMenuEntries, visibleRowsSubmenu)
    if (list == nil or list[attachedFlagName]) then
        return
    end

    local filterDropControl = list.frame:GetNamedChild("FilterDrop")
    if (filterDropControl == nil) then
        return
    end

    local comboBox = list.filterDrop
    if (comboBox == nil) then
        comboBox = ZO_ComboBox_ObjectFromContainer(filterDropControl)
        list.filterDrop = comboBox
    end
    if (comboBox == nil) then
        return
    end

    AddCustomScrollableComboBoxDropdownMenu(list.frame, filterDropControl, {
        sortEntries = false,
        visibleRowsDropdown = 15,
        visibleRowsSubmenu = visibleRowsSubmenu or 8,
        enableFilter = true,
    })

    comboBox:SetSortsItems(false)
    comboBox:ClearItems()

    local menuEntries = buildMenuEntries(list)
    comboBox:AddItems(menuEntries)

    local selectedEntry = FindMenuEntryByFilterId(menuEntries, list.vars.filterId)
    comboBox:SelectItem(selectedEntry, true)
    list[attachedFlagName] = true
    list:RefreshFilters()
end

function CollectiblesTrackerAllTheThings.AttachCrownCrateFilterMenu(list)
    AttachNestedFilterMenu(list, "crownCrateFilterMenuAttached", BuildCrownCrateFilterMenuEntries, 8)
end

local function GetCrownStoreGroupKey(sourceRow)
    if (sourceRow.parentKey ~= "") then
        return sourceRow.parentKey
    end
    if (sourceRow.parentTitle ~= "") then
        return sourceRow.parentTitle
    end
    return CollectiblesTrackerAllTheThings.GetCrownStoreParentDisplayName(sourceRow)
end

local function BuildCrownStoreFilterMenuEntries(list)
    local function OnFilterEntrySelected()
        list:UpdateState()
    end

    local menuEntries = {
        {
            name = GetString(SI_COLLECTIBLESTRACKER_SOURCE_ALL),
            id = FILTER_ID_ALL,
            callback = OnFilterEntrySelected,
        },
    }

    local tabData = list.data
    local storeGroups = {}
    local storeGroupByKey = {}
    for sourceIndex = 2, #tabData do
        local sourceRow = tabData[sourceIndex]
        local storeGroupKey = GetCrownStoreGroupKey(sourceRow)
        local storeGroup = storeGroupByKey[storeGroupKey]
        if (storeGroup == nil) then
            storeGroup = {
                parentKey = sourceRow.parentKey,
                parentTitle = sourceRow.parentTitle,
                parentCategoryType = sourceRow.parentCategoryType,
                leafRows = {},
            }
            storeGroupByKey[storeGroupKey] = storeGroup
            storeGroups[#storeGroups + 1] = storeGroup
        end
        storeGroup.leafRows[#storeGroup.leafRows + 1] = {
            sourceIndex = sourceIndex,
            sourceRow = sourceRow,
        }
    end

    for _, storeGroup in ipairs(storeGroups) do
        local groupSourceIds = {}
        local leafEntries = {}
        for _, leafRow in ipairs(storeGroup.leafRows) do
            groupSourceIds[leafRow.sourceIndex] = true
            leafEntries[#leafEntries + 1] = {
                name = CollectiblesTrackerAllTheThings.GetCrownStoreDisplayName(leafRow.sourceRow),
                icon = CollectiblesTrackerAllTheThings.GetCrownStoreDisplayIcon(leafRow.sourceRow),
                id = leafRow.sourceIndex,
                callback = OnFilterEntrySelected,
            }
        end

        if (#leafEntries == 1) then
            menuEntries[#menuEntries + 1] = leafEntries[1]
        else
            menuEntries[#menuEntries + 1] = {
                name = CollectiblesTrackerAllTheThings.GetCrownStoreParentDisplayName(storeGroup),
                icon = CollectiblesTrackerAllTheThings.GetCrownStoreParentDisplayIcon(storeGroup),
                id = FILTER_ID_GROUP_PARENT,
                groupSourceIds = groupSourceIds,
                callback = OnFilterEntrySelected,
                entries = leafEntries,
            }
        end
    end

    return menuEntries
end

function CollectiblesTrackerAllTheThings.AttachCrownStoreFilterMenu(list)
    AttachNestedFilterMenu(list, "crownStoreFilterMenuAttached", BuildCrownStoreFilterMenuEntries, 8)
end

local function GetCollectionsGroupKey(sourceRow)
    if (sourceRow.parentKey ~= "") then
        return sourceRow.parentKey
    end
    if (sourceRow.parentTitle ~= "") then
        return sourceRow.parentTitle
    end
    return tostring(sourceRow[1] or "")
end

local function BuildCollectionsFilterMenuEntries(list)
    local function OnFilterEntrySelected()
        list:UpdateState()
    end

    local menuEntries = {
        {
            name = GetString(SI_COLLECTIBLESTRACKER_SOURCE_ALL),
            id = FILTER_ID_ALL,
            callback = OnFilterEntrySelected,
        },
    }

    local tabData = list.data
    local collectionsGroups = {}
    local collectionsGroupByKey = {}
    for sourceIndex = 2, #tabData do
        local sourceRow = tabData[sourceIndex]
        local collectionsGroupKey = GetCollectionsGroupKey(sourceRow)
        local collectionsGroup = collectionsGroupByKey[collectionsGroupKey]
        if (collectionsGroup == nil) then
            collectionsGroup = {
                parentKey = sourceRow.parentKey,
                parentTitle = sourceRow.parentTitle,
                parentIcon = sourceRow.parentIcon,
                isChildlessCategory = sourceRow.isChildlessCategory,
                isUnreleased = sourceRow.isUnreleased,
                isNotImplementedGroup = sourceRow.isNotImplementedGroup,
                leafRows = {},
            }
            collectionsGroupByKey[collectionsGroupKey] = collectionsGroup
            collectionsGroups[#collectionsGroups + 1] = collectionsGroup
        end
        collectionsGroup.leafRows[#collectionsGroup.leafRows + 1] = {
            sourceIndex = sourceIndex,
            sourceRow = sourceRow,
        }
    end

    for _, collectionsGroup in ipairs(collectionsGroups) do
        local groupSourceIds = {}
        local leafEntries = {}
        for _, leafRow in ipairs(collectionsGroup.leafRows) do
            groupSourceIds[leafRow.sourceIndex] = true
            -- Collections Book subcategories have no tree icons (CollectionsBook.lua TreeEntrySetup).
            leafEntries[#leafEntries + 1] = {
                name = leafRow.sourceRow.leafTitle,
                id = leafRow.sourceIndex,
                callback = OnFilterEntrySelected,
            }
        end

        if (#leafEntries == 1) then
            local singleEntry = leafEntries[1]
            if (collectionsGroup.isChildlessCategory
                or collectionsGroup.isUnreleased
                or collectionsGroup.isNotImplementedGroup) then
                singleEntry.name = collectionsGroup.parentTitle
            end
            singleEntry.icon = collectionsGroup.parentIcon
            menuEntries[#menuEntries + 1] = singleEntry
        else
            menuEntries[#menuEntries + 1] = {
                name = collectionsGroup.parentTitle,
                icon = collectionsGroup.parentIcon,
                id = FILTER_ID_GROUP_PARENT,
                groupSourceIds = groupSourceIds,
                callback = OnFilterEntrySelected,
                entries = leafEntries,
            }
        end
    end

    return menuEntries
end

function CollectiblesTrackerAllTheThings.AttachCollectionsFilterMenu(list)
    AttachNestedFilterMenu(list, "collectionsFilterMenuAttached", BuildCollectionsFilterMenuEntries, 15)
end

local function SourceMatchesNestedGroupFilter(data, filterId, groupSourceIds)
    if (filterId == FILTER_ID_ALL) then
        return true
    end
    if (groupSourceIds) then
        return groupSourceIds[data.sourceId] == true
    end
    return filterId == data.sourceId
end

local originalCollectiblesListSetup = CollectiblesList.Setup
function CollectiblesList.Setup(self, key)
    originalCollectiblesListSetup(self, key)
    if (key == CROWN_CRATE_TAB_KEY) then
        CollectiblesTrackerAllTheThings.AttachCrownCrateFilterMenu(self)
    elseif (key == CROWN_STORE_TAB_KEY) then
        CollectiblesTrackerAllTheThings.AttachCrownStoreFilterMenu(self)
    elseif (key == UNSORTED_TAB_KEY) then
        CollectiblesTrackerAllTheThings.AttachCollectionsFilterMenu(self)
    end
end

local originalCollectiblesListFilterScrollList = CollectiblesList.FilterScrollList
function CollectiblesList.FilterScrollList(self)
    if (self.key ~= CROWN_CRATE_TAB_KEY
        and self.key ~= CROWN_STORE_TAB_KEY
        and self.key ~= UNSORTED_TAB_KEY) then
        return originalCollectiblesListFilterScrollList(self)
    end

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local selectedItem = self.filterDrop:GetSelectedItemData()
    local filterId = FILTER_ID_ALL
    local groupSourceIds = nil
    if (selectedItem) then
        filterId = selectedItem.id
        groupSourceIds = selectedItem.groupSourceIds or selectedItem.crateSourceIds
    end
    self.vars.filterId = filterId

    local searchInput = self.searchBox:GetText()
    local collected = 0

    for _, data in ipairs(self.masterList or {}) do
        if (SourceMatchesNestedGroupFilter(data, filterId, groupSourceIds)
            and (self.vars.showHidden or not self:IsEntryHidden(data))
            and (searchInput == "" or self.search:IsMatch(searchInput, data))) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCROLL_LIST_DATA_TYPE, data))
            if (data.status == 2) then
                collected = collected + 1
            end
        end
    end

    local collectedCountControl = self.frame:GetNamedChild("CollectedCount")
    if (#scrollData > 0) then
        collectedCountControl:SetText(string.format(
            GetString(SI_COLLECTIBLESTRACKER_COLLECTED_COUNT),
            collected,
            #scrollData,
            100 * collected / #scrollData
        ))
    else
        collectedCountControl:SetText("")
    end
end
