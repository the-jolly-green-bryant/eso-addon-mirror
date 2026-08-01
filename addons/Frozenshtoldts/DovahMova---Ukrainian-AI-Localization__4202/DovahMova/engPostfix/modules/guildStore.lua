-- Guild Store functionality for DovahMova
-- Handles Guild Store item display and search functionality

function DovahMova_doubleNamesGuildStore(DovahMova)
	local rsd = DovahMova.Settings.Data
	
	-- AwesomeGuildStore compatibility - temporarily disable formatting during AGS processing
	local AGSProcessing = false
	
	if DovahMova:IsAddonRunning("AwesomeGuildStore") then
		if AwesomeGuildStore.class and AwesomeGuildStore.class.StoreLocationHelper then
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSProcessing = true
			end)
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSProcessing = true
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSProcessing = false
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSProcessing = false
			end)
		end
	end
	
	-- Helper function to format item names based on settings
	local function FormatItemName(originalName, englishName, setting)
		if not originalName or not englishName then
			return originalName
		end
		
		-- If setting is "ua", return original without postfix
		if setting == "ua" then
			return originalName
		end
		
		-- Clean the English name by removing any existing parenthetical content
		local cleanEnglishName = englishName
		local pos = string.find(englishName, " %(")
		if pos then
			cleanEnglishName = string.sub(englishName, 1, pos - 1)
		end
		
		-- Extract Ukrainian base name (remove any existing postfixes)
		local ukrainianBaseName = originalName
		local ukrainianPos = string.find(originalName, " %(")
		if ukrainianPos then
			ukrainianBaseName = string.sub(originalName, 1, ukrainianPos - 1)
		end
		
		-- Enhanced duplicate detection
		-- 1. Check if already has the exact postfix we want to add
		local targetPostfix = " (" .. cleanEnglishName .. ")"
		if string.find(originalName, string.gsub(targetPostfix, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1"), 1, true) then
			return originalName
		end
		
		-- 2. Check for any existing postfix pattern
		if string.match(originalName, " %(.*%)$") then
			-- Name already has a postfix - don't add another one
			return originalName
		end
		
		-- 3. Add postfix for uaen setting
		if setting == "uaen" then
			return ukrainianBaseName .. targetPostfix
		end
		
		return originalName
	end
	
	-- Helper function to handle crafted items (similar to HandleCraftedItem in itemsDisplay.lua)
	local function HandleCraftedItem(originalName, itemId, setting)
		if not originalName or not itemId or not setting then
			return originalName
		end
		
		-- Add safety check for rsd
		if not rsd or not rsd.Parts or not rsd.Prefixes or not rsd.Affixes then
			return originalName
		end
		
		-- Get the Ukrainian name without the English translation and quality markers
		local ukrainianName = originalName
		
		-- Remove quality markers (^n, ^E, ^L) and gender markers (^F, ^M) first
		ukrainianName = string.gsub(ukrainianName, "%^[nELFM]", "")
		
		-- Then remove English translation in parentheses
		local pos = string.find(ukrainianName, " %(")
		if pos then
			ukrainianName = string.sub(ukrainianName, 1, pos - 1)
		end
		
		-- Check if this is a crafted item by looking for the base component in rsd.Parts
		-- For "Платиновий Перстень", we need to find "перстень" in rsd.Parts
		local ukrainianBaseName = nil
		
		-- Try to find the base component by looking for the last word in the Ukrainian name
		-- This handles cases like "платиновий перстень" -> "перстень"
		local words = {}
		for word in string.gmatch(ukrainianName, "%S+") do
			table.insert(words, word)
		end
		
		-- Check each word from the end to find a base component
		for i = #words, 1, -1 do
			-- First try exact match
			if rsd.Parts[words[i]] then
				ukrainianBaseName = words[i]
				break
			end
			-- Then try looking for keys that start with this word followed by space and parentheses
			for key, value in pairs(rsd.Parts) do
				-- Escape special regex characters in the word
				local escapedWord = string.gsub(words[i], "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
				if string.match(key, "^" .. escapedWord .. " %(") then
					ukrainianBaseName = words[i]
					break
				end
			end
			if ukrainianBaseName then
				break
			end
		end
		
		-- CRITICAL FIX: Handle compound weapon names by checking all Parts entries
		if not ukrainianBaseName then
			-- Try to find compound matches in the Parts table
			local bestMatch = nil
			local bestMatchLength = 0
			
			-- Look through all Parts entries to find the longest matching substring
			for partKey, partValue in pairs(rsd.Parts) do
				-- Check if this part key is contained in the Ukrainian name
				if string.find(ukrainianName, partKey) then
					local keyLength = string.len(partKey)
					-- Keep track of the longest match (most specific)
					if keyLength > bestMatchLength then
						bestMatch = partKey
						bestMatchLength = keyLength
					end
				end
			end
			
			if bestMatch then
				ukrainianBaseName = bestMatch
			end
		end
		
		if ukrainianBaseName then
			-- This is a crafted item, use the same logic as splitItemName
			local finalName = ""
			
			-- Helper function to get the English name from Parts table
			local function getEnglishBaseName(baseName)
				local englishName = nil
				-- First try direct lookup
				if rsd.Parts[baseName] then
					englishName = rsd.Parts[baseName]
				else
					-- Look for keys that start with baseName followed by space and parentheses
					for key, value in pairs(rsd.Parts) do
						-- Escape special regex characters in baseName
						local escapedBaseName = string.gsub(baseName, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
						if string.match(key, "^" .. escapedBaseName .. " %(") then
							englishName = value
							break
						end
					end
				end
				
				-- Extract just the English name, removing any ID in parentheses
				if englishName and string.find(englishName, " %(") then
					local cleanName = string.match(englishName, "^(.*?) %(")
					if cleanName then
						return cleanName
					else
						local pos = string.find(englishName, " %(")
						if pos then
							return string.sub(englishName, 1, pos - 1)
						end
					end
				end
				return englishName
			end
			
					-- Check for prefix + base pattern (e.g., "платиновий перстень")
		if string.match(ukrainianName, " " .. ukrainianBaseName .. "$") then
			local prefix = string.match(ukrainianName, "^(.*) " .. ukrainianBaseName .. "$")
			
			-- Try different prefix forms to handle Ukrainian declensions
			local englishPrefix = nil
			if prefix then
				-- Try the full prefix first
				if rsd.Prefixes[prefix] then
					englishPrefix = rsd.Prefixes[prefix]
				-- Try removing common Ukrainian adjective endings
				elseif rsd.Prefixes[prefix:sub(1, #prefix - 2)] then -- Remove -ий, -ій, -ій endings
					englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 2)]
				elseif rsd.Prefixes[prefix:sub(1, #prefix - 3)] then -- Remove -ова, -ові endings
					englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 3)]
				elseif rsd.Prefixes[prefix:sub(1, #prefix - 4)] then -- Remove longer endings
					englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 4)]
				end
			end
			
			if englishPrefix then
				finalName = englishPrefix .. " "
			end
				
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(ukrainianBaseName)
				finalName = finalName .. (englishBaseName or ukrainianBaseName)
			elseif string.match(ukrainianName, "^" .. ukrainianBaseName .. " ") then
				-- Check for base + affix pattern
				local affix = string.match(ukrainianName, "^" .. ukrainianBaseName .. " (.*)$")
				
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(ukrainianBaseName)
				finalName = englishBaseName or ukrainianBaseName
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				end
			elseif string.match(ukrainianName, " " .. ukrainianBaseName .. " ") then
				-- Check for prefix + base + affix pattern
				local prefix, affix = string.match(ukrainianName, "^(.*) " .. ukrainianBaseName .. " (.*)$")
				
				-- Try different prefix forms to handle Ukrainian declensions
				local englishPrefix = nil
				if prefix then
					-- Try the full prefix first
					if rsd.Prefixes[prefix] then
						englishPrefix = rsd.Prefixes[prefix]
					-- Try removing common Ukrainian adjective endings
					elseif rsd.Prefixes[prefix:sub(1, #prefix - 2)] then -- Remove -ий, -ій, -ій endings
						englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 2)]
					elseif rsd.Prefixes[prefix:sub(1, #prefix - 3)] then -- Remove -ова, -ові endings
						englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 3)]
					elseif rsd.Prefixes[prefix:sub(1, #prefix - 4)] then -- Remove longer endings
						englishPrefix = rsd.Prefixes[prefix:sub(1, #prefix - 4)]
					end
				end
				
				if englishPrefix then
					finalName = englishPrefix .. " "
				end
				
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(ukrainianBaseName)
				finalName = finalName .. (englishBaseName or ukrainianBaseName)
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				end
			else
				-- Fallback to just the base component
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(ukrainianBaseName)
				finalName = englishBaseName or ukrainianBaseName
			end
			
			return FormatItemName(ukrainianName, finalName, setting)
		end
		
		return originalName
	end
	
	-- Hook GetTradingHouseListingItemInfo for guild store listings (with AGS compatibility)
	if GetTradingHouseListingItemInfo then
		local GetTradingHouseListingItemInfoOld = GetTradingHouseListingItemInfo
		GetTradingHouseListingItemInfo = function(listingIndex)
			-- Skip processing if AwesomeGuildStore is currently processing
			if AGSProcessing then
				return GetTradingHouseListingItemInfoOld(listingIndex)
			end
			
			-- Ensure listingIndex is valid
			if not listingIndex or listingIndex < 0 then
				return GetTradingHouseListingItemInfoOld(listingIndex)
			end
			
			-- Get the original info with correct return values based on API documentation
			local icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit = GetTradingHouseListingItemInfoOld(listingIndex)
			
			-- If any return value is nil, return the original values without modification
			if not itemName then
				return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
			end
			
			-- Only modify if we're not in Ukrainian-only mode
			if (DovahMova.Settings.ShowGuildStoreDisplay == "ua") then
				return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
			end
			
		-- Get the item link to extract item ID
		local itemLink = GetTradingHouseListingItemLink(listingIndex)
		if itemLink and GetItemLinkItemId then
			local itemId = GetItemLinkItemId(itemLink)
			if itemId and itemId > 0 then
				-- FIRST: Process adjectives before material expansion (same as itemsDisplay.lua)
				if DovahMova_Adjectives then
					if string.find(itemName, "%^[aа]") or string.find(itemName, "ий%s+%S+%^[fmnp]") or string.find(itemName, "ій%s+%S+%^[fmnp]") then
						itemName = DovahMova_Adjectives.ProcessTaggedString(itemName)
					end
				end
				
				-- CRITICAL FIX: Smart priority with material expansion (same as itemsDisplay.lua)
				local englishName = rsd.Items[itemId]
				if englishName and englishName ~= "" then
					-- Check if this needs material prefix expansion
					local wordCount = 0
					for word in string.gmatch(englishName, "%S+") do
						wordCount = wordCount + 1
					end
					
					-- Simulate final formatted name (like tooltip) to count words consistently
					local simulatedFinalName = itemName .. " (" .. englishName .. ")"
					local ukrainianWordCount = 0
					for word in string.gmatch(simulatedFinalName, "%S+") do
						ukrainianWordCount = ukrainianWordCount + 1
					end
					
					if ukrainianWordCount > wordCount then
						-- This needs material expansion, try to build full English name
						local materialFound = false
						local ukrainianPart = string.match(itemName, "^(.*?) %(") or itemName
						local firstWord = string.match(ukrainianPart, "^(%S+)")
						if firstWord then
							-- Remove gender tags if present
							firstWord = string.gsub(firstWord, "%^[fmnp]", "")
							
							-- Look for material translation in existing rsd.Prefixes table  
							if rsd and rsd.Prefixes then
								-- Handle Ukrainian adjective declensions
								local materialVariants = {}
								table.insert(materialVariants, firstWord)
								
								-- Add root forms by removing common Ukrainian adjective endings
								if string.match(firstWord, "ий$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ий$", "")))
								elseif string.match(firstWord, "ова$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "")))
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "о")))
								elseif string.match(firstWord, "ове$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ове$", "")))
								elseif string.match(firstWord, "ові$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ові$", "")))
								elseif string.match(firstWord, "ній$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ній$", "")))
								elseif string.match(firstWord, "а$") then
									-- Remove -а ending (feminine): залізоткана → залізоткан
									table.insert(materialVariants, (string.gsub(firstWord, "а$", "")))
								elseif string.match(firstWord, "і$") then
									-- Remove -і ending (plural): залізошкірні → залізошкірн
									table.insert(materialVariants, (string.gsub(firstWord, "і$", "")))
								elseif string.match(firstWord, "ні$") then
									-- Remove -ні ending (plural): тінешкірні → тінешкір
									table.insert(materialVariants, (string.gsub(firstWord, "ні$", "")))
								end
								
								-- Try to match any variant against prefixes (prioritize longer matches)
								for _, variant in ipairs(materialVariants) do
									if materialFound then break end
									-- Sort prefixes by key length (longest first) to prioritize longer matches
									local sortedPrefixes = {}
									for prefixKey, prefixValue in pairs(rsd.Prefixes) do
										table.insert(sortedPrefixes, {key = prefixKey, value = prefixValue})
									end
									table.sort(sortedPrefixes, function(a, b) return #a.key > #b.key end)
									
									for _, prefix in ipairs(sortedPrefixes) do
										-- Try exact match first
										if variant:lower() == prefix.key:lower() then
											local fullEnglishName = prefix.value .. " " .. englishName
											itemName = FormatItemName(itemName, fullEnglishName, DovahMova.Settings.ShowGuildStoreDisplay)
											materialFound = true
											break
										end
										-- Then try substring matching (both ways)
										if string.find(variant:lower(), prefix.key:lower()) or string.find(prefix.key:lower(), variant:lower()) then
											local fullEnglishName = prefix.value .. " " .. englishName
											itemName = FormatItemName(itemName, fullEnglishName, DovahMova.Settings.ShowGuildStoreDisplay)
											materialFound = true
											break
										end
									end
								end
							end
						end
						
						-- Fallback to crafted item parsing or direct translation if material not found
						if not materialFound then
							local result = HandleCraftedItem(itemName, itemId, DovahMova.Settings.ShowGuildStoreDisplay)
							if result ~= itemName then
								itemName = result
							else
								itemName = FormatItemName(itemName, englishName, DovahMova.Settings.ShowGuildStoreDisplay)
							end
						end
					else
						-- This is likely a complete item name, use direct translation
						itemName = FormatItemName(itemName, englishName, DovahMova.Settings.ShowGuildStoreDisplay)
					end
				else
					-- Only if no direct translation exists, try to handle as crafted item
					local result = HandleCraftedItem(itemName, itemId, DovahMova.Settings.ShowGuildStoreDisplay)
					if result ~= itemName then
						itemName = result
					end
				end
			end
		end
			
			return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, salePrice, currencyType, itemUniqueId, salePricePerUnit
		end
	end
	
	-- Hook GetTradingHouseSearchResultItemInfo for guild store search results (with AGS compatibility)
	if GetTradingHouseSearchResultItemInfo then
		local GetTradingHouseSearchResultItemInfoOld = GetTradingHouseSearchResultItemInfo
		GetTradingHouseSearchResultItemInfo = function(searchResultIndex)
			-- Skip processing if AwesomeGuildStore is currently processing
			if AGSProcessing then
				return GetTradingHouseSearchResultItemInfoOld(searchResultIndex)
			end
			
			-- Ensure searchResultIndex is valid
			if not searchResultIndex or searchResultIndex < 0 then
				return GetTradingHouseSearchResultItemInfoOld(searchResultIndex)
			end
			
			-- Get the original info with correct return values based on API documentation
			local icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit = GetTradingHouseSearchResultItemInfoOld(searchResultIndex)
			
			-- If any return value is nil, return the original values without modification
			if not itemName then
				return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
			end
			
			-- Only modify if we're not in Ukrainian-only mode
			if (DovahMova.Settings.ShowGuildStoreDisplay == "ua") then
				return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
			end
			
		-- Get the item link to extract item ID
		local itemLink = GetTradingHouseSearchResultItemLink(searchResultIndex)
		if itemLink and GetItemLinkItemId then
			local itemId = GetItemLinkItemId(itemLink)
			if itemId and itemId > 0 then
				-- FIRST: Process adjectives before material expansion (same as itemsDisplay.lua)
				if DovahMova_Adjectives then
					if string.find(itemName, "%^[aа]") or string.find(itemName, "ий%s+%S+%^[fmnp]") or string.find(itemName, "ій%s+%S+%^[fmnp]") then
						itemName = DovahMova_Adjectives.ProcessTaggedString(itemName)
					end
				end
				
				-- CRITICAL FIX: Smart priority with material expansion (same as itemsDisplay.lua)
				local englishName = rsd.Items[itemId]
				if englishName and englishName ~= "" then
					-- Check if this needs material prefix expansion
					local wordCount = 0
					for word in string.gmatch(englishName, "%S+") do
						wordCount = wordCount + 1
					end
					
					-- Simulate final formatted name (like tooltip) to count words consistently
					local simulatedFinalName = itemName .. " (" .. englishName .. ")"
					local ukrainianWordCount = 0
					for word in string.gmatch(simulatedFinalName, "%S+") do
						ukrainianWordCount = ukrainianWordCount + 1
					end
					
					if ukrainianWordCount > wordCount then
						-- This needs material expansion, try to build full English name
						local materialFound = false
						local ukrainianPart = string.match(itemName, "^(.*?) %(") or itemName
						local firstWord = string.match(ukrainianPart, "^(%S+)")
						if firstWord then
							-- Remove gender tags if present
							firstWord = string.gsub(firstWord, "%^[fmnp]", "")
							
							-- Look for material translation in existing rsd.Prefixes table  
							if rsd and rsd.Prefixes then
								-- Handle Ukrainian adjective declensions
								local materialVariants = {}
								table.insert(materialVariants, firstWord)
								
								-- Add root forms by removing common Ukrainian adjective endings
								if string.match(firstWord, "ий$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ий$", "")))
								elseif string.match(firstWord, "ова$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "")))
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "о")))
								elseif string.match(firstWord, "ове$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ове$", "")))
								elseif string.match(firstWord, "ові$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ові$", "")))
								elseif string.match(firstWord, "ній$") then
									table.insert(materialVariants, (string.gsub(firstWord, "ній$", "")))
								elseif string.match(firstWord, "а$") then
									-- Remove -а ending (feminine): залізоткана → залізоткан
									table.insert(materialVariants, (string.gsub(firstWord, "а$", "")))
								elseif string.match(firstWord, "і$") then
									-- Remove -і ending (plural): залізошкірні → залізошкірн
									table.insert(materialVariants, (string.gsub(firstWord, "і$", "")))
								elseif string.match(firstWord, "ні$") then
									-- Remove -ні ending (plural): тінешкірні → тінешкір
									table.insert(materialVariants, (string.gsub(firstWord, "ні$", "")))
								end
								
								-- Try to match any variant against prefixes (prioritize longer matches)
								for _, variant in ipairs(materialVariants) do
									if materialFound then break end
									-- Sort prefixes by key length (longest first) to prioritize longer matches
									local sortedPrefixes = {}
									for prefixKey, prefixValue in pairs(rsd.Prefixes) do
										table.insert(sortedPrefixes, {key = prefixKey, value = prefixValue})
									end
									table.sort(sortedPrefixes, function(a, b) return #a.key > #b.key end)
									
									for _, prefix in ipairs(sortedPrefixes) do
										-- Try exact match first
										if variant:lower() == prefix.key:lower() then
											local fullEnglishName = prefix.value .. " " .. englishName
											itemName = FormatItemName(itemName, fullEnglishName, DovahMova.Settings.ShowGuildStoreDisplay)
											materialFound = true
											break
										end
										-- Then try substring matching (both ways)
										if string.find(variant:lower(), prefix.key:lower()) or string.find(prefix.key:lower(), variant:lower()) then
											local fullEnglishName = prefix.value .. " " .. englishName
											itemName = FormatItemName(itemName, fullEnglishName, DovahMova.Settings.ShowGuildStoreDisplay)
											materialFound = true
											break
										end
									end
								end
							end
						end
						
						-- Fallback to crafted item parsing or direct translation if material not found
						if not materialFound then
							local result = HandleCraftedItem(itemName, itemId, DovahMova.Settings.ShowGuildStoreDisplay)
							if result ~= itemName then
								itemName = result
							else
								itemName = FormatItemName(itemName, englishName, DovahMova.Settings.ShowGuildStoreDisplay)
							end
						end
					else
						-- This is likely a complete item name, use direct translation
						itemName = FormatItemName(itemName, englishName, DovahMova.Settings.ShowGuildStoreDisplay)
					end
				else
					-- Only if no direct translation exists, try to handle as crafted item
					local result = HandleCraftedItem(itemName, itemId, DovahMova.Settings.ShowGuildStoreDisplay)
					if result ~= itemName then
						itemName = result
					end
				end
			end
		end
			
			return icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
		end
	end
	
	-- Enhanced Guild Store search functionality for bilingual search
	-- Hook into the trading house item name matching system for autocomplete
	if MatchTradingHouseItemNames then
		-- Store original function
		local originalMatchTradingHouseItemNames = MatchTradingHouseItemNames
		
		-- Override the function to handle bilingual search
		MatchTradingHouseItemNames = function(searchText)
			-- Skip processing if we're in Ukrainian-only mode
			if DovahMova.Settings.ShowGuildStoreDisplay == "ua" then
				return originalMatchTradingHouseItemNames(searchText)
			end
			
			-- Skip processing if AwesomeGuildStore is currently processing
			if AGSProcessing then
				return originalMatchTradingHouseItemNames(searchText)
			end
			
			-- If search text is empty, just perform normal search
			if not searchText or searchText == "" then
				return originalMatchTradingHouseItemNames(searchText)
			end
			
			-- Check if the search text contains Ukrainian characters
			local hasUkrainianChars = false
			for i = 1, #searchText do
				local char = searchText:sub(i, i)
				if char:match("[а-яА-ЯіїєІЇЄ]") then
					hasUkrainianChars = true
					break
				end
			end
			
			-- If no Ukrainian characters, just do normal search
			if not hasUkrainianChars then
				return originalMatchTradingHouseItemNames(searchText)
			end
			
			-- For Ukrainian search, try to find matching English names
			local lowerSearchText = searchText:lower()
			local foundEnglishMatches = {}
			
			-- Look for items that have Ukrainian names matching the search
			for itemId, englishName in pairs(rsd.Items) do
				if englishName and englishName ~= "" then
					-- Get the Ukrainian name for this item
					local ukrainianName = GetItemName(itemId)
					if ukrainianName and ukrainianName ~= "" then
						local lowerUkrainianName = ukrainianName:lower()
						
						-- If the search text matches the Ukrainian name, add the English name to the search
						if lowerUkrainianName:find(lowerSearchText, 1, true) then
							-- Add English name to search if it's not already included
							if not lowerSearchText:find(englishName:lower(), 1, true) then
								table.insert(foundEnglishMatches, englishName)
								-- Limit to first few matches to avoid overly long search strings
								if #foundEnglishMatches >= 3 then
									break
								end
							end
						end
					end
				end
			end
			
			-- If we found English matches, add them to the search
			if #foundEnglishMatches > 0 then
				local enhancedSearchText = searchText
				for i = 1, #foundEnglishMatches do
					enhancedSearchText = enhancedSearchText .. " " .. foundEnglishMatches[i]
				end
				return originalMatchTradingHouseItemNames(enhancedSearchText)
			end
			
			-- If no matches found, just do the original search
			return originalMatchTradingHouseItemNames(searchText)
		end
	end
	
	-- Don't set the function to nil - it needs to be callable from settings
end
