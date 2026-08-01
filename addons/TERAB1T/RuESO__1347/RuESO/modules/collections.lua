function RuESO_doubleNamesCollections(RuESO)
	if RuESO:GetLanguage() == "ru" then
		
		local localSets = RuESO.Settings.Data.Sets
		
		ZO_PreHook(TEXT_SEARCH_MANAGER, "OnBackgroundListFilterComplete", function(_, taskId)
			if RuESO.Settings.EnglishSearch then
				local context, filterTarget = TEXT_SEARCH_MANAGER:GetInProgressTaskInfoById(taskId)
				
				if context == "itemSetTextSearch" and filterTarget == BACKGROUND_LIST_FILTER_TARGET_ITEM_SET_ID then
					local contextSearch = TEXT_SEARCH_MANAGER.contextSearches[context]
					local searchString = zo_strlower(contextSearch.searchText)
					
					if searchString ~= "" and searchString ~= nil and zo_strmatch(searchString, "[a-z]") ~= nil then
						if not contextSearch.searchResults[filterTarget] then
							contextSearch.searchResults[filterTarget] = {}
						end

						local localSets = RuESO.Settings.Data.Sets
						
						for index,value in pairs(localSets) do
							if zo_strfind(zo_strlower(value), searchString, 1, true) ~= nil then
								contextSearch.searchResults[filterTarget][index] = true
							end
						end
					end
				end
			end
		end)
		
		-- Third-party Compatibility
		-- Item Set Browser
		if ItemBrowserList then
			local ItemBrowserListProcessItemEntryOld = ItemBrowserList.ProcessItemEntry
			
			function ItemBrowserList:ProcessItemEntry(...)
				local stringSearch, data, searchTerm = ...
				if (localSets[data.setId] and zo_plainstrfind(localSets[data.setId]:lower(), searchTerm)) then
					return true
				end
				
				return ItemBrowserListProcessItemEntryOld(self, ...)
			end
		end
		-- Third-party Compatibility
		
		for index, value in pairs(ITEM_SET_COLLECTIONS_DATA_MANAGER.itemSetCollections) do
			value.GetRawName = function()				
				if (RuESO.Settings.ShowCollectionsSetsMenu == "ru" or not localSets[value.itemSetId]) then
					return GetItemSetName(value.itemSetId)
				elseif (RuESO.Settings.ShowCollectionsSetsMenu == "ruen") then
					return GetItemSetName(value.itemSetId) .. " (" .. localSets[value.itemSetId] .. ")"
				elseif (RuESO.Settings.ShowCollectionsSetsMenu == "enru") then
					return localSets[value.itemSetId] .. " (" .. GetItemSetName(value.itemSetId) .. ")"
				end
				
				return localSets[value.itemSetId]
			end
		end
		
		local function itemTooltipHook(tooltipControl, method)
			local origMethod = tooltipControl[method]
			tooltipControl[method] = function(self, ...)
				
				local finalSet = localSets[...]
				local rusSet = GetItemSetName(...)
				
				if RuESO.Settings.ShowItemsSetsTooltip ~= "ru" and finalSet then
					
					if RuESO.Settings.ShowItemsSetsTooltip == "ruen" then
						finalSet = string.format("%s (%s)", rusSet, finalSet)
					elseif RuESO.Settings.ShowItemsSetsTooltip == "enru" then
						finalSet = string.format("%s (%s)", finalSet, rusSet)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, finalSet), 10)
				end
				
				origMethod(self, ...)
					
				SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"], 10)
			end
		end
		
		itemTooltipHook(ItemTooltip, "SetGenericItemSet")
	end
	
	RuESO_doubleNamesCollections = nil
end