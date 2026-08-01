function DovahMova_doubleNamesItems(DovahMova)
	if DovahMova:GetLanguage() == "ua" then
		
		-- Tooltips
		local rsd = DovahMova.Settings.Data
		
		local function GetWornLink(slot, bagId)
			return GetItemLink(bagId, slot)
		end
		
		local function GetChatLink(aLink)
			return aLink
		end
		
		local function CheckAlchemyName(...)
			local link, prospectiveAlchemyResult = GetAlchemyResultingItemLink(...)
			if prospectiveAlchemyResult ~= PROSPECTIVE_ALCHEMY_RESULT_KNOWN then
				return ""
			else
				return link
			end
		end
		
		local function splitItemName(itemName, itemNameRaw)
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
				
				-- CRITICAL FIX: Handle compound weapon names by checking all Parts entries
				if not englishName then
					-- Try to find compound matches in the Parts table
					local bestMatch = nil
					local bestMatchLength = 0
					
					-- Look through all Parts entries to find the longest matching substring
					for partKey, partValue in pairs(rsd.Parts) do
						-- Check if this part key is contained in the base name
						if string.find(baseName, partKey) then
							local keyLength = string.len(partKey)
							-- Keep track of the longest match (most specific)
							if keyLength > bestMatchLength then
								bestMatch = partKey
								bestMatchLength = keyLength
								englishName = partValue
							end
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
			
			-- Debug output
			-- First, check if the itemName contains parentheses (English translation)
			-- If so, extract only the Ukrainian part before the parentheses
			local ukrainianOnly = itemName
			if string.find(itemName, " %(") then
				ukrainianOnly = string.match(itemName, "^(.*?) %(")
				if not ukrainianOnly then
					-- Try a different approach - look for the first opening parenthesis
					local pos = string.find(itemName, " %(")
					if pos then
						ukrainianOnly = string.sub(itemName, 1, pos - 1)
					end
				end
			end
			
			if string.match(ukrainianOnly, " " .. itemNameRaw .. " ") then
				-- Need to escape special regex characters in itemNameRaw for compound names
				local escapedItemNameRaw = string.gsub(itemNameRaw, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
				local prefix, affix = string.match(ukrainianOnly, "^(.*) " .. escapedItemNameRaw .. " (.*)$")
				
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
				
				local englishBaseName = getEnglishBaseName(itemNameRaw)
				finalName = finalName .. (englishBaseName or itemNameRaw)
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				else
				end
				
				return finalName
			elseif string.match(ukrainianOnly, " " .. itemNameRaw .. "$") then
				-- Need to escape special regex characters in itemNameRaw for compound names  
				local escapedItemNameRaw = string.gsub(itemNameRaw, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
				local prefix = string.match(ukrainianOnly, "^(.*) " .. escapedItemNameRaw .. "$")
				
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
				local englishBaseName = getEnglishBaseName(itemNameRaw)
				finalName = finalName .. (englishBaseName or itemNameRaw)
				
				return finalName
			elseif string.match(ukrainianOnly, "^" .. itemNameRaw .. " ") then
				-- Need to escape special regex characters in itemNameRaw for compound names
				local escapedItemNameRaw = string.gsub(itemNameRaw, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
				local affix = string.match(ukrainianOnly, "^" .. escapedItemNameRaw .. " (.*)$")
				
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(itemNameRaw)
				finalName = englishBaseName or itemNameRaw
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				else
				end
				
				return finalName
			else
				-- Get the English base name using helper function
				local englishBaseName = getEnglishBaseName(itemNameRaw)
				return englishBaseName or itemNameRaw
			end
		end
		
		local function modifyTooltip(lnk)
			if DovahMova.Settings.ShowItemsNamesTooltip ~= DovahMova.DropdownParameters["ua"] or DovahMova.Settings.ShowItemsEnchantsTooltip ~= "ua" or DovahMova.Settings.ShowItemsTraitsTooltip ~= "ua" or DovahMova.Settings.ShowItemsSetsTooltip ~= "ua" then
				local ukrainianName, rusTrait, rusEnchant, rusSet
				local itmType = GetItemLinkItemType(lnk)
				-- Names
				
				local itmId = GetItemLinkItemId(lnk)
				local itmName = GetItemLinkName(lnk)
				
				-- DEBUG: Check if adjectives processing is needed for tooltips
				local debugTooltips = DovahMova.tooltipDebugEnabled or false
				if debugTooltips then
					d(string.format("Tooltip debug - ItemID: %s, Name: '%s'", tostring(itmId), tostring(itmName)))
					if itmName and (string.find(itmName, "%^[afmnp]") or string.find(itmName, "[иі]й%s+%S+%^[fmnp]")) then
						d("  -> Name contains adjective patterns, should be processed")
					else
						d("  -> No adjective patterns found")
					end
				end
				
				-- Process adjectives in tooltip names if needed
				if itmName and DovahMova_Adjectives then
					-- First, try to add missing gender tags for common patterns
					if not string.find(itmName, "%^[fmnp]") then
						-- Check if this looks like an item that should have gender tags
						local needsGenderTag = false
						local suggestedGender = nil
						
						-- Common patterns that need gender tags
						-- Use patterns that actually work - based on debug results
						local patterns = {
							-- Neuter gender items (jewelry) - using working pattern %S*ий 
							{pattern = "%S*ий намисто", gender = "n"}, -- мідний намисто^n
							{pattern = "%S*ий кільце", gender = "n"}, -- золотий кільце^n (golden ring)
							{pattern = "%S*ий перстень", gender = "m"}, -- срібний перстень^m (silver ring)
							{pattern = "%S*ій перстень", gender = "m"}, -- синій перстень^m (blue ring)
							
							-- Neuter gender items (armor/weapons)
							{pattern = "%S*ий озброєння", gender = "n"}, -- стальний озброєння^n  
							{pattern = "%S*ий обладунок", gender = "n"}, -- залізний обладунок^n
							
							-- Plural items (jewelry)
							{pattern = "%S*ий сережки", gender = "p"}, -- золотий сережки^p
							{pattern = "%S*ій сережки", gender = "p"}, -- синій сережки^p
							
							-- Plural items (armor)
							{pattern = "%S*ий поножі", gender = "p"}, -- стальний поножі^p
							{pattern = "%S*ій поножі", gender = "p"}, -- синій поножі^p
							{pattern = "%S*ий рукавиці", gender = "p"}, -- шкіряний рукавиці^p
							{pattern = "%S*ій рукавиці", gender = "p"}, -- синій рукавиці^p  
							{pattern = "%S*ий обладунки", gender = "p"}, -- стальний обладунки^p
							
							-- Feminine items
							{pattern = "%S*ий сорочка", gender = "f"}, -- бавовняний сорочка^f
							{pattern = "%S*ій сорочка", gender = "f"}, -- синій сорочка^f
							{pattern = "%S*ий броня", gender = "f"}, -- залізний броня^f
							{pattern = "%S*ій броня", gender = "f"}, -- синій броня^f
						}
						
						for _, pat in ipairs(patterns) do
							if debugTooltips then
								d(string.format("  Checking pattern: '%s' against '%s'", pat.pattern, itmName))
							end
							if string.match(itmName, pat.pattern) then
								needsGenderTag = true
								suggestedGender = pat.gender
								if debugTooltips then
									d(string.format("  PATTERN MATCHED! Adding gender: %s", pat.gender))
								end
								break
							end
						end
						
						if needsGenderTag and suggestedGender then
							itmName = itmName .. "^" .. suggestedGender
							if debugTooltips then
								d(string.format("  -> Added missing gender tag: '%s'", itmName))
							end
						end
					end
					
					-- Apply adjective processing to tooltip name
					if string.find(itmName, "%^[afmnp]") or string.find(itmName, "[иі]й%s+%S+%^[fmnp]") then
						itmName = DovahMova_Adjectives.ProcessTaggedString(itmName)
						if debugTooltips then
							d(string.format("  -> Processed name: '%s'", itmName))
						end
					end
				end
				
				ukrainianName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itmName)
				local itmNameRaw = rsd.Items[itmId]
				-- Use the same Ukrainian name that's displayed in inventory
				local itmNameRawRu = ZO_CachedStrFormat("<<z:1>>", itmName)
				local itmNameFinal = ""
				
				if debugTooltips then
					d(string.format("  Database lookup: itmId=%s, hasDirectTranslation=%s", tostring(itmId), tostring(itmNameRaw ~= nil)))
					if itmNameRaw then
						d(string.format("  Direct translation: '%s'", tostring(itmNameRaw)))
					end
				end
				
				local finalName, finalEnchant, finalTrait, finalSet
				
				if itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then						
					if itmNameRaw then
						for index,value in pairs(rsd.EnchantPrefixes) do
							if string.match(ZO_CachedStrFormat("<<z:1>>", itmName), "^" .. index) then
								itmNameFinal = value .. " "
								break
							end
						end
						
						finalName = itmNameFinal .. itmNameRaw
					end
				elseif itmType == ITEMTYPE_POISON or itmType == ITEMTYPE_POTION then
					if rsd.Potions[ZO_CachedStrFormat("<<z:1>>", itmName)] then
						finalName = rsd.Potions[ZO_CachedStrFormat("<<z:1>>", itmName)]
					elseif rsd.Items[itmId] then
						finalName = rsd.Items[itmId]
					end
				elseif itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_JEWELRY then
					
					if debugTooltips then
						d(string.format("  Processing ARMOR/WEAPON/JEWELRY item - ID: %s, Name: '%s'", tostring(itmId), tostring(itmName)))
					end
					
					-- CRITICAL FIX: Smart priority - use direct translation for complete items, crafted parsing for base parts
					if rsd.Items[itmId] then
						local directEnglishName = rsd.Items[itmId]
						
						if debugTooltips then
							d(string.format("  Found direct English translation: '%s'", tostring(directEnglishName)))
						end
						
						-- Check if this is likely a base part only (single word) vs complete item name
						-- But only do this if the direct translation doesn't look complete
						local wordCount = 0
						for word in string.gmatch(directEnglishName, "%S+") do
							wordCount = wordCount + 1
						end
						
						local ukrainianWordCount = 0
						for word in string.gmatch(itmNameRawRu, "%S+") do
							ukrainianWordCount = ukrainianWordCount + 1
						end
						
						if debugTooltips then
							d(string.format("  Word count analysis: English=%d words, Ukrainian=%d words", wordCount, ukrainianWordCount))
						end
						
						-- IMPROVED LOGIC: Try material expansion if Ukrainian has more words than English
						-- This handles both simple items (Bow) and compound items (Inferno Staff)
						local needsMaterialExpansion = (ukrainianWordCount > wordCount)
						
						if debugTooltips then
							d(string.format("  Material expansion analysis: needsExpansion=%s (Ukrainian:%d > English:%d)", tostring(needsMaterialExpansion), ukrainianWordCount, wordCount))
						end
						
						if needsMaterialExpansion then
							-- This is likely a base part, try crafted item parsing first
							-- Fall through to crafted item logic below
						else
							-- This is likely a complete item name, use direct translation
							-- Extract just the English name, removing the ID in parentheses
							local englishName = string.match(directEnglishName, "^(.*?) %(")
							if englishName then
								finalName = englishName
							else
								-- Check if the string contains parentheses at all
								local pos = string.find(directEnglishName, " %(")
								if pos then
									finalName = string.sub(directEnglishName, 1, pos - 1)
								else
									finalName = directEnglishName
								end
							end
							
							-- Extract just the Ukrainian part of the name (before the parentheses)
							local ukrainianName = string.match(itmNameRawRu, "^(.*?) %(")
							if not ukrainianName then
								-- Try a different approach - look for the first opening parenthesis
								local pos = string.find(itmNameRawRu, " %(")
								if pos then
									ukrainianName = string.sub(itmNameRawRu, 1, pos - 1)
								else
									ukrainianName = itmNameRawRu
								end
							end
							
							-- Format as postfix: Ukrainian Name (English Name)
							finalName = string.format("%s (%s)", ukrainianName, finalName)
							
							if debugTooltips then
								d(string.format("  Created finalName with postfix: '%s'", finalName))
							end
						end
					end
					
					-- If we haven't set finalName yet (either no direct translation or it was a base part), try crafted item parsing
					if not finalName or finalName == "" then
						
						if debugTooltips then
							d("  No direct translation found or base part detected, trying crafted item parsing...")
						end
						
						-- Only if no direct translation exists, check if this is a crafted item
						local isCraftedItem = false
						local ukrainianBaseName = nil
						
						-- Try to find the base component by looking for words in the Ukrainian name
						local words = {}
						for word in string.gmatch(itmNameRawRu, "%S+") do
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
									isCraftedItem = true
									break
								end
								
								-- Try looking for keys that start with this compound part followed by space and parentheses
								for key, value in pairs(rsd.Parts) do
									-- Escape special regex characters
									local escapedBasePart = string.gsub(basePart, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
									if string.match(key, "^" .. escapedBasePart .. " %(") then
										ukrainianBaseName = basePart
										isCraftedItem = true
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
						
						-- If it's a crafted item, use splitItemName
						if isCraftedItem then
						-- This is a crafted item, use splitItemName to build the full English name
						
						if ukrainianBaseName then
							-- Check if we have this base name in Parts (either direct or with ID)
							local hasBaseName = false
							if rsd.Parts[ukrainianBaseName] then
								hasBaseName = true
							else
								-- Check for keys that start with ukrainianBaseName followed by space and parentheses
								for key, value in pairs(rsd.Parts) do
									local escapedBaseName = string.gsub(ukrainianBaseName, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
									if string.match(key, "^" .. escapedBaseName .. " %(") then
										hasBaseName = true
										break
									end
								end
							end
							
							if hasBaseName then
								finalName = splitItemName(ZO_CachedStrFormat("<<z:1>>", itmName), ukrainianBaseName)
								
								-- Format as postfix: Full Ukrainian Name (English Name)
								-- Extract the full Ukrainian name from itmNameRawRu
								local fullUkrainianName = string.match(itmNameRawRu, "^(.*?) %(")
								if not fullUkrainianName then
									-- Try a different approach - look for the first opening parenthesis
									local pos = string.find(itmNameRawRu, " %(")
									if pos then
										fullUkrainianName = string.sub(itmNameRawRu, 1, pos - 1)
									else
										fullUkrainianName = itmNameRawRu
									end
								end
								finalName = string.format("%s (%s)", fullUkrainianName, finalName)
							end
						end
						end
					end
					
					-- FALLBACK: If crafted parsing failed but we have direct translation, use it
					-- Also check if this is a base part that needs full English name creation
					if rsd.Items[itmId] then
						local shouldProcessFallback = (not finalName or finalName == "")
						
						-- Or if finalName already contains a postfix but uses only base name
						if not shouldProcessFallback and finalName and string.find(finalName, " %(") then
							local currentEnglishPart = string.match(finalName, " %((.-)%)$")
							if currentEnglishPart then
								-- Count words in current English part
								local englishWordCount = 0
								for word in string.gmatch(currentEnglishPart, "%S+") do
									englishWordCount = englishWordCount + 1
								end
								
								-- Count Ukrainian words
								local ukrainianPart = string.match(itmNameRawRu, "^(.*?) %(") or itmNameRawRu
								local ukrainianWordCount = 0
								for word in string.gmatch(ukrainianPart, "%S+") do
									ukrainianWordCount = ukrainianWordCount + 1
								end
								
								-- If Ukrainian has more words than English, try to expand with material
								if ukrainianWordCount > englishWordCount then
									shouldProcessFallback = true
									if debugTooltips then
										d(string.format("  Tooltip: Base part detected in existing finalName, will try to expand '%s'", currentEnglishPart))
									end
								end
							end
						end
						
						if shouldProcessFallback then
						local directEnglishName = rsd.Items[itmId]
						
						if debugTooltips then
							d(string.format("  Crafted parsing failed, falling back to direct translation: '%s'", directEnglishName))
						end
						
						-- Extract just the English name, removing any ID in parentheses  
						local englishName = string.match(directEnglishName, "^(.*?) %(")
						if englishName then
							finalName = englishName
						else
							-- Check if the string contains parentheses at all
							local pos = string.find(directEnglishName, " %(")
							if pos then
								finalName = string.sub(directEnglishName, 1, pos - 1)
							else
								finalName = directEnglishName
							end
						end
						
						-- If this is a base part (single English word but multiple Ukrainian words), 
						-- try to create full English name from Ukrainian
						local englishWordCount = 0
						for word in string.gmatch(finalName, "%S+") do
							englishWordCount = englishWordCount + 1
						end
						
						-- Count only Ukrainian words (before any English postfix in parentheses)
						local ukrainianPart = string.match(itmNameRawRu, "^(.*?) %(") or itmNameRawRu
						local ukrainianWordCount = 0
						for word in string.gmatch(ukrainianPart, "%S+") do
							ukrainianWordCount = ukrainianWordCount + 1
						end
						
						if ukrainianWordCount > englishWordCount then
							-- Try to create full English name from Ukrainian
							local firstWord = string.match(ukrainianPart, "^(%S+)")
							if firstWord then
								-- Remove gender tags if present
								firstWord = string.gsub(firstWord, "%^[fmnp]", "")
								
								if debugTooltips then
									d(string.format("  Tooltip: Trying to find material for: '%s' (from '%s')", firstWord, ukrainianPart))
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
									
									if debugTooltips then
										d(string.format("  Tooltip: Material variants for '%s': %s", firstWord, table.concat(materialVariants, ", ")))
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
												local fullEnglishName = prefix.value .. " " .. finalName
												if debugTooltips then
													d(string.format("  Tooltip: EXACT MATCH! '%s' = '%s' → '%s'", variant, prefix.key, fullEnglishName))
												end
												finalName = fullEnglishName
												found = true
												break
											end
											-- Then try substring matching (both ways)
											if string.find(variant:lower(), prefix.key:lower()) or string.find(prefix.key:lower(), variant:lower()) then
												local fullEnglishName = prefix.value .. " " .. finalName
												if debugTooltips then
													d(string.format("  Tooltip: SUBSTRING MATCH! '%s' matches '%s' → '%s'", variant, prefix.key, fullEnglishName))
												end
												finalName = fullEnglishName
												found = true
												break
											end
										end
										if found then break end
									end
									
									if not found and debugTooltips then
										d(string.format("  Tooltip: No material match found for any variant of '%s'", firstWord))
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
									if debugTooltips then
										d("  Tooltip: rsd.Prefixes not available")
									end
								end
							end
						end
						
						-- Extract just the Ukrainian part of the name (before the parentheses)
						local ukrainianName = string.match(itmNameRawRu, "^(.*?) %(")
						if not ukrainianName then
							-- Try a different approach - look for the first opening parenthesis
							local pos = string.find(itmNameRawRu, " %(")
							if pos then
								ukrainianName = string.sub(itmNameRawRu, 1, pos - 1)
							else
								ukrainianName = itmNameRawRu
							end
						end
						
						-- Format as postfix: Ukrainian Name (English Name)  
						finalName = string.format("%s (%s)", ukrainianName, finalName)
						
						if debugTooltips then
							d(string.format("  Fallback finalName with postfix: '%s'", finalName))
						end
						end
					end
					
				elseif itmType == ITEMTYPE_CONTAINER then
					if rsd.Items[itmId] then
						local loweredItemName = ZO_CachedStrFormat("<<z:1>>", itmName)
						if loweredItemName ~= itmNameRawRu then
							local prefix = string.match(loweredItemName, "^([^ ]+) ")
							
							if prefix and rsd.Prefixes[prefix:sub(1, #prefix - 4)] then
								finalName = rsd.Prefixes[prefix:sub(1, #prefix - 4)] .. " " .. rsd.Items[itmId]
							else
								finalName = rsd.Items[itmId]
							end
						else
							finalName = rsd.Items[itmId]
						end
					end
				else
					if rsd.Items[itmId] then
						finalName = rsd.Items[itmId]
					end
				end
				
				-- Enchantments
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then
					if uaesoEnchants[GetItemLinkFinalEnchantId(lnk)] then
						local hasCharges, enchantHeader = GetItemLinkEnchantInfo(lnk)
						rusEnchant = string.match(enchantHeader, ": (.*)$")
						finalEnchant = uaesoEnchants[GetItemLinkFinalEnchantId(lnk)]
					end
				end
				
				-- Traits
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_ARMOR_TRAIT or itmType == ITEMTYPE_JEWELRY_TRAIT or itmType == ITEMTYPE_WEAPON_TRAIT then
					local traitType = GetItemLinkTraitType(lnk)
					if rsd.Traits[traitType] then
						rusTrait = GetString("SI_ITEMTRAITTYPE", traitType)
						finalTrait = rsd.Traits[traitType]
					end
				end
				
				-- Sets
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_JEWELRY then
					local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(lnk, false)
					rusSet = setName
					
					if rsd.Sets[setId] then
						finalSet = rsd.Sets[setId]
					end
				end
				
				if itmType == ITEMTYPE_CONTAINER then
					local numSetIds = GetItemLinkNumContainerSetIds(lnk)
					
					if numSetIds > 0 then
						for i = 1, numSetIds do
							local hasSet, _, _, _, _, setId = GetItemLinkContainerSetInfo(lnk, i)
							
							if rsd.Sets[setId] then
								finalSet = rsd.Sets[setId]
							end
						end
					end
				end
				
				if debugTooltips then
					d(string.format("  Tooltip check: ShowItemsNamesTooltip='%s', finalName='%s', ukrainianName='%s'", 
						tostring(DovahMova.Settings.ShowItemsNamesTooltip), tostring(finalName), tostring(ukrainianName)))
				end
				
				if DovahMova.Settings.ShowItemsNamesTooltip ~= "ua" and finalName and ukrainianName then
					
					if debugTooltips then
						d(string.format("  Setting tooltip name - finalName: '%s', ukrainianName: '%s'", tostring(finalName), tostring(ukrainianName)))
					end
					
					-- For ARMOR/WEAPON/JEWELRY items, we've already formatted the name as postfix
					-- For other items, format as postfix if needed
					if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_JEWELRY then
						-- Use the already formatted finalName (which contains the postfix)
						
						if debugTooltips then
							d(string.format("  Using finalName for ARMOR/WEAPON/JEWELRY tooltip: '%s'", finalName))
						end
						
						SafeAddString(SI_TOOLTIP_ITEM_NAME, finalName, 10)
					else
						-- Check if the name already has a postfix to prevent duplication
						-- This happens when itemsDisplay.lua has already formatted the name
						if string.find(ukrainianName, " %(") and string.find(ukrainianName, "%)$") then
							-- Name already has postfix, don't add another one
							SafeAddString(SI_TOOLTIP_ITEM_NAME, ukrainianName, 10)
						else
							if DovahMova.Settings.ShowItemsNamesTooltip == "uaen" then
								finalName = string.format("%s (%s)", ukrainianName, finalName)
							end
							
							SafeAddString(SI_TOOLTIP_ITEM_NAME, finalName, 10)
						end
					end
				end
				
				if DovahMova.Settings.ShowItemsEnchantsTooltip ~= "ua" and finalEnchant and rusEnchant then
					if DovahMova.Settings.ShowItemsEnchantsTooltip == "uaen" then
						finalEnchant = string.format("%s (%s)", rusEnchant, finalEnchant)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, finalEnchant), 10)
				end
				
				if DovahMova.Settings.ShowItemsTraitsTooltip ~= "ua" and finalTrait and rusTrait then
					if DovahMova.Settings.ShowItemsTraitsTooltip == "uaen" then
						finalTrait = string.format("%s (%s)", rusTrait, finalTrait)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, finalTrait, 10)
					SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER):gsub("<<2>>", finalTrait), 10)
				end
				
				if DovahMova.Settings.ShowItemsSetsTooltip ~= "ua" and finalSet and rusSet then
					if DovahMova.Settings.ShowItemsSetsTooltip == "uaen" then
						finalSet = string.format("«%s» (%s)", rusSet, finalSet)
					else
						finalSet = string.format("«%s»", finalSet)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, GetString(SI_ITEM_FORMAT_STR_SET_NAME):gsub("«<<1>>»", finalSet), 10)
				end
			end
		end
		
		local function itemTooltipHook(tooltipControl, method, linkFunc)
			local origMethod = tooltipControl[method]
			tooltipControl[method] = function(self, ...)
				
				if linkFunc then
					local lnk = linkFunc(...)
					modifyTooltip(lnk)
				end
				
				origMethod(self, ...)
					
				SafeAddString(SI_TOOLTIP_ITEM_NAME, DovahMova.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
			end
		end
		
		local function comparativeTooltipHook(tooltip, gameDataType, ...)
			if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
				local slotIndex, actorCategory = ...
				local itemLink = GetWornLink(slotIndex, GetWornBagForGameplayActorCategory(actorCategory))
				modifyTooltip(itemLink)				
			elseif gameDataType == TOOLTIP_GAME_DATA_STOLEN then
				SafeAddString(SI_TOOLTIP_ITEM_NAME, DovahMova.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
			end
		end
		
		--itemTooltipHook(AntiquityTooltip, "SetAntiquitySetFragment", AntiqTest)
		itemTooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
		itemTooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
		itemTooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
		itemTooltipHook(ItemTooltip, "SetLink", GetChatLink)
		itemTooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
		itemTooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
		itemTooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
		itemTooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
		itemTooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
		itemTooltipHook(ItemTooltip, "SetWornItem", GetWornLink)
		itemTooltipHook(ItemTooltip, "SetReward", GetItemRewardItemLink)
		itemTooltipHook(PopupTooltip, "SetLink", GetChatLink)
		itemTooltipHook(ItemTooltip, "SetItemUsingEnchantment", GetEnchantedItemResultingItemLink)
		itemTooltipHook(ItemTooltip, "SetAction", GetSlotItemLink)
		itemTooltipHook(ItemTooltip, "SetItemSetCollectionPieceLink", GetChatLink)
		
		ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", comparativeTooltipHook)
		ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", comparativeTooltipHook)
		
		itemTooltipHook(ZO_AlchemyTopLevelTooltip, "SetPendingAlchemyItem", CheckAlchemyName)
		itemTooltipHook(ZO_EnchantingTopLevelTooltip, "SetPendingEnchantingItem", GetEnchantingResultingItemLink)
		itemTooltipHook(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
		itemTooltipHook(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
		itemTooltipHook(ZO_SmithingTopLevelImprovementPanelResultTooltip, "SetSmithingImprovementResult", GetSmithingImprovedItemLink)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetPendingRetraitItem", GetResultingItemLinkAfterRetrait)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetBagItem", GetItemLink)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip, "SetItemSetCollectionPieceLink", GetChatLink)
		
		-- Gamepad PreHooks
		
		local function GamepadTooltipPreHook(tooltip, ...)
			modifyTooltip(itemLink)
		end
		
		local function GamepadTooltipPostHook()
			SafeAddString(SI_TOOLTIP_ITEM_NAME, DovahMova.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, DovahMova.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
		end
		
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),    "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),   "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		
		ZO_PreHook(ZO_GamepadSmithingCreation,    "SetupResultTooltip", function(tooltip, ...)   modifyTooltip(GetSmithingPatternResultLink(...)) end)
		ZO_PreHook(ZO_GamepadSmithingImprovement,    "SetupResultTooltip", function(tooltip, ...)   modifyTooltip(GetSmithingImprovedItemLink(...)) end)
		ZO_PreHook(ZO_GamepadAlchemy,    "UpdateTooltip", function(tooltip)   modifyTooltip(CheckAlchemyName(tooltip:GetAllCraftingBagAndSlots())) end)
		
		ZO_PreHook(ZO_GamepadEnchanting,    "UpdateTooltip", function(tooltip)
			if tooltip:IsCraftable() then
				modifyTooltip(GetEnchantingResultingItemLink(tooltip:GetAllCraftingBagAndSlots()))
			elseif tooltip:IsExtractable() and tooltip.extractionSlot:HasOneItem() then
				modifyTooltip(GetItemLink(tooltip.extractionSlot:GetItemBagAndSlot(1)))
			end
		end)
		
		ZO_PreHook(ZO_GamepadProvisioner,    "RefreshRecipeDetails", function(tooltip, selectedData)
			if selectedData then
				modifyTooltip(GetRecipeResultItemLink(selectedData.recipeListIndex, selectedData.recipeIndex))
				local prePostHook = tooltip.ingredientsBar.Clear
				ZO_PostHook(tooltip.ingredientsBar, "Clear", function()
					GamepadTooltipPostHook()
					tooltip.ingredientsBar.Clear = prePostHook
				end)
			end
		end)
		
		ZO_PreHook(ZO_GamepadSmithingExtraction,    "RefreshTooltip", function(tooltip)
			if tooltip.extractionSlot:HasOneItem() then
				local bagId, slotIndex = tooltip.extractionSlot:GetItemBagAndSlot(1)
				modifyTooltip(GetItemLink(bagId, slotIndex))
			end
		end)
		
		local prePostHookSm = ZO_GamepadSmithingImprovement.Refresh
		ZO_PreHook(ZO_GamepadSmithingImprovement, "Refresh", function(tooltip, ...)
			ZO_GamepadSmithingImprovement.Refresh = prePostHookSm
			ZO_PreHook(tooltip.sourceTooltip.tip, "LayoutImproveSourceSmithingItem", function(tlt, ...)
				local bagId, slotIndex = ...
				modifyTooltip(GetItemLink(bagId, slotIndex))
			end)
			
			ZO_PostHook(tooltip.sourceTooltip.tip, "LayoutImproveSourceSmithingItem", function(tlt, ...)
				GamepadTooltipPostHook()
			end)
		end)
		
		ZO_PreHook(ZO_RetraitStation_Retrait_Gamepad, "LayoutSourceItemTooltip", function(tooltip, itemData)
			if itemData then
				modifyTooltip(GetItemLink(itemData.bagId, itemData.slotIndex))
			end
		end)
		
		ZO_PreHook(ZO_RetraitStation_Retrait_Gamepad, "LayoutResultItemTooltip", function(tooltip, traitData)
			local itemData = tooltip.inventory:CurrentSelection()
			if itemData and traitData then
				local bagId = itemData.bagId
				local slotIndex = itemData.slotIndex
				local resultItemLink = GetResultingItemLinkAfterRetrait(bagId, slotIndex, traitData.trait)
				modifyTooltip(resultItemLink)
			end
		end)
		
		ZO_PreHook(ZO_RetraitStation_Reconstruct_Gamepad,    "RefreshResultTooltip", function(tooltip)
			if tooltip.itemSetPieceData and tooltip:IsOptionsModeShowing() then
				modifyTooltip(tooltip.itemSetPieceData:GetItemLink())
			end
		end)
		
		-- Gamepad PostHooks
		
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),   "LayoutItem", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),   "LayoutItem", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", function()   GamepadTooltipPostHook() end)
		
		ZO_PostHook(ZO_GamepadSmithingCreation,    "SetupResultTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadSmithingImprovement,    "SetupResultTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadAlchemy,    "UpdateTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadEnchanting,    "UpdateTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadProvisioner,    "RefreshRecipeDetails", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadSmithingExtraction,    "RefreshTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Retrait_Gamepad,    "LayoutSourceItemTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Retrait_Gamepad,    "LayoutResultItemTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Reconstruct_Gamepad,    "RefreshResultTooltip", function()   GamepadTooltipPostHook() end)
		
		-- Third-party Compatibility
		
		-- Tamriel Trade Centre
		if DovahMova:IsAddonRunning("TamrielTradeCentre") then
			if TamrielTradeCentre_ItemInfo then
				ZO_PreHook(TamrielTradeCentre_ItemInfo, "New", function() SafeAddString(SI_TOOLTIP_ITEM_NAME, DovahMova.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10) end)
			end
			
			if TamrielTradeCentre_MasterWritInfo then
				ZO_PreHook(TamrielTradeCentre_MasterWritInfo, "New", function() SafeAddString(SI_TOOLTIP_ITEM_NAME, DovahMova.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10) end)
			end
		end
		
		-- Item Set Browser
		if ItemBrowser then
			itemTooltipHook(ExtendedJournalItemTooltip, "SetLink", GetChatLink)
		end

		-- Wish List
		if WishList then
			itemTooltipHook(WishListTooltip, "SetLink", GetChatLink)
		end
	end
	
	-- Don't set the function to nil - it needs to be callable from settings
end
