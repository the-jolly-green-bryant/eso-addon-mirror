Reforged.Modules.register({
    id      = "collections",
    enabled = function()
        return GetCVar("language.2") == "br"
            and (Reforged.Settings.EnglishSearch or Reforged.Settings.ShowCollectionsSetsMenu ~= "br")
    end,
    activate = function()
        local sets = Reforged.Settings.Data.Sets
        local backup = Reforged.StringsBackup

        -- English keyword search in item set collections and inventory
        Reforged.Hooks.pre(TEXT_SEARCH_MANAGER, "OnBackgroundListFilterComplete", function(_, taskId)
            if not Reforged.Settings.EnglishSearch then return end
            local context, filterTarget = TEXT_SEARCH_MANAGER:GetInProgressTaskInfoById(taskId)
            if context ~= "itemSetTextSearch"
            and not (context == "playerInventoryTextSearch"
                     and (filterTarget == BACKGROUND_LIST_FILTER_TARGET_ITEM_SET_ID
                          or filterTarget == BACKGROUND_LIST_FILTER_TARGET_BAG_SLOT)) then
                return
            end
            local contextSearch = TEXT_SEARCH_MANAGER.contextSearches[context]
            local searchString  = zo_strlower(contextSearch.searchText)
            if searchString == "" or searchString == nil or zo_strmatch(searchString, "[a-z]") == nil then
                return
            end
            if not contextSearch.searchResults[filterTarget] then
                contextSearch.searchResults[filterTarget] = {}
            end
            for index, value in pairs(sets) do
                if zo_strfind(zo_strlower(value), searchString, 1, true) ~= nil then
                    contextSearch.searchResults[filterTarget][index] = true
                end
            end
        end)

        -- Third-party: Item Set Browser
        if ItemBrowserList then
            local origProcess = ItemBrowserList.ProcessItemEntry
            function ItemBrowserList:ProcessItemEntry(stringSearch, data, searchTerm)
                if sets[data.setId] and zo_plainstrfind(sets[data.setId]:lower(), searchTerm) then
                    return true
                end
                return origProcess(self, stringSearch, data, searchTerm)
            end
        end

        -- Override GetRawName on each collection entry to show bilingual set names
        for _, entry in pairs(ITEM_SET_COLLECTIONS_DATA_MANAGER.itemSetCollections) do
            local setId = entry.itemSetId
            entry.GetRawName = function()
                local brName = GetItemSetName(setId)
                local enName = sets[setId]
                local mode   = Reforged.Settings.ShowCollectionsSetsMenu
                if mode == "br" or not enName then return brName end
                if mode == "bren" then return brName .. " |cffffff(" .. enName .. ")" end
                if mode == "enbr" then return enName .. " |cffffff(" .. brName .. ")" end
                return enName
            end
        end

        -- Item set tooltip hook
        local function itemSetTooltipHook(tooltipCtrl, method)
            local origMethod = tooltipCtrl[method]
            tooltipCtrl[method] = function(self, ...)
                local setId    = ...
                local enName   = sets[setId]
                local brName   = GetItemSetName(setId)
                local mode     = Reforged.Settings.ShowItemsSetsTooltip
                if mode ~= "br" and enName then
                    local finalSet
                    if mode == "bren" then
                        finalSet = string.format("|ca99e83%s \n|cffffff(%s)", brName, enName)
                    elseif mode == "enbr" then
                        finalSet = string.format("|ca99e83%s \n|cffffff(%s)", enName, brName)
                    else
                        finalSet = enName
                    end
                    SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT,
                        ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, finalSet), 10)
                end
                origMethod(self, ...)
                SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT,
                    backup["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"], 10)
            end
        end

        itemSetTooltipHook(ItemTooltip, "SetGenericItemSet")

        -- Fire collection update so the new names are applied immediately
        ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
        ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
    end,
})
