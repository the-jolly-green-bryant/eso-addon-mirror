-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Results module for CollectThemAll add-on
-----------------------------------------------------------

CollectThemAllResults = CollectThemAllResults or {}
local CTAResults = CollectThemAllResults
local CTAData = CollectThemAllData

CTAResults.COLLECTION = {
    CATEGORIES = "categories",
    SUBCATEGORIES = "subcategories",
    SOURCES = "sources",
    GROUPS = "groups",
    TYPES = "types",
}

CTAResults.OrderByNone = "None"
CTAResults.OrderById = "Id"
CTAResults.OrderByCollection = "Collection"
CTAResults.OrderByName = "Name"
CTAResults.OrderBy = { CTAResults.OrderByNone, CTAResults.OrderById, CTAResults.OrderByCollection, CTAResults.OrderByName }

CTAResults.refreshDelay = 1200
CTAResults.chunkDelay = 300
CTAResults.chunkSize = 50

CTAResults.sv = {
    showUncollectedItemsOnly = false,
    rebuildOnDemandOnly = true,
    orderedBy = 3,

    selectedCategory = "All",
    selectedSubcategory = "All",
    selectedSource = "All",
    selectedGroup = "All",

    debug = false,

    -- collections, values by ix
    results = {},
    categories = {},
    subcategories = {},
    sources = {},
    groups = {},
    types = {},

    collectedCount = 0,
    totalCount = 0,

    lastVersion = "0.0.1",
    nextVersion = nil,
}

CTAResults.state = {
    matchingRows = {},
    matchingPageRows = {},
    matchingSelectedRow = nil,
    matchingPage = 1,
    matchingPageSize = 50,
    matchingTotalPages = 1,

    searchFilter = "",

    -- ids/ixs by value
    _categories = {},
    _subcategories = {},
    _sources = {},
    _groups = {},
    _types = {},

    -- for build only
    _categoryTypes = {},
    _fragmentsMap = {},
    _itemsFromFragments = {},
    _matchingItems = {},
    _matchingFragments = {},
}

CTAResults.cache = {
    categoryNames = {},
}

CTAResults.callbacks = {
    RefreshFull = function() end,
}

function CTAResults.Initialize(sv, RefreshFull)
    CTAResults.sv = sv

    CTAResults.EnsureSavedVariables()
    CTAResults.EnsureState()

    if RefreshFull then CTAResults.callbacks.RefreshFull = RefreshFull end

    local forced = CTAResults.sv.nextVersion ~= CTAResults.sv.lastVersion or CTAResults.sv.lastVersion == nil
    CTAResults.Build(forced)
end

function CTAResults.EnsureSavedVariables()
    if type(CTAResults.sv.debug) ~= "boolean" then CTAResults.sv.debug = false end

    if type(CTAResults.sv.showUncollectedItemsOnly) ~= "boolean" then CTAResults.sv.showUncollectedItemsOnly = false end
    if type(CTAResults.sv.rebuildOnDemandOnly) ~= "boolean" then CTAResults.sv.rebuildOnDemandOnly = true end
    if type(CTAResults.sv.orderedBy) ~= "number" then CTAResults.sv.orderedBy = 3 end
    if type(CTAResults.sv.selectedCategory) ~= "string" then CTAResults.sv.selectedCategory = "All" end
    if type(CTAResults.sv.selectedSubcategory) ~= "string" then CTAResults.sv.selectedSubcategory = "All" end
    if type(CTAResults.sv.selectedSource) ~= "string" then CTAResults.sv.selectedSource = "All" end
    if type(CTAResults.sv.selectedGroup) ~= "string" then CTAResults.sv.selectedGroup = "All" end

    if type(CTAResults.sv.results) ~= "table" then CTAResults.sv.results = {} end
    if type(CTAResults.sv.categories) ~= "table" then CTAResults.sv.categories = {} end
    if type(CTAResults.sv.subcategories) ~= "table" then CTAResults.sv.subcategories = {} end
    if type(CTAResults.sv.sources) ~= "table" then CTAResults.sv.sources = {} end
    if type(CTAResults.sv.groups) ~= "table" then CTAResults.sv.groups = {} end
    if type(CTAResults.sv.types) ~= "table" then CTAResults.sv.types = {} end

    if type(CTAResults.sv.collectedCount) ~= "number" then CTAResults.sv.collectedCount = 0 end
    if type(CTAResults.sv.totalCount) ~= "number" then CTAResults.sv.totalCount = 0 end
end

function CTAResults.EnsureState()
    CTAResults.state.matchingRows = CTAResults.state.matchingRows or {}
    CTAResults.state.matchingPageRows = CTAResults.state.matchingPageRows or {}
    CTAResults.state.matchingSelectedRow = CTAResults.state.matchingSelectedRow or nil
    CTAResults.state.matchingPage = CTAResults.state.matchingPage or 1
    CTAResults.state.matchingPageSize = CTAResults.state.matchingPageSize or 50
    CTAResults.state.matchingTotalPages = CTAResults.state.matchingTotalPages or 1

    CTAResults.state.searchFilter = CTAResults.state.searchFilter or ""
end

function CTAResults.ClearWholeState()
    CTAResults.sv.results = {}

    CTAResults.sv.categories = {}
    CTAResults.sv.subcategories = {}
    CTAResults.sv.sources = {}
    CTAResults.sv.groups = {}
    CTAResults.sv.types = {}

    CTAResults.state._categories = {}
    CTAResults.state._subcategories = {}
    CTAResults.state._sources = {}
    CTAResults.state._groups = {}
    CTAResults.state._types = {}

    CTAResults.state.matchingSelectedRow = nil
    CTAResults.state.matchingPage = 1
    CTAResults.state.matchingTotalPages = 1
    CTAResults.state.matchingRows = {}
    CTAResults.state.matchingPageRows = {}

    CTAResults.cache.categoryNames = {}

    CTAResults.sv.collectedCount = 0
    CTAResults.sv.totalCount = 0

    CTAResults.Debug("All saved results cleared.")
end

function CTAResults.AddToCollection(collection, value, getValueKeyFunc)
    local valueKey = getValueKeyFunc and getValueKeyFunc(value) or value

    local reverseCollection = "_"..collection
    if CTAResults.state[reverseCollection][valueKey] then
        return CTAResults.state[reverseCollection][valueKey]
    end

    
    local ix = #CTAResults.sv[collection] + 1

    CTAResults.sv[collection][ix] = value
    CTAResults.state[reverseCollection][valueKey] = ix

    return ix
end

function CTAResults.RebuildReverseCollection(collection, getValueKeyFunc)
    local reverseCollection = "_"..collection

    local collectionData = {}
    local collectionDataCandidate = CTAResults.sv[collection]
    if type(collectionDataCandidate) == "table" then
        collectionData = collectionDataCandidate
    end

    CTAResults.state[reverseCollection] = {}
    for ix, value in ipairs(collectionData) do
        local valueKey = getValueKeyFunc and getValueKeyFunc(value) or value
        CTAResults.state[reverseCollection][valueKey] = ix
    end
end

function CTAResults.Debug(text)
    if CTAResults.sv and CTAResults.sv.debug then
        d(string.format("[CTA] DEBUG: %s", tostring(text)))
    end
end

function CTAResults.GetOrderedByLabel()
    return CTAResults.OrderBy[CTAResults.sv.orderedBy] or ""
end

function CTAResults.NextOrderedBy()
    CTAResults.sv.orderedBy = CTAResults.sv.orderedBy % #CTAResults.OrderBy + 1
end

function CTAResults.GetSources()
    local sources = {}
    local sourcesCheck = {}

    for _, group in ipairs(CTAData.groups) do
        if not sourcesCheck[group.source] then
            sourcesCheck[group.source] = true
            sources[#sources + 1] = group.source
        end
    end

    sources[#sources + 1] = CTAData.specialSource
    sources[#sources + 1] = CTAData.fragmentsSource
    sources[#sources + 1] = CTAData.defaultSource

    return sources
end

function CTAResults.GetGroups()
    local groups = {}
    local groupsCheck = {}

    for _, group in ipairs(CTAData.groups) do
        if CTAResults.sv.selectedSource == "All" or CTAResults.sv.selectedSource == group.source then
            if not groupsCheck[group.name] then
                groupsCheck[group.name] = true
                groups[#groups + 1] = group.name
            end
        end
    end
    return groups
end

function CTAResults.GetCategoryNames(collectibleId)
    local cix, six, iix = GetCategoryInfoFromCollectibleId(collectibleId)
    local categoryName = ""
    local subcategoryName = ""
    if cix ~= nil then
        -- local ckey = tostring(cix)
        -- if CTAResults.cache.categoryNames[ckey] ~= nil then
        --     categoryName = CTAResults.cache.categoryNames[ckey]
        -- else
            categoryName = GetCollectibleCategoryInfo(cix)
        --     CTAResults.cache.categoryNames[ckey] = categoryName
        -- end

        if six ~= nil then
            -- local skey = tostring(cix) .. "_" .. tostring(six)
            -- if CTAResults.cache.categoryNames[skey] ~= nil then
            --     subcategoryName = CTAResults.cache.categoryNames[skey]
            --- else
                subcategoryName = GetCollectibleSubCategoryInfo(cix, six)
            --     CTAResults.cache.categoryNames[skey] = subcategoryName
            -- end
        end
    end

    return categoryName, subcategoryName
end

function CTAResults.ShouldIncludeRowInView(row)
    local isUncollected = row and row.iu or false
    if CTAResults.sv.showUncollectedItemsOnly and not isUncollected then
        return false
    end
    if CTAResults.sv.selectedCategory ~= "All" and row.cn ~= CTAResults.state._categories[CTAResults.sv.selectedCategory] then
        return false
    end
    if CTAResults.sv.selectedSubcategory ~= "All" and row.sn ~= CTAResults.state._subcategories[CTAResults.sv.selectedSubcategory] then
        return false
    end
    if CTAResults.sv.selectedSource ~= "All" and not SPFLibUtils.Contains(row.sns, CTAResults.state._sources[CTAResults.sv.selectedSource]) then
        return false
    end
    if CTAResults.sv.selectedGroup ~= "All" and not SPFLibUtils.Contains(row.gns, CTAResults.state._groups[CTAResults.sv.selectedGroup]) then
        return false
    end
    return true
end

function CTAResults.ShouldIncludeInResults(collectibleName, item, categoryType, collectibleId)
    if collectibleName == item.name then
        if item.id ~= nil then
            return item.id == collectibleId
        end
        return true
    end
    if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
        return CTAResults.ShouldArmorOrWeaponIncludeInResults(collectibleName, item)
    end
    return false
end

function CTAResults.ShouldArmorOrWeaponIncludeInResults(collectibleName, item)
    if not string.find(collectibleName, item.name, 1, true) then
        return false
    end
    if item.armorOnly then
        for _, armor in ipairs(CTAData.armors) do
            -- if string.find(collectibleName, item.name .. " " .. armor, 1, true) then
            if collectibleName == item.name .. " " .. armor then
                return true
            end
        end
        return false
    end
    if item.weaponOnly then
        for _, weapon in ipairs(CTAData.weapons) do
            -- if string.find(collectibleName, item.name .. " " .. weapon, 1, true) then
            if collectibleName == item.name .. " " .. weapon then
                return true
            end
        end
        return false
    end
    for _, armor in ipairs(CTAData.armors) do
        -- if string.find(collectibleName, item.name .. " " .. armor, 1, true) then
        if collectibleName == item.name .. " " .. armor then
            return true
        end
        for i = 1, 5 do
            if collectibleName == item.name .. " " .. armor .. " " .. i then
                return true
            end
        end
    end
    for _, weapon in ipairs(CTAData.weapons) do
        -- if string.find(collectibleName, item.name .. " " .. weapon, 1, true) then
        if collectibleName == item.name .. " " .. weapon then
            return true
        end
        for i = 1, 5 do
            if collectibleName == item.name .. " " .. weapon .. " " .. i then
                return true
            end
        end
    end
    return false
end

function CTAResults.GetItemKey(group, item)
    return string.format("%s - %s - %s", SPFLibUtils.SafeText(group.source), SPFLibUtils.SafeText(group.name), SPFLibUtils.SafeText(item.name))
end

function CTAResults.DisplayUnmatched(matching, itemName)
    if not CTAResults.sv or not CTAResults.sv.debug then
        return
    end

    local unmatchedItems = {}
    for key, isKnown in pairs(matching) do
        if not isKnown then
            unmatchedItems[#unmatchedItems + 1] = key
        end
    end
    if #unmatchedItems > 0 then
        d(string.format("[CTA]: %d %ss are not matched with existing collectibles", #unmatchedItems, itemName))
        local displayMax = 40
        local counter = 0
        for _, unmatchedItem in ipairs(unmatchedItems) do
            d(string.format("[CTA]: Unmatched %s: %s", itemName, unmatchedItem))
            counter = counter + 1
            if counter >= displayMax then
                return
            end
        end
    else
        d(string.format("[CTA]: All %ss are matched with existing collectibles", itemName))
    end
end

function CTAResults.BuildPrepare()
    CTAResults.ClearWholeState()

    local categoryTypes = {}
    for _, categoryType in pairs(CTAData.categoryTypes) do
        categoryTypes[#categoryTypes + 1] = {
            categoryType = categoryType,
            totalCount = GetTotalCollectiblesByCategoryType(categoryType),
        }
    end
    CTAResults.state._categoryTypes = categoryTypes

    local fragmentsMap = {}
    local itemsFromFragments = {}
    local matchingItems = {}
    local matchingFragments = {}

    for _, group in ipairs(CTAData.groups) do
        for itemCategoryType, items in pairs(group.collection) do
            for _, item in ipairs(items) do
                matchingItems[CTAResults.GetItemKey(group, item)] = false
                if item.fragments then
                    itemsFromFragments[item.name] = false
                    for _, fragmentName in ipairs(item.fragments) do
                        fragmentsMap[fragmentName] = { name = fragmentName, unlocked = false, item = item.name }
                        matchingFragments[fragmentName] = false
                    end
                end
            end
        end
    end
    CTAResults.state._itemsFromFragments = itemsFromFragments
    CTAResults.state._matchingItems = matchingItems

    local categoryType = COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT
    for i = 1, GetTotalCollectiblesByCategoryType(categoryType) do
        local collectibleId = GetCollectibleIdFromType(categoryType, i)
        -- local isUnlocked = IsCollectibleUnlocked(collectibleId)
        -- if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
        -- if id and IsCollectibleUnlocked(collectibleId) then table.insert(available, collectibleId) end
        local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)

        local isKnown = false

        for fragmentName, fragment in pairs(fragmentsMap) do
            if name == fragmentName then
                fragment.ix = i
                fragment.id = collectibleId
                fragment.unlocked = unlocked
                isKnown = true
                matchingFragments[fragmentName] = true
            end
        end

        if not isKnown then
            -- CTAResults.BuildResultItem(categoryType, i)
        end
    end

    CTAResults.state._fragmentsMap = fragmentsMap
    CTAResults.state._matchingFragments = matchingFragments
end

CTAResults.refreshRequested = false
function CTAResults.RequestRefresh()
    if not CTAResults.refreshRequested then
        CTAResults.refreshRequested = true
        zo_callLater(function()
            CTAResults.callbacks.RefreshFull()
            CTAResults.refreshRequested = false
        end, CTAResults.refreshDelay)
    end
end

function CTAResults.BuildResults()
    zo_callLater(function() CTAResults.BuildResultsChunk(1, 1) end, CTAResults.chunkDelay)
    CTAResults.RequestRefresh()
end

function CTAResults.BuildResultsChunk(categoryTypeIndex, from)
    if categoryTypeIndex > #CTAResults.state._categoryTypes then
        d(string.format("[CTA]: Found %d collectible items", CTAResults.sv.totalCount))
        CTAResults.sv.lastVersion = CTAResults.sv.nextVersion
        CTAResults.DisplayUnmatched(CTAResults.state._matchingItems, "item")
        CTAResults.DisplayUnmatched(CTAResults.state._matchingFragments, "fragment")
        return
    end

    local categoryTypeInfo = CTAResults.state._categoryTypes[categoryTypeIndex] or {}
    local categoryType = categoryTypeInfo.categoryType or 0
    local categoryTotalCount = categoryTypeInfo.totalCount or 0

    local counter = 0
    for i = from, categoryTotalCount do
        CTAResults.BuildResultItem(categoryType, i)

        counter = counter + 1
        if counter >= CTAResults.chunkSize and i < categoryTotalCount then
            zo_callLater(function() CTAResults.BuildResultsChunk(categoryTypeIndex, i + 1) end, CTAResults.chunkDelay)
            CTAResults.RequestRefresh()
            return
        end
    end

    zo_callLater(function() CTAResults.BuildResultsChunk(categoryTypeIndex + 1, 1) end, CTAResults.chunkDelay)
    CTAResults.RequestRefresh()
end

function CTAResults.GetFragments(item, unlocked)
    CTAResults.state._itemsFromFragments[item.name] = unlocked

    local fragments = nil
    if item.fragments then
        fragments = {}
        for _, fragmentName in ipairs(item.fragments) do
            local fragmentInfo = CTAResults.state._fragmentsMap[fragmentName] or {}
            if unlocked then
                fragmentInfo.unlocked = true -- override fragment unlocked when item is already unlocked
            end
            fragments[#fragments + 1] = fragmentInfo
        end
    end
    return fragments
end

function CTAResults.GetItemCollectionsInfo(name, unlocked, categoryType, collectibleId)
    local ici = {
        sourceNames = {},
        groupNames = {},
        fragments = nil,
        quality = nil,
        tradeBars = nil,
        no = nil,
        motif = nil,
        achievement = nil,
        info = nil,
        sortKey = nil,

        specificGroup = nil,
        specificQuality = nil,
        specificSortKey = nil,

        overridedUnlocked = nil,
    }

    local isUnobtainable = false

    local firstGroupIndex = 0
    local firstCategoryTypeIndex = 0
    local firstItemIndex = 0

    local specificGroupIndex = 0
    local specificCategoryTypeIndex = 0
    local specificItemIndex = 0
    local specificBasesort = nil

    for groupIndex, group in ipairs(CTAData.groups) do
        for itemCategoryType, items in pairs(group.collection) do
            if itemCategoryType == categoryType then
                for itemIndex, item in ipairs(items) do
                    if CTAResults.ShouldIncludeInResults(name, item, categoryType, collectibleId) then
                        CTAResults.state._matchingItems[CTAResults.GetItemKey(group, item)] = true
                        ici.sourceNames[#ici.sourceNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, group.source)
                        ici.groupNames[#ici.groupNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.GROUPS, group.name)

                        if group.source == CTAData.othersSource and group.name == CTAData.unobtainableGroup then
                            isUnobtainable = true
                            firstGroupIndex = groupIndex
                            firstCategoryTypeIndex = CTAData.categoryTypesMap[categoryType]
                            firstItemIndex = itemIndex
                        end

                        if firstGroupIndex == 0 then firstGroupIndex = groupIndex end
                        if firstCategoryTypeIndex == 0 then firstCategoryTypeIndex = CTAData.categoryTypesMap[categoryType] end
                        if firstItemIndex == 0 then firstItemIndex = itemIndex end

                        -- specific behavior
                        if group.specific then
                            if specificGroupIndex == 0 then specificGroupIndex = groupIndex end
                            if specificCategoryTypeIndex == 0 then specificCategoryTypeIndex = CTAData.categoryTypesMap[categoryType] end
                            if specificItemIndex == 0 then specificItemIndex = itemIndex end
                            if ici.specificGroup == nil then ici.specificGroup = CTAResults.AddToCollection(CTAResults.COLLECTION.GROUPS, group.name) end
                            if ici.specificQuality == nil then ici.specificQuality = item.q end
                            if specificBasesort == nil then specificBasesort = group.basesort end
                        end


                        if ici.fragments == nil then ici.fragments = CTAResults.GetFragments(item, unlocked) end
                        if ici.quality == nil then ici.quality = item.q end
                        if ici.tradeBars == nil then ici.tradeBars = item.bars end
                        if ici.no == nil then ici.no = item.no end
                        if ici.motif == nil then ici.motif = item.motif end
                        if ici.achievement == nil then ici.achievement = item.achievement end
                        if ici.info == nil then ici.info = item.info end
                    end
                end
            end
        end
    end

    local firstQuality = ici.quality or 9
    ici.sortKey = firstGroupIndex * 1e8 + firstQuality * 1e7 + firstCategoryTypeIndex * 1e5 + firstItemIndex

    if ici.specificGroup then
        local specificQuality = ici.specificQuality or 0
        if specificBasesort then specificQuality = 0 end
        ici.specificSortKey = specificGroupIndex * 1e8 + specificQuality * 1e7 + specificCategoryTypeIndex * 1e5 + specificItemIndex
    end

    if #ici.sourceNames == 0 then
        if
            categoryType == COLLECTIBLE_CATEGORY_TYPE_TRIBUTE_PATRON
            or categoryType == COLLECTIBLE_CATEGORY_TYPE_DLC
            or categoryType == COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_UPGRADE
            or categoryType == COLLECTIBLE_CATEGORY_TYPE_HOUSE_BANK
        then
            ici.sourceNames[#ici.sourceNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, CTAData.specialSource)
        elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT then
            if CTAResults.state._matchingFragments[name] then
                ici.sourceNames[#ici.sourceNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, CTAData.fragmentsSource)
                local fragmentInfo = CTAResults.state._fragmentsMap[name] or {}
                local itemName = fragmentInfo.item
                local itemUnlocked = CTAResults.state._itemsFromFragments[itemName] or false
                ici.overridedUnlocked = itemUnlocked
            else
                ici.sourceNames[#ici.sourceNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, CTAData.defaultSource)
            end
        else
            ici.sourceNames[#ici.sourceNames + 1] = CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, CTAData.defaultSource)
        end
        
        ici.sortKey = 1e11

        if ici.specificGroup then
            ici.specificSortKey = 1e11
        end
    end

    -- override categorization of the unobtainable item
    if isUnobtainable then
        ici.sourceNames = {
            CTAResults.AddToCollection(CTAResults.COLLECTION.SOURCES, CTAData.othersSource),
        }
        ici.groupNames = {
            CTAResults.AddToCollection(CTAResults.COLLECTION.GROUPS, CTAData.unobtainableGroup),
        }
    end

    return ici
end

function CTAResults.BuildResultItem(categoryType, index)
    local collectibleId = GetCollectibleIdFromType(categoryType, index)
    -- local isUnlocked = IsCollectibleUnlocked(collectibleId)
    -- if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
    -- if id and IsCollectibleUnlocked(collectibleId) then table.insert(available, collectibleId) end
    local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)

    name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)

    local categoryName, subcategoryName = CTAResults.GetCategoryNames(collectibleId)

    local ici = CTAResults.GetItemCollectionsInfo(name, unlocked, categoryType, collectibleId)

    local isUncollected = unlocked == false
    if ici.overridedUnlocked ~= nil then
        isUncollected = ici.overridedUnlocked == false
    end
    local result = {
        -- ix = index,
        im = name,
        id = collectibleId,
        iu = isUncollected,
        cn = CTAResults.AddToCollection(CTAResults.COLLECTION.CATEGORIES, categoryName),
        sn = CTAResults.AddToCollection(CTAResults.COLLECTION.SUBCATEGORIES, subcategoryName),
        tn = CTAResults.AddToCollection(CTAResults.COLLECTION.TYPES, GetString("SI_COLLECTIBLECATEGORYTYPE", categoryType)),
        sk = ici.sortKey,
        sns = ici.sourceNames,
        gns = ici.groupNames,
    }

    if ici.fragments ~= nil then result.fr = ici.fragments end
    if ici.quality ~= nil then result.q = ici.quality end
    if ici.tradeBars ~= nil then result.tb = ici.tradeBars end
    if ici.no ~= nil then result.no = ici.no end
    if ici.motif ~= nil then result.mo = ici.motif end
    if ici.achievement ~= nil then result.ach = ici.achievement end
    if ici.info ~= nil then result.info = ici.info end

    -- specific behavior
    if ici.specificSortKey ~= nil then result.ssk = ici.specificSortKey end
    if ici.specificGroup ~= nil then result.sg = ici.specificGroup end
    if ici.specificQuality ~= nil then result.sq = ici.specificQuality end

    if not isUncollected then
        CTAResults.sv.collectedCount = CTAResults.sv.collectedCount + 1
    end
    
    CTAResults.sv.totalCount = CTAResults.sv.totalCount + 1
    CTAResults.sv.results[CTAResults.sv.totalCount] = result
end

function CTAResults.Build(forced)
    if not CTAResults.sv.rebuildOnDemandOnly or forced == true then
        CTAResults.BuildPrepare()
        CTAResults.BuildResults()
    else
        CTAResults.RebuildState()
    end
end

function CTAResults.RebuildState()
    CTAResults.RebuildReverseCollection(CTAResults.COLLECTION.CATEGORIES)
    CTAResults.RebuildReverseCollection(CTAResults.COLLECTION.SUBCATEGORIES)
    CTAResults.RebuildReverseCollection(CTAResults.COLLECTION.SOURCES)
    CTAResults.RebuildReverseCollection(CTAResults.COLLECTION.GROUPS)
    CTAResults.RebuildReverseCollection(CTAResults.COLLECTION.TYPES)
end

function CTAResults.RecheckUncollectedItems()
    if not (CTAResults.sv and CTAResults.sv and type(CTAResults.sv.results) == "table") then
        return 0
    end

    local refreshed = 0
    for _, item in ipairs(CTAResults.sv.results) do
        if item and item.iu == true then
            local _, _, _, _, unlocked = GetCollectibleInfo(item.id)
            local isUncollected = unlocked == false

            item.iu = isUncollected

            refreshed = refreshed + 1
        end
    end

    if refreshed > 0 then
        CTAResults.callbacks.RefreshFull()
    end

    return refreshed
end

function CTAResults.RecheckUncollectedItem(collectibleId)
    if not (CTAResults.sv and CTAResults.sv and type(CTAResults.sv.results) == "table") then
        return 0
    end

    local refreshed = 0
    for _, item in ipairs(CTAResults.sv.results) do
        if item and item.id == collectibleId and item.iu == true then
            local _, _, _, _, unlocked = GetCollectibleInfo(item.id)
            local isUncollected = unlocked == false

            item.iu = isUncollected

            refreshed = refreshed + 1
        elseif item and item.fr then
            for _, fragment in ipairs(item.fr) do
                if fragment.id == collectibleId then
                    fragment.unlocked = true
                    refreshed = refreshed + 1
                end
            end
        end
    end

    if refreshed > 0 then
        CTAResults.callbacks.RefreshFull()
    end

    return refreshed
end

function CTAResults.RecreateResult(rx)
    if rx == nil then
        return nil
    end

    local result = CTAResults.sv.results[rx] or {}

    local fragmentsCount = 0
    local fragmentsUnlockedCount = 0
    if result.fr then
        fragmentsCount = #result.fr
        for _, fragment in ipairs(result.fr) do
            if fragment.unlocked then
                fragmentsUnlockedCount = fragmentsUnlockedCount + 1
            end
        end
    end
    local fragmentsOutput = ""
    if fragmentsCount > 0 then
        fragmentsOutput = string.format(" - (%d / %d)", fragmentsUnlockedCount, fragmentsCount)
    end

    local quality = result.q or 0
    if
        CTAResults.sv.selectedGroup ~= "All"
        and result ~= nil and SPFLibUtils.Contains(result.gns, CTAResults.state._groups[CTAResults.sv.selectedGroup]) -- this is not necessary probably already
        and result.sg == CTAResults.state._groups[CTAResults.sv.selectedGroup]
        and result.sq ~= nil
    then
        quality = result.sq
    end

    local sources = {}
    for i = 1, #result.sns do
        sources[#sources + 1] = CTAResults.sv.sources[result.sns[i]]
    end

    local groups = {}
    for i = 1, #result.gns do
        groups[#groups + 1] = CTAResults.sv.groups[result.gns[i]]
    end

    -- TODO: fallbacks will not be probably needed already, because reindexing should be fixed now
    local resultFull = {
        collectibleId = result.id,
        -- TODO: if the colorize will work, add some q to all the data
        collectibleName = SPFLibUtils.ColorizeByQuality(string.format("%s%s", result.im, fragmentsOutput), quality),
        categoryName = CTAResults.sv.categories[result.cn or 0] or "",
        subcategoryName = CTAResults.sv.subcategories[result.sn or 0] or "",
        typeName = CTAResults.sv.types[result.tn or 0] or "",

        isUncollected = result.iu,
        fragments = result.fr,

        quality = SPFLibUtils.ColorizeByQuality(CTAData.crownCrateQualities[quality] or nil, quality),
        
        tradeBars = CTAResults.GetItemTradeBars(result),
        motif = result.mo,
        no = result.no,
        achievement = result.ach,
        info = result.info,
        sources = table.concat(sources, ", "),
        groups = table.concat(groups, ", "),
    }
    return resultFull
end

function CTAResults.GetResultCompareValues(rx)
    local result = CTAResults.sv.results[rx]

    local im = ""
    local id = 0
    local sk = 0
    if result ~= nil then im = result.im end
    if result ~= nil then id = result.id end
    if result ~= nil then sk = result.sk end

    if
        CTAResults.sv.selectedGroup ~= "All"
        and result ~= nil and SPFLibUtils.Contains(result.gns, CTAResults.state._groups[CTAResults.sv.selectedGroup]) -- this is not necessary probably already
    then
        if result.sg ~= nil and result.sg == CTAResults.state._groups[CTAResults.sv.selectedGroup] and result.ssk ~= nil then
            sk = result.ssk
        end

        sk = sk % 1e8 -- ignore group part of the sortKey
    end

    return im, id, sk
end

function CTAResults.SortRows(rows)
    if CTAResults.OrderBy[CTAResults.sv.orderedBy] == CTAResults.OrderByName then
        table.sort(rows, function(a, b)
            local an, ad = CTAResults.GetResultCompareValues(a)
            local bn, bd = CTAResults.GetResultCompareValues(b)

            if an == bn then
                return ad < bd
            end
            return an < bn
        end)
    elseif CTAResults.OrderBy[CTAResults.sv.orderedBy] == CTAResults.OrderById then
        table.sort(rows, function(a, b)
            local an, ad = CTAResults.GetResultCompareValues(a)
            local bn, bd = CTAResults.GetResultCompareValues(b)

            if ad == bd then
                return an < bn
            end
            return ad < bd
        end)
    elseif CTAResults.OrderBy[CTAResults.sv.orderedBy] == CTAResults.OrderByCollection then
        table.sort(rows, function(a, b)
            local an, _, ask = CTAResults.GetResultCompareValues(a)
            local bn, _, bsk = CTAResults.GetResultCompareValues(b)

            if ask == bsk then
                return an < bn
            end
            return ask < bsk
        end)
    end
end

function CTAResults.BuildAllRows()
    local rows = {}
    local rowix = 0
    for rx, result in pairs(CTAResults.sv.results) do
        if result ~= nil and CTAResults.ShouldIncludeRowInView(result) then
            rowix = rowix + 1
            rows[rowix] = rx
        end
    end

    CTAResults.SortRows(rows)

    return rows
end

function CTAResults.GetAllVisibleRows()
    local rows = CTAResults.BuildAllRows()
    local filterText = CTAResults.state.searchFilter -- SPFLibUtils.Lower(CTAResults.state.searchFilter)
    if filterText == "" then
        return rows
    end

    local filtered = {}
    local fx = 0
    for _, row in ipairs(rows) do
        local result = CTAResults.sv.results[row]

        local haystack = result.im
            -- TODO: this has performance issue for thousands items
            -- SPFLibUtils.Lower(result.im) .. " " ..
            -- SPFLibUtils.Lower(CTAResults.sv.categories[result.cn])

        if string.find(haystack, filterText, 1, true) then
            fx = fx + 1
            filtered[fx] = row
        end
    end
    return filtered
end

function CTAResults.CalculateVisibleRows()
    local rows = CTAResults.GetAllVisibleRows()
    local pageSize = math.max(1, tonumber(CTAResults.state.matchingPageSize) or 50)
    local totalPages = math.max(1, math.ceil(#rows / pageSize))
    local page = tonumber(CTAResults.state.matchingPage) or 1
    if page < 1 then page = 1 end
    if page > totalPages then page = totalPages end

    local startIndex = ((page - 1) * pageSize) + 1
    local endIndex = math.min(#rows, startIndex + pageSize - 1)
    local pageRows = {}
    local pageRowsIndex = 0
    for i = startIndex, endIndex do
        pageRowsIndex = pageRowsIndex + 1
        pageRows[pageRowsIndex] = rows[i]
    end

    CTAResults.state.matchingRows = rows
    CTAResults.state.matchingPageRows = pageRows
    CTAResults.state.matchingPage = page
    CTAResults.state.matchingTotalPages = totalPages
end

function CTAResults.GetSelectedRow()
    local selectedRow = CTAResults.state.matchingSelectedRow
    if not selectedRow or not CTAResults.state.matchingPageRows then return nil end
    for _, row in ipairs(CTAResults.state.matchingPageRows) do
        if row == selectedRow then
            return row
        end
    end
    return nil
end

function CTAResults.DebugCounts()
    d("CTA Results: "..tostring(#CTAResults.sv.results))
    d("CTA Categories: "..tostring(#CTAResults.sv.categories))
    d("CTA SubCategories: "..tostring(#CTAResults.sv.subcategories))
    d("CTA Sources: "..tostring(#CTAResults.sv.sources))
    d("CTA Groups: "..tostring(#CTAResults.sv.groups))
    d("CTA Types: "..tostring(#CTAResults.sv.types))
end

function CTAResults.DebugResult(rx)
    local result = CTAResults.sv.results[rx]
    local message = {}
    table.insert(message, "rx: "..tostring(rx))
    for key, value in pairs(result or {}) do
        table.insert(message, key..": "..tostring(value))
    end
    d("CTA Result: "..table.concat(message, " ; "))
end

function CTAResults.GetItemTradeBars(result)
    if result and result.tb and result.iu == true then
        if result.fr then
            local lockedFragmentsCount = 0
            for _, fragment in ipairs(result.fr) do
                if not fragment.unlocked then
                    lockedFragmentsCount = lockedFragmentsCount + 1
                end
            end
            return result.tb * lockedFragmentsCount
        else
            return result.tb
        end
    end
    return 0
end

function CTAResults.GetStats()
    local allMatchingRows = CTAResults.state.matchingRows
    local matching = #allMatchingRows
    local collectedTotal = CTAResults.sv.collectedCount
    local total = CTAResults.sv.totalCount
    local page = CTAResults.state.matchingPage
    local totalPages = CTAResults.state.matchingTotalPages

    local collectedMatching = 0
    local neededTradeBars = 0

    for _, row in ipairs(allMatchingRows) do
        local result = CTAResults.sv.results[row]

        if result and result.iu == false then
            collectedMatching = collectedMatching + 1
        end

        neededTradeBars = neededTradeBars + CTAResults.GetItemTradeBars(result)
    end

    return matching, total, collectedMatching, collectedTotal, page, totalPages, neededTradeBars
end

local function GetNextDirtyUnlockStateCollectibleIdIter(_, lastCollectibleId)
    return GetNextDirtyUnlockStateCollectibleId(lastCollectibleId)
end

function CTAResults.OnCollectiblesUnlockStateChanged()
    for collectibleId in GetNextDirtyUnlockStateCollectibleIdIter do
        local refreshed = CTAResults.RecheckUncollectedItem(collectibleId)
        CTAResults.sv.collectedCount = CTAResults.sv.collectedCount + refreshed
        if refreshed > 0 then
            CTAResults.Debug("Item collected - " .. tostring(collectibleId))
        else
            CTAResults.Debug("EVENT_COLLECTIBLES_UPDATED had no effect - " .. tostring(collectibleId))
        end
    end
end
