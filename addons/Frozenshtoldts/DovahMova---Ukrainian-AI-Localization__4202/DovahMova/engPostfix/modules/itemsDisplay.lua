-- Make the function globally available
DovahMova_doubleNamesItemsDisplay = function(DovahMova)
	-- Add safety check
	if not DovahMova or not DovahMova.Settings or not DovahMova.Settings.Data then
		return
	end
	
	local rsd = DovahMova.Settings.Data
	

	
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
	
	-- Helper function to handle crafted items (similar to splitItemName in items.lua)
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
		
		-- CRITICAL FIX: Check for compound base parts by trying progressively longer combinations from the end
		-- This handles compound items like "вогняний посох" (inferno staff) as single base parts
		for startIdx = 2, #words do  -- Start from second word to leave room for material prefix
			local basePart = ""
			for endIdx = startIdx, #words do
				if basePart == "" then
					basePart = words[endIdx]
				else
					basePart = basePart .. " " .. words[endIdx]
				end
				
				-- Try exact match for compound base part
				if rsd.Parts[basePart] then
					ukrainianBaseName = basePart
					break
				end
				
				-- Try looking for keys that start with this compound part followed by space and parentheses
				for key, value in pairs(rsd.Parts) do
					-- Escape special regex characters
					local escapedBasePart = string.gsub(basePart, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
					if string.match(key, "^" .. escapedBasePart .. " %(") then
						ukrainianBaseName = basePart
						break
					end
				end
				
				if ukrainianBaseName then
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
	
	-- Hook GetItemLinkName for item links (used in tooltips and some interfaces)
	local GetItemLinkNameOld = GetItemLinkName
	GetItemLinkName = function(itemLink)
		-- CRITICAL FIX: Skip postfix logic during data generation to prevent duplicates
		if DovahMova._isGeneratingData then
			return GetItemLinkNameOld(itemLink)
		end
		
		-- Simple test to see if this hook is working
		if itemLink and string.find(itemLink, "item:") then
			-- This is an item link, process it
		end
		

		-- Ensure itemLink is valid
		if not itemLink or itemLink == "" then
			return GetItemLinkNameOld(itemLink)
		end
		

		

		
		local originalName = GetItemLinkNameOld(itemLink)
		
		-- FIRST: Process adjectives before anything else (even in UA mode)
		if originalName and DovahMova_Adjectives then
			local debugInventory = DovahMova.tooltipDebugEnabled or false
			
			if debugInventory then
				d(string.format("ItemsDisplay GetItemLinkName - Original: '%s'", tostring(originalName)))
			end
			
			-- Try to add missing gender tags for common patterns
			if not string.find(originalName, "%^[fmnp]") then
				local needsGenderTag = false
				local suggestedGender = nil
				
				-- Use the same working patterns as in main hook
				local patterns = {
					{pattern = "%S*ий намисто", gender = "n"},
					{pattern = "%S*ий кільце", gender = "n"},
					{pattern = "%S*ий перстень", gender = "m"},
					{pattern = "%S*ій перстень", gender = "m"},
					{pattern = "%S*ий озброєння", gender = "n"},
					{pattern = "%S*ий обладунок", gender = "n"},
					{pattern = "%S*ий сережки", gender = "p"},
					{pattern = "%S*ій сережки", gender = "p"},
					{pattern = "%S*ий поножі", gender = "p"},
					{pattern = "%S*ій поножі", gender = "p"},
					{pattern = "%S*ий рукавиці", gender = "p"},
					{pattern = "%S*ій рукавиці", gender = "p"},
					{pattern = "%S*ий обладунки", gender = "p"},
					{pattern = "%S*ий сорочка", gender = "f"},
					{pattern = "%S*ій сорочка", gender = "f"},
					{pattern = "%S*ий броня", gender = "f"},
					{pattern = "%S*ій броня", gender = "f"},
				}
				
				for _, pat in ipairs(patterns) do
					if string.match(originalName, pat.pattern) then
						needsGenderTag = true
						suggestedGender = pat.gender
						if debugInventory then
							d(string.format("  ItemsDisplay: Pattern '%s' matched, adding gender: %s", pat.pattern, pat.gender))
						end
						break
					end
				end
				
				if needsGenderTag and suggestedGender then
					originalName = originalName .. "^" .. suggestedGender
					if debugInventory then
						d(string.format("  ItemsDisplay: Added tag, new name: '%s'", originalName))
					end
				end
			end
			
			-- Apply adjective processing
			if string.find(originalName, "%^[aа]") or string.find(originalName, "ий%s+%S+%^[fmnp]") or string.find(originalName, "ій%s+%S+%^[fmnp]") then
				local beforeProcessing = originalName
				originalName = DovahMova_Adjectives.ProcessTaggedString(originalName)
				if debugInventory then
					d(string.format("  ItemsDisplay: Processed adjectives: '%s' → '%s'", beforeProcessing, originalName))
				end
			end
		end
		
		if (originalName == nil or originalName == "" or DovahMova.Settings.ShowItemsDisplay == "ua") then
			return originalName
		end
		
		-- Use the actual setting instead of forcing it
		local testSetting = DovahMova.Settings.ShowItemsDisplay
		
		-- Get the item ID from the item link
		if GetItemLinkItemId then
			local itemId = GetItemLinkItemId(itemLink)
			if not itemId or itemId <= 0 then
				return originalName
			end
			

			
			-- CRITICAL FIX: Smart priority - use direct translation for complete items, crafted parsing for base parts
			local englishName = rsd.Items[itemId]
			if englishName and englishName ~= "" then
				-- Check if this is likely a base part only (single word) vs complete item name
				local wordCount = 0
				for word in string.gmatch(englishName, "%S+") do
					wordCount = wordCount + 1
				end
				
				-- If Ukrainian has more words than English, it likely needs material prefix expansion
				-- Fall back to crafted item parsing to get the full name
				-- Count only Ukrainian words (before any English postfix in parentheses)
				local ukrainianPart = string.match(originalName, "^(.*?) %(") or originalName
				local ukrainianWordCount = 0
				for word in string.gmatch(ukrainianPart, "%S+") do
					ukrainianWordCount = ukrainianWordCount + 1
				end
				
				if ukrainianWordCount > wordCount then
					if debugInventory then
						d(string.format("  ItemsDisplay: Base part detected - English: %d words, Ukrainian: %d words", wordCount, ukrainianWordCount))
					end
					
					-- Skip HandleCraftedItem for GetItemLinkName - it returns incomplete results  
					-- Go directly to material translation logic
					if debugInventory then
						d("  ItemsDisplay: Skipping HandleCraftedItem, trying material translation directly...")
					end
					
					-- If crafted parsing fails, try to create full English name from Ukrainian
					-- Extract material name from Ukrainian (first word) and translate it using existing system
					local firstWord = string.match(ukrainianPart, "^(%S+)")
					if firstWord then
						-- Remove gender tags if present
						firstWord = string.gsub(firstWord, "%^[fmnp]", "")
						
						if debugInventory then
							d(string.format("  ItemsDisplay: Trying to find material for: '%s' (from '%s')", firstWord, ukrainianPart))
						end
						
						-- Look for material translation in existing rsd.Prefixes table  
						if rsd and rsd.Prefixes then
							-- CRITICAL FIX: Handle Ukrainian adjective declensions
							-- Try multiple forms of the Ukrainian material name
							local materialVariants = {}
							
							-- Add the original word
							table.insert(materialVariants, firstWord)
							
							-- Add root forms by removing common Ukrainian adjective endings
							if string.match(firstWord, "ий$") then
								-- Remove -ий ending (masculine): березовий → березов
								table.insert(materialVariants, (string.gsub(firstWord, "ий$", "")))
							elseif string.match(firstWord, "ова$") then
								-- Remove -ова ending (feminine): березова → березов  
								table.insert(materialVariants, (string.gsub(firstWord, "ова$", "")))
								-- Also try alternative truncation: рубедітова → рубедіто
								table.insert(materialVariants, (string.gsub(firstWord, "ова$", "о")))
							elseif string.match(firstWord, "ове$") then
								-- Remove -ове ending (neuter): березове → березов
								table.insert(materialVariants, (string.gsub(firstWord, "ове$", "")))
							elseif string.match(firstWord, "ові$") then
								-- Remove -ові ending (plural): березові → березов
								table.insert(materialVariants, (string.gsub(firstWord, "ові$", "")))
							elseif string.match(firstWord, "ній$") then
								-- Remove -ній ending: синій → син
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
							
							if debugInventory then
								d(string.format("  ItemsDisplay: Material variants for '%s': %s", firstWord, table.concat(materialVariants, ", ")))
							end
							
							-- Try to match any variant against prefixes (prioritize longer matches)
							local found = false
							for _, variant in ipairs(materialVariants) do
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
										if debugInventory then
											d(string.format("  ItemsDisplay: EXACT MATCH! '%s' = '%s' → '%s'", variant, prefix.key, fullEnglishName))
										end
										return FormatItemName(originalName, fullEnglishName, testSetting)
									end
									-- Then try substring matching (both ways)
									if string.find(variant:lower(), prefix.key:lower()) or string.find(prefix.key:lower(), variant:lower()) then
										local fullEnglishName = prefix.value .. " " .. englishName
										if debugInventory then
											d(string.format("  ItemsDisplay: SUBSTRING MATCH! '%s' matches '%s' → '%s'", variant, prefix.key, fullEnglishName))
										end
										return FormatItemName(originalName, fullEnglishName, testSetting)
									end
								end
								if found then break end
							end
							
							if debugInventory then
								d(string.format("  ItemsDisplay: No material match found for any variant of '%s'", firstWord))
								-- Show first few prefixes for debugging
								local count = 0
								for prefixKey, prefixValue in pairs(rsd.Prefixes) do
									if count < 3 then
										d(string.format("    Example prefix: '%s' -> '%s'", prefixKey, prefixValue))
										count = count + 1
									end
								end
							end
						end
					end
					
					-- If no material translation found, fall back to the direct translation
					return FormatItemName(originalName, englishName, testSetting)
				else
					-- This is likely a complete item name, use direct translation
					return FormatItemName(originalName, englishName, testSetting)
				end
			end
			
			-- Only if no direct translation exists, try to handle as crafted item
			local result = HandleCraftedItem(originalName, itemId, testSetting)
			if result ~= originalName then
				return result
			end
			
			return originalName
		end
		
		return originalName
	end
	
	-- Hook GetItemName for non-linked items (like in inventory slots)
	if GetItemName then
		local GetItemNameOld = GetItemName
		GetItemName = function(bagId, slotIndex)
			-- Simple debug to see if this is being called
			if bagId == BAG_BACKPACK then
				-- Only log for backpack items to avoid spam
			end
			
			-- Add debug output to see if this is called for inventory items
			if bagId == BAG_BACKPACK then
				local originalName = GetItemNameOld(bagId, slotIndex)
				if originalName and string.find(originalName, "платиновий перстень") then
				end
			end
			-- Ensure parameters are valid
			if not bagId or not slotIndex or bagId < 0 or slotIndex < 0 then
				return GetItemNameOld(bagId, slotIndex)
			end
			
			local originalName = GetItemNameOld(bagId, slotIndex)
			
			-- FIRST: Process adjectives before anything else (even in UA mode)
			if originalName and DovahMova_Adjectives then
				local debugInventory = DovahMova.tooltipDebugEnabled or false
				
				if debugInventory then
					d(string.format("GetItemName debug - BagId: %s, Slot: %s, Name: '%s'", tostring(bagId), tostring(slotIndex), tostring(originalName)))
				end
				
				-- Try to add missing gender tags for common patterns
				if not string.find(originalName, "%^[fmnp]") then
					local needsGenderTag = false
					local suggestedGender = nil
					
					-- Use the same working patterns
					local patterns = {
						{pattern = "%S*ий намисто", gender = "n"},
						{pattern = "%S*ий кільце", gender = "n"},
						{pattern = "%S*ий перстень", gender = "m"},
						{pattern = "%S*ій перстень", gender = "m"},
						{pattern = "%S*ий озброєння", gender = "n"},
						{pattern = "%S*ий обладунок", gender = "n"},
						{pattern = "%S*ий сережки", gender = "p"},
						{pattern = "%S*ій сережки", gender = "p"},
						{pattern = "%S*ий поножі", gender = "p"},
						{pattern = "%S*ій поножі", gender = "p"},
						{pattern = "%S*ий рукавиці", gender = "p"},
						{pattern = "%S*ій рукавиці", gender = "p"},
						{pattern = "%S*ий обладунки", gender = "p"},
						{pattern = "%S*ий сорочка", gender = "f"},
						{pattern = "%S*ій сорочка", gender = "f"},
						{pattern = "%S*ий броня", gender = "f"},
						{pattern = "%S*ій броня", gender = "f"},
					}
					
					for _, pat in ipairs(patterns) do
						if string.match(originalName, pat.pattern) then
							needsGenderTag = true
							suggestedGender = pat.gender
							if debugInventory then
								d(string.format("  GetItemName: Pattern '%s' matched, adding gender: %s", pat.pattern, pat.gender))
							end
							break
						end
					end
					
					if needsGenderTag and suggestedGender then
						originalName = originalName .. "^" .. suggestedGender
						if debugInventory then
							d(string.format("  GetItemName: Added tag, new name: '%s'", originalName))
						end
					end
				end
				
				-- Apply adjective processing
				if string.find(originalName, "%^[aа]") or string.find(originalName, "ий%s+%S+%^[fmnp]") or string.find(originalName, "ій%s+%S+%^[fmnp]") then
					local beforeProcessing = originalName
					originalName = DovahMova_Adjectives.ProcessTaggedString(originalName)
					if debugInventory then
						d(string.format("  GetItemName: Processed adjectives: '%s' → '%s'", beforeProcessing, originalName))
					end
				end
			end
			
			local debugInventory = DovahMova.tooltipDebugEnabled or false
			
			if debugInventory then
				d(string.format("  GetItemName: Settings check - ShowItemsDisplay='%s'", tostring(DovahMova.Settings.ShowItemsDisplay)))
			end
			
			if (originalName == nil or originalName == "" or DovahMova.Settings.ShowItemsDisplay == "ua") then
				if debugInventory then
					d(string.format("  GetItemName: Exiting early - originalName='%s', setting='%s'", tostring(originalName), tostring(DovahMova.Settings.ShowItemsDisplay)))
				end
				return originalName
			end
			
			-- Use the actual setting instead of forcing it
			local testSetting = DovahMova.Settings.ShowItemsDisplay
			
			if debugInventory then
				d(string.format("  GetItemName: Will process with setting='%s'", tostring(testSetting)))
			end
			
			-- Get the item ID from the bag slot
			if GetItemId then
				local itemId = GetItemId(bagId, slotIndex)
				if debugInventory then
					d(string.format("  GetItemName: Retrieved itemId=%s from bag=%s slot=%s", tostring(itemId), tostring(bagId), tostring(slotIndex)))
				end
				if not itemId or itemId <= 0 then
					if debugInventory then
						d("  GetItemName: Invalid itemId, returning originalName")
					end
					return originalName
				end
				
				if debugInventory then
					d(string.format("  GetItemName: Valid itemId=%s, checking database", tostring(itemId)))
					d(string.format("  GetItemName: rsd available: %s", tostring(rsd ~= nil)))
					if rsd and rsd.Items then
						d(string.format("  GetItemName: rsd.Items available: %s", tostring(rsd.Items ~= nil)))
					end
				end
				
				-- CRITICAL FIX: Smart priority - use direct translation for complete items, crafted parsing for base parts
				local englishName = rsd and rsd.Items and rsd.Items[itemId]
				
				if debugInventory then
					d(string.format("  GetItemName: English translation for %s: '%s'", tostring(itemId), tostring(englishName)))
				end
				if englishName and englishName ~= "" then
					if debugInventory then
						d(string.format("  GetItemName: Processing English name '%s'", englishName))
					end
					-- Check if this is likely a base part only (single word) vs complete item name
					local wordCount = 0
					for word in string.gmatch(englishName, "%S+") do
						wordCount = wordCount + 1
					end
					
					if debugInventory then
						d(string.format("  GetItemName: Word count analysis - English wordCount=%d", wordCount))
					end
					
					-- If Ukrainian has more words than English, it likely needs material prefix expansion
					-- Fall back to crafted item parsing to get the full name
					-- Simulate final formatted name (like tooltip) to count words consistently
					local simulatedFinalName = originalName .. " (" .. englishName .. ")"
					local ukrainianWordCount = 0
					for word in string.gmatch(simulatedFinalName, "%S+") do
						ukrainianWordCount = ukrainianWordCount + 1
					end
					
					-- Extract Ukrainian part for material extraction later
					local ukrainianPart = string.match(originalName, "^(.*?) %(") or originalName
					
					if debugInventory then
						d(string.format("  GetItemName: Simulated final name (like tooltip): '%s' = %d words", simulatedFinalName, ukrainianWordCount))
						d(string.format("  GetItemName: Ukrainian part for material extraction: '%s'", tostring(ukrainianPart)))
					end
					
					if debugInventory then
						d(string.format("  GetItemName: Ukrainian word count=%d, comparison: %d > %d = %s", ukrainianWordCount, ukrainianWordCount, wordCount, tostring(ukrainianWordCount > wordCount)))
					end
					
					if ukrainianWordCount > wordCount then
						if debugInventory then
							d(string.format("  GetItemName: Base part detected - English: %d words, Ukrainian: %d words", wordCount, ukrainianWordCount))
						end
						
						-- Skip HandleCraftedItem for inventory - it returns incomplete results
						-- Go directly to material translation logic
						if debugInventory then
							d("  GetItemName: Skipping HandleCraftedItem, trying material translation directly...")
						end
						
						-- If crafted parsing fails, try to create full English name from Ukrainian
						-- Extract material name from Ukrainian (first word) and translate it using existing system
						local firstWord = string.match(ukrainianPart, "^(%S+)")
						if firstWord then
							-- Remove gender tags if present
							firstWord = string.gsub(firstWord, "%^[fmnp]", "")
							
							if debugInventory then
								d(string.format("  GetItemName: Trying to find material for: '%s' (from '%s')", firstWord, ukrainianPart))
							end
							
							-- Look for material translation in existing rsd.Prefixes table  
							if rsd and rsd.Prefixes then
								-- CRITICAL FIX: Handle Ukrainian adjective declensions
								-- Try multiple forms of the Ukrainian material name
								local materialVariants = {}
								
								-- Add the original word
								table.insert(materialVariants, firstWord)
								
								-- Add root forms by removing common Ukrainian adjective endings
								if string.match(firstWord, "ий$") then
									-- Remove -ий ending (masculine): березовий → березов
									table.insert(materialVariants, (string.gsub(firstWord, "ий$", "")))
								elseif string.match(firstWord, "ова$") then
									-- Remove -ова ending (feminine): березова → березов  
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "")))
									-- Also try alternative truncation: рубедітова → рубедіто
									table.insert(materialVariants, (string.gsub(firstWord, "ова$", "о")))
								elseif string.match(firstWord, "ове$") then
									-- Remove -ове ending (neuter): березове → березов
									table.insert(materialVariants, (string.gsub(firstWord, "ове$", "")))
								elseif string.match(firstWord, "ові$") then
									-- Remove -ові ending (plural): березові → березов
									table.insert(materialVariants, (string.gsub(firstWord, "ові$", "")))
								elseif string.match(firstWord, "ній$") then
									-- Remove -ній ending: синій → син
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
								
								if debugInventory then
									d(string.format("  GetItemName: Material variants for '%s': %s", firstWord, table.concat(materialVariants, ", ")))
								end
								
								-- Try to match any variant against prefixes (prioritize longer matches)
								local found = false
								for _, variant in ipairs(materialVariants) do
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
											if debugInventory then
												d(string.format("  GetItemName: EXACT MATCH! '%s' = '%s' → '%s'", variant, prefix.key, fullEnglishName))
											end
											return FormatItemName(originalName, fullEnglishName, testSetting)
										end
										-- Then try substring matching (both ways)
										if string.find(variant:lower(), prefix.key:lower()) or string.find(prefix.key:lower(), variant:lower()) then
											local fullEnglishName = prefix.value .. " " .. englishName
											if debugInventory then
												d(string.format("  GetItemName: SUBSTRING MATCH! '%s' matches '%s' → '%s'", variant, prefix.key, fullEnglishName))
											end
											return FormatItemName(originalName, fullEnglishName, testSetting)
										end
									end
									if found then break end
								end
								
								if debugInventory then
									d(string.format("  GetItemName: No material match found for any variant of '%s'", firstWord))
									-- Show first few prefixes for debugging
									local count = 0
									for prefixKey, prefixValue in pairs(rsd.Prefixes) do
										if count < 3 then
											d(string.format("    Example prefix: '%s' -> '%s'", prefixKey, prefixValue))
											count = count + 1
										end
									end
								end
							else
								if debugInventory then
									d("  GetItemName: rsd.Prefixes not available")
								end
							end
						end
						
						if debugInventory then
							d("  GetItemName: Material translation failed, using fallback")
						end
						
						-- If no material translation found, fall back to the direct translation
						return FormatItemName(originalName, englishName, testSetting)
					else
						-- This is likely a complete item name, use direct translation
						if debugInventory then
							d(string.format("  GetItemName: Using direct translation (complete item), returning formatted name"))
						end
						return FormatItemName(originalName, englishName, testSetting)
					end
				else
					if debugInventory then
						d(string.format("  GetItemName: No English translation found, trying HandleCraftedItem"))
					end
				end
				
				-- Only if no direct translation exists, try to handle as crafted item
				local result = HandleCraftedItem(originalName, itemId, testSetting)
				if result ~= originalName then
					return result
				end
				
				return originalName
			end
			
			return originalName
		end
	end
	
	-- Hook GetStoreEntryInfo for store items (corrected function name)
	if GetStoreEntryInfo then
		local GetStoreEntryInfoOld = GetStoreEntryInfo
		GetStoreEntryInfo = function(entryIndex)
			-- Get the original info
			local icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId, actorCategory = GetStoreEntryInfoOld(entryIndex)
			
			-- Only modify the name if we're not in Ukrainian-only mode and have a valid name
			if name and name ~= "" and DovahMova.Settings.ShowItemsDisplay ~= "ua" then
				-- Get the item link to extract item ID
				local itemLink = GetStoreItemLink(entryIndex)
				if itemLink and GetItemLinkItemId then
					local itemId = GetItemLinkItemId(itemLink)
					if itemId and itemId > 0 then
						-- Check if we have an English translation for this item
						local englishName = rsd.Items[itemId]
						if englishName and englishName ~= "" then
							-- Apply the appropriate format based on settings
							name = FormatItemName(name, englishName, DovahMova.Settings.ShowItemsDisplay)
						end
					end
				end
			end
			
			return icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId, actorCategory
		end
	end
	
	-- Hook GetStoreItemLink for Crown Store item links (NEW)
	if GetStoreItemLink then
		local GetStoreItemLinkOld = GetStoreItemLink
		GetStoreItemLink = function(entryIndex, linkStyle)
			-- Ensure entryIndex is valid
			if not entryIndex or entryIndex < 0 then
				return GetStoreItemLinkOld(entryIndex, linkStyle)
			end
			
			local itemLink = GetStoreItemLinkOld(entryIndex, linkStyle)
			
			-- The link itself doesn't need modification, but we can use it to get the name
			-- The GetItemLinkName hook will handle the name formatting
			return itemLink
		end
	end
	
	-- Hook GetMerchantItemName for merchant store items (NEW)
	if GetMerchantItemName then
		local GetMerchantItemNameOld = GetMerchantItemName
		GetMerchantItemName = function(merchantIndex)
			-- Ensure merchantIndex is valid
			if not merchantIndex or merchantIndex < 0 then
				return GetMerchantItemNameOld(merchantIndex)
			end
			
			local originalName = GetMerchantItemNameOld(merchantIndex)
			
			if (originalName == nil or originalName == "" or DovahMova.Settings.ShowItemsDisplay == "ua") then
				return originalName
			end
			
			-- Get the item ID from the merchant entry
			if GetMerchantItemId then
				local itemId = GetMerchantItemId(merchantIndex)
				if not itemId or itemId <= 0 then
					return originalName
				end
				
				-- Check if we have an English translation for this item
				local englishName = rsd.Items[itemId]
				if not englishName or englishName == "" then
					return originalName
				end
				
				-- Apply the appropriate format based on settings
				return FormatItemName(originalName, englishName, DovahMova.Settings.ShowItemsDisplay)
			end
			
			return originalName
		end
	end
	
	-- Hook GetMerchantItemLink for merchant store item links (NEW)
	if GetMerchantItemLink then
		local GetMerchantItemLinkOld = GetMerchantItemLink
		GetMerchantItemLink = function(merchantIndex, linkStyle)
			-- Ensure merchantIndex is valid
			if not merchantIndex or merchantIndex < 0 then
				return GetMerchantItemLinkOld(merchantIndex, linkStyle)
			end
			
			local itemLink = GetMerchantItemLinkOld(merchantIndex, linkStyle)
			
			-- The link itself doesn't need modification, but we can use it to get the name
			-- The GetItemLinkName hook will handle the name formatting
			return itemLink
		end
	end
	
	-- Hook GetVendorItemName for vendor items (NEW)
	if GetVendorItemName then
		local GetVendorItemNameOld = GetVendorItemName
		GetVendorItemName = function(vendorIndex)
			-- Ensure vendorIndex is valid
			if not vendorIndex or vendorIndex < 0 then
				return GetVendorItemNameOld(vendorIndex)
			end
			
			local originalName = GetVendorItemNameOld(vendorIndex)
			
			if (originalName == nil or originalName == "" or DovahMova.Settings.ShowItemsDisplay == "ua") then
				return originalName
			end
			
			-- Get the item ID from the vendor entry
			if GetVendorItemId then
				local itemId = GetVendorItemId(vendorIndex)
				if not itemId or itemId <= 0 then
					return originalName
				end
				
				-- Check if we have an English translation for this item
				local englishName = rsd.Items[itemId]
				if not englishName or englishName == "" then
					return originalName
				end
				
				-- Apply the appropriate format based on settings
				return FormatItemName(originalName, englishName, DovahMova.Settings.ShowItemsDisplay)
			end
			
			return originalName
		end
	end
	
	-- Hook GetVendorItemLink for vendor item links (NEW)
	if GetVendorItemLink then
		local GetVendorItemLinkOld = GetVendorItemLink
		GetVendorItemLink = function(vendorIndex, linkStyle)
			-- Ensure vendorIndex is valid
			if not vendorIndex or vendorIndex < 0 then
				return GetVendorItemLinkOld(vendorIndex, linkStyle)
			end
			
			local itemLink = GetVendorItemLinkOld(vendorIndex, linkStyle)
			
			-- The link itself doesn't need modification, but we can use it to get the name
			-- The GetItemLinkName hook will handle the name formatting
			return itemLink
		end
	end
	
	-- Hook GetBuybackItemInfo for merchant buyback items (NEW)
	if GetBuybackItemInfo then
		local GetBuybackItemInfoOld = GetBuybackItemInfo
		GetBuybackItemInfo = function(entryIndex)
			-- Get the original info
			local icon, name, stack, price, functionalQuality, meetsRequirementsToEquip, displayQuality = GetBuybackItemInfoOld(entryIndex)
			
			-- Only modify the name if we're not in Ukrainian-only mode and have a valid name
			if name and name ~= "" and DovahMova.Settings.ShowItemsDisplay ~= "ua" then
				-- Get the item link to extract item ID
				local itemLink = GetBuybackItemLink(entryIndex)
				if itemLink and GetItemLinkItemId then
					local itemId = GetItemLinkItemId(itemLink)
					if itemId and itemId > 0 then
						-- Check if we have an English translation for this item
						local englishName = rsd.Items[itemId]
						if englishName and englishName ~= "" then
							-- Apply the appropriate format based on settings
							name = FormatItemName(name, englishName, DovahMova.Settings.ShowItemsDisplay)
						end
					end
				end
			end
			
			return icon, name, stack, price, functionalQuality, meetsRequirementsToEquip, displayQuality
		end
	end
	
	-- Hook GetBuybackItemLink for merchant buyback item links (NEW)
	if GetBuybackItemLink then
		local GetBuybackItemLinkOld = GetBuybackItemLink
		GetBuybackItemLink = function(entryIndex, linkStyle)
			-- Ensure entryIndex is valid
			if not entryIndex or entryIndex < 0 then
				return GetBuybackItemLinkOld(entryIndex, linkStyle)
			end
			
			local itemLink = GetBuybackItemLinkOld(entryIndex, linkStyle)
			
			-- The link itself doesn't need modification, but we can use it to get the name
			-- The GetItemLinkName hook will handle the name formatting
			return itemLink
		end
	end
	
	-- Don't set the function to nil - it needs to be callable from settings
end


