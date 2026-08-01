--[[
MasterThief - Loot Processing Module
IMPORTANT: Contains ONLY the recipe/loot processing logic.
Helper functions like fCheckItemType stay in main file.
--]]

----------------------------------------
-- Initialize Module Table
----------------------------------------
if not MasterThief then
	MasterThief = {}
end

-- Local references for performance
local MT = MasterThief

----------------------------------------
-- Recipe/Furnishing Plan Processing
----------------------------------------
function MasterThief:DoActionLootItemRecipe(sName, iQuality, iInstancedLootId, itemLootLink)
	local itemType = GetItemLinkItemType(itemLootLink)
	
	-- Check specialized type for furnishings
	local _, specializedType = GetItemLinkItemType(itemLootLink)
	local isFurnishingPlan = (itemType == ITEMTYPE_FURNISHING and specializedType == SPECIALIZED_ITEMTYPE_FURNISHING_DESIGN)
	local isRecipe = (itemType == ITEMTYPE_RECIPE)
	
	-- This function should ONLY handle recipes and furnishing plans
	if not isRecipe and not isFurnishingPlan then
		-- Not a recipe or plan, don't process it here
		return
	end
	
	-- Check if we've already looked up this item in this session
	local cacheKey = itemLootLink
	local cachedResult = MasterThief.SessionKnowledgeCache[cacheKey]
	
	local bKnownByCurrentChar = false
	local bKnownByAnyChar = false
	
	-- Use cached result if available
	if cachedResult ~= nil then
		bKnownByCurrentChar = cachedResult.currentChar
		bKnownByAnyChar = cachedResult.anyChar
	else
		-- Query ESO API directly for current character knowledge
		-- IsItemLinkRecipeKnown handles both recipes and furnishing plans
		if isRecipe or isFurnishingPlan then
			bKnownByCurrentChar = IsItemLinkRecipeKnown(itemLootLink)
		end
		
		-- Check LibCharacterKnowledge if available and enabled
		if LibCharacterKnowledge and LibCharacterKnowledge.KNOWLEDGE_KNOWN and MasterThief.SavedVarsOptions.compareMyRecipes then
			local knowledgeList = LibCharacterKnowledge.GetItemKnowledgeList(itemLootLink)
			
			bKnownByAnyChar = false
			if knowledgeList and #knowledgeList > 0 then
				for _, charData in ipairs(knowledgeList) do
					if charData.knowledge == LibCharacterKnowledge.KNOWLEDGE_KNOWN then
						bKnownByAnyChar = true
						break
					end
				end
			else
				bKnownByAnyChar = bKnownByCurrentChar
			end
		else
			bKnownByAnyChar = bKnownByCurrentChar
		end
		
		-- Cache the result
		MasterThief.SessionKnowledgeCache[cacheKey] = {
			currentChar = bKnownByCurrentChar,
			anyChar = bKnownByAnyChar
		}
	end
	
	-- Determine which knowledge flag to use
	local bKnown = MasterThief.SavedVarsOptions.compareMyRecipes and bKnownByAnyChar or bKnownByCurrentChar
	
	-- Quality is 1-indexed in GetLootItemInfo, but our settings are 0-indexed
	local itemQuality = iQuality - 1
	local minQuality = MasterThief.SavedVarsOptions.MinRecipeQuality
	
	-- Get sell price
	local _, iSellPrice = GetItemLinkInfo(itemLootLink)
	
	-- SINGLE DECISION POINT - Track once based on final decision
	local shouldLoot = false
	
	if bKnown then
        -- Recipe/Plan is KNOWN
        if itemQuality >= minQuality then
            -- Known but high quality - loot for selling
           if MasterThief.SavedVarsOptions.SpecialOnScreenMsg or MasterThief.SavedVarsOptions.SpecialChatMsg then
				local quality = GetItemLinkQuality(itemLootLink)
				local qualityColor = GetItemQualityColor(quality)
				local coloredName = qualityColor:Colorize(GetItemLinkName(itemLootLink))
				MasterThief:ShowMessage(coloredName .. " (known)", 0)
			end
            shouldLoot = true
		else
			-- Known and low quality - skip
			if MasterThief.SavedVarsOptions.AnnounceKnownRecipes then
				local itemName = MasterThief:FixLinkName(itemLootLink)
				MasterThief:ShowMessage("MT: Known - "..itemName, 1)
			end
			shouldLoot = false
		end
	else
		-- Recipe/Plan is UNKNOWN
		if itemQuality >= minQuality then
			-- Unknown and meets quality - loot it
			shouldLoot = true
		elseif MasterThief.SavedVarsOptions.LootUnknownRecipesBelowLevel then
			-- Unknown + low quality but we want all unknowns - loot it
			shouldLoot = true
		else
			-- Unknown + low quality and don't want unknowns - skip
			shouldLoot = false
		end
	end
	
	-- Execute decision and track ONCE
	if shouldLoot then
		LootItemById(iInstancedLootId)
		MasterThief:TrackItemLooted(itemLootLink, iSellPrice, itemType)
		
		-- ANNOUNCE UNKNOWN RECIPES/PLANS
		if not bKnown then
			if MasterThief.SavedVarsOptions.SpecialOnScreenMsg or MasterThief.SavedVarsOptions.SpecialChatMsg then
				-- Get item quality for coloring
				local quality = GetItemLinkQuality(itemLootLink)
				local qualityColor = GetItemQualityColor(quality)
				local coloredName = qualityColor:Colorize(GetItemLinkName(itemLootLink))
				MasterThief:ShowMessage(coloredName, 0)
			end
		end
	else
		MasterThief:TrackItemSkipped()
	end
end

----------------------------------------
-- Recipe Knowledge Tracking
----------------------------------------
function MasterThief:SaveKnownRecipes(recipeNameFromLoot, bCompare)
	-- This function is now deprecated in favor of direct API calls
	-- We keep it for backward compatibility with the RecipeLearned event
	
	if bCompare then
		-- This path is never actually used anymore since DoActionLootItemRecipe
		-- now uses the ESO API directly. Return false as a safe fallback.
		return false
	end
	
	-- Clear session cache when recipes are learned to ensure fresh lookups
	if not bCompare then
		MasterThief.SessionKnowledgeCache = {}
	end
end

function MasterThief:IsKnownRecipeSaved(_recipeName)
	-- This function is deprecated but kept for compatibility
	-- Return values that won't break existing tooltip code
	return 0, false, nil
end

----------------------------------------
-- Lockpick Event Handlers
----------------------------------------
function MT.LOOT_CLOSED()
	-- Called when loot window closes
	processedLootInThisSession = {}
	lootClosedTime = GetGameTimeMilliseconds()
	lockpickChecked = false
	lockpickTargetType = nil
end

function MT.BEGIN_LOCKPICK(eventCode)
	EVENT_MANAGER:RegisterForEvent(MT.name, EVENT_LOCKPICK_SUCCESS, function(...) MT.LOCKPICK_SUCCESS(...) end)
	EVENT_MANAGER:RegisterForEvent(MT.name, EVENT_LOOT_CLOSED, function(...) MT.LOOT_CLOSED(...) end)
end

function MasterThief.LOCKPICK_SUCCESS(eventCode)
	bLockpickSuccessful = true
	lockpickSuccessTime = GetGameTimeMilliseconds()
	lockpickChecked = false
	
	-- Set a delayed check for doors (which don't open loot windows)
	zo_callLater(function()
		local timeSinceLootClosed = GetGameTimeMilliseconds() - lootClosedTime
		
		if not lockpickChecked then
			-- Check if LOOT_CLOSED fired within 5 seconds
			if timeSinceLootClosed < 5000 then
				lockpickChecked = true
			else
				-- No loot window at all = door
				lockpickChecked = true
				MasterThief:TrackDoorLockpicked()
			d("Safe to loot again")
			end
		end
	end, 5000)
end

function MT.LOCKPICK_FAILED(eventCode)
	lockpickChecked = false
end

function MT.UnregisterLockpick()
	EVENT_MANAGER:UnregisterForEvent(MT.name, EVENT_LOCKPICK_SUCCESS)
	EVENT_MANAGER:UnregisterForEvent(MT.name, EVENT_LOCKPICK_FAILED)
	EVENT_MANAGER:UnregisterForEvent(MT.name, EVENT_LOOT_CLOSED)
end

----------------------------------------
-- Loot Tooltip Integration
----------------------------------------
function MT:LootTooltip()
	-- Add custom tooltip to loot window showing if item is on loot list
	local originalSetLootItem = ItemTooltip.SetLootItem
	
	ItemTooltip.SetLootItem = function(control, lootId)
		originalSetLootItem(control, lootId)
		
		local itemLink = GetLootItemLink(lootId, LINK_STYLE_DEFAULT)
		if itemLink and itemLink ~= "" then
			if MT:isWorthfulItemOnScrollList(itemLink) then
				local itemOnLootList = GetString(MT_MISC_ITEM_TOOLTIP)
				control:AddLine("|c0092FF" .. itemOnLootList .. "|r")
			end
		end
	end
end