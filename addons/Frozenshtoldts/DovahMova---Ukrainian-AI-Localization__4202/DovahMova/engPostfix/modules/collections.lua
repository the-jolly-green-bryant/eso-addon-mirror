-- Helper function to split long names into multiple lines
local function splitNameIntoLines(name, maxLineLength)
	if not name or string.len(name) <= maxLineLength then
		return name
	end

	local lines = {}
	local currentLine = ""

	-- For Ukrainian text, try to split at natural word boundaries
	-- First, try to split at spaces
	local words = {}
	for word in string.gmatch(name, "[^%s]+") do
		table.insert(words, word)
	end

	-- If we have words, use word-based splitting
	if #words > 0 then
		for i, word in ipairs(words) do
			local potentialLine = currentLine .. (currentLine ~= "" and " " or "") .. word

			-- If adding this word would exceed the line length, start a new line
			if string.len(potentialLine) > maxLineLength and currentLine ~= "" then
				table.insert(lines, currentLine)
				currentLine = word
			else
				currentLine = potentialLine
			end
		end
	else
		-- Fallback: character-based splitting for very long words
		local remaining = name
		while string.len(remaining) > maxLineLength do
			local line = string.sub(remaining, 1, maxLineLength)
			table.insert(lines, line)
			remaining = string.sub(remaining, maxLineLength + 1)
		end
		if remaining ~= "" then
			currentLine = remaining
		end
	end

	-- Add the last line
	if currentLine ~= "" then
		table.insert(lines, currentLine)
	end

	-- Join lines with newline characters
	return table.concat(lines, "\n")
end

function DovahMova_doubleNamesCollections(DovahMova)
	local localSets = DovahMova.Settings.Data.Sets

	-- Original set modification logic (restored)
	for index, value in pairs(ITEM_SET_COLLECTIONS_DATA_MANAGER.itemSetCollections) do
		local originalGetRawName = value.GetRawName
		value.GetRawName = function(...)
			local originalName = originalGetRawName(...)
			local translatedName = localSets[value.itemSetId] or DovahMova.Settings.Data.Locations[ZO_CachedStrFormat("<<z:1>>", originalName)]

			if DovahMova.Settings.ShowCollectionsSetsMenu == "ua" or not translatedName then
				return originalName
			elseif DovahMova.Settings.ShowCollectionsSetsMenu == "uaen" then
				return originalName .. " (" .. translatedName .. ")"
			end

			return translatedName
		end
	end

	-- Hook GetItemSetCollectionCategoryName for dungeon postfixes (SAFE - does not cause taint)
	local function HookItemSetCollectionCategoryName()
		local rsd = DovahMova.Settings.Data
		local locationsData = DovahMova_getLocations()  -- Use the complete locations data
		local hookedCount = 0

		if GetItemSetCollectionCategoryName then
			local originalGetItemSetCollectionCategoryName = GetItemSetCollectionCategoryName

			GetItemSetCollectionCategoryName = function(categoryId)
				local originalName = originalGetItemSetCollectionCategoryName(categoryId)

				if originalName then
					-- Check if this is a DUNGEON by looking it up in locations (dynamic approach)
					-- Since DovahMova_getLocations() returns lowercase Ukrainian names, we need to try lowercase first
					local translatedName = nil

					-- Try direct lookup with lowercase category name (Ukrainian names are lowercase in locationsData)
					local lowercaseName = string.lower(originalName)
					translatedName = locationsData[lowercaseName]

					-- If not found, try with ZO formatting (like dungeons.lua does)
					if not translatedName then
						translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", lowercaseName)]
					end

					-- If still not found, try original case
					if not translatedName then
						translatedName = locationsData[originalName]
					end

					-- Last resort: try with ZO formatting on original case
					if not translatedName then
						translatedName = locationsData[ZO_CachedStrFormat("<<z:1>>", originalName)]
					end

					-- ADDITIONAL CHECK: Only apply to dungeon names (ending with " i" or " ii")
					local isDungeon = false
					local dungeonPattern = nil

					if originalName then
						if string.match(originalName, " i$") then
							isDungeon = true
							dungeonPattern = " i"
						elseif string.match(originalName, " ii$") then
							isDungeon = true
							dungeonPattern = " ii"
						end
					end

					-- TEMPORARILY DISABLE DUNGEON-ONLY FILTERING FOR TESTING
					if translatedName then
						-- Apply postfix based on settings (same logic as dungeons.lua)
						local fullResult
						if DovahMova.Settings.ShowLocations == "ua" then
							fullResult = originalName
						elseif DovahMova.Settings.ShowLocations == "uaen" then
							fullResult = originalName .. " (" .. translatedName .. ")"
						else
							fullResult = translatedName
						end

						-- Special handling for problematic Cyrillic names containing "Р"
						local result = fullResult
						if string.find(fullResult, "Р") then
							-- For names containing "Р", ensure they're not corrupted by splitting
							if string.len(fullResult) <= 35 then
								-- If it fits in 35 chars, don't split to avoid corruption
								result = fullResult
							elseif string.len(fullResult) > 35 then
								-- Split carefully to avoid breaking the "Р" character
								local firstPart = string.sub(fullResult, 1, 35)
								local remaining = string.sub(fullResult, 36)

								-- Make sure we don't split in the middle of "Р" (which is 2 bytes)
								-- Check if the last character of firstPart is incomplete UTF-8
								local lastByte = string.byte(firstPart, -1)
								if lastByte and lastByte >= 192 then -- This might be start of multi-byte
									-- Truncate to previous character to be safe
									firstPart = string.sub(firstPart, 1, -2)
									remaining = string.sub(fullResult, string.len(firstPart) + 1)
								end

								if remaining ~= "" then
									result = firstPart .. "\n" .. remaining
								else
									result = firstPart
								end
							end
						else
							-- For other names, use normal splitting
							if string.len(fullResult) > 40 then
								result = splitNameIntoLines(fullResult, 40)
							end
						end

						return result
					end
				end

				return originalName
			end

			hookedCount = hookedCount + 1
		end
	end

	-- Hook the correct API function from ESO documentation
	HookItemSetCollectionCategoryName()

	-- Event handlers for collections updates (SAFE)
	-- Register for collections update events (from ESO documentation)
	local function RegisterCollectionsEvents()
		local function OnCollectionsUpdated()
			HookItemSetCollectionCategoryName() -- Now enabled since main function is uncommented
		end

		if EVENT_ITEM_SET_COLLECTIONS_UPDATED then
			EVENT_MANAGER:RegisterForEvent("DovahMovaCollections", EVENT_ITEM_SET_COLLECTIONS_UPDATED, OnCollectionsUpdated)
		end

		if EVENT_ITEM_SET_COLLECTIONS_SEARCH_RESULTS_READY then
			EVENT_MANAGER:RegisterForEvent("DovahMovaCollections", EVENT_ITEM_SET_COLLECTIONS_SEARCH_RESULTS_READY, function()
			end)
		end
	end

	-- Register for collections update events
	RegisterCollectionsEvents()

	-- REMOVED: UI manipulation code that caused taint issues
	-- The following code was removed as it caused "callstack became untrusted" errors:
	-- - COLLECTIONS_BOOK.OnDeferredInitialize override
	-- - Direct UI control manipulation 
	-- - Complex multiline setup code

	-- Refresh the collections data to apply changes
	if ITEM_SET_COLLECTIONS_DATA_MANAGER then
		ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
		ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
	end
		
	ZO_PreHook(TEXT_SEARCH_MANAGER, "OnBackgroundListFilterComplete", function(_, taskId)
		if DovahMova.Settings.EnglishSearch then
			local context, filterTarget = TEXT_SEARCH_MANAGER:GetInProgressTaskInfoById(taskId)
			
			if context == "itemSetTextSearch" and filterTarget == BACKGROUND_LIST_FILTER_TARGET_ITEM_SET_ID then
				local contextSearch = TEXT_SEARCH_MANAGER.contextSearches[context]
				local searchString = zo_strlower(contextSearch.searchText)
				
				if searchString ~= "" and searchString ~= nil and zo_strmatch(searchString, "[a-z]") ~= nil then
					if not contextSearch.searchResults[filterTarget] then
						contextSearch.searchResults[filterTarget] = {}
					end

					local localSets = DovahMova.Settings.Data.Sets
					
					for index,value in pairs(localSets) do
						if zo_strfind(zo_strlower(value), searchString, 1, true) ~= nil then
							contextSearch.searchResults[filterTarget][index] = true
						end
					end
				end
			end
		end
	end)
		
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

		
	local function itemTooltipHook(tooltipControl, method)
		local origMethod = tooltipControl[method]
		tooltipControl[method] = function(self, ...)
			
			local finalSet = localSets[...]
			local rusSet = GetItemSetName(...)
			
			if DovahMova.Settings.ShowItemsSetsTooltip ~= "ua" and finalSet then
				-- Check if the name already has a postfix to prevent duplication
				-- This happens when itemsDisplay.lua has already formatted the name
				if string.find(rusSet, " %(") and string.find(rusSet, "%)$") then
					-- Name already has postfix, don't add another one
					SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, rusSet), 10)
				else
					if DovahMova.Settings.ShowItemsSetsTooltip == "uaen" then
						finalSet = string.format("%s (%s)", rusSet, finalSet)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, finalSet), 10)
				end
			end
			
			origMethod(self, ...)
				
			SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"], 10)
		end
	end
	
	itemTooltipHook(ItemTooltip, "SetGenericItemSet")
end