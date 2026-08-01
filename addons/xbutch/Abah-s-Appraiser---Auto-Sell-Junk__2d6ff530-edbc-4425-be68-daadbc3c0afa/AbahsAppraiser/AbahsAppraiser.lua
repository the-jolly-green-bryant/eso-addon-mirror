-- Initialize AC namespace if not exists
if not ASJ then ASJ = {} end

ASJ.addOnName = "AbahsAppraiser"
ASJ.addOnDisplayName = "Abah's Appraiser (Auto mark junk)"
ASJ.version = "1.49.07"
ASJ.author = "xbutch"
local C = ASJ.Config

ASJ.defaults = {
	asjStore = true,
	-- Trash items
	asjTrash = true,
	-- Collectibles
	asjMarkSellToMerchant = true,
	-- Misc item types
	asjTreasures = true,
	asjGlyphQualityThreshold = -1,
	asjCompanionItemsQualityThreshold = -1,
	-- Apparel/Weapons/Jewelry settings (shared logic)
	asjOrnate = true,
	asjApparelQualityThreshold = -1,
	asjIncludingSets = false,
	asjIntricate = false,
	asjIncludingKnownTraits = false,
	asjIncludingUnknownTraits = false,
	-- Deconstruction value protections
	asjIncludingDLCStyle = false, -- when false, protect DLC/area styles from being junked
	asjIncludingRareTraits = false, -- when false, protect rare/expensive traits from being junked
	-- Potions / Poisons
	asjAutoMarkNonCraftedPotionsPoisons = false, -- when true, non player-crafted potions & poisons become junk
	asjExcludeBastiansInsight = true, -- when true, keep Bastian's Insight potions out of junk
	-- Quest items
	asjClockworkCity = false,
	asjThievesGuild = false,
	asjEvents = false,
	-- Announcements / performance
	asjPerItemAnnouncements = false, -- individual junk lines outside bulk scans
	asjBulkScanSummary = true -- show one summary line after deferred scan
}
ASJ.variableVersion = 2

-- Announcement prefixes and fixed messages per event type
local PRE_PREFIX = "|cE5C07BASJ|r " -- soft gold
local PREFIX = PRE_PREFIX .. "<<1>>: "

local MSG_JUNK  = "Marked as junk."
local MSG_UNJUNK = "Removed from junk."
local MSG_QUEST  = "Quest item, kept."
local MSG_EVENT  = "Event item, kept."

-- Quest: "A Matter of Leisure"
local SI_TREASURE_ITEM_TAG_DESC_TOYS = "Children's Toys"
local SI_TREASURE_ITEM_TAG_DESC_DOLLS = "Dolls"
local SI_TREASURE_ITEM_TAG_DESC_GAMES = "Games"

-- Quest: "A Matter of Respect"
local SI_TREASURE_ITEM_TAG_DESC_UTENSILS = "Utensils"
local SI_TREASURE_ITEM_TAG_DESC_DRINKWARE = "Drinkware"
local SI_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE = "Dishes and Cookware"

-- Quest: "A Matter of Tributes"
local SI_TREASURE_ITEM_TAG_DESC_COSMETICS = "Cosmetics"
local SI_TREASURE_ITEM_TAG_DESC_GROOMING = "Grooming Items"

-- Quest: "The Covetous Countess" (only additional tags)
local SI_TREASURE_ITEM_TAG_DESC_LINENS = "Dry Goods"
local SI_TREASURE_ITEM_TAG_DESC_ACCESSORIES = "Wardrobe Accessories"
local SI_TREASURE_ITEM_TAG_DESC_STATUES = "Statues"
local SI_TREASURE_ITEM_TAG_DESC_WRITINGS = "Writings"
local SI_TREASURE_ITEM_TAG_DESC_SCRIVENER = "Scrivener Supplies"
local SI_TREASURE_ITEM_TAG_DESC_MAPS = "Maps"
local SI_TREASURE_ITEM_TAG_DESC_RITUAL_OBJECTS = "Ritual Objects"
local SI_TREASURE_ITEM_TAG_DESC_ODDITIES = "Oddities"

local ITEM_QUALITY = {
	ITEM_QUALITY_DISABLED = -1,
	ITEM_QUALITY_TRASH = 0,
	ITEM_QUALITY_NORMAL = 1,
	ITEM_QUALITY_MAGIC = 2,
	ITEM_QUALITY_ARCANE = 3,
	ITEM_QUALITY_ARTIFACT = 4,
	ITEM_QUALITY_LEGENDARY = 5,
	ITEM_QUALITY_ALL = 99
}

local JUNK = {
	TRASH_ITEMIDS = {
		NIBBLES_AND_BITS = {
			54381, -- Trash: Foul Hide
			54382, -- Trash: Carapace
			54383 -- Trash: Daedra Husk
		},
		MORSELS_AND_PECKS = {
			54384, -- Trash: Ectoplasm
			54385, -- Trash: Elemental Essence
			54388 -- Trash: Supple Root
		}
	}
}

local TREASURE_ITEM_TAGS = {
	A_MATTER_OF_LEISURE = {
		GetString(SI_TREASURE_ITEM_TAG_DESC_TOYS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_DOLLS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_GAMES)
	},
	A_MATTER_OF_RESPECT = {
		GetString(SI_TREASURE_ITEM_TAG_DESC_UTENSILS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_DRINKWARE),
		GetString(SI_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE)
	},
	A_MATTER_OF_TRIBUTES = {
		GetString(SI_TREASURE_ITEM_TAG_DESC_COSMETICS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_GROOMING)
	},
	THE_COVETOUS_COUNTESS = {
		GetString(SI_TREASURE_ITEM_TAG_DESC_COSMETICS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_LINENS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_ACCESSORIES),

		GetString(SI_TREASURE_ITEM_TAG_DESC_DRINKWARE),
		GetString(SI_TREASURE_ITEM_TAG_DESC_UTENSILS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE),

		GetString(SI_TREASURE_ITEM_TAG_DESC_GAMES),
		GetString(SI_TREASURE_ITEM_TAG_DESC_DOLLS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_STATUES),

		GetString(SI_TREASURE_ITEM_TAG_DESC_WRITINGS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_SCRIVENER),
		GetString(SI_TREASURE_ITEM_TAG_DESC_MAPS),

		GetString(SI_TREASURE_ITEM_TAG_DESC_RITUAL_OBJECTS),
		GetString(SI_TREASURE_ITEM_TAG_DESC_ODDITIES)
	}
}

--------------------------------------------------------------------
-- DEBUG Helper : simple debug print (disabled in release if needed)
-- ===== Early debug ring buffer (captures messages before /ac_debug) =====
local preDebugBuffer = {}
local preDebugBufferMax = 200
local function bufferDebugLine(txt)
	if #preDebugBuffer >= preDebugBufferMax then table.remove(preDebugBuffer, 1) end
	preDebugBuffer[#preDebugBuffer + 1] = txt
end

local debugEnabled = false -- shared flag everyone sees
local debugCount = 0
local addonInitialized = false

local function dbg(msg)
	-- capture everything in buffer (even if debug off) for later review
	bufferDebugLine(msg)
	if debugEnabled then
		debugCount = debugCount + 1
		if type(d) == 'function' then d('|c99CCFF[ASJ ' .. debugCount .. ']|r ' .. msg) end
	end
end

local function SwitchDebugMode()
	if debugEnabled then
		dbg('Debug disabled')
		debugEnabled = false
		debugCount = 0
	else
		debugEnabled = true
		dbg('Debug enabled')
		-- flush buffered lines (without double-buffering)
		if #preDebugBuffer > 0 then
			for _, ln in ipairs(preDebugBuffer) do
				debugCount = debugCount + 1
				if type(d) == 'function' then d('|c99CCFF[ASJ PRE ' .. debugCount .. ']|r ' .. ln) end
			end
		end
		if not addonInitialized then dbg('Addon not initialized yet (waiting for EVENT_ADD_ON_LOADED).') end
	end
end

--------------------------------------------------------------------
-- Event handling
--------------------------------------------------------------------
-- Directly register events with ESO. No external helpers needed.
local function RegisterForEvent(eventId, callback) EVENT_MANAGER:RegisterForEvent(ASJ.addOnName, eventId, callback) end

-- Add event filters with correct ESO signature (namespace, eventId, filterType, filterParam)
local function RegisterFilterForEvent(eventId, filterID, filterValue) if filterID ~= nil and filterValue ~= nil then EVENT_MANAGER:AddFilterForEvent(ASJ.addOnName, eventId, filterID, filterValue) end end

local function UnregisterForEvent(eventId) EVENT_MANAGER:UnregisterForEvent(ASJ.addOnName, eventId) end

--------------------------------------------------------------------
-- Options value handling
--------------------------------------------------------------------

--------------------------------------------------------------------
-- Addon initialization
--------------------------------------------------------------------

-- Controlled announcement function (respects performance settings)

local function AnnounceJunk(itemLink, message)
	if ASJ._bulkScanning then return end
	local SV = ASJ.savedVars or ASJ.defaults
	if not SV.asjPerItemAnnouncements then return end
	local tmpl = PREFIX .. (message or MSG_JUNK)
	local out = zo_strformat and zo_strformat(tmpl, itemLink) or tostring(tmpl):gsub("<<1>>", tostring(itemLink))
	if type(d) == 'function' then d(out) end
end

local function MarkItemAsJunk(bagId, slotIndex, silent)
	local isJunk = IsItemJunk(bagId, slotIndex)
	if isJunk then return false end
	local itemLink = GetItemLink(bagId, slotIndex)
	SetItemIsJunk(bagId, slotIndex, true)
	if not silent then AnnounceJunk(itemLink, MSG_JUNK) end
	return true
end

local function UnmarkItemAsJunk(bagId, slotIndex, silent)
	local isJunk = IsItemJunk(bagId, slotIndex)
	if not isJunk then return false end
	local itemLink = GetItemLink(bagId, slotIndex)
	SetItemIsJunk(bagId, slotIndex, false)
	if not silent then AnnounceJunk(itemLink, MSG_UNJUNK) end
	return true
end

-- Check if item is quest-excluded for trash logic
local function isTrashItemQuestJunkable(bagId, slotIndex)
	local SV = ASJ.savedVars or ASJ.defaults
	if SV.asjClockworkCity then return true end -- no exclusions apply
	local itemId = GetItemId(bagId, slotIndex)
	for _, constItemId in pairs(JUNK.TRASH_ITEMIDS.NIBBLES_AND_BITS) do
		if itemId == constItemId then
			AnnounceJunk(GetItemLink(bagId, slotIndex), MSG_QUEST)
			return false
		end
	end
	for _, constItemId in pairs(JUNK.TRASH_ITEMIDS.MORSELS_AND_PECKS) do
		if itemId == constItemId then
			AnnounceJunk(GetItemLink(bagId, slotIndex), MSG_QUEST)
			return false
		end
	end
	return true
end

-- Check if item is quest-excluded for sell-to-merchant logic
local function isSellToMerchantItemQuestJunkable(specializedItemType, itemLink)
	local SV = ASJ.savedVars or ASJ.defaults
	if SV.asjEvents then return true end
	if specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH then
		local ItemId = GetItemLinkItemId(itemLink)
		if ItemId >= 100393 and ItemId <= 100395 then
			AnnounceJunk(itemLink, MSG_EVENT)
			return false
		end
	end
	return true
end

-- Check if item is quest-excluded for treasure logic
local function isTreasureItemQuestJunkable(itemLink)
	local SV = ASJ.savedVars or ASJ.defaults
	if SV.asjClockworkCity and SV.asjThievesGuild then return true end
	local numItemTags = GetItemLinkNumItemTags(itemLink)
	for itemTagIndex = 1, numItemTags do
		local itemTagDescription, itemTagCategory = GetItemLinkItemTagInfo(itemLink, itemTagIndex)
		local itemTagDescriptionFmt = zo_strformat("<<1>>", itemTagDescription, 1)
		if itemTagCategory == TAG_CATEGORY_TREASURE_TYPE then
			if not SV.asjClockworkCity then
				for _, itemTagKey in pairs(TREASURE_ITEM_TAGS.A_MATTER_OF_LEISURE) do
					if itemTagDescriptionFmt == itemTagKey then
						AnnounceJunk(itemLink, MSG_QUEST)
						return false
					end
				end
				for _, itemTagKey in pairs(TREASURE_ITEM_TAGS.A_MATTER_OF_RESPECT) do
					if itemTagDescriptionFmt == itemTagKey then
						AnnounceJunk(itemLink, MSG_QUEST)
						return false
					end
				end
				for _, itemTagKey in pairs(TREASURE_ITEM_TAGS.A_MATTER_OF_TRIBUTES) do
					if itemTagDescriptionFmt == itemTagKey then
						AnnounceJunk(itemLink, MSG_QUEST)
						return false
					end
				end
			end
			if not SV.asjThievesGuild then
				for _, itemTagKey in pairs(TREASURE_ITEM_TAGS.THE_COVETOUS_COUNTESS) do
					if itemTagDescriptionFmt == itemTagKey then
						AnnounceJunk(itemLink, MSG_QUEST)
						return false
					end
				end
			end
		end
	end
	return true
end

-- Reverse style logic: treat ANY non-basic style as DLC/valuable so we don't have to maintain a growing whitelist.
-- Basic styles: core racial styles available from the start + a few early common styles.
-- Basic racial styles: Breton=1 .. Khajiit=9 (confirmed), assume contiguous block.
local BASIC_STYLE_MIN = 1
local BASIC_STYLE_MAX = 9
local BASIC_STYLE_IMPERIAL = 34

local function isBasicStyle(styleId) return (type(styleId) == "number" and ((styleId >= BASIC_STYLE_MIN and styleId <= BASIC_STYLE_MAX) or styleId == BASIC_STYLE_IMPERIAL)) end

local function isDLCOrValuableStyle(itemLink)
	if not itemLink or itemLink == "" then return false end
	local styleId = GetItemLinkItemStyle(itemLink)
	if not styleId then return false end
	return (not isBasicStyle(styleId))
end

-- Rare/expensive trait detection (focus on Nirnhoned and valuable jewelry traits)
local RARE_TRAITS = {}
local function _addTrait(t) if t ~= nil then RARE_TRAITS[t] = true end end
_addTrait(ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)
_addTrait(ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)
_addTrait(ITEM_TRAIT_TYPE_JEWELRY_SWIFT)
_addTrait(ITEM_TRAIT_TYPE_JEWELRY_INFUSED)
_addTrait(ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY)
_addTrait(ITEM_TRAIT_TYPE_JEWELRY_HARMONY)
_addTrait(ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)

local function hasRareOrValuableTrait(itemTrait) return itemTrait ~= nil and RARE_TRAITS[itemTrait] == true end

-- Detect Bastian's Insight potions (heuristic: name contains both 'Bastian' and 'Insight').
local BASTIAN_POTION_NAMES = {
	["essence of potent magicka"] = true,
	["essence of potent stamina"] = true,
	["essence of potent health"] = true
}
local function isBastiansInsightPotion(itemLink)
	if not itemLink or itemLink == '' then return false end
	local name
	if GetItemLinkName then pcall(function() name = GetItemLinkName(itemLink) end) end
	name = name or tostring(itemLink)
	name = string.lower(name)
	return BASTIAN_POTION_NAMES[name] == true
end

-- Companion items
-- Check if item is for companion (to apply companion-specific quality threshold)
local function isItemForCompanion(bagId, slotIndex)
	local actorCategory = GetItemActorCategory(bagId, slotIndex)
	return actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION
end

local function SellCompanionItems()
	local SV = ASJ.savedVars or ASJ.defaults
	local threshold = SV.asjCompanionItemsQualityThreshold or ITEM_QUALITY.ITEM_QUALITY_DISABLED
	if threshold == ITEM_QUALITY.ITEM_QUALITY_DISABLED then
		dbg('Companion sell: disabled (threshold = -1).')
		return
	end
	local bagId = BAG_BACKPACK
	local lastIndex = GetBagSize(bagId) - 1
	local sold, skipped = 0, 0
	for slotIndex = 0, lastIndex do
		if isItemForCompanion(bagId, slotIndex) then
			local itemQuality = GetItemFunctionalQuality(bagId, slotIndex)
			local itemLink = GetItemLink(bagId, slotIndex)
			if itemQuality > threshold then
				skipped = skipped + 1
				dbg('Companion skip above threshold: ' .. tostring(itemLink))
			else
				local stack = GetSlotStackSize(bagId, slotIndex) or 1
				if stack < 1 then stack = 1 end
				SellInventoryItem(bagId, slotIndex, stack)
				sold = sold + 1
			end
		end
	end
	dbg(string.format('Companion sell complete: %d sold, %d skipped (threshold=%s).', sold, skipped, tostring(threshold)))
end

-- Extracted shared logic: applies junk rules for a single bag/slot
-- Returns: true if the item was marked as junk, false otherwise
local function ApplyJunkRules(bagId, slotIndex)
	-- Resolve link and types once
	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink or itemLink == "" then return false end

	local itemType, specializedItemType = GetItemType(bagId, slotIndex)
	local sellInformation = GetItemLinkSellInformation(itemLink)
	local SV = ASJ.savedVars or ASJ.defaults

	-- cannot sell items are not junk, even if they match other rules (e.g. some quest items, some event items, etc.)
	if sellInformation == ITEM_SELL_INFORMATION_CANNOT_SELL then
		return false
	end

	-- Always exclude player-crafted items
	if IsItemLinkCrafted and IsItemLinkCrafted(itemLink) then
		dbg('Skipping player-crafted item: ' .. tostring(itemLink))
		return false
	end

	-- Trash items
	if (itemType == ITEMTYPE_TRASH or specializedItemType == SPECIALIZED_ITEMTYPE_TRASH) then
		if SV.asjTrash then
			if not isTrashItemQuestJunkable(bagId, slotIndex) then
				dbg("Skipping quest-excluded trash item: " .. tostring(itemLink))
				return false
			end
			-- If we reach here, the item is trash and can be junked
			return true
		end
	end

	-- Treasures
	if (itemType == ITEMTYPE_TREASURE or specializedItemType == SPECIALIZED_ITEMTYPE_TREASURE) then
		if SV.asjTreasures then
			if not isTreasureItemQuestJunkable(itemLink) then
				dbg("Skipping quest-excluded treasure item: " .. tostring(itemLink))
				return false
			end
			-- If we reach here, the item is treasure and can be junked
			return true
		end
	end

	-- Sell to merchant for gold (collectibles)
	if sellInformation == ITEM_SELL_INFORMATION_PRIORITY_SELL then
		if SV.asjMarkSellToMerchant then
			if not isSellToMerchantItemQuestJunkable(specializedItemType, itemLink) then
				dbg("Skipping quest-excluded collectible item: " .. tostring(itemLink))
				return false
			end
			-- If we reach here, the item is a collectible sellable to merchant and can be junked
			return true
		end
	end

	-- Potions / Poisons (non-crafted) handling
	if SV.asjAutoMarkNonCraftedPotionsPoisons and (itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) then
		-- Optionally exclude Bastian's Insight potions
		if SV.asjExcludeBastiansInsight and isBastiansInsightPotion(itemLink) then
			dbg("Protected Bastian's Insight potion: " .. tostring(itemLink))
			return false
		end
		-- Non-crafted potions/poisons are junk
		return true
	end

	-- Get item quality once
	local itemQuality = GetItemFunctionalQuality(bagId, slotIndex)

	-- Glyphs
	if (itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) then
		local threshold = SV.asjGlyphQualityThreshold or ITEM_QUALITY.ITEM_QUALITY_DISABLED
		-- Disabled means: never auto-junk glyphs
		if threshold == ITEM_QUALITY.ITEM_QUALITY_DISABLED then return false end

		-- If item quality is ABOVE threshold, protect (skip)
		if itemQuality > threshold then
			dbg("Skipping glyph (quality above threshold): " .. tostring(itemLink))
			return false
		end
		-- Otherwise (quality <= threshold) mark as junk
		return true
	end

	-- Apparel
	if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
		-- Quality threshold (weapon/armor/jewelry)
		local qualityThreshold = SV.asjApparelQualityThreshold or ITEM_QUALITY.ITEM_QUALITY_DISABLED
		-- If threshold is disabled (-1) we do not filter by quality; otherwise skip items above threshold
		if qualityThreshold ~= ITEM_QUALITY.ITEM_QUALITY_DISABLED and itemQuality > qualityThreshold then
			dbg("Skipping apparel (quality above threshold): " .. tostring(itemLink))
			return false
		end

		-- Set items
		-- If including sets, treat set items as normal items (apply trait rules)
		local hasSet = GetItemLinkSetInfo(itemLink, false)
		if hasSet and not SV.asjIncludingSets then
			dbg("Skipping set item: " .. tostring(itemLink))
			return false
		end

		-- Traits
		-- No trait (normal) items are always junk
		local itemTraitType = GetItemLinkTraitType(itemLink)
		if itemTraitType ~= ITEM_TRAIT_TYPE_NONE then
			local canBeResearched = CanItemLinkBeTraitResearched(itemLink)
			local include = (canBeResearched and SV.asjIncludingUnknownTraits) or (not canBeResearched and SV.asjIncludingKnownTraits)
			if not include then
				dbg("Skipping item due to trait settings: " .. tostring(itemLink))
				return false
			end
		end

		local itemTrait = GetItemTrait(bagId, slotIndex)

		-- Preserve intricate items if the user does NOT want them auto-junked
		-- When asjIntricate = false, intricate items are protected from other rules
		if (itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE) then
			if not SV.asjIntricate then
				dbg('Protected intricate item (setting OFF): ' .. tostring(itemLink))
				return false
			end
		end

		-- Ornate trait (weapon/armor/jewelry)
		if SV.asjOrnate then
			if (itemTrait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or itemTrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) then
				dbg('Ornate item marked as junk: ' .. tostring(itemLink))
				return true
			end
		end

		-- Intricate trait (weapon/armor/jewelry)
		if SV.asjIntricate then
			if (itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE) then
				dbg('Intricate item marked as junk: ' .. tostring(itemLink))
				return true
			end
		end

		-- Protect rare/valuable traits from being junked if toggle is set to exclude them
		local protectTrait = (ASJ.savedVars.asjIncludingRareTraits == false) and hasRareOrValuableTrait(itemTrait)
		if protectTrait then
			dbg('Protected from junking due to rare trait: ' .. tostring(itemLink))
			return false
		end

		-- Protect DLC/valuable style or rare traits from being junked if toggles are set to exclude them
		local protectStyle = (ASJ.savedVars.asjIncludingDLCStyle == false) and isDLCOrValuableStyle(itemLink)
		if protectStyle then
			dbg('Protected from junking due to DLC style: ' .. tostring(itemLink))
			return false
		end

		-- If we reach here, the item is apparel and can be junked
		return true
	end

	-- If we reach here, no junk rules matched
	-- dbg("No junk rules matched for: " .. tostring(itemLink))
	return false
end

local function OnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
	dbg('OnInventorySingleSlotUpdate called')
	-- pcall guards against any runtime error: ESO permanently unregisters an event callback
	-- that throws, so a crash here (e.g. from a race with another inventory addon) would
	-- silently stop all future junk-marking until the next UI reload.
	local ok, err = pcall(function()
		if ApplyJunkRules(bagId, slotIndex) then MarkItemAsJunk(bagId, slotIndex) end
	end)
	if not ok then dbg('OnInventorySingleSlotUpdate error: ' .. tostring(err)) end
end

-- =============================================================
-- Deferred Backpack Scan (time-sliced to stay under frame budget)
-- =============================================================
ASJ.scanSliceTimeMS = 8 -- approx processing time budget per slice
ASJ.scanSliceDelayMS = 5 -- delay between slices (ms)

local scanState = {
	running = false,
	bag = BAG_BACKPACK,
	nextSlot = 0,
	lastIndex = 0, -- last slot index (bag size - 1)
	processed = 0,
	junked = 0,
	unjunked = 0,
	silent = true,
	skippedEmpty = 0,
	showSummary = true
}

local function ProcessScanSlice()
	if not scanState.running then return end
	local start = GetFrameTimeMilliseconds()
	local bagId = scanState.bag
	while scanState.nextSlot <= scanState.lastIndex do
		local slotIndex = scanState.nextSlot
		if HasItemInSlot(bagId, slotIndex) then
			scanState.processed = scanState.processed + 1
			if ApplyJunkRules(bagId, slotIndex) then
				if MarkItemAsJunk(bagId, slotIndex, true) then scanState.junked = scanState.junked + 1 end
			else
				if UnmarkItemAsJunk(bagId, slotIndex, true) then scanState.unjunked = scanState.unjunked + 1 end
			end
		else
			scanState.skippedEmpty = scanState.skippedEmpty + 1
		end
		scanState.nextSlot = scanState.nextSlot + 1
		if (GetFrameTimeMilliseconds() - start) >= ASJ.scanSliceTimeMS then break end
	end
	if scanState.nextSlot > scanState.lastIndex then
		scanState.running = false
		ASJ._bulkScanning = false
		if type(d) == 'function' then
			if scanState.showSummary then
				if ASJ.savedVars and ASJ.savedVars.asjBulkScanSummary then
					local msg = string.format("%d junked, %d unjunked (processed %d, empty %d, slots %d).", scanState.junked, scanState.unjunked, scanState.processed, scanState.skippedEmpty, scanState.lastIndex + 1)
					d(PRE_PREFIX .. msg)
				end
			end
		end
		dbg(string.format('Deferred scan complete (processed=%d empty=%d totalSlots=%d).', scanState.processed, scanState.skippedEmpty, scanState.lastIndex + 1))
	else
		zo_callLater(ProcessScanSlice, ASJ.scanSliceDelayMS)
	end
end

local function StartDeferredScan(force, showSummary)
	if scanState.running and not force then return end
	scanState.bag = BAG_BACKPACK
	scanState.nextSlot = 0
	scanState.lastIndex = GetBagSize(scanState.bag) - 1
	scanState.processed = 0
	scanState.junked = 0
	scanState.unjunked = 0
	scanState.skippedEmpty = 0
	scanState.showSummary = (showSummary ~= false)
	scanState.running = true
	ASJ._bulkScanning = true
	dbg(string.format('Starting deferred backpack scan (slot range 0..%d, used=%d).', scanState.lastIndex, GetNumBagUsedSlots(scanState.bag)))
	zo_callLater(ProcessScanSlice, 0)
end

local function ScanBackpackForJunk(forceSync)
	if forceSync then
		dbg('ScanBackpackForJunk (synchronous) called')
		local bagId = BAG_BACKPACK
		local lastIndex = GetBagSize(bagId) - 1
		local junked, unjunked, processed, empty = 0, 0, 0, 0
		ASJ._bulkScanning = true -- still suppress per-item spam
		for slotIndex = 0, lastIndex do
			if HasItemInSlot(bagId, slotIndex) then
				processed = processed + 1
				if ApplyJunkRules(bagId, slotIndex) then
					if MarkItemAsJunk(bagId, slotIndex, true) then junked = junked + 1 end
				else
					if UnmarkItemAsJunk(bagId, slotIndex, true) then unjunked = unjunked + 1 end
				end
			else
				empty = empty + 1
			end
		end
		ASJ._bulkScanning = false
		if ASJ.savedVars and ASJ.savedVars.asjBulkScanSummary then if type(d) == 'function' then d(PRE_PREFIX .. string.format("Bulk scan: %d junked, %d unjunked (processed %d empty %d totalSlots %d).", junked, unjunked, processed, empty, lastIndex + 1)) end end
		dbg(string.format('Synchronous scan complete (processed=%d empty=%d totalSlots=%d).', processed, empty, lastIndex + 1))
	else
		StartDeferredScan(true)
	end
end

-- Public API
ASJ.StartDeferredScan = StartDeferredScan
ASJ.SellCompanionItems = SellCompanionItems

local function OnShopOpen()
	dbg('OnShopOpen called')
	if ASJ.savedVars.asjStore then
		SellAllJunk() -- sell standard junk first
		SellCompanionItems() -- then companion items within threshold
		d(PRE_PREFIX .. "Sold junk items.")
	else
		dbg("Skipping junk sell to store (disabled in settings)")
	end
end

-- onLoad initializion
local function OnLoad(eventCode, name)
	if name ~= ASJ.addOnName then return end
	dbg('OnLoad called for ' .. tostring(name) .. ' (char=' .. GetUnitName('player') .. ')')

	ASJ.savedVars = ZO_SavedVars:NewAccountWide(C.SAVEDVARS, ASJ.variableVersion, nil, ASJ.defaults)

	-- Migration shim for old key names (if any)
	local SV = ASJ.savedVars
	if SV.autoMarkIncludingSets ~= nil and SV.asjIncludingSets == nil then SV.asjIncludingSets = SV.autoMarkIncludingSets end
	if SV.autoMarkQualityThreshold ~= nil and SV.asjApparelQualityThreshold == ASJ.defaults.asjApparelQualityThreshold then SV.asjApparelQualityThreshold = SV.autoMarkQualityThreshold end
	-- Additional legacy key migrations (options file former names)
	if SV.asjSellToMerchant ~= nil and SV.asjMarkSellToMerchant == nil then SV.asjMarkSellToMerchant = SV.asjSellToMerchant end
	if SV.asjGlyphsQuality ~= nil and SV.asjGlyphQualityThreshold == nil then SV.asjGlyphQualityThreshold = SV.asjGlyphsQuality end
	if SV.asjCompanionQuality ~= nil and SV.asjCompanionItemsQualityThreshold == nil then SV.asjCompanionItemsQualityThreshold = SV.asjCompanionQuality end

	-- Options panel callback + dirty flag removed; user triggers scan manually via button.
	if ASJ.CreateOptions then ASJ:CreateOptions() end

	dbg('OnLoad: Registering vendor open/close events')
	RegisterForEvent(EVENT_OPEN_STORE, OnShopOpen)
	RegisterForEvent(EVENT_CLOSE_STORE, function()
		dbg('OnShopClose: deferred scan to catch items missed during vendor session')
		StartDeferredScan(true, false)
	end)

	RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)
	RegisterFilterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
	RegisterFilterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	RegisterFilterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

	dbg('onLoad: Unregistering for EVENT_ADD_ON_LOADED')
	UnregisterForEvent(EVENT_ADD_ON_LOADED)

	addonInitialized = true
end

--------------------------------------------------------------------
-- Slash Commands for Testing and Debug
--------------------------------------------------------------------
if GetDisplayName() == "@XBUTCH" or GetDisplayName() == "@xbutch"  then
	SLASH_COMMANDS['/asj_debug'] = SwitchDebugMode
	SLASH_COMMANDS['/asj_scan'] = function(arg)
		if arg == 'sync' then
			ScanBackpackForJunk(true)
		else
			StartDeferredScan(true)
		end
	end
end

-- Register for event onload
EVENT_MANAGER:RegisterForEvent(ASJ.addOnName, EVENT_ADD_ON_LOADED, OnLoad)